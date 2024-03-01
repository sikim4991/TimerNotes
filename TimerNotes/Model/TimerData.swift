//
//  TimerData.swift
//  TimerNotes
//
//  Created by SIKim on 1/17/24.
//

import Foundation
import SwiftUI

///타이머 활동 카테고리
enum Category: String, Equatable, CaseIterable {
    case study = "공부"
    case exercise = "운동"
    case reading = "독서"
    case meeting = "회의"
    case game = "게임"
    case rest = "휴식"
    case etc = "기타"
}

///통계에서 확인되는 카테고리
enum CategoryForChart: String, Equatable, CaseIterable {
    case all = "전체"
    case study = "공부"
    case exercise = "운동"
    case reading = "독서"
    case meeting = "회의"
    case game = "게임"
    case rest = "휴식"
    case etc = "기타"
}
