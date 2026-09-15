<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jsp" %>
<%
request.setCharacterEncoding("UTF-8");String msg="",err="";
if("POST".equalsIgnoreCase(request.getMethod())){
 Connection c=null;PreparedStatement ps=null;
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
  String stime=request.getParameter("scheduledTime"); if(stime==null||stime.isBlank())ps.setNull(8,Types.TIMESTAMP);else ps.setTimestamp(8,Timestamp.valueOf(stime.replace("T"," ")+":00"));
  String deadline=request.getParameter("deadline"); if(deadline==null||deadline.isBlank())ps.setNull(9,Types.TIMESTAMP);else ps.setTimestamp(9,Timestamp.valueOf(deadline.replace("T"," ")+":00"));
  ps.executeUpdate();msg="운송요청이 저장되었습니다.";
 }catch(Exception e){err=e.toString();}finally{close(ps,c);}
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>운송 요청</title>

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
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-pill: 999px;
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
}

body {
  font-family: var(--font-main);
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
  background-repeat: no-repeat;
  color: var(--txt-main);
  line-height: 1.6;
  margin: 0;
  padding: 0;
}

a { text-decoration: none; color: inherit; }

.app-header {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(226, 232, 240, 0.8);
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
  border-radius: var(--radius-lg);
  padding: 2rem;
  margin-bottom: 2rem;
  box-shadow: var(--shadow-soft);
  border: 1px solid #f1f5f9;
}

.form-row {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
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
  border: 1.5px solid #cbd5e1;
  border-radius: 4px;
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
}

.msg {
  padding: 1rem;
  margin-bottom: 1.5rem;
  background: #dcfce7;
  border: 1px solid #86efac;
  color: #15803d;
  border-radius: var(--radius-lg);
}

.err {
  padding: 1rem;
  margin-bottom: 1.5rem;
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #b91c1c;
  border-radius: var(--radius-lg);
}

.app-footer {
  background: var(--surface);
  border-top: 1px solid #e2e8f0;
  color: var(--txt-sub);
  padding: 2.5rem 0;
  margin-top: 4rem;
  font-size: 0.875rem;
}
</style>
</head>
<body>

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
          <li class="nav-item"><a class="nav-link-btn" href="transportRequest.jsp"><i class="bi bi-arrow-repeat"></i> 요청</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="transportStatus.jsp"><i class="bi bi-play-circle"></i> 현황</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="transportHistory.jsp"><i class="bi bi-clock-history"></i> 이력</a></li>
          <li class="nav-item ms-lg-3"><a class="nav-link-btn" href="/CAN/main_student.jsp"><i class="bi bi-house"></i> 메인</a></li>
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
    <h2 class="h5 mb-4">⑥ 운송 요청 생성</h2>
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
            Connection c1=null;Statement s1=null;ResultSet r1=null;
            try{c1=getConnection();s1=c1.createStatement();r1=s1.executeQuery("SELECT resource_id,resource_name FROM resources ORDER BY resource_id");
            while(r1.next()){%><option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option><%}}catch(Exception e){}finally{close(r1,s1,c1);}%>
          </select>
        </div>
        <div class="form-group">
          <label>출발지</label>
          <select name="startLocationId" required>
            <%
            try{c1=getConnection();s1=c1.createStatement();r1=s1.executeQuery("SELECT location_id,location_name FROM locations ORDER BY location_id");
            while(r1.next()){%><option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option><%}}catch(Exception e){}finally{close(r1,s1,c1);}%>
          </select>
        </div>
        <div class="form-group">
          <label>목표지</label>
          <select name="destinationLocationId" required>
            <%
            try{c1=getConnection();s1=c1.createStatement();r1=s1.executeQuery("SELECT location_id,location_name FROM locations ORDER BY location_id");
            while(r1.next()){%><option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> - <%=r1.getString(2)%></option><%}}catch(Exception e){}finally{close(r1,s1,c1);}%>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>운송체</label>
          <select name="vehicleId" required>
            <%
            try{c1=getConnection();s1=c1.createStatement();r1=s1.executeQuery("SELECT vehicle_id,status,battery_soc FROM vehicles ORDER BY vehicle_id");
            while(r1.next()){%><option value="<%=r1.getString(1)%>"><%=r1.getString(1)%> / <%=r1.getString(2)%> / <%=r1.getDouble(3)%>%</option><%}}catch(Exception e){}finally{close(r1,s1,c1);}%>
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
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

</main>

<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold text-dark mb-1">
          <i class="bi bi-truck-front me-1 text-info"></i> 운송 관리 시스템
        </div>
        <div>지능형 운송 관리 및 경로 최적화 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="text-dark fw-bold">개발팀</div>
        <div>&copy; 2026 운송 관리 시스템. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
