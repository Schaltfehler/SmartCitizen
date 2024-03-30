import SwiftUI
import Models

struct DeviceCell: View {
    let model: DevicePreviewModel

    var body: some View {
        VStack {
            HStack {
                Text(model.name)
                    .font(.headline)
                Spacer()
            }
            Spacer(minLength: 5)
            HStack {
                if let userName = model.userName {
                    Text("Owner: " + userName)
                    Spacer()
                } else if let tags = model.tags {
                    Text("Tags: " + tags)
                    Spacer()
                }
                
                if let cityName = model.cityName {
                    Text("City: " + cityName)
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
        let model = DevicePreviewModel(id: 1, name: "SMC Hackathon", cityName: "Fukuoka", userName: "Freddy", tags: "outside")
        return List {
            DeviceCell(model: model)
            DeviceCell(model: model)
            DeviceCell(model: model)
        }
    }
}
#endif
