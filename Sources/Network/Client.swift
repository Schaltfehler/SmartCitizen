import Foundation
import Combine

public typealias RequestToPublisher = (URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error>

public struct Client {
    let networking: RequestToPublisher
    let decoder: JSONDecoder
    let baseURL: URL

    public init(networking: @escaping RequestToPublisher = URLSession.shared.erasedDataTaskPublisher,
         baseURL: URL = URL(string: "https://api.smartcitizen.me")!,
         decoder: JSONDecoder = Client.jsonDecoder()) {
        self.networking = networking
        self.decoder = decoder
        self.baseURL = baseURL
    }

    public func publisher<T: Decodable>(for request: APIRequest<T>) -> AnyPublisher<T, Error> {
        let urlRequest = URLRequest(request, withBaseURL: baseURL)
        print(urlRequest.url ?? "NIL")
        return networking(urlRequest)
            .map { $0.data }
            .decode(type: T.self, decoder: decoder)
            .eraseToAnyPublisher()
    }

    public func publisherWithPagination<T: Decodable>(for request: APIRequest<Array<T>>,
                                          startPage: Int = 1,
                                          pageSize: Int = 25) -> AnyPublisher<[T], Error> {

        precondition(startPage > 0, "page must be larger than 0")
        precondition(pageSize > 0, "pageSize should be larger than 0")

        let pageIndexPublisher = CurrentValueSubject<Int, Error>(startPage)

        return pageIndexPublisher
            .flatMap{ (page: Int) -> AnyPublisher<(Int, Array<T>), Error> in

                let paginatedRequest = request.paginated(page: page, perPage: pageSize)

                return self.publisher(for: paginatedRequest)
                    .map{ (index: page, response: $0) }
                    .eraseToAnyPublisher()
            }
            .handleEvents(receiveOutput: { (index: Int, response: Array<T>) in
                if response.count == pageSize {
                    pageIndexPublisher.send(index + 1)
                } else {
                    pageIndexPublisher.send(completion: .finished)
                }
            })
            .map { $0.1 } // Pass forward only Array<T> because index is not needed anymore
            .reduce([T](), { allItems, items in
                allItems + items
            })
            .eraseToAnyPublisher()
    }
}

extension URLSession {
    public func erasedDataTaskPublisher(for request: URLRequest) -> AnyPublisher<(data: Data, response: URLResponse), Error> {
        dataTaskPublisher(for: request)
            .mapError { $0 } // map URLError -> Error
            .eraseToAnyPublisher()
    }
}
