<%@ page import="java.sql.*" %>
<%!
    public Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";
        String user = "root";
        String password = "1234";
        return DriverManager.getConnection(url, user, password);
    }

    public void close(AutoCloseable... objs) {
        for (AutoCloseable obj : objs) {
            if (obj != null) {
                try { obj.close(); } catch(Exception e) {}
            }
        }
    }
%>
