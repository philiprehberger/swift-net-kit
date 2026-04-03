import Testing
import Foundation
@testable import NetKit

struct SimpleEndpoint: Endpoint {
    var path: String { "/test" }
    var method: HTTPMethod { .get }
}

struct FullEndpoint: Endpoint {
    var path: String { "/users" }
    var method: HTTPMethod { .post }
    var headers: [String: String] { ["Content-Type": "application/json"] }
    var queryItems: [URLQueryItem] { [URLQueryItem(name: "page", value: "1")] }
    var body: Data? { "{}".data(using: .utf8) }
}

@Suite("Endpoint Tests")
struct EndpointTests {
    @Test("Default headers are empty")
    func defaultHeaders() {
        let endpoint = SimpleEndpoint()
        #expect(endpoint.headers.isEmpty)
    }

    @Test("Default query items are empty")
    func defaultQueryItems() {
        let endpoint = SimpleEndpoint()
        #expect(endpoint.queryItems.isEmpty)
    }

    @Test("Default body is nil")
    func defaultBody() {
        let endpoint = SimpleEndpoint()
        #expect(endpoint.body == nil)
    }

    @Test("Full endpoint has all properties")
    func fullEndpoint() {
        let endpoint = FullEndpoint()
        #expect(endpoint.path == "/users")
        #expect(endpoint.method == .post)
        #expect(endpoint.headers["Content-Type"] == "application/json")
        #expect(endpoint.queryItems.count == 1)
        #expect(endpoint.body != nil)
    }
}
