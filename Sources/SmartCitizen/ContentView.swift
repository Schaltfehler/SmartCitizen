import SwiftUI
import Combine
import MapKit

final public class SensorGraphXLabelCache: ObservableObject {
    public init(){}
    var cache = [String : CGFloat]()
}

public struct ContentView: View {
    
    @EnvironmentObject
    var fetcher: DeviceFetcher

    var barcelona = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.385064, longitude: 2.173403),
                                     span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))

    @EnvironmentObject
    var worldMapFetcher: WorldMapFetcher

    public init() {}

    public var body: some View {
        TabView {
            FavoritesView()
                .tabItem {
                    Image(systemName: "heart")
                    Text("Favorite Devices")
                }

            MapFetchView(region: barcelona)
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
        .onAppear {
            worldMapFetcher.fetchIfNeeded()
        }
    }
}

#if DEBUG

struct ContentView_Previews: PreviewProvider {

    static var previews: some View {
        return ContentView()
            .environmentObject(DeviceFetcher.mocked())
            .environmentObject(SearchFetcher.mocked())
            .environmentObject(WorldMapFetcher(client: Client()))
            .environmentObject(FavoritesStore())
            .environmentObject(SensorGraphXLabelCache())
    }
}

#endif
