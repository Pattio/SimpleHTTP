// swift-tools-version: 6.1

import PackageDescription

let package = Package(
    name: "SimpleHTTP",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "SimpleHTTP",
            targets: ["SimpleHTTP"]
        ),
        .library(
            name: "SimpleHTTPCore",
            targets: ["SimpleHTTPCore"]
        ),
        .library(
            name: "SimpleHTTPSauce",
            targets: ["SimpleHTTPSauce"]
        ),
        .library(
            name: "SimpleHTTPSugar",
            targets: ["SimpleHTTPSugar"]
        ),
    ],
    targets: [
        .target(
            name: "SimpleHTTP",
            dependencies: [
                "SimpleHTTPCore",
                "SimpleHTTPSauce",
                "SimpleHTTPSugar",
            ],
            path: "Sources/SimpleHTTP"
        ),
        .target(
            name: "SimpleHTTPCore",
            path: "Sources/Modules/Core"
        ),
        .target(
            name: "SimpleHTTPSauce",
            dependencies: ["SimpleHTTPCore"],
            path: "Sources/Modules/Sauce"
        ),
        .target(
            name: "SimpleHTTPSugar",
            dependencies: ["SimpleHTTPCore"],
            path: "Sources/Modules/Sugar"
        ),
        .testTarget(
            name: "SimpleHTTPTests",
            dependencies: ["SimpleHTTP"]
        ),
    ]
)
