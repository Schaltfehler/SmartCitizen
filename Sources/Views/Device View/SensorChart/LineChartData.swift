import Foundation
import SwiftUI
import Models

struct AxisLabel: Hashable, Identifiable {
    var id = UUID()
    let text: String
    let value: CGFloat
}

struct LineChartData {
    var unitPoints: [(x: Double, y: Double)]

    var xPositions: [CGFloat]
    var xLabels: [AxisLabel]

    var yPositions: [CGFloat]
    var yLabels: [AxisLabel]
    let unit: String
    let type: MeasurementType

    let xScaleIsRanged: Bool

    var dateInterval: DateInterval
    var valueRange: Range<Double>

    init(readings:[(value: Double, date: Date)],
         in timeZone: TimeZone,
         dateInterval: DateInterval,
         scale: DateRange,
         type: MeasurementType,
         unit: String) {
        self.unit = unit
        self.type = type

        // Convert readings to unit points
        let dataPoints = readings.map{ $0.value }

        var maxValue = max(dataPoints.max() ?? 1.0, type.minValueRange.upperBound)
        var minValue = min(dataPoints.min() ?? 0.0, type.minValueRange.lowerBound)
        let youngest = dateInterval.end.timeIntervalSince1970
        let oldest = dateInterval.start.timeIntervalSince1970

        maxValue = dataPoints.max() ?? 1.0
        minValue = dataPoints.min() ?? 0.0
        maxValue = maxValue.roundedUpToNearest(multipleOf: 2)
        minValue = minValue.roundedDownToNearest(multipleOf: 2)

        let valueDiff = maxValue - minValue
        let dateDiff = youngest - oldest

        let unitPoints = readings.compactMap { value -> (x: Double, y: Double)? in
            let part = value.value - minValue
            let yUnit = part / valueDiff
            let timeDiff = value.date.timeIntervalSince1970 - oldest
            let xUnit = timeDiff / dateDiff

            // Trim off datapoints that are outside of the scope
            if xUnit < 0 || 1.01 < xUnit {
//                print("Warning: \(xUnit) is outside of scope.")
                return nil
            }

            return (x: min(1, xUnit), y: yUnit)
        }

        self.unitPoints = unitPoints.sorted{ $0.x < $1.x }

        switch scale {
        case .year, .week:
            self.xScaleIsRanged = true
        case .hour, .day, .month:
            self.xScaleIsRanged = false
        }


        let xScale: Double
        switch scale {
        case .year:
            xScale = dateInterval.duration / 12.0
        case .month:
            xScale = (dateInterval.duration) / 9.0
        case .week:
            xScale = (dateInterval.duration) / 7.0
        case .day:
            xScale = dateInterval.duration / 8.0
        case .hour:
            xScale = dateInterval.duration / 6.0
        }

        let yRange = Range<Double>(uncheckedBounds: (lower: minValue, upper: maxValue))
        let yScale = (valueDiff / 4)

        self.dateInterval = dateInterval
        self.valueRange = yRange

        let formatter = DateFormatter()
        formatter.timeZone = timeZone
        switch scale {
        case .year:
            formatter.dateFormat = "MMMMM"
        case .month:
            formatter.dateFormat = "dd"
        case .week:
            formatter.dateFormat = "EEEEEE"
        case .day:
            formatter.dateFormat = "k"
        case .hour:
            formatter.dateFormat = "H:mm"
        }

        let timeZomeDiff: Double = Double(timeZone.secondsFromGMT())
        let xRangeTimeZoned = Range<Double>(uncheckedBounds: (lower: dateInterval.start.timeIntervalSince1970 + timeZomeDiff,
                                                              upper: dateInterval.end.timeIntervalSince1970 + timeZomeDiff))

        xPositions = xRangeTimeZoned.normalize(withScale: xScale)
        let xTitles = xPositions.map{ pos -> String in
            let value = dateInterval.start.timeIntervalSince1970 + Double(pos) * dateInterval.duration
            let date = Date(timeIntervalSince1970: value)
            var time = formatter.string(from: date)

            if pos == 0.0, time == "24", scale == .day {
                time = "0"
            }

           return time
        }

        yPositions = yRange.normalize(withScale: yScale)
        let yTitles = yPositions.map{ pos -> String in
            let fullDistance = yRange.upperBound - yRange.lowerBound
            let value = yRange.lowerBound + Double(pos) * fullDistance
           return String(format: "%.1f", value)
        }

        yLabels = zip(yTitles, yPositions).map{ AxisLabel(text: $0, value: $1) }
        xLabels = zip(xTitles, xPositions).map{ AxisLabel(text: $0, value: $1) }
    }
}

extension LineChartData {
    init(readings: Readings,
         in timeZone: TimeZone,
         dateInterval: DateInterval,
         selectedDateRange: DateRange,
         type: MeasurementType,
         unit: String) {
        let values = readings.readings.map {(value: $0.value, date: $0.date)}
        self.init(readings: values, in: timeZone, dateInterval: dateInterval, scale: selectedDateRange, type: type, unit: unit)
    }
}
