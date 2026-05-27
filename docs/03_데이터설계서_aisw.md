# CAN 프로젝트 데이터 설계서 (Data Design)

**ICT CampusNav 프로젝트 데이터베이스 및 데이터 구조 설계**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project Code:** CAN-001

**Designed by:** Development Team

---

## 목차

1. [데이터 설계 개요](#1-데이터-설계-개요)
2. [논리 데이터 모델 (ER Diagram)](#2-논리-데이터-모델-er-diagram)
3. [테이블 상세 정의](#3-테이블-상세-정의)
4. [데이터 타입 및 크기](#4-데이터-타입-및-크기)
5. [인덱싱 전략](#5-인덱싱-전략)
6. [데이터 무결성 제약](#6-데이터-무결성-제약)
7. [데이터 보안](#7-데이터-보안)
8. [초기 데이터 로드](#8-초기-데이터-로드)

---

## 1. 데이터 설계 개요

### 1.1 목표
- 8,401개 자산 데이터 효율적 저장
- 동시 100명 사용자 처리 가능한 성능
- 데이터 일관성 및 무결성 보장
- 확장 가능한 스키마 설계

### 1.2 설계 원칙
- **정규화:** 3NF 준수 (데이터 중복 최소화)
- **성능:** 자주 조회되는 데이터는 비정규화 고려
- **보안:** 민감정보 암호화, 접근 제어
- **확장성:** 향후 추가 기능 수용 가능

---

## 2. 논리 데이터 모델 (ER Diagram)

```
┌─────────────┐
│   users     │
├─────────────┤
│ user_id (PK)│
│ username    │
│ password    │
│ name        │
│ role        │
│ email       │
│ phone       │
│ department  │
│ created_at  │
└──────┬──────┘
       │ 1:N
       │
   ┌───┴───────────┐
   │               │
┌──┴──────────┐   │   ┌─────────────────┐
│assets       │   └──→│reservations     │
├─────────────┤       ├─────────────────┤
│asset_id (PK)│       │reservation_id(PK)
│asset_name   │       │user_id (FK)     │
│category     │       │asset_id (FK)    │
│description  │       │reserved_from    │
│status       │       │reserved_to      │
│owner_id(FK) │       │status           │
│location     │       │created_at       │
│created_at   │       └─────────────────┘
└──────┬──────┘
       │ 1:N
       │
   ┌───┴──────────────┐
   │                  │
┌──┴──────────────┐   │   ┌──────────────────┐
│transfers       │   └──→│audit_log         │
├─────────────────┤       ├──────────────────┤
│transfer_id (PK)│       │log_id (PK)       │
│asset_id (FK)   │       │user_id (FK)      │
│from_location   │       │action            │
│to_location     │       │entity_type       │
│reason          │       │entity_id         │
│status          │       │timestamp         │
│approved_by (FK)│       └──────────────────┘
│approved_at     │
│created_at      │
└─────────────────┘

┌──────────────────┐
│professors        │
├──────────────────┤
│professor_id (PK) │
│user_id (FK)      │
│title             │
│department        │
│office_location   │
└────────┬─────────┘
         │ 1:N
         │
    ┌────┴─────────┐
    │              │
┌───┴──────┐  ┌───┴────────┐
│courses   │  │skills      │
├──────────┤  ├────────────┤
│course_id │  │skill_id    │
│prof_id   │  │prof_id     │
│name      │  │skill_name  │
│semester  │  └────────────┘
└──────────┘

┌──────────────┐
│floors        │
├──────────────┤
│floor_id (PK) │
│floor_number  │
│building_name │
│map_image_url │
└──────────────┘

┌──────────────────┐
│routes           │
├──────────────────┤
│route_id (PK)    │
│user_id (FK)     │
│route_name       │
│start_point      │
│end_point        │
│waypoints (JSON) │
│created_at       │
└──────────────────┘
```

---

## 3. 테이블 상세 정의

### 3.1 users 테이블 (사용자)

```sql
CREATE TABLE users (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    role ENUM('student', 'assistant', 'professor', 'admin', 'guest', 'visitor') NOT NULL,
    email VARCHAR(100),
    phone VARCHAR(20),
    department VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    last_login TIMESTAMP,
    INDEX idx_username (username),
    INDEX idx_role (role)
);
```

**컬럼 설명:**
- `user_id`: 자동 증가 기본키
- `username`: 로그인 ID (중복 불가)
- `password_hash`: bcrypt 해시 값
- `role`: 6가지 역할 중 하나
- `is_active`: 활성/비활성 여부
- `last_login`: 마지막 로그인 시간

---

### 3.2 assets 테이블 (자산)

```sql
CREATE TABLE assets (
    asset_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_name VARCHAR(255) NOT NULL,
    category VARCHAR(100) NOT NULL,
    description TEXT,
    status ENUM('available', 'reserved', 'suspended', 'disposed') DEFAULT 'available',
    owner_id INT NOT NULL,
    location VARCHAR(255),
    floor_id INT,
    coordinate_x INT,
    coordinate_y INT,
    image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (owner_id) REFERENCES users(user_id),
    FOREIGN KEY (floor_id) REFERENCES floors(floor_id),
    INDEX idx_category (category),
    INDEX idx_status (status),
    INDEX idx_owner_id (owner_id),
    FULLTEXT INDEX ft_asset_name (asset_name),
    FULLTEXT INDEX ft_description (description)
);
```

**컬럼 설명:**
- `asset_id`: 자동 증가 기본키
- `asset_name`: 자산명 (전문 검색 지원)
- `category`: 카테고리 (인덱싱)
- `status`: 상태 (상태별 필터링 위함)
- `owner_id`: 자산 소유자 (FK)
- `location`: 텍스트 위치 (예: "3층 실습실 A")
- `coordinate_x/y`: 2D 맵 좌표
- `floor_id`: 층 정보 (FK)

---

### 3.3 reservations 테이블 (자산 예약)

```sql
CREATE TABLE reservations (
    reservation_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    asset_id INT NOT NULL,
    reserved_from DATETIME NOT NULL,
    reserved_to DATETIME NOT NULL,
    status ENUM('active', 'cancelled') DEFAULT 'active',
    notes VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    cancelled_at TIMESTAMP NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
    INDEX idx_asset_id (asset_id),
    INDEX idx_user_id (user_id),
    INDEX idx_reserved_from (reserved_from),
    INDEX idx_reserved_to (reserved_to),
    INDEX idx_status (status),
    UNIQUE KEY uk_no_overlap (asset_id, reserved_from, reserved_to, status)
);
```

**컬럼 설명:**
- `reservation_id`: 자동 증가 기본키
- `reserved_from/to`: 예약 시간 범위
- `status`: 활성/취소됨
- `uk_no_overlap`: 시간 겹침 방지 제약

---

### 3.4 transfers 테이블 (자산 이관)

```sql
CREATE TABLE transfers (
    transfer_id INT AUTO_INCREMENT PRIMARY KEY,
    asset_id INT NOT NULL,
    from_location VARCHAR(255) NOT NULL,
    to_location VARCHAR(255) NOT NULL,
    reason VARCHAR(255),
    status ENUM('pending', 'approved', 'rejected') DEFAULT 'pending',
    requested_by INT NOT NULL,
    approved_by INT,
    approved_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id),
    FOREIGN KEY (requested_by) REFERENCES users(user_id),
    FOREIGN KEY (approved_by) REFERENCES users(user_id),
    INDEX idx_asset_id (asset_id),
    INDEX idx_status (status),
    INDEX idx_created_at (created_at)
);
```

---

### 3.5 professors 테이블 (교수)

```sql
CREATE TABLE professors (
    professor_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL UNIQUE,
    title VARCHAR(50),
    department VARCHAR(100) NOT NULL,
    office_location VARCHAR(255),
    office_phone VARCHAR(20),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_department (department)
);
```

---

### 3.6 courses 테이블 (교과목)

```sql
CREATE TABLE courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    professor_id INT NOT NULL,
    course_name VARCHAR(255) NOT NULL,
    semester VARCHAR(20),
    capacity INT,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (professor_id) REFERENCES professors(professor_id),
    INDEX idx_professor_id (professor_id)
);
```

---

### 3.7 floors 테이블 (층별 정보)

```sql
CREATE TABLE floors (
    floor_id INT AUTO_INCREMENT PRIMARY KEY,
    building_name VARCHAR(100) NOT NULL,
    floor_number INT NOT NULL,
    floor_name VARCHAR(100),
    map_image_url VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    UNIQUE KEY uk_building_floor (building_name, floor_number),
    INDEX idx_building_name (building_name)
);
```

---

### 3.8 routes 테이블 (저장된 경로)

```sql
CREATE TABLE routes (
    route_id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    route_name VARCHAR(255) NOT NULL,
    start_point VARCHAR(255) NOT NULL,
    end_point VARCHAR(255) NOT NULL,
    waypoints JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_user_id (user_id)
);
```

---

### 3.9 audit_log 테이블 (감시 로그)

```sql
CREATE TABLE audit_log (
    log_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id INT,
    action VARCHAR(50) NOT NULL,
    entity_type VARCHAR(50) NOT NULL,
    entity_id INT,
    details JSON,
    ip_address VARCHAR(45),
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    INDEX idx_timestamp (timestamp),
    INDEX idx_entity_type (entity_type),
    INDEX idx_user_id (user_id),
    INDEX idx_action (action)
);
```

---

## 4. 데이터 타입 및 크기

### 4.1 숫자 타입

| 타입 | 범위 | 사용처 |
|------|------|--------|
| **INT** | -2^31 ~ 2^31-1 | ID, 숫자 데이터 |
| **BIGINT** | -2^63 ~ 2^63-1 | 감시 로그 ID (대용량) |
| **DECIMAL(10,2)** | 정확한 소수 | 가격 (미래) |

### 4.2 문자 타입

| 타입 | 최대 크기 | 사용처 |
|------|---------|--------|
| **VARCHAR(50)** | 50 bytes | username, phone |
| **VARCHAR(100)** | 100 bytes | name, email, department |
| **VARCHAR(255)** | 255 bytes | asset_name, description, location |
| **TEXT** | 65KB | 큰 텍스트 |

### 4.3 날짜/시간 타입

| 타입 | 범위 | 사용처 |
|------|------|--------|
| **DATE** | 1000-01-01 ~ 9999-12-31 | 날짜만 필요 시 |
| **DATETIME** | 1000-01-01 ~ 9999-12-31 23:59:59 | 정확한 시간 필요 |
| **TIMESTAMP** | 1970-01-01 ~ 2038-01-19 | 자동 관리 (created_at, updated_at) |

### 4.4 특수 타입

| 타입 | 사용처 |
|------|--------|
| **ENUM** | role, status 제약 조건 |
| **JSON** | waypoints (JSON 배열), details (동적 데이터) |
| **BLOB** | 이미지 (선택사항, 보통 URL 저장) |

---

## 5. 인덱싱 전략

### 5.1 주요 인덱스

```sql
-- 자산 검색 최적화
CREATE INDEX idx_assets_category_status ON assets(category, status);
CREATE INDEX idx_assets_status_owner ON assets(status, owner_id);

-- 예약 쿼리 최적화
CREATE INDEX idx_reservations_asset_date ON reservations(asset_id, reserved_from, reserved_to);
CREATE INDEX idx_reservations_user_status ON reservations(user_id, status);

-- 전문 검색 (Full-text Search)
ALTER TABLE assets ADD FULLTEXT INDEX ft_asset_search (asset_name, description);

-- 사용자 조회 최적화
CREATE INDEX idx_users_username ON users(username);
CREATE INDEX idx_users_role ON users(role);

-- 감시 로그 분석
CREATE INDEX idx_audit_log_timestamp_user ON audit_log(timestamp, user_id);
CREATE INDEX idx_audit_log_entity ON audit_log(entity_type, entity_id);
```

### 5.2 인덱싱 이득

| 쿼리 | 인덱스 | 예상 성능 개선 |
|------|--------|--------------|
| 자산 검색 (카테고리+상태) | idx_assets_category_status | ~90% 빠름 |
| 예약 조회 (시간 겹침 검사) | idx_reservations_asset_date | ~85% 빠름 |
| 사용자 로그인 | idx_users_username | ~99% 빠름 |
| 감시 로그 조회 | idx_audit_log_timestamp_user | ~80% 빠름 |

---

## 6. 데이터 무결성 제약

### 6.1 기본키 (Primary Key)

모든 테이블에 AUTO_INCREMENT 기본키 정의:
```sql
-- 자동 증가 기본키
user_id INT AUTO_INCREMENT PRIMARY KEY
asset_id INT AUTO_INCREMENT PRIMARY KEY
-- ... 기타
```

### 6.2 외래키 (Foreign Key)

```sql
-- users와의 관계
ALTER TABLE assets ADD CONSTRAINT fk_assets_owner 
    FOREIGN KEY (owner_id) REFERENCES users(user_id);

ALTER TABLE reservations ADD CONSTRAINT fk_reservations_user 
    FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE transfers ADD CONSTRAINT fk_transfers_requester 
    FOREIGN KEY (requested_by) REFERENCES users(user_id);

-- assets와의 관계
ALTER TABLE reservations ADD CONSTRAINT fk_reservations_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id);

ALTER TABLE transfers ADD CONSTRAINT fk_transfers_asset 
    FOREIGN KEY (asset_id) REFERENCES assets(asset_id);
```

### 6.3 Unique 제약

```sql
-- 중복 불가
ALTER TABLE users ADD UNIQUE KEY uk_username (username);

-- 예약 시간 겹침 방지
ALTER TABLE reservations ADD UNIQUE KEY uk_no_overlap 
    (asset_id, reserved_from, reserved_to, status);
```

### 6.4 Check 제약 (선택)

```sql
-- 시간 논리 검증 (애플리케이션 레벨에서도 검증)
ALTER TABLE reservations ADD CONSTRAINT chk_time_order 
    CHECK (reserved_from < reserved_to);

-- 상태 제약
ALTER TABLE assets ADD CONSTRAINT chk_status 
    CHECK (status IN ('available', 'reserved', 'suspended', 'disposed'));
```

---

## 7. 데이터 보안

### 7.1 민감정보 보호

```sql
-- 비밀번호는 bcrypt 해시로만 저장
-- 원본 비밀번호 절대 저장 금지

-- 사용자 개인정보 접근 제한
CREATE USER 'campusnav_user'@'localhost' IDENTIFIED BY 'strong_password';
GRANT SELECT, INSERT, UPDATE ON campusnav.* TO 'campusnav_user'@'localhost';
-- DELETE 권한 제한 (소프트 딜리트만 사용)
```

### 7.2 감시 로그

모든 수정 작업 기록:
```sql
-- INSERT
INSERT INTO audit_log (user_id, action, entity_type, entity_id, details)
VALUES (123, 'INSERT', 'ASSET', 456, JSON_OBJECT('asset_name', '현미경'));

-- UPDATE
INSERT INTO audit_log (user_id, action, entity_type, entity_id, details)
VALUES (123, 'UPDATE', 'ASSET', 456, JSON_OBJECT('old_status', 'available', 'new_status', 'reserved'));

-- DELETE (논리적 삭제만)
UPDATE assets SET status = 'disposed' WHERE asset_id = 456;
INSERT INTO audit_log (user_id, action, entity_type, entity_id)
VALUES (123, 'DELETE', 'ASSET', 456);
```

### 7.3 SQL Injection 방지

```java
// ❌ 위험 (문자열 연결)
String query = "SELECT * FROM assets WHERE asset_name = '" + keyword + "'";

// ✅ 안전 (PreparedStatement)
String query = "SELECT * FROM assets WHERE asset_name LIKE ?";
PreparedStatement ps = connection.prepareStatement(query);
ps.setString(1, "%" + keyword + "%");
```

---

## 8. 초기 데이터 로드

### 8.1 데이터 마이그레이션 계획

```sql
-- 1. 기존 자산 데이터 로드
-- 파일: mysql에다넣고실행_fixed.sql
-- 내용: INSERT INTO assets VALUES (...)

-- 2. 테스트 사용자 생성
INSERT INTO users (username, password_hash, name, role, department)
VALUES 
    ('student1', '$2a$10$...bcrypt...', '학부생1', 'student', '정보통신과'),
    ('assistant1', '$2a$10$...bcrypt...', '조교1', 'assistant', '정보통신과'),
    ('prof1', '$2a$10$...bcrypt...', '교수1', 'professor', '정보통신과'),
    ('admin', '$2a$10$...bcrypt...', '관리자', 'admin', '전산실');

-- 3. 층 정보 로드
INSERT INTO floors (building_name, floor_number, floor_name, map_image_url)
VALUES 
    ('본관', 1, '1층', '/floormaps/1floor.jpg'),
    ('본관', 2, '2층', '/floormaps/2floor.jpg'),
    ('본관', 3, '3층', '/floormaps/3floor.jpg'),
    ('본관', 4, '4층', '/floormaps/4floor.jpg'),
    ('본관', 5, '5층', '/floormaps/5floor.jpg');
```

### 8.2 데이터 검증 쿼리

```sql
-- 자산 데이터 정합성 확인
SELECT COUNT(*) FROM assets; -- 8,401개 확인

-- 중복 자산 확인
SELECT asset_name, COUNT(*) FROM assets GROUP BY asset_name HAVING COUNT(*) > 1;

-- NULL 값 확인
SELECT COUNT(*) FROM assets WHERE asset_name IS NULL OR category IS NULL;

-- 시간 역순 데이터 확인 (생성 시간이 업데이트 시간보다 나중)
SELECT COUNT(*) FROM assets WHERE created_at > updated_at;
```

### 8.3 백업 및 복구

```bash
# 데이터베이스 백업
mysqldump -u root -p campusnav > backup_20260527.sql

# 복구
mysql -u root -p campusnav < backup_20260527.sql

# 정기 백업 (cron 작업)
0 2 * * * mysqldump -u root -p campusnav > /backups/db_$(date +\%Y\%m\%d).sql
```

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| v1.0 | 2026-05-27 | 초판 작성 - 데이터 스키마 설계 | Development Team |

---

**작성 완료 - 2026-05-27**

