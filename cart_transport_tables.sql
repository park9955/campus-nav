-- ============================================================
-- CAN 시스템: 로봇/AGV 자원 운반 시스템 기초 테이블
-- 생성일: 2026-09-01
-- 포함: nodes, edges, vehicles, obstacles, locations, filters
-- ============================================================

-- 1. 노드 테이블 (지점/교차로/출입구/엘리베이터)
CREATE TABLE IF NOT EXISTS `nodes` (
  `node_id` VARCHAR(20) PRIMARY KEY,
  `node_name` VARCHAR(100) NOT NULL,
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `building` VARCHAR(50),
  `floor` INT,
  `node_type` VARCHAR(50) COMMENT '출입구/교차로/엘리베이터/계단',
  `description` VARCHAR(200),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  KEY `idx_building_floor` (`building`, `floor`),
  KEY `idx_type` (`node_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 2. 엣지 테이블 (경로/노드 간 연결 + 속성) ⭐ 가장 중요!
CREATE TABLE IF NOT EXISTS `edges` (
  `edge_id` VARCHAR(20) PRIMARY KEY,
  `from_node_id` VARCHAR(20) NOT NULL,
  `to_node_id` VARCHAR(20) NOT NULL,
  `distance_m` DECIMAL(8,2),
  `passage_width_cm` DECIMAL(8,2) COMMENT '통로 폭 - 필터링 기준',
  `slope_degree` DECIMAL(5,2),
  `max_weight_kg` INT,
  `speed_limit_kmh` DECIMAL(5,2),
  `is_indoor` BOOLEAN DEFAULT TRUE,
  `has_stairs` BOOLEAN DEFAULT FALSE COMMENT '계단 여부 - 우회 판정',
  `has_elevator` BOOLEAN DEFAULT FALSE COMMENT '엘리베이터 여부',
  `accessible` BOOLEAN DEFAULT TRUE COMMENT '현재 통행가능 - Dynamic Re-routing용',
  `congestion_level` INT DEFAULT 0 COMMENT '혼잡도 0-100',
  `risk_level` INT DEFAULT 0 COMMENT '위험도 0-100',
  `travel_time_min` DECIMAL(8,2),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  FOREIGN KEY (`from_node_id`) REFERENCES `nodes`(`node_id`),
  FOREIGN KEY (`to_node_id`) REFERENCES `nodes`(`node_id`),
  KEY `idx_from_to` (`from_node_id`, `to_node_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 3. 운송체 테이블 (AGV/로봇)
CREATE TABLE IF NOT EXISTS `vehicles` (
  `vehicle_id` VARCHAR(20) PRIMARY KEY,
  `vehicle_name` VARCHAR(100) NOT NULL,
  `vehicle_type` VARCHAR(50) COMMENT 'AGV/자율주행로봇/카트',
  `current_latitude` DECIMAL(10,7),
  `current_longitude` DECIMAL(10,7),
  `current_floor` INT COMMENT '2~4층 구분',
  `current_building` VARCHAR(50),
  `max_payload_kg` INT,
  `max_width_cm` DECIMAL(8,2),
  `max_length_cm` DECIMAL(8,2),
  `max_height_cm` DECIMAL(8,2),
  `max_speed_kmh` DECIMAL(5,2),
  `current_battery_soc` INT COMMENT '현재 배터리 %',
  `min_battery_soc` INT DEFAULT 20 COMMENT '최소 운행 배터리 %',
  `turning_radius_m` DECIMAL(5,2),
  `max_slope_degree` DECIMAL(5,2),
  `can_indoor` BOOLEAN DEFAULT TRUE,
  `can_outdoor` BOOLEAN DEFAULT TRUE,
  `can_use_elevator` BOOLEAN DEFAULT TRUE,
  `current_status` VARCHAR(50) COMMENT '대기/운송/충전/고장',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  KEY `idx_status` (`current_status`),
  KEY `idx_floor` (`current_floor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 4. 장애물 테이블
CREATE TABLE IF NOT EXISTS `obstacles` (
  `obstacle_id` VARCHAR(20) PRIMARY KEY,
  `edge_id` VARCHAR(20),
  `obstacle_type` VARCHAR(50) COMMENT '공사/통제/사람/차량',
  `description` VARCHAR(200),
  `start_time` DATETIME,
  `end_time` DATETIME,
  `accessible` BOOLEAN DEFAULT FALSE COMMENT 'FALSE일 때 경로 차단',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `created_by` VARCHAR(100),
  `is_active` TINYINT DEFAULT 1,
  FOREIGN KEY (`edge_id`) REFERENCES `edges`(`edge_id`),
  KEY `idx_edge_time` (`edge_id`, `start_time`, `end_time`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 5. 출발지 정보 테이블 (PDF 1번)
CREATE TABLE IF NOT EXISTS `source_locations` (
  `source_id` VARCHAR(20) PRIMARY KEY,
  `source_name` VARCHAR(100) NOT NULL,
  `building` VARCHAR(50) NOT NULL,
  `floor` INT NOT NULL,
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `detail_location` VARCHAR(200),
  `entrance_location` VARCHAR(50),
  `accessible` BOOLEAN DEFAULT TRUE,
  `passage_width_cm` DECIMAL(8,2),
  `has_elevator` BOOLEAN,
  `has_stairs` BOOLEAN,
  `can_pickup` BOOLEAN DEFAULT TRUE COMMENT '상차 가능 여부',
  `pickup_space` VARCHAR(100) COMMENT '상차 공간',
  `manager` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  KEY `idx_building_floor` (`building`, `floor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 6. 목표지 정보 테이블 (PDF 2번)
CREATE TABLE IF NOT EXISTS `destination_locations` (
  `destination_id` VARCHAR(20) PRIMARY KEY,
  `destination_name` VARCHAR(100) NOT NULL,
  `building` VARCHAR(50) NOT NULL,
  `floor` INT NOT NULL,
  `latitude` DECIMAL(10,7) NOT NULL,
  `longitude` DECIMAL(10,7) NOT NULL,
  `detail_location` VARCHAR(200),
  `entrance_location` VARCHAR(50),
  `accessible` BOOLEAN DEFAULT TRUE,
  `passage_width_cm` DECIMAL(8,2),
  `has_elevator` BOOLEAN,
  `has_stairs` BOOLEAN,
  `can_unload` BOOLEAN DEFAULT TRUE COMMENT '하차 가능 여부',
  `unload_space` VARCHAR(100) COMMENT '하차 공간',
  `receiver` VARCHAR(100),
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  KEY `idx_building_floor` (`building`, `floor`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- 7. 경로 필터링 규칙 테이블
CREATE TABLE IF NOT EXISTS `route_filters` (
  `filter_id` VARCHAR(20) PRIMARY KEY,
  `filter_name` VARCHAR(100),
  `filter_type` VARCHAR(50) COMMENT '크기/무게/타입',
  `condition_description` VARCHAR(200),
  `check_logic` VARCHAR(500) COMMENT '필터 로직',
  `created_at` TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  `is_active` TINYINT DEFAULT 1,
  KEY `idx_type` (`filter_type`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ============================================================
-- ALTER: 기존 assets 테이블에 컬럼 추가 (PDF 3번)
-- ============================================================
ALTER TABLE `assets` ADD COLUMN `weight_kg` DECIMAL(8,2);
ALTER TABLE `assets` ADD COLUMN `width_cm` DECIMAL(8,2);
ALTER TABLE `assets` ADD COLUMN `length_cm` DECIMAL(8,2);
ALTER TABLE `assets` ADD COLUMN `height_cm` DECIMAL(8,2);
ALTER TABLE `assets` ADD COLUMN `fragile` BOOLEAN DEFAULT FALSE;
ALTER TABLE `assets` ADD COLUMN `can_tilt` BOOLEAN DEFAULT TRUE;
ALTER TABLE `assets` ADD COLUMN `temperature_condition` VARCHAR(100);
ALTER TABLE `assets` ADD COLUMN `priority` VARCHAR(20);
ALTER TABLE `assets` ADD COLUMN `estimated_start_time` TIME;
ALTER TABLE `assets` ADD COLUMN `estimated_deadline` TIME;

-- ============================================================
-- 샘플 데이터
-- ============================================================

-- 노드 샘플 데이터
INSERT INTO `nodes` (`node_id`, `node_name`, `latitude`, `longitude`, `building`, `floor`, `node_type`) VALUES
('NODE-001', 'AI소프트웨어학과 출입구', 37.12345670, 127.12345670, '1공학관', 3, '출입구'),
('NODE-002', '1공학관 3층 복도', 37.12346000, 127.12346000, '1공학관', 3, '교차로'),
('NODE-003', '1공학관 엘리베이터', 37.12346500, 127.12346500, '1공학관', 3, '엘리베이터'),
('NODE-004', '2공학관 엘리베이터', 37.12350000, 127.12350000, '2공학관', 2, '엘리베이터'),
('NODE-005', '2공학관 2층 복도', 37.12350500, 127.12350500, '2공학관', 2, '교차로'),
('NODE-006', 'Smart Factory 출입구', 37.12351000, 127.12351000, '2공학관', 2, '출입구'),
('NODE-007', '중앙광장', 37.12348000, 127.12348000, '야외', 0, '교차로');

-- 엣지 샘플 데이터 (경로)
INSERT INTO `edges` (`edge_id`, `from_node_id`, `to_node_id`, `distance_m`, `passage_width_cm`, `slope_degree`, `max_weight_kg`, `speed_limit_kmh`, `has_stairs`, `has_elevator`, `travel_time_min`) VALUES
('EDGE-001', 'NODE-001', 'NODE-002', 30, 150, 0, 200, 5, FALSE, FALSE, 6),
('EDGE-002', 'NODE-002', 'NODE-003', 25, 120, 0, 200, 5, FALSE, TRUE, 5),
('EDGE-003', 'NODE-003', 'NODE-004', 40, 130, 5, 150, 5, FALSE, TRUE, 8),
('EDGE-004', 'NODE-004', 'NODE-005', 20, 150, 0, 200, 5, FALSE, FALSE, 4),
('EDGE-005', 'NODE-005', 'NODE-006', 30, 120, 0, 200, 5, FALSE, FALSE, 6),
('EDGE-006', 'NODE-002', 'NODE-007', 50, 200, 0, 500, 5, FALSE, FALSE, 10),
('EDGE-007', 'NODE-007', 'NODE-005', 60, 200, 2, 500, 5, FALSE, FALSE, 12);

-- 운송체 샘플 데이터 (AGV)
INSERT INTO `vehicles` (`vehicle_id`, `vehicle_name`, `vehicle_type`, `current_floor`, `current_building`, `max_payload_kg`, `max_width_cm`, `max_length_cm`, `max_height_cm`, `max_speed_kmh`, `current_battery_soc`, `min_battery_soc`, `turning_radius_m`, `max_slope_degree`, `can_use_elevator`, `current_status`) VALUES
('AGV-01', 'AGV-01호', 'AGV', 3, '1공학관', 100, 120, 120, 100, 5, 78, 20, 0.8, 10, TRUE, '대기'),
('AGV-02', 'AGV-02호', 'AGV', 2, '2공학관', 100, 120, 120, 100, 5, 65, 20, 0.8, 10, TRUE, '대기'),
('AGV-03', '자율주행로봇-03', '자율주행로봇', 3, '1공학관', 50, 100, 100, 80, 3, 82, 20, 0.6, 8, FALSE, '대기');

-- 출발지 샘플 데이터
INSERT INTO `source_locations` (`source_id`, `source_name`, `building`, `floor`, `latitude`, `longitude`, `detail_location`, `can_pickup`, `pickup_space`) VALUES
('LOC-S001', 'AI소프트웨어학과 실습실', '1공학관', 3, 37.12345670, 127.12345670, '301호 앞', TRUE, '실습실 앞 공간'),
('LOC-S002', '프로젝트실', '1공학관', 3, 37.12346000, 127.12346000, '304호', TRUE, '복도 공간');

-- 목표지 샘플 데이터
INSERT INTO `destination_locations` (`destination_id`, `destination_name`, `building`, `floor`, `latitude`, `longitude`, `detail_location`, `can_unload`, `unload_space`) VALUES
('LOC-D001', '스마트팩토리 실습실', '2공학관', 2, 37.12351000, 127.12351000, '205호', TRUE, '실습실 앞 공간'),
('LOC-D002', '로봇공학 연구실', '2공학관', 2, 37.12350500, 127.12350500, '210호', TRUE, '연구실 입구');

-- 경로 필터링 규칙 샘플
INSERT INTO `route_filters` (`filter_id`, `filter_name`, `filter_type`, `condition_description`, `check_logic`) VALUES
('FILTER-001', '폭 체크', '크기', '물체 폭이 통로 폭보다 크면 경로 제외', 'resource.width_cm > edge.passage_width_cm'),
('FILTER-002', '무게 체크', '무게', '물체 무게가 경로 최대중량보다 크면 경로 제외', 'resource.weight_kg > edge.max_weight_kg'),
('FILTER-003', '계단 제외', '타입', '기울임 불가 물건이면 계단 경로 제외', 'resource.can_tilt=FALSE AND edge.has_stairs=TRUE'),
('FILTER-004', '엘리베이터 필수', '타입', '큰 물건은 계단 사용 불가, 엘리베이터만 사용', 'resource.width_cm > 100 THEN 계단 경로 제외');

-- ============================================================
-- 샘플 자산 데이터 추가 (assets 테이블에 추가 정보)
-- ============================================================
-- 주의: 기존 asset_no가 없으면 INSERT 실행
-- 실제 운영에서는 UPDATE를 사용하여 기존 자산에 정보 추가

INSERT INTO `assets` (
  `asset_no`, `item_name`, `weight_kg`, `width_cm`, `length_cm`, `height_cm`,
  `fragile`, `can_tilt`, `temperature_condition`, `priority`,
  `estimated_start_time`, `estimated_deadline`, `acq_date`, `asset_status`
) VALUES
('ASSET-001', '서버', 45, 80, 120, 100, FALSE, FALSE, '상온', '높음', '14:00:00', '14:30:00', '2024-01-15', '사용중'),
('ASSET-002', '프로젝터', 15, 40, 30, 20, TRUE, FALSE, '상온', '보통', '10:00:00', '11:00:00', '2024-02-20', '사용중'),
('ASSET-003', '실험장비 세트', 35, 60, 90, 80, TRUE, TRUE, '5~25℃', '높음', '09:00:00', '17:00:00', '2024-03-10', '사용중');

-- ============================================================
-- 확인 쿼리 (실행 후 확인용)
-- ============================================================
-- SELECT * FROM nodes;
-- SELECT * FROM edges;
-- SELECT * FROM vehicles;
-- SELECT * FROM source_locations;
-- SELECT * FROM destination_locations;
-- DESCRIBE assets; -- 추가된 컬럼 확인
