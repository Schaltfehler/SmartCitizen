import Foundation
import MapKit


class SCKAnnotation: NSObject, MKAnnotation, Identifiable {
    enum SCKType {
        case sck21
    }

    init(deviceID: Int, title: String, subtitle: String, coordinate: CLLocationCoordinate2D, type: SCKType) {
        self.deviceID = deviceID
        self.title = title
        self.subtitle = subtitle
        self.coordinate = coordinate
        self.type = type

        super.init()
    }

    var deviceID: Int
    var title: String?
    var subtitle: String?
    var coordinate: CLLocationCoordinate2D
    var type: SCKType
}
