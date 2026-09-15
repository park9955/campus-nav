<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    if(!"admin".equals(session.getAttribute("loginRole"))){response.sendRedirect("/CAN/campuslogin.jsp");return;}

    final String DBURL="jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";

    String okMsg="",errMsg="";
    String filterType=request.getParameter("type");if(filterType==null)filterType="";
    String filterStatus=request.getParameter("status");if(filterStatus==null)filterStatus="";

    // ── POST 처리 (상태 변경/삭제/연장) ──
    if("POST".equals(request.getMethod())){
        request.setCharacterEncoding("UTF-8");
        String act=request.getParameter("act");
        if("extendReserve".equals(act)){
            String rid=request.getParameter("reserveId");
            String extendHours=request.getParameter("extendHours");
            String type=request.getParameter("type");if(type==null)type="";
            try{
                int hours=Integer.parseInt(extendHours!=null?extendHours:"1");
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c=DriverManager.getConnection(DBURL,"root","1234");
                int n=0;
                if("room".equals(type)){
                    PreparedStatement ps=c.prepareStatement("UPDATE room_reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=?");
                    ps.setInt(1,hours);ps.setString(2,rid);n=ps.executeUpdate();ps.close();
                } else {
                    PreparedStatement ps=c.prepareStatement("UPDATE reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=?");
                    ps.setInt(1,hours);ps.setString(2,rid);n=ps.executeUpdate();ps.close();
                }
                c.close();
                okMsg=n>0?"예약 #"+rid+" 이(가) "+hours+"시간 연장되었습니다":"해당 예약을 찾을 수 없습니다.";
            }catch(Exception e){errMsg="연장 오류: "+e.getMessage();}
        }
        else if("updateStatus".equals(act)){
            String rid=request.getParameter("reserveId");
            String newStatus=request.getParameter("newStatus");
            String type=request.getParameter("type");if(type==null)type="";
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c=DriverManager.getConnection(DBURL,"root","1234");
                int n=0;
                if("room".equals(type)){
                    PreparedStatement ps=c.prepareStatement("UPDATE room_reservations SET status=? WHERE reserve_id=?");
                    ps.setString(1,newStatus);ps.setString(2,rid);n=ps.executeUpdate();ps.close();
                } else {
                    PreparedStatement ps=c.prepareStatement("UPDATE reservations SET status=? WHERE reserve_id=?");
                    ps.setString(1,newStatus);ps.setString(2,rid);n=ps.executeUpdate();ps.close();
                }
                c.close();
                okMsg=n>0?"예약 #"+rid+" 상태를 '"+newStatus+"'으로 변경했습니다":"해당 예약을 찾을 수 없습니다.";
            }catch(Exception e){errMsg="상태 변경 오류: "+e.getMessage();}
        }
        else if("deleteReserve".equals(act)){
            String rid=request.getParameter("reserveId");
            String type=request.getParameter("type");if(type==null)type="";
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c=DriverManager.getConnection(DBURL,"root","1234");
                int n=0;
                if("room".equals(type)){
                    PreparedStatement ps=c.prepareStatement("DELETE FROM room_reservations WHERE reserve_id=?");
                    ps.setString(1,rid);n=ps.executeUpdate();ps.close();
                } else {
                    PreparedStatement ps=c.prepareStatement("DELETE FROM reservations WHERE reserve_id=?");
                    ps.setString(1,rid);n=ps.executeUpdate();ps.close();
                }
                c.close();
                okMsg=n>0?"예약 #"+rid+" 삭제 완료":"해당 예약을 찾을 수 없습니다.";
            }catch(Exception e){errMsg="삭제 오류: "+e.getMessage();}
        }
    }

    // ── 예약 조회 ──
    List<Map<String,String>> allReserves=new ArrayList<>();
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection(DBURL,"root","1234");

        // 시간이 지난 예약을 자동으로 "사용완료"로 변경
        String updateSql="UPDATE reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);
        updateSql="UPDATE room_reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);

        // 자산 예약 조회
        String sql="SELECT r.reserve_id,r.user_id,u.user_name,r.asset_no,'자산' AS room_type,IFNULL(a.item_name,'자산') AS item_name,r.reserve_date,r.start_time,r.end_time,r.status,r.purpose,'asset' AS reserve_type ";
        sql+="FROM reservations r LEFT JOIN assets a ON r.asset_no=a.asset_no LEFT JOIN users u ON r.user_id=u.user_id ";
        sql+="WHERE 1=1";
        if(!filterStatus.isEmpty()) sql+=" AND r.status='"+filterStatus+"'";
        sql+=" UNION ALL SELECT rr.reserve_id,rr.user_id,u.user_name,CAST(rr.room_id AS CHAR),rm.room_type,rm.room_name,rr.reserve_date,rr.start_time,rr.end_time,rr.status,rr.purpose,'room' ";
        sql+="FROM room_reservations rr LEFT JOIN rooms rm ON rr.room_id=rm.room_id LEFT JOIN users u ON rr.user_id=u.user_id ";
        sql+="WHERE 1=1";
        if(!filterType.isEmpty()) sql+=" AND rm.room_type='"+filterType+"'";
        if(!filterStatus.isEmpty()) sql+=" AND rr.status='"+filterStatus+"'";
        sql+=" ORDER BY reserve_date DESC, start_time DESC";

        ResultSet rs=conn.createStatement().executeQuery(sql);
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("uid",rs.getString("user_id")!=null?rs.getString("user_id"):"");
            m.put("uname",rs.getString("user_name")!=null?rs.getString("user_name"):rs.getString("user_id"));
            m.put("name",rs.getString("item_name")!=null?rs.getString("item_name"):"");
            m.put("type",rs.getString("room_type")!=null?rs.getString("room_type"):"");
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            m.put("purpose",rs.getString("purpose")!=null?rs.getString("purpose"):"");
            m.put("rtype",rs.getString("reserve_type")!=null?rs.getString("reserve_type"):"");
            allReserves.add(m);
        }
        rs.close();conn.close();
    }catch(Exception e){errMsg+="조회오류: "+e.getMessage();}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 예약 관리</title>

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
}

.filter-tabs {
  display: flex;
  gap: 8px;
  margin-bottom: 1.5rem;
  flex-wrap: wrap;
}

.filter-tab {
  padding: 8px 16px;
  border-radius: 20px;
  background: var(--sky-bg);
  border: 1px solid var(--border-color);
  color: var(--txt-sub);
  text-decoration: none;
  cursor: pointer;
  font-size: 0.9rem;
  transition: all 0.2s;
}

.filter-tab:hover, .filter-tab.active {
  background: var(--sky-primary);
  border-color: var(--sky-primary);
  color: white;
  font-weight: 700;
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

.badge-danger {
  background: var(--red-light);
  color: var(--red-main);
}

.badge-warning {
  background: #fef3c7;
  color: #b45309;
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

@media(max-width: 992px) {
  .row.g-4 > [class*="col-"] {
    margin-bottom: 1.5rem;
  }
}

@media(max-width: 768px) {
  .hero-title { font-size: 1.5rem; }
  .filter-tabs { flex-direction: row; }
  .table-air { font-size: 0.8rem; }
  .table-air th, .table-air td { padding: 10px 12px; }
  .row.g-4 { gap: 2rem 1rem; }

  div[style*="display:flex"][style*="gap:2rem"] {
    flex-direction: column;
  }

  div[style*="width:280px"] {
    width: 100%;
  }
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

[data-theme="dark"] .filter-tab {
  background: #1e3a5f;
  border-color: #475569;
}

.btn {
  height: 38px;
  display: inline-flex;
  align-items: center;
}

.results-card:last-child {
  margin-bottom: 0;
}

</style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_admin.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge">ADMIN</span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/main_admin.jsp"><i class="bi bi-house"></i> 대시보드</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/asset_manage.jsp"><i class="bi bi-pencil"></i> 자산관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/disposal_admin.jsp"><i class="bi bi-trash"></i> 폐기관리</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %> 관리자</span>
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
      <div class="hero-subtitle">ICT CAN · 관리자</div>
      <h1 class="hero-title">전체 예약 <strong style="color: #4ade80;">관리</strong> 📋</h1>
      <p class="hero-subtitle">강의실, 세미나실, 컴퓨터실 등 모든 예약을 통합 관리합니다.</p>
    </div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!okMsg.isEmpty()){ %>
  <div class="alert-success"><i class="bi bi-check-circle-fill"></i><%= okMsg %></div>
  <% } %>
  <% if(!errMsg.isEmpty()){ %>
  <div class="alert-danger"><i class="bi bi-exclamation-circle-fill"></i><%= errMsg %></div>
  <% } %>

  <!-- 필터 섹션 -->
  <div class="results-card" style="margin-bottom:2.5rem">
    <div class="results-header">
      <div>
        <div class="results-title">필터 설정</div>
        <div class="results-subtitle">공간 유형과 상태로 예약을 검색합니다</div>
      </div>
    </div>

    <!-- 공간 유형 필터 -->
    <div style="margin-bottom:20px">
      <div style="font-size:0.9rem;color:var(--txt-main);font-weight:700;margin-bottom:12px;display:flex;align-items:center;gap:6px">
        <i class="bi bi-building" style="color:var(--sky-primary)"></i>공간 유형
      </div>
      <div class="filter-tabs">
        <a href="/CAN/reservations_admin.jsp" class="filter-tab <%= filterType.isEmpty()?"active":"" %>">전체</a>
        <a href="/CAN/reservations_admin.jsp?type=강의실" class="filter-tab <%= "강의실".equals(filterType)?"active":"" %>">강의실</a>
        <a href="/CAN/reservations_admin.jsp?type=세미나실" class="filter-tab <%= "세미나실".equals(filterType)?"active":"" %>">세미나실</a>
        <a href="/CAN/reservations_admin.jsp?type=컴퓨터실" class="filter-tab <%= "컴퓨터실".equals(filterType)?"active":"" %>">컴퓨터실</a>
        <a href="/CAN/reservations_admin.jsp?type=자산" class="filter-tab <%= "자산".equals(filterType)?"active":"" %>">자산</a>
      </div>
    </div>

    <!-- 상태 필터 -->
    <div>
      <div style="font-size:0.9rem;color:var(--txt-main);font-weight:700;margin-bottom:12px;display:flex;align-items:center;gap:6px">
        <i class="bi bi-check2-circle" style="color:var(--amber-main)"></i>상태
      </div>
      <div class="filter-tabs">
        <a href="/CAN/reservations_admin.jsp<%= !filterType.isEmpty()?"?type="+java.net.URLEncoder.encode(filterType,"UTF-8"):"" %>" class="filter-tab <%= filterStatus.isEmpty()?"active":"" %>">전체</a>
        <a href="/CAN/reservations_admin.jsp?status=예약완료<%= !filterType.isEmpty()?"&type="+java.net.URLEncoder.encode(filterType,"UTF-8"):"" %>" class="filter-tab <%= "예약완료".equals(filterStatus)?"active":"" %>">예약완료</a>
        <a href="/CAN/reservations_admin.jsp?status=취소<%= !filterType.isEmpty()?"&type="+java.net.URLEncoder.encode(filterType,"UTF-8"):"" %>" class="filter-tab <%= "취소".equals(filterStatus)?"active":"" %>">취소</a>
        <a href="/CAN/reservations_admin.jsp?status=사용완료<%= !filterType.isEmpty()?"&type="+java.net.URLEncoder.encode(filterType,"UTF-8"):"" %>" class="filter-tab <%= "사용완료".equals(filterStatus)?"active":"" %>">완료</a>
      </div>
    </div>
  </div>

  <!-- 메인 콘텐츠: 2컬럼 레이아웃 -->
  <div style="display:flex;gap:2rem;flex-wrap:wrap">
    <!-- 좌측: 예약 테이블 -->
    <div style="flex:1;min-width:0">
      <!-- 예약 테이블 -->
      <div class="results-card">
        <div class="results-header">
          <div>
            <div class="results-title">전체 예약 관리</div>
            <div class="results-subtitle">모든 시설의 예약 조회 · 관리자 취소 가능</div>
          </div>
        </div>

        <% if(allReserves.isEmpty()){ %>
        <div style="text-align:center;padding:40px;color:var(--txt-muted)">
          <i class="bi bi-calendar-x" style="font-size:36px;display:block;margin-bottom:12px;opacity:.3"></i>
          조회된 예약이 없습니다.
        </div>
        <%}else{%>
        <div class="table-responsive">
          <table class="table-air">
            <thead>
              <tr>
                <th>#</th>
                <th>공간</th>
                <th>신청자</th>
                <th>날짜</th>
                <th>시간</th>
                <th>사용목적</th>
                <th>상태</th>
                <th>관리</th>
              </tr>
            </thead>
            <tbody>
            <%for(Map<String,String> rv:allReserves){
                String st=rv.get("status");
                String bc=st.contains("취소")?"badge-danger":st.contains("완료")?"badge-success":"badge-warning";
            %>
            <tr>
              <td style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)"><%= rv.get("id") %></td>
              <td>
                <strong><%= rv.get("name") %></strong>
                <div style="font-size:0.8rem;color:var(--txt-muted)"><%= rv.get("type") %></div>
              </td>
              <td>
                <strong><%= rv.get("uname") %></strong>
                <div style="font-size:0.8rem;color:var(--txt-muted);font-family:var(--font-mono)"><%= rv.get("uid") %></div>
              </td>
              <td style="font-family:var(--font-mono);font-size:0.8rem"><%= rv.get("date") %></td>
              <td style="font-family:var(--font-mono);font-size:0.8rem"><%= rv.get("start") %>~<%= rv.get("end") %></td>
              <td style="max-width:150px;word-break:break-word"><%= rv.get("purpose").isEmpty()?"-":rv.get("purpose") %></td>
              <td><span class="badge <%= bc %>"><%= st %></span></td>
              <td style="display:flex;gap:4px;flex-wrap:wrap;align-items:center;">
                <%if("사용완료".equals(st)){%>
                <form method="post" action="/CAN/reservations_admin.jsp" accept-charset="UTF-8" style="margin:0;display:flex;gap:4px" onchange="if(confirm('[관리자] 예약 #<%= rv.get("id") %>을(를) '+this.querySelector('select').value+' 연장하시겠습니까?')) this.submit(); else this.reset()">
                  <input type="hidden" name="act" value="extendReserve">
                  <input type="hidden" name="reserveId" value="<%= rv.get("id") %>">
                  <input type="hidden" name="type" value="<%= rv.get("rtype") %>">
                  <select name="extendHours" style="padding:4px 8px;font-size:0.8rem;border:1px solid var(--border-color);border-radius:6px;outline:none;background:var(--surface);color:var(--txt-main);cursor:pointer;">
                    <option value="">연장</option>
                    <option value="1">1시간</option>
                    <option value="2">2시간</option>
                    <option value="4">4시간</option>
                    <option value="8">8시간</option>
                  </select>
                </form>
                <%}else{%>
                <form method="post" action="/CAN/reservations_admin.jsp" accept-charset="UTF-8" style="margin:0;display:flex;gap:4px" onchange="if(confirm('[관리자] 예약 #<%= rv.get("id") %>의 상태를 변경하시겠습니까?')) this.submit(); else this.reset()">
                  <input type="hidden" name="act" value="updateStatus">
                  <input type="hidden" name="reserveId" value="<%= rv.get("id") %>">
                  <input type="hidden" name="type" value="<%= rv.get("rtype") %>">
                  <select name="newStatus" style="padding:4px 8px;font-size:0.8rem;border:1px solid var(--border-color);border-radius:6px;outline:none;background:var(--surface);color:var(--txt-main);cursor:pointer;">
                    <option value="<%= st %>"><%= st %></option>
                    <option value="예약중">예약중</option>
                    <option value="예약완료">예약완료</option>
                    <option value="취소">취소</option>
                    <option value="사용완료">사용완료</option>
                  </select>
                </form>
                <%}%>
                <form method="post" action="/CAN/reservations_admin.jsp" accept-charset="UTF-8" style="margin:0"
                      onsubmit="return confirm('[관리자] 예약 #<%= rv.get("id") %>을(를) 삭제하시겠습니까?\\n이 작업은 되돌릴 수 없습니다.')">
                  <input type="hidden" name="act" value="deleteReserve">
                  <input type="hidden" name="reserveId" value="<%= rv.get("id") %>">
                  <input type="hidden" name="type" value="<%= rv.get("rtype") %>">
                  <button type="submit" class="btn btn-sm btn-outline-danger" style="padding:4px 8px;font-size:0.8rem;height:38px;display:inline-flex;align-items:center"><i class="bi bi-trash"></i></button>
                </form>
              </td>
            </tr>
            <%}%>
            </tbody>
          </table>
        </div>
        <%}%>
      </div>
    </div>

    <!-- 우측 사이드바 (280px 고정) -->
    <div style="width:280px;flex-shrink:0">
      <!-- 예약 통계 -->
      <div class="results-card" style="margin-bottom:1.5rem">
        <div class="results-header">
          <div>
            <div class="results-title" style="font-size:1rem">예약 통계</div>
          </div>
        </div>
        <%
          int totalReserves = allReserves.size();
          int completed = 0, cancelled = 0, reserved = 0;
          for(Map<String,String> r : allReserves) {
            String s = r.get("status");
            if(s.contains("사용완료")) completed++;
            else if(s.contains("취소")) cancelled++;
            else reserved++;
          }
        %>
        <div style="display:flex;flex-direction:column;gap:0;font-size:0.9rem">
          <div style="display:flex;justify-content:space-between;padding:0.75rem 0;border-bottom:1px solid var(--border-color)">
            <span style="color:var(--txt-sub)">총 예약</span>
            <span style="font-weight:700;font-family:var(--font-mono);color:var(--sky-primary)"><%= totalReserves %>건</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding:0.75rem 0;border-bottom:1px solid var(--border-color)">
            <span style="color:var(--txt-sub)">예약중</span>
            <span style="font-weight:700;font-family:var(--font-mono);color:#d97706"><%= reserved %>건</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding:0.75rem 0;border-bottom:1px solid var(--border-color)">
            <span style="color:var(--txt-sub)">사용완료</span>
            <span style="font-weight:700;font-family:var(--font-mono);color:#16a34a"><%= completed %>건</span>
          </div>
          <div style="display:flex;justify-content:space-between;padding:0.75rem 0">
            <span style="color:var(--txt-sub)">취소됨</span>
            <span style="font-weight:700;font-family:var(--font-mono);color:#dc2626"><%= cancelled %>건</span>
          </div>
        </div>
      </div>

      <!-- 빠른 이동 -->
      <div class="results-card" style="margin-bottom:0">
        <div class="results-header">
          <div>
            <div class="results-title" style="font-size:1rem">빠른 이동</div>
          </div>
        </div>
        <div style="display:grid;grid-template-columns:repeat(3, 1fr);gap:8px">
          <a href="/CAN/main_admin.jsp" style="display:flex;flex-direction:column;align-items:center;gap:8px;background:var(--sky-bg);border:1.5px solid #7dd3fc;border-radius:var(--radius-lg);padding:8px 12px;text-decoration:none;color:var(--sky-primary);font-weight:600;font-size:0.85rem;transition:all 0.2s;height:38px;justify-content:center">
            <i class="bi bi-house-fill" style="font-size:16px;flex-shrink:0"></i><span style="line-height:1.2">대시보드</span>
          </a>
          <a href="/CAN/asset_manage.jsp" style="display:flex;flex-direction:column;align-items:center;gap:8px;background:#f0fdfa;border:1.5px solid #99f6e4;border-radius:var(--radius-lg);padding:8px 12px;text-decoration:none;color:#0d9488;font-weight:600;font-size:0.85rem;transition:all 0.2s;height:38px;justify-content:center">
            <i class="bi bi-pencil-square" style="font-size:16px;flex-shrink:0"></i><span style="line-height:1.2">자산</span>
          </a>
          <a href="/CAN/disposal_admin.jsp" style="display:flex;flex-direction:column;align-items:center;gap:8px;background:#fffbeb;border:1.5px solid #fde68a;border-radius:var(--radius-lg);padding:8px 12px;text-decoration:none;color:#d97706;font-weight:600;font-size:0.85rem;transition:all 0.2s;height:38px;justify-content:center">
            <i class="bi bi-trash" style="font-size:16px;flex-shrink:0"></i><span style="line-height:1.2">폐기</span>
          </a>
        </div>
      </div>
    </div>
  </div>

  <!-- 반응형 미디어 쿼리 추가: 768px 이하에서 1컬럼으로 변경 -->
  <style>
  @media(max-width: 768px) {
    [style*="display:flex"][style*="gap:2rem"] {
      flex-direction: column !important;
    }
    [style*="width:280px"] {
      width: 100% !important;
    }
  }
  </style>

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
});
</script>
</body>
</html>
