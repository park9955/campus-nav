package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class LoginServlet extends HttpServlet {

    private static final String[][] USERS = {
        { "student1", "pass1234", "홍길동",   "student"   },
        { "assist1",  "asst1234", "김조교",   "assistant" },
        { "prof1",    "prof1234", "이교수",   "professor" },
        { "admin",    "1234",     "박관리자", "admin"     },
        { "guest1",   "guest123", "방문객",   "guest"     }
    };

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");
        HttpSession session = req.getSession(false);
        if (session != null && session.getAttribute("loginUser") != null) {
            goToRolePage((String) session.getAttribute("loginRole"), resp);
            return;
        }
        req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        String userId = req.getParameter("userId");
        String userPw = req.getParameter("userPw");
        String saveId = req.getParameter("saveId");

        if (userId == null) userId = "";
        if (userPw == null) userPw = "";
        userId = userId.trim();
        userPw = userPw.trim();

        String[] found = null;
        for (String[] u : USERS) {
            if (u[0].equals(userId) && u[1].equals(userPw)) {
                found = u;
                break;
            }
        }

        if (found == null) {
            req.setAttribute("errorMsg", "아이디 또는 비밀번호가 올바르지 않습니다.");
            req.setAttribute("prevId", userId);
            req.getRequestDispatcher("/campuslogin.jsp").forward(req, resp);
            return;
        }

        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession session = req.getSession(true);
        session.setAttribute("loginUser", found[0]);
        session.setAttribute("loginName", found[2]);
        session.setAttribute("loginRole", found[3]);
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

        goToRolePage(found[3], resp);
    }

    private void goToRolePage(String role, HttpServletResponse resp) throws IOException {
        if ("student".equals(role)) {
            resp.sendRedirect("/CampusNav/main_student.jsp");
        } else if ("assistant".equals(role)) {
            resp.sendRedirect("/CampusNav/main_assistant.jsp");
        } else if ("professor".equals(role)) {
            resp.sendRedirect("/CampusNav/main_professor.jsp");
        } else if ("admin".equals(role)) {
            resp.sendRedirect("/CampusNav/main_admin.jsp");
        } else {
            resp.sendRedirect("/CampusNav/main_guest.jsp");
        }
    }
}
