-- ============================================================
-- CAN 시스템: 로봇 운반 시스템 데이터 마이그레이션
-- 기존 데이터 활용 + 없는 정보는 임의값 입력
-- ============================================================

-- 1. NODES 테이블 - campus_entrances 데이터 마이그레이션
INSERT INTO `nodes` (`node_id`, `node_name`, `latitude`, `longitude`, `building`, `floor`, `node_type`, `description`)
SELECT
  CONCAT('NODE-', entrance_id),
  entrance_name,
  IFNULL(CAST(37.397 + RAND()*0.005 AS DECIMAL(10,7)), 37.397),  -- 임의 좌표 (보완 필요)
  IFNULL(CAST(127.248 + RAND()*0.005 AS DECIMAL(10,7)), 127.248),
  building,
  floor,
  CASE
    WHEN entrance_name LIKE '%엘리베이터%' THEN '엘리베이터'
    WHEN entrance_name LIKE '%계단%' THEN '계단'
    WHEN entrance_name LIKE '%출입%' OR entrance_name LIKE '%출입구%' THEN '출입구'
    ELSE '교차로'
  END,
  CONCAT('마이그레이션: ', entrance_name)
FROM `campus_entrances`
WHERE is_active = 1
ON DUPLICATE KEY UPDATE node_name = VALUES(node_name);

-- 2. SOURCE_LOCATIONS 테이블 - campus_entrances에서 출입구만 선별
INSERT INTO `source_locations` (`source_id`, `source_name`, `building`, `floor`, `latitude`, `longitude`, `detail_location`, `can_pickup`, `pickup_space`)
SELECT
  CONCAT('LOC-S', entrance_id),
  entrance_name,
  building,
  floor,
  IFNULL(CAST(37.397 + RAND()*0.005 AS DECIMAL(10,7)), 37.397),
  IFNULL(CAST(127.248 + RAND()*0.005 AS DECIMAL(10,7)), 127.248),
  entrance_name,
  TRUE,  -- 모두 상차 가능으로 설정 (필요시 수정)
  CONCAT(building, ' 앞')
FROM `campus_entrances`
WHERE is_active = 1 AND (entrance_name LIKE '%출입%' OR entrance_name LIKE '%정문%' OR entrance_name LIKE '%후문%')
LIMIT 20
ON DUPLICATE KEY UPDATE source_name = VALUES(source_name);

-- 3. DESTINATION_LOCATIONS 테이블 - rooms 데이터 마이그레이션
INSERT INTO `destination_locations` (`destination_id`, `destination_name`, `building`, `floor`, `latitude`, `longitude`, `detail_location`, `can_unload`, `unload_space`)
SELECT
  CONCAT('LOC-D', room_id),
  room_name,
  building,
  floor,
  IFNULL(lat, CAST(37.397 + RAND()*0.005 AS DECIMAL(10,7))),
  IFNULL(lng, CAST(127.248 + RAND()*0.005 AS DECIMAL(10,7))),
  room_name,
  TRUE,  -- 모두 하차 가능으로 설정
  CONCAT(building, ' ', room_name, ' 앞')
FROM `rooms`
WHERE is_active = 'Y'
ON DUPLICATE KEY UPDATE destination_name = VALUES(destination_name);

-- 4. EDGES 테이블 - campus_routes 데이터 마이그레이션 (거리, 통로폭은 임의)
INSERT INTO `edges` (
  `edge_id`, `from_node_id`, `to_node_id`, `distance_m`, `passage_width_cm`,
  `slope_degree`, `max_weight_kg`, `speed_limit_kmh`, `has_stairs`, `has_elevator`,
  `accessible`, `congestion_level`, `risk_level`, `travel_time_min`
)
SELECT
  CONCAT('EDGE-', route_id),
  CONCAT('NODE-', from_entrance_id),
  CONCAT('NODE-', to_entrance_id),
  ROUND(RAND() * 100 + 20, 2),
  ROUND(RAND() * 50 + 100, 2),
  ROUND(RAND() * 10, 2),
  FLOOR(RAND() * 150 + 100),
  ROUND(RAND() * 3 + 3, 2),
  IF(RAND() > 0.7, TRUE, FALSE),
  IF(RAND() > 0.5, TRUE, FALSE),
  TRUE,
  FLOOR(RAND() * 50),
  FLOOR(RAND() * 30),
  ROUND(RAND() * 15 + 3, 2)
FROM `campus_routes`
WHERE is_active = 1
ON DUPLICATE KEY UPDATE distance_m = VALUES(distance_m);

-- 5. VEHICLES 테이블 - 샘플 데이터 (기존 유지)
INSERT INTO `vehicles` (
  `vehicle_id`, `vehicle_name`, `vehicle_type`, `current_floor`, `current_building`,
  `max_payload_kg`, `max_width_cm`, `max_length_cm`, `max_height_cm`, `max_speed_kmh`,
  `current_battery_soc`, `min_battery_soc`, `turning_radius_m`, `max_slope_degree`,
  `can_use_elevator`, `current_status`
) VALUES
('AGV-01', 'AGV-01호', 'AGV', 3, '1공학관', 100, 120, 120, 100, 5, 78, 20, 0.8, 10, TRUE, '대기'),
('AGV-02', 'AGV-02호', 'AGV', 2, '2공학관', 100, 120, 120, 100, 5, 65, 20, 0.8, 10, TRUE, '대기'),
('ROBOT-03', '자율주행로봇-03', '자율주행로봇', 3, '1공학관', 50, 100, 100, 80, 3, 82, 20, 0.6, 8, FALSE, '대기')
ON DUPLICATE KEY UPDATE current_battery_soc = VALUES(current_battery_soc);

-- 6. OBSTACLES 테이블 - 샘플 데이터 (실제 edge_id로 나중에 추가)
-- INSERT INTO `obstacles` (`obstacle_id`, `edge_id`, `obstacle_type`, `description`, `start_time`, `end_time`, `accessible`, `created_by`)
-- VALUES
-- ('OBS-001', 'EDGE-1', '공사', '1층 복도 수리 중', NOW(), DATE_ADD(NOW(), INTERVAL 3 DAY), FALSE, 'admin'),
-- ('OBS-002', 'EDGE-2', '통제', '2층 임시 통제', NOW(), DATE_ADD(NOW(), INTERVAL 1 DAY), FALSE, 'admin')
-- ON DUPLICATE KEY UPDATE `accessible` = VALUES(`accessible`);

-- 7. ROUTE_FILTERS 테이블 - 샘플 데이터
INSERT INTO `route_filters` (`filter_id`, `filter_name`, `filter_type`, `condition_description`, `check_logic`)
VALUES
('FILTER-001', '폭 체크', '크기', '물체 폭이 통로 폭보다 크면 경로 제외', 'resource.width_cm > edge.passage_width_cm'),
('FILTER-002', '무게 체크', '무게', '물체 무게가 경로 최대중량보다 크면 경로 제외', 'resource.weight_kg > edge.max_weight_kg'),
('FILTER-003', '계단 제외', '타입', '기울임 불가 물건이면 계단 경로 제외', 'resource.can_tilt=FALSE AND edge.has_stairs=TRUE'),
('FILTER-004', '엘리베이터 필수', '타입', '큰 물건은 계단 사용 불가, 엘리베이터만 사용', 'resource.width_cm > 100 THEN 계단 경로 제외')
ON DUPLICATE KEY UPDATE check_logic = VALUES(check_logic);

-- 8. ASSETS 테이블 - 기존 자산에 정보 추가 (샘플)
UPDATE `assets`
SET
  weight_kg = CASE
    WHEN weight_kg IS NULL THEN FLOOR(RAND() * 50 + 10)
    ELSE weight_kg
  END,
  width_cm = CASE
    WHEN width_cm IS NULL THEN FLOOR(RAND() * 60 + 40)
    ELSE width_cm
  END,
  length_cm = CASE
    WHEN length_cm IS NULL THEN FLOOR(RAND() * 80 + 60)
    ELSE length_cm
  END,
  height_cm = CASE
    WHEN height_cm IS NULL THEN FLOOR(RAND() * 70 + 50)
    ELSE height_cm
  END,
  fragile = CASE
    WHEN fragile IS NULL THEN IF(RAND() > 0.7, TRUE, FALSE)
    ELSE fragile
  END,
  can_tilt = CASE
    WHEN can_tilt IS NULL THEN IF(RAND() > 0.3, TRUE, FALSE)
    ELSE can_tilt
  END,
  temperature_condition = CASE
    WHEN temperature_condition IS NULL THEN '상온'
    ELSE temperature_condition
  END,
  priority = CASE
    WHEN priority IS NULL THEN 'N/A'
    ELSE priority
  END
WHERE asset_status = '사용중' LIMIT 100;

-- ============================================================
-- 확인 쿼리
-- ============================================================
-- SELECT COUNT(*) FROM nodes;
-- SELECT COUNT(*) FROM source_locations;
-- SELECT COUNT(*) FROM destination_locations;
-- SELECT COUNT(*) FROM edges;
-- SELECT COUNT(*) FROM vehicles;
-- SELECT * FROM edges LIMIT 5;
