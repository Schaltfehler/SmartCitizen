import Foundation

extension DateFormatter {
    func string(from value: Double) -> String {
        return string(from: Date(timeIntervalSince1970: value))
    }
}
