import Foundation

enum APIRequestBuilder {
    private static func encodeForBody(_ queryItems:[URLQueryItem]) -> Data? {
        var compoentents = URLComponents()
        compoentents.queryItems = queryItems
        let percentageEncoded = compoentents.url?.query

        let data = percentageEncoded?.data(using: .utf8)

        return data
    }

    // MARK: - General
    static func login(user: String, password: String) -> APIRequest<AuthToken> {
        let queryItems = [URLQueryItem(name: "username", value: user),
                          URLQueryItem(name: "password", value: password)]
        let data = encodeForBody(queryItems)

        return APIRequest(method: .post, path: "/v0/sessions", body: data)
    }

    static func sensors() -> APIRequest<Array<Sensor>> {
        return APIRequest(method: .get, path: "/v0/sensors")
    }

    static func device(withId id: Int) -> APIRequest<Device> {
        return APIRequest(method: .get, path: "/v0/devices/\(id)")
    }

    static func measurements() -> APIRequest<Array<SCKMeasurement>> {
        return APIRequest(method: .get, path: "/v0/measurements")
    }

    // Date is expected to be in UTC
    static func readings(deviceID: Int,
                         sensorId: Int,
                         rollup: Rollup,
                         from fromDate: Date?,
                         to toDate: Date?,
                         function: GroupingFunction?,
                         allIntervals: Bool?) -> APIRequest<Readings> {
        var queryItems = [
            URLQueryItem(name: "sensor_id", value: String(sensorId)),
            URLQueryItem(name: "rollup", value: rollup.asString)
        ]

        if let fromDate = fromDate,
            let toDate = toDate {
            let formatter = DateFormatter()
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
            let fromDateString = formatter.string(from: fromDate)
            let toDateString = formatter.string(from: toDate)

            queryItems.append(URLQueryItem(name: "from", value: fromDateString))
            queryItems.append(URLQueryItem(name: "to", value: toDateString))
        }

        if let function = function {
            queryItems.append(URLQueryItem(name: "function", value: function.rawValue))
        }

        if let allIntervals = allIntervals {
            queryItems.append(URLQueryItem(name: "all_intervals", value: allIntervals ? "true" : "false" ))
        }

        return APIRequest(method: .get, path: "/v0/devices/\(deviceID)/readings/", queryParameter: queryItems)
    }

    ///  Searches Users, Devices, Tags and Cities at the same time
    static func globalSearch(for name: String) -> APIRequest<Array<GlobalSearch>> {
        let queryItems = [
            URLQueryItem(name: "q", value: name)
        ]

        return APIRequest(method: .get, path: "/v0/search", queryParameter: queryItems)
    }

    static func worldMapDevices() -> APIRequest<Array<WorldMapDevice>> {
        return APIRequest(method: .get, path: "/v0/devices/world_map")
    }
}

public enum Rollup {
    case years(UInt)
    case months(UInt)
    case weeks(UInt)
    case days(UInt)
    case hours(UInt)
    case minutes(UInt)
    case seconds(UInt)
    case milliseconds(UInt)

    var asString: String {
        switch self {
        case .years(let count):
            return "\(count)y"
        case .months(let count):
            return "\(count)M"
        case .weeks(let count):
            return "\(count)w"
        case .days(let count):
            return "\(count)d"
        case .hours(let count):
            return "\(count)h"
        case .minutes(let count):
            return "\(count)m"
        case .seconds(let count):
            return "\(count)s"
        case .milliseconds(let count):
            return "\(count)ms"
        }
    }
}


enum GroupingFunction: String {
    case avg
    case max
    case min
    case sum
    case count
    case dev
    case fist
    case last
}
