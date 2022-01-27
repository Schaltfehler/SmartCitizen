import SwiftUI

struct SearchResultView: View {
    let result: GlobalSearch

    var searchResult: AnyView {
        switch result {
        case .user(let user):
            return HStack {
                Text("User: ")
                Text(user.username)
            }
            .eraseToAnyView()

        case .device(let device):
            let model = DeviceCellModel(id: device.id,
                                        name: device.name ?? "?",
                                        cityName: device.city ?? "?",
                                        userName: device.ownerUsername ?? "?")
            return DeviceCell(model: model)
                .eraseToAnyView()

        case .city(let city):
            return HStack {
                Text("City: ")
                Text(city.city ?? "No Name")
            }
            .eraseToAnyView()
        case .tag(let tag):
            return HStack {
                Text("Tag: ")
                Text(tag.name)
            }
            .eraseToAnyView()
        case .unknown(let unknown):
            return HStack {
                Text(unknown)
            }
            .eraseToAnyView()
        }
    }

    var body: some View {
        searchResult
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
