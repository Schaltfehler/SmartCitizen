import Foundation

public enum HTTPMethod: String {
    case get    = "GET"
    case post   = "POST"
    case put    = "PUT"
    case delete = "DELETE"
    case patch  = "PATCH"
}

public struct APIRequest<RepsonseValue: Decodable> {
    public let method: HTTPMethod
    public let path: String

    public let queryParameter: [URLQueryItem]?
    public let headers: [String: String]?
    public let body: Data?

    init (
        method: HTTPMethod,
        path: String,
        queryParameter: [URLQueryItem]? = nil,
        headers: [String: String]? = nil,
        body: Data? = nil
        ) {
        self.path = path
        self.method = method
        self.queryParameter = queryParameter
        self.headers = headers
        self.body = body
    }
}

extension APIRequest {
    func url(withBase baseURL: URL) -> URL {
        var urlComponents    = URLComponents()
        urlComponents.scheme = baseURL.scheme
        urlComponents.host   = baseURL.host
        urlComponents.path   = baseURL.path + path
        urlComponents.queryItems = queryParameter

        guard let requestURL = urlComponents.url
            // If this happens, it is a programmer error. The path was wrongly constructed.
            else { fatalError("Combination of authority components and path components are wrong.") }

        return requestURL
    }
}

extension APIRequest where RepsonseValue: Collection {
    /// Every APIRequest which expects an array as a returned value can be paginated
    func paginated(page: Int, pageKey: String = "page", perPage: Int, perPageKey: String = "per_page") -> Self {

        var queryItems = self.queryParameter ?? [URLQueryItem]()

        // In case the query already contains parameter for paging, override them.
        queryItems.removeAll(where: { $0.name == pageKey || $0.name == perPageKey})
        let pagingItems = [
            URLQueryItem(name: pageKey, value: String(page)),
            URLQueryItem(name: perPageKey, value: String(perPage))
        ]
        let pagingQueryItems = queryItems + pagingItems

        let paginatedRequest = APIRequest(method: self.method,
                                          path: self.path,
                                          queryParameter: pagingQueryItems,
                                          headers: self.headers,
                                          body: self.body)

        return paginatedRequest
    }
}

extension URLRequest {
    init<RepsonseValue: Decodable>(_ request: APIRequest<RepsonseValue>,
         withBaseURL baseURL: URL,
         cachePolicy: URLRequest.CachePolicy = .useProtocolCachePolicy,
         timeoutInterval: TimeInterval = 10.0) {

        self = URLRequest(url: request.url(withBase: baseURL),
                          cachePolicy: cachePolicy,
                          timeoutInterval: timeoutInterval)
        self.httpMethod           = request.method.rawValue
        self.httpBody             = request.body
        self.allHTTPHeaderFields  = request.headers
    }
}
