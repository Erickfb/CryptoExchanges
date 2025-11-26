import UIKit

final class ExchangeListCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var detailCoordinator: ExchangeDetailCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let apiService: APIService
        if AppDelegate.isUITesting {
            let mockService = MockAPIService()
            mockService.useJSONFiles = true
            mockService.shouldFail = AppDelegate.shouldSimulateNetworkError
            mockService.errorToThrow = NetworkError.serverError("Network connection failed")
            apiService = mockService
        } else {
            apiService = CoinMarketCapService(apiKey: Config.coinMarketCapAPIKey)
        }

        let viewModel = ExchangeListViewModel(apiService: apiService)
        viewModel.coordinator = self

        let viewController = ExchangeListViewController(viewModel: viewModel)
        navigationController.pushViewController(viewController, animated: false)
    }

    func showExchangeDetail(exchange: Exchange) {
        print("🚀 ExchangeListCoordinator: showExchangeDetail called for \(exchange.name)")
        print("🚀 Navigation controller: \(navigationController)")
        let coordinator = ExchangeDetailCoordinator(
            navigationController: navigationController,
            exchange: exchange
        )
        detailCoordinator = coordinator
        coordinator.start()
        print("🚀 Detail coordinator started")
    }
}
