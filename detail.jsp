<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%  String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName"),loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    String assetNo=request.getParameter("id");if(assetNo==null||assetNo.trim().isEmpty()){response.sendRedirect("/CAN/search.jsp");return;}
    Map<String,String> asset=new LinkedHashMap<>();List<Map<String,String>> transfers=new ArrayList<>(),reserves=new ArrayList<>();String dbErr="";
    try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    PreparedStatement ps=conn.prepareStatement("SELECT * FROM assets WHERE asset_no=?");ps.setString(1,assetNo);ResultSet rs=ps.executeQuery();
    if(rs.next()){ResultSetMetaData m=rs.getMetaData();for(int i=1;i<=m.getColumnCount();i++){String v=rs.getString(i);asset.put(m.getColumnName(i),v!=null?v:"");}}rs.close();ps.close();
    ps=conn.prepareStatement("SELECT transfer_date,before_dept,before_location,after_dept,after_location,remark FROM asset_transfer WHERE asset_no=? ORDER BY transfer_date DESC");ps.setString(1,assetNo);rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("date",nvl(rs.getString(1)));r.put("fdept",nvl(rs.getString(2)));r.put("floc",nvl(rs.getString(3)));r.put("tdept",nvl(rs.getString(4)));r.put("tloc",nvl(rs.getString(5)));r.put("rmk",nvl(rs.getString(6)));transfers.add(r);}rs.close();ps.close();
    ps=conn.prepareStatement("SELECT r.reserve_date,r.start_time,r.end_time,r.purpose,u.user_name FROM reservations r JOIN users u ON r.user_id=u.user_id WHERE r.asset_no=? AND r.reserve_date>=CURDATE() AND r.status='예약완료' ORDER BY r.reserve_date,r.start_time");ps.setString(1,assetNo);rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("date",nvl(rs.getString(1)));r.put("start",nvl(rs.getString(2)));r.put("end",nvl(rs.getString(3)));r.put("purpose",nvl(rs.getString(4)));r.put("user",nvl(rs.getString(5)));reserves.add(r);}rs.close();ps.close();conn.close();
    }catch(Exception e){dbErr=e.getMessage();}
    String nm=asset.getOrDefault("item_name","정보없음"),cls=asset.getOrDefault("asset_class",""),st=asset.getOrDefault("asset_status","");
    String loc=asset.getOrDefault("location",""),dloc=asset.getOrDefault("detail_location","");
    String stBadge=st.contains("사용중")?"badge-danger":st.contains("점검")?"badge-warning":"badge-success";
%>
<%! private String nvl(String s){return s==null?"":s;} %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CAN — 자산 상세</title>

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
  margin-left: auto;
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
  cursor: pointer;
  border: none;
  background: none;
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

/* HERO SECTION */
.hero-card {
  background: linear-gradient(135deg, #e0f2fe 0%, #bae6fd 30%, #7dd3fc 100%);
  border-radius: var(--radius-xl);
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: 0 8px 24px rgba(2, 132, 199, 0.2);
  position: relative;
  overflow: hidden;
  border: 1px solid rgba(2, 132, 199, 0.3);
}

[data-theme="dark"] .hero-card {
  background: linear-gradient(135deg, #0f172a 0%, #164e63 40%, #0d6147 100%);
  border-color: rgba(74, 222, 128, 0.2);
}

.hero-card::after {
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

[data-theme="dark"] .hero-card::after {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0%, rgba(74, 222, 128, 0.08) 100%);
}

.hero-content {
  position: relative;
  z-index: 1;
  display: flex;
  justify-content: space-between;
  align-items: flex-start;
  flex-wrap: wrap;
  gap: 2rem;
}

.hero-text {
  flex: 1;
  min-width: 300px;
}

.hero-subtitle {
  color: #0f172a;
  font-size: 0.95rem;
  margin-bottom: 0.5rem;
  font-family: var(--font-mono);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

[data-theme="dark"] .hero-subtitle {
  color: rgba(255, 255, 255, 0.85);
}

.hero-title {
  font-size: 2rem;
  font-weight: 800;
  color: #0f172a;
  margin-bottom: 1rem;
}

[data-theme="dark"] .hero-title {
  color: #ffffff;
}

.hero-desc {
  color: #334155;
  font-size: 0.95rem;
  margin-bottom: 1rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

[data-theme="dark"] .hero-desc {
  color: rgba(255, 255, 255, 0.85);
}

.hero-actions {
  display: flex;
  gap: 12px;
  flex-wrap: wrap;
  align-items: center;
}

.btn-primary-hero {
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: #ffffff;
  border: none;
  border-radius: var(--radius-md);
  padding: 10px 20px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-size: 0.95rem;
  height: 38px;
  display: inline-flex;
  align-items: center;
}

.btn-primary-hero:hover {
  background: linear-gradient(135deg, #0369a1 0%, #0284c7 100%);
  transform: translateY(-2px);
}

.btn-secondary-hero {
  background: transparent;
  color: #ffffff;
  border: 1.5px solid rgba(255, 255, 255, 0.5);
  border-radius: var(--radius-md);
  padding: 10px 18px;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  white-space: nowrap;
  font-size: 0.95rem;
  height: 38px;
  display: inline-flex;
  align-items: center;
}

.btn-secondary-hero:hover {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.8);
}

/* CARD */
.detail-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2rem;
  box-shadow: var(--shadow-soft);
  border: 1px solid #f1f5f9;
  margin-bottom: 2rem;
}

.card-header {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.card-icon {
  width: 40px;
  height: 40px;
  background: var(--sky-bg);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.card-title {
  font-size: 1.1rem;
  font-weight: 800;
  color: var(--txt-main);
}

.card-subtitle {
  font-size: 0.85rem;
  color: var(--txt-muted);
  margin-top: 2px;
  font-family: var(--font-mono);
}

/* INFO ROWS */
.info-grid {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
  gap: 1.5rem;
}

.info-row {
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.info-row:last-child {
  border-bottom: none;
}

.info-label {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  font-weight: 700;
  color: var(--txt-muted);
  text-transform: uppercase;
  letter-spacing: 0.05em;
  margin-bottom: 4px;
  display: block;
}

.info-value {
  font-size: 0.95rem;
  font-weight: 600;
  color: var(--txt-main);
}

.info-value.muted {
  color: var(--txt-muted);
  font-weight: 400;
}

/* BADGE */
.badge {
  display: inline-flex;
  align-items: center;
  padding: 8px 14px;
  border-radius: var(--radius-md);
  font-size: 0.85rem;
  font-weight: 700;
  font-family: var(--font-mono);
  white-space: nowrap;
  height: 38px;
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

.badge-info {
  background: var(--sky-light);
  color: var(--sky-primary);
}

/* TRANSFER HISTORY */
.transfer-item {
  background: var(--sky-bg);
  border: 1px solid var(--sky-light);
  border-radius: var(--radius-md);
  padding: 1rem;
  margin-bottom: 0.75rem;
  display: flex;
  align-items: center;
  gap: 12px;
  flex-wrap: wrap;
}

.transfer-date {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  font-weight: 700;
  background: var(--sky-light);
  color: var(--sky-primary);
  padding: 3px 10px;
  border-radius: 6px;
  white-space: nowrap;
}

.transfer-flow {
  display: flex;
  align-items: center;
  gap: 8px;
  flex: 1;
  min-width: 200px;
}

.dept-name {
  font-weight: 700;
  font-size: 0.95rem;
}

.transfer-arrow {
  color: var(--sky-primary);
  font-weight: 700;
}

/* RESERVATION */
.reserve-item {
  background: #dcfce7;
  border: 1px solid #86efac;
  border-radius: var(--radius-md);
  padding: 1rem;
  margin-bottom: 0.75rem;
}

.reserve-date {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  font-weight: 700;
  color: var(--emerald-main);
}

.reserve-time {
  font-weight: 600;
  font-size: 0.95rem;
  margin-top: 4px;
}

.reserve-user {
  font-size: 0.85rem;
  color: var(--txt-muted);
  margin-top: 4px;
}

/* NAV BUTTON */
.nav-btn-area {
  margin-top: 1.5rem;
  padding-top: 1rem;
  border-top: 1px solid var(--border-color);
}

.btn-nav-full {
  display: flex;
  align-items: center;
  gap: 14px;
  width: 100%;
  background: linear-gradient(135deg, #16a34a 0%, #15803d 100%);
  color: #ffffff;
  border: none;
  border-radius: var(--radius-md);
  padding: 14px 18px;
  text-decoration: none;
  cursor: pointer;
  transition: all 0.2s;
  font-weight: 700;
}

.btn-nav-full:hover {
  background: #15803d;
  transform: translateY(-1px);
}

.btn-nav-full--disabled {
  background: var(--border-color);
  color: var(--txt-muted);
  pointer-events: none;
}

.btn-nav-label {
  font-size: 0.95rem;
  font-weight: 700;
  line-height: 1.2;
}

.btn-nav-sub {
  font-size: 0.8rem;
  font-family: var(--font-mono);
  opacity: 0.9;
  margin-top: 2px;
}

.btn-nav-arrow {
  margin-left: auto;
  font-size: 1.2rem;
  opacity: 0.7;
  flex-shrink: 0;
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

/* EMPTY STATE */
.empty-state {
  text-align: center;
  padding: 2rem;
  color: var(--txt-muted);
}

.empty-state-text {
  font-size: 0.95rem;
}

/* DARK MODE */
[data-theme="dark"] .detail-card {
  background: #1e293b;
  color: #f1f5f9;
}

[data-theme="dark"] .detail-card p,
[data-theme="dark"] .detail-card span {
  color: #e2e8f0;
}

[data-theme="dark"] .transfer-item {
  background: #1e3a5f;
  border-color: #0c4a6e;
  color: #f1f5f9;
}

[data-theme="dark"] .transfer-item span,
[data-theme="dark"] .transfer-item p {
  color: #e2e8f0;
}

[data-theme="dark"] .reserve-item {
  background: rgba(22, 163, 74, 0.15);
  border-color: #4ade80;
  color: #f1f5f9;
}

[data-theme="dark"] .reserve-item span,
[data-theme="dark"] .reserve-item p {
  color: #e2e8f0;
}

/* RESPONSIVE */
@media (max-width: 768px) {
  .header-inner {
    gap: 0.5rem;
  }

  .nav-right {
    order: 3;
    width: 100%;
  }

  .hero-content {
    flex-direction: column;
  }

  .hero-title {
    font-size: 1.5rem;
  }

  .info-grid {
    grid-template-columns: 1fr;
  }

  .main-container {
    padding: 1rem 0.5rem 2rem;
  }

  .detail-card {
    padding: 1.5rem 1rem;
  }

  .btn-nav-full {
    flex-direction: column;
    text-align: center;
  }

  .btn-nav-arrow {
    margin-left: 0;
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
    <div class="nav-right">
      <span class="user-tag-pill">
        <i class="bi bi-person-circle"></i>
        <%= loginName %> <span style="color: var(--sky-primary);">
        <%= "student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"admin".equals(loginRole)?"관리자":"게스트" %>
        </span>
      </span>
      <button type="button" class="theme-toggle" onclick="toggleTheme()">
        <i class="bi bi-moon" id="themeIcon"></i>
      </button>
      <a href="/CAN/search.jsp" class="nav-link"><i class="bi bi-search"></i>검색</a>
      <form action="/CAN/logout" method="post" class="m-0">
        <button type="submit" class="nav-link">
          <i class="bi bi-box-arrow-right"></i>로그아웃
        </button>
      </form>
    </div>
  </div>
</header>

<main class="main-container">

  <!-- ERROR ALERT -->
  <% if(!dbErr.isEmpty()){ %>
  <div class="alert-error">
    <i class="bi bi-exclamation-triangle-fill"></i>
    <%= dbErr %>
  </div>
  <% } %>

  <!-- HERO CARD -->
  <div class="hero-card">
    <div class="hero-content">
      <div class="hero-text">
        <div class="hero-subtitle"><%= cls %> · <%= assetNo %></div>
        <h1 class="hero-title"><%= nm %></h1>
        <div class="hero-desc">
          <i class="bi bi-geo-alt" style="color: var(--emerald-main);"></i>
          <%= loc %> <%= dloc %>
        </div>
        <div class="hero-actions">
          <span class="badge <%= stBadge %>"><%= st.isEmpty()?"정보없음":st %></span>
          <% if(!"guest".equals(loginRole)){ %><a href="/CAN/reserve.jsp?id=<%= assetNo %>" class="btn-primary-hero">예약하기</a><% } %>
          <a href="/CAN/search.jsp" class="btn-secondary-hero">목록으로</a>
        </div>
      </div>
    </div>
  </div>

  <!-- BASIC INFO -->
  <div class="detail-card">
    <div class="card-header">
      <div class="card-icon">📋</div>
      <div>
        <div class="card-title">기본 정보</div>
      </div>
    </div>
    <div class="info-grid">
      <div class="info-row">
        <label class="info-label">자산번호</label>
        <div class="info-value" style="font-family: var(--font-mono); font-size: 0.9rem;"><%= assetNo %></div>
      </div>
      <div class="info-row">
        <label class="info-label">자산분류</label>
        <div class="info-value"><%= cls %></div>
      </div>
      <div class="info-row">
        <label class="info-label">품목명</label>
        <div class="info-value"><%= nm %></div>
      </div>
      <div class="info-row">
        <label class="info-label">제조사</label>
        <div class="info-value"><%= asset.getOrDefault("manufacturer","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">모델</label>
        <div class="info-value"><%= asset.getOrDefault("model","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">규격/스펙</label>
        <div class="info-value"><%= asset.getOrDefault("spec","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">취득일자</label>
        <div class="info-value"><%= asset.getOrDefault("acq_date","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">취득가</label>
        <div class="info-value"><%= asset.getOrDefault("acq_price","").isEmpty()?"-":asset.get("acq_price")+"원" %></div>
      </div>
      <div class="info-row">
        <label class="info-label">내용연수</label>
        <div class="info-value"><%= asset.getOrDefault("useful_life","").isEmpty()?"-":asset.get("useful_life")+"년" %></div>
      </div>
      <div class="info-row">
        <label class="info-label">수량</label>
        <div class="info-value"><%= asset.getOrDefault("quantity","-") %></div>
      </div>
    </div>
  </div>

  <!-- LOCATION & MANAGEMENT -->
  <div class="detail-card">
    <div class="card-header">
      <div class="card-icon">📍</div>
      <div>
        <div class="card-title">위치 / 관리 정보</div>
      </div>
    </div>
    <div class="info-grid">
      <div class="info-row">
        <label class="info-label">위치</label>
        <div class="info-value"><%= loc %></div>
      </div>
      <div class="info-row">
        <label class="info-label">상세위치</label>
        <div class="info-value"><%= dloc.isEmpty()?"-":dloc %></div>
      </div>
      <div class="info-row">
        <label class="info-label">층</label>
        <div class="info-value"><%= asset.getOrDefault("floor","").isEmpty()?"-":asset.get("floor")+"층" %></div>
      </div>
      <div class="info-row">
        <label class="info-label">위도</label>
        <div class="info-value" style="font-family: var(--font-mono); font-size: 0.9rem;"><%= asset.getOrDefault("latitude","미등록") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">경도</label>
        <div class="info-value" style="font-family: var(--font-mono); font-size: 0.9rem;"><%= asset.getOrDefault("longitude","미등록") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">관리부서</label>
        <div class="info-value"><%= asset.getOrDefault("manage_dept","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">관리자</label>
        <div class="info-value"><%= asset.getOrDefault("manager_name","-") %></div>
      </div>
      <div class="info-row">
        <label class="info-label">상태</label>
        <div class="info-value"><span class="badge <%= stBadge %>"><%= st.isEmpty()?"정보없음":st %></span></div>
      </div>
      <div class="info-row">
        <label class="info-label">비고</label>
        <div class="info-value"><%= asset.getOrDefault("remark","-") %></div>
      </div>

      <%
        String navBuilding = loc;
        if (navBuilding.contains("|")) {
            String[] parts = navBuilding.split("\\|");
            if (parts.length > 1) {
                navBuilding = parts[1].trim();
                navBuilding = navBuilding.replaceAll("^제", "");
            }
        }
        String navRoom        = dloc;
        String navRoomId      = asset.getOrDefault("room_id","");
        String navBuildingEnc = "";
        String navRoomEnc     = "";
        String navRoomIdEnc   = "";
        try {
            navBuildingEnc = java.net.URLEncoder.encode(navBuilding, "UTF-8");
            navRoomEnc     = java.net.URLEncoder.encode(navRoom,     "UTF-8");
            navRoomIdEnc   = java.net.URLEncoder.encode(navRoomId,   "UTF-8");
        } catch(Exception _e){}
        boolean canNav = !navBuilding.isEmpty();
      %>

      <div style="grid-column: 1/-1;">
        <div class="nav-btn-area">
          <% if (canNav) { %>
            <a href="/CAN/navigationTest1.jsp?destBuilding=<%= navBuildingEnc %>&destName=<%= navRoomEnc %>&roomId=<%= navRoomIdEnc %>"
               class="btn-nav-full">
              <i class="bi bi-signpost-2-fill"></i>
              <div>
                <div class="btn-nav-label">길 안내 시작</div>
                <div class="btn-nav-sub"><%= navBuilding %><% if(!navRoom.isEmpty()){ %> · <%= navRoom %><% } %></div>
              </div>
              <i class="bi bi-chevron-right btn-nav-arrow"></i>
            </a>
          <% } else { %>
            <div class="btn-nav-full btn-nav-full--disabled">
              <i class="bi bi-signpost-2"></i>
              <div>
                <div class="btn-nav-label">길 안내 불가</div>
                <div class="btn-nav-sub">위치 정보가 없습니다</div>
              </div>
            </div>
          <% } %>
        </div>
      </div>
    </div>
  </div>

  <!-- TRANSFER HISTORY -->
  <div class="detail-card">
    <div class="card-header">
      <div class="card-icon">↔</div>
      <div>
        <div class="card-title">이관 이력</div>
        <div class="card-subtitle"><%= transfers.size() %>건</div>
      </div>
    </div>
    <% if(transfers.isEmpty()){ %>
    <div class="empty-state">
      <div class="empty-state-text">이관 이력이 없습니다.</div>
    </div>
    <% } else { %>
    <% for(Map<String,String> t: transfers){ %>
    <div class="transfer-item">
      <span class="transfer-date"><%= t.get("date") %></span>
      <div class="transfer-flow">
        <span class="dept-name"><%= t.get("fdept") %></span>
        <span class="transfer-arrow">→</span>
        <span class="dept-name" style="color: var(--sky-primary);"><%= t.get("tdept") %></span>
        <% if(!t.get("rmk").isEmpty()){ %><span style="font-size: 0.85rem; color: var(--txt-muted);">— <%= t.get("rmk") %></span><% } %>
      </div>
      <div style="width: 100%; font-size: 0.85rem; color: var(--txt-muted);"><%= t.get("floc") %> → <%= t.get("tloc") %></div>
    </div>
    <% } %>
    <% } %>
  </div>

  <!-- RESERVATIONS -->
  <div class="detail-card">
    <div class="card-header">
      <div class="card-icon">📅</div>
      <div>
        <div class="card-title">예약 현황</div>
        <div class="card-subtitle">향후 예약 <%= reserves.size() %>건</div>
      </div>
    </div>
    <% if(reserves.isEmpty()){ %>
    <div class="empty-state">
      <div class="empty-state-text">예약 내역이 없습니다.</div>
    </div>
    <% } else { %>
    <% for(Map<String,String> rv: reserves){ %>
    <div class="reserve-item">
      <div class="reserve-date"><%= rv.get("date") %></div>
      <div class="reserve-time"><%= rv.get("start") %> ~ <%= rv.get("end") %></div>
      <div class="reserve-user"><%= rv.get("user") %></div>
      <% if(!rv.get("purpose").isEmpty()){ %><div class="reserve-user" style="font-style: italic;">— <%= rv.get("purpose") %></div><% } %>
    </div>
    <% } %>
    <% } %>
    <% if(!"guest".equals(loginRole)){ %>
    <div style="margin-top: 1.5rem;">
      <a href="/CAN/reserve.jsp?id=<%= assetNo %>" class="btn-primary-hero" style="display: inline-block;">예약하기</a>
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
