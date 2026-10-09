import Foundation

/// Single-device demo membership is enforced here, not just in button visibility.
/// Production authentication, authorization, and atomic booking belong on a server.
struct DemoState: Codable, Equatable {
    var schemaVersion = 1
    var plan: RecoveryPlan?
    var members: [Member] = []
    var activeMemberID: UUID?
    var tasks: [CareTask] = []
    var arrangements: [Arrangement] = []
    var payments: [PaymentRecord] = []
    var activity: [Activity] = []

    var activeMember: Member? { members.first { $0.id == activeMemberID } }
    var canCoordinate: Bool { activeMember?.role == .patient || activeMember?.role == .coordinator }
    var spentCents: Int { payments.filter { $0.status == .approved }.reduce(0) { $0 + $1.amountCents } }
    var remainingCents: Int { max(0, (plan?.budgetCents ?? 0) - spentCents) }

    func visibleTasks(at now: Date = Date()) -> [CareTask] {
        tasks.filter { canView($0) }.sorted {
            func rank(_ task: CareTask) -> Int {
                if task.status == .completed { return 3 }
                if task.isOverdue(at: now) { return 0 }
                return task.status == .needsHelp ? 1 : 2
            }
            if rank($0) != rank($1) { return rank($0) < rank($1) }
            return $0.due < $1.due
        }
    }

    func canView(_ task: CareTask) -> Bool {
        guard let plan, let actor = activeMember, plan.memberIDs.contains(actor.id), task.planID == plan.id else { return false }
        return canCoordinate || task.visibility == .circle
    }

    func ownerName(for task: CareTask) -> String {
        if let owner = members.first(where: { $0.id == task.ownerID }) { return owner.name }
        if let arrangement = activeArrangement(for: task.id) { return arrangement.provider }
        return "No one yet"
    }

    func activeArrangement(for taskID: UUID) -> Arrangement? {
        arrangements.last { $0.taskID == taskID && $0.status != .cancelled }
    }

    static func newPlan(name: String, discharge: Date, location: String, hasDestination: Bool,
                        budgetCents: Int, selfCoordinating: Bool) -> DemoState {
        let person = Member(name: name, role: .patient)
        let coordinator = Member(name: "Alex Morgan", role: .coordinator)
        let members = selfCoordinating ? [person] : [person, coordinator]
        let plan = RecoveryPlan(patientName: name, discharge: discharge, location: location,
                                hasDestination: hasDestination, budgetCents: max(0, budgetCents), memberIDs: members.map(\.id))
        return DemoState(plan: plan, members: members, activeMemberID: selfCoordinating ? person.id : coordinator.id)
    }

    static func seeded(now: Date = Date(), withSupporter: Bool = true) -> DemoState {
        var state = newPlan(name: "Sam Morgan", discharge: now.addingTimeInterval(-7200),
                            location: "Demo neighborhood", hasDestination: true, budgetCents: 6000, selfCoordinating: !withSupporter)
        if withSupporter {
            let supporter = Member(name: "Jordan Lee", role: .supporter)
            state.members.append(supporter)
            state.plan?.memberIDs.append(supporter.id)
        }
        guard let plan = state.plan else { return state }
        state.tasks = [
            CareTask(planID: plan.id, title: "Dinner for tonight", category: .meals, due: now.addingTimeInterval(3 * 3600),
                     isPriority: true, notes: "A prepared meal would make the first evening easier."),
            CareTask(planID: plan.id, title: "Ride to tomorrow’s appointment", category: .transportation,
                     due: now.addingTimeInterval(22 * 3600), isPriority: true, notes: "One-way ride. Confirm the pickup details with Sam."),
            CareTask(planID: plan.id, title: "Bring in groceries", category: .household,
                     due: now.addingTimeInterval(27 * 3600), notes: "Put the essentials within easy reach."),
            CareTask(planID: plan.id, title: "Make time for a check-in", category: .relief,
                     due: now.addingTimeInterval(46 * 3600), notes: "Ask what practical help is still needed.")
        ]
        return state
    }

    private func checkedIndex(_ id: UUID) throws -> Int {
        guard let index = tasks.firstIndex(where: { $0.id == id }), canView(tasks[index]) else {
            throw CareError.invalid("This task is not shared with your current demo role.")
        }
        return index
    }

    private func requireCoordinator() throws {
        guard canCoordinate, let id = activeMemberID, plan?.memberIDs.contains(id) == true else {
            throw CareError.invalid("Switch to the patient or coordinator to make this change.")
        }
    }

    private mutating func record(_ taskID: UUID, _ event: String, at now: Date) {
        guard let actorID = activeMemberID else { return }
        activity.append(Activity(taskID: taskID, actorID: actorID, event: event, timestamp: now))
    }

    mutating func switchMember(_ id: UUID) throws {
        guard plan?.memberIDs.contains(id) == true, members.contains(where: { $0.id == id }) else {
            throw CareError.invalid("This person is not a member of this plan.")
        }
        activeMemberID = id
    }

    mutating func saveTask(_ task: CareTask, now: Date = Date()) throws {
        try requireCoordinator()
        guard task.planID == plan?.id, !task.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CareError.invalid("Give this task a title before saving.")
        }
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            guard tasks[index].status == .needsHelp || tasks[index].status == .claimed else {
                throw CareError.invalid("Reopen or cancel the arrangement before editing this task.")
            }
            guard task.visibility == .circle || tasks[index].ownerID == nil || members.first(where: { $0.id == tasks[index].ownerID })?.role != .supporter else {
                throw CareError.invalid("Release the supporter’s task before making it private.")
            }
            // Editable content never overwrites ownership or lifecycle state.
            tasks[index].title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
            tasks[index].category = task.category
            tasks[index].due = task.due
            tasks[index].isPriority = task.isPriority
            tasks[index].notes = task.notes
            tasks[index].visibility = task.visibility
            record(task.id, "Updated task details", at: now)
        } else {
            var clean = task
            clean.title = task.title.trimmingCharacters(in: .whitespacesAndNewlines)
            clean.status = .needsHelp
            clean.ownerID = nil
            clean.statusBeforeCompletion = nil
            tasks.append(clean)
            record(task.id, "Added this need", at: now)
        }
    }

    mutating func claim(_ id: UUID, now: Date = Date()) throws {
        let i = try checkedIndex(id)
        guard tasks[i].status == .needsHelp else { throw CareError.invalid("Someone is already handling this task. Refresh the plan to see its owner.") }
        tasks[i].status = .claimed
        tasks[i].ownerID = activeMemberID
        record(id, "Accepted responsibility", at: now)
    }

    mutating func release(_ id: UUID, now: Date = Date()) throws {
        let i = try checkedIndex(id)
        guard tasks[i].status == .claimed, tasks[i].ownerID == activeMemberID || canCoordinate else {
            throw CareError.invalid("Only the owner or coordinator can release a claimed task.")
        }
        tasks[i].status = .needsHelp
        tasks[i].ownerID = nil
        record(id, "Released responsibility · needs help again", at: now)
    }

    mutating func complete(_ id: UUID, now: Date = Date()) throws {
        let i = try checkedIndex(id)
        guard tasks[i].status == .claimed || tasks[i].status == .arranged,
              canCoordinate || tasks[i].ownerID == activeMemberID else {
            throw CareError.invalid("A task needs an accepted owner or arrangement before completion can be recorded.")
        }
        tasks[i].statusBeforeCompletion = tasks[i].status
        tasks[i].status = .completed
        if let a = arrangements.firstIndex(where: { $0.taskID == id && $0.status == .confirmed }) {
            arrangements[a].status = .fulfilled
        }
        record(id, "Recorded completion", at: now)
    }

    mutating func reopen(_ id: UUID, now: Date = Date()) throws {
        try requireCoordinator()
        let i = try checkedIndex(id)
        guard tasks[i].status == .completed else { throw CareError.invalid("This task is not completed.") }
        tasks[i].status = tasks[i].statusBeforeCompletion ?? .needsHelp
        tasks[i].statusBeforeCompletion = nil
        if let a = arrangements.firstIndex(where: { $0.taskID == id && $0.status == .fulfilled }) { arrangements[a].status = .confirmed }
        record(id, "Reopened task · completion undone", at: now)
    }

    mutating func book(_ id: UUID, service: ServiceOption, gateway: any BookingGateway,
                       now: Date = Date()) throws -> PaymentRecord {
        try requireCoordinator()
        let i = try checkedIndex(id)
        guard tasks[i].status == .needsHelp else { throw CareError.invalid("This need already has help. No new payment was created.") }
        guard service.category == tasks[i].category, !service.isReferral,
              ServiceOption.samples.contains(service) else { throw CareError.invalid("Choose a sample service that fits this task.") }
        guard plan?.hasDestination == true else { throw CareError.invalid("Confirm a place to stay and service destination before arranging delivery or a ride. Ask your discharge coordinator for help.") }
        guard tasks[i].due > now else { throw CareError.invalid("Choose a future task time before requesting this service.") }
        guard service.totalCents <= remainingCents else { throw CareError.invalid("This exceeds your remaining demo budget. Explore community support or update your spending limit in Circle.") }
        // Both simulated authorization and provider acceptance must succeed before any state changes.
        try gateway.confirm(service: service)
        guard let payer = activeMemberID else { throw CareError.invalid("Choose a payer.") }
        let arrangement = Arrangement(taskID: id, serviceID: service.id, provider: service.provider,
                                      payerID: payer, requestedTime: tasks[i].due)
        let payment = PaymentRecord(arrangementID: arrangement.id, payerID: payer, amountCents: service.totalCents,
                                    receipt: "DEMO-" + UUID().uuidString.prefix(8), createdAt: now)
        arrangements.append(arrangement)
        payments.append(payment)
        tasks[i].status = .arranged
        record(id, "Demo payment approved: \(service.totalCents.dollars). Simulated provider accepted; fulfillment is still pending.", at: now)
        return payment
    }

    mutating func cancelArrangement(_ id: UUID, now: Date = Date()) throws {
        try requireCoordinator()
        let i = try checkedIndex(id)
        guard tasks[i].status == .arranged,
              let a = arrangements.firstIndex(where: { $0.taskID == id && $0.status == .confirmed }) else {
            throw CareError.invalid("There is no active arrangement to cancel.")
        }
        arrangements[a].status = .cancelled
        for p in payments.indices where payments[p].arrangementID == arrangements[a].id { payments[p].status = .released }
        tasks[i].status = .needsHelp
        tasks[i].ownerID = nil
        record(id, "Cancelled demo arrangement · simulated payment released · needs help again", at: now)
    }

    mutating func updatePreferences(budgetCents: Int, hasDestination: Bool) throws {
        try requireCoordinator()
        guard budgetCents >= spentCents else { throw CareError.invalid("The limit cannot be lower than already approved demo payments. Cancel an arrangement first.") }
        plan?.budgetCents = budgetCents
        plan?.hasDestination = hasDestination
    }
}

protocol BookingGateway {
    func confirm(service: ServiceOption) throws
}

struct DemoBookingGateway: BookingGateway {
    enum Outcome { case accepted, paymentFailed, providerDeclined }
    var outcome: Outcome = .accepted
    func confirm(service: ServiceOption) throws {
        switch outcome {
        case .accepted: return
        case .paymentFailed: throw CareError.invalid("The simulated payment failed. No charge or booking was created. Turn off the failure control and retry.")
        case .providerDeclined: throw CareError.invalid("The sample provider declined. No payment was recorded. This task still needs help; try a supporter or another option.")
        }
    }
}

struct DemoRepository {
    var fileURL: URL
    func load() throws -> DemoState {
        let state = try JSONDecoder().decode(DemoState.self, from: Data(contentsOf: fileURL))
        guard state.schemaVersion == 1 else { throw CareError.invalid("This demo data was saved by a different app version.") }
        return state
    }
    func save(_ state: DemoState) throws {
        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try JSONEncoder().encode(state).write(to: fileURL, options: .atomic)
    }
}
