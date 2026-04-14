<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String role = (String) session.getAttribute("loginRole");
    String user = (String) session.getAttribute("loginUser");
    if (!"admin".equals(role) || user == null) { out.print("FORBIDDEN"); return; }

    String building    = request.getParameter("building");
    String destRoom    = request.getParameter("destRoom");
    String floor       = request.getParameter("floor");
    String routeName   = request.getParameter("routeName");
    String floorImg    = request.getParameter("floorplanImg");
    String points      = request.getParameter("points");
    String roomId      = request.getParameter("roomId");

    if (building==null||building.trim().isEmpty()||destRoom==null||destRoom.trim().isEmpty()||
        points==null||points.trim().isEmpty()) { out.print("INVALID_PARAM"); return; }
    if (routeName==null) routeName="";
    if (floor==null)     floor="";
    if (floorImg==null)  floorImg="";
    if (roomId==null)    roomId="";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );
        java.sql.PreparedStatement ps = conn.prepareStatement(
            "INSERT INTO floor_routes (building, floor, dest_room, route_name, points_json, floorplan_img, room_id, created_by) " +
            "VALUES (?,?,?,?,?,?,?,?)"
        );
        ps.setString(1, building);
        ps.setString(2, floor);
        ps.setString(3, destRoom);
        ps.setString(4, routeName);
        ps.setString(5, points);
        ps.setString(6, floorImg);
        if (!roomId.isEmpty() && !roomId.equals("0")) ps.setInt(7, Integer.parseInt(roomId));
        else ps.setNull(7, java.sql.Types.INTEGER);
        ps.setString(8, user);
        ps.executeUpdate();
        ps.close(); conn.close();
        out.print("OK");
    } catch(Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
