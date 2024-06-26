import Foundation
import Network
import Models

final class TestData {

    /// TestData must be a jsonfile and has been added to the Bundle in root
    static func loadTestData(withFileName fileName: String) -> Data {
        guard let url = Bundle.module.url(forResource: "json/" + fileName, withExtension: "json") else {
            fatalError("Could find resource for \(fileName).json")
        }
        let data = try! Data(contentsOf: url)

        return data
    }

    static func loadDevice() -> Device {
        let data = TestData.loadTestData(withFileName: "DeviceResponse")
        let decoder = Client.jsonDecoder()
        let device = try! decoder.decode(Device.self, from: data)

        return device
    }
    
    static func loadReadings() -> Readings {
        let data = TestData.loadTestData(withFileName: "Readings")
        let decoder = Client.jsonDecoder()
        let readings = try! decoder.decode(Readings.self, from: data)

        return readings
    }
}
