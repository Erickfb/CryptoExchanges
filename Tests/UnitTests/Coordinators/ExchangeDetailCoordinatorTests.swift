import XCTest
@testable import CryptoExchanges

final class ExchangeDetailCoordinatorTests: XCTestCase {
    var sut: ExchangeDetailCoordinator!
    var navigationController: UINavigationController!
    var mockExchange: Exchange!

    override func setUp() {
        super.setUp()
        navigationController = UINavigationController()
        mockExchange = createMockExchange()
        sut = ExchangeDetailCoordinator(
            navigationController: navigationController,
            exchange: mockExchange
        )
    }

    override func tearDown() {
        sut = nil
        navigationController = nil
        mockExchange = nil
        super.tearDown()
    }

    func testInitialization() {
        XCTAssertNotNil(sut)
        XCTAssertEqual(sut.navigationController, navigationController)
    }

    func testStartPushesExchangeDetailViewController() {
        XCTAssertEqual(navigationController.viewControllers.count, 0)

        sut.start()

        XCTAssertEqual(navigationController.viewControllers.count, 1)
        XCTAssertTrue(navigationController.viewControllers.first is ExchangeDetailViewController)
    }

    func testDetailViewControllerHasCorrectExchange() {
        sut.start()

        guard let detailVC = navigationController.viewControllers.first as? ExchangeDetailViewController else {
            XCTFail("Expected ExchangeDetailViewController")
            return
        }

        XCTAssertEqual(detailVC.viewModel.exchangeName, "Binance")
        XCTAssertEqual(detailVC.viewModel.exchangeId, 1)
    }

    private func createMockExchange() -> Exchange {
        let exchangeInfo = ExchangeInfo(
            id: 1,
            name: "Binance",
            slug: "binance",
            logo: "https://example.com/logo.png",
            description: "Test exchange",
            dateLaunched: "2017-07-14T00:00:00.000Z",
            urls: ExchangeURLs(
                website: ["https://binance.com"],
                twitter: nil,
                chat: nil,
                fee: nil,
                blog: nil
            ),
            spotVolumeUSD: 1000000.0,
            makerFee: 0.001,
            takerFee: 0.001,
            weeklyVisits: 10000,
            countries: ["US"],
            fiats: ["USD"]
        )

        return Exchange(
            id: 1,
            name: "Binance",
            slug: "binance",
            isActive: 1,
            status: "active",
            firstHistoricalData: "2017-07-14T00:00:00.000Z",
            lastHistoricalData: "2024-01-01T00:00:00.000Z",
            logo: "https://example.com/logo.png",
            dateLaunched: "2017-07-14T00:00:00.000Z",
            spotVolumeUSD: 1000000.0,
            exchangeInfo: exchangeInfo
        )
    }
}
