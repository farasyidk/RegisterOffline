import ProjectDescription

let project = Project(
    name: "RegisterOffline",
    settings: .settings(configurations: [
        .debug(name: "Debug", xcconfig: "Targets/App/Test.xcconfig"),
        .release(name: "Release", xcconfig: "Targets/App/Prod.xcconfig")
    ]),
    targets: [
        .target(
            name: "App",
            destinations: .iOS,
            product: .app,
            bundleId: "$(APP_BUNDLE_ID)",
            deploymentTargets: .iOS("17.6"),
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
                .target(name: "MemberFeature")
            ]
        ),
        .target(
            name: "CoreProtocol",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.coreprotocol",
            deploymentTargets: .iOS("17.6"),
            infoPlist: .default,
            sources: ["Targets/CoreProtocol/Sources/**"],
            dependencies: []
        ),
        .target(
            name: "Core",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.core",
            deploymentTargets: .iOS("17.6"),
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
            deploymentTargets: .iOS("17.6"),
            infoPlist: .default,
            sources: ["Targets/DesignSystem/Sources/**"],
            resources: ["Targets/DesignSystem/Resources/**"]
        ),
        .target(
            name: "AuthFeature",
            destinations: .iOS,
            product: .framework,
            bundleId: "com.zenith.authfeature",
            deploymentTargets: .iOS("17.6"),
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
            deploymentTargets: .iOS("17.6"),
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
            deploymentTargets: .iOS("17.6"),
            infoPlist: .default,
            sources: ["Targets/MemberFeature/Sources/**"],
            dependencies: [
                .target(name: "CoreProtocol"),
                .target(name: "Core"),
                .target(name: "DesignSystem")
            ]
        ),
    ],
    schemes: [
        .scheme(
            name: "Test",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            runAction: .runAction(configuration: "Debug"),
            archiveAction: .archiveAction(configuration: "Debug"),
            profileAction: .profileAction(configuration: "Debug"),
            analyzeAction: .analyzeAction(configuration: "Debug")
        ),
        .scheme(
            name: "Production",
            shared: true,
            buildAction: .buildAction(targets: ["App"]),
            runAction: .runAction(configuration: "Release"),
            archiveAction: .archiveAction(configuration: "Release"),
            profileAction: .profileAction(configuration: "Release"),
            analyzeAction: .analyzeAction(configuration: "Release")
        )
    ]
)
