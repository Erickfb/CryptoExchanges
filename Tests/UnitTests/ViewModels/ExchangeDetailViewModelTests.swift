import XCTest
@testable import CryptoExchanges

final class ExchangeDetailViewModelTests: XCTestCase {
    var sut: ExchangeDetailViewModel!
    var mockAPIService: MockAPIService!
    var mockExchange: Exchange!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockExchange = createMockExchange()
        sut = ExchangeDetailViewModel(exchange: mockExchange, apiService: mockAPIService)
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        mockExchange = nil
        super.tearDown()
    }

    func testExchangeProperties() {
        XCTAssertEqual(sut.exchangeName, "Binance")
        XCTAssertEqual(sut.exchangeId, 1)
    }

    func testLoadAssetsSuccess() async {
        let mockAssets = createMockAssets()
        mockAPIService.assetsToReturn = mockAssets

        await sut.loadAssets()

        XCTAssertEqual(sut.numberOfAssets, mockAssets.count)
        XCTAssertEqual(sut.assets.count, mockAssets.count)

        if case .loaded = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should be loaded after successful fetch")
        }
    }

    func testLoadAssetsFailure() async {
        mockAPIService.shouldFail = true
        mockAPIService.errorToThrow = NetworkError.serverError("Test error")

        await sut.loadAssets()

        XCTAssertEqual(sut.numberOfAssets, 0)

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Test error"))
        } else {
            XCTFail("State should be error after failed fetch")
        }
    }

    func testAssetAtValidIndex() async {
        let mockAssets = createMockAssets()
        mockAPIService.assetsToReturn = mockAssets

        await sut.loadAssets()

        let asset = sut.asset(at: 0)
        XCTAssertNotNil(asset)
        XCTAssertEqual(asset?.currency.name, "Bitcoin")
    }

    func testAssetAtInvalidIndex() {
        let asset = sut.asset(at: 100)
        XCTAssertNil(asset)
    }

    func testInitialAssetsState() {
        XCTAssertEqual(sut.numberOfAssets, 0)

        if case .idle = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle")
        }
    }

    private func createMockExchange() -> Exchange {
        let exchangeInfo = ExchangeInfo(
            id: 1,
            name: "Binance",
            slug: "binance",
            logo: "https://example.com/binance.png",
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
            logo: "https://example.com/binance.png",
            dateLaunched: "2017-07-14T00:00:00.000Z",
            spotVolumeUSD: 1000000.0,
            exchangeInfo: exchangeInfo
        )
    }

    private func createMockAssets() -> [ExchangeAsset] {
        return [
            ExchangeAsset(
                walletAddress: "0x123",
                balance: 1.5,
                currency: AssetCurrency(
                    cryptoId: 1,
                    name: "Bitcoin",
                    symbol: "BTC",
                    priceUSD: 50000.0
                )
            ),
            ExchangeAsset(
                walletAddress: "0x456",
                balance: 10.0,
                currency: AssetCurrency(
                    cryptoId: 2,
                    name: "Ethereum",
                    symbol: "ETH",
                    priceUSD: 3000.0
                )
            )
        ]
    }
}
