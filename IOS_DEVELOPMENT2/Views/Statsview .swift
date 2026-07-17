import SwiftUI
import Charts

struct StatsView: View {
    @StateObject private var viewModel = StatsViewModel()

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.background.ignoresSafeArea()

                if viewModel.sessions.isEmpty {
                    emptyState
                } else {
                    ScrollView {
                        VStack(spacing: 20) {
                            totalsCard
                            personalBestsCard
                            chartCard
                            recentGamesCard
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Stats")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    // MARK: - Empty state

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "chart.bar.fill")
                .font(.system(size: 40))
                .foregroundColor(AppTheme.textSecondary)
            Text("No games yet")
                .font(.system(.title3, design: .rounded))
                .bold()
                .foregroundColor(AppTheme.textPrimary)
            Text("Play a round of any game and your stats will show up here.")
                .font(.subheadline)
                .foregroundColor(AppTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
        }
    }

    // MARK: - Totals

    private var totalsCard: some View {
        HStack(spacing: 20) {
            statBlock(label: "GAMES PLAYED", value: "\(viewModel.totalGamesPlayed)")
            Divider().frame(height: 32).background(Color.white.opacity(0.1))
            statBlock(label: "TOTAL SCORE", value: "\(viewModel.totalScore)")
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(card)
    }

    private func statBlock(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(.title2, design: .rounded))
                .bold()
                .foregroundColor(AppTheme.textPrimary)
            Text(label)
                .font(.caption2)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Personal bests

    private var personalBestsCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("PERSONAL BESTS")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)

            ForEach(GameMode.allCases, id: \.self) { mode in
                HStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(mode.accentColor.opacity(0.18))
                            .frame(width: 36, height: 36)
                        Image(systemName: mode.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(mode.accentColor)
                    }
                    Text(mode.displayName)
                        .font(.subheadline)
                        .foregroundColor(AppTheme.textPrimary)
                    Spacer()
                    Text("\(viewModel.personalBest(for: mode))")
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .foregroundColor(AppTheme.textPrimary)
                }
            }
        }
        .padding()
        .background(card)
    }

    // MARK: - Chart

    private var chartCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("SCORE BY MODE")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)

            Chart(viewModel.totalsByMode) { item in
                BarMark(
                    x: .value("Score", item.totalScore),
                    y: .value("Mode", item.mode.displayName)
                )
                .foregroundStyle(item.mode.accentColor)
                .cornerRadius(6)
            }
            .frame(height: 140)
            .chartXAxis {
                AxisMarks { _ in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.1))
                    AxisValueLabel().foregroundStyle(AppTheme.textSecondary)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel().foregroundStyle(AppTheme.textPrimary)
                }
            }
        }
        .padding()
        .background(card)
    }

    // MARK: - Recent games

    private var recentGamesCard: some View {
        VStack(alignment: .leading, spacing: 14) {
            Text("RECENT GAMES")
                .font(.caption)
                .fontWeight(.semibold)
                .tracking(0.5)
                .foregroundColor(AppTheme.textSecondary)

            VStack(spacing: 12) {
                ForEach(viewModel.recentSessions) { session in
                    HStack(spacing: 12) {
                        Image(systemName: session.mode.icon)
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(session.mode.accentColor)
                            .frame(width: 22)

                        VStack(alignment: .leading, spacing: 2) {
                            Text(session.mode.displayName)
                                .font(.subheadline)
                                .foregroundColor(AppTheme.textPrimary)
                            Text(session.timestamp, style: .relative)
                                .font(.caption2)
                                .foregroundColor(AppTheme.textSecondary)
                        }

                        Spacer()

                        Text("\(session.score)")
                            .font(.system(.body, design: .rounded))
                            .bold()
                            .foregroundColor(AppTheme.textPrimary)
                    }
                }
            }
        }
        .padding()
        .background(card)
    }

    // MARK: - Shared card background

    private var card: some View {
        RoundedRectangle(cornerRadius: 18)
            .fill(Color.white.opacity(0.06))
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
            )
    }
}

#Preview {
    StatsView()
}
