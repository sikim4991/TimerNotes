//
//  ListView.swift
//  TimerNotes
//
//  Created by SIKim on 1/29/24.
//

import SwiftUI

struct ListView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        entity: TimerCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TimerCoreData.startDate, ascending: false)]
    ) var timerCoreDatas: FetchedResults<TimerCoreData>
    @ObservedObject var listViewModel: ListViewModel
    
    var body: some View {
        //타이머 시작 날짜, 타이머 설정 시간 리스트
        List {
            ForEach(listViewModel.dateTitle ?? [], id: \.self) { date in
                Section {
                    ForEach(timerCoreDatas) { data in
                        if date == Calendar.current.startOfDay(for: data.startDate!) {
                            HStack {
                                Text("\(data.timeSet / 60)분 \(data.timeSet % 60)초 \(data.category ?? "")")
                                Spacer()
                                Text(data.startDate!, formatter: dateFormatter)
                                    .font(.caption)
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    }
                    //밀어서 혹은 Edit 버튼으로 삭제
                    .onDelete(perform: { (offsets: IndexSet) in
                        withAnimation {
                            listViewModel.removeDateTitle(offsets: offsets, timerCoreDatas: timerCoreDatas)
                            PersistenceController.shared.removeItem(offsets: offsets, timerCoreDatas: timerCoreDatas)
                        }
                    })
                } header: {
                        Text(date, formatter: dateTitleFormatter)
                }
            }
        }
        .onAppear {
            for data in timerCoreDatas {
                //CoreData에 시작날짜 기준으로 Header 생성
                listViewModel.addDateTitle(date: data.startDate ?? Date())
            }
        }
        .toolbar {
            EditButton()
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YYYY년 MM월 dd일 HH:mm"
    return formatter
}()

private let dateTitleFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YYYY년 MM월 dd일"
    return formatter
}()

#Preview {
    ListView(listViewModel: ListViewModel())
}
