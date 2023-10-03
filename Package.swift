// swift-tools-version:5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EKAstrologyCalc",
    platforms: [
        .iOS(.v11),
        .macOS(.v12),
        .tvOS(.v11),
        .watchOS(.v5),
    ],
    products: [
        .library(name: "EKAstrologyCalc", targets: ["EKAstrologyCalc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ESKARIA/ESDateHelper.git", from: "1.1.0")
    ],
    targets: [
        .target(name: "EKAstrologyCalc", dependencies: [
            "ESDateHelper"
        ]),
        .testTarget(name: "EKAstrologyCalcTests", dependencies: [
            "EKAstrologyCalc"
        ]),
    ]
)
