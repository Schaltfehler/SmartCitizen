import Foundation
import Combine

public final class FavoritesStore: ObservableObject {
    private static let devicesStoreKey = "FavoriteDevicesKey"

    @Published
    private(set) var devices: Array<DeviceCellModel> {
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(devices) {
                let defaults = UserDefaults.standard
                defaults.set(encoded, forKey: FavoritesStore.devicesStoreKey)
            }
        }
    }


    public init() {
        func load() -> Array<DeviceCellModel> {
            let userDefault = UserDefaults.standard
            if let savedPerson = userDefault.object(forKey: FavoritesStore.devicesStoreKey) as? Data {
                let decoder = JSONDecoder()
                if let loadedPerson = try? decoder.decode(Array<DeviceCellModel>.self, from: savedPerson) {
                    return loadedPerson
                }
            }

            return Array<DeviceCellModel>()
        }

        self.devices = load()
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
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(devices) {
            let defaults = UserDefaults.standard
            defaults.set(encoded, forKey: FavoritesStore.devicesStoreKey)
        }
    }
}
