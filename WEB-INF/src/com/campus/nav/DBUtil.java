package com.campus.nav;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

public class DBUtil {

    private static final String DRIVER = "com.mysql.cj.jdbc.Driver";
    private static final String URL    = "jdbc:mysql://localhost:3306/campusnav"
                                       + "?useSSL=false"
                                       + "&serverTimezone=Asia/Seoul"
                                       + "&characterEncoding=UTF-8"
                                       + "&allowPublicKeyRetrieval=true";
    private static final String USER   = "root";
    private static final String PASS   = "1234";

    static {
        try {
            Class.forName(DRIVER);
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL 드라이버 로딩 실패: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        return DriverManager.getConnection(URL, USER, PASS);
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable r : resources) {
            if (r != null) {
                try { r.close(); } catch (Exception e) { /* ignore */ }
            }
        }
    }
}
