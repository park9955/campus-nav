<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String role = (String) session.getAttribute("loginRole");
    String user = (String) session.getAttribute("loginUser");
    if (!"admin".equals(role) || user == null) { out.print("FORBIDDEN"); return; }

    String fromId    = request.getParameter("fromEntranceId");
    String toId      = request.getParameter("toEntranceId");
    String routeName = request.getParameter("routeName");
    String points    = request.getParameter("points");

    if (fromId==null||fromId.trim().isEmpty()||toId==null||toId.trim().isEmpty()||
        points==null||points.trim().isEmpty()) { out.print("INVALID_PARAM"); return; }
    if (routeName==null) routeName="";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );
        java.sql.PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO campus_routes (entrance_id, from_entrance_id, to_entrance_id, route_name, points_json, created_by) " +
            "VALUES (?,?,?,?,?,?)"
        );
        ps.setInt(1, Integer.parseInt(toId.trim()));
        ps.setInt(2, Integer.parseInt(fromId.trim()));
        ps.setInt(3, Integer.parseInt(toId.trim()));
        ps.setString(4, routeName);
        ps.setString(5, points);
        ps.setString(6, user);
        ps.executeUpdate();
        ps.close(); conn.close();
        out.print("OK");
    } catch(Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
