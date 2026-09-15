<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    if(session.getAttribute("loginUser")!=null){
        String role=(String)session.getAttribute("loginRole");
        if("student".equals(role))        response.sendRedirect("/CAN/main_student.jsp");
        else if("assistant".equals(role)) response.sendRedirect("/CAN/main_assistant.jsp");
        else if("professor".equals(role)) response.sendRedirect("/CAN/main_professor.jsp");
        else if("admin".equals(role))     response.sendRedirect("/CAN/main_admin.jsp");
        else if("visitor".equals(role))   response.sendRedirect("/CAN/main_visitor.jsp");
        else { session.invalidate(); }
        if(!"guest".equals(session.getAttribute("loginRole"))) return;
    }
    String errorMsg=(String)request.getAttribute("errorMsg"); if(errorMsg==null)errorMsg="";
    String prevId=(String)request.getAttribute("prevId"); if(prevId==null)prevId="";
    String registered=request.getParameter("registered");
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 로그인</title>

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
  --radius-pill: 999px;
  --shadow-air: 0 20px 40px -15px rgba(2, 132, 199, 0.15);
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
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

.app-header {
  background: var(--header-bg);
  backdrop-filter: blur(16px);
  border-bottom: 1px solid var(--border-color);
  padding: 1rem 2rem;
  transition: all 0.3s ease;
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

.brand-logo {
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-weight: 800;
  font-size: 1.25rem;
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
  gap: 8px;
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

.nav-link-signup {
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: #ffffff;
}

.nav-link-signup:hover {
  background: var(--sky-hover);
  color: #ffffff;
}

/* Login Container */
.login-container {
  flex: 1;
  display: flex;
  align-items: center;
  justify-content: center;
  padding: 2rem;
}

.login-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 3rem 2.5rem;
  box-shadow: var(--shadow-air);
  width: 100%;
  max-width: 480px;
}

.login-header {
  text-align: center;
  margin-bottom: 2rem;
}

.login-logo-icon {
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

.login-logo-icon img {
  width: 100%;
  height: 100%;
  object-fit: contain;
}

.login-title {
  font-size: 1.5rem;
  font-weight: 800;
  color: var(--txt-main);
  margin-bottom: 0.5rem;
}

.login-subtitle {
  font-size: 0.9rem;
  color: var(--txt-sub);
}

/* Role Buttons Grid */
.role-grid {
  display: grid;
  grid-template-columns: repeat(5, 1fr);
  gap: 10px;
  margin-bottom: 2rem;
}

.role-btn {
  border: 1.5px solid var(--border-color);
  border-radius: 12px;
  background: var(--surface);
  color: var(--txt-sub);
  font-size: 0.8rem;
  font-weight: 700;
  padding: 12px 6px;
  text-align: center;
  cursor: pointer;
  transition: all 0.2s ease;
  font-family: var(--font-main);
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 4px;
}

[data-theme="dark"] .role-btn {
  background: #334155;
  border-color: #475569;
  color: #cbd5e1;
}

[data-theme="dark"] .role-btn:hover {
  background: #1e3a5f;
  border-color: #38bdf8;
  color: #38bdf8;
}

[data-theme="dark"] .role-btn.active {
  background: #0c4a6e;
  border-color: #38bdf8;
  color: #38bdf8;
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

.role-btn-visitor {
  border-color: var(--emerald-main) !important;
}

.role-btn-visitor:hover, .role-btn-visitor.active {
  border-color: var(--emerald-main) !important;
  background: #f0fdf4 !important;
  color: var(--emerald-main) !important;
  box-shadow: 0 0 0 3px rgba(22, 163, 74, 0.12) !important;
}

/* Alert Messages */
.alert-success {
  background: #f0fdf4;
  border: 1.5px solid #86efac;
  border-radius: 12px;
  color: var(--emerald-main);
  font-size: 0.9rem;
  font-weight: 600;
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.alert-error {
  background: #fef2f2;
  border: 1.5px solid #fca5a5;
  border-radius: 12px;
  color: var(--red-main);
  font-size: 0.9rem;
  font-weight: 600;
  padding: 12px 16px;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

/* Form */
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
}

.form-input-icon {
  position: absolute;
  left: 14px;
  top: 50%;
  transform: translateY(-50%);
  color: var(--txt-muted);
  font-size: 1.1rem;
  pointer-events: none;
}

[data-theme="dark"] .form-input-icon {
  color: #94a3b8;
}

.form-input {
  width: 100%;
  border: 1.5px solid #cbd5e1;
  border-radius: 10px;
  padding: 12px 14px 12px 42px;
  font-size: 0.95rem;
  outline: none;
  background: #f8fafc;
  color: var(--txt-main);
  transition: all 0.2s;
}

.form-input:focus {
  border-color: var(--sky-primary);
  background: var(--surface);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.12);
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

.form-input.is-error {
  border-color: var(--red-main) !important;
  background: #fef2f2 !important;
}

.form-input.is-error:focus {
  box-shadow: 0 0 0 3px rgba(220, 38, 38, 0.12) !important;
}

.form-input.with-action {
  padding-right: 44px;
}

.form-action-btn {
  position: absolute;
  right: 12px;
  top: 50%;
  transform: translateY(-50%);
  background: none;
  border: none;
  color: var(--txt-muted);
  cursor: pointer;
  padding: 0;
  font-size: 1.1rem;
  transition: all 0.2s;
}

.form-action-btn:hover {
  color: var(--sky-primary);
}

.form-checkbox {
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.9rem;
  color: var(--txt-sub);
  cursor: pointer;
  margin-bottom: 1.5rem;
}

.form-checkbox input {
  cursor: pointer;
  accent-color: var(--sky-primary);
}

/* Buttons */
.btn-primary {
  display: block;
  width: 100%;
  text-align: center;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: white;
  border: none;
  border-radius: 10px;
  padding: 14px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
}

.btn-primary:hover {
  background: var(--sky-hover);
  transform: translateY(-1px);
}

.btn-secondary {
  display: block;
  width: 100%;
  text-align: center;
  background: transparent;
  color: var(--txt-sub);
  border: 1.5px solid #cbd5e1;
  border-radius: 10px;
  padding: 12px;
  font-size: 0.9rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
}

.btn-secondary:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
}

.btn-success {
  display: block;
  width: 100%;
  text-align: center;
  background: var(--emerald-main);
  color: white;
  border: none;
  border-radius: 10px;
  padding: 14px;
  font-size: 0.95rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.25);
}

.btn-success:hover {
  background: #15803d;
}

/* Divider */
.divider {
  display: flex;
  align-items: center;
  gap: 12px;
  margin: 1.5rem 0;
  font-size: 0.85rem;
  color: var(--txt-muted);
}

.divider::before, .divider::after {
  content: '';
  flex: 1;
  height: 1px;
  background: var(--border-color);
}

/* Info Box */
.info-box {
  background: #f0fdf4;
  border: 1.5px solid #86efac;
  border-radius: 10px;
  padding: 1rem;
  margin-top: 1rem;
  font-size: 0.85rem;
  color: var(--emerald-main);
  line-height: 1.6;
}

.info-box strong {
  display: block;
  margin-bottom: 0.5rem;
  font-family: var(--font-mono);
  text-transform: uppercase;
  letter-spacing: 0.5px;
  font-size: 0.75rem;
}

.info-row {
  display: flex;
  gap: 8px;
  margin-bottom: 0.5rem;
}

.info-row:last-child {
  margin-bottom: 0;
}

/* Panels */
.staff-panel { display: block; }
.staff-panel.hide { display: none; }
.visitor-panel { display: none; }
.visitor-panel.show { display: block; }

.visitor-welcome {
  text-align: center;
  padding: 2rem 0;
}

.visitor-emoji {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.visitor-title {
  font-size: 1.25rem;
  font-weight: 800;
  color: var(--txt-main);
  margin-bottom: 0.5rem;
}

.visitor-desc {
  color: var(--txt-sub);
  font-size: 0.9rem;
  line-height: 1.6;
}

.visitor-info {
  background: #f0fdf4;
  border: 1.5px solid #86efac;
  border-radius: 10px;
  padding: 1.25rem;
  margin: 1.5rem 0;
  font-size: 0.9rem;
  color: var(--emerald-main);
  line-height: 1.8;
}

.visitor-info div {
  display: flex;
  align-items: flex-start;
  gap: 8px;
  margin-bottom: 0.75rem;
}

.visitor-info div:last-child {
  margin-bottom: 0;
}

.visitor-info strong {
  font-weight: 700;
}

.visitor-info .unavailable {
  color: var(--red-main);
}

/* Footer */
.app-footer {
  background: var(--header-bg);
  border-top: 1px solid var(--border-color);
  color: var(--txt-sub);
  padding: 2rem;
  margin-top: auto;
  font-size: 0.85rem;
  transition: all 0.3s ease;
}

.footer-content {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1.5rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 800;
  color: var(--txt-main);
}

.footer-logo i {
  color: var(--sky-primary);
}

.footer-text {
  font-family: var(--font-mono);
  text-align: center;
  line-height: 1.6;
}

.footer-text strong {
  color: var(--sky-primary);
}

/* Dark Mode Specific Styles */
[data-theme="dark"] .login-card { background: #1e293b; }
[data-theme="dark"] .info-box { background: #1a3a2a; border-color: #1e5a48; color: #4ade80; }
[data-theme="dark"] .info-box strong { color: #4ade80; }

[data-theme="dark"] .visitor-info { background: #1a3a2a; border-color: #1e5a48; color: #4ade80; }

[data-theme="dark"] .btn-secondary { border-color: #475569; color: #cbd5e1; }
[data-theme="dark"] .btn-secondary:hover { border-color: #38bdf8; color: #38bdf8; }

@media (max-width: 640px) {
  .login-card { padding: 2rem 1.5rem; }
  .role-grid { grid-template-columns: repeat(3, 1fr); }
  .footer-content { flex-direction: column; text-align: center; }
}
</style>
</head>
<body>

<!-- HEADER -->
<header class="app-header">
  <div style="display: flex; align-items: center; justify-content: space-between;">
    <a href="/CAN/campuslogin.jsp" class="brand-logo">
      <i class="bi bi-compass-fill fs-4"></i>
      <span>ICT <strong>CAN</strong></span>
    </a>
    <div class="nav-right">
      <a href="/CAN/search.jsp" class="nav-link"><i class="bi bi-search"></i>검색</a>
      <a href="/CAN/register.jsp" class="nav-link nav-link-signup"><i class="bi bi-person-plus"></i>회원가입</a>
      <button type="button" class="theme-toggle" id="themeToggle" onclick="toggleTheme()">
        <i class="bi bi-moon" id="themeIcon"></i>
      </button>
    </div>
  </div>
</header>

<!-- LOGIN CONTAINER -->
<div class="login-container">
<div class="login-card">

  <!-- Header -->
  <div class="login-header">
    <div class="login-logo-icon">
      <img src="/CAN/images/logo.png" alt="ICT">
    </div>
    <div class="login-title">ICT Campus Navigator</div>
    <div class="login-subtitle">교내 자원 내비게이션 시스템</div>
  </div>

  <!-- Role Selection -->
  <div class="role-grid">
    <button type="button" class="role-btn" id="btn-student" onclick="showStaff();fill('','',this,'student')">
      <i class="bi bi-mortarboard-fill"></i>
      <span>학부생</span>
    </button>
    <button type="button" class="role-btn" id="btn-assist" onclick="showStaff();fill('','',this,'assistant')">
      <i class="bi bi-person-workspace"></i>
      <span>조교</span>
    </button>
    <button type="button" class="role-btn" id="btn-prof" onclick="showStaff();fill('','',this,'professor')">
      <i class="bi bi-person-badge-fill"></i>
      <span>교수</span>
    </button>
    <button type="button" class="role-btn" id="btn-admin" onclick="showStaff();fill('','',this,'admin')">
      <i class="bi bi-shield-fill"></i>
      <span>관리자</span>
    </button>
    <button type="button" class="role-btn role-btn-visitor" id="btn-visitor" onclick="showVisitor(this)">
      <i class="bi bi-person-walking"></i>
      <span>외부인</span>
    </button>
  </div>

  <!-- Success Alert -->
  <% if("true".equals(registered)){%>
  <div class="alert-success">
    <i class="bi bi-check-circle-fill"></i>
    <span>회원가입 완료! 로그인해 주세요.</span>
  </div>
  <%}%>

  <!-- STAFF LOGIN PANEL -->
  <div class="staff-panel" id="staffPanel">
    <form action="/CAN/login" method="post" id="frm">
      <input type="hidden" id="selectedRole" name="selectedRole" value="">

      <!-- User ID -->
      <div class="form-group">
        <label class="form-label">아이디</label>
        <div class="form-input-wrap">
          <i class="bi bi-person form-input-icon"></i>
          <input class="form-input<%= !errorMsg.isEmpty() ? " is-error" : "" %>" type="text" id="userId" name="userId" placeholder="학번 또는 아이디 입력" value="<%= prevId %>" autocomplete="username">
        </div>
      </div>

      <!-- Password -->
      <div class="form-group">
        <label class="form-label">비밀번호</label>
        <div class="form-input-wrap">
          <i class="bi bi-lock form-input-icon"></i>
          <input class="form-input with-action<%= !errorMsg.isEmpty() ? " is-error" : "" %>" type="password" id="pwField" name="userPw" placeholder="비밀번호 입력" autocomplete="current-password">
          <button type="button" class="form-action-btn" onclick="togglePw()">
            <i class="bi bi-eye" id="eyeIco"></i>
          </button>
        </div>
        <% if(!errorMsg.isEmpty()){ %>
        <div style="color: var(--red-main); font-size: 0.85rem; margin-top: 6px; display: flex; align-items: center; gap: 6px;">
          <i class="bi bi-exclamation-circle-fill"></i> <%= errorMsg %>
        </div>
        <% } %>
      </div>

      <!-- Remember ID -->
      <label class="form-checkbox">
        <input type="checkbox" name="saveId">
        <span>아이디 저장</span>
      </label>

      <!-- Login Button -->
      <button type="submit" class="btn-primary">
        <i class="bi bi-compass me-2"></i>로그인
      </button>
    </form>

    <!-- Divider -->
    <div class="divider">또는</div>

    <!-- Sign Up Button -->
    <a href="/CAN/register.jsp" class="btn-secondary" style="margin-bottom: 10px;">
      <i class="bi bi-person-plus me-2"></i>회원가입
    </a>

    <!-- Guest Login -->
    <a href="/CAN/guest" class="btn-secondary" style="background: transparent; border: 1.5px dashed #cbd5e1;">
      <i class="bi bi-eye me-2"></i>로그인 없이 둘러보기
    </a>

    <!-- Info -->
    <div class="info-box">
      <strong><i class="bi bi-info-circle me-1"></i>테스트 계정</strong>
      <div>회원가입 후 생성된 계정으로 로그인하세요.</div>
    </div>
  </div>

  <!-- VISITOR PANEL -->
  <div class="visitor-panel" id="visitorPanel">
    <div class="visitor-welcome">
      <div class="visitor-emoji">🏫</div>
      <div class="visitor-title">외부 방문자이신가요?</div>
      <div class="visitor-desc">별도 계정 없이 바로 캠퍼스를 둘러보세요.</div>
    </div>

    <div class="visitor-info">
      <div>
        <i class="bi bi-check-circle-fill"></i>
        <span><strong>이용 가능:</strong> 공간 예약, 캠퍼스 길찾기</span>
      </div>
      <div>
        <i class="bi bi-x-circle-fill"></i>
        <span><strong class="unavailable">이용 불가:</strong> 자원 검색, 자산 상세 조회</span>
      </div>
    </div>

    <a href="/CAN/visitor" class="btn-success">
      <i class="bi bi-door-open me-2"></i>외부인으로 입장하기
    </a>

    <button type="button" class="btn-secondary" onclick="showStaff()" style="margin-top: 10px;">
      <i class="bi bi-arrow-left me-2"></i>재학생·교직원 로그인으로 돌아가기
    </button>
  </div>

</div>
</div>

<!-- FOOTER -->
<footer class="app-footer">
  <div class="footer-content">
    <a href="/CAN/campuslogin.jsp" class="footer-logo">
      <i class="bi bi-compass-fill"></i>
      <span>ICT <strong>CAN</strong></span>
    </a>
    <div class="footer-text">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 &middot; 권동해 &middot; 원태연 &middot; 이수혁
    </div>
    <div class="footer-text">
      ICT폴리텍대학 교내 자원 내비게이션 시스템<br>
      &copy; 2026 ICT CAN. All rights reserved.
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showVisitor(btn){
  document.getElementById('staffPanel').classList.add('hide');
  document.getElementById('visitorPanel').classList.add('show');
  document.querySelectorAll('.role-btn').forEach(function(b){b.classList.remove('active');});
  if(btn)btn.classList.add('active');
  var r=document.getElementById('selectedRole');
  if(r)r.value='';
}
function showStaff(){
  document.getElementById('staffPanel').classList.remove('hide');
  document.getElementById('visitorPanel').classList.remove('show');
  document.querySelectorAll('.role-btn').forEach(function(b){b.classList.remove('active');});
}
function fill(id,pw,btn,role){
  var u=document.getElementById('userId'),p=document.getElementById('pwField');
  if(u&&id)u.value=id; if(p&&pw)p.value=pw;
  document.querySelectorAll('.role-btn').forEach(function(b){b.classList.remove('active');});
  if(btn)btn.classList.add('active');
  var r=document.getElementById('selectedRole');
  if(r)r.value=role||'';
}
function togglePw(){
  var pw=document.getElementById('pwField'),ic=document.getElementById('eyeIco');
  if(!pw)return;
  if(pw.type==='password'){pw.type='text';ic.className='bi bi-eye-slash';}
  else{pw.type='password';ic.className='bi bi-eye';}
}
var frm=document.getElementById('frm');
if(frm){frm.addEventListener('submit',function(e){
  if(!document.getElementById('userId').value.trim()||!document.getElementById('pwField').value.trim()){
    e.preventDefault();alert('아이디와 비밀번호를 입력해 주세요.');
  }
});}

// Dark Mode Toggle
function toggleTheme(){
  var html=document.documentElement;
  var currentTheme=html.getAttribute('data-theme');
  var newTheme=currentTheme==='dark'?'light':'dark';
  html.setAttribute('data-theme',newTheme);
  localStorage.setItem('theme',newTheme);
  updateThemeIcon();
}

function updateThemeIcon(){
  var icon=document.getElementById('themeIcon');
  var html=document.documentElement;
  var theme=html.getAttribute('data-theme');
  if(theme==='dark'){
    icon.className='bi bi-sun';
  }else{
    icon.className='bi bi-moon';
  }
}

// Initialize theme on page load
window.addEventListener('DOMContentLoaded',function(){
  var savedTheme=localStorage.getItem('theme');
  var html=document.documentElement;

  if(savedTheme){
    html.setAttribute('data-theme',savedTheme);
  }else if(window.matchMedia('(prefers-color-scheme: dark)').matches){
    html.setAttribute('data-theme','dark');
  }

  updateThemeIcon();
});
</script>
</body>
</html>
