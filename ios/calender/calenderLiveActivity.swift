//
//  calenderLiveActivity.swift
//  calender
//
//  Created by apple on 16/01/2025.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct calenderAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct calenderLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: calenderAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension calenderAttributes {
    fileprivate static var preview: calenderAttributes {
        calenderAttributes(name: "World")
    }
}

extension calenderAttributes.ContentState {
    fileprivate static var smiley: calenderAttributes.ContentState {
        calenderAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: calenderAttributes.ContentState {
         calenderAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: calenderAttributes.preview) {
   calenderLiveActivity()
} contentStates: {
    calenderAttributes.ContentState.smiley
    calenderAttributes.ContentState.starEyes
}
