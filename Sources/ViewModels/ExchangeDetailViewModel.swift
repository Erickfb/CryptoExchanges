import Foundation

final class ExchangeDetailViewModel {
    private let exchange: Exchange
    private let apiService: APIService

    @Published private(set) var exchangeInfo: ExchangeInfo?
    @Published private(set) var assets: [ExchangeAsset] = []
    @Published private(set) var state: LoadingState = .idle
    @Published private(set) var isLoadingAssets: Bool = false

    private var allAssets: [ExchangeAsset] = []

    init(exchange: Exchange, apiService: APIService) {
        self.exchange = exchange
        self.apiService = apiService
        self.exchangeInfo = exchange.exchangeInfo
    }

    var exchangeName: String {
        exchangeInfo?.name ?? exchange.name
    }

    var exchangeId: Int {
        exchange.id
    }

    var exchangeLogo: String? {
        exchangeInfo?.logo
    }

    var exchangeDescription: String? {
        exchangeInfo?.description
    }

    var websiteURL: String? {
        exchangeInfo?.urls?.website?.first
    }

    var makerFee: Double? {
        exchangeInfo?.makerFee
    }

    var takerFee: Double? {
        exchangeInfo?.takerFee
    }

    var dateLaunched: String? {
        exchangeInfo?.dateLaunched
    }

    var weeklyVisits: Int? {
        exchangeInfo?.weeklyVisits
    }

    var spotVolumeUSD: Double? {
        exchangeInfo?.spotVolumeUSD
    }

    var countries: [String]? {
        exchangeInfo?.countries
    }

    var fiats: [String]? {
        exchangeInfo?.fiats
    }

    @MainActor
    func loadAssets() async {
        isLoadingAssets = true
        do {
            let fetchedAssets = try await apiService.fetchExchangeAssets(exchangeId: exchange.id)
            allAssets = fetchedAssets
            assets = fetchedAssets
        } catch {
            let errorMessage = error.localizedDescription
            print("Failed to load assets: \(errorMessage)")
        }
        isLoadingAssets = false
    }

    func filterAssets(with searchText: String) {
        if searchText.isEmpty {
            assets = allAssets
        } else {
            assets = allAssets.filter { asset in
                asset.currency.name.lowercased().contains(searchText.lowercased()) ||
                asset.currency.symbol.lowercased().contains(searchText.lowercased())
            }
        }
    }

    var numberOfAssets: Int {
        assets.count
    }

    func asset(at index: Int) -> ExchangeAsset? {
        guard index >= 0 && index < assets.count else {
            return nil
        }
        return assets[index]
    }
}
