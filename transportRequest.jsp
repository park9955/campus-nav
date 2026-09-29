<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%@ include file="db.jsp" %>
<%
// ---- 접근 권한 체크: 로그인 필요 ----
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

request.setCharacterEncoding("UTF-8");
String msg="", err="";
if("POST".equalsIgnoreCase(request.getMethod())){
    Connection c=null; PreparedStatement ps=null;
    try{
        c=getConnection();
        ps=c.prepareStatement("REPLACE INTO transport_requests(request_id,resource_id,start_location_id,destination_location_id,vehicle_id,quantity,priority,scheduled_time,deadline,status) VALUES(?,?,?,?,?,?,?,?,?,'REQUESTED')");
        ps.setString(1,request.getParameter("requestId"));
        ps.setString(2,request.getParameter("resourceId"));
        ps.setString(3,request.getParameter("startLocationId"));
        ps.setString(4,request.getParameter("destinationLocationId"));
        ps.setString(5,request.getParameter("vehicleId"));
        ps.setInt(6,Integer.parseInt(request.getParameter("quantity")));
        ps.setString(7,request.getParameter("priority"));
        String stime=request.getParameter("scheduledTime"); 
        if(stime==null||stime.isBlank()) ps.setNull(8,Types.TIMESTAMP); 
        else ps.setTimestamp(8,Timestamp.valueOf(stime.replace("T"," ")+":00"));
        String deadline=request.getParameter("deadline"); 
        if(deadline==null||deadline.isBlank()) ps.setNull(9,Types.TIMESTAMP); 
        else ps.setTimestamp(9,Timestamp.valueOf(deadline.replace("T"," ")+":00"));
        ps.executeUpdate();
        msg="운송요청이 성공적으로 저장되었습니다.";
    }catch(Exception e){
        err=e.toString();
    }finally{
        close(ps,c);
    }
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>운송 요청 등록</title>

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
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
  --header-bg: rgba(255, 255, 255, 0.85);
  --border-color: rgba(226, 232, 240, 0.8);
  --input-bg: #ffffff;
  --input-border: #cbd5e1;
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
  --input-bg: #0f172a;
  --input-border: #475569;
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

.section-title {
  font-size: 1.25rem;
  font-weight: 800;
  margin-bottom: 1.25rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.form-section {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2.25rem;
  margin-bottom: 2rem;
  box-shadow: var(--shadow-soft);
  border: 1px solid var(--border-color);
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(240px, 1fr));
  gap: 1.5rem;
  margin-bottom: 1.5rem;
}

.form-group {
  display: flex;
  flex-direction: column;
}

.form-group label {
  font-weight: 700;
  font-size: 0.875rem;
  margin-bottom: 0.5rem;
  color: var(--txt-main);
}

.form-group input,
.form-group select {
  padding: 0.75rem 1rem;
  background-color: var(--input-bg);
  color: var(--txt-main);
  border: 1.5px solid var(--input-border);
  border-radius: 10px;
  font-family: var(--font-main);
  font-size: 0.95rem;
  transition: all 0.2s;
}

.form-group input:focus,
.form-group select:focus {
  border-color: var(--sky-primary);
  outline: none;
  box-shadow: 0 0 0 4px rgba(2, 132, 199, 0.12);
}

.form-actions {
  display: flex;
  gap: 1rem;
  margin-top: 2rem;
  flex-wrap: wrap;
}

.btn-primary {
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: #ffffff;
  padding: 0.75rem 2rem;
  border: none;
  border-radius: var(--radius-pill);
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-primary:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
}

.btn-secondary {
  background: #626d79;
  color: #ffffff;
  padding: 0.75rem 2rem;
  border: none;
  border-radius: var(--radius-pill);
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-secondary:hover {
  background: #525a66;
  color: #ffffff;
}

.msg {
  padding: 1rem;
  margin-bottom: 1.5rem;
  background: #dcfce7;
  border: 1px solid #86efac;
  color: #15803d;
  border-radius: var(--radius-lg);
  font-weight: 700;
}

.err {
  padding: 1rem;
  margin-bottom: 1.5rem;
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #b91c1c;
  border-radius: var(--radius-lg);
  font-weight: 700;
}

[data-theme="dark"] .msg { background: #064e3b; border-color: #047857; color: #6ee7b7; }
[data-theme="dark"] .err { background: #7f1d1d; border-color: #991b1b; color: #fca5a5; }

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
          <li class="nav-item">
            <a class="nav-link-btn" href="transportRequest.jsp"><i class="bi bi-arrow-repeat"></i> 요청</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="transportStatus.jsp"><i class="bi bi-play-circle"></i> 현황</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="transportHistory.jsp"><i class="bi bi-clock-history"></i> 이력</a>
          </li>
          <% if(isAdmin){ %>
          <li class="nav-item ms-lg-3">
            <a class="nav-link-btn" href="resource.jsp"><i class="bi bi-boxes"></i> 자원 관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="location.jsp"><i class="bi bi-geo-alt"></i> 위치 관리</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="vehicle.jsp"><i class="bi bi-truck"></i> 운송체 관리</a>
          </li>
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

  <section class="mt-4">
    <div class="section-title">
      <i class="bi bi-arrow-repeat text-info"></i> 운송 요청 등록
    </div>
  </section>

  <section class="form-section">
    <h2 class="h5 fw-bold mb-4"><i class="bi bi-pencil-square text-info me-1"></i> 운송 요청 생성</h2>
    <%if(!msg.equals("")){%><div class="msg">✓ <%=msg%></div><%}%>
    <%if(!err.equals("")){%><div class="err">✗ <%=err%></div><%}%>

    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>운송요청 ID</label>
          <input name="requestId" value="REQ-2026-0001" required>
        </div>
        <div class="form-group">
          <label>운반 자원</label>
          <select name="resourceId" required>
            <%
            Connection c1=null; Statement s1=null; ResultSet r1=null;
            try{
                c1=getConnection(); s1=c1.createStatement(); 
                r1=s1.executeQuery("SELECT resource_id,resource_name FROM resources ORDER BY resource_id");
                while(r1.next()){%>
                  <option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option>
                <%}
            }catch(Exception e){}finally{close(r1,s1,c1);}
            %>
          </select>
        </div>
        <div class="form-group">
          <label>출발지</label>
          <select name="startLocationId" required>
            <%
            try{
                c1=getConnection(); s1=c1.createStatement(); 
                r1=s1.executeQuery("SELECT location_id,location_name FROM locations ORDER BY location_id");
                while(r1.next()){%>
                  <option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option>
                <%}
            }catch(Exception e){}finally{close(r1,s1,c1);}
            %>
          </select>
        </div>
        <div class="form-group">
          <label>목표지</label>
          <select name="destinationLocationId" required>
            <%
            try{
                c1=getConnection(); s1=c1.createStatement(); 
                r1=s1.executeQuery("SELECT location_id,location_name FROM locations ORDER BY location_id");
                while(r1.next()){%>
                  <option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option>
                <%}
            }catch(Exception e){}finally{close(r1,s1,c1);}
            %>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>운송체</label>
          <select name="vehicleId" required>
            <%
            try{
                c1=getConnection(); s1=c1.createStatement(); 
                r1=s1.executeQuery("SELECT vehicle_id,status,battery_soc FROM vehicles ORDER BY vehicle_id");
                while(r1.next()){%>
                  <option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> / <%=r1.getString(2)%> / <%=r1.getDouble(3)%>%</option>
                <%}
            }catch(Exception e){}finally{close(r1,s1,c1);}
            %>
          </select>
        </div>
        <div class="form-group">
          <label>수량</label>
          <input name="quantity" type="number" value="1" min="1" required>
        </div>
        <div class="form-group">
          <label>우선순위</label>
          <select name="priority" required>
            <option>긴급</option>
            <option>높음</option>
            <option selected>보통</option>
            <option>낮음</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>운송 예정시간</label>
          <input name="scheduledTime" type="datetime-local">
        </div>
        <div class="form-group">
          <label>도착 제한시간</label>
          <input name="deadline" type="datetime-local">
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">운송요청 저장</button>
        <a href="routeSearch.jsp" class="btn btn-secondary">A* 경로탐색</a>
        <a href="dashboard.jsp" class="btn btn-outline-secondary fw-bold" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

</main>

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