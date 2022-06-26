import SwiftUI

public struct DeviceCellModel: Identifiable, Equatable, Codable {
    public var id: Int
    var name: String
    var cityName: String?
    var userName: String
}

struct DeviceCell: View {
    let model: DeviceCellModel

    var body: some View {
        VStack {
            HStack {
                Text(model.name)
                    .font(.headline)
                Spacer()
            }
            Spacer(minLength: 5)
            HStack {
                Text("Owner: ")
                Text(model.userName)
                Spacer()
                if let cityName = model.cityName {
                    Text("City: ")
                    Text(cityName)
                } else {
                    EmptyView()
                }
            }
        }
        .padding([.top, .bottom], 5)
    }
}

#if DEBUG
struct DeviceCell_Previews: PreviewProvider {
    static var previews: some View {
        let model = DeviceCellModel(id: 1, name: "SMC Hackathon", cityName: "Fukuoka", userName: "Freddy")
        return List {
            DeviceCell(model: model)
            DeviceCell(model: model)
            DeviceCell(model: model)
        }
    }
}
#endif
