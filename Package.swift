// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SimpleHTTP",
    platforms: [.iOS(.v16), .macOS(.v13)],
    products: [
        .library(
            name: "SimpleHTTP",
            targets: [
                "SimpleHTTPCore",
                "SimpleHTTPSauce",
                "SimpleHTTPSugar"
            ]
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
            name: "SimpleHTTPCore",
            path: "Sources/Core"
        ),
        .target(
            name: "SimpleHTTPSauce",
            dependencies: ["SimpleHTTPCore"],
            path: "Sources/Sauce"
        ),
        .target(
            name: "SimpleHTTPSugar",
            dependencies: ["SimpleHTTPCore"],
            path: "Sources/Sugar"
        ),
        .testTarget(
            name: "SimpleHTTPTests",
            dependencies: [
                "SimpleHTTPCore",
                "SimpleHTTPSauce",
                "SimpleHTTPSugar",
            ]
        ),
    ]
)
