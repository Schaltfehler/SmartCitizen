import Foundation
import SwiftUI

extension Range where Bound == Double {
    func normalize(withScale scale: Double) -> [CGFloat] {
        guard lowerBound < upperBound
        else { return [CGFloat]() }

        let distance = upperBound - lowerBound
        let roundedLower = lowerBound.roundedUpToNearest(multipleOf: scale)
        let roundedUpper = upperBound.roundedDownToNearest(multipleOf: scale)

        let normalized = stride(from: roundedLower, through: roundedUpper, by: scale)
            .map { value -> CGFloat in
                let relativeDistance = value - lowerBound
                let normalized = relativeDistance / distance
                return CGFloat(normalized)
            }

        return normalized
    }
}

public extension View {
    func geometryReader(_ callback: @escaping (GeometryProxy) -> ()) -> some View {
        background(
            GeometryReader { proxy in
                Color.clear
                    .onAppear {
                        callback(proxy)
                    }
                    .id(1)
            }
        )
    }
}

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
    }
}

public extension Path {
    mutating func addQuadCurves(_ points: [CGPoint]) {
        guard points.isEmpty == false else { return }

        if let currentPoint = currentPoint {
            var lastPoint = currentPoint

            (0..<points.count).forEach { index in
                let nextPoint = points[index]

                let halfwayPoint = lastPoint.middlePoint(to: nextPoint)

                let firstControlPoint = halfwayPoint.quadCurveControlPoint(with: lastPoint)
                addQuadCurve(to: halfwayPoint, control: firstControlPoint)

                let secondControlPoint = halfwayPoint.quadCurveControlPoint(with: nextPoint)
                addQuadCurve(to: nextPoint, control: secondControlPoint)

                lastPoint = nextPoint
            }
        } else {
            var lastPoint = points[0]
            move(to: lastPoint)

            (1..<points.count).forEach { index in
                let nextPoint = points[index]

                let middlePoint = lastPoint.middlePoint(to: nextPoint)

                let firstControlPoint = middlePoint.quadCurveControlPoint(with: lastPoint)
                addQuadCurve(to: middlePoint, control: firstControlPoint)

                let secondControlPoint = middlePoint.quadCurveControlPoint(with: nextPoint)
                addQuadCurve(to: nextPoint, control: secondControlPoint)

                lastPoint = nextPoint
            }
        }
    }
}

public extension CGPoint {
    func middlePoint(to point: CGPoint) -> CGPoint {
        CGPoint(x: (x + point.x) * 0.5,
                y: (y + point.y) * 0.5)
    }

    static func *(left: CGPoint, right: CGFloat) -> CGPoint {
        multiply(point: left, with: right)
    }

    static func multiply(point: CGPoint, with multiplier: CGFloat) -> CGPoint {
        CGPoint(x: point.x * multiplier,
                y: point.y * multiplier)
    }

    func quadCurveControlPoint(with point: CGPoint) -> CGPoint {
        let middlePoint = middlePoint(to: point)
        let absoluteDistance = abs(point.y - middlePoint.y)

        if y < point.y {
            return CGPoint(x: middlePoint.x,
                           y: middlePoint.y + absoluteDistance)
        } else if y > point.y {
            return CGPoint(x: middlePoint.x,
                           y: middlePoint.y - absoluteDistance)
        } else {
            return middlePoint
        }
    }
}

extension Double {
    func roundedDownToNearest(multipleOf divisor: Double) -> Double {
        let quotient = self / divisor
        let decimalQuotient = quotient.rounded(.towardZero)

        return decimalQuotient * divisor
    }

    func roundedUpToNearest(multipleOf divisor: Double) -> Double {
        let quotient = self / divisor
        let decimalQuotient = quotient.rounded(.awayFromZero)

        return decimalQuotient * divisor
    }
}
