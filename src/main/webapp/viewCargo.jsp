<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserPojo, model.CargoPojo, java.util.List" %>
<%
    UserPojo currentUser = (UserPojo) session.getAttribute("user");
    if(currentUser == null){
        response.sendRedirect("login.jsp?msg=Please Login First");
        return;
    }
    String userName = currentUser.getName();
    String roleName = currentUser.getRoleName();
    List<CargoPojo> cargoList = (List<CargoPojo>) request.getAttribute("cargoList");
    if (cargoList == null) {
        response.sendRedirect("CargoServlet?action=viewAll");
        return;
    }
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>View Cargo | Port Management ERP</title>
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
            font-weight: 400; border-left: 3px solid transparent; transition: all 0.25s; margin: 1px 0;
        }
        .sidebar-nav a .nav-icon {
            width: 32px; height: 32px; border-radius: 8px; display: flex; align-items: center;
            justify-content: center; font-size: 0.95rem; background: rgba(255,255,255,0.05); flex-shrink: 0; transition: all 0.25s;
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

        /* BUTTONS */
        .btn-primary-teal {
            background: linear-gradient(135deg, var(--teal) 0%, var(--teal-light) 100%);
            color: white; border: none; padding: 10px 22px; border-radius: 10px;
            font-family: 'Poppins', sans-serif; font-size: 0.875rem; font-weight: 500;
            cursor: pointer; transition: all 0.25s; box-shadow: 0 4px 12px rgba(28,167,166,0.25);
            text-decoration: none; display: inline-flex; align-items: center; gap: 6px;
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
        .table tbody td { padding: 14px 18px; border-bottom: 1px solid #f1f5f9; vertical-align: middle; font-size: 0.875rem; }
        .table tbody tr:last-child td { border-bottom: none; }
        .table tbody tr { transition: background 0.15s; }
        .table tbody tr:hover td { background: #f8fbff; }

        /* ID CHIP */
        .id-chip {
            font-size: 0.8rem; font-weight: 700; color: var(--teal);
            background: rgba(28,167,166,0.08); padding: 4px 10px;
            border-radius: 6px; font-family: 'Courier New', monospace;
            border: 1px solid rgba(28,167,166,0.15);
        }
        .cont-chip {
            font-size: 0.78rem; font-weight: 600; color: var(--navy);
            background: rgba(11,61,92,0.06); padding: 3px 9px;
            border-radius: 6px; font-family: 'Courier New', monospace;
            border: 1px solid rgba(11,61,92,0.1);
        }

        /* STATUS PILLS */
        .status-pill {
            display: inline-flex; align-items: center; gap: 6px;
            padding: 5px 12px; border-radius: 20px; font-size: 0.72rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.04em;
        }
        .status-dot { width: 6px; height: 6px; border-radius: 50%; flex-shrink: 0; }
        .s-loaded { background: rgba(46,204,113,0.1); color: #15803d; }
        .s-loaded .status-dot { background: var(--success); }
        .s-transit { background: rgba(244,162,97,0.1); color: #c2410c; }
        .s-transit .status-dot { background: var(--warning); }
        .s-default { background: #f1f5f9; color: var(--muted); }
        .s-default .status-dot { background: #94a3b8; }

        /* ACTION BUTTONS */
        .action-group { display: flex; align-items: center; justify-content: center; gap: 6px; }
        .act-btn {
            width: 34px; height: 34px; border: none; border-radius: 9px;
            display: inline-flex; align-items: center; justify-content: center;
            font-size: 0.85rem; cursor: pointer; transition: all 0.2s;
            text-decoration: none;
        }
        .act-btn:hover { transform: translateY(-2px); }
        .act-move { background: rgba(28,167,166,0.1); color: var(--teal); }
        .act-move:hover { background: rgba(28,167,166,0.2); color: var(--teal); }
        .act-edit { background: rgba(244,162,97,0.1); color: #c2410c; }
        .act-edit:hover { background: rgba(244,162,97,0.2); color: #c2410c; }
        .act-delete { background: rgba(231,76,60,0.1); color: var(--danger); }
        .act-delete:hover { background: rgba(231,76,60,0.2); color: var(--danger); }

        /* SECTION HEADER */
        .section-header { display: flex; align-items: flex-end; justify-content: space-between; margin-bottom: 20px; }
        .section-title { font-size: 1.15rem; font-weight: 700; color: var(--navy); margin: 0; }
        .section-sub { font-size: 0.78rem; color: var(--muted); margin: 3px 0 0; }

        /* ALERT */
        .alert-info-custom {
            background: rgba(28,167,166,0.06); border: 1px solid rgba(28,167,166,0.2);
            color: var(--teal); border-radius: 12px; padding: 12px 18px;
            font-size: 0.85rem; display: flex; align-items: center; gap: 10px; margin-bottom: 24px;
        }

        /* MODAL */
        .modal-content { border: none; border-radius: 20px; box-shadow: 0 25px 60px rgba(0,0,0,0.15); overflow: hidden; }
        .modal-header-custom {
            background: linear-gradient(135deg, var(--navy) 0%, #164e72 100%);
            padding: 22px 28px; display: flex; align-items: center; justify-content: space-between; border: none;
        }
        .modal-header-custom .modal-title { color: white; font-size: 0.95rem; font-weight: 600; }
        .modal-header-custom .btn-close { filter: invert(1); opacity: 0.7; }
        .modal-body-custom { padding: 28px; }
        .modal-footer-custom { padding: 12px 28px 24px; display: flex; justify-content: flex-end; gap: 10px; border: none; }

        .form-label-custom { font-size: 0.72rem; font-weight: 600; text-transform: uppercase; letter-spacing: 0.06em; color: var(--muted); margin-bottom: 6px; display: block; }
        .form-control-custom {
            border: 1.5px solid var(--border); border-radius: 10px; padding: 10px 14px;
            font-size: 0.875rem; font-family: 'Poppins', sans-serif; background: #f8fafc;
            transition: all 0.2s; width: 100%; color: var(--text);
        }
        .form-control-custom:focus { outline: none; border-color: var(--teal); background: white; box-shadow: 0 0 0 4px rgba(28,167,166,0.1); }
        .form-control-custom[readonly] { background: #eef2f7; color: var(--muted); cursor: not-allowed; }
        .form-select-custom {
            border: 1.5px solid var(--border); border-radius: 10px; padding: 10px 14px;
            font-size: 0.875rem; font-family: 'Poppins', sans-serif; background: #f8fafc;
            transition: all 0.2s; width: 100%; color: var(--text); cursor: pointer;
        }
        .form-select-custom:focus { outline: none; border-color: var(--teal); box-shadow: 0 0 0 4px rgba(28,167,166,0.1); }

        .btn-cancel {
            background: #f1f5f9; color: var(--muted); border: none; padding: 10px 22px; border-radius: 10px;
            font-family: 'Poppins', sans-serif; font-size: 0.875rem; font-weight: 500; cursor: pointer; transition: all 0.2s;
        }
        .btn-cancel:hover { background: #e2e8f0; color: var(--text); }

        .divider-label {
            display: flex; align-items: center; gap: 10px; font-size: 0.68rem; font-weight: 600;
            text-transform: uppercase; letter-spacing: 0.08em; color: var(--muted); margin: 4px 0 16px;
        }
        .divider-label::before, .divider-label::after { content: ''; flex: 1; height: 1px; background: var(--border); }

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

<!-- SIDEBAR -->
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
        <a href="CargoServlet?action=viewAll" class="active">
            <div class="nav-icon"><i class="bi bi-box-seam-fill"></i></div>
            View Cargo Items
        </a>
        <a href="CargoMovementServlet?action=viewLog">
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

<!-- TOP NAV -->
<header class="top-navbar">
    <div class="page-title">
        Inventory Overview
        <span>All registered cargo records and statuses</span>
    </div>
    <div class="d-flex align-items-center gap-3">
        <button class="btn btn-sm btn-outline-secondary rounded-pill px-3" style="font-size: 0.8rem;" onclick="location.reload()">
            <i class="bi bi-arrow-clockwise me-1"></i> Refresh
        </button>
        <form action="LogoutServlet" method="post" class="m-0">
            <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3" style="font-size: 0.8rem;">
                <i class="bi bi-box-arrow-right me-1"></i> Logout
            </button>
        </form>
    </div>
</header>

<!-- MAIN -->
<main class="main-content">

    <% String msg = (String) request.getAttribute("msg");
       if(msg != null) { %>
        <div class="alert-info-custom">
            <i class="bi bi-info-circle-fill"></i> <%= msg %>
        </div>
    <% } %>

    <!-- Section Header -->
    <div class="section-header">
        <div>
            <h4 class="section-title">Cargo Items</h4>
            <p class="section-sub">Managing all registered cargo assignments</p>
        </div>
    </div>

    <!-- Search -->
    <div class="glass-card mb-4">
        <form action="CargoServlet" method="post">
            <input type="hidden" name="action" value="searchCargo">
            <div class="row g-3 align-items-center">
                <div class="col-md-10">
                    <div class="search-wrapper">
                        <i class="bi bi-search search-icon"></i>
                        <input type="text" name="query" class="search-input"
                               placeholder="Search by Cargo ID, Status, or Description...">
                    </div>
                </div>
                <div class="col-md-2">
                    <button type="submit" class="btn-primary-teal w-100" style="justify-content: center;">Search</button>
                </div>
            </div>
        </form>
    </div>

    <!-- Table -->
    <div class="table-wrapper">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th style="padding-left: 24px;">Cargo ID</th>
                        <th>Container</th>
                        <th>Description</th>
                        <th>Weight (T)</th>
                        <th>Status</th>
                        <th style="text-align: center;">Actions</th>
                    </tr>
                </thead>
               <tbody>
<%
    if(cargoList != null && !cargoList.isEmpty()) {
        for(CargoPojo cargo : cargoList) {
            String pillClass = "s-default";
            if("Loaded".equalsIgnoreCase(cargo.getStatus())) pillClass = "s-loaded";
            else if("In Transit".equalsIgnoreCase(cargo.getStatus())) pillClass = "s-transit";
%>
<tr>
    <td style="padding-left: 24px;">
        <span class="id-chip">#<%= cargo.getCargoId() %></span>
    </td>
    <td>
        <span class="cont-chip">CONT-<%= cargo.getContainerId() %></span>
    </td>
    <td>
        <div class="text-truncate" style="max-width: 300px; font-size: 0.85rem; color: var(--muted);"
             title="<%= cargo.getDescription() %>">
            <%= cargo.getDescription() %>
        </div>
    </td>
    <td>
        <span style="font-weight: 600; color: var(--navy);"><%= cargo.getWeight() %></span>
        <span style="font-size: 0.72rem; color: var(--muted);">t</span>
    </td>
    <td>
        <span class="status-pill <%= pillClass %>">
            <span class="status-dot"></span>
            <%= cargo.getStatus() %>
        </span>
    </td>
    <td>
        <div class="action-group">
            <button class="act-btn act-move" title="Log Movement" onclick="setMoveId('<%= cargo.getCargoId() %>')">
                <i class="bi bi-truck"></i>
            </button>
            <button class="act-btn act-edit" title="Edit" 
                    onclick="openEditModal('<%= cargo.getCargoId() %>', '<%= cargo.getContainerId() %>', '<%= cargo.getDescription() %>', '<%= cargo.getWeight() %>', '<%= cargo.getStatus() %>')">
                <i class="bi bi-pencil-square"></i>
            </button>
            <a href="CargoServlet?action=delete&cargoId=<%= cargo.getCargoId() %>" class="act-btn act-delete" onclick="return confirm('Delete record?')">
                <i class="bi bi-trash"></i>
            </a>
        </div>
    </td>
</tr>
<% } } else { %>
    <tr>
        <td colspan="6" class="text-center py-5">No cargo records found.</td>
    </tr>
<% } %>
</tbody>
            </table>
        </div>
        <div id="cargoPaginationBar" class="pagination-bar">
            <div class="pagination-info" id="cargoPaginationInfo"></div>
            <div class="pagination-controls" id="cargoPaginationControls"></div>
        </div>
    </div>

</main>

<!-- EDIT MODAL -->
<div class="modal fade" id="editModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="CargoServlet" method="post">
                <input type="hidden" name="action" value="update">
                <input type="hidden" name="cargoId" id="editCargoId">

                <div class="modal-header-custom">
                    <h5 class="modal-title"><i class="bi bi-pencil-square me-2"></i>Update Cargo Details</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body-custom">
                    <div class="row g-3">
                        <div class="col-12">
                            <label class="form-label-custom">Container ID</label>
                            <input type="text" name="containerId" id="editContId" class="form-control-custom" readonly>
                        </div>
                        <div class="col-12">
                            <div class="divider-label">Cargo Info</div>
                        </div>
                        <div class="col-12">
                            <label class="form-label-custom">Description</label>
                            <textarea name="description" id="editDesc" class="form-control-custom" rows="3" required style="resize: none;"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Weight (Tons)</label>
                            <input type="number" step="0.01" name="weight" id="editWeight" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Status</label>
                            <select name="status" id="editStatus" class="form-select-custom">
                                <option value="Loaded">Loaded</option>
                                <option value="In Transit">In Transit</option>
                                <option value="Unloaded">Unloaded</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer-custom">
                    <button type="button" class="btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-teal">
                        <i class="bi bi-check2 me-1"></i> Save Changes
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<!-- MOVEMENT MODAL -->
<div class="modal fade" id="movementModal" tabindex="-1">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="CargoMovementServlet" method="post">
                <input type="hidden" name="action" value="addCargoMovement">

                <div class="modal-header-custom">
                    <h5 class="modal-title"><i class="bi bi-truck me-2"></i>Log Cargo Movement</h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body-custom">
                    <div class="row g-3">
                        <div class="col-6">
                            <label class="form-label-custom">Cargo ID</label>
                            <input type="text" name="cargo_id" id="moveCargoId" class="form-control-custom" readonly>
                        </div>
                        <div class="col-6">
                            <label class="form-label-custom">Handler ID</label>
                            <input type="text" name="user_id" value="<%= currentUser.getUserId() %>" class="form-control-custom" readonly>
                        </div>
                        <div class="col-12">
                            <div class="divider-label">Movement Details</div>
                        </div>
                        <div class="col-12">
                            <label class="form-label-custom">Movement Type</label>
                            <select name="movement_type" class="form-select-custom" required>
                                <option value="Load">Load</option>
                                <option value="Unload">Unload</option>
                                <option value="Transfer">Transfer</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer-custom">
                    <button type="button" class="btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-teal">
                        <i class="bi bi-check2 me-1"></i> Record Movement
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    let editModalObj = new bootstrap.Modal(document.getElementById('editModal'));
    let movementModalObj = new bootstrap.Modal(document.getElementById('movementModal'));

    function openEditModal(id, cont, desc, weight, status) {
        document.getElementById('editCargoId').value = id;
        document.getElementById('editContId').value = cont;
        document.getElementById('editDesc').value = desc;
        document.getElementById('editWeight').value = weight;
        document.getElementById('editStatus').value = status;
        editModalObj.show();
    }

    function setMoveId(id) {
        document.getElementById('moveCargoId').value = id;
        movementModalObj.show();
    }

    (function() {
        const ROWS_PER_PAGE = 10;
        const tbody = document.querySelector('.table tbody');
        const rows = Array.from(tbody.querySelectorAll('tr')).filter(r => r.querySelectorAll('td').length > 1);
        const total = rows.length;
        const bar = document.getElementById('cargoPaginationBar');
        const info = document.getElementById('cargoPaginationInfo');
        const controls = document.getElementById('cargoPaginationControls');

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
            controls.appendChild(btn('‹ Prev', current === 1, () => showPage(current - 1)));
            let startP = Math.max(1, current - 2);
            let endP = Math.min(totalPages, startP + 4);
            if (endP - startP < 4) startP = Math.max(1, endP - 4);
            for (let p = startP; p <= endP; p++) {
                const b = btn(p, false, () => showPage(p));
                if (p === current) b.classList.add('active');
                controls.appendChild(b);
            }
            controls.appendChild(btn('Next ›', current === totalPages, () => showPage(current + 1)));
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
