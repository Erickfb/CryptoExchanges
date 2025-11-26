import UIKit

protocol Coordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    func start()
}

final class AppCoordinator: Coordinator {
    var navigationController: UINavigationController
    private var exchangeListCoordinator: ExchangeListCoordinator?

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showExchangeList()
    }

    func showExchangeList() {
        let coordinator = ExchangeListCoordinator(navigationController: navigationController)
        exchangeListCoordinator = coordinator
        coordinator.start()
    }
}
