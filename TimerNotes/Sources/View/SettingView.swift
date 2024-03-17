//
//  SettingView.swift
//  TimerNotes
//
//  Created by SIKim on 1/16/24.
//

import SwiftUI
import StoreKit

struct SettingView: View {
    @ObservedObject var settingViewModel: SettingViewModel
    @Environment(\.requestReview) var requestReview
    @Environment(\.colorScheme) private var colorScheme
        
    var body: some View {
        List {
            Section(header: Text("설정"), footer:
                        HStack {
                Spacer()
                Text("소리/진동은 측면 버튼으로 조절")
            }) {
                Toggle("디스플레이 항상 켜놓기", isOn: $settingViewModel.isAlwaysOnDisplay)
                Button("설정 바로가기") {
                    settingViewModel.openSetting()
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
            }
            
            Section("정보") {
                Button("앱 평가하기") {
                    requestReview()
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                
                Button("앱 리뷰 작성하기") {
                    settingViewModel.openReviewWriting()
                }
                .foregroundStyle(colorScheme == .dark ? Color.white : Color.black)
                
                HStack {
                    Text("현재 버전")
                    Spacer()
                    Text(settingViewModel.currentVersion ?? "Error check version")
                        .font(.callout)
                        .foregroundStyle(.gray)
                }
            }
        }
    }
}

#Preview {
    SettingView(settingViewModel: SettingViewModel())
}
