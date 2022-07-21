import Foundation
import SwiftUI
import Models
import Domain

public struct FavoritesView: View {
    @ObservedObject
    var viewModel: FavoritesViewModel

    public init(_ viewModel: FavoritesViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            DeviceListView(
                title: "Favorite devices",
                devices: viewModel.storedDevices
            )
        }
    }
}

public struct DeviceListView: View {
    @EnvironmentObject
    var deviceFetcher: DeviceFetcher

    @EnvironmentObject
    var favoritesStore: FavoritesStore

    let title: String
    let devices: [DevicePreviewModel]

    public var body: some View {
        List {
            ForEach(devices) { device in
                NavigationLink(destination: DeviceFetchingView.init(.init(deviceID: device.id,
                                                                          fetcher: deviceFetcher,
                                                                          store: favoritesStore))) {
                    DeviceCell(model: device)
                }
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}

#if DEBUG

struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        let devices = [
            DevicePreviewModel(id: 1, name: "Ludwig", cityName: "Fukuoka", userName: "Paul"),
            DevicePreviewModel(id: 2, name: "Hackathon", cityName: "Fukuoka", userName: "Freddy"),
            DevicePreviewModel(id: 3, name: "Muller", userName: "Hugo"),
        ]
        return NavigationView {
            DeviceListView(title: "My List", devices: devices)
        }
    }
}
#endif
