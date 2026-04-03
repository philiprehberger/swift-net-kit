import Foundation

/// A typed HTTP response
public struct Response<T: Sendable>: Sendable {
    /// The decoded response data
    public let data: T

    /// The HTTP status code
    public let statusCode: Int

    /// The response headers
    public let headers: [String: String]

    /// Create a response
    public init(data: T, statusCode: Int, headers: [String: String]) {
        self.data = data
        self.statusCode = statusCode
        self.headers = headers
    }
}
