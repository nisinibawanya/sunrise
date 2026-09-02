<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String activeMenu = (String) request.getAttribute("activeMenu");
    if (activeMenu == null) activeMenu = "dashboard";
    String userRole = (String) session.getAttribute("userRole");
%>
<aside class="sidebar no-print">
    <div class="sidebar-header">
        <div class="sidebar-logo-icon">🦷</div>
        <div>
            <div class="sidebar-brand-title">Sunrise Dental</div>
            <div class="sidebar-brand-sub">Care with a Smile</div>
        </div>
    </div>
    <ul class="sidebar-nav">
        <li class="sidebar-nav-item <%= "dashboard".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/dashboard">
                <span>📊</span> <span>Dashboard</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "appointment-new".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/appointments?action=new">
                <span>📝</span> <span>New Appointment</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "appointment-search".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/appointments?action=search">
                <span>🔍</span> <span>Search Appointment</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "patients".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/patients">
                <span>👥</span> <span>Patients</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "dentists".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/dentists">
                <span>👨‍⚕️</span> <span>Dentists</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "treatments".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/treatments">
                <span>✂️</span> <span>Treatments</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "billing".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/billing">
                <span>💳</span> <span>Billing</span>
            </a>
        </li>
        <li class="sidebar-nav-item <%= "reports".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/reports">
                <span>📈</span> <span>Reports</span>
            </a>
        </li>
<% if ("admin".equalsIgnoreCase(userRole) || "administrator".equalsIgnoreCase(userRole)) { %>
        <li class="sidebar-nav-item <%= "users".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/users">
                <span>🛡️</span> <span>User Management</span>
            </a>
        </li>
<% } %>
        <li class="sidebar-nav-item <%= "help".equals(activeMenu) ? "active" : "" %>">
            <a class="sidebar-link" href="<%= request.getContextPath() %>/help">
                <span>❓</span> <span>Help</span>
            </a>
        </li>
    </ul>
    <div class="sidebar-footer">
        <a class="sidebar-link logout-btn trigger-exit-modal" href="#">
            <span>🚪</span> <span>Logout</span>
        </a>
    </div>
</aside>
