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

|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 20 29 18](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/02dcb24a-091d-4d9f-9f8c-57085fb979be)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 23 06](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/2ae70320-bf76-49a7-a79f-c50a9d8aab50)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 24 46](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/1f6d68bc-8d9c-4eb8-a5f3-311446dd6751)|
| :---: | :---: | :---: |
|`타이머 설정 및 시작`|`알림 및 기록`|`통계(날짜선택)`|
|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 29 35](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/c5f1a9ab-fc2a-447b-87e0-875138f52747)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 32 51](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/6541561d-3aef-4606-8331-695616bf9f81)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 35 08](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/1f187504-a245-4691-bb81-02f1722f1d23)|
|`통계(카테고리선택)`|`통계(기간범위선택)`|`모든 데이터 보기 및 삭제`|
|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 48 55](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/32dcecc0-50f1-4974-a03f-672daf48b03d)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 41 43](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/01229be5-4e08-4eb5-99bd-75cf8ee52f43)|![Simulator Screen Recording - iPhone 15 Pro - 2024-03-19 at 22 42 00](https://github.com/APP-iOS2/final-billbuddy/assets/73647861/4a9454a6-48d0-45e2-868f-7dbce58bb078)|
|`모든 데이터 삭제`|`Live Activity`|`Dynamic Island`|

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

 처음으로 혼자 기획부터 배포까지 진행한 프로젝트로 앱스토어에 처음 나왔을 떄 몇번을 들락날락할 정도로 신기했고 성취감을 느꼈다.
 그리고 배포까지의 과정을 마무리하는 시점에서, 지금까지 왜 iOS앱 개발을 하는 동안 이슈를 정리하고 기록을 남기지 않았을까 하는 큰 아쉬움과 후회 그 사이의 감정이 들었다.

 개발을 하면서 이슈를 맞닥뜨렸을 때는 조금 더 머리를 쓰고 검색해보면서, 힘겹게 해결을 해냈던만큼 기억에 잘 남고 다음에 똑같은 이슈가 있을 때는 당연히 이전 기억으로 쉽게 해결할 수 있을 것 같았다.
 그런데 가끔 점점 그 양이 쌓여가는만큼  '아 이거 저번에 알았는데 어떻게 했더라?'하며 다시 찾는 일이 있다. 또한 이슈에 대한 접근방식이나 해결 방법도 과거와 현재가 다르기 때문에 기록을 남겨두면, 과거와 비교해보면서 해결에 대한 사고능력에도 좋을 것 같다는 생각이 들었다.
 그래서 얼마되지 않았지만 블로그를 개설해 iOS앱 개발 기록을 남기기로 했다.

 이 앱을 개발하면서 가장 큰 이슈를 적어보자면, 웃기게도 타이머 기능 구현이였다. 기획 떄까지만 해도 타이머를 실행시키고 백그라운드 상태가 될 때, 백그라운드 모드로 타이머가 계속 진행되는 줄 알았다.
 실제로 타이머 구현에 대한 것을 검색해보면 Capability에 Background Mode를 추가하여 백그라운드에도 타이머가 계속 진행되게하는 방법도 나와있었다. 나도 그 자료를 참고하여 코딩을 했고 어느 정도 주기능들을 구현했을 때, 실기기에도 디버그를 진행했었다.
 이 때 문제가 생겼는데 Xcode와 연결한 상태로 디버그를 진행했을 때는 백그라운드 상태에도 문제없이 타이머가 진행되었으나, 연결을 해제하고 실기기에서 앱을 켜서 테스트했을 때는 백그라운드 상태에서 전혀 타이머가 진행되지 않았다.

 그 당시 찾아본 결과로는 정상적인 방법은 아니며, 타이머와 연관없는 백그라운드 모드를 활성화 시키면 애플에서는 인젝 사유가 될 것이라는 의견이 있었다. 그리고 백그라운드에서 시간을 항상 업데이트 해야하기 때문에 사용자의 배터리를 지속적으로 사용하게 하는 것을 효율적이지 않다는 의견도 있었다.
 그럼 백그라운드 상태에서 실제로 타이머가 진행되지않지만 포그라운드로 돌아오면 정상적으로 타이머가 진행되는 것을 어떻게 구현할 것인지가 문제였다. 다른 방법으로는 포그라운드에서 타이머 실행했을 때 초마다 현재 Date를 반영하여 타이머가 끝나는 Date의 timeInterval - 현재 Date의 timeInterval을
 해주면, 백그라운드에서 포그라운드로 전환하는 순간 Date가 반영되어 타이머가 백그라운드에서도 흐르는 것 처럼 보이게 하는 것이다. 결국 타이머 끝나는 시간 - 현재 시간으로 해준 것이다.

 위의 방법으로 타이머를 구현하여 무사히 배포까지 할 수 있었으며, 백그라운드에서도 동작하는 것처럼 보이게하는 방법은 응용할 곳이 있다면 적용해보는 것도 좋겠다.
