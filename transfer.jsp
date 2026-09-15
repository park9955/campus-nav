<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%  String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName"),loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    List<Map<String,String>> tList=new ArrayList<>();int total=0;String dbErr="";
    try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM asset_transfer");if(rs.next())total=rs.getInt(1);rs.close();
    PreparedStatement ps=conn.prepareStatement("SELECT transfer_id,asset_no,item_name,transfer_date,before_dept,before_location,after_dept,after_location,remark FROM asset_transfer ORDER BY transfer_date DESC LIMIT 50");rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("id",nvl(rs.getString(1)));r.put("no",nvl(rs.getString(2)));r.put("name",nvl(rs.getString(3)));r.put("date",nvl(rs.getString(4)));r.put("fdept",nvl(rs.getString(5)));r.put("floc",nvl(rs.getString(6)));r.put("tdept",nvl(rs.getString(7)));r.put("tloc",nvl(rs.getString(8)));r.put("rmk",nvl(rs.getString(9)));tList.add(r);}
    rs.close();ps.close();conn.close();}catch(Exception e){dbErr=e.getMessage();}
%>
<%! private String nvl(String s){return s==null?"":s;}
    private String esc(String s){if(s==null)return "";return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");} %>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ICT CAN — 이관내역</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@700;800&family=Pretendard:wght@400;500;600;700;800&family=JetBrains+Mono:wght@600;700&display=swap" rel="stylesheet">
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

.hero-title {
  font-size: 1.8rem;
  font-weight: 800;
  color: #0f172a;
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

.borderless-card {
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
  justify-content: space-between;
}

.results-title {
  font-size: 1.1rem;
  font-weight: 800;
  color: var(--txt-main);
}

.results-subtitle {
  font-size: 0.85rem;
  color: var(--txt-muted);
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
  padding: 12px 16px;
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
  background: #1e3a5f;
  color: #f1f5f9;
}

[data-theme="dark"] .btn-outline-info {
  color: #38bdf8;
  border-color: #38bdf8;
}

[data-theme="dark"] .btn-outline-info:hover {
  background: #38bdf8;
  color: #0f172a;
}

[data-theme="dark"] .pagination-btn {
  background: #1e3a5f !important;
  color: #cbd5e1 !important;
  border-color: #334155 !important;
}

[data-theme="dark"] .pagination-btn:hover {
  background: #0c4a6e !important;
  color: #f1f5f9 !important;
}

[data-theme="dark"] .pagination-btn.active {
  background: #0284c7 !important;
  color: #ffffff !important;
  border-color: #38bdf8 !important;
}

.btn {
  height: 38px;
  display: inline-flex;
  align-items: center;
}

.status-chip {
  display: inline-block;
  padding: 4px 11px;
  border-radius: 6px;
  font-size: 0.75rem;
  font-weight: 600;
  font-family: var(--font-mono);
}

@media(max-width:768px) {
  div[style*="display:flex"][style*="gap:2rem"] {
    flex-direction: column;
  }
  div[style*="width:320px"] {
    width: 100%;
  }
}


/* ══ Hero 다크그린 그라디언트 (교수님 요청) ══ */
.hero {
    background: linear-gradient(135deg, #0f172a 0%, #0d6147 50%, #16a34a 100%) !important;
    border: none !important;
    box-shadow: 0 8px 32px rgba(15,23,42,.25) !important;
}
.hero::after {
    background: linear-gradient(135deg, rgba(255,255,255,.06) 0%, rgba(22,163,74,.15) 100%) !important;
}
.hero-eyebrow { color: rgba(255,255,255,.72) !important; }
.hero-title   { color: #ffffff !important; }
.hero-title em, .hero-title span { color: #4ade80 !important; }
.hero-desc    { color: rgba(255,255,255,.85) !important; }
.tag {
    background: rgba(255,255,255,.15) !important;
    border-color: rgba(255,255,255,.25) !important;
    color: rgba(255,255,255,.9) !important;
}
.tag b { color: #4ade80 !important; }
/* 검색 hero 안 input */
.search-hero {
    background: rgba(255,255,255,.12) !important;
    border-color: rgba(255,255,255,.35) !important;
    box-shadow: none !important;
}
.search-hero input {
    color: #ffffff !important;
    background: transparent !important;
    border: none !important;
}
.search-hero input::placeholder { color: rgba(255,255,255,.55) !important; }
.search-hero:focus-within {
    background: rgba(255,255,255,.18) !important;
    border-color: rgba(255,255,255,.6) !important;
}

</style>
<link rel="stylesheet" href="/CAN/css/common.css">
</head><body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_<%= loginRole %>.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge">TRANSFER</span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/main_<%= loginRole %>.jsp"><i class="bi bi-house"></i> 홈</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/search.jsp"><i class="bi bi-search"></i> 검색</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %></span>
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
    <div>
      <div class="hero-subtitle">ICT CAN · 이관 관리</div>
      <h1 class="hero-title">자산 이관 <strong style="color: #22c55e;">내역</strong> ↔️</h1>
      <p class="hero-subtitle">누가·어디서·누구에게 이관했는지 확인합니다. 총 <strong><%= total %>건</strong></p>
    </div>
  </div>

  <% if(!dbErr.isEmpty()){ %>
  <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
    <i class="bi bi-exclamation-circle-fill me-2"></i><%= dbErr %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <% } %>

  <!-- 이관 목록 -->
  <div class="borderless-card">
    <div class="results-header">
      <div>
        <div class="results-title">이관 내역</div>
        <div class="results-subtitle">총 <%= total %>건 · 최근 50건</div>
      </div>
      <input type="text" id="kw" placeholder="검색..." oninput="filterList()" style="border:1.5px solid #cbd5e1;border-radius:var(--radius-md);padding:8px 12px;font-size:0.875rem;outline:none;width:200px">
    </div>

    <% if(tList.isEmpty()){ %>
    <div style="text-align:center;padding:40px;color:var(--txt-muted)">
      <i class="bi bi-inbox" style="font-size:36px;display:block;margin-bottom:12px;opacity:.3"></i>
      이관 내역이 없습니다.
    </div>
    <%}else{%>
    <!-- 페이지네이션 탭 -->
    <div style="display:flex;gap:8px;margin-bottom:1.5rem;flex-wrap:wrap;align-items:center">
      <button onclick="goToPage(1)" class="pagination-btn active" data-page="1" style="padding:6px 12px;border:1.5px solid #7dd3fc;border-radius:var(--radius-md);background:var(--sky-bg);color:var(--sky-primary);font-weight:600;font-size:0.875rem;cursor:pointer;transition:all 0.2s">1페이지</button>
      <% for(int p=2; p<=(tList.size()-1)/10+1; p++){ %>
      <button onclick="goToPage(<%= p %>)" class="pagination-btn" data-page="<%= p %>" style="padding:6px 12px;border:1.5px solid #cbd5e1;border-radius:var(--radius-md);background:white;color:var(--txt-sub);font-weight:600;font-size:0.875rem;cursor:pointer;transition:all 0.2s"><%= p %>페이지</button>
      <% } %>
    </div>

    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>#</th>
            <th>자산번호</th>
            <th>품목명</th>
            <th>이관 전</th>
            <th>이관 후</th>
            <th>이관일자</th>
            <th>상세</th>
          </tr>
        </thead>
        <tbody id="tBody">
        <% for(int i=0;i<tList.size();i++){Map<String,String> t=tList.get(i);
           String safeSearch=(t.get("no")+t.get("name")+t.get("fdept")+t.get("tdept")).toLowerCase().replace("\"",""); %>
        <tr class="table-row" data-search="<%= safeSearch %>" data-idx="<%= i %>" onclick="showDetail(<%= i %>)" style="cursor:pointer">
          <td style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)"><%= t.get("id") %></td>
          <td style="font-family:var(--font-mono);font-size:0.8rem"><%= t.get("no") %></td>
          <td><strong><%= t.get("name").isEmpty()?"(품목정보없음)":t.get("name") %></strong></td>
          <td><span style="font-weight:600"><%= t.get("fdept") %></span><div style="font-size:0.8rem;color:var(--txt-muted)"><%= t.get("floc") %></div></td>
          <td><span style="font-weight:600;color:var(--sky-primary)"><%= t.get("tdept") %></span><div style="font-size:0.8rem;color:var(--txt-muted)"><%= t.get("tloc") %></div></td>
          <td style="font-family:var(--font-mono);font-size:0.8rem"><%= t.get("date") %></td>
          <td onclick="event.stopPropagation()"><button class="btn btn-outline-info" onclick="showDetail(<%= i %>)" style="border-radius: var(--radius-pill);padding:6px 16px;font-weight:600;font-size:0.875rem;display:inline-flex;align-items:center;gap:6px"><i class="bi bi-arrow-right"></i>보기</button></td>
        </tr>
        <% }%>
        </tbody>
      </table>
    </div>
    <%}%>
  </div>

  <!-- 상세 패널 -->
  <div id="dPanel" style="display:none;margin-bottom:2rem">
    <div class="borderless-card">
      <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:1.5rem;padding-bottom:1rem;border-bottom:1px solid var(--border-color)">
        <h2 class="fw-bold fs-5 m-0" id="d-title">이관 상세</h2>
        <button type="button" class="btn btn-sm btn-outline-secondary" onclick="document.getElementById('dPanel').style.display='none'" style="border-radius: var(--radius-pill);"><i class="bi bi-x me-1"></i>닫기</button>
      </div>

      <div style="background:var(--sky-bg);border-radius:var(--radius-lg);padding:1.5rem;margin-bottom:1.5rem">
        <div style="display:flex;align-items:center;gap:1.5rem;flex-wrap:wrap">
          <div style="flex:1;min-width:200px;padding:1rem;background:var(--surface);border:1.5px solid #fca5a5;border-radius:var(--radius-md)">
            <div style="font-size:0.75rem;font-weight:700;color:#dc2626;text-transform:uppercase;margin-bottom:0.5rem;letter-spacing:0.05em">이관 전 (출발)</div>
            <div style="font-size:1.1rem;font-weight:800;color:var(--txt-main)" id="d-fdept">-</div>
            <div style="font-size:0.85rem;color:var(--txt-muted);margin-top:0.25rem" id="d-floc">-</div>
          </div>
          <div style="color:var(--sky-primary);font-size:1.5rem"><i class="bi bi-arrow-right"></i></div>
          <div style="flex:1;min-width:200px;padding:1rem;background:var(--surface);border:1.5px solid #86efac;border-radius:var(--radius-md)">
            <div style="font-size:0.75rem;font-weight:700;color:#16a34a;text-transform:uppercase;margin-bottom:0.5rem;letter-spacing:0.05em">이관 후 (도착)</div>
            <div style="font-size:1.1rem;font-weight:800;color:var(--txt-main)" id="d-tdept">-</div>
            <div style="font-size:0.85rem;color:var(--txt-muted);margin-top:0.25rem" id="d-tloc">-</div>
          </div>
        </div>
      </div>

      <div style="display:grid;grid-template-columns:repeat(auto-fit,minmax(200px,1fr));gap:1rem">
        <div style="padding:1rem;background:#f0f9ff;border-radius:var(--radius-md)">
          <div style="font-size:0.75rem;font-weight:700;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">자산번호</div>
          <div style="font-size:0.9rem;font-family:var(--font-mono);font-weight:600" id="d-no">-</div>
        </div>
        <div style="padding:1rem;background:#f0f9ff;border-radius:var(--radius-md)">
          <div style="font-size:0.75rem;font-weight:700;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">품목명</div>
          <div style="font-size:0.9rem;font-weight:600" id="d-name">-</div>
        </div>
        <div style="padding:1rem;background:#f0f9ff;border-radius:var(--radius-md)">
          <div style="font-size:0.75rem;font-weight:700;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">이관일자</div>
          <div style="font-size:0.9rem;font-family:var(--font-mono);font-weight:600" id="d-date">-</div>
        </div>
        <div style="padding:1rem;background:#f0f9ff;border-radius:var(--radius-md)">
          <div style="font-size:0.75rem;font-weight:700;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">비고</div>
          <div style="font-size:0.9rem;font-weight:600" id="d-rmk">-</div>
        </div>
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
// Pagination
const ITEMS_PER_PAGE=10;
let currentPage=1;

function goToPage(page){
  const rows=document.querySelectorAll('.table-row');
  const totalPages=Math.ceil(rows.length/ITEMS_PER_PAGE);
  if(page<1||page>totalPages)return;
  currentPage=page;
  const start=(page-1)*ITEMS_PER_PAGE;
  const end=start+ITEMS_PER_PAGE;
  rows.forEach((row,idx)=>{
    row.style.display=(idx>=start&&idx<end)?'table-row':'none';
  });
  document.querySelectorAll('.pagination-btn').forEach(btn=>{
    btn.classList.remove('active');
    btn.style.background='white';
    btn.style.color='var(--txt-sub)';
    btn.style.borderColor='#cbd5e1';
    if(btn.dataset.page==page){
      btn.classList.add('active');
      btn.style.background='var(--sky-bg)';
      btn.style.color='var(--sky-primary)';
      btn.style.borderColor='#7dd3fc';
    }
  });
}

var data=[<% for(int i=0;i<tList.size();i++){Map<String,String> t=tList.get(i);%>
{id:"T-<%= String.format("%03d",Integer.parseInt(t.get("id").isEmpty()?"0":t.get("id"))) %>",no:"<%= t.get("no").replace("\"","").replace("\\","\\\\") %>",name:"<%= t.get("name").replace("\\","\\\\").replace("\"","\\\"") %>",date:"<%= t.get("date") %>",fdept:"<%= t.get("fdept").replace("\\","\\\\").replace("\"","\\\"") %>",floc:"<%= t.get("floc").replace("\\","\\\\").replace("\"","\\\"") %>",tdept:"<%= t.get("tdept").replace("\\","\\\\").replace("\"","\\\"") %>",tloc:"<%= t.get("tloc").replace("\\","\\\\").replace("\"","\\\"") %>",rmk:"<%= t.get("rmk").replace("\\","\\\\").replace("\"","\\\"") %>"}<%=i<tList.size()-1?",":""%>
<%}%>];

function showDetail(i){
  var t=data[i];
  document.getElementById('d-title').textContent='T-'+String(i+1).padStart(3,'0')+' — '+t.name+' 이관 상세';
  document.getElementById('d-fdept').textContent=t.fdept;
  document.getElementById('d-floc').textContent=t.floc;
  document.getElementById('d-tdept').textContent=t.tdept;
  document.getElementById('d-tloc').textContent=t.tloc;
  document.getElementById('d-no').textContent=t.no;
  document.getElementById('d-name').textContent=t.name;
  document.getElementById('d-date').textContent=t.date;
  document.getElementById('d-rmk').textContent=t.rmk||'-';
  var p=document.getElementById('dPanel');
  p.style.display='block';
  p.scrollIntoView({behavior:'smooth'});
}

function filterList(){
  var kw=document.getElementById('kw').value.toLowerCase();
  document.querySelectorAll('#tBody tr').forEach(function(r){
    r.style.display=(!kw||r.dataset.search.includes(kw))?'':'none';
  });
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

window.addEventListener('DOMContentLoaded',function(){
  var savedTheme=localStorage.getItem('theme');
  var html=document.documentElement;
  if(savedTheme){
    html.setAttribute('data-theme',savedTheme);
  }else if(window.matchMedia('(prefers-color-scheme: dark)').matches){
    html.setAttribute('data-theme','dark');
  }
  updateThemeIcon();
  if(document.querySelectorAll('.table-row').length>0)goToPage(1);
});
</script>
</body></html>