<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    // 게스트 세션 무효화 후 로그인 페이지로 이동
    HttpSession s = request.getSession(false);
    if(s != null) s.invalidate();
    response.sendRedirect("/CampusNav/campuslogin.jsp");
%>
