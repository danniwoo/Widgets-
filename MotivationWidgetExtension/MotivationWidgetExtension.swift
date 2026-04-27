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

// MARK: - Widget Views

struct AccessoryRectangularView: View {
    let entry: QuoteEntry

    // Truncate at a word boundary so we never cut mid-word
    private var displayText: String {
        let text = entry.quote.text
        let limit = 72
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
                // .footnote = 13pt — readable at a glance; semibold for contrast
                // default (sans-serif) design is more legible than serif at small sizes
                .font(.system(.footnote, design: .default, weight: .semibold))
                .lineLimit(2)
                .minimumScaleFactor(0.9)
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

    // Inline only has ~35 chars visible; show the opening words
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
                // Large opening quote mark is instantly recognisable as a quote app
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
        switch family {
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
}

// MARK: - Widget Configuration

struct MotivationWidget: Widget {
    let kind: String = "MotivationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: QuoteTimelineProvider()) { entry in
            MotivationWidgetEntryView(entry: entry)
                .modifier(ContainerBackgroundModifier())
        }
        .configurationDisplayName("Daily Motivation")
        .description("A new motivational quote every day.")
        .supportedFamilies([
            .accessoryRectangular,
            .accessoryInline,
            .accessoryCircular,
        ])
    }
}

// iOS 16 compatibility: containerBackground is iOS 17+
struct ContainerBackgroundModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 17.0, *) {
            content.containerBackground(.fill.tertiary, for: .widget)
        } else {
            content
        }
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
