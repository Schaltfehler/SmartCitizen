import Foundation

extension Comparable {
    func clamped(to limits: ClosedRange<Self>) -> Self {
        return min(max(self, limits.lowerBound), limits.upperBound)
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
