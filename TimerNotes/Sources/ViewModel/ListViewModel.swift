//
//  ListViewModel.swift
//  TimerNotes
//
//  Created by SIKim on 3/12/24.
//

import Foundation
import SwiftUI

final class ListViewModel: ObservableObject {
    ///모든 데이터 보기 리스트 Header
    @Published var dateTitle: [Date]?
    
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
    func removeDateTitle(offsets: IndexSet, timerCoreDatas: FetchedResults<TimerCoreData>) {
        for deleteData in offsets.map({ timerCoreDatas[$0] }) {
            var containCount: Int = 0
            for temp in timerCoreDatas {
                if Calendar.current.startOfDay(for: deleteData.startDate!) == Calendar.current.startOfDay(for: temp.startDate!) {
                    containCount += 1
                }
            }
            
            if containCount == 1 {
                
                
                if let dateTitle {
                    if dateTitle.contains(Calendar.current.startOfDay(for: deleteData.startDate!)) {
                        self.dateTitle = dateTitle.filter { $0 != Calendar.current.startOfDay(for: deleteData.startDate!) }
                    }
                }
            }
        }
    }
    
    //모든 데이터 지우기 실행 시, 모든 Header 삭제
    func removeDateTitleAll() {
        dateTitle = nil
    }
}
