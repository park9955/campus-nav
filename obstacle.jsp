<%@ page contentType="text/html; charset=UTF-8" %>
<%@ include file="db.jsp" %>
<%
request.setCharacterEncoding("UTF-8");String msg="",err="";
if("POST".equalsIgnoreCase(request.getMethod())){
 Connection c=null;PreparedStatement ps=null;
 try{
  c=getConnection();c.setAutoCommit(false);
  ps=c.prepareStatement("REPLACE INTO obstacles(obstacle_id,edge_id,obstacle_type,description,active) VALUES(?,?,?,?,TRUE)");
  ps.setString(1,request.getParameter("obstacleId"));
  ps.setString(2,request.getParameter("edgeId"));
  ps.setString(3,request.getParameter("obstacleType"));
  ps.setString(4,request.getParameter("description"));
  ps.executeUpdate();ps.close();
  ps=c.prepareStatement("UPDATE route_edges SET is_accessible=FALSE WHERE edge_id=?");
  ps.setString(1,request.getParameter("edgeId"));ps.executeUpdate();
  c.commit();msg="장애물이 등록되었고 해당 Edge가 ACCESSIBLE=FALSE로 변경되었습니다.";
 }catch(Exception e){err=e.toString();try{if(c!=null)c.rollback();}catch(Exception x){}}finally{close(ps,c);}
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>장애물 관리</title>

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
  --danger: #dc2626;
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
.form-group select,
.form-group textarea {
  padding: 0.75rem 1rem;
  border: 1.5px solid #cbd5e1;
  border-radius: var(--radius-lg);
  font-family: var(--font-main);
  font-size: 0.95rem;
  transition: all 0.2s;
}

.form-group input:focus,
.form-group select:focus,
.form-group textarea:focus {
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

.btn-danger {
  background: linear-gradient(135deg, #dc2626 0%, #b91c1c 100%);
  color: #ffffff;
  padding: 0.75rem 2rem;
  border: none;
  border-radius: var(--radius-pill);
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

.btn-danger:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(220, 38, 38, 0.25);
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

.info-box {
  padding: 1.25rem;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: var(--radius-lg);
  color: #0369a1;
  margin-bottom: 1.5rem;
}

.info-box strong {
  display: block;
  margin-bottom: 0.5rem;
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
      <i class="bi bi-exclamation-triangle text-warning"></i> 장애물 및 Dynamic Re-routing
    </div>
  </section>

  <section class="form-section">
    <h2 class="h5 mb-4">⑨ 장애물 등록 및 우회 처리</h2>
    <%if(!msg.equals("")){%><div class="msg">✓ <%=msg%></div><%}%>
    <%if(!err.equals("")){%><div class="err">✗ <%=err%></div><%}%>

    <div class="info-box">
      <strong><i class="bi bi-info-circle me-2"></i>장애물 등록 시 프로세스</strong>
      장애물을 등록하면 해당 Edge의 통행 가능 여부가 자동으로 FALSE로 변경되며, 이를 통해 A* 재탐색 시 자동으로 우회경로가 선택됩니다.
    </div>

    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>Obstacle ID</label>
          <input name="obstacleId" value="OBS-001" required>
        </div>
        <div class="form-group">
          <label>차단 Edge ID</label>
          <input name="edgeId" value="E003" required>
        </div>
        <div class="form-group">
          <label>장애물 유형</label>
          <select name="obstacleType" required>
            <option>공사</option>
            <option>통제</option>
            <option>사람</option>
            <option>차량</option>
            <option>시설물</option>
            <option>기타</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>설명</label>
          <textarea name="description" rows="3">공사구간으로 통행불가</textarea>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-danger">장애물 등록 + Edge 차단</button>
        <a href="routeSearch.jsp" class="btn btn-primary">A* 재탐색</a>
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4"><i class="bi bi-arrow-repeat me-2"></i>우회 처리 흐름</h2>
    <div style="background: #f8fafc; padding: 1.5rem; border-radius: var(--radius-lg); border: 1px solid #e2e8f0; font-family: 'JetBrains Mono', monospace; font-size: 0.9rem; line-height: 1.8;">
      장애물 발생 → 해당 Edge 차단 → ACCESSIBLE = FALSE → 현재 Node 확인 → A* 재실행 → 새로운 우회경로
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
