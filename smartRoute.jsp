<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>AI 학교자원 스마트 운송시스템</title>

<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css"
      rel="stylesheet">

<style>
body{
    background:#f4f7fb;
    font-family:"Malgun Gothic",sans-serif;
}

.header{
    background:#173f6b;
    color:white;
    padding:18px 25px;
}

.panel{
    background:white;
    border-radius:15px;
    padding:17px;
    box-shadow:0 2px 8px rgba(0,0,0,.08);
}

.map{
    position:relative;
    height:650px;
    background:#eef5e9;
    border:1px solid #ccd6df;
    border-radius:18px;
    overflow:hidden;
}

/* 건물 */
.building{
    position:absolute;
    width:150px;
    height:80px;
    background:white;
    border:3px solid #607d9b;
    border-radius:10px;
    display:flex;
    align-items:center;
    justify-content:center;
    text-align:center;
    font-weight:bold;
    z-index:8;
}

/* 노드 */
.node{
    position:absolute;
    width:18px;
    height:18px;
    background:#198754;
    border:3px solid white;
    border-radius:50%;
    z-index:12;
}

/* 도로 */
.edge{
    position:absolute;
    height:7px;
    background:#b7bec6;
    transform-origin:0 50%;
    border-radius:5px;
    z-index:2;
    opacity:.65;
}

.edge-search{
    background:#ffc107 !important;
    height:9px;
    opacity:1;
}

.edge-best{
    background:#0d6efd !important;
    height:10px;
    opacity:1;
}

.edge-blocked{
    background:#dc3545 !important;
}

/* 이동체 */
#cart{
    position:absolute;
    width:48px;
    height:48px;
    background:#ffd43b;
    border:3px solid #333;
    border-radius:50%;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:24px;
    z-index:30;

    transition:
        left 1.1s linear,
        top 1.1s linear;
}

/* 환경 아이콘 */
.map-event{
    position:absolute;
    min-width:120px;
    padding:8px 10px;
    border-radius:10px;
    font-weight:bold;
    text-align:center;
    z-index:25;
    box-shadow:0 3px 8px rgba(0,0,0,.25);
    animation:eventPulse 1.2s infinite;
}

@keyframes eventPulse{
    0%{transform:scale(1);}
    50%{transform:scale(1.05);}
    100%{transform:scale(1);}
}

.construction-event{
    background:#fff3cd;
    border:2px solid #ff9800;
}

.elevator-event{
    background:#f8d7da;
    border:2px solid #dc3545;
}

.rain-event{
    background:#d9edf7;
    border:2px solid #2196f3;
}

.snow-event{
    background:#f5fbff;
    border:2px solid #90caf9;
}

/* 출발/목적지 */
.start-marker{
    position:absolute;
    background:#198754;
    color:white;
    padding:5px 10px;
    border-radius:15px;
    font-size:12px;
    font-weight:bold;
    z-index:28;
}

.destination-marker{
    position:absolute;
    background:#dc3545;
    color:white;
    padding:5px 10px;
    border-radius:15px;
    font-size:12px;
    font-weight:bold;
    z-index:28;
}

.log{
    height:190px;
    background:#101820;
    color:#b8ffb8;
    overflow:auto;
    padding:12px;
    border-radius:10px;
    font-family:Consolas,monospace;
    font-size:13px;
}

.candidate{
    border-left:5px solid #adb5bd;
    background:#f8f9fa;
    padding:10px;
    margin-bottom:8px;
    border-radius:6px;
}

.best{
    border-left-color:#0d6efd;
    background:#eef5ff;
}

.reject{
    border-left-color:#dc3545;
    background:#fff1f1;
}

.environment{
    background:#fff8e1;
    border:1px solid #ffe082;
    padding:12px;
    border-radius:10px;
}

.legend{
    position:absolute;
    right:15px;
    top:15px;
    background:rgba(255,255,255,.94);
    padding:10px 13px;
    border-radius:10px;
    z-index:40;
    font-size:12px;
    box-shadow:0 2px 8px rgba(0,0,0,.12);
}

.score{
    font-size:20px;
    font-weight:bold;
    color:#0d6efd;
}
</style>
</head>

<body>

<div class="header">
    <h3>🤖 AI 학교자원 스마트 운송시스템</h3>
    <div>
        A* 다중경로 탐색 · 환경위험 분석 · 이동체/화물 적합성 · Dynamic Re-routing
    </div>
</div>

<div class="container-fluid mt-3">

<div class="row g-3">

<!-- ===================================================== -->
<!-- 왼쪽 설정 화면 -->
<!-- ===================================================== -->

<div class="col-lg-3">

<div class="panel">

<h5>🚚 운송 요청</h5>
<hr>

<label class="form-label">
출발지
</label>

<select id="start"
        class="form-select mb-3"
        onchange="changeStart()">

<option value="A">
AI소프트웨어 실습실
</option>

<option value="B">
제1공학관
</option>

<option value="C">
중앙광장
</option>

<option value="D">
도서관
</option>

<option value="F">
제2공학관
</option>

</select>


<label class="form-label">
목적지
</label>

<select id="destination"
        class="form-select mb-3"
        onchange="changeDestination()">

<option value="H">
스마트팩토리 실습실
</option>

<option value="D">
도서관
</option>

<option value="F">
제2공학관
</option>

<option value="C">
중앙광장
</option>

</select>


<!-- 화물 -->

<label class="form-label">
📦 운송 물품
</label>

<select id="cargo"
        class="form-select mb-3"
        onchange="cargoChanged()">

<option value="normal">
실습 기자재 / 40kg / 폭 0.7m
</option>

<option value="server">
서버장비 / 80kg / 폭 0.9m
</option>

<option value="large">
대형장비 / 180kg / 폭 1.4m
</option>

</select>


<!-- 이동체 -->

<label class="form-label">
🚙 이동체
</label>

<select id="vehicle"
        class="form-select mb-3"
        onchange="vehicleChanged()">

<option value="AGV1">
AGV-01 소형 / 최대 100kg
</option>

<option value="AGV2">
AGV-02 대형 / 최대 250kg
</option>

<option value="CART">
자율주행 카트 / 최대 150kg
</option>

</select>


<!-- 최적화 -->

<label class="form-label">
🧠 최적화 기준
</label>

<select id="mode"
        class="form-select mb-3">

<option value="ai">
AI 종합 최적화
</option>

<option value="distance">
최단거리 우선
</option>

<option value="safe">
안전 우선
</option>

<option value="time">
시간 우선
</option>

</select>


<!-- 환경 -->

<div class="environment mb-3">

<b>🌍 환경/장애 상황</b>

<div class="form-check mt-2">

<input class="form-check-input"
       type="checkbox"
       id="construction"
       onchange="environmentChanged()">

<label class="form-check-label">
🚧 공사구간 발생
</label>

</div>


<div class="form-check">

<input class="form-check-input"
       type="checkbox"
       id="elevator"
       onchange="environmentChanged()">

<label class="form-check-label">
🛗 엘리베이터 서비스 중단
</label>

</div>


<div class="form-check">

<input class="form-check-input"
       type="checkbox"
       id="rain"
       onchange="environmentChanged()">

<label class="form-check-label">
🌧 우천
</label>

</div>


<div class="form-check">

<input class="form-check-input"
       type="checkbox"
       id="snow"
       onchange="environmentChanged()">

<label class="form-check-label">
❄ 폭설 / 결빙
</label>

</div>

</div>


<button class="btn btn-primary w-100 mb-2"
        onclick="searchRoutes()">

🔎 AI 최적경로 탐색

</button>


<button class="btn btn-success w-100 mb-2"
        onclick="startTransport()">

▶ 운송 시작

</button>


<button class="btn btn-danger w-100"
        onclick="dynamicObstacle()">

⚠ 운행 중 돌발 장애물

</button>

<hr>

<div>
상태 :
<span id="status"
      class="badge bg-secondary">
대기
</span>
</div>

<div class="mt-2">
이동체 :
<b id="vehicleInfo">
AGV-01
</b>
</div>

<div>
화물 :
<b id="cargoInfo">
40kg / 폭 0.7m
</b>
</div>

</div>
</div>


<!-- ===================================================== -->
<!-- 지도 -->
<!-- ===================================================== -->

<div class="col-lg-9">

<div class="map" id="map">


<!-- 범례 -->

<div class="legend">

<b>지도 범례</b><br>

<span style="color:#0d6efd">
━━━━
</span>
AI 최적경로<br>

<span style="color:#ffc107">
━━━━
</span>
탐색 중<br>

🚧 공사<br>
🛗 엘리베이터 중단<br>
🌧 우천<br>
❄ 결빙

</div>


<!-- 건물 -->

<div class="building"
     style="left:30px;top:35px;">
AI소프트웨어<br>실습실
</div>


<div class="building"
     style="left:400px;top:35px;">
제1공학관
</div>


<div class="building"
     style="right:30px;top:35px;">
제2공학관
</div>


<div class="building"
     style="left:30px;bottom:35px;">
도서관
</div>


<div class="building"
     style="right:30px;bottom:35px;">
스마트팩토리<br>실습실
</div>


<!-- 중앙광장 -->

<div style="
position:absolute;
left:47%;
top:43%;
width:140px;
height:75px;
background:#dceefb;
border:3px solid #2680c2;
border-radius:50%;
display:flex;
align-items:center;
justify-content:center;
font-weight:bold;
z-index:7;
">

중앙광장

</div>


<!-- Node -->

<div id="nA" class="node"></div>
<div id="nB" class="node"></div>
<div id="nC" class="node"></div>
<div id="nD" class="node"></div>
<div id="nE" class="node"></div>
<div id="nF" class="node"></div>
<div id="nG" class="node"></div>
<div id="nH" class="node"></div>


<!-- 이동체 -->

<div id="cart">
🚚
</div>


<!-- 출발지 표시 -->

<div id="startMarker"
     class="start-marker">

START

</div>


<!-- 목적지 표시 -->

<div id="destinationMarker"
     class="destination-marker">

GOAL

</div>


<!-- 환경 이벤트 -->

<div id="constructionEvent"
     class="map-event construction-event"
     style="display:none;">

🚧 공사중<br>
통행불가

</div>


<div id="elevatorEvent"
     class="map-event elevator-event"
     style="display:none;">

🛗 엘리베이터<br>
서비스 중단

</div>


<div id="rainEvent"
     class="map-event rain-event"
     style="display:none;">

🌧 우천<br>
실외 위험 ↑

</div>


<div id="snowEvent"
     class="map-event snow-event"
     style="display:none;">

❄ 결빙<br>
미끄럼 위험 ↑↑

</div>

</div>


<!-- ===================================================== -->
<!-- 결과 -->
<!-- ===================================================== -->

<div class="row mt-3 g-3">

<div class="col-md-6">

<div class="panel">

<h5>
🧠 AI 경로 탐색 과정
</h5>

<div id="searchResult">

출발지와 목적지를 선택한 후
AI 최적경로 탐색을 실행하십시오.

</div>

</div>

</div>


<div class="col-md-6">

<div class="panel">

<h5>
📊 기존 경로 vs AI 최적경로
</h5>

<div id="comparison">

경로 탐색 후 비교 결과가 표시됩니다.

</div>

</div>

</div>

</div>


<div class="panel mt-3">

<h5>
💻 AI 의사결정 로그
</h5>

<div id="log"
     class="log">

SYSTEM > 운송 요청을 기다리고 있습니다.

</div>

</div>


</div>
</div>
</div>


<script>

/* =======================================================
   NODE
======================================================= */

const nodes={

A:{
 name:"AI소프트웨어 실습실",
 x:170,
 y:90
},

B:{
 name:"제1공학관",
 x:430,
 y:155
},

C:{
 name:"중앙광장",
 x:590,
 y:300
},

D:{
 name:"도서관",
 x:170,
 y:525
},

E:{
 name:"서쪽 우회통로",
 x:390,
 y:410
},

F:{
 name:"제2공학관",
 x:900,
 y:150
},

G:{
 name:"동쪽 통행로",
 x:820,
 y:410
},

H:{
 name:"스마트팩토리 실습실",
 x:1050,
 y:525
}

};


/* =======================================================
   후보 경로
======================================================= */

const routes=[

{
 id:"R1",

 name:"기존 최단경로",

 nodes:["A","B","C","G","H"],

 distance:310,

 time:260,

 congestion:8,

 risk:7,

 slope:3,

 outdoor:80,

 elevator:false,

 minWidth:1.0
},


{
 id:"R2",

 name:"실내 안전경로",

 nodes:["A","B","E","G","H"],

 distance:350,

 time:290,

 congestion:3,

 risk:2,

 slope:2,

 outdoor:20,

 elevator:true,

 minWidth:1.5
},


{
 id:"R3",

 name:"도서관 우회경로",

 nodes:["A","D","E","G","H"],

 distance:390,

 time:320,

 congestion:2,

 risk:2,

 slope:1,

 outdoor:60,

 elevator:false,

 minWidth:1.8
},


{
 id:"R4",

 name:"제2공학관 경유",

 nodes:["A","B","F","G","H"],

 distance:420,

 time:340,

 congestion:4,

 risk:3,

 slope:2,

 outdoor:30,

 elevator:true,

 minWidth:1.4
}

];


let selectedRoute=null;

let movingIndex=0;

let edgeElements=[];


/* =======================================================
   시작
======================================================= */

window.onload=function(){

    positionNodes();

    drawBaseNetwork();

    changeStart();

    changeDestination();

};


/* =======================================================
   Node 위치
======================================================= */

function positionNodes(){

    for(let id in nodes){

        let el=
        document.getElementById("n"+id);

        el.style.left=
        nodes[id].x+"px";

        el.style.top=
        nodes[id].y+"px";

    }

}


/* =======================================================
   기본 도로망
======================================================= */

function drawBaseNetwork(){

    const network=[

        ["A","B"],
        ["A","D"],

        ["B","C"],
        ["B","E"],
        ["B","F"],

        ["C","G"],

        ["D","E"],

        ["E","G"],

        ["F","G"],

        ["G","H"]

    ];


    network.forEach(function(e){

        drawLine(
            e[0],
            e[1],
            "base"
        );

    });

}


/* =======================================================
   출발지 변경
======================================================= */

function changeStart(){

    let id=
    document.getElementById("start").value;


    let n=
    nodes[id];


    let cart=
    document.getElementById("cart");


    cart.style.left=
    (n.x-15)+"px";

    cart.style.top=
    (n.y-15)+"px";


    let marker=
    document.getElementById("startMarker");


    marker.style.left=
    (n.x-25)+"px";

    marker.style.top=
    (n.y-38)+"px";


    log(
        "출발지 변경 → "+
        n.name
    );

}


/* =======================================================
   목적지 변경
======================================================= */

function changeDestination(){

    let id=
    document.getElementById(
        "destination"
    ).value;


    let n=
    nodes[id];


    let marker=
    document.getElementById(
        "destinationMarker"
    );


    marker.style.left=
    (n.x-20)+"px";

    marker.style.top=
    (n.y-38)+"px";


    log(
        "목적지 변경 → "+
        n.name
    );

}


/* =======================================================
   환경 이벤트
======================================================= */

function environmentChanged(){

    let construction=
    document.getElementById(
        "construction"
    ).checked;


    let elevator=
    document.getElementById(
        "elevator"
    ).checked;


    let rain=
    document.getElementById(
        "rain"
    ).checked;


    let snow=
    document.getElementById(
        "snow"
    ).checked;


    /* 공사 */

    let c=
    document.getElementById(
        "constructionEvent"
    );


    if(construction){

        c.style.display="block";

        /*
        중앙광장 -> 동쪽통행로
        공사라고 가정
        */

        c.style.left="680px";
        c.style.top="320px";

        log(
        "🚧 중앙광장-동쪽통행로 공사 발생"
        );

    }else{

        c.style.display="none";

    }


    /* 엘리베이터 */

    let e=
    document.getElementById(
        "elevatorEvent"
    );


    if(elevator){

        e.style.display="block";

        e.style.left="420px";
        e.style.top="115px";

        log(
        "🛗 제1공학관 엘리베이터 서비스 중단"
        );

    }else{

        e.style.display="none";

    }


    /* 우천 */

    let r=
    document.getElementById(
        "rainEvent"
    );


    if(rain){

        r.style.display="block";

        r.style.left="650px";
        r.style.top="180px";

        log(
        "🌧 우천 발생 → 실외구간 위험도 증가"
        );

    }else{

        r.style.display="none";

    }


    /* 눈 */

    let s=
    document.getElementById(
        "snowEvent"
    );


    if(snow){

        s.style.display="block";

        s.style.left="750px";
        s.style.top="470px";

        log(
        "❄ 결빙 발생 → 실외 경로 Cost 증가"
        );

    }else{

        s.style.display="none";

    }

}


/* =======================================================
   이동체 변경
======================================================= */

function vehicleChanged(){

    let v=
    document.getElementById(
        "vehicle"
    ).value;


    let text="";


    if(v==="AGV1")

        text=
        "AGV-01 / 최대 100kg";


    if(v==="AGV2")

        text=
        "AGV-02 / 최대 250kg";


    if(v==="CART")

        text=
        "자율주행 카트 / 최대 150kg";


    document.getElementById(
        "vehicleInfo"
    ).innerHTML=text;


    log(
        "이동체 선택 → "+text
    );

}


/* =======================================================
   화물 변경
======================================================= */

function cargoChanged(){

    let cargo=
    document.getElementById(
        "cargo"
    ).value;


    let text="";


    if(cargo==="normal")

        text=
        "40kg / 폭 0.7m";


    if(cargo==="server")

        text=
        "80kg / 폭 0.9m";


    if(cargo==="large")

        text=
        "180kg / 폭 1.4m";


    document.getElementById(
        "cargoInfo"
    ).innerHTML=text;


    log(
        "화물 변경 → "+text
    );

}


/* =======================================================
   AI Cost
======================================================= */

function calculateCost(route){

    let mode=
    document.getElementById("mode").value;


    let distanceWeight=.30;
    let timeWeight=.25;
    let congestionWeight=.20;
    let riskWeight=.15;
    let slopeWeight=.10;


    if(mode==="distance"){

        distanceWeight=.60;
        timeWeight=.20;
        congestionWeight=.08;
        riskWeight=.07;
        slopeWeight=.05;

    }


    if(mode==="safe"){

        distanceWeight=.15;
        timeWeight=.15;
        congestionWeight=.20;
        riskWeight=.40;
        slopeWeight=.10;

    }


    if(mode==="time"){

        distanceWeight=.20;
        timeWeight=.50;
        congestionWeight=.15;
        riskWeight=.10;
        slopeWeight=.05;

    }


    let cost=

    route.distance*distanceWeight+

    route.time*timeWeight+

    route.congestion*10*
    congestionWeight+

    route.risk*10*
    riskWeight+

    route.slope*10*
    slopeWeight;


    /* 우천 */

    if(
       document.getElementById(
       "rain"
       ).checked
    ){

        cost+=
        route.outdoor*.25;

    }


    /* 폭설 */

    if(
       document.getElementById(
       "snow"
       ).checked
    ){

        cost+=
        route.outdoor*.60;

    }


    return cost;

}


/* =======================================================
   경로 이용 가능 판단
======================================================= */

function checkRoute(route){

    let cargo=
    document.getElementById(
        "cargo"
    ).value;


    let vehicle=
    document.getElementById(
        "vehicle"
    ).value;


    let width=.7;
    let weight=40;


    if(cargo==="server"){

        width=.9;
        weight=80;

    }


    if(cargo==="large"){

        width=1.4;
        weight=180;

    }


    let capacity=100;


    if(vehicle==="AGV2")

        capacity=250;


    if(vehicle==="CART")

        capacity=150;


    /* 적재중량 */

    if(weight>capacity){

        return{

            ok:false,

            reason:
            "화물 "+weight+
            "kg > 이동체 적재한도 "+
            capacity+"kg"

        };

    }


    /* 통로 폭 */

    if(width>route.minWidth){

        return{

            ok:false,

            reason:
            "화물 폭 "+width+
            "m > 최소 통로폭 "+
            route.minWidth+"m"

        };

    }


    /* 엘리베이터 */

    if(
        document.getElementById(
        "elevator"
        ).checked
        &&
        route.elevator
    ){

        return{

            ok:false,

            reason:
            "엘리베이터 서비스 중단"

        };

    }


    /* 공사 */

    if(
        document.getElementById(
        "construction"
        ).checked
        &&
        route.id==="R1"
    ){

        return{

            ok:false,

            reason:
            "중앙광장-동쪽통행로 공사"

        };

    }


    return {ok:true};

}


/* =======================================================
   AI 경로 탐색
======================================================= */

async function searchRoutes(){

    selectedRoute=null;


    removeSearchEdges();


    document.getElementById(
        "searchResult"
    ).innerHTML="";


    setStatus(
        "AI 탐색중",
        "bg-warning text-dark"
    );


    log(
        "=========================="
    );

    log(
        "A* 다중 후보 경로 탐색 시작"
    );


    let valid=[];


    for(
        let i=0;
        i<routes.length;
        i++
    ){

        let route=
        routes[i];


        log(
            "후보 "+(i+1)+
            " 탐색 → "+
            route.name
        );


        drawRoute(
            route,
            "search"
        );


        await sleep(1300);


        let result=
        checkRoute(route);


        if(!result.ok){

            document.getElementById(
                "searchResult"
            ).innerHTML+=

            "<div class='candidate reject'>"+

            "<b>❌ "+
            route.name+
            "</b><br>"+

            routeText(route)+

            "<br><b>제외 :</b> "+
            result.reason+

            "</div>";


            log(
                "후보 제외 → "+
                result.reason
            );


            removeSearchEdges();

            await sleep(600);

            continue;

        }


        let cost=
        calculateCost(route);


        valid.push({

            route:route,

            cost:cost

        });


        document.getElementById(
            "searchResult"
        ).innerHTML+=

        "<div class='candidate'>"+

        "<b>🔍 "+
        route.name+
        "</b><br>"+

        routeText(route)+

        "<br>"+

        "거리 : "+
        route.distance+
        "m / 시간 : "+
        route.time+
        "초"+

        "<br>"+

        "혼잡도 : "+
        route.congestion+
        " / 위험도 : "+
        route.risk+

        "<br>"+

        "<b>AI Cost : "+
        cost.toFixed(1)+
        "</b>"+

        "</div>";


        log(
            "Cost 계산 → "+
            cost.toFixed(1)
        );


        await sleep(800);


        removeSearchEdges();

    }


    if(valid.length===0){

        setStatus(
            "운송불가",
            "bg-danger"
        );


        document.getElementById(
            "comparison"
        ).innerHTML=

        "<div class='alert alert-danger'>"+
        "<b>운송 가능한 경로가 없습니다.</b><br>"+
        "이동체, 화물크기 또는 환경조건을 변경하십시오."+
        "</div>";


        return;

    }


    valid.sort(
        (a,b)=>a.cost-b.cost
    );


    selectedRoute=
    valid[0].route;


    drawRoute(
        selectedRoute,
        "best"
    );


    showComparison(
        valid
    );


    setStatus(
        "최적경로 결정",
        "bg-primary"
    );


    log(
        "★ 최종 선택 → "+
        selectedRoute.name
    );

}


/* =======================================================
   기존경로 vs AI
======================================================= */

function showComparison(valid){

    let original=
    routes[0];


    let best=
    valid[0];


    let originalCheck=
    checkRoute(original);


    let originalStatus=
    originalCheck.ok
    ?
    "이용 가능"
    :
    "❌ "+originalCheck.reason;


    let html=

    "<table class='table table-bordered table-sm'>"+

    "<thead class='table-light'>"+

    "<tr>"+

    "<th>평가항목</th>"+

    "<th>기존 최단경로</th>"+

    "<th>AI 선택경로</th>"+

    "</tr>"+

    "</thead>"+

    "<tbody>"+


    "<tr>"+

    "<td>경로</td>"+

    "<td>"+
    original.name+
    "</td>"+

    "<td><b>"+
    best.route.name+
    "</b></td>"+

    "</tr>"+


    "<tr>"+

    "<td>거리</td>"+

    "<td>"+
    original.distance+
    "m</td>"+

    "<td>"+
    best.route.distance+
    "m</td>"+

    "</tr>"+


    "<tr>"+

    "<td>시간</td>"+

    "<td>"+
    original.time+
    "초</td>"+

    "<td>"+
    best.route.time+
    "초</td>"+

    "</tr>"+


    "<tr>"+

    "<td>혼잡도</td>"+

    "<td>"+
    original.congestion+
    "</td>"+

    "<td>"+
    best.route.congestion+
    "</td>"+

    "</tr>"+


    "<tr>"+

    "<td>위험도</td>"+

    "<td>"+
    original.risk+
    "</td>"+

    "<td>"+
    best.route.risk+
    "</td>"+

    "</tr>"+


    "<tr>"+

    "<td>기존경로 상태</td>"+

    "<td>"+
    originalStatus+
    "</td>"+

    "<td>이용 가능</td>"+

    "</tr>"+


    "<tr>"+

    "<td>AI Cost</td>"+

    "<td>"+
    calculateCost(original)
    .toFixed(1)+
    "</td>"+

    "<td class='score'>"+
    best.cost.toFixed(1)+
    "</td>"+

    "</tr>"+

    "</tbody>"+

    "</table>";


    html+=
    "<div class='alert alert-primary'>"+

    "<b>🤖 왜 이 경로를 선택했는가?</b><br>";


    if(best.route.id==="R1"){

        html+=
        "현재 운행환경에서는 기존 최단경로가 "+
        "거리·시간·혼잡·위험을 종합적으로 "+
        "평가해도 가장 낮은 비용을 나타냅니다.";

    }

    else{

        html+=
        "기존 최단경로보다 거리가 길더라도 "+
        "공사, 엘리베이터 상태, 기상상태, "+
        "혼잡도, 위험도, 화물 크기 및 이동체 "+
        "적재능력을 종합적으로 평가한 결과 "+
        "<b>"+best.route.name+
        "</b>의 총 Cost가 가장 낮았습니다.";

    }


    html+=
    "</div>";


    document.getElementById(
        "comparison"
    ).innerHTML=html;

}


/* =======================================================
   운송
======================================================= */

function startTransport(){

    if(selectedRoute===null){

        alert(
        "먼저 AI 최적경로를 탐색하십시오."
        );

        return;

    }


    movingIndex=0;


    setStatus(
        "운송중",
        "bg-success"
    );


    log(
        "운송 시작"
    );


    moveNext();

}


function moveNext(){

    if(
        movingIndex>=
        selectedRoute.nodes.length
    ){

        setStatus(
            "운송완료",
            "bg-success"
        );


        log(
            "✅ 목적지 도착"
        );


        return;

    }


    let id=
    selectedRoute.nodes[
        movingIndex
    ];


    let n=
    nodes[id];


    let cart=
    document.getElementById(
        "cart"
    );


    cart.style.left=
    (n.x-15)+"px";


    cart.style.top=
    (n.y-15)+"px";


    log(
        "🚚 현재 위치 → "+
        n.name
    );


    movingIndex++;


    setTimeout(
        moveNext,
        1400
    );

}


/* =======================================================
   돌발 장애물
======================================================= */

async function dynamicObstacle(){

    document.getElementById(
        "construction"
    ).checked=true;


    environmentChanged();


    setStatus(
        "장애물 감지",
        "bg-danger"
    );


    log(
        "⚠ 센서가 전방 장애물을 감지했습니다."
    );


    log(
        "현재 Edge ACCESSIBLE = FALSE"
    );


    await sleep(1500);


    log(
        "Dynamic Re-routing 시작"
    );


    await searchRoutes();

}


/* =======================================================
   경로 그리기
======================================================= */

function drawRoute(route,type){

    for(
        let i=0;
        i<route.nodes.length-1;
        i++
    ){

        drawLine(
            route.nodes[i],
            route.nodes[i+1],
            type
        );

    }

}


/* =======================================================
   Line
======================================================= */

function drawLine(aId,bId,type){

    let a=
    nodes[aId];


    let b=
    nodes[bId];


    let dx=
    b.x-a.x;


    let dy=
    b.y-a.y;


    let length=
    Math.sqrt(
        dx*dx+
        dy*dy
    );


    let angle=
    Math.atan2(
        dy,
        dx
    )*180/Math.PI;


    let line=
    document.createElement("div");


    line.className=
    "edge";


    if(type==="search"){

        line.classList.add(
            "edge-search"
        );

        line.dataset.temp="true";

    }


    if(type==="best"){

        line.classList.add(
            "edge-best"
        );

        line.dataset.temp="true";

    }


    line.style.left=
    (a.x+9)+"px";


    line.style.top=
    (a.y+9)+"px";


    line.style.width=
    length+"px";


    line.style.transform=
    "rotate("+angle+"deg)";


    document.getElementById(
        "map"
    ).appendChild(line);

}


/* =======================================================
   탐색선 삭제
======================================================= */

function removeSearchEdges(){

    document.querySelectorAll(
        "[data-temp='true']"
    ).forEach(function(e){

        e.remove();

    });

}


/* =======================================================
   경로 텍스트
======================================================= */

function routeText(route){

    return route.nodes
    .map(function(id){

        return nodes[id].name;

    })
    .join(" → ");

}


/* =======================================================
   상태
======================================================= */

function setStatus(
    text,
    color
){

    let status=
    document.getElementById(
        "status"
    );


    status.innerHTML=
    text;


    status.className=
    "badge "+color;

}


/* =======================================================
   로그
======================================================= */

function log(message){

    let box=
    document.getElementById(
        "log"
    );


    box.innerHTML+=

    "<br>AI &gt; "+
    message;


    box.scrollTop=
    box.scrollHeight;

}


/* =======================================================
   sleep
======================================================= */

function sleep(ms){

    return new Promise(
        resolve=>
        setTimeout(
            resolve,
            ms
        )
    );

}

</script>

</body>
</html>