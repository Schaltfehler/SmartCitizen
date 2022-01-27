import SwiftUI

public struct SearchView: View {

    public init() { }

    @State
    var search: String = ""

    @EnvironmentObject
    var fetcher: SearchFetcher

    fileprivate func cell(for globalResult: GlobalSearch) -> some View {
        if case let GlobalSearch.device(device) = globalResult {
            return NavigationLink(
                destination: DeviceFetchingView(deviceId: device.id)) {
                SearchResultView(result: globalResult)
            }
            .eraseToAnyView()
        } else {
            return SearchResultView(result: globalResult)
                .eraseToAnyView()
        }
    }

    var serachFetchingView: AnyView {
        switch fetcher.state {
        case .fetching:
            return VStack {
                Spacer()
                Text("Loading...")
                    .font(.title)
                Spacer()
            }
            .eraseToAnyView()

        case .fetched(let result):
            switch result {
            case .success(let globalResults):
                return List {
                    ForEach(globalResults, id: \.self) { globalResult in
                        self.cell(for: globalResult)
                    }
                }
                .eraseToAnyView()

            case .failure(let error):
                return VStack {
                    Spacer()
                    Text(error.localizedDescription)
                        .font(.title)
                    Spacer()
                }
                .eraseToAnyView()

            }
        case .empty:
            return VStack {
                Spacer()
                Text("Search for devices")
                    .font(.title)
                Spacer()
            }
            .eraseToAnyView()
        }
    }

    public var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 0) {
                HStack {
                    Image(systemName: "magnifyingglass")
                        .padding(.leading, CGFloat(10.0))
                        .padding(.trailing, CGFloat(5.0))

                    TextField("Search", text: $search,
                              onCommit: {
                                self.fetcher.fetch(searchTerm: self.search)
                              })
                        .padding(.vertical, CGFloat(4.0))
                        .padding(.trailing, CGFloat(10.0))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(Color.secondary, lineWidth: 1.0)
                )
                .padding()
                Spacer()
                serachFetchingView
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
        return SearchView()
            .environmentObject(SearchFetcher.mocked())
    }
}

#endif
