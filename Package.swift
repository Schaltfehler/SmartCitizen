// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SmartCitizen",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "Views", targets: ["Views"]),
        .library(name: "Domain", targets: ["Domain"]),
        .library(name: "Network", targets: ["Network"]),
        .library(name: "Models", targets: ["Models"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(name: "Views",
                dependencies: [
                    .product(name: "Algorithms", package: "swift-algorithms"),
                    .product(name: "Numerics", package: "swift-numerics"),
                    "Domain",
                    "Network",
                    "Models",
                ]),
        .target(name: "Domain", dependencies: ["Network", "Models"]),
        .target(name: "Network", dependencies: ["Models"]),
        .target(name: "Models"),
        .testTarget(
            name: "SmartCitizenTests",
            dependencies: [
                "Network",
                "Models",
            ],
            resources: [ .copy("DebugData/json") ]
        ),
    ]
)
