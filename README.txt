[Tomcat 9.0 Servlet 수동 컴파일 방법]

1.  CMD 실행

2.  src 폴더로 이동 
cd "C:\Program Files\Apache Software Foundation\Tomcat 9.0\webapps\CAN\WEB-INF\src"

3.  classes 폴더 생성 (처음 한 번만) 
mkdir ..\classes

4.  전체 Java 파일 컴파일 
javac -encoding UTF-8 ^
-cp "C:\Program Files\Apache Software Foundation\Tomcat 9.0\lib\servlet-api.jar" ^
-d "..\classes" ^
com\campus\nav\*.java
