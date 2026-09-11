import ActivityKit
import Foundation
struct RecordingAttributes: ActivityAttributes {
    struct ContentState: Codable, Hashable { var recording: Bool }
    let startedAt: Date
}
