import SwiftUI
import MapKit
import UIKit

struct SCKMapView: UIViewRepresentable {

    let annotations: [SCKAnnotation]
    var region: MKCoordinateRegion?

    @Binding
    var tappedDetailsForAnnotation: [SCKAnnotation]

    @Binding
    var selectedSCKAnnotations: [SCKAnnotation]

    init(region: MKCoordinateRegion? = nil,
         annotations: [SCKAnnotation] = [],
         selectedAnnotations: Binding<[SCKAnnotation]> = .constant([]),
         tappedDetailsForAnnotation: Binding<[SCKAnnotation]> = .constant([])){
        self.annotations = annotations
        self.region = region
        self._selectedSCKAnnotations = selectedAnnotations
        self._tappedDetailsForAnnotation = tappedDetailsForAnnotation
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(for: self)
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
        if let region = region {
            mapView.setRegion(region, animated: false)
        }

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: UIViewRepresentableContext<SCKMapView>) {
        let skAnnotations: [SCKAnnotation] = mapView.annotations.compactMap { $0 as? SCKAnnotation }
        let diff = annotations.difference(from: skAnnotations) { (annotationA, annotationB) in
            annotationA.deviceId == annotationB.deviceId
        }

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
        let mapView: SCKMapView

        init(for mapView: SCKMapView) {
            self.mapView = mapView
            super.init()
        }

        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
            self.mapView.selectedSCKAnnotations = mapView.selectedAnnotations.compactMap { $0 as? SCKAnnotation }
        }

        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            self.mapView.selectedSCKAnnotations = mapView.selectedAnnotations.compactMap { $0 as? SCKAnnotation }
        }

        func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView,
                     calloutAccessoryControlTapped control: UIControl) {

            guard let annotation = view.annotation else { return }

            if let clusterAnnotation = annotation as? MKClusterAnnotation,
               let annotations = clusterAnnotation.memberAnnotations as? [SCKAnnotation] {
                self.mapView.tappedDetailsForAnnotation = annotations
            } else if let annotation = annotation as? SCKAnnotation {
                self.mapView.tappedDetailsForAnnotation = [annotation]
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


struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        SCKMapView()
    }
}

