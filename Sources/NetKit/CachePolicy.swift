import Foundation

/// Cache strategy for network requests
public enum CachePolicy: Sendable {
    /// No caching
    case none

    /// In-memory cache with a time-to-live
    case memory(ttl: TimeInterval)
}

/// Thread-safe in-memory cache
final class MemoryCache: @unchecked Sendable {
    private var store: [String: CacheEntry] = [:]
    private let lock = NSLock()

    struct CacheEntry {
        let data: Data
        let statusCode: Int
        let headers: [String: String]
        let expiry: Date
    }

    func get(_ key: String) -> CacheEntry? {
        lock.lock()
        defer { lock.unlock() }
        guard let entry = store[key], entry.expiry > Date() else {
            store.removeValue(forKey: key)
            return nil
        }
        return entry
    }

    func set(_ key: String, entry: CacheEntry) {
        lock.lock()
        store[key] = entry
        lock.unlock()
    }
}
