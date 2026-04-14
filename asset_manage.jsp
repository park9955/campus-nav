<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" session="true" import="java.sql.*,java.util.*" %>
<%
    /* ── 접근 권한 체크: 관리자 / 조교 / 교수만 ── */
    String loginUser = (String)session.getAttribute("loginUser");
    String loginName = (String)session.getAttribute("loginName");
    String loginRole = (String)session.getAttribute("loginRole");
    if(loginUser == null){ response.sendRedirect("/CampusNav/campuslogin.jsp"); return; }
    boolean isAdmin = "admin".equals(loginRole);
    boolean isAssist= "assistant".equals(loginRole);
    boolean isProf  = "professor".equals(loginRole);
    if(!isAdmin && !isAssist && !isProf){
        response.sendRedirect("/CampusNav/main_"+loginRole+".jsp"); return;
    }

    /* ── DB 연결 상수 ── */
    final String DB_URL = "jdbc:mysql://localhost:3306/campusnav?useSSL=false&serverTimezone=Asia/Seoul&characterEncoding=UTF-8&allowPublicKeyRetrieval=true";
    final String DB_USER = "root", DB_PASS = "1234";

    /* ══════════════════════════════════════════
       POST 처리: action 파라미터로 분기
       action=insert → 신규 등록
       action=update → 수정
       action=delete → 삭제
    ══════════════════════════════════════════ */
    String action  = request.getParameter("action");
    String msgOk   = "";
    String msgErr  = "";

    if("POST".equals(request.getMethod()) && action != null){
        request.setCharacterEncoding("UTF-8");
        try{
            Class.forName("com.mysql.cj.jdbc.Driver");
            Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);

            /* ── 삭제 ── */
            if("delete".equals(action)){
                String delNo = request.getParameter("delNo");
                if(delNo != null && !delNo.trim().isEmpty()){
                    PreparedStatement ps = conn.prepareStatement(
                        "DELETE FROM assets WHERE asset_no=?");
                    ps.setString(1, delNo.trim());
                    int n = ps.executeUpdate(); ps.close();
                    msgOk = (n>0) ? "자산 ["+delNo+"] 이(가) DB에서 삭제되었습니다." : "삭제할 자산을 찾지 못했습니다.";
                }
            }
            /* ── 수정 ── */
            else if("update".equals(action)){
                String assetNo   = request.getParameter("u_asset_no");
                String itemName  = request.getParameter("u_item_name");
                String assetCls  = request.getParameter("u_asset_class");
                String model     = request.getParameter("u_model");
                String spec      = request.getParameter("u_spec");
                String mfr       = request.getParameter("u_manufacturer");
                String loc       = request.getParameter("u_location");
                String dloc      = request.getParameter("u_detail_location");
                String dept      = request.getParameter("u_manage_dept");
                String mgr       = request.getParameter("u_manager_name");
                String status    = request.getParameter("u_asset_status");
                String qty       = request.getParameter("u_quantity");
                String acqDate   = request.getParameter("u_acq_date");
                String acqPrice  = request.getParameter("u_acq_price");
                String life      = request.getParameter("u_useful_life");
                String remark    = request.getParameter("u_remark");
                if(assetNo==null||assetNo.trim().isEmpty()){ msgErr="자산번호가 없습니다."; }
                else{
                    PreparedStatement ps = conn.prepareStatement(
                        "UPDATE assets SET item_name=?,asset_class=?,model=?,spec=?,manufacturer=?," +
                        "location=?,detail_location=?,manage_dept=?,manager_name=?,asset_status=?," +
                        "quantity=?,acq_date=?,acq_price=?,useful_life=?,remark=?,mod_date=NOW() " +
                        "WHERE asset_no=?");
                    ps.setString(1, nvl(itemName));
                    ps.setString(2, nvl(assetCls));
                    ps.setString(3, nvl(model));
                    ps.setString(4, nvl(spec));
                    ps.setString(5, nvl(mfr));
                    ps.setString(6, nvl(loc));
                    ps.setString(7, nvl(dloc));
                    ps.setString(8, nvl(dept));
                    ps.setString(9, nvl(mgr));
                    ps.setString(10, nvl(status));
                    if(qty!=null&&!qty.trim().isEmpty()) ps.setInt(11,Integer.parseInt(qty.trim())); else ps.setNull(11,Types.INTEGER);
                    if(acqDate!=null&&!acqDate.trim().isEmpty()) ps.setDate(12,java.sql.Date.valueOf(acqDate.trim())); else ps.setNull(12,Types.DATE);
                    if(acqPrice!=null&&!acqPrice.trim().isEmpty()) ps.setLong(13,Long.parseLong(acqPrice.replaceAll("[^0-9]",""))); else ps.setNull(13,Types.BIGINT);
                    if(life!=null&&!life.trim().isEmpty()) ps.setInt(14,Integer.parseInt(life.trim())); else ps.setNull(14,Types.INTEGER);
                    ps.setString(15, nvl(remark));
                    ps.setString(16, assetNo.trim());
                    int n = ps.executeUpdate(); ps.close();
                    msgOk = (n>0) ? "자산 ["+assetNo+"] 이(가) DB에서 수정되었습니다." : "수정할 자산을 찾지 못했습니다.";
                }
            }
            /* ── 신규 등록 ── */
            else if("insert".equals(action)){
                String assetNo   = request.getParameter("i_asset_no");
                String itemName  = request.getParameter("i_item_name");
                String assetCls  = request.getParameter("i_asset_class");
                String model     = request.getParameter("i_model");
                String spec      = request.getParameter("i_spec");
                String mfr       = request.getParameter("i_manufacturer");
                String loc       = request.getParameter("i_location");
                String dloc      = request.getParameter("i_detail_location");
                String dept      = request.getParameter("i_manage_dept");
                String mgr       = request.getParameter("i_manager_name");
                String status    = request.getParameter("i_asset_status");
                String qty       = request.getParameter("i_quantity");
                String acqDate   = request.getParameter("i_acq_date");
                String acqPrice  = request.getParameter("i_acq_price");
                String life      = request.getParameter("i_useful_life");
                String remark    = request.getParameter("i_remark");
                if(assetNo==null||assetNo.trim().isEmpty()||itemName==null||itemName.trim().isEmpty()){
                    msgErr = "자산번호와 품목명은 필수입니다.";
                } else {
                    // 중복 체크
                    PreparedStatement ck = conn.prepareStatement("SELECT COUNT(*) FROM assets WHERE asset_no=?");
                    ck.setString(1,assetNo.trim()); ResultSet rck=ck.executeQuery();
                    boolean dup = rck.next()&&rck.getInt(1)>0; rck.close(); ck.close();
                    if(dup){ msgErr = "자산번호 ["+assetNo+"] 이(가) 이미 존재합니다."; }
                    else{
                        PreparedStatement ps = conn.prepareStatement(
                            "INSERT INTO assets(asset_no,item_name,asset_class,model,spec,manufacturer," +
                            "location,detail_location,manage_dept,manager_name,asset_status," +
                            "quantity,acq_date,acq_price,useful_life,remark,reg_date,mod_date) " +
                            "VALUES(?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,NOW(),NOW())");
                        ps.setString(1,assetNo.trim());
                        ps.setString(2,nvl(itemName));
                        ps.setString(3,nvl(assetCls));
                        ps.setString(4,nvl(model));
                        ps.setString(5,nvl(spec));
                        ps.setString(6,nvl(mfr));
                        ps.setString(7,nvl(loc));
                        ps.setString(8,nvl(dloc));
                        ps.setString(9,nvl(dept));
                        ps.setString(10,nvl(mgr));
                        ps.setString(11,status!=null&&!status.isEmpty()?status:"사용중");
                        if(qty!=null&&!qty.trim().isEmpty()) ps.setInt(12,Integer.parseInt(qty.trim())); else ps.setInt(12,1);
                        if(acqDate!=null&&!acqDate.trim().isEmpty()) ps.setDate(13,java.sql.Date.valueOf(acqDate.trim())); else ps.setNull(13,Types.DATE);
                        if(acqPrice!=null&&!acqPrice.trim().isEmpty()) ps.setLong(14,Long.parseLong(acqPrice.replaceAll("[^0-9]",""))); else ps.setNull(14,Types.BIGINT);
                        if(life!=null&&!life.trim().isEmpty()) ps.setInt(15,Integer.parseInt(life.trim())); else ps.setNull(15,Types.INTEGER);
                        ps.setString(16,nvl(remark));
                        ps.executeUpdate(); ps.close();
                        msgOk = "자산 ["+assetNo+"] 이(가) DB에 등록되었습니다.";
                    }
                }
            }
            conn.close();
        }catch(Exception e){ msgErr = "DB 오류: "+e.getMessage(); }
    }

    /* ── 자산 목록 조회 (최근 30건) ── */
    String keyword = request.getParameter("keyword"); if(keyword==null)keyword="";
    String filterCls = request.getParameter("filterCls"); if(filterCls==null)filterCls="";
    List<Map<String,String>> assetList = new ArrayList<>();
    int assetTotal = 0;
    try{
        Class.forName("com.mysql.cj.jdbc.Driver");
        Connection conn = DriverManager.getConnection(DB_URL, DB_USER, DB_PASS);
        StringBuilder w = new StringBuilder("WHERE 1=1 ");
        List<String> params = new ArrayList<>();
        if(!keyword.isEmpty()){
            w.append("AND (item_name LIKE ? OR asset_no LIKE ? OR detail_location LIKE ? OR manage_dept LIKE ?) ");
            for(int i=0;i<4;i++) params.add("%"+keyword+"%");
        }
        if(!filterCls.isEmpty()){ w.append("AND asset_class=? "); params.add(filterCls); }
        PreparedStatement ps=conn.prepareStatement("SELECT COUNT(*) FROM assets "+w);
        for(int i=0;i<params.size();i++) ps.setString(i+1,params.get(i));
        ResultSet rs=ps.executeQuery(); if(rs.next())assetTotal=rs.getInt(1); rs.close(); ps.close();
        ps=conn.prepareStatement("SELECT asset_no,asset_class,item_name,model,detail_location,manage_dept,manager_name,asset_status FROM assets "+w+"ORDER BY reg_date DESC LIMIT 30");
        for(int i=0;i<params.size();i++) ps.setString(i+1,params.get(i));
        rs=ps.executeQuery();
        while(rs.next()){
            Map<String,String> r=new LinkedHashMap<>();
            r.put("no",nvl(rs.getString(1))); r.put("cls",nvl(rs.getString(2)));
            r.put("name",nvl(rs.getString(3))); r.put("model",nvl(rs.getString(4)));
            r.put("loc",nvl(rs.getString(5))); r.put("dept",nvl(rs.getString(6)));
            r.put("mgr",nvl(rs.getString(7))); r.put("st",nvl(rs.getString(8)));
            assetList.add(r);
        }
        rs.close(); ps.close(); conn.close();
    }catch(Exception e){ msgErr += " | 목록조회: "+e.getMessage(); }
%>
<%! private String nvl(String s){ return s==null?"":s.trim(); } %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>ICT CampusNav — 자원 관리</title>
<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
<link href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.3/font/bootstrap-icons.css" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=DM+Sans:opsz,wght@9..40,300;9..40,400;9..40,500;9..40,700;9..40,800&family=DM+Mono:wght@400;500&family=Noto+Sans+KR:wght@400;500;700;800&display=swap" rel="stylesheet">
<style>
:root{--white:#fff;--bg:#f7f8fa;--line:#e4e7ed;--line2:#d0d5df;--txt:#111827;--txt2:#4b5563;--txt3:#9ca3af;--blue:#1a56db;--blue-lt:#eff4ff;--blue-md:#c7d7fd;--teal:#0d9488;--teal-lt:#f0fdfa;--teal-md:#99f6e4;--amber:#d97706;--amber-lt:#fffbeb;--red:#dc2626;--red-lt:#fef2f2;--green:#16a34a;--green-lt:#f0fdf4;--purple:#7c3aed;--purple-lt:#f5f3ff;--mono:'DM Mono',monospace;--sans:'DM Sans','Noto Sans KR',sans-serif;--r:12px;--r2:20px;--shadow:0 1px 3px rgba(0,0,0,.06),0 4px 16px rgba(0,0,0,.04);--shadow2:0 2px 8px rgba(0,0,0,.08),0 12px 32px rgba(0,0,0,.06);}
*,*::before,*::after{box-sizing:border-box;margin:0;padding:0;}
body{background:var(--bg);color:var(--txt);font-family:var(--sans);font-size:15px;line-height:1.65;}

/* TOPNAV */
.topnav{display:flex;align-items:center;justify-content:space-between;padding:14px 32px;background:var(--white);border-bottom:1px solid var(--line);position:sticky;top:0;z-index:100;box-shadow:0 1px 4px rgba(0,0,0,.04);}
.logo{display:flex;align-items:center;gap:10px;font-weight:800;font-size:17px;color:var(--txt);text-decoration:none;}
.logo-dot{width:30px;height:30px;border-radius:8px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.logo-dot img{width:100%;height:100%;object-fit:contain;}
.logo em{color:var(--blue);font-style:normal;}
.chip{font-family:var(--mono);font-size:12px;padding:6px 13px;border-radius:999px;background:var(--white);border:1px solid var(--line);color:var(--txt2);cursor:pointer;transition:all .15s;text-decoration:none;display:inline-flex;align-items:center;gap:4px;}
.chip:hover{border-color:var(--blue);color:var(--blue);}
.role-chip{font-family:var(--mono);font-size:12px;padding:5px 12px;border-radius:6px;background:var(--blue-lt);border:1px solid var(--blue-md);color:var(--blue);}

/* SHELL */
.shell{max-width:1380px;margin:0 auto;padding:28px 32px 80px;}

/* HERO (다크그린) */
.hero{background:linear-gradient(135deg,#0f172a 0%,#0d6147 50%,#16a34a 100%);border-radius:var(--r2);padding:36px 44px;margin-bottom:24px;box-shadow:0 8px 32px rgba(15,23,42,.25);display:grid;grid-template-columns:1fr auto;gap:32px;align-items:center;position:relative;overflow:hidden;}
.hero::after{content:'';position:absolute;right:0;top:0;bottom:0;width:240px;background:linear-gradient(135deg,rgba(255,255,255,.06) 0%,rgba(22,163,74,.15) 100%);clip-path:polygon(15% 0%,100% 0%,100% 100%,0% 100%);}
.hero-content{position:relative;z-index:1;}
.hero-eyebrow{font-family:var(--mono);font-size:12px;color:rgba(255,255,255,.7);letter-spacing:.14em;text-transform:uppercase;margin-bottom:8px;}
.hero-title{font-size:26px;font-weight:800;color:#fff;margin-bottom:6px;}
.hero-title em{color:#4ade80;font-style:normal;}
.hero-desc{font-size:14px;color:rgba(255,255,255,.85);line-height:1.7;}
.hero-side{position:relative;z-index:2;font-size:52px;line-height:1;}

/* ALERT */
.alert-ok{background:var(--green-lt);border:1.5px solid #86efac;border-radius:var(--r);color:var(--green);font-size:14px;font-weight:600;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:8px;}
.alert-err{background:var(--red-lt);border:1.5px solid #fca5a5;border-radius:var(--r);color:var(--red);font-size:14px;font-weight:600;padding:12px 16px;margin-bottom:16px;display:flex;align-items:center;gap:8px;animation:shake .4s ease;}
@keyframes shake{0%,100%{transform:translateX(0)} 20%{transform:translateX(-5px)} 40%{transform:translateX(5px)} 60%{transform:translateX(-3px)} 80%{transform:translateX(3px)}}

/* TAB */
.tab-bar{display:flex;gap:4px;border-bottom:2px solid var(--line);margin-bottom:24px;}
.tab-btn{font-family:var(--mono);font-size:13px;font-weight:500;padding:10px 18px;border:none;background:transparent;color:var(--txt3);cursor:pointer;transition:all .15s;border-bottom:2.5px solid transparent;margin-bottom:-2px;}
.tab-btn:hover{color:var(--blue);}
.tab-btn.active{color:var(--blue);border-bottom-color:var(--blue);font-weight:700;}
.tab-pane{display:none;} .tab-pane.active{display:block;}

/* CARD */
.card{background:var(--white);border:1.5px solid var(--line2);border-radius:var(--r2);box-shadow:var(--shadow);overflow:hidden;margin-bottom:20px;}
.card-head{padding:18px 24px;border-bottom:1.5px solid var(--line2);display:flex;align-items:center;gap:12px;}
.ch-icon{width:36px;height:36px;border-radius:9px;display:flex;align-items:center;justify-content:center;font-size:18px;flex-shrink:0;}
.si-blue{background:var(--blue-lt);} .si-teal{background:var(--teal-lt);} .si-purple{background:var(--purple-lt);} .si-amber{background:var(--amber-lt);} .si-red{background:var(--red-lt);}
.ch-title{font-size:15px;font-weight:800;color:var(--txt);}
.ch-sub{font-size:12px;color:var(--txt3);margin-top:2px;}
.card-body{padding:22px 26px;}

/* FORM */
.f-label{font-family:var(--mono);font-size:12px;color:var(--txt2);display:block;margin-bottom:6px;font-weight:600;text-transform:uppercase;letter-spacing:.04em;}
.f-required::after{content:" *";color:var(--red);}
.f-input{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);transition:border-color .15s,box-shadow .15s;}
.f-input:focus{border-color:var(--blue);box-shadow:0 0 0 3px var(--blue-lt);}
.f-input[readonly]{background:var(--bg);color:var(--txt3);}
.f-select{width:100%;border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 14px;font-size:15px;outline:none;background:var(--white);color:var(--txt);font-family:var(--sans);}

/* BUTTONS */
.btn-prim{background:var(--blue);color:white;border:none;border-radius:var(--r);padding:11px 22px;font-size:15px;font-weight:700;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:6px;text-decoration:none;}
.btn-prim:hover{background:#1647c0;color:white;}
.btn-success{background:var(--green);color:white;border:none;border-radius:var(--r);padding:11px 22px;font-size:15px;font-weight:700;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:6px;}
.btn-success:hover{background:#15803d;}
.btn-warn{background:var(--amber);color:white;border:none;border-radius:var(--r);padding:11px 22px;font-size:15px;font-weight:700;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:6px;}
.btn-warn:hover{background:#b45309;}
.btn-danger{background:var(--red);color:white;border:none;border-radius:var(--r);padding:11px 22px;font-size:15px;font-weight:700;cursor:pointer;transition:background .15s;display:inline-flex;align-items:center;gap:6px;}
.btn-danger:hover{background:#b91c1c;}
.btn-ghost{background:transparent;color:var(--txt2);border:1.5px solid var(--line2);border-radius:var(--r);padding:10px 20px;font-size:14px;font-weight:600;cursor:pointer;transition:all .15s;display:inline-flex;align-items:center;gap:6px;text-decoration:none;}
.btn-ghost:hover{border-color:var(--blue);color:var(--blue);}
.btn-sm-edit{font-family:var(--mono);font-size:12px;padding:5px 12px;border-radius:8px;border:1.5px solid var(--amber);background:var(--amber-lt);color:var(--amber);cursor:pointer;transition:all .15s;}
.btn-sm-edit:hover{background:var(--amber);color:white;}
.btn-sm-del{font-family:var(--mono);font-size:12px;padding:5px 12px;border-radius:8px;border:1.5px solid var(--red);background:var(--red-lt);color:var(--red);cursor:pointer;transition:all .15s;}
.btn-sm-del:hover{background:var(--red);color:white;}

/* TABLE */
.tbl{width:100%;border-collapse:collapse;}
.tbl thead th{font-family:var(--mono);font-size:12px;text-transform:uppercase;letter-spacing:.07em;color:var(--txt);font-weight:700;padding:12px 14px;border-bottom:2px solid var(--blue-md);background:var(--blue-lt);white-space:nowrap;}
.tbl thead th:not(:last-child){border-right:1px solid var(--blue-md);}
.tbl tbody td{padding:12px 14px;border-bottom:1px solid var(--line);font-size:14px;vertical-align:middle;}
.tbl tbody td:not(:last-child){border-right:1px solid var(--line);}
.tbl tbody tr:hover td{background:var(--bg);}
.tbl tbody tr:last-child td{border-bottom:none;}
.badge-ok{background:var(--green-lt);color:var(--green);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:700;font-family:var(--mono);white-space:nowrap;}
.badge-busy{background:var(--red-lt);color:var(--red);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:700;font-family:var(--mono);white-space:nowrap;}
.badge-warn{background:var(--amber-lt);color:var(--amber);border-radius:6px;padding:3px 9px;font-size:12px;font-weight:700;font-family:var(--mono);white-space:nowrap;}

/* SEARCH BAR */
.search-bar{background:var(--white);border:2px solid var(--blue-md);border-radius:var(--r2);padding:8px 10px;box-shadow:0 0 0 4px var(--blue-lt);display:flex;gap:8px;align-items:center;}
.search-bar input{flex:1;border:none;background:transparent;font-size:15px;outline:none;color:var(--txt);}
.search-bar:focus-within{border-color:var(--blue);box-shadow:0 0 0 5px rgba(26,86,219,.15);}
.search-bar select{border:1.5px solid var(--line2);border-radius:var(--r);padding:8px 12px;font-size:13px;outline:none;background:var(--white);}

/* DELETE CONFIRM PANEL */
.del-panel{background:var(--red-lt);border:1.5px solid #fca5a5;border-radius:var(--r2);padding:22px;margin-bottom:20px;display:none;}
.del-warn-box{background:#fff7ed;border:1px solid #fde68a;border-radius:var(--r);padding:12px 16px;font-size:14px;color:#713f12;margin-bottom:16px;display:flex;align-items:center;gap:8px;}

/* EDIT PANEL */
.edit-panel{background:var(--amber-lt);border:1.5px solid #fde68a;border-radius:var(--r2);padding:22px;margin-bottom:20px;display:none;}

/* FOOTER */
.site-footer{border-top:1px solid var(--line);padding:22px 32px;background:var(--white);margin-top:60px;}
.footer-inner{max-width:1380px;margin:0 auto;display:flex;align-items:center;justify-content:space-between;flex-wrap:wrap;gap:12px;}
.footer-logo{display:flex;align-items:center;gap:8px;font-weight:800;font-size:14px;color:var(--txt);text-decoration:none;}
.footer-logo em{color:var(--blue);font-style:normal;}
.footer-logo-dot{width:24px;height:24px;border-radius:6px;background:var(--blue);display:flex;align-items:center;justify-content:center;overflow:hidden;}
.footer-logo-dot img{width:100%;height:100%;object-fit:contain;}
.footer-team{font-family:var(--mono);font-size:12px;color:var(--txt3);text-align:center;line-height:1.8;}
.footer-team strong{color:var(--blue);}
.footer-copy{font-family:var(--mono);font-size:12px;color:var(--txt3);text-align:right;line-height:1.8;}
</style>
</head>
<body>

<!-- TOPNAV -->
<div class="topnav">
  <a href="/CampusNav/main_<%= loginRole %>.jsp" class="logo">
    <span class="logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
    ICT Campus<em>Nav</em>
  </a>
  <div style="display:flex;gap:8px;align-items:center">
    <span style="font-family:var(--mono);font-size:13px;color:var(--txt2)"><i class="bi bi-person-circle"></i> <%= loginName %></span>
    <span class="role-chip"><%= isAdmin?"운영관리자":isAssist?"조교":"교수" %></span>
    <a href="/CampusNav/main_<%= loginRole %>.jsp" class="chip"><i class="bi bi-house"></i> 홈</a>
    <a href="/CampusNav/search.jsp" class="chip"><i class="bi bi-search"></i> 검색</a>
    <form action="/CampusNav/logout" method="post" style="margin:0">
      <button type="submit" class="chip"><i class="bi bi-box-arrow-right"></i> 로그아웃</button>
    </form>
  </div>
</div>

<div class="shell">

  <!-- HERO -->
  <div class="hero">
    <div class="hero-content">
      <div class="hero-eyebrow">// ICT CampusNav · 자원 관리</div>
      <div class="hero-title">자산 <em>등록 · 수정 · 삭제</em></div>
      <div class="hero-desc">DB에 직접 연동됩니다. 총 <strong><%= assetTotal %>건</strong> 검색됨.</div>
    </div>
    <div class="hero-side">🗂</div>
  </div>

  <!-- 알림 메시지 -->
  <% if(!msgOk.isEmpty()){ %>
  <div class="alert-ok"><i class="bi bi-check-circle-fill"></i><%= msgOk %></div>
  <% } %>
  <% if(!msgErr.isEmpty()){ %>
  <div class="alert-err"><i class="bi bi-exclamation-circle-fill"></i><%= msgErr %></div>
  <% } %>

  <!-- TAB BAR -->
  <div class="tab-bar">
    <button class="tab-btn active" onclick="showTab('list',this)"><i class="bi bi-list-ul me-1"></i>자산 목록</button>
    <button class="tab-btn" onclick="showTab('insert',this)"><i class="bi bi-plus-circle me-1"></i>신규 등록</button>
    <button class="tab-btn" id="editTabBtn" onclick="showTab('edit',this)" style="display:none"><i class="bi bi-pencil me-1"></i>수정 중</button>
    <button class="tab-btn" id="delTabBtn" onclick="showTab('delete',this)" style="display:none"><i class="bi bi-trash me-1"></i>삭제 확인</button>
  </div>

  <!-- ════ TAB: 자산 목록 ════ -->
  <div class="tab-pane active" id="tab-list">
    <!-- 검색 -->
    <div style="margin-bottom:16px">
      <form method="get" action="/CampusNav/asset_manage.jsp">
        <div class="search-bar">
          <input type="text" name="keyword" value="<%= keyword %>" placeholder="자산번호, 품목명, 위치, 관리부서 검색...">
          <select name="filterCls">
            <option value="">전체 분류</option>
            <option value="공기구비품" <%= "공기구비품".equals(filterCls)?"selected":"" %>>공기구비품</option>
            <option value="집기비품"   <%= "집기비품".equals(filterCls)?"selected":"" %>>집기비품</option>
            <option value="무형고정자산" <%= "무형고정자산".equals(filterCls)?"selected":"" %>>소프트웨어</option>
          </select>
          <button type="submit" class="btn-prim" style="padding:8px 18px;font-size:14px"><i class="bi bi-search"></i> 검색</button>
          <a href="/CampusNav/asset_manage.jsp" class="btn-ghost" style="padding:7px 16px;font-size:14px">초기화</a>
        </div>
      </form>
    </div>

    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-blue"><i class="bi bi-table" style="color:var(--blue)"></i></div>
        <div>
          <div class="ch-title">자산 목록</div>
          <div class="ch-sub">총 <%= assetTotal %>건 · 최근 30건 표시 · 행 클릭 시 수정/삭제</div>
        </div>
      </div>
      <% if(assetList.isEmpty()){ %>
      <div class="card-body" style="text-align:center;padding:48px;color:var(--txt3)">
        <i class="bi bi-inbox" style="font-size:36px;display:block;margin-bottom:12px;opacity:.3"></i>
        검색 결과가 없습니다.
      </div>
      <% } else { %>
      <div style="overflow-x:auto">
        <table class="tbl">
          <thead>
            <tr>
              <th>자산번호</th><th>분류</th><th>품목명</th>
              <th>위치</th><th>관리부서</th><th>관리자</th><th>상태</th><th>관리</th>
            </tr>
          </thead>
          <tbody>
          <% for(Map<String,String> a : assetList) {
               String st = a.get("st");
               String bc = st.contains("사용중")?"badge-busy":st.contains("점검")?"badge-warn":"badge-ok";
               String clsL = a.get("cls").equals("무형고정자산")?"SW":a.get("cls").equals("집기비품")?"집기":"공기구";
          %>
          <tr onclick="openEdit('<%= a.get("no").replace("'","\\'") %>','<%= a.get("cls").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>','<%= a.get("model").replace("'","\\'") %>','<%= a.get("loc").replace("'","\\'") %>','<%= a.get("dept").replace("'","\\'") %>','<%= a.get("mgr").replace("'","\\'") %>','<%= st.replace("'","\\'") %>')">
            <td><span style="font-family:var(--mono);font-size:12px;color:var(--txt3)"><%= a.get("no") %></span></td>
            <td><span style="font-family:var(--mono);font-size:12px;background:var(--blue-lt);color:var(--blue);border-radius:5px;padding:2px 7px"><%= clsL %></span></td>
            <td><strong style="font-size:14px"><%= a.get("name") %></strong></td>
            <td><span style="font-size:13px;color:var(--txt2)"><i class="bi bi-geo-alt" style="color:var(--teal)"></i> <%= a.get("loc") %></span></td>
            <td style="font-size:13px;color:var(--txt2)"><%= a.get("dept") %></td>
            <td style="font-size:13px"><%= a.get("mgr") %></td>
            <td><span class="<%= bc %>"><%= st.isEmpty()?"정보없음":st %></span></td>
            <td onclick="event.stopPropagation()" style="white-space:nowrap">
              <button class="btn-sm-edit me-1" onclick="openEdit('<%= a.get("no").replace("'","\\'") %>','<%= a.get("cls").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>','<%= a.get("model").replace("'","\\'") %>','<%= a.get("loc").replace("'","\\'") %>','<%= a.get("dept").replace("'","\\'") %>','<%= a.get("mgr").replace("'","\\'") %>','<%= st.replace("'","\\'") %>')">
                <i class="bi bi-pencil"></i> 수정
              </button>
              <button class="btn-sm-del" onclick="openDelete('<%= a.get("no").replace("'","\\'") %>','<%= a.get("name").replace("'","\\'").replace("\"","&quot;") %>')">
                <i class="bi bi-trash"></i> 삭제
              </button>
            </td>
          </tr>
          <% } %>
          </tbody>
        </table>
      </div>
      <% } %>
    </div>
  </div>

  <!-- ════ TAB: 신규 등록 ════ -->
  <div class="tab-pane" id="tab-insert">
    <div class="card">
      <div class="card-head">
        <div class="ch-icon si-teal"><i class="bi bi-plus-circle" style="color:var(--teal)"></i></div>
        <div><div class="ch-title">신규 자산 등록</div><div class="ch-sub">* 표시 항목은 필수입니다</div></div>
      </div>
      <div class="card-body">
        <form method="post" action="/CampusNav/asset_manage.jsp" onsubmit="return validateInsert()">
          <input type="hidden" name="action" value="insert">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="f-label f-required">자산번호</label>
              <input class="f-input" type="text" name="i_asset_no" id="i_asset_no" placeholder="예) 8402C9999" required>
            </div>
            <div class="col-md-4">
              <label class="f-label f-required">품목명</label>
              <input class="f-input" type="text" name="i_item_name" placeholder="예) 노트북 Dell XPS 15" required>
            </div>
            <div class="col-md-4">
              <label class="f-label">자산분류</label>
              <select class="f-select" name="i_asset_class">
                <option value="공기구비품">공기구비품</option>
                <option value="집기비품">집기비품</option>
                <option value="무형고정자산">무형고정자산 (소프트웨어)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="f-label">제조사</label>
              <input class="f-input" type="text" name="i_manufacturer" placeholder="예) Dell">
            </div>
            <div class="col-md-4">
              <label class="f-label">모델명</label>
              <input class="f-input" type="text" name="i_model" placeholder="예) XPS 15 9530">
            </div>
            <div class="col-md-4">
              <label class="f-label">규격/스펙</label>
              <input class="f-input" type="text" name="i_spec" placeholder="예) i7-13700H / 16GB / 512GB">
            </div>
            <div class="col-md-6">
              <label class="f-label">위치 (건물)</label>
              <input class="f-input" type="text" name="i_location" placeholder="예) 1공학관">
            </div>
            <div class="col-md-6">
              <label class="f-label">상세위치 (호실)</label>
              <input class="f-input" type="text" name="i_detail_location" placeholder="예) 301호">
            </div>
            <div class="col-md-4">
              <label class="f-label">관리부서</label>
              <input class="f-input" type="text" name="i_manage_dept" placeholder="예) AI소프트웨어학과">
            </div>
            <div class="col-md-4">
              <label class="f-label">관리자명</label>
              <input class="f-input" type="text" name="i_manager_name" placeholder="예) 홍길동">
            </div>
            <div class="col-md-4">
              <label class="f-label">상태</label>
              <select class="f-select" name="i_asset_status">
                <option value="사용중">사용중</option>
                <option value="사용가능">사용가능</option>
                <option value="점검중">점검중</option>
                <option value="폐기예정">폐기예정</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="f-label">수량</label>
              <input class="f-input" type="number" name="i_quantity" value="1" min="1">
            </div>
            <div class="col-md-3">
              <label class="f-label">취득일자</label>
              <input class="f-input" type="date" name="i_acq_date">
            </div>
            <div class="col-md-3">
              <label class="f-label">취득가 (원)</label>
              <input class="f-input" type="text" name="i_acq_price" placeholder="예) 1500000">
            </div>
            <div class="col-md-3">
              <label class="f-label">내용연수 (년)</label>
              <input class="f-input" type="number" name="i_useful_life" placeholder="예) 5" min="1">
            </div>
            <div class="col-12">
              <label class="f-label">비고</label>
              <textarea class="f-input" name="i_remark" rows="2" placeholder="특이사항 등"></textarea>
            </div>
            <div class="col-12 d-flex gap-2 mt-2">
              <button type="submit" class="btn-success"><i class="bi bi-check-circle"></i>DB에 등록하기</button>
              <button type="button" class="btn-ghost" onclick="showTab('list',null)"><i class="bi bi-x-circle"></i>취소</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- ════ TAB: 수정 ════ -->
  <div class="tab-pane" id="tab-edit">
    <div class="card" style="border-color:#fde68a">
      <div class="card-head" style="background:var(--amber-lt);border-bottom-color:#fde68a">
        <div class="ch-icon si-amber"><i class="bi bi-pencil" style="color:var(--amber)"></i></div>
        <div><div class="ch-title" style="color:var(--amber)">자산 수정</div><div class="ch-sub" id="edit-sub-title">DB에 직접 반영됩니다</div></div>
        <button class="btn-ghost ms-auto" onclick="showTab('list',null)"><i class="bi bi-x"></i> 닫기</button>
      </div>
      <div class="card-body">
        <form method="post" action="/CampusNav/asset_manage.jsp" onsubmit="return confirm('DB에 수정 내용을 저장하시겠습니까?')">
          <input type="hidden" name="action" value="update">
          <div class="row g-3">
            <div class="col-md-4">
              <label class="f-label">자산번호 (변경불가)</label>
              <input class="f-input" type="text" name="u_asset_no" id="u_asset_no" readonly>
            </div>
            <div class="col-md-4">
              <label class="f-label f-required">품목명</label>
              <input class="f-input" type="text" name="u_item_name" id="u_item_name" required>
            </div>
            <div class="col-md-4">
              <label class="f-label">자산분류</label>
              <select class="f-select" name="u_asset_class" id="u_asset_class">
                <option value="공기구비품">공기구비품</option>
                <option value="집기비품">집기비품</option>
                <option value="무형고정자산">무형고정자산 (소프트웨어)</option>
              </select>
            </div>
            <div class="col-md-4">
              <label class="f-label">모델명</label>
              <input class="f-input" type="text" name="u_model" id="u_model">
            </div>
            <div class="col-md-4">
              <label class="f-label">규격/스펙</label>
              <input class="f-input" type="text" name="u_spec" id="u_spec">
            </div>
            <div class="col-md-4">
              <label class="f-label">제조사</label>
              <input class="f-input" type="text" name="u_manufacturer" id="u_manufacturer">
            </div>
            <div class="col-md-6">
              <label class="f-label">위치 (건물)</label>
              <input class="f-input" type="text" name="u_location" id="u_location">
            </div>
            <div class="col-md-6">
              <label class="f-label">상세위치 (호실)</label>
              <input class="f-input" type="text" name="u_detail_location" id="u_detail_location">
            </div>
            <div class="col-md-4">
              <label class="f-label">관리부서</label>
              <input class="f-input" type="text" name="u_manage_dept" id="u_manage_dept">
            </div>
            <div class="col-md-4">
              <label class="f-label">관리자명</label>
              <input class="f-input" type="text" name="u_manager_name" id="u_manager_name">
            </div>
            <div class="col-md-4">
              <label class="f-label">상태</label>
              <select class="f-select" name="u_asset_status" id="u_asset_status">
                <option value="사용중">사용중</option>
                <option value="사용가능">사용가능</option>
                <option value="점검중">점검중</option>
                <option value="폐기예정">폐기예정</option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="f-label">수량</label>
              <input class="f-input" type="number" name="u_quantity" id="u_quantity" min="1">
            </div>
            <div class="col-md-3">
              <label class="f-label">취득일자</label>
              <input class="f-input" type="date" name="u_acq_date" id="u_acq_date">
            </div>
            <div class="col-md-3">
              <label class="f-label">취득가 (원)</label>
              <input class="f-input" type="text" name="u_acq_price" id="u_acq_price">
            </div>
            <div class="col-md-3">
              <label class="f-label">내용연수 (년)</label>
              <input class="f-input" type="number" name="u_useful_life" id="u_useful_life" min="1">
            </div>
            <div class="col-12">
              <label class="f-label">비고</label>
              <textarea class="f-input" name="u_remark" id="u_remark" rows="2"></textarea>
            </div>
            <div class="col-12 d-flex gap-2 mt-2">
              <button type="submit" class="btn-warn"><i class="bi bi-floppy"></i>DB에 수정 저장</button>
              <button type="button" class="btn-ghost" onclick="showTab('list',null)"><i class="bi bi-x-circle"></i>취소</button>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>

  <!-- ════ TAB: 삭제 확인 ════ -->
  <div class="tab-pane" id="tab-delete">
    <div class="card" style="border-color:#fca5a5">
      <div class="card-head" style="background:var(--red-lt);border-bottom-color:#fca5a5">
        <div class="ch-icon si-red"><i class="bi bi-trash" style="color:var(--red)"></i></div>
        <div><div class="ch-title" style="color:var(--red)">자산 삭제</div><div class="ch-sub">삭제 후 복구 불가 — DB에서 영구 제거됩니다</div></div>
        <button class="btn-ghost ms-auto" onclick="showTab('list',null)"><i class="bi bi-x"></i> 닫기</button>
      </div>
      <div class="card-body">
        <!-- 삭제 대상 정보 -->
        <div style="background:var(--white);border:1.5px solid #fca5a5;border-radius:var(--r);padding:20px;margin-bottom:16px">
          <div style="font-size:13px;font-family:var(--mono);color:var(--red);font-weight:700;margin-bottom:12px;text-transform:uppercase;letter-spacing:.06em">
            <i class="bi bi-exclamation-triangle-fill me-1"></i>삭제 대상 자산
          </div>
          <div class="row g-3">
            <div class="col-md-4">
              <div style="font-family:var(--mono);font-size:11px;color:var(--txt3);text-transform:uppercase;margin-bottom:4px">자산번호</div>
              <div style="font-weight:800;font-size:17px;font-family:var(--mono);color:var(--red)" id="del-no-display">-</div>
            </div>
            <div class="col-md-8">
              <div style="font-family:var(--mono);font-size:11px;color:var(--txt3);text-transform:uppercase;margin-bottom:4px">품목명</div>
              <div style="font-weight:700;font-size:16px;color:var(--txt)" id="del-name-display">-</div>
            </div>
          </div>
        </div>
        <div style="background:#fff7ed;border:1px solid #fde68a;border-radius:var(--r);padding:12px 16px;font-size:14px;color:#713f12;margin-bottom:20px;display:flex;align-items:center;gap:8px">
          <i class="bi bi-info-circle-fill"></i>
          이 자산에 연결된 이관이력, 폐기이력도 함께 삭제됩니다 (CASCADE). 예약 기록은 별도 확인하세요.
        </div>
        <form method="post" action="/CampusNav/asset_manage.jsp" onsubmit="return confirmDelete()">
          <input type="hidden" name="action" value="delete">
          <input type="hidden" name="delNo" id="delNo">
          <div style="margin-bottom:16px">
            <label class="f-label">삭제 사유를 입력하세요 (선택)</label>
            <input class="f-input" type="text" name="delReason" id="delReason" placeholder="예) 내용연수 만료, 분실, 파손 등">
          </div>
          <div class="d-flex gap-2">
            <button type="submit" class="btn-danger"><i class="bi bi-trash3-fill"></i>DB에서 영구 삭제</button>
            <button type="button" class="btn-ghost" onclick="showTab('list',null)"><i class="bi bi-x-circle"></i>취소 (돌아가기)</button>
          </div>
        </form>
      </div>
    </div>
  </div>

</div><!-- /shell -->

<!-- FOOTER -->
<footer class="site-footer">
  <div class="footer-inner">
    <a href="/CampusNav/campuslogin.jsp" class="footer-logo">
      <span class="footer-logo-dot"><img src="/CampusNav/images/logo.png" alt="ICT"></span>
      ICT Campus<em>Nav</em>
    </a>
    <div class="footer-team">
      <strong>Made by AI 소프트웨어학과</strong><br>
      박승순 &nbsp;&middot;&nbsp; 권동해 &nbsp;&middot;&nbsp; 원태연 &nbsp;&middot;&nbsp; 이수혁
    </div>
    <div class="footer-copy">
      ICT폴리텍대학 교내 자원 내비게이션 시스템<br>
      Copyright &copy; 2026 ICT CampusNav. All rights reserved.
    </div>
  </div>
</footer>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.bundle.min.js"></script>
<script>
/* ══ 탭 전환 ══ */
function showTab(name, btn) {
  document.querySelectorAll('.tab-pane').forEach(function(e){ e.classList.remove('active'); });
  document.querySelectorAll('.tab-btn').forEach(function(e){ e.classList.remove('active'); });
  document.getElementById('tab-'+name).classList.add('active');
  if(btn) btn.classList.add('active');
  else {
    // 이름으로 찾기
    document.querySelectorAll('.tab-btn').forEach(function(b){
      if(b.id === name+'TabBtn' || b.textContent.includes(name)) b.classList.add('active');
    });
    document.querySelector('.tab-btn').classList.add('active'); // fallback → 첫번째
  }
}

/* ══ 수정 탭 열기 (행 클릭) ══ */
function openEdit(no, cls, name, model, loc, dept, mgr, status) {
  document.getElementById('u_asset_no').value         = no;
  document.getElementById('u_item_name').value        = name;
  document.getElementById('u_model').value            = model;
  document.getElementById('u_detail_location').value  = loc;
  document.getElementById('u_manage_dept').value      = dept;
  document.getElementById('u_manager_name').value     = mgr;
  document.getElementById('edit-sub-title').textContent = '자산번호: ' + no + ' — DB에 직접 반영됩니다';
  // 분류 select
  var sel = document.getElementById('u_asset_class');
  for(var i=0;i<sel.options.length;i++){
    if(sel.options[i].value===cls){ sel.selectedIndex=i; break; }
  }
  // 상태 select
  var ssel = document.getElementById('u_asset_status');
  for(var i=0;i<ssel.options.length;i++){
    if(ssel.options[i].value===status){ ssel.selectedIndex=i; break; }
  }
  // 탭 표시
  document.getElementById('editTabBtn').style.display='';
  showTab('edit', document.getElementById('editTabBtn'));
  window.scrollTo({top:0,behavior:'smooth'});
}

/* ══ 삭제 탭 열기 ══ */
function openDelete(no, name) {
  document.getElementById('del-no-display').textContent  = no;
  document.getElementById('del-name-display').textContent = name;
  document.getElementById('delNo').value = no;
  document.getElementById('delReason').value = '';
  document.getElementById('delTabBtn').style.display='';
  showTab('delete', document.getElementById('delTabBtn'));
  window.scrollTo({top:0,behavior:'smooth'});
}

/* ══ 삭제 최종 확인 ══ */
function confirmDelete() {
  var no   = document.getElementById('delNo').value;
  var name = document.getElementById('del-name-display').textContent;
  return confirm('⚠️ 영구 삭제 확인\n\n자산번호: ' + no + '\n품목명: ' + name + '\n\nDB에서 완전히 삭제됩니다.\n계속하시겠습니까?');
}

/* ══ 등록 폼 유효성 검사 ══ */
function validateInsert() {
  var no   = document.getElementById('i_asset_no').value.trim();
  var name = document.querySelector('[name="i_item_name"]').value.trim();
  if(!no){ alert('자산번호를 입력해 주세요.'); return false; }
  if(!name){ alert('품목명을 입력해 주세요.'); return false; }
  return confirm('자산번호 [' + no + ']\n[' + name + ']\n\nDB에 등록하시겠습니까?');
}

/* ══ POST 성공 후 탭 자동 이동 ══ */
<% if(!msgOk.isEmpty()){ %>
window.addEventListener('DOMContentLoaded', function(){
  showTab('list', document.querySelector('.tab-btn'));
});
<% } %>
</script>
</body>
</html>
