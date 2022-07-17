import Foundation
import Combine

public final class FavoritesStore: ObservableObject {
    private static let devicesStoreKey = "FavoriteDevicesKey"

    public static var `default` = FavoritesStore(load: FavoritesStore.load,
                                                 save: FavoritesStore.save)

    static func save(_ devices: [DeviceCellModel]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(devices) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: FavoritesStore.devicesStoreKey)
        }
    }

    static func load() -> [DeviceCellModel] {
        let userDefault = UserDefaults.standard
        if let savedPerson = userDefault.object(forKey: FavoritesStore.devicesStoreKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedPerson = try? decoder.decode(Array<DeviceCellModel>.self, from: savedPerson) {
                return loadedPerson
            }
        }

        return [DeviceCellModel]()
    }

    private let loadDevices: () -> Array<DeviceCellModel>
    private let saveDevices: ([DeviceCellModel]) -> Void

    @Published
    private(set) var devices: Array<DeviceCellModel>

    init(load: @escaping () -> Array<DeviceCellModel>, save: @escaping ([DeviceCellModel]) -> Void) {
        self.loadDevices = load
        self.saveDevices = save

        self.devices = loadDevices()
    }

    func append(_ device: DeviceCellModel) {
        devices.append(device)
        save()
    }

    func remove(withId id: Int) {
        devices.removeAll{ $0.id == id}
        save()
    }

    func save() {
        saveDevices(devices)
    }
}
