// swift-tools-version: 6.1
// This is a Skip (https://skip.dev) package.
import PackageDescription

let package = Package(
    name: "skip-liquid-glass-app",
    defaultLocalization: "en",
    platforms: [.iOS("26.5"), .macOS(.v14)],
    products: [
        .library(name: "LiquidGlassApp", type: .dynamic, targets: ["LiquidGlassApp"]),
    ],
    dependencies: [
        .package(url: "https://source.skip.tools/skip.git", from: "1.9.2"),
        .package(url: "https://source.skip.tools/skip-fuse-ui.git", from: "1.0.0"),
        .package(path: "/Users/dhruvchhatbar/Desktop/Clockworks/Skip projects/liquid-glass-app/demo-lib")
    ],
    targets: [
        .target(name: "LiquidGlassApp", dependencies: [
            .product(name: "SkipFuseUI", package: "skip-fuse-ui"),
            .product(name: "DemoLib", package: "demo-lib"),
        ], resources: [.process("Resources")], plugins: [.plugin(name: "skipstone", package: "skip")]),
    ]
)
