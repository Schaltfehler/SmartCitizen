//
//  ContentView.swift
//  SmartCitizenClip
//
//

import SwiftUI

import Views
import Models
import Network
import Domain

struct ContentView: View {
    @EnvironmentObject
    var device: SmartCitizenDeviceClip

    @EnvironmentObject
    var deviceFetcher: DeviceFetcher

    @EnvironmentObject
    var favoritesStore: FavoritesStore

    var body: some View {
        NavigationView {
            if let deviceID = device.id {
                DeviceFetchingView(.init(deviceID: deviceID,
                                         fetcher: deviceFetcher,
                                         store: favoritesStore))
            } else {
                EmptyView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(SmartCitizenDeviceClip(id: 1234))
    }
}
