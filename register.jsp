<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" import="java.sql.*" %>
<%
    // POST 처리 - 회원가입 DB 저장
    if ("POST".equals(request.getMethod())) {
        request.setCharacterEncoding("UTF-8");
        String userId    = request.getParameter("userId");
        String userName  = request.getParameter("userName");
        String userEmail = request.getParameter("userEmail");
        String userPw    = request.getParameter("userPw");
        String userPw2   = request.getParameter("userPw2");
        String role      = request.getParameter("role");
        String dept      = request.getParameter("dept");
        String studentNum= request.getParameter("studentNum");
        String agree     = request.getParameter("agree");

        if (userId==null) userId=""; if (userName==null) userName="";
        if (userEmail==null) userEmail=""; if (userPw==null) userPw="";
        if (userPw2==null) userPw2=""; if (role==null) role="student";
        if (dept==null) dept=""; if (studentNum==null) studentNum="";

        String errMsg = "";
        if (userId.trim().isEmpty() || userName.trim().isEmpty() || userPw.trim().isEmpty()) {
            errMsg = "필수 항목을 모두 입력해 주세요.";
        } else if (!userPw.equals(userPw2)) {
            errMsg = "비밀번호가 일치하지 않습니다.";
        } else if (userPw.length() < 4) {
            errMsg = "비밀번호는 4자 이상이어야 합니다.";
        } else if (!"on".equals(agree)) {
            errMsg = "이용약관에 동의해 주세요.";
        }

        if (errMsg.isEmpty()) {
            try {
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection conn = DriverManager.getConnection(
                    "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
                // 중복 아이디 체크
                PreparedStatement ps = conn.prepareStatement("SELECT COUNT(*) FROM users WHERE user_id=?");
                ps.setString(1, userId.trim());
                ResultSet rs = ps.executeQuery();
                boolean dup = rs.next() && rs.getInt(1) > 0;
                rs.close(); ps.close();
                if (dup) {
                    errMsg = "이미 사용 중인 아이디입니다.";
                    conn.close();
                } else {
                    ps = conn.prepareStatement(
                        "INSERT INTO users (user_id,user_pw,user_name,user_email,dept,student_num,role) VALUES (?,?,?,?,?,?,?)");
                    ps.setString(1, userId.trim());
                    ps.setString(2, userPw);
                    ps.setString(3, userName.trim());
                    ps.setString(4, userEmail.trim());
                    ps.setString(5, dept.trim());
                    ps.setString(6, studentNum.trim().isEmpty() ? null : studentNum.trim());
                    ps.setString(7, role);
                    ps.executeUpdate();
                    ps.close(); conn.close();
                    response.sendRedirect("/CampusNav/campuslogin.jsp?registered=true");
                    return;
                }
            } catch (Exception e) {
                errMsg = "회원가입 처리 중 오류: " + e.getMessage();
            }
        }
        request.setAttribute("errMsg", errMsg);
        request.setAttribute("prevUserId", userId);
        request.setAttribute("prevUserName", userName);
        request.setAttribute("prevEmail", userEmail);
        request.setAttribute("prevDept", dept);
    }

    if (session.getAttribute("loginUser") != null) {
        response.sendRedirect("/CampusNav/campuslogin.jsp");
        return;
    }
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 회원가입</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>

:root {
  --white:#ffffff; --bg:#f7f8fa; --bg2:#f0f2f5;
  --line:#e4e7ed; --line2:#d0d5df;
  --txt:#111827; --txt2:#4b5563; --txt3:#9ca3af;
  --blue:#1a56db; --blue-lt:#eff4ff; --blue-md:#c7d7fd;
  --teal:#0d9488; --teal-lt:#f0fdfa; --teal-md:#99f6e4;
  --amber:#d97706; --amber-lt:#fffbeb;
  --red:#dc2626; --red-lt:#fef2f2;
  --green:#16a34a; --green-lt:#f0fdf4;
  --purple:#7c3aed; --purple-lt:#f5f3ff;
  --mono:'DM Mono',monospace;
  --sans:'DM Sans','Noto Sans KR',sans-serif;
  --r:12px; --r2:20px;
  --shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.04);
  --shadow2:0 2px 8px rgba(0,0,0,.08),0 12px 32px rgba(0,0,0,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:15px;line-height:1.65;}

/* TOPNAV */
.topnav{display:flex;align-items:center;justify-content:space-between;padding:14px 28px;background:var(--white);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:100;box-shadow:0 1px 4px rgba(0,0,0,.04);}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;color:var(--txt);letter-spacing:-.02em;text-decoration:none;}
.logo-dot{width:32px;height:32px;border-radius:8px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.logo-dot img{width:100%;height:100%;object-fit:contain;}
.logo em{color:var(--blue);font-style:normal;}
.nav-right{display:flex;gap:8px;align-items:center;}
.chip{font-family:var(--mono);font-size:12px;padding:6px 14px;border-radius:999px;background:var(--white);border:1px solid var(--line);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-block;}
.chip:hover{border-color:var(--blue);color:var(--blue);}
.chip-blue{background:var(--blue);color:white;border-color:var(--blue);}
.chip-blue:hover{background:#1647c0;color:white;}
.role-chip{font-family:var(--mono);font-size:12px;padding:5px 13px;border-radius:6px;background:var(--blue-lt);border:1px solid var(--blue-md);color:var(--blue);}

/* SHELL */
.shell{max-width:1380px;margin:0 auto;padding:28px 28px 72px;}

/* HERO */
.hero{background:var(--white);border:1px solid var(--line);border-radius:var(--r2);padding:40px 44px;margin-bottom:24px;box-shadow:var(--shadow);display:grid;grid-template-columns:1fr auto;gap:32px;align-items:center;position:relative;overflow:hidden;}
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,var(--blue-lt) 0%,var(--teal-lt) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);}
.hero-content{position:relative;z-index:1;}
.hero-eyebrow{font-family:var(--mono);font-size:12px;color:var(--blue);letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px;}
.hero-title{font-size:28px;font-weight:800;line-height:1.25;letter-spacing:-.03em;margin-bottom:10px;color:var(--txt);}
.hero-title em{color:var(--blue);font-style:normal;}
.hero-desc{color:var(--txt2);font-size:15px;line-height:1.85;max-width:560px;margin-bottom:18px;}
.tag-row{display:flex;flex-wrap:wrap;gap:6px;}
.tag{font-family:var(--mono);font-size:12px;padding:4px 11px;border-radius:6px;background:var(--bg);border:1px solid var(--line);color:var(--txt2);}
.tag b{color:var(--blue);}
.hero-side{position:relative;z-index:2;display:flex;flex-direction:column;align-items:center;gap:10px;min-width:120px;}
.hero-illo{font-size:56px;line-height:1;}

/* STAT ROW */
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
.stat-card{background:var(--white);border:1px solid var(--line);border-radius:var(--r2);padding:22px 24px;box-shadow:var(--shadow);display:flex;align-items:flex-start;gap:16px;transition:box-shadow .2s,transform .2s;}
.stat-card:hover{box-shadow:var(--shadow2);transform:translateY(-2px);}
.stat-icon{width:46px;height:46px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:22px;flex-shrink:0;}
.si-blue{background:var(--blue-lt);} .si-teal{background:var(--teal-lt);} .si-purple{background:var(--purple-lt);} .si-amber{background:var(--amber-lt);}
.stat-label{font-size:12px;color:var(--txt3);font-family:var(--mono);margin-bottom:4px;}
.stat-val{font-size:30px;font-weight:800;letter-spacing:-.04em;line-height:1;margin-bottom:4px;}
.sv-blue{color:var(--blue);} .sv-teal{color:var(--teal);} .sv-purple{color:var(--purple);} .sv-amber{color:var(--amber);}
.stat-sub{font-size:12px;color:var(--txt3);line-height:1.5;}

/* CARD */
.card{background:var(--white);border:1px solid var(--line);border-radius:var(--r2);box-shadow:var(--shadow);overflow:hidden;margin-bottom:20px;}
.card-head{padding:18px 24px;border-bottom:1px solid var(--line);display:flex;align-items:center;gap:12px;}
.ch-icon{width:36px;height:36px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
.ch-title{font-size:15px;font-weight:700;color:var(--txt);}
.ch-sub{font-size:12px;color:var(--txt3);margin-top:2px;}
.card-body{padding:20px 24px;}

/* TABLE */
.tbl{width:100%;border-collapse:collapse;}
.tbl thead th{font-family:var(--mono);font-size:12px;text-transform:uppercase;letter-spacing:.07em;color:var(--txt3);padding:11px 14px;border-bottom:1.5px solid var(--line);font-weight:500;text-align:left;background:var(--bg);}
.tbl tbody td{padding:13px 14px;border-bottom:1px solid var(--line);font-size:14px;vertical-align:middle;}
.tbl tbody tr:last-child td{border-bottom:none;}
.tbl tbody tr:hover td{background:var(--bg);}
.tbl tbody tr{cursor:pointer;transition:background .1s;}

/* BADGES */
.badge-ok{background:var(--green-lt);color:var(--green);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);white-space:nowrap;}
.badge-busy{background:var(--red-lt);color:var(--red);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);white-space:nowrap;}
.badge-warn{background:var(--amber-lt);color:var(--amber);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);white-space:nowrap;}
.badge-blue{background:var(--blue-lt);color:var(--blue);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);}
.badge-purple{background:var(--purple-lt);color:var(--purple);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);}
.badge-teal{background:var(--teal-lt);color:var(--teal);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:600;font-family:var(--mono);}

/* BUTTONS */
.btn-prim{display:inline-block;text-align:center;background:var(--blue);color:white;border:none;border-radius:var(--r);padding:11px 20px;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s;text-decoration:none;}
.btn-prim:hover{background:#1647c0;color:white;}
.btn-ghost{display:inline-block;text-align:center;background:transparent;color:var(--txt2);border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 20px;font-size:14px;font-weight:600;cursor:pointer;transition:all .15s;text-decoration:none;}
.btn-ghost:hover{border-color:var(--blue);color:var(--blue);}
.btn-sm{font-family:var(--mono);font-size:12px;padding:6px 14px;border-radius:var(--r);border:1.5px solid var(--line2);background:var(--white);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-block;}
.btn-sm:hover{border-color:var(--blue);color:var(--blue);}
.btn-danger{background:var(--red);color:white;border:none;border-radius:var(--r);padding:11px 20px;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s;}
.btn-danger:hover{background:#b91c1c;}

/* FORM */
.f-label{font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:500;}
.f-input{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:11px 14px;font-size:14px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);transition:border-color .15s;}
.f-input:focus{border-color:var(--blue);box-shadow:0 0 0 3px var(--blue-lt);}
.f-select{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:11px 14px;font-size:14px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);}

/* TABS */
.tab-bar{display:flex;gap:4px;border-bottom:2px solid var(--line);margin-bottom:20px;}
.tab-btn{font-family:var(--mono);font-size:13px;font-weight:500;padding:10px 18px;border:none;background:transparent;color:var(--txt3);cursor:pointer;transition:all .15s;border-bottom:2px solid transparent;margin-bottom:-2px;}
.tab-btn:hover{color:var(--blue);}
.tab-btn.active{color:var(--blue);border-bottom-color:var(--blue);font-weight:700;}
.tab-content{display:none;}
.tab-content.active{display:block;}

/* SEARCH BAR */
.search-bar{display:flex;gap:8px;align-items:center;flex-wrap:wrap;}
.search-bar input{flex:1;min-width:180px;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 16px;font-size:14px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);}
.search-bar input:focus{border-color:var(--blue);box-shadow:0 0 0 3px var(--blue-lt);}
.search-bar select{border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:13px;outline:none;background:var(--white);color:var(--txt);}

/* PAGER */
.pager{display:flex;gap:4px;justify-content:center;flex-wrap:wrap;margin-top:20px;}
.pb{border:1.5px solid var(--line);background:var(--white);border-radius:8px;padding:6px 12px;font-size:13px;cursor:pointer;text-decoration:none;color:var(--txt2);font-family:var(--mono);transition:all .15s;}
.pb:hover{border-color:var(--blue);color:var(--blue);}
.pb.on{background:var(--blue);color:white;border-color:var(--blue);}

/* LIST */
.list-item{display:flex;align-items:center;gap:14px;padding:14px 0;border-bottom:1px solid var(--line);cursor:pointer;transition:background .15s;}
.list-item:last-child{border-bottom:none;}

/* FLOW BOX */
.flow-box{display:flex;align-items:center;gap:16px;background:var(--bg);border-radius:var(--r2);padding:20px 24px;flex-wrap:wrap;}
.flow-card{flex:1;min-width:160px;background:var(--white);border-radius:var(--r);padding:16px 18px;border:1.5px solid var(--line);}
.flow-card.from{border-color:#fca5a5;background:var(--red-lt);}
.flow-card.to{border-color:#86efac;background:var(--green-lt);}
.flow-label-sm{font-size:11px;font-weight:700;text-transform:uppercase;letter-spacing:.06em;margin-bottom:4px;font-family:var(--mono);}
.fl-from{color:var(--red);} .fl-to{color:var(--green);}
.flow-dept{font-size:16px;font-weight:800;color:var(--txt);}
.flow-loc{font-size:13px;color:var(--txt3);margin-top:4px;}

/* INFO TABLE */
.info-row{display:flex;padding:11px 0;border-bottom:1px solid var(--line);}
.info-row:last-child{border-bottom:none;}
.info-key{font-family:var(--mono);font-size:12px;color:var(--txt3);width:120px;flex-shrink:0;padding-top:2px;}
.info-val{font-size:14px;color:var(--txt);font-weight:500;}

/* ALERT */
.alert-err{background:var(--red-lt);border:1px solid #fca5a5;border-radius:var(--r);color:var(--red);font-size:13px;padding:11px 14px;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
.alert-ok{background:var(--green-lt);border:1px solid #86efac;border-radius:var(--r);color:var(--green);font-size:13px;padding:11px 14px;margin-bottom:14px;display:flex;align-items:center;gap:8px;}
.alert-warn{background:var(--amber-lt);border:1px solid #fde68a;border-radius:var(--r);color:var(--amber);font-size:13px;padding:11px 14px;margin-bottom:14px;display:flex;align-items:center;gap:8px;}

/* TIME CHECK */
.time-check{margin-top:8px;padding:10px 14px;border-radius:var(--r);font-size:13px;font-weight:600;display:none;}
.time-ok{background:var(--green-lt);border:1px solid #86efac;color:var(--green);}
.time-err{background:var(--red-lt);border:1px solid #fca5a5;color:var(--red);}

/* RESPONSIVE */
@media(max-width:1024px){.stat-row{grid-template-columns:repeat(2,1fr);}}
@media(max-width:768px){
  .topnav{padding:12px 16px;flex-wrap:wrap;gap:8px;}
  .shell{padding:16px 16px 48px;}
  .hero{grid-template-columns:1fr;padding:24px 20px;}
  .hero::after{display:none;}
  .hero-side{display:none;}
  .stat-row{grid-template-columns:repeat(2,1fr);}
  .search-bar{flex-direction:column;}
  .search-bar input,.search-bar select{width:100%;}
  .btn-prim,.btn-ghost{width:100%;display:block;}
  .flow-box{flex-direction:column;}
  table,thead,tbody,th,td,tr{display:block;}
  thead{display:none;}
  tr{background:var(--white);border:1px solid var(--line);border-radius:var(--r);margin-bottom:8px;padding:12px 14px;}
  td{padding:5px 0;border:none;font-size:13px;display:flex;align-items:center;gap:8px;}
  td::before{content:attr(data-label);font-family:var(--mono);font-size:11px;color:var(--txt3);text-transform:uppercase;min-width:70px;flex-shrink:0;}
}


/* ── 글자 크기 상향 override ── */
body { font-size: 15px !important; line-height: 1.7 !important; }
.hero-title { font-size: 30px !important; }
.hero-desc  { font-size: 15px !important; }
.ch-title   { font-size: 16px !important; }
.ch-sub     { font-size: 13px !important; }
.stat-val   { font-size: 32px !important; }
.stat-label { font-size: 13px !important; }
.stat-sub   { font-size: 13px !important; }
.tbl thead th { font-size: 13px !important; }
.tbl tbody td { font-size: 15px !important; }
.btn-prim  { font-size: 15px !important; }
.btn-ghost { font-size: 15px !important; }
.btn-sm    { font-size: 13px !important; }
.f-input   { font-size: 15px !important; }
.f-label   { font-size: 13px !important; }
.tab-btn   { font-size: 14px !important; }
.badge-ok, .badge-busy, .badge-warn, .badge-blue, .badge-purple, .badge-teal { font-size: 13px !important; }
.chip      { font-size: 13px !important; }
.role-chip { font-size: 13px !important; }
.info-val  { font-size: 15px !important; }
.info-key  { font-size: 13px !important; }
.flow-dept { font-size: 18px !important; }
.flow-loc  { font-size: 14px !important; }
.hero-eyebrow { font-size: 13px !important; }
.logo      { font-size: 18px !important; }


    /* ── register 전용 추가 스타일 ── */
    .reg-wrap  { min-height:100vh; display:flex; align-items:flex-start; justify-content:center; padding:40px 20px; }
    .reg-card  { background:var(--white); border:1px solid var(--line); border-radius:var(--r2); padding:44px 42px; width:100%; max-width:580px; box-shadow:var(--shadow2); }
    .reg-logo  { width:38px; height:38px; border-radius:9px; background:var(--blue); display:flex; align-items:center; justify-content:center; margin-bottom:18px; overflow:hidden; }
    .reg-logo img { width:100%; height:100%; object-fit:contain; }
    .reg-title { font-size:28px; font-weight:800; color:var(--txt); letter-spacing:-.03em; margin-bottom:4px; }
    .reg-title em { color:var(--blue); font-style:normal; }
    .reg-sub   { font-size:15px; color:var(--txt3); margin-bottom:30px; }
    .sec-label { font-family:var(--mono); font-size:12px; font-weight:700; color:var(--blue); text-transform:uppercase; letter-spacing:.1em; margin-bottom:10px; display:block; margin-top:20px; }
    .role-grid { display:grid; grid-template-columns:repeat(5,1fr); gap:8px; margin-bottom:20px; }
    .role-btn  { border:1.5px solid var(--line); border-radius:var(--r); background:var(--white); color:var(--txt3); font-size:12px; font-weight:600; padding:10px 4px; text-align:center; cursor:pointer; transition:all .15s; }
    .role-btn i { display:block; font-size:18px; margin-bottom:5px; }
    .role-btn.active, .role-btn:hover { border-color:var(--blue); background:var(--blue-lt); color:var(--blue); }
    .input-row { display:flex; }
    .ig-icon   { background:var(--bg); border:1.5px solid var(--line2); border-right:none; color:var(--txt3); display:flex; align-items:center; padding:0 .9rem; border-radius:var(--r) 0 0 var(--r); font-size:15px; }
    .f-input   { flex:1; background:var(--white); border:1.5px solid var(--line2); border-left:none; border-radius:0 var(--r) var(--r) 0; color:var(--txt); font-size:15px; padding:.65rem 1rem; outline:none; font-family:var(--sans); transition:border-color .15s; }
    .f-input:focus { border-color:var(--blue); box-shadow:0 0 0 3px var(--blue-lt); background:var(--white); }
    .f-label   { font-family:var(--mono); font-size:13px; color:var(--txt2); display:block; margin-bottom:6px; font-weight:500; }
    .pw-bar-wrap { height:4px; background:var(--line); border-radius:4px; margin-top:6px; overflow:hidden; }
    .pw-bar    { height:100%; width:0; border-radius:4px; transition:width .3s, background .3s; }
    .pw-hint   { font-size:12px; color:var(--txt3); margin-top:5px; margin-bottom:0; }
    .terms-box { background:var(--bg); border:1px solid var(--line); border-radius:var(--r); padding:14px 16px; font-size:13px; color:var(--txt2); line-height:1.8; margin-bottom:12px; max-height:110px; overflow-y:auto; }
    .f-check   { display:flex; align-items:flex-start; gap:10px; font-size:14px; color:var(--txt2); }
    .f-check input { accent-color:var(--blue); width:16px; height:16px; margin-top:2px; flex-shrink:0; }
    .btn-submit { display:block; width:100%; background:var(--blue); color:white; border:none; border-radius:var(--r); padding:14px; font-size:16px; font-weight:700; cursor:pointer; transition:background .15s; margin-bottom:10px; }
    .btn-submit:hover { background:#1647c0; }
    .btn-back  { display:block; width:100%; text-align:center; background:transparent; color:var(--txt2); border:1.5px solid var(--line2); border-radius:var(--r); padding:12px; font-size:15px; font-weight:600; text-decoration:none; transition:all .15s; }
    .btn-back:hover { border-color:var(--blue); color:var(--blue); }
    .alert-err { background:var(--red-lt); border:1px solid #fca5a5; border-radius:var(--r); color:var(--red); font-size:14px; padding:11px 14px; margin-bottom:16px; display:flex; align-items:center; gap:8px; }
    .foot      { font-size:13px; color:var(--txt3); text-align:center; margin-top:18px; }
    .foot a    { color:var(--blue); text-decoration:none; }
    /* 글자 크기 상향 */
    body { font-size: 15px !important; }
    
/* ══ 테이블 선명도 강화 ══ */
.tbl { border: 1px solid var(--line2); border-radius: var(--r2); overflow: hidden; }
.tbl thead th {
    font-family: var(--mono);
    font-size: 13px !important;
    text-transform: uppercase;
    letter-spacing: .07em;
    color: var(--txt) !important;
    font-weight: 700 !important;
    padding: 14px 16px !important;
    border-bottom: 2px solid var(--blue-md) !important;
    background: var(--blue-lt) !important;
}
.tbl tbody td {
    padding: 14px 16px !important;
    border-bottom: 1px solid var(--line) !important;
    font-size: 15px !important;
    vertical-align: middle;
    color: var(--txt) !important;
}
.tbl tbody tr:hover td { background: var(--blue-lt) !important; }
.tbl tbody tr { cursor: pointer; transition: background .12s; }

/* ══ 검색바 하이라이트 ══ */
.search-bar {
    background: var(--white);
    border: 2px solid var(--blue-md);
    border-radius: var(--r2);
    padding: 10px 12px;
    box-shadow: 0 0 0 4px var(--blue-lt), var(--shadow);
    gap: 10px !important;
}
.search-bar input {
    border: none !important;
    background: transparent !important;
    font-size: 15px !important;
    font-weight: 500;
    color: var(--txt) !important;
    outline: none !important;
    box-shadow: none !important;
}
.search-bar input::placeholder { color: var(--txt3); font-size: 14px; }
.search-bar input:focus { box-shadow: none !important; border: none !important; }
.search-bar select {
    border: 1.5px solid var(--line2) !important;
    border-radius: var(--r) !important;
    padding: 9px 12px !important;
    font-size: 14px !important;
    background: var(--white) !important;
    color: var(--txt) !important;
    font-weight: 600;
}
.search-bar .btn-prim {
    padding: 10px 22px !important;
    font-size: 15px !important;
    font-weight: 700 !important;
    border-radius: var(--r) !important;
    white-space: nowrap;
}

/* ══ 배지 선명도 ══ */
.badge-ok   { font-size: 13px !important; padding: 4px 11px !important; font-weight: 700 !important; }
.badge-busy { font-size: 13px !important; padding: 4px 11px !important; font-weight: 700 !important; }
.badge-warn { font-size: 13px !important; padding: 4px 11px !important; font-weight: 700 !important; }
.badge-blue, .badge-purple, .badge-teal { font-size: 13px !important; padding: 4px 11px !important; font-weight: 700 !important; }

/* ══ 페이저 선명도 ══ */
.pager .pb {
    font-size: 14px !important;
    padding: 8px 14px !important;
    font-weight: 600 !important;
    border: 1.5px solid var(--line2) !important;
}
.pager .pb.on {
    background: var(--blue) !important;
    color: white !important;
    border-color: var(--blue) !important;
    font-weight: 700 !important;
}

/* ══ 카드 헤더 선명도 ══ */
.ch-title { font-size: 16px !important; font-weight: 800 !important; }
.ch-sub   { font-size: 13px !important; }

/* ══ FOOTER ══ */
.site-footer {
    margin-top: 60px;
    border-top: 1px solid var(--line);
    padding: 28px 0 40px;
}
.footer-inner {
    max-width: 1380px;
    margin: 0 auto;
    padding: 0 24px;
    display: flex;
    align-items: center;
    justify-content: space-between;
    flex-wrap: wrap;
    gap: 16px;
}
.footer-logo {
    display: flex;
    align-items: center;
    gap: 10px;
    font-weight: 800;
    font-size: 15px;
    color: var(--txt);
    text-decoration: none;
    letter-spacing: -.02em;
}
.footer-logo em { color: var(--blue); font-style: normal; }
.footer-logo-dot {
    width: 26px; height: 26px;
    border-radius: 7px;
    background: var(--blue);
    display: flex; align-items: center; justify-content: center;
    overflow: hidden;
}
.footer-logo-dot img { width: 100%; height: 100%; object-fit: contain; }
.footer-team {
    font-family: var(--mono);
    font-size: 12px;
    color: var(--txt3);
    line-height: 1.8;
    text-align: center;
}
.footer-team strong { color: var(--blue); font-size: 13px; }
.footer-copy {
    font-family: var(--mono);
    font-size: 12px;
    color: var(--txt3);
    text-align: right;
    line-height: 1.8;
}


/* ══ 검색바 입력 포커스 하이라이트 (FOCUS GLOW) ══ */
.search-bar:focus-within {
    border-color: var(--blue) !important;
    box-shadow: 0 0 0 4px rgba(26,86,219,.15), var(--shadow2) !important;
}
.search-bar input:focus::placeholder { color: var(--blue-md); }

/* ══ 테이블 헤더 칼럼 구분선 ══ */
.tbl thead th:not(:last-child) { border-right: 1px solid var(--blue-md); }
.tbl tbody td:not(:last-child) { border-right: 1px solid var(--line); }
.tbl thead th { white-space: nowrap; }

/* ══ 테이블 행 번호/자산번호 선명도 ══ */
.tbl tbody td:first-child {
    font-family: var(--mono) !important;
    font-size: 13px !important;
    color: var(--txt3) !important;
    font-weight: 600 !important;
}

/* ══ 검색 결과 카드 border 강화 ══ */
.card { border: 1.5px solid var(--line2) !important; }
.card-head { border-bottom: 1.5px solid var(--line2) !important; }

/* ══ HERO 검색바 하이라이트 ══ */
.search-hero {
    background: var(--white);
    border: 2px solid var(--blue-md);
    border-radius: var(--r2);
    padding: 6px 6px 6px 16px;
    box-shadow: 0 0 0 4px var(--blue-lt), var(--shadow);
    max-width: 560px;
    gap: 6px !important;
}
.search-hero input {
    border: none !important;
    background: transparent !important;
    font-size: 15px !important;
    font-weight: 500;
    outline: none !important;
    box-shadow: none !important;
    padding: 6px 0 !important;
}
.search-hero:focus-within {
    border-color: var(--blue) !important;
    box-shadow: 0 0 0 5px rgba(26,86,219,.18), var(--shadow2) !important;
}
.search-hero .btn-search-hero {
    border-radius: var(--r) !important;
    padding: 10px 20px !important;
    font-size: 15px !important;
    font-weight: 700 !important;
}


/* ══ Hero 다크그린 그라디언트 (교수님 요청 색상) ══ */
.hero {
  background: linear-gradient(135deg, #0f172a 0%, #0d6147 50%, #16a34a 100%) !important;
  border: none !important;
  box-shadow: 0 8px 32px rgba(15,23,42,.30) !important;
}
.hero::after {
  background: linear-gradient(135deg, rgba(255,255,255,.05) 0%, rgba(22,163,74,.12) 100%) !important;
}
.hero-eyebrow { color: rgba(255,255,255,.70) !important; }
.hero-title   { color: #ffffff !important; text-shadow: 0 1px 4px rgba(0,0,0,.2); }
.hero-title em, .hero-title span { color: #4ade80 !important; }
.hero-desc    { color: rgba(255,255,255,.88) !important; }
.tag {
  background: rgba(255,255,255,.15) !important;
  border-color: rgba(255,255,255,.28) !important;
  color: rgba(255,255,255,.92) !important;
}
.tag b { color: #4ade80 !important; }
/* hero 안 검색바 */
.search-hero {
  background: rgba(255,255,255,.14) !important;
  border: 1.5px solid rgba(255,255,255,.38) !important;
  box-shadow: none !important;
  border-radius: var(--r2) !important;
  padding: 6px 6px 6px 16px !important;
  display: flex; gap: 6px; max-width: 520px; margin-top: 16px;
}
.search-hero input {
  background: transparent !important;
  border: none !important;
  color: #ffffff !important;
  font-size: 15px !important;
  outline: none !important;
  flex: 1;
}
.search-hero input::placeholder { color: rgba(255,255,255,.55) !important; }
.search-hero:focus-within {
  border-color: rgba(255,255,255,.65) !important;
  background: rgba(255,255,255,.20) !important;
}
.search-hero .btn-search-hero {
  background: rgba(255,255,255,.20) !important;
  color: white !important;
  border: 1.5px solid rgba(255,255,255,.5) !important;
  border-radius: var(--r) !important;
  font-size: 15px !important; font-weight: 700 !important;
  padding: 9px 20px !important;
  transition: background .15s !important;
}
.search-hero .btn-search-hero:hover {
  background: rgba(255,255,255,.32) !important;
}

</style>
</head>
<body>
<div class="reg-wrap">
  <div class="reg-card">

    <div class="reg-logo"><img src="/CampusNav/images/logo.png" alt="ICT"></div>
    <div class="reg-title">ICT Campus<em>Nav</em> 가입</div>
    <div class="reg-sub">재학생 · 교직원 전용 서비스</div>

    <!-- 에러 메시지 (기존 로직 유지) -->
    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><span><%= errorMsg %></span></div>
    <% } %>

    <!-- 역할 선택 -->
    <span class="sec-label"><i class="bi bi-person-badge me-1"></i>역할 선택</span>
    <div class="role-grid">
      <label class="role-btn active" id="role-student">
        <input type="radio" name="roleDisplay" style="display:none" checked>
        <i class="bi bi-mortarboard-fill"></i>학부생
      </label>
      <label class="role-btn" id="role-assistant">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-workspace"></i>조교
      </label>
      <label class="role-btn" id="role-professor">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-badge-fill"></i>교수
      </label>
      <label class="role-btn" id="role-admin">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-shield-fill"></i>관리자
      </label>
      <label class="role-btn" id="role-guest">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-fill"></i>외부인
      </label>
    </div>

    <!-- errMsg (DB 저장 후 에러) -->
    <%
    String errMsg = (String) request.getAttribute("errMsg");
    if (errMsg == null) errMsg = "";
    %>
    <% if (!errMsg.isEmpty()) { %>
    <div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><span><%= errMsg %></span></div>
    <% } %>

    <form action="/CampusNav/register.jsp" method="post" id="regForm">
      <input type="hidden" name="role" id="roleValue" value="student">

      <!-- 기본 정보 -->
      <span class="sec-label"><i class="bi bi-info-circle me-1"></i>기본 정보</span>
      <div class="row g-3 mb-1">
        <div class="col-12">
          <label class="f-label">학번 / 아이디 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-person"></i></span>
            <input class="f-input" type="text" name="userId" id="userId" placeholder="예) 20240001" required>
          </div>
        </div>
        <div class="col-12">
          <label class="f-label">이름 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-type"></i></span>
            <input class="f-input" type="text" name="userName" placeholder="실명 입력" required>
          </div>
        </div>
        <div class="col-md-6">
          <label class="f-label">이메일 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-envelope"></i></span>
            <input class="f-input" type="email" name="userEmail" placeholder="example@campus.ac.kr" required>
          </div>
        </div>
        <div class="col-md-6">
          <label class="f-label" id="deptLabel">학과 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-building"></i></span>
            <input class="f-input" type="text" name="dept" id="deptInput" placeholder="예) 컴퓨터공학과" required>
          </div>
        </div>
        <div class="col-12" id="studentNumWrap">
          <label class="f-label">학번</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-hash"></i></span>
            <input class="f-input" type="text" name="studentNum" placeholder="예) 20240001">
          </div>
        </div>
      </div>

      <!-- 보안 -->
      <span class="sec-label"><i class="bi bi-shield-lock me-1"></i>보안</span>
      <div class="row g-3 mb-1">
        <div class="col-md-6">
          <label class="f-label">비밀번호 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-lock"></i></span>
            <input class="f-input" type="password" name="userPw" id="userPw"
                   placeholder="8자 이상, 영문+숫자" required oninput="checkPw(this.value)">
          </div>
          <div class="pw-bar-wrap"><div class="pw-bar" id="pwBar"></div></div>
          <p class="pw-hint" id="pwHint">비밀번호를 입력하세요</p>
        </div>
        <div class="col-md-6">
          <label class="f-label">비밀번호 확인 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-lock-fill"></i></span>
            <input class="f-input" type="password" name="userPw2" id="userPw2"
                   placeholder="비밀번호 재입력" required oninput="checkMatch()">
          </div>
          <p class="pw-hint" id="pwMatch"></p>
        </div>
      </div>

      <!-- 약관 -->
      <span class="sec-label"><i class="bi bi-file-text me-1"></i>이용약관</span>
      <div class="terms-box">
        CampusNav 서비스 이용약관 (프로토타입)<br>
        제1조. 본 서비스는 교내 자원 내비게이션 제공을 목적으로 합니다.<br>
        제2조. 수집되는 개인정보는 서비스 제공 목적으로만 사용됩니다.<br>
        제3조. 이용자는 타인의 계정을 도용해서는 안 됩니다.<br>
        제4조. 위치 정보는 캠퍼스 내 이동 안내에만 활용됩니다.
      </div>
      <div class="f-check mb-4">
        <input type="checkbox" id="agree" name="agree" required>
        <label for="agree">이용약관 및 개인정보 처리방침에 동의합니다 <span style="color:var(--blue)">(필수)</span></label>
      </div>

      <button type="submit" class="btn-submit"><i class="bi bi-person-check me-1"></i>가입하기</button>
      <a href="/CampusNav/campuslogin.jsp" class="btn-back"><i class="bi bi-arrow-left me-1"></i>로그인으로 돌아가기</a>
    </form>

    <p class="foot">재학생·교직원 전용 서비스 &nbsp;|&nbsp; <a href="mailto:support@campus.ac.kr">support@campus.ac.kr</a></p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>

var roleConfig = {
    student:   { dept:'학과 *',   showStudentNum:true  },
    assistant: { dept:'학과 *',   showStudentNum:true  },
    professor: { dept:'소속 학과 *', showStudentNum:false },
    admin:     { dept:'소속 부서 *', showStudentNum:false },
    guest:     { dept:'소속 기관',   showStudentNum:false }
};

document.querySelectorAll('.role-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.role-btn').forEach(function(b){ b.classList.remove('active'); });
        this.classList.add('active');
        var role = this.id.replace('role-','');
        document.getElementById('roleValue').value = role;
        var cfg = roleConfig[role];
        document.getElementById('deptLabel').textContent = cfg.dept;
        document.getElementById('studentNumWrap').style.display = cfg.showStudentNum ? '' : 'none';
    });
});

function checkPw(v) {
    var bar = document.getElementById('pwBar');
    var hint = document.getElementById('pwHint');
    if (!v) { bar.style.width='0'; hint.textContent='비밀번호를 입력하세요'; hint.style.color=''; return; }
    var score = 0;
    if (v.length >= 8) score++;
    if (/[A-Za-z]/.test(v)) score++;
    if (/[0-9]/.test(v)) score++;
    if (/[^A-Za-z0-9]/.test(v)) score++;
    var colors = ['#ff4d4d','#ff944d','#f0c040','#00c2a8'];
    var labels = ['매우 약함','보통','강함','매우 강함'];
    var pcts   = ['25%','50%','75%','100%'];
    var i = Math.max(0, score-1);
    bar.style.width = pcts[i]; bar.style.background = colors[i];
    hint.textContent = '강도: ' + labels[i]; hint.style.color = colors[i];
}

function checkMatch() {
    var m = document.getElementById('pwMatch');
    var pw = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;
    if (!pw2) { m.textContent=''; return; }
    if (pw === pw2) { m.textContent='✓ 비밀번호가 일치합니다'; m.style.color='#00c2a8'; }
    else            { m.textContent='✗ 비밀번호가 일치하지 않습니다'; m.style.color='#ff8a9a'; }
}

document.getElementById('regForm').addEventListener('submit', function(e) {
    if (!document.getElementById('agree').checked) {
        e.preventDefault(); alert('이용약관에 동의해 주세요.'); return;
    }
    var pw  = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;
    if (pw.length < 8) { e.preventDefault(); alert('비밀번호는 8자 이상이어야 합니다.'); return; }
    if (pw !== pw2)    { e.preventDefault(); alert('비밀번호가 일치하지 않습니다.'); return; }
});

</script>

<footer class="site-footer">
  <div class="footer-inner">
    <a href="/CampusNav/campuslogin.jsp" class="footer-logo">
      <span class="footer-logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
      ICT Campus<em>Nav</em>
    </a>
    <div class="footer-team">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 &nbsp;&middot;&nbsp; 권동해 &nbsp;&middot;&nbsp; 원태연 &nbsp;&middot;&nbsp; 이수혁
    </div>
    <div class="footer-copy">
      ICT폴리텍대학 교내 자원 내비게이션 시스템<br>
      Copyright &copy; 2026 ICT CampusNav. All rights reserved.
    </div>
  </div>
</footer>

</body>
</html>