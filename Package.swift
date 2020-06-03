// swift-tools-version:5.2
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "EKAstrologyCalc",
    platforms: [
        .iOS(.v11),
    ],
    products: [
        .library(name: "EKAstrologyCalc", targets: ["EKAstrologyCalc"]),
    ],
    dependencies: [
        .package(url: "https://github.com/emvakar/DevHelper.git", from: "1.0.0")
    ],
    targets: [
        .target(name: "EKAstrologyCalc", dependencies: ["DevHelper"]),
        .testTarget(name: "EKAstrologyCalcTests", dependencies: ["EKAstrologyCalc"]),
    ]
)
