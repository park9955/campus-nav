<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String role = (String) session.getAttribute("loginRole");
    String user = (String) session.getAttribute("loginUser");
    if (!"admin".equals(role) || user == null) { out.print("FORBIDDEN"); return; }

    String routeId = request.getParameter("routeId");
    if (routeId==null||routeId.trim().isEmpty()) { out.print("INVALID_PARAM"); return; }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );
        java.sql.PreparedStatement ps = conn.prepareStatement(
            "UPDATE floor_routes SET is_active=0 WHERE route_id=?"
        );
        ps.setInt(1, Integer.parseInt(routeId.trim()));
        ps.executeUpdate();
        ps.close(); conn.close();
        out.print("OK");
    } catch(Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
