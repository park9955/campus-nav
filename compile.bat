@echo off
chcp 65001 > nul
echo.
echo =============================================
echo   CampusNav 컴파일 시작
echo =============================================
echo.

:: 톰캣 경로 자동 탐색
set TOMCAT_HOME=
for /d %%i in ("C:\Program Files\Apache Software Foundation\Tomcat 9*") do set TOMCAT_HOME=%%i
for /d %%i in ("C:\Program Files (x86)\Apache Software Foundation\Tomcat 9*") do set TOMCAT_HOME=%%i

if "%TOMCAT_HOME%"=="" (
    echo [오류] 톰캣 9.0 폴더를 찾을 수 없습니다.
    echo 아래 경로를 확인해 주세요:
    echo C:\Program Files\Apache Software Foundation\Tomcat 9.0
    pause
    exit /b 1
)

echo [확인] 톰캣 경로: %TOMCAT_HOME%
echo.

:: 현재 배치파일 위치 = CampusNav 폴더
set PROJECT_DIR=%~dp0
set PROJECT_DIR=%PROJECT_DIR:~0,-1%

echo [확인] 프로젝트 경로: %PROJECT_DIR%
echo.

:: servlet-api.jar 경로
set SERVLET_JAR=%TOMCAT_HOME%\lib\servlet-api.jar

if not exist "%SERVLET_JAR%" (
    echo [오류] servlet-api.jar 를 찾을 수 없습니다: %SERVLET_JAR%
    pause
    exit /b 1
)

:: classes 폴더 생성
if not exist "%PROJECT_DIR%\WEB-INF\classes\com\campus\nav" (
    mkdir "%PROJECT_DIR%\WEB-INF\classes\com\campus\nav"
    echo [생성] classes 폴더 생성 완료
)

:: 컴파일 실행
echo [컴파일] LoginServlet.java, LogoutServlet.java ...
echo.

javac -encoding UTF-8 ^
  -cp "%SERVLET_JAR%" ^
  -d "%PROJECT_DIR%\WEB-INF\classes" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\LoginServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\LogoutServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\GuestServlet.java"

if %errorlevel% neq 0 (
    echo.
    echo [실패] 컴파일 중 오류가 발생했습니다.
    echo Java 가 설치되어 있는지 확인해 주세요.
    pause
    exit /b 1
)

echo.
echo =============================================
echo   컴파일 완료!
echo =============================================
echo.
echo 다음 단계:
echo   1. 톰캣을 재시작 하세요
echo      작업관리자 - 서비스 - Tomcat9 - 다시시작
echo.
echo   2. 브라우저에서 접속하세요
echo      http://localhost:8080/CampusNav/campuslogin.jsp
echo.
pause
