<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jsp" %>
<%
// ---- 접근 권한 체크: 로그인 필요, 외부인(visitor)은 접근 불가 ----
String loginUser=(String)session.getAttribute("loginUser");
String loginRole=(String)session.getAttribute("loginRole");
if(loginUser==null){ response.sendRedirect("/CAN/campuslogin.jsp"); return; }
if(!("student".equals(loginRole) || "assistant".equals(loginRole) || "professor".equals(loginRole) || "admin".equals(loginRole))){
    response.sendRedirect("/CAN/campuslogin.jsp"); return;
}
boolean isAdmin = "admin".equals(loginRole);
String roleLabel =
    "student".equals(loginRole)   ? "학부생" :
    "assistant".equals(loginRole) ? "조교"   :
    "professor".equals(loginRole) ? "교수"   : "관리자";
String roleBadge =
    "student".equals(loginRole)   ? "STUDENT" :
    "assistant".equals(loginRole) ? "ASSISTANT" :
    "professor".equals(loginRole) ? "PROFESSOR" : "ADMIN";

int resourceCount=0, locationCount=0, vehicleCount=0, requestCount=0;
Connection con=null; Statement st=null; ResultSet rs=null;

// 등록 자원 조회 (실제 DB 연동 - assets 테이블)
try {
    con=getConnection(); st=con.createStatement();
    rs=st.executeQuery("SELECT COUNT(*) FROM assets");
    if(rs.next()) resourceCount=rs.getInt(1);
    rs.close();
} catch(Exception e) {
    resourceCount=0;
} finally {
    close(rs,st,con);
}

// 아직 연동되지 않은 DB는 0으로 표시
locationCount=0;
vehicleCount=0;
requestCount=0;
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>운송 관리 대시보드</title>

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

  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-pill: 999px;

  --shadow-air: 0 20px 40px -15px rgba(2, 132, 199, 0.15);
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);

  --font-main: 'Pretendard', -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
  --header-bg: rgba(255, 255, 255, 0.85);
  --border-color: rgba(226, 232, 240, 0.8);
  
  --stat-label-color: #334155;
}

[data-theme="dark"] {
  --bg-app: #0f172a;
  --surface: #1e293b;
  --txt-main: #f8fafc;
  --txt-sub: #e2e8f0;
  --txt-muted: #94a3b8;
  --sky-primary: #38bdf8;
  --sky-hover: #0ea5e9;
  --sky-light: #0c4a6e;
  --sky-bg: #1e3a5f;
  --header-bg: rgba(30, 41, 59, 0.95);
  --border-color: rgba(71, 85, 105, 0.6);

  --stat-label-color: #f8fafc;
}

body {
  font-family: var(--font-main);
  background: linear-gradient(180deg,
    #dbeafe 0%,
    #e0f2fe 18%,
    #f0f4f9 45%,
    #f0f4f9 100%
  );
  background-repeat: no-repeat;
  background-attachment: fixed;
  color: var(--txt-main);
  line-height: 1.6;
  margin: 0;
  padding: 0;
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

.brand-logo {
  font-family: 'Plus Jakarta Sans', sans-serif;
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

[data-theme="dark"] .brand-logo { color: #f1f5f9; }
[data-theme="dark"] .nav-link-btn { color: #e2e8f0; font-weight: 700; }
[data-theme="dark"] .nav-link-btn:hover { background: var(--sky-bg); color: #38bdf8; }

.theme-toggle {
  background: none;
  border: none;
  color: var(--txt-sub);
  cursor: pointer;
  font-size: 1.2rem;
  transition: all 0.2s;
  padding: 6px 12px;
  border-radius: 999px;
  display: inline-flex;
  align-items: center;
}

.theme-toggle:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

[data-theme="dark"] .theme-toggle { color: #cbd5e1; }
[data-theme="dark"] .theme-toggle:hover { background: var(--sky-bg); color: #38bdf8; }

.user-tag-pill {
  background: var(--surface);
  border: 1px solid var(--border-color);
  padding: 6px 16px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 8px;
  font-size: 0.875rem;
  font-weight: 700;
  color: var(--txt-main);
}

.hero-balanced-section {
  padding-top: 1.5rem;
  padding-bottom: 2rem;
}

.welcome-profile-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2rem;
  box-shadow: var(--shadow-soft);
  height: 100%;
  display: flex;
  flex-direction: column;
  justify-content: center;
}

.hero-welcome-badge {
  display: inline-flex;
  align-items: center;
  gap: 6px;
  background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%);
  color: #0369a1;
  font-weight: 800;
  font-size: 0.8rem;
  padding: 5px 14px;
  border-radius: var(--radius-pill);
  margin-bottom: 0.75rem;
  width: fit-content;
  border: 1px solid #7dd3fc;
}

.hero-title-main {
  font-size: 1.8rem;
  font-weight: 800;
  letter-spacing: -0.8px;
  margin-bottom: 0.4rem;
  color: var(--txt-main);
}

.hero-title-main span { color: var(--sky-primary); }

.hero-subtitle-text {
  font-size: 0.95rem;
  color: var(--txt-sub);
  margin: 0;
}

.hero-side-stats {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 1.5rem;
  box-shadow: var(--shadow-soft);
  display: flex;
  flex-direction: column;
  gap: 12px;
  height: 100%;
  justify-content: center;
}

.stat-item-pill {
  padding: 14px 20px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 16px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.stat-item-blue { background: #f0f9ff; border: 1px solid #bae6fd; }
.stat-item-green { background: #f0fdf4; border: 1px solid #bbf7d0; }
.stat-item-amber { background: #fffbeb; border: 1px solid #fde68a; }

.stat-item-blue .stat-pill-icon { background: #ffffff; color: #0284c7; }
.stat-item-green .stat-pill-icon { background: #ffffff; color: #16a34a; }
.stat-item-amber .stat-pill-icon { background: #ffffff; color: #d97706; }

[data-theme="dark"] .stat-item-blue {
  background: #152942;
  border: 1px solid #1d4ed8;
}
[data-theme="dark"] .stat-item-blue .stat-pill-icon {
  background: #0f1e33;
  color: #38bdf8;
  border: 1px solid #1e40af;
}

[data-theme="dark"] .stat-item-green {
  background: #113322;
  border: 1px solid #15803d;
}
[data-theme="dark"] .stat-item-green .stat-pill-icon {
  background: #0a2417;
  color: #4ade80;
  border: 1px solid #166534;
}

[data-theme="dark"] .stat-item-amber {
  background: #362f13;
  border: 1px solid #a16207;
}
[data-theme="dark"] .stat-item-amber .stat-pill-icon {
  background: #241e0a;
  color: #fbbf24;
  border: 1px solid #854d0e;
}

.stat-pill-icon {
  width: 44px;
  height: 44px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.stat-pill-label {
  font-size: 0.9rem;
  font-weight: 800;
  color: var(--stat-label-color);
}

.stat-pill-num {
  font-size: 1.25rem;
  font-weight: 800;
  font-family: var(--font-mono);
}

.borderless-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2.25rem;
  box-shadow: var(--shadow-soft);
  margin-bottom: 2rem;
  border: 1px solid var(--border-color);
}

/* ---- ICON FLOW DIAGRAM ---- */
.flow-legend {
  display: flex;
  gap: 18px;
  flex-wrap: wrap;
  margin-bottom: 1.25rem;
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--txt-muted);
}
.flow-legend span { display: inline-flex; align-items: center; gap: 6px; }
.flow-legend i { font-size: 0.6rem; }

.flow-track {
  display: flex;
  flex-wrap: nowrap;
  align-items: flex-start;
  gap: 0;
  overflow-x: auto;
  padding-bottom: 8px;
}

.flow-step {
  display: flex;
  flex-direction: column;
  align-items: center;
  width: 104px;
  text-align: center;
  flex-shrink: 0;
}

.flow-icon-circle {
  width: 54px;
  height: 54px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.3rem;
  margin-bottom: 8px;
  box-shadow: var(--shadow-soft);
  border: 1px solid transparent;
}

.flow-icon-sky     { background: var(--sky-bg);       color: var(--sky-primary);  border-color: #bae6fd; }
.flow-icon-emerald { background: #f0fdf4;         color: var(--emerald-main); border-color: #bbf7d0; }
.flow-icon-amber   { background: #fffbeb;         color: var(--amber-main);   border-color: #fde68a; }

[data-theme="dark"] .flow-icon-sky { background: #1e3a5f; color: #38bdf8; border-color: #0c4a6e; }
[data-theme="dark"] .flow-icon-emerald { background: #1a3a2a; color: #4ade80; border-color: #1e5a48; }
[data-theme="dark"] .flow-icon-amber { background: #3a3a1f; color: #fbbf24; border-color: #56540a; }

.flow-step-num {
  font-family: var(--font-mono);
  font-size: 0.68rem;
  font-weight: 700;
  color: var(--txt-muted);
  margin-bottom: 2px;
}

.flow-step-label {
  font-size: 0.78rem;
  font-weight: 700;
  color: var(--txt-sub);
  line-height: 1.3;
}

.flow-connector {
  display: flex;
  align-items: center;
  justify-content: center;
  color: var(--txt-muted);
  font-size: 1.05rem;
  width: 26px;
  height: 54px;
  flex-shrink: 0;
}

.table-air {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.925rem;
}

.table-air th {
  color: var(--txt-muted);
  font-weight: 700;
  padding: 12px 16px;
  border-bottom: 2px solid var(--border-color);
  text-align: left;
}

.table-air td {
  padding: 18px 16px;
  border-bottom: 1px solid var(--border-color);
  color: var(--txt-main);
  vertical-align: middle;
}

.table-air tr:last-child td { border-bottom: none; }

.status-chip {
  padding: 5px 12px;
  border-radius: var(--radius-pill);
  font-size: 0.775rem;
  font-weight: 800;
}

.chip-ok { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
.chip-pending { background: #fef3c7; color: #b45309; border: 1px solid #fcd34d; }

[data-theme="dark"] .chip-ok { background: #064e3b; color: #6ee7b7; border-color: #047857; }

.app-footer {
  background: var(--surface);
  border-top: 1px solid var(--border-color);
  color: var(--txt-sub);
  padding: 2.5rem 0;
  margin-top: 4rem;
  font-size: 0.875rem;
}
</style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/dashboard.jsp">
        <i class="bi bi-truck-front text-info fs-3"></i>
        <span>운송 <strong>관리</strong></span>
        <span class="brand-badge"><%=roleBadge%></span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item"><a class="nav-link-btn" href="transportRequest.jsp"><i class="bi bi-arrow-repeat"></i> 요청</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="transportStatus.jsp"><i class="bi bi-play-circle"></i> 현황</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="transportHistory.jsp"><i class="bi bi-clock-history"></i> 이력</a></li>
          <% if(isAdmin){ %>
          <li class="nav-item ms-lg-3"><a class="nav-link-btn" href="resource.jsp"><i class="bi bi-boxes"></i> 자원 관리</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="location.jsp"><i class="bi bi-geo-alt"></i> 위치 관리</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="vehicle.jsp"><i class="bi bi-truck"></i> 운송체 관리</a></li>
          <% } %>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%=roleLabel%></span>
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

<main class="container-xl pb-5">

  <!-- 1. SYSTEM FLOW SECTION -->
  <section class="borderless-card" style="margin-top: 2rem;">
    <h2 class="fw-bold fs-5 m-0 mb-3"><i class="bi bi-diagram-3 text-info me-2"></i>전체 처리 흐름</h2>

    <div class="flow-legend">
      <span><i class="bi bi-circle-fill" style="color:var(--sky-primary);"></i> 계획 단계</span>
      <span><i class="bi bi-circle-fill" style="color:var(--emerald-main);"></i> 운송 시작·완료</span>
      <span><i class="bi bi-circle-fill" style="color:var(--amber-main);"></i> 장애물 대응·재탐색</span>
    </div>

    <div style="background: var(--bg-app); padding: 1.75rem 1.5rem; border-radius: var(--radius-lg); border: 1px solid var(--border-color); overflow-x: auto;">
      <div class="flow-track">

        <div class="flow-step">
          <div class="flow-step-num">01</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-box-seam"></i></div>
          <div class="flow-step-label">자원 선택</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">02</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-geo-alt"></i></div>
          <div class="flow-step-label">출발지 선택</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">03</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-flag-fill"></i></div>
          <div class="flow-step-label">목표지 선택</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">04</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-truck"></i></div>
          <div class="flow-step-label">운송체 선택</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">05</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-signpost-split"></i></div>
          <div class="flow-step-label">이동불가 Edge 제거</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">06</div>
          <div class="flow-icon-circle flow-icon-sky"><i class="bi bi-diagram-3"></i></div>
          <div class="flow-step-label">A* 최적경로 탐색</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">07</div>
          <div class="flow-icon-circle flow-icon-emerald"><i class="bi bi-play-circle-fill"></i></div>
          <div class="flow-step-label">운송 시작</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">08</div>
          <div class="flow-icon-circle flow-icon-amber"><i class="bi bi-exclamation-triangle-fill"></i></div>
          <div class="flow-step-label">장애물 감지</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">09</div>
          <div class="flow-icon-circle flow-icon-amber"><i class="bi bi-x-octagon-fill"></i></div>
          <div class="flow-step-label">Edge 차단</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">10</div>
          <div class="flow-icon-circle flow-icon-amber"><i class="bi bi-arrow-repeat"></i></div>
          <div class="flow-step-label">현재 위치 기준<br>A* 재탐색</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">11</div>
          <div class="flow-icon-circle flow-icon-amber"><i class="bi bi-signpost-2-fill"></i></div>
          <div class="flow-step-label">우회경로</div>
        </div>
        <div class="flow-connector"><i class="bi bi-chevron-right"></i></div>

        <div class="flow-step">
          <div class="flow-step-num">12</div>
          <div class="flow-icon-circle flow-icon-emerald"><i class="bi bi-check-circle-fill"></i></div>
          <div class="flow-step-label">운송완료</div>
        </div>

      </div>
    </div>
  </section>

  <!-- 2. HERO INTERACTIVE CANVAS -->
  <section class="hero-balanced-section">
    <div class="row g-4 align-items-stretch">
      <div class="col-lg-7 text-start">
        <div class="welcome-profile-card">
          <div class="hero-welcome-badge"><i class="bi bi-speedometer2"></i> 시스템 운영 대시보드</div>
          <h1 class="hero-title-main">운송 관리 <span>시스템</span> 👋</h1>
          <p class="hero-subtitle-text">전체 시스템의 상태를 한눈에 파악하고 운송 요청을 관리하세요.</p>
        </div>
      </div>

      <div class="col-lg-5">
        <div class="hero-side-stats">
          <div class="stat-item-pill stat-item-blue">
            <div class="stat-pill-icon"><i class="bi bi-boxes"></i></div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">등록 자원</div>
              <div class="stat-pill-num" style="color: #38bdf8;"><%=resourceCount%>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <div class="stat-item-pill stat-item-green">
            <div class="stat-pill-icon"><i class="bi bi-geo-alt"></i></div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">등록 위치</div>
              <div class="stat-pill-num" style="color: #4ade80;"><%=locationCount%>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <div class="stat-item-pill stat-item-amber">
            <div class="stat-pill-icon"><i class="bi bi-truck"></i></div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">운송 수단</div>
              <div class="stat-pill-num" style="color: #fbbf24;"><%=vehicleCount%>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 3. RECENT REQUESTS BOARD -->
  <section class="borderless-card">
    <div class="d-flex align-items-center justify-content-between mb-4">
      <h2 class="fw-bold fs-5 m-0"><i class="bi bi-clock-history text-info me-2"></i>최근 운송 요청 (<%=requestCount%>건)</h2>
      <a href="transportRequest.jsp" class="btn btn-sm btn-outline-info fw-bold" style="border-radius: var(--radius-pill);">+ 새 요청 등록</a>
    </div>

    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>자원명</th>
            <th>출발지</th>
            <th>목표지</th>
            <th>상태</th>
            <th class="text-end">동작</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <div class="fw-bold">운송요청 샘플</div>
              <div class="text-muted small">시스템 초기화 중</div>
            </td>
            <td class="font-monospace text-secondary">위치 1</td>
            <td class="font-monospace text-secondary">위치 2</td>
            <td><span class="status-chip chip-ok"><i class="bi bi-check-circle-fill me-1"></i> 진행중</span></td>
            <td class="text-end">
              <a href="#" class="btn btn-sm btn-outline-secondary" style="border-radius: var(--radius-pill);">보기</a>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

</main>

<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold mb-1"><i class="bi bi-truck-front me-1 text-info"></i> 운송 관리 시스템</div>
        <div class="text-muted">지능형 운송 관리 및 경로 최적화 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="fw-bold">개발팀</div>
        <div class="text-muted">&copy; 2026 운송 관리 시스템. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
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