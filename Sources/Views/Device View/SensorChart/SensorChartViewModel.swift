import SwiftUI
import Combine
import Models

enum DateRange: String, CaseIterable, Identifiable {
    case year
    case month
    case week
    case day
    case hour

    var id: String { self.rawValue }

    var title: String {
        switch self {
        case .year:
            return "Year"
        case .month:
            return "Month"
        case .week:
            return "Week"
        case .day:
            return "Day"
        case .hour:
            return "3 Hours"
        }
    }

    var rollup: Rollup {
        switch self {
        case .year:
            return Rollup.weeks(1)
        case .month:
            return Rollup.days(1)
        case .week:
            return Rollup.hours(6)
        case .day:
            return Rollup.minutes(30)
        case .hour:
            return Rollup.minutes(1)
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .year:
            return .year
        case .month:
            return .month
        case .week:
            return .weekOfYear
        case .day:
            return .day
        case .hour:
            return .hour
        }
    }

    func timeInterval(for date: Date, in timeZone: TimeZone) -> TimeInterval {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.firstWeekday = 2 // Monday

        switch self {
        case .year:
            return calendar.dateInterval(of: .year, for: date)!.duration
        case .month:
            return calendar.dateInterval(of: .month, for: date)!.duration
        case .week:
            return calendar.dateInterval(of: .weekOfYear, for: date)!.duration
        case .day:
            return calendar.dateInterval(of: .day, for: date)!.duration
        case .hour:
            return 3 * calendar.dateInterval(of: .hour, for: date)!.duration
        }
    }
}

final class SensorChartViewModel: ObservableObject {
    static var now:() -> Date = { Date() }

    @Published
    var dateRange: DateRange {
        didSet {
            currentDateInterval = SensorChartViewModel.dateInterval(with: dateRange, date: currentDate, in: timeZone)
        }
    }

    @Published
    var currentDateInterval: DateInterval

    var currentDate: Date {
        didSet {
            currentDateInterval = SensorChartViewModel.dateInterval(with: dateRange, date: currentDate, in: timeZone)
        }
    }

    @Published
    var readings: Readings?

    let sensor: SensorModel

    let timeZone: TimeZone

    let fetcher: SensorFetcher

    var deviceID: Int {
        sensor.device_id
    }
    var sensorId: Int{
        sensor.sensor_id
    }

    var relativeInterval: String {
        switch dateRange {
        case .year:
            return "Last 12 months"

        case .month:
            return "Last 4 weeks"

        case .week:
            return "Last 7 days"

        case .day:
            return "Last 24 hours"

        case .hour:
            return "Last 3 hours"
        }
    }

    var dateInterval: String {
        let formatter = DateIntervalFormatter()

        switch dateRange {
        case .year:
            formatter.dateTemplate = "y"

        case .month:
            formatter.dateTemplate = "MMM y"

        case .week:
            formatter.dateTemplate = "MMM d y"

        case .day:
            formatter.dateTemplate = "MMM d y"

        case .hour:
            formatter.dateTemplate = "MMM d HH mm"
        }

        formatter.timeZone = timeZone

        // Exlude end of DateInterval since it is already part of next day/week/month/year
        // This helps to format the date properly
        let end = currentDateInterval.end.advanced(by: -1)
        let interval = DateInterval(start: currentDateInterval.start, end: end)

        return formatter.string(from: interval) ?? "Unknown date interval"
    }

    var exactDataInterval: String {
        let formatter = DateIntervalFormatter()
        formatter.dateTemplate = "MMM d HH mm"
        formatter.timeZone = timeZone

        let start = readings?.readings.last?.date ?? Self.now()
        let end = readings?.readings.first?.date ?? Self.now()

        let interval = DateInterval(start: start, end: end)

        return formatter.string(from: interval) ?? "Unknown date interval"
    }

    private var subscriptions = Set<AnyCancellable>()

    init(dateRange: DateRange, sensor: SensorModel, timeZone: TimeZone, fetcher: SensorFetcher, readings: Readings? = nil) {
        self.dateRange = dateRange
        self.timeZone = timeZone
        self.sensor = sensor
        self.readings = readings
        self.fetcher = fetcher
        self.currentDate = Self.now()

        currentDateInterval = SensorChartViewModel.dateInterval(with: dateRange, date: currentDate, in: timeZone)
    }

    static func dateInterval(with dateRange: DateRange, date: Date, in timeZone: TimeZone) -> DateInterval {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.firstWeekday = 2 // Monday

        let timeInterval = dateRange.timeInterval(for: date, in: timeZone)
        var dateInterval = calendar.dateInterval(of: dateRange.calendarComponent, for: date)!
        dateInterval = DateInterval(start: dateInterval.end - timeInterval, end: dateInterval.end)

        let now = Self.now()

        if dateInterval.contains(now) {
            let duration = dateInterval.duration
            let start = Date(timeInterval: -duration, since: now)
            dateInterval = DateInterval(start: start, duration: duration)
        }

        return dateInterval
    }

    var shouldShowRelativeToNow: Bool {
        var calendar = Calendar.current
        calendar.timeZone = timeZone
        calendar.firstWeekday = 2 // Monday

        let currentInterval = calendar.dateInterval(of: dateRange.calendarComponent, for: Self.now())!
        return currentInterval.contains(currentDateInterval.end - 1)
    }

    var canForwarded: Bool {
        true
    }

    var canBackward: Bool {
        true
    }

    func forwarded() -> Date {
        currentDateInterval.end.advanced(by: 1)
    }

    func backwarded() -> Date {
        currentDateInterval.start.advanced(by: -1)
    }

    func forward() {
        currentDate = forwarded()
    }

    func backward() {
        currentDate = backwarded()
    }

    func fetch() {
        // overshoot by 2min, so we can capture the full range
        let interval = DateInterval(start: currentDateInterval.start, end: currentDateInterval.end.advanced(by: 120))
        fetcher.requestReadingsFor(deviceID: deviceID, sensorId: sensorId, interval: interval, rollup: dateRange.rollup)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { [weak self] (completion: Subscribers.Completion<Error>) in
                if case .failure(_) = completion {
                    self?.readings = nil
                }
            }, receiveValue: { [weak self] readings in
                self?.readings = readings
            })
            .store(in: &subscriptions)
    }
}
