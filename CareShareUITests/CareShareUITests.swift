import XCTest

final class CareShareUITests: XCTestCase {
    private var app: XCUIApplication!
    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting", "--reset-demo"]
        app.launch()
    }

    private func reveal(_ element: XCUIElement, file: StaticString = #filePath, line: UInt = #line) {
        for _ in 0..<12 {
            if element.exists && element.isHittable { return }
            app.scrollViews.firstMatch.swipeUp()
        }
        XCTAssertTrue(element.exists && element.isHittable, "Element not reachable: \(element)", file: file, line: line)
    }

    func testCaregiverJourneyAndRelaunch() throws {
        app.tabBars.buttons["Circle"].tap()
        app.buttons["demoSettings"].tap()
        app.buttons["role-Supporter"].tap()
        app.tabBars.buttons["Plan"].tap()
        let ride = app.buttons["task-Ride to tomorrow’s appointment"]
        reveal(ride); ride.tap()
        let claim = app.buttons["claimTask"]
        reveal(claim); claim.tap()
        XCTAssertTrue(app.staticTexts["Claimed"].exists)
        app.tabBars.buttons["Circle"].tap()
        app.buttons["role-Coordinator"].tap()
        app.tabBars.buttons["Plan"].tap()
        app.navigationBars.buttons.element(boundBy: 0).tap()
        app.scrollViews.firstMatch.swipeDown()
        let dinner = app.buttons["task-Dinner for tonight"]
        reveal(dinner); dinner.tap()
        let find = app.buttons["findTaskHelp"]
        reveal(find); find.tap()
        let meal = app.buttons["service-meal"]
        reveal(meal); meal.tap()
        let fit = app.switches["confirmServiceFit"]
        reveal(fit); fit.tap()
        let review = app.buttons["reviewRequest"]
        reveal(review); review.tap()
        let pay = app.buttons["confirmPayment"]
        reveal(pay); pay.tap()
        XCTAssertTrue(app.staticTexts["bookingConfirmed"].waitForExistence(timeout: 5))
        let arranged = app.buttons["viewArrangedTask"]
        reveal(arranged); arranged.tap()
        let complete = app.buttons["completeTask"]
        reveal(complete); complete.tap()
        XCTAssertTrue(app.staticTexts["Completed"].exists)
        app.terminate()
        app.launchArguments = ["--uitesting"]
        app.launch()
        app.buttons["Done"].tap()
        let saved = app.buttons["task-Dinner for tonight"]
        reveal(saved)
        XCTAssertTrue(saved.exists)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Completed task persists after relaunch"
        shot.lifetime = .keepAlways
        add(shot)
    }

    func testCreateTask() throws {
        let add = app.buttons["addTask"]
        reveal(add); add.tap()
        let title = app.textFields["taskTitle"]
        title.tap(); title.typeText("Water the plants")
        app.buttons["saveTask"].tap()
        let task = app.buttons["task-Water the plants"]
        reveal(task); task.tap()
        XCTAssertTrue(app.staticTexts["Water the plants"].exists)
    }

    func testLargestTextKeepsTaskActionsReachable() throws {
        app.terminate()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        let dinner = app.buttons["task-Dinner for tonight"]
        reveal(dinner); dinner.tap()
        let claim = app.buttons["claimTask"]
        reveal(claim); claim.tap()
        let complete = app.buttons["completeTask"]
        reveal(complete); complete.tap()
        let reopen = app.buttons["reopenTask"]
        reveal(reopen)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Task actions at largest accessibility text size"
        shot.lifetime = .keepAlways
        add(shot)
    }

    func testMockPaymentFailureCanRetry() throws {
        app.tabBars.buttons["Find Help"].tap()
        let meal = app.buttons["service-meal"]
        reveal(meal); meal.tap()
        let fit = app.switches["confirmServiceFit"]
        reveal(fit); fit.tap()
        let review = app.buttons["reviewRequest"]
        reveal(review); review.tap()
        let controls = app.buttons["Demo controls"]
        reveal(controls); controls.tap()
        let response = app.buttons["demoResponse"]
        reveal(response); response.tap()
        app.buttons["Payment fails"].tap()
        app.scrollViews.firstMatch.swipeDown()
        let pay = app.buttons["confirmPayment"]
        reveal(pay); pay.tap()
        XCTAssertTrue(app.alerts["Let’s take another look"].waitForExistence(timeout: 3))
        XCTAssertFalse(app.staticTexts["bookingConfirmed"].exists)
        app.alerts.buttons["OK"].tap()
        reveal(response); response.tap()
        app.buttons["Success"].tap()
        app.scrollViews.firstMatch.swipeDown()
        reveal(pay); pay.tap()
        XCTAssertTrue(app.staticTexts["bookingConfirmed"].waitForExistence(timeout: 3))
    }
    func testGenerateAndEnterJoinCodeThenClaimTask() throws {
        app.tabBars.buttons["Circle"].tap()
        app.buttons["inviteSomeone"].tap()
        let generate = app.buttons["generateJoinCode"]
        reveal(generate); generate.tap()
        let code = app.staticTexts["generatedJoinCode"].label
        XCTAssertEqual(code.count, 8)
        app.navigationBars.buttons["Done"].tap()
        app.buttons["enterJoinCode"].tap()
        app.textFields["joinCodeInput"].tap()
        app.textFields["joinCodeInput"].typeText("WRONG123")
        app.textFields["joinNameInput"].tap()
        app.textFields["joinNameInput"].typeText("Taylor Park")
        app.buttons["joinPlan"].tap()
        XCTAssertTrue(app.staticTexts["joinError"].exists)
        let field = app.textFields["joinCodeInput"]
        field.tap()
        field.typeText(String(repeating: XCUIKeyboardKey.delete.rawValue, count: 8) + code)
        app.buttons["joinPlan"].tap()
        XCTAssertTrue(app.buttons["joinedDone"].waitForExistence(timeout: 3))
        app.buttons["joinedDone"].tap()
        XCTAssertTrue(app.staticTexts["Taylor Park"].exists)
        XCTAssertFalse(app.buttons["inviteSomeone"].exists)
        app.tabBars.buttons["Plan"].tap()
        app.buttons["task-Dinner for tonight"].tap()
        let claim = app.buttons["claimTask"]
        reveal(claim); claim.tap()
        XCTAssertTrue(app.staticTexts["Claimed"].exists)
        app.terminate()
        app.launchArguments = ["--uitesting"]
        app.launch()
        app.tabBars.buttons["Circle"].tap()
        XCTAssertTrue(app.staticTexts["Taylor Park"].exists)
    }

    func testHospitalBillingIsPresentationOnly() throws {
        let planShot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        planShot.name = "Simplified care plan"
        planShot.lifetime = .keepAlways
        add(planShot)
        app.tabBars.buttons["Hospitals"].tap()
        XCTAssertTrue(app.staticTexts["Our B2B2C model"].exists)
        let billing = app.buttons["hospitalBilling"]
        reveal(billing); billing.tap()
        XCTAssertTrue(app.staticTexts["UI mockup · payments disabled"].exists)
        XCTAssertEqual(app.textFields.count, 0)
        let payment = app.buttons["hospitalPayDisabled"]
        // Disabled controls may report isHittable differently; scroll until visible.
        for _ in 0..<5 { if payment.exists && payment.frame.maxY < app.frame.maxY - 90 { break }; app.scrollViews.firstMatch.swipeUp() }
        XCTAssertTrue(payment.exists)
        XCTAssertFalse(payment.isEnabled)
        let shot = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        shot.name = "Hospital billing mockup with disabled payment"
        shot.lifetime = .keepAlways
        add(shot)
    }

}
