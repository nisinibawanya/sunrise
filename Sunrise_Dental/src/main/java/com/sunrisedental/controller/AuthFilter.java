package com.sunrisedental.controller;

import jakarta.servlet.Filter;
import jakarta.servlet.FilterChain;
import jakarta.servlet.FilterConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.ServletRequest;
import jakarta.servlet.ServletResponse;
import jakarta.servlet.annotation.WebFilter;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebFilter("/*")
public class AuthFilter implements Filter {

    @Override
    public void init(FilterConfig filterConfig) throws ServletException {}

    @Override
    public void doFilter(ServletRequest req, ServletResponse res, FilterChain chain)
            throws IOException, ServletException {
        HttpServletRequest request = (HttpServletRequest) req;
        HttpServletResponse response = (HttpServletResponse) res;

        String path = request.getRequestURI().substring(request.getContextPath().length());

        // Allow static assets, login, and root
        boolean isStatic = path.startsWith("/assets/") || path.endsWith(".css") || path.endsWith(".js") 
                        || path.endsWith(".png") || path.endsWith(".jpg") || path.endsWith(".svg") || path.endsWith(".ico");
        boolean isLogin = path.equals("/login") || path.equals("/login.jsp") || path.equals("/logout") || path.equals("/index.jsp") || path.equals("/");

        HttpSession session = request.getSession(false);
        boolean isLoggedIn = (session != null && session.getAttribute("currentUser") != null);

        if (isStatic || isLogin || isLoggedIn) {
            chain.doFilter(req, res);
        } else {
            response.sendRedirect(request.getContextPath() + "/login");
        }
    }

    @Override
    public void destroy() {}
}
