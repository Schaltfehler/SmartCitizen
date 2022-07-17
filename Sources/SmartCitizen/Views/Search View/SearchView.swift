import SwiftUI

public struct SearchView: View {

    @EnvironmentObject
    var store: FavoritesStore

    @EnvironmentObject
    var deviceFetcher: DeviceFetcher

    @ObservedObject
    var viewModel: SearchViewModel

    public init(_ viewModel: SearchViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, CGFloat(10.0))
                        .padding(.trailing, CGFloat(5.0))

                    TextField("Search",
                              text: $viewModel.search,
                              onCommit: viewModel.textinputHasChanged)
                        .padding(.vertical, CGFloat(4.0))
                        .padding(.trailing, CGFloat(10.0))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(Color.secondary, lineWidth: 1.0)
                )
                .padding()
                Spacer()
                switch viewModel.fetchingState {
                case let .displayText(text):
                    VStack {
                        Spacer()
                        Text(text)
                            .font(.title)
                        Spacer()
                    }
                case let .result(globalResults):
                    List {
                        ForEach(globalResults, id: \.self) { globalResult in
                            if case let GlobalSearch.device(device) = globalResult {
                                NavigationLink(
                                    destination: DeviceFetchingView(.init(deviceID: device.id,
                                                                          fetcher: DeviceFetcher(client:Client()),
                                                                          store: store))
                                ) {
                                    SearchResultView(result: globalResult)
                                }
                            } else {
                                SearchResultView(result: globalResult)
                            }
                        }
                    }
                }
            }
            .navigationBarTitle("Search for devices", displayMode: .inline)
        }
    }

    private func title(for value: String?) -> String {
        guard let value = value, value.count > 0 else {
            return "No search"
        }

        return #"Searching for "\#(value)""#
    }
}

#if DEBUG

struct SearchView_Previews: PreviewProvider {
    static var previews: some View {
        SearchView(.init(fetcher: .mocked()))
    }
}

#endif
