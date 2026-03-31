package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class AssetServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("loginUser") == null) {
            resp.sendRedirect("/CampusNav/campuslogin.jsp");
            return;
        }

        String action = req.getParameter("action"); // insert / update / delete
        String role   = (String) session.getAttribute("loginRole");

        // 권한 체크 (학부생/게스트는 불가)
        if ("student".equals(role) || "guest".equals(role)) {
            resp.sendRedirect("/CampusNav/main_student.jsp");
            return;
        }

        if      ("insert".equals(action)) doInsert(req, resp, role);
        else if ("update".equals(action)) doUpdate(req, resp);
        else if ("delete".equals(action)) doDelete(req, resp, role);
        else resp.sendRedirect("/CampusNav/main_" + role + ".jsp");
    }

    /** 자산 등록 */
    private void doInsert(HttpServletRequest req, HttpServletResponse resp, String role)
            throws IOException, ServletException {
        String sql = "INSERT INTO assets "
                   + "(asset_no,asset_class,item_name,spec,manufacturer,model,"
                   + "acq_date,acq_price,useful_life,quantity,"
                   + "location,detail_location,latitude,longitude,floor,room_no,"
                   + "manage_dept,manager_name,asset_status,remark) "
                   + "VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1,  req.getParameter("assetNo"));
            ps.setString(2,  req.getParameter("assetClass"));
            ps.setString(3,  req.getParameter("itemName"));
            ps.setString(4,  req.getParameter("spec"));
            ps.setString(5,  req.getParameter("manufacturer"));
            ps.setString(6,  req.getParameter("model"));
            ps.setString(7,  req.getParameter("acqDate"));
            ps.setString(8,  req.getParameter("acqPrice"));
            ps.setString(9,  req.getParameter("usefulLife"));
            ps.setString(10, req.getParameter("quantity"));
            ps.setString(11, req.getParameter("location"));
            ps.setString(12, req.getParameter("detailLocation"));
            ps.setString(13, req.getParameter("latitude"));
            ps.setString(14, req.getParameter("longitude"));
            ps.setString(15, req.getParameter("floor"));
            ps.setString(16, req.getParameter("roomNo"));
            ps.setString(17, req.getParameter("manageDept"));
            ps.setString(18, req.getParameter("managerName"));
            ps.setString(19, req.getParameter("assetStatus"));
            ps.setString(20, req.getParameter("remark"));
            ps.executeUpdate();
            resp.sendRedirect("/CampusNav/main_" + role + ".jsp?msg=등록완료");
        } catch (Exception e) {
            System.err.println("자산등록 오류: " + e.getMessage());
            req.setAttribute("errorMsg", "등록 중 오류: " + e.getMessage());
            req.getRequestDispatcher("/main_" + role + ".jsp").forward(req, resp);
        } finally {
            DBUtil.close(ps, conn);
        }
    }

    /** 자산 수정 */
    private void doUpdate(HttpServletRequest req, HttpServletResponse resp)
            throws IOException, ServletException {
        String role = (String) req.getSession().getAttribute("loginRole");
        String sql = "UPDATE assets SET "
                   + "item_name=?, spec=?, manufacturer=?, model=?, "
                   + "location=?, detail_location=?, latitude=?, longitude=?, floor=?, room_no=?, "
                   + "manage_dept=?, manager_name=?, asset_status=?, useful_life=?, remark=?, "
                   + "mod_date=NOW() WHERE asset_no=?";
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1,  req.getParameter("itemName"));
            ps.setString(2,  req.getParameter("spec"));
            ps.setString(3,  req.getParameter("manufacturer"));
            ps.setString(4,  req.getParameter("model"));
            ps.setString(5,  req.getParameter("location"));
            ps.setString(6,  req.getParameter("detailLocation"));
            ps.setString(7,  req.getParameter("latitude"));
            ps.setString(8,  req.getParameter("longitude"));
            ps.setString(9,  req.getParameter("floor"));
            ps.setString(10, req.getParameter("roomNo"));
            ps.setString(11, req.getParameter("manageDept"));
            ps.setString(12, req.getParameter("managerName"));
            ps.setString(13, req.getParameter("assetStatus"));
            ps.setString(14, req.getParameter("usefulLife"));
            ps.setString(15, req.getParameter("remark"));
            ps.setString(16, req.getParameter("assetNo"));
            ps.executeUpdate();
            resp.sendRedirect("/CampusNav/detail?id=" + req.getParameter("assetNo") + "&msg=수정완료");
        } catch (Exception e) {
            System.err.println("자산수정 오류: " + e.getMessage());
            resp.sendRedirect("/CampusNav/main_" + role + ".jsp?error=수정오류");
        } finally {
            DBUtil.close(ps, conn);
        }
    }

    /** 자산 삭제 (관리자만) */
    private void doDelete(HttpServletRequest req, HttpServletResponse resp, String role)
            throws IOException {
        if (!"admin".equals(role)) {
            resp.sendRedirect("/CampusNav/main_" + role + ".jsp");
            return;
        }
        String assetNo = req.getParameter("assetNo");
        String reason  = req.getParameter("deleteReason");
        Connection conn = null;
        PreparedStatement ps = null;
        try {
            conn = DBUtil.getConnection();
            // 삭제 전 폐기 이력 기록
            ps = conn.prepareStatement(
                "INSERT INTO asset_disposal (asset_no,item_name,remark,disposal_year,disposal_type,disposal_date) "
              + "SELECT asset_no,item_name,?,YEAR(NOW()),?,CURDATE() FROM assets WHERE asset_no=?");
            ps.setString(1, reason);
            ps.setString(2, "관리자삭제");
            ps.setString(3, assetNo);
            ps.executeUpdate();
            DBUtil.close(ps);
            // 자산 삭제
            ps = conn.prepareStatement("DELETE FROM assets WHERE asset_no=?");
            ps.setString(1, assetNo);
            ps.executeUpdate();
            resp.sendRedirect("/CampusNav/search?msg=삭제완료");
        } catch (Exception e) {
            System.err.println("자산삭제 오류: " + e.getMessage());
            resp.sendRedirect("/CampusNav/main_admin.jsp?error=삭제오류");
        } finally {
            DBUtil.close(ps, conn);
        }
    }
}
