<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
         session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser = (String)session.getAttribute("loginUser");
    String loginName = (String)session.getAttribute("loginName");
    String loginRole = (String)session.getAttribute("loginRole");
    if(loginUser == null){ response.sendRedirect("/CAN/campuslogin.jsp"); return; }
    if("guest".equals(loginRole)){ response.sendRedirect("/CAN/main_guest.jsp"); return; }

    // 파라미터
    String selType   = request.getParameter("type");   if(selType  == null) selType  = "강의실";
    String roomIdStr = request.getParameter("roomId"); if(roomIdStr== null) roomIdStr= "";
    String success   = request.getParameter("success");if(success  == null) success  = "";
    String errMsg    = request.getParameter("err");    if(errMsg   == null) errMsg   = "";

    // POST 처리
    if("POST".equals(request.getMethod())){
        String postRoomId = request.getParameter("roomId");
        String rDate      = request.getParameter("date");
        String rStart     = request.getParameter("startTime");
        String rEnd       = request.getParameter("endTime");
        String purpose    = request.getParameter("purpose");
        String phone      = request.getParameter("phone");
        String postType   = request.getParameter("type"); if(postType==null) postType="강의실";

        if(postRoomId!=null && !postRoomId.isEmpty() && rDate!=null && !rDate.isEmpty()
                && rStart!=null && rEnd!=null){
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");

                // 중복 체크
                PreparedStatement ps = conn.prepareStatement(
                    "SELECT COUNT(*) FROM room_reservations WHERE room_id=? AND reserve_date=? AND status='예약완료' AND start_time<? AND end_time>?");
                ps.setInt(1, Integer.parseInt(postRoomId));
                ps.setString(2, rDate); ps.setString(3, rEnd); ps.setString(4, rStart);
                ResultSet rs = ps.executeQuery();
                boolean dup = rs.next() && rs.getInt(1) > 0;
                rs.close(); ps.close();

                if(dup){
                    response.sendRedirect("/CAN/room_reserve.jsp?type="+java.net.URLEncoder.encode(postType,"UTF-8")+"&roomId="+postRoomId+"&err=이미+예약된+시간입니다");
                } else {
                    ps = conn.prepareStatement(
                        "INSERT INTO room_reservations(room_id,user_id,reserve_date,start_time,end_time,purpose,phone,status) VALUES(?,?,?,?,?,?,?,'예약완료')");
                    ps.setInt(1, Integer.parseInt(postRoomId));
                    ps.setString(2, loginUser);
                    ps.setString(3, rDate); ps.setString(4, rStart); ps.setString(5, rEnd);
                    ps.setString(6, purpose!=null?purpose:"");
                    ps.setString(7, phone!=null?phone:"");
                    ps.executeUpdate(); ps.close();
                    response.sendRedirect("/CAN/room_reserve.jsp?type="+java.net.URLEncoder.encode(postType,"UTF-8")+"&roomId="+postRoomId+"&success=true");
                }
                conn.close();
            } catch(Exception e){
                response.sendRedirect("/CAN/room_reserve.jsp?type="+java.net.URLEncoder.encode(selType,"UTF-8")
                    +"&roomId="+postRoomId+"&err="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));
            }
            return;
        }
    }

    // 방 목록 조회
    List<Map<String,String>> rooms = new ArrayList<>();
    Map<String,String> selRoom = null;
    List<Map<String,String>> existReserves = new ArrayList<>();

    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(
            "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");

        // 선택된 타입의 방 목록
        PreparedStatement ps = conn.prepareStatement(
            "SELECT room_id,room_name,room_type,building,floor,room_no,capacity,description FROM rooms WHERE room_type=? AND is_active='Y' ORDER BY floor,room_no");
        ps.setString(1, selType);
        ResultSet rs = ps.executeQuery();
        while(rs.next()){
            Map<String,String> r = new LinkedHashMap<>();
            r.put("id",       String.valueOf(rs.getInt("room_id")));
            r.put("name",     rs.getString("room_name"));
            r.put("type",     rs.getString("room_type"));
            r.put("building", rs.getString("building"));
            r.put("floor",    String.valueOf(rs.getInt("floor")));
            r.put("no",       rs.getString("room_no"));
            r.put("cap",      String.valueOf(rs.getInt("capacity")));
            r.put("desc",     rs.getString("description")!=null?rs.getString("description"):"");
            rooms.add(r);
            if(r.get("id").equals(roomIdStr)) selRoom = r;
        }
        rs.close(); ps.close();

        // 선택된 방의 기존 예약
        if(selRoom != null){
            ps = conn.prepareStatement(
                "SELECT reserve_date,start_time,end_time,user_id FROM room_reservations WHERE room_id=? AND reserve_date>=CURDATE() AND status='예약완료' ORDER BY reserve_date,start_time LIMIT 20");
            ps.setInt(1, Integer.parseInt(roomIdStr));
            rs = ps.executeQuery();
            while(rs.next()){
                Map<String,String> rv = new LinkedHashMap<>();
                rv.put("date",  rs.getString(1));
                rv.put("start", rs.getString(2));
                rv.put("end",   rs.getString(3));
                rv.put("user",  rs.getString(4));
                existReserves.add(rv);
            }
            rs.close(); ps.close();
        }
        conn.close();
    } catch(Exception ignored){}

    String today = new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date());
    String roleLabel = "student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"관리자";
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ICT CAN — 공간 예약</title>
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
  --red-main: #dc2626;
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

/* HEADER */
.app-header {
  background: var(--header-bg);
  backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid var(--border-color);
  transition: all 0.3s ease;
  padding: 1rem 2rem;
}

.header-inner {
  max-width: 1200px;
  margin: 0 auto;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
}

.brand-logo {
  font-family: var(--font-plus);
  font-weight: 800;
  font-size: 1.3rem;
  color: var(--txt-main);
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-logo i {
  color: var(--sky-primary);
}

.nav-right {
  display: flex;
  gap: 8px;
  align-items: center;
  margin-left: auto;
}

.nav-link {
  font-size: 0.9rem;
  font-weight: 600;
  color: var(--txt-sub);
  padding: 8px 16px;
  border-radius: var(--radius-pill);
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 6px;
  cursor: pointer;
  border: none;
  background: none;
  text-decoration: none;
}

.nav-link:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

.user-tag-pill {
  background: var(--surface);
  border: 1px solid #cbd5e1;
  padding: 6px 14px;
  border-radius: var(--radius-pill);
  display: flex;
  align-items: center;
  gap: 6px;
  font-size: 0.85rem;
  font-weight: 700;
  color: var(--txt-main);
  font-family: var(--font-mono);
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

/* MAIN CONTAINER */
.main-container {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem 4rem;
}

/* HERO SEARCH SECTION */
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

[data-theme="dark"] .hero-search-card::after {
  background: linear-gradient(135deg, rgba(255, 255, 255, 0.02) 0%, rgba(74, 222, 128, 0.08) 100%);
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

.hero-title em {
  color: var(--emerald-main);
  font-style: normal;
}

[data-theme="dark"] .hero-title em {
  color: #4ade80;
}

.hero-subtitle {
  color: #64748b;
  font-size: 0.95rem;
  margin-bottom: 1.5rem;
}

[data-theme="dark"] .hero-subtitle {
  color: rgba(255, 255, 255, 0.85);
}

/* TYPE TABS */
.type-tabs {
  display: flex;
  gap: 0.75rem;
  margin-bottom: 2rem;
  flex-wrap: wrap;
}

.type-tab {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.5rem;
  border-radius: var(--radius-lg);
  border: 2px solid var(--border-color);
  background: var(--surface);
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--txt-sub);
  cursor: pointer;
  text-decoration: none;
  transition: all 0.2s;
  box-shadow: var(--shadow-soft);
}

.type-tab:hover {
  border-color: var(--sky-primary);
  color: var(--sky-primary);
}

.type-tab.active {
  background: var(--sky-primary);
  border-color: var(--sky-primary);
  color: #ffffff;
  box-shadow: 0 4px 16px rgba(2, 132, 199, 0.25);
}

.type-tab .icon {
  font-size: 1.2rem;
}

.type-tab .cnt {
  font-family: var(--font-mono);
  font-size: 0.75rem;
  padding: 2px 8px;
  border-radius: var(--radius-pill);
  background: rgba(255, 255, 255, 0.25);
  margin-left: 0.25rem;
}

.type-tab:not(.active) .cnt {
  background: var(--sky-bg);
  color: var(--txt-muted);
}

/* LAYOUT */
.layout {
  display: grid;
  grid-template-columns: 300px 1fr;
  gap: 1.5rem;
  align-items: start;
}

/* ROOM LIST */
.room-list-card {
  background: var(--surface);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-soft);
  overflow: hidden;
}

.room-list-head {
  padding: 1rem;
  border-bottom: 1.5px solid var(--border-color);
  background: var(--sky-bg);
  display: flex;
  align-items: center;
  gap: 0.75rem;
}

.room-list-title {
  font-size: 0.95rem;
  font-weight: 800;
  color: var(--txt-main);
}

.room-item {
  display: flex;
  align-items: center;
  gap: 1rem;
  padding: 1rem;
  border-bottom: 1px solid var(--border-color);
  cursor: pointer;
  transition: background 0.12s;
  text-decoration: none;
  color: var(--txt-main);
}

.room-item:last-child {
  border-bottom: none;
}

.room-item:hover {
  background: var(--sky-bg);
}

.room-item.selected {
  background: var(--sky-bg);
  border-left: 3px solid var(--sky-primary);
}

.room-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.ri-강의실 { background: var(--sky-bg); }
.ri-컴퓨터실 { background: #f0fdf4; }
.ri-세미나실 { background: #f5f3ff; }

.room-name {
  font-size: 0.95rem;
  font-weight: 700;
  color: var(--txt-main);
}

.room-meta {
  font-size: 0.8rem;
  color: var(--txt-muted);
  font-family: var(--font-mono);
  margin-top: 0.25rem;
}

.room-cap {
  font-family: var(--font-mono);
  font-size: 0.8rem;
  padding: 4px 10px;
  border-radius: var(--radius-pill);
  background: var(--sky-bg);
  color: var(--sky-primary);
  margin-left: auto;
  flex-shrink: 0;
}

/* CARD */
.card {
  background: var(--surface);
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-lg);
  box-shadow: var(--shadow-soft);
  overflow: hidden;
  margin-bottom: 2rem;
}

.card-head {
  padding: 1rem;
  border-bottom: 1.5px solid var(--border-color);
  display: flex;
  align-items: center;
  gap: 0.75rem;
  background: var(--sky-bg);
}

.ch-icon {
  width: 40px;
  height: 40px;
  border-radius: 10px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.ch-title {
  font-size: 1rem;
  font-weight: 800;
  color: var(--txt-main);
}

.ch-sub {
  font-size: 0.8rem;
  color: var(--txt-muted);
  font-family: var(--font-mono);
  margin-top: 0.25rem;
}

.card-body {
  padding: 1.5rem;
}

/* FORM */
.f-label {
  font-family: var(--font-mono);
  font-size: 0.85rem;
  color: var(--txt-sub);
  display: block;
  margin-bottom: 0.5rem;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.f-input {
  width: 100%;
  border: 1.5px solid var(--border-color);
  border-radius: var(--radius-md);
  padding: 11px 14px;
  font-size: 0.95rem;
  outline: none;
  background: var(--surface);
  color: var(--txt-main);
  font-family: var(--font-main);
  transition: border-color 0.2s, box-shadow 0.2s;
}

.f-input:focus {
  border-color: var(--sky-primary);
  box-shadow: 0 0 0 3px rgba(2, 132, 199, 0.15);
}

[data-theme="dark"] .f-input {
  background: rgba(255, 255, 255, 0.1);
  border-color: rgba(255, 255, 255, 0.3);
  color: #f1f5f9;
}

[data-theme="dark"] .f-input:focus {
  background: rgba(255, 255, 255, 0.18);
  border-color: rgba(255, 255, 255, 0.6);
  box-shadow: 0 0 0 3px rgba(56, 189, 248, 0.15);
}

/* BUTTONS */
.btn-prim {
  display: inline-block;
  text-align: center;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: white;
  border: none;
  border-radius: var(--radius-md);
  padding: 11px 24px;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
  text-decoration: none;
  font-size: 0.95rem;
  width: 100%;
}

.btn-prim:hover {
  background: linear-gradient(135deg, #0369a1 0%, #0284c7 100%);
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.3);
}

/* TIME CHECK */
.time-check {
  margin-top: 0.5rem;
  padding: 10px 14px;
  border-radius: var(--radius-md);
  font-size: 0.85rem;
  font-weight: 600;
  display: none;
}

.time-ok {
  background: #dcfce7;
  border: 1px solid #86efac;
  color: #15803d;
}

[data-theme="dark"] .time-ok {
  background: #1a3a1a;
  border-color: #16a34a;
  color: #4ade80;
}

.time-err {
  background: #fef2f2;
  border: 1px solid #fca5a5;
  color: #dc2626;
}

[data-theme="dark"] .time-err {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

/* ALERTS */
.alert-err {
  background: #fef2f2;
  border: 1.5px solid #fca5a5;
  border-radius: var(--radius-md);
  color: var(--red-main);
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

[data-theme="dark"] .alert-err {
  background: #7f1d1d;
  border-color: #991b1b;
  color: #fca5a5;
}

.alert-ok {
  background: #dcfce7;
  border: 1.5px solid #86efac;
  border-radius: var(--radius-md);
  color: #15803d;
  padding: 12px 16px;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 600;
}

[data-theme="dark"] .alert-ok {
  background: #1a3a1a;
  border-color: #16a34a;
  color: #4ade80;
}

/* ROOM INFO BOX */
.room-info-box {
  background: var(--sky-bg);
  border: 1.5px solid rgba(2, 132, 199, 0.4);
  border-radius: var(--radius-lg);
  padding: 1.5rem;
  margin-bottom: 1.5rem;
  display: flex;
  align-items: center;
  gap: 1rem;
}

[data-theme="dark"] .room-info-box {
  background: #1e3a5f;
  border-color: rgba(56, 189, 248, 0.3);
  color: #f1f5f9;
}

[data-theme="dark"] .room-info-box p,
[data-theme="dark"] .room-info-box span,
[data-theme="dark"] .room-info-box div {
  color: #e2e8f0;
}

.rib-icon {
  font-size: 1.75rem;
}

.rib-name {
  font-size: 1rem;
  font-weight: 800;
  color: var(--sky-primary);
}

.rib-meta {
  font-size: 0.85rem;
  color: var(--txt-sub);
  margin-top: 0.25rem;
}

/* EMPTY STATE */
.empty-state {
  text-align: center;
  padding: 2.5rem 1.5rem;
  color: var(--txt-muted);
}

.empty-icon {
  font-size: 2rem;
  display: block;
  margin-bottom: 0.75rem;
  opacity: 0.5;
}

.empty-text {
  font-size: 0.95rem;
  line-height: 1.7;
}

/* FOOTER */
.app-footer {
  background: var(--surface);
  border-top: 1px solid var(--border-color);
  color: var(--txt-sub);
  padding: 2rem 0;
  margin-top: 4rem;
  font-size: 0.85rem;
}

.footer-inner {
  max-width: 1200px;
  margin: 0 auto;
  padding: 0 1rem;
  display: flex;
  align-items: center;
  justify-content: space-between;
  flex-wrap: wrap;
  gap: 1rem;
}

.footer-logo {
  display: flex;
  align-items: center;
  gap: 8px;
  font-weight: 700;
  color: var(--txt-main);
}

.footer-logo em {
  color: var(--sky-primary);
  font-style: normal;
}

.footer-team {
  text-align: center;
  font-family: var(--font-mono);
  line-height: 1.8;
}

.footer-team strong {
  color: var(--sky-primary);
  font-size: 0.9rem;
}

/* RESPONSIVE */
@media (max-width: 900px) {
  .layout {
    grid-template-columns: 1fr;
  }

  .hero-search-card {
    grid-template-columns: 1fr;
  }
}

@media (max-width: 768px) {
  .header-inner {
    gap: 0.5rem;
  }

  .nav-right {
    order: 3;
    width: 100%;
  }

  .hero-search-card {
    padding: 1.5rem 1rem;
  }

  .hero-title {
    font-size: 1.5rem;
  }

  .main-container {
    padding: 1rem 0.75rem 2rem;
  }
}
</style>
</head><body>

<!-- TOP NAVIGATION BAR -->
<header class="app-header">
  <div class="header-inner">
    <a href="/CAN/main_<%= loginRole %>.jsp" class="brand-logo">
      <i class="bi bi-compass-fill fs-5"></i>
      <span>ICT <strong style="color: var(--sky-primary);">CAN</strong></span>
    </a>
    <div class="nav-right">
      <span class="user-tag-pill">
        <i class="bi bi-person-circle"></i>
        <%= loginName %> <span style="color: var(--sky-primary);">
        <%= roleLabel %>
        </span>
      </span>
      <button type="button" class="theme-toggle" onclick="toggleTheme()">
        <i class="bi bi-moon" id="themeIcon"></i>
      </button>
      <a href="/CAN/main_<%= loginRole %>.jsp" class="nav-link"><i class="bi bi-house"></i>홈</a>
      <form action="/CAN/logout" method="post" class="m-0">
        <button type="submit" class="nav-link" style="border: none; background: none; cursor: pointer;">
          <i class="bi bi-box-arrow-right"></i>로그아웃
        </button>
      </form>
    </div>
  </div>
</header>

<main class="main-container">

  <!-- HERO SEARCH SECTION -->
  <div class="hero-search-card">
    <div class="hero-search-content">
      <div class="hero-subtitle">ICT CAN · 공간 예약</div>
      <h1 class="hero-title">강의실 · 세미나실 · <em>컴퓨터실</em> 예약</h1>
      <p class="hero-subtitle">제1공학관 내 공간을 예약하고 편리하게 이용하세요.</p>
    </div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!success.isEmpty()){%>
  <div class="alert-ok">
    <i class="bi bi-check-circle-fill"></i>예약이 완료되었습니다!
  </div>
  <%}%>
  <% if(!errMsg.isEmpty()){%>
  <div class="alert-err">
    <i class="bi bi-exclamation-circle-fill"></i><%= errMsg %>
  </div>
  <%}%>

  <!-- 타입 탭 -->
  <div class="type-tabs">
    <a href="/CAN/room_reserve.jsp?type=강의실" class="type-tab <%= "강의실".equals(selType)?"active":"" %>">
      <span class="icon">🏫</span>강의실
    </a>
    <a href="/CAN/room_reserve.jsp?type=컴퓨터실" class="type-tab <%= "컴퓨터실".equals(selType)?"active":"" %>">
      <span class="icon">💻</span>컴퓨터실
    </a>
    <a href="/CAN/room_reserve.jsp?type=세미나실" class="type-tab <%= "세미나실".equals(selType)?"active":"" %>">
      <span class="icon">🪑</span>세미나실
    </a>
  </div>

  <!-- 메인 레이아웃 -->
  <div class="layout">

    <!-- 왼쪽: 방 목록 -->
    <div class="room-list-card">
      <div class="room-list-head">
        <i class="bi bi-door-open" style="color:var(--sky-primary)"></i>
        <span class="room-list-title"><%= selType %> — 제1공학관</span>
      </div>
      <% if(rooms.isEmpty()){ %>
      <div class="empty-state">
        <span class="empty-icon"><i class="bi bi-inbox"></i></span>
        <div class="empty-text">등록된 방이 없습니다.</div>
      </div>
      <% } else { for(Map<String,String> r : rooms) {
          boolean isSel = r.get("id").equals(roomIdStr);
          String iconEmoji = "강의실".equals(selType)?"🏫":"컴퓨터실".equals(selType)?"💻":"🪑";
          String riClass = "ri-" + selType;
      %>
      <a href="/CAN/room_reserve.jsp?type=<%= java.net.URLEncoder.encode(selType,"UTF-8") %>&roomId=<%= r.get("id") %>"
         class="room-item <%= isSel?"selected":"" %>">
        <div class="room-icon <%= riClass %>"><%= iconEmoji %></div>
        <div style="flex:1;min-width:0;">
          <div class="room-name"><%= r.get("name") %></div>
          <div class="room-meta"><%= r.get("floor") %>층 · <%= r.get("desc") %></div>
        </div>
        <div class="room-cap"><i class="bi bi-people-fill me-1"></i><%= r.get("cap") %>명</div>
      </a>
      <% }} %>
    </div>

    <!-- 오른쪽: 예약 폼 + 기존 예약 -->
    <div>
      <% if(selRoom == null) { %>
      <div class="card">
        <div class="card-body">
          <div class="empty-state">
            <span class="empty-icon"><i class="bi bi-hand-index"></i></span>
            <div class="empty-text">왼쪽 목록에서 예약할 방을 선택하세요.</div>
          </div>
        </div>
      </div>
      <% } else { %>

      <!-- 선택된 방 정보 -->
      <div class="room-info-box">
        <div class="rib-icon"><%= "강의실".equals(selType)?"🏫":"컴퓨터실".equals(selType)?"💻":"🪑" %></div>
        <div>
          <div class="rib-name"><%= selRoom.get("name") %></div>
          <div class="rib-meta">
            <i class="bi bi-building me-1"></i><%= selRoom.get("building") %>
            &nbsp;·&nbsp;<%= selRoom.get("floor") %>층
            &nbsp;·&nbsp;<i class="bi bi-people-fill me-1"></i><%= selRoom.get("cap") %>명
            &nbsp;·&nbsp;<%= selRoom.get("desc") %>
          </div>
        </div>
      </div>

      <div class="row g-4">
        <!-- 예약 폼 -->
        <div class="col-lg-7">
          <div class="card">
            <div class="card-head">
              <div class="ch-icon">📅</div>
              <div>
                <div class="ch-title">예약 정보 입력</div>
                <div class="ch-sub"><%= selRoom.get("name") %></div>
              </div>
            </div>
            <div class="card-body">
              <form method="post" action="/CAN/room_reserve.jsp" onsubmit="return checkBefore()">
                <input type="hidden" name="roomId" value="<%= selRoom.get("id") %>">
                <input type="hidden" name="type" value="<%= selType %>">

                <div style="margin-bottom:1.5rem">
                  <label class="f-label">예약 날짜 *</label>
                  <input class="f-input" type="date" name="date" id="rDate" required min="<%= today %>" onchange="checkTime()">
                </div>

                <div class="row g-3" style="margin-bottom:1.5rem">
                  <div class="col-6">
                    <label class="f-label">시작 시간 *</label>
                    <input class="f-input" type="time" name="startTime" id="rStart" required onchange="checkTime()">
                  </div>
                  <div class="col-6">
                    <label class="f-label">종료 시간 *</label>
                    <input class="f-input" type="time" name="endTime" id="rEnd" required onchange="checkTime()">
                  </div>
                </div>

                <div id="timeCheck" class="time-check"></div>

                <div style="margin-bottom:1.5rem">
                  <label class="f-label">사용 목적</label>
                  <input class="f-input" type="text" name="purpose" placeholder="예) 캡스톤 프로젝트 회의">
                </div>

                <div style="margin-bottom:2rem">
                  <label class="f-label">연락처</label>
                  <input class="f-input" type="text" name="phone" placeholder="010-0000-0000">
                </div>

                <button type="submit" class="btn-prim">
                  <i class="bi bi-check-circle me-1"></i>예약 신청
                </button>
              </form>
            </div>
          </div>
        </div>

        <!-- 기존 예약 현황 -->
        <div class="col-lg-5">
          <div class="card">
            <div class="card-head">
              <div class="ch-icon">⏰</div>
              <div>
                <div class="ch-title">기존 예약 현황</div>
                <div class="ch-sub"><%= existReserves.size() %>건 예약 중</div>
              </div>
            </div>
            <div class="card-body">
              <% if(existReserves.isEmpty()){ %>
              <div style="text-align:center;padding:1.5rem;color:var(--txt-muted)">
                <i class="bi bi-check-circle" style="font-size:2rem;display:block;margin-bottom:0.5rem;color:var(--emerald-main);opacity:.6"></i>
                <div style="font-size:0.9rem">예약 내역이 없습니다.<br>이 공간은 예약 가능합니다!</div>
              </div>
              <% } else { for(Map<String,String> rv : existReserves){ %>
              <div style="border:1px solid #fca5a5;border-radius:var(--radius-md);padding:0.75rem 1rem;margin-bottom:0.5rem;background:#fef2f2">
                <div style="font-weight:700;color:#dc2626;font-size:0.85rem"><i class="bi bi-x-circle me-1"></i><%= rv.get("date") %></div>
                <div style="font-size:0.95rem;font-weight:600;margin:0.25rem 0"><%= rv.get("start") %> ~ <%= rv.get("end") %></div>
                <div style="font-size:0.85rem;color:var(--txt-muted)">예약자: <%= rv.get("user") %></div>
              </div>
              <% }} %>
            </div>
          </div>
        </div>
      </div><!-- row -->

      <% } %>
    </div><!-- 오른쪽 -->
  </div><!-- layout -->

</main>


<!-- FOOTER -->
<footer class="app-footer">
  <div class="footer-inner">
    <a href="/CAN/campuslogin.jsp" class="footer-logo">
      <span style="width: 24px; height: 24px; background: var(--sky-primary); border-radius: 6px; display: flex; align-items: center; justify-content: center; overflow: hidden;">
        <img src="/CAN/images/logo.png" alt="ICT" style="width: 100%; height: 100%; object-fit: contain;">
      </span>
      ICT <em>CAN</em>
    </a>
    <div class="footer-team">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 &nbsp;&middot;&nbsp; 권동해 &nbsp;&middot;&nbsp; 원태연 &nbsp;&middot;&nbsp; 이수혁
    </div>
    <div style="text-align: right; font-family: var(--font-mono); font-size: 0.8rem;">
      ICT폴리텍대학 캠퍼스 내비게이션<br>
      &copy; 2026 ICT CAN. All rights reserved.
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

// Existing Reservations Data
var er = [<% for(int i=0;i<existReserves.size();i++){Map<String,String> rv=existReserves.get(i); %>
  {date:"<%= rv.get("date") %>",start:"<%= rv.get("start") %>",end:"<%= rv.get("end") %>"}<%=i<existReserves.size()-1?",":"" %>
<% } %>];

function checkTime(){
  var date=document.getElementById('rDate').value,
      start=document.getElementById('rStart').value,
      end=document.getElementById('rEnd').value,
      el=document.getElementById('timeCheck');
  if(!date||!start||!end){el.style.display='none';return;}
  if(start>=end){
    el.className='time-check time-err';
    el.innerHTML='<i class="bi bi-x-circle-fill me-2"></i>종료 시간이 시작 시간보다 빠릅니다.';
    el.style.display='block';return;
  }
  var c=null;
  for(var r of er){if(r.date===date&&start<r.end&&end>r.start){c=r;break;}}
  if(c){
    el.className='time-check time-err';
    el.innerHTML='<i class="bi bi-x-circle-fill me-2"></i><strong>예약 불가!</strong> '+c.start+'~'+c.end+' 이미 예약되어 있습니다.';
  } else {
    el.className='time-check time-ok';
    el.innerHTML='<i class="bi bi-check-circle-fill me-2"></i><strong>예약 가능!</strong> 선택하신 시간에 예약할 수 있습니다.';
  }
  el.style.display='block';
}

function checkBefore(){
  var el=document.getElementById('timeCheck');
  if(el&&el.classList.contains('time-err')){alert('예약 불가능한 시간입니다.');return false;}
  return true;
}
</script>

</body></html>
