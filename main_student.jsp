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
    <title>ICT CampusNav — 학부생</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>
        body { background:linear-gradient(180deg,#f4f7fb 0%,#edf3f9 100%); font-family:'Noto Sans KR',sans-serif; color:#1f2937; min-height:100vh; }
        /* 네비바 */
        .topbar { background:linear-gradient(135deg,#0f172a 0%,#0f766e 100%); display:flex; align-items:center; justify-content:space-between; padding:.75rem 2rem; position:sticky; top:0; z-index:100; box-shadow:0 4px 16px rgba(15,23,42,.2); }
        .brand { font-size:1.1rem; font-weight:800; color:#fff; text-decoration:none; display:flex; align-items:center; gap:.6rem; }
        .brand span { color:#4ade80; }
        .nav-right { display:flex; align-items:center; gap:.75rem; }
        .role-badge { background:rgba(255,255,255,.15); border:1px solid rgba(255,255,255,.25); color:#fff; border-radius:999px; padding:.2rem .85rem; font-size:.78rem; font-weight:600; }
        .btn-out { background:rgba(255,255,255,.12); border:1px solid rgba(255,255,255,.2); color:#fff; border-radius:10px; font-size:.8rem; padding:.35rem .9rem; cursor:pointer; transition:all .2s; }
        .btn-out:hover { background:rgba(255,255,255,.22); color:#fff; }
        /* 페이지 */
        .page-wrap { max-width:1200px; margin:28px auto; padding:0 1.5rem; }
        /* 히어로 */
        .hero-box { background:linear-gradient(135deg,#0f172a 0%,#0f766e 48%,#22c55e 100%); color:white; border-radius:28px; padding:42px; box-shadow:0 18px 40px rgba(15,23,42,.16); position:relative; overflow:hidden; margin-bottom:1.5rem; }
        .hero-box::before { content:""; position:absolute; right:-60px; top:-50px; width:220px; height:220px; border-radius:50%; background:rgba(255,255,255,.08); }
        .hero-box::after  { content:""; position:absolute; left:-40px; bottom:-60px; width:180px; height:180px; border-radius:50%; background:rgba(255,255,255,.06); }
        .hero-title { font-size:1.8rem; font-weight:800; margin-bottom:10px; position:relative; z-index:1; }
        .hero-title em { color:#4ade80; font-style:normal; }
        .hero-desc  { font-size:.95rem; line-height:1.85; color:rgba(255,255,255,.92); position:relative; z-index:1; }
        /* 통계 카드 */
        .stat-card { border:none; border-radius:24px; padding:24px; color:white; min-height:140px; box-shadow:0 12px 26px rgba(15,23,42,.09); transition:transform .2s; }
        .stat-card:hover { transform:translateY(-4px); }
        .stat1{background:linear-gradient(135deg,#0ea5e9,#38bdf8);} .stat2{background:linear-gradient(135deg,#16a34a,#4ade80);}
        .stat3{background:linear-gradient(135deg,#7c3aed,#a78bfa);} .stat4{background:linear-gradient(135deg,#ea580c,#fb923c);}
        .stat-label{font-size:.92rem;opacity:.95;} .stat-value{font-size:2rem;font-weight:800;margin:10px 0 6px;} .stat-desc{font-size:.88rem;opacity:.92;}
        /* 카드 */
        .card-modern { border:none; border-radius:26px; background:rgba(255,255,255,.96); box-shadow:0 14px 35px rgba(15,23,42,.08); overflow:hidden; margin-bottom:1.5rem; }
        .card-modern .card-body { padding:28px; }
        .section-title { font-size:1.1rem; font-weight:800; color:#0f172a; margin-bottom:8px; }
        .section-sub { color:#64748b; font-size:.9rem; margin-bottom:16px; line-height:1.8; }
        /* 검색 */
        .search-row { display:flex; gap:.6rem; }
        .search-row input { flex:1; border:1.5px solid #e5e7eb; border-radius:12px; padding:.65rem 1rem; font-size:.9rem; outline:none; transition:border-color .2s; background:#fafafa; }
        .search-row input:focus { border-color:#0f766e; box-shadow:0 0 0 3px rgba(15,118,110,.12); }
        .btn-search { background:linear-gradient(135deg,#0f766e,#16a34a); border:none; border-radius:12px; color:#fff; font-weight:700; padding:.65rem 1.4rem; cursor:pointer; white-space:nowrap; }
        /* 테이블 */
        .table-modern thead th { background:#f7fcfb; color:#334155; border:none; font-weight:700; padding:14px 16px; font-size:.82rem; text-transform:uppercase; letter-spacing:.04em; }
        .table-modern tbody td { vertical-align:middle; padding:14px 16px; border-color:#f1f5f9; font-size:.88rem; }
        .table-modern tbody tr:hover td { background:#f8fbff; }
        /* 뱃지 */
        .badge-use  { background:#dcfce7; color:#16a34a; border-radius:999px; padding:.22rem .75rem; font-size:.76rem; font-weight:700; }
        .badge-busy { background:#fee2e2; color:#dc2626; border-radius:999px; padding:.22rem .75rem; font-size:.76rem; font-weight:700; }
        /* 버튼 */
        .btn-detail  { background:linear-gradient(135deg,#0f766e,#0ea5e9); color:#fff; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
        .btn-reserve { background:linear-gradient(135deg,#0f172a,#1e3a5f); color:#fff; border:none; border-radius:8px; padding:.3rem .85rem; font-size:.78rem; cursor:pointer; font-weight:600; }
        /* 카테고리 카드 */
        .cat-card { border:1px solid #edf2f7; border-radius:20px; padding:20px; background:#fff; text-align:center; text-decoration:none; color:#1f2937; transition:all .2s; display:block; }
        .cat-card:hover { box-shadow:0 10px 22px rgba(15,23,42,.08); transform:translateY(-3px); border-color:#0f766e; }
        .cat-card i { font-size:2rem; display:block; margin-bottom:.5rem; }
        .cat-card span { font-size:.88rem; font-weight:700; }
        /* 반응형 */
        @media(max-width:768px){
            .topbar{padding:.6rem 1rem;flex-wrap:wrap;gap:.4rem;} .page-wrap{padding:1rem;}
            .hero-box{padding:1.6rem 1.4rem;} .hero-title{font-size:1.3rem;}
            .search-row{flex-direction:column;} .btn-search{width:100%;}
            table,thead,tbody,th,td,tr{display:block;} thead{display:none;}
            tr{background:#fff;border:1px solid #e8eef4;border-radius:12px;margin-bottom:.7rem;padding:.8rem 1rem;}
            td{padding:.25rem 0;border:none;font-size:.84rem;display:flex;align-items:center;gap:.4rem;}
            td::before{content:attr(data-label);font-size:.72rem;font-weight:600;color:#6b8aaa;text-transform:uppercase;min-width:70px;flex-shrink:0;}
        }
    </style>
</head>
<body>

<!-- 네비바 -->
<div class="topbar">
    <a href="/CampusNav/main_student.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:28px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div class="nav-right">
        <span style="color:rgba(255,255,255,.75);font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <span class="role-badge">학부생</span>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="container-fluid page-wrap">

    <!-- 히어로 -->
    <div class="hero-box mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <div class="hero-title">안녕하세요, <em><%= loginName %></em>님 👋</div>
                <div class="hero-desc">강의실, 실험실, 장비 등 학교 자원을 검색하고 예약할 수 있습니다.</div>
                <form method="get" action="/CampusNav/search.jsp" class="mt-3">
                    <div class="search-row" style="max-width:520px">
                        <input type="text" name="keyword" placeholder="자원명, 위치, 번호 검색... (예: 공학관 301호, 노트북)">
                        <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
                    </div>
                </form>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0" style="position:relative;z-index:1">
                <span style="background:rgba(255,255,255,.14);border:1px solid rgba(255,255,255,.2);color:#fff;padding:8px 16px;border-radius:999px;font-size:.9rem">
                    <i class="bi bi-mortarboard me-1"></i>학부생
                </span>
            </div>
        </div>
    </div>

    <!-- 통계 -->
    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3">
            <div class="stat-card stat1">
                <div class="stat-label">전체 자산</div>
                <div class="stat-value">8,401</div>
                <div class="stat-desc">공기구비품 · 집기 · SW</div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card stat2">
                <div class="stat-label">사용 가능 자원</div>
                <div class="stat-value">검색</div>
                <div class="stat-desc">실시간 검색으로 확인</div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card stat3">
                <div class="stat-label">내 예약</div>
                <div class="stat-value">0건</div>
                <div class="stat-desc">예약 현황 확인</div>
            </div>
        </div>
        <div class="col-md-6 col-xl-3">
            <div class="stat-card stat4">
                <div class="stat-label">빠른 접근</div>
                <div class="stat-value">↓</div>
                <div class="stat-desc">카테고리별 바로 검색</div>
            </div>
        </div>
    </div>

    <!-- 자원 목록 -->
    <div class="card card-modern">
        <div class="card-body">
            <div class="section-title"><i class="bi bi-grid-3x3-gap me-2"></i>자원 목록</div>
            <div class="section-sub">자원을 클릭하여 상세 정보를 확인하거나 예약하세요.</div>
            <div class="table-responsive">
                <table class="table table-modern">
                    <thead>
                        <tr><th>번호</th><th>자원명</th><th>위치</th><th>활용여부</th><th>관리자</th><th>전화번호</th><th>상세/예약</th></tr>
                    </thead>
                    <tbody>
                        <tr>
                            <td data-label="번호">001</td>
                            <td data-label="자원명"><strong>노트북 Dell XPS</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>공학관 301호</a></td>
                            <td data-label="활용"><span class="badge-use">사용가능</span></td>
                            <td data-label="관리자">김조교</td>
                            <td data-label="전화">010-1234-5678</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=001'">상세</button>
                                <button class="btn-reserve" onclick="location.href='/CampusNav/reserve.jsp?id=001'">예약</button>
                            </td>
                        </tr>
                        <tr>
                            <td data-label="번호">002</td>
                            <td data-label="자원명"><strong>3D 프린터</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>공학관 205호</a></td>
                            <td data-label="활용"><span class="badge-busy">사용중</span></td>
                            <td data-label="관리자">이조교</td>
                            <td data-label="전화">010-2345-6789</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=002'">상세</button>
                                <button class="btn-reserve" disabled style="opacity:.4;background:#94a3b8;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;color:#fff">예약</button>
                            </td>
                        </tr>
                        <tr>
                            <td data-label="번호">003</td>
                            <td data-label="자원명"><strong>강의실 프로젝터</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>인문관 101호</a></td>
                            <td data-label="활용"><span class="badge-use">사용가능</span></td>
                            <td data-label="관리자">박관리</td>
                            <td data-label="전화">010-3456-7890</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=003'">상세</button>
                                <button class="btn-reserve" onclick="location.href='/CampusNav/reserve.jsp?id=003'">예약</button>
                            </td>
                        </tr>
                        <tr>
                            <td data-label="번호">004</td>
                            <td data-label="자원명"><strong>서버 랙 A</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>전산실 B01</a></td>
                            <td data-label="활용"><span class="badge-busy">사용중</span></td>
                            <td data-label="관리자">최조교</td>
                            <td data-label="전화">010-4567-8901</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=004'">상세</button>
                                <button class="btn-reserve" disabled style="opacity:.4;background:#94a3b8;border:none;border-radius:8px;padding:.3rem .85rem;font-size:.78rem;color:#fff">예약</button>
                            </td>
                        </tr>
                        <tr>
                            <td data-label="번호">005</td>
                            <td data-label="자원명"><strong>태블릿 iPad</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>도서관 2층</a></td>
                            <td data-label="활용"><span class="badge-use">사용가능</span></td>
                            <td data-label="관리자">정사서</td>
                            <td data-label="전화">010-5678-9012</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=005'">상세</button>
                                <button class="btn-reserve" onclick="location.href='/CampusNav/reserve.jsp?id=005'">예약</button>
                            </td>
                        </tr>
                        <tr>
                            <td data-label="번호">006</td>
                            <td data-label="자원명"><strong>세미나실</strong></td>
                            <td data-label="위치"><a href="#" style="color:#0f766e;text-decoration:none"><i class="bi bi-geo-alt me-1"></i>학생회관 305호</a></td>
                            <td data-label="활용"><span class="badge-use">사용가능</span></td>
                            <td data-label="관리자">한관리</td>
                            <td data-label="전화">010-6789-0123</td>
                            <td data-label="">
                                <button class="btn-detail me-1" onclick="location.href='/CampusNav/detail.jsp?id=006'">상세</button>
                                <button class="btn-reserve" onclick="location.href='/CampusNav/reserve.jsp?id=006'">예약</button>
                            </td>
                        </tr>
                    </tbody>
                </table>
            </div>
        </div>
    </div>

    <!-- 카테고리 바로가기 -->
    <div class="card card-modern">
        <div class="card-body">
            <div class="section-title"><i class="bi bi-bookmark me-2"></i>카테고리별 빠른 검색</div>
            <div class="row g-3">
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp?keyword=공기구비품" class="cat-card">
                        <i class="bi bi-tools" style="color:#0ea5e9"></i>
                        <span>공기구비품</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp?keyword=집기비품" class="cat-card">
                        <i class="bi bi-laptop" style="color:#16a34a"></i>
                        <span>집기비품</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp?keyword=소프트웨어" class="cat-card">
                        <i class="bi bi-code-square" style="color:#7c3aed"></i>
                        <span>소프트웨어</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp?keyword=공학관" class="cat-card">
                        <i class="bi bi-building" style="color:#ea580c"></i>
                        <span>공학관</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp?keyword=사용가능" class="cat-card">
                        <i class="bi bi-check-circle" style="color:#0f766e"></i>
                        <span>사용가능</span>
                    </a>
                </div>
                <div class="col-6 col-md-4 col-lg-2">
                    <a href="/CampusNav/search.jsp" class="cat-card">
                        <i class="bi bi-grid" style="color:#64748b"></i>
                        <span>전체보기</span>
                    </a>
                </div>
            </div>
        </div>
    </div>


    <!-- 빠른 이동 -->
    <div class="card-modern">
        <div class="card-body">
            <div class="section-title"><i class="bi bi-grid me-2"></i>빠른 이동</div>
            <div class="row g-2 mt-1">
                <div class="col-6 col-md-3">
                    <a href="/CampusNav/professor.jsp" style="display:block;background:linear-gradient(135deg,#0f766e,#22c55e);color:#fff;border-radius:14px;padding:14px;text-decoration:none;text-align:center;transition:opacity .2s">
                        <i class="bi bi-people-fill" style="font-size:1.4rem;display:block;margin-bottom:.4rem"></i>
                        <div style="font-size:.82rem;font-weight:700">교수 자원</div>
                    </a>
                </div>
                <div class="col-6 col-md-3">
                    <a href="/CampusNav/transfer.jsp" style="display:block;background:linear-gradient(135deg,#7c3aed,#a78bfa);color:#fff;border-radius:14px;padding:14px;text-decoration:none;text-align:center;transition:opacity .2s">
                        <i class="bi bi-arrow-left-right" style="font-size:1.4rem;display:block;margin-bottom:.4rem"></i>
                        <div style="font-size:.82rem;font-weight:700">이관내역</div>
                    </a>
                </div>
                <div class="col-6 col-md-3">
                    <a href="/CampusNav/search.jsp" style="display:block;background:linear-gradient(135deg,#0ea5e9,#38bdf8);color:#fff;border-radius:14px;padding:14px;text-decoration:none;text-align:center;transition:opacity .2s">
                        <i class="bi bi-search" style="font-size:1.4rem;display:block;margin-bottom:.4rem"></i>
                        <div style="font-size:.82rem;font-weight:700">자원 검색</div>
                    </a>
                </div>
                <div class="col-6 col-md-3">
                    <a href="/CampusNav/reserve.jsp" style="display:block;background:linear-gradient(135deg,#ea580c,#fb923c);color:#fff;border-radius:14px;padding:14px;text-decoration:none;text-align:center;transition:opacity .2s">
                        <i class="bi bi-calendar-check" style="font-size:1.4rem;display:block;margin-bottom:.4rem"></i>
                        <div style="font-size:.82rem;font-weight:700">예약</div>
                    </a>
                </div>
            </div>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
