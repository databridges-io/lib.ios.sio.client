// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "databridges_sio_swift_client",
    platforms: [.iOS("13.0"), .macOS("10.15"), .tvOS("13.0"), .watchOS("6.0")],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "databridges_sio_swift_client",
            targets: ["databridges_sio_swift_client"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(name: "SocketIO", url: "https://github.com/socketio/socket.io-client-swift", from: "15.0.0"),

        .package(name: "PromiseKit", url: "https://github.com/mxcl/PromiseKit", from: "6.8.4"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "databridges_sio_swift_client",
            dependencies: ["SocketIO" ,  "PromiseKit"]),
        .testTarget(
            name: "databridges_sio_swift_clientTests",
            dependencies: ["databridges_sio_swift_client"]),
    ]
)
