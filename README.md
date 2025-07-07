# 3일 루틴 챌린지 앱

**3일 동안 지속하는 습관 형성 앱**

작은 변화로 큰 성과를 만들어보세요! 3일 동안 지속하는 것만으로도 새로운 습관의 첫걸음을 내딛을 수 있습니다.

## 📱 앱 소개

3일 루틴 챌린지 앱은 단기간 집중 습관 형성을 통해 사용자의 성공 경험을 쌓아가는 앱입니다. 
- **3일 챌린지**: 연속 3일 동안 목표를 달성하는 집중 루틴
- **일일 루틴**: 매일 반복하는 지속적인 습관 관리
- **통합 대시보드**: 오늘의 할 일을 한눈에 확인

## 🎯 핵심 기능

### 1. 3일 챌린지 루틴
- **연속 3일 집중 도전**: 하나의 목표를 3일 동안 지속
- **일차별 자동 관리**: 1일차, 2일차, 3일차 자동 생성 및 관리
- **그룹 단위 추적**: 3일 챌린지 전체 진행률 실시간 확인
- **완주 축하 시스템**: 3일 완주 시 특별한 축하 메시지

### 2. 일일 루틴 관리
- **지속적인 습관 추적**: 매일 반복되는 루틴 관리
- **유연한 기간 설정**: 시작일/종료일 자유 설정
- **완료 히스토리**: 과거 완료 기록 추적

### 3. 통합 대시보드
- **오늘의 할 일 요약**: 일일 루틴과 3일 챌린지 통합 표시
- **진행률 시각화**: 완료 상태를 직관적으로 확인
- **우선순위 기반 정렬**: 중요한 일부터 먼저 표시

### 4. 스마트 관리 시스템
- **우선순위 시스템**: 높음(🔴), 중간(🟡), 낮음(🟢) 3단계
- **자동 정렬**: 우선순위와 상태에 따른 스마트 정렬
- **실시간 동기화**: 변경사항 즉시 반영

## 🛠 기술 스택

### 프레임워크 & 언어
- **Flutter** 3.x
- **Dart** 3.x

### 상태 관리
- **flutter_riverpod** ^2.5.1 - 상태 관리
- **riverpod_annotation** ^2.3.5 - 코드 생성 지원

### 로컬 데이터베이스
- **hive** ^2.2.3 - NoSQL 로컬 데이터베이스
- **hive_flutter** ^1.1.0 - Flutter 통합 지원

### 라우팅
- **auto_route** ^7.8.4 - 선언적 라우팅

### 모델 & 직렬화
- **freezed** ^2.4.7 - 불변 모델 생성
- **json_annotation** ^4.8.1 - JSON 직렬화

### UI & 광고
- **google_fonts** ^6.2.1 - Source Code Pro 폰트
- **google_mobile_ads** ^4.0.0 - AdMob 광고
- **another_flushbar** ^1.10.29 - 사용자 피드백

### 유틸리티
- **intl** ^0.19.0 - 국제화 지원
- **uuid** ^4.3.3 - 고유 ID 생성
- **path_provider** ^2.1.2 - 파일 시스템 접근

## 🏗 프로젝트 구조

```
lib/
├── core/                           # 핵심 공통 모듈
│   ├── constants/                  # 상수 정의
│   │   ├── app_colors.dart        # 색상 팔레트
│   │   ├── app_fonts.dart         # 폰트 설정
│   │   └── app_sizes.dart         # 크기 상수
│   ├── providers/                  # 전역 상태 관리
│   │   ├── theme_provider.dart    # 테마 관리
│   │   └── ad_provider.dart       # 광고 상태 관리
│   ├── routing/                    # 라우팅 설정
│   │   ├── app_router.dart        # 라우트 정의
│   │   └── app_router.gr.dart     # 자동 생성 라우트
│   ├── services/                   # 서비스 계층
│   │   └── ad_service.dart        # 광고 서비스
│   ├── theme/                      # 테마 설정
│   │   ├── app_theme.dart         # 다크 테마
│   │   └── typography.dart        # 타이포그래피
│   ├── utils/                      # 유틸리티
│   │   └── debug_logger.dart      # 디버그 로거
│   └── widgets/                    # 공통 위젯
│       └── banner_ad_widget.dart  # 배너 광고 위젯
├── features/                       # 기능별 모듈
│   └── routine/                    # 루틴 관리 기능
│       ├── data/                   # 데이터 계층
│       │   ├── datasources/        # 데이터 소스
│       │   │   └── routine_local_datasource.dart
│       │   ├── models/             # 데이터 모델
│       │   │   └── routine_model.dart
│       │   └── repositories/       # 리포지토리 구현
│       │       └── routine_repository_impl.dart
│       ├── domain/                 # 도메인 계층
│       │   ├── entities/           # 도메인 엔티티
│       │   │   └── routine.dart
│       │   ├── models/             # 도메인 모델
│       │   │   ├── failure.dart
│       │   │   ├── result.dart
│       │   │   └── routine_state.dart
│       │   ├── repositories/       # 리포지토리 인터페이스
│       │   │   └── routine_repository.dart
│       │   └── usecases/           # 비즈니스 로직
│       │       ├── delete_routine_usecase.dart
│       │       ├── get_routines_usecase.dart
│       │       ├── save_routine_usecase.dart
│       │       └── update_routine_usecase.dart
│       └── presentation/           # 프레젠테이션 계층
│           ├── providers/          # 상태 관리
│           │   └── routine_provider.dart
│           ├── screens/            # 화면
│           │   ├── dashboard_screen.dart     # 메인 대시보드
│           │   ├── routine_form_screen.dart  # 루틴 생성/수정
│           │   ├── routine_list_screen.dart  # 루틴 목록
│           │   └── routine_detail_screen.dart # 루틴 상세
│           ├── utils/              # 프레젠테이션 유틸리티
│           │   └── priority_color_util.dart
│           └── widgets/            # 기능별 위젯
│               ├── routine_card.dart
│               ├── routine_list_item.dart
│               ├── today_summary_card.dart
│               └── flush_message.dart
└── main.dart                       # 앱 진입점
```

## 🚀 주요 구현 기능

### 1. Clean Architecture 기반 설계
- **계층 분리**: Data, Domain, Presentation 계층 명확히 분리
- **의존성 역전**: 인터페이스 기반 의존성 주입
- **테스트 용이성**: 각 계층별 독립적인 테스트 가능

### 2. 3일 챌린지 시스템
- **자동 루틴 생성**: 하나의 목표로 3개의 연속 루틴 자동 생성
- **그룹 관리**: `groupId`를 통한 3일 루틴 그룹 관리
- **일차별 추적**: 1일차, 2일차, 3일차 개별 완료 상태 관리
- **완주 감지**: 3일 모두 완료 시 자동 축하 메시지

### 3. 스마트 상태 관리
- **Optimistic Updates**: 즉각적인 UI 반응
- **자동 복구**: 실패 시 이전 상태로 자동 복구
- **실시간 동기화**: 상태 변경 즉시 전체 앱 동기화

### 4. 사용자 경험 최적화
- **직관적인 우선순위 표시**: 색상 기반 우선순위 구분
- **스마트 정렬**: 우선순위 + 완료 상태 기반 자동 정렬
- **실시간 피드백**: 작업 완료 시 즉각적인 시각적 피드백

### 5. 광고 시스템
- **AdMob 통합**: Google AdMob 배너 광고
- **지능형 로딩**: 재시도 로직과 캐싱 지원
- **성능 최적화**: 광고 로드 실패 시 자동 재시도

## 📊 데이터 모델

### Routine Entity
```dart
class Routine {
  final String id;                    // 고유 식별자
  final String title;                 // 루틴 제목
  final String? memo;                 // 메모
  final bool isActive;                // 활성 상태
  final DateTime createdAt;           // 생성일
  final DateTime updatedAt;           // 수정일
  final List<String> tags;            // 태그 목록
  final int targetCompletionCount;    // 목표 완료 횟수
  final int currentCompletionCount;   // 현재 완료 횟수
  final DateTime startDate;           // 시작일
  final DateTime? endDate;            // 종료일
  final String? category;             // 카테고리
  final Priority priority;            // 우선순위
  final DateTime? completedAt;        // 완료일
  final List<DateTime> completionHistory; // 완료 히스토리
  final RoutineType routineType;      // 루틴 타입 (일일/3일)
  final String? groupId;              // 그룹 ID (3일 루틴용)
  final int? dayNumber;               // 일차 (3일 루틴용)
}
```

### 루틴 타입
- **RoutineType.daily**: 일일 루틴 (반복)
- **RoutineType.threeDay**: 3일 챌린지 루틴

### 우선순위
- **Priority.high**: 높음 (🔴)
- **Priority.medium**: 중간 (🟡)
- **Priority.low**: 낮음 (🟢)

## 🎨 디자인 시스템

### 색상 팔레트
- **Primary**: GitHub 스타일 블루 (#2188FF)
- **Secondary**: VS Code 스타일 민트 (#4EC9B0)
- **Background**: 다크 테마 (#1E1E1E)
- **Surface**: 카드 배경 (#252526)

### 타이포그래피
- **Primary Font**: Source Code Pro
- **크기**: H1(32px), H2(24px), H3(20px), Body(16px), Caption(14px)

### 우선순위 색상
- **높음**: 빨간색 (#FF4444)
- **중간**: 노란색 (#FFD700)
- **낮음**: 초록색 (#4CAF50)

## 🔧 설치 및 실행

### 1. 의존성 설치
```bash
flutter pub get
```

### 2. 코드 생성
```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. 앱 실행
```bash
flutter run
```

## 📱 사용 방법

### 3일 챌린지 시작하기
1. **➕ 버튼** 클릭
2. **3일 루틴** 선택
3. **목표 입력** (예: "매일 물 2L 마시기")
4. **우선순위 설정**
5. **생성** 버튼 클릭
6. **3일 연속 실행** 🎯

### 일일 루틴 만들기
1. **➕ 버튼** 클릭
2. **일일 루틴** 선택
3. **목표 입력**
4. **기간 설정** (시작일/종료일)
5. **생성** 버튼 클릭

### 루틴 완료하기
1. **대시보드**에서 오늘의 할 일 확인
2. **완료 버튼** 클릭
3. **진행률 확인**
4. **3일 챌린지 완주 시 축하 메시지** 🎉

## 🏆 성과 측정

### 완료율 추적
- **일일 완료율**: 오늘 완료한 루틴 비율
- **3일 챌린지 완주율**: 성공한 3일 챌린지 수
- **연속 달성일**: 지속적인 습관 형성 측정

### 시각적 피드백
- **진행률 바**: 실시간 완료 상태 표시
- **우선순위 색상**: 중요도에 따른 색상 구분
- **완료 체크**: 명확한 완료 상태 표시

## 🔮 향후 개발 계획

### 1단계: 기본 기능 확장
- [ ] 통계 대시보드 (주간/월간 리포트)
- [ ] 루틴 카테고리 관리
- [ ] 검색 및 필터링 기능

### 2단계: 사용자 경험 개선
- [ ] 알림 시스템
- [ ] 루틴 템플릿
- [ ] 다양한 3일 챌린지 프리셋

### 3단계: 고급 기능
- [ ] 소셜 기능 (친구와 챌린지 공유)
- [ ] 성취 배지 시스템
- [ ] 데이터 백업/복원

## 🤝 기여하기

1. **Fork** 프로젝트
2. **Feature branch** 생성 (`git checkout -b feature/amazing-feature`)
3. **Commit** 변경사항 (`git commit -m 'Add amazing feature'`)
4. **Push** 브랜치 (`git push origin feature/amazing-feature`)
5. **Pull Request** 생성

## 📄 라이선스

이 프로젝트는 MIT 라이선스 하에 배포됩니다.

## 🎯 핵심 가치

> **"작은 변화, 큰 성과"**
> 
> 3일이라는 짧은 기간 동안의 집중으로 새로운 습관의 가능성을 발견하고, 
> 성공 경험을 통해 더 큰 변화를 만들어가는 것이 이 앱의 핵심 가치입니다.

---

**🚀 지금 바로 3일 챌린지를 시작해보세요!**
