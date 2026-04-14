<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    if (loginUser == null) {
        response.sendRedirect("/CampusNav/campuslogin.jsp");
        return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 교수 자원</title>
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
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,rgba(255,255,255,.06) 0%,rgba(22,163,74,.15) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);}
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


    /* ── professor 전용 추가 스타일 ── */
    .badge-sw     { background:var(--purple-lt); color:var(--purple); border-radius:6px; padding:3px 9px; font-size:13px; font-weight:600; font-family:var(--mono); }
    .pc-card      { background:var(--bg); border:1px solid var(--line); border-radius:var(--r2); padding:20px; margin-bottom:14px; }
    .pc-icon      { width:42px; height:42px; border-radius:11px; display:flex; align-items:center; justify-content:center; font-size:20px; flex-shrink:0; }
    .del-confirm  { background:var(--red-lt); border:1px solid #fca5a5; border-radius:var(--r); padding:20px; margin-bottom:16px; }
    .del-warn     { background:var(--amber-lt); border:1px solid #fde68a; border-radius:var(--r); padding:12px 14px; margin-bottom:16px; font-size:14px; color:#713f12; }
    /* 글자 크기 상향 */
    body          { font-size:15px !important; line-height:1.7 !important; }
    .ch-title     { font-size:16px !important; }
    .tbl tbody td { font-size:15px !important; }
    .btn-prim     { font-size:15px !important; }
    .btn-ghost    { font-size:15px !important; }
    .f-input      { font-size:15px !important; }
    .f-label      { font-size:13px !important; }
    .tab-btn      { font-size:14px !important; }
    
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
</head>
<body>

<!-- 네비바 (ppd4 스타일) -->
<div class="topnav">
    <a href="/CampusNav/main_professor.jsp" class="logo">
        <span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
        ICT Campus<em>Nav</em>
    </a>
    <div class="nav-right">
        <span style="font-family:var(--mono);font-size:14px;color:var(--txt2)">
            <i class="bi bi-person-circle me-1"></i><%= loginName %>
        </span>
        <span class="role-chip">교수</span>
        <a href="/CampusNav/main_professor.jsp" class="chip"><i class="bi bi-house me-1"></i>홈</a>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="chip"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="shell">

    <!-- 히어로 -->
    <div class="hero">
        <div class="hero-content">
            <div class="hero-eyebrow">ICT CampusNav · 교수 자원</div>
            <div class="hero-title">교수도 <em>자원</em>입니다 👨‍🏫</div>
            <div class="hero-desc"><%= loginName %> 교수님의 소프트웨어 자원을 관리하세요.</div>
        </div>
        <div class="hero-side"><div class="hero-illo">🎓</div></div>
    </div>

    <!-- 탭 바 -->
    <div class="tab-bar">
        <button class="tab-btn active" onclick="showTab('search')">
            <i class="bi bi-search me-1"></i>자원 검색
        </button>
        <button class="tab-btn" onclick="showTab('swlist')">
            <i class="bi bi-pc-display me-1"></i>PC별 SW 현황
        </button>
        <button class="tab-btn" onclick="showTab('register')">
            <i class="bi bi-plus-circle me-1"></i>SW 등록
        </button>
        <button class="tab-btn" id="editTabBtn" onclick="showTab('edit')" style="display:none">
            <i class="bi bi-pencil me-1"></i>SW 수정
        </button>
        <button class="tab-btn" id="deleteTabBtn" onclick="showTab('delete')" style="display:none">
            <i class="bi bi-trash me-1"></i>SW 삭제
        </button>
    </div>

    <!-- ── 검색 탭 ── -->
    <div class="tab-content active" id="tab-search">
        <div class="card">
            <div class="card-head">
                <div class="ch-icon si-blue"><i class="bi bi-search" style="font-size:16px"></i></div>
                <div><div class="ch-title">자원 검색</div><div class="ch-sub">소프트웨어 및 장비 검색</div></div>
            </div>
            <div class="card-body">
                <form method="get" action="/CampusNav/search.jsp" style="margin-bottom:20px">
                    <div class="search-bar">
                        <input type="text" name="keyword" placeholder="자원명, 위치, 소프트웨어명 검색...">
                        <button type="submit" class="btn-prim" style="width:auto;white-space:nowrap">
                            <i class="bi bi-search me-1"></i>검색
                        </button>
                    </div>
                </form>
                <div style="overflow-x:auto">
                    <table class="tbl">
                        <thead>
                            <tr><th>번호</th><th>자원명</th><th>위치</th><th>소프트웨어</th><th>활용여부</th><th>관리</th></tr>
                        </thead>
                        <tbody>
                            <tr>
                                <td data-label="번호"><span style="font-family:var(--mono);font-size:13px;color:var(--txt3)">001</span></td>
                                <td data-label="자원명"><strong>노트북 Dell XPS</strong></td>
                                <td data-label="위치"><i class="bi bi-geo-alt" style="color:var(--teal)"></i> 공학관 301호</td>
                                <td data-label="SW"><span class="badge-sw">MATLAB R2024</span></td>
                                <td data-label="활용"><span class="badge-ok">사용가능</span></td>
                                <td data-label="관리">
                                    <button class="btn-sm me-1" onclick="openEdit('001','MATLAB R2024')"><i class="bi bi-pencil me-1"></i>수정</button>
                                    <button class="btn-sm" style="border-color:var(--red);color:var(--red)" onclick="openDelete('001','노트북 Dell XPS','MATLAB R2024')"><i class="bi bi-trash me-1"></i>삭제</button>
                                </td>
                            </tr>
                            <tr>
                                <td data-label="번호"><span style="font-family:var(--mono);font-size:13px;color:var(--txt3)">002</span></td>
                                <td data-label="자원명"><strong>워크스테이션 A</strong></td>
                                <td data-label="위치"><i class="bi bi-geo-alt" style="color:var(--teal)"></i> 연구실 402호</td>
                                <td data-label="SW"><span class="badge-sw">ANSYS 2024</span></td>
                                <td data-label="활용"><span class="badge-busy">사용중</span></td>
                                <td data-label="관리">
                                    <button class="btn-sm me-1" onclick="openEdit('002','ANSYS 2024')"><i class="bi bi-pencil me-1"></i>수정</button>
                                    <button class="btn-sm" style="border-color:var(--red);color:var(--red)" onclick="openDelete('002','워크스테이션 A','ANSYS 2024')"><i class="bi bi-trash me-1"></i>삭제</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <!-- ── PC별 SW 현황 탭 ── -->
    <div class="tab-content" id="tab-swlist">
        <div class="card">
            <div class="card-head">
                <div class="ch-icon si-purple"><i class="bi bi-pc-display" style="font-size:16px"></i></div>
                <div><div class="ch-title">PC별 설치 소프트웨어 현황</div><div class="ch-sub">총 3대 (샘플)</div></div>
            </div>
            <div class="card-body">
                <div style="margin-bottom:18px">
                    <input type="text" placeholder="PC명, 위치, 소프트웨어명 검색..."
                           style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:11px 16px;font-size:15px;outline:none;background:var(--white);color:var(--txt)">
                </div>
                <!-- PC 001 -->
                <div class="pc-card">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="pc-icon si-teal"><i class="bi bi-laptop" style="font-size:18px;color:var(--teal)"></i></div>
                        <div>
                            <div style="font-weight:700;font-size:15px">노트북 Dell XPS 15 <small style="color:var(--txt3);font-weight:400">#001</small></div>
                            <div style="font-size:13px;color:var(--txt3)"><i class="bi bi-geo-alt me-1"></i>공학관 301호</div>
                        </div>
                        <span class="badge-ok ms-auto">사용가능</span>
                    </div>
                    <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;letter-spacing:.06em;margin-bottom:8px">설치 소프트웨어</div>
                    <div style="display:flex;flex-wrap:wrap;gap:6px">
                        <span class="badge-sw">MATLAB R2024b</span>
                        <span class="badge-sw">AutoCAD 2024</span>
                        <span class="badge-sw">MS Office 365</span>
                        <span class="badge-sw">Python 3.11</span>
                        <span class="badge-sw">VS Code</span>
                    </div>
                </div>
                <!-- PC 002 -->
                <div class="pc-card">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="pc-icon si-purple"><i class="bi bi-pc-display" style="font-size:18px;color:var(--purple)"></i></div>
                        <div>
                            <div style="font-weight:700;font-size:15px">워크스테이션 A <small style="color:var(--txt3);font-weight:400">#002</small></div>
                            <div style="font-size:13px;color:var(--txt3)"><i class="bi bi-geo-alt me-1"></i>연구실 402호</div>
                        </div>
                        <span class="badge-busy ms-auto">사용중</span>
                    </div>
                    <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;letter-spacing:.06em;margin-bottom:8px">설치 소프트웨어</div>
                    <div style="display:flex;flex-wrap:wrap;gap:6px">
                        <span class="badge-sw">ANSYS 2024</span>
                        <span class="badge-sw">MATLAB R2024b</span>
                        <span class="badge-sw">SolidWorks 2024</span>
                    </div>
                </div>
                <!-- PC 003 -->
                <div class="pc-card">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="pc-icon si-amber"><i class="bi bi-monitor" style="font-size:18px;color:var(--amber)"></i></div>
                        <div>
                            <div style="font-weight:700;font-size:15px">강의용 PC <small style="color:var(--txt3);font-weight:400">#003</small></div>
                            <div style="font-size:13px;color:var(--txt3)"><i class="bi bi-geo-alt me-1"></i>공학관 401호</div>
                        </div>
                        <span class="badge-ok ms-auto">사용가능</span>
                    </div>
                    <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;letter-spacing:.06em;margin-bottom:8px">설치 소프트웨어</div>
                    <div style="display:flex;flex-wrap:wrap;gap:6px">
                        <span class="badge-sw">MS Office 365</span>
                        <span class="badge-sw">한글 2022</span>
                        <span class="badge-sw">Chrome</span>
                        <span class="badge-sw">Zoom</span>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- ── SW 등록 탭 ── -->
    <div class="tab-content" id="tab-register">
        <div class="card">
            <div class="card-head">
                <div class="ch-icon si-teal"><i class="bi bi-plus-circle" style="font-size:16px"></i></div>
                <div><div class="ch-title">소프트웨어 등록</div><div class="ch-sub">새 SW 정보를 등록하세요</div></div>
            </div>
            <div class="card-body">
                <form>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="f-label">소프트웨어명 *</label>
                            <input class="f-input" type="text" placeholder="예) MATLAB R2024b">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">버전</label>
                            <input class="f-input" type="text" placeholder="예) R2024b">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">설치 자원 (장비명) *</label>
                            <input class="f-input" type="text" placeholder="예) 노트북 Dell XPS (001)">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">라이선스 종류</label>
                            <select class="f-select">
                                <option>교육용 라이선스</option><option>연구용 라이선스</option>
                                <option>오픈소스</option><option>상용</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">라이선스 만료일</label>
                            <input class="f-input" type="date">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">담당 교수</label>
                            <input class="f-input" type="text" value="<%= loginName %>">
                        </div>
                        <div class="col-12">
                            <label class="f-label">비고</label>
                            <textarea class="f-input" rows="3" placeholder="사용 목적, 제한 사항 등"></textarea>
                        </div>
                        <div class="col-12">
                            <button type="button" class="btn-prim" onclick="alert('등록 완료!\n(프로토타입)')">
                                <i class="bi bi-check-circle me-1"></i>등록하기
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ── SW 수정 탭 ── -->
    <div class="tab-content" id="tab-edit">
        <div class="card">
            <div class="card-head">
                <div class="ch-icon si-amber"><i class="bi bi-pencil" style="font-size:16px"></i></div>
                <div><div class="ch-title">소프트웨어 수정</div></div>
            </div>
            <div class="card-body">
                <form>
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="f-label">자원 번호</label>
                            <input class="f-input" type="text" id="edit-id" readonly
                                   style="background:var(--bg);color:var(--txt3)">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">소프트웨어명 *</label>
                            <input class="f-input" type="text" id="edit-sw" placeholder="소프트웨어명">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">버전</label>
                            <input class="f-input" type="text" id="edit-ver" placeholder="예) R2024b">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">라이선스 종류</label>
                            <select class="f-select" id="edit-license">
                                <option>교육용 라이선스</option><option>연구용 라이선스</option>
                                <option>오픈소스</option><option>상용</option>
                            </select>
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">라이선스 만료일</label>
                            <input class="f-input" type="date" id="edit-expire">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">담당 교수</label>
                            <input class="f-input" type="text" id="edit-prof" value="<%= loginName %>">
                        </div>
                        <div class="col-12">
                            <label class="f-label">비고</label>
                            <textarea class="f-input" id="edit-note" rows="2" placeholder="수정 사유 등"></textarea>
                        </div>
                        <div class="col-12 d-flex gap-2">
                            <button type="button" class="btn-prim" onclick="saveEdit()">
                                <i class="bi bi-check-circle me-1"></i>수정 완료
                            </button>
                            <button type="button" class="btn-ghost" onclick="cancelEdit()">
                                <i class="bi bi-x-circle me-1"></i>취소
                            </button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <!-- ── SW 삭제 탭 ── -->
    <div class="tab-content" id="tab-delete">
        <div class="card">
            <div class="card-head" style="background:var(--red-lt);border-bottom:2px solid #fca5a5">
                <div class="ch-icon" style="background:#fee2e2"><i class="bi bi-trash" style="font-size:16px;color:var(--red)"></i></div>
                <div><div class="ch-title" style="color:var(--red)">소프트웨어 삭제</div></div>
            </div>
            <div class="card-body">
                <div class="del-confirm">
                    <div style="display:flex;align-items:center;gap:8px;margin-bottom:14px;color:var(--red);font-weight:700;font-size:15px">
                        <i class="bi bi-exclamation-triangle-fill"></i>삭제할 소프트웨어 정보
                    </div>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;margin-bottom:4px">자원 번호</div>
                            <div style="font-weight:700;font-size:15px" id="del-id">-</div>
                        </div>
                        <div class="col-md-4">
                            <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;margin-bottom:4px">PC명</div>
                            <div style="font-weight:700;font-size:15px" id="del-pc">-</div>
                        </div>
                        <div class="col-md-4">
                            <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;margin-bottom:4px">소프트웨어명</div>
                            <div style="font-weight:700;font-size:15px;color:var(--red)" id="del-sw">-</div>
                        </div>
                    </div>
                </div>
                <div class="del-warn">
                    <i class="bi bi-info-circle me-1"></i>삭제 후 복구가 불가능합니다. 삭제 사유를 입력해 주세요.
                </div>
                <div style="margin-bottom:16px">
                    <label class="f-label">삭제 사유 *</label>
                    <textarea class="f-input" id="del-reason" rows="3"
                              placeholder="예) 라이선스 만료, 소프트웨어 교체 등"></textarea>
                </div>
                <div class="d-flex gap-2">
                    <button type="button" onclick="confirmDelete()"
                            style="flex:1;padding:12px;background:var(--red);border:none;border-radius:var(--r);color:#fff;font-weight:700;font-size:15px;cursor:pointer">
                        <i class="bi bi-trash me-1"></i>삭제 확정
                    </button>
                    <button type="button" onclick="cancelDelete()" class="btn-ghost">
                        <i class="bi bi-x-circle me-1"></i>취소
                    </button>
                </div>
            </div>
        </div>
    </div>

</div><!-- /shell -->

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>

function openDelete(id, pc, sw) {
    document.getElementById('del-id').textContent = id;
    document.getElementById('del-pc').textContent = pc;
    document.getElementById('del-sw').textContent = sw;
    document.getElementById('del-reason').value = '';
    document.getElementById('deleteTabBtn').style.display = '';
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
    document.getElementById('tab-delete').classList.add('active');
    document.getElementById('deleteTabBtn').classList.add('active');
}
function confirmDelete() {
    var reason = document.getElementById('del-reason').value.trim();
    if (!reason) { alert('삭제 사유를 입력해 주세요.'); return; }
    var sw = document.getElementById('del-sw').textContent;
    alert('[' + sw + '] 삭제가 완료됐습니다!\n(프로토타입: DB 연동 시 실제 삭제됩니다)');
    cancelDelete();
}
function cancelDelete() {
    document.getElementById('deleteTabBtn').style.display = 'none';
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
    document.getElementById('tab-search').classList.add('active');
    document.querySelectorAll('.tab-btn')[0].classList.add('active');
}
function showTab(name) {
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
    document.getElementById('tab-' + name).classList.add('active');
    if (event && event.target) event.target.classList.add('active');
}
function openEdit(id, sw) {
    document.getElementById('edit-id').value = id;
    document.getElementById('edit-sw').value = sw;
    document.getElementById('editTabBtn').style.display = '';
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
    document.getElementById('tab-edit').classList.add('active');
    document.getElementById('editTabBtn').classList.add('active');
}
function saveEdit() {
    alert('수정이 완료됐습니다!\n(프로토타입: DB 연동 시 실제 저장됩니다)');
    cancelEdit();
}
function cancelEdit() {
    document.getElementById('editTabBtn').style.display = 'none';
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(el){ el.classList.remove('active'); });
    document.getElementById('tab-search').classList.add('active');
    document.querySelectorAll('.tab-btn')[0].classList.add('active');
}

</script>

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

</body>
</html>