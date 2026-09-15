<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    if(!"admin".equals(session.getAttribute("loginRole"))){response.sendRedirect("/CAN/campuslogin.jsp");return;}

    final String DBURL="jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";

    String okMsg="",errMsg="";
    String filterYear=request.getParameter("year");if(filterYear==null)filterYear="";
    String filterType=request.getParameter("type");if(filterType==null)filterType="";

    // ── POST 처리 (폐기 등록) ──
    if("POST".equals(request.getMethod())){
        request.setCharacterEncoding("UTF-8");
        String act=request.getParameter("act");
        if("addDisposal".equals(act)){
            String assetNo=request.getParameter("d_asset_no");
            String dispDate=request.getParameter("d_date");
            String dispType=request.getParameter("d_type");
            String remark=request.getParameter("d_remark");

            if(assetNo==null||assetNo.trim().isEmpty()||dispDate==null||dispDate.trim().isEmpty()){
                errMsg="자산번호와 폐기일자는 필수입니다.";
            } else {
                try{
                    Class.forName("com.mysql.cj.jdbc.Driver");
                    Connection c=DriverManager.getConnection(DBURL,"root","1234");
                    // 자산 존재 확인
                    PreparedStatement ck=c.prepareStatement("SELECT item_name FROM assets WHERE asset_no=?");
                    ck.setString(1,assetNo.trim());ResultSet rck=ck.executeQuery();
                    if(!rck.next()){errMsg="자산번호 ["+assetNo+"] 이(가) 없습니다.";}
                    else{
                        String iname=rck.getString(1);rck.close();ck.close();
                        PreparedStatement ps=c.prepareStatement(
                            "INSERT INTO asset_disposal(asset_no,item_name,disposal_date,disposal_type,remark) VALUES(?,?,?,?,?)");
                        ps.setString(1,assetNo.trim());ps.setString(2,iname);
                        ps.setString(3,dispDate.trim());ps.setString(4,dispType!=null?dispType:"");
                        ps.setString(5,remark!=null?remark:"");
                        ps.executeUpdate();ps.close();
                        okMsg="폐기 내역 등록 완료! ["+assetNo+"] "+iname;
                    }
                    c.close();
                }catch(Exception e){errMsg="폐기 등록 오류: "+e.getMessage();}
            }
        }
    }

    // ── 폐기 목록 조회 ──
    List<Map<String,String>> disposals=new ArrayList<>();
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection(DBURL,"root","1234");

        String sql="SELECT disposal_id,asset_no,item_name,disposal_year,disposal_type,disposal_date,remark FROM asset_disposal WHERE 1=1";
        if(!filterYear.isEmpty()){
            sql+=" AND disposal_year='"+filterYear+"'";
        }
        if(!filterType.isEmpty()){
            sql+=" AND disposal_type='"+filterType+"'";
        }
        sql+=" ORDER BY disposal_date DESC LIMIT 100";

        ResultSet rs=conn.createStatement().executeQuery(sql);
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("disposal_id")!=null?rs.getString("disposal_id"):"");
            m.put("assetNo",rs.getString("asset_no")!=null?rs.getString("asset_no"):"");
            m.put("name",rs.getString("item_name")!=null?rs.getString("item_name"):"");
            m.put("year",rs.getString("disposal_year")!=null?rs.getString("disposal_year"):"");
            m.put("type",rs.getString("disposal_type")!=null?rs.getString("disposal_type"):"");
            m.put("date",rs.getString("disposal_date")!=null?rs.getString("disposal_date"):"");
            m.put("remark",rs.getString("remark")!=null?rs.getString("remark"):"");
            disposals.add(m);
        }
        rs.close();conn.close();
    }catch(Exception e){errMsg+="조회오류: "+e.getMessage();}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 폐기 처리</title>

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

[data-theme="dark"] .btn-outline-danger {
  color: #ff6b6b;
  border-color: #ff6b6b;
}

[data-theme="dark"] .btn-outline-danger:hover {
  background: #ff6b6b;
  color: #0f172a;
}

[data-theme="dark"] .pagination-btn {
  background: #1e3a5f !important;
  color: #cbd5e1 !important;
  border-color: #334155 !important;
}

[data-theme="dark"] .pagination-btn:hover {
  background: #0c4a6e !important;
  color: #f1f5f9 !important;
}

[data-theme="dark"] .pagination-btn.active {
  background: #0284c7 !important;
  color: #ffffff !important;
  border-color: #38bdf8 !important;
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
            <a class="nav-link-btn" href="/CAN/reservations_admin.jsp"><i class="bi bi-calendar"></i> 예약관리</a>
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
      <h1 class="hero-title">자산 폐기 <strong style="color: #4ade80;">관리</strong> ♻️</h1>
      <p class="hero-subtitle">노후되거나 손상된 자산의 폐기 처리 내역을 관리합니다.</p>
    </div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!okMsg.isEmpty()){ %>
  <div class="alert-success"><i class="bi bi-check-circle-fill"></i><%= okMsg %></div>
  <% } %>
  <% if(!errMsg.isEmpty()){ %>
  <div class="alert-danger"><i class="bi bi-exclamation-circle-fill"></i><%= errMsg %></div>
  <% } %>

  <!-- 등록 섹션 -->
  <div class="results-card" style="margin-bottom:2.5rem">
    <div class="results-header">
      <div>
        <div class="results-title">폐기 내역 등록</div>
        <div class="results-subtitle">새로운 폐기 처리를 기록합니다</div>
      </div>
    </div>

    <form method="post" action="/CAN/disposal_admin.jsp">
      <input type="hidden" name="act" value="addDisposal">
      <div class="row g-3">
        <div class="col-md-6">
          <label class="form-label fw-bold">자산번호 *</label>
          <input class="form-control" type="text" name="d_asset_no" placeholder="예) 8402C0001" required>
        </div>
        <div class="col-md-6">
          <label class="form-label fw-bold">폐기일자 *</label>
          <input class="form-control" type="date" name="d_date" required>
        </div>
        <div class="col-12">
          <label class="form-label fw-bold">폐기 사유</label>
          <input class="form-control" type="text" name="d_type" placeholder="예) 노후, 손상, 기술낙후">
        </div>
        <div class="col-12">
          <label class="form-label fw-bold">비고</label>
          <textarea class="form-control" name="d_remark" rows="2" placeholder="폐기 처리 상세 내용"></textarea>
        </div>
        <div class="col-12">
          <button type="submit" class="btn btn-success"><i class="bi bi-check-circle me-1"></i>폐기 내역 등록</button>
        </div>
      </div>
    </form>
  </div>

  <!-- 메인 콘텐츠 영역: 2컬럼 레이아웃 -->
  <div style="display:flex;gap:2rem;flex-wrap:wrap">
    <!-- 좌측: 폐기 목록 테이블 -->
    <div style="flex:1;min-width:0">
      <div class="results-card">
        <div class="results-header">
          <div>
            <div class="results-title">폐기 처리 현황</div>
            <div class="results-subtitle">최근 100건 · 폐기일 기준 정렬</div>
          </div>
        </div>

        <% if(disposals.isEmpty()){ %>
        <div style="text-align:center;padding:40px;color:var(--txt-muted)">
          <i class="bi bi-inbox" style="font-size:36px;display:block;margin-bottom:12px;opacity:.3"></i>
          폐기 내역이 없습니다.
        </div>
        <%}else{%>
        <!-- 페이지네이션 탭 -->
        <div style="display:flex;gap:8px;margin-bottom:1.5rem;flex-wrap:wrap;align-items:center">
          <button onclick="goToPage(1)" class="pagination-btn active" data-page="1" style="padding:6px 12px;border:1.5px solid #7dd3fc;border-radius:var(--radius-md);background:var(--sky-bg);color:var(--sky-primary);font-weight:600;font-size:0.875rem;cursor:pointer;transition:all 0.2s">1페이지</button>
          <% for(int p=2; p<=(disposals.size()-1)/10+1; p++){ %>
          <button onclick="goToPage(<%= p %>)" class="pagination-btn" data-page="<%= p %>" style="padding:6px 12px;border:1.5px solid #cbd5e1;border-radius:var(--radius-md);background:white;color:var(--txt-sub);font-weight:600;font-size:0.875rem;cursor:pointer;transition:all 0.2s"><%= p %>페이지</button>
          <% } %>
        </div>

        <div class="table-responsive">
          <table class="table-air">
            <thead>
              <tr>
                <th>#</th>
                <th>자산명</th>
                <th>자산번호</th>
                <th>폐기일</th>
                <th>사유</th>
                <th>비고</th>
              </tr>
            </thead>
            <tbody id="tableBody">
            <%for(Map<String,String> d:disposals){%>
            <tr class="table-row" data-idx="<%= disposals.indexOf(d) %>">
              <td style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)"><%= d.get("id") %></td>
              <td><strong><%= d.get("name") %></strong></td>
              <td style="font-family:var(--font-mono);font-size:0.8rem"><%= d.get("assetNo") %></td>
              <td style="font-family:var(--font-mono);font-size:0.8rem"><%= d.get("date") %></td>
              <td><%= d.get("type").isEmpty()?"-":d.get("type") %></td>
              <td style="max-width:250px;word-break:break-word"><%= d.get("remark").isEmpty()?"-":d.get("remark") %></td>
            </tr>
            <%}%>
            </tbody>
          </table>
        </div>
        <%}%>
      </div>
    </div>

    <!-- 우측: 빠른이동 탭 (320px 고정) -->
    <div style="width:320px;flex-shrink:0">
      <div class="results-card" style="margin-bottom:0">
        <div class="results-header">
          <div>
            <div class="results-title" style="font-size:1rem">빠른 이동</div>
          </div>
        </div>
        <div style="display:grid;grid-template-columns:repeat(2, 1fr);gap:12px">
          <a href="/CAN/main_admin.jsp" style="display:flex;flex-direction:column;align-items:center;gap:10px;background:var(--sky-bg);border:1.5px solid #7dd3fc;border-radius:var(--radius-lg);padding:12px 16px;text-decoration:none;color:var(--sky-primary);font-weight:600;font-size:0.9rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center;min-height:70px">
            <i class="bi bi-house-fill" style="font-size:20px;flex-shrink:0"></i><span style="line-height:1.3">대시보드</span>
          </a>
          <a href="/CAN/asset_manage.jsp" style="display:flex;flex-direction:column;align-items:center;gap:10px;background:#f0fdfa;border:1.5px solid #99f6e4;border-radius:var(--radius-lg);padding:12px 16px;text-decoration:none;color:#0d9488;font-weight:600;font-size:0.9rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center;min-height:70px">
            <i class="bi bi-pencil-square" style="font-size:20px;flex-shrink:0"></i><span style="line-height:1.3">자산 관리</span>
          </a>
          <a href="/CAN/reservations_admin.jsp" style="display:flex;flex-direction:column;align-items:center;gap:10px;background:#fffbeb;border:1.5px solid #fde68a;border-radius:var(--radius-lg);padding:12px 16px;text-decoration:none;color:#d97706;font-weight:600;font-size:0.9rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center;min-height:70px">
            <i class="bi bi-calendar-check" style="font-size:20px;flex-shrink:0"></i><span style="line-height:1.3">예약 관리</span>
          </a>
          <a href="/CAN/transfer.jsp" style="display:flex;flex-direction:column;align-items:center;gap:10px;background:#f5f3ff;border:1.5px solid #d8b4fe;border-radius:var(--radius-lg);padding:12px 16px;text-decoration:none;color:#7c3aed;font-weight:600;font-size:0.9rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center;min-height:70px">
            <i class="bi bi-arrow-left-right" style="font-size:20px;flex-shrink:0"></i><span style="line-height:1.3">이관 내역</span>
          </a>
        </div>
      </div>
    </div>
  </div>


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
// Pagination
const ITEMS_PER_PAGE=10;
let currentPage=1;

function goToPage(page){
  const rows=document.querySelectorAll('.table-row');
  const totalPages=Math.ceil(rows.length/ITEMS_PER_PAGE);
  if(page<1||page>totalPages)return;
  currentPage=page;
  const start=(page-1)*ITEMS_PER_PAGE;
  const end=start+ITEMS_PER_PAGE;
  rows.forEach((row,idx)=>{
    row.style.display=(idx>=start&&idx<end)?'table-row':'none';
  });
  document.querySelectorAll('.pagination-btn').forEach(btn=>{
    btn.classList.remove('active');
    btn.style.background='white';
    btn.style.color='var(--txt-sub)';
    btn.style.borderColor='#cbd5e1';
    if(btn.dataset.page==page){
      btn.classList.add('active');
      btn.style.background='var(--sky-bg)';
      btn.style.color='var(--sky-primary)';
      btn.style.borderColor='#7dd3fc';
    }
  });
}

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
  if(document.querySelectorAll('.table-row').length>0)goToPage(1);
});
</script>
</body>
</html>
