@echo off
chcp 65001 > nul
echo.
echo =============================================
echo   ICT CAN 컴파일 시작
echo   경로: Tomcat 9.0\webapps\ROOT\CAN
echo =============================================
echo.

set TOMCAT_HOME=
for /d %%i in ("C:\Program Files\Apache Software Foundation\Tomcat 9*") do set TOMCAT_HOME=%%i
for /d %%i in ("C:\Program Files (x86)\Apache Software Foundation\Tomcat 9*") do set TOMCAT_HOME=%%i

if "%TOMCAT_HOME%"=="" (
    echo [오류] 톰캣 9.0 폴더를 찾을 수 없습니다.
    pause
    exit /b 1
)
echo [확인] 톰캣 경로: %TOMCAT_HOME%

set PROJECT_DIR=%TOMCAT_HOME%\webapps\ROOT\CAN
set SERVLET_JAR=%TOMCAT_HOME%\lib\servlet-api.jar

if not exist "%PROJECT_DIR%" (
    echo [오류] CAN 폴더가 없습니다: %PROJECT_DIR%
    echo Tomcat\webapps\ROOT\ 아래에 CAN 폴더를 놓아주세요.
    pause
    exit /b 1
)

if not exist "%PROJECT_DIR%\WEB-INF\classes\com\campus\nav" (
    mkdir "%PROJECT_DIR%\WEB-INF\classes\com\campus\nav"
)

echo [컴파일 시작]
echo.

javac -encoding UTF-8 -cp "%SERVLET_JAR%" -d "%PROJECT_DIR%\WEB-INF\classes" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\DBUtil.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\LoginServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\LogoutServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\GuestServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\VisitorServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\RegisterServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\AssetServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\DetailServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\ReserveServlet.java" ^
  "%PROJECT_DIR%\WEB-INF\src\com\campus\nav\SearchServlet.java"

if %errorlevel% neq 0 (
    echo.
    echo [실패] 컴파일 오류 발생!
    pause
    exit /b 1
)

echo.
echo =============================================
echo   컴파일 완료!
echo =============================================
echo.
echo   접속 URL: http://localhost:8080/CAN/campuslogin.jsp
echo.
echo   톰캣 재시작 후 접속하세요.
echo   (작업관리자 - 서비스 - Tomcat9 - 다시시작)
echo.
pause
