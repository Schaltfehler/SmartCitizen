import Foundation
import UIKit
import Models
import Network

final class PreviewData {
    static func loadTestData(withFileName fileName: String) -> Data {
        let dataAsset = NSDataAsset(name: fileName)!

        return dataAsset.data
    }
    
    static func loadDevice() -> Device {
        let data = PreviewData.loadTestData(withFileName: "DeviceResponse")
        let decoder = Client.jsonDecoder()
        let device = try! decoder.decode(Device.self, from: data)

        return device
    }
    
    static func loadMeasurements() -> Array<SCKMeasurement> {
        let data = PreviewData.loadTestData(withFileName: "Measurements")
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Array<SCKMeasurement>.self, from: data)

        return measurements
    }
    
    static func loadReadings() -> Readings {
        let data = PreviewData.loadTestData(withFileName: "Readings")
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Readings.self, from: data)

        return measurements
    }

    static func loadReadingsFullDay() -> Readings {
        let data = SensorFetcher.FullDayReadings
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Readings.self, from: data)

        return measurements
    }

    static func loadWorldDeviceForBarcelona() -> [WorldMapDevice] {
        let data = PreviewData.loadTestData(withFileName: "WorldDevices")
        let decoder = Client.jsonDecoder()
        let devices = try! decoder.decode(Array<WorldMapDevice>.self, from: data)

        return devices
    }
}
