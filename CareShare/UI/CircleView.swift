import SwiftUI

struct CircleView: View {
    @EnvironmentObject var store: AppStore
    @State private var resetting = false
    @State private var resetWithoutSupporter = false
    @State private var preferences = false
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Care works better\ntogether.").font(.largeTitle.bold())
                Text("See who’s here, and who’s taking care of what.").foregroundStyle(CareTheme.muted)
                DemoNotice()
                CareCard {
                    Text("Try another perspective").font(.title3.bold())
                    Text("These are fictional roles on one device. Switching demonstrates the same shared plan; it is not an account login.").font(.callout).foregroundStyle(CareTheme.muted)
                    ForEach(store.state.members) { member in
                        Button { store.change { try $0.switchMember(member.id) } } label: {
                            HStack(alignment: .center, spacing: 14) {
                                Text(String(member.name.prefix(1))).font(.title3.bold())
                                    .frame(width: 48, height: 48).background(CareTheme.mint).clipShape(Circle())
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(member.name).font(.headline)
                                    Text(member.role.rawValue).font(.subheadline).foregroundStyle(CareTheme.muted)
                                    let count = store.state.visibleTasks().filter { $0.ownerID == member.id && $0.status != .completed }.count
                                    Text("\(count) shared task\(count == 1 ? "" : "s") claimed").font(.footnote).foregroundStyle(CareTheme.muted)
                                }
                                Spacer(minLength: 0)
                                if member.id == store.state.activeMemberID { Image(systemName: "checkmark.circle.fill").foregroundStyle(CareTheme.teal) }
                            }.frame(minHeight: 56).padding(.vertical, 6).contentShape(Rectangle())
                        }.buttonStyle(.plain).accessibilityIdentifier("role-\(member.role.rawValue)")
                            .accessibilityAddTraits(member.id == store.state.activeMemberID ? [.isSelected] : [])
                    }
                    if !store.state.members.contains(where: { $0.role == .supporter }) {
                        Text("No supporter available? You can coordinate your own plan and explore service options.").font(.callout)
                    }
                }
                if store.state.canCoordinate {
                    CareCard {
                        Label("Your demo budget", systemImage: "wallet.bifold").font(.title3.bold())
                        Text(store.state.remainingCents.dollars).font(.largeTitle.bold())
                        Text("remaining of \((store.state.plan?.budgetCents ?? 0).dollars) · \(store.state.spentCents.dollars) approved").font(.callout)
                        Text("Family or patient pays the sample service cost. No grants or insurance funding are assumed.").font(.footnote).foregroundStyle(CareTheme.muted)
                        Button("Edit budget & destination") { preferences = true }.frame(minHeight: 44)
                    }
                    CareCard {
                        Text("How CareShare could be sustained").font(.headline)
                        Text("This demo passes the full service amount to the fictional provider. A future provider-funded referral fee is a business hypothesis to validate; CareShare collects no revenue here.").font(.callout).foregroundStyle(CareTheme.muted)
                    }
                }
                CareCard {
                    Text("About this prototype").font(.headline)
                    Text("Changes are saved on this device. Invitations, shared accounts, provider connections, and notifications are not connected.").font(.callout).foregroundStyle(CareTheme.muted)
                    Text("Use fictional details only. CareShare coordinates practical help and does not provide clinical guidance.").font(.footnote)
                    Button("Reset demo plan", role: .destructive) { resetWithoutSupporter = false; resetting = true }.frame(minHeight: 44).accessibilityIdentifier("resetDemo")
                    Button("Try a plan without supporters") { resetWithoutSupporter = true; resetting = true }.frame(minHeight: 44)
                }
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Your circle").navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $preferences) { PreferencesView() }
            .confirmationDialog("Replace this device’s demo plan?", isPresented: $resetting, titleVisibility: .visible) {
                Button("Replace with fresh demo", role: .destructive) { store.reset(withSupporter: !resetWithoutSupporter) }
            } message: { Text("This removes local tasks, demo receipts, and activity, then creates a fresh fictional plan with times relative to now.") }
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
