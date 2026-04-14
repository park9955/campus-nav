═══════════════════════════════════════════════════════════════════
  ICT CampusNav — 교내 자원 내비게이션 시스템
  개발 가이드 & 설치 매뉴얼
  최종 업데이트: 2026-04-14
═══════════════════════════════════════════════════════════════════

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  목차
  1. 프로젝트 개요
  2. 기술 스택 및 경로
  3. 폴더 구조
  4. DB 설치 및 연동 순서
  5. 톰캣 배포 순서
  6. LoginServlet 컴파일 방법
  7. 테스트 계정
  8. JSP 페이지별 기능 설명
  9. 확장 예정 기능
  10. 트러블슈팅
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━


┌─────────────────────────────────────────────────────────────────┐
│  1. 프로젝트 개요                                                │
└─────────────────────────────────────────────────────────────────┘

  ICT폴리텍대학 교내 자원 내비게이션 시스템
  - 학교 위치: 경기도 광주시 순암로 16-26
  - 교내 자산 8,401건 DB 연동
    (공기구비품 3,368 / 집기비품 4,737 / 무형고정자산(SW) 296)
  - 이관 이력 140건, 폐기 이력 2,721건 포함
  - 5가지 역할: 학부생 / 조교 / 교수 / 운영관리자 / 게스트

  접속 URL
  → http://localhost:8080/CampusNav/campuslogin.jsp


┌─────────────────────────────────────────────────────────────────┐
│  2. 기술 스택 및 경로                                            │
└─────────────────────────────────────────────────────────────────┘

  백엔드:  JSP, Java Servlet
  WAS:     Apache Tomcat 9.x
  DB:      MySQL 8.x
  JDBC:    mysql-connector-j (Tomcat lib/ 폴더에 위치해야 함)
  프론트:  Bootstrap 5.3.3 + Bootstrap Icons
  폰트:    DM Sans, DM Mono, Noto Sans KR
  UI:      ppd4 스타일 (화이트 베이스 + 블루 포인트, 15px)

  ─── Tomcat 경로 ──────────────────────────────────────────────

  [내 컴퓨터]
    Tomcat 루트: C:\Program Files\apache-tomcat-9.0.115\
    배포 경로:   C:\Program Files\apache-tomcat-9.0.115\webapps\CampusNav\
    JDBC JAR:    C:\Program Files\apache-tomcat-9.0.115\lib\

  [교수님/학교 컴퓨터]
    Tomcat 루트: C:\Program Files\Apache Software Foundation\Tomcat 9.0\
    배포 경로:   C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\CampusNav\
    JDBC JAR:    C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\


┌─────────────────────────────────────────────────────────────────┐
│  3. 폴더 구조                                                    │
└─────────────────────────────────────────────────────────────────┘

  CampusNav/
  ├── campuslogin.jsp              로그인
  ├── register.jsp                 회원가입 (DB 직접 저장)
  ├── main_student.jsp             학부생 메인
  ├── main_assistant.jsp           조교 메인
  ├── main_professor.jsp           교수 메인
  ├── main_admin.jsp               관리자 메인 (DB 실통계)
  ├── main_guest.jsp               게스트 메인
  ├── search.jsp                   자원 검색 (8,401건 / 페이징)
  ├── detail.jsp                   자산 상세 + 이관이력 + 예약현황
  ├── reserve.jsp                  예약 (DB 저장 + 중복체크)
  ├── transfer.jsp                 이관내역 리스트 + 상세
  ├── professor.jsp                교수 자원 (과목/주특기 등록)
  ├── images/logo.png              ICT 로고
  ├── css/style.css                공통 스타일
  ├── WEB-INF/
  │   ├── web.xml                  서블릿 매핑
  │   ├── classes/com/campus/nav/  컴파일된 .class 파일
  │   └── src/com/campus/nav/
  │       ├── LoginServlet.java
  │       ├── LogoutServlet.java
  │       └── GuestServlet.java
  ├── campusnav_db.sql              ← STEP 1: DB/테이블 생성
  ├── campusnav_assets.sql          ← STEP 2: 자산 8,401건
  ├── campusnav_transfer_disposal.sql ← STEP 3: 이관+폐기
  └── campusnav_add.sql             ← STEP 4: 교수/과목/주특기


┌─────────────────────────────────────────────────────────────────┐
│  4. DB 설치 및 연동 순서                                         │
└─────────────────────────────────────────────────────────────────┘

  ─── DB 접속 정보 ─────────────────────────────────────────────

    HOST:     localhost:3306
    DB명:     campusnav
    아이디:   root
    비밀번호: 1234

  ─── SQL 실행 순서 (MySQL Workbench 새 탭에서 순서대로 실행) ──

  [STEP 1] campusnav_db.sql 열기 → 전체 실행 (번개 버튼)
           DB 생성, 테이블 8개 생성
           (users, assets, asset_transfer, asset_disposal,
            reservations, professors, prof_subjects, prof_skills)

  [STEP 2] campusnav_assets.sql 열기 → 전체 실행
           자산 8,401건 INSERT (1~3분 소요)

  [STEP 3] campusnav_transfer_disposal.sql 열기 → 전체 실행
           이관 140건 + 폐기 2,721건 INSERT

  [STEP 4] campusnav_add.sql 열기 → 전체 실행
           교수/과목/주특기 테이블 및 샘플 데이터

  !! 반드시 이 순서대로 실행 (외래키 오류 방지)

  ─── 데이터 확인 쿼리 ─────────────────────────────────────────

    USE campusnav;
    SELECT COUNT(*) FROM assets;          -- 8401 확인
    SELECT COUNT(*) FROM asset_transfer;  -- 140 확인
    SELECT COUNT(*) FROM asset_disposal;  -- 2721 확인
    SELECT * FROM users;                  -- 테스트 계정 확인

  ─── JDBC JAR 설치 ────────────────────────────────────────────

    mysql-connector-j-x.x.x.jar 파일을 Tomcat lib/ 폴더에 복사

    다운로드: https://mvnrepository.com/artifact/com.mysql/mysql-connector-j

    !! JAR 없으면 모든 페이지에서 DB 연결 오류 발생


┌─────────────────────────────────────────────────────────────────┐
│  5. 톰캣 배포 순서                                               │
└─────────────────────────────────────────────────────────────────┘

  [1단계] SQL 4개 파일 순서대로 실행 (4번 참고)

  [2단계] CampusNav 폴더를 webapps 아래에 복사

  [3단계] LoginServlet 컴파일 (6번 참고)
          !! 반드시 톰캣 중지 후 컴파일

  [4단계] 톰캣 재시작
          작업관리자 → 서비스 → Tomcat9 → 다시 시작

  [5단계] 브라우저 접속
          http://localhost:8080/CampusNav/campuslogin.jsp

  ─── JSP vs Servlet 수정 시 ──────────────────────────────────

  JSP 파일(.jsp) 수정    → 톰캣 재시작 없이 바로 반영
  Java 파일(.java) 수정  → 재컴파일 + 톰캣 재시작 필요


┌─────────────────────────────────────────────────────────────────┐
│  6. LoginServlet 컴파일 방법                                     │
└─────────────────────────────────────────────────────────────────┘

  ─── 준비 ─────────────────────────────────────────────────────

  1. 윈도우 검색 → cmd 우클릭 → "관리자 권한으로 실행"
  2. 작업관리자 → 서비스 → Tomcat9 → 중지 (필수!)

  ─── 컴파일 명령어 ────────────────────────────────────────────

  [교수님/학교 컴퓨터]

    cd /d "C:\Program Files\Apache Software Foundation\Tomcat 9.0"

javac -encoding UTF-8 -cp "lib\servlet-api.jar" -d "webapps\CampusNav\WEB-INF\classes" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LoginServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LogoutServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\GuestServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\VisitorServlet.java"

  에러 없이 종료되면 성공
  아래 파일 생성 확인:
    WEB-INF\classes\com\campus\nav\LoginServlet.class  ← 있어야 함
    WEB-INF\classes\com\campus\nav\LogoutServlet.class
    WEB-INF\classes\com\campus\nav\GuestServlet.class

  ─── 컴파일 후 ────────────────────────────────────────────────

  작업관리자 → 서비스 → Tomcat9 → 시작

  ─── 오류 해결 ────────────────────────────────────────────────

  "error while writing LoginServlet.class"
    → 톰캣 실행 중 → 반드시 중지 후 재시도

  "classes\com\campus\nav 폴더 없음"
    → 아래 명령어로 폴더 생성 후 재시도:
       mkdir "C:\...\webapps\CampusNav\WEB-INF\classes\com\campus\nav"

  ─── LoginServlet DB 연동 버전 핵심 코드 ─────────────────────

  (현재 LoginServlet은 하드코딩 배열 방식 → DB 버전으로 교체 필요)

    String DB_URL = "jdbc:mysql://localhost:3306/campusnav"
        + "?useSSL=false&serverTimezone=Asia/Seoul"
        + "&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";

    Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn = DriverManager.getConnection(DB_URL, "root", "1234");

    PreparedStatement ps = conn.prepareStatement(
        "SELECT user_pw, user_name, role FROM users WHERE user_id=?");
    ps.setString(1, userId);
    ResultSet rs = ps.executeQuery();

    if (rs.next() && rs.getString("user_pw").equals(userPw)) {
        // 로그인 성공 처리
        session.setAttribute("loginUser", userId);
        session.setAttribute("loginName", rs.getString("user_name"));
        session.setAttribute("loginRole", rs.getString("role"));
    }


┌─────────────────────────────────────────────────────────────────┐
│  7. 테스트 계정                                                  │
└─────────────────────────────────────────────────────────────────┘

  역할          아이디      비밀번호    접속 후 이동
  ──────────────────────────────────────────────────────────────
  학부생        student1    pass1234    main_student.jsp
  조교          assist1     asst1234    main_assistant.jsp
  교수          prof1       prof1234    main_professor.jsp
  운영 관리자   admin       1234        main_admin.jsp

  ─── DB에 직접 계정 추가 ──────────────────────────────────────

  USE campusnav;
  INSERT INTO users (user_id, user_pw, user_name, user_email, dept, role)
  VALUES ('아이디', '비밀번호', '이름', 'email@ict.ac.kr', '학과', 'student');

  role 값: student / assistant / professor / admin / guest


┌─────────────────────────────────────────────────────────────────┐
│  8. JSP 페이지별 기능 설명                                       │
└─────────────────────────────────────────────────────────────────┘

  campuslogin.jsp
    - 로그인, 역할 버튼 클릭 시 계정 자동 입력
    - 게스트 둘러보기, 회원가입 링크

  register.jsp
    - 회원가입 (DB 직접 저장, 서블릿 불필요)
    - 아이디 중복 체크, 비밀번호 확인

  main_student.jsp
    - 전체 자산 건수 DB 실시간 표시
    - 카테고리별 검색 바로가기

  main_admin.jsp
    - 전체 자산/이관/폐기/예약 DB 실시간 통계
    - 빠른 이동 버튼

  search.jsp
    - 자산 8,401건 검색 (키워드/분류/상태 필터)
    - 20건씩 페이지네이션
    - 행 클릭 → 상세 페이지

  detail.jsp
    - 자산 전체 정보 (DB 모든 컬럼)
    - 이관 이력 타임라인
    - 향후 예약 현황
    - 지도 자리 (GPS 연동 예정)

  reserve.jsp
    - 예약 신청 → DB 저장
    - 날짜/시간 선택 시 실시간 중복 체크
      → 중복: 빨간 경고 / 가능: 초록 확인
    - 기존 예약 현황 우측 표시

  transfer.jsp
    - 이관내역 50건 실시간 조회
    - 누가(출발부서) → 누구에게(도착부서) 화살표로 표시
    - 행 클릭 → 상세 패널 (출발/도착 flow box)
    - 지도 자리 포함

  professor.jsp
    - 교수 목록 카드 (과목/주특기 한눈에)
    - 과목 등록: 과목명/코드/학년/학기/강의실/시간
    - 주특기/연구분야 등록: 태그 방식으로 추가/삭제
    - 관리자만 교수 신규 등록 탭 표시


┌─────────────────────────────────────────────────────────────────┐
│  9. 확장 예정 기능                                               │
└─────────────────────────────────────────────────────────────────┘

  [지도 연동]
    → Google Maps API 키 발급 후 detail.jsp, transfer.jsp 연동
    → 학교 좌표: 위도 37.396681 / 경도 127.247918
    → 지도 자리(placeholder)는 이미 각 페이지에 포함됨

  [실내 GPS]
    → 1공학관, 2공학관 GPS 2개 설치 예정
    → assets 테이블의 latitude/longitude/floor 컬럼으로 연동
    → 설치 후 실내 위치 실시간 표시 가능

  [QR 코드 (앵그로우 앱)]
    → QR 스캔 → /CampusNav/detail.jsp?id=자산번호 이동
    → 자산별 QR 라벨 생성 필요

  [관리자 도착 알림]
    → 예약자 도착 시 관리자에게 메시지 알림
    → WebSocket 또는 DB 폴링 방식 구현 예정

  [LoginServlet DB 연동]
    → 현재 하드코딩 배열 방식
    → DB 조회 버전으로 재컴파일 필요 (6번 코드 참고)


┌─────────────────────────────────────────────────────────────────┐
│  10. 트러블슈팅                                                  │
└─────────────────────────────────────────────────────────────────┘

  Q. 로그인이 안 됩니다
  → 테스트 계정 사용: student1/pass1234, admin/1234
  → LoginServlet이 DB를 아직 안 봄 → 재컴파일 필요
  → 회원가입한 계정은 LoginServlet 재컴파일 전까지 로그인 불가

  Q. 404 오류
  → URL 확인: http://localhost:8080/CampusNav/campuslogin.jsp
  → 서블릿(login/logout/guest) 오류 시 재컴파일 후 재시작
  → forward 경로에 /CampusNav/ 붙어있는지 확인 (없어야 함)

  Q. DB 연결 오류
  → MySQL 실행 중인지 확인
  → Tomcat lib/에 mysql-connector-j.jar 있는지 확인
  → DB 이름 campusnav, 비밀번호 1234 확인

  Q. 자산 데이터가 안 보임
  → campusnav_assets.sql 실행 확인
  → SELECT COUNT(*) FROM assets; → 8401이어야 함

  Q. 회원가입 후 DB에 없음
  → register.jsp 최신 파일인지 확인
  → DB 연결 오류 여부 확인 (화면에 오류 메시지 표시됨)

  Q. 컴파일 오류 "error while writing .class"
  → 톰캣이 실행 중 → 반드시 중지 후 컴파일

  Q. 한글 깨짐
  → JSP pageEncoding="UTF-8" 확인
  → JDBC URL에 characterEncoding=UTF-8 포함 확인
  → Tomcat server.xml URIEncoding="UTF-8" 추가

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  ICT CampusNav v1.0
  ICT폴리텍대학 교내 자원 내비게이션 시스템
  문의: support@ict.ac.kr
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
