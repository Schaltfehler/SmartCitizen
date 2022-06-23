import Foundation

public struct MeasurementViewModel: Hashable, Identifiable, Codable {
    public let id: UUID

    public let type: MeasurementType
    public let name: String
    public let description: String
    public let unit: String
    public let value: Double

    public let sensor_id: Int
}

extension MeasurementViewModel {
    public init(sensor: Device.DataObject.Sensor, measurement: SCKMeasurement?) {
        id = sensor.uuid
        value = sensor.value ?? 0.0
        unit =  sensor.unit

        type = MeasurementType(id: sensor.measurementId)
        name = measurement?.name ?? sensor.name
        description = measurement?.description ?? sensor.description
        
        sensor_id = sensor.id
    }
}

public enum MeasurementType: Codable {
    case light
    case noise
    case temperature
    case humidity
    case pressure
    case particlePM1
    case particlePM2_5
    case particlePM10
    case co2
    case battery
    case unknownsensor

    init(id: Int) {
        switch id {
        case 1:
            self = .temperature
        case 2:
            self = .humidity
        case 3:
            self = .light
        case 4:
            self = .noise
        case 7:
            self = .battery
        case 13: // PM10
            self = .particlePM10
        case 14: // PM2.5
            self = .particlePM2_5
        case 27: // PM1
            self = .particlePM1
        case 25:
            self = .pressure

        default:
            self = .unknownsensor
        }
    }

    public var iconName: String {
        switch self {
        case .light:
            return "light_icon"
        case .noise:
            return "sound_icon"
        case .temperature:
            return "temperature_icon"
        case .humidity:
            return "humidity_icon"
        case .pressure:
            return "pressure_icon"
        case .particlePM1, .particlePM2_5, .particlePM10:
            return "particle_icon"
        case .co2:
            return "co_icon"
        case .battery:
            return "battery_icon"
        case .unknownsensor:
            return "unknownsensor_icon"
        }
    }

    public var minValueRange: ClosedRange<Double> {
        switch self {
        case .light:
            return 100...300
        case .noise:
            return 40...60
        case .temperature:
            return 20...30
        case .humidity:
            return 40...60
        case .pressure:
            return 100...104
        case .particlePM1, .particlePM2_5, .particlePM10:
            return 0...10
        case .co2:
            return 500...1500
        case .battery:
            return 0...100
        case .unknownsensor:
            return 0...1
        }
    }
}
