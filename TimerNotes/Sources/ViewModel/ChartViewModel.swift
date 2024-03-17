//
//  ChartViewModel.swift
//  TimerNotes
//
//  Created by SIKim on 3/12/24.
//

import Foundation
import SwiftUI
import CoreData

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

final class ChartViewModel: ObservableObject {
    ///모든 데이터 삭제 Alert Boolean
    @Published var isShowingRemoveAllAlert: Bool = false
    ///앱 종료 알림 Alert Boolean
    @Published var isShowingExitAlert: Bool = false
    ///기간 설정 (1일, 1주일, 1개월) Int
    @Published var selectedChart: Int = 1
    ///날짜 설정
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    ///카테고리 설정
    @Published var selectedCategory: CategoryForChart = .all
    
    func filteredCoreDataInChart(element: FetchedResults<TimerCoreData>.Element) -> Bool {
        //기간, 카테고리, 날짜 조건에 따른 필터
        switch (selectedChart) {
        case 1:
            switch (selectedCategory) {
            case .all:
                Calendar.current.startOfDay(for: element.startDate!) == selectedDate
            default:
                (Calendar.current.startOfDay(for: element.startDate!) == selectedDate) && (element.category! == selectedCategory.rawValue)
            }
        case 2:
            switch (selectedCategory) {
            case .all:
                (Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)
            default:
                ((Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)) && (element.category! == selectedCategory.rawValue)
            }
        case 3:
            switch (selectedCategory) {
            case .all:
                (Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)
            default:
                ((Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)) && (element.category! == selectedCategory.rawValue)
            }
        default:
            Calendar.current.startOfDay(for: element.startDate!) == Calendar.current.startOfDay(for: selectedDate)
        }
    }
    
    func filteredCoreDataInList(element: FetchedResults<TimerCoreData>.Element) -> Bool {
        switch (selectedChart) {
        case 1:
            Calendar.current.startOfDay(for: element.startDate!) == selectedDate
        case 2:
            (Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)
        case 3:
            (Calendar.current.startOfDay(for: element.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: element.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)
        default:
            Calendar.current.startOfDay(for: element.startDate!) == selectedDate
        }
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
    
    func exitApp() {
        UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            exit(0)
        }
    }
}
