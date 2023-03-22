// swift-tools-version:5.3

import PackageDescription

let package = Package(
	name: "FloatingButton",
	platforms: [
		.macOS(.v10_15),
        .iOS(.v14),
        .watchOS(.v6)
    ],
    products: [
    	.library(
    		name: "FloatingButton", 
    		targets: ["FloatingButton"]
    	)
    ],
    targets: [
    	.target(
    		name: "FloatingButton",
            dependencies: []
        )
    ]
)
