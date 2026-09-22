<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jsp" %>
<%
request.setCharacterEncoding("UTF-8");String msg="",err="";
if("POST".equalsIgnoreCase(request.getMethod())){
 Connection c=null;PreparedStatement ps=null;
 try{
  c=getConnection();ps=c.prepareStatement("REPLACE INTO route_nodes VALUES(?,?,?,?,?,?,?)");
  ps.setString(1,request.getParameter("nodeId"));
  ps.setDouble(2,Double.parseDouble(request.getParameter("latitude")));
  ps.setDouble(3,Double.parseDouble(request.getParameter("longitude")));
  String alt=request.getParameter("altitude");if(alt==null||alt.isBlank())ps.setNull(4,Types.DECIMAL);else ps.setDouble(4,Double.parseDouble(alt));
  ps.setString(5,request.getParameter("building"));
  String fl=request.getParameter("floorNo");if(fl==null||fl.isBlank())ps.setNull(6,Types.INTEGER);else ps.setInt(6,Integer.parseInt(fl));
  ps.setString(7,request.getParameter("nodeType"));
  ps.executeUpdate();msg="Node가 저장되었습니다.";
 }catch(Exception e){err=e.toString();}finally{close(ps,c);}
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Node 관리</title>

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

.borderless-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2.25rem;
  box-shadow: var(--shadow-soft);
  margin-bottom: 2rem;
  border: 1px solid #f1f5f9;
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
  border-radius: var(--radius-lg);
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

.table-air {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.925rem;
}

.table-air th {
  color: var(--txt-muted);
  font-weight: 700;
  padding: 12px 16px;
  border-bottom: 2px solid #e2e8f0;
  text-align: left;
}

.table-air td {
  padding: 18px 16px;
  border-bottom: 1px solid #f1f5f9;
  color: var(--txt-main);
  vertical-align: middle;
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
      <a class="brand-logo" href="dashboard.jsp">
        <i class="bi bi-truck-front text-info fs-3"></i>
        <span>운송 <strong>관리</strong></span>
        <span class="brand-badge">ADMIN</span>
      </a>
      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item"><a class="nav-link-btn" href="node.jsp"><i class="bi bi-diagram-2"></i> Node</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="edge.jsp"><i class="bi bi-diagram-3"></i> Edge</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="obstacle.jsp"><i class="bi bi-exclamation-triangle"></i> 장애물</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="dashboard.jsp"><i class="bi bi-speedometer2"></i> 대시</a></li>
        </ul>
      </div>
    </nav>
  </div>
</header>

<main class="container-xl pb-5">

  <section class="mt-4">
    <div class="section-title">
      <i class="bi bi-diagram-2 text-info"></i> 경로 Node 관리
    </div>
  </section>

  <section class="form-section">
    <h2 class="h5 mb-4">④ Node 등록</h2>
    <%if(!msg.equals("")){%><div class="msg">✓ <%=msg%></div><%}%>
    <%if(!err.equals("")){%><div class="err">✗ <%=err%></div><%}%>

    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>NODE_ID</label>
          <input name="nodeId" value="N001" required>
        </div>
        <div class="form-group">
          <label>LATITUDE</label>
          <input name="latitude" type="number" step="0.0000001" required>
        </div>
        <div class="form-group">
          <label>LONGITUDE</label>
          <input name="longitude" type="number" step="0.0000001" required>
        </div>
        <div class="form-group">
          <label>ALTITUDE</label>
          <input name="altitude" type="number" step="0.1">
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>BUILDING</label>
          <input name="building">
        </div>
        <div class="form-group">
          <label>FLOOR</label>
          <input name="floorNo" type="number">
        </div>
        <div class="form-group">
          <label>NODE_TYPE</label>
          <select name="nodeType" required>
            <option>실습실</option>
            <option>교차로</option>
            <option>출입구</option>
            <option>엘리베이터</option>
            <option>광장</option>
            <option>주차장</option>
          </select>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">Node 저장/수정</button>
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4">Node 목록</h2>
    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>ID</th>
            <th>위도</th>
            <th>경도</th>
            <th>건물</th>
            <th>층</th>
            <th>유형</th>
          </tr>
        </thead>
        <tbody>
          <%
          Connection c2=null;Statement s2=null;ResultSet r2=null;
          try{c2=getConnection();s2=c2.createStatement();r2=s2.executeQuery("SELECT * FROM route_nodes ORDER BY node_id");
          while(r2.next()){%>
          <tr>
            <td><strong><%=r2.getString("node_id")%></strong></td>
            <td><small class="font-monospace"><%=r2.getDouble("latitude")%></small></td>
            <td><small class="font-monospace"><%=r2.getDouble("longitude")%></small></td>
            <td><%=r2.getString("building")%></td>
            <td><%=r2.getString("floor_no")%></td>
            <td><%=r2.getString("node_type")%></td>
          </tr>
          <%}}catch(Exception e){}finally{close(r2,s2,c2);}%>
        </tbody>
      </table>
    </div>
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
