//
//  TimerNotesWidgetLiveActivity.swift
//  TimerNotesWidget
//
//  Created by SIKim on 2/6/24.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct TimerNotesWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var timerInWidget: Int
    }
    // Fixed non-changing properties about your activity go here!
    let categoryInWidget: String
}

struct TimerNotesWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TimerNotesWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            HStack {
                switch context.attributes.categoryInWidget {
                case "공부":
                    Image(systemName: "pencil.line")
                        .font(.largeTitle)
                case "운동":
                    Image(systemName: "dumbbell.fill")
                        .font(.largeTitle)
                case "독서":
                    Image(systemName: "book.fill")
                        .font(.largeTitle)
                case "회의":
                    Image(systemName: "person.3.fill")
                        .font(.largeTitle)
                case "게임":
                    Image(systemName: "gamecontroller.fill")
                        .font(.largeTitle)
                case "휴식":
                    Image(systemName: "hourglass.tophalf.fill")
                        .font(.largeTitle)
                case "기타":
                    Image(systemName: "ellipsis.circle")
                        .font(.largeTitle)
                default:
                    Image(systemName: "questionmark")
                        .font(.largeTitle)
                }
                
                VStack(alignment: .leading) {
                    Text("지금은")
                        .font(.caption2)
                    
                    switch context.attributes.categoryInWidget {
                    case "기타":
                        Text("\(context.attributes.categoryInWidget) 할일중")
                            .font(.title3)
                            .fontWeight(.bold)
                    default:
                        Text("\(context.attributes.categoryInWidget)중")
                            .font(.title3)
                            .fontWeight(.bold)
                    }
                    
                }
                .padding(.trailing)
                
                ProgressView(timerInterval: Date.now...Date.now + TimeInterval(context.state.timerInWidget))
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.red)
                    .frame(width: 100)
                    .padding(.leading)
            }
            .foregroundStyle(Color.white)
            .padding()
            .activityBackgroundTint(Color.init(white: 0, opacity: 0.8))
            .activitySystemActionForegroundColor(Color.black)
            
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        switch context.attributes.categoryInWidget {
                        case "공부":
                            Image(systemName: "pencil.line")
                        case "운동":
                            Image(systemName: "dumbbell.fill")
                        case "독서":
                            Image(systemName: "book.fill")
                        case "회의":
                            Image(systemName: "person.3.fill")
                        case "게임":
                            Image(systemName: "gamecontroller.fill")
                        case "휴식":
                            Image(systemName: "hourglass.tophalf.fill")
                        case "기타":
                            Image(systemName: "ellipsis.circle")
                        default:
                            Image(systemName: "questionmark")
                        }
                    }
                    .padding(.leading, 30)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text("TimerNotes")
                        .font(.caption2)
                        .fontWidth(.condensed)
                        .fontWeight(.light)
                        .padding(.trailing)
                }
                
                DynamicIslandExpandedRegion(.center) {
                    HStack {
                        Text("지금은")
                        
                        switch context.attributes.categoryInWidget {
                        case "기타":
                            Text("\(context.attributes.categoryInWidget) 할일중")
                        default:
                            Text("\(context.attributes.categoryInWidget)중")
                        }
                    }
                    .font(.footnote)
                    .fontWeight(.bold)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                        ProgressView(timerInterval: Date.now...Date.now + TimeInterval(context.state.timerInWidget))
                            .tint(.red)
                            .padding(.horizontal)
                }
            } compactLeading: {
                HStack {
                    switch context.attributes.categoryInWidget {
                    case "공부":
                        Image(systemName: "pencil.line")
                    case "운동":
                        Image(systemName: "dumbbell.fill")
                    case "독서":
                        Image(systemName: "book.fill")
                    case "회의":
                        Image(systemName: "person.3.fill")
                    case "게임":
                        Image(systemName: "gamecontroller.fill")
                    case "휴식":
                        Image(systemName: "hourglass.tophalf.fill")
                    case "기타":
                        Image(systemName: "ellipsis.circle")
                    default:
                        Image(systemName: "questionmark")
                    }
                }
            } compactTrailing: {
                ProgressView(timerInterval: Date.now...Date.now + TimeInterval(context.state.timerInWidget))
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.red)
            } minimal: {
                ProgressView(timerInterval: Date.now...Date.now + TimeInterval(context.state.timerInWidget))
                    .progressViewStyle(CircularProgressViewStyle())
                    .tint(.red)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension TimerNotesWidgetAttributes {
    fileprivate static var preview: TimerNotesWidgetAttributes {
        TimerNotesWidgetAttributes(categoryInWidget: "휴식")
    }
}

extension TimerNotesWidgetAttributes.ContentState {
    fileprivate static var smiley: TimerNotesWidgetAttributes.ContentState {
        TimerNotesWidgetAttributes.ContentState(timerInWidget: 60)
    }
}

//#Preview("Notification", as: .content, using: TimerNotesWidgetAttributes.preview) {
//   TimerNotesWidgetLiveActivity()
//} contentStates: {
//    TimerNotesWidgetAttributes.ContentState.smiley
//    TimerNotesWidgetAttributes.ContentState.starEyes
//}
