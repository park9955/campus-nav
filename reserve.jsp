<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%  String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName"),loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    if("guest".equals(loginRole)){response.sendRedirect("/CAN/main_guest.jsp");return;}
    // visitor는 main_visitor.jsp에서 자체 예약폼 사용
    String assetNo=request.getParameter("id");if(assetNo==null)assetNo="";
    String success=request.getParameter("success");if(success==null)success="";
    String errMsg=request.getParameter("err");if(errMsg==null)errMsg="";
    if("POST".equals(request.getMethod())){
        String rNo=request.getParameter("resourceId"),rDate=request.getParameter("date"),rStart=request.getParameter("startTime"),rEnd=request.getParameter("endTime"),purpose=request.getParameter("purpose"),phone=request.getParameter("phone");
        if(rNo!=null&&!rNo.isEmpty()&&rDate!=null&&rStart!=null&&rEnd!=null&&!rDate.isEmpty()){
            try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
            PreparedStatement ps=conn.prepareStatement("SELECT COUNT(*) FROM reservations WHERE asset_no=? AND reserve_date=? AND status='예약완료' AND start_time<? AND end_time>?");ps.setString(1,rNo);ps.setString(2,rDate);ps.setString(3,rEnd);ps.setString(4,rStart);ResultSet rs=ps.executeQuery();boolean dup=rs.next()&&rs.getInt(1)>0;rs.close();ps.close();
            if(dup){response.sendRedirect("/CAN/reserve.jsp?id="+rNo+"&err=이미+예약된+시간입니다");}
            else{ps=conn.prepareStatement("INSERT INTO reservations(asset_no,user_id,reserve_date,start_time,end_time,purpose,phone,status) VALUES(?,?,?,?,?,?,?,'예약완료')");ps.setString(1,rNo);ps.setString(2,loginUser);ps.setString(3,rDate);ps.setString(4,rStart);ps.setString(5,rEnd);ps.setString(6,purpose!=null?purpose:"");ps.setString(7,phone!=null?phone:"");ps.executeUpdate();ps.close();response.sendRedirect("/CAN/reserve.jsp?id="+rNo+"&success=true");}
            conn.close();}catch(Exception e){response.sendRedirect("/CAN/reserve.jsp?id="+assetNo+"&err="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));}return;}
    }
    Map<String,String> assetInfo=new LinkedHashMap<>();List<Map<String,String>> existReserves=new ArrayList<>();
    if(!assetNo.isEmpty()){try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    PreparedStatement ps=conn.prepareStatement("SELECT item_name,detail_location,asset_status FROM assets WHERE asset_no=?");ps.setString(1,assetNo);ResultSet rs=ps.executeQuery();if(rs.next()){assetInfo.put("name",rs.getString(1));assetInfo.put("loc",rs.getString(2));assetInfo.put("st",rs.getString(3));}rs.close();ps.close();
    ps=conn.prepareStatement("SELECT reserve_date,start_time,end_time,user_id FROM reservations WHERE asset_no=? AND reserve_date>=CURDATE() AND status='예약완료' ORDER BY reserve_date,start_time LIMIT 20");ps.setString(1,assetNo);rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("date",rs.getString(1));r.put("start",rs.getString(2));r.put("end",rs.getString(3));r.put("user",rs.getString(4));existReserves.add(r);}rs.close();ps.close();conn.close();}catch(Exception ignored){}}
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ICT CAN — 기자재 예약</title>
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
  text-decoration: none;
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

/* CARD */
.card {
  background: var(--surface);
  border-radius: var(--radius-lg);
  padding: 1.75rem;
  box-shadow: var(--shadow-soft);
  border: 1px solid #f1f5f9;
  margin-bottom: 2rem;
}

.card-head {
  display: flex;
  align-items: center;
  gap: 12px;
  margin-bottom: 1.5rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid var(--border-color);
}

.ch-icon {
  width: 40px;
  height: 40px;
  background: var(--sky-bg);
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
}

.ch-title {
  font-size: 1.1rem;
  font-weight: 800;
  color: var(--txt-main);
}

.ch-sub {
  font-size: 0.85rem;
  color: var(--txt-muted);
  font-family: var(--font-mono);
  margin-top: 0.25rem;
}

/* BUTTONS */
.btn-prim {
  display: inline-block;
  text-align: center;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  padding: 11px 24px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  font-size: 0.95rem;
}

.btn-prim:hover {
  background: linear-gradient(135deg, #0369a1 0%, #0284c7 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);
}

.btn-ghost {
  display: inline-block;
  text-align: center;
  background: transparent;
  color: var(--txt-sub);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 10px 20px;
  font-size: 0.95rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
}

.btn-ghost:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
  background: var(--sky-bg);
}

/* FORM */
.f-label {
  font-family: var(--font-mono);
  font-size: 0.85rem;
  color: var(--txt-sub);
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.f-input {
  width: 100%;
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 11px 14px;
  font-size: 0.95rem;
  outline: none;
  background: var(--surface);
  color: var(--txt-main);
  font-family: var(--font-main);
  transition: border-color 0.2s, box-shadow 0.2s;
}

.f-input:focus {
  border-color: var(--sky-primary);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
}

[data-theme="dark"] .f-input {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.3);
  color: #f1f5f9;
}

[data-theme="dark"] .f-input:focus {
  background: rgba(255, 255, 255, 0.18);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

/* ALERT */
.alert-err {
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

[data-theme="dark"] .alert-err {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

.alert-ok {
  background: #dcfce7;
  border: 1.5px solid #86efac;
  border-radius: var(--radius-md);
  color: #15803d;
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

[data-theme="dark"] .alert-ok {
  background: #1a3a1a;
  border-color: #16a34a;
  color: #4ade80;
}

/* TIME CHECK */
.time-check {
  margin-top: 0.5rem;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  font-size: 0.85rem;
  font-weight: 600;
  display: none;
}

.time-ok {
  background: #dcfce7;
  border: 1px solid #86efac;
  color: #15803d;
}

[data-theme="dark"] .time-ok {
  background: #1a3a1a;
  border-color: #16a34a;
  color: #4ade80;
}

.time-err {
  background: #fef2f2;
  border: 1px solid #fca5a5;
  color: #dc2626;
}

[data-theme="dark"] .time-err {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

/* INFO BOX */
.info-box {
  background: var(--sky-bg);
  border: 1.5px solid rgba(2, 132, 199, 0.4);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  margin-bottom: 1.5rem;
}

[data-theme="dark"] .info-box {
  background: #1e3a5f;
  border-color: rgba(56, 189, 248, 0.3);
  color: #f1f5f9;
}

[data-theme="dark"] .info-box p,
[data-theme="dark"] .info-box span,
[data-theme="dark"] .info-box div {
  color: #e2e8f0;
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

/* RESPONSIVE */
@media (max-width: 1024px) {
  .main-container {
    padding: 1.5rem 1rem 3rem;
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

  .hero-search-card {
    padding: 1.5rem 1rem;
  }

  .hero-title {
    font-size: 1.5rem;
  }

  .btn-prim, .btn-ghost {
    width: 100%;
    display: block;
  }

  .main-container {
    padding: 1rem 0.75rem 2rem;
  }
}

</style>
</head><body>

<!-- TOP NAVIGATION BAR -->
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
      <div class="hero-subtitle">ICT CAN · 기자재 예약</div>
      <h1 class="hero-title"><% if(!assetInfo.isEmpty()){%><em><%= assetInfo.get("name") %></em><%}else{%>기자재 <em>예약</em><%}%></h1>
      <% if(!assetInfo.isEmpty()){%><p class="hero-subtitle"><i class="bi bi-geo-alt me-2"></i><%= assetInfo.get("loc") %></p><%}%>
    </div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!success.isEmpty()){%>
  <div class="alert-ok">
    <i class="bi bi-check-circle-fill"></i>예약이 완료되었습니다!
  </div>
  <%}%>
  <% if(!errMsg.isEmpty()){%>
  <div class="alert-err">
    <i class="bi bi-exclamation-circle-fill"></i><%= errMsg %>
  </div>
  <%}%>

  <div class="row g-4">
    <!-- 왼쪽: 예약 폼 -->
    <div class="col-lg-7">
      <div class="card">
        <div class="card-head">
          <div class="ch-icon">📝</div>
          <div>
            <div class="ch-title">예약 정보 입력</div>
            <% if(!assetInfo.isEmpty()){%><div class="ch-sub"><%= assetInfo.get("name") %></div><%}%>
          </div>
        </div>
        <div class="card-body">
        <form method="post" action="/CAN/reserve.jsp" onsubmit="return checkBefore()">
          <% if(assetNo.isEmpty()){ %>
          <div style="margin-bottom:1.5rem">
            <label class="f-label">기자재 검색</label>
            <div style="position:relative;display:flex;gap:0.75rem">
              <input class="f-input" type="text" id="assetSearch" placeholder="자산명 입력 (예: 노트북, 프로젝터)" autocomplete="off" style="flex:1">
              <button type="button" class="btn-ghost" id="searchBtn" style="white-space:nowrap"><i class="bi bi-search"></i>검색</button>
              <div id="searchResults" style="display:none;position:absolute;top:100%;left:0;right:0;background:var(--surface);border:1px solid var(--border-color);border-radius:var(--radius-lg);max-height:300px;overflow-y:auto;z-index:100;box-shadow:var(--shadow-soft);margin-top:0.25rem"></div>
            </div>
          </div>
          <% }else{ %>
          <input type="hidden" name="resourceId" value="<%= assetNo %>">
          <div style="display:flex;gap:0.75rem;align-items:center;padding:1rem;background:var(--sky-bg);border:1.5px solid rgba(2,132,199,0.3);border-radius:var(--radius-lg);margin-bottom:1.5rem">
            <div style="flex:1">
              <div style="font-weight:700;color:var(--txt-main);font-size:0.95rem"><%= assetInfo.isEmpty()?"":assetInfo.get("name") %></div>
              <div style="font-size:0.8rem;color:var(--txt-muted);font-family:var(--font-mono)"><%= assetNo %></div>
            </div>
            <a href="/CAN/reserve.jsp" class="btn-ghost" style="white-space:nowrap"><i class="bi bi-plus"></i>다른기자재</a>
          </div>
          <% } %>

          <div style="margin-bottom:1.5rem">
            <label class="f-label">예약 날짜 *</label>
            <input class="f-input" type="date" name="date" id="rDate" required onchange="checkTime()" min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
          </div>

          <div class="row g-3" style="margin-bottom:1.5rem">
            <div class="col-6">
              <label class="f-label">시작 시간 *</label>
              <input class="f-input" type="time" name="startTime" id="rStart" required onchange="checkTime()">
            </div>
            <div class="col-6">
              <label class="f-label">종료 시간 *</label>
              <input class="f-input" type="time" name="endTime" id="rEnd" required onchange="checkTime()">
            </div>
          </div>

          <div id="timeCheck" class="time-check"></div>

          <div style="margin-bottom:1.5rem">
            <label class="f-label">사용 목적</label>
            <input class="f-input" type="text" name="purpose" placeholder="예) 캡스톤 프로젝트 작업">
          </div>

          <div style="margin-bottom:2rem">
            <label class="f-label">연락처</label>
            <input class="f-input" type="text" name="phone" placeholder="010-0000-0000">
          </div>

          <button type="submit" class="btn-prim" style="width:100%;padding:0.75rem">
            <i class="bi bi-check-circle me-1"></i>예약 신청
          </button>
        </form>
        </div>
      </div>
    </div>

    <!-- 오른쪽: 자산 정보 -->
    <div class="col-lg-5">
      <% if(!assetNo.isEmpty() && !assetInfo.isEmpty()){ %>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon">📦</div>
          <div>
            <div class="ch-title">기자재 정보</div>
          </div>
        </div>
        <div class="card-body">
          <div class="info-box">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">기자재명</div>
            <div style="font-size:1rem;font-weight:700;color:var(--txt-main);margin-bottom:1rem"><%= assetInfo.get("name") %></div>

            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">위치</div>
            <div style="font-size:0.95rem;color:var(--txt-sub);margin-bottom:1rem">
              <i class="bi bi-geo-alt me-2" style="color:var(--emerald-main)"></i><%= assetInfo.get("loc") %>
            </div>

            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">상태</div>
            <div>
              <span style="display:inline-block;padding:4px 12px;border-radius:var(--radius-pill);font-size:0.8rem;font-weight:700;<%
                String status = assetInfo.get("st");
                if("정상".equals(status) || "사용가능".equals(status)){
                  out.print("background:#dcfce7;color:#15803d");
                } else if("고장".equals(status)){
                  out.print("background:#fef2f2;color:#dc2626");
                } else {
                  out.print("background:var(--sky-bg);color:var(--sky-primary)");
                }
              %>"><%= status != null ? status : "-" %></span>
            </div>
          </div>
          <p style="font-size:0.85rem;color:var(--txt-muted);text-align:center;margin-top:1rem">위 정보를 확인한 후 예약 날짜와 시간을 선택하세요</p>
        </div>
      </div>
      <% } else if(!assetNo.isEmpty()){ %>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon">⚠️</div>
          <div>
            <div class="ch-title">기자재를 찾을 수 없습니다</div>
          </div>
        </div>
        <div class="card-body" style="text-align:center;padding:2rem;color:var(--txt-muted)">
          <i class="bi bi-exclamation-circle" style="font-size:2rem;display:block;margin-bottom:0.75rem;opacity:0.5"></i>
          기자재 번호 <strong style="color:var(--txt-sub)"><%= assetNo %></strong>를 찾을 수 없습니다.<br>
          번호를 다시 확인하세요.
        </div>
      </div>
      <% } else { %>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon">📋</div>
          <div>
            <div class="ch-title">기자재 정보</div>
          </div>
        </div>
        <div class="card-body" style="text-align:center;padding:2rem;color:var(--txt-muted)">
          <i class="bi bi-info-circle" style="font-size:2rem;display:block;margin-bottom:0.75rem;opacity:0.5"></i>
          왼쪽 검색창에 기자재명을 입력하고<br>
          검색 버튼을 클릭하세요
        </div>
      </div>
      <% } %>
    </div>
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

// Asset Search
var assetSearchTimeout;
function performSearch(){
  var searchInput=document.getElementById('assetSearch');
  if(!searchInput) return;
  var keyword=searchInput.value.trim();
  var resultsDiv=document.getElementById('searchResults');
  if(keyword.length<2){alert('2글자 이상 입력하세요');return;}
  fetch('/CAN/searchAssets.jsp?keyword='+encodeURIComponent(keyword))
    .then(function(r){return r.json()})
    .then(function(data){
      if(!data||data.length===0){resultsDiv.innerHTML='<div style="padding:1rem;text-align:center;color:var(--txt-muted)">검색 결과 없음</div>';resultsDiv.style.display='block';return;}
      var html='';
      data.forEach(function(item){
        if(item.error) return;
        var status=item.status||'-';
        var statusColor=status==='정상'||status==='사용가능'?'#15803d':status==='고장'?'#dc2626':'var(--txt-muted)';
        html+='<div style="padding:0.75rem;border-bottom:1px solid var(--border-color);cursor:pointer;transition:background .2s" onmouseover="this.style.background=\'var(--sky-bg)\'" onmouseout="this.style.background=\'transparent\'" onclick="selectAsset(\''+item.assetNo.replace(/'/g,"\\'")+'\')">';
        html+='<div style="font-weight:700;color:var(--txt-main);font-size:0.95rem">'+item.itemName+'</div>';
        html+='<div style="font-size:0.85rem;color:var(--txt-muted);margin-top:0.25rem"><i class="bi bi-geo-alt me-1"></i>'+(item.location||'-')+'</div>';
        html+='<div style="font-size:0.75rem;color:'+statusColor+';margin-top:0.25rem;font-family:var(--font-mono)">'+item.assetNo+' · '+status+'</div>';
        html+='</div>';
      });
      resultsDiv.innerHTML=html;
      resultsDiv.style.display='block';
    })
    .catch(function(e){console.error('검색 오류:',e);resultsDiv.innerHTML='<div style="padding:1rem;text-align:center;color:var(--red-main)">검색 중 오류 발생</div>';resultsDiv.style.display='block';});
}
document.addEventListener('DOMContentLoaded',function(){
  var searchInput=document.getElementById('assetSearch');
  var searchBtn=document.getElementById('searchBtn');
  if(!searchInput) return;
  searchInput.addEventListener('keyup',function(e){
    clearTimeout(assetSearchTimeout);
    if(e.key==='Enter'){performSearch();return;}
    var keyword=this.value.trim();
    var resultsDiv=document.getElementById('searchResults');
    if(keyword.length<2){resultsDiv.style.display='none';return;}
    assetSearchTimeout=setTimeout(performSearch,300);
  });
  if(searchBtn){
    searchBtn.addEventListener('click',function(e){e.preventDefault();performSearch();});
  }
});
function selectAsset(assetNo){location.href='/CAN/reserve.jsp?id='+encodeURIComponent(assetNo);}

// Time Check
function checkTime(){
  var start=document.getElementById('rStart').value,end=document.getElementById('rEnd').value,el=document.getElementById('timeCheck');
  if(!start||!end){el.style.display='none';return;}
  if(start>=end){el.className='time-check time-err';el.innerHTML='<i class="bi bi-x-circle-fill me-2"></i>종료 시간이 시작 시간보다 빠릅니다.';el.style.display='block';return;}
  el.className='time-check time-ok';el.innerHTML='<i class="bi bi-check-circle-fill me-2"></i><strong>예약 가능!</strong> 선택하신 시간에 예약할 수 있습니다.';el.style.display='block';
}

function checkBefore(){var el=document.getElementById('timeCheck');if(el&&el.classList.contains('time-err')){alert('예약 불가능한 시간입니다.');return false;}return true;}

// Close search results when clicking outside
document.addEventListener('click',function(e){var resultsDiv=document.getElementById('searchResults');if(resultsDiv&&!e.target.closest('#assetSearch')&&!e.target.closest('#searchResults')){resultsDiv.style.display='none';}});
</script>

</body></html>