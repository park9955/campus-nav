<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    if(!"admin".equals(session.getAttribute("loginRole"))){response.sendRedirect("/CAN/campuslogin.jsp");return;}

    final String DBURL="jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";

    String okMsg="",errMsg="";
    // ── POST 처리 ──
    if("POST".equals(request.getMethod())){
        request.setCharacterEncoding("UTF-8");
        String act=request.getParameter("act");
        // 예약 연장
        if("extendReserve".equals(act)){
            String rid=request.getParameter("reserveId");
            String extendHours=request.getParameter("extendHours");
            try{
                int hours=Integer.parseInt(extendHours!=null?extendHours:"1");
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c=DriverManager.getConnection(DBURL,"root","1234");
                PreparedStatement ps=c.prepareStatement("UPDATE reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=?");
                ps.setInt(1,hours);ps.setString(2,rid);int n=ps.executeUpdate();ps.close();c.close();
                okMsg=n>0?"예약 #"+rid+" 이(가) "+hours+"시간 연장되었습니다":"해당 예약을 찾을 수 없습니다.";
            }catch(Exception e){errMsg="연장 오류: "+e.getMessage();}
        }
        // 예약 취소
        else if("cancelReserve".equals(act)){
            String rid=request.getParameter("reserveId");
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection c=DriverManager.getConnection(DBURL,"root","1234");
                PreparedStatement ps=c.prepareStatement("UPDATE reservations SET status='취소' WHERE reserve_id=?");
                ps.setString(1,rid);int n=ps.executeUpdate();ps.close();c.close();
                okMsg=n>0?"예약 #"+rid+" 취소 완료":"해당 예약을 찾을 수 없습니다.";
            }catch(Exception e){errMsg="취소 오류: "+e.getMessage();}
        }
        // 이관내역 등록
        else if("addTransfer".equals(act)){
            String assetNo=request.getParameter("t_asset_no");
            String tDate=request.getParameter("t_date");
            String fDept=request.getParameter("t_from_dept");
            String fLoc=request.getParameter("t_from_loc");
            String tDept=request.getParameter("t_to_dept");
            String tLoc=request.getParameter("t_to_loc");
            String rmk=request.getParameter("t_remark");
            if(assetNo==null||assetNo.trim().isEmpty()||tDate==null||tDate.trim().isEmpty()){
                errMsg="자산번호와 이관일자는 필수입니다.";
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
                            "INSERT INTO asset_transfer(asset_no,item_name,transfer_date,before_dept,before_detail,after_dept,after_detail,remark) VALUES(?,?,?,?,?,?,?,?)");
                        ps.setString(1,assetNo.trim());ps.setString(2,iname);
                        ps.setString(3,tDate.trim());ps.setString(4,fDept!=null?fDept:"");
                        ps.setString(5,fLoc!=null?fLoc:"");ps.setString(6,tDept!=null?tDept:"");
                        ps.setString(7,tLoc!=null?tLoc:"");ps.setString(8,rmk!=null?rmk:"");
                        ps.executeUpdate();ps.close();
                        okMsg="이관내역 등록 완료! ["+assetNo+"] "+iname;
                    }
                    c.close();
                }catch(Exception e){errMsg="이관 등록 오류: "+e.getMessage();}
            }
        }
    }

    // ── 통계 조회 ──
    int tA=0,tT=0,tD=0,tR=0;
    List<Map<String,String>> allReserves=new ArrayList<>();
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection(DBURL,"root","1234");
        // 시간이 지난 예약을 자동으로 "사용완료"로 변경
        String updateSql="UPDATE reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);
        ResultSet rs;
        rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets");if(rs.next())tA=rs.getInt(1);rs.close();
        rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM asset_transfer");if(rs.next())tT=rs.getInt(1);rs.close();
        rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM asset_disposal");if(rs.next())tD=rs.getInt(1);rs.close();
        rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM reservations");if(rs.next())tR=rs.getInt(1);rs.close();
        // 전체 예약 조회
        rs=conn.createStatement().executeQuery(
            "SELECT r.reserve_id,r.user_id,IFNULL(u.user_name,r.user_id) AS uname,"+
            "IFNULL(a.item_name,'강의실') AS item_name,r.reserve_date,r.start_time,r.end_time,r.status "+
            "FROM reservations r LEFT JOIN assets a ON r.asset_no=a.asset_no "+
            "LEFT JOIN users u ON r.user_id=u.user_id "+
            "ORDER BY r.reserve_date DESC,r.start_time DESC LIMIT 30");
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("uid",rs.getString("user_id")!=null?rs.getString("user_id"):"");
            m.put("uname",rs.getString("uname")!=null?rs.getString("uname"):"");
            m.put("name",rs.getString("item_name")!=null?rs.getString("item_name"):"");
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            allReserves.add(m);
        }
        rs.close();conn.close();
    }catch(Exception e){errMsg+="|조회오류:"+e.getMessage();}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 관리자</title>

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

.stat-row { display: grid; grid-template-columns: repeat(4, 1fr); gap: 1.5rem; margin-bottom: 2rem; }
.stat-card { background: var(--surface); border: 1px solid #f1f5f9; border-radius: var(--radius-lg); padding: 1.75rem; box-shadow: var(--shadow-soft); display: flex; align-items: flex-start; gap: 1.5rem; cursor: pointer; transition: all 0.25s; }
.stat-card:hover { box-shadow: var(--shadow-air); transform: translateY(-2px); }
.stat-icon { width: 3rem; height: 3rem; border-radius: 0.75rem; display: flex; align-items: center; justify-content: center; font-size: 1.5rem; flex-shrink: 0; }
.si-blue { background: #f0f9ff; } .si-teal { background: #f0fdf4; } .si-purple { background: #f5f3ff; } .si-amber { background: #fffbeb; }
.stat-label { font-size: 0.75rem; color: var(--txt-muted); font-weight: 600; margin-bottom: 0.25rem; }
.stat-val { font-size: 1.875rem; font-weight: 800; line-height: 1; margin-bottom: 0.25rem; }
.sv-blue { color: var(--sky-primary); } .sv-teal { color: var(--emerald-main); } .sv-purple { color: #7c3aed; } .sv-amber { color: var(--amber-main); }
.stat-sub { font-size: 0.75rem; color: var(--txt-muted); }

.borderless-card { background: var(--surface); border-radius: var(--radius-xl); padding: 2rem; box-shadow: var(--shadow-soft); margin-bottom: 2rem; border: 1px solid #f1f5f9; }
.table-air { width: 100%; border-collapse: collapse; font-size: 0.925rem; }
.table-air th { color: var(--txt-muted); font-weight: 700; padding: 12px 16px; border-bottom: 2px solid #e2e8f0; text-align: left; }
.table-air td { padding: 14px 16px; border-bottom: 1px solid #f1f5f9; color: var(--txt-main); vertical-align: middle; }
.table-air tr:last-child td { border-bottom: none; }

.app-footer { background: var(--surface); border-top: 1px solid #e2e8f0; color: var(--txt-sub); padding: 2.5rem 0; margin-top: 4rem; font-size: 0.875rem; }

[data-theme="dark"] .stat-card { background: #1e293b; border-color: #334155; color: #f1f5f9; }
[data-theme="dark"] .stat-label { color: #cbd5e1; }
[data-theme="dark"] .stat-sub { color: #cbd5e1; }
[data-theme="dark"] .table-air th { border-bottom-color: #475569; color: #f1f5f9; }
[data-theme="dark"] .table-air td { border-bottom-color: #334155; color: #e2e8f0; }

.f-label { font-family: var(--font-main); font-size: 0.875rem; color: var(--txt-sub); font-weight: 600; }
.f-input { width: 100%; border: 1.5px solid #cbd5e1; border-radius: 0.5rem; padding: 0.75rem; font-size: 0.95rem; outline: none; font-family: var(--font-main); transition: all 0.2s; background: var(--surface); color: var(--txt-main); }
.f-input:focus { border-color: var(--sky-primary); box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.1); }

@media(max-width: 768px) { .stat-row { grid-template-columns: repeat(2, 1fr); } }
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
            <a class="nav-link-btn" href="/CAN/search.jsp"><i class="bi bi-search"></i> 검색</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/transfer.jsp"><i class="bi bi-arrow-left-right"></i> 이관내역</a>
          </li>
          <li class="nav-item">
            <a class="nav-link-btn" href="/CAN/asset_manage.jsp"><i class="bi bi-pencil-square"></i> 자원관리</a>
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

<main class="container-xl pb-5">

  <% if(!okMsg.isEmpty()){%>
  <div class="alert alert-success alert-dismissible fade show mt-3" role="alert">
    <i class="bi bi-check-circle-fill me-2"></i><%= okMsg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <%}%>
  <% if(!errMsg.isEmpty()){%>
  <div class="alert alert-danger alert-dismissible fade show mt-3" role="alert">
    <i class="bi bi-exclamation-circle-fill me-2"></i><%= errMsg %>
    <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
  </div>
  <%}%>

  <!-- 2컬럼 레이아웃: 좌측(메인) + 우측(빠른이동) -->
  <div style="display:flex;gap:2rem;flex-wrap:wrap">
    <div style="flex:1;min-width:0">

      <!-- 이관내역 등록 (제일 위) -->
      <div class="borderless-card">
        <h2 class="fw-bold fs-5 m-0 mb-4">
          <i class="bi bi-arrow-left-right text-info me-2"></i>이관내역 등록
        </h2>
        <form method="post" action="/CAN/main_admin.jsp">
          <input type="hidden" name="act" value="addTransfer">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="f-label">자산번호 *</label>
              <input class="f-input" type="text" name="t_asset_no" placeholder="예) 8402C0001" required>
            </div>
            <div class="col-md-4">
              <label class="f-label">이관일자 *</label>
              <input class="f-input" type="date" name="t_date" required>
            </div>
            <div class="col-md-4">
              <label class="f-label">이관 전 부서</label>
              <input class="f-input" type="text" name="t_from_dept" placeholder="예) AI소프트웨어학과">
            </div>
            <div class="col-md-4">
              <label class="f-label">이관 전 위치</label>
              <input class="f-input" type="text" name="t_from_loc" placeholder="예) 301호">
            </div>
            <div class="col-md-4">
              <label class="f-label">이관 후 부서</label>
              <input class="f-input" type="text" name="t_to_dept" placeholder="예) 컴퓨터공학과">
            </div>
            <div class="col-md-4">
              <label class="f-label">이관 후 위치</label>
              <input class="f-input" type="text" name="t_to_loc" placeholder="예) 402호">
            </div>
            <div class="col-12">
              <label class="f-label">비고</label>
              <input class="f-input" type="text" name="t_remark" placeholder="이관 사유 등">
            </div>
            <div class="col-12">
              <button type="submit" class="btn btn-success"><i class="bi bi-check-circle me-1"></i>DB에 이관내역 등록</button>
              <a href="/CAN/transfer.jsp" class="btn btn-outline-secondary ms-2">전체 이관내역 보기</a>
            </div>
          </div>
        </form>
      </div>

      <!-- STATISTICS (가운데) -->
      <div class="stat-row">
        <div class="stat-card" onclick="location.href='/CAN/search.jsp'" style="cursor: pointer;">
          <div class="stat-icon si-blue"><i class="bi bi-box-seam" style="color:var(--sky-primary);font-size:20px"></i></div>
          <div>
            <div class="stat-label">전체 자산</div>
            <div class="stat-val sv-blue"><%= String.format("%,d",tA) %></div>
            <div class="stat-sub">DB 연동</div>
          </div>
        </div>
        <div class="stat-card" onclick="location.href='/CAN/transfer.jsp'" style="cursor: pointer;">
          <div class="stat-icon si-teal"><i class="bi bi-arrow-left-right" style="color:var(--emerald-main);font-size:20px"></i></div>
          <div>
            <div class="stat-label">이관 이력</div>
            <div class="stat-val sv-teal"><%= String.format("%,d",tT) %></div>
            <div class="stat-sub">누적</div>
          </div>
        </div>
        <div class="stat-card" onclick="location.href='/CAN/disposal_admin.jsp'" style="cursor: pointer;">
          <div class="stat-icon si-purple"><i class="bi bi-trash" style="color:#7c3aed;font-size:20px"></i></div>
          <div>
            <div class="stat-label">폐기 처리</div>
            <div class="stat-val sv-purple"><%= String.format("%,d",tD) %></div>
            <div class="stat-sub">누적</div>
          </div>
        </div>
        <div class="stat-card" onclick="location.href='/CAN/reservations_admin.jsp'" style="cursor: pointer;">
          <div class="stat-icon si-amber"><i class="bi bi-calendar-check" style="color:var(--amber-main);font-size:20px"></i></div>
          <div>
            <div class="stat-label">전체 예약</div>
            <div class="stat-val sv-amber"><%= String.format("%,d",tR) %></div>
            <div class="stat-sub">누적</div>
          </div>
        </div>
      </div>

      <!-- 전체 예약 관리 (아래) -->
      <div class="borderless-card">
        <div class="d-flex align-items-center justify-content-between mb-4">
          <h2 class="fw-bold fs-5 m-0">
            <i class="bi bi-calendar-check text-info me-2"></i>전체 예약 관리
          </h2>
        </div>

        <% if(allReserves.isEmpty()){%>
        <div style="text-align:center;padding:40px;color:var(--txt-muted)">
          <i class="bi bi-calendar-x" style="font-size:32px;display:block;margin-bottom:10px;opacity:.3"></i>
          예약 내역이 없습니다.
        </div>
        <%}else{%>
        <div class="table-responsive">
          <table class="table-air">
          <thead>
            <tr>
              <th>#</th>
              <th>신청자</th>
              <th>자산명</th>
              <th>날짜</th>
              <th>시간</th>
              <th>상태</th>
              <th class="text-end">관리</th>
            </tr>
          </thead>
          <tbody>
          <%for(Map<String,String> rv:allReserves){
              String st=rv.get("status");
              String chipClass=st.contains("취소")?"chip-cancel":st.contains("완료")?"chip-ok":"chip-warn";
          %>
          <tr>
            <td class="font-monospace text-secondary"><%= rv.get("id") %></td>
            <td>
              <div class="fw-bold"><%= rv.get("uname") %></div>
              <div class="text-muted small font-monospace"><%= rv.get("uid") %></div>
            </td>
            <td><%= rv.get("name") %></td>
            <td class="font-monospace text-secondary"><%= rv.get("date") %></td>
            <td class="font-monospace text-secondary"><%= rv.get("start") %> ~ <%= rv.get("end") %></td>
            <td><span class="status-chip <%= chipClass %>"><%= st %></span></td>
            <td class="text-end">
              <%if("사용완료".equals(st)){%>
              <form method="post" action="/CAN/main_admin.jsp" style="margin:0;display:inline" onchange="if(confirm('[관리자] 예약 #'+this.parentElement.parentElement.cells[0].textContent+' 연장하시겠습니까?')) this.submit(); else this.reset()">
                <input type="hidden" name="act" value="extendReserve">
                <input type="hidden" name="reserveId" value="<%= rv.get("id") %>">
                <select name="extendHours" style="padding:4px 8px;font-size:12px;border:1.5px solid #cbd5e1;border-radius:6px;outline:none;background:white;color:var(--txt-main);cursor:pointer;">
                  <option value="">연장</option>
                  <option value="1">1시간</option>
                  <option value="2">2시간</option>
                  <option value="4">4시간</option>
                  <option value="8">8시간</option>
                </select>
              </form>
              <%}else if("예약완료".equals(st)){%>
              <form method="post" action="/CAN/main_admin.jsp" style="margin:0;display:inline" onsubmit="return confirm('[관리자] 예약 #'+this.parentElement.parentElement.cells[0].textContent+'을 취소하시겠습니까?')">
                <input type="hidden" name="act" value="cancelReserve">
                <input type="hidden" name="reserveId" value="<%= rv.get("id") %>">
                <button type="submit" class="btn btn-sm btn-outline-danger" style="border-radius: var(--radius-pill);"><i class="bi bi-x-circle"></i>취소</button>
              </form>
              <%}else{%><span class="text-muted small">-</span><%}%>
            </td>
          </tr>
          <%}%>
          </tbody>
          </table>
        </div>
        <%}%>
      </div>

    </div>

    <!-- 우측: 빠른이동 (280px 고정) -->
    <div style="width:280px;flex-shrink:0">
      <!-- 빠른이동 -->
      <div class="borderless-card">
        <h2 class="fw-bold fs-5 m-0 mb-3">
          <i class="bi bi-lightning-fill me-2"></i>빠른 이동
        </h2>
        <div style="display:grid;grid-template-columns:repeat(2, 1fr);gap:8px">
          <a href="/CAN/search.jsp" style="display:flex;flex-direction:column;align-items:center;gap:6px;background:var(--sky-bg);border:1.5px solid #7dd3fc;border-radius:var(--radius-lg);padding:8px 10px;text-decoration:none;color:var(--sky-primary);font-weight:600;font-size:0.75rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center">
            <i class="bi bi-search" style="font-size:18px"></i><span style="line-height:1.2">검색</span>
          </a>
          <a href="/CAN/asset_manage.jsp" style="display:flex;flex-direction:column;align-items:center;gap:6px;background:#f0fdf4;border:1.5px solid #86efac;border-radius:var(--radius-lg);padding:8px 10px;text-decoration:none;color:#16a34a;font-weight:600;font-size:0.75rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center">
            <i class="bi bi-pencil-square" style="font-size:18px"></i><span style="line-height:1.2">자원</span>
          </a>
          <a href="/CAN/transfer.jsp" style="display:flex;flex-direction:column;align-items:center;gap:6px;background:#f5f3ff;border:1.5px solid #d8b4fe;border-radius:var(--radius-lg);padding:8px 10px;text-decoration:none;color:#7c3aed;font-weight:600;font-size:0.75rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center">
            <i class="bi bi-arrow-left-right" style="font-size:18px"></i><span style="line-height:1.2">이관</span>
          </a>
          <a href="/CAN/professor.jsp" style="display:flex;flex-direction:column;align-items:center;gap:6px;background:#fffbeb;border:1.5px solid #fde68a;border-radius:var(--radius-lg);padding:8px 10px;text-decoration:none;color:#d97706;font-weight:600;font-size:0.75rem;transition:all 0.2s;height:auto;justify-content:center;text-align:center">
            <i class="bi bi-people" style="font-size:18px"></i><span style="line-height:1.2">교수</span>
          </a>
        </div>
      </div>

      <!-- 운영 현황 -->
      <div class="borderless-card">
        <h2 class="fw-bold fs-5 m-0 mb-3">
          <i class="bi bi-clipboard-data me-2"></i>운영 현황
        </h2>
        <ul style="list-style:none;padding:0;margin:0">
          <li style="display:flex;justify-content:space-between;padding:12px 0;border-bottom:1px solid #f1f5f9;font-size:0.95rem">
            <span style="color:var(--txt-sub)">전체 자산</span>
            <span style="font-weight:700;font-family:var(--font-mono)"><%= String.format("%,d",tA) %>건</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:12px 0;border-bottom:1px solid #f1f5f9;font-size:0.95rem">
            <span style="color:var(--txt-sub)">이관 이력</span>
            <span style="font-weight:700;font-family:var(--font-mono)"><%= String.format("%,d",tT) %>건</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:12px 0;border-bottom:1px solid #f1f5f9;font-size:0.95rem">
            <span style="color:var(--txt-sub)">폐기 처리</span>
            <span style="font-weight:700;font-family:var(--font-mono)"><%= String.format("%,d",tD) %>건</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:12px 0;font-size:0.95rem">
            <span style="color:var(--txt-sub)">전체 예약</span>
            <span style="font-weight:700;font-family:var(--font-mono)"><%= String.format("%,d",tR) %>건</span>
          </li>
        </ul>
      </div>
    </div>
  </div>

</main>

<!-- FOOTER -->
<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold text-dark mb-1">
          <i class="bi bi-compass-fill me-1 text-info"></i> ICT CAN Navigation System
        </div>
        <div>ICT폴리텍대학 교내 자원 내비게이션 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="text-dark fw-bold">Made by AI 소프트웨어학과</div>
        <div>박승순 · 권동해 · 원태연 · 이수혁</div>
        <div class="mt-1 opacity-75">&copy; 2026 ICT CAN. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
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

// Initialize theme on page load
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
