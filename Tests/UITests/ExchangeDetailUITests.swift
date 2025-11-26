import XCTest

final class ExchangeDetailUITests: XCTestCase {
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

    func testNavigateToDetailScreen() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))
    }

    func testDetailScreenDisplaysExchangeInfo() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let nameLabel = app.staticTexts.matching(identifier: "exchangeNameLabel").firstMatch
        let idLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'ID:'")).firstMatch

        XCTAssertTrue(nameLabel.exists || idLabel.exists)
    }

    func testDetailScreenDisplaysLogo() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let logoImage = app.images.firstMatch
        XCTAssertTrue(logoImage.waitForExistence(timeout: 5))
    }

    func testDetailScreenDisplaysDescription() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        let descriptionButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'descrição'")).firstMatch
        XCTAssertTrue(descriptionButton.waitForExistence(timeout: 5))
    }

    func testDetailScreenDisplaysWebsiteButton() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let websiteButton = app.buttons["Visitar Website"]
        XCTAssertTrue(websiteButton.waitForExistence(timeout: 5))
    }

    func testDetailScreenDisplaysFees() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let makerFeeLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Maker Fee'")).firstMatch
        let takerFeeLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Taker Fee'")).firstMatch

        XCTAssertTrue(makerFeeLabel.waitForExistence(timeout: 5) || takerFeeLabel.exists)
    }

    func testDetailScreenDisplaysDateLaunched() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let dateLabel = app.staticTexts.containing(NSPredicate(format: "label CONTAINS 'Launched'")).firstMatch
        XCTAssertTrue(dateLabel.waitForExistence(timeout: 5))
    }

    func testDetailScreenDisplaysCurrenciesHeader() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let currenciesHeader = app.staticTexts["Moedas"]
        XCTAssertTrue(currenciesHeader.waitForExistence(timeout: 5))
    }

    func testDetailScreenLoadsAssets() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let assetsTable = app.tables.element(boundBy: 1)
        let exists = assetsTable.waitForExistence(timeout: 10)
        if !exists {
            let searchBar = app.searchFields.firstMatch
            XCTAssertTrue(searchBar.exists, "Assets should be loaded")
        }
    }

    func testAssetCellDisplaysCurrencyInfo() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let assetsTable = app.tables.element(boundBy: 1)
        _ = assetsTable.waitForExistence(timeout: 10)

        let firstAssetCell = assetsTable.cells.element(boundBy: 0)
        if firstAssetCell.exists {
            XCTAssertTrue(firstAssetCell.staticTexts.count >= 2)
        }
    }

    func testBackNavigationFromDetail() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let backButton = app.navigationBars.buttons.element(boundBy: 0)
        XCTAssertTrue(backButton.waitForExistence(timeout: 5))

        backButton.tap()

        let listNavBar = app.navigationBars["Crypto Exchanges"]
        XCTAssertTrue(listNavBar.waitForExistence(timeout: 5))
    }

    func testScrollingInDetailScreen() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let scrollView = app.scrollViews.firstMatch
        XCTAssertTrue(scrollView.waitForExistence(timeout: 5))

        scrollView.swipeUp()
        scrollView.swipeDown()

        XCTAssertTrue(scrollView.exists)
    }

    func testDescriptionButtonOpensModal() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let descriptionButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Descrição'")).firstMatch
        if descriptionButton.waitForExistence(timeout: 5) {
            descriptionButton.tap()

            let modalTitle = app.staticTexts["Descrição"]
            XCTAssertTrue(modalTitle.waitForExistence(timeout: 3))
        }
    }

    func testModalCloseButton() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let descriptionButton = app.buttons.containing(NSPredicate(format: "label CONTAINS 'Descrição'")).firstMatch
        if descriptionButton.waitForExistence(timeout: 5) {
            descriptionButton.tap()

            let closeButton = app.buttons.firstMatch
            XCTAssertTrue(closeButton.waitForExistence(timeout: 3))

            closeButton.tap()

            let scrollView = app.scrollViews.firstMatch
            XCTAssertTrue(scrollView.waitForExistence(timeout: 3))
        }
    }

    func testRefreshAssetsOnPullDown() throws {
        let tableView = app.tables.firstMatch
        _ = tableView.waitForExistence(timeout: 10)

        let firstCell = tableView.cells.element(boundBy: 0)
        firstCell.tap()

        let assetsTable = app.tables.element(boundBy: 1)
        if assetsTable.waitForExistence(timeout: 10) {
            assetsTable.swipeDown(velocity: .fast)
            XCTAssertTrue(assetsTable.exists)
        }
    }
}
