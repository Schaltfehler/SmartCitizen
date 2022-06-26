import SwiftUI

public struct DeviceFetchingView: View {

    public init(deviceId: Int, client: Client = Client()) {
        self.deviceId = deviceId
        fetcher = DeviceFetcher(client: client)
    }

    let deviceId: Int

    @ObservedObject
    var fetcher: DeviceFetcher

    @EnvironmentObject
    var store: FavoritesStore

    @State
    var device: DeviceViewModel?

    public var body: some View {
        if let device = self.device {
            DeviceView(device: device)
                .navigationBarTitle(Text(device.name),
                                    displayMode: .inline)
                .navigationBarItems(trailing: navigationBarButtons(for: device))
                .background(Color(.lightGray))
                .refreshable {
                    fetcher.fetch(deviceID: deviceId)
                }
                .onReceive(fetcher.$state) { state in
                    update(for: state)
                }
        } else {
            Text(fetcher.state.displayText)
                .font(.title)
                .onAppear {
                    fetcher.fetchIfNeeded(deviceID: deviceId)
                }
                .onReceive(fetcher.$state) { state in
                    update(for: state)
                }
        }
    }

    @ViewBuilder
    func navigationBarButtons(for device: DeviceViewModel) -> some View {
        HStack {
            if containsModel(withId: device.id) {
                Button(action: {
                    self.store.remove(withId: device.id)
                }) {
                    Image(systemName: "heart.fill")
                }
            } else {
                Button(action: {
                    let deviceModel = DeviceCellModel(id: device.id,
                                                      name: device.name,
                                                      cityName: device.cityName,
                                                      userName: device.ownerName)
                    self.store.append(deviceModel)
                }) {
                    Image(systemName: "heart")
                }
            }
        }
    }

    func containsModel(withId id: Int) -> Bool {
        store.devices.contains{ $0.id == id }
    }

    func update(for state: DeviceFetchState) {
        switch state {
        case .empty, .fetching:
            break
        case let .fetched(device):
            self.device = device
        case .failed:
            self.device = nil
        }
    }
}

#if DEBUG
struct DeviceFetchingView_Previews: PreviewProvider {
    static var previews: some View {
        let data = PreviewData.loadTestData(withFileName: "DeviceResponse")
        let apiClient = Client.mocked(width: data)
        let deviceFetcher = DeviceFetcher(client: apiClient)
        deviceFetcher.fetch(deviceID: 1)
        return DeviceFetchingView.init(deviceId: 1, client: apiClient)
    }
}
#endif
