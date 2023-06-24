// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "TopBar",
	 platforms: [
		.iOS(.v15)
	 ],
    products: [
        .library(
            name: "TopBar",
            targets: ["TopBar"]
		  ),
    ],
    targets: [
        .target(name: "TopBar"),
        .testTarget(
            name: "TopBarTests",
            dependencies: ["TopBar"]
		  ),
    ]
)
