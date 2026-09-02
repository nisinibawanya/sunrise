package com.sunrisedental.controller;

import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

@WebServlet(name = "LoginServlet", urlPatterns = {"/login"})
public class LoginServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private static final String REMEMBER_COOKIE_NAME = "rememberedUsername";
    private static final int COOKIE_MAX_AGE_SECONDS = 7 * 24 * 60 * 60; // 7 days

    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            response.sendRedirect(request.getContextPath() + "/dashboard");
            return;
        }

        // Check for remembered username cookie
        Cookie[] cookies = request.getCookies();
        if (cookies != null) {
            for (Cookie cookie : cookies) {
                if (REMEMBER_COOKIE_NAME.equals(cookie.getName()) && cookie.getValue() != null && !cookie.getValue().trim().isEmpty()) {
                    try {
                        String decodedUsername = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);
                        request.setAttribute("rememberedUsername", decodedUsername);
                        request.setAttribute("isRemembered", true);
                    } catch (Exception e) {
                        request.setAttribute("rememberedUsername", cookie.getValue());
                        request.setAttribute("isRemembered", true);
                    }
                    break;
                }
            }
        }

        request.getRequestDispatcher("/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String username = request.getParameter("username");
        String password = request.getParameter("password");
        String rememberMe = request.getParameter("rememberMe");
        boolean isRememberSelected = (rememberMe != null && ("on".equalsIgnoreCase(rememberMe) || "true".equalsIgnoreCase(rememberMe) || "1".equals(rememberMe)));

        if (username == null || password == null || username.trim().isEmpty() || password.trim().isEmpty()) {
            request.setAttribute("errorMessage", "Please enter both username and password.");
            request.setAttribute("enteredUsername", username != null ? username.trim() : "");
            request.setAttribute("isRemembered", isRememberSelected);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
            return;
        }

        User user = userDAO.authenticate(username.trim(), password.trim());
        if (user != null) {
            // 1. Establish secure server-side session
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setAttribute("userName", user.getFullName());
            session.setAttribute("userRole", user.getRole());

            // 2. Handle Remember Me Cookie
            String contextPath = request.getContextPath();
            if (contextPath == null || contextPath.trim().isEmpty()) {
                contextPath = "/";
            }

            if (isRememberSelected) {
                // Store only username in an HTTP-Only cookie for 7 days
                String encodedUsername = URLEncoder.encode(username.trim(), StandardCharsets.UTF_8);
                Cookie cookie = new Cookie(REMEMBER_COOKIE_NAME, encodedUsername);
                cookie.setMaxAge(COOKIE_MAX_AGE_SECONDS);
                cookie.setHttpOnly(true);
                cookie.setPath(contextPath);
                cookie.setSecure(request.isSecure());
                response.addCookie(cookie);
            } else {
                // Clear the remembered username cookie if user unchecked it
                Cookie cookie = new Cookie(REMEMBER_COOKIE_NAME, "");
                cookie.setMaxAge(0);
                cookie.setHttpOnly(true);
                cookie.setPath(contextPath);
                cookie.setSecure(request.isSecure());
                response.addCookie(cookie);
            }

            response.sendRedirect(request.getContextPath() + "/dashboard");
        } else {
            request.setAttribute("errorMessage", "Invalid username or password. Please try again.");
            request.setAttribute("enteredUsername", username.trim());
            request.setAttribute("isRemembered", isRememberSelected);
            request.getRequestDispatcher("/login.jsp").forward(request, response);
        }
    }
}
