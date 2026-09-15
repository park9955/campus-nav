<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%  String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName"),loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    String keyword=request.getParameter("keyword");if(keyword==null)keyword="";
    String type=request.getParameter("type");if(type==null)type="";
    String status=request.getParameter("status");if(status==null)status="";
    String pageStr=request.getParameter("page");int curPage=1,pageSize=20;try{curPage=Integer.parseInt(pageStr);}catch(Exception e){}if(curPage<1)curPage=1;
    List<Map<String,String>> list=new ArrayList<>();int totalCount=0,totalPage=1;String dbErr="";
    try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    StringBuilder w=new StringBuilder("WHERE 1=1 ");List<String> p=new ArrayList<>();
    if(!keyword.isEmpty()){w.append("AND (item_name LIKE ? OR asset_no LIKE ? OR detail_location LIKE ? OR manage_dept LIKE ? OR model LIKE ?) ");for(int i=0;i<5;i++)p.add("%"+keyword+"%");}
    if(!type.isEmpty()){w.append("AND asset_class=? ");p.add(type);}
    if(!status.isEmpty()){w.append("AND asset_status LIKE ? ");p.add("%"+status+"%");}
    PreparedStatement ps=conn.prepareStatement("SELECT COUNT(*) FROM assets "+w);for(int i=0;i<p.size();i++)ps.setString(i+1,p.get(i));ResultSet rs=ps.executeQuery();if(rs.next())totalCount=rs.getInt(1);rs.close();ps.close();
    totalPage=(int)Math.ceil((double)totalCount/pageSize);if(totalPage<1)totalPage=1;
    ps=conn.prepareStatement("SELECT asset_no,asset_class,item_name,model,detail_location,manage_dept,manager_name,asset_status FROM assets "+w+"ORDER BY reg_date DESC LIMIT ? OFFSET ?");
    for(int i=0;i<p.size();i++)ps.setString(i+1,p.get(i));ps.setInt(p.size()+1,pageSize);ps.setInt(p.size()+2,(curPage-1)*pageSize);rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("no",nvl(rs.getString("asset_no")));r.put("cls",nvl(rs.getString("asset_class")));r.put("name",nvl(rs.getString("item_name")));r.put("model",nvl(rs.getString("model")));r.put("loc",nvl(rs.getString("detail_location")));r.put("dept",nvl(rs.getString("manage_dept")));r.put("mgr",nvl(rs.getString("manager_name")));r.put("st",nvl(rs.getString("asset_status")));list.add(r);}
    rs.close();ps.close();conn.close();}catch(Exception e){dbErr=e.getMessage();}
%>
<%! private String nvl(String s){return s==null?"":s;}
    private String esc(String s){if(s==null)return "";return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;").replace("\"","&quot;");} %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CAN — 자원 검색</title>

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

/* HEADER */
.app-header {
  background: var(--header-bg);
  backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid var(--border-color);
  transition: all 0.3s ease;
  padding: 1rem 2rem;
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
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

.user-tag-pill {
  background: var(--surface);
  border: 1px solid #cbd5e1;
  padding: 6px 14px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--txt-main);
  font-family: var(--font-mono);
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

/* MAIN CONTAINER */
.main-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

/* HERO SEARCH SECTION */
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

[data-theme="dark"] .hero-search-card::after {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0%, rgba(74, 222, 128, 0.08) 100%);
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

.hero-title em {
  color: var(--emerald-main);
  font-style: normal;
}

[data-theme="dark"] .hero-title em {
  color: #4ade80;
}

.hero-subtitle {
  color: #64748b;
  font-size: 0.95rem;
  margin-bottom: 1.5rem;
}

[data-theme="dark"] .hero-subtitle {
  color: rgba(255, 255, 255, 0.85);
}

/* SEARCH FORM */
.search-form {
  margin-top: 1.5rem;
}

.search-form-row {
  display: grid;
  grid-template-columns: 1fr 160px 160px auto auto auto;
  gap: 12px;
  align-items: center;
}

.search-form-row input,
.search-form-row select {
  background: rgba(255, 255, 255, 0.8);
  border: 1.5px solid rgba(2, 132, 199, 0.3);
  border-radius: var(--radius-md);
  padding: 11px 14px;
  font-size: 0.95rem;
  color: #0f172a;
  font-family: var(--font-main);
  transition: all 0.2s;
  height: 42px;
}

[data-theme="dark"] .search-form-row input,
[data-theme="dark"] .search-form-row select {
  background: rgba(255, 255, 255, 0.12);
  border: 1.5px solid rgba(255, 255, 255, 0.35);
  color: #ffffff;
}

.search-form-row input::placeholder {
  color: #94a3b8;
}

[data-theme="dark"] .search-form-row input::placeholder {
  color: rgba(255, 255, 255, 0.55);
}

.search-form-row select option {
  background: #ffffff;
  color: #0f172a;
}

[data-theme="dark"] .search-form-row select option {
  background: #1e293b;
  color: #ffffff;
}

.search-form-row input:focus,
.search-form-row select:focus {
  background: #ffffff;
  border-color: #0284c7;
  outline: none;
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
}

[data-theme="dark"] .search-form-row input:focus,
[data-theme="dark"] .search-form-row select:focus {
  background: rgba(255, 255, 255, 0.18);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

.search-btn {
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: #ffffff;
  border: none;
  border-radius: var(--radius-md);
  padding: 11px 24px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-size: 0.95rem;
  height: 42px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.search-btn:hover {
  background: linear-gradient(135deg, #0369a1 0%, #0284c7 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);
}

.search-reset-btn {
  background: transparent;
  color: #ffffff;
  border: 1.5px solid rgba(255, 255, 255, 0.5);
  border-radius: var(--radius-md);
  padding: 10px 20px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-size: 0.95rem;
  height: 42px;
  display: inline-flex;
  align-items: center;
}

.search-reset-btn:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.8);
  box-shadow: 0 2px 8px rgba(255, 255, 255, 0.1);
}

.add-asset-btn {
  background: var(--emerald-main);
  color: #ffffff;
  border: none;
  border-radius: var(--radius-md);
  padding: 11px 18px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-size: 0.95rem;
  height: 42px;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.add-asset-btn:hover {
  background: #15803d;
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(22, 163, 74, 0.3);
}

/* ALERT */
.alert-error {
  background: #fef2f2;
  border: 1.5px solid #fca5a5;
  border-radius: var(--radius-md);
  color: var(--red-main);
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

[data-theme="dark"] .alert-error {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

/* RESULTS CARD */
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

.results-icon {
  width: 40px;
  height: 40px;
  background: var(--sky-bg);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
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

/* TABLE */
.table-responsive {
  border-radius: var(--radius-lg);
  overflow: hidden;
}

.results-table {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.95rem;
}

.results-table th {
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

.results-table td {
  padding: 14px 16px;
  border-bottom: 1px solid var(--border-color);
  color: var(--txt-sub);
  vertical-align: middle;
}

.results-table tr:hover td {
  background: var(--sky-bg);
}

.results-table tr {
  cursor: pointer;
  transition: background 0.1s;
}

.results-table tr:last-child td {
  border-bottom: none;
}

/* BADGE */
.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 0.8rem;
  font-weight: 700;
  font-family: var(--font-mono);
  white-space: nowrap;
}

.badge-info {
  background: var(--sky-light);
  color: var(--sky-primary);
}

.badge-success {
  background: #dcfce7;
  color: #15803d;
}

.badge-danger {
  background: #fee2e2;
  color: #b91c1c;
}

.badge-warning {
  background: #fef3c7;
  color: #b45309;
}

/* ACTION BUTTONS */
.action-buttons {
  display: flex;
  gap: 6px;
  flex-wrap: wrap;
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

/* EMPTY STATE */
.empty-state {
  text-align: center;
  padding: 3rem 2rem;
  color: var(--txt-muted);
}

.empty-state-icon {
  font-size: 2.5rem;
  margin-bottom: 1rem;
  opacity: 0.3;
  display: block;
}

.empty-state-text {
  font-size: 0.95rem;
  margin-bottom: 1rem;
}

.empty-state-link {
  color: var(--sky-primary);
  font-weight: 600;
  text-decoration: none;
}

.empty-state-link:hover {
  text-decoration: underline;
}

/* PAGINATION */
.pagination-wrapper {
  display: flex;
  justify-content: center;
  gap: 6px;
  flex-wrap: wrap;
  margin-top: 2rem;
}

.pag-btn {
  background: var(--surface);
  border: 1.5px solid var(--border-color);
  color: var(--txt-sub);
  padding: 8px 14px;
  border-radius: var(--radius-md);
  font-size: 0.9rem;
  font-weight: 600;
  font-family: var(--font-mono);
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
}

.pag-btn:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
}

.pag-btn.active {
  background: var(--sky-primary);
  color: #ffffff;
  border-color: var(--sky-primary);
  font-weight: 700;
}

/* FOOTER */
.app-footer {
  background: var(--surface);
  border-top: 1px solid var(--border-color);
  color: var(--txt-sub);
  padding: 2rem 0;
  margin-top: 4rem;
  font-size: 0.85rem;
}

.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  color: var(--txt-main);
}

.footer-logo em {
  color: var(--sky-primary);
  font-style: normal;
}

.footer-team {
  text-align: center;
  font-family: var(--font-mono);
  line-height: 1.8;
}

.footer-team strong {
  color: var(--sky-primary);
  font-size: 0.9rem;
}

/* DARK MODE */
[data-theme="dark"] .results-table th {
  background: #1e3a5f;
  color: #f1f5f9;
}

[data-theme="dark"] .results-table td {
  border-bottom-color: #334155;
  color: #e2e8f0;
}

[data-theme="dark"] .results-table tr:hover td {
  background: #1e3a5f;
  color: #f1f5f9;
}

[data-theme="dark"] .results-card {
  background: #1e293b;
  color: #f1f5f9;
}

[data-theme="dark"] .search-form-row input,
[data-theme="dark"] .search-form-row select {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.3);
  color: #f1f5f9;
}

[data-theme="dark"] .badge-info {
  background: #1e3a5f;
  color: #38bdf8;
}

/* RESPONSIVE */
@media (max-width: 1024px) {
  .search-form-row {
    grid-template-columns: 1fr 1fr;
  }
}

@media (max-width: 768px) {
  .header-inner {
    gap: 0.5rem;
  }

  .nav-right {
    order: 3;
    width: 100%;
  }

  .search-form-row {
    grid-template-columns: 1fr;
  }

  .search-form-row input,
  .search-form-row select,
  .search-btn,
  .search-reset-btn,
  .add-asset-btn {
    width: 100%;
  }

  .results-table {
    font-size: 0.85rem;
  }

  .results-table th,
  .results-table td {
    padding: 10px 12px;
  }

  .hero-search-card {
    padding: 1.5rem 1rem;
  }

  .hero-title {
    font-size: 1.5rem;
  }

  .action-buttons {
    flex-direction: column;
  }

  .btn-action {
    width: 100%;
    text-align: center;
  }
}

    </style>
</head>
<body>

<!-- HEADER -->
<header class="app-header">
  <div class="header-inner">
    <a href="/CAN/main_<%= loginRole %>.jsp" class="brand-logo">
      <i class="bi bi-compass-fill fs-5"></i>
      <span>ICT <strong style="color: var(--sky-primary);">CAN</strong></span>
    </a>
    <div class="nav-right" style="margin-left: auto;">
      <span class="user-tag-pill">
        <i class="bi bi-person-circle"></i>
        <%= loginName %> <span style="color: var(--sky-primary);">
        <%= "student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"admin".equals(loginRole)?"관리자":"게스트" %>
        </span>
      </span>
      <button type="button" class="theme-toggle" onclick="toggleTheme()">
        <i class="bi bi-moon" id="themeIcon"></i>
      </button>
      <a href="/CAN/main_<%= loginRole %>.jsp" class="nav-link"><i class="bi bi-house"></i>홈</a>
      <form action="/CAN/logout" method="post" class="m-0">
        <button type="submit" class="nav-link" style="border: none; background: none; cursor: pointer;">
          <i class="bi bi-box-arrow-right"></i>로그아웃
        </button>
      </form>
    </div>
  </div>
</header>

<main class="main-container">

  <!-- HERO SEARCH SECTION -->
  <div class="hero-search-card">
    <div class="hero-search-content">
      <div class="hero-subtitle">ICT CAN · 자원 검색</div>
      <h1 class="hero-title">자산 <em><%= String.format("%,d", totalCount) %>건</em> 발견됨</h1>
      <p class="hero-subtitle">자산번호, 품목명, 위치, 관리부서로 검색하세요.</p>

      <form method="get" action="/CAN/search.jsp" class="search-form">
        <div class="search-form-row">
          <input type="text" name="keyword" value="<%= keyword %>" placeholder="자산번호, 품목명, 위치 검색...">
          <select name="type">
            <option value="">전체 분류</option>
            <option value="공기구비품" <%= "공기구비품".equals(type)?"selected":"" %>>공기구비품</option>
            <option value="집기비품" <%= "집기비품".equals(type)?"selected":"" %>>집기비품</option>
            <option value="무형고정자산" <%= "무형고정자산".equals(type)?"selected":"" %>>소프트웨어</option>
          </select>
          <select name="status">
            <option value="">전체 상태</option>
            <option value="사용중" <%= "사용중".equals(status)?"selected":"" %>>사용중</option>
            <option value="사용가능" <%= "사용가능".equals(status)?"selected":"" %>>사용가능</option>
          </select>
          <button type="submit" class="search-btn"><i class="bi bi-search me-1"></i>검색</button>
          <a href="/CAN/search.jsp" class="search-reset-btn">초기화</a>
          <% if("admin".equals(loginRole)||"assistant".equals(loginRole)||"professor".equals(loginRole)){ %>
          <a href="/CAN/asset_manage.jsp?action=new" class="add-asset-btn"><i class="bi bi-plus-circle me-1"></i>등록</a>
          <% } %>
        </div>
      </form>
    </div>
  </div>

  <!-- ERROR ALERT -->
  <% if(!dbErr.isEmpty()){ %>
  <div class="alert-error">
    <i class="bi bi-exclamation-triangle-fill"></i>
    <%= dbErr %>
  </div>
  <% } %>

  <!-- RESULTS CARD -->
  <div class="results-card">
    <div class="results-header">
      <div class="results-icon">📋</div>
      <div>
        <div class="results-title">검색 결과</div>
        <div class="results-subtitle">총 <%= String.format("%,d", totalCount) %>건 · 페이지 <%= curPage %>/<%= totalPage %></div>
      </div>
    </div>

    <% if(list.isEmpty()){ %>
    <div class="empty-state">
      <i class="bi bi-search empty-state-icon"></i>
      <div class="empty-state-text">검색 결과가 없습니다.</div>
      <a href="/CAN/search.jsp" class="empty-state-link">전체 보기</a>
    </div>
    <% } else { %>
    <div class="table-responsive">
      <table class="results-table">
        <thead>
          <tr>
            <th>자산번호</th>
            <th>분류</th>
            <th>품목명</th>
            <th>위치</th>
            <th>관리부서</th>
            <th>관리자</th>
            <th>상태</th>
            <th>관리</th>
          </tr>
        </thead>
        <tbody>
          <% for(Map<String,String> a: list) {
             String st = a.get("st");
             String badgeClass = st.contains("사용중") ? "badge-danger" : st.contains("점검") ? "badge-warning" : "badge-success";
             String cls = a.get("cls");
             String clsBadge = cls.equals("무형고정자산") ? "badge-info" : cls.equals("집기비품") ? "badge-info" : "badge-info";
             String clsLabel = cls.equals("무형고정자산") ? "SW" : cls.equals("집기비품") ? "집기" : "공기구";
          %>
          <tr onclick="location.href='/CAN/detail.jsp?id=<%= a.get("no") %>'">
            <td style="font-family: var(--font-mono); font-size: 0.85rem; color: var(--txt-muted);"><%= a.get("no") %></td>
            <td><span class="badge <%= clsBadge %>"><%= clsLabel %></span></td>
            <td>
              <div style="font-weight: 700;"><%= a.get("name") %></div>
              <div style="font-size: 0.8rem; color: var(--txt-muted);"><%= a.get("model") %></div>
            </td>
            <td><i class="bi bi-geo-alt" style="color: var(--emerald-main); margin-right: 4px;"></i><%= a.get("loc") %></td>
            <td><%= a.get("dept") %></td>
            <td><%= a.get("mgr") %></td>
            <td><span class="badge <%= badgeClass %>"><%= st.isEmpty()?"정보없음":st %></span></td>
            <td onclick="event.stopPropagation()">
              <div class="action-buttons">
                <a href="/CAN/detail.jsp?id=<%= a.get("no") %>" class="btn-action">상세</a>
                <% if(!"guest".equals(loginRole)){ %><a href="/CAN/reserve.jsp?id=<%= a.get("no") %>" class="btn-action">예약</a><% } %>
                <% if("admin".equals(loginRole)||"assistant".equals(loginRole)||"professor".equals(loginRole)){ %>
                <a href="/CAN/asset_manage.jsp?keyword=<%= a.get("no") %>" class="btn-action btn-action-edit">수정/삭제</a>
                <% } %>
              </div>
            </td>
          </tr>
          <% } %>
        </tbody>
      </table>
    </div>

    <!-- PAGINATION -->
    <div class="pagination-wrapper">
      <% String encKw=java.net.URLEncoder.encode(keyword,"UTF-8"),encType=java.net.URLEncoder.encode(type,"UTF-8"),encSt=java.net.URLEncoder.encode(status,"UTF-8"); %>
      <% if(curPage > 1){ %><a href="/CAN/search.jsp?keyword=<%= encKw %>&type=<%= encType %>&status=<%= encSt %>&page=<%= curPage-1 %>" class="pag-btn">‹</a><% } %>
      <% int sp=Math.max(1,curPage-4), ep=Math.min(totalPage, curPage+4); for(int p2=sp; p2<=ep; p2++){ %>
      <a href="/CAN/search.jsp?keyword=<%= encKw %>&type=<%= encType %>&status=<%= encSt %>&page=<%= p2 %>" class="pag-btn <%= p2==curPage?"active":"" %>"><%= p2 %></a>
      <% } %>
      <% if(curPage < totalPage){ %><a href="/CAN/search.jsp?keyword=<%= encKw %>&type=<%= encType %>&status=<%= encSt %>&page=<%= curPage+1 %>" class="pag-btn">›</a><% } %>
    </div>
    <% } %>
  </div>

</main>

<!-- FOOTER -->
<footer class="app-footer">
  <div class="footer-inner">
    <a href="/CAN/campuslogin.jsp" class="footer-logo">
      <span style="width: 24px; height: 24px; background: var(--sky-primary); border-radius: 6px; display: flex; align-items: center; justify-content: center; overflow: hidden;">
        <img src="/CAN/images/logo.png" alt="ICT" style="width: 100%; height: 100%; object-fit: contain;">
      </span>
      ICT <em>CAN</em>
    </a>
    <div class="footer-team">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 &nbsp;&middot;&nbsp; 권동해 &nbsp;&middot;&nbsp; 원태연 &nbsp;&middot;&nbsp; 이수혁
    </div>
    <div style="text-align: right; font-family: var(--font-mono); font-size: 0.8rem;">
      ICT폴리텍대학 캠퍼스 내비게이션<br>
      &copy; 2026 ICT CAN. All rights reserved.
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
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