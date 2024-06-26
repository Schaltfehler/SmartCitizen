import Foundation
import SwiftUI
import Combine
import Models
import Domain

public final class DeviceFetchingViewModel: ObservableObject {
    private var fetchSubscription: AnyCancellable?

    @ObservedObject
    private var fetcher: DeviceFetcher

    let deviceID: Int
    let store: FavoritesStore

    @Published
    private(set) var isFavorite: Bool

    @Published
    private(set) var fetchingState: FetchingState

    enum FetchingState {
        case empty
        case fetching(String)
        case fetched(Device)
        case failed(String)
    }

    public init(deviceID: Int, fetcher: DeviceFetcher, store: FavoritesStore) {
        self.fetcher = fetcher
        self.deviceID = deviceID
        self.store = store
        self.isFavorite = store.devices.contains{ $0.id == deviceID }
        self.fetchingState = .empty
    }

    private func fetchDevice(with publisher: AnyPublisher<Device, Error>) {
        fetchSubscription = publisher
        .receive(on: DispatchQueue.main)
        .handleEvents(receiveSubscription: { [unowned self] _ in
            fetchingState = .fetching("Fetching...")
        })
        .map{ .fetched($0) }
        .catch{ Just(.failed("Error: \($0.localizedDescription)")) }
        .sink { [weak self] result in
            self?.fetchingState = result
        }
    }

    func pulledRefresh() {
        let publisher = fetcher.fetch(deviceID: deviceID)
        fetchDevice(with: publisher)
    }

    func viewAppeared() {
        let publisher = fetcher.fetchIfNeeded(deviceID: deviceID)
        fetchDevice(with: publisher)
    }

    func tappedFavoriteButton() {
        let isStored = store.devices.contains{ $0.id == deviceID }
        if isStored {
            store.remove(withId: deviceID)
            isFavorite = false
        } else if case let .fetched(device) = fetchingState {
            let deviceModel = DevicePreviewModel(id: device.id,
                                                 name: device.name,
                                                 cityName: device.location.city ?? "?",
                                                 userName: device.owner.username,
                                                 tags: device.systemTags.joined(separator: ", "))
            store.append(deviceModel)
            isFavorite = true
        }
    }
}
