import MapKit

public extension MKCoordinateRegion {
    static let barcelona = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 41.385064, longitude: 2.173403),
                                              span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
    static var fukuoka = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 33.590355, longitude: 130.401716),
                                            span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5))
}
