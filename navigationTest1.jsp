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
    
    /* ── 편집 모드 (관리자만) ── */
    String editMode = nvl(request.getParameter("editMode"));
    boolean showEditMode = isAdmin; // 관리자는 항상 편집 모드

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
        /* location이 '학교명|건물명|호실명|' 형식이면 건물명만 추출 */
        if (paramDestBuilding.contains("|")) {
            String[] parts = paramDestBuilding.split("\\|");
            if (parts.length > 1) {
                paramDestBuilding = parts[1].trim();
            }
        }
        /* '제' 문자 제거 (제1공학관 → 1공학관) */
        paramDestBuilding = paramDestBuilding.replaceAll("^제", "");
    }
    if (!paramDestName.isEmpty()) {
        try { paramDestName = java.net.URLDecoder.decode(paramDestName, "UTF-8"); } catch(Exception e2){}
    }

    /* ── DB: 출입구 목록 + 강의실 목록 조회 ── */
    List<Map<String,String>> entrances = new ArrayList<>();
    Map<String, List<Map<String,String>>> roomsByBuilding = new LinkedHashMap<>();
    String dbErr = "";

    try {
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true",
            "root", "1234"
        );

        /* 출입구 조회 */
        PreparedStatement ps = conn.prepareStatement(
            "SELECT entrance_id, entrance_name, building, floor, description, " +
            "IFNULL(image_url,'') AS image_url, " +
            "IFNULL(pixel_x,0) AS pixel_x, IFNULL(pixel_y,0) AS pixel_y " +
            "FROM campus_entrances WHERE is_active=1 ORDER BY entrance_name"
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
        rs.close(); ps.close();

        /* 강의실 조회 (rooms 테이블) */
        try {
            PreparedStatement rps = conn.prepareStatement(
                "SELECT room_id, room_name, building, floor, " +
                "IFNULL(lat,0) AS lat, IFNULL(lng,0) AS lng " +
                "FROM rooms WHERE is_active=1 ORDER BY building, floor, room_name"
            );
            ResultSet rrs = rps.executeQuery();
            while (rrs.next()) {
                Map<String,String> rm = new LinkedHashMap<>();
                rm.put("id",       nvl(rrs.getString("room_id")));
                rm.put("name",     nvl(rrs.getString("room_name")));
                rm.put("building", nvl(rrs.getString("building")));
                rm.put("floor",    nvl(rrs.getString("floor")));
                rm.put("lat",      nvl(rrs.getString("lat")));
                rm.put("lng",      nvl(rrs.getString("lng")));
                String bk = rm.get("building").isEmpty() ? "기타" : rm.get("building");
                roomsByBuilding.computeIfAbsent(bk, k -> new ArrayList<>()).add(rm);
            }
            rrs.close(); rps.close();
        } catch (Exception roomEx) {
            /* rooms 테이블 미생성 시 무시 — rooms_insert.sql 먼저 실행 필요 */
        }

        conn.close();
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
            String building = ent.get("building");
            /* 정확한 일치 또는 건물명 포함 여부로 매칭 */
            if (paramDestBuilding.equals(building) || paramDestBuilding.contains(building) || building.contains(paramDestBuilding)) {
                autoDestEntranceId = ent.get("id");
                System.out.println("[DEBUG] 매칭됨: '" + paramDestBuilding + "' = '" + building + "' → " + autoDestEntranceId);
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
<title>ICT CAN — 길 안내</title>
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
/* 층수 탭 */
.floor-tabs{display:flex;gap:6px;margin-bottom:14px;flex-wrap:wrap;}
.floor-tab{font-family:var(--mono);font-size:13px;font-weight:700;padding:7px 18px;border-radius:999px;border:1.5px solid var(--line2);background:var(--white);color:var(--txt2);cursor:pointer;transition:all .15s;}
.floor-tab:hover{border-color:var(--blue);color:var(--blue);}
.floor-tab.active{background:var(--blue);border-color:var(--blue);color:#fff;}

@media(max-width:991px){#floorplanImg{height:320px;}}
.flow-step{display:flex;align-items:flex-start;gap:10px;background:var(--bg);border:1px solid var(--line);border-radius:var(--r);padding:9px 12px;}
.flow-num{width:22px;height:22px;border-radius:50%;background:var(--blue);color:#fff;font-size:11px;font-weight:700;display:flex;align-items:center;justify-content:center;flex-shrink:0;margin-top:1px;}
.flow-title{font-size:12px;font-weight:700;color:var(--txt);}
.flow-sub{font-size:11px;color:var(--txt3);font-family:var(--mono);margin-top:2px;}
.flow-arrow{text-align:center;color:var(--txt3);font-size:12px;margin:-2px 0;}
@keyframes popIn{from{opacity:0;transform:scale(.9) translateY(6px);}to{opacity:1;transform:scale(1) translateY(0);}}

/* ──────────────────────────────────────────────────────────────────── */
/* RESPONSIVE MOBILE */
/* ──────────────────────────────────────────────────────────────────── */

@media(max-width:768px){
  .topnav{padding:10px 14px;gap:6px;}
  .logo{font-size:15px;gap:6px;}
  .logo-dot{width:28px;height:28px;}
  .nav-right{gap:6px;flex-wrap:wrap;}
  .chip{font-size:11px;padding:5px 11px;}
  .role-chip{font-size:11px;padding:4px 11px;}

  .shell{padding:16px 14px 48px;}
  .page-title{font-size:1.2rem;gap:8px;}
  .page-title .icon-box{width:32px;height:32px;font-size:15px;}
  .page-sub{font-size:12px;padding-left:40px;}

  .card{margin-bottom:14px;}
  .card-head{padding:12px 16px;gap:8px;}
  .ch-icon{width:30px;height:30px;font-size:14px;}
  .ch-title{font-size:13px;}
  .ch-sub{font-size:10px;}
  .card-body{padding:14px 16px;}

  .f-label{font-size:11px;margin-bottom:4px;}
  .f-select{padding:7px 10px;font-size:12px;}

  .btn-prim,.btn-ghost{padding:9px 14px;font-size:12px;width:100%;min-height:44px;}
  .btn-sm{padding:4px 8px;font-size:10px;}

  .admin-banner{padding:8px 11px;font-size:11px;}

  .loc-card{padding:9px 11px;margin-bottom:6px;font-size:12px;}
  .loc-card-name{font-size:12px;}
  .loc-card-bldg{font-size:10px;}

  .photo-wrap img{height:100px;}
  .photo-no{height:60px;font-size:11px;}
  .photo-caption{font-size:10px;padding:5px 9px;}

  .result-box{padding:9px 11px;font-size:11px;}

  #floorplanImg{height:280px;}
  #routeCanvas,#markerCanvas{height:280px;}

  .map-toolbar{top:8px;left:8px;gap:4px;}
  .tb-btn{padding:4px 9px;font-size:11px;}

  .map-overlay{padding:6px 12px;font-size:11px;}
  .ov-badge{padding:2px 7px;font-size:10px;}

  .wp-item{padding:4px 7px;gap:5px;font-size:11px;}
  .wp-num{width:16px;height:16px;font-size:8px;}
  .wp-coord{font-size:9px;}
  .wp-del{width:18px;height:18px;font-size:11px;}

  .route-item{padding:9px 11px;font-size:11px;margin-bottom:5px;}

  .modal-box{max-width:95vw;max-height:90vh;}
  .modal-hd{padding:12px 16px;}
  .modal-title{font-size:13px;}
  .modal-close{width:28px;height:28px;font-size:13px;}
  .modal-body{padding:12px 16px;}

  .floor-tabs{gap:5px;}
  .floor-tab{font-size:12px;padding:6px 14px;}

  .floor-placeholder{height:180px;gap:6px;}
  .floor-placeholder i{font-size:32px;}

  .loc-card-header{padding:12px 16px;font-size:13px;}
  .building-header{padding:9px 16px;font-size:12px;}
  .b-icon{width:24px;height:24px;font-size:11px;}
  .b-title{font-size:12px;}
  .b-count{font-size:9px;}

  .place-row{padding:7px 12px 7px 42px;font-size:11px;}
  .place-name{font-size:11px;}
  .place-floor{font-size:9px;padding:1px 4px;}
  .place-btn{font-size:10px;padding:3px 7px;}

  .flow-step{padding:8px 10px;gap:8px;}
  .flow-num{width:20px;height:20px;font-size:10px;}
  .flow-title{font-size:11px;}
  .flow-sub{font-size:10px;}
}

@media(max-width:640px){
  .topnav{padding:9px 12px;}
  .logo{font-size:14px;}
  .logo-dot{width:26px;height:26px;}

  .shell{padding:14px 12px 40px;}
  .page-title{font-size:1.1rem;}
  .page-title .icon-box{width:30px;height:30px;font-size:14px;}
  .page-sub{font-size:11px;padding-left:38px;}

  .admin-banner{margin-bottom:10px;}

  .modal-box{max-width:98vw;}
  .modal-body img{max-height:70vh;}
}

@media(max-width:480px){
  .topnav{padding:8px 10px;}
  .logo{font-size:13px;gap:5px;}
  .logo-dot{width:24px;height:24px;}
  .nav-right{font-size:11px;}
  .chip{font-size:10px;padding:4px 9px;border-radius:6px;}
  .role-chip{font-size:10px;padding:3px 9px;border-radius:5px;}

  .shell{padding:12px 10px 36px;}
  .page-title{font-size:1rem;gap:6px;margin-bottom:2px;}
  .page-title .icon-box{width:28px;height:28px;font-size:13px;border-radius:8px;}
  .page-sub{font-size:10px;padding-left:36px;margin-bottom:12px;}

  .card{margin-bottom:12px;}
  .card-head{padding:10px 12px;gap:6px;}
  .ch-icon{width:28px;height:28px;font-size:13px;border-radius:7px;}
  .ch-title{font-size:12px;font-weight:700;}
  .ch-sub{font-size:9px;}
  .card-body{padding:12px 12px;}

  .f-label{font-size:10px;margin-bottom:3px;}
  .f-select{padding:6px 9px;font-size:11px;border-radius:8px;}

  .btn-prim,.btn-ghost{padding:8px 12px;font-size:11px;min-height:42px;border-radius:8px;}
  .btn-sm{padding:3px 7px;font-size:9px;border-radius:5px;}

  .admin-banner{padding:7px 9px;font-size:10px;border-radius:7px;}
  .admin-banner i{font-size:14px;}

  .loc-card{padding:8px 9px;margin-bottom:5px;font-size:11px;border-radius:7px;}
  .loc-card-name{font-size:11px;}
  .loc-card-bldg{font-size:9px;}

  .photo-wrap{border-radius:8px;border:1px solid var(--line);}
  .photo-wrap img{height:80px;}
  .photo-no{height:50px;font-size:10px;}
  .photo-caption{font-size:9px;padding:4px 8px;}

  .result-box{padding:8px 9px;font-size:10px;border-radius:8px;}

  #floorplanImg{height:240px;}
  #routeCanvas,#markerCanvas{height:240px;}

  .map-toolbar{top:6px;left:6px;gap:3px;}
  .tb-btn{padding:3px 7px;font-size:10px;border-radius:6px;}

  .map-overlay{padding:5px 10px;font-size:10px;border-radius:8px;}
  .ov-badge{padding:2px 6px;font-size:9px;border-radius:4px;}

  .wp-list{gap:2px;margin-top:5px;}
  .wp-item{padding:3px 6px;gap:4px;font-size:10px;border-radius:5px;}
  .wp-num{width:14px;height:14px;font-size:7px;}
  .wp-coord{font-size:8px;}
  .wp-del{width:16px;height:16px;font-size:10px;border-radius:3px;}
  .wp-empty{font-size:11px;}

  .route-item{padding:8px 10px;font-size:10px;margin-bottom:4px;border-radius:7px;}
  .route-item-name{font-size:11px;}
  .route-item-meta{font-size:9px;}

  .modal-box{max-width:100%;border-radius:12px;margin:10px;}
  .modal-hd{padding:10px 12px;gap:8px;}
  .modal-title{font-size:12px;}
  .modal-close{width:26px;height:26px;font-size:12px;border-radius:6px;}
  .modal-body{padding:10px 12px;max-height:calc(100vh - 80px);}

  .floor-tabs{gap:4px;margin-bottom:10px;}
  .floor-tab{font-size:11px;padding:5px 12px;border-radius:20px;}

  .floor-placeholder{height:150px;gap:5px;border-radius:8px;}
  .floor-placeholder i{font-size:28px;}

  .loc-card-header{padding:10px 12px;font-size:12px;gap:8px;}
  .loc-chevron{font-size:13px;}

  .building-row{border-bottom:1px solid var(--line);}
  .building-header{padding:8px 12px;font-size:11px;gap:8px;}
  .b-icon{width:22px;height:22px;font-size:10px;border-radius:5px;}
  .b-title{font-size:11px;}
  .b-count{font-size:8px;}
  .b-chevron{font-size:10px;}

  .place-list{background:var(--bg2);}
  .place-row{padding:6px 10px 6px 38px;font-size:10px;border-radius:5px;}
  .place-name{font-size:10px;}
  .place-floor{font-size:8px;padding:1px 3px;border-radius:3px;}
  .place-btns{gap:2px;}
  .place-btn{font-size:9px;padding:2px 6px;border-radius:4px;}

  .flow-step{padding:7px 9px;gap:7px;border-radius:6px;}
  .flow-num{width:18px;height:18px;font-size:9px;}
  .flow-title{font-size:10px;}
  .flow-sub{font-size:9px;}
  .flow-arrow{font-size:11px;}
}

@media(max-width:400px){
  .topnav{padding:7px 8px;}
  .logo{font-size:12px;}
  .logo-dot{width:22px;height:22px;}

  .shell{padding:10px 8px 30px;}
  .page-title{font-size:0.95rem;}
  .page-title .icon-box{width:26px;height:26px;font-size:12px;}

  .modal-hd{padding:8px 10px;}
  .modal-body{padding:8px 10px;}
}
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
    <a href="/CAN/main_<%= esc(loginRole) %>.jsp" class="chip"><i class="bi bi-house"></i>홈</a>
    <a href="javascript:history.back()" class="chip"><i class="bi bi-arrow-left"></i>뒤로</a>
  </div>
</div>

<!-- 건물 도면 모달 -->
<div class="modal-bg" id="floorModal" onclick="if(event.target===this){resetModalContent();this.classList.remove('show');}">
  <div class="modal-box">
    <div class="modal-hd">
      <div class="modal-title" id="floorModalTitle">건물 내부 도면</div>
      <button class="modal-close" onclick="resetModalContent();document.getElementById('floorModal').classList.remove('show')"><i class="bi bi-x-lg"></i></button>
    </div>
    <div class="modal-body" id="floorModalBody">
      <!-- 2D / 3D 선택 -->
      <div id="dimTabRow" style="display:flex;gap:8px;margin-bottom:12px;"></div>
      <!-- 도면 영역 -->
      <div id="gallery3d" style="display:none;position:relative;background:#0f172a;border-radius:var(--r);overflow:hidden;">
        <img id="galleryImg" src="" alt="도면" style="width:100%;max-height:480px;object-fit:contain;display:block;">
        <iframe id="galleryIframe" src="" style="width:100%;height:480px;border:none;background:#fff;display:none;"></iframe>
      </div>
      <!-- 층수 선택 탭 (도면 아래) -->
      <div id="floorTabWrap" style="display:none;border-top:1px solid var(--line);padding:12px 0 4px;margin-top:2px;">
        <div style="font-size:11px;font-weight:700;color:var(--txt3);margin-bottom:8px;display:flex;align-items:center;gap:5px;">
          <i class="bi bi-layers-fill" style="color:var(--teal);"></i> 층 선택
        </div>
        <div class="floor-tabs" id="floorTabRow" style="display:flex;gap:6px;flex-wrap:wrap;margin-bottom:4px;"></div>
      </div>
      <!-- 공통 placeholder -->
      <div class="floor-placeholder" id="floorModalPlaceholder"><i class="bi bi-map"></i><span>도면 준비 중</span></div>
      <!-- 강의실 목록 (DB 연동) -->
      <div id="roomListSection" style="display:none;margin-top:16px;border-top:1px solid var(--line);padding-top:14px;">
        <div style="font-size:12px;font-weight:700;color:var(--txt2);margin-bottom:8px;display:flex;align-items:center;gap:6px;">
          <i class="bi bi-door-open-fill" style="color:var(--teal);"></i>강의실 · 호실 목록
        </div>
        <div id="roomListBody" style="display:flex;flex-direction:column;gap:4px;max-height:220px;overflow-y:auto;"></div>
      </div>
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
      <button class="tb-btn active" style="width:100%;margin-bottom:14px;background:var(--teal);color:#fff;border:none;border-radius:var(--r);padding:10px;font-weight:600;font-size:13px;cursor:pointer;display:flex;align-items:center;justify-content:center;gap:6px;">
        <i class="bi bi-pencil-fill"></i>편집
      </button>

      <% if (showEditMode) { %>
      <!-- ══ 편집 모드 탭 ══ -->
      <div style="display:flex;gap:6px;margin-bottom:12px;">
        <button class="tb-btn active" id="tabRouteBtn" onclick="switchAdminTab('route')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-pencil-fill"></i>경로 그리기
        </button>
        <button class="tb-btn tb-amber" id="tabPinBtn" onclick="switchAdminTab('pin')" style="flex:1;justify-content:center;border-radius:var(--r);padding:8px;">
          <i class="bi bi-geo-fill"></i>마커 위치 설정
        </button>
      </div>
      <% } else { %>
      <!-- ══ 길안내 모드 (관리자) ══ -->

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
          <div><div class="ch-title">목적지</div><div class="ch-sub">건물 → 호실 순서로 선택하세요</div></div>
        </div>
        <div class="card-body">

          <% if (!paramDestBuilding.isEmpty()) { %>
          <div style="background:linear-gradient(135deg,var(--blue-lt),var(--teal-lt));border:1.5px solid var(--blue-md);border-radius:var(--r);padding:10px 12px;margin-bottom:10px;display:flex;align-items:center;gap:9px;">
            <div style="width:32px;height:32px;border-radius:8px;background:var(--blue);color:#fff;display:flex;align-items:center;justify-content:center;font-size:14px;flex-shrink:0;"><i class="bi bi-bullseye"></i></div>
            <div style="flex:1;min-width:0;">
              <div style="font-size:10px;font-family:var(--mono);color:var(--blue);font-weight:600;text-transform:uppercase;">자동 설정 목적지</div>
              <div style="font-size:13px;font-weight:700;color:var(--txt);overflow:hidden;text-overflow:ellipsis;white-space:nowrap;"><%= esc(paramDestName.isEmpty()?paramDestBuilding:paramDestName) %></div>
              <div style="font-size:11px;color:var(--txt3);"><%= esc(paramDestBuilding) %> 출입구로 안내</div>
            </div>
          </div>
          <% } %>

          <label class="f-label"><i class="bi bi-buildings" style="color:var(--blue);"></i> ① 목적지 건물</label>
          <select class="f-select mb-2" id="destSelect" onchange="onDestSelectChange(this)">
            <option value="">-- 목적지 건물 출입구 선택 --</option>
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

          <div id="roomSelectWrap" style="display:none;">
            <label class="f-label"><i class="bi bi-door-open-fill" style="color:var(--teal);"></i> ② 목적지 호실</label>
            <select class="f-select mb-2" id="roomSelect" onchange="onRoomSelectChange(this)">
              <option value="">-- 호실 선택 --</option>
            </select>
          </div>

          <div id="destSummary" style="display:none;background:var(--teal-lt);border:1.5px solid var(--teal-md);border-radius:var(--r);padding:10px 13px;margin-bottom:8px;font-size:12px;">
            <div style="display:flex;align-items:center;gap:7px;">
              <i class="bi bi-signpost-2-fill" style="color:var(--teal);font-size:15px;"></i>
              <div>
                <div id="destSummaryBuilding" style="font-weight:700;color:var(--txt);font-size:13px;"></div>
                <div id="destSummaryRoom" style="color:var(--teal);font-size:11px;margin-top:1px;"></div>
              </div>
            </div>
          </div>

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

      <div class="card mb-3" id="flowGuideCard" style="display:none;">
        <div class="card-body" style="padding:13px 16px;">
          <div style="font-size:12px;font-weight:700;color:var(--txt2);margin-bottom:9px;"><i class="bi bi-signpost-split-fill" style="color:var(--blue);"></i> 안내 흐름</div>
          <div style="display:flex;flex-direction:column;gap:6px;">
            <div class="flow-step" id="flowStep1">
              <div class="flow-num">1</div>
              <div class="flow-text">
                <div class="flow-title">외부 경로 안내</div>
                <div class="flow-sub" id="flowStep1Sub">출발지 → 목적지 건물 출입구</div>
              </div>
            </div>
            <div class="flow-arrow"><i class="bi bi-arrow-down"></i></div>
            <div class="flow-step" id="flowStep2" style="opacity:.4;">
              <div class="flow-num" style="background:var(--teal);">2</div>
              <div class="flow-text">
                <div class="flow-title">실내 경로 안내</div>
                <div class="flow-sub" id="flowStep2Sub">출입구 → 목적지 호실</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <% } %>

      <!-- 경로 그리기 탭 -->
      <div id="tabRoute" style="display:none;">
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
            <button class="btn-ghost" id="btnFloorPlanRoute" style="width:100%;margin-top:8px;display:none;font-size:12px;padding:8px;color:var(--teal);border-color:var(--teal);" onclick="showBuildingFloorPlanFromRoute()">
              <i class="bi bi-map"></i>건물 도면 보기
            </button>
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
            <div class="result-box" id="editResultBox">도착 출입구를 선택하고 평면도에서 경로를 그리세요.</div>
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
            <button class="btn-ghost" id="btnFloorPlanPin" style="width:100%;margin-top:8px;display:none;font-size:12px;padding:8px;color:var(--teal);border-color:var(--teal);" onclick="showBuildingFloorPlanFromPin()">
              <i class="bi bi-map"></i>건물 도면 보기
            </button>
          </div>
        </div>
      </div>

      <% } else { %>
      <!-- ══ 길안내 모드 (학생/일반과 동일) ══ -->

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
          <div><div class="ch-title">목적지</div><div class="ch-sub">건물 → 호실 순서로 선택하세요</div></div>
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

          <!-- STEP 1: 목적지 건물(출입구) 선택 -->
          <label class="f-label"><i class="bi bi-buildings" style="color:var(--blue);"></i> ① 목적지 건물</label>
          <select class="f-select mb-2" id="destSelect" onchange="onDestSelectChange(this)">
            <option value="">-- 목적지 건물 출입구 선택 --</option>
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

          <!-- STEP 2: 호실 선택 (건물 선택 후 표시) -->
          <div id="roomSelectWrap" style="display:none;">
            <label class="f-label"><i class="bi bi-door-open-fill" style="color:var(--teal);"></i> ② 목적지 호실 <span style="font-weight:400;color:var(--txt3)">(선택 시 실내 안내까지 연결)</span></label>
            <select class="f-select mb-2" id="roomSelect" onchange="onRoomSelectChange(this)">
              <option value="">-- 호실 선택 (선택 안 하면 출입구까지만 안내) --</option>
            </select>
          </div>

          <!-- 선택 요약 배너 -->
          <div id="destSummary" style="display:none;background:var(--teal-lt);border:1.5px solid var(--teal-md);border-radius:var(--r);padding:10px 13px;margin-bottom:8px;font-size:12px;">
            <div style="display:flex;align-items:center;gap:7px;">
              <i class="bi bi-signpost-2-fill" style="color:var(--teal);font-size:15px;"></i>
              <div>
                <div id="destSummaryBuilding" style="font-weight:700;color:var(--txt);font-size:13px;"></div>
                <div id="destSummaryRoom" style="color:var(--teal);font-size:11px;margin-top:1px;"></div>
              </div>
            </div>
          </div>

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

      <!-- 안내 흐름 설명 카드 -->
      <div class="card mb-3" id="flowGuideCard" style="display:none;">
        <div class="card-body" style="padding:13px 16px;">
          <div style="font-size:12px;font-weight:700;color:var(--txt2);margin-bottom:9px;"><i class="bi bi-signpost-split-fill" style="color:var(--blue);"></i> 안내 흐름</div>
          <div style="display:flex;flex-direction:column;gap:6px;">
            <div class="flow-step" id="flowStep1">
              <div class="flow-num">1</div>
              <div class="flow-text">
                <div class="flow-title">외부 경로 안내</div>
                <div class="flow-sub" id="flowStep1Sub">출발지 → 목적지 건물 출입구</div>
              </div>
            </div>
            <div class="flow-arrow"><i class="bi bi-arrow-down"></i></div>
            <div class="flow-step" id="flowStep2" style="opacity:.4;">
              <div class="flow-num" style="background:var(--teal);">2</div>
              <div class="flow-text">
                <div class="flow-title">실내 경로 안내</div>
                <div class="flow-sub" id="flowStep2Sub">출입구 → 목적지 호실</div>
              </div>
            </div>
          </div>
        </div>
      </div>

      <% } %>
    </div><!-- /좌측 -->

    <!-- ════ 우측 — 평면도 ════ -->
    <div class="col-xl-8 col-lg-7">
      <div class="card mb-3">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-map-fill"></i></div>
          <div style="flex:1">
            <div class="ch-title">캠퍼스 평면도</div>
            <div class="ch-sub">
              <% if (isAdmin && showEditMode) { %>출입구 마커 클릭 또는 평면도 클릭으로 경유점 추가
              <% } else { %>원형 마커를 클릭해 출발지/목적지를 선택하세요<% } %>
            </div>
          </div>
        </div>
        <div class="card-body" style="padding-bottom:0;">
          <div class="floorplan-wrap" id="floorplanWrap">
            <img id="floorplanImg" src="/CAN/images/ictlayout.png" alt="캠퍼스 평면도" onerror="this.style.display='none';">
            <% if (isAdmin && showEditMode) { %>
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
const SHOW_EDIT_MODE = <%= showEditMode %>;
const routeCanvas  = document.getElementById('routeCanvas');
const markerCanvas = document.getElementById('markerCanvas');
const rCtx = routeCanvas.getContext('2d');
const mCtx = markerCanvas.getContext('2d');
const wrap = document.getElementById('floorplanWrap');
const img  = document.getElementById('floorplanImg');

let waypoints         = [];  // 관리자: 경로 경유점
let loadedRoutePoints = [];  // 학생: 불러온 경로
let mode              = (IS_ADMIN && SHOW_EDIT_MODE) ? 'add' : 'view';  // 편집 모드 아니면 view
let adminFromId       = '';  // 관리자: 출발 출입구
let adminToId         = '';  // 관리자: 도착 출입구
let pinTargetId       = '';  // 관리자: 마커 위치 설정 대상
let originId          = '';  // 학생: 출발지 ID
let destId            = '';  // 학생: 목적지 ID
let selectedRoomId    = '';  // 학생: 선택한 목적지 호실 ID
let selectedRoomName  = '';  // 학생: 선택한 목적지 호실명

/* 출입구 데이터 */
const entranceData = [
    <% for(int i=0;i<entrances.size();i++){
        Map<String,String> ent=entrances.get(i);
        String pxv=ent.get("px"); String pyv=ent.get("py");
        boolean hasPx=pxv!=null&&!pxv.equals("0")&&!pxv.isEmpty();
        boolean hasPy=pyv!=null&&!pyv.equals("0")&&!pyv.isEmpty();
    %>
    {id:'<%= esc(ent.get("id")) %>',name:'<%= esc(ent.get("name")) %>',
     building:'<%= esc(ent.get("building")) %>',img:'<% String imgVal=ent.get("img"); if(imgVal!=null&&!imgVal.isEmpty()&&!imgVal.startsWith("/")){out.print(request.getContextPath()+"/");}%><%= esc(imgVal) %>',
     px:<%= hasPx?pxv:"null" %>,py:<%= hasPy?pyv:"null" %>}<%= i<entrances.size()-1?",":"" %>
    <% } %>
];

/* ── 출입구 순서 정렬 ── */
(function() {
    const buildingOrder = ['정문', '대학본부', '1공학관', '2공학관', '휴게실', '도서관', '1생활관', '2생활관', '학생회관', '산업협력학관'];
    entranceData.sort((a, b) => {
        const aIdx = buildingOrder.indexOf(a.building);
        const bIdx = buildingOrder.indexOf(b.building);
        if (aIdx !== bIdx) {
            // 목록에 있으면 그 순서대로, 없으면 끝에 배치
            if (aIdx === -1) return 1;
            if (bIdx === -1) return -1;
            return aIdx - bIdx;
        }
        // 같은 건물이면 entrance_name 기준 정렬 (정문1, 정문2, 정문3...)
        return a.name.localeCompare(b.name, 'ko-KR');
    });
})();

/* ── detail.jsp에서 전달된 목적지 자동 설정 ── */
<% if (!autoDestEntranceId.isEmpty()) { %>
(function() {
    const autoDestId = '<%= esc(autoDestEntranceId) %>';
    const autoDestEnt = entranceData.find(e => e.id === autoDestId);

    if (autoDestEnt) {
        setTimeout(() => {
            /* destId 직접 설정 */
            destId = autoDestId;

            /* setDest와 동일한 작업 수행 */
            drawMarkers();
            updateOverlay();
            showPhoto('dest', autoDestEnt.name, autoDestEnt.img);
            syncDestSelect(autoDestEnt.id);

            /* 호실 목록 채우기 */
            const bldg = autoDestEnt.building || '';
            const rooms = roomsByBuildingData[bldg] || [];
            const roomSel = document.getElementById('roomSelect');
            const roomWrap = document.getElementById('roomSelectWrap');

            if (roomSel) {
                roomSel.innerHTML = '<option value="">-- 호실 선택 (선택 안 하면 출입구까지만 안내) --</option>';
                const byFloor = {};
                rooms.forEach(function(rm) {
                    const fl = rm.floor || 1;
                    if (!byFloor[fl]) byFloor[fl] = [];
                    byFloor[fl].push(rm);
                });
                Object.keys(byFloor).sort(function(a,b){return a-b;}).forEach(function(fl) {
                    const og = document.createElement('optgroup');
                    og.label = fl + '층';
                    byFloor[fl].forEach(function(rm) {
                        const o = document.createElement('option');
                        o.value = rm.id;
                        o.textContent = rm.name;
                        o.dataset.roomName = rm.name;
                        o.dataset.floor    = rm.floor;
                        og.appendChild(o);
                    });
                    roomSel.appendChild(og);
                });

                /* detail.jsp에서 전달된 roomId 자동 선택 */
                <% if (!paramRoomId.isEmpty()) { %>
                const autoRoomId = '<%= esc(paramRoomId) %>';
                for (let i = 0; i < roomSel.options.length; i++) {
                    if (roomSel.options[i].value === autoRoomId) {
                        roomSel.selectedIndex = i;
                        onRoomSelectChange(roomSel);
                        break;
                    }
                }
                <% } %>
            }
            if (roomWrap) roomWrap.style.display = rooms.length > 0 ? 'block' : 'none';
            updateDestSummary();
            updateFlowGuide();
        }, 100);
    }
})();
<% } %>

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
    const t = Date.now() / 1000;
    /* 깜빡임: 0.0 ~ 1.0 사이 파동 (초당 1.8회) */
    const pulse = (Math.sin(t * 1.8 * Math.PI * 2) + 1) / 2;

    entranceData.forEach(function(ent) {
        if (ent.px === null || ent.py === null) return;
        const x = ent.px, y = ent.py;
        const isOrigin = ent.id === originId;
        const isDest   = ent.id === destId;
        const isPinTgt = ent.id === pinTargetId;
        const isActive = isOrigin || isDest;
        const c = isOrigin ? '22,163,74' : isDest ? '220,38,38' : isPinTgt ? '217,119,6' : '26,86,219';

        if (isActive) {
            /* 출발/목적지: 팽창하는 파동 링 */
            const waveR = 18 + pulse * 16;
            const waveA = 0.55 - pulse * 0.5;
            mCtx.beginPath(); mCtx.arc(x, y, waveR, 0, Math.PI*2);
            mCtx.fillStyle = 'rgba(' + c + ',' + waveA + ')'; mCtx.fill();

            /* 두 번째 파동 (위상 반전) */
            const wave2R = 18 + (1 - pulse) * 10;
            const wave2A = 0.25 - (1 - pulse) * 0.22;
            mCtx.beginPath(); mCtx.arc(x, y, wave2R, 0, Math.PI*2);
            mCtx.fillStyle = 'rgba(' + c + ',' + wave2A + ')'; mCtx.fill();
        } else {
            /* 일반 마커: 고정 글로우 */
            mCtx.beginPath(); mCtx.arc(x, y, 20, 0, Math.PI*2);
            mCtx.fillStyle = 'rgba(' + c + ',0.15)'; mCtx.fill();
        }

        /* 중간 링 */
        mCtx.beginPath(); mCtx.arc(x, y, 13, 0, Math.PI*2);
        mCtx.fillStyle = 'rgba(' + c + ',' + (isActive ? 0.5 : 0.35) + ')'; mCtx.fill();

        /* 중앙 원 — 활성화 시 테두리 추가 */
        mCtx.beginPath(); mCtx.arc(x, y, 9, 0, Math.PI*2);
        mCtx.fillStyle = 'rgb(' + c + ')'; mCtx.fill();
        if (isActive) {
            mCtx.strokeStyle = '#fff'; mCtx.lineWidth = 2;
            mCtx.stroke();
        }

        /* 흰 점 */
        mCtx.beginPath(); mCtx.arc(x, y, 3.5, 0, Math.PI*2);
        mCtx.fillStyle = '#fff'; mCtx.fill();

        /* 이름 레이블 */
        const label = ent.name.replace(' 출입구','').replace('출입구','');
        mCtx.font = 'bold 10px "Noto Sans KR", sans-serif';
        mCtx.textAlign = 'center'; mCtx.textBaseline = 'bottom';
        const tw = mCtx.measureText(label).width;
        mCtx.fillStyle = 'rgba(0,0,0,.65)';
        mCtx.beginPath();
        mCtx.roundRect(x - tw/2 - 3, y - 26, tw + 6, 16, 3);
        mCtx.fill();
        mCtx.fillStyle = '#fff';
        mCtx.fillText(label, x, y - 12);
    });
    animFrameId = requestAnimationFrame(animateMarkers);
}
setTimeout(function() { animateMarkers(); }, 200);

/* ── markerCanvas 클릭 ── */
markerCanvas.addEventListener('click', function(e) {
    const rect = markerCanvas.getBoundingClientRect();
    // 모바일: canvas 실제 크기 / 화면 표시 크기 비율로 보정
    const scaleX = markerCanvas.width / rect.width;
    const scaleY = markerCanvas.height / rect.height;
    const x = (e.clientX - rect.left) * scaleX;
    const y = (e.clientY - rect.top) * scaleY;

    /* 마커 위에 클릭했는지 확인 - add 모드에서는 감지 영역 좁게 */
    const hitR = (IS_ADMIN && SHOW_EDIT_MODE && mode === 'add') ? MARKER_HIT_ADD : MARKER_HIT_R;
    let clicked = null;
    for (let i = entranceData.length-1; i >= 0; i--) {
        const ent = entranceData[i];
        if (ent.px === null || ent.py === null) continue;
        const dx = x - ent.px, dy = y - ent.py;
        if (Math.sqrt(dx*dx + dy*dy) <= hitR) { clicked = ent; break; }
    }

    if (IS_ADMIN && SHOW_EDIT_MODE) {
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
        /* 길안내 모드 또는 학생: 마커 클릭 → 사진 팝업 표시 + 출발/목적지 설정 */
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
function clearRoute(){waypoints=[];loadedRoutePoints=[];updateWpList();redrawRoute();drawMarkers();updateOverlay();editSetResult('초기화되었습니다.');}

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
function editSetResult(msg){const el=document.getElementById('editResultBox');if(el)el.textContent=msg;}

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
    /* 호실 목록 채우기 (마커 클릭으로 목적지 설정 시도) */
    const fakeSel = document.getElementById('destSelect');
    if (fakeSel) {
        for (let i = 0; i < fakeSel.options.length; i++) {
            if (fakeSel.options[i].value === ent.id) {
                fakeSel.selectedIndex = i;
                onDestSelectChange(fakeSel);
                break;
            }
        }
    }
}

function onOriginSelectChange(sel) {
    const opt=sel.options[sel.selectedIndex];
    if(!opt.value){originId='';hidePhoto('origin');drawMarkers();updateOverlay();return;}
    const ent=entranceData.find(e=>e.id===opt.value);
    if(ent) setOrigin(ent);
}
function onDestSelectChange(sel) {
    const opt = sel.options[sel.selectedIndex];
    /* 호실 선택 초기화 */
    selectedRoomId   = '';
    selectedRoomName = '';
    const roomWrap = document.getElementById('roomSelectWrap');
    const roomSel  = document.getElementById('roomSelect');

    if (!opt.value) {
        destId = '';
        hidePhoto('dest');
        drawMarkers();
        updateOverlay();
        if (roomWrap) roomWrap.style.display = 'none';
        updateDestSummary();
        updateFlowGuide();
        return;
    }
    const ent = entranceData.find(e => e.id === opt.value);
    if (ent) setDest(ent);

    /* 해당 건물의 호실 목록 채우기 */
    const bldg = opt.dataset.building || '';
    const rooms = roomsByBuildingData[bldg] || [];
    if (roomSel) {
        roomSel.innerHTML = '<option value="">-- 호실 선택 (선택 안 하면 출입구까지만 안내) --</option>';
        /* 층별 그룹 */
        const byFloor = {};
        rooms.forEach(function(rm) {
            const fl = rm.floor || 1;
            if (!byFloor[fl]) byFloor[fl] = [];
            byFloor[fl].push(rm);
        });
        Object.keys(byFloor).sort(function(a,b){return a-b;}).forEach(function(fl) {
            const og = document.createElement('optgroup');
            og.label = fl + '층';
            byFloor[fl].forEach(function(rm) {
                const o = document.createElement('option');
                o.value = rm.id;
                o.textContent = rm.name;
                o.dataset.roomName = rm.name;
                o.dataset.floor    = rm.floor;
                og.appendChild(o);
            });
            roomSel.appendChild(og);
        });
        /* detail.jsp에서 전달된 roomId 자동 선택 */
        <% if (!paramRoomId.isEmpty()) { %>
        (function() {
            const autoRoomId = '<%= esc(paramRoomId) %>';
            for (let i = 0; i < roomSel.options.length; i++) {
                if (roomSel.options[i].value === autoRoomId) {
                    roomSel.selectedIndex = i;
                    onRoomSelectChange(roomSel);
                    break;
                }
            }
        })();
        <% } %>
    }
    if (roomWrap) roomWrap.style.display = rooms.length > 0 ? 'block' : 'none';
    updateDestSummary();
    updateFlowGuide();
}

function onRoomSelectChange(sel) {
    const opt = sel.options[sel.selectedIndex];
    if (!opt.value) {
        selectedRoomId   = '';
        selectedRoomName = '';
    } else {
        selectedRoomId   = opt.value;
        selectedRoomName = opt.dataset.roomName || opt.textContent;
    }
    updateDestSummary();
    updateFlowGuide();
}

function updateDestSummary() {
    const sum  = document.getElementById('destSummary');
    const bEl  = document.getElementById('destSummaryBuilding');
    const rEl  = document.getElementById('destSummaryRoom');
    if (!sum) return;
    if (!destId) { sum.style.display = 'none'; return; }
    const ent = entranceData.find(e => e.id === destId);
    if (!ent) { sum.style.display = 'none'; return; }
    sum.style.display = 'block';
    bEl.textContent = ent.building || ent.name;
    rEl.textContent = selectedRoomName ? '호실: ' + selectedRoomName : '출입구까지만 안내';
}

function updateFlowGuide() {
    const card  = document.getElementById('flowGuideCard');
    const step2 = document.getElementById('flowStep2');
    const sub1  = document.getElementById('flowStep1Sub');
    const sub2  = document.getElementById('flowStep2Sub');
    if (!card) return;
    if (!destId) { card.style.display = 'none'; return; }
    card.style.display = 'block';
    const ent = entranceData.find(e => e.id === destId);
    const bldg = ent ? (ent.building || ent.name) : '';
    sub1.textContent = '출발지 → ' + bldg + ' 출입구';
    if (selectedRoomName) {
        step2.style.opacity = '1';
        sub2.textContent = '출입구 → ' + selectedRoomName;
    } else {
        step2.style.opacity = '0.35';
        sub2.textContent = '호실 선택 시 실내 안내 연결';
    }
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
        const res=await fetch('/CAN/getRoutes.jsp?fromId='+encodeURIComponent(originId)+'&toId='+encodeURIComponent(destId)+'&latest=1');
        const data=await res.json();
        if(!data||!data.points||data.points.length===0){
            setResult('⚠️ 등록된 경로가 없습니다.\n관리자에게 경로 등록을 요청하세요.\n\n출입구에 도착하면 아래 버튼으로 실내 안내를 받으세요.');
            return;
        }
        loadedRoutePoints=data.points;
        redrawRoute();updateOverlay();
        const roomMsg = selectedRoomName ? '\n→ 실내: ' + selectedRoomName + '까지 추가 안내 예정' : '';
        setResult('✅ 외부 경로 안내 중\n출발: '+getEntName(originId)+'\n도착: '+getEntName(destId)+' 출입구\n포인트 '+loadedRoutePoints.length+'개'+roomMsg+'\n\n출입구 도착 후 아래 버튼을 누르세요.');
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

    /* 호실 번호에서 층수 추출 (예: 1101 → 1층, 1201 → 2층) */
    let floor = '';
    if (destRoom) {
        const floorNum = destRoom.charAt(1);  // 두 번째 자리
        if (floorNum && !isNaN(floorNum)) {
            floor = floorNum;
        }
    }

    let url = '/CAN/floorNav.jsp?building=' + encodeURIComponent(building);
    if (destRoom) url += '&destRoom=' + encodeURIComponent(destRoom);
    if (roomId)   url += '&roomId='   + encodeURIComponent(roomId);
    if (floor)    url += '&floor='    + encodeURIComponent(floor);
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
    const btnFloor = document.getElementById('btnFloorPlanRoute');
    if(!infoEl) return;
    if(adminFromId && adminToId) {
        infoEl.style.display = 'flex';
        infoTx.textContent = getEntName(adminFromId) + '  →  ' + getEntName(adminToId);
        editSetResult('경로: '+getEntName(adminFromId)+' → '+getEntName(adminToId)+'\n평면도를 클릭해 경로를 그리세요.');
        if(btnFloor) btnFloor.style.display = 'block';
    } else if(adminFromId) {
        infoEl.style.display = 'flex';
        infoTx.textContent = getEntName(adminFromId) + '  →  (도착 출입구 선택 필요)';
        editSetResult('출발: '+getEntName(adminFromId)+'\n도착 출입구를 선택하거나 마커를 클릭하세요.');
        if(btnFloor) btnFloor.style.display = 'none';
    } else {
        infoEl.style.display = 'none';
        editSetResult('출발·도착 출입구를 선택하고 평면도에서 경로를 그리세요.');
        if(btnFloor) btnFloor.style.display = 'none';
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
    const bldg    = ent.building || '';
    const hasDiag = !!(floorMaps[bldg]);
    const popupW  = 300;

    /* 캔버스 안에서 쓸 수 있는 최대 높이 (여백 40px) */
    const canvasW = markerCanvas.width;
    const canvasH = markerCanvas.height;
    const maxH    = Math.min(canvasH - 40, imgSrc ? (hasDiag ? 390 : 340) : (hasDiag ? 210 : 165));

    const popup = document.createElement('div');
    popup.id = 'markerPopup';
    /* flex column: 이미지가 남은 공간 차지, 버튼 영역은 항상 하단 고정 */
    popup.style.cssText =
        'position:absolute;z-index:100;background:#fff;border-radius:14px;' +
        'box-shadow:0 4px 24px rgba(0,0,0,.22);overflow:hidden;width:'+popupW+'px;' +
        'max-height:'+maxH+'px;display:flex;flex-direction:column;' +
        'border:1px solid var(--line);animation:popIn .18s ease;';

    /* 위치: 마커 위쪽 45% → 아래, 그 외 → 위 */
    let left = cx - popupW / 2;
    let top  = cy < canvasH * 0.45 ? cy + 22 : cy - maxH - 22;

    /* 경계 보정 */
    if (left < 4) left = 4;
    if (left + popupW > canvasW - 4) left = canvasW - popupW - 4;
    if (top < 4) top = 4;
    if (top + maxH > canvasH - 4) top = canvasH - maxH - 4;

    popup.style.left = left + 'px';
    popup.style.top  = top  + 'px';

    const diagramBtn = hasDiag
        ? '<button onclick="closeMarkerPopup();openFloorModal(\''+escHtml(bldg)+'\')" ' +
          'style="width:100%;background:var(--blue-lt);color:var(--blue);border:1.5px solid var(--blue-md);border-radius:7px;padding:7px 0;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--sans);margin-top:6px;">' +
          '🗺 내부 도면 보기</button>'
        : '';

    popup.innerHTML =
        /* 이미지 영역 — flex:1 로 남은 공간 차지 */
        '<div style="flex:1;min-height:0;overflow:hidden;">' +
            '<img src="'+escHtml(imgSrc)+'" ' +
                'style="width:100%;height:100%;object-fit:cover;display:'+(imgSrc?'block':'none')+';" ' +
                'onerror="this.style.display=\'none\';document.getElementById(\'popupNoImg\').style.display=\'flex\';">' +
            '<div id="popupNoImg" style="display:'+(imgSrc?'none':'flex')+';height:100%;min-height:80px;background:var(--bg2);align-items:center;justify-content:center;gap:6px;color:var(--txt3);font-size:13px;">' +
                '<i class="bi bi-image"></i>사진 없음' +
            '</div>' +
        '</div>' +
        /* 버튼 영역 — flex-shrink:0 으로 항상 보임 */
        '<div style="flex-shrink:0;padding:10px 12px;background:#fff;">' +
            '<div style="font-size:14px;font-weight:700;color:var(--txt);margin-bottom:3px;">'+escHtml(ent.name)+'</div>'+
            (bldg ? '<div style="font-size:11px;color:var(--txt3);font-family:var(--mono);margin-bottom:8px;">'+escHtml(bldg)+'</div>' : '<div style="margin-bottom:8px;"></div>')+
            '<div style="display:flex;gap:5px;">'+
                '<button onclick="setOriginFromPopup(\''+ent.id+'\')" style="flex:1;background:var(--green);color:#fff;border:none;border-radius:7px;padding:7px 0;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--sans);">출발지</button>'+
                '<button onclick="setDestFromPopup(\''+ent.id+'\')" style="flex:1;background:var(--red);color:#fff;border:none;border-radius:7px;padding:7px 0;font-size:13px;font-weight:700;cursor:pointer;font-family:var(--sans);">목적지</button>'+
                '<button onclick="closeMarkerPopup()" style="width:32px;background:var(--bg2);color:var(--txt3);border:1.5px solid var(--line2);border-radius:7px;font-size:14px;cursor:pointer;flex-shrink:0;">✕</button>'+
            '</div>'+
            diagramBtn +
        '</div>';

    wrap.appendChild(popup);
    photoPopupTimer = setTimeout(closeMarkerPopup, 6000);
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
    const btnFloor = document.getElementById('btnFloorPlanPin');
    if(!opt.value){
        pinTargetId='';
        document.getElementById('pinTargetInfo').style.display='none';
        if(btnFloor) btnFloor.style.display='none';
        return;
    }
    pinTargetId=opt.value;
    document.getElementById('pinTargetName').textContent=opt.dataset.name;
    document.getElementById('pinTargetInfo').style.display='flex';
    if(btnFloor) btnFloor.style.display='block';
    if(mode!=='pin')setMode('pin');
}
function syncPinSelect(id){const s=document.getElementById('pinEntranceSelect');if(!s)return;for(let i=0;i<s.options.length;i++){if(s.options[i].value===id){s.selectedIndex=i;break;}}}
function selectPinTarget(id,name){pinTargetId=id;document.getElementById('pinTargetName').textContent=name;document.getElementById('pinTargetInfo').style.display='flex';syncPinSelect(id);switchAdminTab('pin');}

async function savePinCoord(entranceId, x, y) {
    try {
        const res  = await fetch('/CAN/saveEntrancePin.jsp',{
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
        const res=await fetch('/CAN/saveRoute.jsp',{
            method:'POST',headers:{'Content-Type':'application/x-www-form-urlencoded'},
            body:'fromEntranceId='+encodeURIComponent(adminFromId)+
                 '&toEntranceId='+encodeURIComponent(adminToId)+
                 '&routeName='+encodeURIComponent(routeName)+
                 '&points='+encodeURIComponent(JSON.stringify(waypoints))
        });
        const text=await res.text();
        if(text.trim()==='OK'){
            editSetResult('✅ 경로 저장 완료!\n'+getEntName(adminFromId)+' → '+getEntName(adminToId)+'\n포인트 '+waypoints.length+'개');
            loadSavedRoutes();
        } else editSetResult('⚠️ 저장 실패: '+text);
    }catch(e){editSetResult('⚠️ 오류: '+e.message);}
    finally{btn.disabled=false;btn.innerHTML='<i class="bi bi-floppy-fill"></i>경로 저장하기';}
}

async function loadSavedRoutes() {
    if(!adminFromId || !adminToId) return;
    const container=document.getElementById('savedRouteList');
    container.innerHTML='<div class="wp-empty">불러오는 중...</div>';
    try {
        const res=await fetch('/CAN/getRoutes.jsp?fromId='+encodeURIComponent(adminFromId)+'&toId='+encodeURIComponent(adminToId));
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
        const res=await fetch('/CAN/getRoutes.jsp?routeId='+routeId);
        const data=await res.json();
        if(data&&data.points){waypoints=data.points;updateWpList();redrawRoute();updateOverlay();editSetResult('미리보기: '+(data.route_name||'경로')+'\n경유점 '+waypoints.length+'개');}
    }catch(e){alert('미리보기 실패: '+e.message);}
}

async function deleteRoute(routeId) {
    if(!confirm('이 경로를 삭제하시겠습니까?'))return;
    try{await fetch('/CAN/deleteRoute.jsp?routeId='+routeId,{method:'POST'});loadSavedRoutes();clearRoute();}
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

/* ── 건물 내부 도면 모달 ── */
/* floorMaps 구조
   2D: { html: '/CAN/floormaps/xxx.html' }          → iframe으로 표시
   3D: { floors: [...], gallery: { '층키': [이미지URL,...] } } → 갤러리 슬라이더
*/
/* 건물 도면 데이터
   2D: iframe으로 표시 (floormaps/*.html)
   3D: 갤러리 슬라이더 (images/3d/*.png)
       floors 키: '지하'→B1, 숫자 1자리→N층, 그 외→그대로 표시
*/
var floorMaps = {
  '1공학관': {
    '2D': { html: '/CAN/floormaps/eng1.html' },
    '3D': { floors: ['1','2','3','4','5'], gallery: {
              '1': ['/CAN/images/3d/eng1-3d-1.png'],
              '2': ['/CAN/images/3d/eng1-3d-2.png'],
              '3': ['/CAN/images/3d/eng1-3d-3.png'],
              '4': ['/CAN/images/3d/eng1-3d-4.png'],
              '5': ['/CAN/images/3d/eng1-3d-5.png']
            }}
  },
  '2공학관': {
    '2D': { html: '/CAN/floormaps/eng2.html' },
    '3D': { floors: ['지하','1','2','3','4','5'],
            gallery: {
              '지하': ['/CAN/images/3d/eng2-b1-1.png'],
              '1':    ['/CAN/images/3d/eng2-1f.png'],
              '2':    ['/CAN/images/3d/eng2-2f.png'],
              '3':    ['/CAN/images/3d/eng2-3f.png'],
              '4':    ['/CAN/images/3d/eng2-4f.png'],
              '5':    ['/CAN/images/3d/eng2-5f.png']
            }
          }
  },
  '대학본부': {
    '2D': { html: '/CAN/floormaps/main.html' },
    '3D': { floors: ['지하','1','2','3','4','5'],
            gallery: {
              '지하': ['/CAN/images/3d/main-b1.png'],
              '1':    ['/CAN/images/3d/main-1f.png'],
              '2':    ['/CAN/images/3d/main-2f.png'],
              '3':    ['/CAN/images/3d/main-3f.png'],
              '4':    ['/CAN/images/3d/main-4f.png'],
              '5':    ['/CAN/images/3d/main-5f.png']
            }
          }
  },
  '산학협력관':  { '2D': { html: '/CAN/floormaps/collab.html'  }, '3D': null },
  '산업협력학관': { '2D': { html: '/CAN/floormaps/collab.html'  }, '3D': null },
  '1생활관':     { '2D': { html: '/CAN/floormaps/dorm1.html'   }, '3D': { floors: ['1','2','3'], gallery: { '1': ['/CAN/images/3d/dorm1-3d-1.png'], '2': ['/CAN/images/3d/dorm1-3d-2.png'], '3': ['/CAN/images/3d/dorm1-3d-3.png'] } } },
  '2생활관':     { '2D': { html: '/CAN/floormaps/dorm2.html'   }, '3D': { floors: ['1','2'], gallery: { '1': ['/CAN/images/3d/dorm2-3d-1.png'], '2': ['/CAN/images/3d/dorm2-3d-2.png'] } } },
  '학생회관':    { '2D': { html: '/CAN/floormaps/student.html' },
                 '3D': { floors: ['1','2','3','4','5'], gallery: {
                   '1': ['/CAN/images/3d/stu-1.png'],
                   '2': ['/CAN/images/3d/stu-2.png'],
                   '3': ['/CAN/images/3d/stu-3.png'],
                   '4': ['/CAN/images/3d/stu-4.png'],
                   '5': ['/CAN/images/3d/stu-5.png']
                 }}}
};

/* ── DB에서 읽어온 건물별 강의실 목록 ────────────────────────────
   roomsByBuildingData[building] = [{id, name, floor, lat, lng}, ...]
   rooms_insert.sql 실행 후 자동으로 채워짐
────────────────────────────────────────────────────────────────── */
var roomsByBuildingData = {
<%
  boolean firstB = true;
  for (java.util.Map.Entry<String, List<Map<String,String>>> bEntry : roomsByBuilding.entrySet()) {
    if (!firstB) out.print(",\n");
    firstB = false;
    String bNameJs = bEntry.getKey().replace("'","\\'");
    List<Map<String,String>> rooms = bEntry.getValue();
%>
  '<%= bNameJs %>': [
<%
    boolean firstR = true;
    for (Map<String,String> rm : rooms) {
      if (!firstR) out.print(",\n");
      firstR = false;
      String rmName = rm.get("name").replace("'","\\'");
      String fl  = rm.get("floor").isEmpty()?"1":rm.get("floor");
      String lat = rm.get("lat").isEmpty()?"0":rm.get("lat");
      String lng = rm.get("lng").isEmpty()?"0":rm.get("lng");
%>
    {id:'<%= esc(rm.get("id")) %>',name:'<%= rmName %>',floor:<%= fl %>,lat:<%= lat %>,lng:<%= lng %>}
<%  } %>
  ]
<% } %>
};
var currentBuilding    = '';
var currentDim         = '2D';
var currentFloor       = 1;
var currentGalleryList = [];
var currentGalleryIdx  = 0;

function openFloorModal(building, dim) {
  var info = floorMaps[building];
  if (!info) return;
  currentBuilding = building;

  // 3D 우선, 없으면 2D
  if (!dim || !info[dim]) dim = info['3D'] ? '3D' : '2D';
  currentDim = dim;

  document.getElementById('floorModalTitle').textContent = building + ' 내부 도면';
  resetModalContent();

  // 3D / 2D 탭 생성 (3D 먼저)
  var dimRow = document.getElementById('dimTabRow');
  dimRow.innerHTML = '';
  ['3D','2D'].forEach(function(d) {
    if (!info[d]) return;
    var btn = document.createElement('button');
    btn.className = 'floor-tab' + (d === currentDim ? ' active' : '');
    btn.textContent = d + ' 도면';
    btn.onclick = function() { switchDim(d); };
    dimRow.appendChild(btn);
  });

  renderGallery();
  renderRoomList(building);
  document.getElementById('floorModal').classList.add('show');
}

function switchDim(dim) {
  currentDim = dim;
  document.querySelectorAll('#dimTabRow .floor-tab').forEach(function(btn) {
    btn.classList.toggle('active', btn.textContent === dim + ' 도면');
  });
  resetModalContent();
  renderGallery();
}

/* 층 키 → 버튼 레이블 변환 */
function floorLabel(f) {
  if (f === '지하') return 'B1';
  if (/^\d+$/.test(f)) return f + '층';
  return f;
}

/* 전체 모달 콘텐츠 영역 초기화 */
function resetModalContent() {
  var gal = document.getElementById('gallery3d');
  if (gal) gal.style.display = 'none';
  var gi = document.getElementById('galleryImg');
  if (gi) { gi.src = ''; gi.style.display = 'none'; }
  var gfr = document.getElementById('galleryIframe');
  if (gfr) { gfr.src = 'about:blank'; gfr.style.display = 'none'; }
  var tabWrap = document.getElementById('floorTabWrap');
  if (tabWrap) tabWrap.style.display = 'none';
  var tabRow = document.getElementById('floorTabRow');
  if (tabRow) tabRow.innerHTML = '';
  var ph = document.getElementById('floorModalPlaceholder');
  if (ph) ph.style.display = 'none';
  var rls = document.getElementById('roomListSection');
  if (rls) rls.style.display = 'none';
  var rlb = document.getElementById('roomListBody');
  if (rlb) rlb.innerHTML = '';
}

function renderGallery() {
  var info    = floorMaps[currentBuilding];
  var dimInfo = info && info[currentDim];
  var gal     = document.getElementById('gallery3d');
  var gi      = document.getElementById('galleryImg');
  var gfr     = document.getElementById('galleryIframe');
  var tabWrap = document.getElementById('floorTabWrap');
  var tabRow  = document.getElementById('floorTabRow');
  var ph      = document.getElementById('floorModalPlaceholder');

  if (!dimInfo) { if (ph) ph.style.display = 'flex'; return; }

  /* 2D: iframe */
  if (currentDim === '2D' && dimInfo.html) {
    gfr.src = dimInfo.html;
    gfr.style.display = 'block';
    gi.style.display = 'none';
    gal.style.display = 'block';
    if (tabWrap) tabWrap.style.display = 'none';
    return;
  }

  /* 3D: 이미지 + 층수 버튼 */
  if (currentDim === '3D' && dimInfo.floors && dimInfo.gallery) {
    var floors = dimInfo.floors;
    var curFloorModal = floors[0];

    function showFloor(f) {
      curFloorModal = f;
      var imgs = dimInfo.gallery[f] || [];
      if (imgs.length > 0) {
        gi.src = imgs[0];
        gi.style.display = 'block';
      }
      /* 활성 버튼 갱신 */
      if (tabRow) tabRow.querySelectorAll('.floor-tab').forEach(function(b) {
        b.classList.toggle('active', b.textContent === floorLabel(f));
      });
    }

    /* 층수 버튼 생성 */
    if (tabRow) {
      tabRow.innerHTML = '';
      floors.forEach(function(f) {
        var btn = document.createElement('button');
        btn.className = 'floor-tab' + (f === curFloorModal ? ' active' : '');
        btn.textContent = floorLabel(f);
        btn.onclick = function() { showFloor(f); };
        tabRow.appendChild(btn);
      });
    }

    /* 층수 탭 표시 (1개 이상이면 무조건 표시) */
    if (tabWrap) tabWrap.style.display = floors.length >= 1 ? 'block' : 'none';

    showFloor(curFloorModal);
    gal.style.display = 'block';
  }
}

/* ── 강의실 목록 렌더링 (DB 데이터 기반) ── */
function renderRoomList(building) {
  var sec  = document.getElementById('roomListSection');
  var body = document.getElementById('roomListBody');
  if (!sec || !body) return;

  var rooms = roomsByBuildingData[building];
  if (!rooms || rooms.length === 0) { sec.style.display = 'none'; return; }

  body.innerHTML = '';
  rooms.forEach(function(rm) {
    var row = document.createElement('div');
    row.style.cssText = 'display:flex;align-items:center;justify-content:space-between;' +
      'background:var(--bg);border:1px solid var(--line);border-radius:8px;padding:7px 11px;gap:8px;';
    var left = '<div style="display:flex;align-items:center;gap:8px;">' +
      '<span style="font-family:var(--mono);font-size:11px;background:var(--teal-lt);color:var(--teal);' +
      'border-radius:4px;padding:2px 7px;font-weight:700;">' + rm.floor + '층</span>' +
      '<span style="font-size:13px;font-weight:600;">' + escHtml(rm.name) + '</span>' +
      '</div>';
    var btn = '<button onclick="goToRoomFloorNav(' + JSON.stringify(building) + ',' + JSON.stringify(rm.name) + ',' + rm.id + ')" ' +
      'style="background:var(--teal);color:#fff;border:none;border-radius:6px;padding:4px 10px;' +
      'font-size:11px;font-weight:600;cursor:pointer;white-space:nowrap;font-family:var(--sans);">' +
      '<i class="bi bi-compass-fill"></i> 실내 안내</button>';
    row.innerHTML = left + btn;
    body.appendChild(row);
  });
  sec.style.display = 'block';
}

/* 강의실 클릭 → floorNav.jsp 이동 */
function goToRoomFloorNav(building, roomName, roomId) {
  var url = '/CAN/floorNav.jsp?building=' + encodeURIComponent(building) +
            '&destRoom='  + encodeURIComponent(roomName) +
            '&roomId='    + encodeURIComponent(roomId);
  location.href = url;
}

var currentSlides = [];

function galleryPrev() {}
function galleryNext() {}

/* ── 도면 보기 (관리자 탭용) ── */
function showBuildingFloorPlanFromRoute() {
    if (!adminToId) return;
    const ent = entranceData.find(e => e.id === adminToId);
    if (ent && ent.building) {
        location.href = '/CAN/floorNav.jsp?building=' + encodeURIComponent(ent.building);
    }
}

function showBuildingFloorPlanFromPin() {
    if (!pinTargetId) return;
    const ent = entranceData.find(e => e.id === pinTargetId);
    if (ent && ent.building) {
        location.href = '/CAN/floorNav.jsp?building=' + encodeURIComponent(ent.building);
    }
}

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
