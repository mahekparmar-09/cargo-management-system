<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.ContainerPojo, java.util.List" %>
<%@ page import="model.UserPojo" %>
<%@ page import="model.CargoPojo" %>
<%
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);

    UserPojo currentUser = (UserPojo) session.getAttribute("user");
    if(currentUser == null){
        response.sendRedirect("login.jsp?msg=Please Login First");
        return;
    }
    
    List<ContainerPojo> containerList = (List<ContainerPojo>) request.getAttribute("containerList");

    if(containerList == null) {
        response.sendRedirect("ContainerServlet?action=viewAll");
        return;
    }

    String userName = currentUser.getName();
    String roleName = currentUser.getRoleName();

    int totalContainers = containerList.size();
    int emptyContainers = 0, loadedContainers = 0, inTransitContainers = 0;
    for (ContainerPojo c : containerList) {
        String cs = c.getStatus() == null ? "" : c.getStatus().toLowerCase();
        if (cs.equals("empty"))      emptyContainers++;
        else if (cs.equals("loaded")) loadedContainers++;
        else if (cs.contains("transit")) inTransitContainers++;
    }
    CargoPojo cargoPojo = new CargoPojo();
    List<CargoPojo> allCargo = null;
    int totalCargo = 0, loadedCargo = 0, unloadedCargo = 0, inTransitCargo = 0, pendingCargo = 0;
    try {
        allCargo = cargoPojo.getAllCargo(currentUser);
        if (allCargo != null) {
            totalCargo = allCargo.size();
            for (CargoPojo cargo : allCargo) {
                String st = cargo.getStatus() == null ? "" : cargo.getStatus().toLowerCase();
                if      (st.equals("loaded"))    loadedCargo++;
                else if (st.equals("unloaded"))  unloadedCargo++;
                else if (st.contains("transit")) inTransitCargo++;
            }
            pendingCargo = inTransitCargo;
        }
    } catch (Exception ignored) {}
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard | Port Management ERP</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --navy: #0B3D5C;
            --navy-deep: #072d45;
            --teal: #1CA7A6;
            --teal-light: #22c2c1;
            --teal-glow: rgba(28, 167, 166, 0.15);
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

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--bg);
            color: var(--text);
            overflow-x: hidden;
        }

        /* ── SIDEBAR ── */
        .sidebar {
            height: 100vh;
            width: var(--sidebar-w);
            background: linear-gradient(180deg, var(--navy) 0%, var(--navy-deep) 100%);
            position: fixed;
            left: 0; top: 0;
            z-index: 1050;
            display: flex;
            flex-direction: column;
            overflow: hidden;
        }

        .sidebar::before {
            content: '';
            position: absolute;
            top: -80px; right: -80px;
            width: 240px; height: 240px;
            background: radial-gradient(circle, rgba(28,167,166,0.18) 0%, transparent 70%);
            pointer-events: none;
        }

        .sidebar::after {
            content: '';
            position: absolute;
            bottom: 120px; left: -60px;
            width: 180px; height: 180px;
            background: radial-gradient(circle, rgba(28,167,166,0.1) 0%, transparent 70%);
            pointer-events: none;
        }

        .sidebar-brand {
            padding: 28px 24px 22px;
            display: flex;
            align-items: center;
            gap: 12px;
            text-decoration: none;
            border-bottom: 1px solid rgba(255,255,255,0.07);
        }

        .brand-icon {
            width: 40px; height: 40px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            color: white;
            box-shadow: 0 4px 12px rgba(28,167,166,0.4);
            flex-shrink: 0;
        }

        .brand-text {
            font-size: 1.05rem;
            font-weight: 700;
            color: white;
            letter-spacing: 0.5px;
            line-height: 1.1;
        }

        .brand-sub {
            font-size: 0.65rem;
            color: rgba(255,255,255,0.4);
            font-weight: 400;
            letter-spacing: 1.5px;
            text-transform: uppercase;
        }

        .sidebar-section-label {
            font-size: 0.6rem;
            font-weight: 600;
            letter-spacing: 2px;
            text-transform: uppercase;
            color: rgba(255,255,255,0.25);
            padding: 20px 24px 8px;
        }

        .sidebar-nav a {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 11px 24px;
            color: rgba(255,255,255,0.55);
            text-decoration: none;
            font-size: 0.875rem;
            font-weight: 400;
            border-left: 3px solid transparent;
            transition: all 0.25s ease;
            margin: 1px 0;
            position: relative;
        }

        .sidebar-nav a .nav-icon {
            width: 32px; height: 32px;
            border-radius: 8px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 0.95rem;
            background: rgba(255,255,255,0.05);
            flex-shrink: 0;
            transition: all 0.25s ease;
        }

        .sidebar-nav a:hover {
            color: white;
            border-left-color: rgba(28,167,166,0.5);
            background: rgba(255,255,255,0.04);
        }

        .sidebar-nav a:hover .nav-icon {
            background: rgba(28,167,166,0.15);
            color: var(--teal-light);
        }

        .sidebar-nav a.active {
            color: white;
            border-left-color: var(--teal);
            background: linear-gradient(90deg, rgba(28,167,166,0.15) 0%, transparent 100%);
        }

        .sidebar-nav a.active .nav-icon {
            background: var(--teal);
            color: white;
            box-shadow: 0 3px 10px rgba(28,167,166,0.4);
        }

        .sidebar-footer {
            margin: auto 16px 16px;
            background: rgba(255,255,255,0.05);
            border: 1px solid rgba(255,255,255,0.08);
            border-radius: 14px;
            padding: 14px 16px;
            display: flex;
            align-items: center;
            gap: 12px;
        }

        .avatar-circle {
            width: 38px; height: 38px;
            border-radius: 10px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            display: flex;
            align-items: center;
            justify-content: center;
            font-weight: 700;
            font-size: 0.95rem;
            color: white;
            flex-shrink: 0;
            box-shadow: 0 3px 10px rgba(28,167,166,0.35);
        }

        .avatar-name {
            font-size: 0.82rem;
            font-weight: 600;
            color: white;
            line-height: 1.2;
        }

        .avatar-role {
            font-size: 0.68rem;
            color: var(--teal-light);
            opacity: 0.85;
        }

        /* ── TOP NAV ── */
        .top-navbar {
            margin-left: var(--sidebar-w);
            height: 70px;
            background: var(--white);
            border-bottom: 1px solid var(--border);
            display: flex;
            align-items: center;
            justify-content: space-between;
            padding: 0 36px;
            position: sticky;
            top: 0;
            z-index: 1040;
        }

        .page-title {
            font-size: 1.1rem;
            font-weight: 700;
            color: var(--navy);
        }

        .page-title span {
            font-size: 0.75rem;
            font-weight: 400;
            color: var(--muted);
            display: block;
            margin-top: 1px;
        }

        /* ── MAIN ── */
        .main-content {
            margin-left: var(--sidebar-w);
            padding: 32px 36px;
            min-height: calc(100vh - 70px);
        }

        /* ── GLASS CARD ── */
        .glass-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid rgba(255,255,255,0.8);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05);
            padding: 24px;
            transition: box-shadow 0.25s ease;
        }

        .glass-card:hover {
            box-shadow: 0 2px 6px rgba(0,0,0,0.05), 0 12px 32px rgba(0,0,0,0.08);
        }

        /* ── SEARCH BAR ── */
        .search-wrapper {
            position: relative;
        }

        .search-icon {
            position: absolute;
            left: 16px;
            top: 50%;
            transform: translateY(-50%);
            color: var(--muted);
            font-size: 0.9rem;
            z-index: 5;
        }

        .search-input {
            border: 1.5px solid var(--border);
            border-radius: 12px;
            padding: 11px 18px 11px 42px;
            font-size: 0.875rem;
            font-family: 'Poppins', sans-serif;
            background: #f8fafc;
            color: var(--text);
            transition: all 0.2s;
            width: 100%;
        }

        .search-input:focus {
            outline: none;
            border-color: var(--teal);
            background: white;
            box-shadow: 0 0 0 4px rgba(28,167,166,0.1);
        }

        /* ── BUTTON ── */
        .btn-primary-teal {
            background: linear-gradient(135deg, var(--teal) 0%, var(--teal-light) 100%);
            color: white;
            border: none;
            padding: 10px 22px;
            border-radius: 10px;
            font-family: 'Poppins', sans-serif;
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.25s ease;
            box-shadow: 0 4px 12px rgba(28,167,166,0.25);
        }

        .btn-primary-teal:hover {
            transform: translateY(-2px);
            box-shadow: 0 6px 18px rgba(28,167,166,0.35);
            color: white;
        }

        .btn-primary-teal:active {
            transform: translateY(0);
        }

        /* ── TABLE ── */
        .table-wrapper {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            overflow: hidden;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05);
        }

        .table { margin: 0; }

        .table thead th {
            background: #f8fafc;
            border-bottom: 1px solid var(--border);
            font-size: 0.7rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--muted);
            padding: 14px 20px;
            white-space: nowrap;
        }

        .table tbody td {
            padding: 16px 20px;
            border-bottom: 1px solid #f1f5f9;
            vertical-align: middle;
            font-size: 0.875rem;
        }

        .table tbody tr:last-child td { border-bottom: none; }

        .table tbody tr {
            transition: background 0.15s ease;
        }

        .table tbody tr:hover td {
            background: #f8fbff;
        }

        /* ── STATUS BADGES ── */
        .status-pill {
            display: inline-flex;
            align-items: center;
            gap: 6px;
            padding: 5px 12px;
            border-radius: 20px;
            font-size: 0.75rem;
            font-weight: 600;
        }

        .status-dot {
            width: 6px; height: 6px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .status-empty {
            background: rgba(46, 204, 113, 0.1);
            color: #15803d;
        }

        .status-empty .status-dot { background: var(--success); }

        .status-loaded {
            background: rgba(244, 162, 97, 0.1);
            color: #c2410c;
        }

        .status-loaded .status-dot { background: var(--warning); }

        .status-default {
            background: #f1f5f9;
            color: var(--muted);
        }

        .status-default .status-dot { background: #94a3b8; }

        /* ── CONTAINER ID CHIP ── */
        .id-chip {
            font-size: 0.82rem;
            font-weight: 700;
            color: var(--navy);
            background: rgba(11, 61, 92, 0.06);
            padding: 4px 10px;
            border-radius: 6px;
            font-family: 'Courier New', monospace;
        }

        /* ── ENGAGED BADGE ── */
        .engaged-badge {
            display: inline-flex;
            align-items: center;
            gap: 5px;
            background: #f1f5f9;
            color: var(--muted);
            border: 1px solid var(--border);
            padding: 5px 12px;
            border-radius: 8px;
            font-size: 0.75rem;
            font-weight: 500;
        }

        /* ── SECTION HEADER ── */
        .section-header {
            display: flex;
            align-items: flex-end;
            justify-content: space-between;
            margin-bottom: 20px;
        }

        .section-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--navy);
            margin: 0;
            line-height: 1.3;
        }

        .section-sub {
            font-size: 0.78rem;
            color: var(--muted);
            margin: 3px 0 0;
        }

        /* ── ALERT ── */
        .alert-success-custom {
            background: rgba(46,204,113,0.08);
            border: 1px solid rgba(46,204,113,0.25);
            color: #15803d;
            border-radius: 12px;
            padding: 14px 18px;
            font-size: 0.875rem;
            display: flex;
            align-items: center;
            gap: 10px;
            margin-bottom: 24px;
        }

        /* ── MODAL ── */
        .modal-content {
            border: none;
            border-radius: 20px;
            box-shadow: 0 25px 60px rgba(0,0,0,0.15);
            overflow: hidden;
        }

        .modal-header-custom {
            background: linear-gradient(135deg, var(--navy) 0%, #164e72 100%);
            padding: 24px 28px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            border: none;
        }

        .modal-header-custom .modal-title {
            color: white;
            font-size: 1rem;
            font-weight: 600;
        }

        .modal-header-custom .btn-close {
            filter: invert(1);
            opacity: 0.7;
        }

        .modal-body-custom {
            padding: 28px;
        }

        .form-label-custom {
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.06em;
            color: var(--muted);
            margin-bottom: 6px;
            display: block;
        }

        .form-control-custom {
            border: 1.5px solid var(--border);
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 0.875rem;
            font-family: 'Poppins', sans-serif;
            background: #f8fafc;
            transition: all 0.2s;
            width: 100%;
            color: var(--text);
        }

        .form-control-custom:focus {
            outline: none;
            border-color: var(--teal);
            background: white;
            box-shadow: 0 0 0 4px rgba(28,167,166,0.1);
        }

        .form-control-custom[readonly] {
            background: #eef2f7;
            color: var(--muted);
            cursor: not-allowed;
        }

        .form-select-custom {
            border: 1.5px solid var(--border);
            border-radius: 10px;
            padding: 10px 14px;
            font-size: 0.875rem;
            font-family: 'Poppins', sans-serif;
            background: #f8fafc;
            transition: all 0.2s;
            width: 100%;
            color: var(--text);
            cursor: pointer;
        }

        .form-select-custom:focus {
            outline: none;
            border-color: var(--teal);
            box-shadow: 0 0 0 4px rgba(28,167,166,0.1);
        }

        .modal-footer-custom {
            padding: 16px 28px 24px;
            display: flex;
            justify-content: flex-end;
            gap: 10px;
            border: none;
        }

        .btn-cancel {
            background: #f1f5f9;
            color: var(--muted);
            border: none;
            padding: 10px 22px;
            border-radius: 10px;
            font-family: 'Poppins', sans-serif;
            font-size: 0.875rem;
            font-weight: 500;
            cursor: pointer;
            transition: all 0.2s;
        }

        .btn-cancel:hover {
            background: #e2e8f0;
            color: var(--text);
        }

        /* ── DIVIDER ── */
        .divider-label {
            display: flex;
            align-items: center;
            gap: 10px;
            font-size: 0.72rem;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.08em;
            color: var(--muted);
            margin: 6px 0 16px;
        }

        .divider-label::before, .divider-label::after {
            content: '';
            flex: 1;
            height: 1px;
            background: var(--border);
        }

        /* ── STAT CARDS ── */
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(4, 1fr);
            gap: 16px;
            margin-bottom: 24px;
        }

        @media (max-width: 1200px) { .stats-grid { grid-template-columns: repeat(2, 1fr); } }
        @media (max-width: 768px)  { .stats-grid { grid-template-columns: repeat(2, 1fr); } }

        .stat-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            padding: 20px 22px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 4px 16px rgba(0,0,0,0.04);
            display: flex;
            flex-direction: column;
            gap: 14px;
            transition: transform 0.2s ease, box-shadow 0.2s ease;
            position: relative;
            overflow: hidden;
        }

        .stat-card::before {
            content: '';
            position: absolute;
            top: 0; left: 0; right: 0;
            height: 3px;
            border-radius: 16px 16px 0 0;
        }

        .stat-card:hover {
            transform: translateY(-3px);
            box-shadow: 0 4px 6px rgba(0,0,0,0.06), 0 12px 28px rgba(0,0,0,0.09);
        }

        .stat-card.total::before  { background: linear-gradient(90deg, var(--navy), #1a6ea0); }
        .stat-card.loaded::before { background: linear-gradient(90deg, var(--warning), #f9c74f); }
        .stat-card.unloaded::before { background: linear-gradient(90deg, var(--success), #52d68a); }
        .stat-card.transit::before  { background: linear-gradient(90deg, var(--teal), var(--teal-light)); }
        .stat-card.pending::before  { background: linear-gradient(90deg, var(--danger), #ff7b7b); }

        .stat-top {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .stat-icon {
            width: 40px; height: 40px;
            border-radius: 10px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.1rem;
            flex-shrink: 0;
        }

        .stat-card.total .stat-icon   { background: rgba(11,61,92,0.08);  color: var(--navy); }
        .stat-card.loaded .stat-icon  { background: rgba(244,162,97,0.12); color: #c2410c; }
        .stat-card.unloaded .stat-icon{ background: rgba(46,204,113,0.12); color: #15803d; }
        .stat-card.transit .stat-icon { background: var(--teal-glow);      color: var(--teal); }
        .stat-card.pending .stat-icon { background: rgba(231,76,60,0.1);   color: var(--danger); }

        .stat-badge {
            font-size: 0.65rem;
            font-weight: 600;
            padding: 3px 8px;
            border-radius: 20px;
            letter-spacing: 0.04em;
        }

        .stat-card.total   .stat-badge { background: rgba(11,61,92,0.06);   color: var(--navy); }
        .stat-card.loaded  .stat-badge { background: rgba(244,162,97,0.12); color: #c2410c; }
        .stat-card.unloaded .stat-badge{ background: rgba(46,204,113,0.12); color: #15803d; }
        .stat-card.transit .stat-badge { background: var(--teal-glow);      color: var(--teal); }
        .stat-card.pending .stat-badge { background: rgba(231,76,60,0.1);   color: var(--danger); }

        .stat-number {
            font-size: 2rem;
            font-weight: 700;
            color: var(--text);
            line-height: 1;
            letter-spacing: -0.02em;
        }

        .stat-label {
            font-size: 0.75rem;
            color: var(--muted);
            font-weight: 500;
            margin-top: 2px;
        }

        /* ── OVERVIEW CARD ── */
        .overview-card {
            background: var(--white);
            border-radius: 16px;
            border: 1px solid var(--border);
            padding: 24px 28px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05);
            margin-bottom: 24px;
        }

        .overview-header {
            display: flex;
            align-items: center;
            justify-content: space-between;
            margin-bottom: 22px;
        }

        .overview-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--navy);
        }

        .overview-sub {
            font-size: 0.72rem;
            color: var(--muted);
            margin-top: 2px;
        }

        .overview-total-badge {
            font-size: 0.7rem;
            font-weight: 600;
            background: rgba(11,61,92,0.06);
            color: var(--navy);
            padding: 5px 12px;
            border-radius: 20px;
        }

        .progress-row {
            display: flex;
            flex-direction: column;
            gap: 14px;
        }

        .progress-item {
            display: flex;
            flex-direction: column;
            gap: 6px;
        }

        .progress-meta {
            display: flex;
            align-items: center;
            justify-content: space-between;
        }

        .progress-label {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.8rem;
            font-weight: 500;
            color: var(--text);
        }

        .progress-dot {
            width: 8px; height: 8px;
            border-radius: 50%;
            flex-shrink: 0;
        }

        .progress-count {
            font-size: 0.75rem;
            font-weight: 700;
            color: var(--muted);
        }

        .progress-track {
            height: 8px;
            background: #f1f5f9;
            border-radius: 99px;
            overflow: hidden;
        }

        .progress-fill {
            height: 100%;
            border-radius: 99px;
            transition: width 0.8s cubic-bezier(0.4,0,0.2,1);
        }

        .fill-loaded   { background: linear-gradient(90deg, var(--warning), #f9c74f); }
        .fill-unloaded { background: linear-gradient(90deg, var(--success), #52d68a); }
        .fill-transit  { background: linear-gradient(90deg, var(--teal), var(--teal-light)); }
        .fill-pending  { background: linear-gradient(90deg, var(--danger), #ff7b7b); }

        .overview-two-col {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 20px;
            align-items: center;
        }

        @media (max-width: 900px) { .overview-two-col { grid-template-columns: 1fr; } }

        .donut-wrap {
            display: flex;
            align-items: center;
            justify-content: center;
            position: relative;
        }

        .donut-center-label {
            position: absolute;
            display: flex;
            flex-direction: column;
            align-items: center;
            justify-content: center;
            gap: 0;
        }

        .donut-num {
            font-size: 1.6rem;
            font-weight: 700;
            color: var(--navy);
            line-height: 1;
        }

        .donut-sub {
            font-size: 0.6rem;
            color: var(--muted);
            text-transform: uppercase;
            letter-spacing: 0.08em;
            font-weight: 600;
        }

        .legend-grid {
            display: grid;
            grid-template-columns: 1fr 1fr;
            gap: 10px 16px;
        }

        .legend-item {
            display: flex;
            align-items: center;
            gap: 8px;
            font-size: 0.78rem;
        }

        .legend-swatch {
            width: 10px; height: 10px;
            border-radius: 3px;
            flex-shrink: 0;
        }

        .legend-name  { color: var(--muted); font-weight: 400; }
        .legend-value { font-weight: 700; color: var(--text); margin-left: auto; }

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

<!-- ════════════════ SIDEBAR ════════════════ -->
<aside class="sidebar">
    <a href="#" class="sidebar-brand">
        <div class="brand-icon"><i class="bi bi-ship"></i></div>
        <div>
            <div class="brand-text">PORT ERP</div>
            <div class="brand-sub">Maritime Ops</div>
        </div>
    </a>

    <div class="sidebar-section-label">Navigation</div>

    <nav class="sidebar-nav">
        <a href="dashboard.jsp" class="active">
            <div class="nav-icon"><i class="bi bi-grid-1x2-fill"></i></div>
            Cargo Management
        </a>
        <a href="CargoServlet?action=viewAll">
            <div class="nav-icon"><i class="bi bi-box-seam-fill"></i></div>
            View Cargo Items
        </a>
        <a href="CargoMovementServlet?action=viewLog">
            <div class="nav-icon"><i class="bi bi-arrow-left-right"></i></div>
            Cargo Movement
        </a>
        <a href="profile.jsp">
            <div class="nav-icon"><i class="bi bi-gear-wide-connected"></i></div>
            Profile & Settings
        </a>
    </nav>

    <div class="sidebar-footer">
        <div class="avatar-circle">
            <%= userName != null ? userName.substring(0,1).toUpperCase() : "U" %>
        </div>
        <div>
            <div class="avatar-name"><%= userName %></div>
            <div class="avatar-role"><%= roleName %></div>
        </div>
    </div>
</aside>

<!-- ════════════════ TOP NAV ════════════════ -->
<header class="top-navbar">
    <div class="page-title">
        Cargo Handling Center
        <span>Manage containers and cargo assignments</span>
    </div>
    <div class="d-flex align-items-center gap-3">
        <a href="ContainerServlet" class="btn btn-sm btn-outline-secondary rounded-pill px-3" style="font-size: 0.8rem; text-decoration: none;">
            <i class="bi bi-arrow-clockwise me-1"></i> Refresh
        </a>
        <form action="LogoutServlet" method="post" class="m-0">
            <button class="btn btn-sm btn-outline-danger rounded-pill px-3" style="font-size: 0.8rem;">
                <i class="bi bi-box-arrow-right me-1"></i> Logout
            </button>
        </form>
    </div>
</header>

<!-- ════════════════ MAIN CONTENT ════════════════ -->
<main class="main-content">

    <% String dashMsg = (String) request.getAttribute("msg");
       if (dashMsg == null) dashMsg = (String) session.getAttribute("msg");
       if (dashMsg != null) { session.removeAttribute("msg"); %>
        <div class="alert-success-custom">
            <i class="bi bi-check2-circle fs-5"></i>
            <%= dashMsg %>
        </div>
    <% } %>

    <!-- ── STAT CARDS ── -->
    <div class="stats-grid">
        <div class="stat-card total">
            <div class="stat-top">
                <div class="stat-icon"><i class="bi bi-boxes"></i></div>
                <span class="stat-badge">All Items</span>
            </div>
            <div>
                <div class="stat-number"><%= totalCargo %></div>
                <div class="stat-label">Total Cargo</div>
            </div>
        </div>
        <div class="stat-card loaded">
            <div class="stat-top">
                <div class="stat-icon"><i class="bi bi-box-seam-fill"></i></div>
                <span class="stat-badge">Active</span>
            </div>
            <div>
                <div class="stat-number"><%= loadedCargo %></div>
                <div class="stat-label">Loaded Cargo</div>
            </div>
        </div>
        <div class="stat-card unloaded">
            <div class="stat-top">
                <div class="stat-icon"><i class="bi bi-box-arrow-down"></i></div>
                <span class="stat-badge">Cleared</span>
            </div>
            <div>
                <div class="stat-number"><%= unloadedCargo %></div>
                <div class="stat-label">Unloaded Cargo</div>
            </div>
        </div>
        <div class="stat-card transit">
            <div class="stat-top">
                <div class="stat-icon"><i class="bi bi-arrow-repeat"></i></div>
                <span class="stat-badge">Moving</span>
            </div>
            <div>
                <div class="stat-number"><%= inTransitCargo %></div>
                <div class="stat-label">In Transit</div>
            </div>
        </div>
    </div>

    <!-- Search -->
    <div class="glass-card mb-4">
    <form action="ContainerServlet" method="post">
        <input type="hidden" name="action" value="searchContainer">
        <div class="row g-3 align-items-center">
            <div class="col-md-9">
                <div class="search-wrapper">
                    <i class="bi bi-search search-icon"></i>
                    <input type="text" name="query" class="search-input" 
                           placeholder="Search by ID, Type, or Status..." 
                           value="<%= request.getParameter("query") != null ? request.getParameter("query") : "" %>">
                </div>
            </div>
            <div class="col-md-3">
                <button type="submit" class="btn-primary-teal w-100">Search Containers</button>
            </div>
        </div>
    </form>
</div>

    <!-- Section Header -->
    <div class="section-header">
        <div>
            <h4 class="section-title">Unoccupied Containers</h4>
            <p class="section-sub">Available containers ready for cargo assignment</p>
        </div>
        <a href="CargoServlet?action=viewAll" class="btn-primary-teal text-decoration-none d-inline-flex align-items-center gap-2">
            <i class="bi bi-list-ul"></i> Inventory Log
        </a>
    </div>

    <!-- Table -->
    <div class="table-wrapper">
        <div class="table-responsive">
            <table class="table table-hover">
                <thead>
                    <tr>
                        <th style="padding-left: 28px;">Container ID</th>
                        <th>Type</th>
                        <th>Status</th>
                        <th style="text-align: right; padding-right: 28px;">Action</th>
                    </tr>
                </thead>
                <tbody>
                <%
                    if(containerList != null && !containerList.isEmpty()) {
                        for(ContainerPojo c : containerList) {
                            String pillClass = "status-default";
                            if("Empty".equalsIgnoreCase(c.getStatus())) pillClass = "status-empty";
                            else if("Loaded".equalsIgnoreCase(c.getStatus())) pillClass = "status-loaded";
                %>
                <tr>
                    <td style="padding-left: 28px;">
                        <span class="id-chip">#<%= c.getContainerId() %></span>
                    </td>
                    <td style="color: var(--muted); font-size: 0.875rem;"><%= c.getContainerType() %></td>
                    <td>
                        <span class="status-pill <%= pillClass %>">
                            <span class="status-dot"></span>
                            <%= c.getStatus() %>
                        </span>
                    </td>
                    <td style="text-align: right; padding-right: 28px;">
                        <% if("Empty".equalsIgnoreCase(c.getStatus())) { %>
                            <button class="btn-primary-teal btn-sm"
                                    onclick="openAddModal('<%= c.getContainerId() %>')"
                                    data-bs-toggle="modal" data-bs-target="#addCargoModal"
                                    style="padding: 7px 16px; font-size: 0.8rem;">
                                <i class="bi bi-plus-lg me-1"></i> Add Cargo
                            </button>
                        <% } else { %>
                            <span class="engaged-badge">
                                <i class="bi bi-lock-fill" style="font-size: 0.7rem;"></i> Engaged
                            </span>
                        <% } %>
                    </td>
                </tr>
                <%
                        }
                    } else {
                %>
                <tr>
                    <td colspan="4" style="text-align: center; padding: 60px 20px; color: var(--muted);">
                        <i class="bi bi-inbox display-4 d-block mb-3" style="color: #cbd5e1;"></i>
                        No maritime containers found.
                    </td>
                </tr>
                <% } %>
                </tbody>
            </table>
        </div>
        <div id="dashPaginationBar" class="pagination-bar">
            <div class="pagination-info" id="dashPaginationInfo"></div>
            <div class="pagination-controls" id="dashPaginationControls"></div>
        </div>
    </div>

</main>

<!-- ════════════════ ADD CARGO MODAL ════════════════ -->
<div class="modal fade" id="addCargoModal" tabindex="-1" aria-hidden="true">
    <div class="modal-dialog modal-dialog-centered">
        <div class="modal-content">
            <form action="CargoServlet" method="post">
                <input type="hidden" name="action" value="add">

                <div class="modal-header-custom">
                    <h5 class="modal-title">
                        <i class="bi bi-plus-circle me-2"></i> New Cargo Assignment
                    </h5>
                    <button type="button" class="btn-close" data-bs-dismiss="modal"></button>
                </div>

                <div class="modal-body-custom">
                    <div class="row g-3">
                        <div class="col-md-6">
                            <label class="form-label-custom">Cargo ID</label>
                            <input type="text" name="cargoId" placeholder="GEN-001" class="form-control-custom" readonly>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Container ID</label>
                            <input type="text" id="modalContainerId" name="containerId" class="form-control-custom" readonly>
                        </div>
                        <div class="col-12">
                            <div class="divider-label">Cargo Details</div>
                        </div>
                        <div class="col-12">
                            <label class="form-label-custom">Description</label>
                            <textarea name="description" placeholder="Specify cargo contents and details..." class="form-control-custom" rows="3" required style="resize: none;"></textarea>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Weight (Tons)</label>
                            <input type="number" step="0.01" name="weight" placeholder="0.00" class="form-control-custom" required>
                        </div>
                        <div class="col-md-6">
                            <label class="form-label-custom">Status</label>
                            <select name="status" class="form-select-custom">
                                <option value="Loaded">Loaded</option>
                                <option value="Unloaded">Unloaded</option>
                                <option value="In Transit">In Transit</option>
                            </select>
                        </div>
                    </div>
                </div>

                <div class="modal-footer-custom">
                    <button type="button" class="btn-cancel" data-bs-dismiss="modal">Cancel</button>
                    <button type="submit" class="btn-primary-teal">
                        <i class="bi bi-check2 me-1"></i> Confirm Assignment
                    </button>
                </div>
            </form>
        </div>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
<script>
    function openAddModal(contId) {
        document.getElementById('modalContainerId').value = contId;
    }

    (function() {
        const ROWS_PER_PAGE = 10;
        const tbody = document.querySelector('.table tbody');
        const rows = Array.from(tbody.querySelectorAll('tr')).filter(r => r.querySelectorAll('td').length > 1);
        const total = rows.length;
        const bar = document.getElementById('dashPaginationBar');
        const info = document.getElementById('dashPaginationInfo');
        const controls = document.getElementById('dashPaginationControls');

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
