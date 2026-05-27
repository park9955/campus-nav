# CAN (CampusNav) 프로젝트 지침서

**ICT CampusNav 프로젝트 개발 지침**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project:** ICT CampusNav (CAN)

**Reference:** 개발방법론_aisw.md, Samsung SDS Innovator, BDD (Behavior-Driven Development)

---

## 1. 프로젝트 개요

### 1.1 프로젝트 목표
**ICT CAN** (CampusNav)은 ICT 폴리텍대학 교내 자원(Assets) 관리 및 내비게이션을 통합한 웹 기반 정보시스템이다. 학부생, 조교, 교수, 관리자, 게스트 및 외부인을 포함한 6개 역할의 사용자에게 자산 검색·예약·이관 추적·교수 정보 관리·층별 내비게이션을 제공한다.

### 1.2 핵심 기능
| 기능 | 설명 | 담당 역할 |
|------|------|---------|
| 자산 검색 및 조회 | 8,401개 자산의 키워드/카테고리/상태 기반 검색 | 학부생, 조교, 게스트 |
| 자산 예약 | 자산 중복 예약 방지 및 예약 이력 관리 | 학부생 |
| 자산 이관 추적 | 자산 이관 요청·승인·상세 정보 조회 | 조교, 학부생 |
| 자산 폐기 관리 | 자산 폐기 기록 관리 | 관리자 |
| 교수 정보 관리 | 교과목, 스킬 태그 기반 교수 카드 관리 | 교수 |
| 층별 내비게이션 | 3D 맵 기반 층별 위치 조회 및 경로 저장 | 모든 사용자 |

### 1.3 기술 스택
- **Backend:** Java Servlets, JSP, Apache Tomcat 9.x
- **Frontend:** Bootstrap 5.3.3, Bootstrap Icons, JavaScript
- **Database:** MySQL 8.x (`campusnav` DB)
- **Architecture:** Servlet + JSP (하이브리드: 인증은 Servlet, 데이터 페이지는 JSP 직접 JDBC)

### 1.4 액세스 정보
- **URL:** `http://localhost:8080/CampusNav/campuslogin.jsp`
- **DB Connection:** `root:1234@localhost:3306/campusnav`

---

## 2. 개발 생애주기 및 산출물

### 2.1 기획 단계 (Planning Stage)

| 산출물 | 내용 | 현황 |
|--------|------|------|
| **프로젝트 기획서** | 프로젝트 승인 정보, BRD(비즈니스 요구사항), 범위 정의 | ✓ 완료 (CAN 프로젝트 시작) |
| **사용자 역할 정의** | 6개 역할(학부생, 조교, 교수, 관리자, 게스트, 외부인)의 권한 및 기능 매핑 | ✓ 완료 |

### 2.2 분석 단계 (Analysis Stage)

| 산출물 | 내용 | 현황 |
|--------|------|------|
| **현황 분석서** | 기존 자산 관리 프로세스, 8,401개 자산 데이터 구조, 사용자 요청사항 | ✓ 완료 |
| **환경 분석서** | 웹 기반 자산 관리 시스템의 일반적 기능, Tomcat + MySQL 기술 환경 검토 | ✓ 완료 |
| **요구사항 명세서** | 기능 요구사항(자산 검색, 예약, 이관, 내비게이션), 비기능 요구사항(성능, 보안) | ✓ 작성 필요 (추적성 강화) |

### 2.3 설계 단계 (Design Stage)

| 산출물 | 내용 | 현황 |
|--------|------|------|
| **시스템 아키텍처 설계서** | Servlet(인증 계층) + JSP(데이터 계층) 구조, MySQL 연결 풀(DBUtil.java) | ✓ 완료 |
| **기능 분해도** | 6개 역할별 기능 계층화, 자산/예약/이관 관리 모듈 분리 | ✓ 완료 |
| **데이터 설계서** | 8개 테이블 스키마(users, assets, asset_transfer, reservations 등), 논리/물리 DB 설계 | ✓ 완료 |
| **UI/UX 설계서** | 역할별 메인 페이지(main_student.jsp, main_admin.jsp 등), 검색·예약·내비게이션 인터페이스 | ✓ 진행 중 |
| **프로세스 설계서** | 자산 검색 필터링, 예약 중복 검사(AJAX), 이관 승인 워크플로우 | ✓ 완료 |
| **인터페이스 정의서** | JSP ↔ MySQL 직접 호출(JDBC), AJAX 예약 검사, 3D 맵 경로 API | ✓ 진행 중 |
| **아키텍처 결정 기록(ADR)** | Servlet vs JSP 책임 분리, DBUtil.java 필수 사용, 세션 기반 인증 | ✓ 필수 작성 |

**설계 문서 위치:** `docs/` 폴더 (추가 예정)

### 2.4 구현 및 이행 단계 (Implementation Stage)

| 산출물 | 내용 | 현황 |
|--------|------|------|
| **구현 계획서** | 개발 로드맵, 모듈별 구현 순서(인증 → 자산 검색 → 예약 → 내비게이션) | ✓ 진행 중 |
| **형상/배포 관리 정의서** | Git 버전 관리 전략, compile.bat을 통한 Java 컴파일, Tomcat 배포 절차 | ✓ 완료 |
| **테스트 정의서** | BDD 기반 로그인 테스트, 자산 검색 필터링 테스트, 예약 중복 검사 테스트 | ☐ 작성 필요 |
| **운영/배포 정의서** | Tomcat 실행, MySQL 초기 설정(`mysql에다넣고실행_fixed.sql`), 배포 체크리스트 | ✓ 완료 |

---

## 3. 핵심 개발 지침

### 3.1 아키텍처 원칙

**1) Servlet vs JSP 책임 분리**
- **Servlet 계층 (인증):** `LoginServlet`, `LogoutServlet`, `GuestServlet`, `VisitorServlet` → `web.xml` 등록 필수
  - 로그인 검증, 세션 설정, 역할별 리다이렉트만 담당
  - 세션 속성: `loginUser`, `loginName`, `loginRole`
- **JSP 계층 (데이터):** `search.jsp`, `detail.jsp`, `reserve.jsp`, `transfer.jsp` 등
  - **직접 JDBC 호출** (서블릿 계층 없음)
  - `DBUtil.java`의 `getConnection()` / `close()` 필수 사용
  - `session.getAttribute("loginRole")` 확인 후 권한별 UI 렌더링

**2) 데이터베이스 연결**
```java
// 필수 사용 패턴 (DBUtil.java)
Connection conn = DBUtil.getConnection();
try {
    PreparedStatement pstmt = conn.prepareStatement(sql);
    // 쿼리 실행
} finally {
    DBUtil.close(conn);
}
```

**3) 요청 흐름**
```
브라우저 → Tomcat 9
  ├── POST /login    → LoginServlet   → 세션 설정 → 역할별 리다이렉트
  ├── GET /logout    → LogoutServlet  → 세션 무효화 → campuslogin.jsp
  ├── GET /guest     → GuestServlet   → main_guest.jsp
  ├── GET /visitor   → VisitorServlet → main_visitor.jsp
  └── *.jsp (GET/POST) → 직접 JDBC 호출 (서블릿 계층 없음)
```

### 3.2 개발 워크플로우

#### JSP 수정
- 즉시 반영 (재컴파일 불필요)
- 브라우저 새로고침으로 확인

#### Java 파일 수정 (`.java` 파일)
1. Tomcat 중지
2. 프로젝트 루트에서 `compile.bat` 실행
   ```bat
   compile.bat
   ```
3. Tomcat 재시작
4. 브라우저 새로고침

**수동 컴파일** (필요시):
```bat
javac -encoding UTF-8 -cp "lib\servlet-api.jar" ^
  -d "webapps\CampusNav\WEB-INF\classes" ^
  "webapps\CampusNav\WEB-INF\src\com\campus\nav\LoginServlet.java"
```

### 3.3 데이터베이스 설정

#### 초기 설정
1. MySQL Workbench에서 `mysql에다넣고실행_fixed.sql` 실행
   - 자동으로 `campusnav` DB + 8개 테이블 생성
2. 검증: `SELECT COUNT(*) FROM assets;` → `8401` 반환 확인

#### 테이블 목록
- `users` - 사용자 계정 (역할 포함)
- `assets` - 자산 기본 정보 (8,401개)
- `asset_transfer` - 자산 이관 이력
- `asset_disposal` - 자산 폐기 기록
- `reservations` - 예약 정보
- `professors` - 교수 정보
- `prof_subjects` - 교수 교과목
- `prof_skills` - 교수 스킬

#### 중요 사항
- `mysql-connector-j-*.jar` → Tomcat `lib/` 폴더에만 배치 (프로젝트 내 X)
- 모든 서블릿/JSP에서 `DBUtil.java` 사용 필수

### 3.4 사용자 역할 체계

| 역할 | 세션값 | 진입 페이지 | 기능 |
|------|--------|-----------|------|
| 학부생 | `student` | `main_student.jsp` | 자산 검색, 예약, 이관 신청 |
| 조교 | `assistant` | `main_assistant.jsp` | 이관 승인, 자산 관리 |
| 교수 | `professor` | `main_professor.jsp` | 교과목/스킬 관리 |
| 관리자 | `admin` | `main_admin.jsp` | 전체 자산 관리, 사용자 관리 |
| 게스트 | `guest` | `main_guest.jsp` | 자산 검색만 (읽기) |
| 외부인 | `visitor` | `main_visitor.jsp` | 내비게이션 조회만 |

---

## 4. AI 에이전트를 위한 지침

### 4.1 추적성 준수 (Traceability)
- 모든 기능 구현은 **요구사항 명세서**의 고유 ID와 연결
- `docs/` 폴더 내 설계 문서의 최신 상태 확인 후 코드 작성
- 데이터 페이지(JSP)에서는 반드시 `DBUtil.getConnection()` 사용

### 4.2 아키텍처 결정 기록 확인 (ADR)
- Servlet vs JSP 책임 분리의 의도 확인
- 새로운 기능 추가 시 기존 아키텍처 패턴 준수
- 기술 선택 변경 시 `docs/ADR_*.md` 작성 필수

### 4.3 오류 분석 시 (When Analyzing Errors)
1. **데이터 무결성 확인:** `data_design.md` 스키마와 실제 쿼리 대조
2. **통신 지점 확인:** `interface_spec.md`에서 JSP ↔ DB 인터페이스 검증
3. **권한 검사 확인:** `session.getAttribute("loginRole")` 누락 여부 확인

### 4.4 문서 기반 소통 (Document-Driven Communication)
- JSP 수정 전: 해당 기능의 **프로세스 설계서** 검토
- 데이터 구조 변경 전: **데이터 설계서** 업데이트
- 새로운 역할 추가 시: **기능 분해도** 업데이트

---

## 5. 주요 파일 맵 및 책임

| 파일 | 용도 | 책임 계층 |
|------|------|----------|
| `campuslogin.jsp` | 로그인 폼 + 역할 선택 | 인증 |
| `LoginServlet.java` | 로그인 검증 + 세션 설정 | Servlet (인증) |
| `LogoutServlet.java` | 세션 무효화 | Servlet (인증) |
| `register.jsp` | 사용자 자가 등록 | JSP (데이터) |
| `search.jsp` | 자산 검색(키워드/카테고리/상태 필터) | JSP (데이터) |
| `detail.jsp` | 자산 상세정보 + 이관 이력 | JSP (데이터) |
| `reserve.jsp` | 예약 + AJAX 중복 검사 | JSP (데이터) |
| `transfer.jsp` | 이관 이력 조회 + 상세 패널 | JSP (데이터) |
| `professor.jsp` | 교수 카드 + 교과목/스킬 관리 | JSP (데이터) |
| `asset_manage.jsp` | 관리자 자산 관리 | JSP (데이터) |
| `floorNav.jsp` | 층별 내비게이션 + 3D 맵 | JSP (데이터) |
| `DBUtil.java` | DB 연결/해제 (필수 사용) | 데이터 접근 |
| `WEB-INF/web.xml` | Servlet 매핑, UTF-8 필터, 세션 타임아웃(30분) | 구성 |
| `css/style.css` | 전역 스타일(파란색 테마, Bootstrap) | UI |

---

## 6. 배포 및 운영

### 6.1 신규 배포
1. MySQL Workbench에서 `mysql에다넣고실행_fixed.sql` 실행 → DB + 8개 테이블 생성
2. `CampusNav/` 폴더를 Tomcat `webapps/`에 복사
3. Tomcat 중지
4. 프로젝트 루트에서 `compile.bat` 실행
5. Tomcat 재시작
6. 확인: `http://localhost:8080/CampusNav/campuslogin.jsp` 접속

### 6.2 기존 배포 업데이트
- **JSP만 수정:** Tomcat 재시작 불필요, 브라우저 새로고침
- **Java 수정:** Tomcat 중지 → `compile.bat` → 재시작

### 6.3 환경 설정
- **Tomcat 버전:** 9.x
- **MySQL 버전:** 8.x
- **인코딩:** UTF-8 (서블릿/JSP 필터 자동 적용)
- **세션 타임아웃:** 30분 (`web.xml`)

---

## 7. 알려진 이슈 및 진행 상황

### 7.1 완료됨 ✓
- DB 기반 로그인 인증 구현 (`LoginServlet`)
- 3D 내비게이션 맵 (층별 선택, 마커 자동 표시)
- 자산 이관 추적 + 상세 정보 조회
- 기본 자산 검색 및 예약 기능

### 7.2 진행 중 / TODO
- **Google Maps 통합:** `detail.jsp`, `transfer.jsp`에 지도 플레이스홀더 (좌표: 37.396681, 127.247918)
- **경로 저장 API:** `floorNav.jsp` ↔ `saveFloorRoute.jsp`, `deleteFloorRoute.jsp`, `getRoutes.jsp` 통신
- **예약 충돌 감지 고도화:** 현재 AJAX 기반 중복 체크 → 시간대별 충돌 검사로 개선
- **테스트 자동화:** BDD 시나리오 기반 단위/통합 테스트 작성
- **설계 문서 작성:** 요구사항/인터페이스 명세서 정식화

---

## 8. 파일 관리 규칙

### 8.1 Naming Convention
- **설계/분석 문서:** `CAN_{EN_Name}_{Version}_{YYMMDD}.md`
- **예시:** `CAN_Requirements_Spec_v1.0_260527.md`, `CAN_Data_Design_v1.0_260527.md`

### 8.2 문서 포맷
- **기본 형식:** 마크다운(Markdown) — AI 에이전트와 인간 개발자 모두 가독성 극대화
- **저장 위치:** `docs/` 폴더 (프로젝트 루트)

### 8.3 버전 관리
- 설계 문서 수정 시 버전 업데이트 (v1.0 → v1.1)
- 주요 기능 변경 시 마이너 버전 증가 (v1.0 → v2.0)
- Git 커밋 메시지에 문서 업데이트 상황 기록

---

## 9. 참고 자료

- **개발방법론:** `docs/개발방법론_aisw.md`
- **프로젝트 지침:** 본 문서 (`docs/지침서_aisw.md`)
- **CLAUDE.md:** C:\dev\CAN\CLAUDE.md (프로젝트 클론 시 참조)
