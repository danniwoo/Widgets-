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

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(entry.quote.text)
                .font(.system(size: 11, weight: .medium, design: .serif))
                .lineLimit(3)
                .minimumScaleFactor(0.7)
                .widgetAccentable()
            Text("— \(entry.quote.author)")
                .font(.system(size: 9, weight: .regular))
                .opacity(0.75)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        .padding(.horizontal, 2)
    }
}

struct AccessoryInlineView: View {
    let entry: QuoteEntry

    var body: some View {
        Text("\(entry.quote.text) — \(entry.quote.author)")
            .widgetAccentable()
    }
}

struct AccessoryCircularView: View {
    let entry: QuoteEntry

    private var initials: String {
        entry.quote.author
            .components(separatedBy: " ")
            .compactMap { $0.first }
            .prefix(2)
            .map(String.init)
            .joined()
    }

    var body: some View {
        ZStack {
            AccessoryWidgetBackground()
            VStack(spacing: 1) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 14))
                    .widgetAccentable()
                Text(initials)
                    .font(.system(size: 10, weight: .bold))
                    .lineLimit(1)
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

#Preview(as: .accessoryRectangular) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
    QuoteEntry(date: .now, quote: QuoteManager.quotes[1])
}

#Preview(as: .accessoryInline) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
}

#Preview(as: .accessoryCircular) {
    MotivationWidget()
} timeline: {
    QuoteEntry(date: .now, quote: QuoteManager.quotes[0])
}
