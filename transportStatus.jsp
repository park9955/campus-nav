<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*" %>
<%!
    public Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        String url = "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";
        return DriverManager.getConnection(url, "root", "1234");
    }

    public void close(AutoCloseable... objs) {
        for (AutoCloseable obj : objs) {
            if (obj != null) {
                try { obj.close(); } catch(Exception e) {}
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>운송 현황</title>

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

.badge-status {
  display: inline-block;
  padding: 0.35rem 0.75rem;
  border-radius: var(--radius-pill);
  font-size: 0.75rem;
  font-weight: 700;
}

.badge-requested {
  background: #dbeafe;
  color: #0284c7;
}

.badge-transporting {
  background: #fef3c7;
  color: #b45309;
}

.badge-completed {
  background: #dcfce7;
  color: #15803d;
}

.info-box {
  padding: 1.25rem;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: var(--radius-lg);
  color: #0369a1;
  margin-bottom: 1.5rem;
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
          <li class="nav-item ms-lg-3"><a class="nav-link-btn btn btn-sm btn-info text-white fw-bold" style="border-radius: 999px; padding: 0.5rem 1rem;" href="/CAN/main_admin.jsp"><i class="bi bi-gear"></i> 관리 페이지</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="/CAN/main_student.jsp"><i class="bi bi-house"></i> 메인</a></li>
        </ul>
      </div>
    </nav>
  </div>
</header>

<main class="container-xl pb-5">

  <section class="mt-4">
    <div class="section-title">
      <i class="bi bi-truck-front text-info"></i> 운송 현황
    </div>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4">⑧ 현재 운송 현황</h2>

    <div class="info-box mb-4">
      <i class="bi bi-info-circle me-2"></i>
      <strong>실시간 현황</strong><br>
      GPS 센서에서 수신한 위치 데이터가 current_node_id 또는 차량 현재 좌표에 반영됩니다.
    </div>

    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>요청ID</th>
            <th>자원</th>
            <th>출발지</th>
            <th>목표지</th>
            <th>운송체</th>
            <th>우선순위</th>
            <th>상태</th>
            <th>현재 Node</th>
          </tr>
        </thead>
        <tbody>
          <%
          Connection c=null;Statement s=null;ResultSet r=null;
          try{
           c=getConnection();s=c.createStatement();
           r=s.executeQuery("SELECT tr.*,rs.resource_name,sl.location_name start_name,dl.location_name dest_name FROM transport_requests tr LEFT JOIN resources rs ON tr.resource_id=rs.resource_id LEFT JOIN locations sl ON tr.start_location_id=sl.location_id LEFT JOIN locations dl ON tr.destination_location_id=dl.location_id ORDER BY tr.created_at DESC");
           while(r.next()){
             String status = r.getString("status");
             String badgeClass = "badge-requested";
             if(status.equals("TRANSPORTING")) badgeClass = "badge-transporting";
             else if(status.equals("COMPLETED")) badgeClass = "badge-completed";
          %>
          <tr>
            <td><strong><%=r.getString("request_id")%></strong></td>
            <td><%=r.getString("resource_name")%></td>
            <td><%=r.getString("start_name")%></td>
            <td><%=r.getString("dest_name")%></td>
            <td><%=r.getString("vehicle_id")%></td>
            <td><%=r.getString("priority")%></td>
            <td><span class="badge-status <%=badgeClass%>"><%=status%></span></td>
            <td><code><%=r.getString("current_node_id")==null?"-":r.getString("current_node_id")%></code></td>
          </tr>
          <%}}catch(Exception e){}finally{close(r,s,c);}%>
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
