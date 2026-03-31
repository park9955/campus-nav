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
    // 검색 파라미터
    String keyword  = request.getParameter("keyword");
    String type     = request.getParameter("type");
    String status   = request.getParameter("status");
    String location = request.getParameter("location");
    if (keyword  == null) keyword  = "";
    if (type     == null) type     = "";
    if (status   == null) status   = "";
    if (location == null) location = "";

    // 역할별 홈 링크
    String homeLink = "/main_student.jsp";
    if      ("assistant".equals(loginRole)) homeLink = "/main_assistant.jsp";
    else if ("professor".equals(loginRole)) homeLink = "/main_professor.jsp";
    else if ("admin".equals(loginRole))     homeLink = "/main_admin.jsp";
    else if ("guest".equals(loginRole))     homeLink = "/main_guest.jsp";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 자원 검색</title>
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
    <div class="nav-right">
        <a href="<%= request.getContextPath() + homeLink %>" class="btn-home">
            <i class="bi bi-house me-1"></i>홈
        </a>
        <span style="color:#8bacc8;font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="content">
  
        <!-- 모바일 필터 토글 버튼 -->
        <button class="filter-toggle" id="filterToggle"
                style="display:none;width:100%;margin-bottom:.8rem;padding:.65rem;
                       background:linear-gradient(135deg,#0f172a,#0f766e);border:1px solid rgba(0,194,168,.3);
                       border-radius:10px;color:#fff;font-size:.88rem;cursor:pointer;
                       align-items:center;justify-content:center;gap:.5rem;">
            <i class="bi bi-funnel"></i> 필터 열기/닫기
        </button>

        <div class="layout">

    <!-- 필터 사이드바 -->
    <aside>
      <div class="filter-box">
        <div class="filter-title"><i class="bi bi-funnel-fill" style="color:#0f766e"></i>필터</div>

        <form method="get" action="/CampusNav/search.jsp" id="filterForm">

          <div class="filter-section">
            <label>자원 유형</label>
            <select name="type">
              <option value="">전체</option>
              <option value="hardware"  <%= "hardware".equals(type)  ? "selected" : "" %>>하드웨어</option>
              <option value="software"  <%= "software".equals(type)  ? "selected" : "" %>>소프트웨어</option>
              <option value="room"      <%= "room".equals(type)      ? "selected" : "" %>>강의실/공간</option>
              <option value="equipment" <%= "equipment".equals(type) ? "selected" : "" %>>장비</option>
              <option value="etc"       <%= "etc".equals(type)       ? "selected" : "" %>>기타</option>
            </select>
          </div>

          <div class="filter-section">
            <label>활용여부</label>
            <div class="check-list">
              <label class="check-item">
                <input type="checkbox" name="status" value="available" <%= status.contains("available") ? "checked" : "" %>>
                사용가능
              </label>
              <label class="check-item">
                <input type="checkbox" name="status" value="busy" <%= status.contains("busy") ? "checked" : "" %>>
                사용중
              </label>
              <label class="check-item">
                <input type="checkbox" name="status" value="repair" <%= status.contains("repair") ? "checked" : "" %>>
                점검중
              </label>
            </div>
          </div>

          <div class="filter-section">
            <label>건물</label>
            <select name="location">
              <option value="">전체</option>
              <option value="eng"    <%= "eng".equals(location)    ? "selected" : "" %>>공학관</option>
              <option value="lib"    <%= "lib".equals(location)    ? "selected" : "" %>>도서관</option>
              <option value="hum"    <%= "hum".equals(location)    ? "selected" : "" %>>인문관</option>
              <option value="biz"    <%= "biz".equals(location)    ? "selected" : "" %>>경영관</option>
              <option value="server" <%= "server".equals(location) ? "selected" : "" %>>전산실</option>
              <option value="student"<%= "student".equals(location)? "selected" : "" %>>학생회관</option>
            </select>
          </div>

          <input type="hidden" name="keyword" id="hiddenKeyword" value="<%= keyword %>">

          <button type="submit" class="btn-filter"><i class="bi bi-funnel me-1"></i>필터 적용</button>
          <button type="button" class="btn-reset" onclick="resetFilter()"><i class="bi bi-arrow-counterclockwise me-1"></i>초기화</button>

        </form>
      </div>
    </aside>

    <!-- 결과 영역 -->
    <main>
      <div class="result-box">
        <div class="result-head">
          <span><i class="bi bi-grid-3x3-gap me-1"></i>자원 목록</span>
          <span class="result-count">총 6건 (샘플 데이터)</span>
        </div>

        <!-- 검색바 -->
        <div class="search-top">
          <form method="get" action="/CampusNav/search.jsp" class="search-row">
            <input type="hidden" name="type"     value="<%= type %>">
            <input type="hidden" name="status"   value="<%= status %>">
            <input type="hidden" name="location" value="<%= location %>">
            <input type="text" name="keyword" value="<%= keyword %>"
                   placeholder="자원명, 위치, 번호, 관리자명 검색...">
            <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
          </form>
        </div>

        <!-- 적용된 필터 태그 -->
        <% if (!keyword.isEmpty() || !type.isEmpty() || !status.isEmpty() || !location.isEmpty()) { %>
        <div class="tag-row">
          <% if (!keyword.isEmpty()) { %>
            <span class="tag"><i class="bi bi-search"></i>"<%= keyword %>" <button onclick="clearParam('keyword')">×</button></span>
          <% } %>
          <% if (!type.isEmpty()) { %>
            <span class="tag"><i class="bi bi-tag"></i><%= type %> <button onclick="clearParam('type')">×</button></span>
          <% } %>
          <% if (!status.isEmpty()) { %>
            <span class="tag"><i class="bi bi-circle-fill" style="font-size:.5rem"></i><%= status %> <button onclick="clearParam('status')">×</button></span>
          <% } %>
          <% if (!location.isEmpty()) { %>
            <span class="tag"><i class="bi bi-geo-alt"></i><%= location %> <button onclick="clearParam('location')">×</button></span>
          <% } %>
        </div>
        <% } %>

        <!-- 정렬 -->
        <div class="sort-row">
          <span class="sort-label">정렬:</span>
          <button class="sort-btn active">최신순</button>
          <button class="sort-btn">이름순</button>
          <button class="sort-btn">위치순</button>
          <button class="sort-btn">사용가능 우선</button>
        </div>

        <!-- 테이블 -->
        <table>
          <thead>
            <tr>
              <th>번호</th>
              <th>자원명</th>
              <th>유형</th>
              <th>위치 <small style="font-weight:400;color:#8bacc8">(클릭시 상세)</small></th>
              <th>활용여부</th>
              <th>관리자</th>
              <th>전화번호</th>
              <th>상세/예약</th>
            </tr>
          </thead>
          <tbody>
            <tr onclick="goDetail('001')">
              <td data-label="번호">001</td>
              <td data-label="자원명"><strong>노트북 Dell XPS</strong><br><small style="color:#6b8aaa">하드웨어</small></td>
              <td data-label="유형"><span style="background:#e0f2fe;color:#0284c7;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">HW</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 공학관 301호</a></td>
              <td data-label="활용"><span class="badge-use">사용가능</span></td>
              <td data-label="관리자">김조교</td><td>010-1234-5678</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('001')">상세</button>
                <button class="btn-reserve" onclick="goReserve('001')">예약</button>
              </td>
            </tr>
            <tr onclick="goDetail('002')">
              <td data-label="번호">002</td>
              <td data-label="자원명"><strong>3D 프린터</strong><br><small style="color:#6b8aaa">장비</small></td>
              <td data-label="유형"><span style="background:#fce7f3;color:#9d174d;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">장비</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 공학관 205호</a></td>
              <td data-label="활용"><span class="badge-busy">사용중</span></td>
              <td data-label="관리자">이조교</td><td>010-2345-6789</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('002')">상세</button>
                <button class="btn-reserve" disabled>예약</button>
              </td>
            </tr>
            <tr onclick="goDetail('003')">
              <td data-label="번호">003</td>
              <td data-label="자원명"><strong>강의실 프로젝터</strong><br><small style="color:#6b8aaa">장비</small></td>
              <td data-label="유형"><span style="background:#fce7f3;color:#9d174d;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">장비</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 인문관 101호</a></td>
              <td data-label="활용"><span class="badge-use">사용가능</span></td>
              <td data-label="관리자">박관리</td><td>010-3456-7890</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('003')">상세</button>
                <button class="btn-reserve" onclick="goReserve('003')">예약</button>
              </td>
            </tr>
            <tr onclick="goDetail('004')">
              <td data-label="번호">004</td>
              <td data-label="자원명"><strong>서버 랙 A</strong><br><small style="color:#6b8aaa">하드웨어</small></td>
              <td data-label="유형"><span style="background:#e0f2fe;color:#0284c7;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">HW</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 전산실 B01</a></td>
              <td data-label="활용"><span class="badge-fix">점검중</span></td>
              <td data-label="관리자">최조교</td><td>010-4567-8901</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('004')">상세</button>
                <button class="btn-reserve" disabled>예약</button>
              </td>
            </tr>
            <tr onclick="goDetail('005')">
              <td data-label="번호">005</td>
              <td data-label="자원명"><strong>MATLAB R2024</strong><br><small style="color:#6b8aaa">소프트웨어</small></td>
              <td data-label="유형"><span style="background:#ede9fe;color:#7c3aed;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">SW</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 공학관 401호</a></td>
              <td data-label="활용"><span class="badge-use">사용가능</span></td>
              <td data-label="관리자">이교수</td><td>010-5678-9012</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('005')">상세</button>
                <button class="btn-reserve" onclick="goReserve('005')">예약</button>
              </td>
            </tr>
            <tr onclick="goDetail('006')">
              <td data-label="번호">006</td>
              <td data-label="자원명"><strong>세미나실</strong><br><small style="color:#6b8aaa">강의실/공간</small></td>
              <td data-label="유형"><span style="background:#dcfce7;color:#16a34a;border-radius:5px;padding:.1rem .5rem;font-size:.74rem">공간</span></td>
              <td data-label="위치"><a class="loc-link" onclick="event.stopPropagation()"><i class="bi bi-geo-alt"></i> 학생회관 305호</a></td>
              <td data-label="활용"><span class="badge-use">사용가능</span></td>
              <td data-label="관리자">한관리</td><td>010-6789-0123</td>
              <td onclick="event.stopPropagation()">
                <button class="btn-detail me-1" onclick="goDetail('006')">상세</button>
                <button class="btn-reserve" onclick="goReserve('006')">예약</button>
              </td>
            </tr>
          </tbody>
        </table>

        <!-- 페이지네이션 -->
        <div class="pagination-wrap">
          <button class="pg-btn"><i class="bi bi-chevron-left"></i></button>
          <button class="pg-btn active">1</button>
          <button class="pg-btn">2</button>
          <button class="pg-btn">3</button>
          <button class="pg-btn"><i class="bi bi-chevron-right"></i></button>
        </div>
      </div>
    </main>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function goDetail(id) {
    location.href = '/CampusNav/detail.jsp?id=' + id;
}
function goReserve(id) {
    location.href = '/CampusNav/reserve.jsp?id=' + id;
}
function resetFilter() {
    location.href = '/CampusNav/search.jsp';
}
function clearParam(param) {
    var url = new URL(location.href);
    url.searchParams.delete(param);
    location.href = url.toString();
}
document.querySelectorAll('.sort-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.sort-btn').forEach(function(b){ b.classList.remove('active'); });
        this.classList.add('active');
    });
});

    // 모바일 필터 토글
    var filterToggle = document.getElementById('filterToggle');
    var filterBody   = document.querySelector('.filter-box');
    if (filterToggle && filterBody) {
        function checkMobile() {
            if (window.innerWidth <= 768) {
                filterToggle.style.display = 'flex';
                filterBody.classList.add('filter-body');
            } else {
                filterToggle.style.display = 'none';
                filterBody.classList.remove('filter-body');
                filterBody.classList.remove('open');
            }
        }
        checkMobile();
        window.addEventListener('resize', checkMobile);
        filterToggle.addEventListener('click', function() {
            filterBody.classList.toggle('open');
            this.innerHTML = filterBody.classList.contains('open')
                ? '<i class="bi bi-funnel-fill"></i> 필터 닫기'
                : '<i class="bi bi-funnel"></i> 필터 열기/닫기';
        });
    }

</script>
</body>
</html>
