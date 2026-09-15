# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**ICT CampusNav** — ICT폴리텍대학 교내 자원 내비게이션 시스템  
Campus resource navigation and asset management system with 8,401 assets, reservation, transfer tracking, and role-based access.

**Stack:** JSP + Java Servlets · Apache Tomcat 9.x · MySQL 8.x · Bootstrap 5.3.3 + Bootstrap Icons  
**Access URL:** `http://localhost:8080/CampusNav/campuslogin.jsp`

---

## Build & Compile

Servlet compilation is required only when `.java` files are modified. JSP changes take effect immediately without recompile or restart.

**Stop Tomcat before compiling** (otherwise `.class` write will fail).

```bat
:: Run from the CampusNav project root (double-click or cmd):
compile.bat
```

`compile.bat` auto-detects Tomcat 9 under `C:\Program Files\Apache Software Foundation\` and compiles:  
`LoginServlet`, `LogoutServlet`, `GuestServlet`, `VisitorServlet`

**Manual compile command** (from Tomcat root, admin cmd):
```
javac -encoding UTF-8 -cp "lib\servlet-api.jar" -d "webapps\CampusNav\WEB-INF\classes" ^
  "webapps\CampusNav\WEB-INF\src\com\campus\nav\LoginServlet.java" ^
  "webapps\CampusNav\WEB-INF\src\com\campus\nav\LogoutServlet.java" ^
  "webapps\CampusNav\WEB-INF\src\com\campus\nav\GuestServlet.java" ^
  "webapps\CampusNav\WEB-INF\src\com\campus\nav\VisitorServlet.java"
```

---

## Database Setup

MySQL `campusnav` db · `root` / `1234` · `localhost:3306`

Run SQL files **in order** (MySQL Workbench):
1. `nav.sql` (or split files if present): creates schema + 8 tables
2. Verify: `SELECT COUNT(*) FROM assets;` → must return 8401

Tables: `users`, `assets`, `asset_transfer`, `asset_disposal`, `reservations`, `professors`, `prof_subjects`, `prof_skills`

**JDBC JAR** — `mysql-connector-j-*.jar` must be in Tomcat's `lib/` folder, not in the project.

DBUtil (`WEB-INF/src/com/campus/nav/DBUtil.java`) provides shared `getConnection()` and `close()` — use it in all servlets instead of raw `DriverManager` calls.

---

## Architecture

### Request Flow

```
Browser → Tomcat
  ├── /login   → LoginServlet   → session setup → role-based redirect
  ├── /logout  → LogoutServlet  → session invalidate → campuslogin.jsp
  ├── /guest   → GuestServlet   → main_guest.jsp
  ├── /visitor → VisitorServlet → main_visitor.jsp
  └── *.jsp    → direct JDBC (no servlet intermediary)
```

### Role System

Session attributes set by `LoginServlet`: `loginUser`, `loginName`, `loginRole`

| Role | Value | Main page |
|------|-------|-----------|
| 학부생 | `student` | `main_student.jsp` |
| 조교 | `assistant` | `main_assistant.jsp` |
| 교수 | `professor` | `main_professor.jsp` |
| 관리자 | `admin` | `main_admin.jsp` |
| 게스트 | `guest` | `main_guest.jsp` |
| 외부인 | `visitor` | `main_visitor.jsp` |

Each JSP checks `session.getAttribute("loginRole")` to guard access and conditionally render admin-only UI elements.

### Servlet vs JSP Responsibility Split

- **Auth-only servlets** (registered in `web.xml`): `Login`, `Logout`, `Guest`, `Visitor`
- **All data pages** (`search.jsp`, `detail.jsp`, `reserve.jsp`, `transfer.jsp`, `professor.jsp`, etc.) query MySQL **directly via JDBC** inside the JSP — no servlet layer
- Several `.java` files exist in `src/` (`AssetServlet`, `SearchServlet`, `DetailServlet`, etc.) and are compiled to `classes/`, but are **not mapped in `web.xml`** and not actively used — JSPs handle those flows directly

### Key Files

| File | Purpose |
|------|---------|
| `campuslogin.jsp` | Login form + role quick-fill buttons |
| `register.jsp` | Self-registration (direct JDBC, no servlet) |
| `search.jsp` | Asset search with keyword/category/status filters, 20-per-page pagination |
| `detail.jsp` | Full asset info + transfer timeline + reservation status |
| `reserve.jsp` | Reservation with real-time duplicate check (AJAX) |
| `transfer.jsp` | Transfer history list + detail panel |
| `professor.jsp` | Professor cards with subject/skill tag management |
| `asset_manage.jsp` | Admin asset management |
| `floorNav.jsp` | Floor-based navigation view |
| `navigationTest1.jsp` | Navigation testing page |
| `WEB-INF/src/com/campus/nav/DBUtil.java` | Shared DB connection helper |
| `WEB-INF/web.xml` | Servlet-to-URL mappings, UTF-8 filter, session timeout (30 min) |
| `css/style.css` | Global styles (ppd4 theme: white base + blue accent, 15px base) |

---

## Known Issues / Active TODOs

- **LoginServlet currently uses a hardcoded credential array**, not the DB. Users registered via `register.jsp` cannot log in until `LoginServlet` is recompiled with the DB-lookup version (see `README.txt` §6 for the DB version code).
- `floorNav.jsp` uses `saveFloorRoute.jsp` / `deleteFloorRoute.jsp` / `getRoutes.jsp` for route persistence — these are standalone JSPs acting as mini-API endpoints.
- `detail.jsp` and `transfer.jsp` contain map placeholder divs for a future Google Maps integration (school coords: 37.396681, 127.247918).

---

## Deployment Steps

1. Run SQL files in order (DB setup)
2. Copy `CampusNav/` folder into Tomcat `webapps/`
3. Stop Tomcat → run `compile.bat` → restart Tomcat
4. Verify: `http://localhost:8080/CampusNav/campuslogin.jsp`
