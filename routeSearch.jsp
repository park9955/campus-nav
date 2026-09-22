<%@ page contentType="text/html; charset=UTF-8" %>
<%@ page import="java.util.*,java.sql.*" %>
<%@ include file="db.jsp" %>
<%!
class NodeInfo {
    String id; double lat, lon;
    NodeInfo(String id,double lat,double lon){this.id=id;this.lat=lat;this.lon=lon;}
}
class EdgeInfo {
    String id,from,to; double distance,width,slope,maxWeight,speed,congestion,risk,time;
    boolean indoor,stairs,accessible;
}
class State {
    String node; double g,f;
    State(String node,double g,double f){this.node=node;this.g=g;this.f=f;}
}
double heuristic(NodeInfo a, NodeInfo b){
    if(a==null||b==null)return 0;
    double dx=(a.lat-b.lat)*111000.0;
    double dy=(a.lon-b.lon)*88000.0;
    return Math.sqrt(dx*dx+dy*dy)*0.30;
}
double edgeCost(EdgeInfo e){
    return e.distance*0.30 + e.time*0.25 + e.congestion*0.20 + e.risk*0.15 + Math.abs(e.slope)*0.10;
}
%>
<%
request.setCharacterEncoding("UTF-8");
List<String> nodePath=null, edgePath=null;
double totalDistance=0,totalCost=0;
String message="",error="";

if("POST".equalsIgnoreCase(request.getMethod())){
 String start=request.getParameter("startNode");
 String goal=request.getParameter("goalNode");
 String resourceId=request.getParameter("resourceId");
 String vehicleId=request.getParameter("vehicleId");

 Connection c=null;PreparedStatement ps=null;ResultSet rs=null;
 try{
   c=getConnection();

   double resourceWeight=0,resourceWidthM=0;
   ps=c.prepareStatement("SELECT weight_kg,width_cm,quantity FROM resources WHERE resource_id=?");
   ps.setString(1,resourceId);rs=ps.executeQuery();
   if(rs.next()){resourceWeight=rs.getDouble(1)*Math.max(1,rs.getInt(3));resourceWidthM=rs.getDouble(2)/100.0;}
   close(rs,ps);

   double payload=0,loadWidth=0,battery=0,minBattery=0,maxSlope=0;
   boolean indoorAvail=true,outdoorAvail=true;
   ps=c.prepareStatement("SELECT payload_kg,load_width_m,battery_soc,min_battery_soc,max_slope_deg,indoor_available,outdoor_available FROM vehicles WHERE vehicle_id=?");
   ps.setString(1,vehicleId);rs=ps.executeQuery();
   if(rs.next()){payload=rs.getDouble(1);loadWidth=rs.getDouble(2);battery=rs.getDouble(3);minBattery=rs.getDouble(4);maxSlope=rs.getDouble(5);indoorAvail=rs.getBoolean(6);outdoorAvail=rs.getBoolean(7);}
   close(rs,ps);

   Map<String,NodeInfo> nodes=new HashMap<>();
   ps=c.prepareStatement("SELECT node_id,latitude,longitude FROM route_nodes");rs=ps.executeQuery();
   while(rs.next())nodes.put(rs.getString(1),new NodeInfo(rs.getString(1),rs.getDouble(2),rs.getDouble(3)));
   close(rs,ps);

   List<EdgeInfo> edges=new ArrayList<>();
   ps=c.prepareStatement("SELECT * FROM route_edges");rs=ps.executeQuery();
   while(rs.next()){
     EdgeInfo e=new EdgeInfo();
     e.id=rs.getString("edge_id");e.from=rs.getString("from_node");e.to=rs.getString("to_node");
     e.distance=rs.getDouble("distance_m");e.width=rs.getDouble("width_m");e.slope=rs.getDouble("slope_deg");
     e.maxWeight=rs.getDouble("max_weight_kg");e.speed=rs.getDouble("speed_limit_kmh");
     e.indoor=rs.getBoolean("indoor");e.stairs=rs.getBoolean("stairs");e.accessible=rs.getBoolean("is_accessible");
     e.congestion=rs.getDouble("congestion");e.risk=rs.getDouble("risk_level");e.time=rs.getDouble("travel_time_min");
     edges.add(e);
   }
   close(rs,ps);

   Map<String,List<EdgeInfo>> graph=new HashMap<>();
   for(EdgeInfo e:edges){
     if(!e.accessible)continue;
     if(e.stairs)continue;
     if(e.width<Math.max(resourceWidthM,loadWidth))continue;
     if(e.maxWeight<resourceWeight)continue;
     if(payload<resourceWeight)continue;
     if(Math.abs(e.slope)>maxSlope)continue;
     if(battery<=minBattery)continue;
     if(e.indoor&&!indoorAvail)continue;
     if(!e.indoor&&!outdoorAvail)continue;
     graph.computeIfAbsent(e.from,k->new ArrayList<EdgeInfo>()).add(e);
   }

   PriorityQueue<State> open=new PriorityQueue<State>(new Comparator<State>(){
      public int compare(State a,State b){return Double.compare(a.f,b.f);}
   });
   Map<String,Double> gScore=new HashMap<>();
   Map<String,String> cameNode=new HashMap<>();
   Map<String,String> cameEdge=new HashMap<>();

   gScore.put(start,0.0);
   open.add(new State(start,0,heuristic(nodes.get(start),nodes.get(goal))));

   boolean found=false;
   while(!open.isEmpty()){
     State cur=open.poll();
     if(cur.node.equals(goal)){found=true;break;}
     List<EdgeInfo> nexts=graph.get(cur.node);
     if(nexts==null)continue;
     for(EdgeInfo e:nexts){
       double ng=cur.g+edgeCost(e);
       if(ng<gScore.getOrDefault(e.to,Double.POSITIVE_INFINITY)){
         gScore.put(e.to,ng);cameNode.put(e.to,cur.node);cameEdge.put(e.to,e.id);
         open.add(new State(e.to,ng,ng+heuristic(nodes.get(e.to),nodes.get(goal))));
       }
     }
   }

   if(found){
     LinkedList<String> np=new LinkedList<>();
     LinkedList<String> ep=new LinkedList<>();
     String cur=goal;np.addFirst(cur);
     while(!cur.equals(start)){
       String prev=cameNode.get(cur);if(prev==null)break;
       ep.addFirst(cameEdge.get(cur));np.addFirst(prev);cur=prev;
     }
     nodePath=np;edgePath=ep;totalCost=gScore.get(goal);

     Map<String,EdgeInfo> edgeMap=new HashMap<>();
     for(EdgeInfo e:edges)edgeMap.put(e.id,e);
     for(String eid:ep)totalDistance+=edgeMap.get(eid).distance;
     message="최적경로를 탐색했습니다.";
   }else{
     error="조건을 만족하는 이동 가능한 경로가 없습니다.";
   }

 }catch(Exception e){error=e.toString();}finally{close(rs,ps,c);}
}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>A* 경로 탐색</title>

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

.form-group input {
  padding: 0.75rem 1rem;
  border: 1.5px solid #cbd5e1;
  border-radius: var(--radius-lg);
  font-family: var(--font-main);
  font-size: 0.95rem;
  transition: all 0.2s;
}

.form-group input:focus {
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

.result-box {
  background: #f8fafc;
  padding: 1.5rem;
  border-radius: var(--radius-lg);
  border: 1px solid #e2e8f0;
  margin-bottom: 1.5rem;
}

.result-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
  padding-bottom: 1rem;
  border-bottom: 1px solid #e2e8f0;
}

.result-row:last-child {
  border-bottom: none;
  margin-bottom: 0;
  padding-bottom: 0;
}

.result-label {
  font-weight: 700;
  min-width: 100px;
  color: var(--txt-sub);
}

.result-value {
  font-family: var(--font-mono);
  color: var(--sky-primary);
  font-weight: 600;
  word-break: break-all;
}

.cost-info {
  padding: 1rem;
  background: #f0f9ff;
  border: 1px solid #bae6fd;
  border-radius: var(--radius-lg);
  color: #0369a1;
  font-size: 0.9rem;
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
      <i class="bi bi-diagram-3 text-info"></i> A* 최적경로 탐색
    </div>
  </section>

  <section class="form-section">
    <h2 class="h5 mb-4">⑦ 경로 계산</h2>

    <form method="post">
      <div class="form-row">
        <div class="form-group">
          <label>시작 Node</label>
          <input name="startNode" value="N001" required>
        </div>
        <div class="form-group">
          <label>목표 Node</label>
          <input name="goalNode" value="N006" required>
        </div>
        <div class="form-group">
          <label>Resource ID</label>
          <input name="resourceId" value="RES-0001" required>
        </div>
        <div class="form-group">
          <label>Vehicle ID</label>
          <input name="vehicleId" value="AGV-01" required>
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">A* 경로탐색</button>
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  </section>

  <%if(!message.equals("")){%>
  <section class="borderless-card">
    <div class="msg">✓ <%=message%></div>
    <div class="result-box">
      <div class="result-row">
        <div class="result-label">Node 경로:</div>
        <div class="result-value"><%=nodePath%></div>
      </div>
      <div class="result-row">
        <div class="result-label">Edge 경로:</div>
        <div class="result-value"><%=edgePath%></div>
      </div>
      <div class="result-row">
        <div class="result-label">총 거리:</div>
        <div class="result-value"><%=String.format("%.1f", totalDistance)%> m</div>
      </div>
      <div class="result-row">
        <div class="result-label">총 Cost:</div>
        <div class="result-value"><%=String.format("%.2f", totalCost)%></div>
      </div>
    </div>
  </section>
  <%}%>

  <%if(!error.equals("")){%>
  <section class="borderless-card">
    <div class="err">✗ <%=error%></div>
  </section>
  <%}%>

  <section class="borderless-card">
    <h2 class="h5 mb-3"><i class="bi bi-info-circle me-2"></i>경로 비용 계산</h2>
    <div class="cost-info">
      <strong>Cost 계산식:</strong><br>
      Cost = 거리×0.30 + 이동시간×0.25 + 혼잡도×0.20 + 위험도×0.15 + 경사도×0.10
    </div>
    <p class="text-muted small mb-0">
      <i class="bi bi-exclamation-circle me-1"></i>
      통행불가, 계단, 통로폭 부족, 중량초과, 경사초과, 배터리 부족 Edge는 탐색 전에 제외됩니다.
    </p>
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
