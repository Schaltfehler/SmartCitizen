import XCTest
import Models
import Network


final class SmartCitizenTests: XCTestCase {
    func testDateDecoding() {
        let dateSting = "2020-01-05T01:10:07Z"
        let formatter = DateFormatter()
        formatter.dateFormat = Client.dateFormat
        let date = formatter.date(from: dateSting)!

        XCTAssertEqual(date.description, "2020-01-05 01:10:07 +0000")
    }

    func testCanDecodeDataObject() {
        let data = TestData.loadTestData(withFileName: "DataObject")
        let decoder = Client.jsonDecoder()

        let dataObject: Device.DataObject
        do {
            dataObject = try decoder.decode(Device.DataObject.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(dataObject.sensors.count, 2)
    }

    func testCanDecodeOwner() {
        let data = TestData.loadTestData(withFileName: "Owner")
        let decoder = Client.jsonDecoder()

        let owner: Device.Owner
        do {
            owner = try decoder.decode(Device.Owner.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(owner.id, 1234)
    }

    func testCanDecodeDevice() {
        let data = TestData.loadTestData(withFileName: "DeviceResponse")
        let decoder = Client.jsonDecoder()

        let device: Device
        do {
            device = try decoder.decode(Device.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(device.name, "MyDevice")
    }

    func testCanDecodeMeasurements() {
        let data = TestData.loadTestData(withFileName: "Measurements")
        let decoder = Client.jsonDecoder()

        let measurements: Set<SCKMeasurement>
        do {
            measurements = try decoder.decode(Set<SCKMeasurement>.self, from: data)

        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(measurements.count, 48)
    }

    func testCanDecodeGlobalSearch() {
        let data = TestData.loadTestData(withFileName: "GlobalSearch")
        let decoder = Client.jsonDecoder()

        let searchResults: [GlobalSearch]
        do {
            searchResults = try decoder.decode(Array<GlobalSearch>.self, from: data)

        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(searchResults.count, 4)
    }

    func testCanDecodeGlobalSearchDevice() {
        let data = TestData.loadTestData(withFileName: "GlobalSearchDevice")
        let decoder = Client.jsonDecoder()

        let device: GlobalSearch.Device
        do {
            device = try decoder.decode(GlobalSearch.Device.self, from: data)

        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(device.name, "Barcelona-Corcega")
    }

    func testCanDecodeWorldMapDevice() {
        let data = TestData.loadTestData(withFileName: "WorldMapDevice")
        let decoder = Client.jsonDecoder()

        let device: WorldMapDevice
        do {
            device = try decoder.decode(WorldMapDevice.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(device.name, "Giant Spark Eggnog")
    }

    func testCanDecodeWorldMapDevices() {
        let data = TestData.loadTestData(withFileName: "WorldMapDevices")
        let decoder = Client.jsonDecoder()

        let devices: [WorldMapDevice]
        do {
            devices = try decoder.decode(Array<WorldMapDevice>.self, from: data)
        } catch {
            fatalError(error.localizedDescription)
        }

        XCTAssertEqual(devices.count, 5)
    }

    func testCanDecodeReadings() {
        let data = TestData.loadTestData(withFileName: "Readings")
        let decoder = Client.jsonDecoder()

        let readings: Readings
        do {
            readings = try decoder.decode(Readings.self, from: data)
            XCTAssertEqual(readings.readings.count, 9)
        } catch {
            XCTFail(error.localizedDescription)
        }
    }
}
