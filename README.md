# 🍑 Momo Timer

<div align="center">
  <img src="assets/logo.png" alt="Momo Timer Logo" width="200"/>
  
  **귀여운 복숭아 테마의 포모도로 타이머 앱**
  
  [![Flutter](https://img.shields.io/badge/Flutter-3.0.0+-blue.svg)](https://flutter.dev)
  [![Firebase](https://img.shields.io/badge/Firebase-Enabled-orange.svg)](https://firebase.google.com)
  [![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
</div>

## 📱 소개

Momo Timer는 생산성 향상을 위한 귀여운 복숭아 테마의 포모도로 타이머 앱입니다. 
깔끔한 디자인과 직관적인 인터페이스로 집중력 있는 작업 시간 관리를 도와드립니다.

### ✨ 주요 기능

- 🍑 **복숭아 테마 디자인** - 귀엽고 친근한 UI/UX
- ⏱️ **포모도로 타이머** - 25분 작업, 5분 휴식 사이클
- 📊 **작업 기록 추적** - 일별, 주별 통계 확인
- 🔔 **알림 기능** - 진동과 소리 알림
- 🌙 **다크 모드 지원** - 눈의 피로를 줄이는 다크 테마
- 📈 **Firebase 통합** - 실시간 분석 및 크래시 리포팅

## 🚀 시작하기

### 필수 요구사항

- Flutter SDK (3.0.0 이상)
- Dart SDK (3.0.0 이상)
- Android Studio 또는 Xcode
- Firebase 계정

### 설치 방법

1. **레포지토리 클론**
   ```bash
   git clone https://github.com/dingcodingco/momo_timer.git
   cd momo_timer
   ```

2. **의존성 설치**
   ```bash
   flutter pub get
   ```

3. **환경 설정**
   ```bash
   cp .env.example .env
   # .env 파일을 열어 필요한 설정값 입력
   ```

4. **Firebase 설정**
   - Firebase Console에서 프로젝트 생성
   - `google-services.json` (Android) 다운로드 → `android/app/`
   - `GoogleService-Info.plist` (iOS) 다운로드 → `ios/Runner/`
   - 자세한 설정은 [SETUP.md](SETUP.md) 참고

5. **앱 실행**
   ```bash
   flutter run
   ```

## 📂 프로젝트 구조

```
momo_timer/
├── lib/
│   ├── main.dart              # 앱 진입점
│   ├── screens/               # 화면 위젯
│   ├── services/              # 비즈니스 로직
│   ├── models/                # 데이터 모델
│   ├── providers/             # 상태 관리
│   └── theme/                 # 테마 설정
├── assets/                    # 이미지, 아이콘 등
├── docs/                      # 문서
└── test/                      # 테스트 코드
```

## 🛠️ 기술 스택

- **Frontend**: Flutter, Dart
- **State Management**: Provider
- **Backend Services**: Firebase (Analytics, Crashlytics)
- **Local Storage**: SharedPreferences
- **Notifications**: flutter_local_notifications

## 📸 스크린샷

<div align="center">
  <table>
    <tr>
      <td align="center">
        <img src="docs/screenshots/timer.png" width="200" alt="Timer Screen"/>
        <br>타이머 화면
      </td>
      <td align="center">
        <img src="docs/screenshots/history.png" width="200" alt="History Screen"/>
        <br>기록 화면
      </td>
      <td align="center">
        <img src="docs/screenshots/settings.png" width="200" alt="Settings Screen"/>
        <br>설정 화면
      </td>
    </tr>
  </table>
</div>

## 🎯 빌드 및 배포

### Android APK 빌드
```bash
flutter build apk --release
```

### iOS 빌드
```bash
flutter build ios --release
```

### 웹 빌드
```bash
flutter build web --release
```

## 🤝 기여하기

프로젝트 개선에 기여하고 싶으시다면:

1. Fork 하기
2. Feature 브랜치 생성 (`git checkout -b feature/AmazingFeature`)
3. 변경사항 커밋 (`git commit -m 'Add some AmazingFeature'`)
4. 브랜치에 Push (`git push origin feature/AmazingFeature`)
5. Pull Request 생성

## 📚 학습 자료

### 딩코딩코와 함께 배우기

이 프로젝트는 **딩코딩코**의 Flutter 앱 개발 강의를 통해 학습할 수 있습니다.

#### 📺 YouTube 채널
[**딩코딩코 YouTube**](https://www.youtube.com/@%EB%94%A9%EC%BD%94%EB%94%A9%EC%BD%94)
- Flutter 기초부터 실전까지
- 실시간 코딩 방송
- 앱 개발 노하우 공유

#### 🎓 인프런 강의
[**비개발자 4주만에 수익화 서비스 만들기: AI 바이브코딩 웹 + 앱 ALL IN ONE**](https://inf.run/TkFHv)
- 코딩 경험 없어도 OK
- AI 도구 활용한 효율적인 개발
- 웹과 앱을 한번에 마스터
- 실제 수익화까지 완성

## 📝 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다. 자세한 내용은 [LICENSE](LICENSE) 파일을 참고하세요.

## 📞 문의

- **GitHub**: [@dingcodingco](https://github.com/dingcodingco)
- **YouTube**: [딩코딩코](https://www.youtube.com/@%EB%94%A9%EC%BD%94%EB%94%A9%EC%BD%94)
- **인프런**: [딩코딩코 프로필](https://www.inflearn.com/users/@dingcodingco)

## ⭐ 후원

이 프로젝트가 도움이 되셨다면 ⭐️ 를 눌러주세요!

---

<div align="center">
  Made with ❤️ by <a href="https://github.com/dingcodingco">딩코딩코</a>
</div>