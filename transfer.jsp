<%@ page language="java" contentType="text/html; charset=UTF-8"
         pageEncoding="UTF-8" session="true" %>
<%
    String loginUser = (String) session.getAttribute("loginUser");
    String loginName = (String) session.getAttribute("loginName");
    String loginRole = (String) session.getAttribute("loginRole");
    if (loginUser == null) { response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
    String detail = request.getParameter("id");
    if (detail == null) detail = "";
%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>ICT CampusNav — 이관내역</title>
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
        .hero-box{background:linear-gradient(135deg,#0f172a 0%,#0f766e 48%,#22c55e 100%);color:white;border-radius:28px;padding:36px 42px;box-shadow:0 18px 40px rgba(15,23,42,.16);position:relative;overflow:hidden;margin-bottom:1.5rem;}
        .hero-box::before{content:"";position:absolute;right:-60px;top:-50px;width:220px;height:220px;border-radius:50%;background:rgba(255,255,255,.08);}
        .hero-title{font-size:1.6rem;font-weight:800;margin-bottom:8px;position:relative;z-index:1;}
        .hero-desc{font-size:.92rem;line-height:1.8;color:rgba(255,255,255,.92);position:relative;z-index:1;}
        .card-modern{border:none;border-radius:26px;background:rgba(255,255,255,.96);box-shadow:0 14px 35px rgba(15,23,42,.08);overflow:hidden;margin-bottom:1.5rem;}
        .card-modern .card-body{padding:28px;}
        .section-title{font-size:1.1rem;font-weight:800;color:#0f172a;margin-bottom:8px;}
        .section-sub{color:#64748b;font-size:.9rem;margin-bottom:16px;line-height:1.8;}
        /* 검색 */
        .search-row{display:flex;gap:.6rem;flex-wrap:wrap;}
        .search-row input,.search-row select{border:1.5px solid #e5e7eb;border-radius:12px;padding:.6rem 1rem;font-size:.88rem;outline:none;background:#fafafa;}
        .search-row input:focus,.search-row select:focus{border-color:#0f766e;}
        .btn-search{background:linear-gradient(135deg,#0f766e,#16a34a);border:none;border-radius:12px;color:#fff;font-weight:700;padding:.6rem 1.2rem;cursor:pointer;white-space:nowrap;}
        /* 이관 리스트 */
        .transfer-row{border:1px solid #edf2f7;border-radius:16px;padding:16px 20px;margin-bottom:10px;background:#fff;transition:all .2s;cursor:pointer;display:flex;align-items:center;gap:1rem;flex-wrap:wrap;}
        .transfer-row:hover{border-color:#bae6fd;box-shadow:0 6px 16px rgba(14,165,233,.08);background:#f8fcff;}
        .transfer-num{background:#0f766e;color:#fff;border-radius:8px;padding:.25rem .7rem;font-size:.76rem;font-weight:700;flex-shrink:0;}
        .transfer-arrow{color:#0f766e;font-size:1.2rem;flex-shrink:0;}
        .loc-box{flex:1;min-width:0;}
        .loc-from{font-size:.88rem;color:#374151;font-weight:600;}
        .loc-to{font-size:.88rem;color:#0f766e;font-weight:600;}
        .loc-sub{font-size:.78rem;color:#94a3b8;margin-top:.15rem;}
        .transfer-date{font-size:.8rem;color:#94a3b8;flex-shrink:0;}
        /* 상세 패널 */
        .detail-panel{border:none;border-radius:26px;background:rgba(255,255,255,.98);box-shadow:0 20px 50px rgba(15,23,42,.12);padding:28px;margin-bottom:1.5rem;}
        /* 이관 흐름 */
        .flow-box{display:flex;align-items:center;gap:1rem;background:#f8fafc;border-radius:16px;padding:1.2rem 1.6rem;flex-wrap:wrap;}
        .flow-card{flex:1;min-width:180px;background:#fff;border-radius:14px;padding:1rem 1.2rem;border:1.5px solid #e5e7eb;}
        .flow-card.from{border-color:#fecaca;background:#fff5f5;}
        .flow-card.to{border-color:#bbf7d0;background:#f0fdf4;}
        .flow-label{font-size:.72rem;font-weight:700;text-transform:uppercase;letter-spacing:.06em;margin-bottom:.4rem;}
        .flow-label.from{color:#dc2626;}
        .flow-label.to{color:#16a34a;}
        .flow-dept{font-size:.95rem;font-weight:800;color:#0f172a;}
        .flow-loc{font-size:.82rem;color:#64748b;margin-top:.2rem;}
        .flow-arrow-big{font-size:1.8rem;color:#0f766e;flex-shrink:0;}
        /* 테이블 */
        .table-modern thead th{background:#f7fcfb;color:#334155;border:none;font-weight:700;padding:12px 16px;font-size:.8rem;text-transform:uppercase;letter-spacing:.04em;}
        .table-modern tbody td{vertical-align:middle;padding:12px 16px;border-color:#f1f5f9;font-size:.86rem;}
        .table-modern tbody tr:hover td{background:#f8fbff;}
        /* 지도 자리 */
        .map-placeholder{background:linear-gradient(135deg,#f0fdf4,#ecfeff);border:1.5px dashed #a7f3d0;border-radius:16px;padding:2rem;text-align:center;color:#0f766e;}
        /* 페이징 */
        .page-btn{border:1.5px solid #e5e7eb;background:#fff;border-radius:8px;padding:.35rem .75rem;font-size:.82rem;cursor:pointer;transition:all .2s;}
        .page-btn.active{background:#0f766e;color:#fff;border-color:#0f766e;}
        .page-btn:hover:not(.active){border-color:#0f766e;color:#0f766e;}
        @media(max-width:768px){
            .topbar{padding:.6rem 1rem;flex-wrap:wrap;gap:.4rem;}.page-wrap{padding:1rem;}
            .hero-box{padding:1.4rem 1.2rem;}.hero-title{font-size:1.3rem;}
            .flow-box{flex-direction:column;} .flow-arrow-big{transform:rotate(90deg);}
            .transfer-row{flex-direction:column;align-items:flex-start;}
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
        <span class="role-badge"><%= "admin".equals(loginRole) ? "운영관리자" : "professor".equals(loginRole) ? "교수" : "조교" %></span>
        <a href="/CampusNav/main_<%= loginRole %>.jsp" class="btn-out"><i class="bi bi-house me-1"></i>홈</a>
        <form action="/CampusNav/logout" method="post" style="margin:0">
            <button type="submit" class="btn-out"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
        </form>
    </div>
</div>

<div class="container-fluid page-wrap">

    <!-- 히어로 -->
    <div class="hero-box mb-4">
        <div class="hero-title">자산 이관내역 <i class="bi bi-arrow-left-right ms-2"></i></div>
        <div class="hero-desc">누가 · 어디서 · 누구에게 이관했는지 전체 내역을 확인합니다.<br>이관 전/후 위치와 담당 부서를 상세하게 조회할 수 있습니다.</div>
    </div>

    <!-- 검색/필터 -->
    <div class="card-modern">
        <div class="card-body">
            <div class="section-title"><i class="bi bi-funnel me-2"></i>이관내역 검색</div>
            <div class="search-row">
                <input type="text" id="searchKeyword" placeholder="자산번호, 품목명, 부서명 검색..." style="flex:1;min-width:200px">
                <select id="filterDept" style="min-width:140px">
                    <option value="">전체 부서</option>
                    <option>경영기획팀</option>
                    <option>학사운영팀</option>
                    <option>AI네트워크학과</option>
                    <option>컴퓨터공학과</option>
                    <option>운영지원팀</option>
                </select>
                <input type="date" id="filterDateFrom" style="min-width:140px">
                <input type="date" id="filterDateTo" style="min-width:140px">
                <button class="btn-search" onclick="filterTransfer()"><i class="bi bi-search me-1"></i>검색</button>
                <button class="btn-search" style="background:#64748b" onclick="resetFilter()"><i class="bi bi-arrow-clockwise me-1"></i>초기화</button>
            </div>
        </div>
    </div>

    <!-- 통계 -->
    <div class="row g-3 mb-4">
        <div class="col-md-3">
            <div style="background:linear-gradient(135deg,#0ea5e9,#38bdf8);border-radius:20px;padding:20px;color:#fff;text-align:center">
                <div style="font-size:.88rem;opacity:.9">전체 이관</div>
                <div style="font-size:2rem;font-weight:800;margin:.5rem 0">140건</div>
                <div style="font-size:.82rem;opacity:.85">2025~2026년</div>
            </div>
        </div>
        <div class="col-md-3">
            <div style="background:linear-gradient(135deg,#16a34a,#4ade80);border-radius:20px;padding:20px;color:#fff;text-align:center">
                <div style="font-size:.88rem;opacity:.9">이번 달</div>
                <div style="font-size:2rem;font-weight:800;margin:.5rem 0">12건</div>
                <div style="font-size:.82rem;opacity:.85">2026년 3월</div>
            </div>
        </div>
        <div class="col-md-3">
            <div style="background:linear-gradient(135deg,#7c3aed,#a78bfa);border-radius:20px;padding:20px;color:#fff;text-align:center">
                <div style="font-size:.88rem;opacity:.9">이관 부서</div>
                <div style="font-size:2rem;font-weight:800;margin:.5rem 0">8개</div>
                <div style="font-size:.82rem;opacity:.85">관련 부서 수</div>
            </div>
        </div>
        <div class="col-md-3">
            <div style="background:linear-gradient(135deg,#ea580c,#fb923c);border-radius:20px;padding:20px;color:#fff;text-align:center">
                <div style="font-size:.88rem;opacity:.9">자산 유형</div>
                <div style="font-size:2rem;font-weight:800;margin:.5rem 0">3종</div>
                <div style="font-size:.82rem;opacity:.85">공기구·집기·SW</div>
            </div>
        </div>
    </div>

    <!-- 이관 목록 -->
    <div class="card-modern">
        <div class="card-body">
            <div class="d-flex align-items-center justify-content-between mb-3">
                <div class="section-title"><i class="bi bi-list-ul me-2"></i>이관 목록 <span style="font-size:.85rem;font-weight:400;color:#64748b">총 140건</span></div>
                <% if ("admin".equals(loginRole)) { %>
                <button class="btn-search" style="font-size:.82rem;padding:.45rem 1rem" onclick="document.getElementById('addTransferModal').style.display='flex'">
                    <i class="bi bi-plus-circle me-1"></i>이관 등록
                </button>
                <% } %>
            </div>

            <div id="transferList">
                <!-- 이관 행 1 -->
                <div class="transfer-row" onclick="showDetail(0)">
                    <span class="transfer-num">T-001</span>
                    <div class="loc-box">
                        <div class="loc-from"><i class="bi bi-building me-1"></i>경영기획팀</div>
                        <div class="loc-sub">ICT폴리텍대학 | 대학본부 | 3층</div>
                    </div>
                    <div class="transfer-arrow"><i class="bi bi-arrow-right-circle-fill"></i></div>
                    <div class="loc-box">
                        <div class="loc-to"><i class="bi bi-building-check me-1"></i>학사운영팀</div>
                        <div class="loc-sub">ICT폴리텍대학 | 대학본부 | 1층</div>
                    </div>
                    <div>
                        <div style="font-size:.82rem;font-weight:600;color:#0f172a">의자 (1702C0022)</div>
                        <div class="transfer-date">2025-05-12</div>
                    </div>
                    <button class="btn-search" style="font-size:.78rem;padding:.3rem .8rem;flex-shrink:0" onclick="event.stopPropagation();showDetail(0)">
                        <i class="bi bi-eye me-1"></i>상세
                    </button>
                </div>

                <div class="transfer-row" onclick="showDetail(1)">
                    <span class="transfer-num">T-002</span>
                    <div class="loc-box">
                        <div class="loc-from"><i class="bi bi-building me-1"></i>AI네트워크학과</div>
                        <div class="loc-sub">ICT폴리텍대학 | 제1공학관 | 3층</div>
                    </div>
                    <div class="transfer-arrow"><i class="bi bi-arrow-right-circle-fill"></i></div>
                    <div class="loc-box">
                        <div class="loc-to"><i class="bi bi-building-check me-1"></i>컴퓨터공학과</div>
                        <div class="loc-sub">ICT폴리텍대학 | 제2공학관 | 2층</div>
                    </div>
                    <div>
                        <div style="font-size:.82rem;font-weight:600;color:#0f172a">노트북 (2105C0034)</div>
                        <div class="transfer-date">2025-07-20</div>
                    </div>
                    <button class="btn-search" style="font-size:.78rem;padding:.3rem .8rem;flex-shrink:0" onclick="event.stopPropagation();showDetail(1)">
                        <i class="bi bi-eye me-1"></i>상세
                    </button>
                </div>

                <div class="transfer-row" onclick="showDetail(2)">
                    <span class="transfer-num">T-003</span>
                    <div class="loc-box">
                        <div class="loc-from"><i class="bi bi-building me-1"></i>운영지원팀</div>
                        <div class="loc-sub">ICT폴리텍대학 | 본관 | 1층</div>
                    </div>
                    <div class="transfer-arrow"><i class="bi bi-arrow-right-circle-fill"></i></div>
                    <div class="loc-box">
                        <div class="loc-to"><i class="bi bi-building-check me-1"></i>학생지원팀</div>
                        <div class="loc-sub">ICT폴리텍대학 | 학생회관 | 2층</div>
                    </div>
                    <div>
                        <div style="font-size:.82rem;font-weight:600;color:#0f172a">프로젝터 (1903C0012)</div>
                        <div class="transfer-date">2025-09-05</div>
                    </div>
                    <button class="btn-search" style="font-size:.78rem;padding:.3rem .8rem;flex-shrink:0" onclick="event.stopPropagation();showDetail(2)">
                        <i class="bi bi-eye me-1"></i>상세
                    </button>
                </div>

                <div class="transfer-row" onclick="showDetail(3)">
                    <span class="transfer-num">T-004</span>
                    <div class="loc-box">
                        <div class="loc-from"><i class="bi bi-building me-1"></i>정보보안학과</div>
                        <div class="loc-sub">ICT폴리텍대학 | 제1공학관 | 2층</div>
                    </div>
                    <div class="transfer-arrow"><i class="bi bi-arrow-right-circle-fill"></i></div>
                    <div class="loc-box">
                        <div class="loc-to"><i class="bi bi-building-check me-1"></i>AI네트워크학과</div>
                        <div class="loc-sub">ICT폴리텍대학 | 제1공학관 | 3층</div>
                    </div>
                    <div>
                        <div style="font-size:.82rem;font-weight:600;color:#0f172a">서버 랙 (2001C0008)</div>
                        <div class="transfer-date">2026-01-15</div>
                    </div>
                    <button class="btn-search" style="font-size:.78rem;padding:.3rem .8rem;flex-shrink:0" onclick="event.stopPropagation();showDetail(3)">
                        <i class="bi bi-eye me-1"></i>상세
                    </button>
                </div>
            </div>

            <!-- 페이징 -->
            <div class="d-flex gap-1 justify-content-center mt-3" id="pagination">
                <button class="page-btn active">1</button>
                <button class="page-btn">2</button>
                <button class="page-btn">3</button>
                <button class="page-btn">···</button>
                <button class="page-btn">14</button>
            </div>
        </div>
    </div>

    <!-- 상세 패널 -->
    <div id="detailPanel" class="detail-panel" style="display:none">
        <div class="d-flex align-items-center justify-content-between mb-4">
            <div style="font-size:1.2rem;font-weight:800;color:#0f172a" id="detail-id">이관 상세 정보</div>
            <button class="btn-out" style="color:#374151;background:#f1f5f9;border-color:#e5e7eb" onclick="document.getElementById('detailPanel').style.display='none'">
                <i class="bi bi-x"></i> 닫기
            </button>
        </div>

        <!-- 이관 흐름 -->
        <div class="flow-box mb-4">
            <div class="flow-card from">
                <div class="flow-label from"><i class="bi bi-arrow-up-circle me-1"></i>이관 전 (출발)</div>
                <div class="flow-dept" id="d-from-dept">-</div>
                <div class="flow-loc" id="d-from-loc"><i class="bi bi-geo-alt me-1"></i>-</div>
                <div class="flow-loc" id="d-from-detail" style="color:#94a3b8"></div>
            </div>
            <div class="flow-arrow-big"><i class="bi bi-arrow-right-circle-fill"></i></div>
            <div class="flow-card to">
                <div class="flow-label to"><i class="bi bi-arrow-down-circle me-1"></i>이관 후 (도착)</div>
                <div class="flow-dept" id="d-to-dept">-</div>
                <div class="flow-loc" id="d-to-loc"><i class="bi bi-geo-alt me-1"></i>-</div>
                <div class="flow-loc" id="d-to-detail" style="color:#94a3b8"></div>
            </div>
        </div>

        <!-- 자산 정보 -->
        <div class="row g-3 mb-3">
            <div class="col-md-6">
                <div style="background:#f8fafc;border-radius:14px;padding:1.2rem">
                    <div style="font-size:.78rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.05em;margin-bottom:.8rem">자산 정보</div>
                    <table style="width:100%;font-size:.86rem">
                        <tr><td style="color:#64748b;padding:.3rem 0;width:100px">자산번호</td><td style="font-weight:600" id="d-assetno">-</td></tr>
                        <tr><td style="color:#64748b;padding:.3rem 0">품목명</td><td style="font-weight:600" id="d-item">-</td></tr>
                        <tr><td style="color:#64748b;padding:.3rem 0">자산분류</td><td id="d-class">-</td></tr>
                        <tr><td style="color:#64748b;padding:.3rem 0">이관일자</td><td style="font-weight:600;color:#0f766e" id="d-date">-</td></tr>
                    </table>
                </div>
            </div>
            <div class="col-md-6">
                <div style="background:#f0fdf4;border-radius:14px;padding:1.2rem">
                    <div style="font-size:.78rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.05em;margin-bottom:.8rem">비고</div>
                    <div style="font-size:.88rem;color:#374151" id="d-remark">-</div>
                </div>
            </div>
        </div>

        <!-- 지도 자리 -->
        <div class="map-placeholder">
            <i class="bi bi-map" style="font-size:2.5rem;display:block;margin-bottom:.8rem"></i>
            <div style="font-weight:700;margin-bottom:.4rem">이관 경로 지도</div>
            <div style="font-size:.84rem;opacity:.8">GPS 설치 완료 후 1공학관 · 2공학관 실내 위치가 여기에 표시됩니다.</div>
            <div style="font-size:.78rem;opacity:.65;margin-top:.4rem">위도: 37.396681 | 경도: 127.247918</div>
        </div>
    </div>

    <!-- 이관 등록 모달 -->
    <div id="addTransferModal" style="display:none;position:fixed;inset:0;background:rgba(0,0,0,.5);z-index:1000;align-items:center;justify-content:center">
        <div style="background:#fff;border-radius:24px;padding:2rem;max-width:560px;width:90%;max-height:90vh;overflow-y:auto">
            <div class="d-flex justify-content-between align-items-center mb-3">
                <div style="font-size:1.1rem;font-weight:800">이관 등록</div>
                <button style="background:none;border:none;font-size:1.3rem;cursor:pointer;color:#64748b" onclick="document.getElementById('addTransferModal').style.display='none'">&times;</button>
            </div>
            <div class="row g-3">
                <div class="col-12"><label style="font-size:.78rem;font-weight:700;color:#374151;text-transform:uppercase;letter-spacing:.05em;display:block;margin-bottom:.4rem">이관 자산번호 *</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="예) 1702C0022"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관 전 부서</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="예) 경영기획팀"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관 전 위치</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="예) 대학본부 3층"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관 후 부서</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="예) 학사운영팀"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관 후 위치</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="예) 대학본부 1층"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관일자</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="date"></div>
                <div class="col-md-6"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">이관 담당자</label><input style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" type="text" placeholder="담당자명"></div>
                <div class="col-12"><label style="font-size:.78rem;font-weight:700;color:#374151;display:block;margin-bottom:.4rem">비고</label><textarea style="width:100%;border:1.5px solid #e5e7eb;border-radius:12px;padding:.65rem 1rem;font-size:.9rem;outline:none;background:#fafafa" rows="2" placeholder="이관 사유"></textarea></div>
                <div class="col-12">
                    <button style="width:100%;padding:.75rem;background:linear-gradient(135deg,#0f766e,#16a34a);border:none;border-radius:14px;color:#fff;font-weight:800;font-size:.95rem;cursor:pointer"
                            onclick="alert('이관 등록 완료!\n(프로토타입)');document.getElementById('addTransferModal').style.display='none'">
                        <i class="bi bi-check-circle me-1"></i>이관 등록
                    </button>
                </div>
            </div>
        </div>
    </div>

</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
var transfers = [
    { id:'T-001', assetNo:'1702C0022', item:'의자', cls:'집기비품', date:'2025-05-12',
      fromDept:'경영기획팀', fromLoc:'ICT폴리텍대학 | 대학본부', fromDetail:'3층 경영기획팀',
      toDept:'학사운영팀',   toLoc:'ICT폴리텍대학 | 대학본부',   toDetail:'1층 학사운영팀',
      remark:'부서 이전에 따른 집기 이관' },
    { id:'T-002', assetNo:'2105C0034', item:'노트북', cls:'집기비품', date:'2025-07-20',
      fromDept:'AI네트워크학과', fromLoc:'ICT폴리텍대학 | 제1공학관', fromDetail:'3층 310호',
      toDept:'컴퓨터공학과',    toLoc:'ICT폴리텍대학 | 제2공학관', toDetail:'2층 201호',
      remark:'실습실 재편에 따른 장비 이관' },
    { id:'T-003', assetNo:'1903C0012', item:'프로젝터', cls:'집기비품', date:'2025-09-05',
      fromDept:'운영지원팀', fromLoc:'ICT폴리텍대학 | 본관', fromDetail:'1층 창고',
      toDept:'학생지원팀',   toLoc:'ICT폴리텍대학 | 학생회관', toDetail:'2층 세미나실',
      remark:'학생회관 리모델링 후 비치' },
    { id:'T-004', assetNo:'2001C0008', item:'서버 랙', cls:'공기구비품', date:'2026-01-15',
      fromDept:'정보보안학과', fromLoc:'ICT폴리텍대학 | 제1공학관', fromDetail:'2층 보안실험실',
      toDept:'AI네트워크학과', toLoc:'ICT폴리텍대학 | 제1공학관', toDetail:'3층 AI실험실',
      remark:'AI 연구 프로젝트 지원을 위한 이관' }
];

function showDetail(idx) {
    var t = transfers[idx];
    document.getElementById('detail-id').textContent = t.id + ' — ' + t.item + ' 이관 상세';
    document.getElementById('d-from-dept').textContent = t.fromDept;
    document.getElementById('d-from-loc').innerHTML  = '<i class="bi bi-geo-alt me-1"></i>' + t.fromLoc;
    document.getElementById('d-from-detail').textContent = t.fromDetail;
    document.getElementById('d-to-dept').textContent = t.toDept;
    document.getElementById('d-to-loc').innerHTML   = '<i class="bi bi-geo-alt me-1"></i>' + t.toLoc;
    document.getElementById('d-to-detail').textContent = t.toDetail;
    document.getElementById('d-assetno').textContent = t.assetNo;
    document.getElementById('d-item').textContent   = t.item;
    document.getElementById('d-class').textContent  = t.cls;
    document.getElementById('d-date').textContent   = t.date;
    document.getElementById('d-remark').textContent = t.remark;
    var panel = document.getElementById('detailPanel');
    panel.style.display = 'block';
    panel.scrollIntoView({behavior:'smooth'});
}

function filterTransfer() {
    var kw = document.getElementById('searchKeyword').value.toLowerCase();
    var dept = document.getElementById('filterDept').value;
    document.querySelectorAll('.transfer-row').forEach(function(row, i) {
        var t = transfers[i];
        if (!t) return;
        var match = true;
        if (kw && !JSON.stringify(t).toLowerCase().includes(kw)) match = false;
        if (dept && t.fromDept !== dept && t.toDept !== dept) match = false;
        row.style.display = match ? '' : 'none';
    });
}
function resetFilter() {
    document.getElementById('searchKeyword').value = '';
    document.getElementById('filterDept').value = '';
    document.getElementById('filterDateFrom').value = '';
    document.getElementById('filterDateTo').value = '';
    document.querySelectorAll('.transfer-row').forEach(function(r){ r.style.display = ''; });
}
</script>
</body>
</html>
