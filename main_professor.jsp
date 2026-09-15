<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    List<String[]> swList=new ArrayList<>();int swTotal=0;
    try{Class.forName("com.mysql.cj.jdbc.Driver");
    Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets WHERE asset_class='무형고정자산'");if(rs.next())swTotal=rs.getInt(1);rs.close();
    PreparedStatement ps=conn.prepareStatement("SELECT asset_no,item_name,model,detail_location,manage_dept,asset_status FROM assets WHERE asset_class='무형고정자산' ORDER BY reg_date DESC LIMIT 8");rs=ps.executeQuery();
    while(rs.next())swList.add(new String[]{rs.getString(1),rs.getString(2),rs.getString(3),rs.getString(4),rs.getString(5),rs.getString(6)});
    rs.close();ps.close();conn.close();}catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 교수</title>

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
body {
  font-family: var(--font-main);
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
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

.hero-balanced-section { padding-top: 2rem; padding-bottom: 2.5rem; }
.welcome-profile-card { background: var(--surface); border-radius: var(--radius-xl); padding: 2rem; box-shadow: var(--shadow-soft); height: 100%; display: flex; flex-direction: column; justify-content: center; }
.hero-welcome-badge { display: inline-flex; align-items: center; gap: 6px; background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 100%); color: #0369a1; font-weight: 800; font-size: 0.8rem; padding: 5px 14px; border-radius: var(--radius-pill); margin-bottom: 0.75rem; width: fit-content; border: 1px solid #7dd3fc; }
.hero-title-main { font-size: 1.8rem; font-weight: 800; letter-spacing: -0.8px; margin-bottom: 0.4rem; color: var(--txt-main); }
.hero-title-main span { color: var(--sky-primary); }
.hero-subtitle-text { font-size: 0.95rem; color: var(--txt-sub); margin: 0; }
.hero-search-floating { background: #f8fafc; border-radius: var(--radius-pill); padding: 6px 6px 6px 20px; display: flex; align-items: center; border: 1.5px solid #cbd5e1; transition: all 0.2s ease; }
.hero-search-floating:focus-within { border-color: var(--sky-primary); background: #ffffff; box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.12); }
.hero-search-floating input { border: none; background: transparent; width: 100%; font-size: 0.975rem; font-weight: 600; color: var(--txt-main); outline: none; }
.btn-floating-search { background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); color: #ffffff; font-weight: 700; padding: 10px 26px; border-radius: var(--radius-pill); border: none; white-space: nowrap; box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25); transition: all 0.2s; cursor: pointer; }
.btn-floating-search:hover { background: var(--sky-hover); transform: translateY(-1px); }

.hero-side-stats { background: var(--surface); border-radius: var(--radius-xl); padding: 1.5rem; box-shadow: var(--shadow-soft); display: flex; flex-direction: column; gap: 12px; height: 100%; justify-content: center; }
.stat-item-pill { padding: 12px 20px; border-radius: var(--radius-pill); display: flex; align-items: center; gap: 14px; cursor: pointer; transition: all 0.2s ease; }
.stat-item-blue { background: #f0f9ff; border: 1px solid #bae6fd; }
.stat-item-blue:hover { background: #e0f2fe; transform: translateX(4px); }
.stat-item-blue .stat-pill-icon { background: #ffffff; color: var(--sky-primary); box-shadow: 0 2px 6px rgba(2, 132, 199, 0.15); }
.stat-item-green { background: #f0fdf4; border: 1px solid #bbf7d0; }
.stat-item-green:hover { background: #dcfce7; transform: translateX(4px); }
.stat-item-green .stat-pill-icon { background: #ffffff; color: var(--emerald-main); box-shadow: 0 2px 6px rgba(22, 163, 74, 0.15); }
.stat-item-amber { background: #fffbeb; border: 1px solid #fde68a; }
.stat-item-amber:hover { background: #fef3c7; transform: translateX(4px); }
.stat-item-amber .stat-pill-icon { background: #ffffff; color: var(--amber-main); box-shadow: 0 2px 6px rgba(217, 119, 6, 0.15); }
.stat-pill-icon { width: 40px; height: 40px; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 1.15rem; }
.stat-pill-label { font-size: 0.88rem; font-weight: 700; color: var(--txt-sub); }
.stat-pill-num { font-size: 1.2rem; font-weight: 800; font-family: var(--font-mono); }

.section-head-title { font-size: 1.25rem; font-weight: 800; margin-bottom: 1.25rem; display: flex; align-items: center; justify-content: space-between; }
.borderless-card { background: var(--surface); border-radius: var(--radius-xl); padding: 2.25rem; box-shadow: var(--shadow-soft); margin-bottom: 2rem; border: 1px solid #f1f5f9; }
.table-air { width: 100%; border-collapse: collapse; font-size: 0.925rem; }
.table-air th { color: var(--txt-muted); font-weight: 700; padding: 12px 16px; border-bottom: 2px solid #e2e8f0; text-align: left; }
.table-air td { padding: 18px 16px; border-bottom: 1px solid #f1f5f9; color: var(--txt-main); vertical-align: middle; }
.table-air tr:last-child td { border-bottom: none; }

.status-chip { padding: 5px 12px; border-radius: var(--radius-pill); font-size: 0.775rem; font-weight: 800; }
.chip-ok { background: #dcfce7; color: #15803d; border: 1px solid #86efac; }
.chip-cancel { background: #fee2e2; color: #b91c1c; border: 1px solid #fca5a5; }
.chip-warn { background: #fef3c7; color: #b45309; border: 1px solid #fcd34d; }

.btn-cancel-flat { background: transparent; border: 1px solid #fca5a5; color: #dc2626; font-size: 0.8rem; font-weight: 700; padding: 5px 14px; border-radius: var(--radius-pill); transition: all 0.2s; cursor: pointer; }
.btn-cancel-flat:hover { background: #dc2626; color: #ffffff; }

.nav-quick-bar { display: flex; gap: 12px; align-items: center; }
.nav-input-air { flex: 1; padding: 12px 20px 12px 44px; border-radius: var(--radius-pill); border: 1.5px solid #cbd5e1; background: #f8fafc; font-size: 0.95rem; font-weight: 600; color: var(--txt-main); outline: none; transition: all 0.2s; }
.nav-input-air:focus { background: #ffffff; border-color: var(--amber-main); box-shadow: 0 0 0 4px rgba(217, 119, 6, 0.15); }
[data-theme="dark"] .nav-input-air { background: #334155; border-color: #475569; color: #f1f5f9; }
[data-theme="dark"] .nav-input-air::placeholder { color: #94a3b8; }
[data-theme="dark"] .nav-input-air:focus { background: #1e293b; border-color: #fbbf24; box-shadow: 0 0 0 4px rgba(251, 191, 36, 0.15); }

.btn-amber-pill { background: linear-gradient(135deg, #f59e0b 0%, #d97706 100%); color: #ffffff; font-weight: 700; padding: 12px 28px; border-radius: var(--radius-pill); border: none; white-space: nowrap; box-shadow: 0 4px 12px rgba(217, 119, 6, 0.25); transition: all 0.2s; cursor: pointer; }
.btn-amber-pill:hover { background: #b45309; }

.app-footer { background: var(--surface); border-top: 1px solid #e2e8f0; color: var(--txt-sub); padding: 2.5rem 0; margin-top: 4rem; font-size: 0.875rem; }

[data-theme="dark"] .stat-item-blue { background: #1e3a5f; border-color: #0c4a6e; }
[data-theme="dark"] .stat-item-blue:hover { background: #1a3455; }
[data-theme="dark"] .stat-item-blue .stat-pill-icon { background: #0c2d42; color: #38bdf8; }

[data-theme="dark"] .stat-item-green { background: #1a3a2a; border-color: #1e5a48; }
[data-theme="dark"] .stat-item-green:hover { background: #16362a; }
[data-theme="dark"] .stat-item-green .stat-pill-icon { background: #0d2d24; color: #4ade80; }

[data-theme="dark"] .stat-item-amber { background: #3a3a1f; border-color: #56540a; }
[data-theme="dark"] .stat-item-amber:hover { background: #32320a; }
[data-theme="dark"] .stat-item-amber .stat-pill-icon { background: #2a2a08; color: #fbbf24; }

[data-theme="dark"] .hero-search-floating { background: #334155; border-color: #475569; }
[data-theme="dark"] .hero-search-floating:focus-within { background: #1e293b; border-color: #38bdf8; }
[data-theme="dark"] .hero-search-floating input { color: #f1f5f9; }
[data-theme="dark"] .hero-search-floating input::placeholder { color: #94a3b8; }

[data-theme="dark"] .btn-floating-search { background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%); }

[data-theme="dark"] .table-air th { border-bottom-color: #475569; }
[data-theme="dark"] .table-air td { border-bottom-color: #334155; }

[data-theme="dark"] .btn-outline-info { border-color: #38bdf8; color: #38bdf8; }
[data-theme="dark"] .btn-outline-info:hover { background: #38bdf8; color: #0f172a; }

@media(max-width: 768px) {
  .nav-quick-bar { flex-direction: column; }
  .nav-input-air { width: 100%; }
}


</style>

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
            <a class="nav-link-btn" href="/CAN/professor.jsp"><i class="bi bi-people"></i> 교수 자원</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/asset_manage.jsp"><i class="bi bi-pencil-square"></i> 자원 관리</a>
          </li>
          <% if("admin".equals(session.getAttribute("loginRole"))) { %>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/transportRequest.jsp"><i class="bi bi-box-seam"></i> 자원 운송</a>
          </li>
          <% } %>

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

<main class="container-xl pb-5">
  <!-- 1. HERO INTERACTIVE CANVAS -->
  <section class="hero-balanced-section">
    <div class="row g-4 align-items-stretch">
      <!-- Left Hero Canvas Main -->
      <div class="col-lg-7 text-start">
        <div class="welcome-profile-card">
          <div class="hero-welcome-badge">
            <i class="bi bi-sparkles"></i> SMART CAMPUS NAVIGATION
          </div>
          <h1 class="hero-title-main">좋은 하루입니다, <span><%= loginName %>님</span> 👨‍🏫</h1>
          <p class="hero-subtitle-text">소프트웨어 자산 <strong><%= String.format("%,d",swTotal) %>건</strong> DB 실시간 연동. 교수 자원 관리 및 과목 등록이 가능합니다.</p>

          <!-- Floating Wide Search Field -->
          <form method="get" action="/CAN/search.jsp" class="mt-3 m-0">
            <div class="hero-search-floating">
              <i class="bi bi-search text-muted me-3 fs-5"></i>
              <input type="text" name="keyword" placeholder="찾으시는 자산번호, 품목명, 교수님 성함 검색...">
              <button type="submit" class="btn-floating-search">통합 검색</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Right Side Stats Card Area -->
      <div class="col-lg-5">
        <div class="hero-side-stats">
          <!-- Blue Accent -->
          <div class="stat-item-pill stat-item-blue" onclick="location.href='/CAN/professor.jsp'">
            <div class="stat-pill-icon">
              <i class="bi bi-people"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">교수 자원</div>
              <div class="stat-pill-num" style="color: var(--sky-primary);">관리 →</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <!-- Green Accent -->
          <div class="stat-item-pill stat-item-green" onclick="location.href='/CAN/search.jsp?type=무형고정자산'">
            <div class="stat-pill-icon">
              <i class="bi bi-code-square"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">SW 자산 (DB)</div>
              <div class="stat-pill-num" style="color: var(--emerald-main);"><%= String.format("%,d",swTotal) %>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <!-- Amber Accent -->
          <div class="stat-item-pill stat-item-amber" onclick="location.href='/CAN/asset_manage.jsp'">
            <div class="stat-pill-icon">
              <i class="bi bi-pencil-square"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">자원 관리</div>
              <div class="stat-pill-num" style="color: var(--amber-main); font-size: 0.95rem; font-family: var(--font-main);">편집하기 →</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 2. SOFTWARE LIST -->
  <section class="borderless-card">
    <div class="d-flex align-items-center justify-content-between mb-4">
      <h2 class="fw-bold fs-5 m-0">
        <i class="bi bi-code-square text-info me-2"></i>소프트웨어 현황 (DB)</h2>
      <a href="/CAN/search.jsp?type=무형고정자산" class="btn btn-sm btn-outline-info fw-bold" style="border-radius: var(--radius-pill);">
        + 전체 보기
      </a>
    </div>

    <% if(swList.isEmpty()){%>
    <div style="text-align:center;padding:40px;color:var(--txt-muted)">
      <i class="bi bi-inbox" style="font-size:32px;display:block;margin-bottom:10px;opacity:.3"></i>
      데이터 없음
      <br><a href="/CAN/search.jsp?type=무형고정자산" class="btn btn-primary mt-3">전체 검색</a>
    </div>
    <%}else{%>
    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>자산번호</th>
            <th>SW명</th>
            <th>위치</th>
            <th>상태</th>
            <th class="text-end">상세</th>
          </tr>
        </thead>
        <tbody>
        <% for(String[] sw:swList){
              String stCls=sw[5]!=null&&sw[5].contains("사용중")?"chip-cancel":"chip-ok";
        %>
          <tr>
            <td class="font-monospace text-secondary"><%= sw[0]!=null?sw[0]:"-" %></td>
            <td>
              <div class="fw-bold"><%= sw[1]!=null?sw[1]:"-" %></div>
              <div class="text-muted small"><%= sw[2]!=null?sw[2]:"" %></div>
            </td>
            <td><i class="bi bi-geo-alt" style="color:var(--sky-primary)"></i> <%= sw[3]!=null?sw[3]:"-" %></td>
            <td><span class="status-chip <%= stCls %>"><%= sw[5]!=null&&!sw[5].isEmpty()?sw[5]:"정보없음" %></span></td>
            <td class="text-end">
              <a href="/CAN/detail.jsp?id=<%= sw[0]!=null?sw[0]:"" %>" class="btn btn-sm btn-outline-secondary" style="border-radius: var(--radius-pill);">상세</a>
            </td>
          </tr>
        <%}%>
        </tbody>
      </table>
    </div>
    <%}%>
  </section>

  <!-- 3. QUICK NAVIGATION -->
  <section class="borderless-card">
    <div class="d-flex align-items-center gap-2 mb-3">
      <i class="bi bi-lightning-fill fs-5 text-warning"></i> <span class="text-warning fw-bold">빠른 이동</span>
    </div>
    <div class="row g-4">
      <div class="col-md-6">
        <a href="/CAN/professor.jsp" class="btn btn-outline-info w-100" style="border-radius: var(--radius-lg); padding: 2rem; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <i class="bi bi-people-fill fs-3"></i>
          <strong>교수 자원 관리</strong>
          <small>과목·주특기 등록</small>
        </a>
      </div>
      <div class="col-md-6">
        <a href="/CAN/search.jsp" class="btn btn-outline-secondary w-100" style="border-radius: var(--radius-lg); padding: 2rem; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <i class="bi bi-search fs-3"></i>
          <strong>자원 검색</strong>
          <small>모든 자산 조회</small>
        </a>
      </div>
    </div>
  </section>

  <!-- 4. INDOOR NAVIGATION BANNER SECTION -->
  <section class="borderless-card">
    <div class="row align-items-center">
      <div class="col-lg-5 mb-3 mb-lg-0">
        <div class="d-flex align-items-center gap-2 mb-1">
          <i class="bi bi-compass-fill fs-5 text-warning"></i> <span class="text-warning fw-bold">REALTIME INDOOR NAV</span>
        </div>
        <h2 class="fw-bold fs-4 m-0">캠퍼스 실내 길찾기</h2>
        <p class="text-muted small m-0 mt-1">목적지를 입력하시면 현재 내 위치 기준으로 가장 빠른 동선을 안내합니다.</p>
      </div>

      <div class="col-lg-7">
        <div class="nav-quick-bar">
          <div class="position-relative flex-grow-1">
            <i class="bi bi-geo-alt text-muted position-absolute top-50 start-0 translate-middle-y ms-3"></i>
            <input type="text" id="navDest" class="nav-input-air" placeholder="목적지 입력 (예: 공학관 301호, 이교수 연구실)">
          </div>
          <button class="btn-amber-pill" onclick="goNav();">길찾기</button>
        </div>
        <div id="navMsg" class="mt-2 p-2 bg-light rounded-3 text-info small font-monospace" style="display:none;"></div>
      </div>
    </div>
  </section>

</main>

<!-- FOOTER -->
<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold text-dark mb-1">
          <i class="bi bi-compass-fill me-1 text-info"></i> ICT CAN Navigation System
        </div>
        <div>ICT폴리텍대학 교내 자원 내비게이션 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="text-dark fw-bold">Made by AI 소프트웨어학과</div>
        <div>박승순 · 권동해 · 원태연 · 이수혁</div>
        <div class="mt-1 opacity-75">&copy; 2026 ICT CAN. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function goNav(){
  var dest=document.getElementById('navDest').value.trim();
  var url='/CAN/navigationTest1.jsp';
  if(dest)url+='?destName='+encodeURIComponent(dest);
  var msg=document.getElementById('navMsg');
  msg.innerHTML='<i class="bi bi-arrow-repeat me-1"></i>'+(dest?'목적지 [<strong>'+dest+'</strong>] 경로 계산 중...':'현재 위치 탐색 중...');
  msg.style.display='block';
  setTimeout(function(){location.href=url;},600);
}
document.getElementById('navDest').addEventListener('keydown',function(e){if(e.key==='Enter')goNav();});

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