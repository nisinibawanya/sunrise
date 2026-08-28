<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Login - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
    <div class="login-wrapper">
        <!-- Left Hero Branding -->
        <div class="login-hero">
            <div class="login-hero-logo">🦷</div>
            <h1 class="login-hero-title">Sunrise</h1>
            <h2 class="login-hero-title" style="font-size: 1.8rem; margin-top: -6px;">Dental Clinic</h2>
            <p class="login-hero-tagline">Care with a Smile</p>
        </div>

        <!-- Right Form Section -->
        <div class="login-form-side">
            <div class="login-card">
                <h2 class="login-title">Welcome Back!</h2>
                <p class="login-subtitle">Please login to continue</p>

                <% String error = (String) request.getAttribute("errorMessage"); %>
                <% if (error != null) { %>
                    <div class="alert alert-danger">
                        <span>⚠️</span>
                        <span><%= error %></span>
                    </div>
                <% } %>

                <% if (request.getParameter("loggedOut") != null) { %>
                    <div class="alert alert-success">
                        <span>✓</span>
                        <span>You have been successfully logged out.</span>
                    </div>
                <% } %>

                <form action="<%= request.getContextPath() %>/login" method="POST">
                    <div class="form-group">
                        <div class="input-with-icon">
                            <span class="input-icon-left">👤</span>
                            <input type="text" name="username" class="form-control" placeholder="Username" 
                                   value="<%= request.getAttribute("enteredUsername") != null ? request.getAttribute("enteredUsername") : "staff" %>" required autofocus>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="input-with-icon">
                            <span class="input-icon-left">🔒</span>
                            <input type="password" id="passwordInput" name="password" class="form-control" placeholder="Password" value="staff123" required>
                            <span class="input-icon-right" id="togglePassword" title="Show/Hide Password">👁</span>
                        </div>
                    </div>

                    <div class="login-options">
                        <label class="remember-label">
                            <input type="checkbox" name="rememberMe" checked>
                            <span>Remember me</span>
                        </label>
                        <a href="<%= request.getContextPath() %>/help?topic=login" class="forgot-link">Forgot Password?</a>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 1rem;">
                        Sign In
                    </button>
                </form>

                <p class="login-footer-text">
                    &copy; 2024 Sunrise Dental Clinic. All rights reserved.
                </p>
            </div>
        </div>
    </div>

    <script src="<%= request.getContextPath() %>/assets/js/app.js"></script>
</body>
</html>
