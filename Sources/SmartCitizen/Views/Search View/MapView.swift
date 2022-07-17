import SwiftUI
import MapKit

public struct MapView: View {
    @EnvironmentObject
    var deviceFetcher: DeviceFetcher

    @EnvironmentObject
    var store: FavoritesStore

    @ObservedObject
    var viewModel: MapViewModel

    public init(_ viewModel: MapViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        
        NavigationView {
            ZStack(alignment: .topLeading) {
                NavigationLink(
                    destination: DeviceFetchingView(
                        DeviceFetchingViewModel(
                            deviceID: viewModel.selectedDeviceId,
                            fetcher: deviceFetcher,
                            store: store
                        )
                    ),
                    tag: 1,
                    selection: $viewModel.actionState) {
                        EmptyView()
                    }
                NavigationLink(
                    destination: DeviceListView(title: "Devices",
                                                devices: viewModel.selectedDevices),
                    tag: 2,
                    selection: $viewModel.actionState) {
                        EmptyView()
                    }

                ActivityCapsule(state: $viewModel.activityState) {
                    viewModel.tappedRefreshButton()
                }
                .zIndex(1)
                .offset(x: 10, y: 0)

                SCKMapView(startRegion: viewModel.region,
                           annotations: $viewModel.annotations,
                           selectedAnnotations: $viewModel.selectedAnnotations,
                           tappedDetailsForAnnotation: $viewModel.tappedDetailsForAnnotation
                )
                .edgesIgnoringSafeArea(.top)
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            viewModel.viewAppeared()
        }
    }
}

#if DEBUG
struct MapView_Previews: PreviewProvider {
    static let deviceFetcher = DeviceFetcher.mocked()
    static let favoritesStore = FavoritesStore.default
    static var previews: some View {
        MapView(.init(region: .fukuoka, fetcher: .mocked()))
        .environmentObject(deviceFetcher)
        .environmentObject(favoritesStore)
    }

}
#endif
