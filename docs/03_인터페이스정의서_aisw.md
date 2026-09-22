# CAN 프로젝트 인터페이스 정의서 (Integration Specification)

**ICT CampusNav 프로젝트 컴포넌트 및 API 인터페이스 정의**

**Version:** 1.0 | **Date:** 2026-05-27 | **Project Code:** CAN-001

**Designed by:** Development Team

---

## 목차

1. [인터페이스 정의 개요](#1-인터페이스-정의-개요)
2. [Servlet 인터페이스](#2-servlet-인터페이스)
3. [DAO 인터페이스](#3-dao-인터페이스)
4. [데이터 전문 정의](#4-데이터-전문-정의)
5. [JSP-Servlet 통신](#5-jsp-servlet-통신)
6. [Servlet-DAO 통신](#6-servlet-dao-통신)
7. [REST API (향후)](#7-rest-api-향후)
8. [에러 응답 형식](#8-에러-응답-형식)

---

## 1. 인터페이스 정의 개요

### 1.1 통신 패턴

```
JSP (View)
  ↓↑ HTTP Request/Response
Servlet (Controller)
  ↓↑ 메서드 호출
DAO (Model) & DBUtil
  ↓↑ SQL Query
MySQL Database
```

### 1.2 인터페이스 정의 요소

```
1. Servlet 인터페이스
   ├─ 요청 파라미터 (Query String, Form Data)
   ├─ 응답 속성 (request.setAttribute)
   └─ 포워드 대상 (JSP)

2. DAO 인터페이스
   ├─ 메서드 시그니처
   ├─ 파라미터 정의
   ├─ 반환값 정의
   └─ 예외 정의

3. 데이터 전문 (Data Format)
   ├─ JSON (향후 API용)
   ├─ Entity 객체
   └─ HTTP 파라미터
```

---

## 2. Servlet 인터페이스

### 2.1 LoginServlet

```java
/**
 * 사용자 인증 처리
 * 요청: POST /login
 * 응답: redirect to main page or login page
 */
public class LoginServlet extends HttpServlet {
    
    public void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        // 입력 파라미터
        String username = request.getParameter("username"); // 필수
        String password = request.getParameter("password");  // 필수
        
        // 처리
        // 1. 입력 검증
        // 2. 사용자 조회 및 비밀번호 확인
        // 3. 세션 생성
        // 4. 감시 로그 기록
        
        // 응답
        if (success) {
            // 역할별 메인 페이지로 리다이렉트
            // student → /user/main_student.jsp
            // assistant → /user/main_assistant.jsp
            // professor → /user/main_professor.jsp
            // admin → /user/main_admin.jsp
            response.sendRedirect("/user/main_" + role + ".jsp");
        } else {
            // 로그인 페이지로 리다이렉트 (오류 메시지 포함)
            request.setAttribute("errorMessage", "사용자명 또는 비밀번호가 잘못되었습니다");
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}

/* HTTP 프로토콜 정의 */
POST /login HTTP/1.1
Content-Type: application/x-www-form-urlencoded

username=student1&password=1234567890

// 성공 응답
HTTP/1.1 302 Found
Location: /user/main_student.jsp
Set-Cookie: JSESSIONID=ABC123...

// 실패 응답
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
[login.jsp with error message]
```

### 2.2 SearchServlet

```java
/**
 * 자산 검색
 * 요청: GET /search
 * 응답: forward to searchAssets.jsp
 */
public class SearchServlet extends HttpServlet {
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        // 입력 파라미터
        String keyword = request.getParameter("keyword");     // 선택사항
        String category = request.getParameter("category");   // 선택사항
        String status = request.getParameter("status");       // 선택사항
        String pageStr = request.getParameter("page");        // 기본값: "1"
        String pageSizeStr = request.getParameter("size");    // 기본값: "20"
        
        int page = pageStr != null ? Integer.parseInt(pageStr) : 1;
        int pageSize = pageSizeStr != null ? Integer.parseInt(pageSizeStr) : 20;
        
        // 처리
        // 1. 입력 검증 (keyword, category, status)
        // 2. AssetDAO.searchAssets(keyword, category, status, page, pageSize) 호출
        // 3. 결과를 List<Asset>으로 변환
        // 4. 페이지네이션 정보 계산
        
        // 응답 속성 설정
        request.setAttribute("searchResults", assets);       // List<Asset>
        request.setAttribute("totalCount", totalCount);      // int
        request.setAttribute("pageCount", pageCount);        // int
        request.setAttribute("currentPage", page);           // int
        request.setAttribute("keyword", keyword);            // String
        request.setAttribute("category", category);          // String
        request.setAttribute("status", status);              // String
        
        // JSP로 포워드
        request.getRequestDispatcher("/searchAssets.jsp").forward(request, response);
    }
}

/* HTTP 프로토콜 정의 */
GET /search?keyword=현미경&category=실험장비&status=available&page=1&size=20 HTTP/1.1

// 응답
HTTP/1.1 200 OK
Content-Type: text/html; charset=UTF-8
[searchAssets.jsp rendered with data]
```

### 2.3 DetailServlet

```java
/**
 * 자산 상세정보 조회
 * 요청: GET /asset/{assetId}
 * 응답: forward to detail.jsp
 */
public class DetailServlet extends HttpServlet {
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        
        // 입력 파라미터
        String assetIdStr = request.getParameter("assetId"); // 필수
        int assetId = Integer.parseInt(assetIdStr);
        
        // 처리
        // 1. AssetDAO.getAssetById(assetId) 호출
        // 2. 자산이 없으면 404 에러
        // 3. ReservationDAO.getReservations(assetId) 호출
        // 4. TransferDAO.getTransferHistory(assetId, limit=3) 호출
        
        // 응답 속성 설정
        request.setAttribute("asset", asset);               // Asset
        request.setAttribute("reservations", reservations); // List<Reservation>
        request.setAttribute("transferHistory", transfers); // List<Transfer>
        
        // JSP로 포워드
        request.getRequestDispatcher("/detail.jsp").forward(request, response);
    }
}
```

### 2.4 ReserveServlet

```java
/**
 * 자산 예약 처리
 * 요청 (GET): GET /reserve?assetId=456 → reserve.jsp 표시
 * 요청 (POST): POST /reserve → 예약 생성
 * 응답: redirect or forward
 */
public class ReserveServlet extends HttpServlet {
    
    public void doGet(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        // 예약 폼 표시
        String assetIdStr = request.getParameter("assetId");
        int assetId = Integer.parseInt(assetIdStr);
        
        Asset asset = assetDAO.getAssetById(assetId);
        request.setAttribute("asset", asset);
        
        request.getRequestDispatcher("/reserve.jsp").forward(request, response);
    }
    
    public void doPost(HttpServletRequest request, HttpServletResponse response)
        throws ServletException, IOException {
        // 예약 처리
        int userId = (Integer) request.getSession().getAttribute("userId");
        int assetId = Integer.parseInt(request.getParameter("assetId"));
        String fromStr = request.getParameter("reservedFrom");      // "2026-06-10 10:00"
        String toStr = request.getParameter("reservedTo");          // "2026-06-10 12:00"
        String notes = request.getParameter("notes");               // 선택사항
        
        // 처리 (ReserveServlet 참고)
        // ...
        
        // 응답
        if (success) {
            response.sendRedirect("/asset/detail?assetId=" + assetId);
        } else {
            request.setAttribute("errorMessage", errorMessage);
            doGet(request, response); // 폼 다시 표시
        }
    }
}

/* HTTP 프로토콜 정의 */
// 폼 조회
GET /reserve?assetId=456 HTTP/1.1

// 예약 신청
POST /reserve HTTP/1.1
Content-Type: application/x-www-form-urlencoded

assetId=456&reservedFrom=2026-06-10+10:00&reservedTo=2026-06-10+12:00&notes=실습용
```

---

## 3. DAO 인터페이스

### 3.1 AssetDAO

```java
/**
 * 자산 데이터 접근 객체
 */
public class AssetDAO {
    
    /**
     * 자산 목록 검색
     * @param keyword 검색어 (null 가능)
     * @param category 카테고리 (null 가능)
     * @param status 상태 (null 가능)
     * @param limit 최대 행 수
     * @param offset 시작 위치
     * @return List<Asset>
     */
    public List<Asset> searchAssets(
        String keyword, 
        String category, 
        String status,
        int limit,
        int offset
    ) throws DataAccessException;
    
    /**
     * 자산 상세정보 조회
     * @param assetId 자산 ID
     * @return Asset 객체 (없으면 null)
     */
    public Asset getAssetById(int assetId) throws DataAccessException;
    
    /**
     * 자산 전체 검색 결과 수
     * @param keyword 검색어
     * @param category 카테고리
     * @param status 상태
     * @return 검색 결과 총 개수
     */
    public int countSearchResults(
        String keyword,
        String category,
        String status
    ) throws DataAccessException;
    
    /**
     * 자산 상태 업데이트
     * @param assetId 자산 ID
     * @param newStatus 새로운 상태
     * @throws DataAccessException
     */
    public void updateAssetStatus(
        int assetId,
        String newStatus
    ) throws DataAccessException;
}

/* Entity 정의 */
public class Asset {
    private int assetId;
    private String assetName;
    private String category;
    private String description;
    private String status;        // 'available', 'reserved', 'suspended', 'disposed'
    private int ownerId;
    private String location;
    private int floorId;
    private Integer coordinateX;
    private Integer coordinateY;
    private String imageUrl;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    
    // getters/setters
}
```

### 3.2 ReservationDAO

```java
public class ReservationDAO {
    
    /**
     * 자산 예약 생성
     * @param userId 사용자 ID
     * @param assetId 자산 ID
     * @param reservedFrom 예약 시작
     * @param reservedTo 예약 종료
     * @param notes 메모 (선택)
     * @return 예약 ID
     */
    public int createReservation(
        int userId,
        int assetId,
        LocalDateTime reservedFrom,
        LocalDateTime reservedTo,
        String notes
    ) throws DataAccessException, ReservationConflictException;
    
    /**
     * 예약 시간 겹침 여부 확인
     * @param assetId 자산 ID
     * @param reservedFrom 예약 시작
     * @param reservedTo 예약 종료
     * @return 충돌하는 예약이 있으면 true
     */
    public boolean hasConflict(
        int assetId,
        LocalDateTime reservedFrom,
        LocalDateTime reservedTo
    ) throws DataAccessException;
    
    /**
     * 사용자의 예약 목록
     * @param userId 사용자 ID
     * @param limit 최대 개수
     * @return List<Reservation>
     */
    public List<Reservation> getReservationsByUser(
        int userId,
        int limit
    ) throws DataAccessException;
    
    /**
     * 자산의 예약 이력
     * @param assetId 자산 ID
     * @param limit 최대 개수
     * @return List<Reservation>
     */
    public List<Reservation> getReservationsByAsset(
        int assetId,
        int limit
    ) throws DataAccessException;
    
    /**
     * 예약 취소
     * @param reservationId 예약 ID
     * @throws DataAccessException
     */
    public void cancelReservation(int reservationId) throws DataAccessException;
}

/* Entity 정의 */
public class Reservation {
    private int reservationId;
    private int userId;
    private int assetId;
    private LocalDateTime reservedFrom;
    private LocalDateTime reservedTo;
    private String status;        // 'active', 'cancelled'
    private String notes;
    private LocalDateTime createdAt;
    private LocalDateTime cancelledAt;
    
    // getters/setters
}
```

### 3.3 TransferDAO

```java
public class TransferDAO {
    
    /**
     * 자산 이관 요청 생성
     * @param assetId 자산 ID
     * @param fromLocation 출발 위치
     * @param toLocation 도착 위치
     * @param reason 이관 사유
     * @param requestedBy 요청자 ID
     * @return 이관 ID
     */
    public int createTransferRequest(
        int assetId,
        String fromLocation,
        String toLocation,
        String reason,
        int requestedBy
    ) throws DataAccessException;
    
    /**
     * 이관 요청 목록 (승인 대기)
     * @param limit 최대 개수
     * @return List<Transfer>
     */
    public List<Transfer> getPendingTransfers(int limit) throws DataAccessException;
    
    /**
     * 이관 승인
     * @param transferId 이관 ID
     * @param approvedBy 승인자 ID
     * @param newAssetLocation 새로운 자산 위치
     */
    public void approveTransfer(
        int transferId,
        int approvedBy,
        String newAssetLocation
    ) throws DataAccessException;
    
    /**
     * 이관 반려
     * @param transferId 이관 ID
     * @param rejectionReason 반려 사유
     */
    public void rejectTransfer(
        int transferId,
        String rejectionReason
    ) throws DataAccessException;
    
    /**
     * 자산의 이관 이력
     * @param assetId 자산 ID
     * @param limit 최대 개수
     * @return List<Transfer>
     */
    public List<Transfer> getTransferHistory(
        int assetId,
        int limit
    ) throws DataAccessException;
}
```

---

## 4. 데이터 전문 정의

### 4.1 JSON 응답 형식 (향후 API용)

```json
// 자산 검색 응답
{
  "status": "success",
  "data": {
    "assets": [
      {
        "assetId": 1,
        "assetName": "현미경",
        "category": "실험 장비",
        "status": "available",
        "location": "2층 실습실 A",
        "imageUrl": "/images/asset_1.jpg"
      }
    ],
    "pagination": {
      "currentPage": 1,
      "pageSize": 20,
      "totalCount": 45,
      "pageCount": 3
    }
  },
  "timestamp": "2026-05-27T10:30:00Z"
}

// 자산 상세정보 응답
{
  "status": "success",
  "data": {
    "asset": {
      "assetId": 1,
      "assetName": "현미경",
      "category": "실험 장비",
      "description": "광학 현미경으로 샘플 관찰...",
      "status": "available",
      "location": "2층 실습실 A",
      "owner": {
        "userId": 10,
        "name": "실습실 담당자"
      }
    },
    "reservations": [
      {
        "reservationId": 123,
        "reservedFrom": "2026-06-10T10:00:00",
        "reservedTo": "2026-06-10T12:00:00",
        "user": {
          "userId": 100,
          "name": "학부생1"
        }
      }
    ],
    "transferHistory": [
      {
        "transferId": 456,
        "fromLocation": "1층",
        "toLocation": "2층",
        "status": "approved",
        "approvedAt": "2026-05-25T15:00:00"
      }
    ]
  },
  "timestamp": "2026-05-27T10:30:00Z"
}

// 예약 생성 응답
{
  "status": "success",
  "data": {
    "reservationId": 789,
    "assetId": 1,
    "reservedFrom": "2026-06-10T10:00:00",
    "reservedTo": "2026-06-10T12:00:00",
    "message": "예약이 완료되었습니다"
  },
  "timestamp": "2026-05-27T10:30:00Z"
}
```

### 4.2 Form Data 형식 (현재 JSP)

```
/* 자산 검색 요청 */
GET /search?keyword=현미경&category=실험장비&status=available&page=1&size=20

/* 예약 요청 */
POST /reserve
Content-Type: application/x-www-form-urlencoded

assetId=1&reservedFrom=2026-06-10 10:00&reservedTo=2026-06-10 12:00&notes=실습용

/* 이관 요청 */
POST /transfer
Content-Type: application/x-www-form-urlencoded

assetId=1&toLocation=3층 연구실&reason=이동
```

---

## 5. JSP-Servlet 통신

### 5.1 searchAssets.jsp ↔ SearchServlet

```
[JSP → Servlet]
GET /search?keyword=${keyword}&category=${category}&page=1

[Servlet → JSP]
request.setAttribute("searchResults", assets);         // List<Asset>
request.setAttribute("totalCount", totalCount);        // int
request.setAttribute("pageCount", pageCount);          // int
request.setAttribute("currentPage", page);             // int

[JSP에서 접근]
<c:forEach var="asset" items="${searchResults}">
  <div class="asset-card">
    <h3>${asset.assetName}</h3>
    <p>상태: ${asset.status}</p>
  </div>
</c:forEach>

<div class="pagination">
  <c:forEach var="p" begin="1" end="${pageCount}">
    <a href="/search?keyword=${keyword}&page=${p}">${p}</a>
  </c:forEach>
</div>
```

### 5.2 detail.jsp ↔ DetailServlet

```
[JSP → Servlet]
GET /asset/detail?assetId=1

[Servlet → JSP]
request.setAttribute("asset", asset);                  // Asset
request.setAttribute("reservations", reservations);    // List<Reservation>
request.setAttribute("transferHistory", transfers);    // List<Transfer>

[JSP에서 접근]
<h1>${asset.assetName}</h1>
<p>${asset.description}</p>
<p>상태: ${asset.status}</p>
<p>위치: ${asset.location}</p>

<table>
  <tr><th>예약 시작</th><th>예약 종료</th></tr>
  <c:forEach var="res" items="${reservations}">
    <tr>
      <td>${res.reservedFrom}</td>
      <td>${res.reservedTo}</td>
    </tr>
  </c:forEach>
</table>
```

---

## 6. Servlet-DAO 통신

### 6.1 SearchServlet → AssetDAO

```java
// Servlet에서 DAO 호출
AssetDAO assetDAO = new AssetDAO();
try {
    List<Asset> assets = assetDAO.searchAssets(
        keyword,      // "현미경"
        category,     // "실험 장비"
        status,       // "available"
        20,           // limit
        (page-1)*20   // offset
    );
    
    int totalCount = assetDAO.countSearchResults(keyword, category, status);
    
    // 응답 설정
    request.setAttribute("searchResults", assets);
    request.setAttribute("totalCount", totalCount);
    
} catch (DataAccessException e) {
    // 에러 처리
    request.setAttribute("errorMessage", "검색 중 오류가 발생했습니다");
    log.error("Search error", e);
}
```

### 6.2 ReserveServlet → ReservationDAO

```java
// Servlet에서 DAO 호출
ReservationDAO reservationDAO = new ReservationDAO();
try {
    int reservationId = reservationDAO.createReservation(
        userId,           // 123
        assetId,          // 1
        reservedFrom,     // LocalDateTime
        reservedTo,       // LocalDateTime
        notes             // "실습용"
    );
    
    // 성공 응답
    response.sendRedirect("/asset/detail?assetId=" + assetId);
    
} catch (ReservationConflictException e) {
    // 시간 겹침 처리
    request.setAttribute("errorMessage", "이미 예약된 시간입니다");
    doGet(request, response);
} catch (DataAccessException e) {
    // DB 오류 처리
    log.error("Reservation error", e);
    response.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
}
```

---

## 7. REST API (향후)

### 7.1 RESTful 엔드포인트 설계 (Phase 2+)

```
/* 자산 관련 API */
GET    /api/v1/assets              - 자산 목록 (페이지네이션)
GET    /api/v1/assets/:id          - 자산 상세정보
POST   /api/v1/assets              - 자산 생성 (관리자)
PUT    /api/v1/assets/:id          - 자산 수정 (관리자)
DELETE /api/v1/assets/:id          - 자산 삭제 (관리자)

/* 예약 관련 API */
GET    /api/v1/reservations        - 사용자의 예약 목록
POST   /api/v1/reservations        - 예약 생성
DELETE /api/v1/reservations/:id    - 예약 취소
GET    /api/v1/assets/:id/reservations - 자산의 예약 현황

/* 이관 관련 API */
GET    /api/v1/transfers           - 이관 요청 목록
POST   /api/v1/transfers           - 이관 요청 생성
PUT    /api/v1/transfers/:id       - 이관 승인/반려

/* 내비게이션 API */
GET    /api/v1/floors              - 층 정보 목록
GET    /api/v1/floors/:id/assets   - 층별 자산 목록 (좌표 포함)
```

---

## 8. 에러 응답 형식

```json
/* 입력 검증 오류 */
{
  "status": "error",
  "errorCode": "ERR_VALIDATION",
  "message": "입력값이 유효하지 않습니다",
  "details": {
    "field": "keyword",
    "error": "길이가 100자를 초과했습니다"
  },
  "timestamp": "2026-05-27T10:30:00Z"
}

/* 예약 시간 겹침 */
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
    "suggestedSlots": [
      {
        "start": "2026-06-10T12:00:00",
        "end": "2026-06-10T14:00:00"
      }
    ]
  },
  "timestamp": "2026-05-27T10:30:00Z"
}

/* 리소스 부재 */
{
  "status": "error",
  "errorCode": "ERR_NOT_FOUND",
  "message": "자산을 찾을 수 없습니다",
  "timestamp": "2026-05-27T10:30:00Z"
}

/* 권한 부재 */
{
  "status": "error",
  "errorCode": "ERR_UNAUTHORIZED",
  "message": "권한이 없습니다",
  "timestamp": "2026-05-27T10:30:00Z"
}

/* 내부 서버 오류 */
{
  "status": "error",
  "errorCode": "ERR_INTERNAL_SERVER",
  "message": "서버 오류가 발생했습니다. 관리자에게 문의하세요",
  "timestamp": "2026-05-27T10:30:00Z"
}
```

---

## 문서 이력

| 버전 | 날짜 | 변경 내용 | 작성자 |
|------|------|---------|--------|
| v1.0 | 2026-05-27 | 초판 작성 - 인터페이스 정의 | Development Team |

---

**작성 완료 - 2026-05-27**

