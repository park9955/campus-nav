<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
%>
<!DOCTYPE html><html lang="ko"><head>
<meta charset="UTF-8"><meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>ICT CampusNav — 교수</title>
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
    <a href="/CampusNav/main_professor.jsp" class="brand">
        <img src="/CampusNav/images/logo.png" alt="ICT" style="height:28px;width:auto">
        ICT Campus<span>Nav</span>
    </a>
    <div class="nav-right">
        <span style="color:rgba(255,255,255,.75);font-size:.82rem"><i class="bi bi-person-circle me-1"></i><%= loginName %></span>
        <span class="role-badge">교수</span>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>
<div class="container-fluid page-wrap">

    <div class="hero-box mb-4">
        <div class="row align-items-center">
            <div class="col-lg-8">
                <div class="hero-title">안녕하세요, <em><%= loginName %></em>님 👋</div>
                <div class="hero-desc">소프트웨어 자산을 조회하고 등록·수정할 수 있습니다.</div>
                <form method="get" action="/CampusNav/search.jsp" class="mt-3">
                    <div class="search-row" style="max-width:520px">
                        <input type="text" name="keyword" placeholder="소프트웨어명, 위치 검색...">
                        <button type="submit" class="btn-search"><i class="bi bi-search me-1"></i>검색</button>
                    </div>
                </form>
            </div>
            <div class="col-lg-4 text-lg-end mt-3 mt-lg-0" style="position:relative;z-index:1">
                <span class="soft-tag"><i class="bi bi-person-badge-fill me-1"></i>교수</span>
            </div>
        </div>
    </div>

    <div class="row g-3 mb-4">
        <div class="col-md-6 col-xl-3"><div class="stat-card stat1"><div class="stat-label">소프트웨어 자산</div><div class="stat-value">296건</div><div class="stat-desc">무형고정자산 전체</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat2"><div class="stat-label">사용중</div><div class="stat-value">확인</div><div class="stat-desc">PC별 SW 현황 탭에서</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat3"><div class="stat-label">SW 등록</div><div class="stat-value">가능</div><div class="stat-desc">SW 등록 탭에서</div></div></div>
        <div class="col-md-6 col-xl-3"><div class="stat-card stat4"><div class="stat-label">SW 수정/삭제</div><div class="stat-value">가능</div><div class="stat-desc">목록에서 선택</div></div></div>
    </div>

    <div class="tab-row">
        <button class="tab-btn active" onclick="showTab('search',this)"><i class="bi bi-search me-1"></i>자원 검색</button>
        <button class="tab-btn" onclick="showTab('swlist',this)"><i class="bi bi-pc-display me-1"></i>PC별 SW 현황</button>
        <button class="tab-btn" onclick="showTab('register',this)"><i class="bi bi-plus-circle me-1"></i>SW 등록</button>
        <button class="tab-btn" id="editTabBtn" onclick="showTab('edit',this)" style="display:none"><i class="bi bi-pencil me-1"></i>SW 수정</button>
        <button class="tab-btn" id="delTabBtn" onclick="showTab('delete',this)" style="display:none"><i class="bi bi-trash me-1"></i>SW 삭제</button>
    </div>

    <div class="tab-content active" id="tab-search">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">자원 검색</div>
                <div class="section-sub">소프트웨어 및 전체 자원을 검색할 수 있습니다.</div>
                <div class="table-responsive">
                    <table class="table table-modern">
                        <thead><tr><th>번호</th><th>자원명</th><th>위치</th><th>소프트웨어</th><th>활용여부</th><th>관리</th></tr></thead>
                        <tbody>
                            <tr>
                                <td data-label="번호">001</td><td data-label="자원명"><strong>노트북 Dell XPS</strong></td>
                                <td data-label="위치"><i class="bi bi-geo-alt" style="color:#0f766e"></i> 공학관 301호</td>
                                <td data-label="SW"><span class="badge-soft-purple">MATLAB R2024</span></td>
                                <td data-label="활용"><span class="badge-use">사용가능</span></td>
                                <td data-label="관리">
                                    <button class="btn-edit me-1" onclick="openEdit('001','MATLAB R2024')">수정</button>
                                    <button class="btn-del" onclick="openDelete('001','노트북 Dell XPS','MATLAB R2024')">삭제</button>
                                </td>
                            </tr>
                            <tr>
                                <td data-label="번호">002</td><td data-label="자원명"><strong>워크스테이션 A</strong></td>
                                <td data-label="위치"><i class="bi bi-geo-alt" style="color:#0f766e"></i> 연구실 402호</td>
                                <td data-label="SW"><span class="badge-soft-purple">ANSYS 2024</span></td>
                                <td data-label="활용"><span class="badge-busy">사용중</span></td>
                                <td data-label="관리">
                                    <button class="btn-edit me-1" onclick="openEdit('002','ANSYS 2024')">수정</button>
                                    <button class="btn-del" onclick="openDelete('002','워크스테이션 A','ANSYS 2024')">삭제</button>
                                </td>
                            </tr>
                        </tbody>
                    </table>
                </div>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-swlist">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">PC별 설치 소프트웨어 현황</div>
                <div class="section-sub">각 PC에 설치된 소프트웨어 목록입니다.</div>
                <div class="row g-3">
                    <div class="col-md-6">
                        <div class="result-row">
                            <div class="result-title"><i class="bi bi-laptop me-2" style="color:#0ea5e9"></i>노트북 Dell XPS <small class="text-muted">#001 · 공학관 301호</small></div>
                            <div class="mt-2">
                                <span class="badge-soft-purple">MATLAB R2024b</span>
                                <span class="badge-soft-purple">AutoCAD 2024</span>
                                <span class="badge-soft-purple">VS Code</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="result-row">
                            <div class="result-title"><i class="bi bi-pc-display me-2" style="color:#7c3aed"></i>워크스테이션 A <small class="text-muted">#002 · 연구실 402호</small></div>
                            <div class="mt-2">
                                <span class="badge-soft-purple">ANSYS 2024</span>
                                <span class="badge-soft-purple">SolidWorks 2024</span>
                            </div>
                        </div>
                    </div>
                    <div class="col-md-6">
                        <div class="result-row">
                            <div class="result-title"><i class="bi bi-monitor me-2" style="color:#ea580c"></i>강의용 PC <small class="text-muted">#003 · 공학관 401호</small></div>
                            <div class="mt-2">
                                <span class="badge-soft-purple">MS Office 365</span>
                                <span class="badge-soft-purple">한글 2022</span>
                                <span class="badge-soft-purple">Zoom</span>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-register">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">소프트웨어 등록</div>
                <form>
                    <div class="row g-3">
                        <div class="col-md-6"><label class="f-label">소프트웨어명 *</label><input class="f-input" type="text" placeholder="예) MATLAB R2024b"></div>
                        <div class="col-md-6"><label class="f-label">버전</label><input class="f-input" type="text" placeholder="예) R2024b"></div>
                        <div class="col-md-6"><label class="f-label">설치 자원 (장비명)</label><input class="f-input" type="text" placeholder="예) 노트북 Dell XPS (001)"></div>
                        <div class="col-md-6"><label class="f-label">라이선스 종류</label>
                            <select class="f-select"><option>교육용 라이선스</option><option>연구용 라이선스</option><option>오픈소스</option><option>상용</option></select>
                        </div>
                        <div class="col-md-6"><label class="f-label">라이선스 만료일</label><input class="f-input" type="date"></div>
                        <div class="col-md-6"><label class="f-label">담당 교수</label><input class="f-input" type="text" value="<%= loginName %>"></div>
                        <div class="col-12"><label class="f-label">비고</label><textarea class="f-input" rows="2" placeholder="사용 목적, 제한 사항 등"></textarea></div>
                        <div class="col-12"><button type="button" class="btn-submit" onclick="alert('등록 완료!\n(프로토타입)')"><i class="bi bi-check-circle me-1"></i>등록하기</button></div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-edit">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title">소프트웨어 수정</div>
                <form>
                    <div class="row g-3">
                        <div class="col-md-6"><label class="f-label">자원 번호</label><input class="f-input" type="text" id="edit-id" readonly style="background:#f1f5f9;color:#64748b"></div>
                        <div class="col-md-6"><label class="f-label">소프트웨어명 *</label><input class="f-input" type="text" id="edit-sw"></div>
                        <div class="col-md-6"><label class="f-label">버전</label><input class="f-input" type="text" id="edit-ver" placeholder="예) R2024b"></div>
                        <div class="col-md-6"><label class="f-label">라이선스</label>
                            <select class="f-select" id="edit-lic"><option>교육용 라이선스</option><option>연구용 라이선스</option><option>오픈소스</option></select>
                        </div>
                        <div class="col-12" style="display:flex;gap:.6rem">
                            <button type="button" class="btn-submit" style="flex:1" onclick="alert('수정 완료!\n(프로토타입)')"><i class="bi bi-check-circle me-1"></i>수정 완료</button>
                            <button type="button" class="btn-soft" onclick="cancelEdit()"><i class="bi bi-x-circle me-1"></i>취소</button>
                        </div>
                    </div>
                </form>
            </div>
        </div>
    </div>

    <div class="tab-content" id="tab-delete">
        <div class="card-modern">
            <div class="card-body">
                <div class="section-title" style="color:#dc2626"><i class="bi bi-trash me-2"></i>소프트웨어 삭제</div>
                <div style="background:#fff5f5;border:1px solid #fecaca;border-radius:14px;padding:1.2rem;margin-bottom:1rem">
                    <div style="font-weight:700;color:#dc2626;margin-bottom:.8rem"><i class="bi bi-exclamation-triangle-fill me-1"></i>삭제할 소프트웨어</div>
                    <div class="row g-2">
                        <div class="col-md-4"><div style="font-size:.76rem;color:#64748b">자원번호</div><div style="font-weight:600" id="del-id">-</div></div>
                        <div class="col-md-4"><div style="font-size:.76rem;color:#64748b">PC명</div><div style="font-weight:600" id="del-pc">-</div></div>
                        <div class="col-md-4"><div style="font-size:.76rem;color:#64748b">소프트웨어</div><div style="font-weight:600;color:#dc2626" id="del-sw">-</div></div>
                    </div>
                </div>
                <div class="mb-3"><label class="f-label">삭제 사유 *</label><textarea class="f-input" id="del-reason" rows="2" placeholder="예) 라이선스 만료"></textarea></div>
                <div style="display:flex;gap:.6rem">
                    <button type="button" style="flex:1;padding:.72rem;background:linear-gradient(135deg,#dc2626,#ef4444);border:none;border-radius:12px;color:#fff;font-weight:700;cursor:pointer"
                            onclick="confirmDelete()"><i class="bi bi-trash me-1"></i>삭제 확정</button>
                    <button type="button" class="btn-soft" onclick="cancelDelete()"><i class="bi bi-x-circle me-1"></i>취소</button>
                </div>
            </div>
        </div>
    </div>
    <script>
    function openEdit(id,sw){
        document.getElementById('edit-id').value=id;
        document.getElementById('edit-sw').value=sw;
        document.getElementById('editTabBtn').style.display='';
        document.querySelectorAll('.tab-content').forEach(function(el){el.classList.remove('active');});
        document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
        document.getElementById('tab-edit').classList.add('active');
        document.getElementById('editTabBtn').classList.add('active');
    }
    function cancelEdit(){
        document.getElementById('editTabBtn').style.display='none';
        document.querySelectorAll('.tab-content').forEach(function(el){el.classList.remove('active');});
        document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
        document.getElementById('tab-search').classList.add('active');
        document.querySelectorAll('.tab-btn')[0].classList.add('active');
    }
    function openDelete(id,pc,sw){
        document.getElementById('del-id').textContent=id;
        document.getElementById('del-pc').textContent=pc;
        document.getElementById('del-sw').textContent=sw;
        document.getElementById('del-reason').value='';
        document.getElementById('delTabBtn').style.display='';
        document.querySelectorAll('.tab-content').forEach(function(el){el.classList.remove('active');});
        document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
        document.getElementById('tab-delete').classList.add('active');
        document.getElementById('delTabBtn').classList.add('active');
    }
    function confirmDelete(){
        if(!document.getElementById('del-reason').value.trim()){alert('삭제 사유를 입력해 주세요.');return;}
        alert('삭제 완료!\n(프로토타입)');
        cancelDelete();
    }
    function cancelDelete(){
        document.getElementById('delTabBtn').style.display='none';
        document.querySelectorAll('.tab-content').forEach(function(el){el.classList.remove('active');});
        document.querySelectorAll('.tab-btn').forEach(function(b){b.classList.remove('active');});
        document.getElementById('tab-search').classList.add('active');
        document.querySelectorAll('.tab-btn')[0].classList.add('active');
    }
    </script>
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