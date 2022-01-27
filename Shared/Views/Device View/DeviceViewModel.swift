import Foundation
import CoreLocation

public struct DeviceViewModel: Hashable, Identifiable, Codable {
    public let id: Int

    public let ownerName: String
    public let cityName: String

    public let name: String
    public let description: String
    public let state: String

    public var timeZone: TimeZone

    public let lastRecorded: Date
    public let measurments: [MeasurementViewModel]

    public var aqi: AQI? {
        let aqis: [AQI] = self.measurments.compactMap { sensor in
            switch sensor.type {
            case .particlePM2_5:
                return AQI(pm2_5: sensor.value)
            default:
                return nil
            }
        }

        return aqis.first
    }

    var temperatures: [Double] {
        self.measurments.compactMap { sensor in
            switch sensor.type {
            case .temperature:
                return sensor.value
            default:
                return nil
            }
        }
    }

    var humidities: [Double] {
        self.measurments.compactMap { sensor in
            switch sensor.type {
            case .humidity:
                return sensor.value
            default:
                return nil
            }
        }
    }

    public var temperatureHumidityIndex: TemperatureHumidityIndex? {
        guard let humidity = humidities.first,
              let temperture = temperatures.first
        else { return nil }

        let thi = TemperatureHumidityIndex(celsius: temperture, humidity: humidity)

        return thi
    }

    public var discomfortIndexAfterThom: ThomDiscomfortIndex? {
        guard let humidity = humidities.first,
              let temperture = temperatures.first
        else { return nil }

        return ThomDiscomfortIndex(celsius: temperture, humidity: humidity)
    }

    public var discomfortIndexAfterKawamura: KawamuraDiscomfortIndex? {
        guard let humidity = humidities.first,
              let temperture = temperatures.first
        else { return nil }

        return KawamuraDiscomfortIndex(celsius: temperture, humidity: humidity)
    }

    public var humidex: Humidex? {
        guard let humidity = humidities.first,
              let temperture = temperatures.first
        else { return nil }

        return Humidex(celsius: temperture, humidity: humidity)
    }
}

extension DeviceViewModel {
    public init(device: Device, measurements:[SCKMeasurement]) {

        let measurementDict = Dictionary(uniqueKeysWithValues: measurements.map {($0.id, $0)})

        id = device.id
        name = device.name
        ownerName = device.owner.username
        cityName = device.data.location.city ?? "-"
        description = device.description ?? "-"
        state = device.state
        lastRecorded = device.lastReadingAt ?? Date(timeIntervalSince1970: 0)
        measurments = device.data.sensors.map { (sensor: Device.DataObject.Sensor) in
            let measurement = measurementDict[sensor.measurementId]
            return MeasurementViewModel.init(sensor: sensor, measurement: measurement)
        }.sorted{ $0.name.lowercased() < $1.name.lowercased() }

        timeZone = TimeZone.current
        // TODO: Find a better way to find a correct TimeZone for the device
//        if let latitude = device.data.location.latitude,
//           let longitude = device.data.location.longitude {
//            let location = CLLocation(latitude: latitude, longitude: longitude)
//            let geocoder = CLGeocoder()
//            geocoder.reverseGeocodeLocation(location) { (placemarks: [CLPlacemark]?, error: Error?) in
//                let placemark = placemarks?.first { $0.timeZone != nil}
//                self.timeZone = placemark?.timeZone ?? TimeZone.init(secondsFromGMT: 0)!
//            }
//        }
    }
}
