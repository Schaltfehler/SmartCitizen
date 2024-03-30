import SwiftUI
import Combine
import Charts

struct RangeDomainKey: PreferenceKey {
    static let defaultValue = [Double]()
    static func reduce(value: inout [Double], nextValue: () -> [Double]) {
        value = value.isEmpty
        ? nextValue()
        : value
    }
}

public struct SensorChartView: View {
    @Environment(\.colorScheme)
    var colorScheme

    @State
    private var yDomain: [Double]?

    @ObservedObject
    var model: SensorChartViewModel

    init(model: SensorChartViewModel) {
        self.model = model
    }

    let dataOutlineColor = Color.secondary

    public var body: some View {
        VStack(spacing: 0) {
            HStack {
                Button("<") {
                    model.backward()
                }
                .disabled(!model.canBackward)

                Spacer()
                if model.shouldShowRelativeToNow {
                    Text(model.relativeInterval)
                } else {
                    Text(model.dateInterval)
                }
                Spacer()

                Button(">") {
                    model.forward()
                }
                .disabled(!model.canForwarded)
            }
            .padding()

            Picker("Date Range", selection: $model.selectedDateRange) {
                ForEach(DateRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if let readings = self.model.readings, !readings.readings.isEmpty {
                Chart {
                    ForEach(readings.readings) { item in
                        AreaMark(x: .value("Date", item.date),
                                 y: .value("Value", item.value)
                        )
                        .accessibilityLabel("\(item.value)")
                    }
                    .foregroundStyle(gradiant(model.sensor.type))
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.monotone)
                    .symbol(by: .value("Value", model.sensor.unit))
                    .opacity(colorScheme == .light ? 0.7 : 0.4)

                    ForEach(readings.readings) { item in
                        LineMark(
                            x: .value("Date", item.date),
                            y: .value("Value", item.value)
                        )
                        .accessibilityLabel("\(item.value)")
                    }
                    .foregroundStyle(dataOutlineColor)
                    .alignsMarkStylesWithPlotArea()
                    .interpolationMethod(.monotone)
                }
                .chartXAxis {
                    AxisMarks(position: .bottom, values: .stride(
                        by: model.selectedDateRange.strideBy,
                        count: model.selectedDateRange.strideCount,
                        roundLowerBound: true,
                        roundUpperBound: true)
                    ) { date in
                        AxisGridLine(stroke: .init(lineWidth: 1))
                        AxisValueLabel(
                            format: model.selectedDateRange.dateFormatStyle,
                            centered: !model.selectedDateRange.isPointInTime,
                            anchor: .top,
                            multiLabelAlignment: .center,
                            collisionResolution: .automatic,
                            orientation: .horizontal
                        )
                    }
                }
                .chartOverlay { proxy in
                    Color.clear.preference(key: RangeDomainKey.self,
                                           value: proxy.yDomain(dataType: Double.self))
                }
                .onPreferenceChange(RangeDomainKey.self) {
                    yDomain = $0
                }
                .chartYAxis {
                    AxisMarks(preset: .extended,
                              position: .leading,
                              values: .automatic(desiredCount: 5))
                }
                .chartLegend(position: .top, alignment: .topLeading) {
                    Text(model.sensor.unit)
                        .font(.subheadline)
                        .foregroundColor(dataOutlineColor)
                }
                .padding()
                .frame(height: 300)
            } else if let readings = self.model.readings, readings.readings.isEmpty {
                Text("No data for this time range.")
                    .font(.title)
                    .padding()
                    .frame(height: 300)
            } else {
                Text("Loading...")
                    .font(.title)
                    .padding()
                    .frame(height: 300)
            }

            Spacer()
        }
        .navigationTitle(model.sensor.name)
        .onAppear {
            model.fetch()
        }
        .onChange(of: model.currentDateInterval) { _ in
            model.readings = nil
            model.fetch()
        }
        .onChange(of: model.selectedDateRange) { _ in
            model.readings = nil
            model.fetch()
        }
    }

    func gradiant(_ type: MeasurementType) -> LinearGradient {
        switch type {
        case .light, .noise, .temperature, .humidity, .pressure, .co2, .battery, .organicParticle, .unknownMeasurement:
            return LinearGradient(colors: [.clear, .blue], startPoint: .bottom, endPoint: .top)
        case .particlePM1, .particlePM2_5, .particlePM10:
            return LinearGradient.linearGradient(
                Gradient.airQualtiy(
                    minValue: yDomain?.min() ?? 0,
                    maxValue: yDomain?.max() ?? 0
                ),
                startPoint: .top,
                endPoint: .bottom)
        }
    }
}

#if DEBUG
struct SensorChartView_Previews: PreviewProvider {
    static let readings = PreviewData.loadReadingsFullDay()
    static let end = { Self.readings.readings.first!.date }()
    static var previews: some View {
        let fetcher = SensorFetcher.mockedWithFullDayReadings()
        let model = SensorChartViewModel(
            dateRange: .hour,
            sensor: SensorModel.mocked,
            timeZone: TimeZone(abbreviation: "JST")!,
            fetcher: fetcher,
            readings: readings,
            now: { Date(timeIntervalSince1970: end.timeIntervalSince1970) }
        )
        model.fetch()

        return SensorChartView(model: model)
    }
}
#endif
