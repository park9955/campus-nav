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
import java.util.List;
import java.util.LinkedHashMap;
import java.util.Map;

public class SearchServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 로그인 체크
        if (req.getSession(false) == null ||
            req.getSession(false).getAttribute("loginUser") == null) {
            resp.sendRedirect("/CampusNav/campuslogin.jsp");
            return;
        }

        String keyword  = nvl(req.getParameter("keyword"));
        String type     = nvl(req.getParameter("type"));
        String status   = nvl(req.getParameter("status"));
        String location = nvl(req.getParameter("location"));
        String sort     = nvl(req.getParameter("sort"), "latest");
        int page        = toInt(req.getParameter("page"), 1);
        int pageSize    = 20;

        // SQL 조합
        StringBuilder sql = new StringBuilder(
            "SELECT asset_no, asset_class, item_name, spec, manufacturer, model, "
          + "acq_date, acq_price, residual_value, useful_life, quantity, "
          + "location, detail_location, latitude, longitude, floor, room_no, "
          + "manage_dept, manager_name, asset_status, remark "
          + "FROM assets WHERE 1=1 "
        );
        List<String> params = new ArrayList<>();

        if (!keyword.isEmpty()) {
            sql.append("AND (item_name LIKE ? OR asset_no LIKE ? OR detail_location LIKE ? OR manage_dept LIKE ? OR model LIKE ?) ");
            for (int i=0; i<5; i++) params.add("%" + keyword + "%");
        }
        if (!type.isEmpty()) {
            sql.append("AND asset_class = ? ");
            params.add(type);
        }
        if (!status.isEmpty()) {
            sql.append("AND asset_status LIKE ? ");
            params.add("%" + status + "%");
        }
        if (!location.isEmpty()) {
            sql.append("AND location LIKE ? ");
            params.add("%" + location + "%");
        }

        // 정렬
        if ("name".equals(sort))      sql.append("ORDER BY item_name ASC ");
        else if ("loc".equals(sort))  sql.append("ORDER BY location ASC ");
        else if ("avail".equals(sort)) sql.append("ORDER BY asset_status ASC ");
        else                           sql.append("ORDER BY reg_date DESC ");

        // 전체 건수
        String countSql = "SELECT COUNT(*) FROM assets WHERE 1=1 "
                        + sql.toString().substring(sql.toString().indexOf("WHERE 1=1") + 9,
                          sql.toString().indexOf("ORDER BY"));

        int totalCount = 0;
        List<Map<String,String>> list = new ArrayList<>();

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();

            // 건수 조회
            ps = conn.prepareStatement(countSql);
            for (int i=0; i<params.size(); i++) ps.setString(i+1, params.get(i));
            rs = ps.executeQuery();
            if (rs.next()) totalCount = rs.getInt(1);
            DBUtil.close(rs, ps);

            // 페이징
            sql.append("LIMIT ? OFFSET ?");
            ps = conn.prepareStatement(sql.toString());
            for (int i=0; i<params.size(); i++) ps.setString(i+1, params.get(i));
            ps.setInt(params.size()+1, pageSize);
            ps.setInt(params.size()+2, (page-1)*pageSize);
            rs = ps.executeQuery();

            while (rs.next()) {
                Map<String,String> row = new LinkedHashMap<>();
                row.put("asset_no",       nvl(rs.getString("asset_no")));
                row.put("asset_class",    nvl(rs.getString("asset_class")));
                row.put("item_name",      nvl(rs.getString("item_name")));
                row.put("spec",           nvl(rs.getString("spec")));
                row.put("manufacturer",   nvl(rs.getString("manufacturer")));
                row.put("model",          nvl(rs.getString("model")));
                row.put("acq_date",       nvl(rs.getString("acq_date")));
                row.put("acq_price",      nvl(rs.getString("acq_price")));
                row.put("residual_value", nvl(rs.getString("residual_value")));
                row.put("useful_life",    nvl(rs.getString("useful_life")));
                row.put("quantity",       nvl(rs.getString("quantity")));
                row.put("location",       nvl(rs.getString("location")));
                row.put("detail_location",nvl(rs.getString("detail_location")));
                row.put("latitude",       nvl(rs.getString("latitude")));
                row.put("longitude",      nvl(rs.getString("longitude")));
                row.put("floor",          nvl(rs.getString("floor")));
                row.put("room_no",        nvl(rs.getString("room_no")));
                row.put("manage_dept",    nvl(rs.getString("manage_dept")));
                row.put("manager_name",   nvl(rs.getString("manager_name")));
                row.put("asset_status",   nvl(rs.getString("asset_status")));
                row.put("remark",         nvl(rs.getString("remark")));
                list.add(row);
            }
        } catch (Exception e) {
            System.err.println("검색 DB 오류: " + e.getMessage());
        } finally {
            DBUtil.close(rs, ps, conn);
        }

        req.setAttribute("assetList",  list);
        req.setAttribute("totalCount", totalCount);
        req.setAttribute("page",       page);
        req.setAttribute("pageSize",   pageSize);
        req.setAttribute("totalPage",  (int)Math.ceil((double)totalCount/pageSize));
        req.setAttribute("keyword",    keyword);
        req.setAttribute("type",       type);
        req.setAttribute("status",     status);
        req.setAttribute("location",   location);
        req.setAttribute("sort",       sort);
        req.getRequestDispatcher("/search.jsp").forward(req, resp);
    }

    private String nvl(String s) { return s == null ? "" : s.trim(); }
    private String nvl(String s, String def) { return (s==null||s.trim().isEmpty()) ? def : s.trim(); }
    private int toInt(String s, int def) {
        try { return Integer.parseInt(s); } catch(Exception e) { return def; }
    }
}
