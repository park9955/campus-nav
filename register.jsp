<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" import="java.sql.*" %>
<%
    // POST 처리 - 회원가입 DB 저장
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String userId    = request.getParameter("userId");
        String userName  = request.getParameter("userName");
        String userEmail = request.getParameter("userEmail");
        String userPw    = request.getParameter("userPw");
        String userPw2   = request.getParameter("userPw2");
        String role      = request.getParameter("role");
        String dept      = request.getParameter("dept");
        String studentNum= request.getParameter("studentNum");
        String agree     = request.getParameter("agree");

        if (userId==null) userId=""; if (userName==null) userName="";
        if (userEmail==null) userEmail=""; if (userPw==null) userPw="";
        if (userPw2==null) userPw2=""; if (role==null) role="student";
        if (dept==null) dept=""; if (studentNum==null) studentNum="";

        String errMsg = "";
        if (userId.trim().isEmpty() || userName.trim().isEmpty() || userPw.trim().isEmpty()) {
            errMsg = "필수 항목을 모두 입력해 주세요.";
        } else if (!userPw.equals(userPw2)) {
            errMsg = "비밀번호가 일치하지 않습니다.";
        } else if (userPw.length() < 4) {
            errMsg = "비밀번호는 4자 이상이어야 합니다.";
        } else if (!"on".equals(agree)) {
            errMsg = "이용약관에 동의해 주세요.";
        }

        if (errMsg.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
                // 중복 아이디 체크
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE user_id=?");
                ps.setString(1, userId.trim());
                ResultSet rs = ps.executeQuery();
                boolean dup = rs.next() && rs.getInt(1) > 0;
                rs.close(); ps.close();
                if (dup) {
                    errMsg = "이미 사용 중인 아이디입니다.";
                    conn.close();
                } else {
                    ps = conn.prepareStatement(
                        "INSERT INTO users (user_id,user_pw,user_name,user_email,dept,student_num,role) VALUES (?,?,?,?,?,?,?)");
                    ps.setString(1, userId.trim());
                    ps.setString(2, userPw);
                    ps.setString(3, userName.trim());
                    ps.setString(4, userEmail.trim());
                    ps.setString(5, dept.trim());
                    ps.setString(6, studentNum.trim().isEmpty() ? null : studentNum.trim());
                    ps.setString(7, role);
                    ps.executeUpdate();
                    ps.close(); conn.close();
                    response.sendRedirect("/CAN/campuslogin.jsp?registered=true");
                    return;
                }
            } catch (Exception e) {
                errMsg = "회원가입 처리 중 오류: " + e.getMessage();
            }
        }
        request.setAttribute("errMsg", errMsg);
        request.setAttribute("prevUserId", userId);
        request.setAttribute("prevUserName", userName);
        request.setAttribute("prevEmail", userEmail);
        request.setAttribute("prevDept", dept);
    }

    if (session.getAttribute("loginUser") != null) {
        response.sendRedirect("/CAN/campuslogin.jsp");
        return;
    }
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CAN — 회원가입</title>

    <!-- Fonts & Libraries -->
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@700;800&family=Pretendard:wght@400;500;600;700;800&family=JetBrains+Mono:wght@600;700&display=swap" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

    <style>
:root {
  --bg-app: #f0f4f9;
  --surface: #ffffff;
  --txt-main: #0f172a;
  --txt-sub: #334155;
  --txt-muted: #64748b;
  --sky-primary: #0284c7;
  --sky-hover: #0369a1;
  --sky-light: #e0f2fe;
  --sky-bg: #f0f9ff;
  --emerald-main: #16a34a;
  --amber-main: #d97706;
  --red-main: #dc2626;
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-md: 12px;
  --radius-pill: 999px;
  --shadow-air: 0 20px 40px -15px rgba(2, 132, 199, 0.15);
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
  --font-plus: 'Plus Jakarta Sans', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --header-bg: rgba(255, 255, 255, 0.95);
  --border-color: rgba(226, 232, 240, 0.8);
}

[data-theme="dark"] {
  --bg-app: #0f172a;
  --surface: #1e293b;
  --txt-main: #f1f5f9;
  --txt-sub: #e2e8f0;
  --txt-muted: #cbd5e1;
  --sky-primary: #38bdf8;
  --sky-hover: #0ea5e9;
  --sky-light: #0c4a6e;
  --sky-bg: #1e3a5f;
  --header-bg: rgba(30, 41, 59, 0.95);
  --border-color: rgba(71, 85, 105, 0.6);
}

* { margin: 0; padding: 0; box-sizing: border-box; }

body {
  font-family: var(--font-main);
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
  background-repeat: no-repeat;
  background-attachment: fixed;
  color: var(--txt-main);
  line-height: 1.6;
  min-height: 100vh;
  display: flex;
  flex-direction: column;
  transition: background 0.3s ease, color 0.3s ease;
  -webkit-font-smoothing: antialiased;
}

[data-theme="dark"] body {
  background: linear-gradient(180deg, #0f172a 0%, #1a2f3a 40%, #1a332f 100%);
}

a { text-decoration: none; color: inherit; }

/* HEADER */
.app-header {
  background: var(--header-bg);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--border-color);
  padding: 1rem 2rem;
  transition: all 0.3s ease;
  position: sticky;
  top: 0;
  z-index: 1000;
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.brand-logo {
  font-family: var(--font-plus);
  font-weight: 800;
  font-size: 1.3rem;
  color: var(--txt-main);
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-logo i {
  color: var(--sky-primary);
}

.nav-right {
  display: flex;
  gap: 12px;
  align-items: center;
}

.nav-link {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--txt-sub);
  padding: 8px 16px;
  border-radius: var(--radius-pill);
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.nav-link:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

.theme-toggle {
  background: none;
  border: none;
  color: var(--txt-sub);
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.2s;
  padding: 6px 12px;
  border-radius: var(--radius-pill);
  display: inline-flex;
  align-items: center;
}

.theme-toggle:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

/* MAIN CONTENT */
.register-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.register-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 3.5rem 3rem;
  box-shadow: var(--shadow-air);
  width: 100%;
  max-width: 520px;
  border: 1px solid #f1f5f9;
}

/* HEADER SECTION */
.reg-header {
  text-align: center;
  margin-bottom: 2.5rem;
}

.reg-logo {
  width: 64px;
  height: 64px;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  border-radius: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin: 0 auto 1.5rem;
  overflow: hidden;
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
}

.reg-logo img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.reg-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--txt-main);
  margin-bottom: 0.5rem;
}

.reg-title em {
  color: var(--sky-primary);
  font-style: normal;
}

.reg-subtitle {
  font-size: 0.9rem;
  color: var(--txt-sub);
}

/* ROLE SELECTION */
.role-section-label {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--sky-primary);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 1rem;
  display: block;
  margin-top: 1.5rem;
}

.role-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 8px;
  margin-bottom: 2rem;
}

.role-btn {
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-md);
  background: var(--surface);
  color: var(--txt-sub);
  font-size: 0.8rem;
  font-weight: 700;
  padding: 12px 4px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  font-family: var(--font-main);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

.role-btn i {
  font-size: 1.5rem;
}

.role-btn:hover {
  border-color: var(--sky-primary);
  background: var(--sky-bg);
  color: var(--sky-primary);
}

.role-btn.active {
  border-color: var(--sky-primary);
  background: var(--sky-light);
  color: var(--sky-primary);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.12);
}

[data-theme="dark"] .role-btn {
  background: #334155;
  border-color: #475569;
  color: #cbd5e1;
}

[data-theme="dark"] .role-btn:hover,
[data-theme="dark"] .role-btn.active {
  background: #1e3a5f;
  border-color: #38bdf8;
  color: #38bdf8;
}

/* ALERT MESSAGES */
.alert-error {
  background: #fef2f2;
  border: 1.5px solid #fca5a5;
  border-radius: var(--radius-md);
  color: var(--red-main);
  font-size: 0.9rem;
  font-weight: 600;
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

[data-theme="dark"] .alert-error {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

/* FORM GROUPS */
.form-group {
  margin-bottom: 1.25rem;
}

.form-label {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  color: var(--txt-sub);
  display: block;
  margin-bottom: 6px;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.form-input-wrap {
  position: relative;
  display: flex;
  align-items: center;
}

.form-input-icon {
  position: absolute;
  left: 14px;
  color: var(--txt-muted);
  font-size: 1.1rem;
  pointer-events: none;
}

.form-input {
  width: 100%;
  border: 1.5px solid #cbd5e1;
  border-radius: var(--radius-md);
  padding: 12px 14px 12px 42px;
  font-size: 0.95rem;
  outline: none;
  background: #f8fafc;
  color: var(--txt-main);
  transition: all 0.2s;
  font-family: var(--font-main);
}

.form-input:focus {
  border-color: var(--sky-primary);
  background: var(--surface);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.12);
}

.form-input.is-error {
  border-color: var(--red-main) !important;
  background: #fef2f2 !important;
}

.form-input.is-error:focus {
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.12) !important;
}

[data-theme="dark"] .form-input {
  background: #334155;
  border-color: #475569;
  color: #f1f5f9;
}

[data-theme="dark"] .form-input::placeholder {
  color: #94a3b8;
}

[data-theme="dark"] .form-input:focus {
  background: #1e293b;
  border-color: #38bdf8;
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

[data-theme="dark"] .form-input.is-error {
  background: #7f1d1d !important;
  border-color: #fca5a5 !important;
}

/* PASSWORD STRENGTH BAR */
.pw-strength-wrap {
  margin-top: 8px;
}

.pw-strength-bar {
  height: 4px;
  background: #e2e8f0;
  border-radius: 4px;
  overflow: hidden;
  margin-bottom: 6px;
}

.pw-strength-fill {
  height: 100%;
  width: 0;
  border-radius: 4px;
  transition: width 0.3s, background-color 0.3s;
}

.pw-strength-text {
  font-size: 0.8rem;
  color: var(--txt-muted);
  font-weight: 600;
}

.pw-match-text {
  font-size: 0.8rem;
  margin-top: 6px;
  font-weight: 600;
  display: none;
}

.pw-match-text.match {
  color: var(--emerald-main);
  display: block;
}

.pw-match-text.nomatch {
  color: var(--red-main);
  display: block;
}

/* TERMS BOX */
.terms-section-label {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--sky-primary);
  text-transform: uppercase;
  letter-spacing: 0.1em;
  margin-bottom: 1rem;
  display: block;
  margin-top: 1.5rem;
}

.terms-box {
  background: #f8fafc;
  border: 1.5px solid #e2e8f0;
  border-radius: var(--radius-md);
  padding: 1rem;
  font-size: 0.85rem;
  color: var(--txt-sub);
  line-height: 1.7;
  max-height: 120px;
  overflow-y: auto;
  margin-bottom: 1rem;
}

[data-theme="dark"] .terms-box {
  background: #334155;
  border-color: #475569;
  color: #cbd5e1;
}

/* FORM CHECKBOX */
.form-checkbox {
  display: flex;
  align-items: flex-start;
  gap: 10px;
  font-size: 0.9rem;
  color: var(--txt-sub);
  cursor: pointer;
  margin-bottom: 2rem;
}

.form-checkbox input {
  cursor: pointer;
  accent-color: var(--sky-primary);
  width: 18px;
  height: 18px;
  margin-top: 2px;
  flex-shrink: 0;
}

.form-checkbox label {
  margin: 0;
  cursor: pointer;
  flex: 1;
}

.form-checkbox span {
  color: var(--sky-primary);
  font-weight: 700;
}

/* BUTTONS */
.btn-submit {
  display: block;
  width: 100%;
  text-align: center;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  padding: 14px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
  margin-bottom: 10px;
}

.btn-submit:hover {
  background: var(--sky-hover);
  transform: translateY(-1px);
}

.btn-back {
  display: block;
  width: 100%;
  text-align: center;
  background: transparent;
  color: var(--txt-sub);
  border: 1.5px solid #cbd5e1;
  border-radius: var(--radius-md);
  padding: 12px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
}

.btn-back:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
  background: var(--sky-bg);
}

[data-theme="dark"] .btn-back {
  border-color: #475569;
  color: #cbd5e1;
}

[data-theme="dark"] .btn-back:hover {
  border-color: #38bdf8;
  color: #38bdf8;
  background: #1e3a5f;
}

/* FOOTER TEXT */
.reg-footer {
  font-size: 0.8rem;
  color: var(--txt-muted);
  text-align: center;
  margin-top: 1.5rem;
}

.reg-footer a {
  color: var(--sky-primary);
  text-decoration: none;
  font-weight: 600;
}

.reg-footer a:hover {
  text-decoration: underline;
}

/* RESPONSIVE */
@media (max-width: 640px) {
  .register-card {
    padding: 2.5rem 1.5rem;
  }

  .role-grid {
    grid-template-columns: repeat(3, 1fr);
    gap: 6px;
  }

  .reg-title {
    font-size: 1.25rem;
  }

  .header-inner {
    flex-wrap: wrap;
    gap: 1rem;
  }
}

    </style>
</head>
<body>

<!-- HEADER -->
<header class="app-header">
  <div class="header-inner">
    <a href="/CAN/campuslogin.jsp" class="brand-logo">
      <i class="bi bi-compass-fill fs-5"></i>
      <span>ICT <strong style="color: var(--sky-primary);">CAN</strong></span>
    </a>
    <div class="nav-right">
      <a href="/CAN/campuslogin.jsp" class="nav-link"><i class="bi bi-box-arrow-in-left"></i>로그인</a>
      <button type="button" class="theme-toggle" onclick="toggleTheme()">
        <i class="bi bi-moon" id="themeIcon"></i>
      </button>
    </div>
  </div>
</header>

<!-- MAIN CONTENT -->
<div class="register-container">
  <div class="register-card">

    <!-- Header Section -->
    <div class="reg-header">
      <div class="reg-logo"><img src="/CAN/images/logo.png" alt="ICT"></div>
      <h1 class="reg-title">ICT <em>CAN</em> 가입</h1>
      <p class="reg-subtitle">재학생 · 교직원 전용 서비스</p>
    </div>

    <!-- Error Message -->
    <%
    String errMsg = (String) request.getAttribute("errMsg");
    if (errMsg == null) errMsg = "";
    %>
    <% if (!errMsg.isEmpty()) { %>
    <div class="alert-error">
      <i class="bi bi-exclamation-circle-fill"></i>
      <span><%= errMsg %></span>
    </div>
    <% } %>

    <form action="/CAN/register.jsp" method="post" id="regForm">
      <input type="hidden" name="role" id="roleValue" value="student">

      <!-- Role Selection -->
      <label class="role-section-label"><i class="bi bi-person-badge me-1"></i>역할 선택</label>
      <div class="role-grid">
        <button type="button" class="role-btn active" id="role-student" onclick="selectRole(this, 'student')">
          <i class="bi bi-mortarboard-fill"></i>
          <span>학부생</span>
        </button>
        <button type="button" class="role-btn" id="role-assistant" onclick="selectRole(this, 'assistant')">
          <i class="bi bi-person-workspace"></i>
          <span>조교</span>
        </button>
        <button type="button" class="role-btn" id="role-professor" onclick="selectRole(this, 'professor')">
          <i class="bi bi-person-badge-fill"></i>
          <span>교수</span>
        </button>
        <button type="button" class="role-btn" id="role-admin" onclick="selectRole(this, 'admin')">
          <i class="bi bi-shield-fill"></i>
          <span>관리자</span>
        </button>
        <button type="button" class="role-btn" id="role-guest" onclick="selectRole(this, 'visitor')">
          <i class="bi bi-person-fill"></i>
          <span>외부인</span>
        </button>
      </div>

      <!-- Basic Info Section -->
      <label class="role-section-label"><i class="bi bi-info-circle me-1"></i>기본 정보</label>

      <div class="form-group">
        <label class="form-label">학번 / 아이디 *</label>
        <div class="form-input-wrap">
          <i class="bi bi-person form-input-icon"></i>
          <input class="form-input" type="text" name="userId" id="userId"
                 placeholder="예) 20240001" required>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">이름 *</label>
        <div class="form-input-wrap">
          <i class="bi bi-type form-input-icon"></i>
          <input class="form-input" type="text" name="userName" id="userName"
                 placeholder="실명 입력" required>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">이메일</label>
        <div class="form-input-wrap">
          <i class="bi bi-envelope form-input-icon"></i>
          <input class="form-input" type="email" name="userEmail" id="userEmail"
                 placeholder="example@campus.ac.kr">
        </div>
      </div>

      <div class="form-group">
        <label class="form-label" id="deptLabel">학과 *</label>
        <div class="form-input-wrap">
          <i class="bi bi-building form-input-icon"></i>
          <input class="form-input" type="text" name="dept" id="deptInput"
                 placeholder="예) 컴퓨터공학과" required>
        </div>
      </div>

      <div class="form-group" id="studentNumWrap">
        <label class="form-label">학번</label>
        <div class="form-input-wrap">
          <i class="bi bi-hash form-input-icon"></i>
          <input class="form-input" type="text" name="studentNum" id="studentNum"
                 placeholder="예) 20240001">
        </div>
      </div>

      <!-- Security Section -->
      <label class="role-section-label"><i class="bi bi-shield-lock me-1"></i>보안</label>

      <div class="form-group">
        <label class="form-label">비밀번호 *</label>
        <div class="form-input-wrap">
          <i class="bi bi-lock form-input-icon"></i>
          <input class="form-input" type="password" name="userPw" id="userPw"
                 placeholder="8자 이상, 영문+숫자" required oninput="checkPwStrength(this.value)">
        </div>
        <div class="pw-strength-wrap">
          <div class="pw-strength-bar">
            <div class="pw-strength-fill" id="pwBar"></div>
          </div>
          <div class="pw-strength-text" id="pwHint">비밀번호를 입력하세요</div>
        </div>
      </div>

      <div class="form-group">
        <label class="form-label">비밀번호 확인 *</label>
        <div class="form-input-wrap">
          <i class="bi bi-lock-fill form-input-icon"></i>
          <input class="form-input" type="password" name="userPw2" id="userPw2"
                 placeholder="비밀번호 재입력" required oninput="checkPwMatch()">
        </div>
        <div class="pw-match-text" id="pwMatch"></div>
      </div>

      <!-- Terms Section -->
      <label class="terms-section-label"><i class="bi bi-file-text me-1"></i>이용약관</label>
      <div class="terms-box">
CampusNav 서비스 이용약관 (프로토타입)<br>
제1조. 본 서비스는 교내 자원 내비게이션 제공을 목적으로 합니다.<br>
제2조. 수집되는 개인정보는 서비스 제공 목적으로만 사용됩니다.<br>
제3조. 이용자는 타인의 계정을 도용해서는 안 됩니다.<br>
제4조. 위치 정보는 캠퍼스 내 이동 안내에만 활용됩니다.
      </div>

      <div class="form-checkbox">
        <input type="checkbox" id="agree" name="agree" required>
        <label for="agree">
          이용약관 및 개인정보 처리방침에 동의합니다 <span>(필수)</span>
        </label>
      </div>

      <!-- Buttons -->
      <button type="submit" class="btn-submit">
        <i class="bi bi-person-check me-2"></i>가입하기
      </button>
      <a href="/CAN/campuslogin.jsp" class="btn-back">
        <i class="bi bi-arrow-left me-1"></i>로그인으로 돌아가기
      </a>

      <p class="reg-footer">
        재학생·교직원 전용 서비스 &nbsp;|&nbsp; <a href="mailto:support@campus.ac.kr">support@campus.ac.kr</a>
      </p>
    </form>

  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>

// Role Configuration
var roleConfig = {
    student:   { dept: '학과 *',   showStudentNum: true  },
    assistant: { dept: '학과 *',   showStudentNum: true  },
    professor: { dept: '소속 학과 *', showStudentNum: false },
    admin:     { dept: '소속 부서 *', showStudentNum: false },
    visitor:   { dept: '소속 기관',   showStudentNum: false }
};

// Select Role
function selectRole(btn, role) {
    document.querySelectorAll('.role-btn').forEach(function(b) {
        b.classList.remove('active');
    });
    btn.classList.add('active');
    document.getElementById('roleValue').value = role;

    var cfg = roleConfig[role];
    document.getElementById('deptLabel').textContent = cfg.dept;
    document.getElementById('studentNumWrap').style.display = cfg.showStudentNum ? 'block' : 'none';
}

// Password Strength Check
function checkPwStrength(v) {
    var bar = document.getElementById('pwBar');
    var hint = document.getElementById('pwHint');

    if (!v) {
        bar.style.width = '0';
        hint.textContent = '비밀번호를 입력하세요';
        hint.style.color = '';
        return;
    }

    var score = 0;
    if (v.length >= 8) score++;
    if (/[A-Za-z]/.test(v)) score++;
    if (/[0-9]/.test(v)) score++;
    if (/[^A-Za-z0-9]/.test(v)) score++;

    var colors = ['#ff4d4d', '#ff944d', '#f0c040', '#00c2a8'];
    var labels = ['매우 약함', '보통', '강함', '매우 강함'];
    var pcts   = ['25%', '50%', '75%', '100%'];
    var i = Math.max(0, score - 1);

    bar.style.width = pcts[i];
    bar.style.backgroundColor = colors[i];
    hint.textContent = '강도: ' + labels[i];
    hint.style.color = colors[i];
}

// Password Match Check
function checkPwMatch() {
    var m = document.getElementById('pwMatch');
    var pw = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;

    if (!pw2) {
        m.textContent = '';
        m.classList.remove('match', 'nomatch');
        return;
    }

    if (pw === pw2) {
        m.textContent = '✓ 비밀번호가 일치합니다';
        m.classList.remove('nomatch');
        m.classList.add('match');
    } else {
        m.textContent = '✗ 비밀번호가 일치하지 않습니다';
        m.classList.remove('match');
        m.classList.add('nomatch');
    }
}

// Form Validation on Submit
document.getElementById('regForm').addEventListener('submit', function(e) {
    if (!document.getElementById('agree').checked) {
        e.preventDefault();
        alert('이용약관에 동의해 주세요.');
        return;
    }
    var pw = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;
    if (pw.length < 8) {
        e.preventDefault();
        alert('비밀번호는 8자 이상이어야 합니다.');
        return;
    }
    if (pw !== pw2) {
        e.preventDefault();
        alert('비밀번호가 일치하지 않습니다.');
        return;
    }
});

// Dark Mode Toggle
function toggleTheme() {
    var html = document.documentElement;
    var currentTheme = html.getAttribute('data-theme');
    var newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    html.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeIcon();
}

function updateThemeIcon() {
    var icon = document.getElementById('themeIcon');
    var html = document.documentElement;
    var theme = html.getAttribute('data-theme');
    if (theme === 'dark') {
        icon.className = 'bi bi-sun';
    } else {
        icon.className = 'bi bi-moon';
    }
}

// Initialize theme on page load
window.addEventListener('DOMContentLoaded', function() {
    var savedTheme = localStorage.getItem('theme');
    var html = document.documentElement;

    if (savedTheme) {
        html.setAttribute('data-theme', savedTheme);
    } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
        html.setAttribute('data-theme', 'dark');
    }

    updateThemeIcon();
});

</script>
</body>
</html>
