// swift-tools-version: 6.2
import PackageDescription
let package = Package(name: "PersooConnect", platforms: [.macOS(.v26)], products: [.executable(name: "PersooConnect", targets: ["PersooConnect"])], targets: [.executableTarget(name: "PersooConnect", path: "Sources")])
