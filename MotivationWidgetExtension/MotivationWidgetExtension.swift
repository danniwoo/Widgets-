import WidgetKit
import SwiftUI

// MARK: - Timeline Entry

struct QuoteEntry: TimelineEntry {
    let date: Date
    let quote: Quote
}

// MARK: - Timeline Provider

struct QuoteTimelineProvider: TimelineProvider {
    typealias Entry = QuoteEntry

    func placeholder(in context: Context) -> QuoteEntry {
        QuoteEntry(date: Date(), quote: QuoteManager.quotes[0])
    }

    func getSnapshot(in context: Context, completion: @escaping (QuoteEntry) -> Void) {
        completion(QuoteEntry(date: Date(), quote: QuoteManager.quoteForDate()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<QuoteEntry>) -> Void) {
        var entries: [QuoteEntry] = []
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        for dayOffset in 0..<7 {
            guard let entryDate = calendar.date(byAdding: .day, value: dayOffset, to: today) else {
                continue
            }
            entries.append(QuoteEntry(date: entryDate, quote: QuoteManager.quoteForDate(entryDate)))
        }

        completion(Timeline(entries: entries, policy: .atEnd))
    }
}

// MARK: - Home Screen Widget Views

struct SystemSmallView: View {
    let entry: QuoteEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(entry.quote.text)
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(7)
                .minimumScaleFactor(0.72)
                .lineSpacing(2)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)

            Text(entry.quote.author)
                .font(.system(size: 9, weight: .regular))
                .foregroundColor(.white.opacity(0.60))
                .italic()
                .lineLimit(1)
        }
        .padding(14)
        // Decorative quote mark as non-layout overlay so it never steals vertical space
        .overlay(alignment: .topLeading) {
            Text("\u{201C}")
                .font(.system(size: 56, weight: .black, design: .serif))
                .foregroundColor(.white.opacity(0.12))
                .offset(x: 8, y: -6)
        }
    }
}

struct SystemMediumView: View {
    let entry: QuoteEntry

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
            // Left column: large decorative quote mark
            Text("\u{201C}")
                .font(.system(size: 88, weight: .black, design: .serif))
                .foregroundColor(.white.opacity(0.20))
                .frame(width: 60, alignment: .leading)
                .padding(.leading, 16)
                .padding(.top, 8)

            // Right column: quote content
            VStack(alignment: .leading, spacing: 6) {
                Text(entry.quote.text)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.white)
                    .lineLimit(6)
                    .minimumScaleFactor(0.80)
                    .lineSpacing(2)
                    .frame(maxHeight: .infinity, alignment: .topLeading)

                HStack(spacing: 5) {
                    Rectangle()
                        .fill(Color.white.opacity(0.35))
                        .frame(width: 16, height: 1)
                        .cornerRadius(1)
                    Text(entry.quote.author)
                        .font(.system(size: 10, weight: .regular))
                        .foregroundColor(.white.opacity(0.60))
                        .italic()
                        .lineLimit(1)
                }
            }
            .padding(.vertical, 14)
            .padding(.trailing, 18)
        }
    }
}

// MARK: - Lock Screen Widget Views

struct AccessoryRectangularView: View {
    let entry: QuoteEntry

    // Truncate at a word boundary so we never cut mid-word
    private var displayText: String {
        let text = entry.quote.text
        let limit = 90
        guard text.count > limit else { return text }
        let prefix = String(text.prefix(limit))
        if let cut = prefix.lastIndex(of: " ") {
            return String(prefix[..<cut]) + "…"
        }
        return prefix + "…"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 3) {
            Text(displayText)
                .font(.system(.footnote, design: .default, weight: .semibold))
                .lineLimit(3)
                .minimumScaleFactor(0.88)
                .widgetAccentable()
                .fixedSize(horizontal: false, vertical: false)

            Text(entry.quote.author)
                .font(.system(.caption2, design: .default, weight: .regular))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.tail)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

struct AccessoryInlineView: View {
    let entry: QuoteEntry

    private var inlineText: String {
        let text = entry.quote.text
        let limit = 38
        guard text.count > limit else { return "\u{201C}\(text)\u{201D}" }
        let prefix = String(text.prefix(limit))
        if let cut = prefix.lastIndex(of: " ") {
            return "\u{201C}" + String(prefix[..<cut]) + "…"
        }
        return "\u{201C}" + prefix + "…"
    }

    var body: some View {
        Text(inlineText)
            .widgetAccentable()
    }
}

struct AccessoryCircularView: View {
    let entry: QuoteEntry

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 2) {
                Text("\u{201C}")
                    .font(.system(size: 28, weight: .black, design: .serif))
                    .widgetAccentable()
                    .offset(y: 4)
                Text("Daily")
                    .font(.system(size: 8, weight: .semibold))
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// MARK: - Entry View (dispatches per family)

struct MotivationWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: QuoteEntry

    var body: some View {
        Group {
            switch family {
            case .systemSmall:
                SystemSmallView(entry: entry)
            case .systemMedium:
                SystemMediumView(entry: entry)
            case .accessoryRectangular:
                AccessoryRectangularView(entry: entry)
            case .accessoryInline:
                AccessoryInlineView(entry: entry)
            case .accessoryCircular:
                AccessoryCircularView(entry: entry)
            @unknown default:
                AccessoryRectangularView(entry: entry)
            }
        }
        .modifier(WidgetBackgroundModifier(
            family: family,
            gradientColors: QuoteManager.gradientColors(for: entry.quote.id)
        ))
    }
}

// Applies gradient background for home screen families,
// system vibrancy background for lock screen families.
struct WidgetBackgroundModifier: ViewModifier {
    let family: WidgetFamily
    let gradientColors: [Color]

    private var isHomeScreen: Bool {
        family == .systemSmall || family == .systemMedium || family == .systemLarge
    }

    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            if isHomeScreen {
                content.containerBackground(for: .widget) {
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            } else {
                content.containerBackground(.fill.tertiary, for: .widget)
            }
        } else {
            if isHomeScreen {
                ZStack {
                    LinearGradient(
                        colors: gradientColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                    content
                }
            } else {
                content
            }
        }
    }
}

// MARK: - Widget Configuration

struct MotivationWidget: Widget {
    let kind: String = "MotivationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteTimelineProvider()) { entry in
            MotivationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Daily Motivation")
        .description("A new motivational quote every day.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
        ])
    }
}

// MARK: - Widget Bundle

@main
struct MotivationWidgetBundle: WidgetBundle {
    var body: some Widget {
        MotivationWidget()
    }
}

// MARK: - Previews
@available(iOS 17.0, *)
#Preview(as: .accessoryRectangular) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
    QuoteEntry(date: .now, quote: QuoteManager.quotes[1])
}

@available(iOS 17.0, *)
#Preview(as: .accessoryInline) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
}

@available(iOS 17.0, *)
#Preview(as: .accessoryCircular) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
}
