<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");
    if (loginUser == null) {
        response.sendRedirect("/CampusNav/campuslogin.jsp");
        return;
    }
    String id = request.getParameter("id");
    if (id == null) id = "001";
    // 역할별 홈 링크
    String homeLink = "/main_student.jsp";
    if      ("assistant".equals(loginRole)) homeLink = "/main_assistant.jsp";
    else if ("professor".equals(loginRole)) homeLink = "/main_professor.jsp";
    else if ("admin".equals(loginRole))     homeLink = "/main_admin.jsp";
    else if ("guest".equals(loginRole))     homeLink = "/main_guest.jsp";
    // 외부인은 예약 불가
    boolean canReserve = !"guest".equals(loginRole);
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 자원 상세</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700&display=swap" rel="stylesheet">
    <style>
    /* ── 새 UI 공통 스타일 ── */
    body { background: linear-gradient(180deg,#f4f7fb 0%,#edf3f9 100%); font-family: "Noto Sans KR",sans-serif; color:#1f2937; min-height:100vh; }
    /* 네비바 */
    .topbar { background:linear-gradient(135deg,#0f172a 0%,#0f766e 100%); display:flex; align-items:center; justify-content:space-between; padding:.8rem 2rem; box-shadow:0 4px 16px rgba(15,23,42,.18); position:sticky; top:0; z-index:100; }
    .brand { font-family:"Noto Sans KR",sans-serif; font-size:1.1rem; font-weight:800; color:#fff; text-decoration:none; display:flex; align-items:center; gap:.6rem; }
    .brand span { color:#4ade80; }
    .user-info,.nav-right { display:flex; align-items:center; gap:.75rem; }
    .role-badge { background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.25); color:#fff; border-radius:999px; padding:.2rem .85rem; font-size:.78rem; font-weight:600; }
    .btn-out { background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.2); color:#fff; border-radius:10px; font-size:.8rem; padding:.35rem .9rem; cursor:pointer; transition:all .2s; text-decoration:none; display:inline-block; }
    .btn-out:hover { background:rgba(255,255,255,.22); color:#fff; }
    /* 컨텐츠 */
    .content,.main-wrap,.page-wrap { max-width:1200px; margin:28px auto; padding:0 1.5rem; }
    /* 히어로 */
    .welcome-card,.hero-box { background:linear-gradient(135deg,#0f172a 0%,#0f766e 48%,#22c55e 100%); color:white; border-radius:26px; padding:36px 40px; box-shadow:0 18px 40px rgba(15,23,42,.16); position:relative; overflow:hidden; margin-bottom:1.5rem; }
    .welcome-card::before,.hero-box::before { content:""; position:absolute; right:-60px; top:-50px; width:200px; height:200px; border-radius:50%; background:rgba(255,255,255,.08); }
    .welcome-card h2,.hero-title { font-size:1.7rem; font-weight:800; margin-bottom:.4rem; position:relative; z-index:1; color:#fff; }
    .welcome-card h2 em { color:#4ade80; font-style:normal; }
    .welcome-card p,.hero-desc { color:rgba(255,255,255,.88); font-size:.92rem; margin:0; position:relative; z-index:1; line-height:1.8; }
    /* 검색 */
    .search-card { background:#fff; border-radius:20px; padding:1.6rem; box-shadow:0 8px 24px rgba(15,23,42,.07); margin-bottom:1.5rem; }
    .search-card h5 { font-size:.82rem; font-weight:700; color:#374151; text-transform:uppercase; letter-spacing:.06em; margin-bottom:1rem; }
    .search-row { display:flex; gap:.6rem; }
    .search-row input { flex:1; border:1.5px solid #e5e7eb; border-radius:12px; padding:.65rem 1rem; font-size:.9rem; outline:none; transition:border-color .2s,box-shadow .2s; background:#fafafa; }
    .search-row input:focus { border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,.12); background:#fff; }
    .btn-search { background:linear-gradient(135deg,#0f766e,#16a34a); border:none; border-radius:12px; color:#fff; font-weight:700; padding:.65rem 1.4rem; cursor:pointer; font-size:.9rem; white-space:nowrap; }
    /* 카드 */
    .table-card,.card-box { background:#fff; border-radius:22px; box-shadow:0 8px 28px rgba(15,23,42,.08); overflow:hidden; margin-bottom:1.5rem; }
    .card-head { background:linear-gradient(135deg,#0f172a,#0f766e); color:#fff; padding:1rem 1.4rem; font-size:.88rem; font-weight:700; display:flex; align-items:center; gap:.5rem; }
    /* 테이블 */
    table { width:100%; border-collapse:collapse; }
    th { background:#f8fafc; font-size:.76rem; font-weight:700; color:#475569; text-transform:uppercase; letter-spacing:.05em; padding:.85rem 1rem; border-bottom:1.5px solid #e8eef4; }
    td { padding:.85rem 1rem; font-size:.88rem; border-bottom:1px solid #f1f5f9; vertical-align:middle; }
    tr:last-child td { border-bottom:none; }
    tr:hover td { background:#f8fbff; }
    /* 뱃지 */
    .badge-use  { background:#dcfce7; color:#16a34a; border-radius:999px; padding:.22rem .75rem; font-size:.76rem; font-weight:700; }
    .badge-busy { background:#fee2e2; color:#dc2626; border-radius:999px; padding:.22rem .75rem; font-size:.76rem; font-weight:700; }
    .badge-fix  { background:#fef9c3; color:#ca8a04; border-radius:999px; padding:.22rem .75rem; font-size:.76rem; font-weight:700; }
    /* 버튼 */
    .btn-detail  { background:linear-gradient(135deg,#0f766e,#0ea5e9); color:#fff; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
    .btn-reserve { background:linear-gradient(135deg,#0f172a,#1e3a5f); color:#fff; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
    .btn-edit    { background:#e0f2fe; color:#0284c7; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
    .btn-del     { background:#fee2e2; color:#dc2626; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
    .btn-submit  { background:linear-gradient(135deg,#0f766e,#16a34a); color:#fff; border:none; border-radius:12px; padding:.7rem 1.8rem; font-size:.92rem; font-weight:700; cursor:pointer; width:100%; margin-top:.5rem; }
    /* 통계 */
    .stat-grid { display:grid; grid-template-columns:repeat(4,1fr); gap:1rem; margin-bottom:1.5rem; }
    .stat-card { border-radius:20px; padding:22px; color:white; box-shadow:0 10px 24px rgba(15,23,42,.1); transition:transform .2s; }
    .stat-card:hover { transform:translateY(-3px); }
    .stat1{background:linear-gradient(135deg,#0ea5e9,#38bdf8);} .stat2{background:linear-gradient(135deg,#16a34a,#4ade80);}
    .stat3{background:linear-gradient(135deg,#7c3aed,#a78bfa);} .stat4{background:linear-gradient(135deg,#ea580c,#fb923c);}
    .stat-label{font-size:.88rem;opacity:.95;} .stat-num{font-size:1.9rem;font-weight:800;margin:8px 0 4px;} .stat-desc{font-size:.82rem;opacity:.9;}
    /* 탭 */
    .tab-row { display:flex; gap:.5rem; margin-bottom:1.2rem; flex-wrap:wrap; }
    .tab-btn { padding:.55rem 1.2rem; border-radius:12px; border:1.5px solid #e5e7eb; background:#fff; color:#64748b; font-size:.85rem; font-weight:600; cursor:pointer; transition:all .2s; }
    .tab-btn.active { background:linear-gradient(135deg,#0f766e,#16a34a); color:#fff; border-color:transparent; }
    .tab-btn:hover:not(.active) { border-color:#0f766e; color:#0f766e; }
    .tab-content { display:none; } .tab-content.active { display:block; }
    /* 폼 */
    .f-label { font-size:.78rem; font-weight:700; color:#374151; text-transform:uppercase; letter-spacing:.05em; display:block; margin-bottom:.4rem; }
    .f-input { width:100%; border:1.5px solid #e5e7eb; border-radius:12px; padding:.65rem 1rem; font-size:.9rem; outline:none; transition:border-color .2s; background:#fafafa; color:#1f2937; }
    .f-input:focus { border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,.12); background:#fff; }
    .f-select { width:100%; border:1.5px solid #e5e7eb; border-radius:12px; padding:.65rem 1rem; font-size:.9rem; outline:none; background:#fafafa; }
    /* 반응형 */
    @media(max-width:768px){
        .topbar{padding:.6rem 1rem;flex-wrap:wrap;gap:.4rem;} .content,.main-wrap,.page-wrap{padding:1rem;}
        .welcome-card,.hero-box{padding:1.4rem 1.2rem;} .welcome-card h2,.hero-title{font-size:1.2rem;}
        .search-row{flex-direction:column;} .btn-search{width:100%;}
        .stat-grid{grid-template-columns:1fr 1fr;}
        table,thead,tbody,th,td,tr{display:block;} thead{display:none;}
        tr{background:#fff;border:1px solid #e8eef4;border-radius:12px;margin-bottom:.7rem;padding:.8rem 1rem;box-shadow:0 1px 4px rgba(0,0,0,.06);}
        td{padding:.25rem 0;border:none;font-size:.84rem;display:flex;align-items:center;gap:.4rem;}
        td::before{content:attr(data-label);font-size:.72rem;font-weight:600;color:#6b8aaa;text-transform:uppercase;min-width:70px;flex-shrink:0;}
        td:last-child{margin-top:.4rem;gap:.4rem;justify-content:flex-end;}
        .tab-btn{font-size:.78rem;padding:.45rem .8rem;flex:1;text-align:center;}
    }
    @media(max-width:480px){ .stat-grid{grid-template-columns:1fr 1fr;} }

</style>
</head>
<body>
<div class="topbar">
    <a href="/CampusNav/main_student.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:30px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div style="display:flex;align-items:center;gap:.75rem">
        <a href="<%= request.getContextPath() + homeLink %>" class="btn-home"><i class="bi bi-house me-1"></i>홈</a>
        <span style="color:#8bacc8;font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="content">
    <!-- 브레드크럼 -->
    <div class="breadcrumb-row">
        <a href="<%= request.getContextPath() + homeLink %>">홈</a>
        <i class="bi bi-chevron-right" style="font-size:.7rem"></i>
        <a href="/CampusNav/search.jsp">자원 검색</a>
        <i class="bi bi-chevron-right" style="font-size:.7rem"></i>
        <span>자원 상세 (#<%= id %>)</span>
    </div>

    <!-- 헤더 -->
    <div class="detail-header">
        <div class="left">
            <h2>노트북 Dell XPS 15</h2>
            <div style="font-size:.84rem;color:#8bacc8;margin-top:.2rem">자원번호: <%= id %></div>
            <div class="meta">
                <span class="tag tag-hw">하드웨어</span>
                <span class="badge-use">사용가능</span>
            </div>
        </div>
        <div class="right">
            <div style="font-size:.78rem;color:#8bacc8">등록일</div>
            <div style="font-size:.9rem;color:#fff">2023-09-01</div>
            <div style="font-size:.78rem;color:#8bacc8;margin-top:.4rem">관리자</div>
            <div style="font-size:.9rem;color:#0f766e">김조교 · 010-1234-5678</div>
        </div>
    </div>

    <div class="row g-3">
        <!-- 위치 정보 -->
        <div class="col-12">
            <div class="sec-card">
                <h5><i class="bi bi-geo-alt-fill"></i>위치 정보</h5>
                <div class="loc-box">
                    <div class="loc-icon"><i class="bi bi-geo-alt-fill"></i></div>
                    <div class="loc-info">
                        <div class="building">공학관 (Engineering Hall)</div>
                        <div class="room">301호 · 3층 강의실</div>
                        <div class="coords">위도: 37.5512° N &nbsp;|&nbsp; 경도: 126.9882° E &nbsp;|&nbsp; 3층 301호</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 기본 정보 -->
        <div class="col-md-6">
            <div class="sec-card">
                <h5><i class="bi bi-info-circle"></i>기본 정보</h5>
                <div class="info-grid">
                    <div class="info-item">
                        <div class="lbl">자원명</div>
                        <div class="val">노트북 Dell XPS 15</div>
                    </div>
                    <div class="info-item">
                        <div class="lbl">자원 유형</div>
                        <div class="val">하드웨어</div>
                    </div>
                    <div class="info-item">
                        <div class="lbl">활용여부</div>
                        <div class="val"><span class="badge-use">사용가능</span></div>
                    </div>
                    <div class="info-item">
                        <div class="lbl">취득일</div>
                        <div class="val">2023-09-01</div>
                    </div>
                    <div class="info-item">
                        <div class="lbl">내용연수</div>
                        <div class="val">5년 (2028-09-01)</div>
                    </div>
                    <div class="info-item">
                        <div class="lbl">관리자</div>
                        <div class="val">김조교</div>
                    </div>
                </div>
            </div>
        </div>

        <!-- 하드웨어 스펙 -->
        <div class="col-md-6">
            <div class="sec-card">
                <h5><i class="bi bi-cpu"></i>하드웨어 스펙</h5>
                <table class="spec-table">
                    <tr><td>CPU</td><td>Intel Core i7-12세대</td></tr>
                    <tr><td>RAM</td><td>16GB DDR5</td></tr>
                    <tr><td>저장장치</td><td>SSD 512GB NVMe</td></tr>
                    <tr><td>GPU</td><td>NVIDIA RTX 3050 Ti</td></tr>
                    <tr><td>OS</td><td>Windows 11 Pro</td></tr>
                    <tr><td>화면</td><td>15.6인치 FHD IPS</td></tr>
                </table>
            </div>
        </div>

        <!-- 설치 소프트웨어 -->
        <div class="col-md-6">
            <div class="sec-card">
                <h5><i class="bi bi-laptop"></i>설치 소프트웨어</h5>
                <div style="display:flex;flex-wrap:wrap;gap:.4rem">
                    <span style="background:#ede9fe;color:#7c3aed;border-radius:6px;padding:.25rem .7rem;font-size:.8rem">MATLAB R2024b</span>
                    <span style="background:#ede9fe;color:#7c3aed;border-radius:6px;padding:.25rem .7rem;font-size:.8rem">AutoCAD 2024</span>
                    <span style="background:#ede9fe;color:#7c3aed;border-radius:6px;padding:.25rem .7rem;font-size:.8rem">MS Office 365</span>
                    <span style="background:#ede9fe;color:#7c3aed;border-radius:6px;padding:.25rem .7rem;font-size:.8rem">Python 3.11</span>
                    <span style="background:#ede9fe;color:#7c3aed;border-radius:6px;padding:.25rem .7rem;font-size:.8rem">VS Code</span>
                </div>
            </div>
        </div>

        <!-- 이용 이력 -->
        <div class="col-md-6">
            <div class="sec-card">
                <h5><i class="bi bi-clock-history"></i>최근 이용 이력</h5>
                <div class="history-item">
                    <div class="h-dot done"></div>
                    <div class="h-date">2026-03-18</div>
                    <div>
                        <div class="h-user">홍길동 (학부생)</div>
                        <div class="h-purpose">캡스톤 프로젝트 작업</div>
                    </div>
                </div>
                <div class="history-item">
                    <div class="h-dot done"></div>
                    <div class="h-date">2026-03-15</div>
                    <div>
                        <div class="h-user">이철수 (학부생)</div>
                        <div class="h-purpose">MATLAB 실습</div>
                    </div>
                </div>
                <div class="history-item">
                    <div class="h-dot done"></div>
                    <div class="h-date">2026-03-12</div>
                    <div>
                        <div class="h-user">박영희 (조교)</div>
                        <div class="h-purpose">강의 준비</div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <!-- 하단 버튼 -->
    <div class="action-row mt-3">
        <button class="btn-back-btn" onclick="history.back()">
            <i class="bi bi-arrow-left me-1"></i>돌아가기
        </button>
        <% if (canReserve) { %>
        <button class="btn-reserve"
                onclick="location.href='/CampusNav/reserve.jsp?id=<%= id %>'">
            <i class="bi bi-calendar-plus me-1"></i>이 자원 예약하기
        </button>
        <% } else { %>
        <button class="btn-reserve" disabled style="opacity:.4;flex:1">
            <i class="bi bi-lock me-1"></i>외부인은 예약 불가
        </button>
        <% } %>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
