<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Appointment, com.sunrisedental.model.Patient, com.sunrisedental.model.Bill" %>
<%
    request.setAttribute("activeMenu", "dashboard");
    List<Appointment> todayAppointments = (List<Appointment>) request.getAttribute("todayAppointments");
    List<Patient> recentPatients = (List<Patient>) request.getAttribute("recentPatients");
    List<Bill> recentBills = (List<Bill>) request.getAttribute("recentBills");
    Integer todayApptCount = (Integer) request.getAttribute("todayApptCount");
    Integer totalPatients = (Integer) request.getAttribute("totalPatients");
    Integer upcomingApptCount = (Integer) request.getAttribute("upcomingApptCount");
    Integer pendingBillsCount = (Integer) request.getAttribute("pendingBillsCount");
    BigDecimal todayRevenue = (BigDecimal) request.getAttribute("todayRevenue");
    BigDecimal totalRevenue = (BigDecimal) request.getAttribute("totalRevenue");
    Integer activeReceptionistsCount = (Integer) request.getAttribute("activeReceptionistsCount");
    Integer activeDentistsCount = (Integer) request.getAttribute("activeDentistsCount");
    Integer availableTreatmentsCount = (Integer) request.getAttribute("availableTreatmentsCount");
    String errorMessage = (String) request.getAttribute("errorMessage");

    Boolean isAdminAttr = (Boolean) request.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);
    String userRole = (String) session.getAttribute("userRole");

    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd MMM, hh:mm a");
    String displayName = isAdmin ? "Admin" : "Receptionist";
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <style>
        .quick-action-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 16px;
            margin-top: 12px;
        }
        .quick-action-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 20px;
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            color: var(--text-dark);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
        }
        .quick-action-btn:hover {
            border-color: var(--primary);
            background: var(--primary-subtle);
            color: var(--primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }
        .quick-action-icon {
            font-size: 1.3rem;
            width: 38px;
            height: 38px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            background: #f1f5f9;
            flex-shrink: 0;
        }
        .quick-admin-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(220px, 1fr));
            gap: 16px;
            margin-top: 12px;
        }
        .quick-admin-btn {
            display: flex;
            align-items: center;
            gap: 12px;
            padding: 16px 20px;
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            color: var(--text-dark);
            text-decoration: none;
            font-weight: 600;
            font-size: 0.95rem;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
        }
        .quick-admin-btn:hover {
            border-color: var(--primary);
            background: var(--primary-subtle);
            color: var(--primary);
            transform: translateY(-2px);
            box-shadow: var(--shadow);
        }
        .quick-admin-icon {
            font-size: 1.35rem;
            width: 38px;
            height: 38px;
            display: flex;
            align-items: center;
            justify-content: center;
            border-radius: 8px;
            background: #f1f5f9;
        }
        .system-overview-bar {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 14px;
            margin-bottom: 24px;
        }
        .overview-item-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            padding: 14px 18px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            box-shadow: var(--shadow-sm);
        }
        .overview-badge {
            font-size: 0.95rem;
            font-weight: 700;
            color: var(--primary);
            padding: 3px 10px;
            background: #eef2ff;
            border-radius: 8px;
            border: 1px solid #c7d2fe;
        }
        .revenue-overview-card {
            background: linear-gradient(135deg, #4f46e5 0%, #7c3aed 100%);
            color: #ffffff;
            border-radius: var(--radius);
            padding: 24px;
            margin-bottom: 24px;
            box-shadow: var(--shadow);
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 20px;
        }
        .revenue-metric {
            display: flex;
            flex-direction: column;
            gap: 4px;
        }
        .revenue-label {
            font-size: 0.82rem;
            color: #e0e7ff;
            text-transform: uppercase;
            font-weight: 600;
            letter-spacing: 0.5px;
        }
        .revenue-amount {
            font-size: 1.6rem;
            font-weight: 800;
            color: #ffffff;
        }
        .badge-partial {
            background-color: #fef3c7;
            color: #92400e;
            border: 1px solid #fde68a;
        }
    </style>
</head>
<body>
<div class="app-container">
    <jsp:include page="includes/sidebar.jsp" />

    <div class="main-wrapper">
        <jsp:include page="includes/header.jsp" />

        <main class="content-container">
            <!-- Page Header -->
            <div class="page-header" style="margin-bottom: 24px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                <div>
                    <h1 class="page-title">Dashboard</h1>
                    <p class="page-subtitle">Welcome, <%= displayName %> — Sunrise Dental Clinic Administration</p>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/appointments?action=new" class="btn btn-primary" style="display: inline-flex; align-items: center; gap: 6px;">
                        <span>➕</span> <span>New Appointment</span>
                    </a>
                </div>
            </div>

            <!-- Error Message (if any data loading failed) -->
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-warning" style="margin-bottom: 20px;">
                    <span>⚠️</span> <span><%= errorMessage %></span>
                </div>
            <% } %>

            <!-- ============================================================
                 PRIMARY DASHBOARD SUMMARY CARDS (4 CARDS)
                 ============================================================ -->
            <div class="grid-4" style="margin-bottom: 20px;">
                <!-- Card 1: Today's Appointments -->
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-purple">
                        📅
                    </div>
                    <div class="stat-info">
                        <span class="stat-value"><%= todayApptCount != null ? todayApptCount : 0 %></span>
                        <span class="stat-label">Today's Appointments</span>
                    </div>
                </div>

                <!-- Card 2: Total Patients -->
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-blue">
                        👥
                    </div>
                    <div class="stat-info">
                        <span class="stat-value"><%= totalPatients != null ? totalPatients : 0 %></span>
                        <span class="stat-label">Total Patients</span>
                    </div>
                </div>

                <!-- Card 3: Upcoming Appointments -->
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-green">
                        ⏳
                    </div>
                    <div class="stat-info">
                        <span class="stat-value"><%= upcomingApptCount != null ? upcomingApptCount : 0 %></span>
                        <span class="stat-label">Upcoming Appointments</span>
                    </div>
                </div>

                <!-- Card 4: Admin → Today's Revenue | Receptionist → Pending Bills -->
                <% if (isAdmin) { %>
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-orange">
                        💳
                    </div>
                    <div class="stat-info">
                        <span class="stat-value">Rs. <%= String.format("%,.2f", todayRevenue != null ? todayRevenue : BigDecimal.ZERO) %></span>
                        <span class="stat-label">Today's Revenue</span>
                    </div>
                </div>
                <% } else { %>
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-orange">
                        🧾
                    </div>
                    <div class="stat-info">
                        <span class="stat-value"><%= pendingBillsCount != null ? pendingBillsCount : 0 %></span>
                        <span class="stat-label">Pending Bills</span>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- ============================================================
                 ADMIN SECONDARY STATUS METRICS STRIP (4 STATS)
                 Pending Bills | Dentists | Treatments | Receptionists
                 ============================================================ -->
            <% if (isAdmin) { %>
            <div class="system-overview-bar">
                <div class="overview-item-card">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 1.25rem;">🧾</span>
                        <div>
                            <div style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">Pending Invoices</div>
                            <div style="font-weight: 700; color: #b91c1c; font-size: 1.05rem;"><%= pendingBillsCount != null ? pendingBillsCount : 0 %></div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=pending" class="btn btn-sm btn-outline" style="padding: 2px 8px; font-size: 0.75rem;">View</a>
                </div>

                <div class="overview-item-card">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 1.25rem;">👨‍⚕️</span>
                        <div>
                            <div style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">Active Dentists</div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 1.05rem;"><%= activeDentistsCount != null ? activeDentistsCount : 0 %></div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/dentists" class="btn btn-sm btn-outline" style="padding: 2px 8px; font-size: 0.75rem;">Manage</a>
                </div>

                <div class="overview-item-card">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 1.25rem;">🦷</span>
                        <div>
                            <div style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">Treatments &amp; Tariff</div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 1.05rem;"><%= availableTreatmentsCount != null ? availableTreatmentsCount : 0 %></div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/treatments" class="btn btn-sm btn-outline" style="padding: 2px 8px; font-size: 0.75rem;">Manage</a>
                </div>

                <div class="overview-item-card">
                    <div style="display: flex; align-items: center; gap: 10px;">
                        <span style="font-size: 1.25rem;">👩‍💼</span>
                        <div>
                            <div style="font-size: 0.8rem; color: var(--text-muted); font-weight: 600;">Receptionists</div>
                            <div style="font-weight: 700; color: var(--primary); font-size: 1.05rem;"><%= activeReceptionistsCount != null ? activeReceptionistsCount : 0 %></div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/users" class="btn btn-sm btn-outline" style="padding: 2px 8px; font-size: 0.75rem;">Manage</a>
                </div>
            </div>

            <!-- ADMIN REVENUE OVERVIEW CARD -->
            <div class="revenue-overview-card">
                <div style="display: flex; gap: 32px; flex-wrap: wrap; align-items: center;">
                    <div class="revenue-metric">
                        <span class="revenue-label">Total Collected Revenue</span>
                        <span class="revenue-amount">Rs. <%= String.format("%,.2f", totalRevenue != null ? totalRevenue : BigDecimal.ZERO) %></span>
                    </div>
                    <div class="revenue-metric" style="border-left: 1px solid rgba(255,255,255,0.25); padding-left: 24px;">
                        <span class="revenue-label">Today's Collections</span>
                        <span style="font-size: 1.3rem; font-weight: 700; color: #a7f3d0;">Rs. <%= String.format("%,.2f", todayRevenue != null ? todayRevenue : BigDecimal.ZERO) %></span>
                    </div>
                    <div class="revenue-metric" style="border-left: 1px solid rgba(255,255,255,0.25); padding-left: 24px;">
                        <span class="revenue-label">Pending Invoices</span>
                        <span style="font-size: 1.3rem; font-weight: 700; color: #fecaca;"><%= pendingBillsCount != null ? pendingBillsCount : 0 %> Bills</span>
                    </div>
                </div>
                <div>
                    <a href="<%= request.getContextPath() %>/reports?type=revenue" class="btn btn-sm" style="background: #ffffff; color: var(--primary); font-weight: 700; box-shadow: var(--shadow);">
                        📊 Full Financial Reports
                    </a>
                </div>
            </div>
            <% } %>

            <!-- ============================================================
                 TWO-COLUMN PANELS: 
                 Admin: Today's Appointments & Recent Payments
                 Receptionist: Today's Appointments & Recent Patients
                 ============================================================ -->
            <div class="grid-2" style="margin-bottom: 24px;">
                <!-- Left Panel: Today's Appointments Table -->
                <div class="card" style="display: flex; flex-direction: column;">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h2 class="card-title">Today's Appointments</h2>
                        <a href="<%= request.getContextPath() %>/appointments?action=new" class="btn btn-sm btn-outline-primary" style="display: inline-flex; align-items: center; gap: 4px;">
                            <span>➕</span> <span>New</span>
                        </a>
                    </div>
                    <div class="table-responsive" style="flex-grow: 1;">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Appt No.</th>
                                    <th>Patient Name</th>
                                    <th>Time</th>
                                    <th>Dentist</th>
                                    <th>Treatment</th>
                                    <th style="text-align: center;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (todayAppointments != null && !todayAppointments.isEmpty()) {
                                    for (Appointment a : todayAppointments) { %>
                                    <tr>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/appointments?action=search&no=<%= a.getAppointmentNo() %>"
                                               style="font-weight: 700; color: var(--primary); text-decoration: none; font-family: monospace;">
                                                <%= a.getAppointmentNo() %>
                                            </a>
                                        </td>
                                        <td style="font-weight: 600;"><%= a.getPatientName() %></td>
                                        <td style="color: var(--text-dark);"><%= a.getAppointmentTime() %></td>
                                        <td style="color: var(--text-muted);"><%= a.getDentistName() != null ? a.getDentistName() : "-" %></td>
                                        <td style="color: var(--text-muted);">
                                            <span style="max-width: 130px; display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap;" title="<%= a.getTreatmentName() != null ? a.getTreatmentName() : "-" %>">
                                                <%= a.getTreatmentName() != null ? a.getTreatmentName() : "-" %>
                                            </span>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="badge badge-confirmed"><%= a.getStatus() != null ? a.getStatus() : "Confirmed" %></span>
                                        </td>
                                    </tr>
                                <%  }
                                   } else { %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 36px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">📅</div>
                                            <div>No appointments scheduled for today.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div style="text-align: center; margin-top: 18px; padding-top: 12px; border-top: 1px solid var(--border-color);">
                        <a href="<%= request.getContextPath() %>/appointments?action=search" class="btn btn-outline-primary btn-sm">
                            View All Appointments
                        </a>
                    </div>
                </div>

                <% if (isAdmin) { %>
                <!-- Right Panel (ADMIN): Recent Payments & Billing Activity Table -->
                <div class="card" style="display: flex; flex-direction: column;">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h2 class="card-title">Recent Payments &amp; Invoices</h2>
                        <a href="<%= request.getContextPath() %>/reports?type=revenue" class="btn btn-sm btn-outline">View All Invoices</a>
                    </div>
                    <div class="table-responsive" style="flex-grow: 1;">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Invoice No.</th>
                                    <th>Patient</th>
                                    <th style="text-align: right;">Amount Paid</th>
                                    <th style="text-align: center;">Status</th>
                                    <th style="text-align: center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentBills != null && !recentBills.isEmpty()) {
                                    for (Bill b : recentBills) { 
                                        String st = b.getPaymentStatus() != null ? b.getPaymentStatus() : "Paid";
                                        String badgeCls = "badge-paid";
                                        if ("Pending".equalsIgnoreCase(st)) badgeCls = "badge-pending";
                                        else if ("Partially Paid".equalsIgnoreCase(st)) badgeCls = "badge-partial";
                                %>
                                    <tr>
                                        <td style="font-weight: 700; color: var(--primary); font-family: monospace;">
                                            <%= b.getBillNo() %>
                                        </td>
                                        <td style="font-weight: 600; color: var(--text-dark);">
                                            <%= b.getPatientName() %>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #065f46;">
                                            Rs. <%= String.format("%,.2f", b.getAmountPaid()) %>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="badge <%= badgeCls %>"><%= st %></span>
                                        </td>
                                        <td style="text-align: center;">
                                            <a href="<%= request.getContextPath() %>/billing?action=receipt&billNo=<%= b.getBillNo() %>" class="btn btn-sm btn-outline" style="padding: 3px 8px; font-size: 0.78rem;">
                                                Receipt
                                            </a>
                                        </td>
                                    </tr>
                                <%  }
                                   } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 36px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">💳</div>
                                            <div>No recent invoice transactions found.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div style="text-align: center; margin-top: 18px; padding-top: 12px; border-top: 1px solid var(--border-color);">
                        <a href="<%= request.getContextPath() %>/reports?type=revenue" class="btn btn-outline-primary btn-sm">
                            View Financial Summary
                        </a>
                    </div>
                </div>

                <% } else { %>
                <!-- Right Panel (RECEPTIONIST): Recent Patients Table -->
                <div class="card" style="display: flex; flex-direction: column;">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <h2 class="card-title">Recent Patients</h2>
                        <a href="<%= request.getContextPath() %>/patients" class="btn btn-sm btn-outline">View Directory</a>
                    </div>
                    <div class="table-responsive" style="flex-grow: 1;">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Patient Name</th>
                                    <th>Last Visit</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (recentPatients != null && !recentPatients.isEmpty()) {
                                    for (Patient p : recentPatients) { %>
                                    <tr>
                                        <td style="font-weight: 600; color: var(--text-dark);">
                                            👤 <%= p.getName() %>
                                        </td>
                                        <td style="color: var(--text-muted); font-size: 0.88rem;">
                                            <%= p.getLastVisit() != null ? dateFormat.format(p.getLastVisit()) : "Recent" %>
                                        </td>
                                    </tr>
                                <%  }
                                   } else { %>
                                    <tr>
                                        <td colspan="2" style="text-align: center; color: var(--text-muted); padding: 36px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">👥</div>
                                            <div>No registered patients found.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div style="text-align: center; margin-top: 18px; padding-top: 12px; border-top: 1px solid var(--border-color);">
                        <a href="<%= request.getContextPath() %>/patients" class="btn btn-outline-primary btn-sm">
                            View All Patients
                        </a>
                    </div>
                </div>
                <% } %>
            </div>

            <!-- ============================================================
                 ROLE-SPECIFIC BOTTOM SECTION
                 Admin: Quick Administration
                 Receptionist: Quick Actions
                 ============================================================ -->
            <% if (isAdmin) { %>
            <!-- ADMIN: Quick Administration Shortcuts -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title" style="display: flex; align-items: center; gap: 8px;">
                        <span>⚡</span> <span>Quick Administration</span>
                    </h2>
                </div>
                <div class="quick-admin-grid">
                    <a href="<%= request.getContextPath() %>/users" class="quick-admin-btn">
                        <div class="quick-admin-icon">👥</div>
                        <div>
                            <div>Manage Receptionists</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">User IDs &amp; Credentials</small>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/dentists" class="quick-admin-btn">
                        <div class="quick-admin-icon">👨‍⚕️</div>
                        <div>
                            <div>Manage Dentists</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Doctors &amp; Allocations</small>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/treatments" class="quick-admin-btn">
                        <div class="quick-admin-icon">🦷</div>
                        <div>
                            <div>Manage Treatments</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Services &amp; Pricing</small>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/reports?type=revenue" class="quick-admin-btn">
                        <div class="quick-admin-icon">📊</div>
                        <div>
                            <div>Financial Reports</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Revenue &amp; Settlements</small>
                        </div>
                    </a>
                </div>
            </div>

            <% } else { %>
            <!-- RECEPTIONIST: Quick Actions (Task-Focused) -->
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title" style="display: flex; align-items: center; gap: 8px;">
                        <span>⚡</span> <span>Quick Actions</span>
                    </h2>
                </div>
                <div class="quick-action-grid">
                    <a href="<%= request.getContextPath() %>/appointments?action=new" class="quick-action-btn">
                        <div class="quick-action-icon">📝</div>
                        <div>
                            <div>New Appointment</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Register a new appointment</small>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/appointments?action=search" class="quick-action-btn">
                        <div class="quick-action-icon">🔍</div>
                        <div>
                            <div>Search Appointment</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Find patient appointments</small>
                        </div>
                    </a>
                    <a href="<%= request.getContextPath() %>/billing" class="quick-action-btn">
                        <div class="quick-action-icon">💳</div>
                        <div>
                            <div>Create Bill</div>
                            <small style="color: var(--text-muted); font-weight: normal; font-size: 0.78rem;">Process patient invoices</small>
                        </div>
                    </a>
                </div>
            </div>
            <% } %>

        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
</body>
</html>
