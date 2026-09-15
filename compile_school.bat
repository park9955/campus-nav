@echo off
echo ========================================
echo  CAN Servlet Compiler
echo ========================================
echo.

set TOMCAT=C:\Program Files\Apache Software Foundation\Tomcat 9.0
set SRC=%TOMCAT%\webapps\CAN\WEB-INF\src\com\campus\nav
set OUT=%TOMCAT%\webapps\CAN\WEB-INF\classes
set CP=%TOMCAT%\lib\servlet-api.jar;%TOMCAT%\lib\mysql-connector-j-9.3.0.jar

echo Compiling...
javac -encoding UTF-8 -cp "%CP%" -d "%OUT%" "%SRC%\DBUtil.java" "%SRC%\LoginServlet.java" "%SRC%\LogoutServlet.java" "%SRC%\GuestServlet.java" "%SRC%\VisitorServlet.java"

echo.
if %errorlevel%==0 (
    echo [SUCCESS] Compile complete! Please restart Tomcat.
) else (
    echo [FAILED] Check error above.
)
echo.
pause
