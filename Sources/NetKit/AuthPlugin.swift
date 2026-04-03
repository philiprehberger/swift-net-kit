import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif

/// A plugin that adds an Authorization Bearer header to every request
///
/// ```swift
/// AuthPlugin { await getAccessToken() }
/// ```
public struct AuthPlugin: NetworkPlugin, Sendable {
    private let tokenProvider: @Sendable () async -> String

    /// Create an auth plugin with a token provider
    public init(tokenProvider: @escaping @Sendable () async -> String) {
        self.tokenProvider = tokenProvider
    }

    public func prepare(_ request: inout URLRequest) async throws {
        let token = await tokenProvider()
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
    }
}
