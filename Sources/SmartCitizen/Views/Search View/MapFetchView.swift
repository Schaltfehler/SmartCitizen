import SwiftUI
import MapKit


public struct MapFetchView: View {
    var region: MKCoordinateRegion

    @State
    var selectedAnnotations: [SCKAnnotation] = []

    @EnvironmentObject
    var fetcher: WorldMapFetcher

    @State
    var selectedDeviceId: Int = 0

    @State
    var selectedDevices: [DeviceCellModel] = []

    @State
    var actionState: Int? = nil

    @State
    var tappedDetailsForAnnotation: [SCKAnnotation] = []

    @State
    var activityState: ActivityCapsule.State = .none

    @State
    var annotations: [SCKAnnotation] = []

    public init(region: MKCoordinateRegion) {
        self.region = region
    }

    public var body: some View {
        NavigationView {
            ZStack(alignment: .topLeading) {
                NavigationLink(
                    destination: DeviceFetchingView(deviceId: self.selectedDeviceId),
                    tag: 1,
                    selection: $actionState) {
                    EmptyView()
                }
                NavigationLink(
                    destination: DeviceListView(models: selectedDevices, title: "Devices"),
                    tag: 2,
                    selection: $actionState) {
                    EmptyView()
                }

                ActivityCapsule(state: $activityState) {
                    fetcher.fetch()
                }
                .zIndex(1)
                .offset(x: 10, y: 0)

                SCKMapView(region: region,
                           annotations: annotations,
                           selectedAnnotations: $selectedAnnotations,
                           tappedDetailsForAnnotation: $tappedDetailsForAnnotation
                )
                .edgesIgnoringSafeArea(.top)
                .onAppear {
                    tappedDetailsForAnnotation = []
                }
                .onChange(of: self.tappedDetailsForAnnotation) { (annotations: [SCKAnnotation]) in
                    guard !annotations.isEmpty else {
                        selectedDeviceId = 0
                        selectedDevices = []
                        actionState = nil
                        return
                    }

                    if annotations.count == 1,
                       let annotation = annotations.first {
                        selectedDeviceId = annotation.deviceId
                        actionState = 1
                    } else {
                        selectedDevices = annotations.map { annotation in
                            DeviceCellModel(id: annotation.deviceId,
                                            name: annotation.title ?? "?",
                                            userName: annotation.subtitle ?? "?")
                        }
                        actionState = 2
                    }
                }

            }
            .onAppear {
                fetcher.fetchIfNeeded()
            }
            .onReceive(fetcher.$state) { (state: WorldMapFetcher.MapFetchState) in
                updateState(state)
            }
            .navigationBarHidden(true)
        }
    }

    func updateState(_ state: WorldMapFetcher.MapFetchState) {

        switch state {
        case .none:
            self.activityState = ActivityCapsule.State.none
        case .fetching:
            self.activityState = ActivityCapsule.State.active
        case .fetched(let results):
            self.activityState = ActivityCapsule.State.none

            self.annotations = results.compactMap{ (device: WorldMapDevice) -> SCKAnnotation? in
                guard let latitude = device.latitude,
                      let longitude = device.longitude
                else { return nil }

                return SCKAnnotation(deviceId: device.id,
                                     title: device.name ?? "?",
                                     subtitle: device.systemTags.joined(separator: ", "),
                                     coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                     type: .sck21)
            }
        case .failed(let error):
            self.activityState = ActivityCapsule.State.failed(error.localizedDescription)
        }
    }
}

struct SCKMapView_Previews: PreviewProvider {
    static var fukuoka = MKCoordinateRegion(center:
                                                CLLocationCoordinate2D(latitude: 33.590355, longitude: 130.401716),
                                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    static var previews: some View {
        MapFetchView(region: fukuoka)
    }
}
