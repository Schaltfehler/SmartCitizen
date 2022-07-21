import SwiftUI
import Combine
import Network

public struct DeviceView: View {

    @ObservedObject
    var viewModel: DeviceViewModel

    public init(device: DeviceViewModel) {
        self.viewModel = device
    }
    
    var header: some View {
        HStack {
            Text("Device")
            Spacer()
            Button(action: viewModel.settingsButtonTapped) {
                Image(systemName: "gearshape")
            }
            .sheet(isPresented: $viewModel.showingSettings) {
                SettingsView()
            }
        }
    }

    public var body: some View {
        Form {
            Section(header: header) {
                Text(viewModel.name)
                    .withLabel(label: "Name")
                DateView(date: viewModel.lastRecorded)
                    .withLabel(label: "Updated")

                if let aqi = viewModel.aqi,
                   viewModel.store.shouldShowAqi {
                    AQIValueView(index: aqi)
                }

                if let thi = viewModel.temperatureHumidityIndex,
                   viewModel.store.shouldShowThi {
                    THIValueView(thi: thi)
                }

                if let tdi = viewModel.discomfortIndexAfterThom,
                   viewModel.store.shouldShowTdi {
                    TDIValueView(tdi: tdi)
                }

                if let kdi = viewModel.discomfortIndexAfterKawamura,
                   viewModel.store.shouldShowKdi {
                    KDIValueView(kdi: kdi)
                }

                if let humidex = viewModel.humidex,
                   viewModel.store.shouldShowHumidex {
                    HumidexValueView(humidex: humidex)
                }
            }

            Section(header: Text("Measurments")){
                ForEach(viewModel.measurments) { measurment in
                    let model = SensorChartViewModel(dateRange: .hour,
                                                     sensor: SensorModel(sensor: measurment, device: viewModel),
                                                     timeZone: viewModel.timeZone,
                                                     fetcher: SensorFetcher(client: Client()))

                    NavigationLink(destination: SensorChartView(model: model)) {
                        SensorValueView(sensor: measurment)
                    }
                }
            }
        }
    }
}

struct AQIValueView: View {
    let index: AQI
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color(index.color))
                    .frame(width: 10, height: 10)
                Text("AQI")
                Spacer()
                Text("\(self.index.category) (\(self.index.value))")
            }
            if let advisory = self.index.advisory {
                Text(advisory)
                    .font(.footnote)
            }
        }
    }
}

struct THIValueView: View {
    let thi: TemperatureHumidityIndex
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color(thi.color))
                    .frame(width: 10, height: 10)
                Text("THI")
                Spacer()
                Text("\(self.thi.category) (\(Int(self.thi.index.rounded())))")
            }
        }
    }
}

struct TDIValueView: View {
    let tdi: ThomDiscomfortIndex
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color(tdi.color))
                    .frame(width: 10, height: 10)
                Text("TDI")
                Spacer()
                Text("\(Int(self.tdi.index.rounded()))")
            }
            if let advisory = self.tdi.advisory {
                Text(advisory)
                    .font(.footnote)
            }
        }
    }
}

struct KDIValueView: View {
    let kdi: KawamuraDiscomfortIndex
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color(kdi.color))
                    .frame(width: 10, height: 10)
                Text("KDI")
                Spacer()
                Text("\(self.kdi.category) (\(Int(self.kdi.index.rounded())))")
            }
        }
    }
}

struct HumidexValueView: View {
    let humidex: Humidex
    var body: some View {
        VStack(alignment: .trailing) {
            HStack(alignment: .firstTextBaseline) {
                Circle()
                    .fill(Color(humidex.color))
                    .frame(width: 10, height: 10)
                Text("Humidex")
                Spacer()
                Text("\(Int(self.humidex.index.rounded()))")
            }
            if let advisory = self.humidex.advisory {
                Text(advisory)
                    .font(.footnote)
            }
        }
    }
}

public struct SensorValueView: View {
    let sensor: MeasurementViewModel

    public var body: some View {
        VStack(alignment: .center) {
            HStack(alignment: .firstTextBaseline) {
                Image(sensor.type.iconName)
                    .frame(width: 30)
                Text(String(sensor.name))
                    .bold()
                Spacer()
                Text(sensor.value.formatted(.number.precision(.fractionLength(0...2))) + " " + sensor.unit)
            }
            .font(.headline)
//            Text(sensor.description)
        }
    }
}

#if DEBUG

struct DeviceView_Previews: PreviewProvider {
    
    static var previews: some View {

        let device = PreviewData.loadDevice()
        let measurements = PreviewData.loadMeasurements()

        let viewModel = DeviceViewModel(device: device,
                                        measurements: measurements,
                                        store: .init())
        return NavigationView {
            DeviceView(device: viewModel)
        }
    }
}

#endif
