<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<header class="top-navbar no-print">
    <div class="navbar-left">
        <button class="menu-toggle-btn" id="sidebarToggle" title="Toggle Menu">☰</button>
        <span class="navbar-title">Sunrise Dental Clinic</span>
    </div>
    <div class="navbar-right">
        <div class="user-profile-badge">
            <span class="user-avatar-icon">👤</span>
            <span><%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Staff User" %></span>
        </div>
    </div>
</header>
