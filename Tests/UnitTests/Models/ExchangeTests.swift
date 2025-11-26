import XCTest
@testable import CryptoExchanges

final class ExchangeTests: XCTestCase {
    func testExchangeDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "Binance",
            "slug": "binance",
            "is_active": 1,
            "status": "active",
            "first_historical_data": "2017-07-14T00:00:00.000Z",
            "last_historical_data": "2024-01-01T00:00:00.000Z",
            "logo": "https://example.com/logo.png",
            "date_launched": "2017-07-14T00:00:00.000Z",
            "spot_volume_usd": 1000000.0
        }
        """

        let data = json.data(using: .utf8)!
        let exchange = try JSONDecoder().decode(Exchange.self, from: data)

        XCTAssertEqual(exchange.id, 1)
        XCTAssertEqual(exchange.name, "Binance")
        XCTAssertEqual(exchange.slug, "binance")
        XCTAssertEqual(exchange.isActive, 1)
        XCTAssertEqual(exchange.status, "active")
        XCTAssertEqual(exchange.logo, "https://example.com/logo.png")
        XCTAssertEqual(exchange.dateLaunched, "2017-07-14T00:00:00.000Z")
        XCTAssertEqual(exchange.spotVolumeUSD, 1000000.0)
    }

    func testExchangeDecodingWithMissingOptionalFields() throws {
        let json = """
        {
            "id": 1,
            "name": "Binance",
            "slug": "binance"
        }
        """

        let data = json.data(using: .utf8)!
        let exchange = try JSONDecoder().decode(Exchange.self, from: data)

        XCTAssertEqual(exchange.id, 1)
        XCTAssertEqual(exchange.name, "Binance")
        XCTAssertNil(exchange.logo)
        XCTAssertNil(exchange.dateLaunched)
        XCTAssertNil(exchange.spotVolumeUSD)
    }

    func testExchangeInfoDecoding() throws {
        let json = """
        {
            "id": 1,
            "name": "Binance",
            "slug": "binance",
            "logo": "https://example.com/logo.png",
            "description": "Test description",
            "date_launched": "2017-07-14T00:00:00.000Z",
            "urls": {
                "website": ["https://binance.com", "https://binance.us"],
                "twitter": ["https://twitter.com/binance"],
                "chat": ["https://t.me/binance"],
                "fee": ["https://binance.com/fees"],
                "blog": ["https://binance.com/blog"]
            },
            "spot_volume_usd": 1000000.0,
            "maker_fee": 0.001,
            "taker_fee": 0.001,
            "weekly_visits": 10000,
            "countries": ["US", "UK"],
            "fiats": ["USD", "EUR"]
        }
        """

        let data = json.data(using: .utf8)!
        let exchangeInfo = try JSONDecoder().decode(ExchangeInfo.self, from: data)

        XCTAssertEqual(exchangeInfo.id, 1)
        XCTAssertEqual(exchangeInfo.name, "Binance")
        XCTAssertEqual(exchangeInfo.slug, "binance")
        XCTAssertEqual(exchangeInfo.logo, "https://example.com/logo.png")
        XCTAssertEqual(exchangeInfo.description, "Test description")
        XCTAssertEqual(exchangeInfo.dateLaunched, "2017-07-14T00:00:00.000Z")
        XCTAssertEqual(exchangeInfo.urls?.website?.count, 2)
        XCTAssertEqual(exchangeInfo.urls?.website?.first, "https://binance.com")
        XCTAssertEqual(exchangeInfo.urls?.twitter?.first, "https://twitter.com/binance")
        XCTAssertEqual(exchangeInfo.urls?.chat?.first, "https://t.me/binance")
        XCTAssertEqual(exchangeInfo.urls?.fee?.first, "https://binance.com/fees")
        XCTAssertEqual(exchangeInfo.urls?.blog?.first, "https://binance.com/blog")
        XCTAssertEqual(exchangeInfo.spotVolumeUSD, 1000000.0)
        XCTAssertEqual(exchangeInfo.makerFee, 0.001)
        XCTAssertEqual(exchangeInfo.takerFee, 0.001)
        XCTAssertEqual(exchangeInfo.weeklyVisits, 10000)
        XCTAssertEqual(exchangeInfo.countries?.count, 2)
        XCTAssertEqual(exchangeInfo.fiats?.count, 2)
    }

    func testExchangeURLsDecoding() throws {
        let json = """
        {
            "website": ["https://binance.com"],
            "twitter": ["https://twitter.com/binance"],
            "chat": ["https://t.me/binance"],
            "fee": ["https://binance.com/fees"],
            "blog": ["https://binance.com/blog"]
        }
        """

        let data = json.data(using: .utf8)!
        let urls = try JSONDecoder().decode(ExchangeURLs.self, from: data)

        XCTAssertEqual(urls.website?.first, "https://binance.com")
        XCTAssertEqual(urls.twitter?.first, "https://twitter.com/binance")
        XCTAssertEqual(urls.chat?.first, "https://t.me/binance")
        XCTAssertEqual(urls.fee?.first, "https://binance.com/fees")
        XCTAssertEqual(urls.blog?.first, "https://binance.com/blog")
    }

    func testExchangeDecodingWithInvalidData() {
        let json = "invalid json"
        let data = json.data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode(Exchange.self, from: data)) { error in
            XCTAssertTrue(error is DecodingError)
        }
    }
}
