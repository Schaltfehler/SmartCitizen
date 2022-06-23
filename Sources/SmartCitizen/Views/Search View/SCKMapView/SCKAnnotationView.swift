import Foundation
import MapKit

extension UIColor {
    static let sckYellow = UIColor(red: 255/255, green: 193/255, blue: 0/255, alpha: 255/255)
    static let sckBlue = UIColor(red: 33/255, green: 150/255, blue: 243/255, alpha: 255/255)
}

class SCKAnnotationView: MKMarkerAnnotationView {

        static let reuseIdentifier = "smartCitizenKitAnnotationIdentifier"

        override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
            super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)

            clusteringIdentifier = "smartCitizenKit"
            centerOffset = CGPoint(x: 0, y: 10)
            canShowCallout = true

            rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
        }

        required init?(coder aDecoder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }

        override func prepareForDisplay() {
            super.prepareForDisplay()

            markerTintColor = UIColor.sckYellow
            glyphImage = UIImage(named: "sck_Icon2")
        }
}
