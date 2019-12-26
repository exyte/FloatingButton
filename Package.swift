// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "FloatingActionButton",
	platforms: [
		.macOS(.v10_15),
        .iOS(.v13),
        .watchOS(.v6)
    ],
    products: [
    	.library(
    		name: "FloatingActionButton", 
    		targets: ["FloatingActionButton"]
    	)
    ],
    targets: [
    	.target(
    		name: "FloatingActionButton",
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
