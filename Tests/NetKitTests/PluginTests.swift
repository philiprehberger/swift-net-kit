import Testing
import Foundation
#if canImport(FoundationNetworking)
import FoundationNetworking
#endif
@testable import NetKit

struct TestPlugin: NetworkPlugin {
    let onPrepare: @Sendable (inout URLRequest) async throws -> Void

    func prepare(_ request: inout URLRequest) async throws {
        try await onPrepare(&request)
    }
}

final class MessageLog: @unchecked Sendable {
    var messages: [String] = []
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
        let log = MessageLog()
        let plugin = LoggingPlugin { log.messages.append($0) }
        var request = URLRequest(url: URL(string: "https://example.com/test")!)
        request.httpMethod = "GET"
        try await plugin.prepare(&request)
        #expect(log.messages.count == 1)
        #expect(log.messages[0].contains("GET"))
        #expect(log.messages[0].contains("/test"))
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
