<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%  String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName"),loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null){response.sendRedirect("/CampusNav/campuslogin.jsp");return;}
    if("guest".equals(loginRole)){response.sendRedirect("/CampusNav/main_guest.jsp");return;}
    // visitor는 main_visitor.jsp에서 자체 예약폼 사용
    String assetNo=request.getParameter("id");if(assetNo==null)assetNo="";
    String success=request.getParameter("success");if(success==null)success="";
    String errMsg=request.getParameter("err");if(errMsg==null)errMsg="";
    if("POST".equals(request.getMethod())){
        String rNo=request.getParameter("resourceId"),rDate=request.getParameter("date"),rStart=request.getParameter("startTime"),rEnd=request.getParameter("endTime"),purpose=request.getParameter("purpose"),phone=request.getParameter("phone");
        if(rNo!=null&&rDate!=null&&rStart!=null&&rEnd!=null&&!rDate.isEmpty()){
            try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
            PreparedStatement ps=conn.prepareStatement("SELECT COUNT(*) FROM reservations WHERE asset_no=? AND reserve_date=? AND status='예약완료' AND start_time<? AND end_time>?");ps.setString(1,rNo);ps.setString(2,rDate);ps.setString(3,rEnd);ps.setString(4,rStart);ResultSet rs=ps.executeQuery();boolean dup=rs.next()&&rs.getInt(1)>0;rs.close();ps.close();
            if(dup){response.sendRedirect("/CampusNav/reserve.jsp?id="+rNo+"&err=이미+예약된+시간입니다");}
            else{ps=conn.prepareStatement("INSERT INTO reservations(asset_no,user_id,reserve_date,start_time,end_time,purpose,phone,status) VALUES(?,?,?,?,?,?,?,'예약완료')");ps.setString(1,rNo);ps.setString(2,loginUser);ps.setString(3,rDate);ps.setString(4,rStart);ps.setString(5,rEnd);ps.setString(6,purpose!=null?purpose:"");ps.setString(7,phone!=null?phone:"");ps.executeUpdate();ps.close();response.sendRedirect("/CampusNav/reserve.jsp?id="+rNo+"&success=true");}
            conn.close();}catch(Exception e){response.sendRedirect("/CampusNav/reserve.jsp?id="+assetNo+"&err="+java.net.URLEncoder.encode(e.getMessage(),"UTF-8"));}return;}
    }
    Map<String,String> assetInfo=new LinkedHashMap<>();List<Map<String,String>> existReserves=new ArrayList<>();
    if(!assetNo.isEmpty()){try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
    PreparedStatement ps=conn.prepareStatement("SELECT item_name,detail_location,asset_status FROM assets WHERE asset_no=?");ps.setString(1,assetNo);ResultSet rs=ps.executeQuery();if(rs.next()){assetInfo.put("name",rs.getString(1));assetInfo.put("loc",rs.getString(2));assetInfo.put("st",rs.getString(3));}rs.close();ps.close();
    ps=conn.prepareStatement("SELECT reserve_date,start_time,end_time,user_id FROM reservations WHERE asset_no=? AND reserve_date>=CURDATE() AND status='예약완료' ORDER BY reserve_date,start_time LIMIT 20");ps.setString(1,assetNo);rs=ps.executeQuery();
    while(rs.next()){Map<String,String> r=new LinkedHashMap<>();r.put("date",rs.getString(1));r.put("start",rs.getString(2));r.put("end",rs.getString(3));r.put("user",rs.getString(4));existReserves.add(r);}rs.close();ps.close();conn.close();}catch(Exception ignored){}}
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>ICT CampusNav — 예약</title>
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
.hero{background:linear-gradient(135deg,#0f172a 0%,#0d6147 50%,#16a34a 100%);border:none;border-radius:var(--r2);padding:40px 44px;margin-bottom:24px;box-shadow:0 8px 32px rgba(15,23,42,.25);display:grid;grid-template-columns:1fr auto;gap:32px;align-items:center;position:relative;overflow:hidden;}
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,rgba(255,255,255,.06) 0%,rgba(22,163,74,.15) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);z-index:0;pointer-events:none;}
.hero-content{position:relative;z-index:1;}
.hero-eyebrow{font-family:var(--mono);font-size:12px;color:rgba(255,255,255,.7);letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px;}
.hero-title{font-size:28px;font-weight:800;line-height:1.25;letter-spacing:-.03em;margin-bottom:10px;color:#ffffff;}
.hero-title em{color:#4ade80;font-style:normal;}
.hero-desc{color:rgba(255,255,255,.85);font-size:15px;line-height:1.85;max-width:560px;margin-bottom:18px;}
.tag-row{display:flex;flex-wrap:wrap;gap:6px;}
.tag{font-family:var(--mono);font-size:12px;padding:4px 11px;border-radius:6px;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);color:rgba(255,255,255,.9);}
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
.tbl thead th { font-size: 13px !important; }
.tbl tbody td { font-size: 15px !important; }
.btn-prim  { font-size: 15px !important; }
.btn-ghost { font-size: 15px !important; }
.btn-sm    { font-size: 13px !important; }
.f-input   { font-size: 15px !important; }
.f-label   { font-size: 13px !important; }
.badge-ok, .badge-busy, .badge-warn, .badge-blue, .badge-purple, .badge-teal { font-size: 13px !important; }
.chip      { font-size: 13px !important; }
.role-chip { font-size: 13px !important; }
.info-val  { font-size: 15px !important; }
.logo      { font-size: 18px !important; }
.pager .pb { font-size: 14px !important; }


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


/* ══ Hero 다크그린 그라디언트 (교수님 요청) ══ */
.hero {
    background: linear-gradient(135deg, #0f172a 0%, #0d6147 50%, #16a34a 100%) !important;
    border: none !important;
    box-shadow: 0 8px 32px rgba(15,23,42,.25) !important;
}
.hero::after {
    background: linear-gradient(135deg, rgba(255,255,255,.06) 0%, rgba(22,163,74,.15) 100%) !important;
}
.hero-eyebrow { color: rgba(255,255,255,.72) !important; }
.hero-title   { color: #ffffff !important; }
.hero-title em, .hero-title span { color: #4ade80 !important; }
.hero-desc    { color: rgba(255,255,255,.85) !important; }
.tag {
    background: rgba(255,255,255,.15) !important;
    border-color: rgba(255,255,255,.25) !important;
    color: rgba(255,255,255,.9) !important;
}
.tag b { color: #4ade80 !important; }
/* 검색 hero 안 input */
.search-hero {
    background: rgba(255,255,255,.12) !important;
    border-color: rgba(255,255,255,.35) !important;
    box-shadow: none !important;
}
.search-hero input {
    color: #ffffff !important;
    background: transparent !important;
    border: none !important;
}
.search-hero input::placeholder { color: rgba(255,255,255,.55) !important; }
.search-hero:focus-within {
    background: rgba(255,255,255,.18) !important;
    border-color: rgba(255,255,255,.6) !important;
}

</style>
</head><body>
<div class="topnav">
  <a href="/CampusNav/main_<%= loginRole %>.jsp" class="logo"><span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>ICT Campus<em>Nav</em></a>
  <div class="nav-right">
    <span style="font-family:var(--mono);font-size:13px;color:var(--txt2)"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
    <span class="role-chip"><%= "student".equals(loginRole)?"학부생":"assistant".equals(loginRole)?"조교":"professor".equals(loginRole)?"교수":"관리자" %></span>
    <a href="/CampusNav/main_<%= loginRole %>.jsp" class="chip"><i class="bi bi-house me-1"></i>홈</a>
    <form action="/CampusNav/logout" method="post" style="margin:0"><button type="submit" class="chip"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button></form>
  </div>
</div>
<div class="shell">
<div class="hero"><div class="hero-content">
  <div class="hero-eyebrow">ICT CampusNav · 자원 예약</div>
  <div class="hero-title"><% if(!assetInfo.isEmpty()){%><em><%= assetInfo.get("name") %></em> 예약<%}else{%>자원 <em>예약</em><%}%></div>
  <% if(!assetInfo.isEmpty()){%><div class="hero-desc"><i class="bi bi-geo-alt" style="color:var(--teal)"></i> <%= assetInfo.get("loc") %></div><%}%>
</div><div class="hero-side"><div class="hero-illo">📅</div></div></div>

<% if(!success.isEmpty()){%><div class="alert-ok"><i class="bi bi-check-circle-fill"></i>예약이 완료되었습니다!</div><%}%>
<% if(!errMsg.isEmpty()){%><div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><%= errMsg %></div><%}%>

<div class="row g-4">
<div class="col-lg-7">
<div class="card"><div class="card-head"><div class="ch-icon si-blue">📝</div><div><div class="ch-title">예약 정보 입력</div></div></div>
<div class="card-body">
<form method="post" action="/CampusNav/reserve.jsp" onsubmit="return checkBefore()">
  <input type="hidden" name="resourceId" value="<%= assetNo %>">
  <div style="margin-bottom:16px"><label class="f-label">자산번호</label>
    <% if(assetNo.isEmpty()){ %>
    <input class="f-input" type="text" name="resourceId" value="직접입력">
    <% }else{ %>
    <input class="f-input" type="text" value="<%= assetNo %>" readonly style="background:var(--bg);color:var(--txt3)">
    <% } %>
  </div>
  <div style="margin-bottom:16px"><label class="f-label">예약 날짜 *</label>
    <input class="f-input" type="date" name="date" id="rDate" required onchange="checkTime()" min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>">
  </div>
  <div class="row g-3" style="margin-bottom:16px">
    <div class="col-6"><label class="f-label">시작 시간 *</label><input class="f-input" type="time" name="startTime" id="rStart" required onchange="checkTime()"></div>
    <div class="col-6"><label class="f-label">종료 시간 *</label><input class="f-input" type="time" name="endTime" id="rEnd" required onchange="checkTime()"></div>
  </div>
  <div id="timeCheck" class="time-check"></div>
  <div style="margin-bottom:16px"><label class="f-label">사용 목적</label><input class="f-input" type="text" name="purpose" placeholder="예) 캡스톤 프로젝트 작업"></div>
  <div style="margin-bottom:20px"><label class="f-label">연락처</label><input class="f-input" type="text" name="phone" placeholder="010-0000-0000"></div>
  <button type="submit" class="btn-prim" style="width:100%;padding:13px;font-size:15px"><i class="bi bi-check-circle me-1"></i>예약 신청</button>
</form>
</div></div></div>

<div class="col-lg-5">
<div class="card"><div class="card-head"><div class="ch-icon si-amber">🕐</div><div><div class="ch-title">기존 예약 현황</div><div class="ch-sub"><%= existReserves.size() %>건 예약 중</div></div></div>
<div class="card-body">
<% if(existReserves.isEmpty()){%>
<div style="text-align:center;padding:24px;color:var(--txt3)"><i class="bi bi-check-circle" style="font-size:28px;display:block;margin-bottom:8px;color:var(--green);opacity:.6"></i><div style="font-size:14px">예약 내역이 없습니다.<br>이 시간에 예약 가능합니다!</div></div>
<%}else{for(Map<String,String> rv:existReserves){%>
<div style="border:1px solid #fca5a5;border-radius:var(--r);padding:10px 14px;margin-bottom:8px;background:var(--red-lt)">
  <div style="font-weight:700;color:var(--red);font-size:13px"><i class="bi bi-x-circle me-1"></i><%= rv.get("date") %></div>
  <div style="font-size:14px;font-weight:600"><%= rv.get("start") %> ~ <%= rv.get("end") %></div>
  <div style="font-size:12px;color:var(--txt3)">예약자: <%= rv.get("user") %></div>
</div>
<%}}%>
</div></div>
</div></div>
</div>
<script>
var er=[<% for(int i=0;i<existReserves.size();i++){Map<String,String> rv=existReserves.get(i); %>{date:"<%= rv.get("date") %>",start:"<%= rv.get("start") %>",end:"<%= rv.get("end") %>"}<%=i<existReserves.size()-1?",":"" %><%}%>];
function checkTime(){
  var date=document.getElementById('rDate').value,start=document.getElementById('rStart').value,end=document.getElementById('rEnd').value,el=document.getElementById('timeCheck');
  if(!date||!start||!end){el.style.display='none';return;}
  if(start>=end){el.className='time-check time-err';el.innerHTML='<i class="bi bi-x-circle-fill me-1"></i>종료 시간이 시작 시간보다 빠릅니다.';el.style.display='block';return;}
  var c=null;for(var r of er){if(r.date===date&&start<r.end&&end>r.start){c=r;break;}}
  if(c){el.className='time-check time-err';el.innerHTML='<i class="bi bi-x-circle-fill me-1"></i><strong>예약 불가!</strong> '+c.start+'~'+c.end+' 이미 예약되어 있습니다.';}
  else{el.className='time-check time-ok';el.innerHTML='<i class="bi bi-check-circle-fill me-1"></i><strong>예약 가능!</strong> 선택하신 시간에 예약할 수 있습니다.';}
  el.style.display='block';
}
function checkBefore(){var el=document.getElementById('timeCheck');if(el&&el.classList.contains('time-err')){alert('예약 불가능한 시간입니다.');return false;}return true;}
</script><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<!-- ══ SITE FOOTER ══ -->
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
      ICT폴리텍대학<br>
      교내 자원 내비게이션 시스템<br>
      Copyright &copy; 2026 ICT CampusNav. All rights reserved.
    </div>
  </div>
</footer>

</body></html>