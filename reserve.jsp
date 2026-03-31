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
    // 외부인 접근 차단
    if ("guest".equals(loginRole)) {
        response.sendRedirect("/CampusNav/main_guest.jsp");
        return;
    }
    String id = request.getParameter("id");
    if (id == null) id = "001";
    String homeLink = "/main_student.jsp";
    if      ("assistant".equals(loginRole)) homeLink = "/main_assistant.jsp";
    else if ("professor".equals(loginRole)) homeLink = "/main_professor.jsp";
    else if ("admin".equals(loginRole))     homeLink = "/main_admin.jsp";

    String msg = (String) request.getAttribute("msg");
    if (msg == null) msg = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 예약</title>
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
        <a href="/CampusNav/detail.jsp?id=<%= id %>">상세보기</a>
        <i class="bi bi-chevron-right" style="font-size:.7rem"></i>
        <span>예약</span>
    </div>

    <!-- 자원 요약 -->
    <div class="res-summary">
        <div class="res-icon"><i class="bi bi-laptop"></i></div>
        <div class="res-info">
            <h3>노트북 Dell XPS 15 <small style="font-size:.75rem;opacity:.6">#<%= id %></small></h3>
            <p><i class="bi bi-geo-alt me-1"></i>공학관 301호 &nbsp;·&nbsp; 관리자: 김조교 &nbsp;·&nbsp; 010-1234-5678</p>
        </div>
        <span class="badge-use ms-auto">사용가능</span>
    </div>

    <!-- 완료 메시지 (예약 후 표시) -->
    <div class="success-box" id="successBox">
        <i class="bi bi-check-circle-fill"></i>
        <h3>예약이 완료됐습니다!</h3>
        <p>예약 확인 이메일이 발송됩니다.</p>
        <button class="btn-submit mt-3" style="max-width:200px;margin:1rem auto 0"
                onclick="location.href='<%= request.getContextPath() + homeLink %>'">
            홈으로 돌아가기
        </button>
    </div>

    <!-- 예약 폼 -->
    <div id="formWrap">
        <div class="form-card">
            <div class="form-head"><i class="bi bi-calendar-plus"></i> 예약 정보 입력</div>
            <div class="form-body">
                <form id="reserveForm">
                    <input type="hidden" name="resourceId" value="<%= id %>">
                    <div class="row g-3">
                        <!-- 예약자 정보 -->
                        <div class="col-md-6">
                            <label class="f-label">예약자</label>
                            <input class="f-input" type="text" value="<%= loginName %>" readonly
                                   style="background:#f8fafc;color:#6b8aaa">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">연락처</label>
                            <input class="f-input" type="text" name="phone" placeholder="010-0000-0000" required>
                        </div>
                        <!-- 사용 목적 -->
                        <div class="col-12">
                            <label class="f-label">사용 목적 *</label>
                            <select class="f-select" name="purpose">
                                <option value="">선택하세요</option>
                                <option>수업/강의</option>
                                <option>연구/프로젝트</option>
                                <option>개인 실습</option>
                                <option>팀 프로젝트</option>
                                <option>기타</option>
                            </select>
                        </div>
                        <!-- 날짜 -->
                        <div class="col-12">
                            <label class="f-label">예약 날짜 *</label>
                            <input class="f-input" type="date" name="date" id="resDate"
                                   min="2026-03-20" required onchange="updateSchedule(this.value)">
                        </div>
                        <!-- 시간 -->
                        <div class="col-12">
                            <label class="f-label">사용 시간 *</label>
                            <div class="time-row">
                                <select class="f-select" name="startTime">
                                    <option>09:00</option><option>10:00</option><option>11:00</option>
                                    <option>12:00</option><option>13:00</option><option>14:00</option>
                                    <option>15:00</option><option>16:00</option><option>17:00</option>
                                </select>
                                <span class="time-sep">~</span>
                                <select class="f-select" name="endTime">
                                    <option>10:00</option><option>11:00</option><option>12:00</option>
                                    <option>13:00</option><option>14:00</option><option>15:00</option>
                                    <option>16:00</option><option>17:00</option><option>18:00</option>
                                </select>
                            </div>
                        </div>
                        <!-- 비고 -->
                        <div class="col-12">
                            <label class="f-label">비고</label>
                            <textarea class="f-input" name="note" rows="2" placeholder="추가 요청사항을 입력하세요"></textarea>
                        </div>
                    </div>
                </form>
            </div>
        </div>

        <!-- 해당 날짜 예약 현황 -->
        <div class="form-card">
            <div class="form-head"><i class="bi bi-clock"></i> 당일 예약 현황 <span style="font-weight:400;font-size:.78rem;color:#8bacc8;margin-left:auto" id="scheduleDate">날짜를 선택하세요</span></div>
            <div class="form-body" id="scheduleBody">
                <div style="text-align:center;color:#6b8aaa;padding:1rem;font-size:.84rem">
                    <i class="bi bi-calendar2" style="font-size:1.5rem;display:block;margin-bottom:.4rem;opacity:.4"></i>
                    날짜를 선택하면 예약 현황을 확인할 수 있습니다
                </div>
            </div>
        </div>

        <!-- 주의사항 -->
        <div class="agree-box">
            <i class="bi bi-info-circle-fill" style="flex-shrink:0;margin-top:.1rem"></i>
            <div>
                <strong>예약 이용 안내</strong><br>
                · 예약 후 무단 미사용 시 다음 예약이 제한될 수 있습니다.<br>
                · 사용 종료 후 반드시 원래 상태로 정리해 주세요.<br>
                · 문의: 담당 관리자 김조교 (010-1234-5678)
            </div>
        </div>

        <div class="f-check mb-4">
            <input type="checkbox" id="agreeReserve">
            <label for="agreeReserve">이용 안내를 확인하였으며 예약 규정에 동의합니다</label>
        </div>

        <div class="action-row">
            <button class="btn-cancel" onclick="history.back()">
                <i class="bi bi-arrow-left me-1"></i>취소
            </button>
            <button class="btn-submit" onclick="submitReserve()">
                <i class="bi bi-calendar-check me-1"></i>예약 확정
            </button>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
// 날짜 선택 시 예약 현황 업데이트 (프로토타입: 샘플 데이터)
function updateSchedule(date) {
    var label = document.getElementById('scheduleDate');
    var body  = document.getElementById('scheduleBody');
    if (!date) return;
    label.textContent = date;
    body.innerHTML =
        '<div class="schedule-item">' +
        '  <span class="sch-time">09:00 ~ 11:00</span>' +
        '  <div class="sch-bar"></div>' +
        '  <span class="sch-user">이철수 (학부생)</span>' +
        '</div>' +
        '<div class="schedule-item">' +
        '  <span class="sch-time">14:00 ~ 16:00</span>' +
        '  <div class="sch-bar"></div>' +
        '  <span class="sch-user">박영희 (조교)</span>' +
        '</div>' +
        '<div style="font-size:.78rem;color:#16a34a;margin-top:.6rem">' +
        '  <i class="bi bi-check-circle me-1"></i>09:00~09:00, 11:00~14:00, 16:00~18:00 예약 가능' +
        '</div>';
}

// 예약 제출 (프로토타입: 실제 DB 저장 없음)
function submitReserve() {
    if (!document.getElementById('agreeReserve').checked) {
        alert('이용 안내에 동의해 주세요.');
        return;
    }
    var date = document.getElementById('resDate').value;
    if (!date) { alert('예약 날짜를 선택해 주세요.'); return; }
    document.getElementById('formWrap').style.display = 'none';
    document.getElementById('successBox').style.display = 'block';
    window.scrollTo(0,0);
}

// ── 예약 시간 중복 체크 ──
var existingReservations = [
    { date:'2026-04-01', start:'09:00', end:'11:00', user:'홍길동' },
    { date:'2026-04-01', start:'14:00', end:'16:00', user:'이철수' },
    { date:'2026-04-02', start:'10:00', end:'12:00', user:'박영희' }
];

function checkTimeConflict() {
    var dateEl  = document.getElementById('date') || document.querySelector('input[type=date]');
    var startEl = document.getElementById('startTime') || document.querySelector('input[name=startTime]');
    var endEl   = document.getElementById('endTime')   || document.querySelector('input[name=endTime]');
    if (!dateEl || !startEl || !endEl) return;
    var date  = dateEl.value;
    var start = startEl.value;
    var end   = endEl.value;
    if (!date || !start || !end) return;

    var msgEl = document.getElementById('timeCheckMsg');
    if (!msgEl) {
        msgEl = document.createElement('div');
        msgEl.id = 'timeCheckMsg';
        msgEl.style.cssText = 'margin-top:.6rem;padding:.65rem 1rem;border-radius:12px;font-size:.86rem;font-weight:600';
        endEl.parentElement.after(msgEl);
    }

    var conflict = null;
    for (var i=0; i<existingReservations.length; i++) {
        var r = existingReservations[i];
        if (r.date === date) {
            // 시간 겹침 체크
            if (start < r.end && end > r.start) {
                conflict = r;
                break;
            }
        }
    }

    if (conflict) {
        msgEl.style.background = '#fef2f2';
        msgEl.style.border = '1px solid #fecaca';
        msgEl.style.color = '#dc2626';
        msgEl.innerHTML = '<i class="bi bi-x-circle-fill me-1"></i>'
            + '이미 예약된 시간입니다. <strong>' + conflict.start + ' ~ ' + conflict.end + '</strong> ('
            + conflict.user + ' 예약 중) 다른 시간을 선택해 주세요.';
    } else if (date && start && end) {
        msgEl.style.background = '#f0fdf4';
        msgEl.style.border = '1px solid #bbf7d0';
        msgEl.style.color = '#16a34a';
        msgEl.innerHTML = '<i class="bi bi-check-circle-fill me-1"></i>예약 가능한 시간입니다!';
    }
}

// 날짜/시간 변경 시 자동 체크
document.addEventListener('DOMContentLoaded', function() {
    ['date','startTime','endTime'].forEach(function(id) {
        var el = document.getElementById(id);
        if (el) el.addEventListener('change', checkTimeConflict);
    });
    document.querySelectorAll('input[type=date], input[name=startTime], input[name=endTime]')
        .forEach(function(el){ el.addEventListener('change', checkTimeConflict); });
});
</script>
</body>
</html>
