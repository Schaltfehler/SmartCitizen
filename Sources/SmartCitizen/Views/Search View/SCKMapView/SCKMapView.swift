import SwiftUI
import MapKit
import UIKit
import Combine

struct SCKMapView: UIViewRepresentable {

    let startRegion: MKCoordinateRegion

    @Binding
    var annotations: [SCKAnnotation]

    @Binding
    var tappedDetailsForAnnotation: [SCKAnnotation]

    @Binding
    var selectedSCKAnnotations: [SCKAnnotation]

    init(startRegion: MKCoordinateRegion,
         annotations: Binding<[SCKAnnotation]>,
         selectedAnnotations: Binding<[SCKAnnotation]>,
         tappedDetailsForAnnotation: Binding<[SCKAnnotation]>){
        self.startRegion = startRegion
        self._annotations = annotations
        self._selectedSCKAnnotations = selectedAnnotations
        self._tappedDetailsForAnnotation = tappedDetailsForAnnotation
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(selectedAnnotations: $selectedSCKAnnotations,
                    tappedDetailsForAnnotation: $tappedDetailsForAnnotation)
    }

    func makeUIView(context: UIViewRepresentableContext<SCKMapView>) -> MKMapView {
        let mapView = MKMapView()

        mapView.isRotateEnabled = false
        mapView.delegate = context.coordinator

        mapView.register(SCKAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
        mapView.register(SCKClusterAnnotationView.self,
                         forAnnotationViewWithReuseIdentifier: MKMapViewDefaultClusterAnnotationViewReuseIdentifier)

        mapView.addAnnotations(annotations)
        mapView.showsUserLocation = false
        mapView.userTrackingMode = .none
        mapView.mapType = .mutedStandard
        mapView.setRegion(startRegion, animated: false)

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: UIViewRepresentableContext<SCKMapView>) {
        let currentAnnotations: [SCKAnnotation] = mapView.annotations
            .compactMap { $0 as? SCKAnnotation }
            .sorted { $0.deviceId < $1.deviceId }

        let newAnnotations = annotations.sorted { $0.deviceId < $1.deviceId }

        let diff = newAnnotations.difference(from: currentAnnotations)

        var inserts = [MKAnnotation]()
        var removals = [MKAnnotation]()
        diff.forEach { change in
            switch change {
            case .insert(offset: _, element: let element, associatedWith: _):
                inserts.append(element)
            case .remove(offset: _, element: let element, associatedWith: _):
                removals.append(element)
            }
        }

        mapView.removeAnnotations(removals)
        mapView.addAnnotations(inserts)
    }
}

extension SCKMapView {
    class Coordinator: NSObject, MKMapViewDelegate {

        @Binding
        var tappedDetailsForAnnotation: [SCKAnnotation]

        @Binding
        var selectedSCKAnnotations: [SCKAnnotation]

        init(selectedAnnotations: Binding<[SCKAnnotation]>,
             tappedDetailsForAnnotation: Binding<[SCKAnnotation]>
        ) {
            self._selectedSCKAnnotations = selectedAnnotations
            self._tappedDetailsForAnnotation = tappedDetailsForAnnotation

            super.init()
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            selectedSCKAnnotations = mapView.selectedAnnotations.compactMap { $0 as? SCKAnnotation }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            selectedSCKAnnotations = mapView.selectedAnnotations.compactMap { $0 as? SCKAnnotation }
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {

            guard let annotation = view.annotation else { return }

            if let clusterAnnotation = annotation as? MKClusterAnnotation,
               let annotations = clusterAnnotation.memberAnnotations as? [SCKAnnotation] {
                tappedDetailsForAnnotation = annotations
            } else if let annotation = annotation as? SCKAnnotation {
                tappedDetailsForAnnotation = [annotation]
            }
        }

        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard let annotation = annotation as? SCKAnnotation else { return nil }

            switch annotation.type {
            case .sck21:
                return SCKAnnotationView(annotation: annotation, reuseIdentifier: SCKAnnotationView.reuseIdentifier)
            }
        }
    }
}

struct SCKMapView_Previews: PreviewProvider {
    static var previews: some View {
        SCKMapView(startRegion: .init(center: .init(), span: .init()),
                   annotations: .constant([]),
                   selectedAnnotations: .constant([]),
                   tappedDetailsForAnnotation: .constant([])
        )
    }
}
