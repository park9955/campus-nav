<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.sql.*" %>

<%
request.setCharacterEncoding("UTF-8");

String message = "";
String error = "";

/*
 * ============================================================
 * 학교 자원 스마트 운송관리 시스템 - DB 초기화 JSP
 * ------------------------------------------------------------
 * MySQL 8.x 기준
 *
 * 중요:
 * 1. 아래 USER / PASSWORD를 자신의 MySQL 환경에 맞게 수정
 * 2. MySQL Connector/J가 Tomcat lib에 있어야 함
 * 3. 컬럼명 accessible 대신 is_accessible 사용
 * 4. 컬럼명을 명시하여 INSERT하여 컬럼 순서 오류 방지
 * ============================================================
 */

String DB_NAME = "school_cart";
String USER = "root";
String PASSWORD = "1234";     // 자신의 MySQL 비밀번호로 수정

if ("POST".equalsIgnoreCase(request.getMethod())) {

    Connection con = null;
    Statement st = null;

    try {
        // ----------------------------------------------------
        // 1. MySQL JDBC Driver 로딩
        // ----------------------------------------------------
        Class.forName("com.mysql.cj.jdbc.Driver");

        // 아직 DB가 없을 수 있으므로 DB명을 제외하고 접속
        String serverUrl =
            "jdbc:mysql://localhost:3306/" +
            "?serverTimezone=Asia/Seoul" +
            "&characterEncoding=UTF-8" +
            "&useUnicode=true" +
            "&allowPublicKeyRetrieval=true" +
            "&useSSL=false";

        con = DriverManager.getConnection(serverUrl, USER, PASSWORD);
        con.setAutoCommit(false);

        st = con.createStatement();

        // ----------------------------------------------------
        // 2. 기존 DB 삭제 후 새로 생성
        //    수업/실습용 초기화이므로 기존 데이터가 삭제됩니다.
        // ----------------------------------------------------
        st.executeUpdate("DROP DATABASE IF EXISTS `" + DB_NAME + "`");

        st.executeUpdate(
            "CREATE DATABASE `" + DB_NAME + "` " +
            "DEFAULT CHARACTER SET utf8mb4 " +
            "COLLATE utf8mb4_unicode_ci"
        );

        st.execute("USE `" + DB_NAME + "`");

        // ----------------------------------------------------
        // 3. 학교자원 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE resources (" +
            " resource_id VARCHAR(30) NOT NULL," +
            " resource_name VARCHAR(100) NOT NULL," +
            " category VARCHAR(30) NOT NULL," +
            " quantity INT NOT NULL DEFAULT 1," +
            " weight_kg DECIMAL(10,2) NOT NULL," +
            " width_cm DECIMAL(10,2) NOT NULL," +
            " length_cm DECIMAL(10,2) NOT NULL," +
            " height_cm DECIMAL(10,2) NOT NULL," +
            " fragile BOOLEAN NOT NULL DEFAULT FALSE," +
            " tilt_restricted BOOLEAN NOT NULL DEFAULT FALSE," +
            " temperature_condition VARCHAR(100) NULL," +
            " priority VARCHAR(20) NOT NULL DEFAULT '보통'," +
            " planned_time DATETIME NULL," +
            " deadline DATETIME NULL," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (resource_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 4. 출발지/목표지/공통 위치 테이블
        // accessible -> is_accessible 로 변경
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE locations (" +
            " location_id VARCHAR(30) NOT NULL," +
            " location_type VARCHAR(20) NOT NULL," +
            " location_name VARCHAR(100) NOT NULL," +
            " building_name VARCHAR(100) NOT NULL," +
            " floor_no INT NOT NULL," +
            " latitude DECIMAL(10,7) NOT NULL," +
            " longitude DECIMAL(10,7) NOT NULL," +
            " altitude DECIMAL(10,2) NULL," +
            " detail_location VARCHAR(150) NOT NULL," +
            " entrance_location VARCHAR(100) NULL," +
            " is_accessible BOOLEAN NOT NULL DEFAULT TRUE," +
            " passage_width_m DECIMAL(10,2) NULL," +
            " elevator BOOLEAN NOT NULL DEFAULT FALSE," +
            " stairs BOOLEAN NOT NULL DEFAULT FALSE," +
            " loading_available BOOLEAN NOT NULL DEFAULT TRUE," +
            " loading_space VARCHAR(100) NULL," +
            " manager_name VARCHAR(100) NULL," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (location_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 5. AGV / 자율주행 카트 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE vehicles (" +
            " vehicle_id VARCHAR(30) NOT NULL," +
            " current_latitude DECIMAL(10,7) NOT NULL," +
            " current_longitude DECIMAL(10,7) NOT NULL," +
            " payload_kg DECIMAL(10,2) NOT NULL," +
            " load_width_m DECIMAL(10,2) NOT NULL," +
            " max_speed_kmh DECIMAL(10,2) NOT NULL," +
            " battery_soc DECIMAL(5,2) NOT NULL," +
            " min_battery_soc DECIMAL(5,2) NOT NULL DEFAULT 20," +
            " turning_radius_m DECIMAL(10,2) NOT NULL," +
            " max_slope_deg DECIMAL(10,2) NOT NULL," +
            " indoor_available BOOLEAN NOT NULL DEFAULT TRUE," +
            " outdoor_available BOOLEAN NOT NULL DEFAULT TRUE," +
            " elevator_available BOOLEAN NOT NULL DEFAULT TRUE," +
            " status VARCHAR(20) NOT NULL DEFAULT '대기'," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (vehicle_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 6. 경로 Node 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE route_nodes (" +
            " node_id VARCHAR(30) NOT NULL," +
            " latitude DECIMAL(10,7) NOT NULL," +
            " longitude DECIMAL(10,7) NOT NULL," +
            " altitude DECIMAL(10,2) NULL," +
            " building VARCHAR(100) NULL," +
            " floor_no INT NULL," +
            " node_type VARCHAR(30) NOT NULL," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (node_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 7. 경로 Edge 테이블
        // accessible -> is_accessible 로 변경
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE route_edges (" +
            " edge_id VARCHAR(30) NOT NULL," +
            " from_node VARCHAR(30) NOT NULL," +
            " to_node VARCHAR(30) NOT NULL," +
            " distance_m DECIMAL(10,2) NOT NULL," +
            " width_m DECIMAL(10,2) NOT NULL," +
            " slope_deg DECIMAL(10,2) NOT NULL DEFAULT 0," +
            " max_weight_kg DECIMAL(10,2) NOT NULL," +
            " speed_limit_kmh DECIMAL(10,2) NOT NULL," +
            " indoor BOOLEAN NOT NULL DEFAULT FALSE," +
            " stairs BOOLEAN NOT NULL DEFAULT FALSE," +
            " is_accessible BOOLEAN NOT NULL DEFAULT TRUE," +
            " congestion DECIMAL(5,2) NOT NULL DEFAULT 0," +
            " risk_level DECIMAL(5,2) NOT NULL DEFAULT 0," +
            " travel_time_min DECIMAL(10,2) NOT NULL," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (edge_id)," +
            " CONSTRAINT fk_edge_from_node FOREIGN KEY (from_node)" +
            "   REFERENCES route_nodes(node_id)," +
            " CONSTRAINT fk_edge_to_node FOREIGN KEY (to_node)" +
            "   REFERENCES route_nodes(node_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 8. 운송 요청 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE transport_requests (" +
            " request_id VARCHAR(40) NOT NULL," +
            " resource_id VARCHAR(30) NOT NULL," +
            " start_location_id VARCHAR(30) NOT NULL," +
            " destination_location_id VARCHAR(30) NOT NULL," +
            " vehicle_id VARCHAR(30) NOT NULL," +
            " quantity INT NOT NULL DEFAULT 1," +
            " priority VARCHAR(20) NOT NULL DEFAULT '보통'," +
            " scheduled_time DATETIME NULL," +
            " deadline DATETIME NULL," +
            " status VARCHAR(30) NOT NULL DEFAULT 'REQUESTED'," +
            " current_node_id VARCHAR(30) NULL," +
            " total_distance_m DECIMAL(12,2) NULL," +
            " total_cost DECIMAL(12,4) NULL," +
            " started_at DATETIME NULL," +
            " completed_at DATETIME NULL," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (request_id)," +
            " CONSTRAINT fk_request_resource FOREIGN KEY (resource_id)" +
            "   REFERENCES resources(resource_id)," +
            " CONSTRAINT fk_request_start FOREIGN KEY (start_location_id)" +
            "   REFERENCES locations(location_id)," +
            " CONSTRAINT fk_request_destination FOREIGN KEY (destination_location_id)" +
            "   REFERENCES locations(location_id)," +
            " CONSTRAINT fk_request_vehicle FOREIGN KEY (vehicle_id)" +
            "   REFERENCES vehicles(vehicle_id)," +
            " CONSTRAINT fk_request_current_node FOREIGN KEY (current_node_id)" +
            "   REFERENCES route_nodes(node_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 9. 장애물 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE obstacles (" +
            " obstacle_id VARCHAR(30) NOT NULL," +
            " edge_id VARCHAR(30) NOT NULL," +
            " obstacle_type VARCHAR(30) NOT NULL," +
            " description VARCHAR(255) NULL," +
            " active BOOLEAN NOT NULL DEFAULT TRUE," +
            " occurred_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " cleared_at DATETIME NULL," +
            " PRIMARY KEY (obstacle_id)," +
            " CONSTRAINT fk_obstacle_edge FOREIGN KEY (edge_id)" +
            "   REFERENCES route_edges(edge_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 10. 실제 탐색 경로 저장 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE transport_routes (" +
            " route_id BIGINT NOT NULL AUTO_INCREMENT," +
            " request_id VARCHAR(40) NOT NULL," +
            " sequence_no INT NOT NULL," +
            " node_id VARCHAR(30) NULL," +
            " edge_id VARCHAR(30) NULL," +
            " distance_m DECIMAL(10,2) NULL," +
            " route_cost DECIMAL(12,4) NULL," +
            " active BOOLEAN NOT NULL DEFAULT TRUE," +
            " created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (route_id)," +
            " CONSTRAINT fk_route_request FOREIGN KEY (request_id)" +
            "   REFERENCES transport_requests(request_id)," +
            " CONSTRAINT fk_route_node FOREIGN KEY (node_id)" +
            "   REFERENCES route_nodes(node_id)," +
            " CONSTRAINT fk_route_edge FOREIGN KEY (edge_id)" +
            "   REFERENCES route_edges(edge_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ----------------------------------------------------
        // 11. 운송 이력 테이블
        // ----------------------------------------------------
        st.executeUpdate(
            "CREATE TABLE transport_history (" +
            " history_id BIGINT NOT NULL AUTO_INCREMENT," +
            " request_id VARCHAR(40) NULL," +
            " event_type VARCHAR(30) NOT NULL," +
            " node_id VARCHAR(30) NULL," +
            " edge_id VARCHAR(30) NULL," +
            " event_message VARCHAR(255) NULL," +
            " event_time DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP," +
            " PRIMARY KEY (history_id)," +
            " CONSTRAINT fk_history_request FOREIGN KEY (request_id)" +
            "   REFERENCES transport_requests(request_id)," +
            " CONSTRAINT fk_history_node FOREIGN KEY (node_id)" +
            "   REFERENCES route_nodes(node_id)," +
            " CONSTRAINT fk_history_edge FOREIGN KEY (edge_id)" +
            "   REFERENCES route_edges(edge_id)" +
            ") ENGINE=InnoDB DEFAULT CHARSET=utf8mb4"
        );

        // ====================================================
        // 12. 실습용 Resource 데이터
        // ====================================================
        st.executeUpdate(
            "INSERT INTO resources " +
            "(resource_id, resource_name, category, quantity, weight_kg," +
            " width_cm, length_cm, height_cm, fragile, tilt_restricted," +
            " temperature_condition, priority) VALUES " +

            "('RES-0001','서버','실습장비',1,45,80,120,100,TRUE,TRUE,'해당 없음','높음')," +
            "('RES-0002','네트워크 실습장비','기자재',1,25,60,80,70,FALSE,FALSE,'해당 없음','보통')," +
            "('RES-0003','도서 박스','도서',4,8,40,50,35,FALSE,FALSE,'해당 없음','낮음')"
        );

        // ====================================================
        // 13. 실습용 위치 데이터
        // ====================================================
        st.executeUpdate(
            "INSERT INTO locations " +
            "(location_id, location_type, location_name, building_name," +
            " floor_no, latitude, longitude, altitude, detail_location," +
            " entrance_location, is_accessible, passage_width_m," +
            " elevator, stairs, loading_available, loading_space, manager_name)" +
            " VALUES " +

            "('LOC-S001','START','AI소프트웨어학과 실습실','제1공학관'," +
            "3,37.5001000,127.0001000,20,'301호 앞','동쪽 출입구'," +
            "TRUE,1.8,TRUE,FALSE,TRUE,'실습실 앞 공간','인계 담당자')," +

            "('LOC-D023','DESTINATION','스마트팩토리 실습실','제2공학관'," +
            "2,37.5010000,127.0013000,18,'205호 앞','남쪽 출입구'," +
            "TRUE,2.0,TRUE,FALSE,TRUE,'205호 앞','수령 담당자')"
        );

        // ====================================================
        // 14. 실습용 운송체
        // ====================================================
        st.executeUpdate(
            "INSERT INTO vehicles " +
            "(vehicle_id, current_latitude, current_longitude, payload_kg," +
            " load_width_m, max_speed_kmh, battery_soc, min_battery_soc," +
            " turning_radius_m, max_slope_deg, indoor_available," +
            " outdoor_available, elevator_available, status)" +
            " VALUES " +

            "('AGV-01',37.5001000,127.0001000,100,1.2,5,78,20,0.8,10," +
            "TRUE,TRUE,TRUE,'대기')," +

            "('AGV-02',37.5003000,127.0002000,60,0.9,4,55,20,0.7,8," +
            "TRUE,TRUE,FALSE,'대기')"
        );

        // ====================================================
        // 15. 실습용 Node
        // ====================================================
        st.executeUpdate(
            "INSERT INTO route_nodes " +
            "(node_id, latitude, longitude, altitude, building, floor_no, node_type)" +
            " VALUES " +

            "('N001',37.5001000,127.0001000,20,'제1공학관',3,'실습실')," +
            "('N002',37.5002000,127.0002000,18,'제1공학관',1,'출입구')," +
            "('N003',37.5005000,127.0005000,17,NULL,NULL,'중앙광장')," +
            "('N004',37.5007000,127.0007000,17,NULL,NULL,'도서관앞')," +
            "('N005',37.5009000,127.0010000,18,'제2공학관',1,'출입구')," +
            "('N006',37.5010000,127.0013000,18,'제2공학관',2,'실습실')," +
            "('N007',37.5004500,127.0008500,17,NULL,NULL,'우회교차로')," +
            "('N008',37.5007000,127.0010500,17,NULL,NULL,'우회통로')"
        );

        // ====================================================
        // 16. 실습용 Edge
        //
        // 정상경로:
        // N001 -> N002 -> N003 -> N004 -> N005 -> N006
        //
        // E003 장애물 발생 시:
        // N001 -> N002 -> N003 -> N007 -> N008 -> N005 -> N006
        // ====================================================
        st.executeUpdate(
            "INSERT INTO route_edges " +
            "(edge_id, from_node, to_node, distance_m, width_m, slope_deg," +
            " max_weight_kg, speed_limit_kmh, indoor, stairs, is_accessible," +
            " congestion, risk_level, travel_time_min)" +
            " VALUES " +

            "('E001','N001','N002',30,1.8,2,150,4,TRUE,FALSE,TRUE,10,5,0.5)," +
            "('E002','N002','N003',50,2.0,1,200,5,FALSE,FALSE,TRUE,40,10,0.8)," +
            "('E003','N003','N004',40,1.5,0,200,5,FALSE,FALSE,TRUE,30,10,0.6)," +
            "('E004','N004','N005',60,2.0,2,200,5,FALSE,FALSE,TRUE,20,8,1.0)," +
            "('E005','N005','N006',25,1.6,3,150,4,TRUE,FALSE,TRUE,10,5,0.5)," +

            "('E006','N003','N007',45,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.7)," +
            "('E007','N007','N008',35,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.6)," +
            "('E008','N008','N005',50,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.8)," +

            "('E101','N002','N001',30,1.8,2,150,4,TRUE,FALSE,TRUE,10,5,0.5)," +
            "('E102','N003','N002',50,2.0,1,200,5,FALSE,FALSE,TRUE,40,10,0.8)," +
            "('E103','N004','N003',40,1.5,0,200,5,FALSE,FALSE,TRUE,30,10,0.6)," +
            "('E104','N005','N004',60,2.0,2,200,5,FALSE,FALSE,TRUE,20,8,1.0)," +
            "('E105','N006','N005',25,1.6,3,150,4,TRUE,FALSE,TRUE,10,5,0.5)," +
            "('E106','N007','N003',45,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.7)," +
            "('E107','N008','N007',35,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.6)," +
            "('E108','N005','N008',50,1.8,1,200,5,FALSE,FALSE,TRUE,10,6,0.8)"
        );

        // ====================================================
        // 17. 초기 운송요청 예제
        // ====================================================
        st.executeUpdate(
            "INSERT INTO transport_requests " +
            "(request_id, resource_id, start_location_id," +
            " destination_location_id, vehicle_id, quantity, priority," +
            " status, current_node_id)" +
            " VALUES " +
            "('REQ-2026-0001','RES-0001','LOC-S001','LOC-D023'," +
            "'AGV-01',1,'높음','REQUESTED','N001')"
        );

        // ----------------------------------------------------
        // 18. 초기 이력
        // ----------------------------------------------------
        st.executeUpdate(
            "INSERT INTO transport_history " +
            "(request_id, event_type, node_id, event_message)" +
            " VALUES " +
            "('REQ-2026-0001','REQUEST','N001','운송 요청이 생성되었습니다.')"
        );

        // ----------------------------------------------------
        // 19. Transaction 완료
        // ----------------------------------------------------
        con.commit();

        message =
            "school_cart 데이터베이스 초기화가 완료되었습니다. " +
            "테이블과 실습용 예제 데이터가 정상적으로 생성되었습니다.";

    } catch (Exception e) {

        if (con != null) {
            try {
                con.rollback();
            } catch (Exception rollbackException) {
                // rollback 오류는 원래 오류를 덮어쓰지 않음
            }
        }

        error = e.getClass().getName() + ": " + e.getMessage();

    } finally {

        if (st != null) {
            try { st.close(); } catch (Exception e) {}
        }

        if (con != null) {
            try {
                con.setAutoCommit(true);
            } catch (Exception e) {}

            try {
                con.close();
            } catch (Exception e) {}
        }
    }
}
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>DB 초기화</title>

<style>
:root {
  --bg-app: #f0f4f9;
  --surface: #ffffff;
  --txt-main: #0f172a;
  --txt-sub: #334155;
  --txt-muted: #64748b;
  --sky-primary: #0284c7;
  --sky-light: #e0f2fe;
  --sky-bg: #f0f9ff;
  --emerald-main: #16a34a;
  --radius-xl: 28px;
  --radius-lg: 20px;
  --radius-pill: 999px;
  --shadow-soft: 0 10px 25px -5px rgba(15, 23, 42, 0.05);
  --font-main: 'Pretendard', -apple-system, sans-serif;
}

* {
  box-sizing: border-box;
}

body {
  margin: 0;
  font-family: var(--font-main);
  background: linear-gradient(180deg, #dbeafe 0%, #e0f2fe 18%, #f0f4f9 45%, #f0f4f9 100%);
  background-repeat: no-repeat;
  color: var(--txt-main);
  line-height: 1.6;
}

.header {
  background: rgba(255, 255, 255, 0.85);
  backdrop-filter: blur(16px);
  color: var(--txt-main);
  padding: 2rem 2.5rem;
  border-bottom: 1px solid rgba(226, 232, 240, 0.8);
}

.header h1 {
  margin: 0;
  font-size: 1.5rem;
  font-weight: 800;
}

.container {
  width: min(1200px, 94%);
  margin: 2rem auto;
}

.card {
  background: var(--surface);
  border: 1px solid #f1f5f9;
  border-radius: var(--radius-xl);
  padding: 2.25rem;
  margin-bottom: 2rem;
  box-shadow: var(--shadow-soft);
}

h2 {
  margin-top: 0;
  font-weight: 800;
  font-size: 1.15rem;
}

.success {
  padding: 1.25rem;
  background: #dcfce7;
  border: 1px solid #86efac;
  border-radius: var(--radius-lg);
  margin-bottom: 1.5rem;
  line-height: 1.6;
  color: #15803d;
}

.error {
  padding: 1.25rem;
  background: #fee2e2;
  border: 1px solid #fca5a5;
  color: #b91c1c;
  border-radius: var(--radius-lg);
  margin-bottom: 1.5rem;
  line-height: 1.6;
  word-break: break-all;
}

.warning {
  padding: 1.25rem;
  background: #fef3c7;
  border: 1px solid #fcd34d;
  border-radius: var(--radius-lg);
  margin-bottom: 1.5rem;
  line-height: 1.6;
  color: #b45309;
}

button {
  border: 0;
  background: linear-gradient(135deg, #0284c7 0%, #0369a1 100%);
  color: white;
  padding: 0.75rem 2rem;
  border-radius: var(--radius-pill);
  font-size: 1rem;
  font-weight: 700;
  cursor: pointer;
  transition: all 0.2s;
}

button:hover {
  transform: translateY(-2px);
  box-shadow: 0 4px 12px rgba(2, 132, 199, 0.25);
}

table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 1.5rem;
  font-size: 0.925rem;
}

th, td {
  border: 1px solid #e2e8f0;
  padding: 1rem;
  text-align: left;
}

th {
  background: #f8fafc;
  font-weight: 700;
  color: var(--txt-muted);
}

code {
  background: #f8fafc;
  padding: 0.25rem 0.6rem;
  border-radius: 4px;
  font-family: 'JetBrains Mono', monospace;
  color: var(--sky-primary);
  font-weight: 600;
}

.links {
  margin-top: 2rem;
  display: flex;
  gap: 1rem;
  flex-wrap: wrap;
}

.links a {
  display: inline-block;
  text-decoration: none;
  background: #626d79;
  color: white;
  padding: 0.75rem 1.5rem;
  border-radius: var(--radius-pill);
  font-weight: 700;
  transition: all 0.2s;
}

.links a:hover {
  background: #525a66;
}
</style>
</head>

<body>

<div class="header">
    <h1>학교 자원 스마트 운송관리 시스템</h1>
</div>

<div class="container">

    <div class="card">

        <h2>DB 초기화</h2>

        <% if (!message.equals("")) { %>
            <div class="success">
                <strong>초기화 성공</strong><br>
                <%= message %>
            </div>
        <% } %>

        <% if (!error.equals("")) { %>
            <div class="error">
                <strong>초기화 실패</strong><br>
                <%= error %>
            </div>
        <% } %>

        <div class="warning">
            <strong>주의:</strong>
            이 버튼을 누르면 기존 <code>school_cart</code> 데이터베이스를
            삭제하고 새로 생성합니다. 기존 실습 데이터도 모두 삭제됩니다.
        </div>

        <p>
            MySQL에 <strong>school_cart</strong> 데이터베이스와
            학교자원, 위치, 운송체, Node, Edge, 운송요청,
            장애물, 경로, 운송이력 테이블을 생성합니다.
        </p>

        <form method="post">
            <button type="submit"
                    onclick="return confirm('기존 school_cart DB를 삭제하고 다시 생성하시겠습니까?');">
                DB 완전 초기화
            </button>
        </form>

    </div>

    <div class="card">

        <h2>생성되는 테이블</h2>

        <table>
            <tr>
                <th>테이블</th>
                <th>용도</th>
            </tr>

            <tr>
                <td>resources</td>
                <td>학교 기자재·실습장비·도서·소모품</td>
            </tr>

            <tr>
                <td>locations</td>
                <td>출발지·목표지 및 건물/층/위치 정보</td>
            </tr>

            <tr>
                <td>vehicles</td>
                <td>AGV·자율주행 카트 운송체 정보</td>
            </tr>

            <tr>
                <td>route_nodes</td>
                <td>경로상의 위치 Node</td>
            </tr>

            <tr>
                <td>route_edges</td>
                <td>Node 사이의 이동 통로 Edge</td>
            </tr>

            <tr>
                <td>transport_requests</td>
                <td>운송 요청 및 진행상태</td>
            </tr>

            <tr>
                <td>obstacles</td>
                <td>공사·통제·사람·차량 등의 장애물</td>
            </tr>

            <tr>
                <td>transport_routes</td>
                <td>A*로 계산된 실제 이동 경로</td>
            </tr>

            <tr>
                <td>transport_history</td>
                <td>운송 이벤트 및 완료 이력</td>
            </tr>
        </table>

    </div>

    <div class="card">

        <h2>중요 변경사항</h2>

        <p>
            기존 오류를 발생시킨
            <code>accessible</code> 컬럼은 모두
            <code>is_accessible</code>로 변경했습니다.
        </p>

        <p>
            따라서 다른 JSP에서 다음 SQL을 사용하는 경우도
            동일하게 수정해야 합니다.
        </p>

        <table>
            <tr>
                <th>기존</th>
                <th>수정</th>
            </tr>

            <tr>
                <td><code>accessible</code></td>
                <td><code>is_accessible</code></td>
            </tr>

            <tr>
                <td><code>SELECT accessible FROM locations</code></td>
                <td><code>SELECT is_accessible FROM locations</code></td>
            </tr>

            <tr>
                <td><code>UPDATE route_edges SET accessible=FALSE</code></td>
                <td><code>UPDATE route_edges SET is_accessible=FALSE</code></td>
            </tr>
        </table>

        <div class="links">
            <a href="dashboard.jsp">대시보드</a>
            <a href="resource.jsp">학교자원</a>
            <a href="routeSearch.jsp">A* 경로탐색</a>
        </div>

    </div>

</div>

</body>
</html>
