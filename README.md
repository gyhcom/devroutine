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
│   │   ├── data/             # 데이터 계층 (Repository 구현, 로컬 데이터소스)
│   │   ├── domain/           # 도메인 계층 (엔티티, 인터페이스)
│   │   └── presentation/     # 프레젠테이션 계층 (UI, 상태 관리)
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

2. **루틴 관리 기능**
   - 루틴 CRUD 기능 구현
   - 우선순위 시스템 (높음, 중간, 낮음)
   - 우선순위 기반 자동 정렬
   - 메모 기능
   - 태그 시스템
   - 목표 달성 횟수 설정
   - 시작일/종료일 설정

3. **데이터 저장**
   - Hive를 사용한 로컬 데이터 저장
   - Optimistic Updates 패턴 적용
   - 자동 상태 복구 시스템

4. **UI/UX**
   - 우선순위별 시각적 표시
   - 진행률 표시
   - 직관적인 태그 디스플레이
   - 부드러운 상태 전환
   - 에러 처리 및 피드백

## 다음 구현 예정 기능

1. **통계 기능**
   - 일간/주간/월간 달성률
   - 시각화 그래프
   - 우선순위별 달성률

2. **UI/UX 개선**
   - 애니메이션 효과 추가
   - 필터링 기능
   - 검색 기능 개선

3. **추가 기능**
   - 알림 시스템
   - 루틴 템플릿
   - 루틴 공유

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

## 주요 패턴 및 원칙

1. **Clean Architecture**
   - 데이터, 도메인, 프레젠테이션 계층 분리
   - 의존성 역전 원칙 준수
   - 테스트 용이성 확보

2. **상태 관리**
   - Riverpod을 사용한 상태 관리
   - Optimistic Updates 패턴 적용
   - 자동 상태 복구 메커니즘

3. **에러 처리**
   - 사용자 친화적 에러 메시지
   - 자동 복구 시스템
   - 일관된 에러 처리 패턴

4. **코드 스타일**
   - 일관된 네이밍 컨벤션
   - 명확한 책임 분리
   - 재사용 가능한 컴포넌트
