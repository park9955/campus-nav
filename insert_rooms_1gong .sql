-- ══════════════════════════════════════════════════════
-- ICT CAN — 1공학관 전체 호실 rooms 테이블 삽입
-- 기존 rooms_setup.sql이 building='제1공학관' 으로 되어 있어
-- floorNav.jsp (building='1공학관') 과 불일치 → 이 SQL로 통일
-- MySQL Workbench에서 USE campusnav; 후 실행
-- ══════════════════════════════════════════════════════

USE campusnav;

-- ── Safe Update Mode + 외래키 체크 일시 해제 ────────────
SET SQL_SAFE_UPDATES = 0;
SET FOREIGN_KEY_CHECKS = 0;

-- ── 관련 예약 데이터 먼저 삭제 ────────────────────────
DELETE FROM room_reservations
WHERE room_id IN (
    SELECT room_id FROM rooms WHERE building IN ('1공학관','제1공학관')
);

-- ── 기존 1공학관 호실 모두 삭제 ──────────────────────
DELETE FROM rooms WHERE building = '1공학관';
DELETE FROM rooms WHERE building = '제1공학관';

-- ── Safe Update Mode + 외래키 체크 복구 ──────────────
SET FOREIGN_KEY_CHECKS = 1;
SET SQL_SAFE_UPDATES = 1;

-- ── pixel_x, pixel_y, pin_dim, pin_floor 컬럼 추가 ─────
-- 이미 컬럼이 존재하면 Duplicate column 오류가 나도 무시하고 아래 INSERT로 진행하세요
ALTER TABLE rooms ADD COLUMN pixel_x   FLOAT       DEFAULT NULL;
ALTER TABLE rooms ADD COLUMN pixel_y   FLOAT       DEFAULT NULL;
ALTER TABLE rooms ADD COLUMN pin_dim   VARCHAR(10) DEFAULT '3D';
ALTER TABLE rooms ADD COLUMN pin_floor VARCHAR(10) DEFAULT NULL;

-- ── 1층 ─────────────────────────────────────────────
INSERT INTO rooms (room_name, room_type, building, floor, room_no, capacity, description, is_active) VALUES
('1101호', '컴퓨터실습실', '1공학관', 1, '1101', 40, '컴퓨터 실습실', 'Y'),
('1102호', '컴퓨터실습실', '1공학관', 1, '1102', 40, '컴퓨터 실습실', 'Y'),
('1103호', '컴퓨터실습실', '1공학관', 1, '1103', 40, '컴퓨터 실습실', 'Y'),
('1105호', '컴퓨터실습실', '1공학관', 1, '1105', 40, '컴퓨터 실습실', 'Y'),
('1106호', '컴퓨터실습실', '1공학관', 1, '1106', 40, '컴퓨터 실습실', 'Y'),
('1107호', '컴퓨터실습실', '1공학관', 1, '1107', 40, '컴퓨터 실습실', 'Y');

-- ── 2층 ─────────────────────────────────────────────
INSERT INTO rooms (room_name, room_type, building, floor, room_no, capacity, description, is_active) VALUES
('1201호', '회의실',             '1공학관', 2, '1201', 20, '회의실',                  'Y'),
('1202호', '실습실',             '1공학관', 2, '1202', 30, '도면설계실습실',           'Y'),
('1203호', '강의실',             '1공학관', 2, '1203', 45, '강의실',                  'Y'),
('1205호', '실습실',             '1공학관', 2, '1205', 30, '멀티미디어 기초실습',      'Y'),
('1206호', '실습실',             '1공학관', 2, '1206', 30, '멀티미디어통신실습실',     'Y'),
('1207호', '실습실',             '1공학관', 2, '1207', 30, '멀티미디어통신실습실',     'Y');

-- ── 3층 ─────────────────────────────────────────────
INSERT INTO rooms (room_name, room_type, building, floor, room_no, capacity, description, is_active) VALUES
('1301호', '강의실',  '1공학관', 3, '1301', 45, '강의실',                  'Y'),
('1302호', '실습실',  '1공학관', 3, '1302', 30, '이동통신종합실습',         'Y'),
('1305호', '실습실',  '1공학관', 3, '1305', 30, '이동통신네트워크실습',     'Y'),
('1306호', '실습실',  '1공학관', 3, '1306', 30, '안테나실습실',             'Y'),
('1307호', '실습실',  '1공학관', 3, '1307', 30, '통신회로실습실',           'Y');

-- ── 4층 ─────────────────────────────────────────────
INSERT INTO rooms (room_name, room_type, building, floor, room_no, capacity, description, is_active) VALUES
('1401호', '창고',    '1공학관', 4, '1401', 0,  '창고',                    'Y'),
('1402호', '강의실',  '1공학관', 4, '1402', 30, '일학습병행강의실',         'Y'),
('1403호', '강의실',  '1공학관', 4, '1403', 30, '일학습병행강의실',         'Y'),
('1405호', '강의실',  '1공학관', 4, '1405', 45, '강의실',                  'Y'),
('1406호', '강의실',  '1공학관', 4, '1406', 45, '강의실',                  'Y'),
('1407호', '실습실',  '1공학관', 4, '1407', 30, 'ICT실습',                 'Y');

-- ── 5층 ─────────────────────────────────────────────
INSERT INTO rooms (room_name, room_type, building, floor, room_no, capacity, description, is_active) VALUES
('1501호', '강의실',  '1공학관', 5, '1501', 45, '강의실',                  'Y'),
('1502호', '실습실',  '1공학관', 5, '1502', 15, '산업기술연구소',           'Y'),
('1503호', '강의실',  '1공학관', 5, '1503', 45, '강의실',                  'Y'),
('1505호', '강당',    '1공학관', 5, '1505', 200,'강당 겸 실내 체육관',      'Y');

-- ── 확인 ─────────────────────────────────────────────
SELECT room_id, room_name, floor, building FROM rooms WHERE building='1공학관' ORDER BY floor, room_name;
