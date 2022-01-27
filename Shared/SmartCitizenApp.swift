import SwiftUI

@main
struct SmartCitizenApp: App {
    
    let deviceFetcher = DeviceFetcher(client: Client())
    let searchFetcher = SearchFetcher(client: Client())
    let mapFetcher = WorldMapFetcher(client: Client())
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(deviceFetcher)
                .environmentObject(searchFetcher)
                .environmentObject(mapFetcher)
                .environmentObject(FavoritesStore())
                .environmentObject(SettingsStore())
                .environmentObject(SensorGraphXLabelCache())
        }
    }
}

final public class SensorGraphXLabelCache: ObservableObject {
    var cache = [String : CGFloat]()
}
