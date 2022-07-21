import Foundation
import Combine
import Network
import Models

public final class DeviceFetcher: ObservableObject {
    public struct DeviceAndMeasurements: Hashable, Identifiable, Codable {
        public var id: Int { device.id }
        public let device: Device
        public let measurements: [SCKMeasurement]
    }

    private let apiClient: Client
    private let cache: TimedCache<Int, DeviceAndMeasurements>

    public init(client: Client) {
        apiClient = client
        cache = TimedCache<Int, DeviceAndMeasurements>(name: "DeviceAndMeasurements", interval: .minutes(10))
    }

    public func fetch(deviceID: Int) -> AnyPublisher<DeviceAndMeasurements, Error> {
        cache.deleteEntry(key: deviceID)
        return fetchIfNeeded(deviceID: deviceID)
    }

    public func fetchIfNeeded(deviceID: Int) -> AnyPublisher<DeviceAndMeasurements, Error> {
        let cachePublisher: AnyPublisher<DeviceAndMeasurements, Error> = cache.entryPublisher(key: deviceID)
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()

        let measurementsRequest = APIRequestBuilder.measurements()
        let measurementsPublisher = apiClient.publisherWithPagination(for: measurementsRequest, pageSize: 60)

        let deviceRequest = APIRequestBuilder.device(withId: deviceID)
        let devicePublisher = apiClient.publisher(for: deviceRequest)

        let requestPublisher: AnyPublisher<DeviceAndMeasurements, Error> = Publishers.Zip(measurementsPublisher, devicePublisher)
            .map{ DeviceAndMeasurements(device: $1, measurements: $0) }
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
