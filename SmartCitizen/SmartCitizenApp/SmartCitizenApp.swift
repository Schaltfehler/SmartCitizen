import SwiftUI
import Views
import Domain
import Network

@main
struct SmartCitizenApp: App {
    let favoriteStore = FavoritesStore.default
    let deviceFetcher = DeviceFetcher(client: Client())
    let searchFetcher = SearchFetcher(client: Client())
    let mapFetcher = WorldMapFetcher(client: Client())
    let settingsStore = SettingsStore()

    var body: some Scene {
        WindowGroup {
            AppView()
                .environmentObject(favoriteStore)
                .environmentObject(deviceFetcher)
                .environmentObject(mapFetcher)
                .environmentObject(settingsStore)
                .environmentObject(AppState(
                    favoritesViewModel: .init(title: "Favorites", store: favoriteStore),
                    mapViewModel: .init(region: .barcelona, fetcher: mapFetcher),
                    searchViewModel: .init(fetcher: searchFetcher)
                ))
        }
    }
}
