<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String role = (String) session.getAttribute("loginRole");
    String user = (String) session.getAttribute("loginUser");
    if (!"admin".equals(role) || user == null) { out.print("FORBIDDEN"); return; }

    String entranceId = request.getParameter("entranceId");
    String pixelX     = request.getParameter("pixelX");
    String pixelY     = request.getParameter("pixelY");

    if (entranceId == null || pixelX == null || pixelY == null) { out.print("INVALID_PARAM"); return; }

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root", "1234"
        );
        java.sql.PreparedStatement ps = conn.prepareStatement(
            "UPDATE campus_entrances SET pixel_x=?, pixel_y=? WHERE entrance_id=?"
        );
        ps.setFloat(1, Float.parseFloat(pixelX));
        ps.setFloat(2, Float.parseFloat(pixelY));
        ps.setInt(3, Integer.parseInt(entranceId));
        ps.executeUpdate();
        ps.close(); conn.close();
        out.print("OK");
    } catch (Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
