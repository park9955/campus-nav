-- ══════════════════════════════════════════════════════
-- ICT CAN — 강의실/세미나실/컴퓨터실 예약 테이블
-- MySQL Workbench에서 USE campusnav; 후 실행
-- ══════════════════════════════════════════════════════

USE campusnav;

-- ── 0. 기존 테이블 제거 (재실행 시 충돌 방지) ────────
DROP TABLE IF EXISTS `room_reservations`;
DROP TABLE IF EXISTS `rooms`;

-- ── 1. rooms 테이블 생성 ──────────────────────────────
CREATE TABLE IF NOT EXISTS `rooms` (
  `room_id`     INT           NOT NULL AUTO_INCREMENT,
  `room_name`   VARCHAR(100)  NOT NULL COMMENT '예) 1101호 강의실',
  `room_type`   VARCHAR(20)   NOT NULL COMMENT '강의실/세미나실/컴퓨터실',
  `building`    VARCHAR(100)  DEFAULT '제1공학관',
  `floor`       INT           DEFAULT NULL,
  `room_no`     VARCHAR(10)   DEFAULT NULL COMMENT '호실번호',
  `capacity`    INT           DEFAULT 0    COMMENT '수용 인원',
  `description` VARCHAR(200)  DEFAULT NULL,
  `is_active`   CHAR(1)       DEFAULT 'Y',
  `reg_date`    DATETIME      DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`room_id`),
  KEY `idx_room_type` (`room_type`),
  KEY `idx_room_building` (`building`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ── 2. room_reservations 테이블 생성 ─────────────────
CREATE TABLE IF NOT EXISTS `room_reservations` (
  `reserve_id`   INT          NOT NULL AUTO_INCREMENT,
  `room_id`      INT          NOT NULL,
  `user_id`      VARCHAR(50)  NOT NULL,
  `reserve_date` DATE         NOT NULL,
  `start_time`   TIME         NOT NULL,
  `end_time`     TIME         NOT NULL,
  `purpose`      VARCHAR(200) DEFAULT NULL,
  `phone`        VARCHAR(20)  DEFAULT NULL,
  `status`       VARCHAR(20)  DEFAULT '예약완료' COMMENT '예약완료/취소/이용중/완료',
  `reg_date`     DATETIME     DEFAULT CURRENT_TIMESTAMP,
  PRIMARY KEY (`reserve_id`),
  KEY `idx_rr_room`   (`room_id`),
  KEY `idx_rr_user`   (`user_id`),
  KEY `idx_rr_date`   (`reserve_date`),
  CONSTRAINT `rr_ibfk_room` FOREIGN KEY (`room_id`)  REFERENCES `rooms` (`room_id`),
  CONSTRAINT `rr_ibfk_user` FOREIGN KEY (`user_id`)  REFERENCES `users` (`user_id`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

-- ── 3. 1공학관 방 데이터 INSERT ──────────────────────

-- 강의실 (9개)
INSERT INTO `rooms` (`room_name`, `room_type`, `building`, `floor`, `room_no`, `capacity`, `description`) VALUES
('1101호 강의실', '강의실', '제1공학관', 1, '1101', 45, '1층 대형 강의실'),
('1102호 강의실', '강의실', '제1공학관', 1, '1102', 40, '1층 강의실'),
('1202호 강의실', '강의실', '제1공학관', 2, '1202', 45, '2층 대형 강의실'),
('1205호 강의실', '강의실', '제1공학관', 2, '1205', 40, '2층 강의실'),
('1302호 강의실', '강의실', '제1공학관', 3, '1302', 45, '3층 대형 강의실'),
('1305호 강의실', '강의실', '제1공학관', 3, '1305', 40, '3층 강의실'),
('1402호 강의실', '강의실', '제1공학관', 4, '1402', 40, '4층 강의실'),
('1403호 강의실', '강의실', '제1공학관', 4, '1403', 40, '4층 강의실'),
('1503호 강의실', '강의실', '제1공학관', 5, '1503', 40, '5층 강의실');

-- 컴퓨터실 (7개)
INSERT INTO `rooms` (`room_name`, `room_type`, `building`, `floor`, `room_no`, `capacity`, `description`) VALUES
('1103호 컴퓨터실', '컴퓨터실', '제1공학관', 1, '1103', 30, 'PC 30대 · 실습용'),
('1105호 컴퓨터실', '컴퓨터실', '제1공학관', 1, '1105', 30, 'PC 30대 · 실습용'),
('1203호 컴퓨터실', '컴퓨터실', '제1공학관', 2, '1203', 30, 'PC 30대 · 실습용'),
('1207호 컴퓨터실', '컴퓨터실', '제1공학관', 2, '1207', 32, 'PC 32대 · AI/네트워크 실습'),
('1306호 컴퓨터실', '컴퓨터실', '제1공학관', 3, '1306', 30, 'PC 30대 · 실습용'),
('1307호 컴퓨터실', '컴퓨터실', '제1공학관', 3, '1307', 32, 'PC 32대 · 실습용'),
('1407호 컴퓨터실', '컴퓨터실', '제1공학관', 4, '1407', 30, 'PC 30대 · 실습용');

-- 세미나실 (2개)
INSERT INTO `rooms` (`room_name`, `room_type`, `building`, `floor`, `room_no`, `capacity`, `description`) VALUES
('2층 세미나실',   '세미나실', '제1공학관', 2, '2층회의실', 20, '회의·세미나 겸용'),
('1502호 세미나실','세미나실', '제1공학관', 5, '1502',      15, '소규모 세미나·스터디용');

-- ── 확인 쿼리 ─────────────────────────────────────────
-- SELECT room_type, COUNT(*) FROM rooms GROUP BY room_type;
-- 강의실 9 / 컴퓨터실 7 / 세미나실 2  이어야 함
