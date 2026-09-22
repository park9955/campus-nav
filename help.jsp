<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>실행 방법</title>

<link rel="preconnect" href="https://fonts.googleapis.com">
<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Plus+Jakarta+Sans:wght@700;800&family=Pretendard:wght@400;500;600;700;800&family=JetBrains+Mono:wght@600;700&display=swap" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">

<style>
:root {
  --bg-app: #f0f4f9;
  --surface: #ffffff;
  --txt-main: #0f172a;
  --txt-sub: #334155;
  --sky-primary: #0284c7;
  --sky-light: #e0f2fe;
  --sky-bg: #f0f9ff;
  --emerald-main: #16a34a;
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-pill: 999px;
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
  --font-mono: 'JetBrains Mono', monospace;
}

body {
  font-family: var(--font-main);
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
  background-repeat: no-repeat;
  color: var(--txt-main);
  line-height: 1.6;
  margin: 0;
  padding: 0;
  min-height: 100vh;
}

a { text-decoration: none; color: inherit; }

.app-header {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  position: sticky;
  top: 0;
  z-index: 1000;
  border-bottom: 1px solid rgba(226, 232, 240, 0.8);
}

.brand-logo {
  font-family: 'Plus Jakarta Sans', sans-serif;
  font-weight: 800;
  font-size: 1.35rem;
  color: var(--txt-main);
  display: flex;
  align-items: center;
  gap: 10px;
}

.brand-badge {
  background: linear-gradient(135deg, #38bdf8 0%, #0284c7 100%);
  color: #ffffff;
  font-size: 0.68rem;
  font-weight: 800;
  padding: 3px 9px;
  border-radius: var(--radius-pill);
}

.nav-link-btn {
  font-weight: 700;
  font-size: 0.925rem;
  color: var(--txt-sub);
  padding: 8px 18px;
  border-radius: var(--radius-pill);
  transition: all 0.2s ease;
  display: inline-flex;
  align-items: center;
  gap: 6px;
}

.nav-link-btn:hover {
  background: var(--sky-bg);
  color: var(--sky-primary);
}

.section-title {
  font-size: 1.25rem;
  font-weight: 800;
  margin-bottom: 1.25rem;
  display: flex;
  align-items: center;
  gap: 8px;
}

.borderless-card {
  background: var(--surface);
  border-radius: var(--radius-xl);
  padding: 2.25rem;
  box-shadow: var(--shadow-soft);
  margin-bottom: 2rem;
  border: 1px solid #f1f5f9;
}

.step-item {
  display: flex;
  gap: 1.5rem;
  margin-bottom: 1.5rem;
  padding-bottom: 1.5rem;
  border-bottom: 1px solid #f1f5f9;
}

.step-number {
  display: flex;
  align-items: center;
  justify-content: center;
  width: 3rem;
  height: 3rem;
  border-radius: 50%;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: #ffffff;
  font-weight: 800;
  font-size: 1.2rem;
  flex-shrink: 0;
}

.step-content h3 {
  font-weight: 800;
  margin-bottom: 0.5rem;
  font-size: 1.1rem;
}

.step-content p {
  margin: 0;
  color: var(--txt-sub);
}

code {
  background: #f8fafc;
  padding: 0.25rem 0.6rem;
  border-radius: 4px;
  font-family: var(--font-mono);
  color: var(--sky-primary);
  font-weight: 600;
}

.alert-box {
  padding: 1rem;
  background: #fef3c7;
  border: 1px solid #fcd34d;
  border-radius: var(--radius-lg);
  color: #b45309;
  margin-bottom: 1.5rem;
}

.success-box {
  padding: 1rem;
  background: #dcfce7;
  border: 1px solid #86efac;
  border-radius: var(--radius-lg);
  color: #15803d;
  margin-bottom: 1.5rem;
}

.table-ai {
  width: 100%;
  border-collapse: collapse;
  font-size: 0.9rem;
}

.table-ai th {
  background: #f8fafc;
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
  font-weight: 700;
  text-align: left;
}

.table-ai td {
  padding: 0.75rem;
  border: 1px solid #e2e8f0;
}

.app-footer {
  background: var(--surface);
  border-top: 1px solid #e2e8f0;
  color: var(--txt-sub);
  padding: 2.5rem 0;
  margin-top: 4rem;
  font-size: 0.875rem;
}
</style>
</head>
<body>

<header class="app-header">
  <div class="container-fluid px-4 px-md-5">
    <nav class="navbar navbar-expand-lg py-2.5 px-0">
      <a class="brand-logo" href="dashboard.jsp">
        <i class="bi bi-truck-front text-info fs-3"></i>
        <span>운송 <strong>관리</strong></span>
        <span class="brand-badge">ADMIN</span>
      </a>
      <button class="navbar-toggler border-0" type="button" data-bs-toggle="collapse" data-bs-target="#appNavbar">
        <span class="navbar-toggler-icon"></span>
      </button>
      <div class="collapse navbar-collapse" id="appNavbar">
        <ul class="navbar-nav ms-auto align-items-lg-center gap-lg-1 mt-3 mt-lg-0">
          <li class="nav-item"><a class="nav-link-btn" href="help.jsp"><i class="bi bi-question-circle"></i> 도움말</a></li>
          <li class="nav-item"><a class="nav-link-btn" href="dashboard.jsp"><i class="bi bi-speedometer2"></i> 대시보드</a></li>
        </ul>
      </div>
    </nav>
  </div>
</header>

<main class="container-xl pb-5">

  <section class="mt-4">
    <div class="section-title">
      <i class="bi bi-book text-info"></i> 시스템 설치 및 실행 방법
    </div>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4">설치 및 실행 가이드</h2>

    <div class="alert-box">
      <strong><i class="bi bi-exclamation-triangle me-2"></i>필수 요구사항</strong><br>
      Java 17, Tomcat 10.1 이상, MySQL 8.x가 필요합니다.
    </div>

    <div class="step-item">
      <div class="step-number">1</div>
      <div class="step-content">
        <h3>필수 소프트웨어 설치</h3>
        <p>Java 17 JDK, Apache Tomcat 10.1 이상, MySQL 8.x Server를 설치합니다.</p>
      </div>
    </div>

    <div class="step-item">
      <div class="step-number">2</div>
      <div class="step-content">
        <h3>MySQL 비밀번호 확인</h3>
        <p>MySQL root 비밀번호가 <code>1234</code>가 아니라면 <code>db.jsp</code>와 <code>initDb.jsp</code>의 PASSWORD 변수를 수정합니다.</p>
      </div>
    </div>

    <div class="step-item">
      <div class="step-number">3</div>
      <div class="step-content">
        <h3>파일 복사</h3>
        <p>모든 JSP 파일을 <code>Tomcat webapps/school-cart/</code> 디렉토리에 복사합니다.</p>
      </div>
    </div>

    <div class="step-item">
      <div class="step-number">4</div>
      <div class="step-content">
        <h3>MySQL JDBC 드라이버 설치</h3>
        <p><code>MySQL Connector/J</code> JAR 파일을 <code>Tomcat/lib</code> 폴더에 배치합니다.</p>
      </div>
    </div>

    <div class="step-item">
      <div class="step-number">5</div>
      <div class="step-content">
        <h3>데이터베이스 초기화</h3>
        <p><code>http://localhost:8080/school-cart/initDb.jsp</code>를 브라우저에서 열어 DB 초기화 버튼을 클릭합니다.</p>
      </div>
    </div>

    <div class="step-item">
      <div class="step-number">6</div>
      <div class="step-content">
        <h3>대시보드 접속</h3>
        <p><code>http://localhost:8080/school-cart/dashboard.jsp</code>로 접속하여 시스템을 사용합니다.</p>
      </div>
    </div>

  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4">생성되는 테이블 목록</h2>

    <div class="table-responsive">
      <table class="table-ai">
        <thead>
          <tr>
            <th>테이블명</th>
            <th>용도</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td><code>resources</code></td>
            <td>학교 기자재·실습장비·도서·소모품</td>
          </tr>
          <tr>
            <td><code>locations</code></td>
            <td>출발지·목표지 및 건물/층/위치 정보</td>
          </tr>
          <tr>
            <td><code>vehicles</code></td>
            <td>AGV·자율주행 카트 운송체 정보</td>
          </tr>
          <tr>
            <td><code>route_nodes</code></td>
            <td>경로상의 위치 Node</td>
          </tr>
          <tr>
            <td><code>route_edges</code></td>
            <td>Node 사이의 이동 통로 Edge</td>
          </tr>
          <tr>
            <td><code>transport_requests</code></td>
            <td>운송 요청 및 진행상태</td>
          </tr>
          <tr>
            <td><code>obstacles</code></td>
            <td>공사·통제·사람·차량 등의 장애물</td>
          </tr>
          <tr>
            <td><code>transport_routes</code></td>
            <td>A*로 계산된 실제 이동 경로</td>
          </tr>
          <tr>
            <td><code>transport_history</code></td>
            <td>운송 이벤트 및 완료 이력</td>
          </tr>
        </tbody>
      </table>
    </div>
  </section>

  <section class="borderless-card">
    <h2 class="h5 mb-4"><i class="bi bi-info-circle me-2"></i>시스템 특징</h2>
    <ul class="list-unstyled">
      <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i> <strong>A* 경로 탐색:</strong> 거리, 혼잡도, 위험도, 경사도 등을 가중치로 하는 최적 경로 계산</li>
      <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i> <strong>Dynamic Re-routing:</strong> 장애물 발생 시 자동으로 우회 경로 재계산</li>
      <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i> <strong>제약 조건 검증:</strong> 운송체 적재량, 통로 폭, 경사도, 계단 등의 제약 자동 검토</li>
      <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i> <strong>실시간 현황:</strong> GPS 센서 연동으로 실시간 운송 현황 추적</li>
      <li class="mb-2"><i class="bi bi-check-circle text-success me-2"></i> <strong>이력 관리:</strong> 모든 운송 요청 및 이벤트의 완벽한 기록</li>
    </ul>
  </section>

</main>

<footer class="app-footer">
  <div class="container-xl">
    <div class="row gy-3 align-items-center">
      <div class="col-md-6 text-center text-md-start">
        <div class="fw-bold text-dark mb-1">
          <i class="bi bi-truck-front me-1 text-info"></i> 운송 관리 시스템
        </div>
        <div>지능형 운송 관리 및 경로 최적화 시스템</div>
      </div>
      <div class="col-md-6 text-center text-md-end small">
        <div class="text-dark fw-bold">개발팀</div>
        <div>&copy; 2026 운송 관리 시스템. All rights reserved.</div>
      </div>
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
