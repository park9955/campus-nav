<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    if(loginUser==null){response.sendRedirect("/CampusNav/campuslogin.jsp");return;}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CampusNav — 게스트</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>
:root{
  --white:#fff;--bg:#f7f8fa;--line:#e4e7ed;--line2:#d0d5df;
  --txt:#111827;--txt2:#4b5563;--txt3:#9ca3af;
  --blue:#1a56db;--blue-lt:#eff4ff;--blue-md:#c7d7fd;
  --teal:#0d9488;--teal-lt:#f0fdfa;--teal-md:#99f6e4;
  --amber:#d97706;--amber-lt:#fffbeb;
  --red:#dc2626;--red-lt:#fef2f2;
  --green:#16a34a;--green-lt:#f0fdf4;
  --purple:#7c3aed;--purple-lt:#f5f3ff;
  --mono:'DM Mono',monospace;
  --sans:'DM Sans','Noto Sans KR',sans-serif;
  --r:12px;--r2:20px;
  --shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.04);
  --shadow2:0 2px 8px rgba(0,0,0,.08),0 12px 32px rgba(0,0,0,.06);
}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:15px;line-height:1.65;}

.topnav{display:flex;align-items:center;justify-content:space-between;padding:14px 32px;background:var(--white);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:100;box-shadow:0 1px 4px rgba(0,0,0,.04);}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;color:var(--txt);text-decoration:none;}
.logo-dot{width:30px;height:30px;border-radius:8px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.logo-dot img{width:100%;height:100%;object-fit:contain;}
.logo em{color:var(--blue);font-style:normal;}
.nav-right{display:flex;gap:8px;align-items:center;}
.chip{font-family:var(--mono);font-size:12px;padding:6px 14px;border-radius:999px;background:var(--white);border:1px solid var(--line);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-flex;align-items:center;gap:5px;}
.chip:hover{border-color:var(--blue);color:var(--blue);}
.chip-blue{background:var(--blue) !important;color:white !important;border-color:var(--blue) !important;}
.chip-blue:hover{background:#1647c0 !important;}
.role-chip{font-family:var(--mono);font-size:12px;padding:5px 13px;border-radius:6px;background:var(--bg);border:1px solid var(--line2);color:var(--txt3);}

.shell{max-width:1380px;margin:0 auto;padding:28px 32px 72px;}

/* HERO */
.hero{
  background:linear-gradient(135deg,#0f172a 0%,#0d6147 50%,#16a34a 100%);
  border-radius:var(--r2);padding:44px 48px;margin-bottom:24px;
  box-shadow:0 8px 32px rgba(15,23,42,.25);
  display:grid;grid-template-columns:1fr 120px;gap:32px;align-items:center;
  position:relative;overflow:hidden;
}
/* pointer-events:none 필수! 안 하면 버튼 클릭 차단됨 */
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:280px;background:linear-gradient(135deg,rgba(255,255,255,.05) 0%,rgba(22,163,74,.12) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);pointer-events:none;z-index:0;}
.hero-content{position:relative;z-index:1;}
.hero-eyebrow{font-family:var(--mono);font-size:12px;color:rgba(255,255,255,.7);letter-spacing:.14em;text-transform:uppercase;margin-bottom:10px;}
.hero-title{font-size:30px;font-weight:800;color:#fff;margin-bottom:10px;}
.hero-title em{color:#4ade80;font-style:normal;}
.hero-desc{color:rgba(255,255,255,.88);font-size:15px;line-height:1.8;margin-bottom:20px;}
.hero-side{position:relative;z-index:1;text-align:center;font-size:56px;}

/* 검색바 */
.search-wrap{position:relative;z-index:2;display:flex;gap:8px;max-width:520px;
  background:rgba(255,255,255,.15);border:1.5px solid rgba(255,255,255,.38);
  border-radius:var(--r2);padding:6px 6px 6px 16px;}
.search-wrap input{flex:1;background:transparent;border:none;outline:none;color:#fff;font-size:15px;font-family:var(--sans);}
.search-wrap input::placeholder{color:rgba(255,255,255,.55);}
.search-wrap:focus-within{border-color:rgba(255,255,255,.7);}
.btn-search{background:var(--blue);color:white;border:none;border-radius:var(--r);padding:10px 20px;font-size:15px;font-weight:700;cursor:pointer;white-space:nowrap;flex-shrink:0;}
.btn-search:hover{background:#1647c0;}

/* MAIN GRID */
.main-grid{display:grid;grid-template-columns:1fr 360px;gap:20px;}

/* CARD */
.card{background:var(--white);border:1.5px solid var(--line2);border-radius:var(--r2);box-shadow:var(--shadow);overflow:hidden;margin-bottom:20px;}
.card-head{padding:18px 24px;border-bottom:1.5px solid var(--line2);display:flex;align-items:center;gap:12px;}
.ch-icon{width:36px;height:36px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
.si-blue{background:var(--blue-lt);}.si-teal{background:var(--teal-lt);}
.ch-title{font-size:15px;font-weight:700;color:var(--txt);}
.ch-sub{font-size:12px;color:var(--txt3);margin-top:2px;}
.card-body{padding:20px 24px;}

/* 카테고리 그리드 */
.cat-grid{display:grid;grid-template-columns:repeat(6,1fr);gap:10px;}
.cat-item{border:1.5px solid var(--line);border-radius:var(--r2);padding:18px 8px;text-align:center;text-decoration:none;color:var(--txt);background:var(--white);transition:all .2s;display:block;}
.cat-item:hover{border-color:var(--blue);box-shadow:var(--shadow2);transform:translateY(-2px);color:var(--blue);}
.cat-item i{display:block;font-size:22px;margin-bottom:8px;}
.cat-item span{font-size:13px;font-weight:600;}

/* 네비 카드 */
.map-frame{background:linear-gradient(135deg,var(--teal-lt),var(--blue-lt));border:1.5px dashed var(--teal-md);border-radius:var(--r2);padding:28px;text-align:center;margin-bottom:14px;}
.map-icon{font-size:44px;margin-bottom:10px;}
.map-title{font-size:15px;font-weight:700;color:var(--txt);margin-bottom:6px;}
.map-note{font-size:13px;color:var(--txt3);line-height:1.7;}

/* 로그인 버튼들 */
.btn-login-teal{display:block;width:100%;text-align:center;background:var(--teal);color:white;border:none;border-radius:var(--r);padding:13px;font-size:15px;font-weight:700;cursor:pointer;text-decoration:none;transition:background .15s;margin-bottom:8px;}
.btn-login-teal:hover{background:#0b7b70;color:white;}
.btn-login-blue{display:block;width:100%;text-align:center;background:var(--blue);color:white;border:none;border-radius:var(--r);padding:13px;font-size:15px;font-weight:700;cursor:pointer;text-decoration:none;transition:background .15s;margin-bottom:8px;}
.btn-login-blue:hover{background:#1647c0;color:white;}

/* FOOTER */
.site-footer{border-top:1px solid var(--line);padding:22px 32px;background:var(--white);margin-top:60px;}
.footer-inner{max-width:1380px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.footer-logo{display:flex;align-items:center;gap:8px;font-weight:800;font-size:14px;color:var(--txt);text-decoration:none;}
.footer-logo em{color:var(--blue);font-style:normal;}
.footer-logo-dot{width:24px;height:24px;border-radius:6px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.footer-logo-dot img{width:100%;height:100%;object-fit:contain;}
.footer-team{font-family:var(--mono);font-size:12px;color:var(--txt3);text-align:center;line-height:1.8;}
.footer-team strong{color:var(--blue);}
.footer-copy{font-family:var(--mono);font-size:12px;color:var(--txt3);text-align:right;line-height:1.8;}

@media(max-width:1100px){.main-grid{grid-template-columns:1fr;}.cat-grid{grid-template-columns:repeat(3,1fr);}}
@media(max-width:768px){.topnav{padding:12px 16px;}.shell{padding:16px 16px 48px;}.hero{grid-template-columns:1fr;padding:26px 22px;}.hero::after{display:none;}.hero-side{display:none;}.cat-grid{grid-template-columns:repeat(3,1fr);}}
</style>
</head>
<body>

<nav class="topnav">
  <a href="/CampusNav/main_guest.jsp" class="logo">
    <span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
    ICT Campus<em>Nav</em>
  </a>
  <div class="nav-right">
    <span class="role-chip">게스트</span>
    <a href="/CampusNav/guest_to_login.jsp" class="chip chip-blue">
      <i class="bi bi-box-arrow-in-right"></i> 로그인
    </a>
  </div>
</nav>

<div class="shell">

  <div class="hero">
    <div class="hero-content">
      <div class="hero-eyebrow">// ICT CAMPUSNAV · 게스트 모드</div>
      <div class="hero-title">교내 자원을 <em>검색</em>하세요</div>
      <div class="hero-desc">로그인 없이 자산 검색 및 상세보기가 가능합니다.<br>예약 및 길안내는 로그인 후 이용하세요.</div>
      <form method="get" action="/CampusNav/search.jsp" style="position:relative;z-index:2">
        <div class="search-wrap">
          <input type="text" name="keyword" placeholder="자산번호, 품목명, 위치 검색...">
          <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
        </div>
      </form>
    </div>
    <div class="hero-side">👁</div>
  </div>

  <div class="main-grid">
    <div>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon si-blue"><i class="bi bi-grid-3x3-gap" style="color:var(--blue)"></i></div>
          <div><div class="ch-title">카테고리별 검색</div><div class="ch-sub">분류별로 바로 검색하세요</div></div>
        </div>
        <div class="card-body">
          <div class="cat-grid">
            <a href="/CampusNav/search.jsp?type=공기구비품" class="cat-item">
              <i class="bi bi-tools" style="color:var(--blue)"></i><span>공기구비품</span>
            </a>
            <a href="/CampusNav/search.jsp?type=집기비품" class="cat-item">
              <i class="bi bi-laptop" style="color:var(--teal)"></i><span>집기비품</span>
            </a>
            <a href="/CampusNav/search.jsp?type=무형고정자산" class="cat-item">
              <i class="bi bi-code-square" style="color:var(--purple)"></i><span>소프트웨어</span>
            </a>
            <a href="/CampusNav/search.jsp?keyword=공학관" class="cat-item">
              <i class="bi bi-building" style="color:var(--amber)"></i><span>공학관</span>
            </a>
            <a href="/CampusNav/professor.jsp" class="cat-item">
              <i class="bi bi-people" style="color:var(--teal)"></i><span>교수 자원</span>
            </a>
            <a href="/CampusNav/search.jsp" class="cat-item">
              <i class="bi bi-grid" style="color:var(--txt3)"></i><span>전체보기</span>
            </a>
          </div>
        </div>
      </div>

      <div style="background:var(--amber-lt);border:1.5px solid #fde68a;border-radius:var(--r2);padding:18px 22px;display:flex;align-items:center;gap:14px;">
        <i class="bi bi-info-circle-fill" style="font-size:20px;color:var(--amber);flex-shrink:0"></i>
        <div>
          <div style="font-weight:700;font-size:15px;color:var(--amber);margin-bottom:4px">게스트 이용 안내</div>
          <div style="font-size:14px;color:var(--txt2)">
            게스트는 <strong>검색·상세보기</strong>만 가능합니다.
            <a href="/CampusNav/guest_to_login.jsp" style="color:var(--blue);font-weight:700;text-decoration:none;display:inline-flex;align-items:center;gap:4px;margin-left:6px">
              <i class="bi bi-box-arrow-in-right"></i>로그인하여 예약 및 길찾기 →
            </a>
          </div>
        </div>
      </div>
    </div>

    <div>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon si-teal"><i class="bi bi-compass" style="color:var(--teal)"></i></div>
          <div><div class="ch-title">실내 네비게이션</div><div class="ch-sub">로그인 후 이용 가능</div></div>
        </div>
        <div class="card-body">
          <div class="map-frame">
            <div class="map-icon">🧭</div>
            <div class="map-title">캠퍼스 길찾기</div>
            <div class="map-note">로그인 후 현재 위치 기준<br>실내 경로 안내를 이용할 수 있습니다</div>
          </div>
          <!-- 로그인하여 길찾기 버튼 -->
          <a href="/CampusNav/guest_to_login.jsp" class="btn-login-teal">
            <i class="bi bi-box-arrow-in-right me-1"></i>로그인하여 길찾기
          </a>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <div class="ch-icon si-blue"><i class="bi bi-person-circle" style="color:var(--blue)"></i></div>
          <div><div class="ch-title">더 많은 기능 이용하기</div><div class="ch-sub">로그인하면 모든 기능 사용 가능</div></div>
        </div>
        <div class="card-body">
          <ul style="list-style:none;padding:0;margin:0 0 18px">
            <li style="padding:8px 0;border-bottom:1px solid var(--line);font-size:14px;display:flex;align-items:center;gap:8px"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>자원 예약 신청</li>
            <li style="padding:8px 0;border-bottom:1px solid var(--line);font-size:14px;display:flex;align-items:center;gap:8px"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>실내 네비게이션 (GPS 연동)</li>
            <li style="padding:8px 0;border-bottom:1px solid var(--line);font-size:14px;display:flex;align-items:center;gap:8px"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>교수 자원 협력 요청</li>
            <li style="padding:8px 0;font-size:14px;display:flex;align-items:center;gap:8px"><i class="bi bi-check-circle-fill" style="color:var(--green)"></i>자원 상세 정보 및 이관이력</li>
          </ul>
          <!-- 재학생 로그인 버튼 -->
          <a href="/CampusNav/guest_to_login.jsp" class="btn-login-blue">
            <i class="bi bi-box-arrow-in-right me-1"></i>재학생·교직원 로그인
          </a>
          <!-- 외부인 입장 버튼 -->
          <a href="/CampusNav/visitor" class="btn-login-teal">
            <i class="bi bi-person-walking me-1"></i>외부인 입장 (예약·길찾기)
          </a>
          <a href="/CampusNav/register.jsp" style="display:block;text-align:center;margin-top:10px;font-size:13px;color:var(--blue);text-decoration:none;font-weight:600">
            <i class="bi bi-person-plus me-1"></i>회원가입
          </a>
        </div>
      </div>
    </div>
  </div>

</div>

<footer class="site-footer">
  <div class="footer-inner">
    <a href="/CampusNav/guest_to_login.jsp" class="footer-logo">
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
</body>
</html>
