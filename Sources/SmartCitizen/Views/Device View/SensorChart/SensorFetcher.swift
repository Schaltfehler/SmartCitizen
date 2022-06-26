import Foundation
import Combine

public struct SensorFetcher {

    let apiClient: Client

    public init(client: Client) {
        apiClient = client
    }
    
    public func requestReadingsFor(deviceId id: Int, sensorId: Int, interval: DateInterval, rollup: Rollup) ->  AnyPublisher<Readings, Error> {
        let request = APIRequestBuilder.readings(deviceId: id,
                                                   sensorId: sensorId,
                                                   rollup: rollup,
                                                   from: interval.start,
                                                   to: interval.end,
                                                   function: .none,
                                                   allIntervals: false)

        let readingsPublisher = apiClient.publisher(for: request)

        return readingsPublisher
    }
}

extension TimeInterval {
    private static var hour = TimeInterval(60 * 60)
    private static var day = TimeInterval(60 * 60 * 24)
    private static var week = TimeInterval(60 * 60 * 24 * 7)
    
    var rollup : Rollup {
        switch self {
        case _ where self <= TimeInterval.hour:
            return .minutes(2)
        case _ where self <= TimeInterval.day:
            return .minutes(5)
        case _ where self <= TimeInterval.week:
            return .hours(1)
        default:
            return .days(1)
        }
    }
}
