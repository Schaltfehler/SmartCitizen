import Foundation
import Combine
import Models

public final class FavoritesStore: ObservableObject {
    private static let devicesStoreKey = "FavoriteDevicesKey"

    public static var `default` = FavoritesStore(load: FavoritesStore.load,
                                                 save: FavoritesStore.save)

    static func save(_ devices: [DevicePreviewModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(devices) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: FavoritesStore.devicesStoreKey)
        }
    }

    static func load() -> [DevicePreviewModel] {
        let userDefault = UserDefaults.standard
        if let savedPerson = userDefault.object(forKey: FavoritesStore.devicesStoreKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(Array<DevicePreviewModel>.self, from: savedPerson) {
                return loadedPerson
            }
        }

        return [DevicePreviewModel]()
    }

    private let loadDevices: () -> Array<DevicePreviewModel>
    private let saveDevices: ([DevicePreviewModel]) -> Void

    @Published
    public private(set) var devices: Array<DevicePreviewModel>

    public init(load: @escaping () -> Array<DevicePreviewModel>, save: @escaping ([DevicePreviewModel]) -> Void) {
        self.loadDevices = load
        self.saveDevices = save

        self.devices = loadDevices()
    }

    public func append(_ device: DevicePreviewModel) {
        devices.append(device)
        save()
    }

    public func remove(withId id: Int) {
        devices.removeAll{ $0.id == id}
        save()
    }

    public func save() {
        saveDevices(devices)
    }
}
