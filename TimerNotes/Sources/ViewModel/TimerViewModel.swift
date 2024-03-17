//
//  TimerDataStore.swift
//  TimerNotes
//
//  Created by SIKim on 1/18/24.
//

import Foundation
import SwiftUI
import UserNotifications
import ActivityKit

final class TimerViewModel: ObservableObject {
    ///첫 알림 거부 시, Alert을 띄우기 위한 Boolean
    @AppStorage("notification") var isFirstCheckNotification: Bool = true
    ///TimerData 객체 생성
    @Published var timerData: TimerData = TimerData()
    ///타이머 시작 유무 Boolean
    @Published var isStart: Bool = false
    ///타이머 기록 On/Off Boolean
    @Published var isOnRecord: Bool = false
    ///첫 알림 거부 Alert Boolean
    @Published var isShowingNotifyAlert: Bool = false
    
    ///타이머 퍼블리셔 - 1초
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    let notificationCenter = UNUserNotificationCenter.current()
    var activity: Activity<TimerNotesWidgetAttributes>? = nil
    
    //타이머 실행 시, Live Activity 실행
    func startTimerInLiveActivity(category: String) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let timerNotesWidget = TimerNotesWidgetAttributes(categoryInWidget: category)
                let timerState = TimerNotesWidgetAttributes.ContentState(timerInWidget: self.timerData.angle)
                self.activity = try Activity.request(attributes: timerNotesWidget, content: .init(state: timerState, staleDate: nil))
            } catch {
                print(error)
            }
        }
    }
    
    //Live Activity 삭제
    func endTimerInLiveActivity() {
        guard let activity else {
            return
        }
        
        Task {
            let timerState = TimerNotesWidgetAttributes.ContentState(timerInWidget: 0)
            await activity.end(.init(state: timerState, staleDate: nil), dismissalPolicy: .immediate)
        }
    }
    
    //타이머 알림 요청 및 추가
    func notifcation(category: String?, timeInterval: TimeInterval) {
        let content = UNMutableNotificationContent()
        
        content.sound = UNNotificationSound(named: UNNotificationSoundName(rawValue: "notificationSound.wav"))
        content.title = "타이머 종료"
        if let category {
            content.body = "\(category) 시간이 기록 되었습니다"
        } else {
            content.body = "타이머가 종료되었습니다."
        }
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        let req = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        self.notificationCenter.add(req)
    }
}
