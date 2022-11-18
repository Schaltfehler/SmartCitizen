import Foundation
import SwiftUI
import Combine
import Models
import Network
import Domain

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
        let data = FullDayReadings
        let apiClient = Client.mocked(width: data)
        let sensorFetcher = SensorFetcher(client: apiClient)
        return sensorFetcher
    }
}

extension FavoritesStore {
    static func mocked(_ device: [DevicePreviewModel]) -> FavoritesStore {
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


extension SensorModel {
    static var mocked: SensorModel {
        SensorModel(name: "My Sensor", device_id: 1, sensor_id: 2, type: MeasurementType.co2, unit: "co2")
    }
}


extension SensorFetcher {

    static var FullDayReadings: Data {
"""
{
    "device_id": 1234,
    "sensor_key": "pm_avg_2.5",
    "sensor_id": 87,
    "component_id": 245,
    "rollup": "30m",
    "function": "avg",
    "from": "2021-08-06T14:40:54Z",
    "to": "2021-08-07T14:40:54Z",
    "sample_size": 288,
    "readings":
    [
        [
            "2021-08-07T14:31:34Z",
            7
        ],
        [
            "2021-08-07T14:01:34Z",
            5.666666666666667
        ],
        [
            "2021-08-07T13:31:34Z",
            5.166666666666667
        ],
        [
            "2021-08-07T13:01:34Z",
            5.666666666666667
        ],
        [
            "2021-08-07T12:31:34Z",
            3.6666666666666665
        ],
        [
            "2021-08-07T12:01:34Z",
            33.5
        ],
        [
            "2021-08-07T11:31:34Z",
            33.3333333333333335
        ],
        [
            "2021-08-07T11:01:34Z",
            32.8333333333333335
        ],
        [
            "2021-08-07T10:31:34Z",
            31.8333333333333333
        ],
        [
            "2021-08-07T10:01:34Z",
            32
        ],
        [
            "2021-08-07T09:31:34Z",
            31.3333333333333333
        ],
        [
            "2021-08-07T09:01:34Z",
            30.8333333333333334
        ],
        [
            "2021-08-07T08:31:34Z",
            1.5
        ],
        [
            "2021-08-07T08:01:34Z",
            1.6666666666666667
        ],
        [
            "2021-08-07T07:31:34Z",
            2.3333333333333335
        ],
        [
            "2021-08-07T07:01:34Z",
            1.3333333333333333
        ],
        [
            "2021-08-07T06:31:34Z",
            2.5
        ],
        [
            "2021-08-07T06:01:34Z",
            2
        ],
        [
            "2021-08-07T05:31:34Z",
            0.5
        ],
        [
            "2021-08-07T05:01:34Z",
            0
        ],
        [
            "2021-08-07T04:31:34Z",
            0.5
        ],
        [
            "2021-08-07T04:01:34Z",
            0.8333333333333334
        ],
        [
            "2021-08-07T03:31:34Z",
            0.3333333333333333
        ],
        [
            "2021-08-07T03:01:34Z",
            0.5
        ],
        [
            "2021-08-07T02:31:34Z",
            0.6666666666666666
        ],
        [
            "2021-08-07T02:01:34Z",
            0
        ],
        [
            "2021-08-07T01:31:34Z",
            0.16666666666666666
        ],
        [
            "2021-08-07T01:01:34Z",
            0
        ],
        [
            "2021-08-07T00:31:34Z",
            0.3333333333333333
        ],
        [
            "2021-08-07T00:01:34Z",
            3.1666666666666665
        ],
        [
            "2021-08-06T23:31:34Z",
            3.3333333333333335
        ],
        [
            "2021-08-06T23:01:34Z",
            5.166666666666667
        ],
        [
            "2021-08-06T22:31:34Z",
            5
        ],
        [
            "2021-08-06T22:01:34Z",
            4.333333333333333
        ],
        [
            "2021-08-06T21:31:34Z",
            4.166666666666667
        ],
        [
            "2021-08-06T21:01:34Z",
            2
        ],
        [
            "2021-08-06T20:31:34Z",
            2.1666666666666665
        ],
        [
            "2021-08-06T20:01:34Z",
            4.333333333333333
        ],
        [
            "2021-08-06T19:31:34Z",
            5.833333333333333
        ],
        [
            "2021-08-06T19:01:34Z",
            6.333333333333333
        ],
        [
            "2021-08-06T18:31:34Z",
            7.333333333333333
        ],
        [
            "2021-08-06T18:01:34Z",
            7
        ],
        [
            "2021-08-06T17:31:34Z",
            8.833333333333334
        ],
        [
            "2021-08-06T17:01:34Z",
            9.166666666666666
        ],
        [
            "2021-08-06T16:31:34Z",
            10.666666666666666
        ],
        [
            "2021-08-06T16:01:34Z",
            11.166666666666666
        ],
        [
            "2021-08-06T15:31:34Z",
            10
        ],
        [
            "2021-08-06T15:01:34Z",
            9.833333333333334
        ],
        [
            "2021-08-06T14:41:34Z",
            10.75
        ]
    ]
}
""".data(using: .utf8)!
    }

}
