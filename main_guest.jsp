<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>CAN — 게스트</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Pretendard:wght@300;400;500;600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700;800&family=JetBrains+Mono:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root {
  --sky-primary: #0284c7;
  --sky-hover: #0369a1;
  --sky-light: #bae6fd;
  --sky-bg: #f0f9ff;
  --emerald-primary: #059669;
  --emerald-hover: #047857;
  --emerald-light: #a7f3d0;
  --emerald-bg: #f0fdf4;
  --amber-main: #d97706;
  --amber-hover: #b45309;
  --red-main: #dc2626;
  --txt-main: #0f172a;
  --txt-sub: #64748b;
  --txt-muted: #94a3b8;
  --surface: #ffffff;
  --bg: #f8fafc;
  --border: #e2e8f0;
  --border-dark: #cbd5e1;
  --radius-pill: 999px;
  --radius-lg: 16px;
  --radius-md: 12px;
  --shadow: 0 1px 2px 0 rgba(0, 0, 0, 0.05);
  --shadow-lg: 0 10px 15px -3px rgba(0, 0, 0, 0.1);
}

[data-theme="dark"] {
  --sky-primary: #38bdf8;
  --sky-bg: #0c2d42;
  --emerald-bg: #0d2d24;
  --txt-main: #f1f5f9;
  --txt-sub: #cbd5e1;
  --txt-muted: #94a3b8;
  --surface: #1e293b;
  --bg: #0f172a;
  --border: #334155;
  --border-dark: #475569;
}

* { box-sizing: border-box; margin: 0; padding: 0; }

body {
  background: var(--bg);
  color: var(--txt-main);
  font-family: Pretendard, 'Plus Jakarta Sans', sans-serif;
  font-size: 15px;
  line-height: 1.6;
  transition: background 0.3s, color 0.3s;
}

/* Header */
.app-header {
  background: var(--surface);
  border-bottom: 1px solid var(--border);
  padding: 16px 24px;
  position: sticky;
  top: 0;
  z-index: 100;
  box-shadow: var(--shadow);
  display: flex;
  align-items: center;
  justify-content: space-between;
}

.logo-brand {
  display: flex;
  align-items: center;
  gap: 12px;
  font-weight: 800;
  font-size: 18px;
  color: var(--txt-main);
  text-decoration: none;
}

.logo-icon {
  width: 36px;
  height: 36px;
  background: var(--sky-primary);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  color: white;
  font-weight: 700;
  font-size: 18px;
}

.logo-brand em { color: var(--sky-primary); font-style: normal; font-weight: 700; }

.header-right { display: flex; gap: 12px; align-items: center; }

.badge-role {
  background: var(--border);
  color: var(--txt-muted);
  padding: 5px 12px;
  border-radius: 6px;
  font-size: 12px;
  font-weight: 600;
}

.btn-logout {
  background: var(--sky-primary);
  color: white;
  border: none;
  padding: 8px 16px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.btn-logout:hover {
  background: var(--sky-hover);
  color: white;
}

.theme-toggle {
  background: var(--border);
  color: var(--txt-main);
  border: none;
  width: 36px;
  height: 36px;
  border-radius: 6px;
  cursor: pointer;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 18px;
}

.theme-toggle:hover {
  background: var(--border-dark);
}

/* Main Content */
.app-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 32px 24px 80px;
}

/* Hero Section */
.hero-section {
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
  border-radius: var(--radius-lg);
  padding: 48px;
  margin-bottom: 32px;
  position: relative;
  overflow: hidden;
}

[data-theme="dark"] .hero-section {
  background: linear-gradient(135deg, #0f172a 0%, #164e63 40%, #0d6147 100%);
}

.hero-title {
  font-size: 32px;
  font-weight: 800;
  color: var(--txt-main);
  margin-bottom: 12px;
}

[data-theme="dark"] .hero-title {
  color: #ffffff;
}

.hero-title em { color: var(--emerald-primary); font-style: normal; }
[data-theme="dark"] .hero-title em { color: #4ade80; }

.hero-desc {
  font-size: 16px;
  color: var(--txt-sub);
  margin-bottom: 24px;
  line-height: 1.7;
}

[data-theme="dark"] .hero-desc {
  color: rgba(255, 255, 255, 0.88);
}

/* Search Bar */
.search-container {
  display: flex;
  gap: 8px;
  max-width: 520px;
  background: rgba(255, 255, 255, 0.8);
  border: 1.5px solid var(--border-dark);
  border-radius: var(--radius-lg);
  padding: 8px 8px 8px 16px;
  transition: all 0.2s;
}

[data-theme="dark"] .search-container {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.2);
}

.search-container:focus-within {
  border-color: var(--sky-primary);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.1);
}

[data-theme="dark"] .search-container:focus-within {
  border-color: #38bdf8;
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

.search-container input {
  flex: 1;
  background: transparent;
  border: none;
  outline: none;
  color: var(--txt-main);
  font-size: 15px;
}

[data-theme="dark"] .search-container input {
  color: #f1f5f9;
}

.search-container input::placeholder {
  color: var(--txt-muted);
}

.btn-search {
  background: var(--sky-primary);
  color: white;
  border: none;
  padding: 10px 20px;
  border-radius: var(--radius-md);
  font-weight: 700;
  cursor: pointer;
  white-space: nowrap;
  transition: all 0.2s;
}

.btn-search:hover {
  background: var(--sky-hover);
}

/* Grid Layout */
.content-grid {
  display: grid;
  grid-template-columns: 1fr 340px;
  gap: 24px;
}

/* Card */
.card-box {
  background: var(--surface);
  border: 1px solid var(--border);
  border-radius: var(--radius-lg);
  overflow: hidden;
  box-shadow: var(--shadow);
  transition: all 0.2s;
}

.card-box:hover {
  box-shadow: var(--shadow-lg);
}

.card-header {
  padding: 20px 24px;
  border-bottom: 1px solid var(--border);
  display: flex;
  align-items: center;
  gap: 12px;
}

.card-icon {
  width: 40px;
  height: 40px;
  background: var(--sky-bg);
  border-radius: 8px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  color: var(--sky-primary);
  flex-shrink: 0;
}

[data-theme="dark"] .card-icon {
  background: var(--sky-bg);
  color: #38bdf8;
}

.card-header-text h3 {
  font-size: 16px;
  font-weight: 700;
  color: var(--txt-main);
  margin: 0;
}

.card-header-text p {
  font-size: 13px;
  color: var(--txt-muted);
  margin: 4px 0 0;
}

.card-body {
  padding: 24px;
}

/* Category Grid */
.category-grid {
  display: grid;
  grid-template-columns: repeat(6, 1fr);
  gap: 12px;
}

.category-item {
  border: 1.5px solid var(--border);
  border-radius: var(--radius-lg);
  padding: 20px 12px;
  text-align: center;
  text-decoration: none;
  color: var(--txt-main);
  background: var(--surface);
  transition: all 0.2s;
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 8px;
  cursor: pointer;
}

.category-item:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
  box-shadow: var(--shadow-lg);
  transform: translateY(-2px);
}

.category-item i {
  font-size: 24px;
}

.category-item span {
  font-size: 13px;
  font-weight: 600;
}

/* Info Box */
.info-alert {
  background: #fffbeb;
  border: 1.5px solid #fde68a;
  border-radius: var(--radius-lg);
  padding: 20px;
  display: flex;
  align-items: flex-start;
  gap: 16px;
  margin-top: 20px;
}

[data-theme="dark"] .info-alert {
  background: #3a3a1f;
  border-color: #56540a;
}

.info-alert i {
  font-size: 20px;
  color: var(--amber-main);
  flex-shrink: 0;
  margin-top: 2px;
}

.info-alert-title {
  font-weight: 700;
  color: var(--amber-main);
  margin-bottom: 6px;
  font-size: 15px;
}

.info-alert-text {
  font-size: 14px;
  color: var(--txt-sub);
  line-height: 1.6;
}

[data-theme="dark"] .info-alert-text {
  color: #cbd5e1;
}

.info-alert-text a {
  color: var(--sky-primary);
  text-decoration: none;
  font-weight: 600;
  display: inline-flex;
  align-items: center;
  gap: 4px;
  margin-left: 6px;
}

/* Map Frame */
.map-frame {
  background: linear-gradient(135deg, var(--emerald-bg), var(--sky-bg));
  border: 1.5px dashed var(--sky-light);
  border-radius: var(--radius-lg);
  padding: 32px;
  text-align: center;
}

[data-theme="dark"] .map-frame {
  background: linear-gradient(135deg, #0d2d24, #0c2d42);
  border-color: #0c4a6e;
}

.map-icon {
  font-size: 48px;
  margin-bottom: 12px;
}

.map-title {
  font-size: 16px;
  font-weight: 700;
  color: var(--txt-main);
  margin-bottom: 8px;
}

[data-theme="dark"] .map-title {
  color: #ffffff;
}

.map-desc {
  font-size: 14px;
  color: var(--txt-sub);
  line-height: 1.7;
}

[data-theme="dark"] .map-desc {
  color: rgba(255, 255, 255, 0.8);
}

/* Footer */
.app-footer {
  background: var(--surface);
  border-top: 1px solid var(--border);
  padding: 32px 24px;
  margin-top: 60px;
}

.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 20px;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 800;
  font-size: 15px;
  color: var(--txt-main);
  text-decoration: none;
}

.footer-logo em {
  color: var(--sky-primary);
  font-style: normal;
}

.footer-info {
  font-size: 13px;
  color: var(--txt-muted);
  text-align: center;
  line-height: 1.7;
}

.footer-copy {
  font-size: 13px;
  color: var(--txt-muted);
  text-align: right;
  line-height: 1.7;
}

/* Responsive */
@media (max-width: 1100px) {
  .content-grid { grid-template-columns: 1fr; }
  .category-grid { grid-template-columns: repeat(3, 1fr); }
}

@media (max-width: 768px) {
  .app-header { padding: 12px 16px; }
  .app-container { padding: 16px 16px 48px; }
  .hero-section { padding: 28px 20px; }
  .hero-title { font-size: 24px; }
  .category-grid { grid-template-columns: repeat(3, 1fr); }
  .footer-inner { flex-direction: column; text-align: center; }
  .footer-copy { text-align: center; }
}

/* Dark Mode Specific */
[data-theme="dark"] .card-icon {
  background: #0c2d42;
}

[data-theme="dark"] .info-alert {
  background: #3a3a1f;
  border-color: #56540a;
}

[data-theme="dark"] .info-alert i {
  color: #fbbf24;
}

[data-theme="dark"] .info-alert-title {
  color: #fbbf24;
}
</style>
</head>
<body>

<header class="app-header">
  <a href="/CAN/main_guest.jsp" class="logo-brand">
    <span class="logo-icon">🧭</span>
    CAN <em>내비</em>
  </a>
  <div class="header-right">
    <span class="badge-role">게스트</span>
    <a href="/CAN/guest_to_login.jsp" class="btn-logout">
      <i class="bi bi-box-arrow-in-right"></i> 로그인
    </a>
    <button class="theme-toggle" onclick="toggleTheme()">🌙</button>
  </div>
</header>

<div class="app-container">

  <div class="hero-section">
    <div class="hero-title">교내 자원을 <em>검색</em>하세요</div>
    <div class="hero-desc">로그인 없이 자산 검색 및 상세보기가 가능합니다.<br>예약 및 길안내는 로그인 후 이용하세요.</div>
    <form method="get" action="/CAN/search.jsp">
      <div class="search-container">
        <input type="text" name="keyword" placeholder="자산번호, 품목명, 위치 검색...">
        <button type="submit" class="btn-search"><i class="bi bi-search"></i>검색</button>
      </div>
    </form>
  </div>

  <div class="content-grid">
    <div>
      <div class="card-box">
        <div class="card-header">
          <div class="card-icon"><i class="bi bi-grid-3x3-gap"></i></div>
          <div class="card-header-text">
            <h3>카테고리별 검색</h3>
            <p>분류별로 바로 검색하세요</p>
          </div>
        </div>
        <div class="card-body">
          <div class="category-grid">
            <a href="/CAN/search.jsp?type=공기구비품" class="category-item">
              <i class="bi bi-tools" style="color: var(--sky-primary)"></i>
              <span>공기구비품</span>
            </a>
            <a href="/CAN/search.jsp?type=집기비품" class="category-item">
              <i class="bi bi-laptop" style="color: var(--emerald-primary)"></i>
              <span>집기비품</span>
            </a>
            <a href="/CAN/search.jsp?type=무형고정자산" class="category-item">
              <i class="bi bi-code-square" style="color: #7c3aed"></i>
              <span>소프트웨어</span>
            </a>
            <a href="/CAN/search.jsp?keyword=공학관" class="category-item">
              <i class="bi bi-building" style="color: var(--amber-main)"></i>
              <span>공학관</span>
            </a>
            <a href="/CAN/professor.jsp" class="category-item">
              <i class="bi bi-people" style="color: var(--emerald-primary)"></i>
              <span>교수 자원</span>
            </a>
            <a href="/CAN/search.jsp" class="category-item">
              <i class="bi bi-grid"></i>
              <span>전체보기</span>
            </a>
          </div>
        </div>
      </div>

      <div class="info-alert">
        <i class="bi bi-info-circle-fill"></i>
        <div>
          <div class="info-alert-title">게스트 이용 안내</div>
          <div class="info-alert-text">
            게스트는 <strong>검색·상세보기</strong>만 가능합니다.
            <a href="/CAN/guest_to_login.jsp"><i class="bi bi-box-arrow-in-right"></i>로그인하여 예약 및 길찾기</a>
          </div>
        </div>
      </div>
    </div>

    <div>
      <div class="card-box">
        <div class="card-header">
          <div class="card-icon"><i class="bi bi-compass"></i></div>
          <div class="card-header-text">
            <h3>실내 네비게이션</h3>
            <p>로그인 후 이용 가능</p>
          </div>
        </div>
        <div class="card-body">
          <div class="map-frame">
            <div class="map-icon">🧭</div>
            <div class="map-title">캠퍼스 길찾기</div>
            <div class="map-desc">로그인 후 현재 위치 기준<br>실내 경로 안내를 이용할 수 있습니다</div>
          </div>
        </div>
      </div>
    </div>
  </div>

</div>

<footer class="app-footer">
  <div class="footer-inner">
    <a href="/CAN/main_guest.jsp" class="footer-logo">
      CAN <em>내비</em>
    </a>
    <div class="footer-info">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 · 권동해 · 원태연 · 이수혁
    </div>
    <div class="footer-copy">
      ICT폴리텍대학 교내 자원 내비게이션 시스템<br>
      Copyright © 2026 ICT CAN. All rights reserved.
    </div>
  </div>
</footer>

<script>
function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  html.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);
  updateThemeIcon();
}

function updateThemeIcon() {
  const theme = document.documentElement.getAttribute('data-theme');
  const btn = document.querySelector('.theme-toggle');
  btn.textContent = theme === 'dark' ? '☀️' : '🌙';
}

document.addEventListener('DOMContentLoaded', function() {
  const savedTheme = localStorage.getItem('theme') || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
  document.documentElement.setAttribute('data-theme', savedTheme);
  updateThemeIcon();
});
</script>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
