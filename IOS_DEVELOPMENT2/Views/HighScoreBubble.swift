import SwiftUI

struct HighScoreBubble: View {
    let score: Int
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "star.fill")
                .foregroundColor(.yellow)
                .font(.system(size: 11, weight: .bold))
            
            Text("\(score)")
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(.white)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(Color.black.opacity(0.35))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.15), lineWidth: 1)
                )
        )
        .shadow(color: Color.black.opacity(0.2), radius: 3, x: 0, y: 2)
    }
}

#Preview {
    ZStack {
        Color.gray.ignoresSafeArea()
        HighScoreBubble(score: 42)
    }
}
