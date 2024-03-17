//
//  SettingViewModel.swift
//  TimerNotes
//
//  Created by SIKim on 3/16/24.
//

import Foundation
import SwiftUI

final class SettingViewModel: ObservableObject {
    ///타이머 화면 항상 켜놓기 스위치 Boolean
    @AppStorage("AOD") var isAlwaysOnDisplay: Bool = false
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appStoreURLString = "https://apps.apple.com/app/id6478483182?action=write-review"
    
    //설정 바로가기
    func openSetting() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
    
    //앱 리뷰 작성 바로가기
    func openReviewWriting() {
        guard let url = URL(string: appStoreURLString) else {
            return
        }
        UIApplication.shared.open(url)
    }
}
