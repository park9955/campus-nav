<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    /* ── 접근 권한 체크: 관리자 / 조교 / 교수만 ── */
    String loginUser = (String)session.getAttribute("loginUser");
    String loginName = (String)session.getAttribute("loginName");
    String loginRole = (String)session.getAttribute("loginRole");
    if(loginUser == null){ response.sendRedirect("/CAN/campuslogin.jsp"); return; }
    boolean isAdmin = "admin".equals(loginRole);
    boolean isAssist= "assistant".equals(loginRole);
    boolean isProf  = "professor".equals(loginRole);
    if(!isAdmin && !isAssist && !isProf){
        response.sendRedirect("/CAN/main_"+loginRole+".jsp"); return;
    }

    /* ── DB 연결 상수 ── */
    final String DB_URL = "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";
    final String DB_USER = "root", DB_PASS = "1234";

    /* ══════════════════════════════════════════
       POST 처리: action 파라미터로 분기
       action=insert → 신규 등록
       action=update → 수정
       action=delete → 삭제
    ══════════════════════════════════════════ */
    String action  = request.getParameter("action");
    String msgOk   = "";
    String msgErr  = "";

    if("POST".equals(request.getMethod()) && action != null){
        request.setCharacterEncoding("UTF-8");
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            /* ── 삭제 ── */
            if("delete".equals(action)){
                String delNo = request.getParameter("delNo");
                if(delNo != null && !delNo.trim().isEmpty()){
                    PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM assets WHERE asset_no=?");
                    ps.setString(1, delNo.trim());
                    int n = ps.executeUpdate(); ps.close();
                    msgOk = (n>0) ? "자산 ["+delNo+"] 이(가) DB에서 삭제되었습니다." : "삭제할 자산을 찾지 못했습니다.";
                }
            }
            /* ── 수정 ── */
            else if("update".equals(action)){
                String assetNo   = request.getParameter("u_asset_no");
                String itemName  = request.getParameter("u_item_name");
                String assetCls  = request.getParameter("u_asset_class");
                String model     = request.getParameter("u_model");
                String spec      = request.getParameter("u_spec");
                String mfr       = request.getParameter("u_manufacturer");
                String loc       = request.getParameter("u_location");
                String dloc      = request.getParameter("u_detail_location");
                String dept      = request.getParameter("u_manage_dept");
                String mgr       = request.getParameter("u_manager_name");
                String status    = request.getParameter("u_asset_status");
                String qty       = request.getParameter("u_quantity");
                String acqDate   = request.getParameter("u_acq_date");
                String acqPrice  = request.getParameter("u_acq_price");
                String life      = request.getParameter("u_useful_life");
                String remark    = request.getParameter("u_remark");
                if(assetNo==null||assetNo.trim().isEmpty()){ msgErr="자산번호가 없습니다."; }
                else{
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE assets SET item_name=?,asset_class=?,model=?,spec=?,manufacturer=?," +
                        "location=?,detail_location=?,manage_dept=?,manager_name=?,asset_status=?," +
                        "quantity=?,acq_date=?,acq_price=?,useful_life=?,remark=?,mod_date=NOW() " +
                        "WHERE asset_no=?");
                    ps.setString(1, nvl(itemName));
                    ps.setString(2, nvl(assetCls));
                    ps.setString(3, nvl(model));
                    ps.setString(4, nvl(spec));
                    ps.setString(5, nvl(mfr));
                    ps.setString(6, nvl(loc));
                    ps.setString(7, nvl(dloc));
                    ps.setString(8, nvl(dept));
                    ps.setString(9, nvl(mgr));
                    ps.setString(10, nvl(status));
                    if(qty!=null&&!qty.trim().isEmpty()) ps.setInt(11,Integer.parseInt(qty.trim())); else ps.setNull(11,Types.INTEGER);
                    if(acqDate!=null&&!acqDate.trim().isEmpty()) ps.setDate(12,java.sql.Date.valueOf(acqDate.trim())); else ps.setNull(12,Types.DATE);
                    if(acqPrice!=null&&!acqPrice.trim().isEmpty()) ps.setLong(13,Long.parseLong(acqPrice.replaceAll("[^0-9]",""))); else ps.setNull(13,Types.BIGINT);
                    if(life!=null&&!life.trim().isEmpty()) ps.setInt(14,Integer.parseInt(life.trim())); else ps.setNull(14,Types.INTEGER);
                    ps.setString(15, nvl(remark));
                    ps.setString(16, assetNo.trim());
                    int n = ps.executeUpdate(); ps.close();
                    msgOk = (n>0) ? "자산 ["+assetNo+"] 이(가) DB에서 수정되었습니다." : "수정할 자산을 찾지 못했습니다.";
                }
            }
            /* ── 신규 등록 ── */
            else if("insert".equals(action)){
                String assetNo   = request.getParameter("i_asset_no");
                String itemName  = request.getParameter("i_item_name");
                String assetCls  = request.getParameter("i_asset_class");
                String model     = request.getParameter("i_model");
                String spec      = request.getParameter("i_spec");
                String mfr       = request.getParameter("i_manufacturer");
                String loc       = request.getParameter("i_location");
                String dloc      = request.getParameter("i_detail_location");
                String dept      = request.getParameter("i_manage_dept");
                String mgr       = request.getParameter("i_manager_name");
                String status    = request.getParameter("i_asset_status");
                String qty       = request.getParameter("i_quantity");
                String acqDate   = request.getParameter("i_acq_date");
                String acqPrice  = request.getParameter("i_acq_price");
                String life      = request.getParameter("i_useful_life");
                String remark    = request.getParameter("i_remark");
                if(assetNo==null||assetNo.trim().isEmpty()||itemName==null||itemName.trim().isEmpty()){
                    msgErr = "자산번호와 품목명은 필수입니다.";
                } else {
                    // 중복 체크
                    PreparedStatement ck = conn.prepareStatement("SELECT COUNT(*) FROM assets WHERE asset_no=?");
                    ck.setString(1,assetNo.trim()); ResultSet rck=ck.executeQuery();
                    boolean dup = rck.next()&&rck.getInt(1)>0; rck.close(); ck.close();
                    if(dup){ msgErr = "자산번호 ["+assetNo+"] 이(가) 이미 존재합니다."; }
                    else{
                        PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO assets(asset_no,item_name,asset_class,model,spec,manufacturer," +
                            "location,detail_location,manage_dept,manager_name,asset_status," +
                            "quantity,acq_date,acq_price,useful_life,remark,reg_date,mod_date) " +
                            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW())");
                        ps.setString(1,assetNo.trim());
                        ps.setString(2,nvl(itemName));
                        ps.setString(3,nvl(assetCls));
                        ps.setString(4,nvl(model));
                        ps.setString(5,nvl(spec));
                        ps.setString(6,nvl(mfr));
                        ps.setString(7,nvl(loc));
                        ps.setString(8,nvl(dloc));
                        ps.setString(9,nvl(dept));
                        ps.setString(10,nvl(mgr));
                        ps.setString(11,status!=null&&!status.isEmpty()?status:"사용중");
                        if(qty!=null&&!qty.trim().isEmpty()) ps.setInt(12,Integer.parseInt(qty.trim())); else ps.setInt(12,1);
                        if(acqDate!=null&&!acqDate.trim().isEmpty()) ps.setDate(13,java.sql.Date.valueOf(acqDate.trim())); else ps.setNull(13,Types.DATE);
                        if(acqPrice!=null&&!acqPrice.trim().isEmpty()) ps.setLong(14,Long.parseLong(acqPrice.replaceAll("[^0-9]",""))); else ps.setNull(14,Types.BIGINT);
                        if(life!=null&&!life.trim().isEmpty()) ps.setInt(15,Integer.parseInt(life.trim())); else ps.setNull(15,Types.INTEGER);
                        ps.setString(16,nvl(remark));
                        ps.executeUpdate(); ps.close();
                        msgOk = "자산 ["+assetNo+"] 이(가) DB에 등록되었습니다.";
                    }
                }
            }
            conn.close();
        }catch(Exception e){ msgErr = "DB 오류: "+e.getMessage(); }
    }

    /* ── 자산 목록 조회 (최근 30건) ── */
    String keyword = request.getParameter("keyword"); if(keyword==null)keyword="";
    String filterCls = request.getParameter("filterCls"); if(filterCls==null)filterCls="";
    List<Map<String,String>> assetList = new ArrayList<>();
    int assetTotal = 0;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        StringBuilder w = new StringBuilder("WHERE 1=1 ");
        List<String> params = new ArrayList<>();
        if(!keyword.isEmpty()){
            w.append("AND (item_name LIKE ? OR asset_no LIKE ? OR detail_location LIKE ? OR manage_dept LIKE ?) ");
            for(int i=0;i<4;i++) params.add("%"+keyword+"%");
        }
        if(!filterCls.isEmpty()){ w.append("AND asset_class=? "); params.add(filterCls); }
        PreparedStatement ps=conn.prepareStatement("SELECT COUNT(*) FROM assets "+w);
        for(int i=0;i<params.size();i++) ps.setString(i+1,params.get(i));
        ResultSet rs=ps.executeQuery(); if(rs.next())assetTotal=rs.getInt(1); rs.close(); ps.close();
        ps=conn.prepareStatement("SELECT asset_no,asset_class,item_name,model,detail_location,manage_dept,manager_name,asset_status FROM assets "+w+"ORDER BY reg_date DESC LIMIT 30");
        for(int i=0;i<params.size();i++) ps.setString(i+1,params.get(i));
        rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> r=new LinkedHashMap<>();
            r.put("no",nvl(rs.getString(1))); r.put("cls",nvl(rs.getString(2)));
            r.put("name",nvl(rs.getString(3))); r.put("model",nvl(rs.getString(4)));
            r.put("loc",nvl(rs.getString(5))); r.put("dept",nvl(rs.getString(6)));
            r.put("mgr",nvl(rs.getString(7))); r.put("st",nvl(rs.getString(8)));
            assetList.add(r);
        }
        rs.close(); ps.close(); conn.close();
    }catch(Exception e){ msgErr += " | 목록조회: "+e.getMessage(); }
%>
<%! private String nvl(String s){ return s==null?"":s.trim(); } %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 자산 관리</title>

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
  --amber-light: #fffbeb;
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

.hero-search-card::after {
  content: '';
  position: absolute;
  right: 0;
  top: 0;
  bottom: 0;
  width: 200px;
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.05) 0%, rgba(2, 132, 199, 0.08) 100%);
  clip-path: polygon(15% 0%, 100% 0%, 100% 100%, 0% 100%);
  z-index: 0;
  pointer-events: none;
}

.hero-search-content {
  position: relative;
  z-index: 1;
}

.hero-title {
  font-size: 1.8rem;
  font-weight: 800;
  color: #0f172a;
  margin-bottom: 0.5rem;
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
  font-family: var(--font-mono);
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
  letter-spacing: 0.05em;
  padding: 12px 16px;
  text-align: left;
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

.badge {
  display: inline-block;
  padding: 4px 10px;
  border-radius: var(--radius-md);
  font-size: 0.8rem;
  font-weight: 700;
  font-family: var(--font-mono);
  white-space: nowrap;
}

.badge-success {
  background: #dcfce7;
  color: #15803d;
}

.badge-warning {
  background: var(--amber-light);
  color: #b45309;
}

.badge-danger {
  background: var(--red-light);
  color: var(--red-main);
}

.btn-action {
  background: transparent;
  border: 1.5px solid var(--border-color);
  color: var(--txt-sub);
  padding: 6px 12px;
  border-radius: var(--radius-md);
  font-size: 0.8rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  display: inline-block;
  font-family: var(--font-mono);
}

.btn-action:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
  background: var(--sky-bg);
}

.btn-action-edit {
  border-color: var(--amber-main);
  color: var(--amber-main);
}

.btn-action-edit:hover {
  background: rgba(217, 119, 6, 0.1);
}

.btn-action-del {
  border-color: var(--red-main);
  color: var(--red-main);
}

.btn-action-del:hover {
  background: rgba(220, 38, 38, 0.1);
}

.tab-bar {
  display: flex;
  gap: 4px;
  border-bottom: 2px solid var(--border-color);
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.tab-btn {
  font-family: var(--font-mono);
  font-size: 0.85rem;
  font-weight: 600;
  padding: 8px 14px;
  border: none;
  background: transparent;
  color: var(--txt-muted);
  cursor: pointer;
  transition: all 0.15s;
  border-bottom: 2px solid transparent;
  margin-bottom: -2px;
  white-space: nowrap;
}

.tab-btn:hover {
  color: var(--sky-primary);
}

.tab-btn.active {
  color: var(--sky-primary);
  border-bottom-color: var(--sky-primary);
  font-weight: 700;
}

.tab-content {
  display: none;
}

.tab-content.active {
  display: block;
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
  .tab-bar { flex-direction: column; gap: 0; }
  .tab-btn { width: 100%; text-align: left; margin-bottom: 0; border-radius: 0; padding: 12px 16px; }
  .table-air { font-size: 0.8rem; }
  .table-air th, .table-air td { padding: 10px 12px; }
  .row.g-4 { gap: 2rem 1rem; }
}

[data-theme="dark"] .results-table th {
  background: #1e3a5f;
  color: #f1f5f9;
}

[data-theme="dark"] .results-table td {
  color: #e2e8f0;
}

[data-theme="dark"] .results-card {
  background: #1e293b;
  color: #f1f5f9;
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

</style>
</head>
<body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="/CAN/main_<%= loginRole %>.jsp">
        <i class="bi bi-compass-fill text-info fs-3"></i>
        <span>ICT <strong>CAN</strong></span>
        <span class="brand-badge"><%= isAdmin?"ADMIN":isAssist?"ASSISTANT":"PROFESSOR" %></span>
      </a>

      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>

      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/search.jsp"><i class="bi bi-search"></i> 검색</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/main_<%= loginRole %>.jsp"><i class="bi bi-house"></i> 홈</a>
          </li>

          <li class="nav-item ms-lg-3 my-2 my-lg-0">
            <div class="user-tag-pill">
              <i class="bi bi-person-circle text-info fs-6"></i>
              <span><%= loginName %> <%= isAdmin?"관리자":isAssist?"조교":"교수" %></span>
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
    <div class="hero-search-content">
      <div class="hero-subtitle">ICT CAN · 자산 관리</div>
      <h1 class="hero-title">자산 <strong style="color: #4ade80;">등록 · 수정 · 삭제</strong></h1>
      <p class="hero-subtitle">DB에 직접 연동됩니다. 총 <strong><%= assetTotal %>건</strong> 검색됨.</p>
    </div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!msgOk.isEmpty()){ %>
  <div class="alert-success"><i class="bi bi-check-circle-fill"></i><%= msgOk %></div>
  <% } %>
  <% if(!msgErr.isEmpty()){ %>
  <div class="alert-danger"><i class="bi bi-exclamation-circle-fill"></i><%= msgErr %></div>
  <% } %>

  <!-- TAB NAVIGATION -->
  <div class="tab-bar">
    <button class="tab-btn active" onclick="showTab('list', this)">
      <i class="bi bi-list-ul me-1"></i>자산 목록
    </button>
    <button class="tab-btn" onclick="showTab('insert', this)">
      <i class="bi bi-plus-circle me-1"></i>신규 등록
    </button>
    <button class="tab-btn" id="editTabBtn" onclick="showTab('edit', this)" style="display:none">
      <i class="bi bi-pencil me-1"></i>수정 중
    </button>
    <button class="tab-btn" id="delTabBtn" onclick="showTab('delete', this)" style="display:none">
      <i class="bi bi-trash me-1"></i>삭제 확인
    </button>
  </div>

  <!-- ════ TAB: 자산 목록 ════ -->
  <div class="tab-content active" id="tab-list">
    <!-- 검색 -->
    <div style="margin-bottom:16px">
      <form method="get" action="/CAN/asset_manage.jsp">
        <div class="row g-2 align-items-end">
          <div class="col-lg-6">
            <input type="text" name="keyword" value="<%= keyword %>" class="form-control" placeholder="자산번호, 품목명, 위치, 관리부서 검색...">
          </div>
          <div class="col-lg-3">
            <select name="filterCls" class="form-select">
              <option value="">전체 분류</option>
              <option value="공기구비품" <%= "공기구비품".equals(filterCls)?"selected":"" %>>공기구비품</option>
              <option value="집기비품" <%= "집기비품".equals(filterCls)?"selected":"" %>>집기비품</option>
              <option value="무형고정자산" <%= "무형고정자산".equals(filterCls)?"selected":"" %>>소프트웨어</option>
            </select>
          </div>
          <div class="col-lg-3">
            <div class="d-flex gap-2">
              <button type="submit" class="btn btn-primary w-100"><i class="bi bi-search me-1"></i>검색</button>
              <a href="/CAN/asset_manage.jsp" class="btn btn-outline-secondary w-100">초기화</a>
            </div>
          </div>
        </div>
      </form>
    </div>

    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">자산 목록</div>
          <div class="results-subtitle">총 <%= assetTotal %>건 · 최근 30건 표시</div>
        </div>
      </div>

      <% if(assetList.isEmpty()){ %>
      <div style="text-align:center;padding:48px;color:var(--txt-muted)">
        <i class="bi bi-inbox" style="font-size:36px;display:block;margin-bottom:12px;opacity:.3"></i>
        검색 결과가 없습니다.
      </div>
      <% } else { %>
      <div class="table-responsive">
        <table class="table-air">
          <thead>
            <tr>
              <th>자산번호</th><th>분류</th><th>품목명</th>
              <th>위치</th><th>관리부서</th><th>관리자</th><th>상태</th><th>관리</th>
            </tr>
          </thead>
          <tbody>
          <% for(Map<String,String> a : assetList) {
               String st = a.get("st");
               String bc = st.contains("사용중")?"badge-danger":st.contains("점검")?"badge-warning":"badge-success";
               String clsL = a.get("cls").equals("무형고정자산")?"SW":a.get("cls").equals("집기비품")?"집기":"공기구";
          %>
          <tr onclick="openEdit('<%= a.get("no").replace("'","\\'") %>','<%= a.get("cls").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>','<%= a.get("model").replace("'","\\'") %>','<%= a.get("loc").replace("'","\\'") %>','<%= a.get("dept").replace("'","\\'") %>','<%= a.get("mgr").replace("'","\\'") %>','<%= st.replace("'","\\'") %>')">
            <td><span style="font-family:var(--font-mono);font-size:0.8rem;color:var(--txt-muted)"><%= a.get("no") %></span></td>
            <td><span class="badge badge-success"><%= clsL %></span></td>
            <td><strong><%= a.get("name") %></strong></td>
            <td><i class="bi bi-geo-alt" style="color:var(--emerald-main)"></i> <%= a.get("loc") %></td>
            <td><%= a.get("dept") %></td>
            <td><%= a.get("mgr") %></td>
            <td><span class="badge <%= bc %>"><%= st.isEmpty()?"정보없음":st %></span></td>
            <td onclick="event.stopPropagation()" style="white-space:nowrap">
              <button class="btn-action btn-action-edit me-1" onclick="openEdit('<%= a.get("no").replace("'","\\'") %>','<%= a.get("cls").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>','<%= a.get("model").replace("'","\\'") %>','<%= a.get("loc").replace("'","\\'") %>','<%= a.get("dept").replace("'","\\'") %>','<%= a.get("mgr").replace("'","\\'") %>','<%= st.replace("'","\\'") %>')">
                <i class="bi bi-pencil"></i> 수정
              </button>
              <button class="btn-action btn-action-del" onclick="openDelete('<%= a.get("no").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>')">
                <i class="bi bi-trash"></i> 삭제
              </button>
            </td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <% } %>
    </div>
  </div>

  <!-- ════ TAB: 신규 등록 ════ -->
  <div class="tab-content" id="tab-insert">
    <div class="results-card">
      <div class="results-header">
        <div>
          <div class="results-title">신규 자산 등록</div>
          <div class="results-subtitle">* 표시 항목은 필수입니다</div>
        </div>
      </div>

      <form method="post" action="/CAN/asset_manage.jsp" onsubmit="return validateInsert()">
        <input type="hidden" name="action" value="insert">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label fw-bold">자산번호 *</label>
            <input class="form-control" type="text" name="i_asset_no" id="i_asset_no" placeholder="예) 8402C9999" required>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">품목명 *</label>
            <input class="form-control" type="text" name="i_item_name" placeholder="예) 노트북 Dell XPS 15" required>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">자산분류</label>
            <select class="form-select" name="i_asset_class">
              <option value="공기구비품">공기구비품</option>
              <option value="집기비품">집기비품</option>
              <option value="무형고정자산">무형고정자산 (소프트웨어)</option>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">제조사</label>
            <input class="form-control" type="text" name="i_manufacturer" placeholder="예) Dell">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">모델명</label>
            <input class="form-control" type="text" name="i_model" placeholder="예) XPS 15 9530">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">규격/스펙</label>
            <input class="form-control" type="text" name="i_spec" placeholder="예) i7-13700H / 16GB / 512GB">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">위치 (건물)</label>
            <input class="form-control" type="text" name="i_location" placeholder="예) 1공학관">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">상세위치 (호실)</label>
            <input class="form-control" type="text" name="i_detail_location" placeholder="예) 301호">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">관리부서</label>
            <input class="form-control" type="text" name="i_manage_dept" placeholder="예) AI소프트웨어학과">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">관리자명</label>
            <input class="form-control" type="text" name="i_manager_name" placeholder="예) 홍길동">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">상태</label>
            <select class="form-select" name="i_asset_status">
              <option value="사용중">사용중</option>
              <option value="사용가능">사용가능</option>
              <option value="점검중">점검중</option>
              <option value="폐기예정">폐기예정</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">수량</label>
            <input class="form-control" type="number" name="i_quantity" value="1" min="1">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">취득일자</label>
            <input class="form-control" type="date" name="i_acq_date">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">취득가 (원)</label>
            <input class="form-control" type="text" name="i_acq_price" placeholder="예) 1500000">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">내용연수 (년)</label>
            <input class="form-control" type="number" name="i_useful_life" placeholder="예) 5" min="1">
          </div>
          <div class="col-12">
            <label class="form-label fw-bold">비고</label>
            <textarea class="form-control" name="i_remark" rows="2" placeholder="특이사항 등"></textarea>
          </div>
          <div class="col-12 d-flex gap-2 mt-2">
            <button type="submit" class="btn btn-success"><i class="bi bi-check-circle me-1"></i>DB에 등록하기</button>
            <button type="button" class="btn btn-outline-secondary" onclick="showTab('list',null)"><i class="bi bi-x-circle me-1"></i>취소</button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- ════ TAB: 수정 ════ -->
  <div class="tab-content" id="tab-edit">
    <div class="results-card" style="border-color:#fde68a">
      <div class="results-header" style="background:var(--amber-light);padding:1rem;margin:-1.75rem -1.75rem 1.5rem;border-bottom:1.5px solid #fde68a;border-radius:var(--radius-xl) var(--radius-xl) 0 0">
        <div>
          <div class="results-title" style="color:var(--amber-main)">자산 수정</div>
          <div class="results-subtitle" id="edit-sub-title">DB에 직접 반영됩니다</div>
        </div>
      </div>

      <form method="post" action="/CAN/asset_manage.jsp" onsubmit="return confirm('DB에 수정 내용을 저장하시겠습니까?')">
        <input type="hidden" name="action" value="update">
        <div class="row g-3">
          <div class="col-md-4">
            <label class="form-label fw-bold">자산번호 (변경불가)</label>
            <input class="form-control" type="text" name="u_asset_no" id="u_asset_no" readonly style="background:#f0f4f9">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">품목명 *</label>
            <input class="form-control" type="text" name="u_item_name" id="u_item_name" required>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">자산분류</label>
            <select class="form-select" name="u_asset_class" id="u_asset_class">
              <option value="공기구비품">공기구비품</option>
              <option value="집기비품">집기비품</option>
              <option value="무형고정자산">무형고정자산 (소프트웨어)</option>
            </select>
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">모델명</label>
            <input class="form-control" type="text" name="u_model" id="u_model">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">규격/스펙</label>
            <input class="form-control" type="text" name="u_spec" id="u_spec">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">제조사</label>
            <input class="form-control" type="text" name="u_manufacturer" id="u_manufacturer">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">위치 (건물)</label>
            <input class="form-control" type="text" name="u_location" id="u_location">
          </div>
          <div class="col-md-6">
            <label class="form-label fw-bold">상세위치 (호실)</label>
            <input class="form-control" type="text" name="u_detail_location" id="u_detail_location">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">관리부서</label>
            <input class="form-control" type="text" name="u_manage_dept" id="u_manage_dept">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">관리자명</label>
            <input class="form-control" type="text" name="u_manager_name" id="u_manager_name">
          </div>
          <div class="col-md-4">
            <label class="form-label fw-bold">상태</label>
            <select class="form-select" name="u_asset_status" id="u_asset_status">
              <option value="사용중">사용중</option>
              <option value="사용가능">사용가능</option>
              <option value="점검중">점검중</option>
              <option value="폐기예정">폐기예정</option>
            </select>
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">수량</label>
            <input class="form-control" type="number" name="u_quantity" id="u_quantity" min="1">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">취득일자</label>
            <input class="form-control" type="date" name="u_acq_date" id="u_acq_date">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">취득가 (원)</label>
            <input class="form-control" type="text" name="u_acq_price" id="u_acq_price">
          </div>
          <div class="col-md-3">
            <label class="form-label fw-bold">내용연수 (년)</label>
            <input class="form-control" type="number" name="u_useful_life" id="u_useful_life" min="1">
          </div>
          <div class="col-12">
            <label class="form-label fw-bold">비고</label>
            <textarea class="form-control" name="u_remark" id="u_remark" rows="2"></textarea>
          </div>
          <div class="col-12 d-flex gap-2 mt-2">
            <button type="submit" class="btn btn-warning text-white"><i class="bi bi-floppy me-1"></i>DB에 수정 저장</button>
            <button type="button" class="btn btn-outline-secondary" onclick="showTab('list',null)"><i class="bi bi-x-circle me-1"></i>취소</button>
          </div>
        </div>
      </form>
    </div>
  </div>

  <!-- ════ TAB: 삭제 확인 ════ -->
  <div class="tab-content" id="tab-delete">
    <div class="results-card" style="border-color:#fca5a5">
      <div class="results-header" style="background:var(--red-light);padding:1rem;margin:-1.75rem -1.75rem 1.5rem;border-bottom:1.5px solid #fca5a5;border-radius:var(--radius-xl) var(--radius-xl) 0 0">
        <div>
          <div class="results-title" style="color:var(--red-main)">자산 삭제</div>
          <div class="results-subtitle">삭제 후 복구 불가</div>
        </div>
      </div>

      <div style="background:var(--red-light);border:1.5px solid #fca5a5;border-radius:var(--radius-lg);padding:1.5rem;margin-bottom:1rem">
        <div style="display:flex;align-items:center;gap:8px;margin-bottom:1rem;color:var(--red-main);font-weight:700;font-size:0.95rem">
          <i class="bi bi-exclamation-triangle-fill"></i>삭제 대상 자산
        </div>
        <div class="row g-3">
          <div class="col-md-4">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">자산번호</div>
            <div style="font-weight:800;font-size:0.95rem;font-family:var(--font-mono);color:var(--red-main)" id="del-no-display">-</div>
          </div>
          <div class="col-md-8">
            <div style="font-family:var(--font-mono);font-size:0.75rem;color:var(--txt-muted);text-transform:uppercase;margin-bottom:0.5rem">품목명</div>
            <div style="font-weight:700;font-size:0.95rem" id="del-name-display">-</div>
          </div>
        </div>
      </div>

      <div style="background:var(--amber-light);border:1px solid #fde68a;border-radius:var(--radius-md);padding:12px 14px;font-size:0.9rem;color:#713f12;margin-bottom:1rem;display:flex;align-items:center;gap:8px">
        <i class="bi bi-info-circle-fill"></i>
        이 자산에 연결된 이관이력, 폐기이력도 함께 삭제됩니다. 예약 기록은 별도 확인하세요.
      </div>

      <form method="post" action="/CAN/asset_manage.jsp" onsubmit="return confirmDelete()">
        <input type="hidden" name="action" value="delete">
        <input type="hidden" name="delNo" id="delNo">
        <div style="margin-bottom:16px">
          <label class="form-label fw-bold">삭제 사유를 입력하세요 (선택)</label>
          <input class="form-control" type="text" name="delReason" id="delReason" placeholder="예) 내용연수 만료, 분실, 파손 등">
        </div>
        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-danger"><i class="bi bi-trash3-fill me-1"></i>DB에서 영구 삭제</button>
          <button type="button" class="btn btn-outline-secondary" onclick="showTab('list',null)"><i class="bi bi-x-circle me-1"></i>취소</button>
        </div>
      </form>
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
function showTab(name, btn) {
  document.querySelectorAll('.tab-content').forEach(el => el.classList.remove('active'));
  document.querySelectorAll('.tab-btn').forEach(el => el.classList.remove('active'));
  document.getElementById('tab-' + name).classList.add('active');
  if(btn) btn.classList.add('active');
  else document.querySelector('.tab-btn').classList.add('active');
}

function openEdit(no, cls, name, model, loc, dept, mgr, status) {
  document.getElementById('u_asset_no').value = no;
  document.getElementById('u_item_name').value = name;
  document.getElementById('u_model').value = model;
  document.getElementById('u_detail_location').value = loc;
  document.getElementById('u_manage_dept').value = dept;
  document.getElementById('u_manager_name').value = mgr;
  document.getElementById('edit-sub-title').textContent = '자산번호: ' + no;
  var sel = document.getElementById('u_asset_class');
  for(var i=0;i<sel.options.length;i++){
    if(sel.options[i].value===cls){ sel.selectedIndex=i; break; }
  }
  var ssel = document.getElementById('u_asset_status');
  for(var i=0;i<ssel.options.length;i++){
    if(ssel.options[i].value===status){ ssel.selectedIndex=i; break; }
  }
  document.getElementById('editTabBtn').style.display='';
  showTab('edit', document.getElementById('editTabBtn'));
}

function openDelete(no, name) {
  document.getElementById('del-no-display').textContent = no;
  document.getElementById('del-name-display').textContent = name;
  document.getElementById('delNo').value = no;
  document.getElementById('delReason').value = '';
  document.getElementById('delTabBtn').style.display='';
  showTab('delete', document.getElementById('delTabBtn'));
}

function confirmDelete() {
  var no = document.getElementById('delNo').value;
  var name = document.getElementById('del-name-display').textContent;
  return confirm('영구 삭제 확인\n\n자산번호: ' + no + '\n품목명: ' + name + '\n\nDB에서 완전히 삭제됩니다.\n계속하시겠습니까?');
}

function validateInsert() {
  var no = document.getElementById('i_asset_no').value.trim();
  var name = document.querySelector('[name="i_item_name"]').value.trim();
  if(!no){ alert('자산번호를 입력해 주세요.'); return false; }
  if(!name){ alert('품목명을 입력해 주세요.'); return false; }
  return confirm('자산번호 [' + no + ']\n[' + name + ']\n\nDB에 등록하시겠습니까?');
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
  <% if(!msgOk.isEmpty()){ %>
  showTab('list', document.querySelector('.tab-btn'));
  <% } else if("new".equals(request.getParameter("action"))){ %>
  var insertBtn = document.querySelectorAll('.tab-btn')[1];
  showTab('insert', insertBtn);
  <% } %>
});
</script>
</body>
</html>
