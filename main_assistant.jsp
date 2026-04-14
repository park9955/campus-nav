<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser"),loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CampusNav/campuslogin.jsp");return;}
    int total=0;
    try{Class.forName("com.mysql.cj.jdbc.Driver");Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets");if(rs.next())total=rs.getInt(1);conn.close();}catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CampusNav — 조교</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet"><link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet"><link href="https://fonts.googleapis.com/css2?family=DM+Sans:ital,opsz,wght@0,9..40,300;0,9..40,400;0,9..40,500;0,9..40,700;0,9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>
/* ═══ TOKENS (ppd4) ═══ */
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
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:15px;line-height:1.6;}

/* ═══ TOPNAV ═══ */
.topnav{display:flex;align-items:center;justify-content:space-between;padding:16px 0;border-bottom:1px solid var(--line);margin-bottom:28px;}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;color:var(--txt);letter-spacing:-.02em;text-decoration:none;}
.logo-dot{width:30px;height:30px;border-radius:8px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.logo-dot img{width:100%;height:100%;object-fit:contain;}
.logo em{color:var(--blue);font-style:normal;}
.nav-right{display:flex;gap:8px;align-items:center;}
.chip{font-family:var(--mono);font-size:12px;padding:6px 13px;border-radius:999px;background:var(--white);border:1px solid var(--line);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-flex;align-items:center;gap:4px;}
.chip:hover{border-color:var(--blue);color:var(--blue);}
.chip-blue{background:var(--blue);color:white;border-color:var(--blue);}
.chip-blue:hover{background:#1647c0;color:white;}
.role-chip{font-family:var(--mono);font-size:12px;padding:5px 13px;border-radius:6px;background:var(--blue-lt);border:1px solid var(--blue-md);color:var(--blue);}

/* ═══ SHELL ═══ */
.shell{max-width:1380px;margin:0 auto;padding:0 24px 72px;}

/* ═══ HERO ═══ */
.hero{background:linear-gradient(135deg,#0f172a 0%,#0d6147 50%,#16a34a 100%);border:none;border-radius:var(--r2);padding:40px 44px;margin-bottom:24px;box-shadow:0 8px 32px rgba(15,23,42,.25);display:grid;grid-template-columns:1fr auto;gap:32px;align-items:center;position:relative;overflow:hidden;}
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,rgba(255,255,255,.06) 0%,rgba(22,163,74,.15) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);z-index:0;pointer-events:none;}
.hero-content{position:relative;z-index:1;}
.hero-eyebrow{font-family:var(--mono);font-size:12px;color:rgba(255,255,255,.7);letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px;}
.hero-title{font-size:28px;font-weight:800;line-height:1.25;letter-spacing:-.03em;margin-bottom:10px;color:#ffffff;}
.hero-title span{color:#4ade80;}
.hero-desc{color:rgba(255,255,255,.85);font-size:15px;line-height:1.85;max-width:560px;margin-bottom:18px;}
.tag-row{display:flex;flex-wrap:wrap;gap:6px;}
.tag{font-family:var(--mono);font-size:12px;padding:4px 11px;border-radius:6px;background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);color:rgba(255,255,255,.9);}
.tag b{color:var(--blue);}
.hero-side{position:relative;z-index:2;display:flex;flex-direction:column;align-items:center;gap:10px;min-width:140px;}
.hero-illo{font-size:56px;line-height:1;}

/* 검색바 */
.search-hero{display:flex;gap:8px;max-width:520px;margin-top:16px;}
.search-hero input{flex:1;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 16px;font-size:15px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);}
.search-hero input:focus{border-color:var(--blue);box-shadow:0 0 0 3px var(--blue-lt);}
.btn-search-hero{background:var(--blue);color:white;border:none;border-radius:var(--r);padding:10px 20px;font-size:15px;font-weight:700;cursor:pointer;white-space:nowrap;transition:background .15s;}
.btn-search-hero:hover{background:#1647c0;}

/* ═══ STAT ROW ═══ */
.stat-row{display:grid;grid-template-columns:repeat(4,1fr);gap:14px;margin-bottom:24px;}
.stat-card{background:var(--white);border:1px solid var(--line);border-radius:var(--r2);padding:22px 24px;box-shadow:var(--shadow);display:flex;align-items:flex-start;gap:16px;transition:box-shadow .2s,transform .2s;cursor:pointer;}
.stat-card:hover{box-shadow:var(--shadow2);transform:translateY(-2px);}
.stat-icon{width:44px;height:44px;border-radius:12px;display:flex;align-items:center;justify-content:center;font-size:20px;flex-shrink:0;}
.si-blue{background:var(--blue-lt);} .si-teal{background:var(--teal-lt);} .si-purple{background:var(--purple-lt);} .si-amber{background:var(--amber-lt);}
.stat-label{font-size:12px;color:var(--txt3);font-family:var(--mono);margin-bottom:4px;}
.stat-val{font-size:30px;font-weight:800;letter-spacing:-.04em;line-height:1;margin-bottom:4px;}
.sv-blue{color:var(--blue);} .sv-teal{color:var(--teal);} .sv-purple{color:var(--purple);} .sv-amber{color:var(--amber);}
.stat-sub{font-size:12px;color:var(--txt3);line-height:1.5;}

/* ═══ MAIN GRID ═══ */
.main-grid{display:grid;grid-template-columns:1fr 360px;gap:20px;}

/* ═══ CARD ═══ */
.card{background:var(--white);border:1px solid var(--line);border-radius:var(--r2);box-shadow:var(--shadow);overflow:hidden;margin-bottom:20px;}
.card-head{padding:18px 24px;border-bottom:1px solid var(--line);display:flex;align-items:center;gap:12px;}
.ch-icon{width:34px;height:34px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:16px;flex-shrink:0;}
.ch-title{font-size:15px;font-weight:700;color:var(--txt);}
.ch-sub{font-size:12px;color:var(--txt3);margin-top:1px;}
.card-body{padding:20px 24px;}
.card-head-extra{margin-left:auto;}

/* ═══ SPACE LIST (공간 추천) ═══ */
.space-item{display:flex;align-items:center;gap:16px;padding:14px 0;border-bottom:1px solid var(--line);}
.space-item:last-child{border-bottom:none;}
.space-rank{font-family:var(--mono);font-size:12px;color:var(--txt3);min-width:22px;}
.space-bar{width:3px;height:38px;border-radius:2px;flex-shrink:0;}
.sb-blue{background:var(--blue);} .sb-teal{background:var(--teal);} .sb-purple{background:var(--purple);}
.space-info{flex:1;}
.space-name{font-size:15px;font-weight:700;color:var(--txt);margin-bottom:3px;}
.space-meta{font-size:13px;color:var(--txt2);}
.space-tags{margin-top:6px;display:flex;gap:5px;flex-wrap:wrap;}
.stag{font-size:11px;font-family:var(--mono);font-weight:500;padding:3px 9px;border-radius:5px;}
.stag-blue{background:var(--blue-lt);color:var(--blue);} .stag-green{background:var(--green-lt);color:var(--green);}
.stag-purple{background:var(--purple-lt);color:var(--purple);} .stag-teal{background:var(--teal-lt);color:var(--teal);}
.space-action{flex-shrink:0;}
.btn-prim{font-family:var(--mono);font-size:12px;font-weight:500;padding:8px 16px;background:var(--blue);color:white;border:none;border-radius:var(--r);cursor:pointer;transition:background .15s;white-space:nowrap;text-decoration:none;display:inline-block;}
.btn-prim:hover{background:#1647c0;color:white;}
.btn-ghost{font-family:var(--mono);font-size:12px;font-weight:500;padding:8px 16px;background:var(--white);color:var(--txt2);border:1px solid var(--line);border-radius:var(--r);cursor:pointer;transition:all .15s;white-space:nowrap;text-decoration:none;display:inline-block;}
.btn-ghost:hover{border-color:var(--blue);color:var(--blue);}

/* ═══ CATEGORY GRID ═══ */
.cat-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;}
.cat-item{border:1px solid var(--line);border-radius:var(--r2);padding:18px 8px;text-align:center;text-decoration:none;color:var(--txt);background:var(--white);transition:all .2s;cursor:pointer;}
.cat-item:hover{border-color:var(--blue);box-shadow:var(--shadow2);transform:translateY(-2px);color:var(--blue);}
.cat-item i{display:block;font-size:22px;margin-bottom:8px;}
.cat-item span{font-size:13px;font-weight:600;display:block;}

/* ═══ NAV MAP (우측 패널) ═══ */
.map-frame{background:linear-gradient(135deg,var(--teal-lt),var(--blue-lt));border:1.5px dashed var(--teal-md);border-radius:var(--r2);padding:28px 20px;text-align:center;min-height:180px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:10px;margin-bottom:16px;}
.map-icon{font-size:44px;line-height:1;}
.map-label{font-size:15px;font-weight:700;color:var(--txt);}
.map-note{font-size:13px;color:var(--txt3);line-height:1.7;max-width:260px;}
.map-search{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:14px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);margin-bottom:8px;}
.map-search:focus{border-color:var(--blue);}
.map-btns{display:grid;grid-template-columns:1fr 1fr;gap:8px;}
.btn-nav-prim{background:var(--teal);color:white;border:none;border-radius:var(--r);padding:11px 10px;font-size:14px;font-weight:700;cursor:pointer;transition:background .15s;text-align:center;text-decoration:none;display:block;}
.btn-nav-prim:hover{background:#0b7b70;color:white;}
.btn-nav-ghost{background:transparent;color:var(--txt2);border:1px solid var(--line2);border-radius:var(--r);padding:10px 10px;font-size:13px;font-weight:600;cursor:pointer;transition:all .15s;text-align:center;text-decoration:none;display:block;}
.btn-nav-ghost:hover{border-color:var(--teal);color:var(--teal);}

/* ═══ ADMIN LIST ═══ */
.admin-list{list-style:none;padding:0;margin:0;}
.admin-item{display:flex;justify-content:space-between;align-items:center;padding:12px 0;border-bottom:1px solid var(--line);}
.admin-item:last-child{border-bottom:none;}
.admin-label{font-size:14px;color:var(--txt2);}
.admin-val{font-size:14px;font-weight:700;color:var(--txt);font-family:var(--mono);}

/* ═══ RESPONSIVE ═══ */
@media(max-width:1100px){.main-grid{grid-template-columns:1fr;} .cat-grid{grid-template-columns:repeat(3,1fr);}}
@media(max-width:768px){
  .shell{padding:0 16px 48px;} .topnav{padding:12px 0;}
  .hero{grid-template-columns:1fr;padding:24px 20px;} .hero::after{display:none;} .hero-side{display:none;}
  .stat-row{grid-template-columns:repeat(2,1fr);}
  .search-hero{flex-direction:column;} .btn-search-hero{width:100%;}
  .cat-grid{grid-template-columns:repeat(3,1fr);}
}

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
</head><body><div class="shell">
<div class="topnav">
  <a href="/CampusNav/main_assistant.jsp" class="logo"><span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>ICT Campus<em>Nav</em></a>
  <div class="nav-right">
    <span style="font-family:var(--mono);font-size:13px;color:var(--txt2)"><i class="bi bi-person-circle"></i> <%= loginName %></span>
    <span class="role-chip">조교</span>
    <a href="/CampusNav/asset_manage.jsp" class="chip" style="background:var(--blue);color:white;border-color:var(--blue)"><i class="bi bi-pencil-square"></i> 자원 관리</a>
    <a href="/CampusNav/search.jsp" class="chip"><i class="bi bi-search"></i> 검색</a>
    <a href="/CampusNav/professor.jsp" class="chip"><i class="bi bi-people"></i> 교수</a>
    <form action="/CampusNav/logout" method="post" style="margin:0"><button type="submit" class="chip"><i class="bi bi-box-arrow-right"></i> 로그아웃</button></form>
  </div>
</div>
<div class="hero">
  <div class="hero-content">
    <div class="hero-eyebrow">// ICT CampusNav · 조교</div>
    <div class="hero-title">안녕하세요, <span><%= loginName %></span>님 🧑‍💼</div>
    <div class="hero-desc">자원 검색 및 수정을 담당합니다. DB 총 <strong><%= String.format("%,d",total) %>건</strong> 실시간 연동.</div>
    <div class="tag-row">
      <a href="/CampusNav/search.jsp" class="btn-prim" style="font-size:13px;padding:9px 18px"><i class="bi bi-search me-1"></i>자원 검색</a>
      <a href="/CampusNav/professor.jsp" class="btn-ghost" style="font-size:13px;padding:8px 16px"><i class="bi bi-people me-1"></i>교수 자원</a>
    </div>
  </div>
  <div class="hero-side"><div class="hero-illo">🧑‍💼</div></div>
</div>
<div class="stat-row">
  <div class="stat-card" onclick="location.href='/CampusNav/search.jsp'"><div class="stat-icon si-blue"><i class="bi bi-box-seam" style="color:var(--blue);font-size:20px"></i></div><div><div class="stat-label">전체 자산</div><div class="stat-val sv-blue"><%= String.format("%,d",total) %></div><div class="stat-sub">DB 실시간</div></div></div>
  <div class="stat-card" onclick="location.href='/CampusNav/search.jsp?type=공기구비품'"><div class="stat-icon si-teal"><i class="bi bi-tools" style="color:var(--teal);font-size:20px"></i></div><div><div class="stat-label">공기구비품</div><div class="stat-val sv-teal">3,368</div><div class="stat-sub">장비류</div></div></div>
  <div class="stat-card" onclick="location.href='/CampusNav/search.jsp?type=집기비품'"><div class="stat-icon si-purple"><i class="bi bi-laptop" style="color:var(--purple);font-size:20px"></i></div><div><div class="stat-label">집기비품</div><div class="stat-val sv-purple">4,737</div><div class="stat-sub">가구·PC류</div></div></div>
  <div class="stat-card" onclick="location.href='/CampusNav/search.jsp?type=무형고정자산'"><div class="stat-icon si-amber"><i class="bi bi-code-square" style="color:var(--amber);font-size:20px"></i></div><div><div class="stat-label">소프트웨어</div><div class="stat-val sv-amber">296</div><div class="stat-sub">무형고정자산</div></div></div>
</div>
<div class="main-grid">
  <div class="left-col">
    <div class="card">
      <div class="card-head"><div class="ch-icon si-blue"><i class="bi bi-lightning" style="color:var(--blue)"></i></div><div><div class="ch-title">빠른 이동</div><div class="ch-sub">주요 기능</div></div></div>
      <div class="card-body">
        <div class="cat-grid">
          <a href="/CampusNav/search.jsp" class="cat-item"><i class="bi bi-search" style="color:var(--blue)"></i><span>자원 검색</span></a>
          <a href="/CampusNav/professor.jsp" class="cat-item"><i class="bi bi-people-fill" style="color:var(--teal)"></i><span>교수 자원</span></a>
          <a href="/CampusNav/reserve.jsp" class="cat-item"><i class="bi bi-calendar-check" style="color:var(--amber)"></i><span>예약</span></a>
          <a href="/CampusNav/detail.jsp" class="cat-item"><i class="bi bi-info-circle" style="color:var(--purple)"></i><span>자산 상세</span></a>
          <a href="/CampusNav/search.jsp?type=공기구비품" class="cat-item"><i class="bi bi-tools" style="color:var(--blue)"></i><span>공기구비품</span></a>
          <a href="/CampusNav/search.jsp?type=집기비품" class="cat-item"><i class="bi bi-laptop" style="color:var(--teal)"></i><span>집기비품</span></a>
        </div>
      </div>
    </div>
  </div>
  <div class="right-col"><div class="card">
      <div class="card-head">
        <div class="ch-icon si-teal"><i class="bi bi-compass" style="color:var(--teal)"></i></div>
        <div><div class="ch-title">실내 네비게이션</div><div class="ch-sub">현재 위치 기준 최적 경로 안내</div></div>
      </div>
      <div class="card-body">
        <div class="map-frame">
          <div class="map-icon">🧭</div>
          <div class="map-label">캠퍼스 실내 지도 / 경로 안내</div>
          <div class="map-note">현재 위치에서 강의실, 연구실, 장비실, 교수실까지의 최적 경로를 안내합니다</div>
        </div>
        <input type="text" id="navDest" class="map-search" placeholder="예) 공학관 301호, 이교수 연구실">
        <div class="map-btns">
          <a href="#" class="btn-nav-prim" onclick="goNav();return false;"><i class="bi bi-geo-alt-fill me-1"></i>현재 위치 길찾기</a>
          <a href="/CampusNav/navigationTest1.jsp" class="btn-nav-ghost"><i class="bi bi-arrow-repeat me-1"></i>대체 경로 보기</a>
        </div>
        <div id="navMsg" style="display:none;margin-top:10px;padding:10px 13px;background:var(--teal-lt);border:1px solid var(--teal-md);border-radius:var(--r);font-size:13px;color:var(--teal)"></div>
      </div>
    </div></div>
</div>
</div><script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script><script>
function goNav(){
  var dest=document.getElementById('navDest');if(!dest)return;
  var d=dest.value.trim(),url='/CampusNav/navigationTest1.jsp';
  if(d)url+='?destName='+encodeURIComponent(d);
  var msg=document.getElementById('navMsg');
  if(msg){msg.innerHTML='<i class="bi bi-compass me-1"></i>'+(d?'목적지: <strong>'+d+'</strong> — 경로 계산 중...':'현재 위치 탐색 중...')+'<br><small style="opacity:.75">GPS 설치 후 실시간 경로 표시</small>';msg.style.display='block';}
  setTimeout(function(){location.href=url;},800);
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

</body></html>