-- rooms 테이블에 실내 도면 픽셀 좌표 컬럼 추가
-- floorNav.jsp에서 마커 위치 저장용

USE campusnav;

-- 픽셀 좌표 컬럼 추가 (이미 있으면 오류나도 OK)
ALTER TABLE rooms ADD COLUMN pixel_x FLOAT DEFAULT NULL COMMENT '실내 도면 X좌표';
ALTER TABLE rooms ADD COLUMN pixel_y FLOAT DEFAULT NULL COMMENT '실내 도면 Y좌표';
ALTER TABLE rooms ADD COLUMN pin_dim VARCHAR(5) DEFAULT '3D' COMMENT '2D/3D 구분';
ALTER TABLE rooms ADD COLUMN pin_floor VARCHAR(10) DEFAULT NULL COMMENT '저장된 층 (예: 1, 2, 지하)';

-- 확인
SELECT room_id, building, floor, room_name, pixel_x, pixel_y, pin_dim, pin_floor FROM rooms LIMIT 10;
