// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "TopBar",
	 platforms: [
		.iOS(.v14)
	 ],
    products: [
        .library(
            name: "TopBar",
            targets: ["TopBar"]
		  ),
    ],
	 dependencies: [],
    targets: [
        .target(name: "TopBar"),
        .testTarget(
            name: "TopBarTests",
            dependencies: ["TopBar"]
		  ),
    ]
)
