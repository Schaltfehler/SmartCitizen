import SwiftUI
import Combine
import Charts

public struct SensorChartView: View {
    @Environment(\.colorScheme)
    var colorScheme

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
                    .foregroundStyle(
                        .linearGradient(Gradient.airQualtiy(readings.valueRange),
                                        startPoint: .top,
                                        endPoint: .bottom)
                    )
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
                .chartYAxis { AxisMarks(preset: .extended, position: .leading) }
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
}


struct SensorChartView_Previews: PreviewProvider {
    static let readings = PreviewData.loadReadingsFullDay()
    static let end = { Self.readings.readings.first!.date }()
    static var previews: some View {
        let fetcher = SensorFetcher.mockedWithFullDayReadings()
        let model = SensorChartViewModel(
            dateRange: .day,
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


