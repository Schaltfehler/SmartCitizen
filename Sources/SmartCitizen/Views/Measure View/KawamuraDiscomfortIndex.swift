import Foundation
import CoreGraphics

// Kawamura’s Discomfort Index
public enum KawamuraDiscomfortIndex {
    case level1(Double, Double, Double)
    case level2(Double, Double, Double)
    case level3(Double, Double, Double)
    case level4(Double, Double, Double)
    case level5(Double, Double, Double)

    public init(celsius: Double, humidity: Double) {
        let dewPoint = KawamuraDiscomfortIndex.approximatedDewPoint(celsius: celsius,
                                                                    humidity: humidity)
        let index = KawamuraDiscomfortIndex.discomfortIndex(celsius: celsius,
                                                            dewPoint: dewPoint)

        switch index {
        case ..<55.0:
            self = .level1(index, celsius, humidity)
        case 55.0..<60.0:
            self = .level2(index, celsius, humidity)
        case 60.0..<75.0:
            self = .level3(index, celsius, humidity)
        case 75.0..<80.0:
            self = .level4(index, celsius, humidity)
        default:
            self = .level5(index, celsius, humidity)
        }
    }

    /// Kawamura’s Discomfort Index
    static func discomfortIndex(celsius: Double, dewPoint: Double) -> Double {
        0.99 * celsius + 0.36 * dewPoint + 41.5
    }

    /// This approach is accurate to within about ±1 °C as long as the relative humidity is above 50%
    static func approximatedDewPoint(celsius: Double, humidity: Double) -> Double {
        celsius - (100.0 - humidity) / 5.0
    }

    var index: Double {
        switch self {
        case let .level1(index, _, _),
             let .level2(index, _, _),
             let .level3(index, _, _),
             let .level4(index, _, _),
             let .level5(index, _, _):
            return index
        }
    }

    var celsius: Double {
        switch self {
        case let .level1(_, celsius, _),
             let .level2(_, celsius, _),
             let .level3(_, celsius, _),
             let .level4(_, celsius, _),
             let .level5(_, celsius, _):
            return celsius
        }
    }

    var humidity: Double {
        switch self {
        case let .level1(_, _, humidity),
             let .level2(_, _, humidity),
             let .level3(_, _, humidity),
             let .level4(_, _, humidity),
             let .level5(_, _, humidity):
            return humidity
        }
    }

    var color: CGColor {
        switch self {
        case .level1:
            return CGColor(red: 0/255, green: 0/255, blue: 228/255, alpha: 1)
        case .level2:
            return CGColor(red: 221/255, green: 238/255, blue: 255/255, alpha: 1)
        case .level3:
            return CGColor(red: 0/255, green: 228/255, blue: 0/255, alpha: 1)
        case .level4:
            return CGColor(red: 0/255, green: 128/255, blue: 196/255, alpha: 1)
        case .level5:
            return CGColor(red: 228/255, green: 0/255, blue: 0/255, alpha: 1)
        }
    }

    var category: String {
        switch self {
        case .level1:
            return "Unbearably cold"
        case .level2:
            return "Uncomfortably cold"
        case .level3:
            return "Comfortable"
        case .level4:
            return "Uncomfortably hot"
        case .level5:
            return "Unbearably hot"
        }
    }
}
