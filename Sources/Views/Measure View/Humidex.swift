import Foundation
import CoreGraphics

public enum Humidex {
    case level1(Double, Double, Double)
    case level2(Double, Double, Double)
    case level3(Double, Double, Double)
    case level4(Double, Double, Double)
    case level5(Double, Double, Double)
    case level6(Double, Double, Double)

    public init(celsius: Double, humidity: Double) {
        let dewPoint = Humidex.approximatedDewPoint(celsius: celsius, humidity: humidity)
        let index = Humidex.humidex(celsius: celsius, dewPoint: dewPoint)

        switch index {
        case ..<29.5:
            self = .level1(index, celsius, humidity)
        case 29.5..<34.5:
            self = .level2(index, celsius, humidity)
        case 34.5..<39.5:
            self = .level3(index, celsius, humidity)
        case 40..<45.0:
            self = .level4(index, celsius, humidity)
        case 45.0..<54.0:
            self = .level5(index, celsius, humidity)
        default:
            self = .level6(index, celsius, humidity)
        }
    }

    /// This approach is accurate to within about ±1 °C as long as the relative humidity is above 50%
    static func approximatedDewPoint(celsius: Double, humidity: Double) -> Double {
        celsius - (100.0 - humidity) / 5.0
    }

    /// Humidex formular
    // https://en.wikipedia.org/wiki/Humidex
    static func humidex(celsius: Double, dewPoint: Double) -> Double {
        celsius + 5.0/9.0 * ( 6.11 * pow(M_E, 5417.7530 * ( 1 / 273.16 - 1.0 / (273.15 + dewPoint))) - 10.0)
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
            return "Slight discomfort sensation"
        case .level3:
            return "Strong discomfort. Caution: limit the heaviest physical activities"
        case .level4:
            return "Strong indisposition sensation. Danger: avoid efforts"
        case .level5:
            return "Serious danger: stop all physical activities"
        case .level6:
            return "Death danger: imminent heatstroke"
        }
    }
}

