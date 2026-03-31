<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    if (session.getAttribute("loginUser") != null) {
        String role = (String) session.getAttribute("loginRole");
        if      ("student".equals(role))   response.sendRedirect("/CampusNav/main_student.jsp");
        else if ("assistant".equals(role)) response.sendRedirect("/CampusNav/main_assistant.jsp");
        else if ("professor".equals(role)) response.sendRedirect("/CampusNav/main_professor.jsp");
        else if ("admin".equals(role))     response.sendRedirect("/CampusNav/main_admin.jsp");
        else                               response.sendRedirect("/CampusNav/main_guest.jsp");
        return;
    }
    String errorMsg   = (String) request.getAttribute("errorMsg");
    String prevId     = (String) request.getAttribute("prevId");
    String registered = request.getParameter("registered");
    if (errorMsg == null) errorMsg = "";
    if (prevId   == null) prevId   = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 로그인</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; }
        body {
            font-family: 'Noto Sans KR', sans-serif;
            background: linear-gradient(135deg, #0f172a 0%, #0f766e 50%, #166534 100%);
            min-height: 100vh;
            display: flex; align-items: center; justify-content: center;
        }
        body::before {
            content: ''; position: fixed; inset: 0; z-index: 0;
            background-image: radial-gradient(circle, rgba(255,255,255,.05) 1px, transparent 1px);
            background-size: 30px 30px;
        }
        .login-wrap {
            position: relative; z-index: 10;
            width: 100%; max-width: 460px; padding: 1.5rem;
            animation: fadeUp .5s cubic-bezier(.22,1,.36,1) both;
        }
        @keyframes fadeUp { from{opacity:0;transform:translateY(20px)} to{opacity:1;transform:none} }
        .login-card {
            background: #fff;
            border-radius: 28px;
            padding: 2.8rem 2.4rem;
            box-shadow: 0 32px 64px rgba(0,0,0,.25);
        }
        .login-logo { width: 58px; height: 58px; object-fit: contain; margin-bottom: 1rem; }
        .login-title { font-size: 1.6rem; font-weight: 800; color: #0f172a; }
        .login-title span { color: #0f766e; }
        .login-sub { font-size: .84rem; color: #64748b; margin: .3rem 0 1.8rem; }

        /* 역할 버튼 */
        .role-grid { display: grid; grid-template-columns: repeat(4,1fr); gap: .45rem; margin-bottom: 1.6rem; }
        .role-btn {
            border: 1.5px solid #e5e7eb; border-radius: 12px;
            background: #f9fafb; color: #64748b;
            font-size: .72rem; font-weight: 600;
            padding: .55rem .2rem; text-align: center;
            cursor: pointer; transition: all .2s;
        }
        .role-btn i { display: block; font-size: 1.1rem; margin-bottom: .2rem; }
        .role-btn.active { border-color: #0f766e; background: #f0fdf4; color: #0f766e; }
        .role-btn:hover { border-color: #0f766e; color: #0f766e; }

        /* 알림 */
        .alert-err { background:#fef2f2; border:1px solid #fecaca; border-radius:12px; color:#dc2626; font-size:.84rem; padding:.7rem 1rem; margin-bottom:.9rem; display:flex; align-items:center; gap:.4rem; }
        .alert-ok  { background:#f0fdf4; border:1px solid #bbf7d0; border-radius:12px; color:#16a34a; font-size:.84rem; padding:.7rem 1rem; margin-bottom:.9rem; display:flex; align-items:center; gap:.4rem; }

        /* 입력 필드 */
        .f-group { position: relative; margin-bottom: 1rem; }
        .f-icon { position:absolute; left:14px; top:50%; transform:translateY(-50%); color:#9ca3af; font-size:1rem; pointer-events:none; }
        .f-input-login {
            width: 100%; border: 1.5px solid #e5e7eb; border-radius: 12px;
            padding: .65rem 1rem .65rem 2.6rem; font-size: .9rem; outline: none;
            transition: border-color .2s, box-shadow .2s; background: #fafafa; color: #1f2937;
        }
        .f-input-login:focus { border-color: #0f766e; box-shadow: 0 0 0 3px rgba(15,118,110,.12); background: #fff; }
        .btn-eye { position:absolute; right:12px; top:50%; transform:translateY(-50%); background:none; border:none; color:#9ca3af; cursor:pointer; padding:0; }

        /* 로그인 버튼 */
        .btn-login-main {
            width: 100%; padding: .75rem;
            background: linear-gradient(135deg, #0f766e, #16a34a);
            border: none; border-radius: 14px; color: white;
            font-weight: 800; font-size: .95rem; cursor: pointer;
            transition: opacity .2s, transform .15s; margin-bottom: .8rem;
        }
        .btn-login-main:hover { opacity: .9; transform: translateY(-1px); }
        .btn-register-out {
            width: 100%; padding: .7rem; background: #fff;
            border: 1.5px solid #e5e7eb; border-radius: 14px;
            color: #374151; font-weight: 700; font-size: .9rem;
            cursor: pointer; transition: all .2s; margin-bottom: .5rem;
            display: block; text-align: center; text-decoration: none;
        }
        .btn-register-out:hover { border-color: #0f766e; color: #0f766e; }
        .btn-guest-out {
            width: 100%; padding: .65rem; background: transparent;
            border: 1.5px dashed #cbd5e1; border-radius: 14px;
            color: #94a3b8; font-size: .88rem; cursor: pointer;
            text-align: center; transition: all .2s;
            display: block; text-decoration: none;
        }
        .btn-guest-out:hover { border-color: #0f766e; color: #0f766e; }

        /* 구분선 */
        .divider { position:relative; text-align:center; font-size:.8rem; color:#9ca3af; margin:1rem 0; }
        .divider::before,.divider::after { content:''; position:absolute; top:50%; width:42%; height:1px; background:#e5e7eb; }
        .divider::before{left:0;} .divider::after{right:0;}

        /* 힌트 */
        .hint-box { background:#f8fafc; border:1px solid #e5e7eb; border-radius:14px; padding:.9rem 1.1rem; margin-top:1.2rem; }
        .hint-title { font-size:.72rem; font-weight:700; color:#0f766e; text-transform:uppercase; letter-spacing:.07em; margin-bottom:.5rem; }
        .hint-row { display:flex; justify-content:space-between; font-size:.78rem; color:#64748b; padding:.2rem 0; border-bottom:1px solid #f1f5f9; }
        .hint-row:last-child { border-bottom:none; }
        .hint-row .hl { color:#0f172a; font-weight:600; }
        .hint-row .hv { color:#0f766e; font-family:monospace; cursor:pointer; }
        .hint-row .hv:hover { opacity:.75; }
        .footer-note { font-size:.74rem; color:#94a3b8; text-align:center; margin-top:1.2rem; }
        .footer-note a { color:#0f766e; text-decoration:none; }
    </style>
</head>
<body>
<div class="login-wrap">
  <div class="login-card">

    <img src="/CampusNav/images/logo.png" alt="ICT" class="login-logo">
    <div class="login-title">ICT Campus<span>Nav</span></div>
    <p class="login-sub">교내 자원 내비게이션 시스템</p>

    <!-- 역할 선택 -->
    <div class="role-grid">
      <button type="button" class="role-btn" onclick="fillAccount('student1','pass1234',this)">
        <i class="bi bi-mortarboard-fill"></i>학부생
      </button>
      <button type="button" class="role-btn" onclick="fillAccount('assist1','asst1234',this)">
        <i class="bi bi-person-workspace"></i>조교
      </button>
      <button type="button" class="role-btn" onclick="fillAccount('prof1','prof1234',this)">
        <i class="bi bi-person-badge-fill"></i>교수
      </button>
      <button type="button" class="role-btn" onclick="fillAccount('admin','1234',this)">
        <i class="bi bi-shield-fill"></i>관리자
      </button>
    </div>

    <% if (!errorMsg.isEmpty()) { %>
    <div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><span><%= errorMsg %></span></div>
    <% } %>
    <% if ("true".equals(registered)) { %>
    <div class="alert-ok"><i class="bi bi-check-circle-fill"></i><span>회원가입 완료! 로그인해 주세요.</span></div>
    <% } %>

    <form action="/CampusNav/login" method="post" id="frm">
      <div class="f-group">
        <i class="bi bi-person f-icon"></i>
        <input class="f-input-login" type="text" id="userId" name="userId"
               placeholder="학번 / 아이디" value="<%= prevId %>" autocomplete="username">
      </div>
      <div class="f-group">
        <i class="bi bi-lock f-icon"></i>
        <input class="f-input-login" type="password" id="pwField" name="userPw"
               placeholder="비밀번호" autocomplete="current-password" style="padding-right:2.8rem">
        <button type="button" class="btn-eye" onclick="togglePw()">
          <i class="bi bi-eye" id="eyeIco"></i>
        </button>
      </div>
      <div class="d-flex justify-content-between align-items-center mb-3">
        <label style="display:flex;align-items:center;gap:.4rem;font-size:.82rem;color:#64748b;cursor:pointer">
          <input type="checkbox" name="saveId" style="accent-color:#0f766e"> 아이디 저장
        </label>
        <a href="#" style="font-size:.82rem;color:#0f766e;text-decoration:none">비밀번호 찾기</a>
      </div>
      <button type="submit" class="btn-login-main">
        <i class="bi bi-compass me-1"></i> 로그인
      </button>
    </form>

    <div class="divider">또는</div>
    <a href="/CampusNav/register.jsp" class="btn-register-out">
      <i class="bi bi-person-plus me-1"></i> 회원가입
    </a>
    <a href="/CampusNav/guest" class="btn-guest-out">
      <i class="bi bi-eye me-1"></i> 로그인 없이 둘러보기 (게스트)
    </a>

    <!-- 테스트 계정 -->
    <div class="hint-box">
      <div class="hint-title"><i class="bi bi-info-circle me-1"></i>테스트 계정</div>
      <div class="hint-row">
        <span class="hl">학부생</span>
        <span class="hv" onclick="fillAccount('student1','pass1234',null)">student1 / pass1234</span>
      </div>
      <div class="hint-row">
        <span class="hl">조교</span>
        <span class="hv" onclick="fillAccount('assist1','asst1234',null)">assist1 / asst1234</span>
      </div>
      <div class="hint-row">
        <span class="hl">교수</span>
        <span class="hv" onclick="fillAccount('prof1','prof1234',null)">prof1 / prof1234</span>
      </div>
      <div class="hint-row">
        <span class="hl">운영 관리자</span>
        <span class="hv" onclick="fillAccount('admin','1234',null)">admin / 1234</span>
      </div>
    </div>

    <p class="footer-note">
      재학생·교직원 전용 서비스<br>
      문의: <a href="mailto:support@campus.ac.kr">support@campus.ac.kr</a>
    </p>
  </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function fillAccount(id, pw, btn) {
    document.getElementById('userId').value  = id;
    document.getElementById('pwField').value = pw;
    document.querySelectorAll('.role-btn').forEach(function(b){ b.classList.remove('active'); });
    if (btn) btn.classList.add('active');
}
function togglePw() {
    var pw = document.getElementById('pwField');
    var ic = document.getElementById('eyeIco');
    if (pw.type === 'password') { pw.type = 'text';     ic.className = 'bi bi-eye-slash'; }
    else                        { pw.type = 'password'; ic.className = 'bi bi-eye'; }
}
document.getElementById('frm').addEventListener('submit', function(e) {
    if (!document.getElementById('userId').value.trim() ||
        !document.getElementById('pwField').value.trim()) {
        e.preventDefault();
        alert('아이디와 비밀번호를 입력해 주세요.');
    }
});
</script>
</body>
</html>
