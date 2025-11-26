import Foundation

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(String)
    case networkError(Error)
    case unauthorized

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .noData:
            return "No data received"
        case .decodingError(let error):
            return "Failed to decode data: \(error.localizedDescription)"
        case .serverError(let message):
            return "Server error: \(message)"
        case .networkError(let error):
            return "Network error: \(error.localizedDescription)"
        case .unauthorized:
            return "Unauthorized. Please check your API key"
        }
    }
}

protocol APIService {
    func fetchExchanges() async throws -> [Exchange]
    func fetchExchangeAssets(exchangeId: Int) async throws -> [ExchangeAsset]
}

final class CoinMarketCapService: APIService {
    private let baseURL = "https://pro-api.coinmarketcap.com/v1"
    private let apiKey: String

    init(apiKey: String = "") {
        self.apiKey = apiKey
    }

    func fetchExchanges() async throws -> [Exchange] {
        Logger.log("STEP 1: Fetching Exchange IDs", category: .network)
        let exchangeIds = try await fetchExchangeIds()

        Logger.log("STEP 2: Fetching Exchange Details", category: .network)
        let exchangeInfos = try await fetchExchangeInfoBatch(exchangeIds: exchangeIds)

        let exchanges = exchangeInfos.map { info in
            Exchange(
                id: info.id,
                name: info.name,
                slug: info.slug,
                isActive: nil,
                status: nil,
                firstHistoricalData: nil,
                lastHistoricalData: nil,
                logo: info.logo,
                dateLaunched: info.dateLaunched,
                spotVolumeUSD: info.spotVolumeUSD,
                exchangeInfo: info
            )
        }

        Logger.logSuccess("Successfully fetched \(exchanges.count) exchanges with full details")
        return exchanges
    }

    private func fetchExchangeIds() async throws -> [Int] {
        guard let url = URL(string: "\(baseURL)/exchange/map") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        Logger.logAPIRequest(url: url.absoluteString, headers: request.allHTTPHeaderFields ?? [:])

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            Logger.logAPIResponse(statusCode: httpResponse.statusCode, dataSize: data.count)

            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ExchangeResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.status.errorMessage ?? "Unknown error")
                }
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(ExchangeResponse.self, from: data)
            let exchangeIds = decodedResponse.data.map { $0.id }
            Logger.logSuccess("Successfully fetched \(exchangeIds.count) exchange IDs")
            return exchangeIds
        } catch let error as NetworkError {
            Logger.logError(error, context: "fetchExchangeIds")
            throw error
        } catch {
            Logger.logError(error, context: "fetchExchangeIds")
            throw NetworkError.networkError(error)
        }
    }

    private func fetchExchangeInfoBatch(exchangeIds: [Int]) async throws -> [ExchangeInfo] {
        let idsString = exchangeIds.map { String($0) }.joined(separator: ",")
        guard let url = URL(string: "\(baseURL)/exchange/info?id=\(idsString)&aux=logo,date_launched,description,urls") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        Logger.logAPIRequest(url: url.absoluteString, headers: request.allHTTPHeaderFields ?? [:])

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            Logger.logAPIResponse(statusCode: httpResponse.statusCode, dataSize: data.count)
            Logger.logJSON(data)

            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ExchangeInfoResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.status.errorMessage ?? "Unknown error")
                }
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(ExchangeInfoResponse.self, from: data)
            let exchangeInfos = Array(decodedResponse.data.values)
            Logger.logSuccess("Successfully decoded \(exchangeInfos.count) exchange infos")
            return exchangeInfos
        } catch let error as NetworkError {
            Logger.logError(error, context: "fetchExchangeInfoBatch")
            throw error
        } catch {
            Logger.logError(error, context: "fetchExchangeInfoBatch")
            throw NetworkError.networkError(error)
        }
    }

    func fetchExchangeAssets(exchangeId: Int) async throws -> [ExchangeAsset] {
        guard let url = URL(string: "\(baseURL)/exchange/assets?id=\(exchangeId)") else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.setValue(apiKey, forHTTPHeaderField: "X-CMC_PRO_API_KEY")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        Logger.logAPIRequest(url: url.absoluteString, headers: request.allHTTPHeaderFields ?? [:])

        do {
            let (data, urlResponse) = try await URLSession.shared.data(for: request)

            guard let httpResponse = urlResponse as? HTTPURLResponse else {
                throw NetworkError.noData
            }

            Logger.logAPIResponse(statusCode: httpResponse.statusCode, dataSize: data.count)
            Logger.logJSON(data)

            if httpResponse.statusCode == 401 {
                throw NetworkError.unauthorized
            }

            guard httpResponse.statusCode == 200 else {
                if let errorResponse = try? JSONDecoder().decode(ExchangeAssetResponse.self, from: data) {
                    throw NetworkError.serverError(errorResponse.status.errorMessage ?? "Unknown error")
                }
                throw NetworkError.serverError("HTTP \(httpResponse.statusCode)")
            }

            let decoder = JSONDecoder()
            let decodedResponse = try decoder.decode(ExchangeAssetResponse.self, from: data)
            Logger.logSuccess("Successfully decoded \(decodedResponse.data.count) assets")
            return decodedResponse.data
        } catch let error as NetworkError {
            Logger.logError(error, context: "fetchExchangeAssets")
            throw error
        } catch {
            Logger.logError(error, context: "fetchExchangeAssets")
            throw NetworkError.networkError(error)
        }
    }
}
