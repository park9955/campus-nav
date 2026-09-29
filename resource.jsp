<%@ page contentType="text/html; charset=UTF-8" import="java.sql.*,java.util.*" %>
<%
// ---- 접근 권한 체크: 로그인 필요 ----
String loginUser=(String)session.getAttribute("loginUser");
String loginRole=(String)session.getAttribute("loginRole");
if(loginUser==null){ response.sendRedirect("/CAN/campuslogin.jsp"); return; }

boolean isAdmin = "admin".equals(loginRole);
boolean isProfessor = "professor".equals(loginRole);
boolean isAssistant = "assistant".equals(loginRole);
boolean isStudent = "student".equals(loginRole);
boolean canEdit = isAdmin || isProfessor || isAssistant;

String roleLabel =
    "student".equals(loginRole)   ? "학부생" :
    "assistant".equals(loginRole) ? "조교"   :
    "professor".equals(loginRole) ? "교수"   : "관리자";

request.setCharacterEncoding("UTF-8");
String msg="", err="";
if("POST".equalsIgnoreCase(request.getMethod())){
  if(!canEdit){ err="권한이 없습니다. 관리자, 교수, 조교만 등록/수정이 가능합니다."; }
  else{
  Connection c=null; PreparedStatement ps=null;
  try{
    Class.forName("com.mysql.cj.jdbc.Driver");
    c=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    String sql="REPLACE INTO assets(asset_no,asset_class,item_name,model,manage_dept,manager_name,detail_location,asset_status,weight_kg,width_cm,length_cm,height_cm,fragile,can_tilt,temperature_condition,priority,acq_date) VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)";
    ps=c.prepareStatement(sql);
    ps.setString(1,request.getParameter("assetNo"));
    ps.setString(2,request.getParameter("assetClass"));
    ps.setString(3,request.getParameter("itemName"));
    ps.setString(4,request.getParameter("model"));
    ps.setString(5,request.getParameter("manageDept"));
    ps.setString(6,request.getParameter("managerName"));
    ps.setString(7,request.getParameter("detailLocation"));
    ps.setString(8,request.getParameter("assetStatus"));
    String w=request.getParameter("weightKg"); if(w==null||w.isBlank()) ps.setNull(9,Types.DECIMAL); else ps.setDouble(9,Double.parseDouble(w));
    String wc=request.getParameter("widthCm"); if(wc==null||wc.isBlank()) ps.setNull(10,Types.DECIMAL); else ps.setDouble(10,Double.parseDouble(wc));
    String lc=request.getParameter("lengthCm"); if(lc==null||lc.isBlank()) ps.setNull(11,Types.DECIMAL); else ps.setDouble(11,Double.parseDouble(lc));
    String hc=request.getParameter("heightCm"); if(hc==null||hc.isBlank()) ps.setNull(12,Types.DECIMAL); else ps.setDouble(12,Double.parseDouble(hc));
    ps.setBoolean(13,"1".equals(request.getParameter("fragile")));
    ps.setBoolean(14,"1".equals(request.getParameter("canTilt")));
    ps.setString(15,request.getParameter("temperatureCondition"));
    ps.setString(16,request.getParameter("priority"));
    String aq=request.getParameter("acqDate"); if(aq==null||aq.isBlank()) ps.setNull(17,Types.DATE); else ps.setDate(17,java.sql.Date.valueOf(aq));
    ps.executeUpdate(); msg="자산이 저장되었습니다.";
    }catch(Exception e){err=e.toString();}finally{try{if(ps!=null)ps.close();if(c!=null)c.close();}catch(Exception e){}}
  }
}

// 검색 파라미터
String searchKeyword=request.getParameter("searchKeyword"); if(searchKeyword==null) searchKeyword="";
String searchType=request.getParameter("searchType"); if(searchType==null||searchType.equals("")) searchType="all";

// 자산 목록 페이징
String pageStr=request.getParameter("page");int curPage=1,pageSize=20;try{curPage=Integer.parseInt(pageStr);}catch(Exception e){}if(curPage<1)curPage=1;
List<Map<String,String>> assetList=new ArrayList<>();int totalCount=0,totalPage=1;
String whereClause="";
if(!searchKeyword.isEmpty()){
  if("all".equals(searchType)){
    whereClause=" WHERE (a.item_name LIKE '%"+searchKeyword+"%' OR a.asset_no LIKE '%"+searchKeyword+"%' OR a.asset_class LIKE '%"+searchKeyword+"%' OR a.detail_location LIKE '%"+searchKeyword+"%')";
  } else if("name".equals(searchType)){
    whereClause=" WHERE a.item_name LIKE '%"+searchKeyword+"%'";
  } else if("no".equals(searchType)){
    whereClause=" WHERE a.asset_no LIKE '%"+searchKeyword+"%'";
  } else if("cls".equals(searchType)){
    whereClause=" WHERE a.asset_class LIKE '%"+searchKeyword+"%'";
  } else if("loc".equals(searchType)){
    whereClause=" WHERE a.detail_location LIKE '%"+searchKeyword+"%'";
  }
}
try{
  Class.forName("com.mysql.cj.jdbc.Driver");
  Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
  PreparedStatement ps2=conn.prepareStatement("SELECT COUNT(*) FROM assets a"+whereClause);
  ResultSet rs=ps2.executeQuery();
  if(rs.next())totalCount=rs.getInt(1);
  rs.close();ps2.close();
  totalPage=(int)Math.ceil((double)totalCount/pageSize);if(totalPage<1)totalPage=1;
  ps2=conn.prepareStatement("SELECT a.asset_no,a.asset_class,a.item_name,a.model,a.manage_dept,a.manager_name,a.detail_location,a.asset_status,a.weight_kg,a.width_cm,a.length_cm,a.height_cm,a.fragile, COALESCE(DATE_FORMAT(t.transfer_date,'%Y-%m-%d'),'-') as transfer_date FROM assets a LEFT JOIN asset_transfer t ON a.asset_no=t.asset_no AND t.transfer_id=(SELECT MAX(transfer_id) FROM asset_transfer WHERE asset_no=a.asset_no)"+whereClause+" ORDER BY a.asset_no DESC LIMIT ? OFFSET ?");
  ps2.setInt(1,pageSize);ps2.setInt(2,(curPage-1)*pageSize);
  rs=ps2.executeQuery();
  while(rs.next()){
    Map<String,String> r=new LinkedHashMap<>();
    r.put("no",rs.getString("asset_no")==null?"":rs.getString("asset_no"));
    r.put("cls",rs.getString("asset_class")==null?"":rs.getString("asset_class"));
    r.put("name",rs.getString("item_name")==null?"":rs.getString("item_name"));
    r.put("model",rs.getString("model")==null?"-":rs.getString("model"));
    r.put("dept",rs.getString("manage_dept")==null?"-":rs.getString("manage_dept"));
    r.put("mgr",rs.getString("manager_name")==null?"-":rs.getString("manager_name"));
    r.put("loc",rs.getString("detail_location")==null?"-":rs.getString("detail_location"));
    r.put("st",rs.getString("asset_status")==null?"-":rs.getString("asset_status"));
    r.put("ts",rs.getString("transfer_date")==null?"-":rs.getString("transfer_date"));
    r.put("w",rs.getDouble("weight_kg")>0?rs.getDouble("weight_kg")+"kg":"-");
    r.put("sz",(rs.getDouble("width_cm")>0?rs.getDouble("width_cm"):"")+"×"+(rs.getDouble("length_cm")>0?rs.getDouble("length_cm"):"")+"×"+(rs.getDouble("height_cm")>0?rs.getDouble("height_cm"):"")+("cm"));
    r.put("f",rs.getBoolean("fragile")?"Y":"N");
    assetList.add(r);
  }
  rs.close();ps2.close();conn.close();
}catch(Exception e){}
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

[data-theme="dark"] body {
  background: linear-gradient(180deg, #0f172a 0%, #1a2f3a 40%, #1a332f 100%);
}

[data-theme="dark"] .app-header {
  background: var(--header-bg);
  border-bottom-color: var(--border-color);
}

[data-theme="dark"] .brand-logo {
  color: #f1f5f9;
}

[data-theme="dark"] .nav-link-btn {
  color: #e2e8f0;
  font-weight: 700;
}

[data-theme="dark"] .nav-link-btn:hover {
  background: var(--sky-bg);
  color: #38bdf8;
}

[data-theme="dark"] .borderless-card {
  background: #1e293b;
  border-color: #334155;
}

[data-theme="dark"] .form-section {
  background: #1e293b;
  border-color: #334155;
}

[data-theme="dark"] .table-air th {
  border-bottom-color: #475569;
  color: #f1f5f9;
  font-weight: 700;
}

[data-theme="dark"] .table-air td {
  border-bottom-color: #334155;
  color: #e2e8f0;
}

[data-theme="dark"] .app-footer {
  border-top-color: var(--border-color);
  color: #cbd5e1;
}

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

  <!-- 검색 섹션 -->
  <section class="borderless-card mb-4">
    <div style="margin-bottom: 1rem;">
      <h2 class="h5 m-0">자산 검색</h2>
    </div>
    <form method="get" style="display: flex; gap: 0.75rem; flex-wrap: wrap;">
      <div style="flex: 1; min-width: 200px;">
        <input type="text" name="searchKeyword" value="<%=searchKeyword%>" placeholder="검색어 입력" style="width: 100%; padding: 0.75rem 1rem; border: 1.5px solid #cbd5e1; border-radius: 4px; font-family: var(--font-main); font-size: 0.95rem;">
      </div>
      <div style="width: 150px;">
        <select name="searchType" style="width: 100%; padding: 0.75rem 1rem; border: 1.5px solid #cbd5e1; border-radius: 4px; font-family: var(--font-main); font-size: 0.95rem;">
          <option value="all" <%="all".equals(searchType)?"selected":""%>>전체 검색</option>
          <option value="name" <%="name".equals(searchType)?"selected":""%>>자산명</option>
          <option value="no" <%="no".equals(searchType)?"selected":""%>>자산번호</option>
          <option value="cls" <%="cls".equals(searchType)?"selected":""%>>분류</option>
          <option value="loc" <%="loc".equals(searchType)?"selected":""%>>위치</option>
        </select>
      </div>
      <button type="submit" style="padding: 0.75rem 1.5rem; background: #0284c7; color: #fff; border: none; border-radius: 4px; font-weight: 600; cursor: pointer; font-family: var(--font-main);">검색</button>
      <a href="resource.jsp" style="padding: 0.75rem 1.5rem; background: #f1f5f9; color: #334155; border: 1px solid #e2e8f0; border-radius: 4px; font-weight: 600; cursor: pointer; font-family: var(--font-main); text-decoration: none; display: flex; align-items: center;">초기화</a>
    </form>
  </section>

  <%if(canEdit){%>
  <section class="form-section"><%}else{%>
  <section style="background: #fffbeb; border: 1px solid #fcd34d; border-radius: 12px; padding: 2rem; margin-bottom: 2rem; color: #b45309;"><%}%>
    <h2 class="h5 mb-4">① 자산 등록/수정</h2>
    <%if(!msg.equals("")){%><div class="msg">✓ <%=msg%></div><%}%>
    <%if(!err.equals("")){%><div class="err">✗ <%=err%></div><%}%>

    <%if(!canEdit){%>
    <div style="font-weight: 600; font-size: 0.95rem; margin-top: 1rem;">
      <i class="bi bi-exclamation-triangle me-2"></i> 자산 등록/수정은 <strong>관리자, 교수, 조교</strong>만 가능합니다.
      <div style="margin-top: 0.75rem; font-weight: 400; font-size: 0.875rem;">현재 로그인 권한: <strong><%=roleLabel%></strong></div>
    </div>
    <%}%>
    <form method="post" <%if(!canEdit){%>style="display: none;"<%}%>>
      <div class="form-row">
        <div class="form-group">
          <label>자산 번호</label>
          <input name="assetNo" value="AST-001" required>
        </div>
        <div class="form-group">
          <label>자산 분류</label>
          <input name="assetClass" placeholder="기자재" required>
        </div>
        <div class="form-group">
          <label>자산명</label>
          <input name="itemName" placeholder="서버" required>
        </div>
        <div class="form-group">
          <label>모델</label>
          <input name="model" placeholder="모델명">
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>관리 부서</label>
          <input name="manageDept" placeholder="정보통신과">
        </div>
        <div class="form-group">
          <label>담당자</label>
          <input name="managerName" placeholder="담당자명">
        </div>
        <div class="form-group">
          <label>상세 위치</label>
          <input name="detailLocation" placeholder="301호">
        </div>
        <div class="form-group">
          <label>자산 상태</label>
          <select name="assetStatus">
            <option>사용중</option>
            <option>미사용</option>
            <option>폐기</option>
            <option>수리중</option>
          </select>
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>무게(kg)</label>
          <input name="weightKg" type="number" step="0.1">
        </div>
        <div class="form-group">
          <label>가로(cm)</label>
          <input name="widthCm" type="number" step="0.1">
        </div>
        <div class="form-group">
          <label>세로(cm)</label>
          <input name="lengthCm" type="number" step="0.1">
        </div>
        <div class="form-group">
          <label>높이(cm)</label>
          <input name="heightCm" type="number" step="0.1">
        </div>
      </div>

      <div class="form-row">
        <div class="form-group">
          <label>파손주의</label>
          <select name="fragile">
            <option value="1">Yes</option>
            <option value="0" selected>No</option>
          </select>
        </div>
        <div class="form-group">
          <label>기울임 가능</label>
          <select name="canTilt">
            <option value="1" selected>Yes</option>
            <option value="0">No</option>
          </select>
        </div>
        <div class="form-group">
          <label>온도조건</label>
          <input name="temperatureCondition" value="상온">
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
          <label>취득 날짜</label>
          <input name="acqDate" type="date">
        </div>
      </div>

      <div class="form-actions">
        <button type="submit" class="btn-primary">저장/수정</button>
        <a href="dashboard.jsp" class="btn btn-outline-secondary" style="border-radius: var(--radius-pill); padding: 0.75rem 2rem;">대시보드</a>
      </div>
    </form>
  <%if(canEdit){%>
  </section>
  <%}else{%>
  </section>
  <%}%>

  <section class="borderless-card">
    <div style="margin-bottom: 1.5rem;">
      <h2 class="h5 m-0" style="display: inline-block;">등록 자산 목록</h2>
      <span style="font-size: 0.875rem; color: #64748b; margin-left: 0.5rem;">총 <%=String.format("%,d", totalCount)%>건 · 페이지 <%=curPage%>/<%=totalPage%></span>
    </div>

    <div class="table-responsive">
      <table class="table-air">
        <thead>
          <tr>
            <th>자산번호</th>
            <th>분류</th>
            <th>자산명</th>
            <th>모델</th>
            <th>관리부서</th>
            <th>담당자</th>
            <th>위치</th>
            <th>상태</th>
            <th>운송</th>
          </tr>
        </thead>
        <tbody>
          <%for(Map<String,String> row:assetList){%>
          <tr>
            <td><strong><%=row.get("no")%></strong></td>
            <td><%=row.get("cls")%></td>
            <td><%=row.get("name")%></td>
            <td><%=row.get("model")%></td>
            <td><%=row.get("dept")%></td>
            <td><%=row.get("mgr")%></td>
            <td><%=row.get("loc")%></td>
            <td><%=row.get("st")%></td>
            <td><a href="/CAN/navigationOptimized.jsp?to=<%=java.net.URLEncoder.encode(row.get("loc"),"UTF-8")%>" class="btn btn-sm btn-outline-primary" style="border-radius: 999px; font-size: 0.85rem;">운송</a></td>
          </tr>
          <%}%>
        </tbody>
      </table>
    </div>

    <!-- 페이지 네비게이션 -->
    <%if(totalPage>1){%>
    <div style="margin-top: 2rem; display: flex; justify-content: center; gap: 0.5rem;">
      <%if(curPage>1){%><a href="resource.jsp?page=<%=curPage-1%>" style="padding: 0.5rem 0.75rem; border: 1px solid #e2e8f0; border-radius: 6px; color: #0284c7; text-decoration: none; font-weight: 600;">‹</a><%}%>
      <%int sp=Math.max(1,curPage-4), ep=Math.min(totalPage, curPage+4); for(int p2=sp; p2<=ep; p2++){%>
        <a href="resource.jsp?page=<%=p2%>" style="padding: 0.5rem 0.75rem; border: 1px solid <%=p2==curPage?"#0284c7":"#e2e8f0"%>; border-radius: 6px; background: <%=p2==curPage?"#f0f9ff":"transparent"%>; color: <%=p2==curPage?"#0284c7":"#334155"%>; text-decoration: none; font-weight: 600;"><%=p2%></a>
      <%}%>
      <%if(curPage<totalPage){%><a href="resource.jsp?page=<%=curPage+1%>" style="padding: 0.5rem 0.75rem; border: 1px solid #e2e8f0; border-radius: 6px; color: #0284c7; text-decoration: none; font-weight: 600;">›</a><%}%>
    </div>
    <%}%>
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
