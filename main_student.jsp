<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    String loginUser=(String)session.getAttribute("loginUser");
    String loginName=(String)session.getAttribute("loginName");
    if(loginUser==null){response.sendRedirect("/CAN/campuslogin.jsp");return;}
    int total=0;
    List<Map<String,String>> myReserves=new ArrayList<>();
    String cancelMsg="",cancelErr="";
    // 예약 취소/연장 처리 (POST)
    if("POST".equals(request.getMethod())){
        request.setCharacterEncoding("UTF-8");
        String act=request.getParameter("act");
        String cancelId=request.getParameter("cancelId");
        if(cancelId!=null&&!cancelId.trim().isEmpty()){
            try{
                Class.forName("com.mysql.cj.jdbc.Driver");
                Connection cc=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");
                if("extend".equals(act)){
                    String extendHours=request.getParameter("extendHours");
                    int hours=Integer.parseInt(extendHours!=null?extendHours:"1");
                    // 자산 예약 연장
                    PreparedStatement ps=cc.prepareStatement("UPDATE reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=? AND user_id=? AND status='사용완료'");
                    ps.setInt(1,hours);ps.setString(2,cancelId.trim());ps.setString(3,loginUser);
                    int n=ps.executeUpdate();ps.close();
                    // 방 예약 연장
                    ps=cc.prepareStatement("UPDATE room_reservations SET end_time=DATE_ADD(end_time,INTERVAL ? HOUR) WHERE reserve_id=? AND user_id=? AND status='사용완료'");
                    ps.setInt(1,hours);ps.setString(2,cancelId.trim());ps.setString(3,loginUser);
                    int m=ps.executeUpdate();ps.close();cc.close();
                    cancelMsg=(n+m)>0?"예약이 "+hours+"시간 연장되었습니다.":"연장할 수 없는 예약입니다.";
                } else {
                    // 예약 취소
                    PreparedStatement ps=cc.prepareStatement("UPDATE reservations SET status='취소' WHERE reserve_id=? AND user_id=? AND status='예약완료'");
                    ps.setString(1,cancelId.trim());ps.setString(2,loginUser);
                    int n=ps.executeUpdate();ps.close();
                    ps=cc.prepareStatement("UPDATE room_reservations SET status='취소' WHERE reserve_id=? AND user_id=? AND status='예약완료'");
                    ps.setString(1,cancelId.trim());ps.setString(2,loginUser);
                    int m=ps.executeUpdate();ps.close();cc.close();
                    cancelMsg=(n+m)>0?"예약이 취소되었습니다.":"취소할 수 없는 예약입니다.";
                }
            }catch(Exception e){cancelErr="처리 오류: "+e.getMessage();}
        }
    }
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn=DriverManager.getConnection("jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true","root","1234");

        // 시간이 지난 예약을 자동으로 "사용완료"로 변경
        String updateSql="UPDATE reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);
        updateSql="UPDATE room_reservations SET status='사용완료' WHERE status='예약완료' AND CONCAT(reserve_date,' ',end_time) < NOW()";
        conn.createStatement().executeUpdate(updateSql);

        ResultSet rs=conn.createStatement().executeQuery("SELECT COUNT(*) FROM assets");
        if(rs.next())total=rs.getInt(1);rs.close();

        // 자산 예약 조회
        PreparedStatement ps=conn.prepareStatement(
            "SELECT r.reserve_id,r.asset_no,IFNULL(a.item_name,'자산') AS item_name,"+
            "r.reserve_date,r.start_time,r.end_time,r.status,r.purpose "+
            "FROM reservations r LEFT JOIN assets a ON r.asset_no=a.asset_no "+
            "WHERE r.user_id=? ORDER BY r.reserve_date DESC,r.start_time DESC LIMIT 10");
        ps.setString(1,loginUser);rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("name",rs.getString("item_name"));
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            m.put("purpose",rs.getString("purpose")!=null?rs.getString("purpose"):"");
            myReserves.add(m);
        }
        rs.close();ps.close();

        // 방(강의실/세미나실/컴퓨터실) 예약 조회
        ps=conn.prepareStatement(
            "SELECT rr.reserve_id,CAST(rr.room_id AS CHAR) AS room_id,r.room_name AS item_name,"+
            "rr.reserve_date,rr.start_time,rr.end_time,rr.status,rr.purpose "+
            "FROM room_reservations rr LEFT JOIN rooms r ON rr.room_id=r.room_id "+
            "WHERE rr.user_id=? ORDER BY rr.reserve_date DESC,rr.start_time DESC LIMIT 10");
        ps.setString(1,loginUser);rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> m=new LinkedHashMap<>();
            m.put("id",rs.getString("reserve_id")!=null?rs.getString("reserve_id"):"");
            m.put("name",rs.getString("item_name"));
            m.put("date",rs.getString("reserve_date")!=null?rs.getString("reserve_date"):"");
            m.put("start",rs.getString("start_time")!=null?rs.getString("start_time"):"");
            m.put("end",rs.getString("end_time")!=null?rs.getString("end_time"):"");
            m.put("status",rs.getString("status")!=null?rs.getString("status"):"");
            m.put("purpose",rs.getString("purpose")!=null?rs.getString("purpose"):"");
            myReserves.add(m);
        }
        rs.close();ps.close();

        // 날짜별 정렬
        myReserves.sort((a,b)-> b.get("date").compareTo(a.get("date")) != 0 ? b.get("date").compareTo(a.get("date")) : b.get("start").compareTo(a.get("start")));
        if(myReserves.size()>10) myReserves=myReserves.subList(0,10);

        conn.close();
    }catch(Exception e){}
%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CAN — 학부생</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,400;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<link rel="stylesheet" href="/CAN/css/common.css">
<style>
.cat-grid{display:grid;grid-template-columns:repeat(4,1fr);gap:10px;}
.cat-item{border:1.5px solid var(--line);border-radius:var(--r2);padding:18px 8px;text-align:center;text-decoration:none;color:var(--txt);background:var(--white);transition:all .2s;display:block;}
.cat-item:hover{border-color:var(--blue);box-shadow:var(--shadow2);transform:translateY(-2px);color:var(--blue);}
.cat-item i{display:block;font-size:24px;margin-bottom:8px;}
.cat-item span{font-size:13px;font-weight:700;}
.cat-item.reserve-btn{border-color:var(--teal);background:var(--teal-lt);}
.cat-item.reserve-btn:hover{background:var(--teal);color:white;}

/* 테이블 셀 줄바꿈 */
.tbl tbody td:nth-child(1){word-break:break-word;overflow-wrap:break-word;white-space:normal;}
.tbl tbody td:nth-child(2),.tbl tbody td:nth-child(3){white-space:nowrap;font-size:11px;}

/* 모바일 폼 요소 */
@media(max-width:768px){
  .cat-grid{grid-template-columns:repeat(2,1fr);}
  .tbl tbody select{font-size:11px;padding:3px 6px;width:auto;}
  .tbl tbody .btn-danger{padding:3px 8px;font-size:11px;}
  .tbl tbody td:nth-child(1){font-size:12px;}
  .tbl tbody td:nth-child(2),.tbl tbody td:nth-child(3){font-size:10px;}
}

@media(max-width:480px){
  .tbl tbody td:nth-child(2),.tbl tbody td:nth-child(3){font-size:9px;}
  .tbl tbody td:nth-child(5){font-size:10px;}
}
</style>
</head>
<body>

<!-- TOPNAV -->
<div class="topnav">
  <a href="/CAN/main_student.jsp" class="logo">
    <span class="logo-dot"><img src="/CAN/images/logo.png" alt="ICT"></span>
    ICT <em>CAN</em>
  </a>
  <!-- 데스크탑 -->
  <div class="nav-right">
    <span style="font-family:var(--mono);font-size:13px;color:var(--txt2)"><i class="bi bi-person-circle"></i> <%= loginName %></span>
    <span class="role-chip">학부생</span>
    <a href="/CAN/search.jsp" class="chip"><i class="bi bi-search"></i> 검색</a>
    <a href="/CAN/room_reserve.jsp" class="chip"><i class="bi bi-calendar-check"></i> 예약</a>
    <a href="/CAN/navigationTest1.jsp" class="chip"><i class="bi bi-compass"></i> 길찾기</a>
    <form action="/CAN/logout" method="post" style="margin:0">
      <button type="submit" class="chip"><i class="bi bi-box-arrow-right"></i> 로그아웃</button>
    </form>
  </div>
  <!-- 모바일 햄버거 -->
  <button class="nav-hamburger" onclick="toggleMenu()"><i class="bi bi-list"></i></button>
</div>
<!-- 모바일 드롭다운 메뉴 -->
<div class="nav-mobile-menu" id="mobileMenu">
  <div class="nav-user-info"><i class="bi bi-person-circle me-1"></i><%= loginName %> · <span class="role-chip" style="font-size:11px">학부생</span></div>
  <a href="/CAN/search.jsp" class="chip"><i class="bi bi-search me-1"></i>검색</a>
  <a href="/CAN/room_reserve.jsp" class="chip"><i class="bi bi-calendar-check me-1"></i>강의실 예약</a>
  <a href="/CAN/navigationTest1.jsp" class="chip"><i class="bi bi-compass me-1"></i>길찾기</a>
  <form action="/CAN/logout" method="post" style="margin:0">
    <button type="submit" class="chip" style="width:100%;justify-content:center"><i class="bi bi-box-arrow-right me-1"></i>로그아웃</button>
  </form>
</div>

<div class="shell">

<div class="hero">
  <div class="hero-content">
    <div class="hero-eyebrow">// ICT CAN · 학부생</div>
    <div class="hero-title">안녕하세요, <em><%= loginName %></em>님 👋</div>
    <div class="hero-desc">총 <strong><%= String.format("%,d",total) %>건</strong>의 자산을 검색하고 예약할 수 있습니다.</div>
    <form method="get" action="/CAN/search.jsp" style="margin:0">
      <div class="search-hero">
        <input type="text" name="keyword" placeholder="자산번호, 품목명, 위치 검색...">
        <button type="submit" class="btn-search-hero"><i class="bi bi-search me-1"></i>검색</button>
      </div>
    </form>
  </div>
  <div class="hero-side">🎓</div>
</div>

<!-- STAT ROW -->
<div class="stat-row">
  <div class="stat-card" onclick="location.href='/CAN/search.jsp'">
    <div class="stat-icon si-blue"><i class="bi bi-box-seam" style="color:var(--blue);font-size:20px"></i></div>
    <div><div class="stat-label">전체 자산</div><div class="stat-val sv-blue"><%= String.format("%,d",total) %></div><div class="stat-sub">DB 실시간</div></div>
  </div>
  <div class="stat-card" onclick="location.href='/CAN/reserve.jsp'">
    <div class="stat-icon si-teal"><i class="bi bi-calendar-check" style="color:var(--teal);font-size:20px"></i></div>
    <div><div class="stat-label">내 예약</div><div class="stat-val sv-teal"><%= myReserves.size() %></div><div class="stat-sub">최근 10건</div></div>
  </div>
  <div class="stat-card" onclick="location.href='/CAN/room_reserve.jsp'">
    <div class="stat-icon si-purple"><i class="bi bi-door-open" style="color:var(--purple);font-size:20px"></i></div>
    <div><div class="stat-label">강의실 예약</div><div class="stat-val sv-purple" style="font-size:18px">예약 →</div><div class="stat-sub">바로 신청</div></div>
  </div>
  <div class="stat-card" onclick="location.href='/CAN/navigationTest1.jsp'">
    <div class="stat-icon si-amber"><i class="bi bi-compass" style="color:var(--amber);font-size:20px"></i></div>
    <div><div class="stat-label">길찾기</div><div class="stat-val sv-amber" style="font-size:18px">이동 →</div><div class="stat-sub">실내 네비게이션</div></div>
  </div>
</div>

<div class="main-grid">
  <div>
    <!-- 알림 -->
    <% if(!cancelMsg.isEmpty()){%><div class="alert-ok"><i class="bi bi-check-circle-fill"></i><%= cancelMsg %></div><%}%>
    <% if(!cancelErr.isEmpty()){%><div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><%= cancelErr %></div><%}%>

    <!-- 강의실 예약 카드 (카테고리 교체) -->
    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-teal"><i class="bi bi-door-open" style="color:var(--teal)"></i></div>
        <div><div class="ch-title">강의실 · 공간 · 자산 예약</div><div class="ch-sub">원하는 자원을 선택하세요</div></div>
      </div>
      <div class="card-body">
        <div class="cat-grid">
          <a href="/CAN/room_reserve.jsp?type=강의실" class="cat-item reserve-btn">
            <i class="bi bi-building" style="color:var(--teal)"></i><span>강의실 예약</span>
          </a>
          <a href="/CAN/room_reserve.jsp?type=세미나실" class="cat-item reserve-btn">
            <i class="bi bi-people" style="color:var(--teal)"></i><span>세미나실 예약</span>
          </a>
          <a href="/CAN/room_reserve.jsp?type=컴퓨터실" class="cat-item reserve-btn">
            <i class="bi bi-laptop" style="color:var(--teal)"></i><span>컴퓨터실 예약</span>
          </a>
          <a href="/CAN/reserve.jsp" class="cat-item reserve-btn">
            <i class="bi bi-box-seam" style="color:var(--teal)"></i><span>자산 예약</span>
          </a>
          <a href="/CAN/search.jsp" class="cat-item">
            <i class="bi bi-search" style="color:var(--blue)"></i><span>자원 검색</span>
          </a>
        </div>
      </div>
    </div>

    <!-- 내 예약 현황 -->
    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-teal"><i class="bi bi-calendar-check" style="color:var(--teal)"></i></div>
        <div><div class="ch-title">내 예약 현황</div><div class="ch-sub">내가 신청한 예약만 표시 · 최근 10건</div></div>
        <div class="card-head-extra"><a href="/CAN/room_reserve.jsp" class="btn-ghost">새 예약</a></div>
      </div>
      <% if(myReserves.isEmpty()){%>
      <div class="card-body" style="text-align:center;padding:40px;color:var(--txt3)">
        <i class="bi bi-calendar-x" style="font-size:32px;display:block;margin-bottom:10px;opacity:.3"></i>
        예약 내역이 없습니다.
        <br><a href="/CAN/room_reserve.jsp" class="btn-prim" style="margin-top:14px;display:inline-flex">예약하러 가기</a>
      </div>
      <%}else{%>
      <div style="overflow-x:auto">
        <table class="tbl">
          <thead>
            <tr><th>자산명</th><th>날짜</th><th>시간</th><th>상태</th><th>관리</th></tr>
          </thead>
          <tbody>
          <%for(Map<String,String> rv:myReserves){
              String st=rv.get("status");
              String bc=st.contains("취소")?"badge-busy":st.contains("완료")?"badge-ok":"badge-warn";
          %>
          <tr>
            <td><strong style="font-size:14px"><%= rv.get("name") %></strong>
                <% if(!rv.get("purpose").isEmpty()){%><div style="font-size:12px;color:var(--txt3)"><%= rv.get("purpose") %></div><%}%></td>
            <td style="font-family:var(--mono);font-size:13px"><%= rv.get("date") %></td>
            <td style="font-family:var(--mono);font-size:13px"><%= rv.get("start") %>~<%= rv.get("end") %></td>
            <td><span class="<%= bc %>"><%= st %></span></td>
            <td style="display:flex;gap:6px;flex-wrap:wrap;">
              <% if("사용완료".equals(st)){%>
              <form method="post" action="/CAN/main_student.jsp" style="margin:0;display:contents" onchange="if(confirm('예약을 '+this.querySelector('select').value+' 연장하시겠습니까?')) this.submit(); else this.reset()">
                <input type="hidden" name="act" value="extend">
                <input type="hidden" name="cancelId" value="<%= rv.get("id") %>">
                <select name="extendHours" style="padding:4px 8px;font-size:12px;border:1.5px solid var(--line2);border-radius:6px;outline:none;background:var(--white);color:var(--txt);cursor:pointer;">
                  <option value="">연장</option>
                  <option value="1">1시간 연장</option>
                  <option value="2">2시간 연장</option>
                  <option value="4">4시간 연장</option>
                  <option value="8">8시간 연장</option>
                </select>
              </form>
              <%}else if("예약완료".equals(st)){%>
              <form method="post" action="/CAN/main_student.jsp" style="margin:0"
                    onsubmit="return confirm('예약을 취소하시겠습니까?')">
                <input type="hidden" name="cancelId" value="<%= rv.get("id") %>">
                <button type="submit" class="btn-danger" style="padding:4px 8px;font-size:12px"><i class="bi bi-x-circle"></i>취소</button>
              </form>
              <%}else{%><span style="font-size:12px;color:var(--txt3)">-</span><%}%>
            </td>
          </tr>
          <%}%>
          </tbody>
        </table>
      </div>
      <%}%>
    </div>
  </div>

  <!-- RIGHT: 네비게이션 -->
  <div>
    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-teal"><i class="bi bi-compass" style="color:var(--teal)"></i></div>
        <div><div class="ch-title">실내 네비게이션</div><div class="ch-sub">최적 경로 안내</div></div>
      </div>
      <div class="card-body">
        <div class="map-frame">
          <div style="font-size:44px">🧭</div>
          <div style="font-size:15px;font-weight:700">캠퍼스 길찾기</div>
          <div style="font-size:13px;color:var(--txt3);text-align:center">현재 위치에서 강의실, 연구실까지 최적 경로를 안내합니다</div>
        </div>
        <input type="text" id="navDest" class="map-search" placeholder="예) 공학관 301호, 이교수 연구실">
        <div class="map-btns">
          <a href="#" class="btn-nav-prim" onclick="goNav();return false;">
            <i class="bi bi-geo-alt-fill me-1"></i>현재 위치 길찾기
          </a>
          <a href="/CAN/navigationTest1.jsp" class="btn-nav-ghost">
            <i class="bi bi-map me-1"></i>지도 보기
          </a>
        </div>
        <div id="navMsg" style="display:none;margin-top:10px;padding:10px;background:var(--teal-lt);border:1px solid var(--teal-md);border-radius:var(--r);font-size:13px;color:var(--teal)"></div>
      </div>
    </div>

    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-blue"><i class="bi bi-bar-chart" style="color:var(--blue)"></i></div>
        <div><div class="ch-title">서비스 현황</div></div>
      </div>
      <div class="card-body" style="padding:12px 22px">
        <ul style="list-style:none;padding:0;margin:0">
          <li style="display:flex;justify-content:space-between;padding:10px 0;border-bottom:1px solid var(--line);font-size:14px">
            <span style="color:var(--txt2)">전체 자산</span><span style="font-weight:700;font-family:var(--mono);color:var(--blue)"><%= String.format("%,d",total) %>건</span>
          </li>
          <li style="display:flex;justify-content:space-between;padding:10px 0;font-size:14px">
            <span style="color:var(--txt2)">내 예약</span><span style="font-weight:700;font-family:var(--mono);color:var(--teal)"><%= myReserves.size() %>건</span>
          </li>
        </ul>
      </div>
    </div>
  </div>
</div>

</div>
<footer class="site-footer">
  <div class="footer-inner">
    <a href="/CAN/campuslogin.jsp" class="footer-logo">
      <span class="footer-logo-dot"><img src="/CAN/images/logo.png" alt="ICT"></span>
      ICT <em>CAN</em>
    </a>
    <div class="footer-team"><strong>Made by AI 소프트웨어학과</strong><br>박승순 &middot; 권동해 &middot; 원태연 &middot; 이수혁</div>
    <div class="footer-copy">ICT폴리텍대학 교내 자원 내비게이션 시스템<br>Copyright &copy; 2026 ICT CAN. All rights reserved.</div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
function toggleMenu(){
  var m=document.getElementById('mobileMenu');
  m.classList.toggle('open');
}
function goNav(){
  var dest=document.getElementById('navDest').value.trim();
  var url='/CAN/navigationTest1.jsp';
  if(dest)url+='?destName='+encodeURIComponent(dest);
  var msg=document.getElementById('navMsg');
  msg.innerHTML='<i class="bi bi-compass me-1"></i>'+(dest?'목적지: <strong>'+dest+'</strong> 경로 계산 중...':'현재 위치 탐색 중...');
  msg.style.display='block';
  setTimeout(function(){location.href=url;},700);
}
document.getElementById('navDest').addEventListener('keydown',function(e){if(e.key==='Enter')goNav();});
</script>
</body>
</html>
