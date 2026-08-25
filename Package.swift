// swift-tools-version:6.3
import PackageDescription

let package = Package(
  name: "users-web",
  platforms: [
    .macOS(.v13)
  ],
  dependencies: [
    .package(url: "https://github.com/vapor/vapor.git", from: "4.99.0"),
    .package(url: "https://github.com/vapor/leaf.git", from: "4.3.0"),
    .package(url: "https://github.com/vapor/redis.git", from: "4.10.0"),
    .package(url: "https://github.com/vapor-community/Lingo-Vapor.git", from: "4.2.0"),
  ],
  targets: [
    .executableTarget(
      name: "App",
      dependencies: [
        .product(name: "Vapor", package: "vapor"),
        .product(name: "Leaf", package: "leaf"),
        .product(name: "Redis", package: "redis"),
        .product(name: "LingoVapor", package: "Lingo-Vapor"),
      ],
      swiftSettings: [
        .unsafeFlags(["-cross-module-optimization"], .when(configuration: .release))
      ]
    ),
    .testTarget(
      name: "AppTests",
      dependencies: [
        .target(name: "App"),
        .product(name: "VaporTesting", package: "vapor"),
      ]
    ),
  ]
)
