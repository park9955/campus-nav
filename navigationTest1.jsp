<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%!
    private String esc(String s) {
        if (s == null) return "";
        return s.replace("&","&amp;").replace("<","&lt;").replace(">","&gt;")
                .replace("\"","&quot;").replace("'","&#39;");
    }
    private String nvl(String s) { return s == null ? "" : s; }
%>
<%
    /* ── 세션 확인 ── */
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
    boolean isAdmin = "admin".equals(loginRole);

    /* ── URL 파라미터 (detail.jsp → 길찾기 연동) ──
       destBuilding: 강의실이 속한 건물명 (예: 1공학관)
       destName:     강의실명 (예: 1205호)
       roomId:       rooms 테이블 ID (실내 경로 공유용)
    */
    String paramDestBuilding = nvl(request.getParameter("destBuilding"));
    String paramDestName     = nvl(request.getParameter("destName"));
    String paramRoomId       = nvl(request.getParameter("roomId"));
    if (!paramDestBuilding.isEmpty()) {
        try { paramDestBuilding = java.net.URLDecoder.decode(paramDestBuilding, "UTF-8"); } catch(Exception e2){}
    }
    if (!paramDestName.isEmpty()) {
        try { paramDestName = java.net.URLDecoder.decode(paramDestName, "UTF-8"); } catch(Exception e2){}
    }

    /* ── DB: 출입구 목록 조회 (is_active=1만) ── */
    List<Map<String,String>> entrances = new ArrayList<>();
    String dbErr = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root", "1234"
        );
        PreparedStatement ps = conn.prepareStatement(
            "SELECT entrance_id, entrance_name, building, floor, description, " +
            "IFNULL(image_url,'') AS image_url, " +
            "IFNULL(pixel_x,0) AS pixel_x, IFNULL(pixel_y,0) AS pixel_y " +
            "FROM campus_entrances WHERE is_active=1 ORDER BY building, entrance_name"
        );
        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,String> e = new LinkedHashMap<>();
            e.put("id",       nvl(rs.getString("entrance_id")));
            e.put("name",     nvl(rs.getString("entrance_name")));
            e.put("building", nvl(rs.getString("building")));
            e.put("floor",    nvl(rs.getString("floor")));
            e.put("desc",     nvl(rs.getString("description")));
            e.put("img",      nvl(rs.getString("image_url")));
            e.put("px",       nvl(rs.getString("pixel_x")));
            e.put("py",       nvl(rs.getString("pixel_y")));
            entrances.add(e);
        }
        rs.close(); ps.close(); conn.close();
    } catch (Exception ex) {
        dbErr = ex.getMessage();
    }

    /* 건물별 그룹핑 */
    Map<String, List<Map<String,String>>> grouped = new LinkedHashMap<>();
    for (Map<String,String> ent : entrances) {
        String b = ent.get("building").isEmpty() ? "기타" : ent.get("building");
        grouped.computeIfAbsent(b, k -> new ArrayList<>()).add(ent);
    }

    /* detail.jsp 연동: destBuilding과 일치하는 출입구 ID 찾기 */
    String autoDestEntranceId = "";
    if (!paramDestBuilding.isEmpty()) {
        for (Map<String,String> ent : entrances) {
            if (paramDestBuilding.equals(ent.get("building"))) {
                autoDestEntranceId = ent.get("id");
                break;
            }
        }
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICT CampusNav — 길 안내</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>
:root {
  --white:#fff; --bg:#f7f8fa; --bg2:#f0f2f5;
  --line:#e4e7ed; --line2:#d0d5df;
  --txt:#111827; --txt2:#4b5563; --txt3:#9ca3af;
  --blue:#1a56db; --blue-lt:#eff4ff; --blue-md:#c7d7fd; --blue-dk:#1340a8;
  --teal:#0d9488; --teal-lt:#f0fdfa; --teal-md:#99f6e4;
  --amber:#d97706; --amber-lt:#fffbeb;
  --red:#dc2626; --red-lt:#fef2f2;
  --green:#16a34a; --green-lt:#f0fdf4;
  --mono:'DM Mono',monospace;
  --sans:'DM Sans','Noto Sans KR',sans-serif;
  --r:12px; --r2:20px;
  --shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.04);
  --shadow2:0 2px 8px rgba(0,0,0,.08),0 12px 32px rgba(0,0,0,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:15px;line-height:1.65;}

/* TOPNAV */
.topnav{display:flex;align-items:center;justify-content:space-between;padding:14px 28px;background:var(--white);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:300;box-shadow:0 1px 4px rgba(0,0,0,.04);}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;color:var(--txt);letter-spacing:-.02em;text-decoration:none;}
.logo-dot{width:32px;height:32px;border-radius:8px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.logo-dot img{width:100%;height:100%;object-fit:contain;}
.logo em{color:var(--blue);font-style:normal;}
.nav-right{display:flex;gap:8px;align-items:center;}
.chip{font-family:var(--mono);font-size:12px;padding:6px 14px;border-radius:999px;background:var(--white);border:1px solid var(--line);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-flex;align-items:center;gap:5px;}
.chip:hover{border-color:var(--blue);color:var(--blue);}
.role-chip{font-family:var(--mono);font-size:12px;padding:5px 13px;border-radius:6px;background:var(--blue-lt);border:1px solid var(--blue-md);color:var(--blue);}
.role-chip.admin{background:#fef3c7;border-color:#fcd34d;color:#92400e;}

/* LAYOUT */
.shell{max-width:1400px;margin:0 auto;padding:24px;}
.page-title{font-size:1.4rem;font-weight:800;letter-spacing:-.03em;display:flex;align-items:center;gap:10px;margin-bottom:4px;}
.page-title .icon-box{width:36px;height:36px;border-radius:10px;background:var(--blue-lt);color:var(--blue);display:flex;align-items:center;justify-content:center;font-size:17px;}
.page-sub{color:var(--txt3);font-size:13px;margin-bottom:20px;padding-left:46px;}

/* CARD */
.card{background:var(--white);border-radius:var(--r2);border:1px solid var(--line);box-shadow:var(--shadow);overflow:hidden;}
.card-head{display:flex;align-items:center;gap:11px;padding:15px 20px;border-bottom:1px solid var(--line);}
.ch-icon{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;}
.si-blue{background:var(--blue-lt);color:var(--blue);}
.si-teal{background:var(--teal-lt);color:var(--teal);}
.si-green{background:var(--green-lt);color:var(--green);}
.si-amber{background:var(--amber-lt);color:var(--amber);}
.si-red{background:var(--red-lt);color:var(--red);}
.ch-title{font-weight:700;font-size:14px;}
.ch-sub{font-size:11px;color:var(--txt3);margin-top:1px;}
.card-body{padding:16px 20px;}

/* FORM */
.f-label{font-size:12px;font-weight:600;color:var(--txt2);margin-bottom:5px;display:block;}
.f-select{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);font-size:13px;padding:8px 12px;background:var(--bg);color:var(--txt);font-family:var(--sans);transition:border-color .15s;}
.f-select:focus{border-color:var(--blue);box-shadow:0 0 0 3px rgba(26,86,219,.1);outline:none;background:var(--white);}

/* BUTTONS */
.btn-prim{background:var(--blue);color:#fff;border:none;border-radius:var(--r);padding:10px 16px;font-size:13px;font-weight:600;cursor:pointer;width:100%;display:flex;align-items:center;justify-content:center;gap:6px;font-family:var(--sans);transition:background .15s;}
.btn-prim:hover{background:var(--blue-dk);}
.btn-prim:disabled{background:#93c5fd;cursor:not-allowed;}
.btn-ghost{background:transparent;color:var(--txt2);border:1.5px solid var(--line2);border-radius:var(--r);padding:9px 14px;font-size:13px;font-weight:500;cursor:pointer;width:100%;display:flex;align-items:center;justify-content:center;gap:6px;font-family:var(--sans);transition:all .15s;}
.btn-ghost:hover{border-color:var(--blue);color:var(--blue);}
.btn-ghost.danger{color:var(--red);border-color:#fca5a5;}
.btn-ghost.danger:hover{background:var(--red);color:#fff;border-color:var(--red);}
.btn-sm{padding:4px 10px;font-size:11px;border-radius:7px;border:none;cursor:pointer;font-weight:600;font-family:var(--sans);display:inline-flex;align-items:center;gap:3px;}
.btn-sm-blue{background:var(--blue);color:#fff;}
.btn-sm-blue:hover{background:var(--blue-dk);}
.btn-sm-red{background:var(--red-lt);color:var(--red);border:1.5px solid #fca5a5;}
.btn-sm-red:hover{background:var(--red);color:#fff;}

/* 관리자 배너 */
.admin-banner{background:linear-gradient(135deg,#fef3c7,#fffbeb);border:1.5px solid #fcd34d;border-radius:var(--r);padding:10px 13px;display:flex;align-items:center;gap:9px;margin-bottom:13px;font-size:12px;color:#92400e;}
.admin-banner i{font-size:16px;color:#d97706;flex-shrink:0;}

/* 출발/목적지 선택 카드 상태 */
.loc-card{border:2px solid var(--line);border-radius:var(--r);padding:11px 13px;cursor:pointer;transition:all .15s;display:flex;align-items:center;gap:10px;margin-bottom:7px;}
.loc-card:hover{border-color:var(--blue);background:var(--blue-lt);}
.loc-card.selected-origin{border-color:var(--green);background:var(--green-lt);}
.loc-card.selected-dest{border-color:var(--red);background:var(--red-lt);}
.loc-card-dot{width:14px;height:14px;border-radius:50%;flex-shrink:0;}
.loc-card-dot.origin{background:var(--green);}
.loc-card-dot.dest{background:var(--red);}
.loc-card-dot.none{background:var(--line2);}
.loc-card-name{font-size:13px;font-weight:600;flex:1;}
.loc-card-bldg{font-size:11px;color:var(--txt3);font-family:var(--mono);}

/* 사진 영역 */
.photo-wrap{border-radius:var(--r);overflow:hidden;border:1px solid var(--line);background:var(--bg2);display:none;}
.photo-wrap.show{display:block;}
.photo-wrap img{width:100%;height:130px;object-fit:cover;display:block;}
.photo-no{height:70px;display:flex;align-items:center;justify-content:center;gap:6px;color:var(--txt3);font-size:12px;}
.photo-caption{padding:6px 11px;font-size:11px;color:var(--txt2);background:var(--white);border-top:1px solid var(--line);display:flex;align-items:center;gap:5px;}
.photo-caption .dot{width:8px;height:8px;border-radius:50%;flex-shrink:0;}

/* 결과박스 */
.result-box{background:var(--bg2);border-radius:var(--r);padding:11px 13px;font-size:12px;color:var(--txt2);font-family:var(--mono);border:1px solid var(--line);min-height:56px;line-height:1.7;white-space:pre-line;}

/* 구분선 */
.divider{border:none;border-top:1px solid var(--line);margin:12px 0;}

/* 평면도 */
.floorplan-wrap{position:relative;width:100%;background:#0f172a;border-radius:14px;overflow:hidden;border:1px solid var(--line);user-select:none;}
#floorplanImg{width:100%;height:560px;object-fit:contain;display:block;}
#routeCanvas{position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;}
#markerCanvas{position:absolute;top:0;left:0;width:100%;height:100%;cursor:default;}
#markerCanvas.mode-pin{cursor:crosshair;}
#markerCanvas.mode-add{cursor:crosshair;}

/* 툴바 */
.map-toolbar{position:absolute;top:10px;left:10px;z-index:10;display:flex;gap:5px;flex-wrap:wrap;}
.tb-btn{background:rgba(255,255,255,.93);border:1.5px solid var(--line);border-radius:8px;padding:5px 11px;font-size:12px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:5px;color:var(--txt);transition:all .15s;font-family:var(--sans);}
.tb-btn:hover{background:#fff;border-color:var(--blue);color:var(--blue);}
.tb-btn.active{background:var(--blue);color:#fff;border-color:var(--blue);}
.tb-btn.tb-amber{background:rgba(255,251,235,.95);color:var(--amber);border-color:#fde68a;}
.tb-btn.tb-amber.active{background:var(--amber);color:#fff;border-color:var(--amber);}

/* 평면도 오버레이 (안내 메시지) */
.map-overlay{position:absolute;bottom:12px;left:50%;transform:translateX(-50%);z-index:20;background:rgba(255,255,255,.95);border-radius:10px;padding:8px 16px;box-shadow:var(--shadow2);display:none;align-items:center;gap:10px;font-size:12px;white-space:nowrap;}
.map-overlay.show{display:flex;}
.ov-badge{border-radius:6px;padding:3px 9px;font-size:11px;font-weight:700;color:#fff;}
.ov-badge.blue{background:var(--blue);}
.ov-badge.green{background:var(--green);}

/* 툴팁 */
.map-tooltip{position:absolute;background:rgba(15,23,42,.82);color:#fff;padding:4px 9px;border-radius:6px;font-size:11px;pointer-events:none;z-index:50;white-space:nowrap;display:none;}

/* 경유점 목록 */
.wp-list{display:flex;flex-direction:column;gap:3px;margin-top:7px;}
.wp-item{display:flex;align-items:center;gap:7px;background:var(--bg);border:1px solid var(--line);border-radius:7px;padding:5px 9px;}
.wp-num{width:18px;height:18px;border-radius:50%;background:var(--blue);color:#fff;font-size:9px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;}
.wp-coord{flex:1;font-family:var(--mono);font-size:10px;color:var(--txt2);}
.wp-del{width:20px;height:20px;border-radius:4px;border:none;background:transparent;color:var(--txt3);cursor:pointer;font-size:12px;display:flex;align-items:center;justify-content:center;}
.wp-del:hover{background:var(--red-lt);color:var(--red);}
.wp-empty{font-size:12px;color:var(--txt3);font-family:var(--mono);padding:3px 0;}

/* 저장된 경로 목록 */
.route-item{border:1px solid var(--line);border-radius:var(--r);padding:10px 12px;margin-bottom:6px;background:var(--bg);display:flex;align-items:center;justify-content:space-between;gap:8px;}
.route-item-name{font-size:12px;font-weight:600;color:var(--txt);}
.route-item-meta{font-size:10px;color:var(--txt3);font-family:var(--mono);margin-top:1px;}

/* DB 오류 */
.alert-err{background:var(--red-lt);border:1px solid #fca5a5;border-radius:var(--r);padding:10px 14px;color:var(--red);font-size:13px;margin-bottom:16px;display:flex;align-items:flex-start;gap:8px;}

/* 아코디언 */
.loc-card-header{width:100%;display:flex;align-items:center;justify-content:space-between;padding:14px 20px;background:var(--white);border:none;cursor:pointer;border-bottom:1px solid transparent;transition:background .15s;gap:12px;}
.loc-card-header:hover{background:var(--bg);}
.loc-card-header.open{border-bottom-color:var(--line);}
.loc-chevron{color:var(--txt3);font-size:14px;transition:transform .25s;flex-shrink:0;}
.loc-chevron.open{transform:rotate(180deg);}
.building-row{border-bottom:1px solid var(--line);}
.building-row:last-child{border-bottom:none;}
.building-header{width:100%;display:flex;align-items:center;justify-content:space-between;padding:10px 20px;background:var(--white);border:none;cursor:pointer;transition:background .15s;gap:10px;}
.building-header:hover{background:var(--bg);}
.b-icon{width:26px;height:26px;border-radius:6px;background:var(--teal-lt);color:var(--teal);display:flex;align-items:center;justify-content:center;font-size:12px;flex-shrink:0;}
.b-title{font-size:13px;font-weight:700;}
.b-count{font-size:10px;color:var(--txt3);font-family:var(--mono);}
.b-chevron{color:var(--txt3);font-size:11px;transition:transform .2s;flex-shrink:0;}
.b-chevron.open{transform:rotate(90deg);}
.place-list{background:var(--bg2);border-top:1px solid var(--line);}
.place-row{display:flex;align-items:center;justify-content:space-between;gap:8px;padding:8px 16px 8px 46px;border-bottom:1px solid var(--line);transition:background .1s;}
.place-row:last-child{border-bottom:none;}
.place-row:hover{background:var(--blue-lt);}
.place-name{font-size:12px;font-weight:600;color:var(--txt);}
.place-floor{font-family:var(--mono);font-size:10px;padding:1px 5px;border-radius:4px;background:var(--blue-lt);color:var(--blue);font-weight:600;}
.place-btns{display:flex;gap:3px;flex-shrink:0;}
.place-btn{display:inline-flex;align-items:center;gap:3px;color:#fff;border:none;border-radius:5px;padding:3px 8px;font-size:11px;font-weight:600;cursor:pointer;font-family:var(--sans);}
.place-btn.blue{background:var(--blue);}
.place-btn.blue:hover{background:var(--blue-dk);}
.place-btn.teal{background:var(--teal);}
.place-btn.teal:hover{background:#0f766e;}
.place-btn.amber{background:var(--amber);}
.place-btn.amber:hover{background:#b45309;}

/* 건물 도면 모달 */
.modal-bg{position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:500;display:none;align-items:center;justify-content:center;padding:20px;}
.modal-bg.show{display:flex;}
.modal-box{background:var(--white);border-radius:18px;max-width:800px;width:100%;max-height:88vh;overflow:hidden;display:flex;flex-direction:column;box-shadow:0 8px 40px rgba(0,0,0,.22);}
.modal-hd{display:flex;align-items:center;justify-content:space-between;padding:14px 20px;border-bottom:1px solid var(--line);}
.modal-title{font-size:14px;font-weight:800;}
.modal-close{width:30px;height:30px;border-radius:7px;border:1.5px solid var(--line2);background:var(--white);cursor:pointer;display:flex;align-items:center;justify-content:center;font-size:14px;color:var(--txt2);}
.modal-close:hover{border-color:var(--red);color:var(--red);}
.modal-body{flex:1;overflow:auto;padding:16px 20px;}
.modal-body img{width:100%;border-radius:var(--r);}
.floor-placeholder{height:220px;border:2px dashed var(--line2);border-radius:var(--r);display:flex;align-items:center;justify-content:center;flex-direction:column;gap:8px;color:var(--txt3);}
.floor-placeholder i{font-size:38px;}

@media(max-width:991px){#floorplanImg{height:320px;}}
@keyframes popIn{from{opacity:0;transform:scale(.9) translateY(6px);}to{opacity:1;transform:scale(1) translateY(0);}}
</style>
</head>
<body>

<!-- TOPNAV -->
<div class="topnav">
  <a href="/CampusNav/campuslogin.jsp" class="logo">
    <div class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></div>
    <span>ICT Campus<em>Nav</em></span>
  </a>
  <div class="nav-right">
    <span style="font-size:13px;color:var(--txt2);font-family:var(--mono);"><i class="bi bi-person-circle"></i> <%= esc(loginName) %></span>
    <span class="role-chip <%= isAdmin?"admin":"" %>">
      <%= isAdmin?"관리자":"student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"게스트" %>
    </span>
    <a href="/CampusNav/main_<%= esc(loginRole) %>.jsp" class="chip"><i class="bi bi-house"></i>홈</a>
    <a href="javascript:history.back()" class="chip"><i class="bi bi-arrow-left"></i>뒤로</a>
  </div>
</div>

<!-- 건물 도면 모달 -->
<div class="modal-bg" id="floorModal" onclick="if(event.target===this)this.classList.remove('show')">
  <div class="modal-box">
    <div class="modal-hd">
      <div class="modal-title" id="floorModalTitle">건물 내부 도면</div>
      <button class="modal-close" onclick="document.getElementById('floorModal').classList.remove('show')"><i class="bi bi-x-lg"></i></button>
    </div>
    <div class="modal-body" id="floorModalBody">
      <div class="floor-placeholder"><i class="bi bi-map"></i><span>도면 준비 중</span></div>
    </div>
  </div>
</div>

<!-- MAIN -->
<div class="shell">
  <div class="page-title">
    <div class="icon-box"><i class="bi bi-signpost-2"></i></div>
    교내 길 안내
  </div>
  <div class="page-sub">
    <% if (isAdmin) { %>
    <i class="bi bi-shield-fill" style="color:#d97706;"></i> 관리자 모드 — 경로 그리기 및 출입구 위치 설정
    <% } else if (!paramDestBuilding.isEmpty()) { %>
    <i class="bi bi-geo-alt-fill" style="color:var(--blue);"></i>
    <strong style="color:var(--txt)"><%= esc(paramDestName.isEmpty()?paramDestBuilding:paramDestName) %></strong> 까지 경로를 안내합니다.
    <% } else { %>
    평면도에서 출발지와 목적지를 선택하세요.
    <% } %>
  </div>

  <% if (!dbErr.isEmpty()) { %>
  <div class="alert-err"><i class="bi bi-exclamation-triangle-fill"></i>
    <div><strong>DB 오류</strong><br><small style="font-family:var(--mono)"><%= esc(dbErr) %></small></div>
  </div>
  <% } %>

  <div class="row g-3">

    <!-- ════ 좌측 패널 ════ -->
    <div class="col-xl-4 col-lg-5">

      <% if (isAdmin) { %>
      <!-- ══ 관리자 패널 ══ -->
      <div class="admin-banner">
        <i class="bi bi-shield-fill"></i>
        <div>관리자 모드 — <strong>출입구 위치 설정</strong> 또는 <strong>경로 그리기</strong></div>
      </div>

      <!-- 탭 전환 -->
      <div style="display:flex;gap:6px;margin-bottom:12px;">
        <button class="tb-btn active" id="tabRouteBtn" onclick="switchAdminTab('route')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-pencil-fill"></i>경로 그리기
        </button>
        <button class="tb-btn tb-amber" id="tabPinBtn" onclick="switchAdminTab('pin')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-geo-fill"></i>마커 위치 설정
        </button>
      </div>

      <!-- 경로 그리기 탭 -->
      <div id="tabRoute">
        <div class="card mb-3">
          <div class="card-head">
            <div class="ch-icon si-blue"><i class="bi bi-arrow-left-right"></i></div>
            <div><div class="ch-title">출발 · 도착 출입구 설정</div><div class="ch-sub">어느 출입구 사이의 경로인지 선택하세요</div></div>
          </div>
          <div class="card-body">
            <!-- 출발 출입구 -->
            <label class="f-label"><i class="bi bi-circle-fill" style="color:var(--green);font-size:9px;"></i> 출발 출입구</label>
            <select class="f-select mb-2" id="adminFromSelect" onchange="onAdminFromChange(this)">
              <option value="">-- 출발 출입구 선택 --</option>
              <% String prevB2=""; for(Map<String,String> ent:entrances){
                   String b2=ent.get("building").isEmpty()?"기타":ent.get("building");
                   if(!b2.equals(prevB2)){if(!prevB2.isEmpty()){%></optgroup><%}%>
                   <optgroup label="<%= esc(b2) %>"><%prevB2=b2;}%>
                <option value="<%= esc(ent.get("id")) %>" data-name="<%= esc(ent.get("name")) %>">
                  <%= esc(ent.get("name")) %>
                </option>
              <%}if(!prevB2.isEmpty()){%></optgroup><%}%>
            </select>
            <!-- 도착 출입구 -->
            <label class="f-label" style="margin-top:6px;"><i class="bi bi-geo-alt-fill" style="color:var(--red);font-size:9px;"></i> 도착 출입구</label>
            <select class="f-select" id="adminToSelect" onchange="onAdminToChange(this)">
              <option value="">-- 도착 출입구 선택 --</option>
              <% String prevB2b=""; for(Map<String,String> ent:entrances){
                   String b2b=ent.get("building").isEmpty()?"기타":ent.get("building");
                   if(!b2b.equals(prevB2b)){if(!prevB2b.isEmpty()){%></optgroup><%}%>
                   <optgroup label="<%= esc(b2b) %>"><%prevB2b=b2b;}%>
                <option value="<%= esc(ent.get("id")) %>" data-name="<%= esc(ent.get("name")) %>">
                  <%= esc(ent.get("name")) %>
                </option>
              <%}if(!prevB2b.isEmpty()){%></optgroup><%}%>
            </select>
            <!-- 선택 현황 표시 -->
            <div id="adminRouteInfo" style="display:none;margin-top:10px;background:var(--blue-lt);border:1px solid var(--blue-md);border-radius:8px;padding:8px 12px;font-size:12px;color:var(--blue);display:flex;align-items:center;gap:8px;">
              <i class="bi bi-arrow-right-circle-fill"></i>
              <span id="adminRouteInfoText"></span>
            </div>
            <div class="divider"></div>
            <label class="f-label">경로 이름 <span style="font-weight:400;color:var(--txt3)">(선택)</span></label>
            <input type="text" style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);font-size:13px;padding:8px 12px;background:var(--bg);color:var(--txt);font-family:var(--sans);" id="routeNameInput" placeholder="예: 정문1번 → 1공학관">
          </div>
        </div>

        <div class="card mb-3">
          <div class="card-head">
            <div class="ch-icon si-blue"><i class="bi bi-pencil-fill"></i></div>
            <div><div class="ch-title">경로 그리기</div><div class="ch-sub">평면도를 순서대로 클릭해 이동 경로를 만드세요</div></div>
          </div>
          <div class="card-body">
            <div style="background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);margin-bottom:12px;display:flex;gap:7px;">
              <i class="bi bi-lightbulb-fill" style="flex-shrink:0;margin-top:1px;"></i>
              <span>평면도를 순서대로 클릭하면 경로가 만들어집니다.<br><strong>S</strong> = 출발점 · <strong>E</strong> = 도착점(출입구)</span>
            </div>
            <label class="f-label">찍은 경로 포인트</label>
            <div class="wp-list" id="wpList"><div class="wp-empty">아직 찍은 포인트가 없습니다</div></div>
            <div class="divider"></div>
            <div class="d-flex flex-column gap-2">
              <button class="btn-prim" onclick="saveRoute()" id="btnSave"><i class="bi bi-floppy-fill"></i>경로 저장하기</button>
              <div class="d-flex gap-2">
                <button class="btn-ghost" onclick="undoLast()" style="flex:1;font-size:12px;padding:8px;"><i class="bi bi-arrow-counterclockwise"></i>마지막 포인트 취소</button>
                <button class="btn-ghost danger" onclick="clearRoute()" style="flex:1;font-size:12px;padding:8px;"><i class="bi bi-trash3"></i>전체 초기화</button>
              </div>
            </div>
            <div class="divider"></div>
            <div class="result-box" id="resultBox">도착 출입구를 선택하고 평면도에서 경로를 그리세요.</div>
          </div>
        </div>

        <!-- 저장된 경로 목록 -->
        <div class="card mb-3">
          <div class="card-head">
            <div class="ch-icon si-green"><i class="bi bi-database-fill"></i></div>
            <div><div class="ch-title">저장된 경로 목록</div><div class="ch-sub">출발·도착 출입구를 선택하면 표시됩니다</div></div>
          </div>
          <div class="card-body" id="savedRouteList">
            <div class="wp-empty">출발·도착 출입구를 선택하면 경로 목록이 표시됩니다</div>
          </div>
        </div>
      </div>

      <!-- 위치 설정 탭 -->
      <div id="tabPin" style="display:none;">
        <div class="card mb-3">
          <div class="card-head">
            <div class="ch-icon si-amber"><i class="bi bi-geo-fill"></i></div>
            <div><div class="ch-title">출입구 위치 설정</div><div class="ch-sub">평면도에서 클릭으로 마커 위치 저장</div></div>
          </div>
          <div class="card-body">
            <div style="background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);margin-bottom:12px;display:flex;gap:7px;">
              <i class="bi bi-lightbulb-fill" style="flex-shrink:0;margin-top:1px;"></i>
              <span>출입구를 선택한 뒤 평면도에서 해당 출입구 위치를 클릭하세요.<br>✓ 표시는 이미 위치가 등록된 출입구입니다.</span>
            </div>
            <label class="f-label">위치 설정할 출입구</label>
            <select class="f-select" id="pinEntranceSelect" onchange="onPinEntranceChange(this)">
              <option value="">-- 출입구 선택 --</option>
              <% String prevBP=""; for(Map<String,String> ent:entrances){
                   String bP=ent.get("building").isEmpty()?"기타":ent.get("building");
                   if(!bP.equals(prevBP)){if(!prevBP.isEmpty()){%></optgroup><%}%>
                   <optgroup label="<%= esc(bP) %>"><%prevBP=bP;}
                   boolean hasPx = !ent.get("px").equals("0") && !ent.get("px").isEmpty();%>
                <option value="<%= esc(ent.get("id")) %>" data-name="<%= esc(ent.get("name")) %>">
                  <%= esc(ent.get("name")) %><%= hasPx?" ✓":"" %>
                </option>
              <%}if(!prevBP.isEmpty()){%></optgroup><%}%>
            </select>
            <div id="pinTargetInfo" style="display:none;margin-top:9px;background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);display:none;align-items:center;gap:7px;">
              <i class="bi bi-cursor-fill"></i>
              <span><strong id="pinTargetName"></strong> — 평면도를 클릭하세요</span>
            </div>
          </div>
        </div>
      </div>

      <% } else { %>
      <!-- ══ 학생/일반 패널 ══ -->

      <!-- 출발지 -->
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-green"><i class="bi bi-circle-fill"></i></div>
          <div><div class="ch-title">출발지</div><div class="ch-sub">평면도의 마커를 클릭하거나 목록에서 선택</div></div>
        </div>
        <div class="card-body">
          <select class="f-select" id="originSelect" onchange="onOriginSelectChange(this)">
            <option value="">-- 출발 출입구 선택 --</option>
            <% String prevBO=""; for(Map<String,String> ent:entrances){
                 String bO=ent.get("building").isEmpty()?"기타":ent.get("building");
                 if(!bO.equals(prevBO)){if(!prevBO.isEmpty()){%></optgroup><%}%>
                 <optgroup label="<%= esc(bO) %>"><%prevBO=bO;}%>
              <option value="<%= esc(ent.get("id")) %>"
                      data-name="<%= esc(ent.get("name")) %>"
                      data-building="<%= esc(ent.get("building")) %>"
                      data-img="<%= esc(ent.get("img")) %>">
                <%= esc(ent.get("name")) %>
              </option>
            <%}if(!prevBO.isEmpty()){%></optgroup><%}%>
          </select>
        </div>
      </div>

      <!-- 목적지 -->
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-red"><i class="bi bi-geo-alt-fill"></i></div>
          <div><div class="ch-title">목적지</div><div class="ch-sub">평면도의 마커를 클릭하거나 목록에서 선택</div></div>
        </div>
        <div class="card-body">

          <% if (!paramDestBuilding.isEmpty()) { %>
          <!-- detail.jsp에서 넘어온 자동 목적지 배너 -->
          <div style="background:linear-gradient(135deg,var(--blue-lt),var(--teal-lt));border:1.5px solid var(--blue-md);border-radius:var(--r);padding:10px 12px;margin-bottom:10px;display:flex;align-items:center;gap:9px;">
            <div style="width:32px;height:32px;border-radius:8px;background:var(--blue);color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;"><i class="bi bi-bullseye"></i></div>
            <div style="flex:1;min-width:0;">
              <div style="font-size:10px;font-family:var(--mono);color:var(--blue);font-weight:600;text-transform:uppercase;">자동 설정 목적지</div>
              <div style="font-size:13px;font-weight:700;color:var(--txt);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%= esc(paramDestName.isEmpty()?paramDestBuilding:paramDestName) %></div>
              <div style="font-size:11px;color:var(--txt3);"><%= esc(paramDestBuilding) %> 출입구로 안내</div>
            </div>
          </div>
          <% } %>

          <select class="f-select" id="destSelect" onchange="onDestSelectChange(this)">
            <option value="">-- 목적지 출입구 선택 --</option>
            <% String prevBD=""; for(Map<String,String> ent:entrances){
                 String bD=ent.get("building").isEmpty()?"기타":ent.get("building");
                 if(!bD.equals(prevBD)){if(!prevBD.isEmpty()){%></optgroup><%}%>
                 <optgroup label="<%= esc(bD) %>"><%prevBD=bD;}%>
              <option value="<%= esc(ent.get("id")) %>"
                      data-name="<%= esc(ent.get("name")) %>"
                      data-building="<%= esc(ent.get("building")) %>"
                      data-img="<%= esc(ent.get("img")) %>">
                <%= esc(ent.get("name")) %>
              </option>
            <%}if(!prevBD.isEmpty()){%></optgroup><%}%>
          </select>

          <div class="divider"></div>
          <div class="d-flex flex-column gap-2">
            <button class="btn-prim" onclick="loadRoute()" id="btnLoad">
              <i class="bi bi-play-circle-fill"></i>경로 안내 시작
            </button>
            <button class="btn-ghost" id="btnArrived" onclick="goToFloorNav()"
                    style="display:none;border-color:var(--teal);color:var(--teal);">
              <i class="bi bi-building-check"></i>출입구 도착 — 실내 안내 보기
            </button>
          </div>
          <div class="divider"></div>
          <div class="result-box" id="resultBox">출발지와 목적지를 선택하세요.</div>
        </div>
      </div>

      <% } %>
    </div><!-- /좌측 -->

    <!-- ════ 우측 — 평면도 ════ -->
    <div class="col-xl-8 col-lg-7">
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-map-fill"></i></div>
          <div>
            <div class="ch-title">캠퍼스 평면도</div>
            <div class="ch-sub">
              <% if (isAdmin) { %>출입구 마커 클릭 또는 평면도 클릭으로 경유점 추가
              <% } else { %>원형 마커를 클릭해 출발지/목적지를 선택하세요<% } %>
            </div>
          </div>
        </div>
        <div class="card-body" style="padding-bottom:0;">
          <div class="floorplan-wrap" id="floorplanWrap">
            <img id="floorplanImg" src="/CampusNav/images/ictlayout.png" alt="캠퍼스 평면도" onerror="this.style.display='none';">
            <% if (isAdmin) { %>
            <div class="map-toolbar">
              <button class="tb-btn active" id="btnModeAdd" onclick="setMode('add')"><i class="bi bi-plus-circle"></i>경로 찍기</button>
              <button class="tb-btn tb-amber" id="btnModePin" onclick="setMode('pin')"><i class="bi bi-geo-fill"></i>마커 위치 설정</button>
              <button class="tb-btn" id="btnModeView" onclick="setMode('view')"><i class="bi bi-hand-index"></i>보기</button>
            </div>
            <% } %>
            <!-- 경로 그리기 캔버스 (pointer-events:none) -->
            <canvas id="routeCanvas"></canvas>
            <!-- 마커/클릭 캔버스 -->
            <canvas id="markerCanvas"></canvas>
            <div class="map-tooltip" id="mapTooltip"></div>
            <div class="map-overlay" id="mapOverlay">
              <span class="ov-badge blue" id="ovBadge">대기 중</span>
              <span id="ovText">출발지와 목적지를 선택하세요</span>
            </div>
          </div>
        </div>
      </div>

      <!-- 등록된 위치 목록 -->
      <% if (!entrances.isEmpty()) { %>
      <div class="card">
        <button class="loc-card-header" onclick="toggleLocList(this)">
          <div style="display:flex;align-items:center;gap:11px;">
            <div class="ch-icon si-green" style="flex-shrink:0;"><i class="bi bi-door-open"></i></div>
            <div style="text-align:left;">
              <div class="ch-title">출입구 목록</div>
              <div class="ch-sub">총 <%= entrances.size() %>개 출입구 · 클릭하여 펼치기</div>
            </div>
          </div>
          <i class="bi bi-chevron-down loc-chevron"></i>
        </button>
        <div id="locListBody" style="display:none;">
          <% int bIdx=0;
             for(Map.Entry<String,List<Map<String,String>>> entry:grouped.entrySet()){
               String bName=entry.getKey();
               List<Map<String,String>> bList=entry.getValue(); %>
          <div class="building-row">
            <button class="building-header" onclick="toggleBuilding(<%= bIdx %>,this)">
              <div style="display:flex;align-items:center;gap:8px;">
                <div class="b-icon"><i class="bi bi-buildings"></i></div>
                <div style="text-align:left;">
                  <div class="b-title"><%= esc(bName) %></div>
                  <div class="b-count"><%= bList.size() %>개</div>
                </div>
              </div>
              <i class="bi bi-chevron-right b-chevron"></i>
            </button>
            <div class="place-list" id="places-<%= bIdx %>" style="display:none;">
              <% for(Map<String,String> ent:bList){ %>
              <div class="place-row">
                <div style="flex:1;min-width:0;">
                  <div class="place-name"><%= esc(ent.get("name")) %></div>
                </div>
                <div class="place-btns" onclick="event.stopPropagation()">
                  <% if (isAdmin) { %>
                  <button class="place-btn amber" onclick="selectPinTarget('<%= esc(ent.get("id")) %>','<%= esc(ent.get("name")) %>')"><i class="bi bi-geo-fill"></i>위치설정</button>
                  <button class="place-btn blue" onclick="selectAdminEntrance('<%= esc(ent.get("id")) %>','<%= esc(ent.get("name")) %>')"><i class="bi bi-pencil"></i>경로대상</button>
                  <% } else { %>
                  <button class="place-btn" style="background:var(--green);" onclick="setOriginFromList('<%= esc(ent.get("id")) %>','<%= esc(ent.get("name")) %>','<%= esc(ent.get("img")) %>')"><i class="bi bi-circle-fill"></i>출발</button>
                  <button class="place-btn blue" onclick="setDestFromList('<%= esc(ent.get("id")) %>','<%= esc(ent.get("name")) %>','<%= esc(ent.get("img")) %>')"><i class="bi bi-geo-alt-fill"></i>도착</button>
                  <% } %>
                </div>
              </div>
              <% } %>
            </div>
          </div>
          <% bIdx++; } %>
        </div>
      </div>
      <% } %>
    </div><!-- /우측 -->
  </div><!-- /row -->
</div><!-- /shell -->

<script>
const IS_ADMIN = <%= isAdmin %>;
const routeCanvas  = document.getElementById('routeCanvas');
const markerCanvas = document.getElementById('markerCanvas');
const rCtx = routeCanvas.getContext('2d');
const mCtx = markerCanvas.getContext('2d');
const wrap = document.getElementById('floorplanWrap');
const img  = document.getElementById('floorplanImg');

let waypoints         = [];  // 관리자: 경로 경유점
let loadedRoutePoints = [];  // 학생: 불러온 경로
let mode              = IS_ADMIN ? 'add' : 'view';
let adminFromId       = '';  // 관리자: 출발 출입구
let adminToId         = '';  // 관리자: 도착 출입구
let pinTargetId       = '';  // 관리자: 마커 위치 설정 대상
let originId          = '';  // 학생: 출발지 ID
let destId            = '';  // 학생: 목적지 ID

/* 출입구 데이터 */
const entranceData = [
    <% for(int i=0;i<entrances.size();i++){
        Map<String,String> ent=entrances.get(i);
        String pxv=ent.get("px"); String pyv=ent.get("py");
        boolean hasPx=pxv!=null&&!pxv.equals("0")&&!pxv.isEmpty();
        boolean hasPy=pyv!=null&&!pyv.equals("0")&&!pyv.isEmpty();
    %>
    {id:'<%= esc(ent.get("id")) %>',name:'<%= esc(ent.get("name")) %>',
     building:'<%= esc(ent.get("building")) %>',img:'<%= esc(ent.get("img")) %>',
     px:<%= hasPx?pxv:"null" %>,py:<%= hasPy?pyv:"null" %>}<%= i<entrances.size()-1?",":"" %>
    <% } %>
];

/* ── Canvas 크기 맞추기 ── */
function resizeCanvas() {
    const w = wrap.offsetWidth;
    const h = wrap.offsetHeight;
    routeCanvas.width  = markerCanvas.width  = w;
    routeCanvas.height = markerCanvas.height = h;
    redrawRoute();
}
img.addEventListener('load', resizeCanvas);
window.addEventListener('resize', resizeCanvas);
if (img.complete) setTimeout(resizeCanvas, 150);

/* ── 모드 전환 ── */
function setMode(m) {
    mode = m;
    markerCanvas.className = m === 'view' ? '' : 'mode-' + m;
    if (IS_ADMIN) {
        document.getElementById('btnModeAdd').classList.toggle('active',  m==='add');
        document.getElementById('btnModePin').classList.toggle('active',  m==='pin');
        document.getElementById('btnModeView').classList.toggle('active', m==='view');
    }
    const tip = document.getElementById('mapTooltip');
    if (tip) tip.style.display = 'none';
}

/* ── 관리자 탭 전환 ── */
function switchAdminTab(tab) {
    document.getElementById('tabRoute').style.display = tab==='route' ? 'block' : 'none';
    document.getElementById('tabPin').style.display   = tab==='pin'   ? 'block' : 'none';
    document.getElementById('tabRouteBtn').classList.toggle('active', tab==='route');
    document.getElementById('tabPinBtn').classList.toggle('active',   tab==='pin');
    if (tab==='pin') setMode('pin'); else setMode('add');
}

/* ════════════════════════════
   원형 마커 그리기 (markerCanvas)
════════════════════════════ */
const MARKER_R     = 20;  // 글로우 외곽 반경 (감지용)
const MARKER_HIT_R = 20;
const MARKER_HIT_ADD = 8; // 경로 찍기 모드 - 중앙 원(8px) 이내만
let animFrameId = null;

/* ════════════════════════════
   원형 마커 그리기 - animateMarkers 루프 내부에서 처리
   (아래 drawMarkers는 외부 호출용 stub)
════════════════════════════ */
function drawMarkers() { /* animateMarkers 루프가 처리 */ }

/* 마커 애니메이션 루프 */
function animateMarkers() {
    mCtx.clearRect(0, 0, markerCanvas.width, markerCanvas.height);
    entranceData.forEach(function(ent) {
        if (ent.px === null || ent.py === null) return;
        const x = ent.px, y = ent.py;
        const isOrigin = ent.id === originId;
        const isDest   = ent.id === destId;
        const isPinTgt = ent.id === pinTargetId;
        const c = isOrigin ? '22,163,74' : isDest ? '220,38,38' : isPinTgt ? '217,119,6' : '26,86,219';

        /* 외곽 글로우 */
        mCtx.beginPath(); mCtx.arc(x, y, 20, 0, Math.PI*2);
        mCtx.fillStyle = 'rgba(' + c + ',0.15)'; mCtx.fill();

        /* 중간 링 */
        mCtx.beginPath(); mCtx.arc(x, y, 13, 0, Math.PI*2);
        mCtx.fillStyle = 'rgba(' + c + ',0.35)'; mCtx.fill();

        /* 중앙 원 */
        mCtx.beginPath(); mCtx.arc(x, y, 8, 0, Math.PI*2);
        mCtx.fillStyle = 'rgb(' + c + ')'; mCtx.fill();

        /* 흰 점 */
        mCtx.beginPath(); mCtx.arc(x, y, 3, 0, Math.PI*2);
        mCtx.fillStyle = '#fff'; mCtx.fill();

        /* 이름 레이블 */
        const label = ent.name.replace(' 출입구','').replace('출입구','');
        mCtx.font = 'bold 10px "Noto Sans KR", sans-serif';
        mCtx.textAlign = 'center'; mCtx.textBaseline = 'bottom';
        const tw = mCtx.measureText(label).width;
        mCtx.fillStyle = 'rgba(0,0,0,.65)';
        mCtx.beginPath();
        mCtx.roundRect(x - tw/2 - 3, y - 24, tw + 6, 16, 3);
        mCtx.fill();
        mCtx.fillStyle = '#fff';
        mCtx.fillText(label, x, y - 10);
    });
    animFrameId = requestAnimationFrame(animateMarkers);
}
setTimeout(function() { animateMarkers(); }, 200);

/* ── markerCanvas 클릭 ── */
markerCanvas.addEventListener('click', function(e) {
    const rect = markerCanvas.getBoundingClientRect();
    const dpr  = window.devicePixelRatio || 1;
    const x = (e.clientX - rect.left);
    const y = (e.clientY - rect.top);

    /* 마커 위에 클릭했는지 확인 - add 모드에서는 감지 영역 좁게 */
    const hitR = (IS_ADMIN && mode === 'add') ? MARKER_HIT_ADD : MARKER_HIT_R;
    let clicked = null;
    for (let i = entranceData.length-1; i >= 0; i--) {
        const ent = entranceData[i];
        if (ent.px === null || ent.py === null) continue;
        const dx = x - ent.px, dy = y - ent.py;
        if (Math.sqrt(dx*dx + dy*dy) <= hitR) { clicked = ent; break; }
    }

    if (IS_ADMIN) {
        if (mode === 'pin') {
            if (clicked) {
                pinTargetId = clicked.id;
                document.getElementById('pinTargetName').textContent = clicked.name;
                document.getElementById('pinTargetInfo').style.display = 'flex';
                syncPinSelect(clicked.id);
            } else {
                if (!pinTargetId) { alert('마커 위치를 설정할 출입구를 먼저 선택하세요.'); return; }
                /* CSS 좌표 기준으로 저장 */
                savePinCoord(pinTargetId, x, y);
            }
        } else if (mode === 'add') {
            if (clicked) {
                /* 마커 클릭: 출발 미설정이면 출발로, 설정됐으면 도착으로 */
                if (!adminFromId) {
                    adminFromId = clicked.id;
                    syncAdminFromSelect(clicked.id);
                    updateAdminRouteInfo();
                } else if (!adminToId && clicked.id !== adminFromId) {
                    adminToId = clicked.id;
                    syncAdminToSelect(clicked.id);
                    updateAdminRouteInfo();
                    loadSavedRoutes();
                }
            } else {
                /* 빈 곳 클릭 → 경로 포인트 추가 (CSS 좌표 기준) */
                waypoints.push({x, y});
                updateWpList();
                redrawRoute();
                updateOverlay();
            }
        }
    } else {
        /* 학생: 마커 클릭 → 사진 팝업 표시 + 출발/목적지 설정 */
        if (!clicked) return;
        showMarkerPhotoPopup(clicked, x, y);
    }
});

/* 마우스 오버 */
markerCanvas.addEventListener('mousemove', function(e) {
    const rect = markerCanvas.getBoundingClientRect();
    const x = (e.clientX - rect.left);
    const y = (e.clientY - rect.top);
    const tip = document.getElementById('mapTooltip');

    let hovered = null;
    const hitR2 = (IS_ADMIN && mode === 'add') ? MARKER_HIT_ADD : MARKER_HIT_R;
    for (let i = entranceData.length-1; i >= 0; i--) {
        const ent = entranceData[i];
        if (ent.px===null||ent.py===null) continue;
        const dx=x-ent.px, dy=y-ent.py;
        if (Math.sqrt(dx*dx+dy*dy) <= hitR2) { hovered=ent; break; }
    }

    if (hovered) {
        markerCanvas.style.cursor = 'pointer';
        tip.style.display = 'block';
        tip.style.left = (e.offsetX+14)+'px';
        tip.style.top  = (e.offsetY+14)+'px';
        if (IS_ADMIN) {
            if (mode==='pin') tip.textContent = hovered.name+' — 클릭하여 위치 설정 대상 선택';
            else if (!adminFromId) tip.textContent = hovered.name+' — 클릭하여 출발지로 설정';
            else if (!adminToId)  tip.textContent = hovered.name+' — 클릭하여 도착지로 설정';
            else tip.textContent = hovered.name;
        } else {
            tip.textContent = hovered.name+' — 클릭하여 사진 보기';
        }
    } else {
        markerCanvas.style.cursor = (IS_ADMIN && (mode==='add'||mode==='pin')) ? 'crosshair' : 'default';
        tip.style.display = 'none';
    }
});
markerCanvas.addEventListener('mouseleave', () => document.getElementById('mapTooltip').style.display='none');

/* ════════════════════════════
   경로 그리기 (routeCanvas)
════════════════════════════ */
function redrawRoute() {
    rCtx.clearRect(0, 0, routeCanvas.width, routeCanvas.height);
    const pts = IS_ADMIN ? waypoints : loadedRoutePoints;
    if (pts.length < 1) return;

    rCtx.beginPath();
    rCtx.moveTo(pts[0].x, pts[0].y);
    for (let i=1; i<pts.length; i++) rCtx.lineTo(pts[i].x, pts[i].y);
    rCtx.strokeStyle = IS_ADMIN ? '#1a56db' : '#16a34a';
    rCtx.lineWidth   = 5;
    rCtx.lineCap     = 'round';
    rCtx.lineJoin    = 'round';
    rCtx.shadowColor = IS_ADMIN ? 'rgba(26,86,219,.4)' : 'rgba(22,163,74,.4)';
    rCtx.shadowBlur  = 10;
    rCtx.stroke();
    rCtx.shadowBlur  = 0;

    pts.forEach(function(wp, i) {
        const isFirst=i===0, isLast=i===pts.length-1;
        rCtx.beginPath();
        rCtx.arc(wp.x, wp.y, isFirst||isLast?11:8, 0, Math.PI*2);
        rCtx.fillStyle   = isFirst?'#16a34a':isLast?'#dc2626':'#1a56db';
        rCtx.fill();
        rCtx.strokeStyle = '#fff';
        rCtx.lineWidth   = 2.5;
        rCtx.stroke();
        rCtx.fillStyle='#fff'; rCtx.font='bold 10px sans-serif';
        rCtx.textAlign='center'; rCtx.textBaseline='middle';
        rCtx.fillText(isFirst?'S':isLast?'E':String(i), wp.x, wp.y);
    });
}

/* ════════════════════════════
   경유점 목록 (관리자)
════════════════════════════ */
function updateWpList() {
    const list = document.getElementById('wpList');
    if (!list) return;
    list.innerHTML = '';
    if (waypoints.length===0) { list.innerHTML='<div class="wp-empty">아직 경유점이 없습니다</div>'; return; }
    waypoints.forEach(function(wp,i) {
        const item=document.createElement('div');
        item.className='wp-item';
        item.innerHTML='<div class="wp-num">'+(i+1)+'</div>'+
            '<div class="wp-coord">x:'+Math.round(wp.x)+'  y:'+Math.round(wp.y)+'</div>'+
            '<button class="wp-del" onclick="removeWp('+i+')"><i class="bi bi-x"></i></button>';
        list.appendChild(item);
    });
}
function removeWp(i){waypoints.splice(i,1);updateWpList();redrawRoute();updateOverlay();}
function undoLast(){if(waypoints.length>0){waypoints.pop();updateWpList();redrawRoute();updateOverlay();}}
function clearRoute(){waypoints=[];loadedRoutePoints=[];updateWpList();redrawRoute();drawMarkers();updateOverlay();setResult('초기화되었습니다.');}

function updateOverlay() {
    const ov=document.getElementById('mapOverlay');
    const badge=document.getElementById('ovBadge');
    const text=document.getElementById('ovText');
    if (IS_ADMIN) {
        if(waypoints.length>0){ov.classList.add('show');badge.className='ov-badge blue';badge.textContent='경유점 '+waypoints.length+'개';text.textContent='저장 버튼으로 DB에 저장하세요';}
        else ov.classList.remove('show');
    } else {
        if(loadedRoutePoints.length>0){ov.classList.add('show');badge.className='ov-badge green';badge.textContent='경로 표시 중';text.textContent='평면도에서 경로를 확인하세요';}
        else if(originId&&destId){ov.classList.add('show');badge.className='ov-badge blue';badge.textContent='준비 완료';text.textContent='경로 안내 시작을 누르세요';}
        else if(originId){ov.classList.add('show');badge.className='ov-badge blue';badge.textContent='출발지 선택됨';text.textContent='목적지 마커를 클릭하세요';}
        else ov.classList.remove('show');
    }
}
function setResult(msg){const el=document.getElementById('resultBox');if(el)el.textContent=msg;}

/* ════════════════════════════
   학생: 출발지/목적지 설정
════════════════════════════ */
function setOrigin(ent) {
    originId = ent.id;
    drawMarkers();
    updateOverlay();
    showPhoto('origin', ent.name, ent.img);
    syncOriginSelect(ent.id);
    setResult('출발지: '+ent.name+'\n목적지 마커를 클릭하거나 선택하세요.');
}
function setDest(ent) {
    destId = ent.id;
    drawMarkers();
    updateOverlay();
    showPhoto('dest', ent.name, ent.img);
    syncDestSelect(ent.id);
    setResult('출발: '+getEntName(originId)+'\n도착: '+ent.name+'\n[경로 안내 시작]을 누르세요.');
    /* 목적지 건물 있으면 도착 버튼 미리 표시 */
    const arrivedBtn = document.getElementById('btnArrived');
    if (arrivedBtn && ent.building) {
        arrivedBtn.style.display = 'flex';
        arrivedBtn.dataset.building = ent.building;
    }
}

function onOriginSelectChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    if(!opt.value){originId='';hidePhoto('origin');drawMarkers();updateOverlay();return;}
    const ent=entranceData.find(e=>e.id===opt.value);
    if(ent) setOrigin(ent);
}
function onDestSelectChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    if(!opt.value){destId='';hidePhoto('dest');drawMarkers();updateOverlay();return;}
    const ent=entranceData.find(e=>e.id===opt.value);
    if(ent) setDest(ent);
}
function setOriginFromList(id,name,img){const ent=entranceData.find(e=>e.id===id)||{id,name,img};setOrigin(ent);}
function setDestFromList(id,name,img){const ent=entranceData.find(e=>e.id===id)||{id,name,img};setDest(ent);}

function syncOriginSelect(id){const s=document.getElementById('originSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}
function syncDestSelect(id){const s=document.getElementById('destSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}
function getEntName(id){const e=entranceData.find(e=>e.id===id);return e?e.name:id;}

function showPhoto(type, name, imgUrl) {
    const wrap2 = document.getElementById(type+'PhotoWrap');
    const pImg  = document.getElementById(type+'PhotoImg');
    const pNo   = document.getElementById(type+'PhotoNo');
    const pCap  = document.getElementById(type+'PhotoCaption');
    if(!wrap2)return;
    wrap2.classList.add('show');
    pCap.querySelector('span').textContent = name;
    if(imgUrl){pImg.src=imgUrl;pImg.style.display='';pNo.style.display='none';}
    else{pImg.style.display='none';pNo.style.display='flex';}
}
function hidePhoto(type){const w=document.getElementById(type+'PhotoWrap');if(w)w.classList.remove('show');}

/* ════════════════════════════
   학생: 경로 불러오기
════════════════════════════ */
async function loadRoute() {
    if(!originId){alert('출발지를 선택하세요.');return;}
    if(!destId){alert('목적지를 선택하세요.');return;}
    const btn=document.getElementById('btnLoad');
    btn.disabled=true;btn.innerHTML='<i class="bi bi-hourglass-split"></i>불러오는 중...';

    /* 목적지 건물명 미리 확인 후 도착 버튼 표시 */
    const destEnt = entranceData.find(e=>e.id===destId);
    const destBuilding = destEnt ? destEnt.building : '';
    const arrivedBtn = document.getElementById('btnArrived');
    if (arrivedBtn && destBuilding) {
        arrivedBtn.style.display = 'flex';
        arrivedBtn.dataset.building = destBuilding;
    }

    try {
        const res=await fetch('/CampusNav/getRoutes.jsp?fromId='+encodeURIComponent(originId)+'&toId='+encodeURIComponent(destId)+'&latest=1');
        const data=await res.json();
        if(!data||!data.points||data.points.length===0){
            setResult('⚠️ 등록된 경로가 없습니다.\n관리자에게 경로 등록을 요청하세요.\n\n출입구에 도착하면 아래 버튼으로 실내 안내를 받으세요.');
            return;
        }
        loadedRoutePoints=data.points;
        redrawRoute();updateOverlay();
        setResult('✅ 경로 안내\n출발: '+getEntName(originId)+'\n도착: '+getEntName(destId)+'\n포인트 '+loadedRoutePoints.length+'개\n\n출입구 도착 후 아래 버튼을 누르세요.');
    }catch(e){setResult('⚠️ 오류: '+e.message);}
    finally{btn.disabled=false;btn.innerHTML='<i class="bi bi-play-circle-fill"></i>경로 안내 시작';}
}

/* 출입구 도착 → 실내 안내 페이지 이동 */
function goToFloorNav() {
    const btn = document.getElementById('btnArrived');
    const building = btn ? btn.dataset.building : '';
    if (!building) { alert('목적지 건물 정보가 없습니다.'); return; }
    const destRoom = '<%= esc(paramDestName).replace("'","\\'") %>';
    const roomId   = '<%= esc(paramRoomId).replace("'","\\'") %>';
    let url = '/CampusNav/floorNav.jsp?building=' + encodeURIComponent(building);
    if (destRoom) url += '&destRoom=' + encodeURIComponent(destRoom);
    if (roomId)   url += '&roomId='   + encodeURIComponent(roomId);
    location.href = url;
}

/* ════════════════════════════
   관리자: 출발/도착 출입구 선택
════════════════════════════ */
function onAdminFromChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    adminFromId = opt.value || '';
    updateAdminRouteInfo();
    if(adminFromId && adminToId) loadSavedRoutes();
}
function onAdminToChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    adminToId = opt.value || '';
    updateAdminRouteInfo();
    if(adminFromId && adminToId) loadSavedRoutes();
}
function syncAdminFromSelect(id){const s=document.getElementById('adminFromSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}
function syncAdminToSelect(id){const s=document.getElementById('adminToSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}

function updateAdminRouteInfo() {
    const infoEl = document.getElementById('adminRouteInfo');
    const infoTx = document.getElementById('adminRouteInfoText');
    if(!infoEl) return;
    if(adminFromId && adminToId) {
        infoEl.style.display = 'flex';
        infoTx.textContent = getEntName(adminFromId) + '  →  ' + getEntName(adminToId);
        setResult('경로: '+getEntName(adminFromId)+' → '+getEntName(adminToId)+'\n평면도를 클릭해 경로를 그리세요.');
    } else if(adminFromId) {
        infoEl.style.display = 'flex';
        infoTx.textContent = getEntName(adminFromId) + '  →  (도착 출입구 선택 필요)';
        setResult('출발: '+getEntName(adminFromId)+'\n도착 출입구를 선택하거나 마커를 클릭하세요.');
    } else {
        infoEl.style.display = 'none';
        setResult('출발·도착 출입구를 선택하고 평면도에서 경로를 그리세요.');
    }
    drawMarkers();
}

/* ════════════════════════════
   학부생: 마커 클릭 사진 팝업
════════════════════════════ */
let photoPopupTimer = null;

function showMarkerPhotoPopup(ent, cx, cy) {
    const old = document.getElementById('markerPopup');
    if(old) old.remove();
    if(photoPopupTimer) clearTimeout(photoPopupTimer);

    const imgSrc  = ent.img || '';
    const popupH  = imgSrc ? 260 : 150;
    const popupW  = 220;

    const popup = document.createElement('div');
    popup.id = 'markerPopup';
    popup.style.cssText =
        'position:absolute;z-index:100;background:#fff;border-radius:14px;' +
        'box-shadow:0 4px 24px rgba(0,0,0,.22);overflow:hidden;width:'+popupW+'px;' +
        'border:1px solid var(--line);animation:popIn .18s ease;';

    /* 위치: 마커 위쪽 40% → 아래 표시, 그 외 → 위 표시 */
    const canvasW = markerCanvas.width;
    const canvasH = markerCanvas.height;
    let left = cx - popupW / 2;
    let top  = cy < canvasH * 0.4 ? cy + 22 : cy - popupH - 22;

    /* 경계 보정 */
    if (left < 4) left = 4;
    if (left + popupW > canvasW - 4) left = canvasW - popupW - 4;
    if (top < 4) top = cy + 22;

    popup.style.left = left + 'px';
    popup.style.top  = top  + 'px';

    popup.innerHTML =
        '<div>' +
            '<img src="'+escHtml(imgSrc)+'" ' +
                'style="width:100%;height:160px;object-fit:cover;display:'+(imgSrc?'block':'none')+';" ' +
                'onerror="this.style.display=\'none\';document.getElementById(\'popupNoImg\').style.display=\'flex\';">' +
            '<div id="popupNoImg" style="display:'+(imgSrc?'none':'flex')+';height:90px;background:var(--bg2);align-items:center;justify-content:center;gap:6px;color:var(--txt3);font-size:12px;">' +
                '<i class="bi bi-image"></i>사진 없음' +
            '</div>' +
        '</div>' +
        '<div style="padding:10px 12px;">' +
            '<div style="font-size:13px;font-weight:700;color:var(--txt);margin-bottom:8px;">'+escHtml(ent.name)+'</div>'+
            '<div style="display:flex;gap:5px;">'+
                '<button onclick="setOriginFromPopup(\''+ent.id+'\')" style="flex:1;background:var(--green);color:#fff;border:none;border-radius:7px;padding:6px 0;font-size:12px;font-weight:700;cursor:pointer;font-family:var(--sans);">출발지</button>'+
                '<button onclick="setDestFromPopup(\''+ent.id+'\')" style="flex:1;background:var(--red);color:#fff;border:none;border-radius:7px;padding:6px 0;font-size:12px;font-weight:700;cursor:pointer;font-family:var(--sans);">목적지</button>'+
                '<button onclick="closeMarkerPopup()" style="width:30px;background:var(--bg2);color:var(--txt3);border:1.5px solid var(--line2);border-radius:7px;font-size:13px;cursor:pointer;flex-shrink:0;">✕</button>'+
            '</div>'+
        '</div>';

    wrap.appendChild(popup);
    photoPopupTimer = setTimeout(closeMarkerPopup, 5000);
}

function closeMarkerPopup() {
    const p = document.getElementById('markerPopup');
    if(p) p.remove();
    if(photoPopupTimer) { clearTimeout(photoPopupTimer); photoPopupTimer=null; }
}

function setOriginFromPopup(id) {
    closeMarkerPopup();
    const ent = entranceData.find(e=>e.id===id);
    if(ent) setOrigin(ent);
}
function setDestFromPopup(id) {
    closeMarkerPopup();
    const ent = entranceData.find(e=>e.id===id);
    if(ent) setDest(ent);
}

/* ════════════════════════════
   관리자: pin 모드
════════════════════════════ */
function onPinEntranceChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    if(!opt.value){pinTargetId='';document.getElementById('pinTargetInfo').style.display='none';return;}
    pinTargetId=opt.value;
    document.getElementById('pinTargetName').textContent=opt.dataset.name;
    document.getElementById('pinTargetInfo').style.display='flex';
    if(mode!=='pin')setMode('pin');
}
function syncPinSelect(id){const s=document.getElementById('pinEntranceSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}
function selectPinTarget(id,name){pinTargetId=id;document.getElementById('pinTargetName').textContent=name;document.getElementById('pinTargetInfo').style.display='flex';syncPinSelect(id);switchAdminTab('pin');}

async function savePinCoord(entranceId, x, y) {
    try {
        const res  = await fetch('/CampusNav/saveEntrancePin.jsp',{
            method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'entranceId='+encodeURIComponent(entranceId)+'&pixelX='+encodeURIComponent(x.toFixed(2))+'&pixelY='+encodeURIComponent(y.toFixed(2))
        });
        const text = await res.text();
        if(text.trim()==='OK'){
            entranceData.forEach(function(e){if(e.id===entranceId){e.px=x;e.py=y;}});
            drawMarkers();
            const nm=document.getElementById('pinTargetName');
            alert('✅ '+(nm?nm.textContent:'')+' 위치 저장 완료!');
        } else alert('저장 실패: '+text);
    } catch(e){alert('오류: '+e.message);}
}

/* ════════════════════════════
   관리자: 경로 저장/목록
════════════════════════════ */
async function saveRoute() {
    if(!adminFromId || !adminToId){alert('출발·도착 출입구를 모두 선택하세요.');return;}
    if(waypoints.length<2){alert('경로 포인트를 2개 이상 찍어주세요.');return;}
    const routeName=document.getElementById('routeNameInput').value.trim();
    const btn=document.getElementById('btnSave');
    btn.disabled=true;btn.innerHTML='<i class="bi bi-hourglass-split"></i>저장 중...';
    try {
        const res=await fetch('/CampusNav/saveRoute.jsp',{
            method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'fromEntranceId='+encodeURIComponent(adminFromId)+
                 '&toEntranceId='+encodeURIComponent(adminToId)+
                 '&routeName='+encodeURIComponent(routeName)+
                 '&points='+encodeURIComponent(JSON.stringify(waypoints))
        });
        const text=await res.text();
        if(text.trim()==='OK'){
            setResult('✅ 경로 저장 완료!\n'+getEntName(adminFromId)+' → '+getEntName(adminToId)+'\n포인트 '+waypoints.length+'개');
            loadSavedRoutes();
        } else setResult('⚠️ 저장 실패: '+text);
    }catch(e){setResult('⚠️ 오류: '+e.message);}
    finally{btn.disabled=false;btn.innerHTML='<i class="bi bi-floppy-fill"></i>경로 저장하기';}
}

async function loadSavedRoutes() {
    if(!adminFromId || !adminToId) return;
    const container=document.getElementById('savedRouteList');
    container.innerHTML='<div class="wp-empty">불러오는 중...</div>';
    try {
        const res=await fetch('/CampusNav/getRoutes.jsp?fromId='+encodeURIComponent(adminFromId)+'&toId='+encodeURIComponent(adminToId));
        const data=await res.json();
        if(!data||data.length===0){container.innerHTML='<div class="wp-empty">이 구간에 저장된 경로가 없습니다</div>';return;}
        container.innerHTML='';
        data.forEach(function(r){
            const item=document.createElement('div');
            item.className='route-item';
            item.innerHTML='<div><div class="route-item-name">'+escHtml(r.route_name||'이름 없음')+'</div>'+
                '<div class="route-item-meta">'+escHtml(r.created_at)+' · '+r.point_count+'개 포인트</div></div>'+
                '<div style="display:flex;gap:4px;">'+
                '<button class="btn-sm btn-sm-blue" onclick="previewRoute('+r.route_id+')"><i class="bi bi-eye"></i>미리보기</button>'+
                '<button class="btn-sm btn-sm-red" onclick="deleteRoute('+r.route_id+')"><i class="bi bi-trash3"></i></button></div>';
            container.appendChild(item);
        });
    }catch(e){container.innerHTML='<div class="wp-empty">로드 실패</div>';}
}

async function previewRoute(routeId) {
    try {
        const res=await fetch('/CampusNav/getRoutes.jsp?routeId='+routeId);
        const data=await res.json();
        if(data&&data.points){waypoints=data.points;updateWpList();redrawRoute();updateOverlay();setResult('미리보기: '+(data.route_name||'경로')+'\n경유점 '+waypoints.length+'개');}
    }catch(e){alert('미리보기 실패: '+e.message);}
}

async function deleteRoute(routeId) {
    if(!confirm('이 경로를 삭제하시겠습니까?'))return;
    try{await fetch('/CampusNav/deleteRoute.jsp?routeId='+routeId,{method:'POST'});loadSavedRoutes();clearRoute();}
    catch(e){alert('삭제 실패: '+e.message);}
}

/* ════════════════════════════
   아코디언
════════════════════════════ */
function toggleLocList(btn){
    const body=document.getElementById('locListBody'),ch=btn.querySelector('.loc-chevron'),open=body.style.display!=='none';
    body.style.display=open?'none':'block';ch.classList.toggle('open',!open);btn.classList.toggle('open',!open);
}
function toggleBuilding(idx,btn){
    const pl=document.getElementById('places-'+idx),ch=btn.querySelector('.b-chevron'),op=pl.style.display!=='none';
    pl.style.display=op?'none':'block';ch.classList.toggle('open',!op);
}

/* ════════════════════════════
   유틸
════════════════════════════ */
function escHtml(s){if(!s)return'';return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}

/* ── 초기화 ── */
window.addEventListener('load', function() {
    setTimeout(function(){ resizeCanvas(); }, 200);
    <% if (!isAdmin && !autoDestEntranceId.isEmpty()) { %>
    /* detail.jsp 연동: 자동 목적지 설정 */
    const autoEnt = entranceData.find(e => e.id === '<%= esc(autoDestEntranceId) %>');
    if (autoEnt) setTimeout(function(){ setDest(autoEnt); }, 400);
    <% } %>
});
</script>
</body>
</html>
