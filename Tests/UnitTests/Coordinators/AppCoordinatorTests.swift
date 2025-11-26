import XCTest
@testable import CryptoExchanges

final class AppCoordinatorTests: XCTestCase {
    var sut: AppCoordinator!
    var navigationController: UINavigationController!

    override func setUp() {
        super.setUp()
        navigationController = UINavigationController()
        sut = AppCoordinator(navigationController: navigationController)
    }

    override func tearDown() {
        sut = nil
        navigationController = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.navigationController, navigationController)
    }

    func testStartSetsUpExchangeList() {
        sut.start()

        XCTAssertTrue(navigationController.viewControllers.count > 0)
        XCTAssertTrue(navigationController.viewControllers.first is ExchangeListViewController)
    }

    func testShowExchangeListAddsViewController() {
        XCTAssertEqual(navigationController.viewControllers.count, 0)

        sut.showExchangeList()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertTrue(navigationController.viewControllers.first is ExchangeListViewController)
    }
}
