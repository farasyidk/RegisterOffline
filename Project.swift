import ProjectDescription

let project = Project(
    name: "RegisterOffline",
    settings: .settings(configurations: [
        .debug(name: "Test", xcconfig: "Targets/App/Test.xcconfig"),
        .release(name: "Production", xcconfig: "Targets/App/Prod.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "$(APP_BUNDLE_ID)",
            infoPlist: .extendingDefault(with: [
                "CFBundleDisplayName": "$(APP_NAME)",
                "UILaunchScreen": [:],
                "UIRequiresFullScreen": true,
                "NSCameraUsageDescription": "Aplikasi membutuhkan akses kamera untuk mengambil foto KTP.",
                "BASE_URL": "$(BASE_URL)"
            ]),
            sources: ["Targets/App/Sources/**"],
            resources: ["Targets/App/Resources/**"],
            dependencies: [
                .target(name: "Core"),
                .target(name: "DesignSystem"),
                .target(name: "AuthFeature"),
                .target(name: "ProfileFeature"),
                .target(name: "MemberFeature"),
                .target(name: "SyncFeature")
            ]
        ),
        .target(
            name: "CoreProtocol",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.coreprotocol",
            infoPlist: .default,
            sources: ["Targets/CoreProtocol/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.core",
            infoPlist: .default,
            sources: ["Targets/Core/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol")
            ]
        ),
        .target(
            name: "DesignSystem",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.designsystem",
            infoPlist: .default,
            sources: ["Targets/DesignSystem/Sources/**"],
            resources: ["Targets/DesignSystem/Resources/**"],
            dependencies: []
        ),
        .target(
            name: "AuthFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.authfeature",
            infoPlist: .default,
            sources: ["Targets/AuthFeature/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol"),
                .target(name: "Core"),
                .target(name: "DesignSystem")
            ]
        ),
        .target(
            name: "ProfileFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.profilefeature",
            infoPlist: .default,
            sources: ["Targets/ProfileFeature/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol"),
                .target(name: "Core"),
                .target(name: "DesignSystem")
            ]
        ),
        .target(
            name: "MemberFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.memberfeature",
            infoPlist: .default,
            sources: ["Targets/MemberFeature/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol"),
                .target(name: "Core"),
                .target(name: "DesignSystem")
            ]
        ),
        .target(
            name: "SyncFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.syncfeature",
            infoPlist: .default,
            sources: ["Targets/SyncFeature/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol"),
                .target(name: "Core")
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "App-Test",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            runAction: .runAction(configuration: "Test"),
            archiveAction: .archiveAction(configuration: "Test"),
            profileAction: .profileAction(configuration: "Test"),
            analyzeAction: .analyzeAction(configuration: "Test")
        ),
        .scheme(
            name: "App-Production",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            runAction: .runAction(configuration: "Production"),
            archiveAction: .archiveAction(configuration: "Production"),
            profileAction: .profileAction(configuration: "Production"),
            analyzeAction: .analyzeAction(configuration: "Test")
        )
    ]
)
