import Foundation
import SwiftUI


public struct SettingsView: View {
    @EnvironmentObject
    var store: SettingsStore

    public var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Device Settings")) {

                    HStack {
                        Toggle(isOn: $store.shouldShowAqi,
                               label: {
                                Text("Show AQI")
                               })
                    }

                    HStack {
                        Toggle(isOn: $store.shouldShowThi,
                               label: {
                                Text("Show THI")
                               })
                    }

                    HStack {
                        Toggle(isOn: $store.shouldShowTdi,
                               label: {
                                Text("Show TDI")
                               })
                    }

                    HStack {
                        Toggle(isOn: $store.shouldShowKdi,
                               label: {
                                Text("Show KDI")
                               })
                    }

                    HStack {
                        Toggle(isOn: $store.shouldShowHumidex,
                               label: {
                                Text("Show Humidex")
                               })
                    }
                }
            }
            .navigationBarTitle("Settings", displayMode: .inline)
        }
    }
}

#if DEBUG
struct SettingsView_Previews: PreviewProvider {

    static var previews: some View {
        SettingsView()
    }
}
#endif
