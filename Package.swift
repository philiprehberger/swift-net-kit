// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "swift-net-kit",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9)
    ],
    products: [
        .library(name: "NetKit", targets: ["NetKit"])
    ],
    targets: [
        .target(
            name: "NetKit",
            path: "Sources/NetKit"
        ),
        .testTarget(
            name: "NetKitTests",
            dependencies: ["NetKit"],
            path: "Tests/NetKitTests"
        )
    ]
)
