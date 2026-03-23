import SwiftUI
import DesignSystem

public struct SplashView: View {
    public init() {}
    public var body: some View {
        ZStack {
            Color.brandDarkBlue.ignoresSafeArea()
            VStack(spacing: 24) {
                DesignSystemAssets.icon
                    .renderingMode(.template)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                Text("Register Offline")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
        }
    }
}
