# CAN 프로젝트 프로세스 설계서 (Process Logic Design)

**ICT CampusNav 프로젝트 단위 기능별 알고리즘 및 비즈니스 로직**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project Code:** CAN-001

**Designed by:** Development Team

---

## 목차

1. [프로세스 설계 개요](#1-프로세스-설계-개요)
2. [인증 프로세스](#2-인증-프로세스)
3. [자산 검색 프로세스](#3-자산-검색-프로세스)
4. [자산 예약 프로세스](#4-자산-예약-프로세스)
5. [자산 이관 프로세스](#5-자산-이관-프로세스)
6. [자산 폐기 프로세스](#6-자산-폐기-프로세스)
7. [내비게이션 프로세스](#7-내비게이션-프로세스)
8. [오류 처리 및 예외](#8-오류-처리-및-예외)

---

## 1. 프로세스 설계 개요

### 1.1 설계 원칙

```
1. 명확성 (Clarity)
   - 각 단계가 분명함
   - 의사결정 지점 명시
   - 예외 처리 명확화

2. 효율성 (Efficiency)
   - 최소 단계로 목표 달성
   - 불필요한 검사 제거
   - 캐싱 활용

3. 안정성 (Reliability)
   - 원자성 (Atomicity) 보장
   - 트랜잭션 관리
   - 에러 복구

4. 확장성 (Scalability)
   - 동시 100명 사용자 처리
   - 8,401개 자산 처리
   - 성능 저하 없음
```

### 1.2 표기법

```
[프로세스명]
Input: 입력 데이터
Output: 출력 데이터
Precondition: 선결 조건
Postcondition: 후조건
Algorithm: 알고리즘 (단계별)
Error Handling: 오류 처리
Performance: 성능 목표
```

---

## 2. 인증 프로세스

### 2.1 로그인 프로세스

```
[사용자 로그인]

Input:
  - username: 문자열
  - password: 문자열
  - rememberMe: 부울값 (선택)

Output:
  - sessionId: 문자열
  - role: 열거형
  - userName: 문자열

Precondition:
  - HTTPS 연결
  - 세션 미보유

Algorithm:
  1. 입력 검증
     - username 길이: 3~50자
     - password 길이: 8~255자
     - username에 특수문자 없음
       
  2. SQL Injection 방지
     - 모든 입력에서 특수문자 이스케이프
     
  3. 데이터베이스 조회
     query: "SELECT user_id, password_hash, role, name 
             FROM users WHERE username = ?"
     params: [username]
     
  4. 비밀번호 검증
     BCrypt.checkpw(inputPassword, storedHash)
     
  5. 검증 결과
     IF checkpw == true:
       ├─ 5-1. 세션 생성
       │        Session.setAttribute("userId", userId)
       │        Session.setAttribute("role", role)
       │        Session.setMaxInactiveInterval(1800) // 30분
       │
       ├─ 5-2. 마지막 로그인 시간 업데이트
       │        UPDATE users SET last_login = NOW() WHERE user_id = ?
       │
       ├─ 5-3. 감시 로그 기록
       │        INSERT INTO audit_log 
       │        (user_id, action, timestamp) VALUES (?, 'LOGIN', NOW())
       │
       └─ 5-4. 성공 응답 반환
              response: {status: 'success', sessionId: JSESSIONID}
     ELSE:
       ├─ 실패 횟수 증가
       │  UPDATE login_attempts SET count = count + 1 
       │  WHERE username = ?
       │
       ├─ 5회 이상 실패 시
       │  UPDATE users SET is_active = FALSE WHERE username = ?
       │
       └─ 오류 응답 반환
          response: {status: 'error', message: '사용자명 또는 비밀번호가 잘못되었습니다'}

Performance:
  - 응답 시간: < 500ms
  - 데이터베이스 쿼리: < 100ms
  - bcrypt 검증: < 300ms

Exception Handling:
  - DB 연결 실패 → 오류 메시지 표시, 로그 기록
  - 비밀번호 해싱 실패 → 500 에러
  - 세션 생성 실패 → 재시도 또는 오류 메시지
```

### 2.2 로그아웃 프로세스

```
[사용자 로그아웃]

Input:
  - JSESSIONID: 세션 ID (쿠키에서)

Output:
  - 로그인 페이지로 리다이렉트

Algorithm:
  1. 세션 확인
     IF session.isNew() OR session == null:
       └─ 이미 로그아웃됨 → 로그인 페이지로 리다이렉트
       
  2. 감시 로그 기록
     userId = session.getAttribute("userId")
     INSERT INTO audit_log 
     (user_id, action, timestamp) 
     VALUES (userId, 'LOGOUT', NOW())
     
  3. 세션 종료
     session.invalidate()
     
  4. JSESSIONID 쿠키 삭제
     cookie.setMaxAge(0)
     response.addCookie(cookie)
     
  5. 로그인 페이지로 리다이렉트
     response.sendRedirect("/login")

Performance:
  - 응답 시간: < 200ms
  - 로그 기록: < 50ms

Exception Handling:
  - 세션 무효화 실패 → 무시하고 계속
  - 로깅 실패 → 경고만 기록
```

---

## 3. 자산 검색 프로세스

### 3.1 자산 검색 알고리즘

```
[자산 검색]

Input:
  - keyword: 문자열 (검색어, 선택사항)
  - category: 문자열 (카테고리, 선택사항)
  - status: 문자열 (상태, 선택사항)
  - page: 정수 (페이지 번호, 기본값: 1)
  - pageSize: 정수 (페이지당 개수, 기본값: 20)

Output:
  - assets: 자산 객체 배열
  - totalCount: 정수
  - pageCount: 정수
  - currentPage: 정수

Precondition:
  - 사용자 로그인 (권한 확인)
  - 검색 권한 보유 (모든 로그인 사용자)

Algorithm:
  1. 입력 검증
     IF keyword != null:
       ├─ 길이: 1~100자
       ├─ 특수문자 이스케이프 (XSS 방지)
       └─ SQL Injection 방지 (PreparedStatement 사용)
       
  2. SQL 쿼리 동적 구성
     query = "SELECT asset_id, asset_name, category, status, location
              FROM assets WHERE 1=1"
     params = []
     
     IF keyword != null:
       query += " AND (asset_name LIKE ? OR description LIKE ?)"
       params.add("%" + keyword + "%")
       params.add("%" + keyword + "%")
       
     IF category != null:
       query += " AND category = ?"
       params.add(category)
       
     IF status != null:
       query += " AND status = ?"
       params.add(status)
     ELSE:
       // 폐기됨 상태는 기본으로 제외
       query += " AND status != 'disposed'"
       
     query += " ORDER BY asset_id DESC"
     
  3. 페이지네이션 계산
     totalCount = COUNT(*) 쿼리 실행
     pageCount = ceil(totalCount / pageSize)
     offset = (page - 1) * pageSize
     
  4. 데이터베이스 쿼리
     query += " LIMIT ? OFFSET ?"
     params.add(pageSize)
     params.add(offset)
     
     ps = connection.prepareStatement(query)
     FOR i = 0 to params.size():
       ps.setParameter(i+1, params[i])
     rs = ps.executeQuery()
     
  5. ResultSet → Asset 객체 변환
     assets = new ArrayList<Asset>()
     WHILE rs.next():
       asset = new Asset()
       asset.setAssetId(rs.getInt("asset_id"))
       asset.setAssetName(rs.getString("asset_name"))
       asset.setCategory(rs.getString("category"))
       asset.setStatus(rs.getString("status"))
       asset.setLocation(rs.getString("location"))
       assets.add(asset)
       
  6. 응답 생성
     response = {
       assets: assets,
       totalCount: totalCount,
       pageCount: pageCount,
       currentPage: page
     }

Performance:
  - 응답 시간: < 2초
  - 데이터베이스 쿼리: < 1.5초
  - 전문 검색 (full-text): < 500ms
  - 메모리 사용: < 5MB (최대 자산 1000개 * 5KB)

Optimization:
  - 인덱스: idx_assets_category_status (category, status)
  - FULLTEXT INDEX on asset_name, description
  - 캐싱 (선택): 자주 검색되는 항목 캐시

Exception Handling:
  - DB 연결 실패 → 오류 메시지, 500 에러
  - PreparedStatement 실패 → 로그 기록, 500 에러
  - 결과 변환 실패 → 부분 반환 또는 재시도
```

---

## 4. 자산 예약 프로세스

### 4.1 자산 예약 알고리즘

```
[자산 예약]

Input:
  - userId: 정수
  - assetId: 정수
  - reservedFrom: DateTime
  - reservedTo: DateTime
  - notes: 문자열 (선택)

Output:
  - reservationId: 정수
  - status: 문자열 ('success' 또는 'error')

Precondition:
  - 사용자 로그인
  - 역할: 학부생 또는 조교
  - assetId가 유효함
  - 자산 상태 != 'disposed'

Algorithm:
  1. 입력 검증
     IF reservedFrom >= reservedTo:
       └─ throw ValidationException("시작 시간이 종료 시간보다 커야 합니다")
       
     IF reservedFrom < NOW() + 1시간:
       └─ throw ValidationException("최소 1시간 이후부터 예약 가능")
       
     IF (reservedTo - reservedFrom) > 30일:
       └─ throw ValidationException("최대 30일까지만 예약 가능")
       
  2. 자산 존재 및 상태 확인
     asset = SELECT * FROM assets WHERE asset_id = ?
     
     IF asset == null:
       └─ throw AssetNotFoundException("자산을 찾을 수 없습니다")
       
     IF asset.status == 'disposed':
       └─ throw AssetDisposedException("폐기된 자산입니다")
       
  3. 예약 가능 시간 확인 (중복 검사)
     existingReservation = SELECT * FROM reservations
       WHERE asset_id = ?
       AND status = 'active'
       AND (
         (reserved_from <= ? AND reserved_to > ?) OR
         (reserved_from < ? AND reserved_to >= ?)
       )
       
     IF existingReservation != null:
       └─ throw ReservationConflictException("이미 예약된 시간입니다")
       
  4. 트랜잭션 시작
     connection.setAutoCommit(false)
     
  5. 예약 데이터 삽입
     INSERT INTO reservations 
     (user_id, asset_id, reserved_from, reserved_to, status, notes, created_at)
     VALUES (?, ?, ?, ?, 'active', ?, NOW())
     
     reservationId = getGeneratedKey()
     
  6. 감시 로그 기록
     INSERT INTO audit_log
     (user_id, action, entity_type, entity_id, details, timestamp)
     VALUES (userId, 'INSERT', 'RESERVATION', reservationId, 
             JSON_OBJECT('asset_name', asset.name), NOW())
     
  7. 트랜잭션 커밋
     connection.commit()
     connection.setAutoCommit(true)
     
  8. 응답 반환
     response = {
       status: 'success',
       reservationId: reservationId,
       message: '예약이 완료되었습니다'
     }

Performance:
  - 응답 시간: < 1초
  - 데이터베이스 쿼리: < 800ms
  - 동시성 처리: < 100ms

Transaction Handling:
  - ACID 특성 보장
  - Isolation Level: READ COMMITTED
  - 락: 낙관적 락 (버전 관리) 또는 비관적 락 (행 잠금)

Exception Handling:
  - ValidationException → 400 오류, 사용자 메시지
  - ReservationConflictException → 409 오류, 가능한 시간 제안
  - AssetNotFoundException → 404 오류
  - DB 오류 → 500 오류, 로그 기록, 트랜잭션 롤백
  - 트랜잭션 실패 → 자동 롤백, 재시도 메시지
```

### 4.2 예약 취소 알고리즘

```
[자산 예약 취소]

Input:
  - userId: 정수 (취소 요청자)
  - reservationId: 정수

Output:
  - status: 문자열 ('success' 또는 'error')

Precondition:
  - 사용자 로그인
  - 자신의 예약만 취소 가능 (역할별 권한)
  - 예약이 활성 상태

Algorithm:
  1. 예약 조회
     reservation = SELECT * FROM reservations WHERE reservation_id = ?
     
     IF reservation == null:
       └─ throw ReservationNotFoundException("예약을 찾을 수 없습니다")
       
  2. 권한 확인
     IF reservation.user_id != userId AND role != 'admin':
       └─ throw UnauthorizedException("권한이 없습니다")
       
  3. 취소 가능 시간 확인
     HOURS_UNTIL_RESERVATION = reservation.reserved_from - NOW()
     
     IF HOURS_UNTIL_RESERVATION < 24:
       └─ throw CancellationNotAllowedException("24시간 이전에만 취소 가능")
       
  4. 예약 상태 업데이트
     UPDATE reservations SET status = 'cancelled', cancelled_at = NOW()
     WHERE reservation_id = ?
     
  5. 감시 로그 기록
     INSERT INTO audit_log
     (user_id, action, entity_type, entity_id, timestamp)
     VALUES (userId, 'UPDATE', 'RESERVATION', reservationId, NOW())
     
  6. 응답 반환
     response = {status: 'success', message: '취소되었습니다'}

Performance:
  - 응답 시간: < 500ms

Exception Handling:
  - CancellationNotAllowedException → 400 오류
  - UnauthorizedException → 403 오류
  - ReservationNotFoundException → 404 오류
```

---

## 5. 자산 이관 프로세스

```
[자산 이관 요청]

Input:
  - userId: 정수 (요청자)
  - assetId: 정수
  - toLocation: 문자열 (도착 위치)
  - reason: 문자열 (이관 사유, 선택)

Algorithm:
  1. 자산 존재 확인
  2. 입력 검증 (위치 형식)
  3. 이관 요청 생성
     INSERT INTO transfers
     (asset_id, from_location, to_location, reason, status, requested_by, created_at)
     VALUES (?, ?, ?, ?, 'pending', ?, NOW())
  4. 감시 로그 기록
  5. 응답 반환 (이관 ID)

[자산 이관 승인 - 조교/관리자]

Input:
  - approverId: 정수 (승인자)
  - transferId: 정수
  - approved: 부울값 (승인 여부)
  - rejectionReason: 문자열 (반려 사유, 선택)

Algorithm:
  1. 이관 요청 조회
  2. 권한 확인 (승인자는 조교/관리자)
  3. 상태 업데이트
     IF approved:
       ├─ UPDATE transfers SET status = 'approved', approved_by = ?, approved_at = NOW()
       ├─ UPDATE assets SET location = ? WHERE asset_id = ?
       └─ 알림 발송
     ELSE:
       └─ UPDATE transfers SET status = 'rejected', rejection_reason = ?
  4. 감시 로그 기록
  5. 응답 반환

Performance:
  - 요청: < 500ms
  - 승인: < 500ms
```

---

## 6. 자산 폐기 프로세스

```
[자산 폐기]

Input:
  - assetIds: 정수 배열
  - reason: 문자열
  - disposedBy: 정수 (관리자)

Algorithm:
  1. 권한 확인 (관리자만)
  2. 자산 존재 확인 (배열의 모든 항목)
  3. 트랜잭션 시작
  4. 각 자산에 대해:
     ├─ UPDATE assets SET status = 'disposed', updated_at = NOW()
     ├─ 기존 예약 취소
     │  UPDATE reservations SET status = 'cancelled'
     │  WHERE asset_id = ? AND status = 'active'
     └─ 감시 로그 기록
  5. 트랜잭션 커밋
  6. 응답 반환

Performance:
  - 단일 자산: < 500ms
  - 배치 (100개): < 2초
```

---

## 7. 내비게이션 프로세스

```
[2D 맵 로드]

Input:
  - floorId: 정수

Output:
  - mapImageUrl: 문자열
  - assets: 자산 객체 배열 (좌표 포함)

Algorithm:
  1. 층 정보 조회
     floor = SELECT * FROM floors WHERE floor_id = ?
     
  2. 해당 층의 자산 조회
     assets = SELECT asset_id, asset_name, status, coordinate_x, coordinate_y
              FROM assets WHERE floor_id = ? AND status != 'disposed'
     
  3. 자산을 상태별로 분류
     availableAssets = [status == 'available']
     reservedAssets = [status == 'reserved']
     suspendedAssets = [status == 'suspended']
     
  4. 맵 데이터 생성
     mapData = {
       mapImageUrl: floor.map_image_url,
       assets: {
         available: availableAssets,
         reserved: reservedAssets,
         suspended: suspendedAssets
       }
     }
     
  5. 응답 반환

[3D 맵 로드 - 클라이언트 사이드]

Input:
  - building: 문자열
  - floor: 정수

Output:
  - 3D 모델 (Three.js로 렌더링)

JavaScript Algorithm:
  1. 3D 모델 파일 로드 (OBJ/glTF)
  2. 부분 모델 스위칭 (층별)
  3. 자산 마커 렌더링 (Mesh 추가)
  4. 마우스 이벤트 처리 (회전, 줌)
  5. 클릭 이벤트 → 자산 상세정보

Performance:
  - 맵 로드: < 500ms
  - 3D 모델 로드: < 3초
  - 프레임레이트: > 30 FPS (목표: 60 FPS)
```

---

## 8. 오류 처리 및 예외

### 8.1 예외 클래스 계층

```
Exception
├─ ValidationException (입력 검증 실패)
│  ├─ InvalidKeywordException
│  ├─ InvalidDateTimeException
│  └─ InvalidLocationException
│
├─ BusinessLogicException (비즈니스 규칙 위반)
│  ├─ ReservationConflictException (시간 겹침)
│  ├─ CancellationNotAllowedException (취소 불가)
│  ├─ AssetDisposedException (폐기된 자산)
│  └─ InsufficientPermissionException (권한 부족)
│
├─ ResourceException (리소스 부재)
│  ├─ UserNotFoundException
│  ├─ AssetNotFoundException
│  ├─ ReservationNotFoundException
│  └─ TransferNotFoundException
│
├─ DataAccessException (데이터 접근 오류)
│  ├─ DatabaseConnectionException
│  ├─ QueryExecutionException
│  └─ TransactionException
│
└─ SystemException (시스템 오류)
   ├─ SessionException
   ├─ ConfigurationException
   └─ InternalServerException
```

### 8.2 오류 응답 형식

```json
{
  "status": "error",
  "errorCode": "ERR_RESERVATION_CONFLICT",
  "message": "이미 예약된 시간입니다",
  "details": {
    "conflictingReservation": {
      "reservationId": 123,
      "reservedFrom": "2026-06-10T10:00:00",
      "reservedTo": "2026-06-10T12:00:00"
    },
    "availableSlots": [
      {
        "start": "2026-06-10T12:00:00",
        "end": "2026-06-10T14:00:00"
      }
    ]
  },
  "timestamp": "2026-05-27T10:30:00Z"
}
```

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| v1.0 | 2026-05-27 | 초판 작성 - 프로세스 설계 | Development Team |

---

**작성 완료 - 2026-05-27**

