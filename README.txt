=============================================
  ICT CampusNav 교내 자원 내비게이션 시스템
  프로토타입 최종본
=============================================


[ 사전 준비 ]

  아래 2가지가 설치되어 있어야 합니다.

  1. Apache Tomcat 9.x
  2. JDK 21 이상 (Java Development Kit)
     다운로드: https://www.oracle.com/java/technologies/downloads/
               Java 21 - Windows - x64 설치 관리자 (.exe)


=============================================
  교수님 컴퓨터 / 학교 컴퓨터 설치 방법
  (경로: Apache Software Foundation\Tomcat 9.0)
=============================================

  ─────────────────────────────────────
  1단계. CampusNav 폴더 복사
  ─────────────────────────────────────

  CampusNav_folder 폴더 이름을 CampusNav 로 변경 후
  아래 경로에 복사하세요:

    C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\CampusNav\

  주의: ROOT 폴더 안이 아닌 webapps 바로 아래에 넣어야 합니다!

  올바른 구조:
    webapps\
      CampusNav\        <- 여기!
        campuslogin.jsp
        WEB-INF\
          web.xml       <- 반드시 포함 확인!
          classes\
          src\


  ─────────────────────────────────────
  2단계. 컴파일 (cmd 관리자 권한으로 실행)
  ─────────────────────────────────────

  시작 버튼 -> cmd 검색 -> 우클릭 -> 관리자 권한으로 실행

  [1] classes 폴더 생성
  mkdir "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\CampusNav\WEB-INF\classes\com\campus\nav"

  [2] 톰캣 폴더로 이동
  cd /d "C:\Program Files\Apache Software Foundation\Tomcat 9.0"

  [3] 컴파일 실행
  javac -encoding UTF-8 -cp "lib\servlet-api.jar" -d "webapps\CampusNav\WEB-INF\classes" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LoginServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LogoutServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\GuestServlet.java"

  아무 메시지 없이 끝나면 컴파일 성공!

  [4] 컴파일 확인
  dir "webapps\CampusNav\WEB-INF\classes\com\campus\nav"

  LoginServlet.class / LogoutServlet.class / GuestServlet.class
  위 3개 파일이 보이면 성공!

  [5] 톰캣 재시작
  작업관리자 -> 서비스 탭 -> Tomcat9 -> 우클릭 -> 다시 시작

  [6] 브라우저 접속
  http://localhost:8080/CampusNav/campuslogin.jsp


=============================================
  내 컴퓨터 설치 방법
  (경로: apache-tomcat-9.0.115)
=============================================

  ─────────────────────────────────────
  1단계. CampusNav 폴더 복사
  ─────────────────────────────────────

    C:\Program Files\apache-tomcat-9.0.115\webapps\CampusNav\


  ─────────────────────────────────────
  2단계. 컴파일 (cmd 관리자 권한으로 실행)
  ─────────────────────────────────────

  [1] classes 폴더 생성
  mkdir "C:\Program Files\apache-tomcat-9.0.115\webapps\CampusNav\WEB-INF\classes\com\campus\nav"

  [2] 톰캣 폴더로 이동
  cd /d "C:\Program Files\apache-tomcat-9.0.115"

  [3] 컴파일 실행
  javac -encoding UTF-8 -cp "lib\servlet-api.jar" -d "webapps\CampusNav\WEB-INF\classes" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LoginServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\LogoutServlet.java" "webapps\CampusNav\WEB-INF\src\com\campus\nav\GuestServlet.java"

  [4] 톰캣 재시작
  작업관리자 -> 서비스 탭 -> Tomcat9 -> 우클릭 -> 다시 시작

  [5] 브라우저 접속
  http://localhost:8080/CampusNav/campuslogin.jsp


=============================================
  공통 정보
=============================================

[ 테스트 계정 ]

  역할              아이디       비밀번호
  ─────────────────────────────────────
  학부생            student1     pass1234
  조교              assist1      asst1234
  교수              prof1        prof1234
  대학 운영 관리자   admin        1234

  로그인 없이 둘러보기(게스트) 버튼으로 바로 입장 가능


[ 역할별 기능 ]

  학부생
    - 자원 검색 / 상세보기 / 예약

  조교
    - 자원 검색 / 상세보기
    - 자원 등록 (하드웨어 스펙 포함)
    - 자원 수정

  교수
    - 자원 검색 / 상세보기
    - PC별 SW 현황 (어떤 PC에 무엇이 설치됐는지 확인)
    - 소프트웨어 등록
    - 소프트웨어 수정
    - 소프트웨어 삭제

  대학 운영 관리자
    - 자원 검색 / 상세보기
    - 내용연수 등록
    - 이관 내역 등록/조회
    - 전체 자원 현황 통계

  게스트 (로그인 없음)
    - 자원 검색 / 상세보기만 가능


[ 핸드폰 접속 방법 (같은 와이파이) ]

  1. cmd -> ipconfig -> 무선 LAN 어댑터 Wi-Fi -> IPv4 주소 확인
     예) 192.168.0.10

  2. 핸드폰 브라우저 접속
     http://192.168.0.10:8080/CampusNav/campuslogin.jsp


[ 파일 구조 ]

  CampusNav\
  ├── campuslogin.jsp       <- 로그인 (시작 페이지)
  ├── register.jsp          <- 회원가입
  ├── main_student.jsp      <- 학부생 홈
  ├── main_assistant.jsp    <- 조교 홈
  ├── main_professor.jsp    <- 교수 홈
  ├── main_admin.jsp        <- 운영관리자 홈
  ├── main_guest.jsp        <- 게스트 홈
  ├── search.jsp            <- 자원 검색
  ├── detail.jsp            <- 자원 상세보기
  ├── reserve.jsp           <- 예약
  └── WEB-INF\
      ├── web.xml           <- 반드시 포함!
      ├── classes\          <- 컴파일 후 생성됨
      └── src\com\campus\nav\
          ├── LoginServlet.java
          ├── LogoutServlet.java
          └── GuestServlet.java


[ 주의사항 ]

  - 현재 프로토타입으로 DB 연동이 되어 있지 않습니다.
  - 모든 데이터는 샘플 데이터입니다.
  - Tomcat 9.x 기반 (javax.servlet 사용)
  - JSP 파일 수정 시 톰캣 재시작 불필요
  - Java 파일 수정 시 재컴파일 + 톰캣 재시작 필요
  - cmd 는 반드시 관리자 권한으로 실행


[ 향후 추가 예정 ]

  - MySQL DB 연동 (실제 데이터 저장)
  - 구글맵 API 연동 (위치 지도 표시)
    학교 위치: 경기도 광주시 순암로 16-26
    위도: 37.396681 / 경도: 127.247918

=============================================
