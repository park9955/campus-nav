<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1.0">
<title>AI 경로 최적화 & 장애물 회피 시뮬레이션</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<script src="/CAN/nodedata.js"></script>

<style>
:root {
  --white:#fff; --bg:#f7f8fa; --blue:#1a56db; --green:#16a34a; --red:#dc2626;
  --teal:#0d9488; --txt:#111827; --txt2:#4b5563; --txt3:#9ca3af; --line:#e4e7ed;
  --shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.04);
}

[data-theme="dark"] {
  --white:#0f172a; --bg:#0f172a; --blue:#1a56db; --green:#16a34a; --red:#dc2626;
  --teal:#0d9488; --txt:#f1f5f9; --txt2:#cbd5e1; --txt3:#94a3b8; --line:rgba(71,85,105,0.6);
  --shadow:0 1px 3px rgba(0,0,0,.3),0 4px 16px rgba(0,0,0,.2);
  --surface:#1e293b; --sky-primary:#38bdf8; --header-bg:rgba(30,41,59,0.95);
}

[data-theme="dark"] body {
  background:linear-gradient(180deg,#0f172a 0%,#1a2f3a 40%,#1a332f 100%);
}

.theme-toggle {
  background:transparent; border:none; color:var(--txt2); cursor:pointer;
  font-size:18px; padding:6px 8px; border-radius:6px; transition:all 0.2s;
}

.theme-toggle:hover {
  color:var(--txt); background:rgba(0,0,0,0.05);
}

[data-theme="dark"] .theme-toggle:hover {
  background:rgba(255,255,255,0.1);
}
*{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--bg);color:var(--txt);font-family:-apple-system,BlinkMacSystemFont,"Segoe UI",Roboto,sans-serif;font-size:14px;line-height:1.6;}
.topnav{display:flex;justify-content:space-between;align-items:center;padding:14px 24px;background:var(--white);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:100;}
.logo{font-weight:700;font-size:16px;display:flex;align-items:center;gap:8px;color:var(--txt);text-decoration:none;}
.shell{max-width:1440px;margin:0 auto;padding:20px;}
.page-title{font-size:1.3rem;font-weight:700;margin-bottom:4px;}
.page-sub{color:var(--txt3);font-size:12px;margin-bottom:16px;}
.card{background:var(--white);border-radius:12px;border:1px solid var(--line);box-shadow:var(--shadow);overflow:hidden;margin-bottom:14px;}
.card-head{display:flex;align-items:center;gap:10px;padding:12px 16px;border-bottom:1px solid var(--line);}
.ch-icon{width:30px;height:30px;border-radius:8px;background:var(--blue);color:#fff;display:flex;align-items:center;justify-content:center;font-size:13px;flex-shrink:0;}
.ch-title{font-weight:700;font-size:13px;}
.card-body{padding:14px 16px;}
.f-label{font-size:11px;font-weight:600;color:var(--txt2);margin-bottom:4px;display:block;margin-top:6px;}
.f-select{width:100%;border:1.5px solid var(--line);border-radius:8px;font-size:12px;padding:7px 10px;background:var(--white);color:var(--txt);font-family:inherit;transition:border-color .15s;}
.f-select:focus{border-color:var(--blue);box-shadow:0 0 0 3px rgba(26,86,219,.1);outline:none;}
.btn-prim{background:var(--blue);color:#fff;border:none;border-radius:8px;padding:9px 14px;font-size:12px;font-weight:600;cursor:pointer;width:100%;display:flex;align-items:center;justify-content:center;gap:6px;transition:background .15s;}
.btn-prim:hover{background:#1340a8;}
.btn-ghost{background:transparent;color:var(--txt2);border:1.5px solid var(--line);border-radius:8px;padding:7px 12px;font-size:12px;font-weight:500;cursor:pointer;transition:all .15s;text-align:center;}
.btn-ghost:hover{border-color:var(--blue);color:var(--blue);}
.btn-ghost.active{background:var(--blue);color:#fff;border-color:var(--blue);}
.grid-2{display:grid;grid-template-columns:1fr 1fr;gap:6px;}
.sim-wrap{position:relative;width:100%;aspect-ratio:16/9;background:#0f172a;border-radius:10px;overflow:hidden;border:1px solid var(--line);user-select:none;}
.sim-canvas{position:absolute;top:0;left:0;width:100%;height:100%;display:block;}
.log-console{height:140px;background:#0f172a;color:#4ade80;padding:10px;border-radius:8px;font-family:Consolas,monospace;font-size:11px;overflow-y:auto;}
.candidate{border-left:4px solid var(--line);background:#f8fafc;padding:8px;margin-bottom:6px;border-radius:6px;font-size:11px;}
.candidate.best{border-left-color:var(--blue);background:#eff6ff;}
.candidate.reject{border-left-color:var(--red);background:#fef2f2;}
.row-layout{display:grid;grid-template-columns:360px 1fr;gap:16px;}
@media(max-width:991px){.row-layout{grid-template-columns:1fr;}}

[data-theme="dark"] .topnav {
  background:var(--header-bg); border-bottom-color:var(--line);
}

[data-theme="dark"] .card {
  background:var(--surface); border-color:var(--line);
}

[data-theme="dark"] .card-head {
  border-bottom-color:var(--line);
}

[data-theme="dark"] .f-select {
  background:var(--surface); border-color:var(--line); color:var(--txt);
}

[data-theme="dark"] .f-select:focus {
  border-color:var(--sky-primary); box-shadow:0 0 0 3px rgba(56,189,248,0.1);
}

[data-theme="dark"] .f-select option {
  background:#0f172a; color:#f1f5f9;
}

[data-theme="dark"] .btn-prim {
  background:var(--blue);
}

[data-theme="dark"] .btn-prim:hover {
  background:#1340a8;
}

[data-theme="dark"] .btn-ghost {
  color:var(--txt2); border-color:var(--line);
}

[data-theme="dark"] .btn-ghost:hover {
  border-color:var(--sky-primary); color:var(--sky-primary);
}

[data-theme="dark"] .log-console {
  background:#0a0f1a; color:#4ade80; border-color:var(--line);
}

[data-theme="dark"] .candidate {
  border-left-color:var(--line); background:var(--surface); color:var(--txt);
}

[data-theme="dark"] .candidate.best {
  border-left-color:var(--sky-primary); background:#1e3a5f;
}

[data-theme="dark"] .candidate.reject {
  border-left-color:var(--red); background:#3a1f1f;
}

[data-theme="dark"] .form-check-input {
  background:var(--surface); border-color:var(--line);
}

[data-theme="dark"] .form-check-input:checked {
  background:var(--blue); border-color:var(--blue);
}

[data-theme="dark"] .form-check-label {
  color:var(--txt);
}

[data-theme="dark"] table {
  color:var(--txt);
}

[data-theme="dark"] table thead {
  background:var(--surface); border-color:var(--line);
}

[data-theme="dark"] table th, [data-theme="dark"] table td {
  border-color:var(--line);
}

[data-theme="dark"] .alert {
  background:var(--surface); border-color:var(--line); color:var(--txt);
}

[data-theme="dark"] .alert-info {
  background:#1e3a5f; border-color:var(--sky-primary); color:var(--txt);
}

[data-theme="dark"] .alert-danger {
  background:#3a1f1f; border-color:var(--red);
}

[data-theme="dark"] #simWrap {
  background:#050a15; border-color:var(--line);
}

[data-theme="dark"] .form-check-input:disabled {
  background:var(--line); opacity:0.5;
}
</style>
</head>
<body>

<!-- 상단 헤더 -->
<div class="topnav">
  <a href="#" class="logo">
    <i class="bi bi-geo-alt-fill" style="color:var(--blue);font-size:18px;"></i>
    <span>ICT CAN — <strong>캠퍼스 AI 경로 최적화 시스템</strong></span>
  </a>
  <div style="display:flex;gap:8px;align-items:center;">
    <button type="button" class="theme-toggle" onclick="toggleTheme()" title="다크모드 토글">
      <i class="bi bi-moon" id="themeIcon"></i>
    </button>
    <a href="/CAN/navigationTest1.jsp" class="btn-ghost" style="width:auto;padding:5px 12px;" title="기본 길찾기로 이동">📍 기본 길찾기</a>
    <a href="/CAN/dashboard.jsp" class="btn-ghost" style="width:auto;padding:5px 12px;" title="운송 관리로 이동">🚚 운송 관리로</a>
  </div>
</div>

<div class="shell">
  <div class="page-title"><i class="bi bi-signpost-2-fill" style="color:var(--blue);"></i> 캠퍼스 자율 운송 경로 최적화 & 시뮬레이션</div>
  <div class="page-sub">전체 캠퍼스 평면도 비율에 맞춘 파란점 기준점 기반 최적 경로 시뮬레이션</div>

  <div class="row-layout">
    <!-- ================= 좌측 설정 컨트롤 패널 ================= -->
    <div>
      <div class="card">
        <div class="card-head">
          <div class="ch-icon" style="background:var(--green);"><i class="bi bi-pin-map-fill"></i></div>
          <div class="ch-title">출발지 & 목적지 선택</div>
        </div>
        <div class="card-body">
          <label class="f-label">출발지</label>
          <select class="f-select" id="startNode" onchange="changeStart()">
            <option value="GATE1">정문1</option>
            <option value="GATE2">정문2</option>
            <option value="GATE3" selected>정문3</option>
            <option value="MAIN_HQ">대학본부</option>
            <option value="ENG_1">제1공학관</option>
            <option value="LIBRARY">도서관</option>
            <option value="DORM_1">1생활관</option>
            <option value="STU_HALL">학생회관</option>
            <option value="ENG_2">제2공학관</option>
            <option value="SANHAK">산학협력관</option>
          </select>

          <label class="f-label">목적지</label>
          <select class="f-select" id="endNode" onchange="changeEnd()">
            <option value="GATE1">정문1</option>
            <option value="GATE2">정문2</option>
            <option value="GATE3">정문3</option>
            <option value="MAIN_HQ">대학본부</option>
            <option value="ENG_1">제1공학관</option>
            <option value="LIBRARY">도서관</option>
            <option value="DORM_1">1생활관</option>
            <option value="STU_HALL">학생회관</option>
            <option value="ENG_2" selected>제2공학관</option>
            <option value="SANHAK">산학협력관</option>
          </select>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <div class="ch-icon" style="background:var(--teal);"><i class="bi bi-cpu-fill"></i></div>
          <div class="ch-title">알고리즘 & 최적화 기준</div>
        </div>
        <div class="card-body">
          <div class="grid-2 mb-2">
            <button class="btn-ghost active" id="algAstar" onclick="selectAlgorithm('astar')">
              <i class="bi bi-lightning-fill"></i> A* 알고리즘
            </button>
            <button class="btn-ghost" id="algQl" onclick="selectAlgorithm('qlearning')">
              <i class="bi bi-brain"></i> Q-러닝 (강화학습)
            </button>
          </div>
          <label class="f-label">최적화 가중치 기준</label>
          <select class="f-select" id="optMode">
            <option value="ai">AI 종합 최적화</option>
            <option value="distance">최단거리 우선</option>
            <option value="safe" selected>안전/경사도 우선</option>
            <option value="time">시간 우선</option>
          </select>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <div class="ch-icon" style="background:var(--blue);"><i class="bi bi-box-seam-fill"></i></div>
          <div class="ch-title">이동체 & 화물 규격</div>
        </div>
        <div class="card-body">
          <label class="f-label">이동수단 (적재한도)</label>
          <div class="grid-2 mb-2">
            <button class="btn-ghost" id="transWalk" onclick="selectTransport('walk')">도보 (30kg)</button>
            <button class="btn-ghost" id="transRobot" onclick="selectTransport('robot')">로봇 (80kg)</button>
            <button class="btn-ghost active" id="transCart" onclick="selectTransport('cart')">카트 (150kg)</button>
            <button class="btn-ghost" id="transAgv" onclick="selectTransport('agv')">AGV (250kg)</button>
          </div>

          <label class="f-label">운송 화물 종류</label>
          <select class="f-select" id="cargoType" onchange="updateCargoInfo()">
            <option value="normal">실습 기자재 / 40kg / 폭 0.7m</option>
            <option value="server">서버 장비 / 80kg / 폭 0.9m</option>
            <option value="large">대형 장비 / 180kg / 폭 1.4m</option>
          </select>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <div class="ch-icon" style="background:#d97706;"><i class="bi bi-cloud-sun-fill"></i></div>
          <div class="ch-title">환경 & 장애 상황</div>
        </div>
        <div class="card-body">
          <div class="form-check form-switch mb-1">
            <input class="form-check-input" type="checkbox" id="chkConstruction" onchange="drawMap()">
            <label class="form-check-label" for="chkConstruction" style="font-size:12px;">🚧 운동장/중앙로 공사 중</label>
          </div>
          <div class="form-check form-switch mb-1">
            <input class="form-check-input" type="checkbox" id="chkElevator" onchange="drawMap()">
            <label class="form-check-label" for="chkElevator" style="font-size:12px;">🛗 엘리베이터 고장/점검</label>
          </div>
          <div class="form-check form-switch mb-1">
            <input class="form-check-input" type="checkbox" id="chkRain" onchange="drawMap()">
            <label class="form-check-label" for="chkRain" style="font-size:12px;">🌧 우천 (실외 위험도 ↑)</label>
          </div>
          <div class="form-check form-switch mb-2">
            <input class="form-check-input" type="checkbox" id="chkSnow" onchange="drawMap()">
            <label class="form-check-label" for="chkSnow" style="font-size:12px;">❄ 폭설/결빙 (미끄럼 위험 ↑)</label>
          </div>
          <div class="grid-2 mb-2">
            <button class="btn-ghost" id="btnObstacleMode" onclick="toggleObstacleMode()" style="background:#fef3c7;border-color:#f59e0b;color:#b45309;">
              <i class="bi bi-pin-fill"></i> 장애물 지정
            </button>
            <button class="btn-ghost" id="btnClearObstacles" onclick="clearAllObstacles()" style="border-color:#ef4444;color:#dc2626;">
              <i class="bi bi-x-circle"></i> 전체 삭제
            </button>
          </div>
          <div id="obstacleInfo" style="font-size:11px;color:var(--txt3);display:none;text-align:center;">
            평면도를 클릭하여 장애물을 지정하세요
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-head">
          <div class="ch-icon" style="background:#16a34a;"><i class="bi bi-map-fill"></i></div>
          <div class="ch-title">노드맵 표시 옵션</div>
        </div>
        <div class="card-body">
          <div class="form-check form-switch mb-1">
            <input class="form-check-input" type="checkbox" id="chkShowImage" checked onchange="toggleImageBackground()">
            <label class="form-check-label" for="chkShowImage" style="font-size:12px;">📍 평면도 배경 표시</label>
          </div>
          <div class="form-check form-switch">
            <input class="form-check-input" type="checkbox" id="chkShowLabels" checked onchange="toggleNodeLabels()">
            <label class="form-check-label" for="chkShowLabels" style="font-size:12px;">🏷️ 노드 레이블 표시</label>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-body">
          <button class="btn-prim mb-2" onclick="searchOptimalPath()">
            <i class="bi bi-search"></i> AI 최적경로 탐색
          </button>
          <button class="btn-prim mb-2" id="btnStartSim" onclick="startTransport()" style="background:var(--green);display:none;">
            <i class="bi bi-play-fill"></i> 운송 이동 실시
          </button>
          <button class="btn-prim" onclick="triggerDynamicObstacle()" style="background:var(--red);">
            <i class="bi bi-exclamation-triangle-fill"></i> ⚠ 운행 중 돌발 장애물 발생
          </button>
        </div>
      </div>
    </div>

    <!-- ================= 우측 시뮬레이션 및 결과 영역 ================= -->
    <div>
      <div class="card">
        <div class="card-head justify-content-between">
          <div class="d-flex align-items-center gap-2">
            <div class="ch-icon" style="background:var(--teal);"><i class="bi bi-map-fill"></i></div>
            <div class="ch-title">캠퍼스 평면도 전체 노드 맵</div>
          </div>
          <span id="statusBadge" class="badge bg-secondary" style="font-size:11px;">대기 중</span>
        </div>
        <div class="card-body" style="padding-bottom:0;">
          <div class="sim-wrap" id="simWrap">
            <canvas id="simCanvas" class="sim-canvas" width="800" height="450"></canvas>
          </div>
          
          <div class="mt-2">
            <div class="d-flex justify-content-between" style="font-size:11px;color:var(--txt2);margin-bottom:3px;">
              <span>이동 진행률</span>
              <span id="progressText">0%</span>
            </div>
            <div style="width:100%;height:8px;background:var(--line);border-radius:4px;overflow:hidden;">
              <div id="progressBar" style="width:0%;height:100%;background:var(--green);transition:width .2s;"></div>
            </div>
          </div>
        </div>
      </div>

      <div class="row g-3 mb-3">
        <div class="col-md-6">
          <div class="card h-100 mb-0">
            <div class="card-head"><div class="ch-title">🧠 AI 경로 탐색 과정</div></div>
            <div class="card-body" id="searchResult" style="max-height:220px;overflow-y:auto;">
              경로 탐색을 실행하면 후보 경로 검증 결과가 표시됩니다.
            </div>
          </div>
        </div>
        <div class="col-md-6">
          <div class="card h-100 mb-0">
            <div class="card-head"><div class="ch-title">📊 기존 경로 vs AI 최적경로 비교</div></div>
            <div class="card-body" id="comparisonResult" style="max-height:220px;overflow-y:auto;">
              탐색 완료 후 경로 비교 분석표가 작성됩니다.
            </div>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-head"><div class="ch-title">💻 AI 의사결정 실시간 로그</div></div>
        <div class="card-body">
          <div id="logConsole" class="log-console">SYSTEM > 전체 캠퍼스 노드 가시화 완료. 최적 경로 탐색을 시작하세요.</div>
        </div>
      </div>
    </div>
  </div>
</div>

<script>
// 🎯 공통 노드 데이터 사용 (navigationTest1.jsp와 동일)
const nodes = CAMPUS_NODES;
const edges = CAMPUS_EDGES;
const routes = CAMPUS_ROUTES;

// 캠퍼스 평면도 이미지 로드
const backgroundImg = new Image();
backgroundImg.src = CAMPUS_IMAGE.url;

// 노드맵 최적화 설정
const nodeConfig = {
  showImage: true,
  showNodeLabels: true,
  nodeRadius: 7,
  nodeLabelFont: 'bold 11px "Noto Sans KR", sans-serif',
  edgeWidth: 2,
  edgeColor: '#0d9488',
  selectedEdgeColor: '#1a56db',
  selectedEdgeWidth: 5,
  nodeGlowColor: 'rgba(26, 86, 219, 0.3)',
  nodeGlowRadius: 12
};

let selectedAlgorithm = 'astar';
let selectedTransport = 'cart';
let activeRoute = null;
let animTimer = null;
let currentStep = 0;
let dynamicObstacleActive = false;
let obstacleMode = false;
let obstacles = [];
const OBSTACLE_RADIUS_PERCENT = 4;

function resizeCanvas() {
  const canvas = document.getElementById('simCanvas');
  const wrap = document.getElementById('simWrap');

  // wrap 크기에 맞춰 canvas 크기 설정
  const w = wrap.offsetWidth;
  const h = (w * CAMPUS_IMAGE.height) / CAMPUS_IMAGE.width;

  canvas.width = w;
  canvas.height = h;
}

window.onload = function() {
  // 테마 초기화
  const savedTheme = localStorage.getItem('theme');
  const html = document.documentElement;

  if (savedTheme) {
    html.setAttribute('data-theme', savedTheme);
  } else if (window.matchMedia('(prefers-color-scheme: dark)').matches) {
    html.setAttribute('data-theme', 'dark');
    localStorage.setItem('theme', 'dark');
  }
  updateThemeIcon();

  const canvas = document.getElementById('simCanvas');

  backgroundImg.onload = function() {
    resizeCanvas();
    drawMap();
    log("✓ 캠퍼스 평면도 이미지 로드 완료");
  };

  backgroundImg.onerror = function() {
    log("⚠ 평면도 이미지 로드 실패 - 노드맵만 표시됩니다");
    nodeConfig.showImage = false;
    document.getElementById('chkShowImage').checked = false;
    resizeCanvas();
    drawMap();
  };

  if (backgroundImg.complete) {
    resizeCanvas();
    drawMap();
  }

  window.addEventListener('resize', () => {
    resizeCanvas();
    setTimeout(drawMap, 50);
  });

  canvas.addEventListener('click', handleCanvasClick);

  // URL 파라미터에서 from, to, vehicle 값 읽기
  const params = new URLSearchParams(window.location.search);
  const fromParam = params.get('from');
  const toParam = params.get('to');
  const vehicleParam = params.get('vehicle');

  // 위치값을 노드 ID로 매핑하는 임시 객체
  const locationMapping = {
    '위치 1': 'GATE1',
    '위치 2': 'DORM_1',
    '1206호': 'ENG_1',
    '1공학관': 'ENG_1',
    '2공학관': 'ENG_2',
    '정문': 'GATE1',
    '학생회관': 'STU_HALL',
    '도서관': 'LIBRARY',
    '1생활관': 'DORM_1',
    '대학본부': 'MAIN_HQ'
  };

  // 출발지 자동 선택
  if (fromParam) {
    const mappedFrom = locationMapping[fromParam] || fromParam;
    if (nodes[mappedFrom]) {
      document.getElementById('startNode').value = mappedFrom;
      changeStart();
    } else {
      log("⚠️ 지도에 없는 위치입니다: " + fromParam);
    }
  }

  // 목적지 자동 선택
  if (toParam) {
    const mappedTo = locationMapping[toParam] || toParam;
    if (nodes[mappedTo]) {
      document.getElementById('endNode').value = mappedTo;
      changeEnd();
    } else {
      log("⚠️ 지도에 없는 위치입니다: " + toParam);
    }
  }

  // 이동수단 자동 선택
  if (vehicleParam) {
    selectTransport(vehicleParam.toLowerCase());
  }
};

function selectAlgorithm(algo) {
  selectedAlgorithm = algo;
  document.getElementById('algAstar').classList.toggle('active', algo === 'astar');
  document.getElementById('algQl').classList.toggle('active', algo === 'qlearning');
  log("알고리즘 변경 → " + (algo === 'astar' ? "A* 최단경로" : "Q-러닝 (강화학습)"));
}

function selectTransport(type) {
  selectedTransport = type;
  ['Walk','Robot','Cart','Agv'].forEach(t => {
    document.getElementById('trans'+t).classList.toggle('active', t.toLowerCase() === type);
  });
  log("이동수단 변경 → " + type.toUpperCase());
}

function changeStart() { drawMap(); log("출발지 변경 → " + nodes[document.getElementById('startNode').value].name); }
function changeEnd() { drawMap(); log("목적지 변경 → " + nodes[document.getElementById('endNode').value].name); }

function updateCargoInfo() {
  log("화물 사양 변경 → " + document.getElementById('cargoType').selectedOptions[0].text);
}

function validateRoute(route) {
  const cargo = document.getElementById('cargoType').value;
  const weight = cargo === 'normal' ? 40 : (cargo === 'server' ? 80 : 180);
  const width = cargo === 'normal' ? 0.7 : (cargo === 'server' ? 0.9 : 1.4);

  const limits = { walk:30, robot:80, cart:150, agv:250 };
  const cap = limits[selectedTransport];

  if (weight > cap) return { ok: false, reason: "화물 무게(" + weight + "kg) > 적재한도(" + cap + "kg)" };
  if (width > route.minWidth) return { ok: false, reason: "화물 폭(" + width + "m) > 통로폭(" + route.minWidth + "m)" };
  if (document.getElementById('chkElevator').checked && route.elevator) return { ok: false, reason: "엘리베이터 고장/점검 중" };
  if ((document.getElementById('chkConstruction').checked || dynamicObstacleActive) && route.id === "R1") return { ok: false, reason: "운동장/중앙로 공사구간 통과 불가" };

  // 직접 지정 장애물 확인
  for (let i = 0; i < route.path.length; i++) {
    const nodeKey = route.path[i];
    if (isNodeBlockedByObstacles(nodeKey)) {
      return { ok: false, reason: "경로상 노드가 장애물과 겹침" };
    }

    if (i < route.path.length - 1) {
      const nextNodeKey = route.path[i + 1];
      if (isEdgeBlockedByObstacles(nodeKey, nextNodeKey)) {
        return { ok: false, reason: "경로상 간선이 장애물과 겹침" };
      }
    }
  }

  return { ok: true };
}

function getEdgeDistance(n1Key, n2Key) {
  const n1 = nodes[n1Key];
  const n2 = nodes[n2Key];
  if (!n1 || !n2) return Infinity;

  const dx = n2.x - n1.x;
  const dy = n2.y - n1.y;
  return Math.sqrt(dx * dx + dy * dy);
}

function buildAdjacencyList() {
  const adj = {};
  for (let key in nodes) adj[key] = [];

  for (let edge of edges) {
    const [u, v] = edge;
    if (!nodes[u] || !nodes[v]) continue;
    adj[u].push(v);
    adj[v].push(u);
  }
  return adj;
}

function dijkstra(startKey, endKey, costFunc) {
  const adj = buildAdjacencyList();
  const dist = {};
  const prev = {};
  const visited = new Set();

  for (let key in nodes) {
    dist[key] = Infinity;
    prev[key] = null;
  }
  dist[startKey] = 0;

  while (visited.size < Object.keys(nodes).length) {
    let minDist = Infinity;
    let minKey = null;

    for (let key in nodes) {
      if (!visited.has(key) && dist[key] < minDist) {
        minDist = dist[key];
        minKey = key;
      }
    }

    if (minKey === null || minKey === endKey) break;
    visited.add(minKey);

    for (let neighbor of adj[minKey]) {
      const edgeCost = costFunc(minKey, neighbor);
      const newDist = dist[minKey] + edgeCost;

      if (newDist < dist[neighbor]) {
        dist[neighbor] = newDist;
        prev[neighbor] = minKey;
      }
    }
  }

  if (dist[endKey] === Infinity) return null;

  const path = [];
  let current = endKey;
  while (current !== null) {
    path.unshift(current);
    current = prev[current];
  }
  return path;
}

function calculatePathStats(pathKeys) {
  let totalDistance = 0;
  for (let i = 0; i < pathKeys.length - 1; i++) {
    totalDistance += getEdgeDistance(pathKeys[i], pathKeys[i + 1]);
  }
  return {
    distance: Math.round(totalDistance),
    time: Math.round(totalDistance * 0.8),
    pathKeys: pathKeys
  };
}

function calculateCost(pathKeys) {
  const mode = document.getElementById('optMode').value;
  let dW=0.3, tW=0.25, cW=0.2, rW=0.15, sW=0.1;

  if (mode === "distance") { dW=0.6; tW=0.2; cW=0.1; rW=0.05; sW=0.05; }
  else if (mode === "safe") { dW=0.15; tW=0.15; cW=0.2; rW=0.4; sW=0.1; }
  else if (mode === "time") { dW=0.2; tW=0.5; cW=0.15; rW=0.1; sW=0.05; }

  const stats = calculatePathStats(pathKeys);
  let cost = stats.distance * dW + stats.time * tW;

  if (document.getElementById('chkRain').checked) cost += stats.distance * 0.3;
  if (document.getElementById('chkSnow').checked) cost += stats.distance * 0.7;

  return cost;
}

function isPathBlocked(pathKeys) {
  for (let i = 0; i < pathKeys.length; i++) {
    const nodeKey = pathKeys[i];

    if (isNodeBlockedByObstacles(nodeKey)) {
      return { blocked: true, reason: "경로상 노드가 장애물과 겹침" };
    }

    if (i < pathKeys.length - 1) {
      const nextNodeKey = pathKeys[i + 1];
      if (isEdgeBlockedByObstacles(nodeKey, nextNodeKey)) {
        return { blocked: true, reason: "경로상 간선이 장애물과 겹침" };
      }
    }
  }

  if ((document.getElementById('chkConstruction').checked || dynamicObstacleActive) &&
      (pathKeys.includes("STU_HALL") && pathKeys.includes("SANHAK"))) {
    const sIdx = pathKeys.indexOf("STU_HALL");
    const sIdx2 = pathKeys.indexOf("SANHAK");
    if (Math.abs(sIdx - sIdx2) === 1) {
      return { blocked: true, reason: "운동장/중앙로 공사구간 통과 불가" };
    }
  }

  if (document.getElementById('chkElevator').checked) {
    for (let key of pathKeys) {
      if (key === "LIBRARY" || key === "DORM_1") {
        return { blocked: true, reason: "엘리베이터 고장/점검 중" };
      }
    }
  }

  return { blocked: false };
}


async function searchOptimalPath() {
  activeRoute = null;
  document.getElementById('searchResult').innerHTML = "";
  document.getElementById('btnStartSim').style.display = "none";
  setStatus("AI 경로 탐색 중...", "bg-warning text-dark");
  log("======================================");
  log(selectedAlgorithm.toUpperCase() + " 기반 경로 탐색 실시");

  const startKey = document.getElementById('startNode').value;
  const endKey = document.getElementById('endNode').value;

  if (startKey === endKey) {
    setStatus("경로 탐색 불가", "bg-warning");
    document.getElementById('searchResult').innerHTML = "<div class='candidate'><b>⚠ 출발지와 목적지가 같습니다</b></div>";
    log("⚠ 출발지와 목적지가 같습니다");
    return;
  }

  let candidates = [];

  // R1: 거리 최단 경로
  const pathR1 = dijkstra(startKey, endKey, (u, v) => getEdgeDistance(u, v));
  if (pathR1) {
    const check = isPathBlocked(pathR1);
    if (!check.blocked) {
      const stats = calculatePathStats(pathR1);
      const cost = calculateCost(pathR1);
      candidates.push({
        name: "최단거리 경로",
        path: pathR1,
        distance: stats.distance,
        time: stats.time,
        cost: cost,
        type: "R1"
      });
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate'><b>🔍 최단거리 경로</b><br>거리: " + stats.distance + "m | 예상시간: " + stats.time + "초<br><b>AI Cost: " + cost.toFixed(1) + "</b></div>";
      log("후보 R1 검증 통과 (Cost: " + cost.toFixed(1) + ")");
    } else {
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate reject'><b>❌ 최단거리 경로</b><br>사유: " + check.reason + "</div>";
      log("후보 R1 제외 → " + check.reason);
    }
  }
  await sleep(200);

  // R2: 안전/경사도 기준 경로 (다른 가중치 사용)
  const optModeBackup = document.getElementById('optMode').value;
  document.getElementById('optMode').value = 'safe';

  const pathR2 = dijkstra(startKey, endKey, (u, v) => {
    const dist = getEdgeDistance(u, v);
    let penalty = dist;
    if (document.getElementById('chkRain').checked) penalty += dist * 0.3;
    if (document.getElementById('chkSnow').checked) penalty += dist * 0.7;
    return penalty;
  });

  document.getElementById('optMode').value = optModeBackup;

  if (pathR2 && pathR2.join(',') !== pathR1?.join(',')) {
    const check = isPathBlocked(pathR2);
    if (!check.blocked) {
      const stats = calculatePathStats(pathR2);
      const cost = calculateCost(pathR2);
      candidates.push({
        name: "안전경로",
        path: pathR2,
        distance: stats.distance,
        time: stats.time,
        cost: cost,
        type: "R2"
      });
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate'><b>🔍 안전경로</b><br>거리: " + stats.distance + "m | 예상시간: " + stats.time + "초<br><b>AI Cost: " + cost.toFixed(1) + "</b></div>";
      log("후보 R2 검증 통과 (Cost: " + cost.toFixed(1) + ")");
    } else {
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate reject'><b>❌ 안전경로</b><br>사유: " + check.reason + "</div>";
      log("후보 R2 제외 → " + check.reason);
    }
  } else if (pathR2?.join(',') === pathR1?.join(',')) {
    log("후보 R2 생략 (R1과 동일)");
  }
  await sleep(200);

  // R3: 우회 경로 (R1 회피)
  const pathR3 = dijkstra(startKey, endKey, (u, v) => {
    const dist = getEdgeDistance(u, v);
    if (pathR1 && pathR1.length >= 2) {
      for (let i = 0; i < pathR1.length - 1; i++) {
        if ((pathR1[i] === u && pathR1[i+1] === v) || (pathR1[i] === v && pathR1[i+1] === u)) {
          return dist * 5;
        }
      }
    }
    return dist;
  });

  if (pathR3 && pathR3.join(',') !== pathR1?.join(',') && pathR3.join(',') !== pathR2?.join(',')) {
    const check = isPathBlocked(pathR3);
    if (!check.blocked) {
      const stats = calculatePathStats(pathR3);
      const cost = calculateCost(pathR3);
      candidates.push({
        name: "우회경로",
        path: pathR3,
        distance: stats.distance,
        time: stats.time,
        cost: cost,
        type: "R3"
      });
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate'><b>🔍 우회경로</b><br>거리: " + stats.distance + "m | 예상시간: " + stats.time + "초<br><b>AI Cost: " + cost.toFixed(1) + "</b></div>";
      log("후보 R3 검증 통과 (Cost: " + cost.toFixed(1) + ")");
    } else {
      document.getElementById('searchResult').innerHTML +=
        "<div class='candidate reject'><b>❌ 우회경로</b><br>사유: " + check.reason + "</div>";
      log("후보 R3 제외 → " + check.reason);
    }
  } else if (pathR3?.join(',') === pathR1?.join(',') || pathR3?.join(',') === pathR2?.join(',')) {
    log("후보 R3 생략 (기존 후보와 동일)");
  }

  if (candidates.length === 0) {
    setStatus("운송 불가", "bg-danger");
    document.getElementById('comparisonResult').innerHTML = "<div class='alert alert-danger p-2' style='font-size:12px;'>조건을 만족하는 이동 경로가 없습니다. 이동체나 환경 설정을 변경하십시오.</div>";
    const hasObstacles = obstacles.length > 0;
    log("❌ 조건에 맞는 경로 없음" + (hasObstacles ? " (우회 경로 없음)" : ""));
    return;
  }

  candidates.sort((a, b) => a.cost - b.cost);
  activeRoute = { path: candidates[0].path, name: candidates[0].name };

  renderComparisonDynamic(candidates[0]);
  setStatus("최적경로 결정", "bg-primary");
  document.getElementById('btnStartSim').style.display = "block";
  drawMap();
  log("★ 최적 경로 선정 완료 → " + candidates[0].name + " (" + candidates[0].distance + "m)");
}

function renderComparisonDynamic(candidate) {
  let html = "<table class='table table-bordered table-sm' style='font-size:11px;margin-bottom:8px;'>"+
    "<thead class='table-light'><tr><th>항목</th><th>값</th></tr></thead>"+
    "<tbody>"+
    "<tr><td>경로명</td><td><b>" + candidate.name + "</b></td></tr>"+
    "<tr><td>경유 노드</td><td><b>" + candidate.path.map(k => nodes[k].name).join(" → ") + "</b></td></tr>"+
    "<tr><td>총 거리</td><td>" + candidate.distance + "m</td></tr>"+
    "<tr><td>예상 시간</td><td>" + candidate.time + "초</td></tr>"+
    "<tr><td>AI Cost</td><td><b style='color:var(--blue);'>" + candidate.cost.toFixed(1) + "</b></td></tr>"+
    "</tbody></table>"+
    "<div class='alert alert-info p-2 mb-0' style='font-size:11px;'><b>🤖 AI Decision:</b> 선택된 출발지와 목적지에 최적화된 경로를 계산했습니다.</div>";

  document.getElementById('comparisonResult').innerHTML = html;
}

function startTransport() {
  if (!activeRoute) return;
  if (animTimer) clearInterval(animTimer);

  currentStep = 0;
  setStatus("운송 이동 중", "bg-success");

  const pathStr = activeRoute.path.map(k => nodes[k].name).join(" → ");
  log("🚚 운송 시뮬레이션 시작: " + pathStr);

  let totalDistance = 0;
  for (let i = 0; i < activeRoute.path.length - 1; i++) {
    totalDistance += getEdgeDistance(activeRoute.path[i], activeRoute.path[i + 1]);
  }

  let totalSteps = 100;
  animTimer = setInterval(() => {
    currentStep++;
    let ratio = Math.min(1.0, currentStep / totalSteps);
    let progressPercent = Math.round(ratio * 100);

    document.getElementById('progressBar').style.width = progressPercent + "%";
    document.getElementById('progressText').textContent = progressPercent + "%";

    drawMap(ratio);

    if (currentStep >= totalSteps) {
      clearInterval(animTimer);
      setStatus("운송 완료", "bg-success");
      log("✅ 목적지 안전 도착 완료!");
    }
  }, 60);
}

async function triggerDynamicObstacle() {
  dynamicObstacleActive = true;
  document.getElementById('chkConstruction').checked = true;
  drawMap();
  setStatus("돌발 장애물 감지", "bg-danger");
  log("⚠ 전방 장애물 감지! Dynamic Re-routing을 시작합니다.");
  await sleep(600);
  await searchOptimalPath();
}

function resizeCanvas() {
  const canvas = document.getElementById('simCanvas');
  const wrap = document.getElementById('simWrap');

  canvas.width = wrap.offsetWidth;
  canvas.height = wrap.offsetHeight;
}

function drawMap(progressRatio = 0) {
  const canvas = document.getElementById('simCanvas');
  const ctx = canvas.getContext('2d');

  // 스케일 팩터 계산 (canvas 크기 / 원본 이미지 크기)
  const scaleX = canvas.width / CAMPUS_IMAGE.width;
  const scaleY = canvas.height / CAMPUS_IMAGE.height;

  ctx.clearRect(0, 0, canvas.width, canvas.height);

  // 0. 배경 이미지 그리기 (노드맵 최적화)
  if (nodeConfig.showImage && backgroundImg.complete) {
    ctx.drawImage(backgroundImg, 0, 0, canvas.width, canvas.height);
  }

  // 1. 도로망 연결선

  // 기본 도로망 그리기 (반투명)
  ctx.strokeStyle = nodeConfig.edgeColor;
  ctx.lineWidth = nodeConfig.edgeWidth;
  ctx.globalAlpha = 0.6;
  edges.forEach(e => {
    let p1 = nodes[e[0]], p2 = nodes[e[1]];
    if (p1 && p2) {
      ctx.beginPath();
      ctx.moveTo(p1.x * scaleX, p1.y * scaleY);
      ctx.lineTo(p2.x * scaleX, p2.y * scaleY);
      ctx.stroke();
    }
  });
  ctx.globalAlpha = 1.0;

  // 2. 최적 경로 하이라이트 (강조)
  if (activeRoute) {
    ctx.strokeStyle = nodeConfig.selectedEdgeColor;
    ctx.lineWidth = nodeConfig.selectedEdgeWidth;
    ctx.lineCap = 'round';
    ctx.lineJoin = 'round';
    ctx.beginPath();
    for (let i = 0; i < activeRoute.path.length; i++) {
      let p = nodes[activeRoute.path[i]];
      if (p) {
        if (i === 0) ctx.moveTo(p.x * scaleX, p.y * scaleY);
        else ctx.lineTo(p.x * scaleX, p.y * scaleY);
      }
    }
    ctx.stroke();
  }

  // 3. 노드 포인트 그리기 (navigationTest1.jsp 스타일로 통일)
  const t = Date.now() / 1000;
  const pulse = (Math.sin(t * 1.8 * Math.PI * 2) + 1) / 2;

  for (let key in nodes) {
    let n = nodes[key];

    // invisible 노드는 표시하지 않음
    if (n.isInvisible) continue;

    const isOnActiveRoute = activeRoute && activeRoute.path.includes(key);
    const c = '26,86,219';

    // 스케일된 좌표
    const sx = n.x * scaleX;
    const sy = n.y * scaleY;

    if (isOnActiveRoute) {
      // 활성 경로 노드: 팽창하는 파동 링
      const waveR = 18 + pulse * 16;
      const waveA = 0.55 - pulse * 0.5;
      ctx.beginPath();
      ctx.arc(sx, sy, waveR, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(' + c + ',' + waveA + ')';
      ctx.fill();

      // 두 번째 파동 (위상 반전)
      const wave2R = 18 + (1 - pulse) * 10;
      const wave2A = 0.25 - (1 - pulse) * 0.22;
      ctx.beginPath();
      ctx.arc(sx, sy, wave2R, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(' + c + ',' + wave2A + ')';
      ctx.fill();
    } else {
      // 일반 노드: 고정 글로우
      ctx.beginPath();
      ctx.arc(sx, sy, 20, 0, Math.PI * 2);
      ctx.fillStyle = 'rgba(' + c + ',0.15)';
      ctx.fill();
    }

    // 중간 링 (반경 13px)
    ctx.beginPath();
    ctx.arc(sx, sy, 13, 0, Math.PI * 2);
    ctx.fillStyle = 'rgba(' + c + ',' + (isOnActiveRoute ? 0.5 : 0.35) + ')';
    ctx.fill();

    // 중앙 원 — 반경 9px, 파란색 #1a56db
    ctx.beginPath();
    ctx.arc(sx, sy, 9, 0, Math.PI * 2);
    ctx.fillStyle = '#1a56db';
    ctx.fill();

    // 활성화 시 흰색 테두리 추가
    if (isOnActiveRoute) {
      ctx.strokeStyle = '#fff';
      ctx.lineWidth = 2;
      ctx.stroke();
    }

    // 흰 점 (반경 3.5px)
    ctx.beginPath();
    ctx.arc(sx, sy, 3.5, 0, Math.PI * 2);
    ctx.fillStyle = '#fff';
    ctx.fill();

    // 노드 레이블 (navigationTest1.jsp와 동일)
    if (nodeConfig.showNodeLabels) {
      const label = n.name;
      ctx.font = 'bold 10px "Noto Sans KR", sans-serif';
      ctx.textAlign = 'center';
      ctx.textBaseline = 'bottom';
      const tw = ctx.measureText(label).width;
      ctx.fillStyle = 'rgba(0,0,0,.65)';
      ctx.beginPath();
      ctx.roundRect(sx - tw/2 - 3, sy - 26, tw + 6, 16, 3);
      ctx.fill();
      ctx.fillStyle = '#fff';
      ctx.fillText(label, sx, sy - 12);
    }
  }

  // 4. 출발지 / 목적지 마커
  let startKey = document.getElementById('startNode').value;
  let endKey = document.getElementById('endNode').value;

  if (nodes[startKey]) {
    const sn = nodes[startKey];
    drawMarker(ctx, { x: sn.x * scaleX, y: sn.y * scaleY }, "출발", "#16a34a");
  }
  if (nodes[endKey]) {
    const en = nodes[endKey];
    drawMarker(ctx, { x: en.x * scaleX, y: en.y * scaleY }, "목적지", "#dc2626");
  }

  // 5. 고정 공사 장애물 표시
  if (document.getElementById('chkConstruction').checked || dynamicObstacleActive) {
    let c = nodes["ENG_1"];
    const cx = (c.x + 70) * scaleX;
    const cy = (c.y + 10) * scaleY;
    ctx.fillStyle = "rgba(220, 38, 38, 0.5)";
    ctx.beginPath();
    ctx.arc(cx, cy, 28, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#dc2626";
    ctx.lineWidth = 2;
    ctx.stroke();
    ctx.fillStyle = "#dc2626";
    ctx.font = "bold 12px 'Noto Sans KR', sans-serif";
    ctx.textAlign = 'center';
    ctx.fillText("🚧 공사", cx, cy);
  }

  // 5-2. 직접 지정 장애물 표시
  for (let obs of obstacles) {
    const obsCenterX = (canvas.width / 100) * obs.x;
    const obsCenterY = (canvas.height / 100) * obs.y;
    const obsRadiusPx = (canvas.width / 100) * obs.radiusPercent;

    ctx.fillStyle = "rgba(239, 68, 68, 0.4)";
    ctx.beginPath();
    ctx.arc(obsCenterX, obsCenterY, obsRadiusPx, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#ef4444";
    ctx.lineWidth = 2;
    ctx.stroke();
  }

  // 6. 이동체 애니메이션
  if (activeRoute && progressRatio > 0) {
    let pos = getPathPosition(activeRoute.path, progressRatio);
    const px = pos.x * scaleX;
    const py = pos.y * scaleY;
    // 글로우
    ctx.fillStyle = "rgba(245, 158, 11, 0.4)";
    ctx.beginPath();
    ctx.arc(px, py, 14, 0, Math.PI * 2);
    ctx.fill();
    // 본체
    ctx.fillStyle = "#f59e0b";
    ctx.beginPath();
    ctx.arc(px, py, 8, 0, Math.PI * 2);
    ctx.fill();
    ctx.strokeStyle = "#ffffff";
    ctx.lineWidth = 2;
    ctx.stroke();
  }
}

function drawMarker(ctx, node, label, color) {
  // navigationTest1.jsp drawMarker와 동일한 스타일
  // 메인 마커 (반경 11px, 컬러 유지)
  ctx.fillStyle = color;
  ctx.beginPath();
  ctx.arc(node.x, node.y, 11, 0, Math.PI * 2);
  ctx.fill();

  // 테두리 (흰색)
  ctx.strokeStyle = "#ffffff";
  ctx.lineWidth = 2;
  ctx.stroke();

  // 흰 점
  ctx.beginPath();
  ctx.arc(node.x, node.y, 3.5, 0, Math.PI * 2);
  ctx.fillStyle = '#fff';
  ctx.fill();

  // 이름 레이블 (검은 배경 박스)
  ctx.font = 'bold 10px "Noto Sans KR", sans-serif';
  ctx.textAlign = 'center';
  ctx.textBaseline = 'bottom';
  const tw = ctx.measureText(label).width;
  ctx.fillStyle = 'rgba(0,0,0,.65)';
  ctx.beginPath();
  ctx.roundRect(node.x - tw/2 - 3, node.y - 26, tw + 6, 16, 3);
  ctx.fill();
  ctx.fillStyle = '#fff';
  ctx.fillText(label, node.x, node.y - 12);
}

function getPathPosition(pathKeys, ratio) {
  if (pathKeys.length < 2) return nodes[pathKeys[0]];

  // 전체 경로 거리 계산
  let totalDistance = 0;
  const segmentDistances = [];

  for (let i = 0; i < pathKeys.length - 1; i++) {
    const dist = getEdgeDistance(pathKeys[i], pathKeys[i + 1]);
    segmentDistances.push(dist);
    totalDistance += dist;
  }

  // 목표 거리
  const targetDistance = totalDistance * ratio;
  let currentDistance = 0;

  // 어느 세그먼트에 있는지 찾기
  for (let i = 0; i < segmentDistances.length; i++) {
    if (currentDistance + segmentDistances[i] >= targetDistance) {
      const p1 = nodes[pathKeys[i]];
      const p2 = nodes[pathKeys[i + 1]];

      // 이 세그먼트 내에서의 비율
      const segmentRatio = (targetDistance - currentDistance) / segmentDistances[i];

      return {
        x: p1.x + (p2.x - p1.x) * segmentRatio,
        y: p1.y + (p2.y - p1.y) * segmentRatio
      };
    }
    currentDistance += segmentDistances[i];
  }

  // 끝점 반환
  const lastKey = pathKeys[pathKeys.length - 1];
  return nodes[lastKey];
}

function setStatus(text, bgClass) {
  let badge = document.getElementById('statusBadge');
  badge.textContent = text;
  badge.className = "badge " + bgClass;
}

function log(msg) {
  let consoleEl = document.getElementById('logConsole');
  consoleEl.innerHTML += "<br>AI &gt; " + msg;
  consoleEl.scrollTop = consoleEl.scrollHeight;
}

function sleep(ms) { return new Promise(r => setTimeout(r, ms)); }

function toggleImageBackground() {
  nodeConfig.showImage = document.getElementById('chkShowImage').checked;
  drawMap();
  log("평면도 배경 " + (nodeConfig.showImage ? "표시" : "숨김"));
}

function toggleNodeLabels() {
  nodeConfig.showNodeLabels = document.getElementById('chkShowLabels').checked;
  drawMap();
  log("노드 레이블 " + (nodeConfig.showNodeLabels ? "표시" : "숨김"));
}

function toggleObstacleMode() {
  obstacleMode = !obstacleMode;
  const btn = document.getElementById('btnObstacleMode');
  const info = document.getElementById('obstacleInfo');

  if (obstacleMode) {
    btn.classList.add('active');
    btn.style.background = '#f59e0b';
    btn.style.color = '#fff';
    info.style.display = 'block';
    log("🎯 장애물 지정 모드 ON - 평면도를 클릭하여 장애물을 추가하세요");
  } else {
    btn.classList.remove('active');
    btn.style.background = '#fef3c7';
    btn.style.color = '#b45309';
    info.style.display = 'none';
    log("장애물 지정 모드 OFF");
  }
  drawMap();
}

function clearAllObstacles() {
  obstacles = [];
  log("🗑️ 모든 장애물이 삭제되었습니다");
  drawMap();
}

function handleCanvasClick(event) {
  if (!obstacleMode) return;

  const canvas = document.getElementById('simCanvas');
  const wrap = document.getElementById('simWrap');
  const rect = canvas.getBoundingClientRect();

  const clickX = event.clientX - rect.left;
  const clickY = event.clientY - rect.top;

  // 캔버스 좌표 → 이미지 좌표 (퍼센트)
  const percentX = (clickX / canvas.width) * 100;
  const percentY = (clickY / canvas.height) * 100;

  // 반경 (원본 이미지 가로 대비 4%)
  const radiusPercent = OBSTACLE_RADIUS_PERCENT;
  const radiusPx = (canvas.width / 100) * radiusPercent;

  // 기존 장애물 클릭했는지 확인
  let clickedObstacle = -1;
  for (let i = 0; i < obstacles.length; i++) {
    const obsRadiusPx = (canvas.width / 100) * obstacles[i].radiusPercent;
    const obsCenterX = (canvas.width / 100) * obstacles[i].x;
    const obsCenterY = (canvas.height / 100) * obstacles[i].y;

    const dx = clickX - obsCenterX;
    const dy = clickY - obsCenterY;

    if (Math.sqrt(dx * dx + dy * dy) <= obsRadiusPx) {
      clickedObstacle = i;
      break;
    }
  }

  if (clickedObstacle >= 0) {
    obstacles.splice(clickedObstacle, 1);
    log("🗑️ 장애물이 삭제되었습니다 (" + obstacles.length + "개 남음)");
  } else {
    obstacles.push({ x: percentX, y: percentY, radiusPercent: radiusPercent });
    log("📍 장애물이 추가되었습니다 (" + obstacles.length + "개)");
  }

  drawMap();
}

function isNodeBlockedByObstacles(nodeKey) {
  const node = nodes[nodeKey];
  if (!node) return false;

  const canvas = document.getElementById('simCanvas');
  const nodeX = (node.x / CAMPUS_IMAGE.width) * 100;
  const nodeY = (node.y / CAMPUS_IMAGE.height) * 100;

  for (let obs of obstacles) {
    const dx = nodeX - obs.x;
    const dy = nodeY - obs.y;
    const dist = Math.sqrt(dx * dx + dy * dy);

    // 퍼센트 기반 거리 비교
    if (dist <= obs.radiusPercent) {
      return true;
    }
  }
  return false;
}

function isEdgeBlockedByObstacles(nodeKey1, nodeKey2) {
  const n1 = nodes[nodeKey1];
  const n2 = nodes[nodeKey2];
  if (!n1 || !n2) return false;

  const n1X = (n1.x / CAMPUS_IMAGE.width) * 100;
  const n1Y = (n1.y / CAMPUS_IMAGE.height) * 100;
  const n2X = (n2.x / CAMPUS_IMAGE.width) * 100;
  const n2Y = (n2.y / CAMPUS_IMAGE.height) * 100;

  for (let obs of obstacles) {
    // 선분과 원의 충돌 판정
    const closestDist = pointToLineSegmentDistance(obs.x, obs.y, n1X, n1Y, n2X, n2Y);
    if (closestDist <= obs.radiusPercent) {
      return true;
    }
  }
  return false;
}

function pointToLineSegmentDistance(px, py, x1, y1, x2, y2) {
  const dx = x2 - x1;
  const dy = y2 - y1;
  const t = Math.max(0, Math.min(1, ((px - x1) * dx + (py - y1) * dy) / (dx * dx + dy * dy)));

  const closestX = x1 + t * dx;
  const closestY = y1 + t * dy;

  const dpx = px - closestX;
  const dpy = py - closestY;
  return Math.sqrt(dpx * dpx + dpy * dpy);
}

function toggleTheme() {
  const html = document.documentElement;
  const currentTheme = html.getAttribute('data-theme');
  const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
  html.setAttribute('data-theme', newTheme);
  localStorage.setItem('theme', newTheme);
  updateThemeIcon();
}

function updateThemeIcon() {
  const icon = document.getElementById('themeIcon');
  const html = document.documentElement;
  const theme = html.getAttribute('data-theme');

  if (theme === 'dark') {
    icon.className = 'bi bi-sun';
  } else {
    icon.className = 'bi bi-moon';
  }
}
</script>

</body>
</html>