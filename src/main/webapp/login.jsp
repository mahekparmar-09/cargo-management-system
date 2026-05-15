<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ page import="model.UserPojo" %>
<%
    UserPojo currentUser = (UserPojo) session.getAttribute("user");
    if(currentUser != null) {
        response.sendRedirect("dashboard.jsp");
        return;
    }
    response.setHeader("Cache-Control", "no-cache, no-store, must-revalidate");
    response.setHeader("Pragma", "no-cache");
    response.setDateHeader("Expires", 0);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login | Port ERP System</title>

    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@300;400;600&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.11.1/font/bootstrap-icons.css">

    <style>
        :root {
            --primary-navy: #0B3D5C;
            --secondary-teal: #1CA7A6;
            --accent-soft: #F5F7FA;
        }

        body {
            font-family: 'Poppins', sans-serif;
            background-color: var(--accent-soft);
            height: 100vh;
            margin: 0;
            display: flex;
            align-items: center;
            justify-content: center;
        }

        .login-wrapper {
            width: 100%;
            max-width: 900px;
            background: #fff;
            border-radius: 20px;
            overflow: hidden;
            box-shadow: 0 15px 35px rgba(0,0,0,0.1);
            display: flex;
            min-height: 500px;
        }

        .login-brand-side {
            flex: 1;
            background: linear-gradient(135deg, var(--primary-navy) 0%, #082d44 100%);
            color: white;
            padding: 40px;
            display: flex;
            flex-direction: column;
            justify-content: center;
            position: relative;
        }

        .login-brand-side::after {
            content: "";
            position: absolute;
            top: 0; left: 0; width: 100%; height: 100%;
            background: url('https://images.unsplash.com/photo-1524522173746-f628baad3644?auto=format&fit=crop&q=80&w=1000') center/cover;
            opacity: 0.15;
            z-index: 0;
        }

        .brand-content { position: relative; z-index: 1; }

        .login-form-side {
            flex: 1;
            padding: 50px;
            display: flex;
            flex-direction: column;
            justify-content: center;
        }

        .form-control {
            border-radius: 10px;
            padding: 12px 15px;
            border: 1px solid #e0e0e0;
            background-color: #fcfcfc;
        }

        .form-control:focus {
            border-color: var(--secondary-teal);
            box-shadow: 0 0 0 0.25rem rgba(28, 167, 166, 0.1);
        }

        .btn-login {
            background-color: var(--secondary-teal);
            color: white;
            border: none;
            border-radius: 10px;
            padding: 12px;
            font-weight: 600;
            transition: 0.3s;
        }

        .btn-login:hover {
            background-color: #168d8c;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(28, 167, 166, 0.3);
        }

        .alert-custom {
            border-radius: 10px;
            font-size: 0.9rem;
            border: none;
        }

        @media (max-width: 768px) {
            .login-brand-side { display: none; }
            .login-wrapper { max-width: 400px; }
        }
    </style>
</head>
<body>

<div class="login-wrapper">
    <div class="login-brand-side">
        <div class="brand-content">
            <h1 class="fw-bold mb-3"><i class="bi bi-ship"></i> PORT ERP</h1>
            <p class="lead opacity-75">Advanced Maritime & Cargo Operations Intelligence.</p>
            <hr class="w-25 border-2 opacity-50">
            <ul class="list-unstyled mt-4 small opacity-75">
                <li class="mb-2"><i class="bi bi-check2-circle me-2"></i> Real-time Cargo Tracking</li>
                <li class="mb-2"><i class="bi bi-check2-circle me-2"></i> Secure Movement Logs</li>
                <li><i class="bi bi-check2-circle me-2"></i> Multi-Role Management</li>
            </ul>
        </div>
    </div>

    <div class="login-form-side">
        <div class="mb-4">
            <h3 class="fw-bold text-dark">Welcome Back</h3>
            <p class="text-muted small">Please enter your credentials to access the terminal.</p>
        </div>

        <%
            String msg = request.getParameter("msg");
            if(msg != null) {
                String alertClass = msg.toLowerCase().contains("success") ? "alert-success" : "alert-danger";
        %>
            <div class="alert <%= alertClass %> alert-custom d-flex align-items-center mb-4">
                <i class="bi <%= alertClass.equals("alert-success") ? "bi-check-circle-fill" : "bi-exclamation-triangle-fill" %> me-2"></i>
                <div><%= msg %></div>
            </div>
        <% } %>

        <form action="LoginServlet" method="post">
            <div class="mb-3">
                <label class="form-label small fw-bold text-muted">Email Address</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-envelope"></i></span>
                    <input type="email" name="email" class="form-control border-start-0" placeholder="name@port.com" required>
                </div>
            </div>

            <div class="mb-4">
                <label class="form-label small fw-bold text-muted">Password</label>
                <div class="input-group">
                    <span class="input-group-text bg-white border-end-0 text-muted"><i class="bi bi-lock"></i></span>
                    <input type="password" name="password" class="form-control border-start-0" placeholder="••••••••" required>
                </div>
            </div>

            <div class="d-grid">
                <button type="submit" class="btn btn-login mb-3">
                    Sign In <i class="bi bi-arrow-right ms-2"></i>
                </button>
            </div>

            <div class="text-center">
                <a href="#" class="text-decoration-none small text-muted">Forgot password? Contact Administrator</a>
            </div>
        </form>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>