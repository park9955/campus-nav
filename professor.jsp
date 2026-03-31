<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
    String viewProfId = request.getParameter("profId");
    if (viewProfId == null) viewProfId = "";
    String msg = request.getParameter("msg");
    if (msg == null) msg = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 교수 자원</title>
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
        .hero-title{font-size:1.8rem;font-weight:800;margin-bottom:10px;position:relative;z-index:1;}
        .hero-desc{font-size:.95rem;line-height:1.85;color:rgba(255,255,255,.92);position:relative;z-index:1;}
        .card-modern{border:none;border-radius:26px;background:rgba(255,255,255,.96);box-shadow:0 14px 35px rgba(15,23,42,.08);overflow:hidden;margin-bottom:1.5rem;}
        .card-modern .card-body{padding:28px;}
        .section-title{font-size:1.1rem;font-weight:800;color:#0f172a;margin-bottom:8px;}
        .section-sub{color:#64748b;font-size:.9rem;margin-bottom:16px;line-height:1.8;}
        /* 교수 카드 */
        .prof-card{border:1px solid #edf2f7;border-radius:20px;padding:22px;background:#fff;transition:all .2s;cursor:pointer;}
        .prof-card:hover{box-shadow:0 10px 24px rgba(15,23,42,.1);transform:translateY(-3px);border-color:#0f766e;}
        .prof-card.selected{border-color:#0f766e;background:#f0fdf4;box-shadow:0 10px 24px rgba(15,118,110,.12);}
        .prof-avatar{width:52px;height:52px;border-radius:14px;background:linear-gradient(135deg,#0f766e,#22c55e);display:flex;align-items:center;justify-content:center;color:#fff;font-size:1.3rem;font-weight:800;flex-shrink:0;}
        .prof-name{font-size:1rem;font-weight:800;color:#0f172a;}
        .prof-dept{font-size:.82rem;color:#64748b;margin-top:.2rem;}
        .prof-office{font-size:.8rem;color:#0f766e;margin-top:.3rem;}
        /* 뱃지 */
        .badge-skill{background:#f3edff;color:#7c3aed;border-radius:8px;padding:.25rem .7rem;font-size:.76rem;font-weight:600;display:inline-block;margin:.2rem .2rem 0 0;}
        .badge-subject{background:#e0f2fe;color:#0284c7;border-radius:8px;padding:.25rem .7rem;font-size:.76rem;font-weight:600;display:inline-block;margin:.2rem .2rem 0 0;}
        .badge-research{background:#dcfce7;color:#16a34a;border-radius:8px;padding:.25rem .7rem;font-size:.76rem;font-weight:600;display:inline-block;margin:.2rem .2rem 0 0;}
        /* 탭 */
        .tab-row{display:flex;gap:.5rem;margin-bottom:1.2rem;flex-wrap:wrap;}
        .tab-btn{padding:.55rem 1.2rem;border-radius:12px;border:1.5px solid #e5e7eb;background:#fff;color:#64748b;font-size:.85rem;font-weight:600;cursor:pointer;transition:all .2s;}
        .tab-btn.active{background:linear-gradient(135deg,#0f766e,#16a34a);color:#fff;border-color:transparent;}
        .tab-btn:hover:not(.active){border-color:#0f766e;color:#0f766e;}
        .tab-content{display:none;}.tab-content.active{display:block;}
        /* 폼 */
        .f-label{font-size:.78rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:.4rem;}
        .f-input{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa;color:#1f2937;}
        .f-input:focus{border-color:#0f766e;box-shadow:0 0 0 3px rgba(15,118,110,.12);background:#fff;}
        .f-select{width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa;}
        .btn-submit{background:linear-gradient(135deg,#0f766e,#16a34a);color:#fff;border:none;border-radius:12px;padding:.7rem 1.8rem;font-size:.92rem;font-weight:700;cursor:pointer;}
        .btn-soft{background:#f8fafc;border:1px solid #e2e8f0;color:#334155;border-radius:12px;padding:.65rem 1.4rem;font-weight:600;cursor:pointer;}
        /* 과목 리스트 */
        .subject-row{border:1px solid #f1f5f9;border-radius:14px;padding:14px 18px;margin-bottom:10px;background:#fff;display:flex;align-items:center;gap:1rem;}
        .subject-row:hover{border-color:#e0f2fe;background:#f8fcff;}
        .subject-credit{background:#0ea5e9;color:#fff;border-radius:8px;padding:.2rem .6rem;font-size:.76rem;font-weight:700;flex-shrink:0;}
        /* 알림 */
        .alert-ok{background:#f0fdf4;border:1px solid #bbf7d0;border-radius:12px;color:#16a34a;font-size:.85rem;padding:.7rem 1rem;margin-bottom:1rem;display:flex;align-items:center;gap:.4rem;}
        /* 확장성 안내 */
        .expand-note{background:linear-gradient(135deg,#ecfeff,#f0fdf4);border:none;border-radius:16px;padding:1rem 1.4rem;font-size:.85rem;color:#0f766e;}
        @media(max-width:768px){
            .topbar{padding:.6rem 1rem;flex-wrap:wrap;gap:.4rem;}.page-wrap{padding:1rem;}
            .hero-box{padding:1.6rem 1.4rem;}.hero-title{font-size:1.3rem;}
        }
    </style>
</head>
<body>

<!-- 네비바 -->
<div class="topbar">
    <a href="/CampusNav/main_<%= loginRole %>.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:28px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div class="nav-right">
        <span style="color:rgba(255,255,255,.75);font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <span class="role-badge"><%= "professor".equals(loginRole) ? "교수" : "admin".equals(loginRole) ? "관리자" : "조교" %></span>
        <a href="/CampusNav/main_<%= loginRole %>.jsp" class="btn-out"><i class="bi bi-house me-1"></i>홈</a>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="container-fluid page-wrap">

    <!-- 히어로 -->
    <div class="hero-box mb-4">
        <div class="hero-title">교수 자원 관리 👨‍🏫</div>
        <div class="hero-desc">교수별 과목, 주특기, 연구분야를 등록하고 관리합니다.<br>교수도 교내 자원입니다 — 협업 및 연구 연계에 활용하세요.</div>
    </div>

    <% if (!msg.isEmpty()) { %>
    <div class="alert-ok"><i class="bi bi-check-circle-fill"></i><%= msg %></div>
    <% } %>

    <!-- 탭 -->
    <div class="tab-row">
        <button class="tab-btn active" onclick="showTab('list',this)"><i class="bi bi-people me-1"></i>교수 목록</button>
        <% if ("professor".equals(loginRole) || "admin".equals(loginRole)) { %>
        <button class="tab-btn" onclick="showTab('subject',this)"><i class="bi bi-book me-1"></i>과목 등록</button>
        <button class="tab-btn" onclick="showTab('skill',this)"><i class="bi bi-star me-1"></i>주특기/연구분야 등록</button>
        <% } %>
        <% if ("admin".equals(loginRole)) { %>
        <button class="tab-btn" onclick="showTab('regprof',this)"><i class="bi bi-person-plus me-1"></i>교수 등록</button>
        <% } %>
    </div>

    <!-- 교수 목록 탭 -->
    <div class="tab-content active" id="tab-list">
        <div class="row g-3 mb-3">
            <!-- 교수 카드 1 -->
            <div class="col-md-6 col-xl-4">
                <div class="prof-card <%= "prof1".equals(viewProfId) ? "selected" : "" %>" onclick="selectProf('prof1')">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="prof-avatar">이</div>
                        <div>
                            <div class="prof-name">이교수</div>
                            <div class="prof-dept">AI네트워크학과</div>
                            <div class="prof-office"><i class="bi bi-geo-alt me-1"></i>공학관 511호</div>
                        </div>
                    </div>
                    <div class="mb-2">
                        <span class="badge-subject">인공지능개론</span>
                        <span class="badge-subject">딥러닝</span>
                        <span class="badge-subject">머신러닝</span>
                    </div>
                    <div>
                        <span class="badge-skill">Python</span>
                        <span class="badge-skill">TensorFlow</span>
                        <span class="badge-research">AI 연구</span>
                        <span class="badge-research">컴퓨터비전</span>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button class="btn-submit" style="padding:.4rem 1rem;font-size:.8rem" onclick="event.stopPropagation();showProfDetail('prof1')">
                            <i class="bi bi-eye me-1"></i>상세보기
                        </button>
                        <% if ("professor".equals(loginRole) && "prof1".equals(loginUser) || "admin".equals(loginRole)) { %>
                        <button class="btn-soft" style="padding:.4rem 1rem;font-size:.8rem" onclick="event.stopPropagation();editProf('prof1')">
                            <i class="bi bi-pencil me-1"></i>수정
                        </button>
                        <% } %>
                    </div>
                </div>
            </div>
            <!-- 교수 카드 2 -->
            <div class="col-md-6 col-xl-4">
                <div class="prof-card <%= "prof2".equals(viewProfId) ? "selected" : "" %>" onclick="selectProf('prof2')">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="prof-avatar" style="background:linear-gradient(135deg,#7c3aed,#a78bfa)">김</div>
                        <div>
                            <div class="prof-name">김교수</div>
                            <div class="prof-dept">컴퓨터공학과</div>
                            <div class="prof-office"><i class="bi bi-geo-alt me-1"></i>공학관 302호</div>
                        </div>
                    </div>
                    <div class="mb-2">
                        <span class="badge-subject">임베디드시스템</span>
                        <span class="badge-subject">IoT프로그래밍</span>
                    </div>
                    <div>
                        <span class="badge-skill">C/C++</span>
                        <span class="badge-skill">Arduino</span>
                        <span class="badge-research">IoT</span>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button class="btn-submit" style="padding:.4rem 1rem;font-size:.8rem" onclick="event.stopPropagation();showProfDetail('prof2')">
                            <i class="bi bi-eye me-1"></i>상세보기
                        </button>
                    </div>
                </div>
            </div>
            <!-- 교수 카드 3 -->
            <div class="col-md-6 col-xl-4">
                <div class="prof-card <%= "prof3".equals(viewProfId) ? "selected" : "" %>" onclick="selectProf('prof3')">
                    <div class="d-flex align-items-center gap-3 mb-3">
                        <div class="prof-avatar" style="background:linear-gradient(135deg,#ea580c,#fb923c)">박</div>
                        <div>
                            <div class="prof-name">박교수</div>
                            <div class="prof-dept">정보보안학과</div>
                            <div class="prof-office"><i class="bi bi-geo-alt me-1"></i>공학관 215호</div>
                        </div>
                    </div>
                    <div class="mb-2">
                        <span class="badge-subject">정보보안개론</span>
                        <span class="badge-subject">네트워크보안</span>
                    </div>
                    <div>
                        <span class="badge-skill">네트워크보안</span>
                        <span class="badge-research">사이버보안</span>
                    </div>
                    <div class="mt-3 d-flex gap-2">
                        <button class="btn-submit" style="padding:.4rem 1rem;font-size:.8rem" onclick="event.stopPropagation();showProfDetail('prof3')">
                            <i class="bi bi-eye me-1"></i>상세보기
                        </button>
                    </div>
                </div>
            </div>
        </div>

        <!-- 교수 상세 패널 -->
        <div id="profDetailPanel" style="display:none">
            <div class="card-modern">
                <div class="card-body">
                    <div class="d-flex align-items-center justify-content-between mb-3">
                        <div class="section-title" id="detail-title">교수 상세 정보</div>
                        <button class="btn-soft" style="padding:.35rem .9rem;font-size:.8rem" onclick="document.getElementById('profDetailPanel').style.display='none'">
                            <i class="bi bi-x"></i> 닫기
                        </button>
                    </div>
                    <div id="detail-content"></div>
                </div>
            </div>
        </div>
    </div>

    <!-- 과목 등록 탭 -->
    <div class="tab-content" id="tab-subject">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title"><i class="bi bi-book me-2"></i>과목 등록</div>
                <div class="section-sub">담당 과목을 등록하세요. 학생들이 교수 검색 시 과목 정보를 확인할 수 있습니다.</div>
                <form action="/CampusNav/professor" method="post">
                    <input type="hidden" name="action" value="addSubject">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="f-label">과목명 *</label>
                            <input class="f-input" type="text" name="subjectName" placeholder="예) 인공지능개론" required>
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">과목코드</label>
                            <input class="f-input" type="text" name="subjectCode" placeholder="예) AI101">
                        </div>
                        <div class="col-md-3">
                            <label class="f-label">학년</label>
                            <select class="f-select" name="grade">
                                <option value="1">1학년</option>
                                <option value="2">2학년</option>
                                <option value="3">3학년</option>
                                <option value="4">4학년</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="f-label">학기</label>
                            <select class="f-select" name="semester">
                                <option>1학기</option>
                                <option>2학기</option>
                                <option>계절학기</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="f-label">학점</label>
                            <select class="f-select" name="credit">
                                <option value="1">1학점</option>
                                <option value="2">2학점</option>
                                <option value="3" selected>3학점</option>
                            </select>
                        </div>
                        <div class="col-md-3">
                            <label class="f-label">강의 시간</label>
                            <input class="f-input" type="text" name="schedule" placeholder="예) 월3,4 수3,4">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">강의실</label>
                            <input class="f-input" type="text" name="room" placeholder="예) 공학관 301호">
                        </div>
                        <div class="col-md-6">
                            <label class="f-label">과목 설명</label>
                            <input class="f-input" type="text" name="description" placeholder="간단한 과목 소개">
                        </div>
                        <div class="col-12">
                            <button type="button" class="btn-submit" onclick="alert('과목 등록 완료!\n(프로토타입: DB 연동 시 저장됩니다)')">
                                <i class="bi bi-check-circle me-1"></i>과목 등록
                            </button>
                        </div>
                    </div>
                </form>

                <!-- 현재 등록된 과목 -->
                <hr style="margin:1.8rem 0">
                <div class="section-title"><i class="bi bi-list-ul me-2"></i>등록된 과목 목록</div>
                <div class="subject-row">
                    <span class="subject-credit">3학점</span>
                    <div>
                        <div style="font-weight:700">인공지능개론 <small class="text-muted">AI101</small></div>
                        <div style="font-size:.82rem;color:#64748b">2학년 · 1학기 · 화3,4 목3,4 · 공학관 301호</div>
                    </div>
                    <button class="btn-soft ms-auto" style="padding:.25rem .7rem;font-size:.76rem;flex-shrink:0">삭제</button>
                </div>
                <div class="subject-row">
                    <span class="subject-credit">3학점</span>
                    <div>
                        <div style="font-weight:700">딥러닝 <small class="text-muted">AI301</small></div>
                        <div style="font-size:.82rem;color:#64748b">3학년 · 2학기 · 월5,6 수5,6 · 공학관 301호</div>
                    </div>
                    <button class="btn-soft ms-auto" style="padding:.25rem .7rem;font-size:.76rem;flex-shrink:0">삭제</button>
                </div>
                <div class="subject-row">
                    <span class="subject-credit">3학점</span>
                    <div>
                        <div style="font-weight:700">머신러닝 <small class="text-muted">AI201</small></div>
                        <div style="font-size:.82rem;color:#64748b">3학년 · 1학기 · 화1,2 목1,2 · 공학관 301호</div>
                    </div>
                    <button class="btn-soft ms-auto" style="padding:.25rem .7rem;font-size:.76rem;flex-shrink:0">삭제</button>
                </div>
            </div>
        </div>
    </div>

    <!-- 주특기/연구분야 등록 탭 -->
    <div class="tab-content" id="tab-skill">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title"><i class="bi bi-star me-2"></i>주특기 / 연구분야 등록</div>
                <div class="section-sub">보유 기술, 연구분야, 자격증 등을 등록하세요.</div>
                <form>
                    <div class="row g-3">
                        <div class="col-md-4">
                            <label class="f-label">구분</label>
                            <select class="f-select" name="skillType">
                                <option>주특기</option>
                                <option>연구분야</option>
                                <option>자격증</option>
                                <option>수상이력</option>
                            </select>
                        </div>
                        <div class="col-md-5">
                            <label class="f-label">기술/분야명 *</label>
                            <input class="f-input" type="text" name="skillName" placeholder="예) Python, 머신러닝, 정보처리기사" required>
                        </div>
                        <div class="col-md-3">
                            <label class="f-label">수준</label>
                            <select class="f-select" name="skillLevel">
                                <option>전문가</option>
                                <option>고급</option>
                                <option>중급</option>
                                <option>초급</option>
                            </select>
                        </div>
                        <div class="col-12">
                            <label class="f-label">설명</label>
                            <input class="f-input" type="text" name="description" placeholder="간단한 설명 (선택)">
                        </div>
                        <div class="col-12">
                            <button type="button" class="btn-submit" onclick="addSkillTag()">
                                <i class="bi bi-plus-circle me-1"></i>추가
                            </button>
                        </div>
                    </div>
                </form>

                <!-- 등록된 주특기 -->
                <hr style="margin:1.8rem 0">
                <div class="section-title"><i class="bi bi-tags me-2"></i>등록된 주특기/연구분야</div>
                <div id="skillTagList" class="mt-2">
                    <span class="badge-skill" style="font-size:.84rem;padding:.3rem .9rem">Python <button style="background:none;border:none;color:#7c3aed;cursor:pointer;padding:0;margin-left:.3rem" onclick="this.parentElement.remove()">×</button></span>
                    <span class="badge-skill" style="font-size:.84rem;padding:.3rem .9rem">TensorFlow <button style="background:none;border:none;color:#7c3aed;cursor:pointer;padding:0;margin-left:.3rem" onclick="this.parentElement.remove()">×</button></span>
                    <span class="badge-research" style="font-size:.84rem;padding:.3rem .9rem">인공지능 <button style="background:none;border:none;color:#16a34a;cursor:pointer;padding:0;margin-left:.3rem" onclick="this.parentElement.remove()">×</button></span>
                    <span class="badge-research" style="font-size:.84rem;padding:.3rem .9rem">컴퓨터비전 <button style="background:none;border:none;color:#16a34a;cursor:pointer;padding:0;margin-left:.3rem" onclick="this.parentElement.remove()">×</button></span>
                </div>
                <div class="mt-3">
                    <button type="button" class="btn-submit" onclick="alert('저장 완료!\n(프로토타입)')">
                        <i class="bi bi-check-circle me-1"></i>전체 저장
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- 교수 등록 탭 (관리자만) -->
    <% if ("admin".equals(loginRole)) { %>
    <div class="tab-content" id="tab-regprof">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title"><i class="bi bi-person-plus me-2"></i>교수 등록</div>
                <div class="section-sub">새 교수 정보를 등록합니다.</div>
                <form>
                    <div class="row g-3">
                        <div class="col-md-4"><label class="f-label">교수 ID *</label><input class="f-input" type="text" placeholder="예) prof4"></div>
                        <div class="col-md-4"><label class="f-label">교수명 *</label><input class="f-input" type="text" placeholder="예) 최교수"></div>
                        <div class="col-md-4"><label class="f-label">소속 학과 *</label><input class="f-input" type="text" placeholder="예) 컴퓨터공학과"></div>
                        <div class="col-md-4"><label class="f-label">연구실 위치</label><input class="f-input" type="text" placeholder="예) 공학관 301호"></div>
                        <div class="col-md-4"><label class="f-label">연락처</label><input class="f-input" type="text" placeholder="010-0000-0000"></div>
                        <div class="col-md-4"><label class="f-label">이메일</label><input class="f-input" type="email" placeholder="prof@ict.ac.kr"></div>
                        <div class="col-12"><label class="f-label">소개</label><textarea class="f-input" rows="2" placeholder="교수 소개 (연구 관심사, 경력 등)"></textarea></div>
                        <div class="col-12"><button type="button" class="btn-submit" onclick="alert('교수 등록 완료!\n(프로토타입)')"><i class="bi bi-check-circle me-1"></i>등록하기</button></div>
                    </div>
                </form>
            </div>
        </div>
    </div>
    <% } %>

    <!-- 확장성 안내 -->
    <div class="expand-note">
        <i class="bi bi-info-circle me-2"></i>
        <strong>확장 예정:</strong> 지도 연동 시 교수 연구실 위치를 실시간으로 표시할 수 있습니다.
        GPS 2개 설치 후 1공학관/2공학관 실내 위치도 연동 가능합니다.
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function showTab(name, btn) {
    document.querySelectorAll('.tab-content').forEach(function(el){ el.classList.remove('active'); });
    document.querySelectorAll('.tab-btn').forEach(function(b){ b.classList.remove('active'); });
    document.getElementById('tab-' + name).classList.add('active');
    if (btn) btn.classList.add('active');
}
function selectProf(id) {
    document.querySelectorAll('.prof-card').forEach(function(c){ c.classList.remove('selected'); });
    event.currentTarget.classList.add('selected');
}
// 교수 상세 데이터
var profData = {
    'prof1': {
        name: '이교수', dept: 'AI네트워크학과', office: '공학관 511호',
        phone: '010-1111-2222', email: 'prof1@ict.ac.kr',
        intro: 'AI 및 네트워크 분야 전문가. 딥러닝, 컴퓨터비전 연구 중심.',
        subjects: [
            {name:'인공지능개론',code:'AI101',grade:'2학년',sem:'1학기',credit:'3',sched:'화3,4 목3,4',room:'공학관 301호'},
            {name:'딥러닝',code:'AI301',grade:'3학년',sem:'2학기',credit:'3',sched:'월5,6 수5,6',room:'공학관 301호'},
            {name:'머신러닝',code:'AI201',grade:'3학년',sem:'1학기',credit:'3',sched:'화1,2 목1,2',room:'공학관 301호'}
        ],
        skills: ['Python','TensorFlow','PyTorch'],
        research: ['인공지능','컴퓨터비전','딥러닝']
    },
    'prof2': {
        name: '김교수', dept: '컴퓨터공학과', office: '공학관 302호',
        phone: '010-2222-3333', email: 'prof2@ict.ac.kr',
        intro: '임베디드 시스템 및 IoT 전문가.',
        subjects: [
            {name:'임베디드시스템',code:'CS201',grade:'2학년',sem:'1학기',credit:'3',sched:'월3,4 금3,4',room:'실험실 402호'},
            {name:'IoT프로그래밍',code:'CS301',grade:'3학년',sem:'2학기',credit:'3',sched:'화5,6 목5,6',room:'실험실 402호'}
        ],
        skills: ['C/C++','Arduino','Raspberry Pi'],
        research: ['IoT','임베디드','스마트디바이스']
    },
    'prof3': {
        name: '박교수', dept: '정보보안학과', office: '공학관 215호',
        phone: '010-3333-4444', email: 'prof3@ict.ac.kr',
        intro: '사이버보안 및 암호학 전문가.',
        subjects: [
            {name:'정보보안개론',code:'SEC101',grade:'2학년',sem:'1학기',credit:'3',sched:'수3,4 금1,2',room:'공학관 215호'},
            {name:'네트워크보안',code:'SEC201',grade:'3학년',sem:'2학기',credit:'3',sched:'월1,2 수1,2',room:'공학관 215호'}
        ],
        skills: ['네트워크보안','침투테스트','암호화'],
        research: ['사이버보안','암호학','보안']
    }
};
function showProfDetail(id) {
    var p = profData[id];
    if (!p) return;
    var subjectHtml = p.subjects.map(function(s) {
        return '<div class="subject-row">'
            + '<span class="subject-credit">'+s.credit+'학점</span>'
            + '<div><div style="font-weight:700">'+s.name+' <small class="text-muted">'+s.code+'</small></div>'
            + '<div style="font-size:.82rem;color:#64748b">'+s.grade+' · '+s.sem+' · '+s.sched+' · '+s.room+'</div></div>'
            + '</div>';
    }).join('');
    var skillHtml = p.skills.map(function(s){ return '<span class="badge-skill">'+s+'</span>'; }).join('');
    var researchHtml = p.research.map(function(r){ return '<span class="badge-research">'+r+'</span>'; }).join('');

    document.getElementById('detail-title').textContent = p.name + ' 교수 상세 정보';
    document.getElementById('detail-content').innerHTML =
        '<div class="row g-3">'
        + '<div class="col-md-4">'
        +   '<div style="background:#f8fafc;border-radius:16px;padding:1.2rem">'
        +   '<div class="prof-avatar mb-3" style="width:60px;height:60px;font-size:1.5rem">'+p.name[0]+'</div>'
        +   '<div style="font-weight:800;font-size:1.1rem">'+p.name+'</div>'
        +   '<div style="color:#64748b;font-size:.84rem;margin:.3rem 0">'+p.dept+'</div>'
        +   '<div style="font-size:.84rem"><i class="bi bi-geo-alt me-1" style="color:#0f766e"></i>'+p.office+'</div>'
        +   '<div style="font-size:.84rem"><i class="bi bi-telephone me-1" style="color:#0f766e"></i>'+p.phone+'</div>'
        +   '<div style="font-size:.84rem"><i class="bi bi-envelope me-1" style="color:#0f766e"></i>'+p.email+'</div>'
        +   '<div style="font-size:.84rem;color:#64748b;margin-top:.8rem">'+p.intro+'</div>'
        +   '</div>'
        + '</div>'
        + '<div class="col-md-8">'
        +   '<div style="font-weight:700;margin-bottom:.6rem">담당 과목</div>'
        +   subjectHtml
        +   '<div style="font-weight:700;margin:.8rem 0 .5rem">주특기</div>' + skillHtml
        +   '<div style="font-weight:700;margin:.8rem 0 .5rem">연구분야</div>' + researchHtml
        + '</div>'
        + '</div>';
    document.getElementById('profDetailPanel').style.display = 'block';
    document.getElementById('profDetailPanel').scrollIntoView({behavior:'smooth'});
}
function addSkillTag() {
    var type = document.querySelector('select[name="skillType"]').value;
    var name = document.querySelector('input[name="skillName"]').value.trim();
    if (!name) { alert('기술/분야명을 입력해 주세요.'); return; }
    var cls = type === '주특기' ? 'badge-skill' : 'badge-research';
    var span = document.createElement('span');
    span.className = cls;
    span.style.cssText = 'font-size:.84rem;padding:.3rem .9rem';
    span.innerHTML = name + ' <button style="background:none;border:none;color:inherit;cursor:pointer;padding:0;margin-left:.3rem" onclick="this.parentElement.remove()">×</button>';
    document.getElementById('skillTagList').appendChild(span);
    document.querySelector('input[name="skillName"]').value = '';
}
</script>
</body>
</html>
