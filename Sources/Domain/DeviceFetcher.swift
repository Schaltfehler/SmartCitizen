import Foundation
import Combine
import Network
import Models

public final class DeviceFetcher: ObservableObject {
    private let apiClient: Client
    private let cache: TimedCache<Int, Device>

    public init(client: Client) {
        apiClient = client
        cache = TimedCache<Int, Device>(name: "CachedDevices", interval: .minutes(10))
    }

    public func fetch(deviceID: Int) -> AnyPublisher<Device, Error> {
        cache.deleteEntry(key: deviceID)
        return fetchIfNeeded(deviceID: deviceID)
    }

    public func fetchIfNeeded(deviceID: Int) -> AnyPublisher<Device, Error> {
        let cachePublisher: AnyPublisher<Device, Error> = cache.entryPublisher(key: deviceID)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let deviceRequest = APIRequestBuilder.device(withId: deviceID)
        let devicePublisher = apiClient.publisher(for: deviceRequest)

        let requestPublisher: AnyPublisher<Device, Error> = devicePublisher
            .handleEvents(
                receiveOutput: { [unowned self] in self.cache.setEntry(key: $0.id, value: $0) }
            )
            .eraseToAnyPublisher()

        // First check cache if stale or empty, do a request
        return cachePublisher
            .append(requestPublisher)
            .first()
            .eraseToAnyPublisher()
    }
}
