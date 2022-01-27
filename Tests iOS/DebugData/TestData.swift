import Foundation
import UIKit

@testable import SmartCitizen

final class TestData {

    /// TestData must be a jsonfile and has been added to the Bundle in root
    static func loadTestData(withFileName fileName: String) -> Data {
        let bundle = Bundle(for: TestData.self)
        let path = bundle.path(forResource: fileName, ofType: "json")!
        let url = URL(fileURLWithPath: path, isDirectory: false)
        let data = try! Data(contentsOf: url)

        return data
    }

    static func loadDevice() -> Device {
        let data = TestData.loadTestData(withFileName: "DeviceResponse")
        let decoder = Client.jsonDecoder()
        let device = try! decoder.decode(Device.self, from: data)

        return device
    }

    static func loadMeasurements() -> Array<SCKMeasurement> {
        let data = TestData.loadTestData(withFileName: "Measurements")
        let decoder = Client.jsonDecoder()
        let measurements = try! decoder.decode(Array<SCKMeasurement>.self, from: data)

        return measurements
    }
    
    static func loadReadings() -> Readings {
        let data = TestData.loadTestData(withFileName: "Readings")
        let decoder = Client.jsonDecoder()
        let readings = try! decoder.decode(Readings.self, from: data)

        return readings
    }
}
