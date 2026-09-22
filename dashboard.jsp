<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jsp" %>
<%
int resourceCount=0, locationCount=0, vehicleCount=0, requestCount=0;
Connection con=null; Statement st=null; ResultSet rs=null;
try {
    con=getConnection(); st=con.createStatement();
    rs=st.executeQuery("SELECT COUNT(*) FROM resources"); if(rs.next()) resourceCount=rs.getInt(1); rs.close();
    rs=st.executeQuery("SELECT COUNT(*) FROM locations"); if(rs.next()) locationCount=rs.getInt(1); rs.close();
    rs=st.executeQuery("SELECT COUNT(*) FROM vehicles"); if(rs.next()) vehicleCount=rs.getInt(1); rs.close();
    rs=st.executeQuery("SELECT COUNT(*) FROM transport_requests"); if(rs.next()) requestCount=rs.getInt(1); rs.close();
} catch(Exception e) {} finally { close(rs,st,con); }
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

  --flow-box-bg: #f8fafc;
  --flow-border: #e2e8f0;
  --flow-item-bg: #ffffff;
  --flow-item-txt: #0f172a;
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

  --flow-box-bg: #0f172a;
  --flow-border: #334155;
  --flow-item-bg: #1e293b;
  --flow-item-txt: #f8fafc;
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

[data-theme="dark"] .brand-logo {
  color: #f1f5f9;
}

[data-theme="dark"] .nav-link-btn {
  color: #e2e8f0;
  font-weight: 700;
}

[data-theme="dark"] .nav-link-btn:hover {
  background: var(--sky-bg);
  color: #38bdf8;
}

[data-theme="dark"] .stat-pill-label {
  color: #cbd5e1;
  font-weight: 700;
}

[data-theme="dark"] .stat-pill-num {
  color: #e2e8f0;
  font-weight: 800;
}

[data-theme="dark"] .stat-item-blue {
  background: #1e3a5f;
  border-color: #0c4a6e;
}

[data-theme="dark"] .stat-item-blue .stat-pill-icon {
  background: #0c2d42;
  color: #38bdf8;
}

[data-theme="dark"] .stat-item-green {
  background: #1a3a2a;
  border-color: #1e5a48;
}

[data-theme="dark"] .stat-item-green .stat-pill-icon {
  background: #0d2d24;
  color: #4ade80;
}

[data-theme="dark"] .stat-item-amber {
  background: #3a3a1f;
  border-color: #56540a;
}

[data-theme="dark"] .stat-item-amber .stat-pill-icon {
  background: #2a2a08;
  color: #fbbf24;
}

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

[data-theme="dark"] .theme-toggle {
  color: #cbd5e1;
}

[data-theme="dark"] .theme-toggle:hover {
  background: var(--sky-bg);
  color: #38bdf8;
}

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

.hero-title-main span {
  color: var(--sky-primary);
}

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
  padding: 12px 20px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 14px;
  cursor: pointer;
  transition: all 0.2s ease;
}

.stat-item-blue {
  background: #f0f9ff;
  border: 1px solid #bae6fd;
}
.stat-item-blue:hover {
  background: #e0f2fe;
  transform: translateX(4px);
}
.stat-item-blue .stat-pill-icon {
  background: #ffffff;
  color: var(--sky-primary);
  box-shadow: 0 2px 6px rgba(2, 132, 199, 0.15);
}

.stat-item-green {
  background: #f0fdf4;
  border: 1px solid #bbf7d0;
}
.stat-item-green:hover {
  background: #dcfce7;
  transform: translateX(4px);
}
.stat-item-green .stat-pill-icon {
  background: #ffffff;
  color: var(--emerald-main);
  box-shadow: 0 2px 6px rgba(22, 163, 74, 0.15);
}

.stat-item-amber {
  background: #fffbeb;
  border: 1px solid #fde68a;
}
.stat-item-amber:hover {
  background: #fef3c7;
  transform: translateX(4px);
}
.stat-item-amber .stat-pill-icon {
  background: #ffffff;
  color: var(--amber-main);
  box-shadow: 0 2px 6px rgba(217, 119, 6, 0.15);
}

.stat-pill-icon {
  width: 40px;
  height: 40px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.15rem;
}

.stat-pill-label {
  font-size: 0.88rem;
  font-weight: 700;
  color: var(--txt-sub);
}

.stat-pill-num {
  font-size: 1.2rem;
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

/* 직사각형 스타일 스텝 프로세스 네비게이션 */
.flow-nav-container {
  background: var(--surface);
  border-radius: 0; /* 컨테이너 직사각형화 */
  padding: 1.25rem 1.75rem;
  box-shadow: var(--shadow-soft);
  margin-top: 1.5rem;
  border: 1px solid var(--border-color);
}

.flow-nav-wrapper {
  display: flex;
  align-items: center;
  gap: 8px;
  overflow-x: auto;
  padding-bottom: 4px;
  scroll-behavior: smooth;
}

.flow-nav-wrapper::-webkit-scrollbar {
  height: 6px;
}
.flow-nav-wrapper::-webkit-scrollbar-thumb {
  background: var(--border-color);
  border-radius: 0;
}

.flow-step-item {
  display: flex;
  align-items: center;
  background: var(--flow-box-bg);
  border: 1px solid var(--flow-border);
  color: var(--flow-item-txt);
  padding: 6px 14px;
  border-radius: 0; /* 라운드 제거 -> 직사각형 구조 */
  font-size: 0.825rem;
  font-weight: 700;
  white-space: nowrap;
  transition: all 0.2s ease;
}

.flow-step-item:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
}

.flow-step-arrow {
  color: var(--txt-muted);
  font-size: 0.85rem;
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

[data-theme="dark"] .chip-ok {
  background: #064e3b;
  color: #6ee7b7;
  border-color: #047857;
}

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
        <span class="brand-badge">ADMIN</span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="transportRequest.jsp"><i class="bi bi-arrow-repeat"></i> 요청</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="transportStatus.jsp"><i class="bi bi-play-circle"></i> 현황</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="transportHistory.jsp"><i class="bi bi-clock-history"></i> 이력</a>
          </li>
          <li class="nav-item ms-lg-3">
            <a class="nav-link-btn" href="resource.jsp"><i class="bi bi-boxes"></i> 자원 관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="location.jsp"><i class="bi bi-geo-alt"></i> 위치 관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="vehicle.jsp"><i class="bi bi-truck"></i> 운송체 관리</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span>관리자</span>
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

  <!-- 1. 최상단 배치: 전체 처리 흐름 (직사각형 네비게이션 바 형태) -->
  <section class="flow-nav-container">
    <div class="d-flex align-items-center mb-2">
      <span class="fw-bold fs-6 text-info me-2"><i class="bi bi-diagram-3"></i> 전체 처리 흐름</span>
    </div>
    <div class="flow-nav-wrapper">
      <div class="flow-step-item">자원 선택</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">출발지 선택</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">목표지 선택</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">운송체 선택</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">이동불가 Edge 제거</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">A* 최적경로 탐색</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">운송 시작</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">장애물 감지</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">Edge 차단</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">현재 위치 기준 A* 재탐색</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item">우회경로</div>
      <i class="bi bi-chevron-right flow-step-arrow"></i>
      <div class="flow-step-item fw-bold text-success">운송완료</div>
    </div>
  </section>

  <!-- 2. HERO INTERACTIVE CANVAS -->
  <section class="hero-balanced-section">
    <div class="row g-4 align-items-stretch">
      <div class="col-lg-7 text-start">
        <div class="welcome-profile-card">
          <div class="hero-welcome-badge">
            <i class="bi bi-speedometer2"></i> 시스템 운영 대시보드
          </div>
          <h1 class="hero-title-main">운송 관리 <span>시스템</span> 👋</h1>
          <p class="hero-subtitle-text">전체 시스템의 상태를 한눈에 파악하고 운송 요청을 관리하세요.</p>
        </div>
      </div>

      <!-- Right Side Stats Card Area -->
      <div class="col-lg-5">
        <div class="hero-side-stats">
          <div class="stat-item-pill stat-item-blue">
            <div class="stat-pill-icon">
              <i class="bi bi-boxes"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">등록 자원</div>
              <div class="stat-pill-num" style="color: var(--sky-primary);"><%=resourceCount%></div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <div class="stat-item-pill stat-item-green">
            <div class="stat-pill-icon">
              <i class="bi bi-geo-alt"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">등록 위치</div>
              <div class="stat-pill-num" style="color: var(--emerald-main);"><%=locationCount%></div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <div class="stat-item-pill stat-item-amber">
            <div class="stat-pill-icon">
              <i class="bi bi-truck"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">운송 수단</div>
              <div class="stat-pill-num" style="color: var(--amber-main);"><%=vehicleCount%></div>
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
      <h2 class="fw-bold fs-5 m-0">
        <i class="bi bi-clock-history text-info me-2"></i>최근 운송 요청 (<%=requestCount%>건)
      </h2>
      <a href="transportRequest.jsp" class="btn btn-sm btn-outline-info fw-bold" style="border-radius: var(--radius-pill);">
        + 새 요청 등록
      </a>
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

<!-- FOOTER -->
<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold mb-1">
          <i class="bi bi-truck-front me-1 text-info"></i> 운송 관리 시스템
        </div>
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