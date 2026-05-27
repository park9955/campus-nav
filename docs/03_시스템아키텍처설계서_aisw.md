# CAN 프로젝트 시스템 아키텍처 설계서 (Architecture Design)

**ICT CampusNav 프로젝트 시스템 아키텍처 및 인프라 설계**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project Code:** CAN-001

**Designed by:** Development Team | **Reviewed by:** Technical Lead

---

## 목차 (Table of Contents)

1. [아키텍처 설계 개요](#1-아키텍처-설계-개요)
2. [시스템 아키텍처 개요](#2-시스템-아키텍처-개요)
3. [컴포넌트 아키텍처](#3-컴포넌트-아키텍처)
4. [계층별 설계 (Layered Architecture)](#4-계층별-설계-layered-architecture)
5. [데이터 흐름 및 상호작용](#5-데이터-흐름-및-상호-작용)
6. [인프라 구성 (Deployment)](#6-인프라-구성-deployment)
7. [보안 아키텍처](#7-보안-아키텍처)
8. [성능 및 확장성 전략](#8-성능-및-확장성-전략)
9. [배포 전략](#9-배포-전략)
10. [기술 결정 기록 (ADR)](#10-기술-결정-기록-adr)

---

## 1. 아키텍처 설계 개요

### 1.1 목표
- 명확한 계층 구조로 유지보수성 향상
- 기술 스택 제약(Java Servlet/JSP) 내에서 최적화
- 동시 100명 사용자 처리 가능한 성능
- OWASP 표준 준수 가능한 보안 구조
- 향후 확장 가능한 아키텍처

### 1.2 설계 원칙

```
1. MVC 패턴 준수
   - Model: 데이터베이스 + DAO 클래스
   - View: JSP 페이지
   - Controller: Servlet 클래스

2. 단일 책임 원칙 (Single Responsibility)
   - 각 Servlet은 하나의 기능만 담당
   - DAO는 데이터 접근만 담당
   - Utility는 공통 기능만 담당

3. 의존성 역전 원칙 (Dependency Inversion)
   - DAO 인터페이스 활용 (향후)
   - Service 계층 분리 (향후)

4. DRY (Don't Repeat Yourself)
   - 공통 기능은 유틸리티 클래스로 분리
   - 필터를 통한 횡단 관심사 처리

5. 보안 우선
   - 모든 입력은 검증
   - PreparedStatement 필수
   - 권한 검사 강화
```

---

## 2. 시스템 아키텍처 개요

### 2.1 고수준 아키텍처 (High-Level Architecture)

```
┌──────────────────────────────────────────────────────────────┐
│                        사용자 (User Layer)                     │
│  학부생, 조교, 교수, 관리자, 게스트, 외부인 (6개 역할)        │
└──────────────────────┬───────────────────────────────────────┘
                       │ HTTP/HTTPS
┌──────────────────────▼───────────────────────────────────────┐
│                  웹 브라우저 (Web Browser)                     │
│  Chrome, Firefox, Safari (최신 2개 버전, 반응형 지원)         │
└──────────────────────┬───────────────────────────────────────┘
                       │ HTTP/HTTPS (TLS 1.2+)
┌──────────────────────▼───────────────────────────────────────┐
│        Apache Tomcat 9.x (Web Container / Application Server) │
├──────────────────────────────────────────────────────────────┤
│                     Presentation Layer                        │
│  ├─ JSP Pages (View)                                         │
│  └─ Static Resources (CSS, JS, Images)                       │
│                                                               │
│                     Business Logic Layer                      │
│  ├─ Servlets (Controllers)                                   │
│  ├─ Filters (Cross-Cutting Concerns)                         │
│  └─ Utilities (Helper Classes)                               │
│                                                               │
│                     Data Access Layer                         │
│  ├─ DAO (Data Access Objects)                                │
│  └─ DBUtil (Connection Management)                           │
└──────────────────────┬───────────────────────────────────────┘
                       │ SQL (TCP/IP port 3306)
┌──────────────────────▼───────────────────────────────────────┐
│              MySQL 8.x Database Server                        │
├──────────────────────────────────────────────────────────────┤
│  ├─ users (사용자 및 인증)                                    │
│  ├─ assets (자산 데이터: 8,401개)                            │
│  ├─ reservations (자산 예약)                                 │
│  ├─ transfers (자산 이관)                                    │
│  ├─ professors (교수 정보)                                   │
│  ├─ courses (교과목)                                        │
│  ├─ floors (층별 정보)                                       │
│  ├─ routes (저장된 경로)                                     │
│  └─ audit_log (감사 로그)                                   │
└──────────────────────────────────────────────────────────────┘

File System (Static Assets):
├─ /css/* (Bootstrap, Custom CSS)
├─ /js/* (Vanilla JavaScript)
├─ /images/* (Asset images)
└─ /floormaps/* (Floor maps, 3D assets)
```

### 2.2 아키텍처 패턴

**선택된 패턴:** Layered (N-Tier) Architecture

```
이점:
✓ 단순하고 이해하기 쉬움
✓ 역할 분리가 명확함
✓ 테스트가 용이함
✓ Servlet/JSP 환경에 적합

단점:
✗ 계층 간 경계 모호할 수 있음
✗ 대규모 확장 시 성능 저하 가능
✗ 단일 데이터베이스에 의존

향후 고려:
- Microservices로의 마이그레이션 (Phase 6+)
- API Gateway 추가 (REST API 확장 시)
```

---

## 3. 컴포넌트 아키텍처

### 3.1 컴포넌트 다이어그램

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────┐  ┌──────────────┐  ┌──────────────┐     │
│  │   JSP Pages  │  │ CSS / JS     │  │   Images     │     │
│  │  (30+ files) │  │  (Static)    │  │ (Floormaps)  │     │
│  └──────────────┘  └──────────────┘  └──────────────┘     │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                  Business Logic Layer                        │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    Authentication & Authorization     │                  │
│  │  ├─ LoginServlet                     │                  │
│  │  ├─ LogoutServlet                    │                  │
│  │  └─ AuthenticationFilter             │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    Asset Management Controllers       │                  │
│  │  ├─ SearchServlet                    │                  │
│  │  ├─ DetailServlet                    │                  │
│  │  ├─ ReserveServlet                   │                  │
│  │  ├─ RegisterServlet (Transfer)       │                  │
│  │  └─ AssetServlet (Disposal)          │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    Other Controllers                  │                  │
│  │  ├─ GuestServlet                     │                  │
│  │  ├─ VisitorServlet                   │                  │
│  │  └─ (ProfessorServlet - 향후)        │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    Utility & Helper Classes           │                  │
│  │  ├─ ValidationUtil                   │                  │
│  │  ├─ SecurityUtil                     │                  │
│  │  ├─ DateUtil                         │                  │
│  │  ├─ LoggingUtil                      │                  │
│  │  └─ PaginationUtil                   │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                   Data Access Layer                          │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    DAO (Data Access Objects)          │                  │
│  │  ├─ UserDAO                          │                  │
│  │  ├─ AssetDAO                         │                  │
│  │  ├─ ReservationDAO                   │                  │
│  │  ├─ TransferDAO                      │                  │
│  │  ├─ ProfessorDAO                     │                  │
│  │  ├─ CourseDAO                        │                  │
│  │  ├─ FloorDAO                         │                  │
│  │  ├─ RouteDAO                         │                  │
│  │  └─ AuditLogDAO                      │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
│  ┌──────────────────────────────────────┐                  │
│  │    Database Utilities                 │                  │
│  │  ├─ DBUtil (Connection Pool)         │                  │
│  │  ├─ QueryBuilder (향후)              │                  │
│  │  └─ TransactionManager (향후)        │                  │
│  └──────────────────────────────────────┘                  │
│                                                              │
└─────────────────────────────────────────────────────────────┘
                          ↓
┌─────────────────────────────────────────────────────────────┐
│                   Database Layer                             │
├─────────────────────────────────────────────────────────────┤
│              MySQL 8.x Database Server                       │
└─────────────────────────────────────────────────────────────┘
```

### 3.2 컴포넌트 설명

#### **Presentation Layer (표현 계층)**

**JSP Pages (30+ 파일):**
- `campuslogin.jsp` — 로그인 페이지
- `main_student.jsp`, `main_assistant.jsp`, `main_professor.jsp`, `main_admin.jsp`, `main_guest.jsp`, `main_visitor.jsp` — 역할별 메인
- `searchAssets.jsp` — 자산 검색 페이지
- `detail.jsp` — 자산 상세정보
- `reserve.jsp` — 자산 예약
- `transfer.jsp` — 자산 이관
- `floorNav.jsp` — 층별 네비게이션
- `navigationTest1.jsp` — 3D 맵 테스트
- 기타 (통계, 관리 페이지 등)

**Static Resources:**
- `/css/` — Bootstrap 5.3.3, Custom CSS
- `/js/` — Vanilla JavaScript (검증, 3D 맵 로직)
- `/images/` — 자산 이미지
- `/floormaps/` — 층별 맵 이미지, 3D 모델

#### **Business Logic Layer (비즈니스 로직 계층)**

**Servlets (10개):**
- `LoginServlet` — 사용자 인증, 세션 생성
- `LogoutServlet` — 세션 종료
- `SearchServlet` — 자산 검색 로직, 필터링, 페이지네이션
- `DetailServlet` — 자산 상세정보 조회, 관련 데이터 수집
- `ReserveServlet` — 예약 처리, 중복 검사, 트랜잭션 관리
- `RegisterServlet` — 자산 이관 요청 처리
- `AssetServlet` — 자산 기본 처리, 폐기 관리
- `GuestServlet` — 게스트 제한 접근 처리
- `VisitorServlet` — 외부인 접근 처리
- (향후) `ProfessorServlet` — 교수 관리

**Filters (횡단 관심사):**
- `AuthenticationFilter` — 로그인 여부 확인
- `AuthorizationFilter` — 역할별 권한 검사
- `LoggingFilter` — 요청/응답 로깅
- `SecurityFilter` — 보안 헤더 추가 (HTTPS, CSP, X-Frame-Options)
- (향후) `CacheFilter` — 응답 캐싱
- (향후) `CompressionFilter` — Gzip 압축

**Utility Classes:**
- `DBUtil` — 데이터베이스 연결 풀 관리
- `ValidationUtil` — 입력 검증 (XSS, SQL Injection 방지)
- `SecurityUtil` — 암호화, 토큰 생성
- `PaginationUtil` — 페이지네이션 로직
- `DateUtil` — 날짜/시간 처리

#### **Data Access Layer (데이터 접근 계층)**

**DAO Classes (Data Access Objects):**
- `UserDAO` — users 테이블 CRUD
- `AssetDAO` — assets 테이블 CRUD, 검색, 필터링
- `ReservationDAO` — reservations 테이블 CRUD, 중복 검사
- `TransferDAO` — transfers 테이블 CRUD, 승인 상태 관리
- `ProfessorDAO` — professors 테이블 CRUD
- `CourseDAO` — courses 테이블 CRUD
- `FloorDAO` — floors 테이블 CRUD
- `RouteDAO` — routes 테이블 CRUD
- `AuditLogDAO` — audit_log 테이블 INSERT (감사 로그)

**Database Utilities:**
- `DBUtil` — Connection Pool 관리, 연결 획득/반환
- (향후) `TransactionManager` — 트랜잭션 관리
- (향후) `CacheManager` — Redis 캐싱 (선택)

---

## 4. 계층별 설계 (Layered Architecture)

### 4.1 요청 처리 흐름 (Request-Response Cycle)

```
1. 사용자 요청
   ┌──────────────────────────────┐
   │ 사용자 브라우저에서 HTTP 요청  │
   │ GET /search?keyword=computer  │
   └────────────┬─────────────────┘
                │
                ▼
2. Tomcat 수신
   ┌──────────────────────────────┐
   │ Tomcat이 HTTP 요청 수신        │
   │ DispatcherServlet 처리        │
   └────────────┬─────────────────┘
                │
                ▼
3. Filter Chain 실행
   ┌──────────────────────────────┐
   │ AuthenticationFilter          │
   │ → 로그인 여부 확인             │
   │ → 없으면 로그인 페이지로 리다  │
   └────────────┬─────────────────┘
                │
                ▼
   ┌──────────────────────────────┐
   │ AuthorizationFilter           │
   │ → 역할별 권한 확인             │
   │ → 권한 없으면 403 Forbidden   │
   └────────────┬─────────────────┘
                │
                ▼
   ┌──────────────────────────────┐
   │ SecurityFilter                │
   │ → HTTPS, CSRF, XSS 검증      │
   └────────────┬─────────────────┘
                │
                ▼
   ┌──────────────────────────────┐
   │ LoggingFilter                 │
   │ → 요청 정보 로깅               │
   └────────────┬─────────────────┘
                │
                ▼
4. Servlet 처리 (Controller)
   ┌──────────────────────────────┐
   │ SearchServlet.doGet()         │
   │ ├─ 파라미터 추출               │
   │ ├─ ValidationUtil로 검증      │
   │ └─ 입력 값 정제 (HTML 이스케이프)│
   └────────────┬─────────────────┘
                │
                ▼
5. Business Logic
   ┌──────────────────────────────┐
   │ AssetDAO.searchAssets()       │
   │ ├─ PreparedStatement 생성      │
   │ ├─ 데이터베이스 쿼리 실행      │
   │ └─ ResultSet → Asset 객체 변환 │
   └────────────┬─────────────────┘
                │
                ▼
6. Data Processing
   ┌──────────────────────────────┐
   │ PaginationUtil.paginate()     │
   │ ├─ 검색 결과를 페이지 분할     │
   │ └─ 페이지 정보 포함            │
   └────────────┬─────────────────┘
                │
                ▼
7. Response 생성
   ┌──────────────────────────────┐
   │ request.setAttribute() 호출   │
   │ ├─ searchResults            │
   │ ├─ pagination               │
   │ └─ other metadata            │
   │                              │
   │ RequestDispatcher.forward()   │
   │ → searchAssets.jsp로 전달     │
   └────────────┬─────────────────┘
                │
                ▼
8. View Rendering
   ┌──────────────────────────────┐
   │ searchAssets.jsp             │
   │ ├─ JSP 태그 실행              │
   │ ├─ HTML 생성                  │
   │ └─ 응답 버퍼에 작성            │
   └────────────┬─────────────────┘
                │
                ▼
9. 응답 송신
   ┌──────────────────────────────┐
   │ HTTP 응답 (200 OK)            │
   │ Content-Type: text/html       │
   │ Set-Cookie: JSESSIONID=...    │
   │                              │
   │ [HTML 바디]                   │
   │ 검색 결과 페이지              │
   └────────────┬─────────────────┘
                │
                ▼
10. 브라우저 렌더링
    ┌──────────────────────────────┐
    │ HTML 파싱                     │
    │ CSS 적용                      │
    │ JavaScript 실행 (상호작용)    │
    │ 사용자에게 페이지 표시        │
    └──────────────────────────────┘
```

### 4.2 데이터 모델 (Entity-Relationship)

**사용자 관련:**
```java
// User 엔티티
public class User {
    private int userId;           // PK
    private String username;      // Unique
    private String passwordHash;  // bcrypt
    private String name;
    private String role;          // 6개 역할 중 하나
    private String email;
    private String phone;
    private String department;
    private LocalDateTime createdAt;
    private LocalDateTime lastLogin;
    private boolean active;
}
```

**자산 관련:**
```java
// Asset 엔티티
public class Asset {
    private int assetId;          // PK
    private String assetName;
    private String category;      // 자산 분류
    private String description;
    private String status;        // 사용가능, 예약됨, 정지됨, 폐기됨
    private int ownerId;          // FK: User
    private String location;      // 건물-층-실
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
}

// Reservation 엔티티
public class Reservation {
    private int reservationId;    // PK
    private int userId;           // FK: User
    private int assetId;          // FK: Asset
    private LocalDateTime reservedFrom;
    private LocalDateTime reservedTo;
    private String status;        // 예약중, 취소됨
    private LocalDateTime createdAt;
}

// Transfer 엔티티
public class Transfer {
    private int transferId;       // PK
    private int assetId;          // FK: Asset
    private String fromLocation;
    private String toLocation;
    private String reason;
    private String status;        // 승인대기, 승인, 반려
    private int approvedBy;       // FK: User (승인자)
    private LocalDateTime approvedAt;
    private LocalDateTime createdAt;
}
```

---

## 5. 데이터 흐름 및 상호작용

### 5.1 자산 검색 데이터 흐름 예시

```
User Input
  "현미경" 키워드, "실험 장비" 카테고리 선택
           │
           ▼
[1] SearchServlet.doGet()
    ├─ getParameter("keyword") → "현미경"
    ├─ getParameter("category") → "실험 장비"
    └─ getParameter("page") → 1
           │
           ▼
[2] ValidationUtil.validateInput()
    ├─ 길이 검증: keyword 길이 <= 100
    ├─ XSS 방지: HTML 이스케이프
    └─ SQL Injection 방지: 특수문자 필터링
           │
           ▼
[3] AssetDAO.searchAssets()
    │
    ├─ SQL 생성:
    │  SELECT asset_id, asset_name, category, status, location, owner_id
    │  FROM assets
    │  WHERE asset_name LIKE ? AND category = ?
    │  AND status != 'deleted'
    │  ORDER BY asset_id DESC
    │  LIMIT 20 OFFSET 0;
    │
    ├─ PreparedStatement에 파라미터 바인딩
    │  ps.setString(1, "%현미경%")
    │  ps.setString(2, "실험 장비")
    │
    ├─ executeQuery() 실행
    │
    ├─ ResultSet → Asset 객체 컬렉션 변환
    │  └─ List<Asset> results
    │
    ▼
[4] PaginationUtil.paginate()
    ├─ 전체 결과 수: 45개
    ├─ 페이지당 20개
    ├─ 전체 페이지: 3페이지
    └─ 현재 페이지: 1 → 데이터 0~19번 선택
           │
           ▼
[5] SearchServlet - Data Set
    ├─ request.setAttribute("results", assetList)
    ├─ request.setAttribute("pagination", paginationInfo)
    ├─ request.setAttribute("keyword", "현미경")
    └─ request.setAttribute("category", "실험 장비")
           │
           ▼
[6] Forward to searchAssets.jsp
           │
           ▼
[7] JSP Rendering
    ├─ <c:forEach var="asset" items="${results}">
    │   └─ 각 자산을 HTML 행으로 렌더링
    ├─ 페이지네이션 버튼 생성
    │   └─ "1 2 3 다음"
    └─ 검색 조건 표시
           │
           ▼
[8] HTTP Response (200 OK)
    ├─ Content-Type: text/html; charset=UTF-8
    ├─ Set-Cookie: JSESSIONID=...
    └─ [HTML 바디]
           │
           ▼
Browser Rendering
└─ 자산 검색 결과 페이지 표시
```

### 5.2 자산 예약 시퀀스 다이어그램

```
User          Browser        Tomcat        MySQL
  │              │              │             │
  │──────[1]────>│              │             │
  │  예약 클릭    │              │             │
  │              │──────[2]────>│             │
  │              │  GET reserve │             │
  │              │   ?assetId=5 │             │
  │              │              │             │
  │              │<─────[3]─────│             │
  │              │  reserve.jsp │             │
  │              │   (폼)        │             │
  │<─────────[4]─────────────────│             │
  │  예약 폼 표시                  │             │
  │              │              │             │
  │──────[5]────>│              │             │
  │  예약 신청    │              │             │
  │ (assetId,    │              │             │
  │  start, end) │              │             │
  │              │──────[6]────>│             │
  │              │  POST reserve│             │
  │              │              │             │
  │              │  [SearchServlet]
  │              │  ├─ 입력 검증
  │              │  ├─ 예약 중복 검사
  │              │  └─ 시간 겹침 검사
  │              │              │             │
  │              │──────[7]────────────────>│
  │              │ SELECT * FROM reservations
  │              │ WHERE asset_id = 5      │
  │              │ AND status != 'cancelled'│
  │              │                          │
  │              │<─────[8]────────────────│
  │              │ 기존 예약 없음           │
  │              │              │             │
  │              │──────[9]─────────────────>│
  │              │ INSERT INTO reservations
  │              │ (user_id, asset_id, ...)│
  │              │                          │
  │              │<─────[10]───────────────│
  │              │ 1 row inserted           │
  │              │              │             │
  │              │──────[11]───>│             │
  │              │ INSERT INTO audit_log
  │              │              │             │
  │<─────[12]─────────────────────│         │
  │  성공 메시지                    │         │
  │  "예약이 완료되었습니다"       │         │
  └──────────────────────────────────────────┘
```

---

## 6. 인프라 구성 (Deployment)

### 6.1 배포 환경 구성도

```
┌─────────────────────────────────────────────────────┐
│            사용자 클라이언트                         │
│  (Windows 11 + 브라우저)                           │
└────────────────────┬────────────────────────────────┘
                     │ HTTPS (TLS 1.2+)
                     │ port 443
┌────────────────────▼────────────────────────────────┐
│         방화벽 / 로드 밸런서 (선택사항)              │
│         - 향후: nginx, Apache 프록시                │
└────────────────────┬────────────────────────────────┘
                     │
┌────────────────────▼────────────────────────────────┐
│          Windows 11 Server (온프레미스)              │
│          ICT 폴리텍 캠퍼스 내 서버실                │
├────────────────────────────────────────────────────┤
│                                                    │
│  ┌──────────────────────────────────────┐        │
│  │      Apache Tomcat 9.x                │        │
│  │  (port 8080, HTTPS 443 프록시)       │        │
│  ├──────────────────────────────────────┤        │
│  │                                       │        │
│  │  ┌────────────────────────────────┐  │        │
│  │  │   Deployed Application          │  │        │
│  │  │   /CampusNav/                   │  │        │
│  │  │  ├─ WEB-INF/                    │  │        │
│  │  │  │  ├─ src/                     │  │        │
│  │  │  │  │  └─ com/campus/nav/       │  │        │
│  │  │  │  │     ├─ LoginServlet.class │  │        │
│  │  │  │  │     ├─ SearchServlet.class│  │        │
│  │  │  │  │     ├─ DBUtil.class       │  │        │
│  │  │  │  │     └─ ...                │  │        │
│  │  │  │  ├─ lib/                     │  │        │
│  │  │  │  │  ├─ mysql-connector.jar   │  │        │
│  │  │  │  │  └─ (기타 라이브러리)     │  │        │
│  │  │  │  └─ web.xml                  │  │        │
│  │  │  ├─ css/                        │  │        │
│  │  │  ├─ js/                         │  │        │
│  │  │  ├─ images/                     │  │        │
│  │  │  ├─ floormaps/                  │  │        │
│  │  │  └─ *.jsp (30+ 파일)           │  │        │
│  │  └────────────────────────────────┘  │        │
│  │                                       │        │
│  │  Java 11 JVM (Runtime)                │        │
│  │  Memory: -Xmx2G -Xms512M             │        │
│  │                                       │        │
│  └──────────────────────────────────────┘        │
│                                                    │
└────────────────┬───────────────────────────────────┘
                 │ JDBC (TCP port 3306)
┌────────────────▼───────────────────────────────────┐
│          MySQL 8.x Community Server                 │
│          (Windows 서비스로 실행)                   │
├────────────────────────────────────────────────────┤
│                                                    │
│  Default Data Directory:                           │
│  C:\ProgramData\MySQL\MySQL Server 8.0\Data\      │
│                                                    │
│  Database: campusnav                              │
│  ├─ users                (사용자)                 │
│  ├─ assets               (8,401개 자산)          │
│  ├─ reservations         (자산 예약)             │
│  ├─ transfers            (자산 이관)             │
│  ├─ professors           (교수 정보)             │
│  ├─ courses              (교과목)                │
│  ├─ floors               (층별 정보)             │
│  ├─ routes               (저장된 경로)           │
│  └─ audit_log            (감사 로그)            │
│                                                    │
│  My.ini (Configuration):                          │
│  [mysqld]                                          │
│  default-storage-engine=InnoDB                    │
│  max_connections=200                              │
│  innodb_buffer_pool_size=1G                       │
│  character_set_server=utf8mb4                     │
│                                                    │
└────────────────────────────────────────────────────┘

File System (Local):
├─ C:\Tomcat9\                (Tomcat 설치 디렉토리)
├─ C:\Tomcat9\webapps\CampusNav\ (애플리케이션)
├─ C:\logs\                   (로그 파일)
│  ├─ catalina.log           (Tomcat 로그)
│  ├─ app.log                (애플리케이션 로그)
│  └─ access.log             (접근 로그)
└─ C:\backups\               (백업 디렉토리)
   └─ db_backup_*.sql        (MySQL 백업)
```

### 6.2 네트워크 다이어그램

```
┌──────────────────────────────────────────────────┐
│           사용자 클라이언트 (교내)                │
│                                                 │
│  ┌──────┐  ┌──────┐  ┌──────┐  ┌──────┐       │
│  │학부생 │  │조교  │  │교수  │  │관리자│       │
│  │Chrome│  │Edge  │  │Safari│  │Firefox
│  └──┬───┘  └──┬───┘  └──┬───┘  └──┬───┘       │
│     │         │         │         │            │
└─────┼─────────┼─────────┼─────────┼────────────┘
      │         │         │         │
      └─────────┼─────────┼─────────┘
                │         │
        (교내 무선 LAN / 유선)
                │         │
      ┌─────────▼─────────▼─────────┐
      │   교내 방화벽 / NAT          │
      │   (게이트웨이)               │
      └─────────┬───────────────────┘
                │ 내부 네트워크
      ┌─────────▼───────────────────┐
      │  Tomcat 서버                │
      │  IP: 192.168.1.100          │
      │  Port: 443 (HTTPS)          │
      │  Port: 8080 (내부)          │
      └─────────┬───────────────────┘
                │
      ┌─────────▼───────────────────┐
      │  MySQL 서버                 │
      │  IP: 192.168.1.101 (로컬)   │
      │  Port: 3306                 │
      └─────────────────────────────┘

보안 고려사항:
1. HTTPS (TLS 1.2+) 필수
2. 방화벽: 
   - 443 (HTTPS) 개방
   - 3306 (MySQL) 내부 전용
   - 다른 포트는 폐쇄
3. 교내 VPN 또는 애드혹 인증 권장
```

### 6.3 배포 절차

```
Phase 5: 배포 준비
├─ 1. 코드 완성
│  └─ Git commit, tag (v1.0)
│
├─ 2. 빌드
│  ├─ mvn clean package (또는 IDE 빌드)
│  ├─ WAR 파일 생성: CampusNav.war
│  └─ 크기: 약 10-20MB (예상)
│
├─ 3. 데이터 마이그레이션
│  ├─ 기존 8,401개 자산 데이터 로드
│  │  └─ mysql에다넣고실행_fixed.sql 실행
│  ├─ 테스트 사용자 생성
│  └─ 감사 로그 테이블 초기화
│
├─ 4. 테스트 배포 (Staging)
│  ├─ 테스트 서버에 WAR 배포
│  ├─ 스모크 테스트 실행
│  │  ├─ 로그인 기능
│  │  ├─ 자산 검색
│  │  ├─ 자산 예약
│  │  └─ 내비게이션
│  └─ 성능 테스트
│     └─ 응답 시간 < 2초 확인
│
├─ 5. 운영 배포 (Production)
│  ├─ Tomcat 중지
│  │  └─ shutdown.sh
│  ├─ 기존 웹앱 백업
│  │  └─ CampusNav.war.bak
│  ├─ 새 WAR 파일 배포
│  │  └─ webapps/CampusNav/
│  ├─ Tomcat 시작
│  │  └─ startup.sh
│  └─ 헬스 체크
│     ├─ 로그 확인
│     └─ 초기 요청 테스트
│
└─ 6. 모니터링
   ├─ CPU, 메모리 사용률
   ├─ 응답 시간
   ├─ 에러 로그
   └─ 동시 사용자 수
```

---

## 7. 보안 아키텍처

### 7.1 보안 계층

```
┌────────────────────────────────────┐
│      사용자 브라우저                │
└────────────────┬───────────────────┘
                 │ HTTPS (TLS 1.2+)
                 │
┌────────────────▼───────────────────┐
│    방화벽 / 로드 밸런서             │
│  - IP 화이트리스트 (향후)          │
│  - DDoS 방어                        │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│  Web Application Firewall (향후)   │
│  - XSS, SQL Injection 탐지         │
│  - 비정상 패턴 차단                │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│    Tomcat / Servlet Layer           │
│  ┌──────────────────────────────┐  │
│  │  SecurityFilter              │  │
│  │  - HTTPS 강제                │  │
│  │  - HSTS 헤더                 │  │
│  │  - X-Frame-Options (Clickjack)
│  │  - X-Content-Type-Options    │  │
│  │  - CSP (Content Security Policy)
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  AuthenticationFilter         │  │
│  │  - 로그인 필수 확인           │  │
│  │  - 세션 타임아웃 (30분)       │  │
│  │  - 재로그인 강제              │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  AuthorizationFilter          │  │
│  │  - 역할 기반 접근 제어         │  │
│  │  - 권한 없는 접근 → 403      │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Servlet / Controller         │  │
│  │  - 입력 검증 (XSS, SQLi)      │  │
│  │  - CSRF 토큰 검증 (향후)      │  │
│  │  - 에러 처리 (정보 노출 방지)  │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Data Access Layer (DAO)      │  │
│  │  - PreparedStatement (SQLi 방지)
│  │  - 트랜잭션 격리              │  │
│  └──────────────────────────────┘  │
└────────────────┬───────────────────┘
                 │
┌────────────────▼───────────────────┐
│    MySQL Database Layer             │
│  ┌──────────────────────────────┐  │
│  │  User Authentication         │  │
│  │  - DB 계정: campusnav_user   │  │
│  │  - 강한 비밀번호              │  │
│  │  - 최소 권한 원칙             │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Encryption                  │  │
│  │  - InnoDB 암호화 (선택)      │  │
│  │  - 비밀번호: bcrypt           │  │
│  │  - 중요정보: AES (향후)       │  │
│  └──────────────────────────────┘  │
│                                    │
│  ┌──────────────────────────────┐  │
│  │  Access Control              │  │
│  │  - 테이블 권한 제한           │  │
│  │  - 로우 레벨 보안 (향후)      │  │
│  └──────────────────────────────┘  │
└────────────────────────────────────┘

File System 보안:
├─ web.xml: 노출 방지
├─ database.properties: 암호화
└─ logs/: 접근 제한 (관리자만)
```

### 7.2 인증 및 권한 체계

**인증 (Authentication):**
```
사용자명 + 비밀번호
    │
    ▼
[1] LoginServlet 수신
    ├─ 입력 검증
    └─ 전송 방식: HTTPS POST
    
    ▼
[2] 데이터베이스 조회
    └─ SELECT password_hash FROM users WHERE username = ?
    
    ▼
[3] 비밀번호 검증
    └─ BCrypt.checkpw(inputPassword, storedHash)
    
    ▼
[4] 세션 생성
    ├─ Session.setAttribute("userId", userId)
    ├─ Session.setAttribute("role", role)
    ├─ Session.setMaxInactiveInterval(1800) // 30분
    └─ JSESSIONID 쿠키 발급
         (HttpOnly, Secure, SameSite=Strict)
    
    ▼
[5] 메인 페이지로 리다이렉트
    └─ 역할에 따라 다른 페이지
```

**권한 (Authorization):**
```
각 요청마다:
    │
    ▼
[1] AuthorizationFilter 확인
    ├─ Session에서 역할 추출
    └─ request.getSession().getAttribute("role")
    
    ▼
[2] 요청 URL과 매핑
    ├─ "/reserve" → 학부생, 조교만 허용
    ├─ "/admin/*" → 관리자만 허용
    ├─ "/search" → 모든 역할 허용
    └─ 기타 등등
    
    ▼
[3] 권한 확인
    ├─ 권한 있음 → 요청 계속 진행
    └─ 권한 없음 → 403 Forbidden 응답
```

---

## 8. 성능 및 확장성 전략

### 8.1 성능 최적화 계획

**Phase 3 (구현 중):**
```
1. 데이터베이스 인덱싱
   CREATE INDEX idx_asset_category ON assets(category);
   CREATE INDEX idx_asset_status ON assets(status);
   CREATE INDEX idx_reservation_asset ON reservations(asset_id);
   CREATE INDEX idx_reservation_user ON reservations(user_id);

2. 쿼리 최적화
   - SELECT * 사용 금지 → 필요한 컬럼만
   - JOIN 최소화
   - 불필요한 WHERE 절 제거
   - LIMIT/OFFSET 활용 (페이지네이션)

3. 연결 풀링
   - DBUtil.getConnection() 사용
   - 최대 연결: 20개
   - 타임아웃: 30초
```

**Phase 5 (배포 전):**
```
4. 캐싱 전략
   - HTTP 헤더: Cache-Control, ETag
   - 정적 파일: 1년 캐시
   - 동적 콘텐츠: 1시간 캐시
   - JavaScript: gzip 압축

5. 이미지 최적화
   - 해상도 조정 (웹용)
   - WebP 형식 (지원하는 브라우저)
   - 썸네일 생성

6. JavaScript 최적화
   - 최소화 (minification)
   - 코드 분할 (필요한 부분만 로드)
   - 번들 크기 최소화
```

**Phase 6+ (선택사항):**
```
7. Redis 캐싱 (선택)
   - 자주 검색되는 데이터
   - 세션 저장소
   - 타임스탬프 데이터

8. CDN 사용 (선택)
   - 정적 파일 (CSS, JS, 이미지)
   - 지리적으로 분산된 캐시

9. 로드 밸런싱 (선택)
   - 여러 Tomcat 인스턴스
   - nginx 또는 HAProxy로 분산
   - 세션 공유 (Redis 사용)

10. 데이터베이스 최적화
    - Read Replica (선택)
    - Sharding (대규모 시 고려)
```

### 8.2 확장성 고려사항

**수직 확장 (Scale Up - 현재):**
```
기존 서버의 리소스 증가:
├─ CPU 업그레이드
├─ RAM 증가 (현재 2GB → 4GB 이상)
├─ SSD 스토리지 추가
└─ 네트워크 대역폭 증가
```

**수평 확장 (Scale Out - 향후):**
```
클라우드 전환 시 (Phase 6+):

AWS Elastic Beanstalk 예시:
├─ Auto Scaling Group
│  ├─ EC2 인스턴스 2-4개
│  ├─ Application Load Balancer
│  └─ CloudWatch 모니터링
├─ RDS (Relational Database Service)
│  ├─ Multi-AZ 배포
│  └─ 자동 백업
└─ S3 (정적 파일 저장소)
   └─ CloudFront CDN
```

---

## 9. 배포 전략

### 9.1 배포 환경별 구성

**개발 환경 (Development):**
```
구성:
- 개발자 로컬 머신
- Tomcat (localhost:8080)
- MySQL (localhost:3306)
- 디버그 모드 활성화

용도:
- 기능 개발 및 테스트
- 즉시 반영 및 재시작
```

**테스트 환경 (Staging):**
```
구성:
- 테스트 서버 (별도)
- Tomcat (테스트 포트)
- MySQL (테스트 DB)
- 프로덕션과 동일한 설정

용도:
- 통합 테스트
- 성능 테스트
- UAT (사용자 수용 테스트)
- 배포 전 검증
```

**운영 환경 (Production):**
```
구성:
- 운영 서버 (Windows 11 Server)
- Tomcat (포트 443 HTTPS)
- MySQL (안전한 위치)
- 모니터링 및 로깅 활성화

용도:
- 실제 사용자 서비스
- 24/7 가용성 요구
- 백업 및 복구 절차 필수
```

### 9.2 배포 전략 (Blue-Green Deployment)

```
현재 (Phase 5):
├─ 단일 서버 배포
├─ 다운타임 0.5-1시간 (재시작)
└─ 롤백 계획: 이전 WAR 복원

향후 (Phase 6+):
├─ Blue-Green 배포
│  ├─ Blue: 현재 운영 (v1.0)
│  └─ Green: 신규 배포 (v1.1)
│
├─ 배포 절차:
│  ├─ Green 환경에 새 버전 배포
│  ├─ Green 환경 테스트
│  ├─ 트래픽 전환 (Blue → Green)
│  └─ 문제 시 즉시 롤백 (Green → Blue)
│
└─ 장점:
   ├─ 다운타임 0 (무중단 배포)
   ├─ 빠른 롤백
   └─ 안정적인 배포
```

---

## 10. 기술 결정 기록 (ADR)

### 10.1 아키텍처 의사결정

#### **ADR-001: Servlet/JSP 기반 아키텍처 선택**

**상황:**
- 기술 스택 고정 (Java 11 + Servlet + Tomcat)
- 현대적 프레임워크(Spring Boot, Quarkus) 미지원

**의사결정:**
- 전통적인 Servlet/JSP 기반 아키텍처 적용
- MVC 패턴으로 구조화

**근거:**
- ✓ 기술 스택 제약 준수
- ✓ Tomcat 9.x와 완전 호환
- ✓ 개발 속도 (간단한 구조)
- ✓ 작은 팀에 적합 (2명 개발자)
- ✗ 현대적 기능 부족 (향후 마이그레이션 검토)

**대안:**
- A1: Spring Framework (Servlet 위에서 동작) → 과도한 복잡도
- A2: JSF (JavaServer Faces) → 학습곡선 높음
- A3: Struts 2 → 레거시, 보안 이슈

**결과:**
- ✓ 채택됨

---

#### **ADR-002: Layered Architecture 선택**

**상황:**
- 명확한 아키텍처 패턴 필요
- 유지보수성과 테스트 용이성 고려

**의사결정:**
- 3계층 Layered Architecture 적용
  - Presentation (JSP)
  - Business Logic (Servlet + Utility)
  - Data Access (DAO + DBUtil)

**근거:**
- ✓ 단순하고 이해하기 쉬움
- ✓ 역할 분리 명확
- ✓ Servlet/JSP 환경에 자연스러움
- ✓ 초기 개발 속도 우선

**대안:**
- A1: Microservices → 규모 과다, 복잡도 높음
- A2: Hexagonal (DDD) → 중소 프로젝트에 과도
- A3: Event-Driven → 자산 관리에 불필요

**결과:**
- ✓ 채택됨
- 향후 Microservices 마이그레이션 검토 (Phase 6+)

---

#### **ADR-003: MySQL 선택 (PostgreSQL 비교)**

**상황:**
- 오픈소스 관계형 데이터베이스 필요
- 8,401개 자산 데이터 처리

**의사결정:**
- MySQL 8.x (Community Edition) 선택

**근거:**
- ✓ 간단하고 가볍다
- ✓ 성능 충분 (8,401개 자산, 100명 동시 사용자)
- ✓ 교내 기술지원 가능성 (일반적)
- ✓ 무료 라이선스

**대안:**
- A1: PostgreSQL → 더 강력하나 필요 이상
- A2: Oracle → 라이선스 비용
- A3: MongoDB → 관계형 데이터에 부적합

**결과:**
- ✓ 채택됨
- 향후 PostgreSQL 마이그레이션 검토 (보안성 우수)

---

#### **ADR-004: 외부 API 최소화**

**상황:**
- 외부 서비스 의존성 고려
- 예산 제약 ($0)

**의사결정:**
- 외부 API 미사용 (Google Maps, Email Service 등 제외)
- 온프레미스 구현

**근거:**
- ✓ 예산 절감 ($0 유지)
- ✓ 데이터 보안 (온프레미스)
- ✓ 의존성 최소화
- ✓ 운영 단순화

**대안:**
- A1: Google Maps API → 추가 비용 (~$200/월)
- A2: SendGrid (이메일) → 추가 비용 (~$20/월)
- A3: Firebase (실시간) → 추가 비용 + 복잡도

**결과:**
- ✓ 채택됨
- 향후 필요시 단계적 추가 고려

---

### 10.2 기술 결정 요약표

| ADR ID | 결정 항목 | 선택지 | 채택 | 근거 |
|--------|---------|--------|------|------|
| ADR-001 | Web Framework | Spring Boot vs Servlet/JSP | Servlet/JSP | 기술 스택 고정 |
| ADR-002 | 아키텍처 패턴 | Layered vs Microservices | Layered | 단순성, 적절성 |
| ADR-003 | 데이터베이스 | MySQL vs PostgreSQL | MySQL | 가벼움, 성능 충분 |
| ADR-004 | 외부 API | 사용 vs 미사용 | 미사용 | 비용, 보안 |
| ADR-005 | 인증 방식 | OAuth vs Username/Password | Username/Password | 단순성 |
| ADR-006 | 캐싱 전략 | Redis vs 애플리케이션 캐시 | 단계적 (Phase 6+) | 필요시 추가 |
| ADR-007 | 배포 전략 | Blue-Green vs Rolling | 단계적 적용 | 향후 고려 |

---

## 11. 향후 아키텍처 진화 (Roadmap)

### Phase 1-5 (현재 ~ 2026년 7월)
```
✓ Servlet/JSP + MySQL 기반 MVP 완성
✓ 기본 보안 (HTTPS, 권한 제어)
✓ 성능 기준 충족 (< 2초)
```

### Phase 6 (2026년 8월-9월)
```
○ REST API 설계 및 구현
○ 성능 최적화 (Redis 캐싱)
○ 향상된 보안 (PIPA 완전 준수)
```

### Phase 7 (2026년 10월-12월)
```
◐ 모바일 앱 (선택) - Vue.js/React
◐ AI 기반 추천 시스템
◐ 실시간 알림 (WebSocket)
```

### Phase 8+ (2027년+)
```
◐ 클라우드 마이그레이션 (AWS/Azure)
◐ Microservices 아키텍처
◐ GraphQL API
◐ Machine Learning 기반 분석
```

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| v1.0 | 2026-05-27 | 초판 작성 - 시스템 아키텍처 설계 | Development Team |

---

## 참고 자료

- `기획서_aisw.md` — 프로젝트 기획서
- `현황분석서_aisw.md` — 내부 환경 분석
- `환경분석서_aisw.md` — 외부 환경 분석
- `요구사항명세서_aisw.md` — 요구사항 명세

---

**작성 완료 - 2026-05-27**

이 아키텍처 설계서는 CAN 프로젝트의 기술적 기반을 제공하며, Phase 1 상세 설계 단계에서 각 컴포넌트의 상세 스펙으로 확장됩니다.

