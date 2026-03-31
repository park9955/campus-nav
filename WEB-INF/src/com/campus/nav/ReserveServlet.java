package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;

public class ReserveServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            resp.sendRedirect("/CampusNav/campuslogin.jsp");
            return;
        }

        String userId    = (String) session.getAttribute("loginUser");
        String assetNo   = req.getParameter("resourceId");
        String date      = req.getParameter("date");
        String startTime = req.getParameter("startTime");
        String endTime   = req.getParameter("endTime");
        String purpose   = req.getParameter("purpose");
        String phone     = req.getParameter("phone");
        String note      = req.getParameter("note");

        if (assetNo==null||date==null||startTime==null||endTime==null) {
            req.setAttribute("errorMsg", "필수 항목을 입력해 주세요.");
            req.getRequestDispatcher("/reserve.jsp").forward(req, resp);
            return;
        }

        String sql = "INSERT INTO reservations "
                   + "(asset_no,user_id,reserve_date,start_time,end_time,purpose,phone,note,status) "
                   + "VALUES (?,?,?,?,?,?,?,?,'예약완료')";

        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, assetNo);
            ps.setString(2, userId);
            ps.setString(3, date);
            ps.setString(4, startTime);
            ps.setString(5, endTime);
            ps.setString(6, purpose);
            ps.setString(7, phone);
            ps.setString(8, note);
            ps.executeUpdate();
            resp.sendRedirect("/CampusNav/reserve.jsp?id=" + assetNo + "&success=true");
        } catch (Exception e) {
            System.err.println("예약 DB 오류: " + e.getMessage());
            req.setAttribute("errorMsg", "예약 처리 중 오류가 발생했습니다.");
            req.getRequestDispatcher("/reserve.jsp").forward(req, resp);
        } finally {
            DBUtil.close(ps, conn);
        }
    }
}
