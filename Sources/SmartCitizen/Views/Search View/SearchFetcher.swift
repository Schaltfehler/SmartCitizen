import Foundation
import Combine

public enum FetchState<T: Equatable> {
    case empty
    case fetching
    case fetched(T)
    case failed(Error)
}

extension FetchState: Equatable {
    public static func == (lhs: FetchState<T>, rhs: FetchState<T>) -> Bool {
        switch (lhs, rhs) {
        case (.empty, .empty), (.fetching, .fetching):
            return true
        case let (.fetched(lResult), .fetched(rResult)):
            return lResult == rResult
        case let (.failed(lError), .failed(rError)):
            return lError.localizedDescription == rError.localizedDescription
        default:
            return false
        }
    }
}

public final class SearchFetcher: ObservableObject {

    @Published
    private(set) var state: FetchState<[GlobalSearch]> = .empty

    let apiClient: Client

    public init(client: Client) {
        apiClient = client
    }

    public func fetch(searchTerm text: String) {
        state = .fetching

        let request = APIRequestBuilder.globalSearch(for: text)
        let searchPublisher = apiClient.publisher(for: request)

        searchPublisher
            .map{ (results: [GlobalSearch]) -> [GlobalSearch] in
                results.filter {
                    if case GlobalSearch.device(_) = $0 {
                        return true
                    } else  {
                        return false
                    }
                }
            }
            .receive(on: DispatchQueue.main)
            .map{ .fetched($0) }
            .catch{ Just(.failed($0)) }
            .assign(to: &$state)
    }
}
