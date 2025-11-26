import XCTest
@testable import CryptoExchanges

final class ExchangeListViewModelTests: XCTestCase {
    var sut: ExchangeListViewModel!
    var mockAPIService: MockAPIService!

    override func setUp() {
        super.setUp()
        mockAPIService = MockAPIService()
        sut = ExchangeListViewModel(apiService: mockAPIService)
    }

    override func tearDown() {
        sut = nil
        mockAPIService = nil
        super.tearDown()
    }

    func testInitialState() {
        XCTAssertEqual(sut.numberOfExchanges, 0)
        if case .idle = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("Initial state should be idle")
        }
    }

    func testLoadExchangesSuccess() async {
        let mockExchanges = createMockExchanges()
        mockAPIService.exchangesToReturn = mockExchanges

        await sut.loadExchanges()

        XCTAssertEqual(sut.numberOfExchanges, mockExchanges.count)
        XCTAssertEqual(sut.exchanges.count, mockExchanges.count)

        if case .loaded = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should be loaded after successful fetch")
        }
    }

    func testLoadExchangesFailure() async {
        mockAPIService.shouldFail = true
        mockAPIService.errorToThrow = NetworkError.serverError("Test error")

        await sut.loadExchanges()

        XCTAssertEqual(sut.numberOfExchanges, 0)

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Test error"))
        } else {
            XCTFail("State should be error after failed fetch")
        }
    }

    func testLoadExchangesUnauthorized() async {
        mockAPIService.shouldFail = true
        mockAPIService.errorToThrow = NetworkError.unauthorized

        await sut.loadExchanges()

        if case .error(let message) = sut.state {
            XCTAssertTrue(message.contains("Unauthorized"))
        } else {
            XCTFail("State should be error with unauthorized message")
        }
    }

    func testExchangeAtValidIndex() async {
        let mockExchanges = createMockExchanges()
        mockAPIService.exchangesToReturn = mockExchanges

        await sut.loadExchanges()

        let exchange = sut.exchange(at: 0)
        XCTAssertNotNil(exchange)
        XCTAssertEqual(exchange?.id, mockExchanges[0].id)
    }

    func testExchangeAtInvalidIndex() {
        let exchange = sut.exchange(at: 100)
        XCTAssertNil(exchange)
    }

    func testLoadingState() async {
        mockAPIService.delayResponse = true

        Task {
            await sut.loadExchanges()
        }

        try? await Task.sleep(nanoseconds: 100_000_000)

        if case .loading = sut.state {
            XCTAssertTrue(true)
        } else {
            XCTFail("State should be loading during fetch")
        }
    }

    private func createMockExchanges() -> [Exchange] {
        return [
            Exchange(
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
                exchangeInfo: nil
            ),
            Exchange(
                id: 2,
                name: "Coinbase",
                slug: "coinbase",
                isActive: 1,
                status: "active",
                firstHistoricalData: "2012-06-01T00:00:00.000Z",
                lastHistoricalData: "2024-01-01T00:00:00.000Z",
                logo: "https://example.com/coinbase.png",
                dateLaunched: "2012-06-01T00:00:00.000Z",
                spotVolumeUSD: 500000.0,
                exchangeInfo: nil
            )
        ]
    }
}
