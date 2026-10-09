import XCTest
@testable import CareShareCore

final class CareShareCoreTests: XCTestCase {
    let now = Date(timeIntervalSince1970: 1_800_000_000)
    let meal = ServiceOption.samples.first { $0.id == "meal" }!

    func testClaimDoesNotAllowOverwriteAndReleaseRestoresNeed() throws {
        var state = DemoState.seeded(now: now)
        let coordinator = state.activeMemberID!
        let supporter = state.members.first { $0.role == .supporter }!.id
        let id = state.tasks[1].id
        try state.switchMember(supporter)
        try state.claim(id, now: now)
        XCTAssertEqual(state.tasks[1].ownerID, supporter)
        try state.switchMember(coordinator)
        let before = state
        XCTAssertThrowsError(try state.claim(id, now: now))
        XCTAssertEqual(state, before)
        try state.release(id, now: now)
        XCTAssertEqual(state.tasks[1].status, .needsHelp)
        XCTAssertNil(state.tasks[1].ownerID)
    }

    func testPaymentFailureAndDeclineAreAtomicThenRetryIsIdempotent() throws {
        for outcome in [DemoBookingGateway.Outcome.paymentFailed, .providerDeclined] {
            var state = DemoState.seeded(now: now)
            let id = state.tasks[0].id
            let before = state
            XCTAssertThrowsError(try state.book(id, service: meal, gateway: DemoBookingGateway(outcome: outcome), now: now))
            XCTAssertEqual(state, before)
            let receipt = try state.book(id, service: meal, gateway: DemoBookingGateway(), now: now)
            XCTAssertEqual(receipt.amountCents, 2400)
            XCTAssertEqual(receipt.payerID, state.activeMemberID)
            XCTAssertEqual(state.tasks[0].status, .arranged)
            XCTAssertEqual(state.arrangements.count, 1)
            XCTAssertThrowsError(try state.book(id, service: meal, gateway: DemoBookingGateway(), now: now))
            XCTAssertEqual(state.payments.count, 1)
        }
    }

    func testArrangementCompletionUndoAndCancellationReleasesBudget() throws {
        var state = DemoState.seeded(now: now)
        let id = state.tasks[0].id
        _ = try state.book(id, service: meal, gateway: DemoBookingGateway(), now: now)
        XCTAssertEqual(state.remainingCents, 3600)
        XCTAssertEqual(state.tasks[0].status, .arranged)
        try state.complete(id, now: now)
        XCTAssertEqual(state.arrangements[0].status, .fulfilled)
        XCTAssertEqual(state.activity.last?.actorID, state.activeMemberID)
        try state.reopen(id, now: now)
        XCTAssertEqual(state.tasks[0].status, .arranged)
        XCTAssertEqual(state.arrangements[0].status, .confirmed)
        try state.cancelArrangement(id, now: now)
        XCTAssertEqual(state.tasks[0].status, .needsHelp)
        XCTAssertEqual(state.payments[0].status, .released)
        XCTAssertEqual(state.remainingCents, 6000)
        _ = try state.book(id, service: meal, gateway: DemoBookingGateway(), now: now)
        XCTAssertEqual(state.spentCents, 2400)
        XCTAssertEqual(state.payments.count, 2)
    }

    func testZeroBudgetAndUnknownDestinationNeverBecomeArranged() throws {
        for destination in [true, false] {
            var state = DemoState.seeded(now: now)
            try state.updatePreferences(budgetCents: destination ? 0 : 6000, hasDestination: destination)
            let before = state
            XCTAssertThrowsError(try state.book(state.tasks[0].id, service: meal, gateway: DemoBookingGateway(), now: now))
            XCTAssertEqual(state, before)
        }
    }

    func testReferralCannotBecomeBookingAndWrongCategoryRejected() throws {
        var state = DemoState.seeded(now: now)
        let before = state
        let referral = ServiceOption.samples.first { $0.isReferral }!
        XCTAssertThrowsError(try state.book(state.tasks[0].id, service: referral, gateway: DemoBookingGateway(), now: now))
        XCTAssertThrowsError(try state.book(state.tasks[1].id, service: meal, gateway: DemoBookingGateway(), now: now))
        XCTAssertEqual(state, before)
    }

    func testOverdueAndUncoveredTasksSortAheadOfCoveredAndDone() throws {
        var state = DemoState.seeded(now: now)
        state.tasks[3].due = now.addingTimeInterval(-60)
        try state.claim(state.tasks[0].id, now: now)
        try state.complete(state.tasks[0].id, now: now)
        let sorted = state.visibleTasks(at: now)
        XCTAssertEqual(sorted.first?.id, state.tasks[3].id)
        XCTAssertEqual(sorted.last?.id, state.tasks[0].id)
        XCTAssertEqual(state.visibleTasks(at: now.addingTimeInterval(100 * 3600)).count, 4)
    }

    func testRecoveryWindowIsExactly72HoursAcrossDST() {
        let state = DemoState.seeded(now: now)
        XCTAssertEqual(state.plan!.windowEnd.timeIntervalSince(state.plan!.discharge), 72 * 3600)
    }

    func testSupporterCannotSeePrivateTasksOrPayOrChangeBudget() throws {
        var state = DemoState.seeded(now: now)
        state.tasks[0].visibility = .coordinators
        try state.switchMember(state.members.first { $0.role == .supporter }!.id)
        XCTAssertEqual(state.visibleTasks(at: now).count, 3)
        XCTAssertThrowsError(try state.claim(state.tasks[0].id, now: now))
        XCTAssertThrowsError(try state.book(state.tasks[1].id, service: ServiceOption.samples[1], gateway: DemoBookingGateway(), now: now))
        XCTAssertThrowsError(try state.updatePreferences(budgetCents: 9999, hasDestination: true))
        XCTAssertThrowsError(try state.switchMember(UUID()))
    }

    func testSupporterCannotCompleteOrReleaseAnotherPersonsTask() throws {
        var state = DemoState.seeded(now: now)
        let id = state.tasks[0].id
        try state.claim(id, now: now)
        try state.switchMember(state.members.first { $0.role == .supporter }!.id)
        let before = state
        XCTAssertThrowsError(try state.complete(id, now: now))
        XCTAssertThrowsError(try state.release(id, now: now))
        XCTAssertEqual(state, before)
    }

    func testPatientWithoutSupportersCanArrangeAndComplete() throws {
        var state = DemoState.seeded(now: now, withSupporter: false)
        XCTAssertEqual(state.members.count, 1)
        XCTAssertEqual(state.activeMember?.role, .patient)
        let id = state.tasks[0].id
        _ = try state.book(id, service: meal, gateway: DemoBookingGateway(), now: now)
        try state.complete(id, now: now)
        XCTAssertEqual(state.tasks[0].status, .completed)
    }

    func testPersistencePreservesOwnershipPaymentsAndHistory() throws {
        let directory = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        defer { try? FileManager.default.removeItem(at: directory) }
        let repository = DemoRepository(fileURL: directory.appendingPathComponent("state.json"))
        var state = DemoState.seeded(now: now)
        try state.claim(state.tasks[1].id, now: now)
        _ = try state.book(state.tasks[0].id, service: meal, gateway: DemoBookingGateway(), now: now)
        try repository.save(state)
        XCTAssertEqual(try repository.load(), state)
        try Data("corrupt".utf8).write(to: repository.fileURL)
        XCTAssertThrowsError(try repository.load())
    }

    func testNewTaskAndEditingPreserveAcceptedOwner() throws {
        var state = DemoState.seeded(now: now)
        var task = CareTask(planID: state.plan!.id, title: "  Do laundry  ", category: .household, due: now)
        try state.saveTask(task, now: now)
        XCTAssertEqual(state.tasks.last?.title, "Do laundry")
        try state.claim(task.id, now: now)
        task.title = "Bring clean towels"
        task.status = .completed
        try state.saveTask(task, now: now)
        XCTAssertEqual(state.tasks.last?.status, .claimed)
        XCTAssertEqual(state.tasks.last?.ownerID, state.activeMemberID)
    }

    func testInvalidPrivateEditIsAtomic() throws {
        var state = DemoState.seeded(now: now)
        let coordinator = state.activeMemberID!
        try state.switchMember(state.members.first { $0.role == .supporter }!.id)
        try state.claim(state.tasks[0].id, now: now)
        try state.switchMember(coordinator)
        var task = state.tasks[0]
        task.title = "Changed title"
        task.visibility = .coordinators
        let before = state
        XCTAssertThrowsError(try state.saveTask(task, now: now))
        XCTAssertEqual(before, state)
    }

    func testPastServiceTimeRejectedAndBudgetCannotEraseApprovedSpend() throws {
        var state = DemoState.seeded(now: now)
        state.tasks[0].due = now.addingTimeInterval(-1)
        XCTAssertThrowsError(try state.book(state.tasks[0].id, service: meal, gateway: DemoBookingGateway(), now: now))
        state.tasks[0].due = now.addingTimeInterval(3600)
        _ = try state.book(state.tasks[0].id, service: meal, gateway: DemoBookingGateway(), now: now)
        XCTAssertThrowsError(try state.updatePreferences(budgetCents: 0, hasDestination: true))
        XCTAssertEqual(state.plan?.budgetCents, 6000)
    }
    func testJoinCodePersistsAndAddsSupporterWithLimitedAccess() throws {
        var state = DemoState.seeded(now: now)
        state.tasks[0].visibility = .coordinators
        try state.generateJoinCode(now: now)
        let code = try XCTUnwrap(state.invitation?.code)
        state = try JSONDecoder().decode(DemoState.self, from: JSONEncoder().encode(state))
        let formatted = "  " + code.prefix(4).lowercased() + "-" + code.suffix(4).lowercased() + " "
        let member = try state.joinPlan(code: formatted, name: " Taylor Park ", now: now)
        XCTAssertEqual(member.name, "Taylor Park")
        XCTAssertEqual(member.role, .supporter)
        XCTAssertEqual(state.activeMemberID, member.id)
        XCTAssertTrue(state.plan!.memberIDs.contains(member.id))
        XCTAssertEqual(state.visibleTasks(at: now).count, 3)
        XCTAssertNil(state.invitation)
        XCTAssertThrowsError(try state.generateJoinCode(now: now))
        XCTAssertThrowsError(try state.revokeJoinCode())
        XCTAssertThrowsError(try state.claim(state.tasks[0].id, now: now))
        try state.claim(state.tasks[1].id, now: now)
        XCTAssertEqual(state.tasks[1].ownerID, member.id)
        let before = state
        XCTAssertThrowsError(try state.joinPlan(code: code, name: "Another person", now: now))
        XCTAssertEqual(state, before)
    }

    func testInvalidExpiredReplacedAndRevokedCodesDoNotMutatePlan() throws {
        var state = DemoState.seeded(now: now)
        try state.generateJoinCode(now: now)
        let original = state.invitation!.code
        for (code, name, time) in [("INVALID!", "Taylor", now), (original, " ", now),
                                   (original, "Sam Morgan", now), (original, String(repeating: "a", count: 61), now),
                                   (original, "Taylor", now.addingTimeInterval(24 * 3600))] {
            let before = state
            XCTAssertThrowsError(try state.joinPlan(code: code, name: name, now: time))
            XCTAssertEqual(state, before)
        }
        try state.generateJoinCode(now: now)
        XCTAssertNotEqual(original, state.invitation!.code)
        XCTAssertThrowsError(try state.joinPlan(code: original, name: "Taylor", now: now))
        let replaced = state.invitation!.code
        try state.revokeJoinCode()
        XCTAssertThrowsError(try state.joinPlan(code: replaced, name: "Taylor", now: now))
    }

    func testExistingSavedPlansWithoutInvitationStillLoad() throws {
        var state = DemoState.seeded(now: now)
        try state.claim(state.tasks[0].id, now: now)
        var json = try XCTUnwrap(JSONSerialization.jsonObject(with: JSONEncoder().encode(state)) as? [String: Any])
        json.removeValue(forKey: "invitation")
        let loaded = try JSONDecoder().decode(DemoState.self, from: JSONSerialization.data(withJSONObject: json))
        XCTAssertEqual(loaded, state)
        XCTAssertNil(loaded.invitation)
    }

}
