import ActivityKit
import SwiftUI
import WidgetKit

@main
struct FormaLiveActivityBundle: WidgetBundle {
  var body: some Widget {
    RestLiveActivityWidget()
  }
}

struct LiveActivitiesAppAttributes: ActivityAttributes, Identifiable {
  public typealias LiveDeliveryData = ContentState

  public struct ContentState: Codable, Hashable {}

  var id = UUID()
}

private let sharedDefault =
  UserDefaults(suiteName: "group.com.example.silowniaPraktyki") ?? .standard

@available(iOSApplicationExtension 16.1, *)
struct RestLiveActivityWidget: Widget {
  var body: some WidgetConfiguration {
    ActivityConfiguration(for: LiveActivitiesAppAttributes.self) { context in
      let endTime = restEndTime(for: context)
      let isComplete = isRestComplete(for: context)

      HStack(spacing: 12) {
        Image(systemName: "dumbbell.fill")
          .foregroundStyle(.green)
        VStack(alignment: .leading, spacing: 3) {
          Text(isComplete ? "PORA NA SERIĘ" : "PRZERWA")
            .font(.headline)
          Text(isComplete ? "Koniec odpoczynku" : "Do kolejnej serii")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        Spacer()
        if isComplete {
          Image(systemName: "checkmark.circle.fill")
            .foregroundStyle(.green)
        } else {
          countdown(to: endTime)
            .font(.title3.monospacedDigit().weight(.bold))
        }
      }
      .padding()
      .activityBackgroundTint(.black.opacity(0.85))
      .activitySystemActionForegroundColor(.white)
    } dynamicIsland: { context in
      let endTime = restEndTime(for: context)
      let isComplete = isRestComplete(for: context)

      return DynamicIsland {
        DynamicIslandExpandedRegion(.leading) {
          Label("FORMA", systemImage: "dumbbell.fill")
            .font(.caption.weight(.bold))
        }
        DynamicIslandExpandedRegion(.trailing) {
          if isComplete {
            Image(systemName: "checkmark.circle.fill")
              .foregroundStyle(.green)
          } else {
            countdown(to: endTime)
              .font(.title3.monospacedDigit().weight(.bold))
          }
        }
        DynamicIslandExpandedRegion(.bottom) {
          Text(isComplete ? "Pora na serię" : "Odpocznij przed kolejną serią")
            .font(.caption)
            .foregroundStyle(.secondary)
        }
      } compactLeading: {
        Image(systemName: "dumbbell.fill")
          .foregroundStyle(.green)
      } compactTrailing: {
        if isComplete {
          Image(systemName: "checkmark")
        } else {
          countdown(to: endTime)
            .font(.caption2.monospacedDigit())
        }
      } minimal: {
        Image(systemName: "dumbbell.fill")
          .foregroundStyle(.green)
      }
      .keylineTint(.green)
    }
  }
}

@available(iOSApplicationExtension 16.1, *)
private func restEndTime(
  for context: ActivityViewContext<LiveActivitiesAppAttributes>,
) -> Date {
  let timestamp = sharedDefault.double(
    forKey: context.attributes.prefixedKey("restEndTime"),
  )
  return Date(timeIntervalSince1970: timestamp / 1000)
}

@available(iOSApplicationExtension 16.1, *)
private func isRestComplete(
  for context: ActivityViewContext<LiveActivitiesAppAttributes>,
) -> Bool {
  sharedDefault.bool(
    forKey: context.attributes.prefixedKey("isComplete"),
  )
}

@available(iOSApplicationExtension 16.1, *)
private func countdown(to endTime: Date) -> some View {
  let targetTime = max(endTime, Date.now)
  return Text(timerInterval: Date.now...targetTime, countsDown: true)
}

extension LiveActivitiesAppAttributes {
  func prefixedKey(_ key: String) -> String {
    "\(id)_\(key)"
  }
}
