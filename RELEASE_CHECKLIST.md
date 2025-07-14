# 🚀 DevRoutine 출시 체크리스트

## 📋 출시 전 필수 체크리스트

### ✅ 기본 설정 완료
- [x] 앱 이름 설정 (DevRoutine)
- [x] 패키지명 변경 (com.gyhmac.devroutine)
- [x] 앱 버전 설정 (1.0.0+1)
- [x] 개인정보 처리방침 작성
- [x] 스토어 리스팅 자료 준비

### ✅ 빌드 설정 완료
- [x] ProGuard 설정 (코드 난독화)
- [x] 릴리즈 빌드 최적화
- [x] Firebase Crashlytics 연동
- [x] 디버그 코드 제거 준비

### 🔧 출시 전 필수 작업

#### 1. Firebase 프로젝트 설정
```bash
# Firebase CLI 설치
npm install -g firebase-tools

# Firebase 프로젝트 생성 후 FlutterFire 설정
dart pub global activate flutterfire_cli
flutterfire configure
```

#### 2. Android 서명 설정
```bash
# 키스토어 생성
keytool -genkey -v -keystore ~/devroutine-release-key.keystore -keyalg RSA -keysize 2048 -validity 10000 -alias devroutine

# android/key.properties 파일 생성
storePassword=your_store_password
keyPassword=your_key_password
keyAlias=devroutine
storeFile=../devroutine-release-key.keystore
```

#### 3. iOS 서명 설정
- Apple Developer 계정 등록
- Xcode에서 Signing & Capabilities 설정
- Bundle Identifier 확인 (com.gyhmac.devroutine)

### 📱 테스트 체크리스트

#### 기능 테스트
- [ ] 스플래시 화면 정상 동작
- [ ] 온보딩 플로우 완료
- [ ] 3일 챌린지 생성 및 완료
- [ ] 일일 루틴 생성 및 완료
- [ ] 알림 시스템 동작 확인
- [ ] 앱 종료 후 데이터 보존 확인

#### 성능 테스트
- [ ] 앱 시작 시간 3초 이내
- [ ] 메모리 사용량 정상 범위
- [ ] 배터리 소모량 최적화
- [ ] 네트워크 없이 정상 동작

#### 호환성 테스트
- [ ] Android 5.0 이상에서 정상 동작
- [ ] iOS 11.0 이상에서 정상 동작
- [ ] 다양한 화면 크기 지원
- [ ] 다크 모드 지원

### 🏪 스토어 준비 사항

#### Google Play Store
- [ ] Google Play Console 계정 등록
- [ ] 앱 서명 키 업로드
- [ ] 스크린샷 5장 준비
- [ ] 앱 아이콘 512x512 준비
- [ ] 개인정보 처리방침 URL 등록

#### Apple App Store
- [ ] Apple Developer 계정 등록
- [ ] App Store Connect 설정
- [ ] 스크린샷 각 화면 크기별 준비
- [ ] 앱 아이콘 1024x1024 준비
- [ ] 앱 미리보기 비디오 준비

## 🔨 빌드 가이드

### Android 릴리즈 빌드
```bash
# 1. 의존성 업데이트
flutter pub get

# 2. 코드 생성
flutter packages pub run build_runner build --delete-conflicting-outputs

# 3. 릴리즈 빌드 생성
flutter build apk --release --obfuscate --split-debug-info=build/app/outputs/symbols

# 4. AAB 빌드 (Play Store 권장)
flutter build appbundle --release --obfuscate --split-debug-info=build/app/outputs/symbols
```

### iOS 릴리즈 빌드
```bash
# 1. iOS 빌드
flutter build ios --release

# 2. Xcode에서 Archive
# Product > Archive 선택
# Organizer에서 "Distribute App" 선택
```

### 빌드 후 확인사항
```bash
# APK 크기 확인
ls -lh build/app/outputs/flutter-apk/

# 권한 확인
aapt dump permissions build/app/outputs/flutter-apk/app-release.apk

# 서명 확인
jarsigner -verify -verbose -certs build/app/outputs/flutter-apk/app-release.apk
```

## ⚠️ 주의사항

### 민감정보 제거
- [ ] 개발용 API 키 제거
- [ ] 테스트 데이터 제거
- [ ] 디버그 로그 제거
- [ ] 개발용 설정 제거

### 법적 요구사항
- [ ] 개인정보 처리방침 링크 추가
- [ ] 이용약관 작성 (필요시)
- [ ] 오픈소스 라이선스 고지
- [ ] 광고 정책 준수

## 📊 출시 후 모니터링

### 필수 모니터링 항목
- [ ] 크래시 발생률 (Firebase Crashlytics)
- [ ] 앱 시작 시간
- [ ] 사용자 리텐션
- [ ] 광고 수익
- [ ] 사용자 피드백

### 모니터링 도구
- **Firebase Crashlytics**: 크래시 리포트
- **Google Play Console**: 다운로드 및 리뷰
- **App Store Connect**: iOS 앱 성능
- **Firebase Analytics**: 사용자 행동 분석

## 🎯 출시 후 계획

### 1주차
- 크래시 및 주요 버그 수정
- 사용자 리뷰 모니터링
- 성능 최적화

### 1개월차
- 사용자 피드백 기반 개선
- 추가 기능 개발 시작
- 마케팅 활동 시작

### 3개월차
- 주요 기능 업데이트
- 글로벌 출시 준비
- 사용자 증가 전략 실행

## 🚨 긴급 대응 계획

### 심각한 크래시 발생 시
1. Firebase Crashlytics에서 크래시 로그 확인
2. 핫픽스 버전 개발
3. 긴급 업데이트 배포
4. 사용자 공지

### 사용자 불만 급증 시
1. 리뷰 및 피드백 분석
2. 문제점 파악 및 해결책 마련
3. 개선 계획 공유
4. 업데이트 일정 안내

---

**출시 승인자**: gyhmac
**출시 예정일**: 2024년 12월 중
**버전**: 1.0.0 