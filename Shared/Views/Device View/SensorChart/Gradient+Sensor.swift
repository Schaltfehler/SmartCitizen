import Foundation
import SwiftUI

extension Gradient {
    static func airQualtiy(_ range: Range<Double>) -> Gradient {

        let minValue = range.lowerBound
        let maxValue = range.upperBound

        let level1Color = Color(AQI.level1(0).color)
        let level2Color = Color(AQI.level2(0).color)
        let level3Color = Color(AQI.level3(0).color)
        let level4Color = Color(AQI.level4(0).color)
        let level5Color = Color(AQI.level5(0).color)

        let level1Upper = CGFloat(1 - (PM2_5Range.level1.upperBound - minValue) / maxValue )
        let level2Lower = CGFloat(1 - (PM2_5Range.level2.lowerBound - minValue) / maxValue )
        let level2Upper = CGFloat(1 - (PM2_5Range.level2.upperBound - minValue) / maxValue )
        let level3Lower = CGFloat(1 - (PM2_5Range.level3.lowerBound - minValue) / maxValue )
        let level3Upper = CGFloat(1 - (PM2_5Range.level3.upperBound - minValue) / maxValue )
        let level4Lower = CGFloat(1 - (PM2_5Range.level4.lowerBound - minValue) / maxValue )
        let level4Upper = CGFloat(1 - (PM2_5Range.level4.upperBound - minValue) / maxValue )
        let level5Lower = CGFloat(1 - (PM2_5Range.level5.lowerBound - minValue) / maxValue )

        return Gradient(stops: [
            Gradient.Stop(color: level5Color, location: level5Lower.clamped(to: 0...1)),
            Gradient.Stop(color: level4Color, location: level4Upper.clamped(to: 0...1)),
            Gradient.Stop(color: level4Color, location: level4Lower.clamped(to: 0...1)),
            Gradient.Stop(color: level3Color, location: level3Upper.clamped(to: 0...1)),
            Gradient.Stop(color: level3Color, location: level3Lower.clamped(to: 0...1)),
            Gradient.Stop(color: level2Color, location: level2Upper.clamped(to: 0...1)),
            Gradient.Stop(color: level2Color, location: level2Lower.clamped(to: 0...1)),
            Gradient.Stop(color: level1Color, location: level1Upper.clamped(to: 0...1)),
        ])
    }
}
