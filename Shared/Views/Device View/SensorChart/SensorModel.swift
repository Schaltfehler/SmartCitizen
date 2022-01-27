import Foundation

public struct SensorModel: Hashable, Identifiable {
    public let id: UUID = UUID()
    public let name: String

    // For API
    public let device_id: Int
    public let sensor_id: Int

    public let type: MeasurementType
    public let unit: String
}

extension SensorModel {
    public init(sensor: MeasurementViewModel, device: DeviceViewModel) {
        name = sensor.name

        type = sensor.type
        unit = sensor.unit

        device_id = device.id
        sensor_id = sensor.sensor_id
    }
}
