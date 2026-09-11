// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "PersooCore", platforms: [.iOS(.v26), .macOS(.v15)], products: [.library(name: "PersooCore", targets: ["PersooCore"])], targets: [.target(name: "PersooCore"), .testTarget(name: "PersooCoreTests", dependencies: ["PersooCore"])])
