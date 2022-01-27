import Foundation
import CoreGraphics

/// Temperature-humidity index
// https://link.springer.com/referenceworkentry/10.1007%2F0-387-30749-4_176
public enum TemperatureHumidityIndex {
    case level1(Double, Double, Double)
    case level2(Double, Double, Double)
    case level3(Double, Double, Double)
    case level4(Double, Double, Double)

    public init(celsius: Double, humidity: Double) {
        let index = TemperatureHumidityIndex.comfortIndex(withCelsius: celsius, humidity: humidity)

        switch index {
        case 0..<75.0:
            self = .level1(index, celsius, humidity)
        case 75.0..<79.0:
            self = .level2(index, celsius, humidity)
        case 79.0..<90.0:
            self = .level3(index, celsius, humidity)
        default:
            self = .level4(index, celsius, humidity)
        }
    }

    var category: String {
        switch self {
        case .level1:
            return "Comfortable"
        case .level2:
            return "Uncomfortable"
        case .level3:
            return "Discomfort"
        case .level4:
            return "Dangerous"
        }
    }

    var index: Double {
        switch self {
        case let .level1(index, _, _),
             let .level2(index, _, _),
             let .level3(index, _, _),
             let .level4(index, _, _):
            return index
        }
    }

    var celsius: Double {
        switch self {
        case let .level1(_, celsius, _),
             let .level2(_, celsius, _),
             let .level3(_, celsius, _),
             let .level4(_, celsius, _):
            return celsius
        }
    }

    var humidity: Double {
        switch self {
        case let .level1(_, _, humidity),
             let .level2(_, _, humidity),
             let .level3(_, _, humidity),
             let .level4(_, _, humidity):
            return humidity
        }
    }

    var color: CGColor {
        switch self {
        case .level1:
            return CGColor(red: 0, green: 228/255, blue: 0, alpha: 1)
        case .level2:
            return CGColor(red: 236/255, green: 224/255, blue: 0, alpha: 1)
        case .level3:
            return CGColor(red: 242/255, green: 140/255, blue: 0, alpha: 1)
        case .level4:
            return CGColor(red: 242/255, green: 23/255, blue: 29/255, alpha: 1)
        }
    }

    // Environmental factors influencing heat stress in feedlot cattle
    // Mader 2006
    static func comfortIndex(withCelsius celsius: Double, humidity: Double) -> Double {
        0.81 * celsius + 0.01 * humidity * (0.99 * celsius - 14.3 ) + 46.3
    }
}
