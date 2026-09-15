<%@ page language="java" contentType="text/plain; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String role = (String) session.getAttribute("loginRole");
    String user = (String) session.getAttribute("loginUser");
    if (!"admin".equals(role) || user == null) { out.print("FORBIDDEN"); return; }

    String roomId = request.getParameter("roomId");
    String pixelX = request.getParameter("pixelX");
    String pixelY = request.getParameter("pixelY");
    String pinDim   = request.getParameter("pinDim");
    String pinFloor = request.getParameter("pinFloor");

    if (roomId == null || pixelX == null || pixelY == null) { out.print("INVALID_PARAM"); return; }
    if (pinDim   == null) pinDim   = "3D";
    if (pinFloor == null) pinFloor = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root", "1234"
        );

        int n = 0;
        /* roomId가 숫자면 room_id 기준, 아니면 room_no 기준으로 UPDATE */
        boolean isNumeric = roomId.matches("\\d+");
        if (isNumeric) {
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "UPDATE rooms SET pixel_x=?, pixel_y=?, pin_dim=?, pin_floor=? WHERE room_id=?"
            );
            ps.setFloat(1, Float.parseFloat(pixelX));
            ps.setFloat(2, Float.parseFloat(pixelY));
            ps.setString(3, pinDim);
            ps.setString(4, pinFloor);
            ps.setInt(5, Integer.parseInt(roomId));
            n = ps.executeUpdate();
            ps.close();
        } else {
            /* room_no 기준 (호실번호 폴백 케이스) */
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "UPDATE rooms SET pixel_x=?, pixel_y=?, pin_dim=?, pin_floor=? WHERE room_no=?"
            );
            ps.setFloat(1, Float.parseFloat(pixelX));
            ps.setFloat(2, Float.parseFloat(pixelY));
            ps.setString(3, pinDim);
            ps.setString(4, pinFloor);
            ps.setString(5, roomId);
            n = ps.executeUpdate();
            ps.close();
        }
        conn.close();
        out.print(n > 0 ? "OK" : "NOT_FOUND");
    } catch (Exception e) {
        out.print("ERROR: " + e.getMessage());
    }
%>
