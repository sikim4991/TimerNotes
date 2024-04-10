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
    @StateObject private var chartViewModel: ChartViewModel = ChartViewModel()
    @ObservedObject var listViewModel: ListViewModel
    @FetchRequest(
        entity: TimerCoreData.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \TimerCoreData.startDate, ascending: false)]
    ) var timerCoreDatas: FetchedResults<TimerCoreData>
    
    var body: some View {
        NavigationStack {
            ScrollView {
                //기간 설정 Picker 뷰
                Picker(selection: $chartViewModel.selectedChart, label: Text("Picker")) {
                    Text("1일").tag(1)
                    Text("1주일").tag(2)
                    Text("1개월").tag(3)
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                //기간 설정에 따른 날짜 Text 뷰 및 달력 Picker 버튼
                switch (chartViewModel.selectedChart) {
                case 1:
                    HStack {
                        Text(chartViewModel.selectedDate, formatter: dateTitleFormatter)
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $chartViewModel.selectedDate, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko"))
                                    .blendMode(.destinationOver)
                            }
                    }
                    .font(.footnote)
                    .padding(.horizontal)
                case 2:
                    HStack {
                        Text("\(Calendar.current.date(byAdding: .day, value: -7, to: chartViewModel.selectedDate)!, formatter: dateTitleFormatter) ~ \(chartViewModel.selectedDate, formatter: dateTitleFormatter)")
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $chartViewModel.selectedDate, displayedComponents: .date)
                                    .environment(\.locale, Locale.init(identifier: "ko"))
                                    .blendMode(.destinationOver)
                            }
                    }
                    .padding(.horizontal)
                    .font(.footnote)
                case 3:
                    HStack {
                        Text("\(Calendar.current.date(byAdding: .day, value: -30, to: chartViewModel.selectedDate)!, formatter: dateTitleFormatter) ~ \(chartViewModel.selectedDate, formatter: dateTitleFormatter)")
                        Image(systemName: "calendar")
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 1)
                                    .frame(width: 25)
                                DatePicker("달력", selection: $chartViewModel.selectedDate, displayedComponents: .date)
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
                Chart(timerCoreDatas.filter {chartViewModel.filteredCoreDataInChart(element: $0)}) {
                    //기간 설정에 따른 x, y 값 변경
                    switch (chartViewModel.selectedChart) {
                    case 1:
                        BarMark(
                            x: .value("카테고리", $0.category!),
                            y: .value("타이머 기록", $0.timeSet)
                        )
                    default:
                        BarMark(
                            x: .value("날짜", $0.startDate!, unit: .day),
                            y: .value("타이머 기록",  $0.timeSet)
                        )
                    }
                }
                .chartXAxisLabel(chartViewModel.selectedChart == 1 ? String(localized: "분류") : String(localized: "날짜"))
                .chartYAxisLabel(String(localized: "타이머 기록"))
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
                                    switch category {
                                    case "공부":
                                        Image(systemName: "pencil.line")
                                    case "운동":
                                        Image(systemName: "dumbbell.fill")
                                    case "독서":
                                        Image(systemName: "book.fill")
                                    case "회의":
                                        Image(systemName: "person.3.fill")
                                    case "게임":
                                        Image(systemName: "gamecontroller.fill")
                                    case "휴식":
                                        Image(systemName: "figure.mind.and.body")
                                    case "기타":
                                        Image(systemName: "ellipsis.circle")
                                    default:
                                        Text("")
                                    }
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
                    switch (chartViewModel.selectedChart) {
                    case 1:
                        switch (chartViewModel.selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ Calendar.current.startOfDay(for: $0.startDate!) == chartViewModel.selectedDate }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) == chartViewModel.selectedDate) && ($0.category! == chartViewModel.selectedCategory.rawValue.key) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    case 2:
                        switch (chartViewModel.selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) <= chartViewModel.selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: chartViewModel.selectedDate)!) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ ((Calendar.current.startOfDay(for: $0.startDate!) <= chartViewModel.selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -7, to: chartViewModel.selectedDate)!)) && ($0.category! == chartViewModel.selectedCategory.rawValue.key) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    case 3:
                        switch (chartViewModel.selectedCategory) {
                        case .all:
                            if timerCoreDatas.filter({ (Calendar.current.startOfDay(for: $0.startDate!) <= chartViewModel.selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: chartViewModel.selectedDate)!) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        default:
                            if timerCoreDatas.filter({ ((Calendar.current.startOfDay(for: $0.startDate!) <= chartViewModel.selectedDate) && (Calendar.current.startOfDay(for: $0.startDate!) >= Calendar.current.date(byAdding: .day, value: -30, to: chartViewModel.selectedDate)!)) && ($0.category! == chartViewModel.selectedCategory.rawValue.key) }).isEmpty {
                                Text("데이터가 없습니다.")
                                    .foregroundStyle(Color.gray)
                            }
                        }
                    default:
                        if timerCoreDatas.filter({ Calendar.current.startOfDay(for: $0.startDate!) == Calendar.current.startOfDay(for: chartViewModel.selectedDate) }).isEmpty {
                            Text("데이터가 없습니다.")
                                .foregroundStyle(Color.gray)
                        }
                    }
                }
                
                //카테고리 Picker 뷰
                Picker(selection: $chartViewModel.selectedCategory, label: Text("CategoryForChart")) {
                    ForEach(CategoryForChart.allCases, id: \.self) { category in
                        switch category.rawValue {
                        case "공부":
                            Image(systemName: "pencil.line")
                                .tag(category)
                        case "운동":
                            Image(systemName: "dumbbell.fill")
                                .tag(category)
                        case "독서":
                            Image(systemName: "book.fill")
                                .tag(category)
                        case "회의":
                            Image(systemName: "person.3.fill")
                                .tag(category)
                        case "게임":
                            Image(systemName: "gamecontroller.fill")
                                .tag(category)
                        case "휴식":
                            Image(systemName: "figure.mind.and.body")
                                .tag(category)
                        case "기타":
                            Image(systemName: "ellipsis.circle")
                                .tag(category)
                        default:
                            Text(category.rawValue)
                                .tag(category)
                        }
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding(.horizontal)
                .padding(.bottom)
                
                List {
                    //기간 설정에 따른 Header
                    Section(chartViewModel.selectedChart == 1 ? "타이머 기록 시간" : "타이머 기록 시간(평균)") {
                        //기간, 날짜 조건에 따른 Text 리스트
                        ForEach (CategoryForChart.allCases, id: \.self) { category in
                            HStack {
                                Text("\(category.rawValue) ")
                                    .font(.callout)
                                Spacer()
                                Text(chartViewModel.makeAverageDatas(
                                    selectedChart: chartViewModel.selectedChart,
                                    datas: timerCoreDatas.filter { chartViewModel.filteredCoreDataInList(element: $0)},
                                    category: category))
                                .foregroundStyle(Color.gray)
                                .font(.footnote)
                            }
                        }
                    }
                    
                    Section("관리") {
                        //모든 타이머 기록 리스트 이동
                        NavigationLink("모든 데이터 보기") {
                            ListView(listViewModel: listViewModel)
                        }
                        //모든 타이머 기록 삭제
                        Button("모든 데이터 지우기", role: .destructive) {
                            chartViewModel.isShowingRemoveAllAlert.toggle()
                        }
                    }
                }
                .frame(height: 600)
            }
            .navigationBarTitleDisplayMode(.inline)
            //모든 데이터 삭제 확인 Alert
            .alert("데이터 삭제", isPresented: $chartViewModel.isShowingRemoveAllAlert) {
                //CoreData 및 Header 삭제
                Button("삭제", role: .destructive) {
                    PersistenceController.shared.removeCoreDataAll()
                    listViewModel.removeDateTitleAll()
                    chartViewModel.isShowingExitAlert.toggle()
                }
                Button("닫기", role: .cancel) { }
            } message: {
                Text("모든 데이터를 삭제하시겠습니까?")
            }
            .alert("안내", isPresented: $chartViewModel.isShowingExitAlert) {
                //앱 종료
                Button("확인") {
                    chartViewModel.exitApp()
                }
            } message: {
                Text("안정적인 실행을 위해 앱을 종료합니다.\n종료 후 다시 실행바랍니다.")
            }
        }
    }
}

private let dateTitleFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone.autoupdatingCurrent
    formatter.locale = Locale.autoupdatingCurrent
    formatter.dateFormat = "YYYY-MM-dd"
    return formatter
}()

private let monthFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone.autoupdatingCurrent
    formatter.locale = Locale.autoupdatingCurrent
    formatter.dateFormat = "MMM"
    return formatter
}()

private let dayFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.timeZone  = TimeZone.autoupdatingCurrent
    formatter.locale = Locale.autoupdatingCurrent
    formatter.dateFormat = "d"
    return formatter
}()

#Preview {
    ChartView(listViewModel: ListViewModel())
}
