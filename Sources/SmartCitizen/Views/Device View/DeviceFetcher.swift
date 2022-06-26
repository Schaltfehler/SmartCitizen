import Foundation
import Combine

public enum DeviceFetchState {
    case empty
    case fetching
    case fetched(DeviceViewModel)
    case failed(Error)

    var displayText: String {
        switch self {
        case .empty, .fetching:
            return "Fetching..."
        case .fetched(_):
            return "Finished"
        case let .failed(error):
            return "Error: \(error.localizedDescription)"
        }
    }
}

public final class DeviceFetcher: ObservableObject {
    @Published private(set)
    public var state: DeviceFetchState = .empty

    let apiClient: Client
    let cache: TimedCache<Int, DeviceViewModel>

    public init(client: Client) {
        apiClient = client
        cache = TimedCache<Int, DeviceViewModel>(name: "DeviceViewModels", interval: .minutes(10))
    }

    public func fetch(deviceID: Int) {
        cache.deleteEntry(key: deviceID)
        fetchIfNeeded(deviceID: deviceID)
    }

    public func fetchIfNeeded(deviceID: Int) {
        let cachePublisher: AnyPublisher<DeviceViewModel, Error> = cache.entryPublisher(key: deviceID)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let measurementsRequest = APIRequestBuilder.measurements()
        let measurementsPublisher = apiClient.publisherWithPagination(for: measurementsRequest, pageSize: 60)

        let deviceRequest = APIRequestBuilder.device(withId: deviceID)
        let devicePublisher = apiClient.publisher(for: deviceRequest)

        let requestPublisher: AnyPublisher<DeviceViewModel, Error> = Publishers.Zip(measurementsPublisher, devicePublisher)
            .map{ DeviceViewModel(device: $1, measurements: $0) }
            .handleEvents(receiveSubscription: { [weak self] _ in
                self?.state = .fetching
            }, receiveOutput: { [weak self] value in
                self?.cache.setEntry(key: value.id, value: value)
            })
            .eraseToAnyPublisher()

        // First check cache if stale or empty, do a request
        cachePublisher
            .append(requestPublisher)
            .first()
            .receive(on: DispatchQueue.main)
            .map{ DeviceFetchState.fetched($0) }
            .catch{ Just(DeviceFetchState.failed($0)) }
            .assign(to: &$state)
    }
}
