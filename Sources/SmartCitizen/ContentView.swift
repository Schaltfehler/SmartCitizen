import SwiftUI
import Combine
import MapKit

final public class SensorGraphXLabelCache: ObservableObject {
    public init(){}
    var cache = [String : CGFloat]()
}

public class AppState: ObservableObject {
    let favoritesViewModel: FavoritesViewModel
    let mapViewModel: MapViewModel
    let searchViewModel: SearchViewModel

    public init(favoritesViewModel: FavoritesViewModel,
                mapViewModel: MapViewModel,
                searchViewModel: SearchViewModel) {
        self.favoritesViewModel = favoritesViewModel
        self.mapViewModel = mapViewModel
        self.searchViewModel = searchViewModel
    }

}

public struct AppView: View {

    @EnvironmentObject
    var appState: AppState

    public init() {}

    public var body: some View {
        TabView {
            FavoritesView(appState.favoritesViewModel)
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorite Devices")
                }

            MapView(appState.mapViewModel)
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }

            SearchView(appState.searchViewModel)
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
        AppView()
            .environmentObject(AppState(
                favoritesViewModel: .init(title: "Favorites", store: .mocked([DeviceCellModel]())),
                mapViewModel: .init(region: .barcelona, fetcher: .mocked()),
                searchViewModel: .init(fetcher: .mocked())
            ))
    }
}

#endif
