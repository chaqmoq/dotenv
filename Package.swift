// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "chaqmoq-dotenv",
    products: [
        .library(name: "DotEnv", targets: ["DotEnv"])
    ],
    targets: [
        .target(name: "DotEnv"),
        .testTarget(
            name: "DotEnvTests",
            dependencies: [
                .target(name: "DotEnv")
            ],
            resources: [
                .process("Resources")
            ]
        )
    ],
    swiftLanguageVersions: [.v5]
)
