import Foundation
import MapKit

class SCKClusterAnnotationView: MKAnnotationView {
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        collisionMode = .circle
        rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForDisplay() {
        super.prepareForDisplay()

        guard
            let clusterAnnotation = annotation as? MKClusterAnnotation
        else { return }

        collisionMode = .circle

        let mapAnnotations = clusterAnnotation.memberAnnotations
        image = SCKClusterAnnotationView.drawNumber(mapAnnotations.count)
    }

    static func drawNumber(_ count: Int) -> UIImage {
        let imageSize = CGSize(width: 40, height: 40)
        let ringWidth: CGFloat = 3
        let renderer = UIGraphicsImageRenderer(size: imageSize)
        return renderer.image { (context: UIGraphicsImageRendererContext) in
            // Outer circle
            UIColor.sckYellow.setFill()
            UIBezierPath(ovalIn: .init(origin: .zero, size: imageSize)).fill()

            // Inner circle
            UIColor.white.setFill()
            UIBezierPath(ovalIn: CGRect(x: ringWidth, y: ringWidth,
                                        width: imageSize.width - 2 * ringWidth,
                                        height: imageSize.height - 2 * ringWidth)).fill()

            let attributes = [ NSAttributedString.Key.foregroundColor: UIColor.black,
                               NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
            let text = "\(count)"
            let size = text.size(withAttributes: attributes)
            let rect = CGRect(x: (imageSize.width - size.width) / 2,
                              y: (imageSize.height - size.height) / 2,
                              width: size.width,
                              height: size.height)
            text.draw(in: rect, withAttributes: attributes)
        }
    }

}
