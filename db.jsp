<%@ page import="java.sql.*" %>
<%!
    public Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/school_cart?serverTimezone=Asia/Seoul&characterEncoding=UTF-8";
        String user = "root";
        String password = "1234";   // 자신의 MySQL 비밀번호로 변경
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
