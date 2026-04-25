import SwiftUI

struct ContentView: View {
    private let quote = QuoteManager.quoteForDate()

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color(red: 0.20, green: 0.20, blue: 0.60), Color(red: 0.55, green: 0.20, blue: 0.70)],
            [Color(red: 0.10, green: 0.50, blue: 0.60), Color(red: 0.10, green: 0.30, blue: 0.80)],
            [Color(red: 0.70, green: 0.20, blue: 0.30), Color(red: 0.90, green: 0.50, blue: 0.10)],
            [Color(red: 0.10, green: 0.55, blue: 0.35), Color(red: 0.10, green: 0.30, blue: 0.55)],
            [Color(red: 0.45, green: 0.10, blue: 0.65), Color(red: 0.20, green: 0.10, blue: 0.45)],
        ]
        return palettes[quote.id % palettes.count]
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Text("\u{201C}")
                    .font(.system(size: 120, weight: .bold, design: .serif))
                    .foregroundColor(.white.opacity(0.15))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 28)
                    .offset(y: 40)

                Text(quote.text)
                    .font(.system(size: 24, weight: .medium, design: .serif))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .lineSpacing(6)
                    .padding(.horizontal, 32)
                    .shadow(color: .black.opacity(0.25), radius: 4, x: 0, y: 2)

                Rectangle()
                    .fill(Color.white.opacity(0.40))
                    .frame(width: 48, height: 2)
                    .cornerRadius(1)

                Text("— \(quote.author)")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundColor(.white.opacity(0.80))
                    .italic()

                Spacer()

                Text("Quote refreshes daily")
                    .font(.caption2)
                    .foregroundColor(.white.opacity(0.40))
                    .padding(.bottom, 16)
            }
        }
    }
}

#Preview {
    ContentView()
}
