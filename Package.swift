// swift-tools-version: 6.3

import PackageDescription

let package = Package(
    name: "MonkeyInterpreter",
    products: [
        .executable(
            name: "MonkeyInterpreter",
            targets: ["MonkeyInterpreter"]
        ),
    ],
    targets: [
        .executableTarget(
            name: "MonkeyInterpreter"
        ),
        .testTarget(
            name: "MonkeyInterpreterTests",
            dependencies: ["MonkeyInterpreter"]
        ),
    ],
    swiftLanguageModes: [.v6]
)
