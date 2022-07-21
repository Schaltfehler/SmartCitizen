import SwiftUI
import Models

struct SearchResultView: View {
    let result: GlobalSearch

    var body: some View {
        switch result {
        case .user(let user):
            HStack {
                Text("User: ")
                Text(user.username)
            }

        case .device(let device):
            let model = DevicePreviewModel(id: device.id,
                                        name: device.name ?? "?",
                                        cityName: device.city ?? "?",
                                        userName: device.ownerUsername ?? "?")
            DeviceCell(model: model)

        case .city(let city):
            HStack {
                Text("City: ")
                Text(city.city ?? "No Name")
            }

        case .tag(let tag):
            HStack {
                Text("Tag: ")
                Text(tag.name)
            }
        case .unknown(let unknown):
            HStack {
                Text(unknown)
            }
        }
    }
}

#if DEBUG

struct SearchResultView_Previews: PreviewProvider {
    static var previews: some View {
        let device = GlobalSearch.Device(id: 1, type: "", name: "MyDevice", description: nil, ownerId: 0, ownerUsername: "Freddy", city: "Fukuoka", url: URL(fileURLWithPath: ""), countryCode: "JP", country: "Japan")
        return List {
            SearchResultView(result: .device(device))
            SearchResultView(result: .device(device))
            SearchResultView(result: .device(device))
        }
    }
}

#endif
