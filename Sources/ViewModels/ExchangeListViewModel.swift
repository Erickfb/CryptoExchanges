import Foundation

enum LoadingState {
    case idle
    case loading
    case loaded
    case error(String)
}

final class ExchangeListViewModel {
    weak var coordinator: ExchangeListCoordinator?
    private let apiService: APIService

    @Published private(set) var exchanges: [Exchange] = []
    @Published private(set) var state: LoadingState = .idle
    @Published var searchText: String = ""

    private var allExchanges: [Exchange] = []

    init(apiService: APIService) {
        self.apiService = apiService
    }

    @MainActor
    func loadExchanges() async {
        state = .loading

        do {
            let fetchedExchanges = try await apiService.fetchExchanges()
            allExchanges = fetchedExchanges
            exchanges = fetchedExchanges
            state = .loaded
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    func filterExchanges(with searchText: String) {
        if searchText.isEmpty {
            exchanges = allExchanges
        } else {
            exchanges = allExchanges.filter { exchange in
                exchange.name.lowercased().contains(searchText.lowercased()) ||
                exchange.slug.lowercased().contains(searchText.lowercased())
            }
        }
    }

    func didSelectExchange(_ exchange: Exchange) {
        print("📱 ViewModel: didSelectExchange called for \(exchange.name)")
        print("📱 Coordinator exists: \(coordinator != nil)")
        coordinator?.showExchangeDetail(exchange: exchange)
    }

    var numberOfExchanges: Int {
        exchanges.count
    }

    func exchange(at index: Int) -> Exchange? {
        guard index >= 0 && index < exchanges.count else {
            return nil
        }
        return exchanges[index]
    }
}

@propertyWrapper
class Published<Value> {
    private var value: Value
    private var observers: [(Value) -> Void] = []

    var wrappedValue: Value {
        get { value }
        set {
            value = newValue
            observers.forEach { $0(newValue) }
        }
    }

    var projectedValue: Published<Value> {
        self
    }

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    func addObserver(_ observer: @escaping (Value) -> Void) {
        observers.append(observer)
        observer(value)
    }
}
