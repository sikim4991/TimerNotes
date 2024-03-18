# TimerNotes

![TimerNotesMainImage](https://github.com/sikim4991/TimerNotes/assets/73647861/f0229f8c-d86c-43c7-b8ae-0a81302becb4)

<br>

## 소개

__타이머 이용 시간을 노트처럼 기록하며 시간을 관리해보세요!__

- 개발 기간 : 2024.01 - 2024.02

- `Swift 5.10` `Xcode 15.3` `iOS 17.0`

- `Swift` `SwiftUI` `CoreData` `Chart` `ActivityKit` `Git/GitHub` `Figma`

- 다크모드 지원

<br>

## 주요 기능

- 타이머 기능
  - 기록을 하지않더라도 일반적인 타이머 기능을 이용할 수 있습니다. (최대 1시간)
  - '설정'에서 '디스플레이 항상 켜놓기'를 눌러 타이머 화면을 항상 켜둘 수 있습니다.

- 기록 기능
  - 타이머 시작 전 '기록'스위치를 눌러 타이머를 활용한 시간을 기록할 수 있습니다.
  - 타이머 기록들은 '통계'탭에서 확인할 수 있습니다.

- 통계 기능
  - 각 날짜와 조건에 맞게 그래프와 이용 시간을 확인할 수 있습니다.
  - 타이머 기록 날짜는 타이머 시작 시간을 기준으로 합니다. (12월 31일 23:59:59 시작, 1월 1일 00:00:09 끝이면 12월 31일자로 저장)
 
<br>

## 구현 영상

<br>

## 아키텍처

Model-View-Store에서 Model-View-ViewModel로 변경

- __MV-Store__(ver1.0.0)
```
🗂TimerNotes
 ┣ 🗂Model
 ┣ 🗂Store
 ┣ 🗂View
 ┣ 🗂Assets.xcassets
 ┗ 🗂notificationSound.wav
🗂TimerNotesWidget
🗂Frameworks
```

<br>

- __MVVM__(ver1.0.1~)
```
🗂TimerNotes
 ┣ 🗂Source
 ┃ ┣ 🗂Model
 ┃ ┣ 🗂View
 ┃ ┣ 🗂ViewModel
 ┃ ┗ 🗂CoreData
 ┗ 🗂Resource
   ┣ 🗂Assets.xcassets
   ┗ 🗂notificationSound.wav
🗂TimerNotesWidget
🗂Frameworks
```

<br>

## 회고

