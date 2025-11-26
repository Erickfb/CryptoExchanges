// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CryptoExchanges",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "CryptoExchanges",
            targets: ["CryptoExchanges"]),
    ],
    targets: [
        .target(
            name: "CryptoExchanges",
            dependencies: [],
            path: "Sources"),
        .testTarget(
            name: "CryptoExchangesTests",
            dependencies: ["CryptoExchanges"],
            path: "Tests/UnitTests"),
        .testTarget(
            name: "CryptoExchangesUITests",
            dependencies: ["CryptoExchanges"],
            path: "Tests/UITests"),
    ]
)
