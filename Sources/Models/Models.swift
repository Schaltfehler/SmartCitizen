import Foundation

public struct Device: Codable, Hashable {
    public let id: Int
    public let uuid: UUID

    public let name: String
    public let description: String?
    public let state: String
    public let systemTags: [String]
    public let userTags: [String]
    public let lastReadingAt: Date?
    public let owner: Owner
    public let data: DataObject

    public struct Owner: Codable, Hashable {
        public let id: Int
        public let uuid: UUID
        public let username: String
    }

    public struct DataObject: Codable, Hashable {
        public let recordedAt: Date?
        public let addedAt: Date?
        public let location: Location
        public let sensors: Array<Sensor>

        public struct Location: Codable, Hashable {
            public let exposure: String? // "indoor"
            public let latitude: Double?
            public let longitude: Double?

            public let city: String?
            public let country: String?
        }

        public struct Sensor: Codable, Hashable {
            public let id: Int

            public let name: String
            public let description: String
            public let unit: String
            public let createdAt: Date
            public let updatedAt: Date
            public let measurementId: Int
            public let uuid: UUID

            public let value: Double?

            public init(from decoder: Decoder) throws {
                let container = try decoder.container(keyedBy: Device.DataObject.Sensor.CodingKeys.self)

                id = try container.decode(Int.self, forKey: .id)
                name = try container.decode(String.self, forKey: .name)
                description = try container.decode(String.self, forKey: .description)
                unit = try container.decode(String.self, forKey: .unit)
                createdAt = try container.decode(Date.self, forKey: .createdAt)
                updatedAt = try container.decode(Date.self, forKey: .updatedAt)
                measurementId = try container.decode(Int.self, forKey: .measurementId)
                uuid = try container.decode(UUID.self, forKey: .uuid)
                value = try? container.decodeIfPresent(Double.self, forKey: .value) ?? nil
            }
        }
    }
}

public struct SCKMeasurement: Codable, Hashable {
    public let id: Int
    public let uuid: UUID
    public let name: String
    public let description: String

    public let createdAt: Date
    public let updatedAt: Date
}

public struct Sensor: Codable, Hashable {
    public let deviceID: Int
    public let sensorKey: String // "t"
    public let sensorId: Int
    public let componentId: Int
    public let rollup: String
    public let function: String
    public let from: Date
    public let to: Date
    public let sampleSize: Int
}

public struct Readings: Codable, Hashable {
    public let from: Date
    public let to: Date
    public let readings: [SensorReading]

    public struct SensorReading: Codable, Hashable {
        public let date: Date
        public let value: Double

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            date = try container.decode(Date.self)
            value = try container.decodeIfPresent(Double.self) ?? Double.nan
        }
    }
}

public struct AuthToken: Codable, Hashable {
    public let accessToken: String
}

public enum GlobalSearch {
    case user(User)
    case device(Device)
    case city(City)
    case tag(Tag)

    case unknown(String)


    public struct User: Codable, Hashable {
        public let id: Int
        public let type: String // User, City, Device, Tag
        public let username: String
        public let avatar: URL
        public let city: String?
        public let url: URL
        public let countryCode: String?
        public let country: String?
    }

    public struct City: Codable, Hashable {
        public let type: String
        public let city: String?
        public let name: String
        public let layer: String
        public let countryCode: String
        public let country: String
        public let latitude: Double
        public let longitude: Double
    }

    public struct Device: Codable, Hashable {
        public let id: Int
        public let type: String

        public let name: String?
        public let description: String?
        public let ownerId: Int
        public let ownerUsername: String?
        public let city: String?
        public let url: URL?
        public let countryCode: String?
        public let country: String?

        public init(id: Int, type: String, name: String?, description: String?, ownerId: Int, ownerUsername: String?, city: String?, url: URL?, countryCode: String?, country: String?) {
            self.id = id
            self.type = type
            self.name = name
            self.description = description
            self.ownerId = ownerId
            self.ownerUsername = ownerUsername
            self.city = city
            self.url = url
            self.countryCode = countryCode
            self.country = country
        }
    }

    public struct Tag: Codable, Hashable {
        public let id: Int
        public let type: String
        public let name: String
        public let description: String
        public let url: URL
    }
}

extension GlobalSearch: Codable, Hashable {
    private enum CodingKeys: String, CodingKey {
        case user
        case device
        case city
        case tag
    }

    public init(from decoder: Decoder) throws {

        struct Peek: Decodable {
            let type: String
        }

        let container = try decoder.singleValueContainer()

        // Peek into the container to see with what type we are dealing with
        let peek = try container.decode(Peek.self)
        let type = peek.type.lowercased()
        guard let codingKey = CodingKeys(rawValue: type) else {
            self = .unknown(type)
            return
        }

        switch codingKey {
        case .user:
            let user = try container.decode(User.self)
            self = .user(user)
        case .device:
            let device = try container.decode(Device.self)
            self = .device(device)
        case .city:
            let city = try container.decode(City.self)
            self = .city(city)
        case .tag:
            let tag = try container.decode(Tag.self)
            self = .tag(tag)
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        switch self {
        case .user(let user):
            try container.encode(user, forKey: .user)
        case .device(let device):
            try container.encode(device, forKey: .device)
        case .city(let city):
            try container.encode(city, forKey: .city)
        case .tag(let tag):
            try container.encode(tag, forKey: .tag)
        case .unknown(_):
            break
        }
    }
}

public struct WorldMapDevice: Codable, Hashable {
    public let id: Int
    public let name: String?
    public let description: String?

    public let ownerId: Int
    public let ownerUsername: String?

    public let kitId: Int?

    public let latitude: Double?
    public let longitude: Double?

    public let city: String?
    public let countryCode: String?

    public let state: String
    public let systemTags: [String]
    public let userTags: [String]

    public let addedAt: Date
    public let updatedAt: Date
    public let lastReadingAt: Date
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

    public var asString: String {
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

public struct DevicePreviewModel: Identifiable, Equatable, Codable {
    public var id: Int
    public var name: String
    public var cityName: String?
    public var userName: String

    public init(id: Int, name: String, cityName: String? = nil, userName: String) {
        self.id = id
        self.name = name
        self.cityName = cityName
        self.userName = userName
    }
}
