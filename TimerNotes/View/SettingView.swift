//
//  SettingView.swift
//  TimerNotes
//
//  Created by SIKim on 1/16/24.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    @EnvironmentObject private var timerDataStore: TimerDataStore
    @Environment(\.requestReview) var requestReview
    @Environment(\.colorScheme) private var colorScheme
    
    let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    let appStoreURLString = "https://apps.apple.com/app/id6478483182?action=write-review"
    
    var body: some View {
        List {
            Section(header: Text("설정"), footer:
                        HStack {
                Spacer()
                Text("소리/진동은 측면 버튼으로 조절")
            }) {
                Toggle("디스플레이 항상 켜놓기", isOn: $timerDataStore.isAlwaysOnDisplay)
                Button("설정 바로가기") {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!)
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            }
            
            Section("정보") {
                Button("앱 평가하기") {
                    requestReview()
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                
                Button("앱 리뷰 작성하기") {
                    guard let url = URL(string: appStoreURLString) else {
                        return
                    }
                    UIApplication.shared.open(url)
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                
                HStack {
                    Text("현재 버전")
                    Spacer()
                    Text(currentVersion ?? "Error check version")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    SettingView()
}
