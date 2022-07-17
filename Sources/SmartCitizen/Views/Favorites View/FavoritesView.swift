import Foundation
import SwiftUI

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
    let devices: [DeviceCellModel]

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
            DeviceCellModel(id: 1, name: "Ludwig", cityName: "Fukuoka", userName: "Paul"),
            DeviceCellModel(id: 2, name: "Hackathon", cityName: "Fukuoka", userName: "Freddy"),
            DeviceCellModel(id: 3, name: "Muller", userName: "Hugo"),
        ]
        return NavigationView {
            DeviceListView(title: "My List", devices: devices)
        }
    }
}
#endif
