import SwiftUI

private struct GameInfo {
    let title: String
    let tagline: String
    let icon: String
    let gradient: [Color]
}

private enum Games {
    static let tapFrenzy = GameInfo(
        title: "Tap Frenzy",
        tagline: "Fast taps, faster reflexes",
        icon: "hand.tap.fill",
        gradient: [Color(red: 1.0, green: 0.42, blue: 0.29), Color(red: 0.55, green: 0.13, blue: 0.16)]
    )
    static let lightItUp = GameInfo(
        title: "Light It Up",
        tagline: "Spot the lit tile before it fades",
        icon: "square.grid.3x3.fill.square",
        gradient: [Color(red: 0.16, green: 0.83, blue: 0.65), Color(red: 0.04, green: 0.42, blue: 0.42)]
    )
    static let quizRush = GameInfo(
        title: "Quiz Rush",
        tagline: "Answer fast, build your streak",
        icon: "bolt.horizontal.circle.fill",
        gradient: [Color(red: 0.42, green: 0.32, blue: 0.78), Color(red: 0.19, green: 0.14, blue: 0.42)]
    )
}

struct HomeView: View {
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background
                    .ignoresSafeArea()

                VStack(spacing: 36) {
                    Spacer()

                    VStack(spacing: 6) {
                        Text("ARCADE")
                            .font(.caption)
                            .fontWeight(.bold)
                            .tracking(3)
                            .foregroundColor(AppTheme.textSecondary)
                        Text("Mini Games")
                            .font(.system(.largeTitle, design: .rounded))
                            .bold()
                            .foregroundColor(AppTheme.textPrimary)
                    }

                    VStack(spacing: 16) {
                        GameCardLink(info: Games.tapFrenzy) { TapFrenzyView() }
                        GameCardLink(info: Games.lightItUp) { LightItUpView() }
                        GameCardLink(info: Games.quizRush) { QuizRushView() }
                    }
                    .padding(.horizontal, 20)

                    Spacer()
                    Spacer()
                }
                .padding()
            }
            .navigationBarHidden(true)
        }
    }
}

private struct GameCardLink<Destination: View>: View {
    let info: GameInfo
    @ViewBuilder let destination: () -> Destination

    var body: some View {
        NavigationLink(destination: destination) {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color.white.opacity(0.18))
                        .frame(width: 48, height: 48)
                    Image(systemName: info.icon)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.white)
                }

                VStack(alignment: .leading, spacing: 3) {
                    Text(info.title)
                        .font(.system(.title3, design: .rounded))
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    Text(info.tagline)
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.8))
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.subheadline.weight(.semibold))
                    .foregroundColor(.white.opacity(0.7))
            }
            .padding(18)
            .frame(maxWidth: .infinity)
            .background(
                LinearGradient(colors: info.gradient, startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .clipShape(RoundedRectangle(cornerRadius: 20))
            .shadow(color: info.gradient.first?.opacity(0.35) ?? .clear, radius: 12, x: 0, y: 8)
        }
        .buttonStyle(CardPressStyle())
    }
}


private struct CardPressStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

#Preview {
    HomeView()
}
