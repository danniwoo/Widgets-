import SwiftUI

struct ContentView: View {
    @State private var currentIndex: Int
    @State private var slideDirection: SlideDirection = .forward

    init() {
        _currentIndex = State(initialValue: QuoteManager.quoteForDate().id)
    }

    private var quote: Quote { QuoteManager.quotes[currentIndex] }
    private var isToday: Bool { currentIndex == QuoteManager.quoteForDate().id }

    private var gradientColors: [Color] {
        let palettes: [[Color]] = [
            [Color(red: 0.20, green: 0.20, blue: 0.60), Color(red: 0.55, green: 0.20, blue: 0.70)],
            [Color(red: 0.10, green: 0.50, blue: 0.60), Color(red: 0.10, green: 0.30, blue: 0.80)],
            [Color(red: 0.70, green: 0.20, blue: 0.30), Color(red: 0.90, green: 0.50, blue: 0.10)],
            [Color(red: 0.10, green: 0.55, blue: 0.35), Color(red: 0.10, green: 0.30, blue: 0.55)],
            [Color(red: 0.45, green: 0.10, blue: 0.65), Color(red: 0.20, green: 0.10, blue: 0.45)],
        ]
        return palettes[currentIndex % palettes.count]
    }

    private func showNext() {
        slideDirection = .forward
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            currentIndex = (currentIndex + 1) % QuoteManager.quotes.count
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func showPrevious() {
        slideDirection = .backward
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            currentIndex = (currentIndex - 1 + QuoteManager.quotes.count) % QuoteManager.quotes.count
        }
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
    }

    private func jumpToToday() {
        let todayIndex = QuoteManager.quoteForDate().id
        slideDirection = currentIndex < todayIndex ? .forward : .backward
        withAnimation(.spring(response: 0.38, dampingFraction: 0.82)) {
            currentIndex = todayIndex
        }
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
    }

    var body: some View {
        ZStack {
            LinearGradient(
                colors: gradientColors,
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.5), value: currentIndex)

            VStack(spacing: 0) {
                // Top bar
                HStack {
                    if !isToday {
                        Button(action: jumpToToday) {
                            Label("Today", systemImage: "calendar")
                                .font(.caption.weight(.semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(.white.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    } else {
                        Label("Today's Quote", systemImage: "star.fill")
                            .font(.caption.weight(.semibold))
                            .foregroundColor(.white.opacity(0.7))
                    }

                    Spacer()

                    ShareLink(
                        item: "\"\(quote.text)\"\n— \(quote.author)",
                        subject: Text("Daily Motivation"),
                        message: Text("Here's today's quote")
                    ) {
                        Image(systemName: "square.and.arrow.up")
                            .font(.system(size: 17, weight: .semibold))
                            .foregroundColor(.white.opacity(0.85))
                            .padding(10)
                            .background(.white.opacity(0.15))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal, 24)
                .padding(.top, 16)

                Spacer()

                // Quote card
                VStack(spacing: 28) {
                    Text("\u{201C}")
                        .font(.system(size: 100, weight: .bold, design: .serif))
                        .foregroundColor(.white.opacity(0.15))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 28)
                        .offset(y: 36)

                    Text(quote.text)
                        .font(.system(size: 23, weight: .medium, design: .serif))
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, 32)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)

                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 44, height: 2)
                        .cornerRadius(1)

                    Text("— \(quote.author)")
                        .font(.system(size: 15, weight: .regular, design: .serif))
                        .foregroundColor(.white.opacity(0.80))
                        .italic()
                }
                .id(currentIndex)
                .transition(
                    .asymmetric(
                        insertion: .move(edge: slideDirection == .forward ? .trailing : .leading)
                            .combined(with: .opacity),
                        removal: .move(edge: slideDirection == .forward ? .leading : .trailing)
                            .combined(with: .opacity)
                    )
                )

                Spacer()

                // Bottom navigation
                VStack(spacing: 16) {
                    // Progress dots (show up to 7 dots around current position)
                    HStack(spacing: 6) {
                        ForEach(dotRange, id: \.self) { i in
                            Circle()
                                .fill(Color.white.opacity(i == currentIndex ? 0.9 : 0.3))
                                .frame(width: i == currentIndex ? 8 : 5, height: i == currentIndex ? 8 : 5)
                                .animation(.spring(response: 0.3), value: currentIndex)
                        }
                    }

                    HStack(spacing: 0) {
                        Button(action: showPrevious) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .frame(width: 52, height: 52)
                                .background(.white.opacity(0.15))
                                .clipShape(Circle())
                        }

                        Spacer()

                        Text("\(currentIndex + 1) of \(QuoteManager.quotes.count)")
                            .font(.caption)
                            .foregroundColor(.white.opacity(0.45))

                        Spacer()

                        Button(action: showNext) {
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.white.opacity(0.85))
                                .frame(width: 52, height: 52)
                                .background(.white.opacity(0.15))
                                .clipShape(Circle())
                        }
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 48)
            }
        }
        .gesture(
            DragGesture(minimumDistance: 40)
                .onEnded { value in
                    if value.translation.width < 0 { showNext() }
                    else if value.translation.width > 0 { showPrevious() }
                }
        )
    }

    // Show 5 dots centered on current index
    private var dotRange: [Int] {
        let total = QuoteManager.quotes.count
        let radius = 2
        let start = max(0, min(currentIndex - radius, total - (radius * 2 + 1)))
        let end = min(total - 1, start + radius * 2)
        return Array(start...end)
    }
}

enum SlideDirection { case forward, backward }

#Preview {
    ContentView()
}
