import Foundation
import SwiftUI

public final class SettingsStore: ObservableObject {
    public init() {}
    
    @AppStorage("shouldShowAqi")
    public var shouldShowAqi: Bool = true {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowThi")
    public var shouldShowThi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowTdi")
    public var shouldShowTdi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowKdi")
    public var shouldShowKdi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowHumidex")
    public var shouldShowHumidex: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
}
