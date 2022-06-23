import Foundation
import Combine

public enum FetchState<T> {
    case empty
    case fetching
    case fetched(Result<T, Error>)
}

extension FetchState: Equatable {
    public static func == (lhs: FetchState<T>, rhs: FetchState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty):
            return true
        case (.fetching, .fetching):
            return true
        case let (.fetched(result1), .fetched(result2)):
            switch (result1, result2) {
            case (.failure(_), .failure(_)):
                return true
            case (.success(_), .success(_)):
                return true
            default:
                return false
            }
        default:
            return false
        }
    }
}

public final class SearchFetcher: ObservableObject {

    @Published private(set)
    public var state: FetchState<Array<GlobalSearch>>

    let apiClient: Client
    private var subscriptions = Set<AnyCancellable>()

    public init(client: Client) {
        state = .empty
        apiClient = client
    }

    private func onReceive(_ completion: Subscribers.Completion<Error>) {
        switch completion {
        case .finished:
            break
        case .failure(let error):
            state = .fetched(.failure(error))
        }
    }

    private func onReceive(_ searchResults: [GlobalSearch]) {
        state = .fetched(.success(searchResults))
    }

    public func fetch(searchTerm text: String) {
        state = .fetching

        let request = APIRequestBuilder.globalSearch(for: text)
        let searchPublisher = apiClient.publisher(for: request)

        searchPublisher
            .map{ (results: Array<GlobalSearch>) -> Array<GlobalSearch> in
                results.filter {
                    if case GlobalSearch.device(_) = $0 {
                        return true
                    } else  {
                        return false
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: onReceive, receiveValue: onReceive)
            .store(in: &subscriptions)
    }
}
