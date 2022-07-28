//
//  SmartCitizenClip.swift
//  SmartCitizenClip
//
//

import SwiftUI
import Network
import Domain

class SmartCitizenDeviceClip: ObservableObject {
    @Published
    var id: Int?

    init(id: Int? = nil) {
        self.id = id
    }
}

@main
struct SmartCitizenClip: App {
    let favoriteStore = FavoritesStore.default
    let deviceFetcher = DeviceFetcher(client: Client())
    let settingsStore = SettingsStore()
    let graphCache = SensorGraphXLabelCache()

    @StateObject
    var device = SmartCitizenDeviceClip()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .onContinueUserActivity(NSUserActivityTypeBrowsingWeb,
                                        perform: onContinueUserActivity)
                .environmentObject(favoriteStore)
                .environmentObject(deviceFetcher)
                .environmentObject(settingsStore)
                .environmentObject(graphCache)
                .environmentObject(device)

        }
    }

    func onContinueUserActivity(_ userActivity: NSUserActivity) {
        guard
            let webpageURL = userActivity.webpageURL,
            let queryItems = URLComponents(url: webpageURL, resolvingAgainstBaseURL: true)?.queryItems,
            let itemValue = queryItems.first(where: { $0.name == "deviceID" })?.value,
            let deviceID = Int(itemValue)
        else {
            return
        }

        device.id = deviceID
    }
}
