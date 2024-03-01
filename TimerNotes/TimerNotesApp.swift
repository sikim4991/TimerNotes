//
//  TimerNotesApp.swift
//  TimerNotes
//
//  Created by SIKim on 12/28/23.
//

import SwiftUI
import UIKit
import ActivityKit

//앱 foreground 에서 notification을 받기 위함
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .badge, .sound])
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    //    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
    //        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    //    }
    //
    //    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
    //
    //    }
}

//타이머 실행 중 사용자가 앱을 종료하면 대기 중이던 notification과 실행 중인 live activity 삭제
extension AppDelegate {
    func applicationWillTerminate(_ application: UIApplication) {
        let semaphore = DispatchSemaphore(value: 0)
        
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        
        Task.detached {
            for activity in Activity<TimerNotesWidgetAttributes>.activities {
                await activity.end(nil, dismissalPolicy: .immediate)
            }
            semaphore.signal()
        }
        semaphore.wait()
    }
}

@main
struct TimerNotesApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    @StateObject private var timerDataStore: TimerDataStore = TimerDataStore()
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(timerDataStore)
        }
    }
}
