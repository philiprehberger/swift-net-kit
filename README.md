# NetKit

[![Tests](https://github.com/philiprehberger/swift-net-kit/actions/workflows/ci.yml/badge.svg)](https://github.com/philiprehberger/swift-net-kit/actions/workflows/ci.yml)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fphiliprehberger%2Fswift-net-kit%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/philiprehberger/swift-net-kit)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fphiliprehberger%2Fswift-net-kit%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/philiprehberger/swift-net-kit)

Declarative networking client with retry, caching, plugins, and automatic Codable decoding

## Requirements

- Swift >= 6.0
- macOS 13+ / iOS 16+ / tvOS 16+ / watchOS 9+

## Installation

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/philiprehberger/swift-net-kit.git", from: "0.1.0")
]
```

Then add `"NetKit"` to your target dependencies:

```swift
.target(name: "YourTarget", dependencies: [
    .product(name: "NetKit", package: "swift-net-kit")
])
```

## Usage

```swift
import NetKit

// Define an endpoint
struct GetUser: Endpoint {
    let userId: String
    var path: String { "/users/\(userId)" }
    var method: HTTPMethod { .get }
}

// Make a request
let client = NetworkClient(baseURL: URL(string: "https://api.example.com")!)
let response = try await client.request(GetUser(userId: "123"), as: User.self)
print(response.data.name)
```

### POST with Body

```swift
struct CreateUser: Endpoint {
    let name: String
    var path: String { "/users" }
    var method: HTTPMethod { .post }
    var body: Data? { try? JSONEncoder().encode(["name": name]) }
    var headers: [String: String] { ["Content-Type": "application/json"] }
}
```

### Retry Policy

```swift
let response = try await client.request(
    GetUser(userId: "123"),
    as: User.self,
    retry: .default  // 3 attempts, 1s delay, retries on 500/502/503/504
)
```

### Caching

```swift
let response = try await client.request(
    GetUser(userId: "123"),
    as: User.self,
    cache: .memory(ttl: 60)  // cache for 60 seconds
)
```

### Plugins

```swift
let client = NetworkClient(
    baseURL: url,
    plugins: [
        AuthPlugin { await getToken() },
        LoggingPlugin()
    ]
)
```

## API

### NetworkClient

| Method | Description |
|--------|-------------|
| `init(baseURL:plugins:session:)` | Create a client with base URL and plugins |
| `request(_:as:retry:cache:)` | Request with Codable decoding |
| `request(_:)` | Request returning raw Data |
| `upload(_:to:contentType:)` | Upload data to an endpoint |
| `download(_:)` | Download raw data |

### Endpoint

| Property | Description |
|----------|-------------|
| `path` | URL path component |
| `method` | HTTP method |
| `headers` | Request headers (default: empty) |
| `queryItems` | URL query parameters (default: empty) |
| `body` | Request body data (default: nil) |

### NetworkPlugin

| Method | Description |
|--------|-------------|
| `prepare(_:)` | Modify request before sending |
| `process(_:data:)` | Process response after receiving |

## Development

```bash
swift build
swift test
```

## Support

[💬 Bluesky](https://bsky.app/profile/philiprehberger.bsky.social) · [🐦 X](https://x.com/philiprehberger) · [💼 LinkedIn](https://linkedin.com/in/philiprehberger) · [🌐 Website](https://philiprehberger.com) · [📦 GitHub](https://github.com/philiprehberger) · [☕ Buy Me a Coffee](https://buymeacoffee.com/philiprehberger) · [❤️ GitHub Sponsors](https://github.com/sponsors/philiprehberger)

## License

[MIT](LICENSE)
