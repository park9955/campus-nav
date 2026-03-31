package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;

public class DetailServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        if (req.getSession(false) == null ||
            req.getSession(false).getAttribute("loginUser") == null) {
            resp.sendRedirect("/CampusNav/campuslogin.jsp");
            return;
        }

        String assetNo = req.getParameter("id");
        if (assetNo == null || assetNo.trim().isEmpty()) {
            resp.sendRedirect("/CampusNav/search");
            return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBUtil.getConnection();

            // 자산 기본 정보
            ps = conn.prepareStatement("SELECT * FROM assets WHERE asset_no=?");
            ps.setString(1, assetNo);
            rs = ps.executeQuery();
            Map<String,String> asset = new LinkedHashMap<>();
            if (rs.next()) {
                java.sql.ResultSetMetaData meta = rs.getMetaData();
                for (int i=1; i<=meta.getColumnCount(); i++) {
                    String val = rs.getString(i);
                    asset.put(meta.getColumnName(i), val != null ? val : "");
                }
            }
            DBUtil.close(rs, ps);

            // 이관 이력
            ps = conn.prepareStatement(
                "SELECT * FROM asset_transfer WHERE asset_no=? ORDER BY transfer_date DESC");
            ps.setString(1, assetNo);
            rs = ps.executeQuery();
            List<Map<String,String>> transfers = new ArrayList<>();
            while (rs.next()) {
                Map<String,String> row = new LinkedHashMap<>();
                row.put("transfer_date",   nvl(rs.getString("transfer_date")));
                row.put("before_dept",     nvl(rs.getString("before_dept")));
                row.put("before_location", nvl(rs.getString("before_location")));
                row.put("after_dept",      nvl(rs.getString("after_dept")));
                row.put("after_location",  nvl(rs.getString("after_location")));
                row.put("remark",          nvl(rs.getString("remark")));
                transfers.add(row);
            }
            DBUtil.close(rs, ps);

            // 예약 현황 (해당 자산의 예약 목록)
            ps = conn.prepareStatement(
                "SELECT r.reserve_date, r.start_time, r.end_time, r.purpose, u.user_name "
              + "FROM reservations r JOIN users u ON r.user_id=u.user_id "
              + "WHERE r.asset_no=? AND r.reserve_date >= CURDATE() "
              + "AND r.status='예약완료' ORDER BY r.reserve_date, r.start_time");
            ps.setString(1, assetNo);
            rs = ps.executeQuery();
            List<Map<String,String>> reserves = new ArrayList<>();
            while (rs.next()) {
                Map<String,String> row = new LinkedHashMap<>();
                row.put("reserve_date", nvl(rs.getString("reserve_date")));
                row.put("start_time",   nvl(rs.getString("start_time")));
                row.put("end_time",     nvl(rs.getString("end_time")));
                row.put("purpose",      nvl(rs.getString("purpose")));
                row.put("user_name",    nvl(rs.getString("user_name")));
                reserves.add(row);
            }

            req.setAttribute("asset",     asset);
            req.setAttribute("transfers", transfers);
            req.setAttribute("reserves",  reserves);

        } catch (Exception e) {
            System.err.println("상세조회 DB 오류: " + e.getMessage());
            req.setAttribute("asset", new LinkedHashMap<>());
            req.setAttribute("transfers", new ArrayList<>());
            req.setAttribute("reserves",  new ArrayList<>());
        } finally {
            DBUtil.close(rs, ps, conn);
        }

        req.getRequestDispatcher("/detail.jsp").forward(req, resp);
    }

    private String nvl(String s) { return s == null ? "" : s; }
}
