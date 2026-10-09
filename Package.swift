// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "CareShareCore",
    platforms: [.macOS(.v13), .iOS(.v16)],
    products: [.library(name: "CareShareCore", targets: ["CareShareCore"])],
    targets: [
        .target(name: "CareShareCore", path: "CareShare/Core"),
        .testTarget(name: "CareShareCoreTests", dependencies: ["CareShareCore"])
    ]
)
