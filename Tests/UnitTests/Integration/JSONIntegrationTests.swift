import XCTest
@testable import CryptoExchanges

final class JSONIntegrationTests: XCTestCase {
    var mockAPIService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        mockAPIService.useJSONFiles = true
    }

    override func tearDown() {
        mockAPIService = nil
        super.tearDown()
    }

    func testLoadExchangesFromJSON() async throws {
        let exchanges = try await mockAPIService.fetchExchanges()

        XCTAssertFalse(exchanges.isEmpty)
        XCTAssertEqual(exchanges.count, 3)

        let uniswap = exchanges.first { $0.id == 1419 }
        XCTAssertNotNil(uniswap)
        XCTAssertEqual(uniswap?.name, "Uniswap v3 (Optimism)")
        XCTAssertEqual(uniswap?.slug, "uniswap-v3-optimism")

        let kraken = exchanges.first { $0.id == 24 }
        XCTAssertNotNil(kraken)
        XCTAssertEqual(kraken?.name, "Kraken")

        let binance = exchanges.first { $0.id == 270 }
        XCTAssertNotNil(binance)
        XCTAssertEqual(binance?.name, "Binance")
    }

    func testLoadExchangeInfoFromJSON() async throws {
        let exchangeInfo = try await mockAPIService.fetchExchangeInfo(exchangeId: 1419)

        XCTAssertEqual(exchangeInfo.id, 1419)
        XCTAssertEqual(exchangeInfo.name, "Uniswap v3 (Optimism)")
        XCTAssertEqual(exchangeInfo.slug, "uniswap-v3-optimism")
        XCTAssertNotNil(exchangeInfo.description)
        XCTAssertTrue(exchangeInfo.description?.contains("Uniswap") ?? false)

        XCTAssertNotNil(exchangeInfo.urls)
        XCTAssertEqual(exchangeInfo.urls?.website?.first, "https://app.uniswap.org/")
        XCTAssertEqual(exchangeInfo.urls?.twitter?.first, "https://twitter.com/Uniswap")

        XCTAssertEqual(exchangeInfo.makerFee, 0.0005)
        XCTAssertEqual(exchangeInfo.takerFee, 0.003)
        XCTAssertEqual(exchangeInfo.weeklyVisits, 445775)
    }

    func testLoadExchangeAssetsFromJSON() async throws {
        let assets = try await mockAPIService.fetchExchangeAssets(exchangeId: 1419)

        XCTAssertFalse(assets.isEmpty)
        XCTAssertEqual(assets.count, 3)

        let bitcoin = assets.first { $0.id == 1 }
        XCTAssertNotNil(bitcoin)
        XCTAssertEqual(bitcoin?.currency.name, "Bitcoin")
        XCTAssertEqual(bitcoin?.currency.symbol, "BTC")
        XCTAssertEqual(bitcoin?.currency.cryptoId, 1)
        XCTAssertEqual(bitcoin?.walletAddress, "bc1qxy2kgdygjrsqtzq2n0yrf2493p83kkfjhx0wlh")
        XCTAssertEqual(bitcoin?.balance, 1000.5)
        XCTAssertEqual(bitcoin?.currency.priceUSD, 45000.50)

        let ethereum = assets.first { $0.id == 1027 }
        XCTAssertNotNil(ethereum)
        XCTAssertEqual(ethereum?.currency.name, "Ethereum")
        XCTAssertEqual(ethereum?.currency.symbol, "ETH")
        XCTAssertEqual(ethereum?.balance, 5000.25)
        XCTAssertEqual(ethereum?.currency.priceUSD, 3200.75)

        let tether = assets.first { $0.id == 825 }
        XCTAssertNotNil(tether)
        XCTAssertEqual(tether?.currency.name, "Tether")
        XCTAssertEqual(tether?.currency.symbol, "USDT")
        XCTAssertEqual(tether?.balance, 100000.0)
        XCTAssertEqual(tether?.currency.priceUSD, 1.0)
    }

    func testExchangeListViewModelWithJSON() async {
        let viewModel = ExchangeListViewModel(apiService: mockAPIService)

        await viewModel.loadExchanges()

        XCTAssertEqual(viewModel.numberOfExchanges, 3)

        if case .loaded = viewModel.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("ViewModel should be in loaded state")
        }

        let firstExchange = viewModel.exchange(at: 0)
        XCTAssertNotNil(firstExchange)
    }

    func testExchangeDetailViewModelWithJSON() async throws {
        let exchanges = try await mockAPIService.fetchExchanges()
        guard let uniswap = exchanges.first(where: { $0.id == 1419 }) else {
            XCTFail("Could not find Uniswap exchange in mock data")
            return
        }

        let viewModel = ExchangeDetailViewModel(
            exchange: uniswap,
            apiService: mockAPIService
        )

        await viewModel.loadAssets()

        XCTAssertEqual(viewModel.numberOfAssets, 3)

        let firstAsset = viewModel.asset(at: 0)
        XCTAssertNotNil(firstAsset)
        XCTAssertEqual(firstAsset?.currency.name, "Bitcoin")
    }
}
