package com.campus.nav;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import java.io.IOException;

public class GuestServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {
        HttpSession old = req.getSession(false);
        if (old != null) old.invalidate();
        HttpSession session = req.getSession(true);
        session.setAttribute("loginUser", "guest");
        session.setAttribute("loginName", "게스트");
        session.setAttribute("loginRole", "guest");
        session.setMaxInactiveInterval(60 * 60);
        resp.sendRedirect("/CampusNav/main_guest.jsp");
    }
}
