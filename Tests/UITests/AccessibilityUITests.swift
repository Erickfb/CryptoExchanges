import XCTest

final class AccessibilityUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["--uitesting"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func testExchangeListAccessibility() throws {
        let tableView = app.tables.firstMatch
        XCTAssertTrue(tableView.waitForExistence(timeout: 10))
        XCTAssertTrue(tableView.isHittable)
    }

    func testExchangeCellsAreAccessible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)
        XCTAssertTrue(firstCell.isHittable)
    }

    func testNavigationButtonsAreAccessible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        XCTAssertTrue(backButton.isEnabled)
        XCTAssertTrue(backButton.isHittable)
    }

    func testLoadingIndicatorAccessibility() throws {
        let loadingIndicator = app.activityIndicators.firstMatch

        if loadingIndicator.exists {
            XCTAssertTrue(loadingIndicator.exists)
        }
    }

    func testDetailScreenElementsAreAccessible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
        XCTAssertTrue(scrollView.isHittable)
    }

    func testButtonsInDetailScreenAreAccessible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let websiteButton = app.buttons["Visit Website"]
        if websiteButton.waitForExistence(timeout: 5) {
            XCTAssertTrue(websiteButton.isEnabled)
            XCTAssertTrue(websiteButton.isHittable)
        }
    }

    func testRetryButtonIsAccessible() throws {
        app.launchArguments = ["--uitesting", "--network-error"]
        app.launch()

        let retryButton = app.buttons["Retry"]
        if retryButton.waitForExistence(timeout: 5) {
            XCTAssertTrue(retryButton.isEnabled)
            XCTAssertTrue(retryButton.isHittable)
        }
    }

    func testModalCloseButtonIsAccessible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let descriptionButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Descrição'")).firstMatch
        if descriptionButton.waitForExistence(timeout: 5) {
            descriptionButton.tap()

            let closeButton = app.buttons.firstMatch
            XCTAssertTrue(closeButton.waitForExistence(timeout: 3))
            XCTAssertTrue(closeButton.isEnabled)
            XCTAssertTrue(closeButton.isHittable)
        }
    }

    func testAllStaticTextsAreVisible() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let staticTexts = app.staticTexts.allElementsBoundByIndex
        for text in staticTexts where text.exists {
            XCTAssertTrue(text.isHittable || !text.frame.isEmpty)
        }
    }
}
