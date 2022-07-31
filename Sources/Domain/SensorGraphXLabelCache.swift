//
//  SensorGraphXLabelCache.swift
//
//

import Foundation
import CoreGraphics

public final class SensorGraphXLabelCache: ObservableObject {
    public init(){}
    public var cache = [String : CGFloat]()
}
