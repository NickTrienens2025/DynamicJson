// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "DynamicJson",
     platforms: [.macOS(.v14),
                  .iOS(.v16),
                  .tvOS(.v16),
                  .watchOS(.v8)],
    products: [
        .library(
            name: "JSON",
            targets: ["JSON"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "JSON",
            dependencies: []
        ),
        .testTarget(
            name: "JSONTests",
            dependencies: ["JSON"]
        ),
    ]
)
