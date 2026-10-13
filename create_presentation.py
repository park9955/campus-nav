# -*- coding: utf-8 -*-
from pptx import Presentation
from pptx.util import Inches, Pt
from pptx.enum.text import PP_ALIGN, MSO_ANCHOR
from pptx.dml.color import RGBColor
from pptx.chart.data import CategoryChartData
from pptx.enum.chart import XL_CHART_TYPE

# 프레젠테이션 생성
prs = Presentation()
prs.slide_width = Inches(10)
prs.slide_height = Inches(7.5)

# 색상 정의
PRIMARY_COLOR = RGBColor(102, 126, 234)  # 보라색
SECONDARY_COLOR = RGBColor(118, 75, 162)  # 진한 보라색
ACCENT_COLOR = RGBColor(255, 107, 107)  # 빨강
TEXT_COLOR = RGBColor(51, 51, 51)  # 어두운 회색
LIGHT_BG = RGBColor(248, 249, 255)  # 밝은 배경

def add_title_slide(prs, title, subtitle):
    """제목 슬라이드 추가"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])  # 빈 레이아웃
    background = slide.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = PRIMARY_COLOR

    # 제목
    title_box = slide.shapes.add_textbox(Inches(0.5), Inches(2.5), Inches(9), Inches(1.5))
    title_frame = title_box.text_frame
    title_frame.word_wrap = True
    title_p = title_frame.paragraphs[0]
    title_p.text = title
    title_p.font.size = Pt(60)
    title_p.font.bold = True
    title_p.font.color.rgb = RGBColor(255, 255, 255)
    title_p.alignment = PP_ALIGN.CENTER

    # 부제목
    subtitle_box = slide.shapes.add_textbox(Inches(0.5), Inches(4), Inches(9), Inches(1))
    subtitle_frame = subtitle_box.text_frame
    subtitle_p = subtitle_frame.paragraphs[0]
    subtitle_p.text = subtitle
    subtitle_p.font.size = Pt(32)
    subtitle_p.font.color.rgb = RGBColor(255, 255, 255)
    subtitle_p.alignment = PP_ALIGN.CENTER

    return slide

def add_content_slide(prs, title, content_type="text"):
    """콘텐츠 슬라이드 추가"""
    slide = prs.slides.add_slide(prs.slide_layouts[6])

    # 배경
    background = slide.background
    fill = background.fill
    fill.solid()
    fill.fore_color.rgb = RGBColor(255, 255, 255)

    # 제목 배경
    title_shape = slide.shapes.add_shape(1, Inches(0), Inches(0), Inches(10), Inches(1))
    title_shape.fill.solid()
    title_shape.fill.fore_color.rgb = PRIMARY_COLOR
    title_shape.line.color.rgb = PRIMARY_COLOR

    # 제목 텍스트
    title_box = slide.shapes.add_textbox(Inches(0.5), Inches(0.2), Inches(9), Inches(0.8))
    title_frame = title_box.text_frame
    title_p = title_frame.paragraphs[0]
    title_p.text = title
    title_p.font.size = Pt(44)
    title_p.font.bold = True
    title_p.font.color.rgb = RGBColor(255, 255, 255)

    return slide

def add_text_content(slide, text, top, left=0.5, width=9, height=1.5, font_size=18):
    """텍스트 콘텐츠 추가"""
    text_box = slide.shapes.add_textbox(Inches(left), Inches(top), Inches(width), Inches(height))
    text_frame = text_box.text_frame
    text_frame.word_wrap = True
    p = text_frame.paragraphs[0]
    p.text = text
    p.font.size = Pt(font_size)
    p.font.color.rgb = TEXT_COLOR
    return text_box

def add_feature_box(slide, title, description, left, top, width=2.5, height=1.8):
    """기능 박스 추가"""
    # 박스 배경
    shape = slide.shapes.add_shape(1, Inches(left), Inches(top), Inches(width), Inches(height))
    shape.fill.solid()
    shape.fill.fore_color.rgb = LIGHT_BG
    shape.line.color.rgb = PRIMARY_COLOR
    shape.line.width = Pt(2)

    # 제목
    title_box = slide.shapes.add_textbox(Inches(left + 0.1), Inches(top + 0.1), Inches(width - 0.2), Inches(0.4))
    title_frame = title_box.text_frame
    title_frame.word_wrap = True
    title_p = title_frame.paragraphs[0]
    title_p.text = title
    title_p.font.size = Pt(14)
    title_p.font.bold = True
    title_p.font.color.rgb = PRIMARY_COLOR

    # 설명
    desc_box = slide.shapes.add_textbox(Inches(left + 0.1), Inches(top + 0.55), Inches(width - 0.2), Inches(height - 0.7))
    desc_frame = desc_box.text_frame
    desc_frame.word_wrap = True
    desc_p = desc_frame.paragraphs[0]
    desc_p.text = description
    desc_p.font.size = Pt(11)
    desc_p.font.color.rgb = TEXT_COLOR

    return shape

# ===== Slide 1: 제목 슬라이드 =====
slide1 = add_title_slide(prs, "ICT CAN", "캠퍼스 자산 관리 & 내비게이션 통합 시스템")

# 팀 정보
team_box = slide1.shapes.add_textbox(Inches(0.5), Inches(5.5), Inches(9), Inches(1.5))
team_frame = team_box.text_frame
team_frame.word_wrap = True

p1 = team_frame.paragraphs[0]
p1.text = "조장: (학생 이름)  |  조원: (학생 이름), (학생 이름), (학생 이름)"
p1.font.size = Pt(18)
p1.font.color.rgb = RGBColor(255, 255, 255)
p1.alignment = PP_ALIGN.CENTER

p2 = team_frame.add_paragraph()
p2.text = "2026년 프로젝트 실습"
p2.font.size = Pt(16)
p2.font.color.rgb = RGBColor(200, 200, 200)
p2.alignment = PP_ALIGN.CENTER
p2.space_before = Pt(10)

# ===== Slide 2: 프로젝트 개요 =====
slide2 = add_content_slide(prs, "프로젝트 개요")

# 개요 텍스트
overview_text = """ICT CAN은 ICT 폴리텍대학의 교내 자산 8,401개를 통합 관리하고,
학부생·조교·교수·관리자·게스트·외부인 등 다양한 사용자에게 자산 검색, 예약,
이관 추적, 교수 정보 관리, 층별 내비게이션을 제공하는 웹 기반 통합 정보시스템입니다."""

add_text_content(slide2, overview_text, 1.3, font_size=16)

# 통계 박스들
stats = [
    ("8,401개", "관리 자산 수", 0.7),
    ("6개 역할", "사용자 구분", 3.7),
    ("7개 기능", "핵심 시스템", 6.7)
]

for i, (num, label, left) in enumerate(stats):
    stat_shape = slide2.shapes.add_shape(1, Inches(left), Inches(3.2), Inches(2.5), Inches(1.5))
    stat_shape.fill.solid()
    stat_shape.fill.fore_color.rgb = PRIMARY_COLOR if i == 0 else (SECONDARY_COLOR if i == 1 else ACCENT_COLOR)
    stat_shape.line.color.rgb = stat_shape.fill.fore_color.rgb

    # 숫자
    num_box = slide2.shapes.add_textbox(Inches(left + 0.1), Inches(3.35), Inches(2.3), Inches(0.6))
    num_frame = num_box.text_frame
    num_p = num_frame.paragraphs[0]
    num_p.text = num
    num_p.font.size = Pt(36)
    num_p.font.bold = True
    num_p.font.color.rgb = RGBColor(255, 255, 255)
    num_p.alignment = PP_ALIGN.CENTER

    # 레이블
    label_box = slide2.shapes.add_textbox(Inches(left + 0.1), Inches(4), Inches(2.3), Inches(0.5))
    label_frame = label_box.text_frame
    label_p = label_frame.paragraphs[0]
    label_p.text = label
    label_p.font.size = Pt(13)
    label_p.font.color.rgb = RGBColor(255, 255, 255)
    label_p.alignment = PP_ALIGN.CENTER

# 하단 설명
add_text_content(slide2, "• 기존의 분산된 엑셀 기반 자산 관리를 중앙 집중식 데이터베이스로 통합\n• 실시간 자산 상태 조회 및 완전한 감사 추적 가능", 5.2, font_size=14)

# ===== Slide 3: 프로젝트 목표 =====
slide3 = add_content_slide(prs, "프로젝트 목표")

objectives = [
    ("1. 자산 가시성 강화", "8,401개 자산을 키워드/카테고리/상태로\n검색 가능하게 통합 관리"),
    ("2. 사용 편의성 증대", "자산 예약, 이관, 내비게이션을\n한 플랫폼에서 처리"),
    ("3. 운영 효율성 개선", "자산 이관/폐기 프로세스를\n디지털화"),
    ("4. 사용자 경험 최적화", "역할별 맞춤형 인터페이스 제공\n(6개 역할)")
]

for i, (title, desc) in enumerate(objectives):
    row = i // 2
    col = i % 2
    left = 0.7 + col * 4.7
    top = 1.5 + row * 2.8

    # 배경 박스
    box_shape = slide3.shapes.add_shape(1, Inches(left), Inches(top), Inches(4.3), Inches(2.3))
    box_shape.fill.solid()
    box_shape.fill.fore_color.rgb = LIGHT_BG
    box_shape.line.color.rgb = PRIMARY_COLOR
    box_shape.line.width = Pt(3)

    # 제목
    title_box = slide3.shapes.add_textbox(Inches(left + 0.2), Inches(top + 0.15), Inches(3.9), Inches(0.5))
    title_frame = title_box.text_frame
    title_p = title_frame.paragraphs[0]
    title_p.text = title
    title_p.font.size = Pt(14)
    title_p.font.bold = True
    title_p.font.color.rgb = PRIMARY_COLOR

    # 설명
    desc_box = slide3.shapes.add_textbox(Inches(left + 0.2), Inches(top + 0.7), Inches(3.9), Inches(1.4))
    desc_frame = desc_box.text_frame
    desc_frame.word_wrap = True
    desc_p = desc_frame.paragraphs[0]
    desc_p.text = desc
    desc_p.font.size = Pt(12)
    desc_p.font.color.rgb = TEXT_COLOR

# ===== Slide 4: 주요 기능 =====
slide4 = add_content_slide(prs, "주요 기능")

features = [
    ("🔍\n검색", "키워드, 카테고리,\n상태별 검색"),
    ("📅\n예약", "자산 중복 방지\n예약/취소"),
    ("🔄\n이관", "이관 요청\n승인 워크플로우"),
    ("🗺️\n내비게이션", "3D 맵 기반\n층별 안내"),
    ("👨‍🏫\n교수 관리", "교수 정보\n교과목 관리"),
    ("🔐\n권한 제어", "6개 역할별\n접근 권한")
]

for i, (emoji_title, desc) in enumerate(features):
    row = i // 3
    col = i % 3
    left = 0.6 + col * 3.2
    top = 1.4 + row * 2.8

    add_feature_box(slide4, emoji_title, desc, left, top, width=2.8, height=2.3)

# ===== Slide 5: 시스템 아키텍처 =====
slide5 = add_content_slide(prs, "시스템 아키텍처")

# 계층 구조
layers = [
    ("사용자 인터페이스", "HTML5, CSS3, JavaScript", RGBColor(102, 126, 234)),
    ("비즈니스 로직", "Java Servlet, JSP", RGBColor(118, 75, 162)),
    ("데이터 계층", "MySQL Database", RGBColor(255, 107, 107)),
    ("서버", "Apache Tomcat 9.0", RGBColor(75, 192, 192))
]

for i, (layer, tech, color) in enumerate(layers):
    top = 1.5 + i * 1.2

    # 레이어 박스
    layer_shape = slide5.shapes.add_shape(1, Inches(1.5), Inches(top), Inches(7), Inches(0.95))
    layer_shape.fill.solid()
    layer_shape.fill.fore_color.rgb = color
    layer_shape.line.width = Pt(2)
    layer_shape.line.color.rgb = color

    # 계층명
    layer_box = slide5.shapes.add_textbox(Inches(1.7), Inches(top + 0.1), Inches(2.5), Inches(0.75))
    layer_frame = layer_box.text_frame
    layer_p = layer_frame.paragraphs[0]
    layer_p.text = layer
    layer_p.font.size = Pt(16)
    layer_p.font.bold = True
    layer_p.font.color.rgb = RGBColor(255, 255, 255)
    layer_p.alignment = PP_ALIGN.LEFT

    # 기술
    tech_box = slide5.shapes.add_textbox(Inches(5), Inches(top + 0.1), Inches(3.2), Inches(0.75))
    tech_frame = tech_box.text_frame
    tech_p = tech_frame.paragraphs[0]
    tech_p.text = tech
    tech_p.font.size = Pt(14)
    tech_p.font.color.rgb = RGBColor(255, 255, 255)
    tech_p.alignment = PP_ALIGN.RIGHT

# ===== Slide 6: 사용자 역할 =====
slide6 = add_content_slide(prs, "사용자 역할 및 권한")

roles = [
    ("학부생", "검색, 예약\n이관 요청"),
    ("조교", "이관 승인\n상태 관리"),
    ("교수", "프로필 관리\n교과목 관리"),
    ("관리자", "전체 관리\n폐기 처리"),
    ("게스트", "검색, 조회\n내비게이션"),
    ("외부인", "제한된 검색")
]

for i, (role, perms) in enumerate(roles):
    row = i // 3
    col = i % 3
    left = 0.6 + col * 3.2
    top = 1.4 + row * 2.7

    # 역할 박스
    role_shape = slide6.shapes.add_shape(1, Inches(left), Inches(top), Inches(2.8), Inches(2.2))
    role_shape.fill.solid()
    role_shape.fill.fore_color.rgb = LIGHT_BG
    role_shape.line.color.rgb = SECONDARY_COLOR
    role_shape.line.width = Pt(3)

    # 역할명
    role_box = slide6.shapes.add_textbox(Inches(left + 0.15), Inches(top + 0.2), Inches(2.5), Inches(0.4))
    role_frame = role_box.text_frame
    role_p = role_frame.paragraphs[0]
    role_p.text = role
    role_p.font.size = Pt(16)
    role_p.font.bold = True
    role_p.font.color.rgb = SECONDARY_COLOR
    role_p.alignment = PP_ALIGN.CENTER

    # 권한
    perm_box = slide6.shapes.add_textbox(Inches(left + 0.15), Inches(top + 0.75), Inches(2.5), Inches(1.3))
    perm_frame = perm_box.text_frame
    perm_frame.word_wrap = True
    perm_p = perm_frame.paragraphs[0]
    perm_p.text = perms
    perm_p.font.size = Pt(11)
    perm_p.font.color.rgb = TEXT_COLOR
    perm_p.alignment = PP_ALIGN.CENTER

# ===== Slide 7: 기술 스택 =====
slide7 = add_content_slide(prs, "기술 스택 & 비기능 요구사항")

# Frontend
tech_sections = [
    ("Frontend", ["HTML5", "CSS3", "JavaScript"], 1.4),
    ("Backend", ["Java Servlet", "JSP", "MySQL"], 3.3),
    ("Server", ["Apache Tomcat 9.0", "UTF-8 Encoding"], 5.2)
]

for section_title, techs, left in tech_sections:
    # 섹션 제목
    section_box = slide7.shapes.add_textbox(Inches(left), Inches(1.4), Inches(2.8), Inches(0.4))
    section_frame = section_box.text_frame
    section_p = section_frame.paragraphs[0]
    section_p.text = section_title
    section_p.font.size = Pt(14)
    section_p.font.bold = True
    section_p.font.color.rgb = PRIMARY_COLOR

    # 기술들
    for i, tech in enumerate(techs):
        tech_tag = slide7.shapes.add_shape(1, Inches(left), Inches(2 + i * 0.6), Inches(2.8), Inches(0.45))
        tech_tag.fill.solid()
        tech_tag.fill.fore_color.rgb = PRIMARY_COLOR
        tech_tag.line.color.rgb = PRIMARY_COLOR

        tech_box = slide7.shapes.add_textbox(Inches(left + 0.1), Inches(2 + i * 0.6 + 0.05), Inches(2.6), Inches(0.35))
        tech_frame = tech_box.text_frame
        tech_p = tech_frame.paragraphs[0]
        tech_p.text = "• " + tech
        tech_p.font.size = Pt(12)
        tech_p.font.color.rgb = RGBColor(255, 255, 255)

# 비기능 요구사항
req_text = "응답시간 < 2초 | 동시사용자 100명 | 가용성 99% | 브라우저: Chrome/Firefox/Safari | WCAG 2.1 AA 준수"
add_text_content(slide7, req_text, 5.5, font_size=12)

# ===== Slide 8: 개발 일정 =====
slide8 = add_content_slide(prs, "개발 일정 & 타임라인")

timeline_items = [
    ("요구사항 분석\n& 설계", "기획, 데이터 모델, UI/UX"),
    ("백엔드 개발", "API, DB 연동"),
    ("프론트엔드 개발", "UI 구현"),
    ("통합 테스트\n& 배포", "Tomcat 배포")
]

for i, (phase, desc) in enumerate(timeline_items):
    left = 0.8 + i * 2.3

    # 단계 박스
    phase_shape = slide8.shapes.add_shape(1, Inches(left), Inches(2.2), Inches(2), Inches(1.5))
    phase_shape.fill.solid()
    phase_shape.fill.fore_color.rgb = PRIMARY_COLOR if i % 2 == 0 else SECONDARY_COLOR
    phase_shape.line.width = Pt(2)
    phase_shape.line.color.rgb = phase_shape.fill.fore_color.rgb

    # 단계명
    phase_box = slide8.shapes.add_textbox(Inches(left + 0.1), Inches(2.35), Inches(1.8), Inches(0.6))
    phase_frame = phase_box.text_frame
    phase_frame.word_wrap = True
    phase_p = phase_frame.paragraphs[0]
    phase_p.text = phase
    phase_p.font.size = Pt(13)
    phase_p.font.bold = True
    phase_p.font.color.rgb = RGBColor(255, 255, 255)
    phase_p.alignment = PP_ALIGN.CENTER

    # 설명
    desc_box = slide8.shapes.add_textbox(Inches(left + 0.1), Inches(3.1), Inches(1.8), Inches(0.5))
    desc_frame = desc_box.text_frame
    desc_frame.word_wrap = True
    desc_p = desc_frame.paragraphs[0]
    desc_p.text = desc
    desc_p.font.size = Pt(10)
    desc_p.font.color.rgb = RGBColor(255, 255, 255)
    desc_p.alignment = PP_ALIGN.CENTER

    # 화살표
    if i < len(timeline_items) - 1:
        arrow = slide8.shapes.add_textbox(Inches(left + 2.1), Inches(2.9), Inches(0.2), Inches(0.4))
        arrow_frame = arrow.text_frame
        arrow_p = arrow_frame.paragraphs[0]
        arrow_p.text = "→"
        arrow_p.font.size = Pt(24)
        arrow_p.font.color.rgb = TEXT_COLOR
        arrow_p.alignment = PP_ALIGN.CENTER

# 하단 설명
add_text_content(slide8, "각 단계별 병렬 진행으로 빠른 개발 주기 달성", 4.5, font_size=13)

# ===== Slide 9: 기대 효과 =====
slide9 = add_content_slide(prs, "기대 효과")

effects = [
    ("📊 데이터 통합", "분산된 시스템을\n중앙 집중식으로 통합"),
    ("⏱️ 효율성 향상", "자산 검색 시간\n50% 단축"),
    ("👥 사용자 만족도", "사용자 만족도\n80% 이상 달성"),
    ("📈 확장성", "모바일 앱, 추가 기능\n확장 가능한 구조"),
    ("🔍 감사 추적", "완전한 이력 추적으로\n투명성 확보"),
    ("🎓 학습 성과", "풀스택 개발 역량\n강화 및 팀 협업")
]

for i, (emoji_title, desc) in enumerate(effects):
    row = i // 3
    col = i % 3
    left = 0.6 + col * 3.2
    top = 1.4 + row * 2.8

    add_feature_box(slide9, emoji_title, desc, left, top, width=2.8, height=2.3)

# ===== Slide 10: 마무리 =====
slide10 = add_title_slide(prs, "감사합니다!", "질문이 있으신가요?")

# 프로젝트명 추가
project_box = slide10.shapes.add_textbox(Inches(0.5), Inches(5), Inches(9), Inches(1))
project_frame = project_box.text_frame
project_p = project_frame.paragraphs[0]
project_p.text = "ICT CAN - 캠퍼스 자산 관리 & 내비게이션 통합 시스템"
project_p.font.size = Pt(20)
project_p.font.color.rgb = RGBColor(255, 255, 255)
project_p.alignment = PP_ALIGN.CENTER

# 프레젠테이션 저장
output_path = "C:\\Program Files\\Apache Software Foundation\\Tomcat 9.0\\webapps\\CAN\\ICT_CAN_presentation.pptx"
prs.save(output_path)
import sys
sys.stdout.reconfigure(encoding='utf-8')
print("PPTX file created successfully!")
print(f"Location: {output_path}")
print(f"Total slides: {len(prs.slides)}")
