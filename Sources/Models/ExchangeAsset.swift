import Foundation

struct ExchangeAssetResponse: Codable {
    let status: Status
    let data: [ExchangeAsset]
}

struct ExchangeAsset: Codable, Identifiable {
    let walletAddress: String?
    let balance: Double?
    let currency: AssetCurrency

    var id: Int {
        currency.cryptoId
    }

    enum CodingKeys: String, CodingKey {
        case walletAddress = "wallet_address"
        case balance
        case currency
    }
}

struct AssetCurrency: Codable {
    let cryptoId: Int
    let name: String
    let symbol: String
    let priceUSD: Double?

    enum CodingKeys: String, CodingKey {
        case cryptoId = "crypto_id"
        case name
        case symbol
        case priceUSD = "price_usd"
    }
}
