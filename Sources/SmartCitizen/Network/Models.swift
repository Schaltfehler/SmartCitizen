import Foundation

public struct Device: Codable, Hashable {
    let id: Int
    let uuid: UUID

    let name: String
    let description: String?
    let state: String
    let systemTags: [String]
    let userTags: [String]
    let lastReadingAt: Date?
    let owner: Owner
    let data: DataObject

    public struct Owner: Codable, Hashable {
        let id: Int
        let uuid: UUID
        let username: String
    }

    public struct DataObject: Codable, Hashable {
        let recordedAt: Date?
        let addedAt: Date?
        let location: Location
        let sensors: Array<Sensor>

        public struct Location: Codable, Hashable {
            let exposure: String? // "indoor"
            let latitude: Double?
            let longitude: Double?

            let city: String?
            let country: String?
        }

        public struct Sensor: Codable, Hashable {
            let id: Int

            let name: String
            let description: String
            let unit: String
            let createdAt: Date
            let updatedAt: Date
            let measurementId: Int
            let uuid: UUID

            let value: Double?
            let rawValue: Double?
            let prevValue: Double?
            let prevRawValue: Double?
        }
    }
}

public struct SCKMeasurement: Codable, Hashable {
    let id: Int
    let uuid: UUID
    let name: String
    let description: String

    let createdAt: Date
    let updatedAt: Date
}

public struct Sensor: Codable, Hashable {
    let deviceId: Int
    let sensorKey: String // "t"
    let sensorId: Int
    let componentId: Int
    let rollup: String
    let function: String
    let from: Date
    let to: Date
    let sampleSize: Int
}

public struct Readings: Codable, Hashable {
    let from: Date
    let to: Date
    let readings: [SensorReading]

    public struct SensorReading: Codable, Hashable {
        let date: Date
        let value: Double

        public init(from decoder: Decoder) throws {
            var container = try decoder.unkeyedContainer()
            date = try container.decode(Date.self)
            value = try container.decodeIfPresent(Double.self) ?? Double.nan
        }
    }
}

public struct AuthToken: Codable, Hashable {
    let accessToken: String
}

public enum GlobalSearch {
    case user(User)
    case device(Device)
    case city(City)
    case tag(Tag)

    case unknown(String)


    public struct User: Codable, Hashable {
        let id: Int
        let type: String // User, City, Device, Tag
        let username: String
        let avatar: URL
        let city: String?
        let url: URL
        let countryCode: String?
        let country: String?
    }

    public struct City: Codable, Hashable {
        let type: String
        let city: String?
        let name: String
        let layer: String
        let countryCode: String
        let country: String
        let latitude: Double
        let longitude: Double
    }

    public struct Device: Codable, Hashable {
        let id: Int
        let type: String

        let name: String?
        let description: String?
        let ownerId: Int
        let ownerUsername: String?
        let city: String?
        let url: URL?
        let countryCode: String?
        let country: String?
    }

    public struct Tag: Codable, Hashable {
        let id: Int
        let type: String
        let name: String
        let description: String
        let url: URL
    }
}

extension GlobalSearch: Codable, Hashable {
    private enum CodingKeys: String, CodingKey {
        case user
        case device
        case city
        case tag
    }

    enum PostTypeCodingError: Error {
        case decoding(String)
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
    let id: Int
    let name: String?
    let description: String?

    let ownerId: Int
    let ownerUsername: String?

    let kitId: Int?

    let latitude: Double?
    let longitude: Double?

    let city: String?
    let countryCode: String?

    let state: String
    let systemTags: [String]
    let userTags: [String]

    let addedAt: Date
    let updatedAt: Date
    let lastReadingAt: Date
}
