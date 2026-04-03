import Foundation

/// A declarative, type-safe networking client
///
/// ```swift
/// let client = NetworkClient(baseURL: URL(string: "https://api.example.com")!)
/// let response = try await client.request(GetUser(userId: "1"), as: User.self)
/// ```
public struct NetworkClient: Sendable {
    private let baseURL: URL
    private let plugins: [any NetworkPlugin]
    private let session: URLSession
    private let cache = MemoryCache()

    /// Create a network client
    public init(
        baseURL: URL,
        plugins: [any NetworkPlugin] = [],
        session: URLSession = .shared
    ) {
        self.baseURL = baseURL
        self.plugins = plugins
        self.session = session
    }

    /// Perform a request and decode the response as a Codable type
    public func request<T: Decodable & Sendable>(
        _ endpoint: some Endpoint,
        as type: T.Type,
        retry: RetryPolicy = .none,
        cache: CachePolicy = .none
    ) async throws -> Response<T> {
        let dataResponse = try await performRequest(endpoint, retry: retry, cache: cache)
        do {
            let decoded = try JSONDecoder().decode(T.self, from: dataResponse.data)
            return Response(data: decoded, statusCode: dataResponse.statusCode, headers: dataResponse.headers)
        } catch {
            throw NetworkError.decodingFailed(error)
        }
    }

    /// Perform a request returning raw Data
    public func request(_ endpoint: some Endpoint) async throws -> Response<Data> {
        try await performRequest(endpoint, retry: .none, cache: .none)
    }

    /// Upload data to an endpoint
    public func upload(
        _ data: Data,
        to endpoint: some Endpoint,
        contentType: String = "application/octet-stream"
    ) async throws -> Response<Data> {
        var request = try buildRequest(for: endpoint)
        request.httpBody = data
        request.setValue(contentType, forHTTPHeaderField: "Content-Type")
        return try await execute(request)
    }

    /// Download raw data from an endpoint
    public func download(_ endpoint: some Endpoint) async throws -> Data {
        let response = try await performRequest(endpoint, retry: .none, cache: .none)
        return response.data
    }

    // MARK: - Private

    private func performRequest(
        _ endpoint: some Endpoint,
        retry: RetryPolicy,
        cache cachePolicy: CachePolicy
    ) async throws -> Response<Data> {
        let request = try buildRequest(for: endpoint)
        let cacheKey = "\(request.httpMethod ?? "GET"):\(request.url?.absoluteString ?? "")"

        // Check cache
        if case .memory = cachePolicy, let entry = cache.get(cacheKey) {
            return Response(data: entry.data, statusCode: entry.statusCode, headers: entry.headers)
        }

        var lastError: Error?
        let attempts = max(1, retry.maxAttempts + 1)

        for attempt in 1...attempts {
            do {
                let response = try await execute(request)

                // Store in cache if applicable
                if case .memory(let ttl) = cachePolicy {
                    let entry = MemoryCache.CacheEntry(
                        data: response.data,
                        statusCode: response.statusCode,
                        headers: response.headers,
                        expiry: Date().addingTimeInterval(ttl)
                    )
                    cache.set(cacheKey, entry: entry)
                }

                return response
            } catch let error as NetworkError {
                lastError = error
                if case .httpError(let code, _) = error, retry.retryableStatusCodes.contains(code), attempt < attempts {
                    try await Task.sleep(nanoseconds: UInt64(retry.delay * 1_000_000_000))
                    continue
                }
                throw error
            } catch {
                throw error
            }
        }

        throw lastError ?? NetworkError.noData
    }

    private func buildRequest(for endpoint: some Endpoint) throws -> URLRequest {
        var components = URLComponents(url: baseURL, resolvingAgainstBaseURL: true)
        components?.path = (components?.path ?? "") + endpoint.path

        if !endpoint.queryItems.isEmpty {
            components?.queryItems = endpoint.queryItems
        }

        guard let url = components?.url else {
            throw NetworkError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.httpBody = endpoint.body

        for (key, value) in endpoint.headers {
            request.setValue(value, forHTTPHeaderField: key)
        }

        return request
    }

    private func execute(_ request: URLRequest) async throws -> Response<Data> {
        var mutableRequest = request

        // Run prepare plugins
        for plugin in plugins {
            do {
                try await plugin.prepare(&mutableRequest)
            } catch {
                throw NetworkError.pluginError(error)
            }
        }

        let (data, urlResponse) = try await session.data(for: mutableRequest)

        guard let httpResponse = urlResponse as? HTTPURLResponse else {
            throw NetworkError.noData
        }

        // Run process plugins
        for plugin in plugins {
            do {
                try await plugin.process(httpResponse, data: data)
            } catch {
                throw NetworkError.pluginError(error)
            }
        }

        let headers = Dictionary(
            uniqueKeysWithValues: httpResponse.allHeaderFields.compactMap { key, value in
                guard let key = key as? String, let value = value as? String else { return nil }
                return (key, value)
            }
        )

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode, data: data)
        }

        return Response(data: data, statusCode: httpResponse.statusCode, headers: headers)
    }
}
