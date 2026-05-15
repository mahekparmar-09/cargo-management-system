<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserPojo" %>
<%
    UserPojo currentUser = (UserPojo) session.getAttribute("user");
    if(currentUser == null){
        response.sendRedirect("login.jsp?msg=Please Login First");
        return;
    }
    String userName = currentUser.getName();
    String userEmail = currentUser.getEmail();
    String roleName = currentUser.getRoleName();
    int userId = currentUser.getUserId();

    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Profile & Settings | Port ERP</title>
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

        /* PROFILE HERO */
        .profile-hero {
            background: linear-gradient(135deg, var(--navy) 0%, #1a5f8a 50%, #0f4a6e 100%);
            border-radius: 20px;
            padding: 36px 40px;
            margin-bottom: 28px;
            display: flex;
            align-items: center;
            gap: 28px;
            position: relative;
            overflow: hidden;
            box-shadow: 0 10px 30px rgba(11,61,92,0.2);
        }
        .profile-hero::before {
            content: '';
            position: absolute;
            top: -60px; right: -60px;
            width: 220px; height: 220px;
            background: radial-gradient(circle, rgba(28,167,166,0.2) 0%, transparent 65%);
            pointer-events: none;
        }
        .profile-hero::after {
            content: '';
            position: absolute;
            bottom: -40px; right: 200px;
            width: 150px; height: 150px;
            background: radial-gradient(circle, rgba(255,255,255,0.04) 0%, transparent 70%);
            pointer-events: none;
        }

        .hero-avatar {
            width: 86px; height: 86px;
            background: linear-gradient(135deg, var(--teal), var(--teal-light));
            border-radius: 20px;
            display: flex; align-items: center; justify-content: center;
            font-size: 2.2rem; font-weight: 700; color: white;
            box-shadow: 0 8px 24px rgba(28,167,166,0.4);
            border: 3px solid rgba(255,255,255,0.15);
            flex-shrink: 0;
            position: relative; z-index: 1;
        }

        .hero-info { position: relative; z-index: 1; }
        .hero-name { font-size: 1.6rem; font-weight: 700; color: white; line-height: 1.2; margin: 0 0 6px; }
        .hero-role {
            display: inline-flex; align-items: center; gap: 7px;
            background: rgba(28,167,166,0.2); border: 1px solid rgba(28,167,166,0.3);
            color: var(--teal-light); padding: 5px 14px; border-radius: 20px;
            font-size: 0.8rem; font-weight: 500; margin-bottom: 8px;
        }
        .hero-id { font-size: 0.75rem; color: rgba(255,255,255,0.4); }

        /* STAT PILLS in hero */
        .hero-stats {
            margin-left: auto;
            position: relative; z-index: 1;
            display: flex; flex-direction: column; gap: 8px; align-items: flex-end;
        }
        .stat-pill {
            background: rgba(255,255,255,0.06);
            border: 1px solid rgba(255,255,255,0.1);
            border-radius: 10px; padding: 8px 16px;
            font-size: 0.75rem; color: rgba(255,255,255,0.7);
            display: flex; align-items: center; gap: 8px;
        }
        .stat-pill i { color: var(--teal-light); }
        .stat-pill strong { color: white; font-weight: 600; }

        /* CARDS */
        .card-section {
            background: var(--white); border-radius: 16px;
            border: 1px solid var(--border);
            box-shadow: 0 1px 3px rgba(0,0,0,0.04), 0 8px 24px rgba(0,0,0,0.05);
            overflow: hidden;
        }
        .card-section-header {
            padding: 20px 26px; border-bottom: 1px solid var(--border);
            display: flex; align-items: center; gap: 12px;
        }
        .card-section-icon {
            width: 36px; height: 36px;
            background: rgba(28,167,166,0.1); border-radius: 10px;
            display: flex; align-items: center; justify-content: center;
            color: var(--teal); font-size: 1rem;
        }
        .card-section-title { font-size: 0.95rem; font-weight: 700; color: var(--navy); margin: 0; }
        .card-section-body { padding: 26px; }

        /* INFO GRID */
        .info-item { margin-bottom: 20px; }
        .info-item:last-child { margin-bottom: 0; }
        .info-label {
            font-size: 0.68rem; font-weight: 600; text-transform: uppercase;
            letter-spacing: 0.08em; color: var(--muted); margin-bottom: 5px;
        }
        .info-value { font-size: 0.92rem; color: var(--navy); font-weight: 500; }

        /* DIVIDER */
        .section-divider {
            height: 1px; background: var(--border); margin: 22px 0;
        }
        .update-label {
            font-size: 0.82rem; font-weight: 600; color: var(--navy); margin-bottom: 14px;
        }

        /* FORM ELEMENTS */
        .form-field-wrapper { position: relative; }
        .field-icon {
            position: absolute; left: 14px; top: 50%; transform: translateY(-50%);
            color: var(--muted); font-size: 0.9rem; pointer-events: none; z-index: 5;
        }
        .form-input {
            border: 1.5px solid var(--border); border-radius: 10px;
            padding: 10px 14px 10px 40px;
            font-size: 0.875rem; font-family: 'Poppins', sans-serif;
            background: #f8fafc; color: var(--text); transition: all 0.2s; width: 100%;
        }
        .form-input:focus { outline: none; border-color: var(--teal); background: white; box-shadow: 0 0 0 4px rgba(28,167,166,0.1); }

        .form-input-plain {
            border: 1.5px solid var(--border); border-radius: 10px;
            padding: 10px 14px;
            font-size: 0.875rem; font-family: 'Poppins', sans-serif;
            background: #f8fafc; color: var(--text); transition: all 0.2s; width: 100%;
        }
        .form-input-plain:focus { outline: none; border-color: var(--teal); background: white; box-shadow: 0 0 0 4px rgba(28,167,166,0.1); }
        .form-label-custom {
            font-size: 0.72rem; font-weight: 600; text-transform: uppercase;
            letter-spacing: 0.06em; color: var(--muted); margin-bottom: 6px; display: block;
        }

        /* BUTTONS */
        .btn-primary-teal {
            background: linear-gradient(135deg, var(--teal) 0%, var(--teal-light) 100%);
            color: white; border: none; padding: 10px 22px; border-radius: 10px;
            font-family: 'Poppins', sans-serif; font-size: 0.875rem; font-weight: 500;
            cursor: pointer; transition: all 0.25s; box-shadow: 0 4px 12px rgba(28,167,166,0.25);
        }
        .btn-primary-teal:hover { transform: translateY(-2px); box-shadow: 0 6px 18px rgba(28,167,166,0.35); color: white; }

        .btn-navy {
            background: var(--navy); color: white; border: none; padding: 12px 22px; border-radius: 10px;
            font-family: 'Poppins', sans-serif; font-size: 0.875rem; font-weight: 500;
            cursor: pointer; transition: all 0.25s; box-shadow: 0 4px 12px rgba(11,61,92,0.2); width: 100%;
        }
        .btn-navy:hover { background: #0d4e73; transform: translateY(-2px); box-shadow: 0 6px 18px rgba(11,61,92,0.3); color: white; }

        /* ALERT */
        .alert-custom {
            border-radius: 12px; padding: 12px 18px; font-size: 0.85rem;
            display: flex; align-items: center; gap: 10px; margin-bottom: 24px;
            border: 1px solid;
        }
        .alert-success-c { background: rgba(46,204,113,0.08); border-color: rgba(46,204,113,0.25); color: #15803d; }
        .alert-danger-c { background: rgba(231,76,60,0.08); border-color: rgba(231,76,60,0.25); color: #b91c1c; }

        /* INFO BANNER */
        .info-banner {
            background: rgba(28,167,166,0.06); border: 1px solid rgba(28,167,166,0.2);
            border-radius: 10px; padding: 11px 16px; font-size: 0.8rem; color: var(--teal);
            display: flex; align-items: center; gap: 8px; margin-bottom: 20px;
        }

        /* ROLE BADGE */
        .role-badge {
            display: inline-flex; align-items: center; gap: 6px;
            background: rgba(28,167,166,0.08); border: 1px solid rgba(28,167,166,0.2);
            color: var(--teal); padding: 4px 12px; border-radius: 20px;
            font-size: 0.78rem; font-weight: 600;
        }

        /* ACTIVE STATUS */
        .active-status {
            display: inline-flex; align-items: center; gap: 6px;
            font-size: 0.85rem; color: #15803d; font-weight: 500;
        }
        .active-dot { width: 7px; height: 7px; background: var(--success); border-radius: 50%; animation: pulse 2s infinite; }
        @keyframes pulse {
            0%, 100% { opacity: 1; transform: scale(1); }
            50% { opacity: 0.6; transform: scale(0.85); }
        }
    </style>
</head>
<body>

<!-- SIDEBAR -->
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
        <a href="dashboard.jsp">
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
        <a href="profile.jsp" class="active">
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
<!-- TOP NAV -->
<header class="top-navbar">
    <div class="page-title">
        User Settings
        <span>Manage your account and security preferences</span>
    </div>
    <form action="LogoutServlet" method="post" class="m-0">
        <button type="submit" class="btn btn-sm btn-outline-danger rounded-pill px-3" style="font-size: 0.8rem;">
            <i class="bi bi-box-arrow-right me-1"></i> Logout
        </button>
    </form>
</header>

<!-- MAIN -->
<main class="main-content">

    <% String msg = (String) session.getAttribute("profileMsg");
       if (msg != null) {
           session.removeAttribute("profileMsg");
           String alertCls = msg.toLowerCase().contains("success") ? "alert-success-c" : "alert-danger-c";
           String icon = msg.toLowerCase().contains("success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill";
    %>
        <div class="alert-custom <%= alertCls %>">
            <i class="bi <%= icon %>"></i> <%= msg %>
        </div>
    <% } %>

    <!-- Profile Hero -->
    <div class="profile-hero">
        <div class="hero-avatar">
            <%= (userName != null && !userName.isEmpty()) ? userName.substring(0,1).toUpperCase() : "U" %>
        </div>
        <div class="hero-info">
            <h2 class="hero-name"><%= userName %></h2>
            <div class="hero-role">
                <i class="bi bi-shield-check" style="font-size: 0.85rem;"></i>
                <%= roleName %>
            </div>
            <div class="hero-id">User ID: #<%= userId %> &nbsp;·&nbsp; <%= userEmail %></div>
        </div>
        <div class="hero-stats">
            <div class="stat-pill">
                <i class="bi bi-envelope-fill"></i>
                <strong><%= userEmail %></strong>
            </div>
            <div class="stat-pill">
                <i class="bi bi-circle-fill text-success" style="font-size: 0.5rem;"></i>
                <strong>Active Session</strong>
            </div>
        </div>
    </div>

    <div class="row g-4">

        <!-- Account Details -->
        <div class="col-md-7">
            <div class="card-section">
                <div class="card-section-header">
                    <div class="card-section-icon"><i class="bi bi-person-vcard"></i></div>
                    <h5 class="card-section-title">Account Details</h5>
                </div>
                <div class="card-section-body">
                    <div class="row">
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Full Name</div>
                                <div class="info-value"><%= userName %></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Email Address</div>
                                <div class="info-value" style="font-size: 0.85rem;"><%= userEmail %></div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">Current Role</div>
                                <div class="info-value">
                                    <span class="role-badge"><i class="bi bi-shield-fill-check" style="font-size: 0.75rem;"></i> <%= roleName %></span>
                                </div>
                            </div>
                        </div>
                        <div class="col-md-6">
                            <div class="info-item">
                                <div class="info-label">System Access</div>
                                <div class="info-value">
                                    <span class="active-status">
                                        <span class="active-dot"></span>
                                        Active Status
                                    </span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <div class="section-divider"></div>
<div class="update-label"><i class="bi bi-pencil me-2" style="color: var(--teal);"></i>Update Display Name</div>

<form action="UserServlet" method="post">
    <input type="hidden" name="action" value="updateProfile">
    <div class="row g-3 align-items-end">
        <div class="col-md-8">
            <div class="form-field-wrapper">
                <i class="bi bi-person field-icon"></i>
                <input type="text" name="name" class="form-input" value="<%= userName %>" required>
            </div>
        </div>
        <div class="col-md-4">
            <button type="submit" class="btn-primary-teal w-100">
                <i class="bi bi-check2 me-1"></i> Update
            </button>
        </div>
    </div>
</form>

<div class="section-divider"></div>
<div class="update-label"><i class="bi bi-envelope me-2" style="color: var(--teal);"></i>Update Email Address</div>

<form action="UserServlet" method="post">
    <input type="hidden" name="action" value="updateEmail">
    <div class="row g-3 align-items-end">
        <div class="col-md-8">
            <div class="form-field-wrapper">
                <i class="bi bi-envelope field-icon"></i>
                <input type="email" name="newEmail" class="form-input" value="<%= userEmail %>" required>
            </div>
        </div>
        <div class="col-md-4">
            <button type="submit" class="btn-primary-teal w-100">
                <i class="bi bi-check2 me-1"></i> Update
            </button>
        </div>
    </div>
</form>
                </div>
            </div>
        </div>

        <!-- Security -->
        <div class="col-md-5">
            <div class="card-section">
                <div class="card-section-header">
                    <div class="card-section-icon"><i class="bi bi-shield-lock"></i></div>
                    <h5 class="card-section-title">Security Management</h5>
                </div>
                <div class="card-section-body">
                    <div class="info-banner">
                        <i class="bi bi-info-circle"></i>
                        Update your password regularly for account security.
                    </div>

                    <form action="UserServlet" method="post">
                        <input type="hidden" name="action" value="changePassword">
                        <div class="mb-3">
                            <label class="form-label-custom">Current Password</label>
                            <input type="password" name="oldPassword" class="form-input-plain" placeholder="••••••••" required>
                        </div>
                        <div class="mb-3">
                            <label class="form-label-custom">New Password</label>
                            <input type="password" name="newPassword" class="form-input-plain" placeholder="••••••••" required>
                        </div>
                        <div class="mb-4">
                            <label class="form-label-custom">Confirm New Password</label>
                            <input type="password" name="confirmPassword" class="form-input-plain" placeholder="••••••••" required>
                        </div>
                        <button type="submit" class="btn-navy">
                            <i class="bi bi-shield-lock me-2"></i> Change Password
                        </button>
                    </form>
                </div>
            </div>
        </div>

    </div>
</main>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
