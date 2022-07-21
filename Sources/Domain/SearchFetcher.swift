import Foundation
import Combine
import Network
import Models

public final class SearchFetcher: ObservableObject {

    @Published
    public private(set) var state: FetchState<[GlobalSearch]> = .empty

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
