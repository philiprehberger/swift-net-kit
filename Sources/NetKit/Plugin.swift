import Foundation

/// A plugin that can intercept and modify network requests and responses
///
/// Use plugins to add authentication, logging, or custom headers.
public protocol NetworkPlugin: Sendable {
    /// Modify the request before sending
    func prepare(_ request: inout URLRequest) async throws

    /// Process the response after receiving
    func process(_ response: HTTPURLResponse, data: Data) async throws
}

extension NetworkPlugin {
    /// Default: no response processing
    public func process(_ response: HTTPURLResponse, data: Data) async throws {}
}
