/* ================================================================
   캠퍼스 노드 맵 공통 데이터
   navigationTest1.jsp와 navigationOptimized.jsp에서 공통으로 사용

   좌표 기준: 800x450px (캠퍼스 평면도 원본 이미지 크기)
   ================================================================ */

const CAMPUS_NODES = {
  GATE1:    { name: "정문1", x: 60, y: 390 },
  GATE2:    { name: "정문2", x: 170, y: 385 },
  GATE3:    { name: "정문3", x: 310, y: 380 },
  MAIN_HQ:  { name: "대학본부", x: 290, y: 310 },
  ENG_1:    { name: "제1공학관", x: 308, y: 220 },
  LIBRARY:  { name: "도서관", x: 320, y: 160 },
  DORM_1:   { name: "1생활관", x: 400, y: 140 },
  STU_HALL: { name: "학생회관", x: 520, y: 140 },
  STU_ENG2_MID: { name: "", x: 710, y: 140, isInvisible: true },
  ENG_2:    { name: "제2공학관", x: 710, y: 180 },
  SANHAK:   { name: "산학협력관", x: 710, y: 270 }
};

// 도로망 연결선 (경로 계산용)
const CAMPUS_EDGES = [
  ["GATE1","GATE2"],["GATE2","GATE3"],["GATE3","MAIN_HQ"],
  ["MAIN_HQ","ENG_1"],["ENG_1","LIBRARY"],["LIBRARY","DORM_1"],
  ["DORM_1","STU_HALL"],["SANHAK","ENG_2"],
  ["GATE3","SANHAK"],["STU_HALL","STU_ENG2_MID"],["STU_ENG2_MID","ENG_2"]
];

// 경로 데이터 (navigationOptimized.jsp용 AI 경로 탐색)
const CAMPUS_ROUTES = [
  { id:"R1", name:"중앙 도로 경로 (기존)", path:["GATE3","MAIN_HQ","ENG_1","STU_HALL","STU_ENG2_MID","ENG_2"], distance:290, time:228, congestion:8, risk:6, slope:2, outdoor:80, elevator:false, minWidth:1.0 },
  { id:"R2", name:"생활관-학생회관 실내외 안전경로", path:["GATE3","ENG_1","LIBRARY","DORM_1","STU_HALL","STU_ENG2_MID","ENG_2"], distance:330, time:261, congestion:3, risk:2, slope:1, outdoor:30, elevator:true, minWidth:1.5 },
  { id:"R3", name:"외곽 우회 경로", path:["GATE1","GATE2","GATE3","SANHAK","ENG_2"], distance:460, time:360, congestion:2, risk:2, slope:1, outdoor:90, elevator:false, minWidth:2.0 }
];

// 이미지 정보
const CAMPUS_IMAGE = {
  url: '/CAN/images/ictlayout.png',
  width: 800,
  height: 450,
  aspectRatio: 16/9
};
