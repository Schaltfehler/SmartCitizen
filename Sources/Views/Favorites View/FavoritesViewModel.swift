import Foundation
import Models
import Domain

public final class FavoritesViewModel: ObservableObject {
    let title: String

    @Published
    var storedDevices = [DevicePreviewModel]()

    @Published
    var store: FavoritesStore

    public init(title: String, store: FavoritesStore) {
        self.title = title
        self.store = store

        store.$devices.assign(to: &$storedDevices)
    }
}
