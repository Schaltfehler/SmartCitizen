import Foundation
import SwiftUI

public struct FavoritesView: View {
    public init() { }

    @EnvironmentObject
    var store: FavoritesStore

    public var body: some View {
        NavigationView {
            DeviceListView(models: store.devices, title: "Favorite devices")
        }
    }
}

public struct DeviceListView: View {

    var models: [DeviceCellModel]
    let title: String

    public var body: some View {
        List {
            ForEach(models) { deviceModel in
                NavigationLink(destination: DeviceFetchingView(deviceId: deviceModel.id)) {
                    DeviceCell(model: deviceModel)
                }
            }
        }
        .navigationBarTitle(title, displayMode: .inline)
    }
}

#if DEBUG
struct FavoritesView_Previews: PreviewProvider {

    static var previews: some View {
        let models = [
            DeviceCellModel(id: 1, name: "Ludwig", cityName: "Fukuoka", userName: "Paul"),
            DeviceCellModel(id: 2, name: "Hackathon", cityName: "Fukuoka", userName: "Freddy"),
            DeviceCellModel(id: 3, name: "Muller", userName: "Hugo"),
        ]
        return NavigationView {
            DeviceListView(models: models, title: "My List")
        }
    }
}
#endif
