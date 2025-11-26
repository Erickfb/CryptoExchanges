import XCTest
@testable import CryptoExchanges

final class CoinMarketCapServiceTests: XCTestCase {
    var sut: CoinMarketCapService!

    override func setUp() {
        super.setUp()
        sut = CoinMarketCapService(apiKey: "test-api-key")
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func testFetchExchangesWithEmptyAPIKey() async {
        let service = CoinMarketCapService(apiKey: "")

        do {
            _ = try await service.fetchExchanges()
            XCTFail("Should throw unauthorized error with empty API key")
        } catch NetworkError.unauthorized {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Should throw unauthorized error, got \(error)")
        }
    }

    func testFetchExchangeAssetsWithEmptyAPIKey() async {
        let service = CoinMarketCapService(apiKey: "")

        do {
            _ = try await service.fetchExchangeAssets(exchangeId: 1)
            XCTFail("Should throw unauthorized error with empty API key")
        } catch NetworkError.unauthorized {
            XCTAssertTrue(true)
        } catch {
            XCTFail("Should throw unauthorized error, got \(error)")
        }
    }

    func testNetworkErrorHandling() {
        let error = NetworkError.serverError("Test error")
        XCTAssertEqual(error.errorDescription, "Server error: Test error")

        let invalidURLError = NetworkError.invalidURL
        XCTAssertEqual(invalidURLError.errorDescription, "Invalid URL")

        let unauthorizedError = NetworkError.unauthorized
        XCTAssertEqual(unauthorizedError.errorDescription, "Unauthorized. Please check your API key")
    }
}
