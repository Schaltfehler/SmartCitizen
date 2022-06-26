// swift-tools-version: 5.6

import PackageDescription

let package = Package(
    name: "SmartCitizen",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "SmartCitizen", targets: ["SmartCitizen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-algorithms", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-numerics", from: "1.0.0"),
    ],
    targets: [
        .target(name: "SmartCitizen",
                dependencies: [
                    .product(name: "Algorithms", package: "swift-algorithms"),
                    .product(name: "Numerics", package: "swift-numerics"),
                ]
               ),
        .testTarget(name: "SmartCitizenTests",
                    dependencies: ["SmartCitizen"],
                    resources: [
                        .copy("DebugData/json")
                    ]
                   )
    ]
)
