import Foundation

struct ExchangeResponse: Codable {
    let status: Status
    let data: [Exchange]
}

struct ExchangeInfoResponse: Codable {
    let status: Status
    let data: [String: ExchangeInfo]
}

struct Status: Codable {
    let timestamp: String
    let errorCode: Int
    let errorMessage: String?

    enum CodingKeys: String, CodingKey {
        case timestamp
        case errorCode = "error_code"
        case errorMessage = "error_message"
    }
}

struct Exchange: Codable, Identifiable {
    let id: Int
    let name: String
    let slug: String
    let isActive: Int?
    let status: String?
    let firstHistoricalData: String?
    let lastHistoricalData: String?
    let logo: String?
    let dateLaunched: String?
    let spotVolumeUSD: Double?
    let exchangeInfo: ExchangeInfo?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, status, logo
        case isActive = "is_active"
        case firstHistoricalData = "first_historical_data"
        case lastHistoricalData = "last_historical_data"
        case dateLaunched = "date_launched"
        case spotVolumeUSD = "spot_volume_usd"
        case exchangeInfo
    }
}

struct ExchangeInfo: Codable {
    let id: Int
    let name: String
    let slug: String
    let logo: String?
    let description: String?
    let dateLaunched: String?
    let urls: ExchangeURLs?
    let spotVolumeUSD: Double?
    let makerFee: Double?
    let takerFee: Double?
    let weeklyVisits: Int?
    let countries: [String]?
    let fiats: [String]?

    enum CodingKeys: String, CodingKey {
        case id, name, slug, logo, description
        case dateLaunched = "date_launched"
        case urls
        case spotVolumeUSD = "spot_volume_usd"
        case makerFee = "maker_fee"
        case takerFee = "taker_fee"
        case weeklyVisits = "weekly_visits"
        case countries, fiats
    }
}

struct ExchangeURLs: Codable {
    let website: [String]?
    let twitter: [String]?
    let chat: [String]?
    let fee: [String]?
    let blog: [String]?
}
