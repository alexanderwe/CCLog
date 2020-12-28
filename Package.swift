// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "CCLog",
     platforms: [
        .macOS(.v10_15)
    ],
      products: [
        // dev .library(name: "DangerDeps", type: .dynamic, targets: ["DangerDependencies"]),
        .executable(name: "cc-log", targets: ["CCLog"])
    ],
     dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", .exact("0.3.1")),
        .package(url: "https://github.com/kareman/SwiftGit2", .branch("spm-binary-target")),
        .package(url: "https://github.com/stencilproject/Stencil.git", .exact("0.14.0")),
        .package(url: "https://github.com/pointfreeco/swift-parsing", .exact("0.1.1")),
        .package(url: "https://github.com/alexanderwe/SemanticVersioningKit.git", .exact("1.0.0")),
        .package(url: "https://github.com/alexanderwe/ConventionalCommitsKit.git",.exact("1.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(name: "CCLog",
                dependencies: ["CCLogCore"],
                path: "Targets/CCLog/Sources"
        ),
        .target(name: "CCLogCore",
                dependencies: [ "ConventionalCommitsKit",
                                "SemanticVersioningKit",
                                .product(name: "Parsing", package: "swift-parsing"),
                                "SwiftGit2",
                                "Stencil",
                                .product(name: "ArgumentParser", package: "swift-argument-parser")
                ],
                path: "Targets/CCLogCore/Sources"
        ),
        .testTarget(
            name: "CCLogTests",
            dependencies: ["CCLog"],
            path: "Targets/CCLog/Tests"
        ),
        .testTarget(
            name: "CCLogCoreTests",
            dependencies: ["CCLogCore"],
            path: "Targets/CCLogCore/Tests"
        ),
    ]
)
