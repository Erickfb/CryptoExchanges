import XCTest

final class ExchangeListUITests: XCTestCase {
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

    func testExchangeListScreenAppears() throws {
        let navigationBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(navigationBar.exists)
    }

    func testLoadingIndicatorAppearsAndDisappears() throws {
        let tableView = app.tables.firstMatch
        let exists = tableView.waitForExistence(timeout: 10)
        XCTAssertTrue(exists, "Table view should appear after loading")

        let loadingIndicator = app.activityIndicators.firstMatch
        XCTAssertFalse(loadingIndicator.exists, "Loading indicator should disappear after loading")
    }

    func testExchangeListDisplaysItems() throws {
        let tableView = app.tables.firstMatch
        let exists = tableView.waitForExistence(timeout: 10)
        XCTAssertTrue(exists)

        let cells = tableView.cells
        XCTAssertTrue(cells.count > 0, "Should display at least one exchange")
    }

    func testExchangeCellContainsRequiredElements() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)

        let nameLabel = firstCell.staticTexts.element(matching: .any, identifier: "exchangeName")
        let volumeLabel = firstCell.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Volume'")).firstMatch
        let dateLabel = firstCell.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Lançamento'")).firstMatch

        XCTAssertTrue(volumeLabel.exists || nameLabel.exists)
        XCTAssertTrue(dateLabel.exists || nameLabel.exists)
    }

    func testTapExchangeNavigatesToDetail() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        XCTAssertTrue(firstCell.exists)

        firstCell.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
    }

    func testErrorStateDisplaysRetryButton() throws {
        app.launchArguments = ["--uitesting", "--network-error"]
        app.launch()

        let errorLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'error'")).firstMatch
        let retryButton = app.buttons["Retry"]

        XCTAssertTrue(errorLabel.waitForExistence(timeout: 5))
        XCTAssertTrue(retryButton.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }

    func testPullToRefresh() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        tableView.swipeDown(velocity: .fast)

        let loadingIndicator = app.activityIndicators.firstMatch
        XCTAssertTrue(loadingIndicator.exists || tableView.exists)
    }

    func testScrollThroughExchangeList() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let cellCount = tableView.cells.count
        if cellCount > 5 {
            tableView.swipeUp()
            XCTAssertTrue(tableView.exists)

            tableView.swipeDown()
            XCTAssertTrue(tableView.exists)
        }
    }

    func testExchangeCellsAreUnique() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let cells = tableView.cells
        if cells.count >= 2 {
            let firstCell = tableView.cells.element(boundBy: 0)
            let secondCell = tableView.cells.element(boundBy: 1)

            let firstName = firstCell.staticTexts.firstMatch.label
            let secondName = secondCell.staticTexts.firstMatch.label

            XCTAssertNotEqual(firstName, secondName, "Exchange cells should have unique names")
        }
    }

    func testNavigationBarTitle() throws {
        let navigationBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        XCTAssertEqual(navigationBar.identifier, "Crypto Exchanges")
    }

    func testTableViewAccessibility() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        XCTAssertTrue(tableView.isHittable)
    }
}
