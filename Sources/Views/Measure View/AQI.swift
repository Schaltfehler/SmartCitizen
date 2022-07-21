import Foundation
import CoreGraphics

enum PM2_5Range {
    static let level1 = 0..<12.1
    static let level2 = 12.1..<35.5
    static let level3 = 35.5..<55.5
    static let level4 = 55.5..<150.5
    static let level5 = 150.5..<250.5
    static let level6 = 250.5..<350.5
    static let level7 = 350.5..<500.5
}

enum PM10Range {
    static let level1 = 0..<55.0
    static let level2 = 55..<155
    static let level3 = 155..<255
    static let level4 = 255..<355
    static let level5 = 355..<425
    static let level6 = 425..<505
    static let level7 = 505..<605
}

enum AQIRange {
    static let level1 = 0..<51
    static let level2 = 51..<101
    static let level3 = 101..<151
    static let level4 = 151..<201
    static let level5 = 201..<301
    static let level6 = 301..<401
    static let level7 = 401..<501
}

public enum AQI {
    case level1(Int)
    case level2(Int)
    case level3(Int)
    case level4(Int)
    case level5(Int)
    case level6(Int)
    case level7(Int)
    case outOfScope(Int)

    public init(pm2_5: Double) {
        switch pm2_5 {
        case PM2_5Range.level1:
            let aqi = AQI.aqi(iRange: AQIRange.level1,
                              cRange: PM2_5Range.level1,
                              c: pm2_5)
            self = AQI.level1(aqi)

        case PM2_5Range.level2:
            let aqi = AQI.aqi(iRange: AQIRange.level2,
                              cRange: PM2_5Range.level2,
                              c: pm2_5)
            self = AQI.level2(aqi)

        case PM2_5Range.level3:
            let aqi = AQI.aqi(iRange: AQIRange.level3,
                              cRange: PM2_5Range.level3,
                              c: pm2_5)
            self = AQI.level3(aqi)

        case PM2_5Range.level4:
            let aqi = AQI.aqi(iRange: AQIRange.level4,
                              cRange: PM2_5Range.level4,
                              c: pm2_5)
            self = AQI.level4(aqi)

        case PM2_5Range.level5:
            let aqi = AQI.aqi(iRange: AQIRange.level5,
                              cRange: PM2_5Range.level5,
                              c: pm2_5)
            self = AQI.level5(aqi)

        case PM2_5Range.level6:
            let aqi = AQI.aqi(iRange: AQIRange.level6,
                              cRange: PM2_5Range.level6,
                              c: pm2_5)
            self = AQI.level6(aqi)

        case PM2_5Range.level7:
            let aqi = AQI.aqi(iRange: AQIRange.level7,
                              cRange: PM2_5Range.level7,
                              c: pm2_5)
            self = AQI.level7(aqi)
        default:
            let aqi = AQI.aqi(iRange: AQIRange.level7,
                              cRange: PM2_5Range.level7,
                              c: pm2_5)
            self = AQI.outOfScope(aqi)
        }
    }

    var value: Int {
        switch self {
        case  .level1(let index),
              .level2(let index),
              .level3(let index),
              .level4(let index),
              .level5(let index),
              .level6(let index),
              .level7(let index),
              .outOfScope(let index):
            return index
        }
    }

    static func aqi(iRange: Range<Int>,
                    cRange: Range<Double>,
                    c: Double) -> Int {
        let iRangeDiff = Double(iRange.upperBound - iRange.lowerBound)
        let cRangeDiff = cRange.upperBound - cRange.lowerBound
        let index = (iRangeDiff / cRangeDiff) * (c - cRange.lowerBound)
            + Double(iRange.lowerBound)

        return Int(index.rounded())
    }

    var color: CGColor {
        switch self {
        case .level1:
            return CGColor(red: 0, green: 228/255, blue: 0, alpha: 1)
        case .level2:
            return CGColor(red: 1, green: 1, blue: 0, alpha: 1)
        case .level3:
            return CGColor(red: 1, green: 126/255, blue: 0, alpha: 1)
        case .level4:
            return CGColor(red: 1, green: 0, blue: 0, alpha: 1)
        case .level5:
            return CGColor(red: 143/255, green: 63/255, blue: 151/255, alpha: 1)
        case .level6:
            return CGColor(red: 126/255, green: 0, blue: 35/255, alpha: 1)
        case .level7:
            return CGColor(red: 126/255, green: 0, blue: 35/255, alpha: 1)
        case .outOfScope:
            return CGColor(red: 126/255, green: 0, blue: 35/255, alpha: 1)
        }
    }

    var category: String {
        switch self {
        case .level1:
            return "Good"
        case .level2:
            return "Moderate"
        case .level3:
            return "Unhealthy for Sensitive Groups"
        case .level4:
            return "Unhealthy"
        case .level5:
            return "Very unhealthy"
        case .level6:
            return "Hazardous"
        case .level7:
            return "Hazardous"
        case .outOfScope:
            return "Hazardous"
        }
    }
    var advisory: String? {
        switch self {
        case .level1:
            return nil
        case .level2:
            return "Unusually sensitive people should consider reducing prolonged  or heavy outdoor exertion."
        case .level3:
            return "The following groups should reduce prolonged or heavy outdoor exertion:\n  • People with lung disease, such as asthma\n  • Children and older adults\n  • People who are active outdoors"
        case .level4:
            return "The following groups should avoid prolonged or heavy outdoor exertion:\n  • People with lung disease, such as asthma\n  • Children and older adults\n  • People who are active outdoorsEveryone else should limit prolonged outdoor exertion."
        case .level5, .level6, .level7, .outOfScope:
            return "The following groups should avoid all outdoor exertion:\n  • People with lung disease, such as asthma\n  • Children and older adults\n  • People who are active outdoorsEveryone else should limit outdoor exertion."
        }
    }
}
