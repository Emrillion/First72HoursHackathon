import SwiftUI

struct CircleView: View {
    @EnvironmentObject var store: AppStore
    @State private var inviting = false
    @State private var joining = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("You have a circle.").font(.title.bold())
                Text("Bring people together around the everyday things.").foregroundStyle(CareTheme.muted)
                if store.state.canCoordinate {
                    Button { inviting = true } label: { Label("Invite someone", systemImage: "person.badge.plus") }
                        .buttonStyle(PrimaryButton()).accessibilityIdentifier("inviteSomeone")
                }
                Button("Have a join code?") { joining = true }
                    .frame(maxWidth: .infinity, minHeight: 44).accessibilityIdentifier("enterJoinCode")
                CareCard {
                    Text("Your people").font(.title3.bold())
                    ForEach(store.state.members) { member in
                        HStack(spacing: 12) {
                            Text(String(member.name.prefix(1))).font(.headline)
                                .frame(width: 44, height: 44).background(CareTheme.mint).clipShape(Circle())
                            VStack(alignment: .leading, spacing: 4) {
                                Text(member.name).font(.headline)
                                Text(member.role.rawValue + (member.id == store.state.activeMemberID ? " · viewing as" : ""))
                                    .font(.subheadline).foregroundStyle(CareTheme.muted)
                                let count = store.state.visibleTasks().filter { $0.ownerID == member.id && $0.status != .completed }.count
                                if count > 0 { Text("Helping with \(count) task\(count == 1 ? "" : "s")").font(.footnote) }
                            }
                        }.padding(.vertical, 4)
                    }
                    if !store.state.members.contains(where: { $0.role == .supporter }) {
                        Text("You can manage your own plan or find services in Find Help.").font(.callout)
                    }
                }
                NavigationLink { DemoSettingsView() } label: {
                    Label("Plan & demo settings", systemImage: "gearshape").frame(minHeight: 44)
                }.accessibilityIdentifier("demoSettings")
                DemoNotice()
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Your circle").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $inviting) { InviteView() }
            .sheet(isPresented: $joining) { JoinPlanView() }
    }
}

struct InviteView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text("A small ask. A little more support.").font(.title.bold())
                    Text("Invite a supporter to \(store.state.plan?.patientName ?? "your patient")’s care plan.")
                    CareCard {
                        Label("On this device only", systemImage: "iphone").font(.headline)
                        Text("Generate a code, then enter it in Circle → Have a join code? to try joining as a new supporter. Other devices cannot use this code yet.").font(.callout)
                    }
                    if let invitation = store.state.invitation {
                        CareCard {
                            Text("JOIN CODE").font(.caption.bold()).foregroundStyle(CareTheme.muted)
                            Text(invitation.code).font(.title.monospaced().bold()).textSelection(.enabled)
                                .accessibilityIdentifier("generatedJoinCode")
                            Text("One use · expires \(invitation.expiresAt.careDate)").font(.subheadline)
                            Text("Supporters can view shared tasks and volunteer to help. Private tasks remain private.").font(.callout)
                        }
                        Button("Generate a new code") { store.change { try $0.generateJoinCode() } }
                            .buttonStyle(PrimaryButton()).accessibilityIdentifier("generateJoinCode")
                        Text("A new code replaces the previous one.").font(.footnote).foregroundStyle(CareTheme.muted)
                        Button("Revoke code", role: .destructive) { store.change { try $0.revokeJoinCode() } }.frame(minHeight: 44)
                    } else {
                        Button("Generate join code") { store.change { try $0.generateJoinCode() } }
                            .buttonStyle(PrimaryButton()).accessibilityIdentifier("generateJoinCode")
                    }
                }.padding(16)
            }.background(CareTheme.cloud).navigationTitle("Invite to your plan").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .confirmationAction) { Button("Done") { dismiss() } } }
        }
    }
}

struct JoinPlanView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) private var dismiss
    @State private var code = ""
    @State private var name = ""
    @State private var message: String?
    @State private var joined = false
    var body: some View {
        NavigationStack {
            Form {
                if joined {
                    Section {
                        Label("You’re in the circle", systemImage: "checkmark.circle.fill").font(.title2.bold())
                        Text("You’re now viewing the plan as \(store.state.activeMember?.name ?? "a supporter"). Open Plan and choose a shared task to help with.")
                        Button("Back to circle") { dismiss() }.accessibilityIdentifier("joinedDone")
                    }
                } else {
                    Section {
                        Text("Join a care plan").font(.title2.bold())
                        Text("This prototype accepts codes generated on this device only. Use a fictional name.")
                    }
                    Section("Invitation details") {
                        TextField("Join code", text: $code).textInputAutocapitalization(.characters)
                            .autocorrectionDisabled().accessibilityIdentifier("joinCodeInput")
                        TextField("Your display name", text: $name).textContentType(.nickname)
                            .accessibilityIdentifier("joinNameInput")
                    }
                    Section {
                        Text("You’ll join as a supporter and see only tasks shared with the circle.").font(.callout)
                        if let message { Text(message).foregroundStyle(CareTheme.amber).accessibilityIdentifier("joinError") }
                        Button("Join care plan") {
                            // Keep validation next to the form; persistence failures use the app's normal alert.
                            do {
                                var next = store.state
                                try next.joinPlan(code: code, name: name)
                                if store.change({ $0 = next }) { joined = true; message = nil }
                            } catch { message = error.localizedDescription }
                        }.buttonStyle(PrimaryButton())
                            .disabled(code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                            .accessibilityIdentifier("joinPlan")
                    }
                }
            }.navigationTitle("Join with a code").navigationBarTitleDisplayMode(.inline)
                .toolbar { ToolbarItem(placement: .cancellationAction) { Button("Close") { dismiss() } } }
        }
    }
}

struct DemoSettingsView: View {
    @EnvironmentObject var store: AppStore
    @State private var resetting = false
    @State private var resetWithoutSupporter = false
    @State private var preferences = false
    var body: some View {
        Form {
            Section {
                Text("Try the same plan as a different person. These are local demo roles, not signed-in accounts.")
                ForEach(store.state.members) { member in
                    Button { store.change { try $0.switchMember(member.id) } } label: {
                        HStack {
                            VStack(alignment: .leading) {
                                Text(member.name)
                                Text(member.role.rawValue).font(.caption).foregroundStyle(CareTheme.muted)
                            }
                            Spacer()
                            if member.id == store.state.activeMemberID { Image(systemName: "checkmark") }
                        }.frame(minHeight: 44)
                    }.accessibilityIdentifier("role-\(member.role.rawValue)")
                }
            } header: { Text("Viewing as \(store.state.activeMember?.name ?? "" )") }
            if store.state.canCoordinate {
                Section("Optional service budget") {
                    Text("\(store.state.remainingCents.dollars) remaining of \((store.state.plan?.budgetCents ?? 0).dollars)")
                    Text("For sample meals and rides only. Hospital platform billing is separate.").font(.footnote)
                    Button("Edit budget & destination") { preferences = true }
                }
            }
            Section("About this prototype") {
                Text("Saved on this device. Join codes add local supporters; shared accounts, device sync, provider connections, and notifications are not connected.")
                Text("Use fictional details only. CareShare organizes practical help, not clinical guidance.")
                Button("Reset demo plan", role: .destructive) { resetWithoutSupporter = false; resetting = true }.accessibilityIdentifier("resetDemo")
                Button("Try a plan without supporters") { resetWithoutSupporter = true; resetting = true }
            }
        }.navigationTitle("Plan & demo settings").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $preferences) { PreferencesView() }
            .confirmationDialog("Replace this device’s demo plan?", isPresented: $resetting, titleVisibility: .visible) {
                Button("Replace with fresh demo", role: .destructive) { store.reset(withSupporter: !resetWithoutSupporter) }
            } message: { Text("This removes local tasks, join codes, demo receipts, and activity, then creates a fresh fictional plan.") }
    }
}

struct PreferencesView: View {
    @EnvironmentObject var store: AppStore
    @Environment(\.dismiss) var dismiss
    @State private var budget = ""
    @State private var hasDestination = true
    var body: some View {
        NavigationStack {
            Form {
                Section("Spending limit") {
                    TextField("Whole US dollars", text: $budget).keyboardType(.numberPad)
                    Text("$0 is welcome. A spending limit is not a payment or a funding promise.")
                }
                Section("Service destination") {
                    Toggle("I have a confirmed place to stay", isOn: $hasDestination)
                    Text("If you’re unsure where you’ll stay, ask your discharge coordinator or a local support worker for help. A resource listing is not a confirmed destination.")
                }
            }.navigationTitle("Plan preferences").navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            guard let amount = Int(budget), (0...10000).contains(amount) else {
                                store.errorMessage = "Enter a whole-dollar amount from 0 to 10,000."; return
                            }
                            if store.change({ try $0.updatePreferences(budgetCents: amount * 100, hasDestination: hasDestination) }) { dismiss() }
                        }
                    }
                }.onAppear { budget = String((store.state.plan?.budgetCents ?? 0) / 100); hasDestination = store.state.plan?.hasDestination ?? false }
        }
    }
}
