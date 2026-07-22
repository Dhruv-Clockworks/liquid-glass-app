// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "demo-lib",
    defaultLocalization: "en",
    platforms: [.iOS("26.0"), .macOS(.v14)],
    products: [
        .library(name: "DemoLib", type: .dynamic, targets: ["DemoLib"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(url: "https://source.skip.tools/skip-fuse.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "DemoLib", dependencies: [
            .product(name: "SkipFuse", package: "skip-fuse"),
            .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
