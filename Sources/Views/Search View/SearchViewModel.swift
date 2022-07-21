import Foundation
import Combine
import Models
import Domain

public final class SearchViewModel: ObservableObject{

    @Published
    var search: String = ""

    let fetcher: SearchFetcher

    @Published
    private(set) var fetchingState: FetchingState

    enum FetchingState {
        case result([GlobalSearch])
        case displayText(String)
    }

    public init(fetcher: SearchFetcher) {
        self.fetcher = fetcher
        self.fetchingState = .displayText("Search for devices.")

        fetcher.$state
            .map{ [unowned self] in self.translate($0) }
            .assign(to: &$fetchingState)
    }

    private func translate(_ state: FetchState<[GlobalSearch]>) -> FetchingState {
        switch state {
        case .empty:
            return .displayText("Search for devices.")
        case .fetching:
            return .displayText("Searching...")
        case let .fetched(result):
            return .result(result)
        case let .failed(error):
            return .displayText("Error: \(error.localizedDescription)")
        }
    }

    func textinputHasChanged() {
        fetcher.fetch(searchTerm: search)
    }

}
