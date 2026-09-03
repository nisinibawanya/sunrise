<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="jakarta.servlet.http.Cookie, java.net.URLDecoder, java.nio.charset.StandardCharsets" %>
<%
    String usernameValue = (String) request.getAttribute("enteredUsername");
    Boolean isRememberedAttr = (Boolean) request.getAttribute("isRemembered");
    boolean isRemembered = (isRememberedAttr != null && isRememberedAttr);

    if (usernameValue == null || usernameValue.isEmpty()) {
        String remAttr = (String) request.getAttribute("rememberedUsername");
        if (remAttr != null && !remAttr.trim().isEmpty()) {
            usernameValue = remAttr;
            isRemembered = true;
        } else {
            // Direct JSP access fallback check from cookies
            Cookie[] cookies = request.getCookies();
            if (cookies != null) {
                for (Cookie c : cookies) {
                    if ("rememberedUsername".equals(c.getName()) && c.getValue() != null && !c.getValue().trim().isEmpty()) {
                        try {
                            usernameValue = URLDecoder.decode(c.getValue(), StandardCharsets.UTF_8);
                            isRemembered = true;
                        } catch (Exception ignored) {
                            usernameValue = c.getValue();
                            isRemembered = true;
                        }
                        break;
                    }
                }
            }
        }
    }

    if (usernameValue == null) {
        usernameValue = "";
    }

    // XSS Sanitization for HTML attribute rendering
    String safeUsername = usernameValue.replace("&", "&amp;")
                                       .replace("<", "&lt;")
                                       .replace(">", "&gt;")
                                       .replace("\"", "&quot;")
                                       .replace("'", "&#x27;");
%>
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
                <p class="login-subtitle">Please sign in with your credentials to continue</p>

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
                            <input type="text" id="usernameInput" name="username" class="form-control" placeholder="Enter Username" 
                                   value="<%= safeUsername %>" required <%= safeUsername.isEmpty() ? "autofocus" : "" %>>
                        </div>
                    </div>

                    <div class="form-group">
                        <div class="input-with-icon">
                            <span class="input-icon-left">🔒</span>
                            <input type="password" id="passwordInput" name="password" class="form-control" placeholder="Enter Password" required <%= !safeUsername.isEmpty() ? "autofocus" : "" %>>
                            <span class="input-icon-right" id="togglePassword" title="Show/Hide Password">👁</span>
                        </div>
                    </div>

                    <div class="login-options">
                        <label class="remember-label">
                            <input type="checkbox" name="rememberMe" id="rememberMeCheckbox" <%= isRemembered ? "checked" : "" %>>
                            <span>Remember me</span>
                        </label>
                        <a href="<%= request.getContextPath() %>/help?topic=login" class="forgot-link">Help / Credentials</a>
                    </div>

                    <button type="submit" class="btn btn-primary" style="width: 100%; padding: 12px; font-size: 1rem;">
                        Sign In
                    </button>
                </form>

                <p class="login-footer-text">
                    &copy; 2026 Sunrise Dental Clinic. All rights reserved.
                </p>
            </div>
        </div>
    </div>

    <script src="<%= request.getContextPath() %>/assets/js/app.js"></script>
</body>
</html>
