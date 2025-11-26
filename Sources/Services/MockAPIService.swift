import Foundation

final class MockAPIService: APIService {
    var exchangesToReturn: [Exchange] = []
    var exchangeInfoToReturn: ExchangeInfo?
    var assetsToReturn: [ExchangeAsset] = []
    var shouldFail = false
    var errorToThrow: Error = NetworkError.serverError("Mock error")
    var delayResponse = false
    var useJSONFiles = false

    func fetchExchanges() async throws -> [Exchange] {
        if delayResponse {
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        if shouldFail {
            throw errorToThrow
        }

        if useJSONFiles {
            return try loadExchangesFromJSON()
        }

        return exchangesToReturn
    }

    func fetchExchangeInfo(exchangeId: Int) async throws -> ExchangeInfo {
        if delayResponse {
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        if shouldFail {
            throw errorToThrow
        }

        if useJSONFiles {
            return try loadExchangeInfoFromJSON(exchangeId: exchangeId)
        }

        guard let info = exchangeInfoToReturn else {
            throw NetworkError.noData
        }

        return info
    }

    func fetchExchangeAssets(exchangeId: Int) async throws -> [ExchangeAsset] {
        if delayResponse {
            try await Task.sleep(nanoseconds: 500_000_000)
        }

        if shouldFail {
            throw errorToThrow
        }

        if useJSONFiles {
            return try loadAssetsFromJSON()
        }

        return assetsToReturn
    }

    private func loadExchangesFromJSON() throws -> [Exchange] {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "exchange_map", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NetworkError.noData
        }

        let response = try JSONDecoder().decode(MockExchangeMapResponse.self, from: data)
        return response.data
    }

    private func loadExchangeInfoFromJSON(exchangeId: Int) throws -> ExchangeInfo {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "exchange_info", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NetworkError.noData
        }

        let response = try JSONDecoder().decode(MockExchangeInfoResponse.self, from: data)
        guard let info = response.data[String(exchangeId)] else {
            throw NetworkError.noData
        }
        return info
    }

    private func loadAssetsFromJSON() throws -> [ExchangeAsset] {
        let bundle = Bundle(for: type(of: self))
        guard let url = bundle.url(forResource: "exchange_assets", withExtension: "json"),
              let data = try? Data(contentsOf: url) else {
            throw NetworkError.noData
        }

        let response = try JSONDecoder().decode(MockExchangeAssetsResponse.self, from: data)
        return response.data
    }

    private struct MockExchangeMapResponse: Codable {
        let data: [Exchange]
    }

    private struct MockExchangeInfoResponse: Codable {
        let data: [String: ExchangeInfo]
    }

    private struct MockExchangeAssetsResponse: Codable {
        let data: [ExchangeAsset]
    }
}
