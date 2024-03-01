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

final class TimerDataStore: AppDelegate, ObservableObject {
    ///타이머 화면 항상 켜놓기 스위치 Boolean
    @AppStorage("AOD") var isAlwaysOnDisplay: Bool = false
    ///타이머 각도 = 시간
    @Published var angle: Int = 0
    ///모든 데이터 보기 리스트 Header
    @Published var dateTitle: [Date]?
    
    let notificationCenter = UNUserNotificationCenter.current()
    var activity: Activity<TimerNotesWidgetAttributes>? = nil
    
    //모든 데이터 보기 리스트 Header 생성
    func addDateTitle(date: Date) {
        if let dateTitle {
            if !dateTitle.contains(Calendar.current.startOfDay(for: date)) {
                self.dateTitle?.append((Calendar.current.startOfDay(for: date)))
            }
        } else {
            self.dateTitle = [Calendar.current.startOfDay(for: date)]
        }
        dateTitle?.sort { $0 > $1 }
    }
    
    //모든 데이터 보기 리스트에서 해당 날짜 데이터가 없으면 Header 삭제
    func removeDateTitle(date: Date) {
        if let dateTitle {
            if dateTitle.contains(Calendar.current.startOfDay(for: date)) {
                self.dateTitle = dateTitle.filter { $0 != Calendar.current.startOfDay(for: date) }
            }
        }
    }
    
    //모든 데이터 지우기 실행 시, 모든 Header 삭제
    func removeDateTitleAll() {
        dateTitle = nil
    }
    
    //타이머 실행 시, Live Activity 실행
    func startTimerInLiveActivity(category: String) {
        if ActivityAuthorizationInfo().areActivitiesEnabled {
            do {
                let timerNotesWidget = TimerNotesWidgetAttributes(categoryInWidget: category)
                let timerState = TimerNotesWidgetAttributes.ContentState(timerInWidget: self.angle)
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
    
    //타이머 기록들의 통계 ( 1일, 1주일, 1개월 )
    func makeAverageDatas(selectedChart: Int, datas: [TimerCoreData], category: CategoryForChart) -> String {
        var sum: Int64 = 0
        var count: Int64 = 0
        var result: Double = 0
        var tempDate: Date = Date() + 1
        
        switch (selectedChart) {
        case 1:
            switch (category) {
            case .all:
                for data in datas {
                    sum += data.timeSet
                }
                if sum == 0 {
                    return "-"
                } else {
                    return "\(sum / 3600)시간 \((sum % 3600) / 60)분 \((sum % 3600) % 60)초"
                }
            default:
                for data in datas.filter({ $0.category! == category.rawValue }) {
                    sum += data.timeSet
                }
                if sum == 0 {
                    return "-"
                } else {
                    return "\(sum / 3600)시간 \((sum % 3600) / 60)분 \((sum % 3600) % 60)초"
                }
            }
        default:
            switch (category) {
            case .all:
                for data in datas {
                    sum += data.timeSet
                    if tempDate != Calendar.current.startOfDay(for: data.startDate!) {
                        count += 1
                        tempDate = Calendar.current.startOfDay(for: data.startDate!)
                    }
                }
                result = Double(sum) / Double(count != 0 ? count : 1)
                result = round(result)
                if result == 0 {
                    return "-"
                } else {
                    return "기록된 일수 \(count)일 : 약 \(Int(result) / 3600)시간 \((Int(result) % 3600) / 60)분 \((Int(result) % 3600) % 60)초/일"
                }
            default:
                for data in datas.filter({ $0.category! == category.rawValue }) {
                    sum += data.timeSet
                    if tempDate != Calendar.current.startOfDay(for: data.startDate!) {
                        count += 1
                        tempDate = Calendar.current.startOfDay(for: data.startDate!)
                    }
                }
                result = Double(sum) / Double(count != 0 ? count : 1)
                result = round(result)
                if result == 0 {
                    return "-"
                } else {
                    return "기록된 일수 \(count)일 : 약 \(Int(result) / 3600)시간 \((Int(result) % 3600) / 60)분 \((Int(result) % 3600) % 60)초/일"
                }
            }
        }
    }
}
