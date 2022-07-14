import SwiftUI
import SmartCitizen

@main
struct SmartCitizenApp: App {
    let deviceFetcher = DeviceFetcher(client: Client())
    let searchFetcher = SearchFetcher(client: Client())
    let mapFetcher = WorldMapFetcher(client: Client())

    var body: some Scene {
        WindowGroup {
            ContentView(mapViewModel: MapViewModel(region: .barcelona, fetcher: mapFetcher))
                .environmentObject(deviceFetcher)
                .environmentObject(searchFetcher)
                .environmentObject(FavoritesStore())
                .environmentObject(SettingsStore())
                .environmentObject(SensorGraphXLabelCache())
        }
    }
}
