<%@ page language="java" contentType="application/json; charset=UTF-8" pageEncoding="UTF-8" import="java.sql.*,java.util.*" %><%
    String keyword = request.getParameter("keyword");
    if(keyword == null) keyword = "";
    keyword = keyword.trim();

    StringBuilder json = new StringBuilder("[");
    int count = 0;

    if(keyword.length() > 0) {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(
                "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");

            String sql = "SELECT asset_no, item_name, detail_location, asset_status FROM assets WHERE (item_name LIKE ? OR asset_no LIKE ?) AND asset_status != '폐기' ORDER BY item_name LIMIT 50";
            PreparedStatement ps = conn.prepareStatement(sql);
            ps.setString(1, "%" + keyword + "%");
            ps.setString(2, "%" + keyword + "%");

            ResultSet rs = ps.executeQuery();
            while(rs.next()) {
                if(count > 0) json.append(",");
                String assetNo = rs.getString("asset_no");
                String itemName = rs.getString("item_name");
                String location = rs.getString("detail_location");
                String status = rs.getString("asset_status");

                json.append("{");
                json.append("\"assetNo\":\"").append(assetNo != null ? assetNo.replace("\"", "\\\"") : "").append("\",");
                json.append("\"itemName\":\"").append(itemName != null ? itemName.replace("\"", "\\\"") : "").append("\",");
                json.append("\"location\":\"").append(location != null ? location.replace("\"", "\\\"") : "").append("\",");
                json.append("\"status\":\"").append(status != null ? status : "").append("\"");
                json.append("}");
                count++;
            }
            rs.close();
            ps.close();
            conn.close();
        } catch(Exception e) {
            json.append("{\"error\":\"").append(e.getMessage().replace("\"", "\\\"")).append("\"}");
        }
    }

    json.append("]");
    out.print(json.toString());
%>
