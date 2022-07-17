import Foundation

public enum FetchState<T: Equatable> {
    case empty
    case fetching
    case fetched(T)
    case failed(Error)
}
