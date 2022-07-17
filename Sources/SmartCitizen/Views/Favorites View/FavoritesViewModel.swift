import Foundation

public class FavoritesViewModel: ObservableObject {
    let title: String

    @Published
    var storedDevices = [DeviceCellModel]()

    @Published
    var store: FavoritesStore

    public init(title: String, store: FavoritesStore) {
        self.title = title
        self.store = store

        store.$devices.assign(to: &$storedDevices)
    }
}
