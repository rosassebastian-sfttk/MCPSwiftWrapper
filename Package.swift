// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "MCPSwiftWrapper",
    platforms: [
      .macOS(.v14),
    ],
    products: [
        // Products define the executables and libraries a package produces, making them visible to other packages.
        .library(
            name: "MCPSwiftWrapper",
            targets: ["MCPSwiftWrapper"]),
    ],
    dependencies: [
      .package(url: "https://github.com/gsabran/mcp-swift-sdk", from: "0.2.2"),
      .package(url: "https://github.com/rosassebastian-sfttk/SwiftOpenAI.git", from: "4.0.3"),
      .package(url: "https://github.com/jamesrochabrun/SwiftAnthropic", from: "2.1.2"),
    ],
    targets: [
        // Targets are the basic building blocks of a package, defining a module or a test suite.
        // Targets can depend on other targets in this package and products from dependencies.
        .target(
            name: "MCPSwiftWrapper",
            dependencies: [
               .product(name: "SwiftOpenAI", package: "SwiftOpenAI"),
               .product(name: "SwiftAnthropic", package: "SwiftAnthropic"),
              .product(name: "MCPClient", package: "mcp-swift-sdk"),
            ]),
        .testTarget(
            name: "MCPSwiftWrapperTests",
            dependencies: ["MCPSwiftWrapper"]
        ),
    ]
)
