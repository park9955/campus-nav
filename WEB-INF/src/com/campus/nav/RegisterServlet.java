package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

public class RegisterServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.getRequestDispatcher("/register.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String userId    = nvl(req.getParameter("userId"));
        String userName  = nvl(req.getParameter("userName"));
        String userEmail = nvl(req.getParameter("userEmail"));
        String userPw    = nvl(req.getParameter("userPw"));
        String userPw2   = nvl(req.getParameter("userPw2"));
        String role      = nvl(req.getParameter("role"), "student");
        String dept      = nvl(req.getParameter("dept"));
        String studentNum= nvl(req.getParameter("studentNum"));
        String agree     = req.getParameter("agree");

        // 유효성 검사
        if (userId.isEmpty()||userName.isEmpty()||userEmail.isEmpty()||userPw.isEmpty()) {
            req.setAttribute("errorMsg", "모든 항목을 입력해 주세요.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp); return;
        }
        if (!userPw.equals(userPw2)) {
            req.setAttribute("errorMsg", "비밀번호가 일치하지 않습니다.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp); return;
        }
        if (userPw.length() < 8) {
            req.setAttribute("errorMsg", "비밀번호는 8자 이상이어야 합니다.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp); return;
        }
        if (!"on".equals(agree)) {
            req.setAttribute("errorMsg", "이용약관에 동의해 주세요.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp); return;
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;
        try {
            conn = DBUtil.getConnection();

            // 중복 아이디 체크
            ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE user_id=?");
            ps.setString(1, userId);
            rs = ps.executeQuery();
            if (rs.next() && rs.getInt(1) > 0) {
                req.setAttribute("errorMsg", "이미 사용 중인 아이디입니다.");
                req.getRequestDispatcher("/register.jsp").forward(req, resp); return;
            }
            DBUtil.close(rs, ps);

            // 회원 저장
            ps = conn.prepareStatement(
                "INSERT INTO users (user_id,user_pw,user_name,user_email,dept,student_num,role) "
              + "VALUES (?,?,?,?,?,?,?)");
            ps.setString(1, userId);
            ps.setString(2, userPw); // 실제 서비스 시 암호화 필요
            ps.setString(3, userName);
            ps.setString(4, userEmail);
            ps.setString(5, dept);
            ps.setString(6, studentNum.isEmpty() ? null : studentNum);
            ps.setString(7, role);
            ps.executeUpdate();

            resp.sendRedirect("/CampusNav/campuslogin.jsp?registered=true");

        } catch (Exception e) {
            System.err.println("회원가입 오류: " + e.getMessage());
            req.setAttribute("errorMsg", "회원가입 처리 중 오류가 발생했습니다.");
            req.getRequestDispatcher("/register.jsp").forward(req, resp);
        } finally {
            DBUtil.close(rs, ps, conn);
        }
    }

    private String nvl(String s) { return s==null?"":s.trim(); }
    private String nvl(String s, String def) { return (s==null||s.trim().isEmpty())?def:s.trim(); }
}
