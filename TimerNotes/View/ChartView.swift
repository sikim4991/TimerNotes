//
//  ChartListView.swift
//  TimerNotes
//
//  Created by SIKim on 1/22/24.
//

import SwiftUI
import Charts
import CoreData

struct ChartView: View {
    @EnvironmentObject private var timerDataStore: TimerDataStore
    @FetchRequest(
        entity: TimerCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TimerCoreData.startDate, ascending: false)]
    ) var timerCoreDatas: FetchedResults<TimerCoreData>
    ///모든 데이터 삭제 Alert Boolean
    @State private var isShowingRemoveAllAlert: Bool = false
    ///앱 종료 알림 Alert Boolean
    @State private var isShowingExitAlert: Bool = false
    ///기간 설정 (1일, 1주일, 1개월) Int
    @State private var selectedChart: Int = 1
    ///날짜 설정
    @State private var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    ///카테고리 설정
    @State private var selectedCategory: CategoryForChart = .all
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //기간 설정 Picker 뷰
                Picker(selection: $selectedChart, label: Text("Picker")) {
                    Text("1일").tag(1)
                    Text("1주일").tag(2)
                    Text("1개월").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                //기간 설정에 따른 날짜 Text 뷰 및 달력 Picker 버튼
                switch (selectedChart) {
                case 1:
                    HStack {
                        Text(selectedDate, formatter: dateTitleFormatter)
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $selectedDate, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko"))
                                    .blendMode(.destinationOver)
                            }
                    }
                    .font(.footnote)
                    .padding(.horizontal)
                case 2:
                    HStack {
                        Text("\(Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!, formatter: dateTitleFormatter) ~ \(selectedDate, formatter: dateTitleFormatter)")
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $selectedDate, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko"))
                                    .blendMode(.destinationOver)
                            }
                    }
                    .padding(.horizontal)
                    .font(.footnote)
                case 3:
                    HStack {
                        Text("\(Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!, formatter: dateTitleFormatter) ~ \(selectedDate, formatter: dateTitleFormatter)")
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $selectedDate, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko"))
                                    .blendMode(.destinationOver)
                            }
                    }
                    .padding(.horizontal)
                    .font(.footnote)
                default:
                    Text("")
                }
                //막대 그래프 뷰
                Chart(timerCoreDatas.filter {
                    //기간, 카테고리, 날짜 조건에 따른 필터
                    switch (selectedChart) {
                    case 1:
                        switch (selectedCategory) {
                        case .all:
                            Calendar.current.startOfDay(for: $0.startDate!) == selectedDate
                        default:
                            (Calendar.current.startOfDay(for: $0.startDate!) == selectedDate) && ($0.category! == selectedCategory.rawValue)
                        }
                    case 2:
                        switch (selectedCategory) {
                        case .all:
                            (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)
                        default:
                            ((Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)) && ($0.category! == selectedCategory.rawValue)
                        }
                    case 3:
                        switch (selectedCategory) {
                        case .all:
                            (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)
                        default:
                            ((Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)) && ($0.category! == selectedCategory.rawValue)
                        }
                    default:
                        Calendar.current.startOfDay(for: $0.startDate!) == Calendar.current.startOfDay(for: selectedDate)
                    }
                }) {
                    //기간 설정에 따른 x, y 값 변경
                    switch (selectedChart) {
                    case 1:
                        BarMark(
                            x: .value("카테고리", $0.category!),
                            y: .value("타이머기록", $0.timeSet)
                        )
                    default:
                        BarMark(
                            x: .value("날짜", $0.startDate!, unit: .day),
                            y: .value("타이머기록",  $0.timeSet)
                        )
                    }
                }
                .chartXAxisLabel(selectedChart == 1 ? "분류" : "날짜")
                .chartYAxisLabel("타이머기록")
                .chartYScale(domain: [0, 64800])
                .chartXAxis {
                    AxisMarks { value in
                        //x축이 날짜일 경우 중심선 날짜별로 그리기
                        if let date = value.as(Date.self) {
                            let hour = Calendar.current.component(.hour, from: date)
                            AxisValueLabel {
                                VStack(alignment: .leading) {
                                    if hour == 0 {
                                        Text(date, formatter: dayFormatter)
                                    }
                                    if value.index == 0 {
                                        Text(date, formatter: monthFormatter)
                                    }
                                }
                            }
                            
                            AxisGridLine()
                            AxisTick()
                        }
                        
                        //x축이 카테고리일 경우 중심선 카테고리별로 그리기
                        if let category = value.as(String.self) {
                            AxisValueLabel {
                                VStack {
                                    Text(category)
                                }
                            }
                            
                            AxisGridLine()
                            AxisTick()
                        }
                    }
                }
                .chartYAxis {
                    //y축 최대값 (18시간)일 때 숫자 및 중심선, 단위 그리기
                    AxisMarks(values: [64800]) { value in
                        if let second = value.as(Int.self) {
                            AxisValueLabel {
                                HStack {
                                    Text("\(second / 3600)시간")
                                }
                            }
                            AxisGridLine()
                        }
                    }
                    
                    //y축 3시간 마다 숫자 및 중심선 그리기
                    AxisMarks(values: [0, 10800, 21600, 32400, 43200, 54000]) { value in
                        if let second = value.as(Int.self) {
                            AxisValueLabel {
                                HStack {
                                    Text("\(second / 3600)")
                                }
                            }
                            AxisGridLine()
                        }
                    }
                }
                .foregroundStyle(Color.red)
                .frame(height: 300)
                .padding()
                .overlay {
                    //데이터가 없을 때의 조건으로 데이터 없음을 표시
                    switch (selectedChart) {
                    case 1:
                        switch (selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ Calendar.current.startOfDay(for: $0.startDate!) == selectedDate }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) == selectedDate) && ($0.category! == selectedCategory.rawValue) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    case 2:
                        switch (selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ ((Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)) && ($0.category! == selectedCategory.rawValue) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    case 3:
                        switch (selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ ((Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)) && ($0.category! == selectedCategory.rawValue) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    default:
                        if timerCoreDatas.filter({ Calendar.current.startOfDay(for: $0.startDate!) == Calendar.current.startOfDay(for: selectedDate) }).isEmpty {
                            Text("데이터가 없습니다.")
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                
                //카테고리 Picker 뷰
                Picker(selection: $selectedCategory, label: Text("CategoryForChart")) {
                    ForEach(CategoryForChart.allCases, id: \.self) { category in
                        Text(category.rawValue)
                            .tag(category)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom)
                
                List {
                    //기간 설정에 따른 Header
                    Section(selectedChart == 1 ? "타이머 기록 시간" : "타이머 기록 시간(평균)") {
                        //기간, 날짜 조건에 따른 Text 리스트
                        ForEach (CategoryForChart.allCases, id: \.self) { category in
                            HStack {
                                Text("\(category.rawValue) ")
                                    .font(.callout)
                                Spacer()
                                Text(timerDataStore.makeAverageDatas(
                                    selectedChart: selectedChart,
                                    datas: timerCoreDatas.filter {
                                        switch (selectedChart) {
                                        case 1:
                                            Calendar.current.startOfDay(for: $0.startDate!) == selectedDate
                                        case 2:
                                            (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: selectedDate)!)
                                        case 3:
                                            (Calendar.current.startOfDay(for: $0.startDate!) <= selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: selectedDate)!)
                                        default:
                                            Calendar.current.startOfDay(for: $0.startDate!) == selectedDate
                                        }
                                    },
                                    category: category))
                                .foregroundStyle(Color.gray)
                                .font(.footnote)
                            }
                        }
                    }
                    
                    Section("관리") {
                        //모든 타이머 기록 리스트 이동
                        NavigationLink("모든 데이터 보기") {
                            ListView()
                        }
                        //모든 타이머 기록 삭제
                        Button("모든 데이터 지우기", role: .destructive) {
                            isShowingRemoveAllAlert.toggle()
                        }
                    }
                }
                .frame(height: 600)
            }
            .navigationBarTitleDisplayMode(.inline)
            //모든 데이터 삭제 확인 Alert
            .alert("데이터 삭제", isPresented: $isShowingRemoveAllAlert) {
                //CoreData 및 Header 삭제
                Button("삭제", role: .destructive) {
                    PersistenceController.shared.removeCoreDataAll()
                    timerDataStore.removeDateTitleAll()
                    isShowingExitAlert.toggle()
                }
                Button("닫기", role: .cancel) { }
            } message: {
                Text("모든 데이터를 삭제하시겠습니까?")
            }
            .alert("안내", isPresented: $isShowingExitAlert) {
                //앱 종료
                Button("확인") {
                    UIApplication.shared.perform(#selector(NSXPCConnection.suspend))
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        exit(0)
                    }
                }
            } message: {
                Text("안정적인 실행을 위해 앱을 종료합니다.\n종료 후 다시 실행바랍니다.")
            }
        }
    }
}

private let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YYYY년 M월 dd일 HH:mm"
    return formatter
}()

private let dateTitleFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "YYYY년 MM월 dd일"
    return formatter
}()

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "M월"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone(abbreviation: "KST")
    formatter.locale = Locale(identifier: "ko_KR")
    formatter.dateFormat = "d일"
    return formatter
}()

#Preview {
    ChartView()
}
