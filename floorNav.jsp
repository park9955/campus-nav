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
    if (loginUser == null) { response.sendRedirect("/CAN/campuslogin.jsp"); return; }
    boolean isAdmin = "admin".equals(loginRole);

    /* ── URL 파라미터
       building : 건물명  (예: 1공학관)
       destRoom : 목적 호실 (예: 1206호)
       floor    : 층 (선택)
       roomId   : rooms 테이블 ID (room_id 기준 경로 우선 조회)
    */
    String paramBuilding = nvl(request.getParameter("building"));
    String paramDestRoom = nvl(request.getParameter("destRoom"));
    String paramFloor    = nvl(request.getParameter("floor"));
    String paramRoomId   = nvl(request.getParameter("roomId"));
    try { paramBuilding = java.net.URLDecoder.decode(paramBuilding,"UTF-8"); } catch(Exception e2){}
    try { paramDestRoom = java.net.URLDecoder.decode(paramDestRoom,"UTF-8"); } catch(Exception e2){}

    /* ── DB: 실내 경로 조회 ──
       room_id 있으면 room_id 기준으로 우선 조회,
       없으면 building + dest_room 텍스트 매칭
    */
    List<Map<String,String>> floorRoutes = new ArrayList<>();
    List<Map<String,String>> buildingRooms = new ArrayList<>();  // 해당 건물의 호실 목록
    String dbErr = "";
    String autoPoints = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );

        PreparedStatement ps;
        if (!paramRoomId.isEmpty() && !paramRoomId.equals("0")) {
            /* room_id 기준 조회 (우선) */
            ps = conn.prepareStatement(
                "SELECT route_id, building, floor, dest_room, route_name, points_json, " +
                "IFNULL(floorplan_img,'') AS floorplan_img, created_at " +
                "FROM floor_routes WHERE room_id=? AND is_active=1 ORDER BY created_at DESC"
            );
            ps.setInt(1, Integer.parseInt(paramRoomId));
        } else {
            /* building + dest_room 텍스트 매칭 */
            ps = conn.prepareStatement(
                "SELECT route_id, building, floor, dest_room, route_name, points_json, " +
                "IFNULL(floorplan_img,'') AS floorplan_img, created_at " +
                "FROM floor_routes WHERE building=? AND is_active=1 " +
                "ORDER BY CASE WHEN dest_room=? THEN 0 ELSE 1 END, created_at DESC"
            );
            ps.setString(1, paramBuilding);
            ps.setString(2, paramDestRoom);
        }

        ResultSet rs = ps.executeQuery();
        while (rs.next()) {
            Map<String,String> r = new LinkedHashMap<>();
            r.put("id",      nvl(rs.getString("route_id")));
            r.put("floor",   nvl(rs.getString("floor")));
            r.put("room",    nvl(rs.getString("dest_room")));
            r.put("name",    nvl(rs.getString("route_name")));
            r.put("points",  nvl(rs.getString("points_json")));
            r.put("img",     nvl(rs.getString("floorplan_img")));
            r.put("created", nvl(rs.getString("created_at")));
            floorRoutes.add(r);
            if (autoPoints.isEmpty()) autoPoints = nvl(rs.getString("points_json"));
        }
        rs.close(); ps.close();

        conn.close();
    } catch(Exception ex) { dbErr = ex.getMessage(); }

    /* ── 건물 호실 목록 별도 조회 (컬럼 없어도 안전하게) ── */
    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        java.sql.Connection conn2 = java.sql.DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root","1234"
        );

        /* 기본 컬럼만 조회 (description 없어도 OK) */
        java.sql.PreparedStatement psBase = conn2.prepareStatement(
            "SELECT room_id, room_name, floor FROM rooms " +
            "WHERE building=? AND (is_active='Y' OR is_active=1 OR is_active IS NULL) ORDER BY floor, room_name"
        );
        psBase.setString(1, paramBuilding);
        java.sql.ResultSet rsBase = psBase.executeQuery();
        while (rsBase.next()) {
            Map<String,String> rm = new LinkedHashMap<>();
            rm.put("id",          nvl(rsBase.getString("room_id")));
            rm.put("name",        nvl(rsBase.getString("room_name")));
            rm.put("floor",       nvl(rsBase.getString("floor")));
            rm.put("description", "");
            rm.put("px",          "0");
            rm.put("py",          "0");
            rm.put("pinDim",      "3D");
            rm.put("pinFloor",    "");
            buildingRooms.add(rm);
        }
        rsBase.close(); psBase.close();

        /* description 컬럼 있으면 추가 */
        try {
            java.sql.PreparedStatement psDesc = conn2.prepareStatement(
                "SELECT room_id, IFNULL(description,'') AS description FROM rooms WHERE building=?"
            );
            psDesc.setString(1, paramBuilding);
            java.sql.ResultSet rsDesc = psDesc.executeQuery();
            while (rsDesc.next()) {
                String rid = nvl(rsDesc.getString("room_id"));
                for (Map<String,String> rm : buildingRooms) {
                    if (rm.get("id").equals(rid)) {
                        rm.put("description", nvl(rsDesc.getString("description")));
                        break;
                    }
                }
            }
            rsDesc.close(); psDesc.close();
        } catch(Exception ignoredDesc) { }

        /* 픽셀 좌표 컬럼 있으면 추가 */
        try {
            java.sql.PreparedStatement psPin = conn2.prepareStatement(
                "SELECT room_id, IFNULL(pixel_x,0) AS pixel_x, IFNULL(pixel_y,0) AS pixel_y, " +
                "IFNULL(pin_dim,'3D') AS pin_dim, IFNULL(pin_floor,'') AS pin_floor " +
                "FROM rooms WHERE building=?"
            );
            psPin.setString(1, paramBuilding);
            java.sql.ResultSet rsPin = psPin.executeQuery();
            while (rsPin.next()) {
                String rid = nvl(rsPin.getString("room_id"));
                for (Map<String,String> rm : buildingRooms) {
                    if (rm.get("id").equals(rid)) {
                        rm.put("px",       nvl(rsPin.getString("pixel_x")));
                        rm.put("py",       nvl(rsPin.getString("pixel_y")));
                        rm.put("pinDim",   nvl(rsPin.getString("pin_dim")));
                        rm.put("pinFloor", nvl(rsPin.getString("pin_floor")));
                        break;
                    }
                }
            }
            rsPin.close(); psPin.close();
        } catch(Exception ignoredPin) { }

        conn2.close();
    } catch(Exception exR) { dbErr = dbErr + " | rooms: " + exR.getMessage(); }

    /* 도면 이미지 (첫 번째 경로에서) */
    String floorplanImg = "";
    for (Map<String,String> r : floorRoutes) {
        if (!r.get("img").isEmpty()) { floorplanImg = r.get("img"); break; }
    }

    /* 건물 URL 인코딩 (뒤로가기용) */
    String buildingEnc = "";
    try { buildingEnc = java.net.URLEncoder.encode(paramBuilding,"UTF-8"); } catch(Exception e2){}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICT CAN — <%= esc(paramBuilding) %> 실내 안내</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
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
.page-title .icon-box{width:36px;height:36px;border-radius:10px;background:var(--teal-lt);color:var(--teal);display:flex;align-items:center;justify-content:center;font-size:17px;}
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
.f-select,.f-input{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);font-size:13px;padding:8px 12px;background:var(--bg);color:var(--txt);font-family:var(--sans);transition:border-color .15s;}
.f-select:focus,.f-input:focus{border-color:var(--blue);box-shadow:0 0 0 3px rgba(26,86,219,.1);outline:none;background:var(--white);}

/* BUTTONS */
.btn-prim{background:var(--blue);color:#fff;border:none;border-radius:var(--r);padding:10px 16px;font-size:13px;font-weight:600;cursor:pointer;width:100%;display:flex;align-items:center;justify-content:center;gap:6px;font-family:var(--sans);transition:background .15s;}
.btn-prim:hover{background:var(--blue-dk);}
.btn-prim:disabled{background:#93c5fd;cursor:not-allowed;}
.btn-teal{background:var(--teal);color:#fff;border:none;border-radius:var(--r);padding:10px 16px;font-size:13px;font-weight:600;cursor:pointer;width:100%;display:flex;align-items:center;justify-content:center;gap:6px;font-family:var(--sans);transition:background .15s;}
.btn-teal:hover{background:#0f766e;}
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

/* 도착 배너 */
.arrived-banner{background:linear-gradient(135deg,var(--green-lt),var(--teal-lt));border:1.5px solid var(--teal-md);border-radius:var(--r);padding:14px 16px;display:flex;align-items:center;gap:12px;margin-bottom:16px;}
.arrived-icon{width:42px;height:42px;border-radius:12px;background:var(--teal);color:#fff;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
.arrived-title{font-size:15px;font-weight:800;color:var(--txt);}
.arrived-sub{font-size:12px;color:var(--txt2);margin-top:2px;}

/* 도면 */
.floorplan-wrap{position:relative;width:100%;background:#fff;border-radius:14px;overflow:hidden;border:1px solid var(--line);user-select:none;}
#floorplanImg{width:100%;height:560px;object-fit:contain;display:block;}
.fp-placeholder{height:400px;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:12px;color:rgba(255,255,255,.4);}
.fp-placeholder i{font-size:56px;}
.fp-placeholder p{font-size:14px;}
#routeCanvas{position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;}
#clickCanvas{position:absolute;top:0;left:0;width:100%;height:100%;cursor:crosshair;display:none;}
#clickCanvas.mode-view{cursor:default;pointer-events:none;}

/* 툴바 */
.map-toolbar{position:absolute;top:10px;left:10px;z-index:10;display:flex;gap:5px;flex-wrap:wrap;}
.tb-btn{background:rgba(255,255,255,.93);border:1.5px solid var(--line);border-radius:8px;padding:5px 11px;font-size:12px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:5px;color:var(--txt);transition:all .15s;font-family:var(--sans);}
.tb-btn:hover{background:#fff;border-color:var(--blue);color:var(--blue);}
.tb-btn.active{background:var(--blue);color:#fff;border-color:var(--blue);}
.tb-btn.tb-amber:hover{border-color:var(--amber);color:var(--amber);}
.tb-btn.tb-amber.active{background:var(--amber);color:#fff;border-color:var(--amber);}

/* 오버레이 */
.map-overlay{position:absolute;bottom:12px;left:50%;transform:translateX(-50%);z-index:20;background:rgba(255,255,255,.95);border-radius:10px;padding:8px 16px;box-shadow:var(--shadow2);display:none;align-items:center;gap:10px;font-size:12px;white-space:nowrap;}
.map-overlay.show{display:flex;}
.ov-badge{border-radius:6px;padding:3px 9px;font-size:11px;font-weight:700;color:#fff;}
.ov-badge.blue{background:var(--blue);}
.ov-badge.green{background:var(--green);}
.ov-badge.teal{background:var(--teal);}
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
.route-item.active-route{border-color:var(--teal);background:var(--teal-lt);}
.route-item-name{font-size:12px;font-weight:600;color:var(--txt);}
.route-item-meta{font-size:10px;color:var(--txt3);font-family:var(--mono);margin-top:1px;}

/* 결과박스 */
.result-box{background:var(--bg2);border-radius:var(--r);padding:11px 13px;font-size:12px;color:var(--txt2);font-family:var(--mono);border:1px solid var(--line);min-height:56px;line-height:1.7;white-space:pre-line;}

/* DB 오류 */
.alert-err{background:var(--red-lt);border:1px solid #fca5a5;border-radius:var(--r);padding:10px 14px;color:var(--red);font-size:13px;margin-bottom:16px;display:flex;align-items:flex-start;gap:8px;}

/* 구분선 */
.divider{border:none;border-top:1px solid var(--line);margin:12px 0;}

@keyframes popIn{from{opacity:0;transform:scale(.9);}to{opacity:1;transform:scale(1);}}
@media(max-width:991px){#floorplanImg,.fp-placeholder{height:320px;}}
.floor-tabs{display:flex;gap:6px;margin-bottom:10px;flex-wrap:wrap;}
.floor-tab{font-family:var(--mono);font-size:12px;font-weight:700;padding:6px 16px;border-radius:999px;border:1.5px solid var(--line2);background:var(--white);color:var(--txt2);cursor:pointer;transition:all .15s;}
.floor-tab:hover{border-color:var(--blue);color:var(--blue);}
.floor-tab.active{background:var(--blue);border-color:var(--blue);color:#fff;}
</style>
</head>
<body>

<!-- TOPNAV -->
<div class="topnav">
  <a href="/CAN/campuslogin.jsp" class="logo">
    <div class="logo-dot"><img src="/CAN/images/logo.png" alt="ICT"></div>
    <span>ICT <em>CAN</em></span>
  </a>
  <div class="nav-right">
    <span style="font-size:13px;color:var(--txt2);font-family:var(--mono);"><i class="bi bi-person-circle"></i> <%= esc(loginName) %></span>
    <span class="role-chip <%= isAdmin?"admin":"" %>">
      <%= isAdmin?"관리자":"student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"게스트" %>
    </span>
    <a href="javascript:history.back()" class="chip"><i class="bi bi-arrow-left"></i>뒤로</a>
    <a href="/CAN/navigationTest1.jsp" class="chip"><i class="bi bi-map"></i>캠퍼스 지도</a>
  </div>
</div>

<!-- MAIN -->
<div class="shell">

  <div class="page-title">
    <div class="icon-box"><i class="bi bi-building"></i></div>
    <%= esc(paramBuilding) %> 실내 안내
  </div>
  <div class="page-sub">
    <% if (!paramDestRoom.isEmpty()) { %>
    <i class="bi bi-geo-alt-fill" style="color:var(--teal);"></i>
    <strong style="color:var(--txt)"><%= esc(paramDestRoom) %></strong>까지 실내 경로를 안내합니다.
    <% } else { %>
    도면에서 목적지를 선택하세요.
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
      <!-- ══ 관리자: 실내 경로 그리기 ══ -->
      <div class="admin-banner">
        <i class="bi bi-shield-fill"></i>
        <div><strong>관리자 모드</strong> — 경로 그리기 또는 마커 위치 설정</div>
      </div>

      <!-- 탭 전환: 경로 그리기 / 마커 위치 설정 -->
      <div style="display:flex;gap:6px;margin-bottom:12px;">
        <button class="tb-btn active" id="tabRouteBtn" onclick="switchAdminTab('route')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-pencil-fill"></i>경로 그리기
        </button>
        <button class="tb-btn tb-amber" id="tabPinBtn" onclick="switchAdminTab('pin')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-geo-fill"></i>마커 위치 설정
        </button>
      </div>

      <!-- ═══ 경로 그리기 탭 ═══ -->
      <div id="tabRoute">
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-building"></i></div>
          <div><div class="ch-title">경로 정보</div><div class="ch-sub">저장할 경로의 목적지 호실 입력</div></div>
        </div>
        <div class="card-body">
          <label class="f-label">건물</label>
          <input type="text" class="f-input mb-2" value="<%= esc(paramBuilding) %>" readonly style="background:var(--bg2);color:var(--txt2);">
          <label class="f-label">목적지 호실</label>
          <% if (!buildingRooms.isEmpty()) { %>
          <select class="f-select mb-2" id="destRoomInput" onchange="onDestRoomSelect(this)">
            <option value="">-- 호실 선택 --</option>
            <% String prevFloor = ""; for (Map<String,String> rm : buildingRooms) {
                 String fl = rm.get("floor").isEmpty() ? "기타" : rm.get("floor")+"층";
                 if (!fl.equals(prevFloor)) { if (!prevFloor.isEmpty()) { %></optgroup><% } %>
                 <optgroup label="<%= esc(fl) %>">
                 <% prevFloor = fl; } %>
              <option value="<%= esc(rm.get("name")) %>"
                      data-floor="<%= esc(rm.get("floor")) %>"
                      data-id="<%= esc(rm.get("id")) %>"
                      <%= rm.get("name").equals(paramDestRoom) ? "selected" : "" %>>
                <%= esc(rm.get("name")) %>
              </option>
            <% } if (!prevFloor.isEmpty()) { %></optgroup><% } %>
          </select>
          <% } else { %>
          <input type="text" class="f-select mb-2" id="destRoomInput" placeholder="예: 1206호" value="<%= esc(paramDestRoom) %>">
          <% } %>
          <input type="hidden" id="floorInput" value="<%= esc(paramFloor) %>">
          <input type="hidden" id="routeNameInput" value="">
          <div class="divider"></div>
          <label class="f-label">도면 이미지 경로 <span style="font-weight:400;color:var(--txt3)">(선택)</span></label>
          <input type="text" class="f-input" id="floorImgInput"
                 placeholder="예: /CAN/images/floors/eng1_2f.png"
                 value="<%= esc(floorplanImg) %>"
                 oninput="updateFloorplanImg(this.value)">
        </div>
      </div>

      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-blue"><i class="bi bi-pencil-fill"></i></div>
          <div><div class="ch-title">경로 그리기</div><div class="ch-sub">도면을 순서대로 클릭해 경로를 만드세요</div></div>
        </div>
        <div class="card-body">
          <div style="background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);margin-bottom:10px;display:flex;gap:7px;">
            <i class="bi bi-lightbulb-fill" style="flex-shrink:0;margin-top:1px;"></i>
            <span><strong>S</strong> = 출발(입구) · <strong>E</strong> = 도착(호실)<br>도면을 순서대로 클릭하세요.</span>
          </div>
          <label class="f-label">경로 포인트</label>
          <div class="wp-list" id="wpList"><div class="wp-empty">아직 찍은 포인트가 없습니다</div></div>
          <div class="divider"></div>
          <div class="d-flex flex-column gap-2">
            <button class="btn-teal" onclick="saveFloorRoute()" id="btnSave"><i class="bi bi-floppy-fill"></i>경로 저장하기</button>
            <div class="d-flex gap-2">
              <button class="btn-ghost" onclick="undoLast()" style="flex:1;font-size:12px;padding:7px;"><i class="bi bi-arrow-counterclockwise"></i>되돌리기</button>
              <button class="btn-ghost danger" onclick="clearRoute()" style="flex:1;font-size:12px;padding:7px;"><i class="bi bi-trash3"></i>초기화</button>
            </div>
          </div>
          <div class="divider"></div>
          <div class="result-box" id="resultBox">도면에서 경로를 그리고 저장하세요.</div>
        </div>
      </div>

      <!-- 저장된 경로 목록 -->
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-green"><i class="bi bi-database-fill"></i></div>
          <div><div class="ch-title">저장된 실내 경로</div><div class="ch-sub"><%= esc(paramBuilding) %></div></div>
        </div>
        <div class="card-body" id="savedRouteList">
          <% if (floorRoutes.isEmpty()) { %>
          <div class="wp-empty">저장된 실내 경로가 없습니다</div>
          <% } else { for (Map<String,String> r : floorRoutes) { %>
          <div class="route-item" id="ri-<%= esc(r.get("id")) %>">
            <div style="flex:1;min-width:0;">
              <div class="route-item-name">
                <% if(!r.get("room").isEmpty()){ %><span style="background:var(--teal-lt);color:var(--teal);padding:1px 6px;border-radius:4px;font-size:10px;margin-right:5px;font-family:var(--mono)"><%= esc(r.get("room")) %></span><% } %>
                <%= esc(r.get("name").isEmpty() ? r.get("room")+"호 경로" : r.get("name")) %>
              </div>
              <div class="route-item-meta"><%= esc(r.get("created")) %></div>
            </div>
            <div style="display:flex;gap:4px;flex-shrink:0;">
              <button class="btn-sm btn-sm-blue" onclick="loadFloorRoute('<%= esc(r.get("id")) %>','<%= esc(r.get("points")) %>')"><i class="bi bi-eye"></i>미리보기</button>
              <button class="btn-sm btn-sm-red" onclick="deleteFloorRoute('<%= esc(r.get("id")) %>')"><i class="bi bi-trash3"></i></button>
            </div>
          </div>
          <% } } %>
        </div>
      </div>
      </div><!-- /#tabRoute -->

      <!-- ═══ 마커 위치 설정 탭 ═══ -->
      <div id="tabPin" style="display:none;">
        <div class="card mb-3">
          <div class="card-head">
            <div class="ch-icon si-amber"><i class="bi bi-geo-fill"></i></div>
            <div><div class="ch-title">호실 마커 위치 설정</div><div class="ch-sub"><%= esc(paramBuilding) %> 도면에서 호실 위치 지정</div></div>
          </div>
          <div class="card-body">
            <div style="background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);margin-bottom:12px;display:flex;gap:7px;">
              <i class="bi bi-lightbulb-fill" style="flex-shrink:0;margin-top:1px;"></i>
              <span>호실을 선택한 뒤 도면에서 해당 호실 위치를 클릭하세요.<br>✓ 표시는 이미 위치가 등록된 호실입니다.</span>
            </div>
            <label class="f-label">위치 설정할 호실</label>
            <select class="f-select" id="pinRoomSelect" onchange="onPinRoomChange(this)">
              <option value="">-- 호실 선택 --</option>
              <%
                /* buildingRooms (DB)에서 room_no → room_id / px / py 매핑 맵 */
                java.util.Map<String,String> roomNoToId = new java.util.LinkedHashMap<>();
                java.util.Map<String,String> roomNoToPx = new java.util.LinkedHashMap<>();
                for (Map<String,String> rm : buildingRooms) {
                    String rname2 = rm.get("name"); /* 예: 1101호 */
                    String rno2   = rname2 != null ? rname2.replace("호","").trim() : "";
                    if (!rno2.isEmpty()) {
                        roomNoToId.put(rno2, rm.get("id"));
                        roomNoToPx.put(rno2, rm.get("px"));
                    }
                }
                if ("1공학관".equals(paramBuilding)) {
                    String[][][] eng1pin = {
                      { {"1101","컴퓨터 실습실"},{"1102","컴퓨터 실습실"},{"1103","컴퓨터 실습실"},
                        {"1105","컴퓨터 실습실"},{"1106","컴퓨터 실습실"},{"1107","컴퓨터 실습실"} },
                      { {"1201","회의실"},{"1202","도면설계실습실"},{"1203","강의실"},
                        {"1205","멀티미디어 기초실습"},{"1206","멀티미디어통신실습실"},{"1207","멀티미디어통신실습실"} },
                      { {"1301","강의실"},{"1302","이동통신종합실습"},
                        {"1305","이동통신네트워크실습"},{"1306","안테나실습실"},{"1307","통신회로실습실"} },
                      { {"1401","창고"},{"1402","일학습병행강의실"},{"1403","일학습병행강의실"},
                        {"1405","강의실"},{"1406","강의실"},{"1407","ICT실습"} },
                      { {"1501","강의실"},{"1502","산업기술연구소"},
                        {"1503","강의실"},{"1505","강당 겸 실내 체육관"} }
                    };
                    for (int flPin = 1; flPin <= eng1pin.length; flPin++) {
                        out.print("<optgroup label=\"" + flPin + "층\">");
                        for (String[] rmPin : eng1pin[flPin-1]) {
                            String rnoPin  = rmPin[0];
                            String rdesc   = rmPin[1];
                            String ridPin  = roomNoToId.getOrDefault(rnoPin, "");
                            String rpxPin  = roomNoToPx.getOrDefault(rnoPin, "0");
                            boolean hasPxPin = !"0".equals(rpxPin) && !rpxPin.isEmpty()
                                               && !"0.0".equals(rpxPin) && !"null".equals(rpxPin);
                            /* value에 room_id 사용 (없으면 호실번호로 폴백) */
                            String valPin = ridPin.isEmpty() ? rnoPin : ridPin;
                            out.print("<option value=\"" + valPin + "\""
                                + " data-name=\"" + rnoPin + "호\""
                                + " data-floor=\"" + flPin + "\">"
                                + rnoPin + "호 — " + rdesc
                                + (hasPxPin ? " ✓" : "")
                                + "</option>");
                        }
                        out.print("</optgroup>");
                    }
                } else {
                    /* 기타 건물: DB 기반 */
                    int prevFloor2 = -999;
                    for (Map<String,String> rm : buildingRooms) {
                        int cf2;
                        try { cf2 = Integer.parseInt(rm.get("floor")); } catch(Exception e) { cf2 = 0; }
                        if (cf2 != prevFloor2) {
                            if (prevFloor2 != -999) out.print("</optgroup>");
                            out.print("<optgroup label=\"" + cf2 + "층\">");
                            prevFloor2 = cf2;
                        }
                        boolean hasPx2 = !"0".equals(rm.get("px")) && !rm.get("px").isEmpty()
                                         && !"0.0".equals(rm.get("px"));
                        out.print("<option value=\"" + esc(rm.get("id")) + "\""
                            + " data-name=\"" + esc(rm.get("name")) + "\""
                            + " data-floor=\"" + esc(rm.get("floor")) + "\">"
                            + esc(rm.get("name")) + (hasPx2 ? " ✓" : "")
                            + "</option>");
                    }
                    if (prevFloor2 != -999) out.print("</optgroup>");
                }
              %>
            </select>
            <div id="pinTargetInfo" style="display:none;margin-top:9px;background:var(--amber-lt);border:1px solid #fde68a;border-radius:8px;padding:8px 11px;font-size:12px;color:var(--amber);align-items:center;gap:7px;">
              <i class="bi bi-cursor-fill"></i>
              <span><strong id="pinTargetName"></strong> — 도면을 클릭하세요</span>
            </div>
            <div class="divider"></div>
            <div class="result-box" id="pinResultBox">호실을 선택하고 도면을 클릭하여 위치를 저장하세요.</div>
          </div>
        </div>
      </div>

      <% } else { %>
      <!-- ══ 학생: 실내 경로 안내 ══ -->

      <!-- 도착 배너 -->
      <div class="arrived-banner">
        <div class="arrived-icon"><i class="bi bi-building-check"></i></div>
        <div>
          <div class="arrived-title"><%= esc(paramBuilding) %> 도착!</div>
          <div class="arrived-sub">
            <% if (!paramDestRoom.isEmpty()) { %>
            <strong><%= esc(paramDestRoom) %></strong>까지 실내 경로를 확인하세요.
            <% } else { %>
            목적지 호실을 선택하세요.
            <% } %>
          </div>
        </div>
      </div>

      <!-- 목적지 호실 선택 -->
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-door-open-fill"></i></div>
          <div><div class="ch-title">목적지 호실</div><div class="ch-sub">찾아가려는 강의실/호실</div></div>
        </div>
        <div class="card-body">
          <% if (!paramDestRoom.isEmpty()) { %>
          <div style="background:var(--teal-lt);border:1.5px solid var(--teal-md);border-radius:var(--r);padding:12px 14px;display:flex;align-items:center;gap:10px;">
            <div style="width:32px;height:32px;border-radius:8px;background:var(--teal);color:#fff;display:flex;align-items:center;justify-content:center;font-size:15px;flex-shrink:0;"><i class="bi bi-geo-alt-fill"></i></div>
            <div>
              <div style="font-size:12px;color:var(--teal);font-weight:600;font-family:var(--mono);">목적지</div>
              <div style="font-size:15px;font-weight:800;color:var(--txt);"><%= esc(paramDestRoom) %></div>
              <div style="font-size:11px;color:var(--txt3);"><%= esc(paramBuilding) %></div>
            </div>
          </div>
          <% } %>

          <!-- 다른 호실로 변경 -->
          <div style="margin-top:10px;">
            <label class="f-label">다른 호실 선택</label>
            <select class="f-select" id="roomSelect" onchange="onRoomChange(this)">
              <option value="">-- 호실 선택 --</option>
              <%
              /* ── 1공학관 호실 하드코딩 ── */
              if ("1공학관".equals(paramBuilding)) {
                  /* 층별 [호실번호, 설명] */
                  String[][][] eng1 = {
                    { {"1101","컴퓨터 실습실"},{"1102","컴퓨터 실습실"},{"1103","컴퓨터 실습실"},
                      {"1105","컴퓨터 실습실"},{"1106","컴퓨터 실습실"},{"1107","컴퓨터 실습실"} },
                    { {"1201","회의실"},{"1202","도면설계실습실"},{"1203","강의실"},
                      {"1205","멀티미디어 기초실습"},{"1206","멀티미디어통신실습실"},{"1207","멀티미디어통신실습실"} },
                    { {"1301","강의실"},{"1302","이동통신종합실습"},
                      {"1305","이동통신네트워크실습"},{"1306","안테나실습실"},{"1307","통신회로실습실"} },
                    { {"1401","창고"},{"1402","일학습병행강의실"},{"1403","일학습병행강의실"},
                      {"1405","강의실"},{"1406","강의실"},{"1407","ICT실습"} },
                    { {"1501","강의실"},{"1502","산업기술연구소"},
                      {"1503","강의실"},{"1505","강당 겸 실내 체육관"} }
                  };
                  for (int fl = 1; fl <= eng1.length; fl++) {
                      out.print("<optgroup label=\"" + fl + "층\">");
                      for (String[] rm : eng1[fl-1]) {
                          String roomNo   = rm[0];
                          String roomDesc = rm[1];
                          String roomName = roomNo + "호";
                          /* floorRoutes에서 경로 포인트 찾기 */
                          String pts = ""; String rname = "";
                          for (Map<String,String> r : floorRoutes) {
                              if (roomName.equals(r.get("room")) || roomNo.equals(r.get("room"))) {
                                  pts   = r.get("points"); rname = r.get("name"); break;
                              }
                          }
                          boolean hasPts = !pts.isEmpty();
                          String sel = roomName.equals(paramDestRoom) ? " selected" : "";
                          out.print("<option value=\"" + roomNo + "\""
                              + " data-room=\"" + roomName + "\""
                              + " data-floor=\"" + fl + "\""
                              + " data-points='" + (hasPts ? esc(pts).replace("'","&#39;") : "") + "'"
                              + " data-has-route=\"" + hasPts + "\""
                              + sel + ">"
                              + roomName + " — " + roomDesc
                              + "</option>");
                      }
                      out.print("</optgroup>");
                  }
              } else {
                  /* 다른 건물: floorRoutes 기반 */
                  for (Map<String,String> r : floorRoutes) {
                      if (!r.get("room").isEmpty()) {
                          out.print("<option value=\"" + esc(r.get("id")) + "\""
                              + " data-room=\"" + esc(r.get("room")) + "\""
                              + " data-floor=\"" + esc(r.get("floor")) + "\""
                              + " data-points='" + esc(r.get("points")).replace("'","&#39;") + "'"
                              + " data-has-route=\"true\""
                              + (r.get("room").equals(paramDestRoom) ? " selected" : "") + ">"
                              + esc(r.get("room"))
                              + (r.get("name").isEmpty() ? "" : " — " + esc(r.get("name")))
                              + "</option>");
                      }
                  }
              }
              %>
            </select>
          </div>

          <div class="divider"></div>
          <button class="btn-teal" onclick="showAutoRoute()" id="btnShowRoute">
            <i class="bi bi-compass-fill"></i>실내 경로 보기
          </button>
          <div class="divider"></div>
          <div class="result-box" id="resultBox">
            <% if (!paramDestRoom.isEmpty() && !autoPoints.isEmpty()) { %>
            ✅ <%= esc(paramDestRoom) %>까지 경로가 준비되었습니다.
            <% } else if (!paramDestRoom.isEmpty()) { %>
            ⚠️ <%= esc(paramDestRoom) %>의 실내 경로가 아직 등록되지 않았습니다.
            <% } else { %>
            목적지 호실을 선택하세요.
            <% } %>
          </div>
        </div>
      </div>

      <% } %>
    </div><!-- /좌측 -->

    <!-- ════ 우측: 도면 ════ -->
    <div class="col-xl-8 col-lg-7">
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-map-fill"></i></div>
          <div>
            <div class="ch-title"><%= esc(paramBuilding) %> 도면</div>
            <div class="ch-sub">
              <% if (isAdmin) { %>도면을 클릭해 경로 포인트를 추가하세요
              <% } else { %>실내 경로가 파란 선으로 표시됩니다<% } %>
            </div>
          </div>
        </div>
        <div class="card-body" style="padding-bottom:0;">
          <div id="dimTabRow" style="display:flex;gap:8px;margin-bottom:10px;"></div>
          <div class="floorplan-wrap" id="floorplanWrap">
            <iframe id="floorIframe" src="" style="width:100%;height:560px;border:none;border-radius:var(--r);display:none;"></iframe>
            <div id="gallery3d" style="display:none;position:relative;background:#0f172a;border-radius:14px;overflow:hidden;">
              <img id="galleryImg" src="" alt="3D 도면" style="width:100%;max-height:560px;object-fit:contain;display:block;">
            </div>
            <div id="fpPlaceholder" class="fp-placeholder" style="display:flex;">
              <i class="bi bi-map"></i>
              <p>도면 이미지 준비 중</p>
              <% if (isAdmin) { %><p style="font-size:12px;">왼쪽에서 도면 이미지 경로를 입력하세요</p><% } %>
            </div>
            <% if (isAdmin) { %>
            <div class="map-toolbar">
              <button class="tb-btn active" id="btnModeAdd" onclick="setMode('add')"><i class="bi bi-plus-circle"></i>경로 찍기</button>
              <button class="tb-btn tb-amber" id="btnModePin" onclick="setMode('pin')"><i class="bi bi-geo-fill"></i>마커 위치</button>
              <button class="tb-btn" id="btnModeView" onclick="setMode('view')"><i class="bi bi-hand-index"></i>보기</button>
            </div>
            <% } %>
            <canvas id="routeCanvas"></canvas>
            <canvas id="clickCanvas"></canvas>
            <div class="map-tooltip" id="mapTooltip"></div>
            <div class="map-overlay" id="mapOverlay">
              <span class="ov-badge blue" id="ovBadge">대기 중</span>
              <span id="ovText">경로를 불러오는 중...</span>
            </div>
          </div><!-- /floorplan-wrap -->
          <!-- ── 층수 선택 탭 (도면 아래) ── -->
          <div id="floorTabWrap" style="display:none;border-top:1px solid var(--line);padding:12px 0 4px;">
            <div style="font-size:11px;font-weight:700;color:var(--txt3);margin-bottom:8px;display:flex;align-items:center;gap:5px;">
              <i class="bi bi-layers-fill" style="color:var(--teal);"></i> 층 선택
            </div>
            <div class="floor-tabs" id="floorTabRow" style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:8px;"></div>
          </div>
        </div>
      </div>
    </div><!-- /우측 -->
  </div><!-- /row -->
</div><!-- /shell -->

<script>
/* ── URL 파라미터 받기 ── */
const paramFloor = '<%= esc(paramFloor) %>';

/* ── 건물별 2D/3D 도면 데이터 ── */
var floorMaps = {
  '1공학관': {
    '2D': { html: '/CAN/floormaps/eng1.html', floors: ['1','2','3','4','5'] },
    '3D': { floors: ['1','2','3','4','5'], gallery: {
      '1': ['/CAN/images/3d/eng1-3d-1.png'],
      '2': ['/CAN/images/3d/eng1-3d-2.png'],
      '3': ['/CAN/images/3d/eng1-3d-3.png'],
      '4': ['/CAN/images/3d/eng1-3d-4.png'],
      '5': ['/CAN/images/3d/eng1-3d-5.png']
    }}
  },
  '2공학관': {
    '2D': { html: '/CAN/floormaps/eng2.html', floors: ['지하','1','2','3','4','5'] },
    '3D': { floors: ['지하','1','2','3','4','5'], gallery: { '지하':['/CAN/images/3d/eng2-b1.png'],'1':['/CAN/images/3d/eng2-1f.png'],'2':['/CAN/images/3d/eng2-2f.png'],'3':['/CAN/images/3d/eng2-3f.png'],'4':['/CAN/images/3d/eng2-4f.png'],'5':['/CAN/images/3d/eng2-5f.png'] } }
  },
  '대학본부': {
    '2D': { html: '/CAN/floormaps/main.html', floors: ['지하','1','2','3','4','5'] },
    '3D': { floors: ['지하','1','2','3','4','5'], gallery: { '지하':['/CAN/images/3d/main-b1.png'],'1':['/CAN/images/3d/main-1f.png'],'2':['/CAN/images/3d/main-2f.png'],'3':['/CAN/images/3d/main-3f.png'],'4':['/CAN/images/3d/main-4f.png'],'5':['/CAN/images/3d/main-5f.png'] } }
  },
  '산학협력관':  { '2D': { html: '/CAN/floormaps/collab.html', floors: ['1','2','3','4','5'] }, '3D': null },
  '산업협력학관': { '2D': { html: '/CAN/floormaps/collab.html', floors: ['1','2','3','4','5'] }, '3D': null },
  '1생활관':     { '2D': { html: '/CAN/floormaps/dorm1.html', floors: ['1','2','3','4','5'] }, '3D': null },
  '2생활관':     { '2D': { html: '/CAN/floormaps/dorm2.html', floors: ['1','2','3','4','5'] }, '3D': null },
  '학생회관':    { '2D': { html: '/CAN/floormaps/student.html' },
                 '3D': { floors: ['1','2','3','4','5'], gallery: {
                   '1': ['/CAN/images/3d/stu-1.png'],
                   '2': ['/CAN/images/3d/stu-2.png'],
                   '3': ['/CAN/images/3d/stu-3.png'],
                   '4': ['/CAN/images/3d/stu-4.png'],
                   '5': ['/CAN/images/3d/stu-5.png']
                 }}}
};
var curDim = '3D', curFloor = '', curGalleryList = [], curGalleryIdx = 0;

function initFloorDiagram() {
  var bldg = BUILDING;
  var info = floorMaps[bldg];
  if (!info) return;
  var dimRow = document.getElementById('dimTabRow');
  dimRow.innerHTML = '';
  ['3D','2D'].forEach(function(d) {
    if (!info[d]) return;
    var btn = document.createElement('button');
    btn.className = 'floor-tab' + (d === curDim ? ' active' : '');
    btn.textContent = d + ' 도면';
    btn.onclick = function() { switchDimFloor(d); };
    dimRow.appendChild(btn);
  });
  renderFloorDiagram();
}

function switchDimFloor(dim) {
  curDim = dim;
  document.querySelectorAll('#dimTabRow .floor-tab').forEach(function(btn) {
    btn.classList.toggle('active', btn.textContent === dim + ' 도면');
  });
  renderFloorDiagram();
}

function floorLabel(f) {
  if (f === '지하') return 'B1';
  if (/^\d+$/.test(f)) return f + '층';
  return f;
}

function renderFloorDiagram() {
  var info    = floorMaps[BUILDING];
  var dimInfo = info && info[curDim];
  var iframe  = document.getElementById('floorIframe');
  var gallery = document.getElementById('gallery3d');
  var ph      = document.getElementById('fpPlaceholder');
  var tabRow  = document.getElementById('floorTabRow');
  var tabWrap = document.getElementById('floorTabWrap');
  var rCv     = document.getElementById('routeCanvas');
  var cCv     = document.getElementById('clickCanvas');

  iframe.style.display = 'none'; iframe.src = 'about:blank';
  gallery.style.display = 'none';
  ph.style.display = 'none';
  tabRow.innerHTML = '';
  if (tabWrap) tabWrap.style.display = 'none';

  if (!dimInfo) { ph.style.display = 'flex'; return; }

  if (curDim === '2D' && dimInfo.html) {
    iframe.src = dimInfo.html;
    iframe.style.display = 'block';
    rCv.style.display = 'block';
    cCv.style.display = 'block';                              /* 학부생도 마커 표시 */
    cCv.style.pointerEvents = IS_ADMIN ? 'auto' : 'none';    /* 학부생은 클릭 차단 */
    /* 2D 도면은 자체 iframe에서 층수 선택 - 탭은 표시 안 함 */
    if (tabWrap) tabWrap.style.display = 'none';
    setTimeout(function(){ resizeCanvas(); drawRoomMarkers(); }, 300);
    return;
  }

  if (curDim === '3D' && dimInfo.floors && dimInfo.gallery) {
    rCv.style.display = 'block';
    cCv.style.display = 'block';                              /* 학부생도 마커 표시 */
    cCv.style.pointerEvents = IS_ADMIN ? 'auto' : 'none';    /* 학부생은 클릭 차단 */
    cCv.style.cursor = IS_ADMIN && mode === 'add' ? 'crosshair' : 'default';
    /* paramFloor가 있으면 사용, 없으면 첫 번째 층 */
    curFloor = (paramFloor && dimInfo.floors.includes(paramFloor)) ? paramFloor : dimInfo.floors[0];

    /* 층수 버튼 생성 */
    dimInfo.floors.forEach(function(f) {
      var btn = document.createElement('button');
      btn.className = 'floor-tab' + (f === curFloor ? ' active' : '');
      btn.textContent = floorLabel(f);
      btn.onclick = function() {
        curFloor = f;
        tabRow.querySelectorAll('.floor-tab').forEach(function(b) {
          b.classList.toggle('active', b.textContent === floorLabel(f));
        });
        showGallery(dimInfo.gallery[f]);
        /* 자동선택 목적지 취소 및 경로 삭제 */
        const destRoomSelect = document.getElementById('destRoomInput');
        if (destRoomSelect) destRoomSelect.value = '';
        stopPulse();
        shownPoints = [];
        redraw(); updateOverlay();
        setTimeout(function(){ resizeCanvas(); drawRoomMarkers(); }, 120);
      };
      tabRow.appendChild(btn);
    });

    /* 층수 탭 영역 표시 (1개 이상이면 무조건 표시) */
    if (tabWrap) tabWrap.style.display = dimInfo.floors.length >= 1 ? 'block' : 'none';

    showGallery(dimInfo.gallery[curFloor]);
    gallery.style.display = 'block';
    setTimeout(function() {
      resizeCanvas();
      drawRoomMarkers();  /* 3D 도면에서 마커 그리기 */
    }, 300);
  }
}

function showGallery(list) {
  curGalleryList = list || []; curGalleryIdx = 0; updateGalleryImg();
}
function updateGalleryImg() {
  if (!curGalleryList.length) return;
  document.getElementById('galleryImg').src = curGalleryList[curGalleryIdx];
}

const IS_ADMIN  = <%= isAdmin %>;
const BUILDING  = '<%= esc(paramBuilding).replace("'","\\'") %>';
const DEST_ROOM = '<%= esc(paramDestRoom).replace("'","\\'") %>';
const ROOM_ID   = '<%= esc(paramRoomId).replace("'","\\'") %>';
const AUTO_PTS  = '<%= autoPoints.replace("'","\\'").replace("\n","").replace("\r","") %>';

const routeCanvas = document.getElementById('routeCanvas');
const clickCanvas = document.getElementById('clickCanvas');
const rCtx = routeCanvas.getContext('2d');
const cCtx = clickCanvas.getContext('2d');
const wrap = document.getElementById('floorplanWrap');
const img  = document.getElementById('floorplanImg');

let waypoints   = [];   // 관리자: 그리는 경로
let shownPoints = [];   // 학생: 표시 중인 경로
let mode = IS_ADMIN ? 'add' : 'view';
let activeRouteId = '';

/* ── 호실 마커 데이터 (DB에서 로드) ── */
let roomData = [
  <%
    boolean firstRm = true;
    for (Map<String,String> rm : buildingRooms) {
      if (!firstRm) out.print(",\n  ");
      firstRm = false;
      String px = rm.get("px"); String py = rm.get("py");
      if (px == null || px.isEmpty() || "null".equals(px)) px = "null";
      if (py == null || py.isEmpty() || "null".equals(py)) py = "null";
      String hasPos = (!"null".equals(px) && !"0".equals(px) && !"0.0".equals(px)) ? "true" : "false";
      out.print("{id:'" + esc(rm.get("id")) + "',"
              + "name:'" + esc(rm.get("name")) + "',"
              + "floor:'" + esc(rm.get("floor")) + "',"
              + "px:" + px + ","
              + "py:" + py + ","
              + "pinDim:'" + esc(rm.get("pinDim")) + "',"
              + "pinFloor:'" + esc(rm.get("pinFloor")) + "',"
              + "hasPos:" + hasPos + "}");
    }
  %>
];
let pinTargetId = '';
let pinTargetName = '';
let pinTargetFloor = '';
const ROOM_MARKER_HIT_R = 25;
const ROOM_MARKER_R     = 15;  /* 마커 원 반지름 */

/* ── 반짝임 애니메이션 ── */
let pulseTimer = null;
let pulsePhase = 0;
function startPulse() {
    if (pulseTimer) cancelAnimationFrame(pulseTimer);
    pulsePhase = 0;
    function tick() {
        pulsePhase += 0.08;
        drawRoomMarkers();
        pulseTimer = requestAnimationFrame(tick);
    }
    pulseTimer = requestAnimationFrame(tick);
}
function stopPulse() {
    if (pulseTimer) { cancelAnimationFrame(pulseTimer); pulseTimer = null; }
    pulsePhase = 0;
    drawRoomMarkers();
}
/* ── Canvas 크기 (DPI 보정) ── */
function resizeCanvas() {
    const dpr = window.devicePixelRatio || 1;
    const w = wrap.offsetWidth;
    const h = wrap.offsetHeight;
    routeCanvas.width  = clickCanvas.width  = w * dpr;
    routeCanvas.height = clickCanvas.height = h * dpr;
    routeCanvas.style.width  = clickCanvas.style.width  = w + 'px';
    routeCanvas.style.height = clickCanvas.style.height = h + 'px';
    rCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    redraw();
}
if (img) img.addEventListener('load', resizeCanvas);
window.addEventListener('resize', resizeCanvas);
setTimeout(resizeCanvas, 200);

/* ── 모드 전환 (관리자) ── */
function setMode(m) {
    mode = m;
    clickCanvas.className = m === 'view' ? 'mode-view' : '';
    if (m === 'add')       clickCanvas.style.cursor = 'crosshair';
    else if (m === 'pin')  clickCanvas.style.cursor = 'crosshair';
    else                   clickCanvas.style.cursor = 'default';
    if (IS_ADMIN) {
        var bAdd = document.getElementById('btnModeAdd');
        var bPin = document.getElementById('btnModePin');
        var bView= document.getElementById('btnModeView');
        if (bAdd)  bAdd.classList.toggle('active', m==='add');
        if (bPin)  bPin.classList.toggle('active', m==='pin');
        if (bView) bView.classList.toggle('active', m==='view');
    }
    /* 좌측 탭도 동기화 */
    if (m === 'pin') switchAdminTab('pin', true);
    else if (m === 'add') switchAdminTab('route', true);
    drawRoomMarkers();
}

/* ── 좌측 탭 전환: 경로 그리기 / 마커 위치 설정 ── */
function switchAdminTab(tab, fromSetMode) {
    var tabRoute   = document.getElementById('tabRoute');
    var tabPin     = document.getElementById('tabPin');
    var tabRouteBtn= document.getElementById('tabRouteBtn');
    var tabPinBtn  = document.getElementById('tabPinBtn');
    if (!tabRoute || !tabPin) return;
    if (tab === 'pin') {
        tabRoute.style.display = 'none';
        tabPin.style.display   = 'block';
        tabRouteBtn.classList.remove('active');
        tabPinBtn.classList.add('active');
        if (!fromSetMode && mode !== 'pin') setMode('pin');
    } else {
        tabRoute.style.display = 'block';
        tabPin.style.display   = 'none';
        tabRouteBtn.classList.add('active');
        tabPinBtn.classList.remove('active');
        if (!fromSetMode && mode === 'pin') setMode('add');
    }
}

/* ── 호실 선택 드롭다운 변경 ── */
function onPinRoomChange(sel) {
    var opt = sel.options[sel.selectedIndex];
    var info = document.getElementById('pinTargetInfo');
    if (!opt.value) {
        pinTargetId = '';
        pinTargetName = '';
        pinTargetFloor = '';
        if (info) info.style.display = 'none';
        drawRoomMarkers();
        return;
    }
    pinTargetId    = opt.value;
    pinTargetName  = opt.dataset.name;
    pinTargetFloor = opt.dataset.floor;
    if (info) {
        info.style.display = 'flex';
        document.getElementById('pinTargetName').textContent = pinTargetName + ' (' + pinTargetFloor + '층)';
    }
    /* 해당 호실의 층으로 자동 전환 */
    var info2 = floorMaps[BUILDING];
    var dimInfo = info2 && info2[curDim];
    if (dimInfo && dimInfo.floors && dimInfo.floors.indexOf(pinTargetFloor) >= 0) {
        curFloor = pinTargetFloor;
        if (dimInfo.gallery) showGallery(dimInfo.gallery[curFloor]);
        var tabRow = document.getElementById('floorTabRow');
        if (tabRow) tabRow.querySelectorAll('.floor-tab').forEach(function(b) {
            b.classList.toggle('active', b.textContent === floorLabel(pinTargetFloor));
        });
    }
    if (mode !== 'pin') setMode('pin');
    setTimeout(drawRoomMarkers, 150);
    var rb = document.getElementById('pinResultBox');
    if (rb) rb.textContent = '✏️ ' + pinTargetName + ' 위치를 도면에서 클릭하세요.';
}

/* ── 클릭 이벤트 (관리자: 경로 포인트 / 마커 위치 설정) ── */
clickCanvas.addEventListener('click', function(e) {
    if (!IS_ADMIN) return;
    const rect = clickCanvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;

    if (mode === 'pin') {
        /* 마커 위치 설정 모드 */
        /* 기존 마커 클릭 → 선택 */
        for (var i = roomData.length - 1; i >= 0; i--) {
            var rm = roomData[i];
            if (!rm.hasPos) continue;
            /* 현재 층에 속한 마커만 히트 */
            if (String(rm.floor) !== String(pinTargetFloor || curFloor)) continue;
            var dx = x - rm.px, dy = y - rm.py;
            if (Math.sqrt(dx*dx + dy*dy) <= ROOM_MARKER_HIT_R) {
                /* 선택 상태로 전환 */
                pinTargetId    = rm.id;
                pinTargetName  = rm.name;
                pinTargetFloor = rm.floor;
                var sel = document.getElementById('pinRoomSelect');
                if (sel) for (var k=0;k<sel.options.length;k++) if (sel.options[k].value===rm.id){sel.selectedIndex=k;break;}
                var info = document.getElementById('pinTargetInfo');
                if (info) {
                    info.style.display = 'flex';
                    document.getElementById('pinTargetName').textContent = rm.name + ' (' + rm.floor + '층)';
                }
                drawRoomMarkers();
                return;
            }
        }
        /* 빈 곳 클릭 → 선택된 호실에 좌표 저장 */
        if (!pinTargetId) { alert('왼쪽에서 위치를 설정할 호실을 먼저 선택하세요.'); return; }
        saveRoomPin(pinTargetId, x, y);
    } else if (mode === 'add') {
        /* 경로 포인트 추가 */
        waypoints.push({x, y});
        updateWpList();
        redraw();
        updateOverlay();
    }
});

/* ── 마커 저장 ── */
async function saveRoomPin(roomId, x, y) {
    try {
        const params = 'roomId=' + encodeURIComponent(roomId) +
                       '&pixelX=' + encodeURIComponent(x.toFixed(2)) +
                       '&pixelY=' + encodeURIComponent(y.toFixed(2)) +
                       '&pinDim=' + encodeURIComponent(curDim) +
                       '&pinFloor=' + encodeURIComponent(curFloor);
        const res = await fetch('/CAN/saveRoomPin.jsp', {
            method: 'POST',
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: params
        });
        const text = await res.text();
        if (text.trim() === 'OK') {
            /* 로컬 roomData 갱신 */
            for (var i=0; i<roomData.length; i++) {
                if (roomData[i].id === String(roomId)) {
                    roomData[i].px = x;
                    roomData[i].py = y;
                    roomData[i].pinDim = curDim;
                    roomData[i].pinFloor = curFloor;
                    roomData[i].hasPos = true;
                    break;
                }
            }
            drawRoomMarkers();
            /* 드롭다운에 ✓ 표시 갱신 */
            var sel = document.getElementById('pinRoomSelect');
            if (sel) {
                for (var k=0; k<sel.options.length; k++) {
                    if (sel.options[k].value === String(roomId)) {
                        var txt = sel.options[k].textContent.replace(' ✓','');
                        sel.options[k].textContent = txt + ' ✓';
                        break;
                    }
                }
            }
            var rb = document.getElementById('pinResultBox');
            if (rb) rb.textContent = '✅ ' + pinTargetName + ' 위치 저장 완료!';
            alert('✅ ' + pinTargetName + ' 위치 저장 완료!');
        } else {
            alert('저장 실패: ' + text);
        }
    } catch (err) {
        alert('오류: ' + err.message);
    }
}

/* ── 현재 층에 속한 호실 마커 그리기 ── */
function drawRoomMarkers() {
    if (!cCtx) return;
    const dpr = window.devicePixelRatio || 1;
    cCtx.save();
    cCtx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cCtx.clearRect(0, 0, clickCanvas.width/dpr, clickCanvas.height/dpr);

    roomData.forEach(function(rm) {
        if (!rm.hasPos) return;
        if (String(rm.floor) !== String(curFloor)) return;
        if (rm.pinDim && rm.pinDim !== curDim) return;

        var isSelected  = IS_ADMIN && rm.id === pinTargetId;
        var isHighlight = !IS_ADMIN && (rm.id === highlightRoomId || rm.name === highlightRoomId);

        /* 반짝임: 선택된 마커 주변에 파동 원 */
        if (isHighlight && pulseTimer !== null) {
            var pulseR = ROOM_MARKER_R + 6 + Math.sin(pulsePhase) * 8;
            var pulseAlpha = 0.5 + Math.sin(pulsePhase) * 0.4;
            cCtx.globalAlpha = Math.max(0, pulseAlpha);
            cCtx.beginPath();
            cCtx.arc(rm.px, rm.py, pulseR, 0, Math.PI*2);
            cCtx.fillStyle = '#ef4444';
            cCtx.fill();

            /* 2번째 파동 (위상 차이) */
            var pulseR2 = ROOM_MARKER_R + 6 + Math.sin(pulsePhase + Math.PI) * 8;
            var pulseAlpha2 = 0.3 + Math.sin(pulsePhase + Math.PI) * 0.25;
            cCtx.globalAlpha = Math.max(0, pulseAlpha2);
            cCtx.beginPath();
            cCtx.arc(rm.px, rm.py, pulseR2, 0, Math.PI*2);
            cCtx.fillStyle = '#fca5a5';
            cCtx.fill();
        }

        /* 외곽 그림자 */
        cCtx.globalAlpha = 0.25;
        cCtx.beginPath();
        cCtx.arc(rm.px, rm.py, ROOM_MARKER_R + 4, 0, Math.PI*2);
        cCtx.fillStyle = 'rgba(0,0,0,0.5)';
        cCtx.fill();

        /* 본체 */
        cCtx.globalAlpha = 1.0;
        var markerR = isHighlight ? ROOM_MARKER_R + 3 : ROOM_MARKER_R;
        cCtx.beginPath();
        cCtx.arc(rm.px, rm.py, markerR, 0, Math.PI*2);
        if (IS_ADMIN && mode === 'pin') {
            cCtx.fillStyle = isSelected ? '#f59e0b' : '#0ea5e9';
        } else if (isHighlight) {
            cCtx.fillStyle = '#ef4444';
        } else {
            cCtx.fillStyle = '#10b981';
        }
        cCtx.fill();
        cCtx.strokeStyle = '#fff';
        cCtx.lineWidth = isHighlight ? 3 : 2.5;
        cCtx.stroke();

        /* 라벨 */
        cCtx.fillStyle = '#fff';
        cCtx.font = 'bold ' + (isHighlight ? '11' : '10') + 'px sans-serif';
        cCtx.textAlign = 'center';
        cCtx.textBaseline = 'middle';
        var lbl = rm.name.replace(/호$/,'');
        if (lbl.length > 4) lbl = lbl.slice(-4);
        cCtx.fillText(lbl, rm.px, rm.py);

        cCtx.globalAlpha = 1.0;
    });
    cCtx.restore();
}

clickCanvas.addEventListener('mousemove', function(e) {
    const tip = document.getElementById('mapTooltip');
    if (!IS_ADMIN || (mode !== 'add' && mode !== 'pin')) { 
        tip.style.display='none'; 
        return; 
    }
    clickCanvas.style.cursor = 'crosshair';
    tip.style.display='block';
    tip.style.left=(e.offsetX+14)+'px';
    tip.style.top=(e.offsetY+14)+'px';
    if (mode === 'pin') {
        tip.textContent = pinTargetId ? ('📍 ' + pinTargetName + ' 위치로 지정') : '호실을 먼저 선택하세요';
    } else {
        tip.textContent='클릭하여 경로 포인트 추가';
    }
});
clickCanvas.addEventListener('mouseleave', ()=>document.getElementById('mapTooltip').style.display='none');

/* ── 경로 그리기 ── */
function redraw() {
    rCtx.clearRect(0, 0, routeCanvas.width, routeCanvas.height);
    const pts = IS_ADMIN ? waypoints : shownPoints;
    if (pts.length < 1) return;

    rCtx.beginPath();
    rCtx.moveTo(pts[0].x, pts[0].y);
    for (let i=1; i<pts.length; i++) rCtx.lineTo(pts[i].x, pts[i].y);
    rCtx.strokeStyle = IS_ADMIN ? '#1a56db' : '#0d9488';
    rCtx.lineWidth   = 5;
    rCtx.lineCap     = 'round';
    rCtx.lineJoin    = 'round';
    rCtx.shadowColor = IS_ADMIN ? 'rgba(26,86,219,.4)' : 'rgba(13,148,136,.4)';
    rCtx.shadowBlur  = 10;
    rCtx.stroke();
    rCtx.shadowBlur  = 0;

    pts.forEach(function(wp, i) {
        const isFirst=i===0, isLast=i===pts.length-1;
        rCtx.beginPath();
        rCtx.arc(wp.x, wp.y, isFirst||isLast?11:8, 0, Math.PI*2);
        rCtx.fillStyle = isFirst?'#16a34a':isLast?'#dc2626':'#1a56db';
        rCtx.fill();
        rCtx.strokeStyle='#fff'; rCtx.lineWidth=2.5; rCtx.stroke();
        rCtx.fillStyle='#fff'; rCtx.font='bold 10px sans-serif';
        rCtx.textAlign='center'; rCtx.textBaseline='middle';
        rCtx.fillText(isFirst?'S':isLast?'E':String(i), wp.x, wp.y);
    });
}

/* ── 오버레이 ── */
function updateOverlay() {
    const ov=document.getElementById('mapOverlay');
    const badge=document.getElementById('ovBadge');
    const text=document.getElementById('ovText');
    if (IS_ADMIN) {
        if(waypoints.length>0){ov.classList.add('show');badge.className='ov-badge blue';badge.textContent='포인트 '+waypoints.length+'개';text.textContent='저장 버튼을 눌러 경로를 저장하세요';}
        else ov.classList.remove('show');
    } else {
        if(shownPoints.length>0){ov.classList.add('show');badge.className='ov-badge teal';badge.textContent='경로 표시 중';text.textContent=DEST_ROOM+'까지 안내 중';}
        else ov.classList.remove('show');
    }
}
function setResult(msg){const el=document.getElementById('resultBox');if(el)el.textContent=msg;}

/* ── 관리자: 경유점 목록 ── */
function updateWpList() {
    const list=document.getElementById('wpList');
    if(!list)return;
    list.innerHTML='';
    if(waypoints.length===0){list.innerHTML='<div class="wp-empty">아직 찍은 포인트가 없습니다</div>';return;}
    waypoints.forEach(function(wp,i){
        const item=document.createElement('div');
        item.className='wp-item';
        item.innerHTML='<div class="wp-num">'+(i+1)+'</div>'+
            '<div class="wp-coord">x:'+Math.round(wp.x)+'  y:'+Math.round(wp.y)+'</div>'+
            '<button class="wp-del" onclick="removeWp('+i+')"><i class="bi bi-x"></i></button>';
        list.appendChild(item);
    });
}
function removeWp(i){waypoints.splice(i,1);updateWpList();redraw();updateOverlay();}
function undoLast(){if(waypoints.length>0){waypoints.pop();updateWpList();redraw();updateOverlay();}}
function clearRoute(){waypoints=[];shownPoints=[];updateWpList();redraw();updateOverlay();setResult('초기화되었습니다.');}

/* ── 관리자: 도면 이미지 실시간 교체 ── */
function updateFloorplanImg(src) {
    const ph      = document.getElementById('fpPlaceholder');
    const iframe  = document.getElementById('floorIframe');
    const gallery = document.getElementById('gallery3d');
    const dimRow  = document.getElementById('dimTabRow');
    let el = document.getElementById('customFloorImg');
    
    if (!src || src.trim() === '') {
        /* 도면 경로가 없으면 → floorMaps 도면 표시 (복원) */
        if (el) el.style.display = 'none';
        if(ph) ph.style.display = 'none';
        if(dimRow) dimRow.style.display = 'flex';  /* 도면 탭 표시 */
        renderFloorDiagram();  /* floorMaps 도면 다시 렌더링 */
        return;
    }
    
    /* 도면 경로가 입력되면 → 커스텀 이미지 표시 */
    if (!el) {
        el = document.createElement('img');
        el.id = 'customFloorImg';
        el.style.cssText = 'width:100%;height:560px;object-fit:contain;display:block;';
        el.alt = BUILDING + ' 도면';
        wrap.insertBefore(el, wrap.firstChild);
        el.addEventListener('load', resizeCanvas);
    }
    
    iframe.style.display = 'none'; iframe.src = 'about:blank';
    gallery.style.display = 'none';
    if(dimRow) dimRow.style.display = 'none';  /* 도면 탭 숨김 */
    if(ph) ph.style.display = 'none';
    el.src = src; el.style.display = 'block';
    resizeCanvas();
}

/* ── 관리자: 실내 경로 저장 ── */
function onDestRoomSelect(sel) {
    const opt = sel.options[sel.selectedIndex];
    if (!opt.value) return;
    const floor = opt.dataset.floor || '';
    const roomName = opt.value;
    const floorInput = document.getElementById('floorInput');
    if (floorInput) floorInput.value = floor;
    const routeNameInput = document.getElementById('routeNameInput');
    if (routeNameInput) routeNameInput.value = '입구 → ' + roomName;
    if (floor) switchFloor(floor);
    /* 마커 반짝거리기 효과 */
    setTimeout(function() {
        /* roomData에서 해당 호실 찾기 */
        var targetMarker = null;
        for (var i = 0; i < roomData.length; i++) {
            if (roomData[i].name === roomName) {
                targetMarker = roomData[i];
                break;
            }
        }
        if (targetMarker && targetMarker.hasPos) startPulse();
    }, 200);
}

async function saveFloorRoute() {
    if(waypoints.length<2){alert('경로 포인트를 2개 이상 찍어주세요.');return;}
    const destRoom  = document.getElementById('destRoomInput').value.trim();
    const floor     = document.getElementById('floorInput').value.trim();
    const routeName = document.getElementById('routeNameInput').value.trim();
    const floorImg  = document.getElementById('floorImgInput').value.trim();
    if(!destRoom){alert('목적지 호실을 입력하세요.');return;}
    const btn=document.getElementById('btnSave');
    btn.disabled=true;btn.innerHTML='<i class="bi bi-hourglass-split"></i>저장 중...';
    try {
        const res=await fetch('/CAN/saveFloorRoute.jsp',{
            method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'building='+encodeURIComponent(BUILDING)+
                 '&destRoom='+encodeURIComponent(destRoom)+
                 '&floor='+encodeURIComponent(floor)+
                 '&routeName='+encodeURIComponent(routeName)+
                 '&floorplanImg='+encodeURIComponent(floorImg)+
                 '&roomId='+encodeURIComponent(ROOM_ID)+
                 '&points='+encodeURIComponent(JSON.stringify(waypoints))
        });
        const text=await res.text();
        if(text.trim()==='OK'){
            setResult('✅ 실내 경로 저장 완료!\n'+destRoom+' · 포인트 '+waypoints.length+'개');
            location.reload();
        } else setResult('⚠️ 저장 실패: '+text);
    }catch(e){setResult('⚠️ 오류: '+e.message);}
    finally{btn.disabled=false;btn.innerHTML='<i class="bi bi-floppy-fill"></i>경로 저장하기';}
}

/* ── 관리자: 경로 미리보기 / 삭제 ── */
function loadFloorRoute(id, pointsJson) {
    try {
        shownPoints = JSON.parse(pointsJson) || [];
        waypoints   = JSON.parse(pointsJson) || [];
        updateWpList(); redraw(); updateOverlay();
        /* 활성 스타일 */
        document.querySelectorAll('.route-item').forEach(el=>el.classList.remove('active-route'));
        const ri = document.getElementById('ri-'+id);
        if(ri) ri.classList.add('active-route');
        activeRouteId = id;
    } catch(e){ alert('경로 파싱 실패: '+e.message); }
}

async function deleteFloorRoute(id) {
    if(!confirm('이 경로를 삭제하시겠습니까?'))return;
    try{
        await fetch('/CAN/deleteFloorRoute.jsp?routeId='+id,{method:'POST'});
        location.reload();
    }catch(e){alert('삭제 실패: '+e.message);}
}

/* ── 학생: 자동 경로 표시 ── */
function showAutoRoute() {
    /* 1순위: 드롭다운에서 선택한 호실의 경로 */
    const sel = document.getElementById('roomSelect');
    const opt = sel && sel.options[sel.selectedIndex];
    const selPtsRaw = opt && opt.dataset.points;
    const selRoom   = opt && (opt.dataset.room || opt.value);

    if (selPtsRaw) {
        try {
            const selPts = JSON.parse(selPtsRaw);
            if (selPts && selPts.length > 0) {
                shownPoints = selPts;
                redraw(); updateOverlay();
                setResult('✅ ' + (selRoom || DEST_ROOM) + '까지 실내 경로\n포인트 ' + selPts.length + '개 표시 중');
                return;
            }
        } catch(e) {}
    }

    /* 2순위: URL 파라미터로 넘어온 자동 경로 (AUTO_PTS) */
    const pts = AUTO_PTS ? JSON.parse(AUTO_PTS) : null;
    if (!pts || pts.length === 0) {
        setResult('⚠️ 등록된 실내 경로가 없습니다.\n관리자에게 경로 등록을 요청하세요.');
        return;
    }
    shownPoints = pts;
    redraw(); updateOverlay();
    setResult('✅ ' + DEST_ROOM + '까지 실내 경로\n포인트 ' + pts.length + '개 표시 중');
}

/* ── 학생: 호실 드롭다운 변경 ── */
/* 학부생 강조 마커 ID */
let highlightRoomId = '';

function onRoomChange(sel) {
    const opt = sel.options[sel.selectedIndex];
    if (!opt.value) {
        shownPoints=[]; highlightRoomId='';
        stopPulse();
        redraw(); updateOverlay(); drawRoomMarkers();
        setResult('목적지 호실을 선택하세요.');
        return;
    }

    const roomNo    = opt.value;
    const roomName  = opt.dataset.room  || '';
    const hasRoute  = opt.dataset.hasRoute === 'true';
    const pts       = opt.dataset.points || '';

    /* roomData에서 해당 호실 마커 찾기 (room_id 또는 이름 매칭) */
    var markerRoom = null;
    for (var i = 0; i < roomData.length; i++) {
        var rm = roomData[i];
        if (rm.id === roomNo || rm.name === roomName || rm.name === roomNo + '호') {
            markerRoom = rm; break;
        }
    }

    highlightRoomId = markerRoom ? markerRoom.id : roomNo;

    /* 마커가 있으면 해당 dim + 층으로 자동 전환 */
    if (markerRoom && markerRoom.hasPos) {
        var targetDim   = markerRoom.pinDim   || curDim;
        var targetFloor = markerRoom.pinFloor || opt.dataset.floor || '';

        /* dim 전환 */
        if (targetDim !== curDim) {
            curDim = targetDim;
            document.querySelectorAll('#dimTabRow .floor-tab').forEach(function(b) {
                b.classList.toggle('active', b.textContent === targetDim + ' 도면');
            });
            renderFloorDiagram();
        }

        /* 층 전환 */
        if (targetFloor && targetFloor !== String(curFloor)) {
            var info    = floorMaps[BUILDING];
            var dimInfo = info && info[curDim];
            if (dimInfo && dimInfo.floors && dimInfo.floors.indexOf(targetFloor) >= 0) {
                curFloor = targetFloor;
                if (dimInfo.gallery) showGallery(dimInfo.gallery[targetFloor]);
                var tabRow = document.getElementById('floorTabRow');
                if (tabRow) tabRow.querySelectorAll('.floor-tab').forEach(function(b) {
                    b.classList.toggle('active', b.textContent === floorLabel(targetFloor));
                });
                setTimeout(resizeCanvas, 150);
            }
        }
    } else {
        /* 마커 없으면 층만 전환 */
        var floorVal = opt.dataset.floor || '';
        if (floorVal && floorVal !== String(curFloor)) {
            var info2    = floorMaps[BUILDING];
            var dimInfo2 = info2 && info2[curDim];
            if (dimInfo2 && dimInfo2.floors && dimInfo2.floors.indexOf(floorVal) >= 0) {
                curFloor = floorVal;
                if (dimInfo2.gallery) showGallery(dimInfo2.gallery[floorVal]);
                var tabRow2 = document.getElementById('floorTabRow');
                if (tabRow2) tabRow2.querySelectorAll('.floor-tab').forEach(function(b) {
                    b.classList.toggle('active', b.textContent === floorLabel(floorVal));
                });
                setTimeout(resizeCanvas, 150);
            }
        }
    }

    /* 경로 표시 */
    if (hasRoute && pts) {
        try {
            shownPoints = JSON.parse(pts) || [];
            redraw(); updateOverlay();
            setResult('✅ ' + roomName + '까지 경로 안내 중');
        } catch(e) { setResult('경로 데이터 오류'); }
    } else {
        shownPoints = []; redraw(); updateOverlay();
        setResult(roomName + (markerRoom && markerRoom.hasPos ? ' — 도면에서 위치를 확인하세요.' : ' — 경로가 아직 등록되지 않았습니다.'));
    }

    /* 마커 강조 + 반짝임 시작 */
    setTimeout(function() {
        drawRoomMarkers();
        if (markerRoom && markerRoom.hasPos) startPulse();
    }, 200);
}

/* ── 초기화 ── */
window.addEventListener('load', function() {
    initFloorDiagram();
    setTimeout(function() {
        resizeCanvas();
        /* detail.jsp 자동선택 목적지: 경로 표시 + 호실 드롭다운 선택 */
        console.log('=== Load event ===');
        console.log('paramFloor:', paramFloor);
        console.log('AUTO_PTS:', AUTO_PTS);
        console.log('DEST_ROOM:', DEST_ROOM);
        if (paramFloor && AUTO_PTS) {
            console.log('Condition met, processing...');
            try {
                shownPoints = JSON.parse(AUTO_PTS) || [];
                redraw(); updateOverlay();
            } catch(e) {}
            /* 드롭다운 자동 선택 및 마커 표시 */
            const destRoomSelect = document.getElementById('destRoomInput');

            if (destRoomSelect) {
                /* 관리자 모드: 드롭다운이 있음 */
                if (!destRoomSelect.value || destRoomSelect.value === '') {
                    var destNum = DEST_ROOM.replace('호', '').trim();
                    for (var i = 0; i < roomData.length; i++) {
                        var roomNum = roomData[i].name.replace('호', '').trim();
                        if (roomNum === destNum) {
                            destRoomSelect.value = roomData[i].name;
                            break;
                        }
                    }
                }
                if (destRoomSelect.value) {
                    onDestRoomSelect(destRoomSelect);
                }
            } else {
                /* 학생 모드: 드롭다운 없음 → 직접 highlightRoomId 설정 */
                var destNum = DEST_ROOM.replace('호', '').trim();
                for (var i = 0; i < roomData.length; i++) {
                    var roomNum = roomData[i].name.replace('호', '').trim();
                    if (roomNum === destNum) {
                        highlightRoomId = roomData[i].id;
                        console.log('✅ Set highlightRoomId:', highlightRoomId);
                        break;
                    }
                }
            }

            /* 마커 반짝거리기 직접 호출 */
            setTimeout(function() {
                console.log('✨ startPulse called');
                startPulse();
            }, 300);
        }
        /* 항상 마커 그리기 (학부생/관리자 모두) */
        drawRoomMarkers();
    }, 500);
});

function escHtml(s){if(!s)return'';return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
</script>
</body>
</html>
