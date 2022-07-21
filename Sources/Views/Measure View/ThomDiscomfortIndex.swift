import Foundation
import CoreGraphics

// Thom’s Discomfort Index
public enum ThomDiscomfortIndex {
    case level1(Double, Double, Double)
    case level2(Double, Double, Double)
    case level3(Double, Double, Double)
    case level4(Double, Double, Double)
    case level5(Double, Double, Double)
    case level6(Double, Double, Double)

    public init(celsius: Double, humidity: Double) {
        let index = ThomDiscomfortIndex.discomfortIndex(celsius: celsius,
                                                        humidity: humidity)

        switch index {
        case ..<21.0:
            self = .level1(index, celsius, humidity)
        case 21.0..<24.0:
            self = .level2(index, celsius, humidity)
        case 24.0..<27.0:
            self = .level3(index, celsius, humidity)
        case 27.0..<29.0:
            self = .level4(index, celsius, humidity)
        case 29.0..<32.0:
            self = .level5(index, celsius, humidity)
        default:
            self = .level6(index, celsius, humidity)
        }
    }

    /// Thom’s Discomfort Index, modified as in
    /// Thermal remote sensing of Thom’s Discomfort Index (DI):comparison with in situ measurements
    static func discomfortIndex(celsius: Double, humidity: Double) -> Double {
        celsius - 0.55 * ( 1.0 - 0.01 * humidity) * (celsius - 14.5 )
    }

    var index: Double {
        switch self {
        case let .level1(index, _, _),
             let .level2(index, _, _),
             let .level3(index, _, _),
             let .level4(index, _, _),
             let .level5(index, _, _),
             let .level6(index, _, _):
            return index
        }
    }

    var celsius: Double {
        switch self {
        case let .level1(_, celsius, _),
             let .level2(_, celsius, _),
             let .level3(_, celsius, _),
             let .level4(_, celsius, _),
             let .level5(_, celsius, _),
             let .level6(_, celsius, _):
            return celsius
        }
    }

    var humidity: Double {
        switch self {
        case let .level1(_, _, humidity),
             let .level2(_, _, humidity),
             let .level3(_, _, humidity),
             let .level4(_, _, humidity),
             let .level5(_, _, humidity),
             let .level6(_, _, humidity):
            return humidity
        }
    }

    var color: CGColor {
        switch self {
        case .level1:
            return CGColor(red: 153/255, green: 204/255, blue: 255/255, alpha: 1)
        case .level2:
            return CGColor(red: 221/255, green: 238/255, blue: 255/255, alpha: 1)
        case .level3:
            return CGColor(red: 255/255, green: 255/255, blue: 49/255, alpha: 1)
        case .level4:
            return CGColor(red: 255/255, green: 206/255, blue: 0/255, alpha: 1)
        case .level5:
            return CGColor(red: 255/255, green: 156/255, blue: 0/255, alpha: 1)
        case .level6:
            return CGColor(red: 255/255, green: 0/255, blue: 0/255, alpha: 1)
        }
    }

    var advisory: String? {
        switch self {
        case .level1:
            return "No discomfort"
        case .level2:
            return "Less than half population feels discomfort"
        case .level3:
            return "More than half population feels discomfort"
        case .level4:
            return "Most population feels discomfort and deterioration of psychophysical conditions"
        case .level5:
            return "The whole population feels an heavy discomfort"
        case .level6:
            return "Sanitary emergency due to the the very strong discomfort which may cause heatstrokes"
        }
    }
}
