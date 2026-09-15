<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    if (loginUser == null) {
        response.sendRedirect("/CAN/campuslogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>ICT CAN — 교수 자원</title>

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
  --emerald-light: #f0fdf4;
  --amber-main: #d97706;
  --amber-light: #fffbeb;
  --red-main: #dc2626;
  --red-light: #fef2f2;
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-md: 12px;
  --radius-pill: 999px;
  --shadow-air: 0 20px 40px -15px rgba(2, 132, 199, 0.15);
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
  --font-plus: 'Plus Jakarta Sans', sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --header-bg: rgba(255, 255, 255, 0.85);
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
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid var(--border-color);
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
  font-family: var(--font-plus);
  font-weight: 800;
  font-size: 1.35rem;
  color: var(--txt-main);
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-badge {
  background: linear-gradient(135deg, #38bdf8 0%, #0284c7 100%);
  color: #ffffff;
  font-size: 0.68rem;
  font-weight: 800;
  padding: 3px 9px;
  border-radius: var(--radius-pill);
}

.nav-link-btn {
  font-weight: 700;
  font-size: 0.925rem;
  color: var(--txt-sub);
  padding: 8px 18px;
  border-radius: var(--radius-pill);
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.nav-link-btn:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

.user-tag-pill {
  background: var(--surface);
  border: 1px solid #cbd5e1;
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--txt-main);
}

.main-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

.hero-search-card {
  background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 30%, #7dd3fc 100%);
  border-radius: var(--radius-xl);
  padding: 2.5rem 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 24px rgba(2, 132, 199, 0.2);
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(2, 132, 199, 0.3);
}

[data-theme="dark"] .hero-search-card {
  background: linear-gradient(135deg, #0f172a 0%, #164e63 40%, #0d6147 100%);
}

.hero-search-card::after {
  content: '';
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 200px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0%, rgba(2, 132, 199, 0.08) 100%);
  clip-path: polygon(15% 0%, 100% 0%, 100% 100%, 0% 100%);
  z-index: 0;
  pointer-events: none;
}

.hero-search-content {
  position: relative;
  z-index: 1;
}

.hero-title {
  font-size: 1.8rem;
  font-weight: 800;
  color: #0f172a;
  margin-bottom: 0.5rem;
}

[data-theme="dark"] .hero-title {
  color: #ffffff;
}

.hero-subtitle {
  color: #64748b;
  font-size: 0.95rem;
  margin-bottom: 1rem;
}

[data-theme="dark"] .hero-subtitle {
  color: rgba(255, 255, 255, 0.85);
}

.results-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 1.75rem;
  box-shadow: var(--shadow-soft);
  border: 1px solid #f1f5f9;
  margin-bottom: 2rem;
}

.results-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.results-title {
  font-size: 1.1rem;
  font-weight: 800;
  color: var(--txt-main);
}

.results-subtitle {
  font-size: 0.85rem;
  color: var(--txt-muted);
  font-family: var(--font-mono);
}

.table-air {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.925rem;
}

.table-air th {
  background: var(--sky-bg);
  color: var(--txt-main);
  font-family: var(--font-mono);
  font-size: 0.8rem;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
  padding: 12px 16px;
  text-align: left;
  border-bottom: 2px solid var(--sky-light);
}

.table-air td {
  padding: 14px 16px;
  border-bottom: 1px solid var(--border-color);
  color: var(--txt-sub);
  vertical-align: middle;
}

.table-air tr:hover td {
  background: var(--sky-bg);
}

.table-air tr:last-child td {
  border-bottom: none;
}

.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 0.8rem;
  font-weight: 700;
  font-family: var(--font-mono);
  white-space: nowrap;
}

.badge-success {
  background: #dcfce7;
  color: #15803d;
}

.badge-warning {
  background: var(--amber-light);
  color: #b45309;
}

.btn-action {
  background: transparent;
  border: 1.5px solid var(--border-color);
  color: var(--txt-sub);
  padding: 6px 12px;
  border-radius: var(--radius-md);
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
  font-family: var(--font-mono);
}

.btn-action:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
  background: var(--sky-bg);
}

.btn-action-edit {
  border-color: var(--amber-main);
  color: var(--amber-main);
}

.btn-action-edit:hover {
  background: rgba(217, 119, 6, 0.1);
}

.tab-bar {
  display: flex;
  gap: 4px;
  border-bottom: 2px solid var(--border-color);
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.tab-btn {
  font-family: var(--font-mono);
  font-size: 0.85rem;
  font-weight: 600;
  padding: 8px 14px;
  border: none;
  background: transparent;
  color: var(--txt-muted);
  cursor: pointer;
  transition: all 0.15s;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  white-space: nowrap;
}

.tab-btn:hover {
  color: var(--sky-primary);
}

.tab-btn.active {
  color: var(--sky-primary);
  border-bottom-color: var(--sky-primary);
  font-weight: 700;
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
}

.alert-success {
  background: #dcfce7;
  border: 1.5px solid #86efac;
  border-radius: var(--radius-md);
  color: #15803d;
  padding: 12px 16px;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.alert-danger {
  background: var(--red-light);
  border: 1.5px solid #fca5a5;
  border-radius: var(--radius-md);
  color: var(--red-main);
  padding: 12px 16px;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

.app-footer {
  background: var(--surface);
  border-top: 1px solid #e2e8f0;
  color: var(--txt-sub);
  padding: 2.5rem 0;
  margin-top: 4rem;
  font-size: 0.875rem;
}

@media(max-width: 768px) {
  .hero-title { font-size: 1.5rem; }
  .tab-bar { flex-direction: column; gap: 0; }
  .tab-btn { width: 100%; text-align: left; margin-bottom: 0; border-radius: 0; padding: 12px 16px; }
  .table-air { font-size: 0.8rem; }
  .table-air th, .table-air td { padding: 10px 12px; }
}

[data-theme="dark"] .results-table th {
  background: #1e3a5f;
  color: #f1f5f9;
}

[data-theme="dark"] .results-table td {
  color: #e2e8f0;
}

[data-theme="dark"] .results-card {
  background: #1e293b;
  color: #f1f5f9;
}

[data-theme="dark"] .table-air th {
  background: #1e3a5f;
  border-bottom-color: #0c4a6e;
  color: #f1f5f9;
}

[data-theme="dark"] .table-air td {
  border-bottom-color: #334155;
  color: #e2e8f0;
}

[data-theme="dark"] .table-air tr:hover td {
  color: #f1f5f9;
  background: #1e3a5f;
}

    </style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_professor.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge">PROFESSOR</span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/search.jsp"><i class="bi bi-search"></i> 자원 검색</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/main_professor.jsp"><i class="bi bi-house"></i> 대시보드</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %> 교수</span>
            </div>
          </li>

          <li class="nav-item">
            <button type="button" class="theme-toggle" onclick="toggleTheme()">
              <i class="bi bi-moon" id="themeIcon"></i>
            </button>
          </li>

          <li class="nav-item">
            <form action="/CAN/logout" method="post" class="m-0">
              <button type="submit" class="btn border-0 bg-transparent nav-link-btn text-danger">
                <i class="bi bi-box-arrow-right"></i> 로그아웃
              </button>
            </form>
          </li>
        </ul>
      </div>
    </nav>
  </div>
</header>

<main class="main-container">

  <!-- HERO SEARCH SECTION -->
  <div class="hero-search-card">
    <div class="hero-search-content">
      <div class="hero-subtitle">ICT CAN · 교수 자원 관리</div>
      <h1 class="hero-title">교수도 <strong style="color: #4ade80;">자원</strong>입니다 👨‍🏫</h1>
      <p class="hero-subtitle"><%= loginName %> 교수님의 소프트웨어 및 장비 자원을 관리하세요.</p>
    </div>
  </div>

  <!-- TAB NAVIGATION -->
  <div class="tab-bar">
    <button class="tab-btn active" onclick="showTab('search', this)">
      <i class="bi bi-search me-1"></i>자원 검색
    </button>
    <button class="tab-btn" onclick="showTab('swlist', this)">
      <i class="bi bi-pc-display me-1"></i>PC별 SW 현황
    </button>
    <button class="tab-btn" onclick="showTab('register', this)">
      <i class="bi bi-plus-circle me-1"></i>SW 등록
    </button>
    <button class="tab-btn" id="editTabBtn" onclick="showTab('edit', this)" style="display:none">
      <i class="bi bi-pencil me-1"></i>SW 수정
    </button>
    <button class="tab-btn" id="deleteTabBtn" onclick="showTab('delete', this)" style="display:none">
      <i class="bi bi-trash me-1"></i>SW 삭제
    </button>
  </div>

  <!-- ── 검색 탭 ── -->
  <div class="tab-content active" id="tab-search">
    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">자원 검색</div>
          <div class="results-subtitle">소프트웨어 및 장비 검색</div>
        </div>
      </div>

      <form method="get" action="/CAN/search.jsp" style="margin-bottom:20px">
        <div class="row g-2 align-items-end">
          <div class="col-lg-6">
            <input type="text" name="keyword" class="form-control" placeholder="자원명, 위치, 소프트웨어명 검색...">
          </div>
          <div class="col-lg-3">
            <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search me-1"></i>검색</button>
          </div>
        </div>
      </form>

      <div class="table-responsive">
        <table class="table-air">
          <thead>
            <tr>
              <th>번호</th>
              <th>자원명</th>
              <th>위치</th>
              <th>소프트웨어</th>
              <th>활용여부</th>
              <th>관리</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td><span style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)">001</span></td>
              <td><strong>노트북 Dell XPS</strong></td>
              <td><i class="bi bi-geo-alt" style="color:var(--emerald-main)"></i> 공학관 301호</td>
              <td><span class="badge badge-warning">MATLAB R2024</span></td>
              <td><span class="badge badge-success">사용가능</span></td>
              <td>
                <a href="#" class="btn-action">상세</a>
              </td>
            </tr>
            <tr>
              <td><span style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)">002</span></td>
              <td><strong>워크스테이션 A</strong></td>
              <td><i class="bi bi-geo-alt" style="color:var(--emerald-main)"></i> 연구실 402호</td>
              <td><span class="badge badge-warning">ANSYS 2024</span></td>
              <td><span class="badge" style="background:#fee2e2;color:#b91c1c">사용중</span></td>
              <td>
                <a href="#" class="btn-action">상세</a>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>

  <!-- ── PC별 SW 현황 탭 ── -->
  <div class="tab-content" id="tab-swlist">
    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">PC별 설치 소프트웨어 현황</div>
          <div class="results-subtitle">총 3대 (샘플)</div>
        </div>
      </div>

      <div style="margin-bottom:18px">
        <input type="text" placeholder="PC명, 위치, 소프트웨어명 검색..." class="form-control">
      </div>

      <div style="background: #f0f9ff; border: 1px solid #bae6fd; border-radius: var(--radius-lg); padding: 1.5rem; margin-bottom: 1.5rem;">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:1rem">
          <div style="width:40px;height:40px;border-radius:10px;background:var(--sky-light);display:flex;align-items:center;justify-content:center;color:var(--sky-primary);font-size:1.2rem">
            <i class="bi bi-laptop"></i>
          </div>
          <div>
            <div style="font-weight:700;font-size:0.95rem">노트북 Dell XPS 15 <small style="color:var(--txt-muted);font-weight:400">#001</small></div>
            <div style="font-size:0.8rem;color:var(--txt-muted)"><i class="bi bi-geo-alt me-1"></i>공학관 301호</div>
          </div>
          <span class="badge badge-success ms-auto">사용가능</span>
        </div>
        <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:0.5rem">설치 소프트웨어</div>
        <div style="display:flex;flex-wrap:wrap;gap:6px">
          <span class="badge badge-warning">MATLAB R2024b</span>
          <span class="badge badge-warning">AutoCAD 2024</span>
          <span class="badge badge-warning">MS Office 365</span>
        </div>
      </div>

      <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: var(--radius-lg); padding: 1.5rem;">
        <div style="display:flex;align-items:center;gap:12px;margin-bottom:1rem">
          <div style="width:40px;height:40px;border-radius:10px;background:#dcfce7;display:flex;align-items:center;justify-content:center;color:var(--emerald-main);font-size:1.2rem">
            <i class="bi bi-pc-display"></i>
          </div>
          <div>
            <div style="font-weight:700;font-size:0.95rem">워크스테이션 A <small style="color:var(--txt-muted);font-weight:400">#002</small></div>
            <div style="font-size:0.8rem;color:var(--txt-muted)"><i class="bi bi-geo-alt me-1"></i>연구실 402호</div>
          </div>
          <span class="badge" style="background:#fee2e2;color:#b91c1c;margin-left:auto">사용중</span>
        </div>
        <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;letter-spacing:.06em;margin-bottom:0.5rem">설치 소프트웨어</div>
        <div style="display:flex;flex-wrap:wrap;gap:6px">
          <span class="badge badge-warning">ANSYS 2024</span>
          <span class="badge badge-warning">MATLAB R2024b</span>
          <span class="badge badge-warning">SolidWorks 2024</span>
        </div>
      </div>
    </div>
  </div>

  <!-- ── SW 등록 탭 ── -->
  <div class="tab-content" id="tab-register">
    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">소프트웨어 등록</div>
          <div class="results-subtitle">새 SW 정보를 등록하세요</div>
        </div>
      </div>

      <form>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label fw-bold">소프트웨어명 *</label>
            <input class="form-control" type="text" placeholder="예) MATLAB R2024b">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">버전</label>
            <input class="form-control" type="text" placeholder="예) R2024b">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">설치 자원 (장비명) *</label>
            <input class="form-control" type="text" placeholder="예) 노트북 Dell XPS (001)">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">라이선스 종류</label>
            <select class="form-select">
              <option>교육용 라이선스</option>
              <option>연구용 라이선스</option>
              <option>오픈소스</option>
              <option>상용</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">라이선스 만료일</label>
            <input class="form-control" type="date">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">담당 교수</label>
            <input class="form-control" type="text" value="<%= loginName %>">
          </div>
          <div class="col-12">
            <label class="form-label fw-bold">비고</label>
            <textarea class="form-control" rows="3" placeholder="사용 목적, 제한 사항 등"></textarea>
          </div>
          <div class="col-12">
            <button type="button" class="btn btn-success">
              <i class="bi bi-check-circle me-1"></i>등록하기
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- ── SW 수정 탭 ── -->
  <div class="tab-content" id="tab-edit">
    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">소프트웨어 수정</div>
        </div>
      </div>

      <form>
        <div class="row g-3">
          <div class="col-md-6">
            <label class="form-label fw-bold">자원 번호</label>
            <input class="form-control" type="text" id="edit-id" readonly style="background:#f0f4f9;color:var(--txt-muted)">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">소프트웨어명 *</label>
            <input class="form-control" type="text" id="edit-sw" placeholder="소프트웨어명">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">버전</label>
            <input class="form-control" type="text" id="edit-ver" placeholder="예) R2024b">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">라이선스 종류</label>
            <select class="form-select" id="edit-license">
              <option>교육용 라이선스</option>
              <option>연구용 라이선스</option>
              <option>오픈소스</option>
              <option>상용</option>
            </select>
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">라이선스 만료일</label>
            <input class="form-control" type="date" id="edit-expire">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">담당 교수</label>
            <input class="form-control" type="text" id="edit-prof" value="<%= loginName %>">
          </div>
          <div class="col-12">
            <label class="form-label fw-bold">비고</label>
            <textarea class="form-control" id="edit-note" rows="2" placeholder="수정 사유 등"></textarea>
          </div>
          <div class="col-12 d-flex gap-2">
            <button type="button" class="btn btn-primary" onclick="saveEdit()">
              <i class="bi bi-check-circle me-1"></i>수정 완료
            </button>
            <button type="button" class="btn btn-outline-secondary" onclick="cancelEdit()">
              <i class="bi bi-x-circle me-1"></i>취소
            </button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- ── SW 삭제 탭 ── -->
  <div class="tab-content" id="tab-delete">
    <div class="results-card" style="border-color:#fca5a5">
      <div class="results-header" style="background:var(--red-light);padding:1rem;margin:-1.75rem -1.75rem 1.5rem;border-bottom:1.5px solid #fca5a5;border-radius:var(--radius-xl) var(--radius-xl) 0 0">
        <div>
          <div class="results-title" style="color:var(--red-main)">소프트웨어 삭제</div>
          <div class="results-subtitle">삭제 후 복구가 불가능합니다</div>
        </div>
      </div>

      <div style="background:var(--red-light);border:1.5px solid #fca5a5;border-radius:var(--radius-lg);padding:1.5rem;margin-bottom:1rem">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:1rem;color:var(--red-main);font-weight:700;font-size:0.95rem">
          <i class="bi bi-exclamation-triangle-fill"></i>삭제할 소프트웨어 정보
        </div>
        <div class="row g-3">
          <div class="col-md-4">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">자원 번호</div>
            <div style="font-weight:700;font-size:0.95rem" id="del-id">-</div>
          </div>
          <div class="col-md-4">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">PC명</div>
            <div style="font-weight:700;font-size:0.95rem" id="del-pc">-</div>
          </div>
          <div class="col-md-4">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">소프트웨어명</div>
            <div style="font-weight:700;font-size:0.95rem;color:var(--red-main)" id="del-sw">-</div>
          </div>
        </div>
      </div>

      <div style="background:var(--amber-light);border:1px solid #fde68a;border-radius:var(--radius-md);padding:12px 14px;margin-bottom:1rem;font-size:0.9rem;color:#713f12;display:flex;align-items:center;gap:8px">
        <i class="bi bi-info-circle me-1"></i>삭제 후 복구가 불가능합니다. 삭제 사유를 입력해 주세요.
      </div>

      <div style="margin-bottom:1rem">
        <label class="form-label fw-bold">삭제 사유 *</label>
        <textarea class="form-control" id="del-reason" rows="3" placeholder="예) 라이선스 만료, 소프트웨어 교체 등"></textarea>
      </div>
      <div class="d-flex gap-2">
        <button type="button" class="btn btn-danger" onclick="confirmDelete()">
          <i class="bi bi-trash me-1"></i>삭제 확정
        </button>
        <button type="button" class="btn btn-outline-secondary" onclick="cancelDelete()">
          <i class="bi bi-x-circle me-1"></i>취소
        </button>
      </div>
    </div>
  </div>

</main>

<!-- FOOTER -->
<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold" style="color:var(--txt-main);margin-bottom:0.5rem">
          <i class="bi bi-compass-fill me-1 text-info"></i> ICT CAN Navigation System
        </div>
        <div style="color:var(--txt-muted)">ICT폴리텍대학 교내 자원 내비게이션 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="fw-bold" style="color:var(--txt-main)">Made by AI 소프트웨어학과</div>
        <div style="color:var(--txt-muted)">박승순 &middot; 권동해 &middot; 원태연 &middot; 이수혁</div>
        <div class="mt-1" style="opacity:0.75;color:var(--txt-muted)">&copy; 2026 ICT CAN. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  if(btn) btn.classList.add('active');
}

function openDelete(id, pc, sw) {
  document.getElementById('del-id').textContent = id;
  document.getElementById('del-pc').textContent = pc;
  document.getElementById('del-sw').textContent = sw;
  document.getElementById('del-reason').value = '';
  document.getElementById('deleteTabBtn').style.display = '';
  showTab('delete', document.getElementById('deleteTabBtn'));
}

function confirmDelete() {
  var reason = document.getElementById('del-reason').value.trim();
  if (!reason) { alert('삭제 사유를 입력해 주세요.'); return; }
  var sw = document.getElementById('del-sw').textContent;
  alert('[' + sw + '] 삭제가 완료됐습니다!\n(프로토타입: DB 연동 시 실제 삭제됩니다)');
  cancelDelete();
}

function cancelDelete() {
  document.getElementById('deleteTabBtn').style.display = 'none';
  showTab('search', document.querySelectorAll('.tab-btn')[0]);
}

function openEdit(id, sw) {
  document.getElementById('edit-id').value = id;
  document.getElementById('edit-sw').value = sw;
  document.getElementById('editTabBtn').style.display = '';
  showTab('edit', document.getElementById('editTabBtn'));
}

function saveEdit() {
  alert('수정이 완료됐습니다!\n(프로토타입: DB 연동 시 실제 저장됩니다)');
  cancelEdit();
}

function cancelEdit() {
  document.getElementById('editTabBtn').style.display = 'none';
  showTab('search', document.querySelectorAll('.tab-btn')[0]);
}

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
