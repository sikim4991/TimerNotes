//
//  TimerData.swift
//  TimerNotes
//
//  Created by SIKim on 1/17/24.
//

import Foundation
import SwiftUI

///타이머 활동 카테고리
enum Category: LocalizedStringResource, Equatable, CaseIterable {
    case study = "공부"
    case exercise = "운동"
    case reading = "독서"
    case meeting = "회의"
    case game = "게임"
    case rest = "휴식"
    case etc = "기타"
}

struct TimerData {
    ///타이머 각도 = 시간
    var angle: Int = 0
    ///마지막으로 설정한 각도 = 시간
    var lastAngle: Int = 0
    ///타이머 카테고리
    var selectedCategory: Category = .study
    ///타이머 끝나는 날짜
    var endDate: Date = Date()
}
