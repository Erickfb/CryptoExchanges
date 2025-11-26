import UIKit

final class ExchangeDetailCoordinator: Coordinator {
    var navigationController: UINavigationController
    private let exchange: Exchange

    init(navigationController: UINavigationController, exchange: Exchange) {
        self.navigationController = navigationController
        self.exchange = exchange
    }

    func start() {
        print("🔵 ExchangeDetailCoordinator: start() called for \(exchange.name)")
        let apiService: APIService
        if AppDelegate.isUITesting {
            let mockService = MockAPIService()
            mockService.useJSONFiles = true
            apiService = mockService
        } else {
            apiService = CoinMarketCapService(apiKey: Config.coinMarketCapAPIKey)
        }

        let viewModel = ExchangeDetailViewModel(
            exchange: exchange,
            apiService: apiService
        )

        let viewController = ExchangeDetailViewController(viewModel: viewModel)
        print("🔵 Pushing detail view controller...")
        navigationController.pushViewController(viewController, animated: true)
        print("🔵 View controller pushed successfully")
    }
}
