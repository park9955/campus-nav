-- ============================================================
-- ICT CAN 시스템 테스트 계정 생성 SQL
-- 날짜: 2026-09-29
-- ============================================================

-- 기존 모든 사용자 계정 삭제
TRUNCATE TABLE `users`;

-- 테스트 계정 생성
INSERT INTO `users` (user_id, user_pw, user_name, user_email, dept, student_num, role, use_yn)
VALUES
('student', '1234', '학부생테스트', 'student@test.ac.kr', '컴퓨터공학', '20240001', 'student', 'Y'),
('assistant', '1234', '조교테스트', 'assistant@test.ac.kr', '정보통신', NULL, 'assistant', 'Y'),
('professor', '1234', '교수테스트', 'professor@test.ac.kr', '정보통신대학', NULL, 'professor', 'Y'),
('admin', '1234', '관리자테스트', 'admin@test.ac.kr', '관리자', NULL, 'admin', 'Y');

-- ============================================================
-- 로그인 정보
-- ============================================================
-- 학부생:  student / 1234
-- 조교:    assistant / 1234
-- 교수:    professor / 1234
-- 관리자:  admin / 1234
-- ============================================================
