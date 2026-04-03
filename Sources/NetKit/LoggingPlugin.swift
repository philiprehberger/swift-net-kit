import Foundation

/// A plugin that logs requests and responses
public struct LoggingPlugin: NetworkPlugin, Sendable {
    private let logger: @Sendable (String) -> Void

    /// Create a logging plugin with an optional custom logger
    public init(logger: @escaping @Sendable (String) -> Void = { print($0) }) {
        self.logger = logger
    }

    public func prepare(_ request: inout URLRequest) async throws {
        let method = request.httpMethod ?? "GET"
        let url = request.url?.absoluteString ?? "unknown"
        logger("[NetKit] \(method) \(url)")
    }

    public func process(_ response: HTTPURLResponse, data: Data) async throws {
        logger("[NetKit] \(response.statusCode) (\(data.count) bytes)")
    }
}
