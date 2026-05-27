# CAN 프로젝트 기능 분해도 (Function Map / Work Breakdown Structure)

**ICT CampusNav 프로젝트 기능 계층적 분해**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project Code:** CAN-001

**Designed by:** Development Team

---

## 목차 (Table of Contents)

1. [기능 분해도 개요](#1-기능-분해도-개요)
2. [전체 기능 트리 구조](#2-전체-기능-트리-구조)
3. [1단계: 주요 기능 영역](#3-1단계-주요-기능-영역)
4. [2단계: 중분류 기능](#4-2단계-중분류-기능)
5. [3단계: 원자 단위 기능](#5-3단계-원자-단위-기능)
6. [기능-요구사항 매핑](#6-기능-요구사항-매핑)
7. [기능-구현 대상 매핑](#7-기능-구현-대상-매핑)
8. [기능 우선순위 및 의존성](#8-기능-우선순위-및-의존성)

---

## 1. 기능 분해도 개요

### 1.1 목적
- 시스템의 모든 기능을 논리적으로 계층화
- 각 기능의 범위와 책임을 명확히 정의
- 요구사항과 기능의 추적성 확보
- 개발 일정 계획의 기반 제공

### 1.2 분해 원칙
```
1. 계층적 분해 (Hierarchical Decomposition)
   - L0: CAN 시스템 (전체)
   - L1: 기능 영역 (6개)
   - L2: 중분류 기능 (20+개)
   - L3: 원자 기능 (40+개)

2. 원자성 (Atomicity)
   - L3 기능은 더 이상 분해 불가
   - 하나의 Servlet/JSP로 구현 가능

3. 상호 배타성 (Mutual Exclusivity)
   - 각 기능은 겹치지 않음
   - 명확한 경계

4. 완전성 (Completeness)
   - 모든 요구사항 포함
   - 누락 없음
```

### 1.3 표기법

```
## [FID] 기능명 (Function Level)
- **설명:** 기능 설명
- **액터:** 관련 역할
- **입출력:** 입력 → 출력
- **요구사항 ID:** 관련 FR/NFR
- **구현 대상:** Servlet, JSP, DAO 등
- **우선순위:** 높음/중간/낮음
- **상태:** 완료/진행중/기획

FID 명명:
- F1.1.1: 레벨1-레벨2-레벨3
  F1: 인증 및 접근 제어
  F1.1: 사용자 인증
  F1.1.1: 로그인
```

---

## 2. 전체 기능 트리 구조

```
┌─ CAN (ICT CampusNav) 통합 시스템
│
├─ F1. 인증 및 접근 제어 (Authentication & Authorization)
│  ├─ F1.1 사용자 인증 (User Authentication)
│  │  ├─ F1.1.1 로그인 (Login)
│  │  ├─ F1.1.2 로그아웃 (Logout)
│  │  └─ F1.1.3 세션 관리 (Session Management)
│  │
│  └─ F1.2 권한 관리 (Authorization)
│     ├─ F1.2.1 역할 확인 (Role Verification)
│     ├─ F1.2.2 기능 접근 제어 (Function Access Control)
│     └─ F1.2.3 데이터 접근 제어 (Data Access Control)
│
├─ F2. 자산 관리 (Asset Management)
│  ├─ F2.1 자산 조회 (Asset Inquiry)
│  │  ├─ F2.1.1 자산 검색 (Search Assets)
│  │  ├─ F2.1.2 자산 상세정보 조회 (View Asset Details)
│  │  ├─ F2.1.3 자산 목록 조회 (List Assets)
│  │  └─ F2.1.4 자산 카테고리 조회 (Browse by Category)
│  │
│  ├─ F2.2 자산 예약 (Asset Reservation)
│  │  ├─ F2.2.1 예약 신청 (Request Reservation)
│  │  ├─ F2.2.2 예약 취소 (Cancel Reservation)
│  │  ├─ F2.2.3 예약 조회 (View Reservations)
│  │  └─ F2.2.4 중복 예약 방지 (Prevent Double Booking)
│  │
│  ├─ F2.3 자산 이관 (Asset Transfer)
│  │  ├─ F2.3.1 이관 요청 (Request Transfer)
│  │  ├─ F2.3.2 이관 승인 (Approve Transfer)
│  │  ├─ F2.3.3 이관 반려 (Reject Transfer)
│  │  ├─ F2.3.4 이관 이력 조회 (View Transfer History)
│  │  └─ F2.3.5 이관 상태 추적 (Track Transfer Status)
│  │
│  └─ F2.4 자산 폐기 (Asset Disposal)
│     ├─ F2.4.1 폐기 신청 (Request Disposal)
│     ├─ F2.4.2 폐기 승인 (Approve Disposal)
│     └─ F2.4.3 폐기 이력 조회 (View Disposal History)
│
├─ F3. 교수 관리 (Professor Management)
│  ├─ F3.1 교수 정보 조회 (Professor Inquiry)
│  │  ├─ F3.1.1 교수 검색 (Search Professors)
│  │  ├─ F3.1.2 교수 상세정보 (View Professor Details)
│  │  └─ F3.1.3 교수 목록 (List Professors)
│  │
│  └─ F3.2 교수 프로필 관리 (Professor Profile Management)
│     ├─ F3.2.1 교과목 정보 입력 (Enter Courses)
│     ├─ F3.2.2 전문 분야 입력 (Enter Skills)
│     ├─ F3.2.3 프로필 수정 (Edit Profile)
│     └─ F3.2.4 프로필 조회 (View Profile)
│
├─ F4. 내비게이션 (Navigation)
│  ├─ F4.1 층별 맵 (Floor Maps)
│  │  ├─ F4.1.1 건물 선택 (Select Building)
│  │  ├─ F4.1.2 층 선택 (Select Floor)
│  │  ├─ F4.1.3 층별 맵 표시 (Display Floor Map)
│  │  └─ F4.1.4 자산 마커 표시 (Show Asset Markers)
│  │
│  ├─ F4.2 3D 맵 (3D Navigation)
│  │  ├─ F4.2.1 3D 모델 로드 (Load 3D Model)
│  │  ├─ F4.2.2 건물/층 선택 (Select Building/Floor)
│  │  ├─ F4.2.3 3D 뷰 제어 (Control 3D View)
│  │  └─ F4.2.4 자산 위치 표시 (Display Asset Locations)
│  │
│  └─ F4.3 경로 관리 (Route Management)
│     ├─ F4.3.1 경로 저장 (Save Route)
│     ├─ F4.3.2 저장된 경로 조회 (View Saved Routes)
│     └─ F4.3.3 경로 삭제 (Delete Route)
│
├─ F5. 대시보드 (Dashboard / Portal)
│  ├─ F5.1 학부생 대시보드 (Student Dashboard)
│  │  ├─ F5.1.1 내 예약 조회 (View My Reservations)
│  │  ├─ F5.1.2 인기 자산 표시 (Show Popular Assets)
│  │  └─ F5.1.3 빠른 접근 메뉴 (Quick Access Menu)
│  │
│  ├─ F5.2 조교 대시보드 (Assistant Dashboard)
│  │  ├─ F5.2.1 승인대기 항목 표시 (Show Pending Approvals)
│  │  ├─ F5.2.2 이관 현황 조회 (View Transfer Status)
│  │  └─ F5.2.3 통계 표시 (Show Statistics)
│  │
│  ├─ F5.3 교수 대시보드 (Professor Dashboard)
│  │  ├─ F5.3.1 담당 교과목 표시 (Show Courses)
│  │  └─ F5.3.2 프로필 관리 메뉴 (Profile Management Menu)
│  │
│  ├─ F5.4 관리자 대시보드 (Admin Dashboard)
│  │  ├─ F5.4.1 자산 현황 표시 (Show Asset Status)
│  │  ├─ F5.4.2 통계 및 그래프 (Show Statistics & Graphs)
│  │  ├─ F5.4.3 사용자 현황 (Show User Status)
│  │  └─ F5.4.4 시스템 상태 (Show System Status)
│  │
│  ├─ F5.5 게스트 대시보드 (Guest Portal)
│  │  ├─ F5.5.1 자산 검색 (Search Assets)
│  │  ├─ F5.5.2 내비게이션 조회 (View Navigation)
│  │  └─ F5.5.3 로그인 유도 (Prompt Login)
│  │
│  └─ F5.6 외부인 내비게이션 (Visitor Portal)
│     ├─ F5.6.1 층별 맵 조회 (View Floor Maps)
│     └─ F5.6.2 3D 맵 조회 (View 3D Map)
│
├─ F6. 시스템 관리 (System Administration)
│  ├─ F6.1 감사 로그 (Audit Logging)
│  │  ├─ F6.1.1 작업 기록 (Log Actions)
│  │  ├─ F6.1.2 감사 로그 조회 (View Audit Log)
│  │  └─ F6.1.3 로그 분석 (Analyze Logs)
│  │
│  ├─ F6.2 사용자 관리 (User Management)
│  │  ├─ F6.2.1 사용자 정보 조회 (View User Info)
│  │  ├─ F6.2.2 사용자 정보 수정 (Edit User Info)
│  │  ├─ F6.2.3 비밀번호 변경 (Change Password)
│  │  └─ F6.2.4 권한 관리 (Manage Permissions)
│  │
│  └─ F6.3 시스템 설정 (System Configuration)
│     ├─ F6.3.1 시스템 파라미터 설정 (Configure Parameters)
│     ├─ F6.3.2 백업 관리 (Manage Backups)
│     └─ F6.3.3 시스템 모니터링 (Monitor System)
│
└─ F7. 공통 기능 (Common Features)
   ├─ F7.1 검색 및 필터링 (Search & Filtering)
   │  ├─ F7.1.1 키워드 검색 (Keyword Search)
   │  ├─ F7.1.2 카테고리 필터 (Category Filter)
   │  ├─ F7.1.3 상태 필터 (Status Filter)
   │  └─ F7.1.4 페이지네이션 (Pagination)
   │
   ├─ F7.2 입력 검증 (Input Validation)
   │  ├─ F7.2.1 필드 검증 (Field Validation)
   │  ├─ F7.2.2 형식 검증 (Format Validation)
   │  └─ F7.2.3 비즈니스 규칙 검증 (Business Rule Validation)
   │
   ├─ F7.3 보안 (Security)
   │  ├─ F7.3.1 HTTPS 지원 (HTTPS Support)
   │  ├─ F7.3.2 입력 정제 (Input Sanitization)
   │  ├─ F7.3.3 암호화 (Encryption)
   │  └─ F7.3.4 감사 추적 (Audit Trail)
   │
   ├─ F7.4 에러 처리 (Error Handling)
   │  ├─ F7.4.1 예외 처리 (Exception Handling)
   │  ├─ F7.4.2 에러 메시지 (Error Messages)
   │  └─ F7.4.3 로깅 (Logging)
   │
   └─ F7.5 응답성 및 성능 (Performance)
      ├─ F7.5.1 페이지 로딩 (Page Loading)
      ├─ F7.5.2 쿼리 응답 (Query Response)
      └─ F7.5.3 캐싱 (Caching)
```

---

## 3. 1단계: 주요 기능 영역

| FID | 기능 영역 | 설명 | 액터 | 우선순위 | 상태 |
|-----|---------|------|------|---------|------|
| **F1** | 인증 및 접근 제어 | 사용자 로그인/로그아웃, 역할별 권한 | 모든 사용자 | 🔴 높음 | ✓ 진행 |
| **F2** | 자산 관리 | 자산 검색/예약/이관/폐기 | 학부생, 조교, 관리자 | 🔴 높음 | ▲ 진행 |
| **F3** | 교수 관리 | 교수 정보/프로필 관리 | 교수, 모든 사용자 | 🟠 중간 | ◐ 기획 |
| **F4** | 내비게이션 | 층별/3D 맵, 경로 관리 | 모든 사용자 | 🟠 중간 | ▲ 진행 |
| **F5** | 대시보드 | 역할별 포탈, 메인 페이지 | 모든 사용자 | 🟠 중간 | ▲ 진행 |
| **F6** | 시스템 관리 | 감사 로그, 사용자 관리, 설정 | 관리자 | 🟠 중간 | ◐ 기획 |
| **F7** | 공통 기능 | 검색, 검증, 보안, 에러 처리 | 시스템 | 🔴 높음 | ▲ 진행 |

---

## 4. 2단계: 중분류 기능

### F1. 인증 및 접근 제어

#### **F1.1 사용자 인증 (User Authentication)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F1.1.1** | 로그인 | 사용자명과 비밀번호로 인증 | username, password | 세션 생성 | FR-AUTH-001 | LoginServlet |
| **F1.1.2** | 로그아웃 | 세션 종료, 로그인 페이지로 이동 | JSESSIONID | 로그인 페이지 | FR-AUTH-002 | LogoutServlet |
| **F1.1.3** | 세션 관리 | 세션 생성/유지/타임아웃 | Session | Session 정보 | NFR-SEC-004 | Filter |

#### **F1.2 권한 관리 (Authorization)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F1.2.1** | 역할 확인 | 세션에서 사용자 역할 추출 | JSESSIONID | role | FR-AUTH-003 | Filter |
| **F1.2.2** | 기능 접근 제어 | 역할에 따른 기능 접근 허용/거부 | role, URL | 200 또는 403 | FR-AUTH-003 | Filter |
| **F1.2.3** | 데이터 접근 제어 | 사용자가 해당 데이터 접근 권한 확인 | role, dataId | 접근 허용/거부 | FR-AUTH-003 | DAO |

---

### F2. 자산 관리

#### **F2.1 자산 조회 (Asset Inquiry)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F2.1.1** | 자산 검색 | 키워드/카테고리/상태로 검색 | keyword, category, status | 자산 목록 | FR-ASSET-001 | SearchServlet |
| **F2.1.2** | 상세정보 조회 | 자산 ID로 상세정보 조회 | asset_id | 자산 정보, 예약 현황 | FR-ASSET-002 | DetailServlet |
| **F2.1.3** | 목록 조회 | 자산 목록 페이지네이션 | page, size | 자산 목록 + 메타정보 | FR-ASSET-001 | SearchServlet |
| **F2.1.4** | 카테고리 조회 | 카테고리별 자산 조회 | category | 자산 목록 | FR-ASSET-001 | SearchServlet |

#### **F2.2 자산 예약 (Asset Reservation)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F2.2.1** | 예약 신청 | 자산 예약 신청 | asset_id, from_time, to_time | 예약 확인 | FR-ASSET-003 | ReserveServlet |
| **F2.2.2** | 예약 취소 | 자신의 예약 취소 | reservation_id | 취소 확인 | FR-ASSET-004 | ReserveServlet |
| **F2.2.3** | 예약 조회 | 자신의 예약 목록 조회 | user_id | 예약 목록 | FR-ASSET-003 | ReserveServlet |
| **F2.2.4** | 중복 방지 | 이미 예약된 시간 검사 | asset_id, from_time, to_time | 중복 여부 | FR-ASSET-003 | ReserveDAO |

#### **F2.3 자산 이관 (Asset Transfer)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F2.3.1** | 이관 요청 | 자산 이관 요청 생성 | asset_id, to_location, reason | 요청 확인 | FR-ASSET-005 | RegisterServlet |
| **F2.3.2** | 이관 승인 | 이관 요청 승인 | transfer_id | 승인 완료 | FR-ASSET-005 | RegisterServlet |
| **F2.3.3** | 이관 반려 | 이관 요청 반려 | transfer_id, reason | 반려 완료 | FR-ASSET-005 | RegisterServlet |
| **F2.3.4** | 이력 조회 | 자산의 이관 이력 조회 | asset_id | 이관 이력 목록 | FR-ASSET-005 | TransferDAO |
| **F2.3.5** | 상태 추적 | 이관 요청의 현재 상태 확인 | transfer_id | 상태 정보 | FR-ASSET-005 | TransferDAO |

#### **F2.4 자산 폐기 (Asset Disposal)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F2.4.1** | 폐기 신청 | 자산 폐기 신청 (관리자) | asset_id, reason | 폐기 확인 | FR-ASSET-006 | AssetServlet |
| **F2.4.2** | 폐기 승인 | 폐기 승인 | asset_id | 승인 완료 | FR-ASSET-006 | AssetServlet |
| **F2.4.3** | 폐기 이력 | 폐기된 자산 이력 조회 | date_range | 폐기 이력 목록 | FR-ASSET-006 | AssetDAO |

---

### F3. 교수 관리

#### **F3.1 교수 정보 조회 (Professor Inquiry)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F3.1.1** | 교수 검색 | 교수명/학과로 검색 | name, department | 교수 목록 | FR-PROF-001 | ProfessorServlet |
| **F3.1.2** | 상세정보 | 교수 상세정보 조회 | professor_id | 교수 정보, 교과목 | FR-PROF-001 | ProfessorServlet |
| **F3.1.3** | 목록 조회 | 전체 교수 목록 | page, size | 교수 목록 | FR-PROF-001 | ProfessorServlet |

#### **F3.2 교수 프로필 관리 (Professor Profile)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F3.2.1** | 교과목 입력 | 담당 교과목 등록 | course_id, name, semester | 등록 확인 | FR-PROF-002 | CourseDAO |
| **F3.2.2** | 전문분야 입력 | 스킬/전문분야 등록 | skills (태그) | 등록 확인 | FR-PROF-002 | ProfessorDAO |
| **F3.2.3** | 프로필 수정 | 프로필 정보 수정 | profile_data | 수정 확인 | FR-PROF-002 | ProfessorServlet |
| **F3.2.4** | 프로필 조회 | 자신의 프로필 조회 | user_id | 프로필 정보 | FR-PROF-002 | ProfessorDAO |

---

### F4. 내비게이션

#### **F4.1 층별 맵 (Floor Maps)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F4.1.1** | 건물 선택 | 건물 목록에서 선택 | building_list | 선택된 건물 | FR-NAV-001 | floorNav.jsp |
| **F4.1.2** | 층 선택 | 층 버튼 선택 | floor_number | 해당 층 맵 | FR-NAV-001 | floorNav.jsp |
| **F4.1.3** | 맵 표시 | 층별 맵 이미지 표시 | floor_id | 맵 이미지 | FR-NAV-001 | floorNav.jsp |
| **F4.1.4** | 마커 표시 | 자산 위치 마커 표시 | asset_locations | 마커 클러스터 | FR-NAV-001 | JavaScript |

#### **F4.2 3D 맵 (3D Navigation)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F4.2.1** | 3D 모델 로드 | 3D 캠퍼스 모델 로드 | 없음 | 3D 모델 | FR-NAV-002 | Three.js |
| **F4.2.2** | 건물/층 선택 | 3D 에서 건물/층 선택 | building, floor | 선택된 층 표시 | FR-NAV-002 | Three.js |
| **F4.2.3** | 뷰 제어 | 회전, 줌, 팬 | mouse events | 업데이트된 뷰 | FR-NAV-002 | JavaScript |
| **F4.2.4** | 자산 위치 | 3D 맵에 자산 마커 표시 | asset_locations | 3D 마커 | FR-NAV-002 | Three.js |

#### **F4.3 경로 관리 (Route Management)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F4.3.1** | 경로 저장 | 경로 저장 요청 | start, end, route_name | 저장 확인 | FR-NAV-003 | saveRoute.jsp |
| **F4.3.2** | 경로 조회 | 저장된 경로 목록 조회 | user_id | 경로 목록 | FR-NAV-003 | getRoutes.jsp |
| **F4.3.3** | 경로 삭제 | 저장된 경로 삭제 | route_id | 삭제 확인 | FR-NAV-003 | deleteRoute.jsp |

---

### F5. 대시보드

#### **F5.1~F5.6 역할별 대시보드**

| FID | 기능명 | 설명 | 주요 표시 항목 | 요구사항 | 구현 대상 |
|-----|--------|------|-------------|---------|---------|
| **F5.1** | 학부생 대시보드 | 학부생의 홈 화면 | 내 예약, 인기 자산, 빠른 접근 | FR-DASH-001 | main_student.jsp |
| **F5.2** | 조교 대시보드 | 조교의 관리 화면 | 승인대기, 이관 현황, 통계 | FR-DASH-002 | main_assistant.jsp |
| **F5.3** | 교수 대시보드 | 교수의 정보 화면 | 담당 교과목, 프로필 | FR-DASH-003 | main_professor.jsp |
| **F5.4** | 관리자 대시보드 | 관리자의 통제 화면 | 자산 현황, 통계, 사용자 상태 | FR-DASH-004 | main_admin.jsp |
| **F5.5** | 게스트 포탈 | 게스트의 제한 접근 | 자산 검색, 내비게이션 | FR-DASH-005 | main_guest.jsp |
| **F5.6** | 외부인 내비게이션 | 방문객의 길 안내 | 층별 맵, 3D 맵 | FR-DASH-006 | main_visitor.jsp |

---

### F6. 시스템 관리

#### **F6.1 감사 로그 (Audit Logging)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F6.1.1** | 작업 기록 | 모든 주요 작업 자동 기록 | action, user_id, resource | 로그 저장 | FR-OTHER-001 | Filter / Servlet |
| **F6.1.2** | 로그 조회 | 감사 로그 조회 (관리자) | date_range, action | 로그 목록 | FR-OTHER-001 | AuditLogDAO |
| **F6.1.3** | 로그 분석 | 로그 통계 및 분석 | 없음 | 분석 리포트 | FR-OTHER-001 | ReportServlet |

#### **F6.2 사용자 관리 (User Management)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F6.2.1** | 정보 조회 | 자신의 사용자 정보 조회 | user_id | 사용자 정보 | FR-OTHER-002 | UserDAO |
| **F6.2.2** | 정보 수정 | 사용자 정보 수정 | user_data | 수정 확인 | FR-OTHER-002 | UserServlet |
| **F6.2.3** | 비밀번호 변경 | 비밀번호 변경 | old_pwd, new_pwd | 변경 확인 | FR-OTHER-002 | SecurityUtil |
| **F6.2.4** | 권한 관리 | 사용자 역할/권한 변경 (관리자) | user_id, new_role | 변경 확인 | FR-AUTH-003 | UserDAO |

#### **F6.3 시스템 설정 (System Configuration)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F6.3.1** | 파라미터 설정 | 시스템 파라미터 변경 | parameter, value | 설정 저장 | 설계 필요 | ConfigServlet |
| **F6.3.2** | 백업 관리 | 데이터베이스 백업 (관리자) | backup_type | 백업 파일 | 설계 필요 | BackupUtil |
| **F6.3.3** | 시스템 모니터링 | 시스템 상태 모니터링 | 없음 | 상태 정보 | 설계 필요 | MonitoringServlet |

---

### F7. 공통 기능

#### **F7.1 검색 및 필터링 (Search & Filtering)**

| FID | 기능명 | 설명 | 입력 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|------|------|---------|---------|
| **F7.1.1** | 키워드 검색 | 텍스트 검색 | keyword | 검색 결과 | FR-ASSET-001 | SearchServlet |
| **F7.1.2** | 카테고리 필터 | 카테고리별 필터링 | category | 필터된 결과 | FR-ASSET-001 | SearchServlet |
| **F7.1.3** | 상태 필터 | 상태별 필터링 | status | 필터된 결과 | FR-ASSET-001 | SearchServlet |
| **F7.1.4** | 페이지네이션 | 결과 페이지 분할 | page, size | 페이지 데이터 | FR-ASSET-001 | PaginationUtil |

#### **F7.2 입력 검증 (Input Validation)**

| FID | 기능명 | 설명 | 검증 대상 | 출력 | 요구사항 | 구현 대상 |
|-----|--------|------|---------|--------|---------|---------|
| **F7.2.1** | 필드 검증 | 필드 길이, 필수 여부 검증 | 모든 입력 필드 | 검증 결과 | NFR-SEC-005 | ValidationUtil |
| **F7.2.2** | 형식 검증 | 이메일, 전화번호 형식 검증 | email, phone | 검증 결과 | NFR-SEC-005 | ValidationUtil |
| **F7.2.3** | 비즈니스 규칙 | 시간 겹침, 중복 예약 검증 | 예약 데이터 | 검증 결과 | FR-ASSET-003 | ReserveDAO |

#### **F7.3 보안 (Security)**

| FID | 기능명 | 설명 | 적용 범위 | 구현 대상 |
|-----|--------|------|---------|---------|
| **F7.3.1** | HTTPS 지원 | 모든 통신 암호화 | 전체 시스템 | web.xml, Tomcat |
| **F7.3.2** | 입력 정제 | XSS/SQLi 방지 | 모든 입력 필드 | ValidationUtil |
| **F7.3.3** | 암호화 | 비밀번호, 민감정보 암호화 | 비밀번호, PII | SecurityUtil |
| **F7.3.4** | 감사 추적 | 모든 주요 작업 기록 | 전체 작업 | AuditLogDAO |

#### **F7.4 에러 처리 (Error Handling)**

| FID | 기능명 | 설명 | 출력 | 구현 대상 |
|-----|--------|------|------|---------|
| **F7.4.1** | 예외 처리 | try-catch 블록 | 안전한 종료 | 모든 Servlet |
| **F7.4.2** | 에러 메시지 | 사용자 친화적 메시지 | 오류 페이지 | error.jsp |
| **F7.4.3** | 로깅 | 에러 로그 기록 | 로그 파일 | Log4j, SLF4J |

#### **F7.5 응답성 및 성능 (Performance)**

| FID | 기능명 | 설명 | 성능 기준 | 구현 대상 |
|-----|--------|------|---------|---------|
| **F7.5.1** | 페이지 로딩 | 페이지 로딩 최적화 | < 2초 | JavaScript 최소화, 이미지 압축 |
| **F7.5.2** | 쿼리 응답 | DB 쿼리 응답 최적화 | < 1초 | 인덱싱, 쿼리 최적화 |
| **F7.5.3** | 캐싱 | HTTP 캐싱, 데이터 캐싱 | 캐시 히트율 > 70% | 캐시 헤더, Redis (선택) |

---

## 5. 3단계: 원자 단위 기능

_(상세 내용은 위 2단계 섹션 참조)_

원자 단위 기능은 더 이상 분해되지 않는 최소 단위로, 보통 하나의 Servlet/JSP 또는 메서드로 구현됩니다.

예: F2.1.1 자산 검색
```
입력: keyword, category, status, page
처리: SearchServlet.doGet()
     ├─ 입력 검증
     ├─ AssetDAO.searchAssets() 호출
     ├─ 결과 페이지네이션
     └─ searchAssets.jsp로 forward
출력: 자산 목록 + 페이지네이션 정보
```

---

## 6. 기능-요구사항 매핑

### 기능 요구사항 (FR) 매핑표

| 기능 ID | 기능명 | 요구사항 ID | 요구사항 명 | 포함 범위 |
|--------|--------|-----------|-----------|---------|
| F1.1.1 | 로그인 | FR-AUTH-001 | 사용자 인증 | ✓ 포함 |
| F1.1.2 | 로그아웃 | FR-AUTH-002 | 사용자 로그아웃 | ✓ 포함 |
| F1.2.1~3 | 권한 관리 | FR-AUTH-003 | 역할별 권한 제어 | ✓ 포함 |
| F2.1.1~4 | 자산 조회 | FR-ASSET-001 | 자산 검색 | ✓ 포함 |
| F2.1.2 | 상세정보 | FR-ASSET-002 | 자산 상세정보 조회 | ✓ 포함 |
| F2.2.1~4 | 자산 예약 | FR-ASSET-003 | 자산 예약 | ✓ 포함 |
| F2.2.2 | 예약 취소 | FR-ASSET-004 | 자산 예약 취소 | ✓ 포함 |
| F2.3.1~5 | 자산 이관 | FR-ASSET-005 | 자산 이관 | ✓ 포함 |
| F2.4.1~3 | 자산 폐기 | FR-ASSET-006 | 자산 폐기 | ✓ 포함 |
| F3.1.1~3 | 교수 정보 | FR-PROF-001 | 교수 정보 조회 | ✓ 포함 |
| F3.2.1~4 | 교수 프로필 | FR-PROF-002 | 교수 프로필 관리 | ✓ 포함 |
| F4.1.1~4 | 층별 맵 | FR-NAV-001 | 층별 맵 조회 | ✓ 포함 |
| F4.2.1~4 | 3D 맵 | FR-NAV-002 | 3D 맵 기반 내비게이션 | ✓ 포함 |
| F4.3.1~3 | 경로 관리 | FR-NAV-003 | 경로 저장/삭제 | ✓ 포함 |
| F5.1~6 | 대시보드 | FR-DASH-001~006 | 역할별 메인 페이지 | ✓ 포함 |
| F6.1.1~3 | 감사 로그 | FR-OTHER-001 | 감사 로그 기록 | ✓ 포함 |
| F6.2.1~4 | 사용자 관리 | FR-OTHER-002 | 사용자 정보 관리 | ✓ 포함 |
| F7.1~5 | 공통 기능 | NFR-* | 비기능 요구사항 | ✓ 포함 |

---

## 7. 기능-구현 대상 매핑

### Servlet 별 기능 할당

| Servlet | 담당 기능 | 메서드 |
|---------|---------|--------|
| **LoginServlet** | F1.1.1 로그인 | doPost() |
| **LogoutServlet** | F1.1.2 로그아웃 | doGet() |
| **SearchServlet** | F2.1.1~4 자산 조회 | doGet() |
| **DetailServlet** | F2.1.2 상세정보 | doGet() |
| **ReserveServlet** | F2.2.1~4 자산 예약 | doPost() / doGet() |
| **RegisterServlet** | F2.3.1~5 자산 이관 | doPost() / doGet() |
| **AssetServlet** | F2.4.1~3 자산 폐기 | doPost() |
| **GuestServlet** | F5.5 게스트 포탈 | doGet() |
| **VisitorServlet** | F5.6 외부인 포탈 | doGet() |
| **(향후) ProfessorServlet** | F3.1~2 교수 관리 | doGet() / doPost() |

### JSP 별 기능 할당

| JSP 페이지 | 담당 기능 |
|----------|---------|
| **campuslogin.jsp** | F1.1.1 로그인 폼 |
| **main_student.jsp** | F5.1 학부생 대시보드 |
| **main_assistant.jsp** | F5.2 조교 대시보드 |
| **main_professor.jsp** | F5.3 교수 대시보드 |
| **main_admin.jsp** | F5.4 관리자 대시보드 |
| **main_guest.jsp** | F5.5 게스트 포탈 |
| **main_visitor.jsp** | F5.6 외부인 포탈 |
| **searchAssets.jsp** | F2.1.1~4 자산 검색 폼/결과 |
| **detail.jsp** | F2.1.2 자산 상세정보 |
| **reserve.jsp** | F2.2.1~4 자산 예약 폼 |
| **transfer.jsp** | F2.3.1 자산 이관 폼 |
| **disposal_admin.jsp** | F2.4.1~3 자산 폐기 |
| **floorNav.jsp** | F4.1.1~4 층별 맵 |
| **navigationTest1.jsp** | F4.2.1~4 3D 맵 |
| **saveRoute.jsp** | F4.3.1 경로 저장 |
| **getRoutes.jsp** | F4.3.2 경로 조회 |
| **deleteRoute.jsp** | F4.3.3 경로 삭제 |

### DAO 별 기능 할당

| DAO 클래스 | 담당 기능 |
|----------|---------|
| **UserDAO** | F6.2.1~4 사용자 관리 |
| **AssetDAO** | F2.1.1~4 자산 조회, F7.1 검색 |
| **ReservationDAO** | F2.2.1~4 자산 예약 |
| **TransferDAO** | F2.3.1~5 자산 이관 |
| **ProfessorDAO** | F3.1~2 교수 관리 |
| **CourseDAO** | F3.2.1 교과목 관리 |
| **FloorDAO** | F4.1.1~4 층별 맵 데이터 |
| **RouteDAO** | F4.3.1~3 경로 관리 |
| **AuditLogDAO** | F6.1.1~3 감사 로그 |

---

## 8. 기능 우선순위 및 의존성

### 우선순위별 기능 분류

**🔴 높음 (Phase 2-3: 6월 중순~말)**
```
F1.1.1 로그인
F1.1.2 로그아웃
F1.2.1~3 권한 제어
F2.1.1~4 자산 조회
F2.2.1~4 자산 예약
F2.3.1~5 자산 이관
F7.1~3 공통 기능 (검색, 검증, 보안)
```

**🟠 중간 (Phase 3-4: 6월 말~7월 초)**
```
F2.4.1~3 자산 폐기
F4.1.1~4 층별 맵
F4.2.1~4 3D 맵
F5.1~4 주요 역할별 대시보드
F7.4~5 에러 처리, 성능
```

**🟡 낮음 (Phase 4-5: 7월 중~말)**
```
F3.1~2 교수 관리
F4.3.1~3 경로 관리
F5.5~6 게스트/외부인
F6.1~3 시스템 관리
```

### 의존성 관계

```
F1.1.1 (로그인)
  ↓ (필수)
F1.2.1~3 (권한 제어)
  ↓ (필수)
F2.1.1~4 (자산 조회)
  ├─→ F2.2.1~4 (자산 예약)
  └─→ F2.3.1~5 (자산 이관)
       └─→ F2.4.1~3 (자산 폐기)

F2.1.1~4 (자산 조회)
  ↓ (필수)
F4.1.1~4 (층별 맵)
  ↓ (선택적)
F4.2.1~4 (3D 맵)

F1.1.1 (로그인)
  ↓ (필수)
F5.1~6 (대시보드)

F6.1.1~3 (감사 로그)
  ↑ (모든 기능이 기여)
```

### Phase별 기능 구현 계획

**Phase 2 (2026-06-11~06-17): 인증 모듈**
```
✓ F1.1.1 로그인
✓ F1.1.2 로그아웃
✓ F1.2.1~3 권한 제어
```

**Phase 3 (2026-06-18~06-24): 자산 관리**
```
✓ F2.1.1~4 자산 조회
✓ F2.2.1~4 자산 예약
✓ F2.3.1~5 자산 이관
▲ F2.4.1~3 자산 폐기
```

**Phase 4 (2026-06-25~07-01): 내비게이션**
```
▲ F4.1.1~4 층별 맵
▲ F4.2.1~4 3D 맵
▲ F4.3.1~3 경로 관리
▲ F5.1~4 주요 대시보드
```

**Phase 5 (2026-07-02~07-31): 테스트 & 배포**
```
▲ 전체 기능 통합 테스트
▲ 성능 최적화
▲ 배포 및 운영
```

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| v1.0 | 2026-05-27 | 초판 작성 - 기능 계층적 분해 | Development Team |

---

## 참고 자료

- `04_시스템아키텍처설계서_aisw.md` — 시스템 아키텍처
- `03_요구사항명세서_aisw.md` — 요구사항 명세

---

**작성 완료 - 2026-05-27**

이 기능 분해도는 CAN 프로젝트의 개발, 테스트, 배포의 기반이 되며, 각 기능의 구현 순서와 우선순위를 결정하는 데 사용됩니다.

