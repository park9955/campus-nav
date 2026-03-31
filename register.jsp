<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    if (session.getAttribute("loginUser") != null) {
        response.sendRedirect("/CampusNav/campuslogin.jsp");
        return;
    }
    String errorMsg = (String) request.getAttribute("errorMsg");
    if (errorMsg == null) errorMsg = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 회원가입</title>
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
<div class="bg"></div>
<div class="ping"></div><div class="ping"></div>

<div class="wrap">
  <div class="card-box">
    <img src="/CampusNav/images/logo.png" alt="ICT" style="width:56px;height:56px;object-fit:contain;margin-bottom:1rem">
    <div class="brand-name">ICT Campus<span>Nav</span></div>
    <p class="brand-sub">교내 자원 내비게이션 시스템 &mdash; 회원가입</p>

    <% if (!errorMsg.isEmpty()) { %>
      <div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><span><%= errorMsg %></span></div>
    <% } %>

    <!-- 역할 선택 -->
    <p class="sec-label"><i class="bi bi-person-badge me-1"></i>역할 선택</p>
    <div class="role-grid">
      <label class="role-btn active" id="role-student">
        <input type="radio" name="roleDisplay" style="display:none" checked>
        <i class="bi bi-mortarboard-fill"></i>학부생
      </label>
      <label class="role-btn" id="role-assistant">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-workspace"></i>조교
      </label>
      <label class="role-btn" id="role-professor">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-badge-fill"></i>교수
      </label>
      <label class="role-btn" id="role-admin">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-shield-fill"></i>관리자
      </label>
      <label class="role-btn" id="role-guest">
        <input type="radio" name="roleDisplay" style="display:none">
        <i class="bi bi-person-fill"></i>외부인
      </label>
    </div>

    <form action="<%= request.getContextPath() %>/register" method="post" id="regForm">
      <input type="hidden" name="role" id="roleValue" value="student">

      <!-- 기본 정보 -->
      <p class="sec-label"><i class="bi bi-info-circle me-1"></i>기본 정보</p>
      <div class="row g-3 mb-1">
        <div class="col-12">
          <label class="f-label">학번 / 아이디 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-person"></i></span>
            <input class="f-input" type="text" name="userId" id="userId" placeholder="예) 20240001" required>
          </div>
        </div>
        <div class="col-12">
          <label class="f-label">이름 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-type"></i></span>
            <input class="f-input" type="text" name="userName" placeholder="실명 입력" required>
          </div>
        </div>
        <div class="col-12">
          <label class="f-label">이메일 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-envelope"></i></span>
            <input class="f-input" type="email" name="userEmail" placeholder="example@campus.ac.kr" required>
          </div>
        </div>
        <!-- 소속 (역할에 따라 라벨 변경) -->
        <div class="col-12">
          <label class="f-label" id="deptLabel">학과 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-building"></i></span>
            <input class="f-input" type="text" name="dept" id="deptInput" placeholder="예) 컴퓨터공학과" required>
          </div>
        </div>
        <!-- 학번 (학부생/조교만 표시) -->
        <div class="col-12" id="studentNumWrap">
          <label class="f-label">학번</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-hash"></i></span>
            <input class="f-input" type="text" name="studentNum" placeholder="예) 20240001">
          </div>
        </div>
      </div>

      <!-- 보안 -->
      <p class="sec-label"><i class="bi bi-shield-lock me-1"></i>보안</p>
      <div class="row g-3 mb-1">
        <div class="col-12">
          <label class="f-label">비밀번호 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-lock"></i></span>
            <input class="f-input" type="password" name="userPw" id="userPw"
                   placeholder="8자 이상, 영문+숫자 조합" required oninput="checkPw(this.value)">
          </div>
          <div class="pw-bar-wrap"><div class="pw-bar" id="pwBar"></div></div>
          <p class="pw-hint" id="pwHint">비밀번호를 입력하세요</p>
        </div>
        <div class="col-12">
          <label class="f-label">비밀번호 확인 *</label>
          <div class="input-row">
            <span class="ig-icon"><i class="bi bi-lock-fill"></i></span>
            <input class="f-input" type="password" name="userPw2" id="userPw2"
                   placeholder="비밀번호 재입력" required oninput="checkMatch()">
          </div>
          <p class="pw-hint" id="pwMatch"></p>
        </div>
      </div>

      <!-- 약관 -->
      <p class="sec-label"><i class="bi bi-file-text me-1"></i>이용약관</p>
      <div class="terms-box">
        CampusNav 서비스 이용약관 (프로토타입)<br>
        제1조. 본 서비스는 교내 자원 내비게이션 제공을 목적으로 합니다.<br>
        제2조. 수집되는 개인정보는 서비스 제공 목적으로만 사용됩니다.<br>
        제3조. 이용자는 타인의 계정을 도용해서는 안 됩니다.<br>
        제4조. 위치 정보는 캠퍼스 내 이동 안내에만 활용됩니다.
      </div>
      <div class="f-check mb-4">
        <input type="checkbox" id="agree" name="agree" required>
        <label for="agree">이용약관 및 개인정보 처리방침에 동의합니다 <span style="color:#0f766e">(필수)</span></label>
      </div>

      <button type="submit" class="btn-submit">
        <i class="bi bi-person-check me-1"></i>가입하기
      </button>
      <a href="/CampusNav/campuslogin.jsp" class="btn-back">
        <i class="bi bi-arrow-left me-1"></i>로그인으로 돌아가기
      </a>
    </form>

    <p class="foot">재학생·교직원 전용 서비스 &nbsp;|&nbsp;
      <a href="mailto:support@campus.ac.kr">support@campus.ac.kr</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
var roleConfig = {
    student:   { dept:'학과 *',   showStudentNum:true  },
    assistant: { dept:'학과 *',   showStudentNum:true  },
    professor: { dept:'소속 학과 *', showStudentNum:false },
    admin:     { dept:'소속 부서 *', showStudentNum:false },
    guest:     { dept:'소속 기관',   showStudentNum:false }
};

document.querySelectorAll('.role-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
        document.querySelectorAll('.role-btn').forEach(function(b){ b.classList.remove('active'); });
        this.classList.add('active');
        var role = this.id.replace('role-','');
        document.getElementById('roleValue').value = role;
        var cfg = roleConfig[role];
        document.getElementById('deptLabel').textContent = cfg.dept;
        document.getElementById('studentNumWrap').style.display = cfg.showStudentNum ? '' : 'none';
    });
});

function checkPw(v) {
    var bar = document.getElementById('pwBar');
    var hint = document.getElementById('pwHint');
    if (!v) { bar.style.width='0'; hint.textContent='비밀번호를 입력하세요'; hint.style.color=''; return; }
    var score = 0;
    if (v.length >= 8) score++;
    if (/[A-Za-z]/.test(v)) score++;
    if (/[0-9]/.test(v)) score++;
    if (/[^A-Za-z0-9]/.test(v)) score++;
    var colors = ['#ff4d4d','#ff944d','#f0c040','#00c2a8'];
    var labels = ['매우 약함','보통','강함','매우 강함'];
    var pcts   = ['25%','50%','75%','100%'];
    var i = Math.max(0, score-1);
    bar.style.width = pcts[i]; bar.style.background = colors[i];
    hint.textContent = '강도: ' + labels[i]; hint.style.color = colors[i];
}

function checkMatch() {
    var m = document.getElementById('pwMatch');
    var pw = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;
    if (!pw2) { m.textContent=''; return; }
    if (pw === pw2) { m.textContent='✓ 비밀번호가 일치합니다'; m.style.color='#00c2a8'; }
    else            { m.textContent='✗ 비밀번호가 일치하지 않습니다'; m.style.color='#ff8a9a'; }
}

document.getElementById('regForm').addEventListener('submit', function(e) {
    if (!document.getElementById('agree').checked) {
        e.preventDefault(); alert('이용약관에 동의해 주세요.'); return;
    }
    var pw  = document.getElementById('userPw').value;
    var pw2 = document.getElementById('userPw2').value;
    if (pw.length < 8) { e.preventDefault(); alert('비밀번호는 8자 이상이어야 합니다.'); return; }
    if (pw !== pw2)    { e.preventDefault(); alert('비밀번호가 일치하지 않습니다.'); return; }
});
</script>
</body>
</html>
