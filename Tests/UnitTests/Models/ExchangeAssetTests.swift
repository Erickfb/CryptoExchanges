import XCTest
@testable import CryptoExchanges

final class ExchangeAssetTests: XCTestCase {
    func testExchangeAssetDecoding() throws {
        let json = """
        {
            "wallet_address": "0x123",
            "balance": 1.5,
            "currency": {
                "crypto_id": 1,
                "name": "Bitcoin",
                "symbol": "BTC",
                "price_usd": 50000.0
            }
        }
        """

        let data = json.data(using: .utf8)!
        let asset = try JSONDecoder().decode(ExchangeAsset.self, from: data)

        XCTAssertEqual(asset.walletAddress, "0x123")
        XCTAssertEqual(asset.balance, 1.5)
        XCTAssertEqual(asset.currency.cryptoId, 1)
        XCTAssertEqual(asset.currency.name, "Bitcoin")
        XCTAssertEqual(asset.currency.symbol, "BTC")
        XCTAssertEqual(asset.currency.priceUSD, 50000.0)
        XCTAssertEqual(asset.id, 1)
    }

    func testCurrencyDecodingWithMissingPrice() throws {
        let json = """
        {
            "wallet_address": "0x123",
            "balance": 1.5,
            "currency": {
                "crypto_id": 1,
                "name": "Bitcoin",
                "symbol": "BTC"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let asset = try JSONDecoder().decode(ExchangeAsset.self, from: data)

        XCTAssertNil(asset.currency.priceUSD)
    }

    func testMultipleAssetsDecoding() throws {
        let json = """
        [
            {
                "wallet_address": "0x123",
                "balance": 1.5,
                "currency": {
                    "crypto_id": 1,
                    "name": "Bitcoin",
                    "symbol": "BTC",
                    "price_usd": 50000.0
                }
            },
            {
                "wallet_address": "0x456",
                "balance": 10.0,
                "currency": {
                    "crypto_id": 2,
                    "name": "Ethereum",
                    "symbol": "ETH",
                    "price_usd": 3000.0
                }
            }
        ]
        """

        let data = json.data(using: .utf8)!
        let assets = try JSONDecoder().decode([ExchangeAsset].self, from: data)

        XCTAssertEqual(assets.count, 2)
        XCTAssertEqual(assets[0].currency.name, "Bitcoin")
        XCTAssertEqual(assets[1].currency.name, "Ethereum")
    }

    func testCurrencyIdProperty() throws {
        let json = """
        {
            "wallet_address": "0x999",
            "balance": 2.0,
            "currency": {
                "crypto_id": 999,
                "name": "Bitcoin",
                "symbol": "BTC",
                "price_usd": 50000.0
            }
        }
        """

        let data = json.data(using: .utf8)!
        let asset = try JSONDecoder().decode(ExchangeAsset.self, from: data)

        XCTAssertEqual(asset.id, 999)
        XCTAssertEqual(asset.currency.cryptoId, 999)
    }

    func testAssetWithMissingOptionalFields() throws {
        let json = """
        {
            "currency": {
                "crypto_id": 1,
                "name": "Bitcoin",
                "symbol": "BTC"
            }
        }
        """

        let data = json.data(using: .utf8)!
        let asset = try JSONDecoder().decode(ExchangeAsset.self, from: data)

        XCTAssertNil(asset.walletAddress)
        XCTAssertNil(asset.balance)
        XCTAssertNil(asset.currency.priceUSD)
    }
}
