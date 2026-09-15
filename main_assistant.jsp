<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    int total=0;
    try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets");if(rs.next())total=rs.getInt(1);conn.close();}catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 조교</title>

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

.stat-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; margin-bottom: 2rem; }
.stat-card { background: var(--surface); border: 1px solid #f1f5f9; border-radius: var(--radius-lg); padding: 1.5rem; box-shadow: var(--shadow-soft); display: flex; gap: 1rem; cursor: pointer; transition: all 0.25s; align-items: flex-start; }
.stat-card:hover { box-shadow: var(--shadow-air); transform: translateY(-2px); }
.stat-icon { width: 2.75rem; height: 2.75rem; border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; font-size: 1.25rem; flex-shrink: 0; }
.si-blue { background: #f0f9ff; } .si-teal { background: #f0fdf4; } .si-purple { background: #f5f3ff; } .si-amber { background: #fffbeb; }
.stat-val { font-size: 1.75rem; font-weight: 800; line-height: 1; }
.sv-blue { color: var(--sky-primary); } .sv-teal { color: var(--emerald-main); } .sv-purple { color: #7c3aed; } .sv-amber { color: var(--amber-main); }

.borderless-card { background: var(--surface); border-radius: var(--radius-xl); padding: 2rem; box-shadow: var(--shadow-soft); margin-bottom: 2rem; border: 1px solid #f1f5f9; }

.app-footer { background: var(--surface); border-top: 1px solid #e2e8f0; color: var(--txt-sub); padding: 2.5rem 0; margin-top: 4rem; font-size: 0.875rem; }

[data-theme="dark"] .stat-card { background: #1e293b; border-color: #334155; }

@media(max-width: 768px) { .stat-row { grid-template-columns: repeat(2, 1fr); } }

</style>

</style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_assistant.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge">ASSISTANT</span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/search.jsp"><i class="bi bi-search"></i> 검색</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/asset_manage.jsp"><i class="bi bi-pencil-square"></i> 자원 관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/professor.jsp"><i class="bi bi-people"></i> 교수</a>
          </li>
          <% if("admin".equals(session.getAttribute("loginRole"))) { %>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/transportRequest.jsp"><i class="bi bi-box-seam"></i> 자원 운송</a>
          </li>
          <% } %>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %> 조교</span>
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

  <!-- STATISTICS -->
  <div class="stat-row">
    <div class="stat-card" onclick="location.href='/CAN/search.jsp'" style="cursor: pointer;">
      <div class="stat-icon si-blue"><i class="bi bi-box-seam" style="color:var(--sky-primary);font-size:20px"></i></div>
      <div>
        <div style="font-size: 0.75rem; color: var(--txt-muted); font-weight: 600; margin-bottom: 0.25rem;">전체 자산</div>
        <div class="stat-val sv-blue"><%= String.format("%,d",total) %></div>
        <div style="font-size: 0.75rem; color: var(--txt-muted);">DB 실시간</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon si-teal"><i class="bi bi-tools" style="color:var(--emerald-main);font-size:20px"></i></div>
      <div>
        <div style="font-size: 0.75rem; color: var(--txt-muted); font-weight: 600; margin-bottom: 0.25rem;">공기구비품</div>
        <div class="stat-val sv-teal">3,368</div>
        <div style="font-size: 0.75rem; color: var(--txt-muted);">장비류</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon si-purple"><i class="bi bi-laptop" style="color:#7c3aed;font-size:20px"></i></div>
      <div>
        <div style="font-size: 0.75rem; color: var(--txt-muted); font-weight: 600; margin-bottom: 0.25rem;">집기비품</div>
        <div class="stat-val sv-purple">4,737</div>
        <div style="font-size: 0.75rem; color: var(--txt-muted);">가구·PC류</div>
      </div>
    </div>
    <div class="stat-card">
      <div class="stat-icon si-amber"><i class="bi bi-code-square" style="color:var(--amber-main);font-size:20px"></i></div>
      <div>
        <div style="font-size: 0.75rem; color: var(--txt-muted); font-weight: 600; margin-bottom: 0.25rem;">소프트웨어</div>
        <div class="stat-val sv-amber">296</div>
        <div style="font-size: 0.75rem; color: var(--txt-muted);">무형고정자산</div>
      </div>
    </div>
  </div>

  <!-- 빠른 이동 섹션 -->
  <div class="borderless-card">
    <h2 class="fw-bold fs-5 m-0 mb-4">
      <i class="bi bi-lightning-fill me-2"></i>빠른 이동
    </h2>
    <div class="row g-3">
      <div class="col-md-4">
        <a href="/CAN/search.jsp" class="btn btn-outline-info w-100" style="border-radius: var(--radius-lg); padding: 1.5rem; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <i class="bi bi-search fs-3"></i>
          <strong>자원 검색</strong>
          <small>전체 자산 조회</small>
        </a>
      </div>
      <div class="col-md-4">
        <a href="/CAN/professor.jsp" class="btn btn-outline-secondary w-100" style="border-radius: var(--radius-lg); padding: 1.5rem; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <i class="bi bi-people-fill fs-3"></i>
          <strong>교수 자원</strong>
          <small>교수별 자원</small>
        </a>
      </div>
      <div class="col-md-4">
        <a href="/CAN/reserve.jsp" class="btn btn-outline-warning w-100" style="border-radius: var(--radius-lg); padding: 1.5rem; display: flex; flex-direction: column; align-items: center; gap: 0.5rem;">
          <i class="bi bi-calendar-check fs-3"></i>
          <strong>예약</strong>
          <small>예약 관리</small>
        </a>
      </div>
    </div>
  </div>

  <!-- 실내 길찾기 섹션 -->
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
        <div style="display: flex; gap: 12px; align-items: center;">
          <div style="position: relative; flex-grow: 1;">
            <i class="bi bi-geo-alt text-muted position-absolute top-50 start-0 translate-middle-y ms-3"></i>
            <input type="text" id="navDest" style="flex: 1; padding: 12px 20px 12px 44px; border-radius: var(--radius-pill); border: 1.5px solid #cbd5e1; background: #f8fafc; font-size: 0.95rem; font-weight: 600; outline: none; width: 100%;" placeholder="목적지 입력 (예: 공학관 301호)">
          </div>
          <button class="btn btn-warning" onclick="goNav();" style="border-radius: var(--radius-pill); padding: 0.75rem 1.75rem; white-space: nowrap; font-weight: 600;">길찾기</button>
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