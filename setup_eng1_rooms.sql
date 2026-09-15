-- ═══════════════════════════════════════════════════════════
-- 1공학관 전체 설정 SQL
-- 1) rooms 테이블에 픽셀 좌표 컬럼 추가
-- 2) 1공학관 호실 데이터 전체 INSERT
-- ═══════════════════════════════════════════════════════════

USE campusnav;

-- ── STEP 1: 픽셀 좌표 컬럼 추가 (이미 있으면 무시) ──
ALTER TABLE rooms ADD COLUMN pixel_x   FLOAT        DEFAULT NULL COMMENT '실내 도면 X좌표';
ALTER TABLE rooms ADD COLUMN pixel_y   FLOAT        DEFAULT NULL COMMENT '실내 도면 Y좌표';
ALTER TABLE rooms ADD COLUMN pin_dim   VARCHAR(5)   DEFAULT '3D' COMMENT '2D/3D 구분';
ALTER TABLE rooms ADD COLUMN pin_floor VARCHAR(10)  DEFAULT NULL COMMENT '저장된 층';

-- ── STEP 2: 기존 1공학관 데이터 삭제 후 재삽입 ──
DELETE FROM rooms WHERE building = '1공학관';

-- ───── 1층 ─────
INSERT INTO rooms (building, floor, room_no, room_name, room_type, description, is_active) VALUES
('1공학관', 1, '1101', '1101호', '실습실', '컴퓨터 실습실', 'Y'),
('1공학관', 1, '1102', '1102호', '실습실', '컴퓨터 실습실', 'Y'),
('1공학관', 1, '1103', '1103호', '실습실', '컴퓨터 실습실', 'Y'),
('1공학관', 1, '1105', '1105호', '실습실', '컴퓨터 실습실', 'Y'),
('1공학관', 1, '1106', '1106호', '실습실', '컴퓨터 실습실', 'Y'),
('1공학관', 1, '1107', '1107호', '실습실', '컴퓨터 실습실', 'Y');

-- ───── 2층 ─────
INSERT INTO rooms (building, floor, room_no, room_name, room_type, description, is_active) VALUES
('1공학관', 2, '1201', '1201호', '회의실',  '회의실',                   'Y'),
('1공학관', 2, '1202', '1202호', '실습실',  '도면설계실습실',            'Y'),
('1공학관', 2, '1203', '1203호', '강의실',  '강의실',                   'Y'),
('1공학관', 2, '1205', '1205호', '실습실',  '멀티미디어 기초실습',       'Y'),
('1공학관', 2, '1206', '1206호', '실습실',  '멀티미디어통신실습실',      'Y'),
('1공학관', 2, '1207', '1207호', '실습실',  '멀티미디어통신실습실',      'Y');

-- ───── 3층 ─────
INSERT INTO rooms (building, floor, room_no, room_name, room_type, description, is_active) VALUES
('1공학관', 3, '1301', '1301호', '강의실',  '강의실',                   'Y'),
('1공학관', 3, '1302', '1302호', '실습실',  '이동통신종합실습',          'Y'),
('1공학관', 3, '1305', '1305호', '실습실',  '이동통신네트워크실습',      'Y'),
('1공학관', 3, '1306', '1306호', '실습실',  '안테나실습실',              'Y'),
('1공학관', 3, '1307', '1307호', '실습실',  '통신회로실습실',            'Y');

-- ───── 4층 ─────
INSERT INTO rooms (building, floor, room_no, room_name, room_type, description, is_active) VALUES
('1공학관', 4, '1401', '1401호', '창고',    '창고',                     'Y'),
('1공학관', 4, '1402', '1402호', '강의실',  '일학습병행강의실',          'Y'),
('1공학관', 4, '1403', '1403호', '강의실',  '일학습병행강의실',          'Y'),
('1공학관', 4, '1405', '1405호', '강의실',  '강의실',                   'Y'),
('1공학관', 4, '1406', '1406호', '강의실',  '강의실',                   'Y'),
('1공학관', 4, '1407', '1407호', '실습실',  'ICT실습',                  'Y');

-- ───── 5층 ─────
INSERT INTO rooms (building, floor, room_no, room_name, room_type, description, is_active) VALUES
('1공학관', 5, '1501', '1501호', '강의실',  '강의실',                   'Y'),
('1공학관', 5, '1502', '1502호', '연구소',  '산업기술연구소',            'Y'),
('1공학관', 5, '1503', '1503호', '강의실',  '강의실',                   'Y'),
('1공학관', 5, '1505', '1505호', '체육관',  '강당 겸 실내 체육관',       'Y');

-- ── 확인 ──
SELECT floor, room_no, room_name, description FROM rooms
WHERE building = '1공학관' ORDER BY floor, room_no;
