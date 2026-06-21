// swift-tools-version: 5.10

import PackageDescription

let package = Package(
    name: "MacTreeSize",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "MacTreeSize", targets: ["MacTreeSize"])
    ],
    targets: [
        .executableTarget(name: "MacTreeSize")
    ]
)
