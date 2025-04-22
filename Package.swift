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
            name: "DynamicJson",
            targets: ["DynamicJson"]
        ),
    ],
    dependencies: [
    ],
    targets: [
        .target(
            name: "DynamicJson",
            dependencies: []
        ),
        .testTarget(
            name: "JSONTests",
            dependencies: ["DynamicJson"]
        ),
    ]
)
