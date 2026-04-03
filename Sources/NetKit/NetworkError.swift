import Foundation

/// Errors thrown by NetworkClient
public enum NetworkError: Error, Sendable, CustomStringConvertible {
    /// The URL could not be constructed
    case invalidURL

    /// The server returned a non-2xx status code
    case httpError(statusCode: Int, data: Data)

    /// The response body could not be decoded
    case decodingFailed(Error)

    /// No data was returned
    case noData

    /// The request timed out
    case timeout

    /// The request was cancelled
    case cancelled

    /// A plugin threw an error
    case pluginError(Error)

    public var description: String {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case .httpError(let code, _):
            return "HTTP error: \(code)"
        case .decodingFailed(let error):
            return "Decoding failed: \(error)"
        case .noData:
            return "No data"
        case .timeout:
            return "Request timed out"
        case .cancelled:
            return "Request cancelled"
        case .pluginError(let error):
            return "Plugin error: \(error)"
        }
    }
}
