import Foundation

/// A declarative HTTP endpoint definition
///
/// Conform to this protocol to define API endpoints:
/// ```swift
/// struct GetUser: Endpoint {
///     let userId: String
///     var path: String { "/users/\(userId)" }
///     var method: HTTPMethod { .get }
/// }
/// ```
public protocol Endpoint: Sendable {
    /// The URL path component (e.g. "/users/123")
    var path: String { get }

    /// The HTTP method
    var method: HTTPMethod { get }

    /// Request headers
    var headers: [String: String] { get }

    /// URL query parameters
    var queryItems: [URLQueryItem] { get }

    /// Request body data
    var body: Data? { get }
}

extension Endpoint {
    /// Default: no headers
    public var headers: [String: String] { [:] }

    /// Default: no query parameters
    public var queryItems: [URLQueryItem] { [] }

    /// Default: no body
    public var body: Data? { nil }
}
