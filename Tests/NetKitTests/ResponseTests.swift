import Testing
import Foundation
@testable import NetKit

@Suite("Response Tests")
struct ResponseTests {
    @Test("Response stores all properties")
    func properties() {
        let response = Response(data: "hello", statusCode: 200, headers: ["X-Custom": "value"])
        #expect(response.data == "hello")
        #expect(response.statusCode == 200)
        #expect(response.headers["X-Custom"] == "value")
    }
}
