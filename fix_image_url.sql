-- 이미지 경로 수정: /CampusNav/ → /CAN/
-- nav.sql 실행 후 이 파일을 실행하세요

USE campusnav;
SET SQL_SAFE_UPDATES = 0;

-- 1. /CampusNav/images/locations/ → /CAN/images/ 경로 변경
UPDATE campus_entrances
SET image_url = REPLACE(image_url, '/CampusNav/images/locations/', '/CAN/images/locations/')
WHERE image_url LIKE '%/CampusNav/images/locations/%';

-- 2. NULL 값에 기본 이미지 경로 설정 (건물별)
UPDATE campus_entrances
SET image_url = '/CAN/images/locations/eng1.jpg'
WHERE building = '1공학관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/eng2.jpg'
WHERE building = '2공학관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/dorm1.jpg'
WHERE building = '1생활관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/dorm2.jpg'
WHERE building = '2생활관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/main.jpg'
WHERE building = '대학본부' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/library.jpg'
WHERE building = '도서관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/student.jpg'
WHERE building = '학생회관' AND image_url IS NULL;

UPDATE campus_entrances
SET image_url = '/CAN/images/locations/lounge.jpg'
WHERE building = '휴게실' AND image_url IS NULL;

SET SQL_SAFE_UPDATES = 1;

-- 확인 쿼리
SELECT entrance_id, entrance_name, building, image_url FROM campus_entrances WHERE image_url IS NOT NULL;
