import Foundation

/// Configuration for automatic request retries
public struct RetryPolicy: Sendable {
    /// Maximum number of retry attempts
    public let maxAttempts: Int

    /// Delay in seconds between retries
    public let delay: TimeInterval

    /// HTTP status codes that trigger a retry
    public let retryableStatusCodes: Set<Int>

    /// No retries
    public static let none = RetryPolicy(maxAttempts: 0, delay: 0, retryableStatusCodes: [])

    /// Default: 3 attempts, 1s delay, retries on common server errors
    public static let `default` = RetryPolicy(
        maxAttempts: 3,
        delay: 1.0,
        retryableStatusCodes: [408, 429, 500, 502, 503, 504]
    )

    /// Create a retry policy
    public init(maxAttempts: Int, delay: TimeInterval, retryableStatusCodes: Set<Int>) {
        self.maxAttempts = maxAttempts
        self.delay = delay
        self.retryableStatusCodes = retryableStatusCodes
    }
}
