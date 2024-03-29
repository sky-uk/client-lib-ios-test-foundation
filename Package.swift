// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "SkyTestFoundation",
    platforms: [
        .iOS(.v12),
        .macOS(.v10_15),
        .tvOS(.v12),
        .watchOS(.v5)
        ],
    products: [
        .library(name: "SkyTestFoundation", targets: ["SkyTestFoundation"])
    ],
    dependencies: [
        .package(name: "Swifter", url: "https://github.com/httpswift/swifter", from: "1.5.0")
    ],
    targets: [
        .target(
            name: "SkyTestFoundation",
            dependencies: ["Swifter"],
	    path: "Xcode/Sources"
        ),
        .testTarget(
            name: "SkyTestFoundationTests",
            dependencies: ["SkyTestFoundation"],
	    path: "Xcode/Tests"
        )
    ]
)
