# 🌤️ WearCast - 오늘 뭐 입지?

**WearCast**는 사용자의 현재 위치를 기반으로 실시간 날씨 데이터를 분석하여, 그날의 기온, 강수량, 습도, 풍속 등을 종합해 가장 적합한 옷차림을 AI가 직접 추천해주는 개인화 코디 앱입니다.

🌤️ 오늘 날씨에 맞는 옷차림이 고민될 때, </br>
🧠 ChatGPT의 스타일링 조언을 받고 싶을 때, </br>
📸 직접 받은 추천 결과를 다시 보고 싶을 때, </br>
WearCast는 매일 아침 당신의 패션 고민을 덜어줍니다.

---

## 📱 주요 기능

- 🌎 **날씨 기반 의상 추천**  
  위치 기반 또는 도시 직접 입력을 통해 실시간 날씨를 받아 적절한 옷차림 추천

- 🎨 **개인화된 추천**  
  성별, 스타일, 상황(예: 데이트, 출근 등), 선호 색상을 바탕으로 GPT가 추천 구성

- 🧥 **의상 구성**  
  상의, 하의, 겉옷, 신발, 액세서리 + 스타일 팁까지 구체적으로 안내

- 🖼️ **의상 이미지 프리뷰**  
  DALL·E를 활용해 추천 결과를 이미지로 시각화

- 🔖 **내가 저장한 착장 보기**  
  Firebase를 통해 추천 결과 저장 및 조회

- 🧭 **다양한 화면 이동**  
  총 10개 이상의 ViewController로 구성된 유기적인 화면 전환

- 🗣️ **실시간 팝업 기반 사용자 경험**  
  모달 기반의 설정, 이미지 뷰어, 날씨 상세 보기 구현

---

## ⚙️ 기술 스택

- **iOS UIKit / Storyboard 기반**
- **Swift**
- **OpenAI GPT-3.5 + DALL·E API**
- **Firebase (Firestore, Auth)**
- **MapKit, CoreLocation, CLGeocoder**
- **Xcode 15+, iOS 16+ 지원**

---

## 🏃‍♀️ 실행 방법

1. 이 레포를 clone 받습니다.
2. `GoogleService-Info.plist`를 프로젝트에 추가합니다.
3. `API Key`는 OpenAI의 키를 발급받아 `RecommendationViewController.swift`에 입력합니다.
4. Xcode에서 `Cmd + R`로 실행!

---

## 🧱 앱 내비게이션 구조

### UITabBarController 구성

- **🧥 코디 추천 (`HomeTabViewController`)**
  - 위치 선택: `LocationPickerViewController`
  - 날씨 확인: OpenWeatherMap API 사용
  - 상세 기상정보 보기: `WeatherDetailPopupViewController`
  - 사용자 선호 입력: `PreferencePopupViewController`
  - AI 추천 받기: `RecommendationViewController`
    - 추천 결과 이미지 생성: `PreviewImageViewController`
  - 추천 저장: Firebase Firestore 연동

- **🌐 커뮤니티 (`CommunityTabViewController`)**
  - 전체 피드 목록: `UITableView`
  - 셀 선택 시 → 상세 코디 보기 (Detail 화면)

- **🧳 내 코디함 (`MyPageViewController`)**
  - 내가 등록한 코디 불러오기: `MyOutfitListViewController`
    - 셀 선택 시 → 상세 코디 보기 (Detail 화면)
  - 설정/FAQ/로그아웃 페이지 이동

---
