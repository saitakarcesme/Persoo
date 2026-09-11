import SwiftUI
import WidgetKit
import ActivityKit

@main struct PersooActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RecordingAttributes.self) { context in
            HStack(spacing: 16) {
                Image(systemName: "waveform").font(.title).foregroundStyle(.mint)
                VStack(alignment: .leading) {
                    Text("Persoo dinliyor").font(.headline)
                    Text("Bitirmek için Action Button kısayolunu tekrar çalıştır.").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Text(context.attributes.startedAt, style: .timer).monospacedDigit()
            }.padding(20).activityBackgroundTint(.black).activitySystemActionForegroundColor(.white)
        } dynamicIsland: { context in
            DynamicIsland {
                DynamicIslandExpandedRegion(.leading) { Label("Persoo", systemImage: "waveform").foregroundStyle(.mint) }
                DynamicIslandExpandedRegion(.trailing) { Text(context.attributes.startedAt, style: .timer).monospacedDigit() }
                DynamicIslandExpandedRegion(.bottom) { Text("Dinliyor · Bitirmek için kısayolu tekrar çalıştır").font(.caption) }
            } compactLeading: { Image(systemName: "waveform").foregroundStyle(.mint) }
            compactTrailing: { Text(context.attributes.startedAt, style: .timer).monospacedDigit().frame(width: 44) }
            minimal: { Image(systemName: "mic.fill").foregroundStyle(.mint) }
        }
    }
}
