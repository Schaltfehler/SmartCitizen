import Foundation
import SwiftUI

public class SettingsStore: ObservableObject {
    public init() {}
    
    @AppStorage("shouldShowAqi")
    var shouldShowAqi: Bool = true {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowThi")
    var shouldShowThi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowTdi")
    var shouldShowTdi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowKdi")
    var shouldShowKdi: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }

    @AppStorage("shouldShowHumidex")
    var shouldShowHumidex: Bool = false {
        willSet {
            objectWillChange.send()
        }
    }
}
