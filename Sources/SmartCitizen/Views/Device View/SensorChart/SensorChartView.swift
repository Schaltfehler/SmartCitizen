import SwiftUI
import Combine

public struct SensorChartView: View {

    @ObservedObject
    var model: SensorChartViewModel

    init(model: SensorChartViewModel) {
        self.model = model
    }
    
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
//                    Text(model.exactDataInterval)
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

            Picker("Date Range", selection: $model.dateRange) {
                ForEach(DateRange.allCases) { range in
                    Text(range.title).tag(range)
                }
            }
            .pickerStyle(SegmentedPickerStyle())

            if let readings = self.model.readings {
                let chartData = LineChartData(readings: readings,
                                              in: model.timeZone,
                                              dateInterval: model.currentDateInterval,
                                              selectedDateRange: model.dateRange,
                                              type: model.sensor.type,
                                              unit: model.sensor.unit)
                LineChartView(data: chartData)
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
        .onChange(of: model.dateRange) { _ in
            model.readings = nil
            model.fetch()
        }
    }
}

#if DEBUG

extension SensorModel {
    static var mocked: SensorModel {
        SensorModel(name: "My Sensor", device_id: 1, sensor_id: 2, type: MeasurementType.co2, unit: "co2")
    }
}


struct SensorChartView_Previews: PreviewProvider {
    static var previews: some View {
        let readings = PreviewData.loadReadingsFullDay()
        let end = readings.readings.first!.date
        SensorChartViewModel.now = { Date(timeIntervalSince1970: end.timeIntervalSince1970) }

        let fetcher = SensorFetcher.mockedWithFullDayReadings()
        let model = SensorChartViewModel(dateRange: .day,
                                         sensor: SensorModel.mocked,
                                         timeZone: TimeZone(abbreviation: "JST")!,
                                         fetcher: fetcher,
                                         readings: readings)
        model.fetch()

        return SensorChartView(model: model)
            .preferredColorScheme(.light)
    }
}

#endif
