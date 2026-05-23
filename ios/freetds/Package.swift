// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "freetds",
    platforms: [
        .iOS("12.0"),
    ],
    products: [
        .library(name: "freetds", targets: ["freetds"])
    ],
    dependencies: [],
    targets: [
        .binaryTarget(
            name: "FreeTDS",
            path: "FreeTDS.xcframework"
        ),
        .target(
            name: "freetds",
            dependencies: [
                "FreeTDS",
            ],
            path: "Sources/freetds",
            cSettings: [
                .headerSearchPath("include/freetds"),
            ],
            linkerSettings: [
                .linkedLibrary("c++"),
            ]
        ),
    ]
)
