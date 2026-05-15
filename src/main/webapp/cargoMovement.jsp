<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserPojo, model.CargoMovementPojo, java.util.List, java.text.SimpleDateFormat" %>
<%
    UserPojo currentUser = (UserPojo) session.getAttribute("user");
    if(currentUser == null){
        response.sendRedirect("login.jsp?msg=Please Login First");
        return;
    }
    String userName = currentUser.getName();
    String roleName = currentUser.getRoleName();
    List<CargoMovementPojo> movementList = (List<CargoMovementPojo>) request.getAttribute("movementList");
    if (movementList == null) {
        response.sendRedirect("CargoMovementServlet?action=viewLog");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Cargo Movement | Port Management ERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #0B3D5C;
            --navy-deep: #072d45;
            --teal: #1CA7A6;
            --teal-light: #22c2c1;
            --success: #2ECC71;
            --warning: #F4A261;
            --danger: #E74C3C;
            --bg: #F0F4F8;
            --white: #FFFFFF;
            --text: #1e293b;
            --muted: #64748b;
            --border: #e2e8f0;
            --sidebar-w: 268px;
        }

        * { box-sizing: border-box; }
        body { font-family: 'Poppins', sans-serif; background-color: var(--bg); color: var(--text); overflow-x: hidden; }

        /* SIDEBAR */
        .sidebar {
            height: 100vh; width: var(--sidebar-w);
            background: linear-gradient(180deg, var(--navy) 0%, var(--navy-deep) 100%);
            position: fixed; left: 0; top: 0; z-index: 1050;
            display: flex; flex-direction: column; overflow: hidden;
        }
        .sidebar::before {
            content: ''; position: absolute; top: -80px; right: -80px;
            width: 240px; height: 240px;
            background: radial-gradient(circle, rgba(28,167,166,0.18) 0%, transparent 70%);
            pointer-events: none;
        }
        .sidebar-brand {
            padding: 28px 24px 22px; display: flex; align-items: center; gap: 12px;
            text-decoration: none; border-bottom: 1px solid rgba(255,255,255,0.07);
        }
        .brand-icon {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            border-radius: 10px; display: flex; align-items: center; justify-content: center;
            font-size: 1.1rem; color: white; box-shadow: 0 4px 12px rgba(28,167,166,0.4); flex-shrink: 0;
        }
        .brand-text { font-size: 1.05rem; font-weight: 700; color: white; letter-spacing: 0.5px; line-height: 1.1; }
        .brand-sub { font-size: 0.65rem; color: rgba(255,255,255,0.4); font-weight: 400; letter-spacing: 1.5px; text-transform: uppercase; }

        .sidebar-section-label {
            font-size: 0.6rem; font-weight: 600; letter-spacing: 2px;
            text-transform: uppercase; color: rgba(255,255,255,0.25); padding: 20px 24px 8px;
        }
        .sidebar-nav a {
            display: flex; align-items: center; gap: 12px; padding: 11px 24px;
            color: rgba(255,255,255,0.55); text-decoration: none; font-size: 0.875rem;
            font-weight: 400; border-left: 3px solid transparent; transition: all 0.25s ease; margin: 1px 0;
        }
        .sidebar-nav a .nav-icon {
            width: 32px; height: 32px; border-radius: 8px;
            display: flex; align-items: center; justify-content: center;
            font-size: 0.95rem; background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.25s;
        }
        .sidebar-nav a:hover { color: white; border-left-color: rgba(28,167,166,0.5); background: rgba(255,255,255,0.04); }
        .sidebar-nav a:hover .nav-icon { background: rgba(28,167,166,0.15); color: var(--teal-light); }
        .sidebar-nav a.active { color: white; border-left-color: var(--teal); background: linear-gradient(90deg, rgba(28,167,166,0.15) 0%, transparent 100%); }
        .sidebar-nav a.active .nav-icon { background: var(--teal); color: white; box-shadow: 0 3px 10px rgba(28,167,166,0.4); }

        .sidebar-footer {
            margin: auto 16px 16px; background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.08); border-radius: 14px;
            padding: 14px 16px; display: flex; align-items: center; gap: 12px;
        }
        .avatar-circle {
            width: 38px; height: 38px; border-radius: 10px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 0.95rem; color: white; flex-shrink: 0;
            box-shadow: 0 3px 10px rgba(28,167,166,0.35);
        }
        .avatar-name { font-size: 0.82rem; font-weight: 600; color: white; line-height: 1.2; }
        .avatar-role { font-size: 0.68rem; color: var(--teal-light); opacity: 0.85; }

        /* TOP NAV */
        .top-navbar {
            margin-left: var(--sidebar-w); height: 70px; background: var(--white);
            border-bottom: 1px solid var(--border); display: flex; align-items: center;
            justify-content: space-between; padding: 0 36px; position: sticky; top: 0; z-index: 1040;
        }
        .page-title { font-size: 1.1rem; font-weight: 700; color: var(--navy); }
        .page-title span { font-size: 0.75rem; font-weight: 400; color: var(--muted); display: block; margin-top: 1px; }

        /* MAIN */
        .main-content { margin-left: var(--sidebar-w); padding: 32px 36px; min-height: calc(100vh - 70px); }

        /* GLASS CARD */
        .glass-card {
            background: var(--white); border-radius: 16px; border: 1px solid rgba(255,255,255,0.8);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05); padding: 24px;
        }

        /* SEARCH */
        .search-wrapper { position: relative; }
        .search-icon { position: absolute; left: 16px; top: 50%; transform: translateY(-50%); color: var(--muted); font-size: 0.9rem; z-index: 5; }
        .search-input {
            border: 1.5px solid var(--border); border-radius: 12px; padding: 11px 18px 11px 42px;
            font-size: 0.875rem; font-family: 'Poppins', sans-serif; background: #f8fafc;
            color: var(--text); transition: all 0.2s; width: 100%;
        }
        .search-input:focus { outline: none; border-color: var(--teal); background: white; box-shadow: 0 0 0 4px rgba(28,167,166,0.1); }

        /* BUTTON */
        .btn-primary-teal {
            background: linear-gradient(135deg, var(--teal) 0%, var(--teal-light) 100%);
            color: white; border: none; padding: 10px 22px; border-radius: 10px;
            font-family: 'Poppins', sans-serif; font-size: 0.875rem; font-weight: 500;
            cursor: pointer; transition: all 0.25s; box-shadow: 0 4px 12px rgba(28,167,166,0.25);
        }
        .btn-primary-teal:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(28,167,166,0.35); color: white; }

        /* TABLE */
        .table-wrapper {
            background: var(--white); border-radius: 16px; border: 1px solid var(--border);
            overflow: hidden; box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05);
        }
        .table { margin: 0; }
        .table thead th {
            background: #f8fafc; border-bottom: 1px solid var(--border); font-size: 0.68rem;
            font-weight: 600; text-transform: uppercase; letter-spacing: 0.08em;
            color: var(--muted); padding: 14px 18px; white-space: nowrap;
        }
        .table tbody td { padding: 14px 18px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; font-size: 0.85rem; }
        .table tbody tr:last-child td { border-bottom: none; }
        .table tbody tr:hover td { background: #f8fbff; }

        /* MOVEMENT TYPE PILL */
        .type-pill {
            display: inline-flex; align-items: center; gap: 7px;
            padding: 5px 12px; border-radius: 20px; font-size: 0.75rem; font-weight: 600;
        }
        .type-dot { width: 7px; height: 7px; border-radius: 50%; flex-shrink: 0; }
        .type-load { background: rgba(28,167,166,0.1); color: #0d7a7a; }
        .type-load .type-dot { background: var(--teal); }
        .type-unload { background: rgba(231,76,60,0.1); color: #b91c1c; }
        .type-unload .type-dot { background: var(--danger); }
        .type-transfer { background: rgba(244,162,97,0.1); color: #c2410c; }
        .type-transfer .type-dot { background: var(--warning); }

        /* MINI CHIPS */
        .mini-chip {
            display: inline-block; background: #f1f5f9; border: 1px solid var(--border);
            color: var(--muted); font-size: 0.72rem; font-weight: 600;
            padding: 3px 9px; border-radius: 6px; font-family: 'Courier New', monospace;
        }
        .mini-chip.teal { background: rgba(28,167,166,0.08); border-color: rgba(28,167,166,0.2); color: var(--teal); }

        /* INFO ROW WITHIN CELL */
        .meta-row { display: flex; align-items: center; gap: 6px; font-size: 0.75rem; color: var(--muted); margin-top: 3px; }
        .meta-row i { font-size: 0.7rem; }

        /* AVATAR TINY */
        .avatar-tiny {
            width: 24px; height: 24px; border-radius: 6px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            display: flex; align-items: center; justify-content: center;
            font-weight: 700; font-size: 0.65rem; color: white; flex-shrink: 0;
        }

        /* SECTION HEADER */
        .section-header { display: flex; align-items: flex-end; justify-content: space-between; margin-bottom: 20px; }
        .section-title { font-size: 1.15rem; font-weight: 700; color: var(--navy); margin: 0; line-height: 1.3; }
        .section-sub { font-size: 0.78rem; color: var(--muted); margin: 3px 0 0; }

        /* STATUS TEXT */
        .status-text { font-size: 0.72rem; font-weight: 600; color: var(--teal); text-transform: uppercase; letter-spacing: 0.05em; }

        /* CUSTOM BUTTON FOR ACTION */
        .btn-edit-movement {
            padding: 6px 12px;
            font-size: 0.75rem;
            font-weight: 600;
            border-radius: 8px;
            border: 1px solid var(--border);
            background: #fff;
            color: var(--navy);
            transition: all 0.2s;
        }
        .btn-edit-movement:hover {
            background: var(--navy);
            color: #fff;
            border-color: var(--navy);
        }

        /* PAGINATION */
        .pagination-bar {
            display: flex; align-items: center; justify-content: space-between;
            padding: 16px 24px; border-top: 1px solid var(--border);
            background: #fafcff;
        }
        .pagination-info { font-size: 0.78rem; color: var(--muted); }
        .pagination-controls { display: flex; align-items: center; gap: 4px; }
        .pg-btn {
            min-width: 34px; height: 34px; padding: 0 10px;
            border: 1px solid var(--border); border-radius: 8px;
            background: white; color: var(--text); font-size: 0.78rem;
            font-family: 'Poppins', sans-serif; font-weight: 500;
            cursor: pointer; transition: all 0.2s; display: inline-flex;
            align-items: center; justify-content: center;
        }
        .pg-btn:hover:not(:disabled) { border-color: var(--teal); color: var(--teal); background: rgba(28,167,166,0.05); }
        .pg-btn.active { background: var(--teal); color: white; border-color: var(--teal); font-weight: 600; }
        .pg-btn:disabled { opacity: 0.4; cursor: not-allowed; }
    </style>
</head>
<body>

<aside class="sidebar">
    <a href="dashboard.jsp" class="sidebar-brand">
        <div class="brand-icon"><i class="bi bi-ship"></i></div>
        <div>
            <div class="brand-text">PORT ERP</div>
            <div class="brand-sub">Maritime Ops</div>
        </div>
    </a>
    <div class="sidebar-section-label">Navigation</div>
    <nav class="sidebar-nav">
        <a href="dashboard.jsp">
            <div class="nav-icon"><i class="bi bi-grid-1x2-fill"></i></div>
            Cargo Management
        </a>
        <a href="CargoServlet?action=viewAll">
            <div class="nav-icon"><i class="bi bi-box-seam-fill"></i></div>
            View Cargo Items
        </a>
        <a href="CargoMovementServlet?action=viewLog" class="active">
            <div class="nav-icon"><i class="bi bi-truck"></i></div>
            Cargo Movement
        </a>
        <a href="profile.jsp">
            <div class="nav-icon"><i class="bi bi-gear-wide-connected"></i></div>
            Profile & Settings
        </a>
    </nav>
    <div class="sidebar-footer">
        <div class="avatar-circle">
            <%= (userName != null && !userName.isEmpty()) ? userName.substring(0,1).toUpperCase() : "U" %>
        </div>
        <div>
            <div class="avatar-name"><%= userName %></div>
            <div class="avatar-role"><%= roleName %></div>
        </div>
    </div>
</aside>

<header class="top-navbar">
    <div class="page-title">
        Movement Tracking
        <span>Real-time log of all cargo transitions</span>
    </div>
    <div class="d-flex align-items-center gap-3">
        <a href="CargoMovementServlet?action=viewLog" class="btn btn-sm btn-outline-secondary rounded-pill px-3" style="font-size: 0.8rem; text-decoration: none;">
            <i class="bi bi-arrow-clockwise me-1"></i> Refresh
        </a>
        <form action="LogoutServlet" method="post" class="m-0">
            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3" style="font-size: 0.8rem;">
                <i class="bi bi-box-arrow-right me-1"></i> Logout
            </button>
        </form>
    </div>
</header>

<main class="main-content">
<% if(request.getAttribute("msg") != null) { %>
    <div class="alert alert-info alert-dismissible fade show mx-4 mt-3" role="alert">
        <%= request.getAttribute("msg") %>
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
    </div>
<% } %>
  <div class="section-header">
        <div>
            <h4 class="section-title">Transfer History</h4>
            <p class="section-sub">Complete audit trail of all cargo movements</p>
        </div>
    </div>

    <div class="table-wrapper">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th style="padding-left: 24px;">Log</th>
                        <th>Cargo & Goods</th>
                        <th>Logistics Chain</th>
                        <th>Action & Status</th>
                        <th>Timestamp & Handler</th>
                        <th>Manage</th>
                    </tr>
                </thead>
               <tbody>
<%
    if(movementList != null && !movementList.isEmpty()) {
        for(CargoMovementPojo m : movementList) {
            String pillClass = "type-transfer";
            if("Load".equalsIgnoreCase(m.getMovementType())) pillClass = "type-load";
            else if("Unload".equalsIgnoreCase(m.getMovementType())) pillClass = "type-unload";
%>
<tr>
    <td style="padding-left: 24px;">
        <span class="mini-chip">#<%= m.getMovementId() %></span>
    </td>

    <td>
        <div class="fw-bold" style="font-size: 0.85rem; color: var(--navy);">
            CARGO-<%= m.getCargoId() %>
        </div>
        <div class="text-truncate" style="max-width: 200px; font-size: 0.78rem; color: var(--muted); margin-top: 2px;"
             title="<%= m.getDescription() %>">
            <%= m.getDescription() != null ? m.getDescription() : "N/A" %>
        </div>
        <div class="meta-row" style="margin-top: 4px;">
            <i class="bi bi-box-seam"></i>
            <span style="font-weight: 600; color: var(--text);"><%= m.getWeight() %> Tons</span>
        </div>
    </td>

    <td>
        <span class="mini-chip teal mb-1 d-inline-block">CONT-<%= m.getContainerId() %></span>
        <div class="meta-row"><i class="bi bi-ship"></i> Ship: <strong style="color: var(--text);">SHP-<%= m.getShipId() %></strong></div>
        <div class="meta-row"><i class="bi bi-person-badge"></i> Op: <strong style="color: var(--text);">OP-<%= m.getOperatorId() %></strong></div>
    </td>

    <td>
        <span class="type-pill <%= pillClass %>">
            <span class="type-dot"></span>
            <%= m.getMovementType() %>
        </span>
        <div style="margin-top: 6px;">
            <span style="font-size: 0.68rem; text-transform: uppercase; color: var(--muted); letter-spacing: 0.05em;">
                Status:&nbsp;
            </span>
            <span class="status-text"><%= m.getStatus() %></span>
        </div>
    </td>

    <td>
        <div style="margin-bottom: 6px;">
<%
    if (m.getMovementDate() != null) {
        SimpleDateFormat timeF = new SimpleDateFormat("hh:mm a");
        SimpleDateFormat dateF = new SimpleDateFormat("MM/dd/yyyy");
%>
            <div style="font-size: 0.85rem; font-weight: 700; color: var(--navy); line-height: 1.3;">
                <i class="bi bi-clock me-1"></i><%= timeF.format(m.getMovementDate()) %>
            </div>
            <div style="font-size: 0.75rem; color: var(--muted); margin-top: 2px;">
                <i class="bi bi-calendar3 me-1"></i><%= dateF.format(m.getMovementDate()) %>
            </div>
<% } else { %>
            <span style="font-size: 0.8rem; color: var(--muted);">N/A</span>
<% } %>
        </div>
        <div style="display: flex; align-items: center; gap: 7px;">
            <div class="avatar-tiny">
                ID
            </div>
            <div>
                <div style="font-size: 0.78rem; color: var(--text); font-weight: 600; line-height: 1.2;">
                    Handler ID: <%= m.getHandledBy() %>
                </div>
                <div style="font-size: 0.68rem; color: var(--muted);">Authorized Personnel</div>
            </div>
        </div>
    </td>
    <td>
        <button type="button" class="btn-edit-movement" onclick="openMovementForm('<%= m.getCargoId() %>')">
            <i class="bi bi-pencil-square me-1"></i> Edit
        </button>
    </td>
</tr>
<%
        }
    } else {
%>
<tr>
    <td colspan="6" style="text-align: center; padding: 70px 20px; color: var(--muted);">
        <i class="bi bi-clipboard-x display-4 d-block mb-3" style="color: #cbd5e1;"></i>
        <div style="font-size: 0.95rem; font-weight: 500;">No cargo movement history found.</div>
        <div style="font-size: 0.8rem; margin-top: 4px;">Refresh the page or record a new movement.</div>
    </td>
</tr>
<% } %>
</tbody>
            </table>
        </div>
        <div id="movPaginationBar" class="pagination-bar">
            <div class="pagination-info" id="movPaginationInfo"></div>
            <div class="pagination-controls" id="movPaginationControls"></div>
        </div>
    </div>

</main>

<div id="movementModal" style="display:none; position: fixed; top: 50%; left: 50%; transform: translate(-50%, -50%); background: white; padding: 30px; border-radius: 16px; box-shadow: 0 10px 40px rgba(0,0,0,0.15); z-index: 1000; width: 350px; border: 1px solid var(--border);">
    <div class="d-flex justify-content-between align-items-center mb-3">
        <h5 style="margin: 0; font-weight: 700; color: var(--navy);">Update Movement</h5>
        <button type="button" class="btn-close" onclick="closeMovementForm()" style="font-size: 0.8rem;"></button>
    </div>
    <form action="CargoMovementServlet" method="post">
        <input type="hidden" name="action" value="addCargoMovement">
        <input type="hidden" id="modal_cargo_id" name="cargo_id">
        <input type="hidden" name="handled_by" value="<%= currentUser.getUserId() %>">
        
        <div style="margin-bottom: 20px;">
            <label style="display: block; margin-bottom: 8px; font-size: 0.8rem; font-weight: 600; color: var(--muted);">SELECT MOVEMENT TYPE</label>
            <select name="movement_type" class="form-select" style="font-size: 0.9rem; border-radius: 10px;" required>
                <option value="Load">Load (Entry)</option>
                <option value="Unload">Unload (Exit)</option>
                <option value="Transfer">Transfer (Internal)</option>
            </select>
        </div>
        
        <div class="d-grid">
            <button type="submit" class="btn-primary-teal">Confirm & Sync Status</button>
        </div>
    </form>
</div>

<div id="overlay" onclick="closeMovementForm()" style="display:none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(11, 61, 92, 0.2); backdrop-filter: blur(2px); z-index: 999;"></div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
function openMovementForm(id) {
    document.getElementById('modal_cargo_id').value = id;
    document.getElementById('movementModal').style.display = 'block';
    document.getElementById('overlay').style.display = 'block';
}

function closeMovementForm() {
    document.getElementById('movementModal').style.display = 'none';
    document.getElementById('overlay').style.display = 'none';
}

(function() {
    const ROWS_PER_PAGE = 10;
    const tbody = document.querySelector('.table tbody');
    const rows = Array.from(tbody.querySelectorAll('tr')).filter(r => r.querySelectorAll('td').length > 1);
    const total = rows.length;
    const bar = document.getElementById('movPaginationBar');
    const info = document.getElementById('movPaginationInfo');
    const controls = document.getElementById('movPaginationControls');

    if (total <= ROWS_PER_PAGE) { bar.style.display = 'none'; return; }

    let current = 1;
    const totalPages = Math.ceil(total / ROWS_PER_PAGE);

    function showPage(page) {
        current = page;
        const start = (page - 1) * ROWS_PER_PAGE;
        const end = start + ROWS_PER_PAGE;
        rows.forEach((r, i) => r.style.display = (i >= start && i < end) ? '' : 'none');
        info.textContent = 'Showing ' + (start + 1) + '–' + Math.min(end, total) + ' of ' + total + ' records';
        renderControls();
    }

    function renderControls() {
        controls.innerHTML = '';
        const prevBtn = btn('‹ Prev', current === 1, () => showPage(current - 1));
        controls.appendChild(prevBtn);

        let startP = Math.max(1, current - 2);
        let endP = Math.min(totalPages, startP + 4);
        if (endP - startP < 4) startP = Math.max(1, endP - 4);

        for (let p = startP; p <= endP; p++) {
            const b = btn(p, false, () => showPage(p));
            if (p === current) b.classList.add('active');
            controls.appendChild(b);
        }

        const nextBtn = btn('Next ›', current === totalPages, () => showPage(current + 1));
        controls.appendChild(nextBtn);
    }

    function btn(label, disabled, onClick) {
        const b = document.createElement('button');
        b.className = 'pg-btn'; b.innerHTML = label; b.disabled = disabled;
        if (!disabled) b.addEventListener('click', onClick);
        return b;
    }

    showPage(1);
})();
</script>
</body>
</html>