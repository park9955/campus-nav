package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

/**
 * 외부인(Visitor) 진입 서블릿
 * /visitor → 세션에 role=visitor 설정 후 main_visitor.jsp 이동
 */
public class VisitorServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        // 기존 세션 초기화
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        // 외부인 세션 생성
        HttpSession session = req.getSession(true);
        session.setAttribute("loginUser",  "visitor");
        session.setAttribute("loginName",  "외부인");
        session.setAttribute("loginRole",  "visitor");
        session.setMaxInactiveInterval(60 * 60); // 1시간
        resp.sendRedirect("/CampusNav/main_visitor.jsp");
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        doGet(req, resp);
    }
}
