# DevRoutine

개발자를 위한 루틴 관리 앱입니다. 일일 루틴을 설정하고 추적하여 개발자의 생산성과 습관 형성을 돕습니다.

## 기술 스택

### 프레임워크 & 언어
- Flutter 3.x
- Dart 3.x

### 상태 관리
- flutter_riverpod: ^2.5.1
- riverpod_annotation: ^2.3.5

### 로컬 데이터베이스
- hive: ^2.2.3
- hive_flutter: ^1.1.0

### 라우팅
- auto_route: ^7.8.4

### 모델 생성 & 직렬화
- freezed: ^2.4.7
- freezed_annotation: ^2.4.1
- json_annotation: ^4.8.1

### 유틸리티
- intl: ^0.19.0
- google_fonts: ^6.2.1

## 프로젝트 구조

```
lib/
├── core/
│   ├── constants/
│   │   ├── app_colors.dart    # 색상 상수
│   │   ├── app_fonts.dart     # 폰트 설정
│   │   └── app_sizes.dart     # 크기 상수
│   ├── providers/
│   │   └── theme_provider.dart # 테마 관리
│   ├── routing/
│   │   └── app_router.dart    # 라우팅 설정
│   ├── theme/
│   │   ├── app_theme.dart     # 테마 설정
│   │   └── typography.dart    # 타이포그래피 설정
│   └── utils/
│       └── date_utils.dart    # 날짜 관련 유틸리티
├── features/
│   ├── routine/
│   │   ├── data/
│   │   ├── domain/
│   │   └── presentation/
│   └── statistics/
│       └── ... (통계 기능)
├── common/
│   ├── widgets/
│   └── services/
└── main.dart
```

## 현재 구현된 기능

1. **프로젝트 기본 설정**
   - Clean Architecture 기반 프로젝트 구조
   - 다크 테마 설정
   - SourceCodePro 폰트 적용
   - 기본 색상 및 크기 상수 정의

2. **UI 구현**
   - 메인 화면 기본 레이아웃
   - 다크 테마 기반 디자인
   - 기본 버튼 및 타이포그래피 스타일

## 다음 구현 예정 기능

1. **루틴 관리 기능**
   - 루틴 생성/수정/삭제
   - 요일별 반복 설정
   - 루틴 완료 체크

2. **데이터 저장**
   - Hive를 사용한 로컬 데이터 저장
   - 루틴 데이터 모델 구현

3. **통계 기능**
   - 일간/주간/월간 달성률
   - 시각화 그래프

4. **UI/UX 개선**
   - 플로팅 액션 버튼 추가
   - 루틴 카드 디자인
   - 상단 통계 영역 구현

## 향후 계획

1. **백엔드 연동**
   - Supabase 연동
   - 데이터 동기화

2. **추가 기능**
   - 알림 기능
   - 포모도로 타이머
   - 위젯 지원

## 설치 및 실행

```bash
# 의존성 설치
flutter pub get

# 개발 모드 실행
flutter run
```

## 개발 가이드

- 코드 생성
```bash
# freezed, riverpod 등의 코드 생성
flutter pub run build_runner build --delete-conflicting-outputs
```

- 린트 규칙 적용
```bash
flutter analyze
```
