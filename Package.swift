// swift-tools-version:5.5

import PackageDescription

let package = Package(
    name: "refreshable-scroll-view",
    platforms: [
        .iOS(.v14)
    ],
    products: [
        .library(
            name: "RefreshableScrollView",
            targets: [
                "RefreshableScrollView"
            ]
        )
    ],
    dependencies: [
    ],
    targets: [
        .target(name: "RefreshableScrollView")
    ]
)
