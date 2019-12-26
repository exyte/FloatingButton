// swift-tools-version:5.1

import PackageDescription

let package = Package(
	name: "FloatingButton",
	platforms: [
		.macOS(.v10_15),
        .iOS(.v13),
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
            path: "Source"
        )
    ],
    swiftLanguageVersions: [.v5]
)
