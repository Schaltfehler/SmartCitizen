import SwiftUI
import Combine

public struct DeviceFetchingView: View {
    @EnvironmentObject
    var store: SettingsStore

    @ObservedObject
    var viewModel: DeviceFetchingViewModel

    public init( _ viewModel: DeviceFetchingViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        switch viewModel.fetchingState {
        case .empty:
            Text("")
                .font(.title)
                .onAppear {
                    viewModel.viewAppeared()
                }
        case let .fetching(text), let .failed(text):
            Text(text)
                .font(.title)
                .onAppear {
                    viewModel.viewAppeared()
                }
        case let .fetched(fetched):
            let _ = Self._printChanges()
            DeviceView(device: .init(device: fetched.device,
                                     measurements: fetched.measurements,
                                     store: store))
            .navigationBarTitle(Text(fetched.device.name),
                                displayMode: .inline)
            .navigationBarItems(trailing: Button(action: viewModel.tappedFavoriteButton) {
                viewModel.isFavorite
                ? Image(systemName: "heart.fill")
                : Image(systemName: "heart")
            })
            .background(Color(.lightGray))
            .refreshable {
                viewModel.pulledRefresh()
            }
        }

    }
}

#if DEBUG
extension DeviceFetchingViewModel {
    static func mocked() -> DeviceFetchingViewModel {
        let data = PreviewData.loadTestData(withFileName: "DeviceResponse")
        let apiClient = Client.mocked(width: data)
        let deviceFetcher = DeviceFetcher(client: apiClient)
        let storedDevice = [DeviceCellModel]()

        return DeviceFetchingViewModel(deviceID: 1,
                                       fetcher: deviceFetcher,
                                       store: .mocked(storedDevice))
    }
}

struct DeviceFetchingView_Previews: PreviewProvider {
    static var previews: some View {
        DeviceFetchingView(.mocked())
    }
}
#endif
