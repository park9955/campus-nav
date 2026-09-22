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
<%
request.setCharacterEncoding("UTF-8");
String msg="", err="";
if("POST".equalsIgnoreCase(request.getMethod())){
  Connection c=null; PreparedStatement ps=null;
  try{
    c=getConnection();
    String sql="REPLACE INTO resources(resource_id,resource_name,category,quantity,weight_kg,width_cm,length_cm,height_cm,fragile,tilt_restricted,temperature_condition,priority,planned_time,deadline) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    ps=c.prepareStatement(sql);
    ps.setString(1,request.getParameter("resourceId"));
    ps.setString(2,request.getParameter("resourceName"));
    ps.setString(3,request.getParameter("category"));
    ps.setInt(4,Integer.parseInt(request.getParameter("quantity")));
    ps.setDouble(5,Double.parseDouble(request.getParameter("weightKg")));
    ps.setDouble(6,Double.parseDouble(request.getParameter("widthCm")));
    ps.setDouble(7,Double.parseDouble(request.getParameter("lengthCm")));
    ps.setDouble(8,Double.parseDouble(request.getParameter("heightCm")));
    ps.setBoolean(9,"1".equals(request.getParameter("fragile")));
    ps.setBoolean(10,"1".equals(request.getParameter("tiltRestricted")));
    ps.setString(11,request.getParameter("temperatureCondition"));
    ps.setString(12,request.getParameter("priority"));
    String p=request.getParameter("plannedTime");
    String d=request.getParameter("deadline");
    if(p==null||p.isBlank()) ps.setNull(13,Types.TIMESTAMP); else ps.setTimestamp(13,Timestamp.valueOf(p.replace("T"," ")+":00"));
    if(d==null||d.isBlank()) ps.setNull(14,Types.TIMESTAMP); else ps.setTimestamp(14,Timestamp.valueOf(d.replace("T"," ")+":00"));
    ps.executeUpdate(); msg="학교자원이 저장되었습니다.";
  }catch(Exception e){err=e.toString();}finally{close(ps,c);}
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>학교자원 관리</title>

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
  border-radius: 4px;
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
          <li class="nav-item"><a class="nav-link-btn" href="resource.jsp"><i class="bi bi-boxes"></i> 자원</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="location.jsp"><i class="bi bi-geo-alt"></i> 위치</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="vehicle.jsp"><i class="bi bi-truck"></i> 운송체</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="transportRequest.jsp"><i class="bi bi-arrow-repeat"></i> 요청</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="dashboard.jsp"><i class="bi bi-speedometer2"></i> 대시</a></li>
        </ul>
      </div>
    </nav>
  </div>
</header>

<main class="container-xl pb-5">

  <section class="mt-4">
    <div class="section-title">
      <i class="bi bi-boxes text-info"></i> 학교자원 관리
    </div>
  </section>

  <section class="form-section">
    <h2 class="h5 mb-4">① 학교자원 등록</h2>
    <%if(!msg.equals("")){%><div class="msg">✓ <%=msg%></div><%}%>
    <%if(!err.equals("")){%><div class="err">✗ <%=err%></div><%}%>

    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>Resource ID</label>
          <input name="resourceId" value="RES-0001" required>
        </div>
        <div class="form-group">
          <label>자원명</label>
          <input name="resourceName" placeholder="서버" required>
        </div>
        <div class="form-group">
          <label>자원분류</label>
          <select name="category" required>
            <option>기자재</option>
            <option>도서</option>
            <option>실습장비</option>
            <option>소모품</option>
          </select>
        </div>
        <div class="form-group">
          <label>수량</label>
          <input name="quantity" type="number" value="1" min="1" required>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>무게(kg)</label>
          <input name="weightKg" type="number" step="0.1" required>
        </div>
        <div class="form-group">
          <label>가로(cm)</label>
          <input name="widthCm" type="number" step="0.1" required>
        </div>
        <div class="form-group">
          <label>세로(cm)</label>
          <input name="lengthCm" type="number" step="0.1" required>
        </div>
        <div class="form-group">
          <label>높이(cm)</label>
          <input name="heightCm" type="number" step="0.1" required>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>파손주의</label>
          <select name="fragile">
            <option value="1">Y</option>
            <option value="0">N</option>
          </select>
        </div>
        <div class="form-group">
          <label>기울임 제한</label>
          <select name="tiltRestricted">
            <option value="1">불가</option>
            <option value="0">가능</option>
          </select>
        </div>
        <div class="form-group">
          <label>온도조건</label>
          <input name="temperatureCondition" value="해당 없음">
        </div>
        <div class="form-group">
          <label>우선순위</label>
          <select name="priority">
            <option>긴급</option>
            <option>높음</option>
            <option selected>보통</option>
            <option>낮음</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>운반 예정시간</label>
          <input name="plannedTime" type="datetime-local">
        </div>
        <div class="form-group">
          <label>도착 제한시간</label>
          <input name="deadline" type="datetime-local">
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">저장/수정</button>
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4">등록 자원 목록</h2>
    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>ID</th>
            <th>자원명</th>
            <th>분류</th>
            <th>수량</th>
            <th>무게</th>
            <th>크기</th>
            <th>파손</th>
            <th>우선순위</th>
          </tr>
        </thead>
        <tbody>
          <%
          Connection c=null; Statement s=null; ResultSet r=null;
          try{c=getConnection();s=c.createStatement();r=s.executeQuery("SELECT * FROM resources ORDER BY resource_id");
          while(r.next()){
          %>
          <tr>
            <td><strong><%=r.getString("resource_id")%></strong></td>
            <td><%=r.getString("resource_name")%></td>
            <td><%=r.getString("category")%></td>
            <td><%=r.getInt("quantity")%></td>
            <td><%=r.getDouble("weight_kg")%>kg</td>
            <td><%=r.getDouble("width_cm")%>×<%=r.getDouble("length_cm")%>×<%=r.getDouble("height_cm")%>cm</td>
            <td><%=r.getBoolean("fragile")?"Y":"N"%></td>
            <td><%=r.getString("priority")%></td>
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
