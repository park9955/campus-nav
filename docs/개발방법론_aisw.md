# CAN (CampusNav) 프로젝트 개발방법론

**ICT CampusNav 프로젝트 AI-기반 개발 방법론**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project:** ICT CampusNav (CAN)

**Reference:** Samsung SDS Innovator, BDD (Behavior-Driven Development), ADR (Architecture Decision Records)

---

## 1. 개요 (Introduction)

### 1.1 개발방법론의 의미

**ICT CAN** 개발방법론은 소프트웨어 공학 원리를 적용하여 교내 자원 관리 및 내비게이션 시스템을 구축하는 과정에서의 작업 단계, 절차, 산출물 및 관리 체계를 표준화한 것이다. 본 방법론은 다음을 보장한다:

- **원활한 소통:** 프로젝트 팀원(개발자, AI 에이전트) 간 명확한 의도 전달
- **품질 보증:** 기능 구현 단계부터 테스트까지 추적성(Traceability) 유지
- **유지보수 효율성:** 아키텍처 결정 기록(ADR)을 통한 기술적 맥락 보존
- **확장 가능성:** 새로운 기능/역할 추가 시 설계 원칙 일관성 유지

### 1.2 적용 방법

본 방법론은 **AI 에이전트와 인간 개발자의 협업**을 전제로 설계되었다:

1. **설계 문서 우선:** 코드 작성 전 설계 문서(`docs/` 폴더)의 최신 상태 확인
2. **추적성 기반:** 모든 구현은 요구사항 명세서의 고유 ID와 연결
3. **문서 병행 업데이트:** 코드 변경 시 관련 설계 문서 동시 업데이트
4. **결정 기록 유지:** 기술 선택 사항과 그 의도를 ADR에 기록

---

## 2. 개발 생애주기 (SDLC)

### 2.1 단계별 구조

```
기획 → 분석 → 설계 → 구현 → 검증 → 배포 → 운영
 ↓      ↓      ↓      ↓      ↓     ↓      ↓
[산출물 정의] [요구사항 상세화] [설계 문서] [코드] [테스트] [배포 자동화] [모니터링]
```

각 단계의 산출물은 다음 단계의 입력물이 되며, **AI 에이전트는 산출물의 텍스트 명확성을 통해 의도를 정확히 파악**한다.

---

## 3. 단계별 산출물 (Deliverables)

### 3.1 기획 단계 (Planning Stage)

프로젝트의 공식적 승인과 비즈니스 목표, 범위를 확정한다.

| 산출물 | 영문 명칭 | 주요 포함 내용 | 현황 |
|--------|-----------|---------------|------|
| **프로젝트 기획서** | Project Charter | 프로젝트 승인, BRD(비즈니스 요구사항), 범위 정의 | ✓ 완료 |
| **사용자 역할 정의** | Stakeholder & Role Definition | 6개 역할(학부생, 조교, 교수, 관리자, 게스트, 외부인) 정의 | ✓ 완료 |

**입력:** 경영진 의사결정  
**출력:** 프로젝트 승인 및 범위 문서  
**AI 에이전트 역할:** 범위 문서를 읽고 프로젝트 경계 파악

---

### 3.2 분석 단계 (Analysis Stage)

내/외부 환경을 진단하고 시스템이 갖춰야 할 '무엇(What)'을 확정한다.

| 산출물 | 영문 명칭 | 주요 포함 내용 | 현황 |
|--------|-----------|---------------|------|
| **현황 분석서** | Internal Assessment | 기존 자산 관리 프로세스, 사용자 요청사항, 제약 조건 분석 | ✓ 완료 |
| **환경 분석서** | External Analysis | 기술 환경(Tomcat, MySQL, Bootstrap), 유사 시스템 사례 | ✓ 완료 |
| **요구사항 명세서** | Requirement Specification | 기능 요구사항(FR), 비기능 요구사항(NFR), 추적 매트릭스 | ☐ 작성 필요 |

**요구사항 명세서 구조:**

```markdown
# CAN_Requirements_Spec_v1.0_YYMMDD.md

## 기능 요구사항 (FR)

| 고유 ID | 역할 | 기능 | 세부사항 | 우선순위 |
|--------|------|------|---------|----------|
| FR-001 | 학부생 | 자산 검색 | 키워드/카테고리/상태 필터링 | 높음 |
| FR-002 | 학부생 | 자산 예약 | 중복 예약 방지, AJAX 검사 | 높음 |
| ...    | ...  | ...  | ...     | ... |

## 비기능 요구사항 (NFR)

- NFR-001: 응답 시간 < 2초 (자산 검색)
- NFR-002: 동시 사용자 100명 지원
- NFR-003: UTF-8 인코딩 필수
```

**입력:** 프로젝트 기획서, 사용자 인터뷰 기록  
**출력:** 요구사항 명세서 (FR/NFR + 추적 ID)  
**AI 에이전트 역할:** 요구사항 명세서를 참조하여 기능 구현 시 추적성 확보

---

### 3.3 설계 단계 (Design Stage)

시스템의 구성 요소와 상호작용 등 '어떻게(How)'를 정의하며 결정 근거를 남긴다.

#### 3.3.1 시스템 아키텍처 설계서

| 항목 | 내용 |
|------|------|
| **구조** | Servlet(인증) + JSP(데이터 계층) 하이브리드 아키텍처 |
| **컴포넌트** | `LoginServlet` → `web.xml` → `main_*.jsp` → `DBUtil.getConnection()` → MySQL |
| **통신** | HTTP/HTTPS, AJAX(예약 검사) |
| **보안** | 세션 기반 인증, 30분 타임아웃, `session.getAttribute("loginRole")` 권한 검사 |

**구성도:**
```
┌─────────────────────────────────────────────────────────┐
│                    Tomcat 9.x                           │
│  ┌────────────────────────────────────────────────────┐ │
│  │ Servlet Layer (인증)                               │ │
│  │ ├─ LoginServlet    → 로그인 검증 + 세션 설정       │ │
│  │ ├─ LogoutServlet   → 세션 무효화                   │ │
│  │ ├─ GuestServlet    → 게스트 권한 설정              │ │
│  │ └─ VisitorServlet  → 외부인 권한 설정              │ │
│  └────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────┐ │
│  │ JSP Layer (데이터)                                 │ │
│  │ ├─ search.jsp      → 자산 검색(직접 JDBC)         │ │
│  │ ├─ detail.jsp      → 자산 상세정보(직접 JDBC)     │ │
│  │ ├─ reserve.jsp     → 예약 처리(직접 JDBC)         │ │
│  │ ├─ transfer.jsp    → 이관 이력(직접 JDBC)         │ │
│  │ ├─ professor.jsp   → 교수 관리(직접 JDBC)         │ │
│  │ ├─ asset_manage.jsp → 자산 관리(직접 JDBC)        │ │
│  │ └─ floorNav.jsp    → 3D 내비게이션(직접 JDBC)     │ │
│  └────────────────────────────────────────────────────┘ │
│  ┌────────────────────────────────────────────────────┐ │
│  │ DBUtil.java (데이터 접근 계층)                     │ │
│  │ ├─ getConnection() → MySQL 연결                     │ │
│  │ └─ close()        → 연결 해제                      │ │
│  └────────────────────────────────────────────────────┘ │
└─────────────────────────────────────────────────────────┘
         ↓
┌─────────────────────────────────────────────────────────┐
│               MySQL 8.x (campusnav DB)                  │
│ ├─ users           (사용자 + 역할)                      │
│ ├─ assets          (8,401개 자산)                       │
│ ├─ reservations    (예약 정보)                          │
│ ├─ asset_transfer  (자산 이관)                          │
│ ├─ asset_disposal  (자산 폐기)                          │
│ ├─ professors      (교수 정보)                          │
│ ├─ prof_subjects   (교과목)                             │
│ └─ prof_skills     (스킬)                               │
└─────────────────────────────────────────────────────────┘
```

#### 3.3.2 기능 분해도

| 계층 | 기능 그룹 | 세부 기능 |
|------|----------|----------|
| **인증** | 사용자 관리 | 로그인, 로그아웃, 역할 선택 |
| **자산 관리** | 검색 | 키워드/카테고리/상태 필터링, 페이지네이션 |
| | 예약 | 예약 신청, 중복 검사, 예약 취소 |
| | 이관 | 이관 요청, 이관 승인, 이관 이력 조회 |
| **교수 관리** | 프로필 | 교수 정보 조회, 교과목/스킬 관리 |
| **내비게이션** | 지도 | 층별 선택, 마커 표시, 경로 저장/삭제 |

#### 3.3.3 데이터 설계서

**테이블 정의:**

```sql
-- users: 사용자 계정 + 역할
CREATE TABLE users (
    id INT PRIMARY KEY AUTO_INCREMENT,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('student','assistant','professor','admin','guest','visitor') NOT NULL
);

-- assets: 8,401개 자산
CREATE TABLE assets (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(255) NOT NULL,
    category VARCHAR(100),
    status ENUM('available','reserved','transferred','disposed') NOT NULL,
    location VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- reservations: 예약 정보
CREATE TABLE reservations (
    id INT PRIMARY KEY AUTO_INCREMENT,
    user_id INT,
    asset_id INT,
    reservation_date DATE NOT NULL,
    status ENUM('pending','approved','cancelled') DEFAULT 'pending',
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (asset_id) REFERENCES assets(id)
);

-- (기타 테이블은 지침서_aisw.md 참조)
```

**제약 조건:**
- 예약 중복 방지: `UNIQUE(user_id, asset_id, reservation_date)`
- 이관 이력 추적: `asset_transfer` 테이블에 모든 변경 기록

#### 3.3.4 UI/UX 설계서

**역할별 진입 페이지:**

| 역할 | 진입 페이지 | 주요 메뉴 |
|------|-----------|---------|
| 학부생 | `main_student.jsp` | 자산 검색, 예약, 이관 신청 |
| 조교 | `main_assistant.jsp` | 자산 관리, 이관 승인 |
| 교수 | `main_professor.jsp` | 교과목/스킬 관리 |
| 관리자 | `main_admin.jsp` | 전체 자산 관리, 사용자 관리 |
| 게스트 | `main_guest.jsp` | 자산 검색(읽기 전용) |
| 외부인 | `main_visitor.jsp` | 내비게이션 조회 |

**권한 체크 JSP 패턴:**

```jsp
<%
    String loginRole = (String) session.getAttribute("loginRole");
    if (loginRole == null) {
        response.sendRedirect("campuslogin.jsp");
        return;
    }
    if (!loginRole.equals("student") && !loginRole.equals("admin")) {
        out.println("<h3>접근 권한이 없습니다.</h3>");
        return;
    }
%>
```

#### 3.3.5 프로세스 설계서

**자산 검색 프로세스:**

```
사용자 입력 (키워드/카테고리/상태)
    ↓
search.jsp 수신
    ↓
query 생성 (WHERE 조건 동적 구성)
    ↓
DBUtil.getConnection() → PreparedStatement
    ↓
SELECT * FROM assets WHERE ... (필터 적용)
    ↓
결과셋 → HTML 테이블 렌더링
    ↓
페이지네이션 적용 (10개/페이지)
    ↓
사용자 화면 출력
```

**예약 검사 프로세스 (AJAX):**

```javascript
// reserve.jsp - AJAX 호출
fetch('/CampusNav/checkReservation.jsp', {
    method: 'POST',
    body: JSON.stringify({
        asset_id: assetId,
        reservation_date: selectedDate
    })
})
.then(response => response.json())
.then(data => {
    if (data.available) {
        // 예약 가능
    } else {
        alert('이미 예약된 자산입니다.');
    }
});
```

#### 3.3.6 인터페이스 정의서

**JSP ↔ MySQL 인터페이스:**

| JSP 파일 | 메서드 | 쿼리 | 입력 | 출력 |
|----------|--------|------|------|------|
| search.jsp | POST | SELECT * FROM assets WHERE ... | 키워드, 카테고리, 상태 | JSON 배열 (자산 목록) |
| reserve.jsp | POST | INSERT INTO reservations | user_id, asset_id, date | 성공/실패 메시지 |
| transfer.jsp | GET | SELECT * FROM asset_transfer WHERE ... | asset_id | JSON 배열 (이관 이력) |

**API 데이터 규격:**

```json
// search.jsp 응답 예시
{
    "success": true,
    "data": [
        {
            "id": 1,
            "name": "프로젝터",
            "category": "전자기기",
            "status": "available",
            "location": "301호"
        }
    ],
    "totalCount": 8401
}
```

#### 3.3.7 아키텍처 결정 기록 (ADR)

**ADR-001: Servlet vs JSP 책임 분리**

- **결정:** 인증은 Servlet, 데이터 처리는 JSP에서 직접 JDBC 호출
- **이유:** 
  - 복잡한 비즈니스 로직 없음 (CRUD 중심)
  - 빠른 개발 속도 필요
  - JSP 내 JDBC 직접 호출로 계층 단순화
- **대안:** 
  - MVC 패턴 (모든 데이터 처리를 Servlet에서) → 추가 복잡도, 개발 지연
  - 순수 MVC (DAO/Service 계층) → 엔터프라이즈 복잡도
- **결과:** 현재 구조 유지, 새로운 Servlet 추가 필수 (web.xml 등록)

**ADR-002: DBUtil.java 필수 사용**

- **결정:** 모든 JDBC 연결은 `DBUtil.getConnection()` / `DBUtil.close()` 사용 의무
- **이유:**
  - 연결 풀 관리 중앙화
  - 메모리 누수 방지 (finally 블록 보장)
  - 연결 설정 변경 시 한 곳만 수정
- **결과:** 모든 JSP/Servlet에서 필수 적용

---

### 3.4 구현 및 이행 단계 (Implementation Stage)

실제 구동 환경을 구축하고 품질을 검증하여 배포한다.

#### 3.4.1 구현 계획서

| 단계 | 모듈 | 일정 | 담당자 | 의존성 |
|------|------|------|--------|--------|
| Phase 1 | 인증 (LoginServlet, LogoutServlet) | ~ 2026-06-03 | Dev | DB 스키마 완성 |
| Phase 2 | 자산 검색 (search.jsp) | ~ 2026-06-10 | Dev | Phase 1 완료 |
| Phase 3 | 예약 (reserve.jsp) | ~ 2026-06-17 | Dev | Phase 2 완료 |
| Phase 4 | 이관 (transfer.jsp) | ~ 2026-06-24 | Dev | Phase 3 완료 |
| Phase 5 | 내비게이션 (floorNav.jsp) | ~ 2026-07-01 | Dev | Phase 2 완료 |

#### 3.4.2 형상/배포 관리 정의서

**Git 브랜칭 전략:**

```
main (프로덕션)
  └─ develop (통합 개발)
      ├─ feature/auth-system
      ├─ feature/asset-search
      ├─ feature/reservation
      └─ feature/navigation
```

**배포 프로세스:**

1. **로컬 개발:**
   - JSP 수정: 즉시 반영 (Tomcat 재시작 불필요)
   - Java 수정: Tomcat 중지 → compile.bat → Tomcat 재시작

2. **테스트 환경:**
   - 모든 코드 검토(Code Review) 후 develop에 merge
   - 통합 테스트 수행

3. **프로덕션:**
   - develop → main 최종 merge
   - 배포 자동화 (GitHub Actions 등) 검토

#### 3.4.3 테스트 정의서

**BDD 기반 테스트 시나리오:**

```gherkin
# 자산 검색 테스트
Feature: 자산 검색

  Scenario: 키워드로 자산 검색
    Given 자산 데이터베이스에 "프로젝터" 2개가 있다
    When 사용자가 "프로젝터"로 검색한다
    Then 2개의 결과가 반환된다
    And 각 결과는 "프로젝터"를 포함한다

  Scenario: 중복 예약 방지
    Given 자산 "프로젝터"가 "2026-06-01"에 예약되어 있다
    When 다른 사용자가 같은 날짜에 예약하려 한다
    Then 예약이 거부된다
    And "이미 예약된 자산입니다" 메시지를 받는다
```

**테스트 케이스 구조:**

| TC ID | 기능 | 입력 | 예상 결과 | 상태 |
|-------|------|------|----------|------|
| TC-001 | 로그인 | username: admin, password: admin123 | 로그인 성공, admin.jsp 리다이렉트 | ☐ |
| TC-002 | 자산 검색 | keyword: "프로젝터" | 8401개 자산 중 프로젝터만 필터링 | ☐ |
| TC-003 | 예약 중복 검사 | asset_id:1, date:2026-06-01(이미 예약됨) | 예약 거부 | ☐ |

#### 3.4.4 운영/배포 정의서

**배포 체크리스트:**

- [ ] MySQL 초기화: `mysql에다넣고실행_fixed.sql` 실행
- [ ] Tomcat 설정: `server.xml`, `context.xml` 확인
- [ ] 환경 변수: JAVA_HOME, CATALINA_HOME 설정
- [ ] JDBC 드라이버: `mysql-connector-j-*.jar` → Tomcat `lib/` 배치
- [ ] 컴파일: `compile.bat` 정상 실행 (오류 없음)
- [ ] 테스트: `http://localhost:8080/CampusNav/campuslogin.jsp` 접속 확인
- [ ] 세션 타임아웃: 30분(`web.xml`에 설정)

**모니터링:**

```
주기적 확인 항목:
- Tomcat 로그: C:\path\to\tomcat\logs\catalina.out
- MySQL 연결 상태: SELECT 1; → 성공 확인
- 세션 활성 사용자: MySQL `session_tracking` 테이블 모니터링 (구현 시)
```

---

## 4. AI 에이전트를 위한 지침

### 4.1 추적성 준수 (Maintain Traceability)

모든 기능 구현은 요구사항과 연결되어야 한다:

1. **요구사항 명세서 확인:**
   - 구현 전 `docs/CAN_Requirements_Spec_v*.md` 검토
   - 해당 기능의 **고유 ID**(예: FR-001) 파악

2. **코드 주석에 추적 ID 기록:**
   ```java
   // FR-001: 자산 검색 기능
   // 요구사항: 키워드/카테고리/상태 필터링
   public List<Asset> searchAssets(String keyword, String category) {
       // ...
   }
   ```

3. **커밋 메시지에 FR ID 포함:**
   ```
   git commit -m "FR-001: 자산 검색 필터링 구현 - 키워드/카테고리/상태 지원"
   ```

### 4.2 결정 근거 확인 (Consult Decision Records)

구조 변경 제안 전 ADR 확인:

```
제안하기 전: ADR-001 (Servlet vs JSP 책임 분리) 검토
           → 새로운 기능이 이 원칙을 따르는가 확인
           → 예: "새로운 검색 기능"은 JSP(데이터)에 구현 필수
```

### 4.3 오류 분석 시 (When Analyzing Errors)

시스템 상호작용 오류 발생 시 체계적 진단:

1. **아키텍처 검토:** `CAN_Architecture_Design_v*.md` 확인
2. **데이터 스키마 검증:** `CAN_Data_Design_v*.md`의 테이블 정의와 쿼리 대조
3. **인터페이스 검증:** `CAN_Interface_Spec_v*.md`의 데이터 규격 확인
4. **권한 검사:** `session.getAttribute("loginRole")` 누락 여부 확인

**오류 추적 예시:**

```
증상: "자산 검색 결과가 NULL"
대조 항목:
  ✓ 아키텍처: search.jsp → DBUtil.getConnection() → MySQL
  ✓ 데이터: assets 테이블 존재, 8401개 행 확인
  ✓ 쿼리: SQL 문법 정확, WHERE 조건 맞음
  ✓ 권한: loginRole 설정되어 있음
→ 원인: 페이지 인코딩 UTF-8 누락 (web.xml 확인)
```

### 4.4 문서 기반 소통 (Document-Driven Communication)

코드 작성 전 설계 문서 업데이트:

1. **기능 추가 시:**
   - `CAN_Requirements_Spec_v*.md` → 요구사항 추가 (FR-XXX ID 부여)
   - `CAN_Function_Map_v*.md` → 기능 분해도 업데이트
   - `CAN_Data_Design_v*.md` → 테이블/컬럼 변경 반영

2. **데이터 구조 변경 시:**
   - SQL 스크립트 생성
   - 마이그레이션 계획 문서화
   - 기존 데이터 호환성 검증

3. **새로운 기술 도입 시:**
   - `CAN_ADR_XXX_v1.0_YYMMDD.md` 작성
   - 대안 분석, 장단점, 결정 배경 기록

---

## 5. 개발 워크플로우 실무

### 5.1 JSP 수정 흐름

```
1. docs/CAN_*_v*.md 설계 문서 검토
   ↓
2. search.jsp (또는 해당 JSP) 수정
   ↓
3. 브라우저에서 http://localhost:8080/CampusNav/search.jsp 접속
   ↓
4. F5 새로고침 → 즉시 반영 확인 (Tomcat 재시작 불필요)
   ↓
5. git add search.jsp
   ↓
6. git commit -m "FR-002: 자산 검색 필터링 UI 개선"
```

### 5.2 Java 파일 수정 흐름

```
1. WEB-INF/src/com/campus/nav/LoginServlet.java 수정
   ↓
2. Tomcat 중지 (포트 8080 점유 해제)
   ↓
3. 프로젝트 루트에서 compile.bat 실행
   ↓
4. 컴파일 성공 확인 (오류 없음)
   ↓
5. Tomcat 재시작
   ↓
6. 브라우저에서 http://localhost:8080/CampusNav/campuslogin.jsp 접속 확인
   ↓
7. git add WEB-INF/src/.../LoginServlet.java
   ↓
8. git commit -m "FR-001: 로그인 세션 30분 타임아웃 적용"
```

### 5.3 데이터베이스 마이그레이션

```
1. 새로운 테이블/컬럼 필요 판단
   ↓
2. docs/CAN_Data_Design_v1.0.md 업데이트 (스키마 명세)
   ↓
3. migration.sql 작성 (ALTER TABLE / CREATE TABLE)
   ↓
4. 로컬 MySQL에서 테스트
   ↓
5. docs/CAN_Migration_Plan_v1.0.md 문서화 (롤백 계획 포함)
   ↓
6. 프로덕션에 적용 (백업 후)
```

---

## 6. 파일 관리 규칙 (File Management)

### 6.1 네이밍 컨벤션

**설계/분석 문서:**

```
CAN_{EN_Name}_{Version}_{YYMMDD}.md

예시:
- CAN_Requirements_Spec_v1.0_260527.md
- CAN_Architecture_Design_v1.0_260527.md
- CAN_Data_Design_v1.1_260528.md
- CAN_ADR_001_v1.0_260527.md  (아키텍처 결정 기록)
```

**코드 파일:**

```
{Module}_{Functionality}.java/jsp

예시:
- LoginServlet.java
- search.jsp
- DBUtil.java
- style.css
```

### 6.2 저장 위치

| 문서 유형 | 위치 | 예시 |
|----------|------|------|
| 설계 문서 | `docs/` | `docs/CAN_Requirements_Spec_v1.0_260527.md` |
| 코드 | `webapps/CampusNav/` | `webapps/CampusNav/search.jsp` |
| Java 소스 | `WEB-INF/src/` | `WEB-INF/src/com/campus/nav/LoginServlet.java` |
| 배포 스크립트 | 프로젝트 루트 | `compile.bat`, `deploy.sh` |

### 6.3 버전 관리

| 상황 | 버전 변경 | 예시 |
|------|----------|------|
| 오타/문법 수정 | 마이너(v1.0 → v1.1) | `CAN_Requirements_Spec_v1.1_260528.md` |
| 기능 추가/변경 | 마이너(v1.0 → v1.1) | 새로운 FR 추가 |
| 구조적 변경 | 메이저(v1.0 → v2.0) | 아키텍처 전면 개편 |

---

## 7. 품질 보증 (Quality Assurance)

### 7.1 코드 리뷰 체크리스트

- [ ] 요구사항 명세서(FR/NFR)와 매칭 확인
- [ ] DBUtil 사용 여부 (JDBC 직접 호출 시)
- [ ] SQL 인젝션 방지 (PreparedStatement 사용)
- [ ] 권한 검사 (session.getAttribute("loginRole"))
- [ ] 오류 처리 (try-finally 또는 try-with-resources)
- [ ] UTF-8 인코딩 설정 확인
- [ ] 성능 고려 (N+1 쿼리, 인덱스 활용)

### 7.2 테스트 체크리스트

- [ ] 단위 테스트 (각 메서드/쿼리 개별 검증)
- [ ] 통합 테스트 (JSP ↔ DB 상호작용)
- [ ] 권한 테스트 (역할별 접근 제어)
- [ ] 성능 테스트 (응답 시간 < 2초)
- [ ] 보안 테스트 (SQL 인젝션, XSS)

---

## 8. 운영 및 지속적 개선

### 8.1 장애 대응 프로세스

```
1. 장애 감지
   ↓
2. 아키텍처/설계 문서와 실제 코드 대조
   ↓
3. 근본 원인 분석 (데이터/로직/권한)
   ↓
4. 핫픽스 또는 정식 수정안 작성
   ↓
5. 설계 문서 동시 업데이트
   ↓
6. 테스트 및 배포
   ↓
7. 사후 분석(Post-Mortem) 기록
```

### 8.2 기술 부채 관리

| 이슈 | 우선순위 | 해결 계획 |
|------|----------|----------|
| Google Maps 미통합 | 중간 | 2026-07-15까지 통합 완료 |
| 테스트 자동화 부재 | 높음 | BDD 프레임워크 도입 준비 |
| 모니터링 대시보드 부재 | 낮음 | 2026-Q3 계획 |

---

## 9. 참고 자료

- **일반 방법론:** `docs/개발방법론__AIsw (1).md`
- **프로젝트 지침:** `docs/지침서_aisw.md`
- **이 문서:** `docs/CAN_Development_Methodology_v1.0_260527.md`
- **CLAUDE.md:** 프로젝트 클론 시 최상위 참조 문서

---

**문서 이력:**

| 버전 | 날짜 | 변경 내용 |
|------|------|---------|
| v1.0 | 2026-05-27 | 초판 작성 |

