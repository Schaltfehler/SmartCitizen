import Foundation

extension Client  {
    public static func decodeDate(_ decoder: Decoder) throws -> Date {
        let container = try decoder.singleValueContainer()
        let dateAsString = try container.decode(String.self)

        let formatter = DateFormatter()
        formatter.dateFormat = Client.dateFormat
        guard let date = formatter.date(from: dateAsString)
            else {
                return Date(timeIntervalSince1970: 0)
        }

        return date
    }

    public static let dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"

    public static func jsonDecoder() -> JSONDecoder {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .custom(Client.decodeDate)
        // Note: Might have a noticeable performance cost because this may inspect and transform each key.
        decoder.keyDecodingStrategy  = .convertFromSnakeCase

        return decoder
    }
}
