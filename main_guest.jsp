<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICT CampusNav — 게스트</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>
    body{background:linear-gradient(180deg,#f4f7fb 0%,#edf3f9 100%);font-family:'Noto Sans KR',sans-serif;color:#1f2937;min-height:100vh;}
    .topbar{background:linear-gradient(135deg,#0f172a 0%,#0f766e 100%);display:flex;align-items:center;justify-content:space-between;padding:.75rem 2rem;position:sticky;top:0;z-index:100;box-shadow:0 4px 16px rgba(15,23,42,.2);}
    .brand{font-size:1.1rem;font-weight:800;color:#fff;text-decoration:none;display:flex;align-items:center;gap:.6rem;}
    .brand span{color:#4ade80;}
    .nav-right{display:flex;align-items:center;gap:.75rem;}
    .role-badge{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);color:#fff;border-radius:999px;padding:.2rem .85rem;font-size:.78rem;font-weight:600;}
    .btn-out{background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.2);color:#fff;border-radius:10px;font-size:.8rem;padding:.35rem .9rem;cursor:pointer;transition:all .2s;text-decoration:none;}
    .btn-out:hover{background:rgba(255,255,255,.22);color:#fff;}
    .page-wrap{max-width:1200px;margin:28px auto;padding:0 1.5rem;}
    .hero-box{background:linear-gradient(135deg,#0f172a 0%,#0f766e 48%,#22c55e 100%);color:white;border-radius:28px;padding:42px;box-shadow:0 18px 40px rgba(15,23,42,.16);position:relative;overflow:hidden;margin-bottom:1.5rem;}
    .hero-box::before{content:"";position:absolute;right:-60px;top:-50px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.08);}
    .hero-title{font-size:1.8rem;font-weight:800;margin-bottom:10px;position:relative;z-index:1;}
    .hero-desc{font-size:.95rem;line-height:1.85;color:rgba(255,255,255,.92);position:relative;z-index:1;}
    .card-modern{border:none;border-radius:26px;background:rgba(255,255,255,.96);box-shadow:0 14px 35px rgba(15,23,42,.08);overflow:hidden;margin-bottom:1.5rem;}
    .card-modern .card-body{padding:28px;}
    .section-title{font-size:1.1rem;font-weight:800;color:#0f172a;margin-bottom:8px;}
    .section-sub{color:#64748b;font-size:.9rem;margin-bottom:16px;line-height:1.8;}
    .search-row{display:flex;gap:.6rem;}
    .search-row input{flex:1;border:1.5px solid rgba(255,255,255,.4);border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:rgba(255,255,255,.15);color:#fff;}
    .search-row input::placeholder{color:rgba(255,255,255,.6);}
    .search-row input:focus{background:rgba(255,255,255,.25);border-color:rgba(255,255,255,.7);}
    .btn-search{background:#fff;border:none;border-radius:12px;color:#0f766e;font-weight:700;padding:.65rem 1.4rem;cursor:pointer;white-space:nowrap;}
    .cat-card{border:1px solid #edf2f7;border-radius:20px;padding:20px;background:#fff;text-align:center;text-decoration:none;color:#1f2937;transition:all .2s;display:block;}
    .cat-card:hover{box-shadow:0 10px 22px rgba(15,23,42,.08);transform:translateY(-3px);border-color:#0f766e;}
    .cat-card i{font-size:2rem;display:block;margin-bottom:.5rem;}
    .cat-card span{font-size:.88rem;font-weight:700;}
    .alert-info-box{background:rgba(255,255,255,.15);border:1px solid rgba(255,255,255,.25);border-radius:14px;padding:.8rem 1.1rem;color:#fff;font-size:.88rem;position:relative;z-index:1;margin-top:1rem;}
    .alert-info-box a{color:#4ade80;font-weight:700;text-decoration:none;}
</style>
</head><body>
<div class="topbar">
    <a href="/CampusNav/main_guest.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:28px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div class="nav-right">
        <span style="color:rgba(255,255,255,.75);font-size:.82rem"><i class="bi bi-person me-1"></i>게스트</span>
        <span class="role-badge">외부인</span>
        <a href="/CampusNav/campuslogin.jsp" class="btn-out"><i class="bi bi-box-arrow-in-right me-1"></i>로그인</a>
    </div>
</div>
<div class="container-fluid page-wrap">
    <div class="hero-box mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <div class="hero-title">ICT CampusNav 자원 검색 🔍</div>
                <div class="hero-desc">로그인 없이 교내 자산을 검색하고 위치를 확인할 수 있습니다.</div>
                <form method="get" action="/CampusNav/search.jsp" class="mt-3">
                    <div class="search-row" style="max-width:520px">
                        <input type="text" name="keyword" placeholder="자산명, 위치, 번호 검색...">
                        <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
                    </div>
                </form>
                <div class="alert-info-box">
                    <i class="bi bi-info-circle me-1"></i>
                    게스트는 검색·상세보기만 가능합니다. 예약하려면 <a href="/CampusNav/campuslogin.jsp">로그인</a>해 주세요.
                </div>
            </div>
        </div>
    </div>
    <div class="card-modern">
        <div class="card-body">
            <div class="section-title"><i class="bi bi-bookmark me-2"></i>카테고리별 검색</div>
            <div class="row g-3">
                <div class="col-6 col-md-4"><a href="/CampusNav/search.jsp?keyword=공기구비품" class="cat-card"><i class="bi bi-tools" style="color:#0ea5e9"></i><span>공기구비품</span></a></div>
                <div class="col-6 col-md-4"><a href="/CampusNav/search.jsp?keyword=집기비품"   class="cat-card"><i class="bi bi-laptop" style="color:#16a34a"></i><span>집기비품</span></a></div>
                <div class="col-6 col-md-4"><a href="/CampusNav/search.jsp?keyword=소프트웨어" class="cat-card"><i class="bi bi-code-square" style="color:#7c3aed"></i><span>소프트웨어</span></a></div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body></html>