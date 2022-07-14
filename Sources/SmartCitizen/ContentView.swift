import SwiftUI
import Combine
import MapKit

final public class SensorGraphXLabelCache: ObservableObject {
    public init(){}
    var cache = [String : CGFloat]()
}

public struct ContentView: View {
    let mapViewModel: MapViewModel
    public init(mapViewModel: MapViewModel) {
        self.mapViewModel = mapViewModel
    }

    public var body: some View {
        TabView {
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorite Devices")
                }

            MapView(mapViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }

            SearchView()
                .tabItem {
                    Image(systemName: "magnifyingglass")
                    Text("Search Devices")
                }
        }
    }
}

#if DEBUG

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        ContentView(mapViewModel: .init(region: .init(), fetcher: .mocked()))
            .environmentObject(DeviceFetcher.mocked())
            .environmentObject(SearchFetcher.mocked())
            .environmentObject(FavoritesStore())
            .environmentObject(SensorGraphXLabelCache())
    }
}

#endif
