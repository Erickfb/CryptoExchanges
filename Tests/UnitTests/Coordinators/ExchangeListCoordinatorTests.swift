import XCTest
@testable import CryptoExchanges

final class ExchangeListCoordinatorTests: XCTestCase {
    var sut: ExchangeListCoordinator!
    var navigationController: UINavigationController!

    override func setUp() {
        super.setUp()
        navigationController = UINavigationController()
        sut = ExchangeListCoordinator(navigationController: navigationController)
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

    func testStartPushesExchangeListViewController() {
        XCTAssertEqual(navigationController.viewControllers.count, 0)

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertTrue(navigationController.viewControllers.first is ExchangeListViewController)
    }

    func testShowExchangeDetailPushesDetailViewController() {
        sut.start()

        let mockExchange = createMockExchange()

        sut.showExchangeDetail(exchange: mockExchange)

        XCTAssertEqual(navigationController.viewControllers.count, 2)
        XCTAssertTrue(navigationController.viewControllers.last is ExchangeDetailViewController)
    }

    private func createMockExchange() -> Exchange {
        return Exchange(
            id: 1,
            name: "Binance",
            slug: "binance",
            isActive: 1,
            status: "active",
            firstHistoricalData: nil,
            lastHistoricalData: nil,
            logo: nil,
            dateLaunched: nil,
            spotVolumeUSD: nil,
            exchangeInfo: nil
        )
    }
}
