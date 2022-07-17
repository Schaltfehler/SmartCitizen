import Foundation
import SwiftUI
import Combine

#if DEBUG

extension Client {
    static func mocked(width data: Data) -> Client {
        Client(networking: { (request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> in
            Just((data: data, response: URLResponse()))
                .setFailureType(to: Error.self)
                .eraseToAnyPublisher()
        })
    }
}

extension SearchFetcher {
    static func mocked() -> SearchFetcher {
        let data = NSDataAsset(name: "GlobalSearch")!.data
        let apiClient = Client.mocked(width: data)
        let fetcher = SearchFetcher(client: apiClient)

        return fetcher
    }
}

extension DeviceFetcher {
    static func mocked() -> DeviceFetcher {
        let data = NSDataAsset(name: "DeviceResponse")!.data
        let apiClient = Client.mocked(width: data)
        let deviceFetcher = DeviceFetcher(client: apiClient)

        return deviceFetcher
    }
}

extension SensorFetcher {
    static func mocked() -> SensorFetcher {
        let data = NSDataAsset(name: "Readings")!.data
        let apiClient = Client.mocked(width: data)
        let sensorFetcher = SensorFetcher(client: apiClient)
        return sensorFetcher
    }

    static func mockedWithFullDayReadings() -> SensorFetcher {
        let data = NSDataAsset(name: "Readings-FullDay")!.data
        let apiClient = Client.mocked(width: data)
        let sensorFetcher = SensorFetcher(client: apiClient)
        return sensorFetcher
    }
}

extension FavoritesStore {
    static func mocked(_ device: [DeviceCellModel]) -> FavoritesStore {
        FavoritesStore(load: { device }, save: { _ in /* no-op */})
    }
}

extension WorldMapFetcher {
    static func mocked() -> WorldMapFetcher {
        let data = NSDataAsset(name: "WorldDevices")!.data
        let apiClient = Client.mocked(width: data)
        let fetcher = WorldMapFetcher(client: apiClient)
        return fetcher
    }
}

#endif
