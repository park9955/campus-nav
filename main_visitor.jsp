<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    String loginRole=(String)session.getAttribute("loginRole");
    if(loginUser==null||!"visitor".equals(loginRole)){
        response.sendRedirect("/CampusNav/campuslogin.jsp"); return;
    }
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CampusNav — 외부인</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
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
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,rgba(255,255,255,.06) 0%,rgba(22,163,74,.15) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);}
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



/* ══ 외부인 전용 추가 스타일 ══ */
/* 검색 차단 오버레이 */
.locked-box {
    border:2px dashed var(--line2); border-radius:var(--r2);
    background:var(--bg); padding:32px; text-align:center; color:var(--txt3);
    position:relative; overflow:hidden;
}
.locked-box::before {
    content:"\f3dd"; font-family:"bootstrap-icons";
    font-size:48px; display:block; margin-bottom:12px; opacity:.2;
}
.locked-title { font-size:16px; font-weight:700; color:var(--txt2); margin-bottom:6px; }
.locked-sub   { font-size:14px; }

/* 예약 폼 */
.reserve-card { border:1.5px solid var(--teal-md); border-radius:var(--r2); overflow:hidden; margin-bottom:20px; }
.reserve-head { background:linear-gradient(135deg,#0f172a,#0d6147,#16a34a); padding:20px 26px; display:flex; align-items:center; gap:14px; }
.reserve-head-icon { width:44px; height:44px; background:rgba(255,255,255,.2); border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; }
.reserve-head-title { font-size:17px; font-weight:800; color:#fff; }
.reserve-head-sub   { font-size:13px; color:rgba(255,255,255,.75); margin-top:2px; }

/* 네비 카드 */
.nav-card { border:1.5px solid var(--blue-md); border-radius:var(--r2); overflow:hidden; margin-bottom:20px; }
.nav-head  { background:linear-gradient(135deg,#0f172a,#0d6147,#16a34a); padding:20px 26px; display:flex; align-items:center; gap:14px; }
.nav-head-icon  { width:44px; height:44px; background:rgba(255,255,255,.2); border-radius:12px; display:flex; align-items:center; justify-content:center; font-size:22px; }
.nav-head-title { font-size:17px; font-weight:800; color:#fff; }
.nav-head-sub   { font-size:13px; color:rgba(255,255,255,.75); margin-top:2px; }

/* 알림 배지 */
.badge-visitor { background:var(--purple-lt); color:var(--purple); border-radius:6px; padding:4px 11px; font-size:13px; font-weight:700; font-family:var(--mono); }

/* 시간 체크 */
.time-check { margin-top:8px; padding:10px 14px; border-radius:var(--r); font-size:14px; font-weight:600; display:none; }
.time-ok  { background:var(--green-lt); border:1px solid #86efac; color:var(--green); }
.time-err { background:var(--red-lt); border:1px solid #fca5a5; color:var(--red); }

/* 다크그린 override */
.hero { background:linear-gradient(135deg,#0f172a 0%,#0d6147 50%,#16a34a 100%) !important; border:none !important; box-shadow:0 8px 32px rgba(15,23,42,.25) !important; }
.hero::after { background:linear-gradient(135deg,rgba(255,255,255,.05) 0%,rgba(22,163,74,.12) 100%) !important; }
.hero-eyebrow { color:rgba(255,255,255,.72) !important; }
.hero-title   { color:#fff !important; }
.hero-title em { color:#4ade80 !important; font-style:normal; }
.hero-desc    { color:rgba(255,255,255,.88) !important; }
</style>
</head>
<body>

<!-- TOPNAV -->
<div class="topnav" style="padding:14px 32px;">
  <a href="/CampusNav/main_visitor.jsp" class="logo">
    <span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
    ICT Campus<em>Nav</em>
  </a>
  <div class="nav-right">
    <span style="font-family:var(--mono);font-size:13px;color:var(--txt2)">
      <i class="bi bi-person-circle"></i> <%= loginName %>
    </span>
    <span class="badge-visitor">외부인</span>
    <a href="/CampusNav/campuslogin.jsp" class="chip" style="border-color:var(--blue);color:var(--blue)">
      <i class="bi bi-box-arrow-in-right"></i> 재학생 로그인
    </a>
    <form action="/CampusNav/logout" method="post" style="margin:0">
      <button type="submit" class="chip"><i class="bi bi-box-arrow-right"></i> 나가기</button>
    </form>
  </div>
</div>

<div class="shell">

  <!-- HERO -->
  <div class="hero">
    <div class="hero-content">
      <div class="hero-eyebrow">// ICT CampusNav · 외부인 모드</div>
      <div class="hero-title">외부인 <em>예약 · 길찾기</em></div>
      <div class="hero-desc">외부 방문자는 공간 예약과 캠퍼스 길찾기만 이용 가능합니다.<br>자원 검색은 재학생 로그인 후 이용하세요.</div>
    </div>
    <div class="hero-side"><div class="hero-illo">🏫</div></div>
  </div>

  <!-- 안내 배너 -->
  <div style="background:var(--amber-lt);border:1.5px solid #fde68a;border-radius:var(--r2);padding:16px 22px;margin-bottom:24px;display:flex;align-items:center;gap:14px;">
    <i class="bi bi-info-circle-fill" style="font-size:20px;color:var(--amber);flex-shrink:0"></i>
    <div>
      <div style="font-weight:700;font-size:15px;color:var(--amber)">외부인 이용 안내</div>
      <div style="font-size:14px;color:var(--txt2);margin-top:2px">
        외부인은 <strong>공간 예약</strong>과 <strong>캠퍼스 길찾기</strong>만 이용 가능합니다.
        자원 검색 및 상세 조회는 <a href="/CampusNav/campuslogin.jsp" style="color:var(--blue);font-weight:700;text-decoration:none">재학생 로그인 →</a>
      </div>
    </div>
  </div>

  <div class="row g-4">
  <div class="col-xl-7">

    <!-- ══ 공간 예약 폼 ══ -->
    <div class="reserve-card">
      <div class="reserve-head">
        <div class="reserve-head-icon">📅</div>
        <div>
          <div class="reserve-head-title">공간 예약</div>
          <div class="reserve-head-sub">방문 목적 공간을 직접 예약하세요 — DB 실시간 저장</div>
        </div>
      </div>
      <div style="padding:24px 26px;background:var(--white)">
        <%
          String reserveMsg="", reserveErr="";
          if("POST".equals(request.getMethod())&&request.getParameter("v_action")!=null){
              request.setCharacterEncoding("UTF-8");
              String vName=request.getParameter("v_name");
              String vPhone=request.getParameter("v_phone");
              String vOrg=request.getParameter("v_org");
              String vPurpose=request.getParameter("v_purpose");
              String vDate=request.getParameter("v_date");
              String vStart=request.getParameter("v_start");
              String vEnd=request.getParameter("v_end");
              String vPlace=request.getParameter("v_place");
              if(vName==null||vName.trim().isEmpty()||vDate==null||vDate.trim().isEmpty()
                 ||vStart==null||vStart.trim().isEmpty()||vEnd==null||vEnd.trim().isEmpty()){
                  reserveErr="이름, 날짜, 시간은 필수 항목입니다.";
              } else {
                  try{
                      Class.forName("com.mysql.cj.jdbc.Driver");
                      Connection conn=DriverManager.getConnection(
                          "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
                      // 시간 중복 체크 (같은 공간)
                      boolean dup=false;
                      if(vPlace!=null&&!vPlace.trim().isEmpty()){
                          PreparedStatement ck=conn.prepareStatement(
                              "SELECT COUNT(*) FROM reservations WHERE asset_no=? AND reserve_date=? AND status='예약완료' AND start_time<? AND end_time>?");
                          ck.setString(1,vPlace.trim());ck.setString(2,vDate.trim());ck.setString(3,vEnd.trim());ck.setString(4,vStart.trim());
                          ResultSet rck=ck.executeQuery();dup=rck.next()&&rck.getInt(1)>0;rck.close();ck.close();
                      }
                      if(dup){
                          reserveErr="해당 시간에 이미 예약이 있습니다. 다른 시간을 선택해 주세요.";
                      } else {
                          PreparedStatement ps=conn.prepareStatement(
                              "INSERT INTO reservations(asset_no,user_id,reserve_date,start_time,end_time,purpose,phone,status) VALUES(?,?,?,?,?,?,?,'예약완료')");
                          ps.setString(1,vPlace!=null&&!vPlace.trim().isEmpty()?vPlace.trim():"VISITOR-SPACE");
                          ps.setString(2,"visitor");
                          ps.setString(3,vDate.trim());
                          ps.setString(4,vStart.trim());
                          ps.setString(5,vEnd.trim());
                          String purposeFull=(vPurpose!=null?vPurpose:"")+" [방문자:"+vName+(vOrg!=null&&!vOrg.isEmpty()?" ("+vOrg+")":"")+" / "+vPhone+"]";
                          ps.setString(6,purposeFull);
                          ps.setString(7,vPhone!=null?vPhone:"");
                          ps.executeUpdate();ps.close();
                          reserveMsg="예약 완료! "+vDate+" "+vStart+"~"+vEnd+" 예약이 DB에 저장되었습니다.";
                      }
                      conn.close();
                  }catch(Exception e){ reserveErr="DB 오류: "+e.getMessage(); }
              }
          }
        %>

        <% if(!reserveMsg.isEmpty()){%>
        <div style="background:var(--green-lt);border:1.5px solid #86efac;border-radius:var(--r);color:var(--green);font-size:14px;font-weight:600;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:8px">
          <i class="bi bi-check-circle-fill"></i><%= reserveMsg %>
        </div>
        <%}%>
        <% if(!reserveErr.isEmpty()){%>
        <div style="background:var(--red-lt);border:1.5px solid #fca5a5;border-radius:var(--r);color:var(--red);font-size:14px;font-weight:600;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:8px">
          <i class="bi bi-exclamation-circle-fill"></i><%= reserveErr %>
        </div>
        <%}%>

        <form method="post" action="/CampusNav/main_visitor.jsp" onsubmit="return checkVisitorTime()">
          <input type="hidden" name="v_action" value="reserve">
          <div class="row g-3">
            <div class="col-md-6">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">방문자 성명 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans);transition:border-color .15s" onfocus="this.style.borderColor='var(--blue)';this.style.boxShadow='0 0 0 3px var(--blue-lt)'" onblur="this.style.borderColor='var(--line2)';this.style.boxShadow=''" type="text" name="v_name" placeholder="홍길동" required>
            </div>
            <div class="col-md-6">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">연락처 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans);transition:border-color .15s" onfocus="this.style.borderColor='var(--blue)';this.style.boxShadow='0 0 0 3px var(--blue-lt)'" onblur="this.style.borderColor='var(--line2)';this.style.boxShadow=''" type="text" name="v_phone" placeholder="010-0000-0000" required>
            </div>
            <div class="col-md-6">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">소속 기관</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans);transition:border-color .15s" onfocus="this.style.borderColor='var(--blue)';this.style.boxShadow='0 0 0 3px var(--blue-lt)'" onblur="this.style.borderColor='var(--line2)';this.style.boxShadow=''" type="text" name="v_org" placeholder="예) ○○기업, 지자체">
            </div>
            <div class="col-md-6">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">방문 목적 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans);transition:border-color .15s" onfocus="this.style.borderColor='var(--blue)';this.style.boxShadow='0 0 0 3px var(--blue-lt)'" onblur="this.style.borderColor='var(--line2)';this.style.boxShadow=''" type="text" name="v_purpose" placeholder="예) 산학협력 미팅, 시설 견학" required>
            </div>
            <div class="col-md-4">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">방문 날짜 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans)" type="date" name="v_date" id="v_date" onchange="checkVisitorTimeAuto()" min="<%= new java.text.SimpleDateFormat("yyyy-MM-dd").format(new java.util.Date()) %>" required>
            </div>
            <div class="col-md-4">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">시작 시간 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans)" type="time" name="v_start" id="v_start" onchange="checkVisitorTimeAuto()" required>
            </div>
            <div class="col-md-4">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">종료 시간 *</label>
              <input style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;font-family:var(--sans)" type="time" name="v_end" id="v_end" onchange="checkVisitorTimeAuto()" required>
            </div>
            <div class="col-12">
              <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600">희망 공간</label>
              <select style="width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;background:var(--white);font-family:var(--sans)" name="v_place">
                <option value="">공간 선택 (선택사항)</option>
                <option value="VISITOR-SEMINAR">세미나실 (A동)</option>
                <option value="VISITOR-MEETING">회의실 (본관)</option>
                <option value="VISITOR-HALL">강당 (ICT융합관)</option>
                <option value="VISITOR-PROJECT">프로젝트실</option>
              </select>
            </div>
            <div id="v_timeCheck" class="time-check"></div>
            <div class="col-12">
              <button type="submit" style="background:var(--teal);color:white;border:none;border-radius:var(--r);padding:12px 26px;font-size:15px;font-weight:700;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:8px" onmouseover="this.style.background='#0b7b70'" onmouseout="this.style.background='var(--teal)'">
                <i class="bi bi-calendar-check"></i>예약 신청 (DB 저장)
              </button>
            </div>
          </div>
        </form>
      </div>
    </div>

    <!-- ══ 자원 검색 잠금 안내 ══ -->
    <div class="locked-box">
      <div class="locked-title">🔒 자원 검색 — 외부인 이용 불가</div>
      <div class="locked-sub">재학생·교직원만 이용 가능한 기능입니다.</div>
      <div style="margin-top:16px">
        <a href="/CampusNav/campuslogin.jsp" style="background:var(--blue);color:white;border:none;border-radius:var(--r);padding:10px 20px;font-size:14px;font-weight:700;cursor:pointer;text-decoration:none;display:inline-flex;align-items:center;gap:6px">
          <i class="bi bi-box-arrow-in-right"></i>재학생 로그인하여 이용
        </a>
      </div>
    </div>

  </div>
  <div class="col-xl-5">

    <!-- ══ 실내 길찾기 ══ -->
    <div class="nav-card">
      <div class="nav-head">
        <div class="nav-head-icon">🧭</div>
        <div>
          <div class="nav-head-title">캠퍼스 길찾기</div>
          <div class="nav-head-sub">목적지까지 최적 경로 안내</div>
        </div>
      </div>
      <div style="padding:24px 26px;background:var(--white)">
        <div style="background:linear-gradient(135deg,var(--teal-lt),var(--blue-lt));border:1.5px dashed var(--teal-md);border-radius:var(--r2);padding:28px;text-align:center;margin-bottom:18px">
          <div style="font-size:48px;line-height:1;margin-bottom:10px">🧭</div>
          <div style="font-size:15px;font-weight:700;color:var(--txt);margin-bottom:6px">캠퍼스 실내 지도 / 경로 안내</div>
          <div style="font-size:13px;color:var(--txt3);line-height:1.7;max-width:260px;margin:0 auto">
            현재 위치에서 강의실, 연구실, 행정실까지 최적 경로를 안내합니다<br>
            <span style="font-size:12px;color:var(--teal)">ICT폴리텍대학 (위도 37.396681 / 경도 127.247918)</span>
          </div>
        </div>

        <div style="margin-bottom:14px">
          <label style="font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:7px;font-weight:600">목적지 검색</label>
          <div style="display:flex;gap:8px">
            <input type="text" id="navDest" placeholder="예) 행정실, 학생처, 공학관 301호"
                   style="flex:1;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:14px;outline:none;font-family:var(--sans);"
                   onfocus="this.style.borderColor='var(--teal)'" onblur="this.style.borderColor='var(--line2)'">
            <a href="#" class="btn-nav-prim" onclick="goNav();return false;"
               style="background:var(--teal);color:white;border:none;border-radius:var(--r);padding:10px 16px;font-size:14px;font-weight:700;text-decoration:none;white-space:nowrap;display:flex;align-items:center;gap:4px">
              <i class="bi bi-compass"></i>길찾기
            </a>
          </div>
        </div>

        <!-- 자주 찾는 장소 -->
        <div style="margin-bottom:18px">
          <div style="font-family:var(--mono);font-size:12px;color:var(--txt3);text-transform:uppercase;letter-spacing:.06em;margin-bottom:10px">자주 찾는 장소</div>
          <div style="display:flex;flex-wrap:wrap;gap:6px">
            <button onclick="quickNav('행정실')"   style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">🏢 행정실</button>
            <button onclick="quickNav('학생처')"   style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">👥 학생처</button>
            <button onclick="quickNav('강당')"     style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">🎪 강당</button>
            <button onclick="quickNav('도서관')"   style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">📚 도서관</button>
            <button onclick="quickNav('세미나실')" style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">🖥 세미나실</button>
            <button onclick="quickNav('주차장')"   style="border:1.5px solid var(--line2);border-radius:var(--r);padding:6px 14px;font-size:13px;background:var(--white);cursor:pointer;transition:all .15s" onmouseover="this.style.borderColor='var(--teal)';this.style.color='var(--teal)'" onmouseout="this.style.borderColor='var(--line2)';this.style.color=''">🚗 주차장</button>
          </div>
        </div>

        <div style="display:grid;grid-template-columns:1fr 1fr;gap:8px">
          <a href="#" onclick="goNav();return false;"
             style="background:var(--teal);color:white;border:none;border-radius:var(--r);padding:11px;font-size:14px;font-weight:700;text-decoration:none;text-align:center;display:flex;align-items:center;justify-content:center;gap:6px">
            <i class="bi bi-geo-alt-fill"></i>현재 위치 길찾기
          </a>
          <a href="/CampusNav/navigationTest1.jsp"
             style="background:transparent;color:var(--txt2);border:1.5px solid var(--line2);border-radius:var(--r);padding:10px;font-size:13px;font-weight:600;text-decoration:none;text-align:center;display:flex;align-items:center;justify-content:center;gap:6px">
            <i class="bi bi-map"></i>전체 지도 보기
          </a>
        </div>

        <div id="navMsg" style="display:none;margin-top:12px;padding:11px 14px;background:var(--teal-lt);border:1px solid var(--teal-md);border-radius:var(--r);font-size:14px;color:var(--teal)"></div>
      </div>
    </div>

    <!-- ══ 학교 안내 ══ -->
    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-blue"><i class="bi bi-building" style="color:var(--blue)"></i></div>
        <div><div class="ch-title">ICT폴리텍대학 안내</div><div class="ch-sub">경기도 광주시 순암로 16-26</div></div>
      </div>
      <div class="card-body">
        <ul style="list-style:none;padding:0;margin:0">
          <li style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--line);font-size:14px">
            <span style="color:var(--txt2)">📞 대표 전화</span><span style="font-weight:700;font-family:var(--mono)">031-639-1114</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--line);font-size:14px">
            <span style="color:var(--txt2)">🕐 운영 시간</span><span style="font-weight:700">평일 09:00 ~ 18:00</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--line);font-size:14px">
            <span style="color:var(--txt2)">📍 위치</span><span style="font-weight:700">경기 광주 순암로 16-26</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:10px 0;font-size:14px">
            <span style="color:var(--txt2)">🅿 주차</span><span style="font-weight:700;color:var(--green)">무료 주차 가능</span>
          </li>
        </ul>
        <div style="margin-top:16px">
          <a href="https://map.kakao.com/link/to/ICT폴리텍대학,37.396681,127.247918" target="_blank"
             style="display:block;text-align:center;background:var(--blue);color:white;border:none;border-radius:var(--r);padding:11px;font-size:14px;font-weight:700;text-decoration:none">
            <i class="bi bi-map me-1"></i>카카오맵으로 오시는 길 보기
          </a>
        </div>
      </div>
    </div>

  </div>
  </div><!-- /row -->

</div><!-- /shell -->

<!-- FOOTER -->
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

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* ══ 길찾기 ══ */
function goNav() {
  var dest = document.getElementById('navDest').value.trim();
  var url  = '/CampusNav/navigationTest1.jsp';
  if(dest) url += '?destName=' + encodeURIComponent(dest);
  var msg = document.getElementById('navMsg');
  msg.innerHTML = '<i class="bi bi-compass me-1"></i>' +
    (dest ? '목적지: <strong>'+dest+'</strong> — 경로를 계산 중입니다...' : '현재 위치를 탐색 중입니다...') +
    '<br><small style="opacity:.75">GPS 설치 후 실시간 경로 표시 (위도 37.396681 / 경도 127.247918)</small>';
  msg.style.display='block';
  setTimeout(function(){ location.href=url; }, 700);
}
function quickNav(dest) {
  document.getElementById('navDest').value = dest;
  goNav();
}

/* ══ 예약 시간 체크 ══ */
function checkVisitorTimeAuto() {
  var date  = document.getElementById('v_date').value;
  var start = document.getElementById('v_start').value;
  var end   = document.getElementById('v_end').value;
  var el    = document.getElementById('v_timeCheck');
  if(!date || !start || !end) { el.style.display='none'; return; }
  if(start >= end) {
    el.className='time-check time-err';
    el.innerHTML='<i class="bi bi-x-circle-fill me-1"></i>종료 시간이 시작 시간보다 빠릅니다.';
    el.style.display='block'; return;
  }
  el.className='time-check time-ok';
  el.innerHTML='<i class="bi bi-check-circle-fill me-1"></i>시간이 유효합니다. 예약 신청 버튼을 눌러주세요.';
  el.style.display='block';
}
function checkVisitorTime() {
  var el = document.getElementById('v_timeCheck');
  if(el && el.classList.contains('time-err')) {
    alert('예약 시간을 확인해 주세요.'); return false;
  }
  return confirm('예약을 신청하시겠습니까?\n\n이름: ' +
    document.querySelector('[name="v_name"]').value + '\n날짜: ' +
    document.getElementById('v_date').value + '\n시간: ' +
    document.getElementById('v_start').value + ' ~ ' + document.getElementById('v_end').value);
}
</script>
</body>
</html>