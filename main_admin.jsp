<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICT CampusNav — 운영관리자</title>
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
    .btn-out{background:rgba(255,255,255,.12);border:1px solid rgba(255,255,255,.2);color:#fff;border-radius:10px;font-size:.8rem;padding:.35rem .9rem;cursor:pointer;transition:all .2s;}
    .btn-out:hover{background:rgba(255,255,255,.22);color:#fff;}
    .page-wrap{max-width:1200px;margin:28px auto;padding:0 1.5rem;}
    .hero-box{background:linear-gradient(135deg,#0f172a 0%,#0f766e 48%,#22c55e 100%);color:white;border-radius:28px;padding:42px;box-shadow:0 18px 40px rgba(15,23,42,.16);position:relative;overflow:hidden;margin-bottom:1.5rem;}
    .hero-box::before{content:"";position:absolute;right:-60px;top:-50px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.08);}
    .hero-box::after{content:"";position:absolute;left:-40px;bottom:-60px;width:180px;height:180px;border-radius:50%;background:rgba(255,255,255,.06);}
    .hero-title{font-size:1.8rem;font-weight:800;margin-bottom:10px;position:relative;z-index:1;}
    .hero-title em{color:#4ade80;font-style:normal;}
    .hero-desc{font-size:.95rem;line-height:1.85;color:rgba(255,255,255,.92);position:relative;z-index:1;}
    .soft-tag{display:inline-block;background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.15);color:#fff;padding:6px 14px;border-radius:999px;font-size:.88rem;margin:5px 5px 0 0;position:relative;z-index:1;}
    .stat-card{border:none;border-radius:24px;padding:24px;color:white;min-height:140px;box-shadow:0 12px 26px rgba(15,23,42,.09);transition:transform .2s;}
    .stat-card:hover{transform:translateY(-4px);}
    .stat1{background:linear-gradient(135deg,#0ea5e9,#38bdf8);}.stat2{background:linear-gradient(135deg,#16a34a,#4ade80);}
    .stat3{background:linear-gradient(135deg,#7c3aed,#a78bfa);}.stat4{background:linear-gradient(135deg,#ea580c,#fb923c);}
    .stat-label{font-size:.92rem;opacity:.95;}.stat-value{font-size:2rem;font-weight:800;margin:10px 0 6px;}.stat-desc{font-size:.88rem;opacity:.92;}
    .card-modern{border:none;border-radius:26px;background:rgba(255,255,255,.96);box-shadow:0 14px 35px rgba(15,23,42,.08);overflow:hidden;margin-bottom:1.5rem;}
    .card-modern .card-body{padding:28px;}
    .section-title{font-size:1.1rem;font-weight:800;color:#0f172a;margin-bottom:8px;}
    .section-sub{color:#64748b;font-size:.9rem;margin-bottom:16px;line-height:1.8;}
    .result-row{border:1px solid #edf2f7;border-radius:18px;padding:18px;margin-bottom:12px;background:#fff;transition:all .2s;}
    .result-row:hover{border-color:#bae6fd;box-shadow:0 8px 20px rgba(14,165,233,.08);}
    .result-title{font-size:1rem;font-weight:700;color:#111827;margin-bottom:5px;}
    .result-meta{color:#6b7280;font-size:.88rem;line-height:1.7;}
    .badge-soft-blue{background:#eaf6ff;color:#0284c7;border-radius:999px;padding:5px 12px;font-size:.82rem;font-weight:700;display:inline-block;margin:4px 4px 0 0;}
    .badge-soft-green{background:#ebfbf1;color:#16a34a;border-radius:999px;padding:5px 12px;font-size:.82rem;font-weight:700;display:inline-block;margin:4px 4px 0 0;}
    .badge-soft-purple{background:#f3edff;color:#7c3aed;border-radius:999px;padding:5px 12px;font-size:.82rem;font-weight:700;display:inline-block;margin:4px 4px 0 0;}
    .badge-use{background:#dcfce7;color:#16a34a;border-radius:999px;padding:.22rem .75rem;font-size:.76rem;font-weight:700;}
    .badge-busy{background:#fee2e2;color:#dc2626;border-radius:999px;padding:.22rem .75rem;font-size:.76rem;font-weight:700;}
    .btn-main{background:linear-gradient(135deg,#0f766e,#16a34a);border:none;color:#fff;border-radius:12px;padding:10px 18px;font-weight:700;cursor:pointer;transition:opacity .2s;display:inline-block;text-decoration:none;}
    .btn-main:hover{opacity:.9;color:#fff;}
    .btn-soft{background:#f8fafc;border:1px solid #e2e8f0;color:#334155;border-radius:12px;padding:10px 18px;font-weight:600;cursor:pointer;}
    .btn-detail{background:linear-gradient(135deg,#0f766e,#0ea5e9);color:#fff;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;cursor:pointer;font-weight:600;}
    .btn-reserve{background:linear-gradient(135deg,#0f172a,#1e3a5f);color:#fff;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;cursor:pointer;font-weight:600;}
    .btn-edit{background:#e0f2fe;color:#0284c7;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;cursor:pointer;font-weight:600;}
    .btn-del{background:#fee2e2;color:#dc2626;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;cursor:pointer;font-weight:600;}
    .btn-submit{background:linear-gradient(135deg,#0f766e,#16a34a);color:#fff;border:none;border-radius:12px;padding:.7rem 1.8rem;font-size:.92rem;font-weight:700;cursor:pointer;width:100%;}
    .search-row{display:flex;gap:.6rem;}
    .search-row input{flex:1;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa;}
    .search-row input:focus{border-color:#0f766e;box-shadow:0 0 0 3px rgba(15,118,110,.12);}
    .btn-search{background:linear-gradient(135deg,#0f766e,#16a34a);border:none;border-radius:12px;color:#fff;font-weight:700;padding:.65rem 1.4rem;cursor:pointer;white-space:nowrap;}
    .table-modern thead th{background:#f7fcfb;color:#334155;border:none;font-weight:700;padding:14px 16px;font-size:.82rem;text-transform:uppercase;letter-spacing:.04em;}
    .table-modern tbody td{vertical-align:middle;padding:14px 16px;border-color:#f1f5f9;font-size:.88rem;}
    .table-modern tbody tr:hover td{background:#f8fbff;}
    .f-label{font-size:.78rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:.4rem;}
    .f-input{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa;color:#1f2937;}
    .f-input:focus{border-color:#0f766e;box-shadow:0 0 0 3px rgba(15,118,110,.12);background:#fff;}
    .f-select{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa;}
    .tab-row{display:flex;gap:.5rem;margin-bottom:1.2rem;flex-wrap:wrap;}
    .tab-btn{padding:.55rem 1.2rem;border-radius:12px;border:1.5px solid #e5e7eb;background:#fff;color:#64748b;font-size:.85rem;font-weight:600;cursor:pointer;transition:all .2s;}
    .tab-btn.active{background:linear-gradient(135deg,#0f766e,#16a34a);color:#fff;border-color:transparent;}
    .tab-btn:hover:not(.active){border-color:#0f766e;color:#0f766e;}
    .tab-content{display:none;}.tab-content.active{display:block;}
    .resource-card{border:1px solid #edf2f7;border-radius:20px;padding:20px;height:100%;background:linear-gradient(180deg,#fff 0%,#fbfefd 100%);transition:all .2s;}
    .resource-card:hover{box-shadow:0 10px 20px rgba(15,23,42,.07);transform:translateY(-3px);}
    .resource-title{font-weight:800;font-size:1rem;margin-bottom:8px;color:#0f172a;}
    .alert-campus{background:linear-gradient(135deg,#ecfeff,#f0fdf4);border:none;border-radius:16px;color:#0f172a;padding:1rem 1.2rem;}
    .side-list li{border:none;border-bottom:1px solid #f1f5f9;padding:13px 0;}
    .side-list li:last-child{border-bottom:none;}
    @media(max-width:768px){
        .topbar{padding:.6rem 1rem;flex-wrap:wrap;gap:.4rem;}.page-wrap{padding:1rem;}
        .hero-box{padding:1.6rem 1.4rem;}.hero-title{font-size:1.3rem;}
        .search-row{flex-direction:column;}.btn-search{width:100%;}
        .tab-btn{font-size:.78rem;padding:.45rem .8rem;flex:1;text-align:center;}
        table,thead,tbody,th,td,tr{display:block;}thead{display:none;}
        tr{background:#fff;border:1px solid #e8eef4;border-radius:12px;margin-bottom:.7rem;padding:.8rem 1rem;}
        td{padding:.25rem 0;border:none;font-size:.84rem;display:flex;align-items:center;gap:.4rem;}
        td::before{content:attr(data-label);font-size:.72rem;font-weight:600;color:#6b8aaa;text-transform:uppercase;min-width:70px;flex-shrink:0;}
    }
</style>
</head><body>
<div class="topbar">
    <a href="/CampusNav/main_admin.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:28px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div class="nav-right">
        <span style="color:rgba(255,255,255,.75);font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <span class="role-badge">운영관리자</span>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>
<div class="container-fluid page-wrap">

    <div class="hero-box mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <div class="hero-title">대학 자원 운영 관리 현황 📊</div>
                <div class="hero-desc">전체 자산 현황, 이관 이력, 폐기 내역을 한눈에 확인하고 관리하세요.</div>
                <form method="get" action="/CampusNav/search.jsp" class="mt-3">
                    <div class="search-row" style="max-width:520px">
                        <input type="text" name="keyword" placeholder="자산명, 위치, 자산번호 검색...">
                        <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
                    </div>
                </form>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0" style="position:relative;z-index:1">
                <span class="soft-tag"><i class="bi bi-shield-fill me-1"></i>운영관리자</span>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3"><div class="stat-card stat1"><div class="stat-label">전체 자산</div><div class="stat-value">8,401</div><div class="stat-desc">공기구비품 · 집기 · SW</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat2"><div class="stat-label">이관 이력</div><div class="stat-value">140건</div><div class="stat-desc">2025~2026년 자산 이관</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat3"><div class="stat-label">폐기 처리</div><div class="stat-value">2,721건</div><div class="stat-desc">25~26년 제각·폐기</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat4"><div class="stat-label">오늘 예약</div><div class="stat-value">0건</div><div class="stat-desc">실시간 예약 현황</div></div></div>
    </div>

    <div class="tab-row">
        <button class="tab-btn active" onclick="showTab('search',this)"><i class="bi bi-search me-1"></i>자원 검색</button>
        <button class="tab-btn" onclick="showTab('transfer',this)"><i class="bi bi-arrow-left-right me-1"></i>이관 등록</button>
        <button class="tab-btn" onclick="showTab('lifespan',this)"><i class="bi bi-calendar-x me-1"></i>내용연수</button>
        <button class="tab-btn" onclick="showTab('summary',this)"><i class="bi bi-bar-chart me-1"></i>통계 요약</button>
    </div>

    <div class="tab-content active" id="tab-search">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">전체 자원 검색</div>
                <div class="section-sub">자산번호, 품목명, 위치, 관리부서로 검색할 수 있습니다.</div>
                <a href="/CampusNav/search.jsp" class="btn-main"><i class="bi bi-search me-1"></i>전체 자원 검색 페이지로 이동</a>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-transfer">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">자산 이관 등록</div>
                <form>
                    <div class="row g-3">
                        <div class="col-md-6"><label class="f-label">이관 자산번호</label><input class="f-input" type="text" placeholder="예) 1702C0022"></div>
                        <div class="col-md-6"><label class="f-label">이관일자</label><input class="f-input" type="date"></div>
                        <div class="col-md-6"><label class="f-label">이관 전 관리부서</label><input class="f-input" type="text" placeholder="예) 경영기획팀"></div>
                        <div class="col-md-6"><label class="f-label">이관 전 위치</label><input class="f-input" type="text" placeholder="예) 대학본부 3층"></div>
                        <div class="col-md-6"><label class="f-label">이관 후 사용부서</label><input class="f-input" type="text" placeholder="예) 학사운영팀"></div>
                        <div class="col-md-6"><label class="f-label">이관 후 위치</label><input class="f-input" type="text" placeholder="예) 대학본부 1층"></div>
                        <div class="col-12"><label class="f-label">비고</label><input class="f-input" type="text" placeholder="이관 사유"></div>
                        <div class="col-12"><button type="button" class="btn-submit" onclick="alert('등록 완료!\n(프로토타입)')"><i class="bi bi-check-circle me-1"></i>이관 등록</button></div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-lifespan">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">내용연수 관리</div>
                <div class="section-sub">자산의 내용연수를 검색하고 수정할 수 있습니다.</div>
                <div class="alert-campus mb-3">
                    <i class="bi bi-info-circle me-2"></i>
                    자산을 검색한 후 상세 페이지에서 내용연수를 수정할 수 있습니다.
                </div>
                <a href="/CampusNav/search.jsp" class="btn-main"><i class="bi bi-search me-1"></i>자산 검색하기</a>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-summary">
        <div class="row g-3">
            <div class="col-xl-8">
                <div class="card-modern">
                    <div class="card-body">
                        <div class="section-title">자산 분류별 현황</div>
                        <div class="table-responsive">
                            <table class="table table-modern">
                                <thead><tr><th>자산 분류</th><th>전체</th><th>사용중</th><th>사용가능</th><th>비율</th></tr></thead>
                                <tbody>
                                    <tr><td><strong>공기구비품</strong></td><td>3,368</td><td>-</td><td>-</td><td><div style="background:#e0f2fe;border-radius:4px;height:8px"><div style="background:#0ea5e9;width:40%;height:100%;border-radius:4px"></div></div></td></tr>
                                    <tr><td><strong>집기비품</strong></td><td>4,737</td><td>-</td><td>-</td><td><div style="background:#dcfce7;border-radius:4px;height:8px"><div style="background:#16a34a;width:56%;height:100%;border-radius:4px"></div></div></td></tr>
                                    <tr><td><strong>무형고정자산</strong></td><td>296</td><td>-</td><td>-</td><td><div style="background:#f3edff;border-radius:4px;height:8px"><div style="background:#7c3aed;width:4%;height:100%;border-radius:4px"></div></div></td></tr>
                                </tbody>
                            </table>
                        </div>
                    </div>
                </div>
            </div>
            <div class="col-xl-4">
                <div class="card-modern">
                    <div class="card-body">
                        <div class="section-title">관리자 서비스 요약</div>
                        <ul class="list-group side-list">
                            <li class="list-group-item d-flex justify-content-between"><span>전체 자산</span><strong>8,401건</strong></li>
                            <li class="list-group-item d-flex justify-content-between"><span>이관 이력</span><strong>140건</strong></li>
                            <li class="list-group-item d-flex justify-content-between"><span>폐기 처리</span><strong>2,721건</strong></li>
                            <li class="list-group-item d-flex justify-content-between"><span>예약 현황</span><strong>0건</strong></li>
                        </ul>
                    </div>
                </div>
            </div>
        </div>
    </div>
</div>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showTab(name,btn){
    document.querySelectorAll('.tab-content').forEach(function(el){el.classList.remove('active');});
    document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
    document.getElementById('tab-'+name).classList.add('active');
    if(btn)btn.classList.add('active');
}
</script>
</body></html>