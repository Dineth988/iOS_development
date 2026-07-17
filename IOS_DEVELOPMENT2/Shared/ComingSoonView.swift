import SwiftUI

struct ComingSoonView: View {
    let icon: String
    let title: String
    let message: String

    var body: some View {
        ZStack {
            AppTheme.background
                .ignoresSafeArea()

            VStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.08))
                        .frame(width: 88, height: 88)
                    Image(systemName: icon)
                        .font(.system(size: 34, weight: .semibold))
                        .foregroundColor(AppTheme.textPrimary)
                }

                Text(title)
                    .font(.system(.title2, design: .rounded))
                    .bold()
                    .foregroundColor(AppTheme.textPrimary)

                Text(message)
                    .font(.subheadline)
                    .foregroundColor(AppTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
        }
    }
}
