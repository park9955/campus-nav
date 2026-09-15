<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    int total=0;
    List<Map<String,String>> myReserves=new ArrayList<>();
    String cancelMsg="",cancelErr="";
    if("POST".equals(request.getMethod())){
        request.setCharacterEncoding("UTF-8");
        String act=request.getParameter("act");
        String cancelId=request.getParameter("cancelId");
        if(cancelId!=null&&!cancelId.trim().isEmpty()){
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection cc=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
                if("extend".equals(act)){
                    String extendHours=request.getParameter("extendHours");
                    int hours=Integer.parseInt(extendHours!=null?extendHours:"1");
                    PreparedStatement ps=cc.prepareStatement("UPDATE reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=? AND user_id=? AND status='사용완료'");
                    ps.setInt(1,hours);ps.setString(2,cancelId.trim());ps.setString(3,loginUser);
                    int n=ps.executeUpdate();ps.close();
                    ps=cc.prepareStatement("UPDATE room_reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=? AND user_id=? AND status='사용완료'");
                    ps.setInt(1,hours);ps.setString(2,cancelId.trim());ps.setString(3,loginUser);
                    int m=ps.executeUpdate();ps.close();cc.close();
                    cancelMsg=(n+m)>0?"예약이 "+hours+"시간 연장되었습니다.":"연장할 수 없는 예약입니다.";
                } else {
                    PreparedStatement ps=cc.prepareStatement("UPDATE reservations SET status='취소' WHERE reserve_id=? AND user_id=? AND status='예약완료'");
                    ps.setString(1,cancelId.trim());ps.setString(2,loginUser);
                    int n=ps.executeUpdate();ps.close();
                    ps=cc.prepareStatement("UPDATE room_reservations SET status='취소' WHERE reserve_id=? AND user_id=? AND status='예약완료'");
                    ps.setString(1,cancelId.trim());ps.setString(2,loginUser);
                    int m=ps.executeUpdate();ps.close();cc.close();
                    cancelMsg=(n+m)>0?"예약이 취소되었습니다.":"취소할 수 없는 예약입니다.";
                }
            }catch(Exception e){cancelErr="처리 오류: "+e.getMessage();}
        }
    }
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
        String updateSql="UPDATE reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);
        updateSql="UPDATE room_reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);
        ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets");
        if(rs.next())total=rs.getInt(1);rs.close();
        PreparedStatement ps=conn.prepareStatement(
            "SELECT r.reserve_id,r.asset_no,IFNULL(a.item_name,'자산') AS item_name,"+
            "r.reserve_date,r.start_time,r.end_time,r.status,r.purpose "+
            "FROM reservations r LEFT JOIN assets a ON r.asset_no=a.asset_no "+
            "WHERE r.user_id=? ORDER BY r.reserve_date DESC,r.start_time DESC LIMIT 10");
        ps.setString(1,loginUser);rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("name",rs.getString("item_name"));
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            m.put("purpose",rs.getString("purpose")!=null?rs.getString("purpose"):"");
            myReserves.add(m);
        }
        rs.close();ps.close();
        ps=conn.prepareStatement(
            "SELECT rr.reserve_id,CAST(rr.room_id AS CHAR) AS room_id,r.room_name AS item_name,"+
            "rr.reserve_date,rr.start_time,rr.end_time,rr.status,rr.purpose "+
            "FROM room_reservations rr LEFT JOIN rooms r ON rr.room_id=r.room_id "+
            "WHERE rr.user_id=? ORDER BY rr.reserve_date DESC,rr.start_time DESC LIMIT 10");
        ps.setString(1,loginUser);rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("name",rs.getString("item_name"));
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            m.put("purpose",rs.getString("purpose")!=null?rs.getString("purpose"):"");
            myReserves.add(m);
        }
        rs.close();ps.close();
        myReserves.sort((a,b)-> b.get("date").compareTo(a.get("date")) != 0 ? b.get("date").compareTo(a.get("date")) : b.get("start").compareTo(a.get("start")));
        if(myReserves.size()>10) myReserves=myReserves.subList(0,10);
        conn.close();
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 스마트 대시보드</title>

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
.resource-deck { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 18px; margin-bottom: 3.5rem; }
.deck-card { background: var(--surface); border-radius: var(--radius-lg); padding: 1.75rem 1.5rem; box-shadow: var(--shadow-soft); display: flex; flex-direction: column; justify-content: space-between; height: 180px; transition: all 0.25s cubic-bezier(0.4, 0, 0.2, 1); position: relative; border: 1px solid #f1f5f9; }
.deck-card-icon-bg { width: 52px; height: 52px; border-radius: 16px; background: var(--sky-bg); display: flex; align-items: center; justify-content: center; transition: all 0.2s; }
.deck-card i { font-size: 1.75rem; color: var(--sky-primary); transition: transform 0.2s; }
.deck-card h3 { font-size: 1.1rem; font-weight: 800; margin: 0; color: var(--txt-main); }
.deck-card .deck-arrow { font-size: 0.875rem; font-weight: 700; color: var(--sky-primary); display: flex; align-items: center; gap: 4px; margin-top: 4px; }
.deck-card:hover { transform: translateY(-6px); box-shadow: var(--shadow-air); border-color: #bae6fd; }
.deck-card:hover .deck-card-icon-bg { background: var(--sky-light); }
.deck-card:hover i { transform: scale(1.15); }

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

/* Dark Mode Specific Styles */
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
  .resource-deck { grid-template-columns: repeat(auto-fit, minmax(160px, 1fr)); }
  .hero-title-main { font-size: 1.5rem; }
  .nav-quick-bar { flex-direction: column; }
  .nav-input-air { width: 100%; }
}
</style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_student.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge">STUDENT</span>
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
            <a class="nav-link-btn" href="/CAN/room_reserve.jsp"><i class="bi bi-calendar-check"></i> 공간/자산 예약</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/navigationTest1.jsp"><i class="bi bi-geo-alt"></i> 실내 길찾기</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %> 학부생</span>
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

  <!-- 알림 메시지 -->
  <% if(!cancelMsg.isEmpty()){%>
  <div class="alert alert-success alert-dismissible fade show mt-3" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i><%= cancelMsg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <%}%>
  <% if(!cancelErr.isEmpty()){%>
  <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
    <i class="bi bi-exclamation-circle-fill me-2"></i><%= cancelErr %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <%}%>

  <!-- 1. HERO INTERACTIVE CANVAS -->
  <section class="hero-balanced-section">
    <div class="row g-4 align-items-stretch">
      <!-- Left Hero Canvas Main -->
      <div class="col-lg-7 text-start">
        <div class="welcome-profile-card">
          <div class="hero-welcome-badge">
            <i class="bi bi-sparkles"></i> SMART CAMPUS NAVIGATION
          </div>
          <h1 class="hero-title-main">좋은 하루입니다, <span><%= loginName %>님</span> 👋</h1>
          <p class="hero-subtitle-text">오늘도 원하시는 강의실과 교내 자원을 편리하게 탐색해보세요.</p>

          <!-- Floating Wide Search Field -->
          <form method="get" action="/CAN/search.jsp" class="mt-3 m-0">
            <div class="hero-search-floating">
              <i class="bi bi-search text-muted me-3 fs-5"></i>
              <input type="text" name="keyword" placeholder="찾으시는 자산번호, 공간명, 교수님 성함 검색...">
              <button type="submit" class="btn-floating-search">통합 검색</button>
            </div>
          </form>
        </div>
      </div>

      <!-- Right Side Stats Card Area -->
      <div class="col-lg-5">
        <div class="hero-side-stats">
          <!-- Blue Accent -->
          <div class="stat-item-pill stat-item-blue" onclick="location.href='/CAN/search.jsp'">
            <div class="stat-pill-icon">
              <i class="bi bi-boxes"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">전체 연동 자산</div>
              <div class="stat-pill-num" style="color: var(--sky-primary);"><%= String.format("%,d",total) %>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <!-- Green Accent -->
          <div class="stat-item-pill stat-item-green" onclick="location.href='/CAN/room_reserve.jsp'">
            <div class="stat-pill-icon">
              <i class="bi bi-calendar-check"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">내 활성 예약</div>
              <div class="stat-pill-num" style="color: var(--emerald-main);"><%= myReserves.size() %>건</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>

          <!-- Amber Accent -->
          <div class="stat-item-pill stat-item-amber" onclick="location.href='/CAN/navigationTest1.jsp'">
            <div class="stat-pill-icon">
              <i class="bi bi-compass"></i>
            </div>
            <div class="text-start flex-grow-1">
              <div class="stat-pill-label">실내 길찾기 서비스</div>
              <div class="stat-pill-num" style="color: var(--amber-main); font-size: 0.95rem; font-family: var(--font-main);">탐색하기 &rarr;</div>
            </div>
            <i class="bi bi-chevron-right text-muted small"></i>
          </div>
        </div>
      </div>
    </div>
  </section>

  <!-- 2. RESOURCE CARDS DECK -->
  <section>
    <div class="section-head-title">
      <span><i class="bi bi-grid-fill text-info me-2"></i>공간 및 자산 바로 예약</span>
    </div>
    <div class="resource-deck">
      <a href="/CAN/room_reserve.jsp?type=강의실" class="deck-card">
        <div class="deck-card-icon-bg">
          <i class="bi bi-building"></i>
        </div>
        <div>
          <h3>강의실 예약</h3>
          <div class="deck-arrow">바로가기 &rarr;</div>
        </div>
      </a>

      <a href="/CAN/room_reserve.jsp?type=세미나실" class="deck-card">
        <div class="deck-card-icon-bg">
          <i class="bi bi-people"></i>
        </div>
        <div>
          <h3>세미나실 예약</h3>
          <div class="deck-arrow">바로가기 &rarr;</div>
        </div>
      </a>

      <a href="/CAN/room_reserve.jsp?type=컴퓨터실" class="deck-card">
        <div class="deck-card-icon-bg">
          <i class="bi bi-laptop"></i>
        </div>
        <div>
          <h3>컴퓨터실 예약</h3>
          <div class="deck-arrow">바로가기 &rarr;</div>
        </div>
      </a>

      <a href="/CAN/reserve.jsp" class="deck-card">
        <div class="deck-card-icon-bg">
          <i class="bi bi-box-seam"></i>
        </div>
        <div>
          <h3>기자재 예약</h3>
          <div class="deck-arrow">바로가기 &rarr;</div>
        </div>
      </a>

      <a href="/CAN/search.jsp" class="deck-card">
        <div class="deck-card-icon-bg" style="background: #f1f5f9;">
          <i class="bi bi-search text-secondary"></i>
        </div>
        <div>
          <h3>자원 통합 검색</h3>
          <div class="deck-arrow text-secondary">검색하기 &rarr;</div>
        </div>
      </a>
    </div>
  </section>

  <!-- 3. INDOOR NAVIGATION BANNER SECTION -->
  <section class="borderless-card mb-4">
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

  <!-- 4. RECENT RESERVATIONS BOARD -->
  <section class="borderless-card">
    <div class="d-flex align-items-center justify-content-between mb-4">
      <h2 class="fw-bold fs-5 m-0">
        <i class="bi bi-clock-history text-info me-2"></i>최근 내 예약 현황
      </h2>
      <a href="/CAN/room_reserve.jsp" class="btn btn-sm btn-outline-info fw-bold" style="border-radius: var(--radius-pill);">
        + 새 예약 신청
      </a>
    </div>

    <% if(myReserves.isEmpty()){%>
    <div style="text-align:center;padding:40px;color:var(--txt-muted)">
      <i class="bi bi-calendar-x" style="font-size:32px;display:block;margin-bottom:10px;opacity:.3"></i>
      예약 내역이 없습니다.
      <br><a href="/CAN/room_reserve.jsp" class="btn btn-primary mt-3">예약하러 가기</a>
    </div>
    <%}else{%>
    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>자산/공간명</th>
            <th>예약일자</th>
            <th>이용시간</th>
            <th>상태</th>
            <th class="text-end">취소 처리</th>
          </tr>
        </thead>
        <tbody>
          <%for(Map<String,String> rv:myReserves){
              String st=rv.get("status");
              String chipClass=st.contains("취소")?"chip-cancel":st.contains("완료")?"chip-ok":"chip-warn";
          %>
          <tr>
            <td>
              <div class="fw-bold"><%= rv.get("name") %></div>
              <% if(!rv.get("purpose").isEmpty()){%><div class="text-muted small"><%= rv.get("purpose") %></div><%}%>
            </td>
            <td class="font-monospace text-secondary"><%= rv.get("date") %></td>
            <td class="font-monospace text-secondary"><%= rv.get("start") %> ~ <%= rv.get("end") %></td>
            <td><span class="status-chip <%= chipClass %>"><%= st %></span></td>
            <td class="text-end">
              <% if("사용완료".equals(st)){%>
              <form method="post" action="/CAN/main_student.jsp" style="margin:0;display:inline" onchange="if(confirm('예약을 '+this.querySelector('select').value+' 연장하시겠습니까?')) this.submit(); else this.reset()">
                <input type="hidden" name="act" value="extend">
                <input type="hidden" name="cancelId" value="<%= rv.get("id") %>">
                <select name="extendHours" style="padding:4px 8px;font-size:12px;border:1.5px solid #cbd5e1;border-radius:6px;outline:none;background:white;color:var(--txt-main);cursor:pointer;">
                  <option value="">연장</option>
                  <option value="1">1시간 연장</option>
                  <option value="2">2시간 연장</option>
                  <option value="4">4시간 연장</option>
                  <option value="8">8시간 연장</option>
                </select>
              </form>
              <%}else if("예약완료".equals(st)){%>
              <form method="post" action="/CAN/main_student.jsp" style="margin:0;display:inline" onsubmit="return confirm('예약을 취소하시겠습니까?')">
                <input type="hidden" name="cancelId" value="<%= rv.get("id") %>">
                <button type="submit" class="btn-cancel-flat"><i class="bi bi-x-circle"></i>취소</button>
              </form>
              <%}else{%><span class="text-muted small">-</span><%}%>
            </td>
          </tr>
          <%}%>
        </tbody>
      </table>
    </div>
    <%}%>
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
        <div>박승순 &middot; 권동해 &middot; 원태연 &middot; 이수혁</div>
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
