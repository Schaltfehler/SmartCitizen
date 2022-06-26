import Foundation
import Combine

extension TimeInterval {
    static func seconds(_ seconds: Int) -> TimeInterval {
        Calendar.current.date(byAdding: .second, value: seconds, to: Date())!.timeIntervalSinceNow
    }

    static func minutes(_ minutes: Int) -> TimeInterval {
        Calendar.current.date(byAdding: .minute, value: minutes, to: Date())!.timeIntervalSinceNow
    }

    static func hours(_ hours: Int) -> TimeInterval {
        Calendar.current.date(byAdding: .hour, value: hours, to: Date())!.timeIntervalSinceNow
    }

    static func days(_ days: Int) -> TimeInterval {
        Calendar.current.date(byAdding: .day, value: days, to: Date())!.timeIntervalSinceNow
    }
}

public final class WorldMapFetcher: ObservableObject {

    public enum MapFetchState {
        case none
        case fetching
        case fetched(Array<WorldMapDevice>)
        case failed(Error)
    }

    @Published
    public private(set) var state: MapFetchState = .none

    let apiClient: Client

    let cache: TimedCache<String, [WorldMapDevice]>


    public init(client: Client) {
        apiClient = client

        cache = TimedCache<String, [WorldMapDevice]>(name: "WorldMapDevices", interval: .hours(24))
    }

    public func fetch() {
        cache.deleteAllEntries()

        fetchIfNeeded()
    }

    public func fetchIfNeeded() {
        let cachePublisher: AnyPublisher<[WorldMapDevice], Error> = cache.entryPublisher(key: "MapDevices")
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let request = APIRequestBuilder.worldMapDevices()
        let requestPublisher = apiClient.publisher(for: request)
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.state = .fetching
            }, receiveOutput: { [weak self] value in
                self?.cache.setEntry(key: "MapDevices", value: value)
            })
            .eraseToAnyPublisher()

        // First check cache, if stale or empty, check disk, if stale or empty, do request
        cachePublisher
            .append(requestPublisher)
            .first()
            .receive(on: DispatchQueue.main)
            .map{ MapFetchState.fetched($0) }
            .catch{ Just(MapFetchState.failed($0)) }
            .assign(to: &$state)
    }
}

