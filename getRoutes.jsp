<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    if (loginUser==null) { out.print("[]"); return; }

    String fromId   = request.getParameter("fromId");
    String toId     = request.getParameter("toId");
    String routeId  = request.getParameter("routeId");
    String latest   = request.getParameter("latest");

    StringBuilder json = new StringBuilder();

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );

        if (routeId!=null && !routeId.trim().isEmpty()) {
            /* ── 단건 조회 (미리보기) ── */
            java.sql.PreparedStatement ps = conn.prepareStatement(
                "SELECT route_id, route_name, points_json FROM campus_routes WHERE route_id=? AND is_active=1"
            );
            ps.setInt(1, Integer.parseInt(routeId.trim()));
            java.sql.ResultSet rs = ps.executeQuery();
            if (rs.next()) {
                String nm=rs.getString("route_name"); if(nm==null)nm="";
                String pts=rs.getString("points_json"); if(pts==null)pts="[]";
                json.append("{\"route_id\":").append(rs.getString("route_id"))
                    .append(",\"route_name\":\"").append(escJ(nm)).append("\"")
                    .append(",\"points\":").append(pts).append("}");
            } else json.append("{}");
            rs.close(); ps.close();

        } else if (fromId!=null && !fromId.trim().isEmpty() && toId!=null && !toId.trim().isEmpty()) {

            if ("1".equals(latest)) {
                /* ── 최신 1개 (학생용) ── */
                java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT route_id, route_name, points_json FROM campus_routes " +
                    "WHERE from_entrance_id=? AND to_entrance_id=? AND is_active=1 " +
                    "ORDER BY created_at DESC LIMIT 1"
                );
                ps.setInt(1, Integer.parseInt(fromId.trim()));
                ps.setInt(2, Integer.parseInt(toId.trim()));
                java.sql.ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    String nm=rs.getString("route_name"); if(nm==null)nm="";
                    String pts=rs.getString("points_json"); if(pts==null)pts="[]";
                    json.append("{\"route_id\":").append(rs.getString("route_id"))
                        .append(",\"route_name\":\"").append(escJ(nm)).append("\"")
                        .append(",\"points\":").append(pts).append("}");
                } else json.append("{}");
                rs.close(); ps.close();

            } else {
                /* ── 목록 조회 (관리자용) ── */
                java.sql.PreparedStatement ps = conn.prepareStatement(
                    "SELECT route_id, route_name, created_at, JSON_LENGTH(points_json) AS point_count " +
                    "FROM campus_routes WHERE from_entrance_id=? AND to_entrance_id=? AND is_active=1 " +
                    "ORDER BY created_at DESC"
                );
                ps.setInt(1, Integer.parseInt(fromId.trim()));
                ps.setInt(2, Integer.parseInt(toId.trim()));
                java.sql.ResultSet rs = ps.executeQuery();
                json.append("[");
                boolean first=true;
                while (rs.next()) {
                    if(!first) json.append(","); first=false;
                    String nm=rs.getString("route_name"); if(nm==null)nm="";
                    String cat=rs.getString("created_at"); if(cat==null)cat="";
                    json.append("{\"route_id\":").append(rs.getString("route_id"))
                        .append(",\"route_name\":\"").append(escJ(nm)).append("\"")
                        .append(",\"created_at\":\"").append(escJ(cat)).append("\"")
                        .append(",\"point_count\":").append(rs.getInt("point_count")).append("}");
                }
                json.append("]");
                rs.close(); ps.close();
            }
        } else {
            json.append("[]");
        }
        conn.close();
    } catch(Exception e) {
        json = new StringBuilder("{\"error\":\""+e.getMessage().replace("\"","'")+"\"}");
    }
    out.print(json.toString());
%>
<%!
    private String escJ(String s){
        if(s==null)return"";
        return s.replace("\\","\\\\").replace("\"","\\\"").replace("\n","\\n").replace("\r","\\r");
    }
%>
