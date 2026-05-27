# 10. 아키텍처 결정 기록 (Architecture Decision Records)

**프로젝트명:** ICT CampusNav (CAN)  
**작성일:** 2025년 2월  
**버전:** 1.0  
**작성자:** AI SW 팀

---

## 목차
1. [개요](#개요)
2. [ADR-001: 기술 스택 선택](#adr-001-기술-스택-선택)
3. [ADR-002: 아키텍처 패턴 선택](#adr-002-아키텍처-패턴-선택)
4. [ADR-003: 웹 프레임워크 선택](#adr-003-웹-프레임워크-선택)
5. [ADR-004: 데이터베이스 선택](#adr-004-데이터베이스-선택)
6. [ADR-005: 인증 방식 선택](#adr-005-인증-방식-선택)
7. [ADR-006: 프론트엔드 기술 선택](#adr-006-프론트엔드-기술-선택)
8. [ADR-007: 배포 전략 선택](#adr-007-배포-전략-선택)
9. [ADR-008: 캐싱 전략](#adr-008-캐싱-전략)
10. [의존성 매트릭스](#의존성-매트릭스)

---

## 개요

아키텍처 결정 기록(ADR)은 프로젝트의 주요 기술 결정사항과 그 근거를 문서화한다. 각 ADR은 결정의 배경, 고려사항, 선택된 방안과 그 이유, 그리고 결과를 명확히 기록하여 향후 유지보수와 확장성 판단에 도움을 제공한다.

**ADR 상태 정의:**
- **Accepted**: 승인되어 현재 적용 중인 결정
- **Pending**: 검토 중이거나 추가 논의가 필요한 결정
- **Deprecated**: 더 이상 사용하지 않는 결정
- **Superseded**: 새로운 결정에 의해 대체된 결정

---

## ADR-001: 기술 스택 선택

**제목:** Java 11 + Servlet/JSP + Tomcat 9.x + MySQL 8.x 스택 채택  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 프로젝트 리드, 개발팀, IT 인프라팀

### 배경 (Context)

ICT 폴리텍 캠퍼스 자산관리 및 네비게이션 시스템 개발 시작 단계에서 기술 스택을 선택해야 한다. 다음과 같은 제약조건이 있다:
- 대학의 기존 인프라 환경(Windows Server, Tomcat)과의 호환성 필요
- 교육기관의 예산 제약 (오픈소스 선호)
- 유지보수 인력의 Java 개발 경험
- 대학 내 IT 인프라팀의 기술 지원 가능성
- 중소 규모 프로젝트 (8,401개 자산, 예상 동시사용자 100명)

### 결정 (Decision)

다음의 기술 스택을 채택한다:
- **언어:** Java 11 (LTS 버전, 대학 표준 정책)
- **웹 애플리케이션 서버:** Apache Tomcat 9.x (Servlet 4.0, JSP 2.3 지원)
- **데이터베이스:** MySQL 8.0 (InnoDB 스토리지 엔진)
- **IDE:** Eclipse IDE / IntelliJ IDEA Community
- **빌드 도구:** Apache Maven 3.6+
- **버전 관리:** Git + GitHub

### 근거 (Rationale)

1. **Java 11 선택 이유:**
   - 2023년 기준 LTS(Long-Term Support) 버전으로 2026년까지 지원
   - 대학 기존 Java 6/8 기반 시스템과의 하위호환성
   - 현대적 언어 기능(모듈 시스템, var 키워드) 활용 가능
   - 널리 사용되는 표준으로 개발자 자산 풍부

2. **Servlet/JSP 선택 이유:**
   - Tomcat의 표준 기술로 최적화된 성능
   - 약 20년 이상의 검증된 기술로 안정성 보장
   - MVC 패턴 구현에 필요한 최소한의 복잡성
   - 높은 제어도와 명확한 요청-응답 사이클

3. **Tomcat 9.x 선택 이유:**
   - 대학 기존 인프라에서 이미 운영 중인 서버
   - IT 인프라팀의 운영 및 지원 경험 보유
   - 가벼운 리소스 사용으로 Windows Server 환경에 적합
   - 컨테이너 기술로의 향후 마이그레이션 가능

4. **MySQL 8.0 선택 이유:**
   - 오픈소스로 라이선스 비용 없음
   - 대학 기존 데이터베이스 환경과 일관성
   - InnoDB의 ACID 트랜잭션 지원
   - JSON 데이터 타입 지원 (향후 API 확장 시)
   - 강력한 데이터 보안 기능 (AES 암호화)

### 검토한 대안 (Alternatives Considered)

| 기술 | 검토 내용 | 탈락 이유 |
|------|---------|---------|
| **Spring Boot** | 현대적이고 생산성 높음 | 높은 학습곡선, 기존 Tomcat 노하우 활용 불가 |
| **Java 17+** | 최신 LTS 버전, 더 많은 기능 | 대학 IT 인프라 호환성 미확인 |
| **PostgreSQL** | 고급 기능, 성능 우수 | 기존 MySQL 인프라, 운영 경험 부족 |
| **Node.js/Express** | 개발 속도 빠름 | Java 기술 자산 활용 불가, 타입 안정성 부족 |
| **Docker/Kubernetes** | 현대적 배포 방식 | 대학 IT 인프라 미지원, 운영 복잡도 높음 |

### 결과 (Consequences)

**긍정적 영향:**
- 대학 기존 인프라와 완벽한 호환성
- IT 인프라팀의 적극적 지원 가능
- 안정적이고 검증된 기술로 위험 최소화
- 개발팀의 빠른 학습곡선
- 낮은 운영 비용

**부정적 영향:**
- Spring Boot 대비 개발 시간 증가 (약 20-30%)
- 마이크로서비스 아키텍처로의 확장 어려움
- 최신 프레임워크의 개발 생산성 미활용
- JavaScript 프레임워크 미사용으로 프론트엔드 현대화 제한

### 추가 고려사항

- **마이그레이션 경로:** 향후 Java 17+ 또는 Spring Boot로의 점진적 마이그레이션 가능
- **학습 자료:** Java/Servlet/JSP 관련 교육 자료 풍부 (대학 교육 목적)
- **컨설팅:** 필요 시 Tomcat/MySQL 전문가 컨설팅 비용 상대적으로 저렴

---

## ADR-002: 아키텍처 패턴 선택

**제목:** Layered (3-Tier) 아키텍처 패턴 채택  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 아키텍처팀, 개발팀, 운영팀

### 배경 (Context)

기술 스택 선택(Java 11 + Servlet/JSP) 이후, 전체 애플리케이션의 구조를 결정해야 한다. 다음을 고려해야 한다:
- 중소 규모 프로젝트 (예상 기능: 자산관리, 예약, 네비게이션 등)
- 향후 기능 추가 및 유지보수 용이성
- 개발팀의 설계 경험 수준
- 배포 및 운영의 단순성

### 결정 (Decision)

Layered Architecture (계층화 아키텍처)를 3-Tier 구조로 채택한다:

```
┌─────────────────────────────────┐
│   Presentation Layer (JSP)      │  사용자 인터페이스
├─────────────────────────────────┤
│   Business Logic Layer (Service)│  비즈니스 규칙, 데이터 처리
├─────────────────────────────────┤
│   Data Access Layer (DAO)       │  데이터베이스 연동
└─────────────────────────────────┘
```

### 근거 (Rationale)

1. **명확한 책임 분리:**
   - Presentation Layer: 화면 표시, 사용자 입력 처리
   - Business Logic Layer: 비즈니스 규칙 구현, 데이터 검증
   - Data Access Layer: SQL 실행, 데이터베이스 연동
   - 각 계층의 책임이 명확하여 코드 이해와 유지보수 용이

2. **독립적인 개발:**
   - 각 계층을 독립적으로 개발 가능
   - 팀원 간 병렬 작업 가능
   - 테스트 작성 및 자동화 용이

3. **기술 변경에 대한 유연성:**
   - Presentation을 JSP → JSF 또는 템플릿 엔진으로 변경 가능
   - Business Logic 계층을 Spring 프레임워크로 마이그레이션 가능
   - Data Access를 ORM(Hibernate)으로 변경 가능

4. **성능 최적화의 용이성:**
   - 각 계층별 캐싱 전략 적용 가능
   - Database 쿼리 최적화와 UI 최적화를 독립적으로 수행
   - 병목 지점 파악 및 개선 용이

### 검토한 대안 (Alternatives Considered)

| 패턴 | 장점 | 단점 | 결정 |
|------|------|------|------|
| **Layered (3-Tier)** | 단순, 이해하기 쉬움 | 확장성 제한 | **선택** |
| **Microservices** | 높은 확장성, 독립 배포 | 복잡도 높음, 운영 어려움 | 탈락 |
| **Event-Driven** | 비동기 처리, 높은 응답성 | 복잡한 메시지 처리, 디버깅 어려움 | 탈락 |
| **Clean Architecture** | 테스트 용이, 의존성 역전 | 초기 복잡도 높음, 소규모 팀에 과도함 | 탈락 |

### 결과 (Consequences)

**긍정적 영향:**
- 전체 시스템 아키텍처 이해 용이 (팀원 온보딩 시간 단축)
- 각 계층의 변경이 다른 계층에 미치는 영향 최소화
- 테스트 전략이 명확 (단위 테스트, 통합 테스트 분리)
- 배포 단순 (한 WAR 파일로 전체 배포)

**부정적 영향:**
- 마이크로서비스로의 확장 시 전면적 리팩토링 필요
- 특정 계층이 병목이 되면 수평 확장 어려움
- 많은 inter-layer 호출로 인한 약간의 성능 오버헤드

### 추가 고려사항

- **확장 경로:** 향후 특정 모듈(예: 네비게이션 API)을 별도 마이크로서비스로 분리 가능
- **기술 부채:** Layered 구조의 명확성으로 인해 기술 부채 최소화

---

## ADR-003: 웹 프레임워크 선택

**제목:** Servlet/JSP 직접 사용, Spring Framework 미채택  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 개발팀, 아키텍처팀

### 배경 (Context)

Java 기술 스택 선택 후, 요청 처리 및 뷰 렌더링을 위한 웹 프레임워크를 결정해야 한다. 다음을 고려:
- 팀의 Spring Framework 경험 수준
- 프로젝트의 복잡도 (중소 규모)
- 개발 속도 vs. 장기적 유지보수성
- 대학 IT 지원 가능성

### 결정 (Decision)

Spring Framework를 사용하지 않고, 순수 Servlet/JSP와 간단한 MVC 패턴으로 개발한다.

```java
// Controller Servlet
@WebServlet("/search")
public class SearchServlet extends HttpServlet {
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) {
        String keyword = req.getParameter("keyword");
        AssetService service = new AssetService();
        List<Asset> results = service.search(keyword);
        req.setAttribute("results", results);
        req.getRequestDispatcher("/search-results.jsp").forward(req, resp);
    }
}

// JSP View
<%@ page import="com.can.model.Asset" %>
<% List<Asset> results = (List<Asset>) request.getAttribute("results"); %>
<table>
    <% for (Asset asset : results) { %>
        <tr><td><%= asset.getName() %></td></tr>
    <% } %>
</table>
```

### 근거 (Rationale)

1. **학습곡선 최소화:**
   - Servlet/JSP는 Java EE의 기본 기술
   - 팀원들이 관련 자료를 쉽게 찾을 수 있음
   - Spring의 DI, AOP 같은 고급 개념을 학습할 필요 없음

2. **배포 및 운영의 단순성:**
   - WAR 파일로 간단히 Tomcat에 배포
   - Spring의 auto-configuration 없이도 작동
   - IT 인프라팀이 쉽게 지원 가능

3. **성능:**
   - Servlet/JSP는 Tomcat에서 최고의 성능 발휘
   - Spring의 추상화 계층으로 인한 오버헤드 없음
   - 100명 동시 사용자 처리에는 충분한 성능

4. **프로젝트 규모의 적절성:**
   - Spring은 규모가 큰 엔터프라이즈 애플리케이션용
   - 중소 규모 프로젝트에는 과도한 기능 제공
   - 불필요한 복잡도 회피

### 검토한 대안 (Alternatives Considered)

| 프레임워크 | 장점 | 단점 | 결정 |
|-----------|------|------|------|
| **Servlet/JSP** | 단순, 성능 우수 | 라이브러리 없음 | **선택** |
| **Spring MVC** | 강력함, 많은 기능 | 학습곡선 높음, 과도한 기능 | 탈락 |
| **Spring Boot** | 최신식, 빠른 개발 | 마이크로서비스 중심, 복잡도 | 탈락 |
| **Struts 2** | 레거시 지원 | 개발 중단, 보안 취약점 | 탈락 |

### 결과 (Consequences)

**긍정적 영향:**
- 빠른 초기 개발
- 명확한 요청-응답 사이클 이해
- 최적의 성능
- 의존성 최소 (WAR 크기 작음)

**부정적 영향:**
- 반복적인 코드 작성 (보일러플레이트)
- 입력값 검증, 에러 처리를 직접 구현해야 함
- 향후 기능 복잡도 증가 시 Spring으로의 마이그레이션 필요 가능

### 향후 마이그레이션 경로

프로젝트가 성장하여 다음과 같은 요구사항이 발생하면 Spring MVC로 점진적 마이그레이션 고려:
- 100개 이상의 Servlet 개발 필요
- 국제화(i18n), 보안(Security) 기능 강화
- 테스트 자동화 요구도 증가

---

## ADR-004: 데이터베이스 선택

**제목:** MySQL 8.0 채택 (PostgreSQL 제외)  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** DBA팀, 개발팀, IT인프라팀

### 배경 (Context)

데이터 저장소 선택 단계. 다음의 요구사항 고려:
- 대학 기존 데이터베이스 인프라와의 호환성
- 자산 8,401개, 예약 데이터 처리
- ACID 트랜잭션 필요 (자산 이전, 예약 충돌 방지)
- 데이터 보안 (기숙사 배치도, 개인 정보 포함)
- 확장성 및 백업 전략

### 결정 (Decision)

MySQL 8.0 + InnoDB 스토리지 엔진을 선택한다.

```sql
-- 기본 설정
CREATE DATABASE can CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

-- InnoDB 설정
SET SESSION innodb_strict_mode=ON;
SET SESSION innodb_flush_log_at_trx_commit=1;

-- 사용자 생성
CREATE USER 'can_app'@'localhost' IDENTIFIED BY '[bcrypt_hashed_password]';
GRANT SELECT, INSERT, UPDATE, DELETE, CREATE TEMPORARY TABLES ON can.* TO 'can_app'@'localhost';
```

### 근거 (Rationale)

1. **ACID 트랜잭션 지원:**
   - InnoDB는 완전한 ACID 준수
   - 자산 예약 시 동시성 제어 필요 → 트랜잭션 필수
   - 자산 이전 승인 프로세스의 데이터 일관성 보장

2. **보안:**
   - AES-256 암호화 지원 (기숙사 배치도 보안)
   - 사용자별 권한 관리 가능
   - SQL Injection 방지를 위한 PreparedStatement 지원

3. **성능 최적화:**
   - 인덱싱 전략 효과적 (Full-text Search)
   - 쿼리 최적화 가능 (EXPLAIN 분석)
   - 100명 동시 사용자 수준의 성능 충분

4. **기존 인프라 활용:**
   - 대학 기존 MySQL 5.7 환경의 8.0 업그레이드 경로 명확
   - DBA팀의 운영 경험 풍부
   - 백업/복구 절차 이미 수립

5. **확장성:**
   - JSON 데이터 타입 (향후 API 확장)
   - 파티셔닝 지원 (대량 데이터 처리)
   - Replication으로 읽기 확장 가능

### 검토한 대안 (Alternatives Considered)

| 데이터베이스 | 특징 | 검토 내용 | 탈락 이유 |
|-------------|------|---------|---------|
| **MySQL 8.0** | ACID, 성능, 편의성 | 최적의 선택 | **선택** |
| **PostgreSQL** | 고급 기능, 성능 우수 | 우수하나 | 기존 인프라 미활용, DBA 경험 부족 |
| **MariaDB** | MySQL 호환, 오픈소스 | 가능하나 | 표준화 필요, 마이그레이션 비용 |
| **Oracle DB** | 엔터프라이즈급 | 과도하고 | 높은 라이선스 비용 (교육기관 제외), 대학 예산 초과 |
| **MongoDB** | NoSQL, 유연성 | 검토함 | 트랜잭션 필요, 관계형 데이터 설계 적합 |

### 결과 (Consequences)

**긍정적 영향:**
- 기존 대학 인프라 활용 (라이선스, 운영 비용 절감)
- DBA팀 지원으로 신뢰성 확보
- 안정적인 데이터 관리
- 백업/복구/모니터링 도구 풍부

**부정적 영향:**
- PostgreSQL의 고급 기능 미활용
- 매우 대규모 데이터(petabyte급)에는 제약
- 일부 분석 쿼리의 성능 제약

### 마이그레이션 전략

향후 PostgreSQL 이전이 필요한 경우:
1. 데이터 내보내기 (mysqldump)
2. pg_dump로 PostgreSQL 형식 변환
3. 애플리케이션 코드 최소 변경 (SQL 표준 준수 필요)

---

## ADR-005: 인증 방식 선택

**제목:** 세션 기반 인증 + bcrypt 비밀번호 해싱  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 보안팀, 개발팀

### 배경 (Context)

사용자 인증 메커니즘 선택. 다음을 고려:
- 대학 기존 인증 시스템과의 연계 가능성
- 보안 요구사항 (OWASP Top 10 준수)
- 모바일 앱 향후 추가 가능성
- 세션 타임아웃 요구사항 (30분)

### 결정 (Decision)

서버 세션 기반 인증 + bcrypt 비밀번호 해싱을 채택한다.

```java
// LoginServlet.java
@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) {
        String username = req.getParameter("username");
        String password = req.getParameter("password");
        
        User user = userDAO.findByUsername(username);
        if (user != null && BCrypt.checkpw(password, user.getPasswordHash())) {
            // 세션 생성
            HttpSession session = req.getSession();
            session.setAttribute("user", user);
            session.setMaxInactiveInterval(30 * 60); // 30분
            resp.sendRedirect("/dashboard");
        } else {
            req.setAttribute("error", "Invalid credentials");
            req.getRequestDispatcher("/login.jsp").forward(req, resp);
        }
    }
}
```

### 근거 (Rationale)

1. **보안성:**
   - bcrypt는 비밀번호 해싱의 표준 알고리즘
   - Salt 자동 생성으로 Rainbow Table 공격 방지
   - 의도적으로 느린 알고리즘으로 brute-force 공격 방지

2. **세션 기반 선택:**
   - Servlet의 표준 HttpSession 사용
   - 서버에서 세션 상태 관리 (안전함)
   - 토큰 검증 없이 간단한 구현
   - 기존 대학 시스템과 호환 가능

3. **OWASP 보안 기준 준수:**
   - OWASP A01: 깨진 접근 제어 → 세션 기반으로 관리
   - OWASP A02: 암호화 실패 → bcrypt + HTTPS TLS 1.2+
   - OWASP A07: 약한 인증 → 세션 타임아웃 설정

4. **30분 타임아웃:**
   - 교육 기관 보안 표준 (일반적)
   - 수동 로그아웃 기능 제공
   - 자동 갱신(Sliding Window) 미지원 (보안)

### 검토한 대안 (Alternatives Considered)

| 방식 | 특징 | 검토 내용 | 탈락 이유 |
|------|------|---------|---------|
| **세션 기반** | 서버 관리, 간단 | 적합 | **선택** |
| **JWT (Token)** | 상태 비저장, 확장성 | 검토함 | 모바일 미지원, 로그아웃 구현 어려움 |
| **OAuth 2.0** | 표준, 외부 연계 | 검토함 | 대학 인증 서버 미지원, 구현 복잡 |
| **SAML** | 엔터프라이즈 표준 | 검토함 | 설정 복잡, 대학 인프라 미지원 |

### 결과 (Consequences)

**긍정적 영향:**
- 간단하고 검증된 보안 메커니즘
- 세션 강제 종료 가능 (관리자 권한)
- Servlet 표준 API 활용 (별도 라이브러리 불필요)
- 메모리 효율적 (비교적 적은 세션 수)

**부정적 영향:**
- 모바일 앱 추가 시 별도 토큰 방식 필요 가능
- 서버 메모리에 세션 저장 (대규모 동시 사용자 시 문제)
- 마이크로서비스 아키텍처로 확장 시 세션 공유 복잡

### 향후 마이그레이션 경로

모바일 앱 개발 시:
1. JWT 토큰 기반 API 별도 개발
2. 웹과 API 간 다중 인증 메커니즘 공존
3. 향후 모든 클라이언트 JWT로 통일 가능

---

## ADR-006: 프론트엔드 기술 선택

**제목:** Vanilla JavaScript + HTML5 + CSS3 (프레임워크 미사용)  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 개발팀, UI/UX팀

### 배경 (Context)

사용자 인터페이스 구현 기술 선택. 다음을 고려:
- 2D/3D 캠퍼스 지도 인터렉션 필요
- 페이지 로드 성능 < 2초
- 브라우저 호환성 (Chrome, Firefox, Safari, Edge)
- 개발팀의 JavaScript 경험 수준

### 결정 (Decision)

프론트엔드 프레임워크(React, Vue, Angular) 미사용, Vanilla JavaScript + HTML5 + CSS3 사용한다.

```javascript
// assets/js/map.js
class CampusMap {
    constructor(canvasId) {
        this.canvas = document.getElementById(canvasId);
        this.ctx = this.canvas.getContext('2d');
        this.floors = [];
        this.currentFloor = 0;
    }
    
    render() {
        this.ctx.clearRect(0, 0, this.canvas.width, this.canvas.height);
        this.floors[this.currentFloor].draw(this.ctx);
    }
    
    selectFloor(floorIndex) {
        this.currentFloor = floorIndex;
        this.render();
    }
}

// 사용
const map = new CampusMap('campusCanvas');
document.getElementById('floor-buttons').addEventListener('click', (e) => {
    if (e.target.classList.contains('floor-btn')) {
        map.selectFloor(parseInt(e.target.dataset.floor));
    }
});
```

### 근거 (Rationale)

1. **성능:**
   - 프레임워크 라이브러리 로딩 불필요
   - 페이지 번들 크기 최소 (React: ~40KB vs Vanilla: ~10KB)
   - 캔버스 기반 2D 지도 렌더링 직접 최적화 가능

2. **지도 표현:**
   - HTML Canvas API로 2D 지도 구현 최적
   - Three.js로 3D 지도 구현 가능
   - DOM 조작 없이 단순 렌더링 (성능 우수)

3. **브라우저 호환성:**
   - ES6 문법 모든 최신 브라우저에서 지원
   - Polyfill 불필요 (IE 지원 안함)
   - CSS Grid, Flexbox 표준화

4. **학습곡선:**
   - JavaScript 기본 지식만 필요
   - 별도 빌드 프로세스 불필요
   - 디버깅 용이 (직접 소스 추적)

5. **서버 렌더링 기반:**
   - JSP에서 직접 HTML 생성
   - 프론트엔드-백엔드 간 데이터 전달 간단
   - JavaScript는 UI 인터렉션만 담당

### 검토한 대안 (Alternatives Considered)

| 기술 | 장점 | 단점 | 결정 |
|------|------|------|------|
| **Vanilla JS** | 단순, 성능 우수 | 반복적인 코드 | **선택** |
| **React** | 컴포넌트 기반, 성숙함 | 번들 크기, 학습곡선 | 탈락 |
| **Vue.js** | 가벼움, 배우기 쉬움 | 에코시스템 작음, 번들 크기 | 탈락 |
| **Angular** | 풀 프레임워크 | 과도한 기능, 복잡도 | 탈락 |
| **jQuery** | 레거시 지원 | 유지보수 낮음, 최신 기술 아님 | 탈락 |

### 결과 (Consequences)

**긍성적 영향:**
- 빠른 페이지 로드 시간
- 지도 렌더링 성능 최적화
- 단순한 아키텍처로 유지보수 용이
- 의존성 최소 (보안 취약점 감소)

**부정적 영향:**
- 복잡한 UI 기능 추가 시 코드 증가
- 상태 관리 복잡도 증가 (대규모 SPA 불가)
- 재사용 컴포넌트 라이브러리 없음

### 향후 개선 경로

프론트엔드 복잡도 증가 시:
1. Webpack 기반 모듈 번들링 도입
2. TypeScript 추가 (타입 안정성)
3. 필요한 경우 React/Vue로 점진적 마이그레이션

---

## ADR-007: 배포 전략 선택

**제목:** Blue-Green 배포 전략 + 자동화  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** DevOps팀, 운영팀, IT인프라팀

### 배경 (Context)

프로덕션 배포 전략 결정. 다음을 고려:
- 배포 중 다운타임 최소화 (교육 기관 특성상 학기 중 배포)
- 빠른 롤백 가능성 (문제 발생 시)
- 운영팀의 자동화 능력
- 대학 인프라(Tomcat, Windows Server) 제약

### 결정 (Decision)

Blue-Green 배포 전략을 채택한다.

```
배포 전:
┌─────────────────┐         ┌──────────────┐
│  Blue Instance  │───────→ │   users      │
│ (Production)    │         │              │
└─────────────────┘         └──────────────┘

┌─────────────────┐
│  Green Instance │  (새 버전 배포)
│ (Standby)       │
└─────────────────┘

배포 후:
┌─────────────────┐         ┌──────────────┐
│  Blue Instance  │  ──X    │              │
│ (Idle)          │         │              │
└─────────────────┘         │              │
                            │   users      │
┌─────────────────┐         │              │
│  Green Instance │─────→   │              │
│ (Production)    │         │              │
└─────────────────┘         └──────────────┘

롤백 시:
┌─────────────────┐         ┌──────────────┐
│  Green Instance │  ──X    │              │
│ (Idle)          │         │              │
└─────────────────┘         │              │
                            │   users      │
┌─────────────────┐         │              │
│  Blue Instance  │─────→   │              │
│ (Production)    │         │              │
└─────────────────┘         └──────────────┘
```

### 근거 (Rationale)

1. **무중단 배포:**
   - 사용자가 이용 중인 서비스 영향 없음
   - 새 버전 검증 후 전환
   - 점심시간/야간에 배포하지 않아도 됨

2. **빠른 롤백:**
   - 문제 발생 시 이전 버전으로 즉시 전환
   - 데이터 일관성 보장 (데이터베이스 스키마 변경 시 주의)
   - 사용자에게 보이는 중단 시간 < 1분

3. **테스트 환경:**
   - Green 인스턴스에서 추가 테스트 가능
   - 실제 데이터로 검증 (스모크 테스트)
   - 성능 검증 후 전환

4. **구현 용이성:**
   - 로드밸런서(Load Balancer) 또는 리버스 프록시로 전환
   - Tomcat 두 개 인스턴스만 필요
   - 자동화 스크립트로 배포 자동화 가능

### 검토한 대안 (Alternatives Considered)

| 배포 방식 | 특징 | 검토 내용 | 탈락 이유 |
|----------|------|---------|---------|
| **Blue-Green** | 무중단, 빠른 롤백 | 적합 | **선택** |
| **Rolling** | 단계적 배포 | 검토함 | 버전 혼재, 데이터 마이그레이션 복잡 |
| **Canary** | 일부 사용자 먼저 | 검토함 | 모니터링 복잡, 필요 없음 |
| **Feature Flag** | 동적 기능 제어 | 검토함 | 코드 복잡도 증가, 즉각적 롤백 필요 |
| **Traditional** | 한 번에 배포 | 검토함 | 다운타임 필요, 대학 정책 위배 |

### 결과 (Consequences)

**긍정적 영향:**
- 배포 중 서비스 중단 없음
- 빠른 문제 대응 및 롤백 가능
- 배포 과정 표준화 및 자동화
- 배포 신뢰도 증가

**부정적 영향:**
- 두 배의 서버 리소스 필요
- 데이터베이스 스키마 변경 시 조율 필요
- 배포 자동화 초기 구축 비용

### 배포 자동화 스크립트

```bash
#!/bin/bash
# deploy.sh - Blue-Green 배포 스크립트

# 1. Green 인스턴스에 새 버전 배포
echo "Deploying new version to Green instance..."
sudo cp can-new-version.war /opt/tomcat-green/webapps/can.war

# 2. Green 인스턴스 시작
echo "Starting Green instance..."
/opt/tomcat-green/bin/startup.sh
sleep 10

# 3. Green 인스턴스 헬스 체크
echo "Health check..."
if curl -f http://localhost:8081/can/health; then
    echo "Green instance is healthy"
    
    # 4. 로드밸런서 전환
    echo "Switching load balancer..."
    echo "server green 127.0.0.1:8081;" > /etc/nginx/blue-green.conf
    sudo systemctl reload nginx
    
    # 5. Blue 인스턴스 중지
    echo "Stopping Blue instance..."
    /opt/tomcat-blue/bin/shutdown.sh
else
    echo "Green instance health check failed"
    /opt/tomcat-green/bin/shutdown.sh
    exit 1
fi
```

---

## ADR-008: 캐싱 전략

**제목:** 다층 캐싱 전략 (DB 쿼리 + 세션 + HTTP 캐시)  
**날짜:** 2024년 12월  
**상태:** Accepted  
**관련자:** 개발팀, 운영팀, DBA팀

### 배경 (Context)

성능 목표(페이지 로드 < 2초, 쿼리 < 1초) 달성을 위한 캐싱 전략 결정. 다음을 고려:
- 반복적으로 조회되는 자산 데이터 (8,401개)
- 캠퍼스 지도, 층수 정보 (변경 빈도 낮음)
- 사용자 선호도 (로그인 후 유지)
- 예약 정보 (실시간 일관성 필수)

### 결정 (Decision)

3단계 캐싱 전략을 채택한다:

**1단계: 데이터베이스 쿼리 캐싱**
```java
// AssetDAO.java - 메모리 캐시
private static final Map<Integer, Asset> ASSET_CACHE = new HashMap<>();
private static final long CACHE_EXPIRY = 60 * 1000; // 60초

public Asset getAssetById(int assetId) {
    if (ASSET_CACHE.containsKey(assetId)) {
        return ASSET_CACHE.get(assetId);
    }
    
    Asset asset = queryDatabase(assetId);
    ASSET_CACHE.put(assetId, asset);
    return asset;
}
```

**2단계: 세션 캐싱**
```java
// LoginServlet.java - 사용자 정보 세션 저장
HttpSession session = req.getSession();
User user = userDAO.findByUsername(username);
session.setAttribute("user", user);
session.setAttribute("preferences", userDAO.getPreferences(user.getId()));
```

**3단계: HTTP 캐싱**
```jsp
<!-- JSP에서 캐시 헤더 설정 -->
<%
    response.setHeader("Cache-Control", "public, max-age=3600");
    response.setHeader("ETag", "\"" + System.currentTimeMillis() + "\"");
%>
```

### 근거 (Rationale)

1. **성능 향상:**
   - DB 쿼리 시간 단축 (1초 → 10ms)
   - 네트워크 왕복 제거 (HTTP 캐시)
   - 전체 응답 시간 30-50% 단축

2. **캐시 레이어별 최적화:**
   - DB 캐시: 자주 사용되는 자산 정보
   - 세션 캐시: 사용자별 맞춤 정보
   - HTTP 캐시: 정적 리소스, 변경 없는 페이지

3. **일관성 보장:**
   - 예약 데이터는 캐싱 없음 (실시간 반영)
   - 자산 수정 시 캐시 무효화 (60초 TTL)
   - 사용자 명시적 갱신 기능

### 캐시 무효화 전략

```java
// 자산 수정 시 캐시 무효화
public void updateAsset(Asset asset) {
    database.update(asset);
    ASSET_CACHE.remove(asset.getId()); // 캐시 제거
}

// 예약 완료 시 해당 자산의 예약 정보 갱신
public void createReservation(Reservation reservation) {
    database.insert(reservation);
    reservation_cache.invalidate(reservation.getAssetId());
}
```

### 결과 (Consequences)

**긍정적 영향:**
- 성능 목표(< 2초) 달성 가능
- 데이터베이스 부하 감소
- 사용자 경험 향상

**부정적 영향:**
- 메모리 사용량 증가
- 캐시 일관성 관리 복잡도 증가
- 분산 시스템 확장 시 캐시 동기화 문제

---

## 의존성 매트릭스

각 아키텍처 결정 간의 의존성을 나타낸다.

```
ADR-001 (기술 스택)
  ├── 선택: Java 11, Servlet/JSP, Tomcat, MySQL
  │
  ├→ ADR-002 (아키텍처 패턴) [의존]
  │   └── 선택: Layered Architecture
  │
  ├→ ADR-003 (웹 프레임워크) [의존]
  │   └── 선택: Servlet/JSP 직접 사용
  │
  ├→ ADR-004 (데이터베이스) [의존]
  │   └── 선택: MySQL 8.0 + InnoDB
  │
  └→ ADR-007 (배포 전략) [영향]
      └── 선택: Blue-Green 배포

ADR-005 (인증 방식)
  ├── 세션 기반 선택
  │
  ├→ ADR-006 (프론트엔드) [협력]
  │   └── JavaScript로 세션 유지
  │
  └→ ADR-008 (캐싱 전략) [영향]
      └── 세션 캐싱 포함

ADR-006 (프론트엔드)
  ├── Vanilla JS 선택
  │
  ├→ ADR-001 (기술 스택) [협력]
  │   └── HTML5, CSS3, Canvas API 활용
  │
  └→ ADR-008 (캐싱 전략) [협력]
      └── HTTP 캐시 헤더 설정

ADR-008 (캐싱 전략)
  ├── 3단계 캐싱
  │
  ├→ ADR-004 (데이터베이스) [협력]
  │   └── DB 쿼리 캐시
  │
  └→ ADR-005 (인증 방식) [협력]
      └── 세션 캐싱
```

---

## 아키텍처 결정 변경 프로세스

향후 아키텍처 결정을 변경해야 하는 경우:

### 변경 요청 프로세스

1. **문제 식별 및 제안:**
   - 기존 결정의 문제점 명확히
   - 변경의 이유와 이득 제시
   - 예상 영향 범위 분석

2. **검토 및 승인:**
   - 아키텍처팀 리뷰
   - 관련 팀(개발, 운영, DBA) 의견 수렴
   - 마이그레이션 계획 수립

3. **기록 및 추적:**
   - 새로운 ADR 작성
   - 기존 ADR을 "Superseded"로 표시
   - 변경 이력 문서화

### 예: Spring Boot로의 마이그레이션 (가정)

만약 향후 Spring Boot로 마이그레이션이 필요한 경우:

```markdown
## ADR-009: Spring Boot로의 마이그레이션 (제안)

**제목:** ADR-003 (Servlet/JSP) 교체, Spring Boot MVC 도입  
**날짜:** [향후 일자]  
**상태:** Pending  

### 배경
- 프로젝트 규모 증가 (수백 개의 Servlet)
- 테스트 자동화 요구도 증가
- 새로운 팀원들의 Spring 경험 활용 필요

### 결정
Spring Boot 2.x로 점진적 마이그레이션

### 마이그레이션 계획
1. Phase 1: 신규 기능부터 Spring Boot로 개발
2. Phase 2: 기존 Servlet 점진적 변환
3. Phase 3: 완전 전환 및 Tomcat Embed로 통합
```

---

## 결론

본 문서의 8개 ADR은 ICT CampusNav 프로젝트의 기술적 기반을 형성한다. 각 결정은 다음과 같은 원칙에 따라 이루어졌다:

1. **실용성:** 현재 상황(기존 인프라, 팀 역량)을 최우선으로 고려
2. **장기 유지보수성:** 기술 부채를 최소화하고 확장 경로 확보
3. **보안:** OWASP, WCAG 등 국제 표준 준수
4. **성능:** 목표 성능 달성 가능한 기술 선택
5. **팀 역량:** 학습곡선을 고려한 현실적 선택

이 결정들은 2-3년 내에는 프로젝트의 안정적인 운영을 보장하며, 그 이후 변경이 필요한 경우 이 문서의 "변경 프로세스"를 따라 체계적으로 관리할 수 있다.

---

## 버전 이력

| 버전 | 날짜 | 작성자 | 변경사항 |
|------|------|--------|---------|
| 1.0 | 2025-02-XX | AI SW 팀 | 초기 8개 ADR 작성 |

---

**문서 작성 완료일:** 2025년 2월  
**최종 검토자:** [프로젝트 리드]  
**승인일:** [승인 예정일]
