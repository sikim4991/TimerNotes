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
    @StateObject private var timerViewModel: TimerViewModel = TimerViewModel()
    @ObservedObject var listViewModel: ListViewModel
    //타이머 디스플레이 분
    private var displayMinute: String {
        String(format: "%01d", timerViewModel.timerData.angle / 60)
    }
    //타이머 디스플레이 초
    private var displaySecond: String {
        String(format: "%02d", timerViewModel.timerData.angle % 60)
    }
    
    var body: some View {
        NavigationStack {
            VStack {
                Spacer()
                
                //타이머 카테고리 뷰
                ZStack {
                    Picker(selection: $timerViewModel.timerData.selectedCategory, label: Text("분류")) {
                        ForEach(Category.allCases, id: \.self) { option in
                            Text(option.rawValue)
                                .tag(option)
                        }
                    }
                    .pickerStyle(WheelPickerStyle())
                    .frame(height: 80)
                    .disabled(timerViewModel.isStart)
                    
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
                            .trim(from: 0.0, to: CGFloat(timerViewModel.timerData.angle) * 0.1 / 360)
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
                                    .rotationEffect(.degrees(Double(timerViewModel.timerData.angle) * -0.1))
                                Rectangle()
                                    .frame(width: 5, height: 15)
                                    .foregroundStyle(Color.white)
                                    .padding(.bottom, 54)
                                    .shadow(radius: 3, y: -2)
                                    .rotationEffect(.degrees(Double(timerViewModel.timerData.angle) * -0.1))
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
                                        timerViewModel.timerData.angle = Int(round(theta)) * 10 + timerViewModel.timerData.lastAngle
                                        
                                        if timerViewModel.timerData.angle > 3600 {
                                            timerViewModel.timerData.angle -= 3600
                                        }
                                    }
                                    .onEnded { v in
                                        timerViewModel.timerData.lastAngle = timerViewModel.timerData.angle
                                    }
                            )
                            .disabled(timerViewModel.isStart)
                    }
                }
                //타이머 설정 중 효과음과 햅틱
                .onChange(of: timerViewModel.timerData.angle) {
                    if !timerViewModel.isStart {
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        AudioServicesPlaySystemSound(1104)
                    }
                }
                //타이머 시작 시, 정지 및 타이머 끝났을 때
                .onReceive(timerViewModel.timer, perform: { _ in
                    if timerViewModel.isStart {
                        if timerViewModel.timerData.angle > 0 {
                            if Int(timerViewModel.timerData.endDate.timeIntervalSince1970) > Int(Date().timeIntervalSince1970) {
                                timerViewModel.timerData.angle = Int(timerViewModel.timerData.endDate.timeIntervalSince1970) - Int(Date().timeIntervalSince1970)
                            } else {
                                timerViewModel.isStart.toggle()
                                timerViewModel.timerData.angle = 0
                                timerViewModel.endTimerInLiveActivity()
                                if timerViewModel.isOnRecord {
                                    PersistenceController.shared.addItem(date: timerViewModel.timerData.endDate, category: timerViewModel.timerData.selectedCategory.rawValue, timeSet: timerViewModel.timerData.lastAngle)
                                    listViewModel.addDateTitle(date: timerViewModel.timerData.endDate - TimeInterval(timerViewModel.timerData.lastAngle))                                }
                            }
                        }
                    }
                })
                
                Spacer()
                Spacer()
                
                ZStack {
                    //타이머 숫자 뷰
                    if timerViewModel.isStart && timerViewModel.timerData.angle > 0 {
                        Text(timerInterval: Date.now...timerViewModel.timerData.endDate)
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
                            Image(systemName: timerViewModel.isStart ? "stop.fill" : "play.fill")
                            Circle()
                                .stroke(lineWidth: /*@START_MENU_TOKEN@*/1.0/*@END_MENU_TOKEN@*/)
                                .frame(width: 35)
                        }
                        //버튼 눌렀을 때
                        .onTapGesture {
                            if timerViewModel.timerData.angle != 0 {
                                timerViewModel.isStart.toggle()
                                if timerViewModel.isStart {
                                    timerViewModel.startTimerInLiveActivity(category: timerViewModel.timerData.selectedCategory.rawValue)
                                    timerViewModel.timerData.endDate = Date(timeInterval: TimeInterval(timerViewModel.timerData.angle), since: Date())
                                    if timerViewModel.isOnRecord {
                                        timerViewModel.notifcation(category: timerViewModel.timerData.selectedCategory.rawValue, timeInterval: TimeInterval(timerViewModel.timerData.lastAngle))
                                    } else {
                                        timerViewModel.notifcation(category: nil, timeInterval: TimeInterval(timerViewModel.timerData.lastAngle))
                                    }
                                } else {
                                    timerViewModel.timerData.angle = 0
                                    timerViewModel.timerData.lastAngle = 0
                                    timerViewModel.notificationCenter.removeAllPendingNotificationRequests()
                                    timerViewModel.endTimerInLiveActivity()
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
                    Toggle("기록", isOn: $timerViewModel.isOnRecord)
                        .toggleStyle(SwitchToggleStyle())
                        .disabled(timerViewModel.isStart)
                }
            }
            .onAppear {
                //알림 요청 및 허용/거부
                timerViewModel.notificationCenter.requestAuthorization(options: [.badge, .sound, .alert]) { isAllow, error in
                    if let error {
                        print("Error : \(error)")
                    }
                    
                    guard isAllow else {
                        if timerViewModel.isFirstCheckNotification {
                            timerViewModel.isShowingNotifyAlert.toggle()
                            timerViewModel.isFirstCheckNotification = false
                        }
                        return
                    }
                }
            }
            //알림 거부 시, 최초 1회 Alert
            .alert("안내", isPresented: $timerViewModel.isShowingNotifyAlert) {
                Button("확인") { }
            } message: {
                Text("알림이 거부되어 정삭적인 알림이 작동하지 않습니다. 설정 > TimerNotes > 알림에서 설정이 가능합니다.")
            }
        }
    }
}

#Preview {
    NavigationStack {
        TimerView(listViewModel: ListViewModel())
    }
}
