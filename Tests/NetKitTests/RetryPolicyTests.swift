import Testing
@testable import NetKit

@Suite("RetryPolicy Tests")
struct RetryPolicyTests {
    @Test("None policy has zero attempts")
    func nonePolicy() {
        let policy = RetryPolicy.none
        #expect(policy.maxAttempts == 0)
        #expect(policy.delay == 0)
        #expect(policy.retryableStatusCodes.isEmpty)
    }

    @Test("Default policy has 3 attempts")
    func defaultPolicy() {
        let policy = RetryPolicy.default
        #expect(policy.maxAttempts == 3)
        #expect(policy.delay == 1.0)
        #expect(policy.retryableStatusCodes.contains(500))
        #expect(policy.retryableStatusCodes.contains(502))
        #expect(policy.retryableStatusCodes.contains(503))
        #expect(policy.retryableStatusCodes.contains(504))
        #expect(policy.retryableStatusCodes.contains(429))
    }

    @Test("Custom policy preserves values")
    func customPolicy() {
        let policy = RetryPolicy(maxAttempts: 5, delay: 2.0, retryableStatusCodes: [500])
        #expect(policy.maxAttempts == 5)
        #expect(policy.delay == 2.0)
        #expect(policy.retryableStatusCodes == [500])
    }
}
