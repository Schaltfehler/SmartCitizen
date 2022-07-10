import SwiftUI
import MapKit

public struct MapView: View {

    @ObservedObject
    var viewModel: MapViewModel

    public init(_ viewModel: MapViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                NavigationLink(
                    destination: DeviceFetchingView(deviceId: viewModel.selectedDeviceId),
                    tag: 1,
                    selection: $viewModel.actionState) {
                        EmptyView()
                    }
                NavigationLink(
                    destination: DeviceListView(models: viewModel.selectedDevices, title: "Devices"),
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
    static var previews: some View {
        MapView(.init(region: .fukuoka, fetcher: WorldMapFetcher.mocked() ))
    }
}
#endif
