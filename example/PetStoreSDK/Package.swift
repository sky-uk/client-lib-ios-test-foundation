// swift-tools-version:5.3
import PackageDescription

let package = Package(
    name: "PetStoreSDK",
    platforms: [
            .iOS(.v12),
            .macOS(.v10_15),
            .tvOS(.v12),
            .watchOS(.v5)
        ],
    products: [
        .library(name: "PetStoreSDK", targets: ["PetStoreSDK"]),
        .library(name: "PetStoreSDKTests", targets: ["PetStoreSDKTests"])
    ],
    dependencies: [
        .package(name: "ReactiveAPI", url: "https://github.com/sky-uk/ReactiveAPI", from: "1.13.0"),
        .package(name: "SkyTestFoundation", url: "https://github.com/sky-uk/client-lib-ios-test-foundation", from: "2.0.3")
    ],
    targets: [
        .target(
            name: "PetStoreSDK",
            dependencies: ["ReactiveAPI"]
        ),
        .target(
            name: "PetStoreSDKTests",
            dependencies: ["PetStoreSDK", "SkyTestFoundation"]
        )
    ]
)