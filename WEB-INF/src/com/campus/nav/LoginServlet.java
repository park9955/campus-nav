package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class LoginServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loginUser") != null) {
            String role = (String) session.getAttribute("loginRole");
            if ("guest".equals(role)) {
                session.invalidate();
            } else {
                goToRolePage(role, resp); return;
            }
        }
        req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String userId      = req.getParameter("userId");
        String userPw      = req.getParameter("userPw");
        String saveId      = req.getParameter("saveId");
        String selectedRole = req.getParameter("selectedRole");

        if (userId == null) userId = "";
        if (userPw == null) userPw = "";
        if (selectedRole == null) selectedRole = "";
        userId = userId.trim();
        userPw = userPw.trim();
        selectedRole = selectedRole.trim();

        String foundName = null, foundRole = null;
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();
            ps = conn.prepareStatement(
                "SELECT user_name, role FROM users WHERE user_id=? AND user_pw=? AND use_yn='Y'");
            ps.setString(1, userId);
            ps.setString(2, userPw);
            rs = ps.executeQuery();
            if (rs.next()) {
                foundName = rs.getString("user_name");
                foundRole = rs.getString("role");
            }
        } catch (Exception e) {
            System.err.println("LoginServlet DB error: " + e.getMessage());
        } finally {
            DBUtil.close(rs, ps, conn);
        }

        // 아이디/비밀번호 불일치
        if (foundName == null) {
            req.setAttribute("errorMsg", "아이디 또는 비밀번호가 틀렸습니다.");
            req.setAttribute("prevId", userId);
            req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
            return;
        }

        // 역할 미선택 체크
        if (selectedRole.isEmpty()) {
            req.setAttribute("errorMsg", "역할을 선택해 주세요.");
            req.setAttribute("prevId", userId);
            req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
            return;
        }

        // 선택 역할과 DB 역할 불일치
        if (!selectedRole.isEmpty() && !selectedRole.equals(foundRole)) {
            req.setAttribute("errorMsg", "선택한 역할과 계정 유형이 일치하지 않습니다.");
            req.setAttribute("prevId", userId);
            req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
            return;
        }

        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession session = req.getSession(true);
        session.setAttribute("loginUser", userId);
        session.setAttribute("loginName", foundName);
        session.setAttribute("loginRole", foundRole);
        session.setMaxInactiveInterval(30 * 60);

        if ("on".equals(saveId)) {
            Cookie c = new Cookie("savedId", userId);
            c.setMaxAge(60 * 60 * 24 * 30);
            c.setPath("/");
            resp.addCookie(c);
        } else {
            Cookie c = new Cookie("savedId", "");
            c.setMaxAge(0);
            c.setPath("/");
            resp.addCookie(c);
        }

        goToRolePage(foundRole, resp);
    }

    private void goToRolePage(String role, HttpServletResponse resp) throws IOException {
        if (role == null) role = "guest";
        switch (role) {
            case "student":   resp.sendRedirect("/CAN/main_student.jsp");   break;
            case "assistant": resp.sendRedirect("/CAN/main_assistant.jsp"); break;
            case "professor": resp.sendRedirect("/CAN/main_professor.jsp"); break;
            case "admin":     resp.sendRedirect("/CAN/main_admin.jsp");     break;
            case "visitor":   resp.sendRedirect("/CAN/main_visitor.jsp");   break;
            default:          resp.sendRedirect("/CAN/main_guest.jsp");     break;
        }
    }
}
