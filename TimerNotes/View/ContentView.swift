//
//  ContentView.swift
//  TimerNotes
//
//  Created by SIKim on 12/28/23.
//

import SwiftUI
import CoreData

struct ContentView: View {
    ///Onboarding animation 순서를 위한 Int
    @AppStorage("onboarding") private var onboardingAnimationNumber: Int = 1
    
    var body: some View {
        TabView {
            TimerView()
                .tabItem {
                    Image(systemName: "clock.fill")
                    Text("타이머")
                }
            ChartView()
                .tabItem {
                    Image(systemName: "chart.bar.xaxis")
                    Text("통계")
                }
            SettingView()
                .tabItem {
                    Image(systemName: "gearshape.fill")
                    Text("설정")
                }
        }
        //Onboarding
        .overlay {
            if onboardingAnimationNumber != 0 {
                let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
                    ZStack {
                        Color.black
                            .ignoresSafeArea()
                            .opacity(0.7)
                        Circle()
                            .frame(width: 370)
                            .foregroundStyle(Color.white)
                        ForEach(1..<60) { stick in
                            VStack {
                                Rectangle()
                                    .frame(width: stick % 5 == 0 ? 3 : 1, height: stick % 5 == 0 ? 15 : 7)
                                Spacer()
                                    .frame(height: 280)
                            }
                            .rotationEffect(Angle.degrees(Double(stick)/60 * 360))
                        }
                        
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
                        Circle()
                            .trim(from: 0.0, to: (onboardingAnimationNumber % 2 == 0 ? 45 : 0) / 360)
                            .stroke(lineWidth: 140)
                            .frame(width: 140)
                            .foregroundStyle(.red)
                            .rotationEffect(.degrees(-90))
                            .scaleEffect(CGSize(width: -1.0, height: 1.0))
                        Circle()
                            .stroke(lineWidth: 20)
                            .frame(width: 20)
                            .foregroundStyle(.white)
                            .shadow(radius: 3, y: -2)
                        Rectangle()
                            .frame(width: 1, height: 110)
                            .padding(.bottom, 170)
                            .rotationEffect(.degrees(Double(onboardingAnimationNumber % 2 == 0 ? -45 : 0)))
                        Rectangle()
                            .frame(width: 5, height: 15)
                            .foregroundStyle(Color.white)
                            .padding(.bottom, 54)
                            .shadow(radius: 3, y: -2)
                            .rotationEffect(.degrees(Double(onboardingAnimationNumber % 2 == 0 ? -45 : 0)))
                        Image(systemName: onboardingAnimationNumber % 2 == 0 ?  "hand.tap.fill" : "hand.draw.fill")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .foregroundStyle(Color.orange)
                            .rotationEffect(.degrees(Double(25)))
                            .padding(.bottom, onboardingAnimationNumber < 3 ? 180 : 20)
                            .rotationEffect(.degrees(Double(onboardingAnimationNumber % 2 == 0 ? -43 : 0)))
                    }
                //Onboarding 종료
                .onTapGesture {
                    onboardingAnimationNumber = 0
                }
                //초당 Animation 변경
                .onReceive(timer , perform: { _ in
                    if onboardingAnimationNumber > 0 {
                        onboardingAnimationNumber = (onboardingAnimationNumber % 4) + 1
                    }
                })
                .animation(.default , value: onboardingAnimationNumber)
            }
        }
    }
}


#Preview {
    ContentView()
}
