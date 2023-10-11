// swift-tools-version:5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EKAstrologyCalc",
    platforms: [
        .iOS(.v15),
        .macOS(.v14),
        .tvOS(.v15),
        .watchOS(.v8),
    ],
    products: [
        .library(name: "EKAstrologyCalc", targets: ["EKAstrologyCalc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/ESKARIA/ESDateHelper.git", from: "1.1.1")
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
