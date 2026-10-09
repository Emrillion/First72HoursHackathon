import SwiftUI

struct FindHelpView: View {
    @EnvironmentObject var store: AppStore
    var taskID: UUID?
    @State private var filter = "All"
    private var task: CareTask? { store.state.visibleTasks().first { $0.id == taskID } }
    private var options: [ServiceOption] {
        ServiceOption.samples.filter {
            (task == nil || $0.category == task?.category) &&
            (filter == "All" || (filter == "Community" ? $0.isReferral : !$0.isReferral))
        }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Find a little extra help").font(.title.bold())
                Text(task.map { "Let’s find a little support for: \($0.title)." } ?? "Explore sample services for uncovered meals and rides.")
                    .foregroundStyle(CareTheme.muted)
                DemoNotice()
                Picker("Service type", selection: $filter) {
                    Text("All").tag("All")
                    Text("Paid").tag("Paid")
                    Text("Community").tag("Community")
                }.pickerStyle(.segmented)
                if store.state.canCoordinate {
                    Label("\(store.state.remainingCents.dollars) left in your demo budget", systemImage: "wallet.bifold").font(.callout)
                }
                if options.isEmpty {
                    EmptyMessage(symbol: "person.2", title: "Your circle can help here", message: "The demo offers meals and rides. A supporter can claim this task, or you can coordinate suitable help outside the app.")
                }
                ForEach(options) { option in
                    NavigationLink { ServiceDetailView(service: option, initialTaskID: taskID) } label: {
                        CareCard {
                            Label(option.isReferral ? "COMMUNITY RESOURCE" : "SAMPLE SERVICE", systemImage: option.category.symbol)
                                .font(.caption.weight(.bold)).foregroundStyle(CareTheme.teal)
                            Text(option.title).font(.title2.bold())
                            Text(option.provider).font(.subheadline).foregroundStyle(CareTheme.muted)
                            Divider()
                            HStack {
                                Text(option.isReferral ? "Ask about no-cost support" : option.totalCents.dollars).font(.headline)
                                Spacer()
                                Image(systemName: "arrow.right")
                            }
                            Text(option.isReferral ? "Availability & eligibility unconfirmed" : "Simulated availability · review fit first")
                                .font(.footnote).foregroundStyle(CareTheme.muted)
                        }
                    }.buttonStyle(.plain).accessibilityIdentifier("service-\(option.id)")
                }
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Find Help").navigationBarTitleDisplayMode(.inline)
    }
}

struct ServiceDetailView: View {
    @EnvironmentObject var store: AppStore
    let service: ServiceOption
    var initialTaskID: UUID?
    @State private var selectedTaskID: UUID?
    @State private var fitConfirmed = false
    private var eligible: [CareTask] {
        store.state.visibleTasks().filter { $0.category == service.category && $0.status == .needsHelp }
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                CareCard {
                    Label(service.isReferral ? "Sample resource" : "Sample service", systemImage: service.category.symbol).font(.headline)
                    Text(service.title).font(.largeTitle.bold())
                    Text(service.provider).foregroundStyle(CareTheme.muted)
                    Text(service.scope)
                    Divider()
                    Text("Check that it fits").font(.headline)
                    Text(service.exclusions).font(.callout)
                }
                if service.isReferral {
                    CareCard {
                        Text("Information, not a reservation").font(.title3.bold())
                        Text("Ask your discharge coordinator or a local community support worker about services in your area. Check timing, cost, eligibility, and accessibility before relying on an option.")
                        Text("Your task remains Needs help. This sample resource cannot confirm capacity or funding.").font(.callout).foregroundStyle(CareTheme.amber)
                    }
                } else if !store.state.canCoordinate {
                    Text("Switch to the patient or coordinator in Circle to review and pay for a service.")
                } else {
                    CareCard {
                        Text("Which need should this cover?").font(.headline)
                        if eligible.isEmpty {
                            Text("Add an uncovered \(service.category.rawValue.lowercased()) task in Plan first.")
                        } else {
                            Picker("Task", selection: $selectedTaskID) {
                                Text("Choose a task").tag(UUID?.none)
                                ForEach(eligible) { Text($0.title).tag(Optional($0.id)) }
                            }.pickerStyle(.menu)
                            if let selected = eligible.first(where: { $0.id == selectedTaskID }) {
                                Text("Sample service time: \(selected.due.careDate)").font(.callout)
                                Text("Task notes: \(selected.notes.isEmpty ? "No additional needs recorded." : selected.notes)").font(.callout)
                            }
                            Toggle("I’ve reviewed the sample scope and limitations", isOn: $fitConfirmed)
                                .accessibilityIdentifier("confirmServiceFit")
                        }
                    }
                    CareCard {
                        Text("A clear cost, up front").font(.title3.bold())
                        ForEach(service.lines, id: \.label) { line in HStack { Text(line.label); Spacer(); Text(line.cents.dollars) } }
                        Divider()
                        HStack { Text("Total").bold(); Spacer(); Text(service.totalCents.dollars).bold() }
                        Text("Demo cancellation releases the full simulated amount. No real cancellation policy or provider agreement exists.")
                            .font(.footnote).foregroundStyle(CareTheme.muted)
                    }
                    if let id = selectedTaskID, eligible.contains(where: { $0.id == id }) {
                        NavigationLink { CheckoutView(taskID: id, service: service) } label: { Text("Review request") }
                            .buttonStyle(PrimaryButton()).disabled(!fitConfirmed).accessibilityIdentifier("reviewRequest")
                    }
                }
                DemoNotice()
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Service details").navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if selectedTaskID == nil { selectedTaskID = initialTaskID ?? eligible.first?.id }
            }
    }
}

struct CheckoutView: View {
    @EnvironmentObject var store: AppStore
    let taskID: UUID
    let service: ServiceOption
    @State private var receipt: PaymentRecord?
    private var task: CareTask? { store.state.visibleTasks().first { $0.id == taskID } }
    private var canBook: Bool {
        store.state.canCoordinate && task?.status == .needsHelp &&
        service.totalCents <= store.state.remainingCents && store.state.plan?.hasDestination == true && (task?.due ?? .distantPast) > Date()
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                if let receipt {
                    CareCard {
                        Image(systemName: "checkmark.seal.fill").font(.system(size: 48)).foregroundStyle(CareTheme.teal).accessibilityHidden(true)
                        Text("Demo booking confirmed").font(.largeTitle.bold()).accessibilityIdentifier("bookingConfirmed")
                        Text("\(service.provider) has accepted in this simulation. Fulfillment is still pending.")
                        Text("No money was charged. No real provider was contacted.").font(.headline)
                        Divider()
                        Text("\(receipt.amountCents.dollars) · paid by \(store.state.members.first { $0.id == receipt.payerID }?.name ?? "Demo payer")")
                        Text(receipt.receipt).font(.callout.monospaced())
                    }
                    NavigationLink { TaskDetailView(taskID: taskID) } label: { Text("View arranged task") }.buttonStyle(PrimaryButton()).accessibilityIdentifier("viewArrangedTask")
                } else {
                    Text("One less thing\nto carry.").font(.largeTitle.bold())
                    Text("Review your demo request").font(.title3.bold())
                    CareCard {
                        Text(service.title).font(.title2.bold())
                        Text(service.provider).font(.callout)
                        if let task {
                            Label(task.due.careDate, systemImage: "clock")
                            Text("For: \(task.title)")
                        }
                        Divider()
                        Text("Payer: \(store.state.activeMember?.name ?? "Choose a role")").font(.headline)
                        Text("The current patient or coordinator approves their own simulated payment. No card details are needed.").font(.footnote).foregroundStyle(CareTheme.muted)
                        ForEach(service.lines, id: \.label) { line in HStack { Text(line.label); Spacer(); Text(line.cents.dollars) } }
                        Divider()
                        HStack { Text("You pay").font(.headline); Spacer(); Text(service.totalCents.dollars).font(.title.bold()) }
                        Text("Why: cover an everyday need that no supporter has accepted.").font(.callout)
                        Text("Budget remaining after approval: \(max(0, store.state.remainingCents - service.totalCents).dollars)").font(.footnote)
                    }
                    if !canBook {
                        CareCard {
                            Label("This request needs attention", systemImage: "exclamationmark.circle").font(.headline)
                            Text(blockReason).foregroundStyle(CareTheme.amber)
                        }
                    }
                    Button("Confirm demo payment") {
                        var created: PaymentRecord?
                        if store.change({ created = try $0.book(taskID, service: service, gateway: DemoBookingGateway(outcome: store.demoOutcome)) }) {
                            receipt = created
                        }
                    }.buttonStyle(PrimaryButton()).disabled(!canBook).accessibilityIdentifier("confirmPayment")
                    Text("Backing out leaves the task unchanged. Confirming simulates payment and provider acceptance; it does not complete the task.")
                        .font(.footnote).foregroundStyle(CareTheme.muted)
                    DisclosureGroup("Demo controls") {
                        Picker("Simulated response", selection: $store.demoOutcome) {
                            Text("Success").tag(DemoBookingGateway.Outcome.accepted)
                            Text("Payment fails").tag(DemoBookingGateway.Outcome.paymentFailed)
                            Text("Provider declines").tag(DemoBookingGateway.Outcome.providerDeclined)
                        }.pickerStyle(.menu).accessibilityIdentifier("demoResponse")
                        Text("After a failure, choose Success and retry. No duplicate payment or booking is created.").font(.footnote)
                    }
                }
                DemoNotice()
            }.padding(16)
        }.background(CareTheme.cloud).navigationTitle("Mock checkout").navigationBarTitleDisplayMode(.inline)
    }
    private var blockReason: String {
        if !store.state.canCoordinate { return "Switch to the patient or coordinator to approve payment." }
        if task?.status != .needsHelp { return "This task already has help. Return to your plan." }
        if store.state.plan?.hasDestination != true { return "A service destination is not confirmed. Ask a discharge coordinator or local support worker for help, then update the place-to-stay setting in Circle." }
        if (task?.due ?? .distantPast) <= Date() { return "The requested time has passed. Edit the task to choose a future time." }
        return "Your remaining demo budget is \(store.state.remainingCents.dollars). Try community support or update your limit in Circle. No funding is assumed."
    }
}
