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
    @EnvironmentObject private var timerDataStore: TimerDataStore
    
    var body: some View {
        //타이머 시작 날짜, 타이머 설정 시간 리스트
        List {
            ForEach(timerDataStore.dateTitle ?? [], id: \.self) { date in
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
                            for deleteData in offsets.map({ timerCoreDatas[$0] }) {
                                var containCount: Int = 0
                                for temp in timerCoreDatas {
                                    if Calendar.current.startOfDay(for: deleteData.startDate!) == Calendar.current.startOfDay(for: temp.startDate!) {
                                        containCount += 1
                                    }
                                }
                                
                                if containCount == 1 {
                                    timerDataStore.removeDateTitle(date: deleteData.startDate!)
                                }
                            }
                            offsets.map { timerCoreDatas[$0] }.forEach(viewContext.delete)
                            do {
                                try viewContext.save()
                            } catch {
                                // Replace this implementation with code to handle the error appropriately.
                                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                                let nsError = error as NSError
                                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
                            }
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
                timerDataStore.addDateTitle(date: data.startDate ?? Date())
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
    ListView()
}
