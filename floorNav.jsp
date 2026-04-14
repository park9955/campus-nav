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
        rs.close(); ps.close(); conn.close();
    } catch(Exception ex) { dbErr = ex.getMessage(); }

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
<title>ICT CampusNav — <%= esc(paramBuilding) %> 실내 안내</title>
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
.floorplan-wrap{position:relative;width:100%;background:#0f172a;border-radius:14px;overflow:hidden;border:1px solid var(--line);user-select:none;}
#floorplanImg{width:100%;height:560px;object-fit:contain;display:block;}
.fp-placeholder{height:400px;display:flex;align-items:center;justify-content:center;flex-direction:column;gap:12px;color:rgba(255,255,255,.4);}
.fp-placeholder i{font-size:56px;}
.fp-placeholder p{font-size:14px;}
#routeCanvas{position:absolute;top:0;left:0;width:100%;height:100%;pointer-events:none;}
#clickCanvas{position:absolute;top:0;left:0;width:100%;height:100%;cursor:crosshair;}
#clickCanvas.mode-view{cursor:default;}

/* 툴바 */
.map-toolbar{position:absolute;top:10px;left:10px;z-index:10;display:flex;gap:5px;flex-wrap:wrap;}
.tb-btn{background:rgba(255,255,255,.93);border:1.5px solid var(--line);border-radius:8px;padding:5px 11px;font-size:12px;font-weight:600;cursor:pointer;display:flex;align-items:center;gap:5px;color:var(--txt);transition:all .15s;font-family:var(--sans);}
.tb-btn:hover{background:#fff;border-color:var(--blue);color:var(--blue);}
.tb-btn.active{background:var(--blue);color:#fff;border-color:var(--blue);}

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
    <a href="javascript:history.back()" class="chip"><i class="bi bi-arrow-left"></i>뒤로</a>
    <a href="/CampusNav/navigationTest1.jsp" class="chip"><i class="bi bi-map"></i>캠퍼스 지도</a>
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
        <div><strong>관리자 모드</strong> — 도면 위에 실내 경로를 그려 저장하세요.</div>
      </div>

      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-building"></i></div>
          <div><div class="ch-title">경로 정보</div><div class="ch-sub">저장할 경로의 목적지 호실 입력</div></div>
        </div>
        <div class="card-body">
          <label class="f-label">건물</label>
          <input type="text" class="f-input mb-2" value="<%= esc(paramBuilding) %>" readonly style="background:var(--bg2);color:var(--txt2);">
          <label class="f-label">목적지 호실</label>
          <input type="text" class="f-input mb-2" id="destRoomInput" placeholder="예: 1206호" value="<%= esc(paramDestRoom) %>">
          <label class="f-label">층</label>
          <input type="text" class="f-input mb-2" id="floorInput" placeholder="예: 2" value="<%= esc(paramFloor) %>">
          <label class="f-label">경로 이름 <span style="font-weight:400;color:var(--txt3)">(선택)</span></label>
          <input type="text" class="f-input" id="routeNameInput" placeholder="예: 입구 → 1206호">
          <div class="divider"></div>
          <label class="f-label">도면 이미지 경로 <span style="font-weight:400;color:var(--txt3)">(선택)</span></label>
          <input type="text" class="f-input" id="floorImgInput"
                 placeholder="예: /CampusNav/images/floors/eng1_2f.png"
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
              <% for (Map<String,String> r : floorRoutes) {
                   if (!r.get("room").isEmpty()) { %>
              <option value="<%= esc(r.get("id")) %>"
                      data-room="<%= esc(r.get("room")) %>"
                      data-points="<%= esc(r.get("points")) %>"
                      <%= r.get("room").equals(paramDestRoom) ? "selected" : "" %>>
                <%= esc(r.get("room")) %><% if(!r.get("name").isEmpty()){ %> — <%= esc(r.get("name")) %><% } %>
              </option>
              <% } } %>
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
          <div class="floorplan-wrap" id="floorplanWrap">
            <% if (!floorplanImg.isEmpty()) { %>
            <img id="floorplanImg" src="<%= esc(floorplanImg) %>" alt="<%= esc(paramBuilding) %> 도면"
                 onerror="this.style.display='none';document.getElementById('fpPlaceholder').style.display='flex';">
            <% } %>
            <div id="fpPlaceholder" style="display:<%= floorplanImg.isEmpty() ? "flex" : "none" %>;" class="fp-placeholder">
              <i class="bi bi-map"></i>
              <p>도면 이미지 준비 중</p>
              <% if (isAdmin) { %><p style="font-size:12px;">왼쪽에서 도면 이미지 경로를 입력하세요</p><% } %>
            </div>
            <% if (isAdmin) { %>
            <div class="map-toolbar">
              <button class="tb-btn active" id="btnModeAdd" onclick="setMode('add')"><i class="bi bi-plus-circle"></i>경로 찍기</button>
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
          </div>
        </div>
      </div>
    </div><!-- /우측 -->
  </div><!-- /row -->
</div><!-- /shell -->

<script>
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
    if (IS_ADMIN) {
        document.getElementById('btnModeAdd').classList.toggle('active', m==='add');
        document.getElementById('btnModeView').classList.toggle('active', m==='view');
    }
}

/* ── 클릭 이벤트 (관리자: 경로 포인트 추가) ── */
clickCanvas.addEventListener('click', function(e) {
    if (!IS_ADMIN || mode !== 'add') return;
    const rect = clickCanvas.getBoundingClientRect();
    const x = e.clientX - rect.left;
    const y = e.clientY - rect.top;
    waypoints.push({x, y});
    updateWpList();
    redraw();
    updateOverlay();
});

clickCanvas.addEventListener('mousemove', function(e) {
    const tip = document.getElementById('mapTooltip');
    if (!IS_ADMIN || mode !== 'add') { tip.style.display='none'; return; }
    tip.style.display='block';
    tip.style.left=(e.offsetX+14)+'px';
    tip.style.top=(e.offsetY+14)+'px';
    tip.textContent='클릭하여 경로 포인트 추가';
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
    const imgEl = document.getElementById('floorplanImg');
    const ph    = document.getElementById('fpPlaceholder');
    if (!src) { if(imgEl)imgEl.style.display='none'; if(ph)ph.style.display='flex'; return; }
    if (!imgEl) {
        const newImg = document.createElement('img');
        newImg.id = 'floorplanImg';
        newImg.style.cssText = 'width:100%;height:560px;object-fit:contain;display:block;';
        newImg.alt = BUILDING + ' 도면';
        wrap.insertBefore(newImg, wrap.firstChild);
        newImg.addEventListener('load', resizeCanvas);
    }
    const el = document.getElementById('floorplanImg');
    el.src = src;
    el.style.display = 'block';
    if(ph) ph.style.display='none';
    resizeCanvas();
}

/* ── 관리자: 실내 경로 저장 ── */
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
        const res=await fetch('/CampusNav/saveFloorRoute.jsp',{
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
        await fetch('/CampusNav/deleteFloorRoute.jsp?routeId='+id,{method:'POST'});
        location.reload();
    }catch(e){alert('삭제 실패: '+e.message);}
}

/* ── 학생: 자동 경로 표시 ── */
function showAutoRoute() {
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
function onRoomChange(sel) {
    const opt = sel.options[sel.selectedIndex];
    if (!opt.value) { shownPoints=[]; redraw(); updateOverlay(); return; }
    try {
        shownPoints = JSON.parse(opt.dataset.points) || [];
        redraw(); updateOverlay();
        setResult('✅ ' + opt.dataset.room + '까지 경로 표시 중\n포인트 ' + shownPoints.length + '개');
    } catch(e) { setResult('⚠️ 경로 데이터 오류'); }
}

/* ── 초기화: 학생은 자동으로 경로 표시 ── */
window.addEventListener('load', function() {
    setTimeout(function() {
        resizeCanvas();
        if (!IS_ADMIN && AUTO_PTS) {
            try {
                shownPoints = JSON.parse(AUTO_PTS) || [];
                redraw(); updateOverlay();
            } catch(e) {}
        }
    }, 300);
});

function escHtml(s){if(!s)return'';return String(s).replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;');}
</script>
</body>
</html>
