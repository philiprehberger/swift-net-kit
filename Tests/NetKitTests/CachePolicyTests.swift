import Testing
@testable import NetKit

@Suite("CachePolicy Tests")
struct CachePolicyTests {
    @Test("None policy pattern matches")
    func nonePolicy() {
        let policy = CachePolicy.none
        if case .none = policy {
            // passes
        } else {
            #expect(Bool(false), "Should be .none")
        }
    }

    @Test("Memory policy preserves TTL")
    func memoryPolicy() {
        let policy = CachePolicy.memory(ttl: 60)
        if case .memory(let ttl) = policy {
            #expect(ttl == 60)
        } else {
            #expect(Bool(false), "Should be .memory")
        }
    }
}
