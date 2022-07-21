import Foundation
import MapKit
import Combine
import Models
import Domain

public final class MapViewModel: ObservableObject {
    let region: MKCoordinateRegion

    private let fetcher: WorldMapFetcher
    private var subscriptions = Set<AnyCancellable>()

    @Published
    private(set) var selectedDeviceId: Int = 0

    @Published
    private(set) var selectedDevices: [DevicePreviewModel] = []

    @Published
    var annotations: [SCKAnnotation] = []

    @Published
    var selectedAnnotations: [SCKAnnotation] = []

    @Published
    var tappedDetailsForAnnotation: [SCKAnnotation] = []

    @Published
    var actionState: Int? = nil

    @Published
    var activityState: ActivityCapsule.State = .none

    public init(region: MKCoordinateRegion, fetcher: WorldMapFetcher) {
        self.region = region
        self.fetcher = fetcher

        $tappedDetailsForAnnotation
            .sink { [weak self] annotation in
                self?.onTappedDetailsForAnnotation(annotation)
            }
            .store(in: &subscriptions)

        fetcher.$state
            .sink { [weak self] state in
                self?.onFetcherStateChange(state)
            }
            .store(in: &subscriptions)
    }

    private func onTappedDetailsForAnnotation(_ annotations: [SCKAnnotation]) {
        guard !annotations.isEmpty else {
            selectedDeviceId = 0
            selectedDevices = []
            actionState = nil
            return
        }

        if annotations.count == 1,
           let annotation = annotations.first {
            selectedDeviceId = annotation.deviceID
            actionState = 1
        } else {
            selectedDevices = annotations.map { annotation in
                DevicePreviewModel(id: annotation.deviceID,
                                name: annotation.title ?? "?",
                                userName: annotation.subtitle ?? "?")
            }
            actionState = 2
        }
    }

    private func onFetcherStateChange(_ state: WorldMapFetcher.MapFetchState) {
        switch state {
        case .none:
            self.activityState = ActivityCapsule.State.none
        case .fetching:
            self.activityState = ActivityCapsule.State.active
        case .fetched(let results):
            self.activityState = ActivityCapsule.State.none

            let annotations = results.compactMap{ (device: WorldMapDevice) -> SCKAnnotation? in
                guard let latitude = device.latitude,
                      let longitude = device.longitude
                else { return nil }

                return SCKAnnotation(deviceID: device.id,
                                     title: device.name ?? "?",
                                     subtitle: device.systemTags.joined(separator: ", "),
                                     coordinate: CLLocationCoordinate2D(latitude: latitude, longitude: longitude),
                                     type: .sck21)
            }

            if self.annotations.count != annotations.count {
                self.annotations = annotations
            }

        case .failed(let error):
            self.activityState = ActivityCapsule.State.failed(error.localizedDescription)
        }
    }

    func tappedRefreshButton() {
        fetcher.fetch()
    }

    func viewAppeared() {
        tappedDetailsForAnnotation = []
        fetcher.fetchIfNeeded()
    }
}
