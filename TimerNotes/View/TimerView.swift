//
//  TimerView.swift
//  TimerNotes
//
//  Created by SIKim on 1/3/24.
//

import SwiftUI
import AVFoundation
//import UserNotifications

struct TimerView: View {
    ///첫 알림 거부 시, Alert을 띄우기 위한 Boolean
    @AppStorage("notification") private var isFirstCheckNotification: Bool = true
    @EnvironmentObject private var timerDataStore: TimerDataStore
    ///마지막으로 설정한 각도 = 시간
    @State private var lastAngle: Int = 0
    ///타이머 끝나는 날짜
    @State private var endDate: Date = Date()
    ///타이머 카테고리
    @State private var selectedCategory: Category = .study
    ///타이머 시작 유무 Boolean
    @State private var isStart: Bool = false
    ///타이머 기록 On/Off Boolean
    @State private var isOnRecord: Bool = false
    ///첫 알림 거부 Alert Boolean
    @State private var isShowingNotifyAlert: Bool = false
    
    ///타이머 퍼블리셔 - 1초
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    //타이머 디스플레이 분
    private var displayMinute: String {
        String(format: "%01d", timerDataStore.angle / 60)
    }
    //타이머 디스플레이 초
    private var displaySecond: String {
        String(format: "%02d", timerDataStore.angle % 60)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                //타이머 카테고리 뷰
                ZStack {
                    Picker(selection: $selectedCategory, label: Text("분류")) {
                        ForEach(Category.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 80)
                    .disabled(isStart)
                    
                    HStack {
                        Spacer()
                            .frame(width: 130)
                        
                        Image(systemName: "arrow.up.and.line.horizontal.and.arrow.down")
                            .opacity(0.2)
                    }
                }
                
                Spacer()
                
                //타이머 뷰
                ZStack {
                    //타이머 테두리 (선)
                    ForEach(1..<60) { stick in
                        VStack {
                            Rectangle()
                                .frame(width: stick % 5 == 0 ? 3 : 1, height: stick % 5 == 0 ? 15 : 7)
                            Spacer()
                                .frame(height: 280)
                        }
                        .rotationEffect(Angle.degrees(Double(stick)/60 * 360))
                    }
                    
                    //타이머 테두리 (숫자)
                    ForEach(0..<60) { stick in
                        VStack {
                            if stick % 5 == 0 {
                                Text("\(stick)")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .rotationEffect(Angle.degrees(Double(stick)/60 * 360))
                            }
                            Spacer()
                                .frame(height: 330)
                        }
                        .rotationEffect(Angle.degrees(-Double(stick)/60 * 360))
                    }
                    
                    //1초마다 뷰를 다시 그려주는 뷰
                    TimelineView(.periodic(from: .now, by: 1.0)) { _ in
                        //고정되지 않은 뷰들 ( 빨간 원, 침, 다이얼 )
                        Circle()
                            .trim(from: 0.0, to: CGFloat(timerDataStore.angle) * 0.1 / 360)
                            .stroke(lineWidth: 140)
                            .frame(width: 140)
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(CGSize(width: -1.0, height: 1.0))
                            .overlay {
                                Circle()
                                    .stroke(lineWidth: 20)
                                    .frame(width: 20)
                                    .foregroundStyle(.white)
                                    .shadow(radius: 3, y: -2)
                                Rectangle()
                                    .frame(width: 1, height: 110)
                                    .padding(.bottom, 170)
                                    .rotationEffect(.degrees(Double(timerDataStore.angle) * -0.1))
                                Rectangle()
                                    .frame(width: 5, height: 15)
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 54)
                                    .shadow(radius: 3, y: -2)
                                    .rotationEffect(.degrees(Double(timerDataStore.angle) * -0.1))
                            }
                        //타이머 설정을 위한 drag gesture
                            .gesture(
                                DragGesture()
                                    .onChanged { v in
                                        var theta = (atan2(v.location.x - 140 / 2, 140 / 2 - v.location.y) - atan2(v.startLocation.x - 140 / 2, 140 / 2 - v.startLocation.y)) * 180 / .pi
                                        if theta < 0 {
                                            theta += 360
                                        }
                                        
                                        theta = 360 - theta
                                        timerDataStore.angle = Int(round(theta)) * 10 + self.lastAngle
                                        
                                        if timerDataStore.angle > 3600 {
                                            timerDataStore.angle -= 3600
                                        }
                                    }
                                    .onEnded { v in
                                        self.lastAngle = timerDataStore.angle
                                    }
                            )
                            .disabled(isStart)
                    }
                }
                //타이머 설정 중 효과음과 햅틱
                .onChange(of: timerDataStore.angle) {
                    if !isStart {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        AudioServicesPlaySystemSound(1104)
                    }
                }
                //타이머 시작 시, 정지 및 타이머 끝났을 때
                .onReceive(timer, perform: { _ in
                    if isStart {
                        if timerDataStore.angle > 0 {
                            if Int(endDate.timeIntervalSince1970) > Int(Date().timeIntervalSince1970) {
                                timerDataStore.angle = Int(endDate.timeIntervalSince1970) - Int(Date().timeIntervalSince1970)
                            } else {
                                isStart.toggle()
                                timerDataStore.angle = 0
                                timerDataStore.endTimerInLiveActivity()
                                if isOnRecord {
                                    PersistenceController.shared.addItem(date: endDate, category: selectedCategory.rawValue, timeSet: self.lastAngle)
                                    timerDataStore.addDateTitle(date: endDate - TimeInterval(self.lastAngle))
                                }
                            }
                        }
                    }
                })
                
                Spacer()
                Spacer()
                
                ZStack {
                    //타이머 숫자 뷰
                    if isStart && timerDataStore.angle > 0 {
                        Text(timerInterval: Date.now...endDate)
                                .font(.largeTitle)
                                .fontWeight(.light)
                    } else {
                        Text("\(displayMinute):\(displaySecond)")
                            .font(.largeTitle)
                            .fontWeight(.light)
                    }
                    //시작, 정지 버튼 뷰
                    HStack {
                        Spacer()
                            .frame(width: 150)
                        ZStack {
                            Image(systemName: isStart ? "stop.fill" : "play.fill")
                            Circle()
                                .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                                .frame(width: 35)
                        }
                        //버튼 눌렀을 때
                        .onTapGesture {
                            if timerDataStore.angle != 0 {
                                isStart.toggle()
                                if isStart {
                                    timerDataStore.startTimerInLiveActivity(category: selectedCategory.rawValue)
                                    endDate = Date(timeInterval: TimeInterval(timerDataStore.angle), since: Date())
                                    if isOnRecord {
                                        timerDataStore.notifcation(category: selectedCategory.rawValue, timeInterval: TimeInterval(self.lastAngle))
                                    } else {
                                        timerDataStore.notifcation(category: nil, timeInterval: TimeInterval(self.lastAngle))
                                    }
                                } else {
                                    timerDataStore.angle = 0
                                    self.lastAngle = 0
                                    timerDataStore.notificationCenter.removeAllPendingNotificationRequests()
                                    timerDataStore.endTimerInLiveActivity()
                                }
                            }
                        }
                    }
                }
                
                Spacer()
                Spacer()
                
            }
            //기록 toggle switch
            .toolbar {
                ToolbarItem {
                    Toggle("기록", isOn: $isOnRecord)
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(isStart)
                }
            }
            .onAppear {
                //디스플레이 항상 켜놓기 설정
                UIApplication.shared.isIdleTimerDisabled = timerDataStore.isAlwaysOnDisplay
                //알림 요청 및 허용/거부
                timerDataStore.notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { isAllow, error in
                    if let error {
                        print("Error : \(error)")
                    }
                    
                    guard isAllow else {
                        if isFirstCheckNotification {
                            isShowingNotifyAlert.toggle()
                            isFirstCheckNotification = false
                        }
                        return
                    }
                }
            }
            //알림 거부 시, 최초 1회 Alert
            .alert("안내", isPresented: $isShowingNotifyAlert) {
                Button("확인") { }
            } message: {
                Text("알림이 거부되어 정삭적인 알림이 작동하지 않습니다. 설정 > TimerNotes > 알림에서 설정이 가능합니다.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TimerView()
            .environmentObject(TimerDataStore())
    }
}
