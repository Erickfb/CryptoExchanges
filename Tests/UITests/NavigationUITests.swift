import XCTest

final class NavigationUITests: XCTestCase {
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

    func testAppLaunchesSuccessfully() throws {
        XCTAssertTrue(app.state == .runningForeground)
    }

    func testInitialScreenIsExchangeList() throws {
        let navigationBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
    }

    func testNavigationBarHasLargeTitle() throws {
        let navigationBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(navigationBar.exists)
    }

    func testNavigationFromListToDetail() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let navigationBar = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(navigationBar.exists)

        let backButton = navigationBar.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.exists)
    }

    func testBackNavigationRestoresListState() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let cellCount = tableView.cells.count

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()

        XCTAssertTrue(tableView.exists)
        XCTAssertEqual(tableView.cells.count, cellCount)
    }

    func testMultipleNavigationsWork() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        for i in 0..<min(3, tableView.cells.count) {
            let cell = tableView.cells.element(boundBy: i)
            cell.tap()

            let backButton = app.navigationBars.buttons.element(boundBy: 0)
            XCTAssertTrue(backButton.waitForExistence(timeout: 5))

            backButton.tap()

            XCTAssertTrue(tableView.exists)
        }
    }

    func testNavigationStackIsCorrect() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let listNavBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(listNavBar.exists)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let detailNavBar = app.navigationBars.element(boundBy: 0)
        XCTAssertTrue(detailNavBar.exists)
        XCTAssertFalse(listNavBar.exists)

        let backButton = detailNavBar.buttons.element(boundBy: 0)
        backButton.tap()

        XCTAssertTrue(listNavBar.exists)
    }

    func testNavigationBarAppearance() throws {
        let navigationBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(navigationBar.waitForExistence(timeout: 5))
        XCTAssertTrue(navigationBar.isHittable)
    }

    func testBackButtonAppearance() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))
        XCTAssertTrue(backButton.isEnabled)
        XCTAssertTrue(backButton.isHittable)
    }

    func testNavigationTransitions() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        backButton.tap()

        XCTAssertTrue(tableView.waitForExistence(timeout: 5))
    }
}
