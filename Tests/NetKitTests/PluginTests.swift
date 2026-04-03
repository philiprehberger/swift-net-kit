import Testing
import Foundation
@testable import NetKit

struct TestPlugin: NetworkPlugin {
    let onPrepare: @Sendable (inout URLRequest) async throws -> Void

    func prepare(_ request: inout URLRequest) async throws {
        try await onPrepare(&request)
    }
}

@Suite("Plugin Tests")
struct PluginTests {
    @Test("Auth plugin adds bearer header")
    func authPlugin() async throws {
        let plugin = AuthPlugin(tokenProvider: { "test-token" })
        var request = URLRequest(url: URL(string: "https://example.com")!)
        try await plugin.prepare(&request)
        #expect(request.value(forHTTPHeaderField: "Authorization") == "Bearer test-token")
    }

    @Test("Logging plugin calls logger on prepare")
    func loggingPluginPrepare() async throws {
        var messages: [String] = []
        let plugin = LoggingPlugin { messages.append($0) }
        var request = URLRequest(url: URL(string: "https://example.com/test")!)
        request.httpMethod = "GET"
        try await plugin.prepare(&request)
        #expect(messages.count == 1)
        #expect(messages[0].contains("GET"))
        #expect(messages[0].contains("/test"))
    }

    @Test("Network error descriptions are meaningful")
    func errorDescriptions() {
        let invalidURL = NetworkError.invalidURL
        #expect(invalidURL.description.contains("Invalid URL"))

        let httpError = NetworkError.httpError(statusCode: 404, data: Data())
        #expect(httpError.description.contains("404"))

        let timeout = NetworkError.timeout
        #expect(timeout.description.contains("timed out"))
    }
}
