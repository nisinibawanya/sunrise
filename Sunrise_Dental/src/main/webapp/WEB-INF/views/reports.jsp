<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.math.BigDecimal, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Appointment, com.sunrisedental.model.Patient, com.sunrisedental.model.Treatment, com.sunrisedental.model.Bill" %>
<%
    request.setAttribute("activeMenu", "reports");
    String activeTab = (String) request.getAttribute("activeTab");
    if (activeTab == null || activeTab.trim().isEmpty()) {
        activeTab = "dashboard";
    }

    Boolean isAdminAttr = (Boolean) request.getAttribute("isAdmin");
    boolean isAdmin = (isAdminAttr != null && isAdminAttr);

    String errorMessage = (String) request.getAttribute("errorMessage");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Reports &amp; Analytics - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <style>
        .report-hub-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            padding: 24px;
            display: flex;
            flex-direction: column;
            justify-content: space-between;
            transition: var(--transition);
            box-shadow: var(--shadow-sm);
            position: relative;
        }
        .report-hub-card:hover {
            border-color: var(--primary);
            transform: translateY(-3px);
            box-shadow: var(--shadow);
        }
        .report-hub-card.active {
            border-color: var(--primary);
            background: #fdfaff;
            box-shadow: 0 0 0 2px rgba(124, 58, 237, 0.2);
        }
        .report-hub-header {
            display: flex;
            align-items: flex-start;
            gap: 16px;
            margin-bottom: 14px;
        }
        .report-hub-icon {
            width: 46px;
            height: 46px;
            border-radius: 12px;
            display: flex;
            align-items: center;
            justify-content: center;
            font-size: 1.5rem;
            flex-shrink: 0;
        }
        .report-hub-title {
            font-size: 1.05rem;
            font-weight: 700;
            color: var(--text-dark);
            margin-bottom: 4px;
        }
        .report-hub-desc {
            font-size: 0.85rem;
            color: var(--text-muted);
            line-height: 1.4;
        }
        .filter-bar {
            background: #f8fafc;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            padding: 16px 20px;
            margin-bottom: 20px;
            display: flex;
            align-items: center;
            justify-content: space-between;
            flex-wrap: wrap;
            gap: 16px;
        }
        .filter-group {
            display: flex;
            align-items: center;
            gap: 10px;
            flex-wrap: wrap;
        }
        .filter-label {
            font-size: 0.85rem;
            font-weight: 600;
            color: var(--text-dark);
        }
        .summary-metric-card {
            background: #ffffff;
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
            padding: 18px 20px;
            display: flex;
            align-items: center;
            gap: 16px;
            box-shadow: var(--shadow-sm);
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
            <!-- Breadcrumbs -->
            <nav class="breadcrumb">
                <a href="<%= request.getContextPath() %>/dashboard">Home</a>
                <span>/</span>
                <a href="<%= request.getContextPath() %>/reports">Reports</a>
                <% if (!"dashboard".equals(activeTab)) { %>
                    <span>/</span>
                    <span style="text-transform: capitalize;"><%= activeTab %></span>
                <% } %>
            </nav>

            <div class="page-header" style="margin-bottom: 24px;">
                <h1 class="page-title">Reports &amp; Analytics</h1>
                <p class="page-subtitle">
                    <%= isAdmin ? "Comprehensive clinical, operational, and financial analytics." : "Operational reports and daily clinic activities." %>
                </p>
            </div>

            <!-- Error / Alert Message -->
            <% if (errorMessage != null && !errorMessage.isEmpty()) { %>
                <div class="alert alert-danger" style="margin-bottom: 24px; display: flex; align-items: center; gap: 10px;">
                    <span style="font-size: 1.2rem;">⛔</span>
                    <span><%= errorMessage %></span>
                </div>
            <% } %>

            <!-- ============================================================
                 REPORTS 4-CARD HUB GRID
                 Admin: Daily Appts | Patient Report | Treatment Report | Revenue Report
                 Receptionist: Daily Appts | Patient Directory | Treatment & Service | Pending Bills
                 ============================================================ -->
            <div class="grid-4" style="margin-bottom: 30px;">
                <!-- 1. Daily Appointments Card (Both) -->
                <div class="report-hub-card <%= "daily".equals(activeTab) ? "active" : "" %>">
                    <div>
                        <div class="report-hub-header">
                            <div class="report-hub-icon" style="background-color: #ede9fe; color: #7c3aed;">
                                📅
                            </div>
                            <div>
                                <h3 class="report-hub-title">Daily Appointments</h3>
                                <p class="report-hub-desc">View appointments for a selected date.</p>
                            </div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=daily" class="btn btn-sm <%= "daily".equals(activeTab) ? "btn-primary" : "btn-outline-primary" %>" style="width: 100%; margin-top: 12px;">
                        <%= "daily".equals(activeTab) ? "Viewing Report" : "View Report" %>
                    </a>
                </div>

                <!-- 2. Patient Directory & History Card (Both) -->
                <div class="report-hub-card <%= "patient".equals(activeTab) ? "active" : "" %>">
                    <div>
                        <div class="report-hub-header">
                            <div class="report-hub-icon" style="background-color: #fce7f3; color: #db2777;">
                                👥
                            </div>
                            <div>
                                <h3 class="report-hub-title"><%= isAdmin ? "Patient Report" : "Patient Directory & History" %></h3>
                                <p class="report-hub-desc">View patient details and visit history.</p>
                            </div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=patient" class="btn btn-sm <%= "patient".equals(activeTab) ? "btn-primary" : "btn-outline-primary" %>" style="width: 100%; margin-top: 12px;">
                        <%= "patient".equals(activeTab) ? "Viewing Report" : "View Report" %>
                    </a>
                </div>

                <!-- 3. Treatment & Service Report Card -->
                <div class="report-hub-card <%= "treatment".equals(activeTab) ? "active" : "" %>">
                    <div>
                        <div class="report-hub-header">
                            <div class="report-hub-icon" style="background-color: #e0f2fe; color: #0284c7;">
                                📋
                            </div>
                            <div>
                                <h3 class="report-hub-title"><%= isAdmin ? "Treatment Report" : "Treatment & Service Report" %></h3>
                                <p class="report-hub-desc">
                                    <%= isAdmin ? "View treatments performed during a selected period." : "View treatment/service usage." %>
                                </p>
                            </div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=treatment" class="btn btn-sm <%= "treatment".equals(activeTab) ? "btn-primary" : "btn-outline-primary" %>" style="width: 100%; margin-top: 12px;">
                        <%= "treatment".equals(activeTab) ? "Viewing Report" : "View Report" %>
                    </a>
                </div>

                <!-- 4. Fourth Card: Admin → Revenue Report | Receptionist → Pending Bills -->
                <% if (isAdmin) { %>
                <div class="report-hub-card <%= "revenue".equals(activeTab) ? "active" : "" %>">
                    <div>
                        <div class="report-hub-header">
                            <div class="report-hub-icon" style="background-color: #ffedd5; color: #ea580c;">
                                📊
                            </div>
                            <div>
                                <h3 class="report-hub-title">Revenue Report</h3>
                                <p class="report-hub-desc">View income and payment summaries.</p>
                            </div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=revenue" class="btn btn-sm <%= "revenue".equals(activeTab) ? "btn-primary" : "btn-outline-primary" %>" style="width: 100%; margin-top: 12px;">
                        <%= "revenue".equals(activeTab) ? "Viewing Report" : "View Report" %>
                    </a>
                </div>
                <% } else { %>
                <div class="report-hub-card <%= "pending".equals(activeTab) ? "active" : "" %>">
                    <div>
                        <div class="report-hub-header">
                            <div class="report-hub-icon" style="background-color: #ffedd5; color: #ea580c;">
                                🧾
                            </div>
                            <div>
                                <h3 class="report-hub-title">Pending Bills</h3>
                                <p class="report-hub-desc">View outstanding bills and payment status.</p>
                            </div>
                        </div>
                    </div>
                    <a href="<%= request.getContextPath() %>/reports?type=pending" class="btn btn-sm <%= "pending".equals(activeTab) ? "btn-primary" : "btn-outline-primary" %>" style="width: 100%; margin-top: 12px;">
                        <%= "pending".equals(activeTab) ? "Viewing Report" : "View Report" %>
                    </a>
                </div>
                <% } %>
            </div>

            <!-- ============================================================
                 DETAILED REPORT VIEWS (Based on activeTab)
                 ============================================================ -->

            <!-- TAB 1: DAILY APPOINTMENTS REPORT -->
            <% if ("daily".equals(activeTab)) { 
                List<Appointment> dailyList = (List<Appointment>) request.getAttribute("dailyAppointments");
                String reportDate = (String) request.getAttribute("reportDate");
            %>
                <div class="card">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 14px;">
                        <div>
                            <h2 class="card-title">Daily Appointments Report</h2>
                            <small style="color: var(--text-muted);">Scheduled patient appointments for the selected date.</small>
                        </div>
                        <form action="<%= request.getContextPath() %>/reports" method="GET" style="display: flex; gap: 10px; align-items: center;">
                            <input type="hidden" name="type" value="daily">
                            <label class="filter-label">Select Date:</label>
                            <input type="date" name="date" class="form-control" style="width: 170px;" value="<%= reportDate %>" onchange="this.form.submit()">
                            <button type="submit" class="btn btn-sm btn-primary">Filter</button>
                        </form>
                    </div>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Appointment Number</th>
                                    <th>Patient Name</th>
                                    <th>Contact Number</th>
                                    <th>Dentist</th>
                                    <th>Treatment</th>
                                    <th>Time</th>
                                    <th style="text-align: center;">Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (dailyList != null && !dailyList.isEmpty()) { 
                                    for (Appointment a : dailyList) { %>
                                    <tr>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/appointments?action=search&no=<%= a.getAppointmentNo() %>"
                                               style="font-weight: 700; color: var(--primary); text-decoration: none; font-family: monospace;">
                                                <%= a.getAppointmentNo() %>
                                            </a>
                                        </td>
                                        <td style="font-weight: 600;"><%= a.getPatientName() %></td>
                                        <td><%= a.getPatientContact() != null ? a.getPatientContact() : "-" %></td>
                                        <td style="color: var(--text-muted);"><%= a.getDentistName() != null ? a.getDentistName() : "-" %></td>
                                        <td><%= a.getTreatmentName() != null ? a.getTreatmentName() : "-" %></td>
                                        <td style="font-weight: 600; color: var(--text-dark);"><%= a.getAppointmentTime() %></td>
                                        <td style="text-align: center;">
                                            <span class="badge badge-confirmed"><%= a.getStatus() != null ? a.getStatus() : "Confirmed" %></span>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">📅</div>
                                            <div>No appointments found for <%= reportDate != null ? reportDate : "selected date" %>.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            <!-- TAB 2: PATIENT DIRECTORY & HISTORY REPORT -->
            <% } else if ("patient".equals(activeTab)) { 
                List<Patient> patients = (List<Patient>) request.getAttribute("patientsList");
            %>
                <div class="card">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h2 class="card-title"><%= isAdmin ? "Patient Report" : "Patient Directory & History Report" %></h2>
                            <small style="color: var(--text-muted);">Registered patients and last recorded clinical visits.</small>
                        </div>
                        <a href="<%= request.getContextPath() %>/patients" class="btn btn-sm btn-outline-primary">Open Patient Registry</a>
                    </div>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Patient ID</th>
                                    <th>Patient Name</th>
                                    <th>Contact Number</th>
                                    <th>Address</th>
                                    <th>Last Visit Date</th>
                                    <th style="text-align: center;">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (patients != null && !patients.isEmpty()) { 
                                    for (Patient p : patients) { %>
                                    <tr>
                                        <td style="font-weight: 700; color: var(--text-muted); font-family: monospace;">#<%= p.getId() %></td>
                                        <td style="font-weight: 600; color: var(--text-dark);"><%= p.getName() %></td>
                                        <td><%= p.getContactNumber() %></td>
                                        <td style="color: var(--text-muted);"><%= p.getAddress() != null && !p.getAddress().isEmpty() ? p.getAddress() : "-" %></td>
                                        <td><%= p.getLastVisit() != null ? dateFormat.format(p.getLastVisit()) : "No visits recorded" %></td>
                                        <td style="text-align: center;">
                                            <a href="<%= request.getContextPath() %>/appointments?action=new" class="btn btn-sm btn-outline" style="padding: 4px 10px; font-size: 0.8rem;">
                                                Book Visit
                                            </a>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">👥</div>
                                            <div>No records found for the selected criteria.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            <!-- TAB 3: TREATMENT & SERVICE REPORT -->
            <% } else if ("treatment".equals(activeTab)) { 
                List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatmentsList");
                String fromDateStr = (String) request.getAttribute("fromDateStr");
                String toDateStr = (String) request.getAttribute("toDateStr");
                if (fromDateStr == null) fromDateStr = "";
                if (toDateStr == null) toDateStr = "";
            %>
                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">
                            <%= isAdmin ? "Treatment Usage & Tariff Report" : "Treatment & Service Report" %>
                        </h2>
                        <small style="color: var(--text-muted);">
                            <%= isAdmin ? "Analysis of clinical treatments, standard fees, and appointment utilization." : "Operational information on treatment utilization across appointments." %>
                        </small>
                    </div>

                    <!-- Date Range Filter Form -->
                    <form action="<%= request.getContextPath() %>/reports" method="GET" class="filter-bar">
                        <input type="hidden" name="type" value="treatment">
                        <div class="filter-group">
                            <span class="filter-label">From Date:</span>
                            <input type="date" name="from" class="form-control" style="width: 160px;" value="<%= fromDateStr %>">
                            
                            <span class="filter-label" style="margin-left: 8px;">To Date:</span>
                            <input type="date" name="to" class="form-control" style="width: 160px;" value="<%= toDateStr %>">
                        </div>
                        <div class="filter-group">
                            <button type="submit" class="btn btn-sm btn-primary">Filter</button>
                            <a href="<%= request.getContextPath() %>/reports?type=treatment" class="btn btn-sm btn-outline">Reset</a>
                        </div>
                    </form>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Treatment Name</th>
                                    <th>Description</th>
                                    <% if (isAdmin) { %>
                                        <th style="text-align: right;">Standard Fee (Rs.)</th>
                                    <% } %>
                                    <th style="text-align: center;">Number of Appointments / Uses</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (treatments != null && !treatments.isEmpty()) { 
                                    for (Treatment t : treatments) { %>
                                    <tr>
                                        <td style="font-weight: 700; color: var(--text-dark);">
                                            🦷 <%= t.getName() %>
                                        </td>
                                        <td style="color: var(--text-muted); font-size: 0.88rem;">
                                            <%= t.getDescription() != null && !t.getDescription().isEmpty() ? t.getDescription() : "-" %>
                                        </td>
                                        <% if (isAdmin) { %>
                                            <td style="text-align: right; font-weight: 600; color: var(--primary);">
                                                Rs. <%= String.format("%,.2f", t.getCost()) %>
                                            </td>
                                        <% } %>
                                        <td style="text-align: center;">
                                            <span style="display: inline-block; padding: 4px 12px; background: #f1f5f9; border-radius: 12px; font-weight: 700; color: var(--primary); border: 1px solid var(--border-color);">
                                                <%= t.getUsageCount() %>
                                            </span>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="<%= isAdmin ? 4 : 3 %>" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">📋</div>
                                            <div>No records found for the selected criteria.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            <!-- TAB 4 (RECEPTIONIST): PENDING BILLS REPORT -->
            <% } else if ("pending".equals(activeTab)) { 
                List<Bill> pendingBills = (List<Bill>) request.getAttribute("pendingBillsList");
            %>
                <div class="card">
                    <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                        <div>
                            <h2 class="card-title">Pending Bills Report</h2>
                            <small style="color: var(--text-muted);">View outstanding patient bills, amounts paid, and pending balances.</small>
                        </div>
                        <a href="<%= request.getContextPath() %>/billing" class="btn btn-sm btn-primary">+ Create / Process Bill</a>
                    </div>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Invoice Number</th>
                                    <th>Appointment Number</th>
                                    <th>Patient Name</th>
                                    <th style="text-align: right;">Total Amount</th>
                                    <th style="text-align: right;">Amount Paid</th>
                                    <th style="text-align: right;">Balance Due</th>
                                    <th style="text-align: center;">Payment Status</th>
                                    <th style="text-align: center;" class="no-print">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (pendingBills != null && !pendingBills.isEmpty()) { 
                                    for (Bill b : pendingBills) { 
                                        String status = b.getPaymentStatus() != null ? b.getPaymentStatus() : "Pending";
                                        String badgeClass = "badge-pending";
                                        if ("Partially Paid".equalsIgnoreCase(status)) {
                                            badgeClass = "badge-partial";
                                        } else if ("Paid".equalsIgnoreCase(status)) {
                                            badgeClass = "badge-paid";
                                        }
                                %>
                                    <tr>
                                        <td style="font-weight: 700; color: var(--primary); font-family: monospace;">
                                            <%= b.getBillNo() %>
                                        </td>
                                        <td style="font-weight: 600; font-family: monospace;">
                                            <%= b.getAppointmentNo() %>
                                        </td>
                                        <td style="font-weight: 600; color: var(--text-dark);">
                                            <%= b.getPatientName() %>
                                        </td>
                                        <td style="text-align: right; font-weight: 600;">
                                            Rs. <%= String.format("%,.2f", b.getTotalAmount()) %>
                                        </td>
                                        <td style="text-align: right; color: #065f46; font-weight: 600;">
                                            Rs. <%= String.format("%,.2f", b.getAmountPaid()) %>
                                        </td>
                                        <td style="text-align: right; color: #b91c1c; font-weight: 700;">
                                            Rs. <%= String.format("%,.2f", b.getBalanceDue()) %>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="badge <%= badgeClass %>"><%= status %></span>
                                        </td>
                                        <td style="text-align: center;" class="no-print">
                                            <a href="<%= request.getContextPath() %>/billing?action=receipt&billNo=<%= b.getBillNo() %>" class="btn btn-sm btn-outline" style="padding: 4px 10px; font-size: 0.8rem;">
                                                Receipt
                                            </a>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="8" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">🧾</div>
                                            <div>No pending or outstanding bills found. All patient invoices are settled!</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>

            <!-- TAB 5 (ADMIN ONLY): FINANCIAL & REVENUE REPORT -->
            <% } else if ("revenue".equals(activeTab) && isAdmin) { 
                List<Bill> bills = (List<Bill>) request.getAttribute("billsList");
                BigDecimal totalInvoiced = (BigDecimal) request.getAttribute("totalInvoiced");
                BigDecimal totalCollected = (BigDecimal) request.getAttribute("totalCollected");
                BigDecimal outstandingBalance = (BigDecimal) request.getAttribute("outstandingBalance");
                String fromDateStr = (String) request.getAttribute("fromDateStr");
                String toDateStr = (String) request.getAttribute("toDateStr");
                String selectedStatus = (String) request.getAttribute("selectedStatus");
                String selectedMethod = (String) request.getAttribute("selectedMethod");

                if (fromDateStr == null) fromDateStr = "";
                if (toDateStr == null) toDateStr = "";
                if (selectedStatus == null) selectedStatus = "All";
                if (selectedMethod == null) selectedMethod = "All";
                if (totalInvoiced == null) totalInvoiced = BigDecimal.ZERO;
                if (totalCollected == null) totalCollected = BigDecimal.ZERO;
                if (outstandingBalance == null) outstandingBalance = BigDecimal.ZERO;
            %>
                <!-- Admin Financial Summary Cards -->
                <div class="grid-3" style="margin-bottom: 24px;">
                    <div class="summary-metric-card">
                        <div class="stat-icon-wrapper stat-icon-purple">
                            🧾
                        </div>
                        <div>
                            <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Total Invoiced</div>
                            <div style="font-size: 1.35rem; font-weight: 700; color: var(--text-dark);">
                                Rs. <%= String.format("%,.2f", totalInvoiced) %>
                            </div>
                        </div>
                    </div>

                    <div class="summary-metric-card">
                        <div class="stat-icon-wrapper stat-icon-green">
                            💰
                        </div>
                        <div>
                            <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Total Collected</div>
                            <div style="font-size: 1.35rem; font-weight: 700; color: #065f46;">
                                Rs. <%= String.format("%,.2f", totalCollected) %>
                            </div>
                        </div>
                    </div>

                    <div class="summary-metric-card">
                        <div class="stat-icon-wrapper stat-icon-orange">
                            ⏳
                        </div>
                        <div>
                            <div style="font-size: 0.82rem; color: var(--text-muted); font-weight: 600; text-transform: uppercase;">Outstanding Balance</div>
                            <div style="font-size: 1.35rem; font-weight: 700; color: #b91c1c;">
                                Rs. <%= String.format("%,.2f", outstandingBalance) %>
                            </div>
                        </div>
                    </div>
                </div>

                <div class="card">
                    <div class="card-header">
                        <h2 class="card-title">Financial &amp; Revenue Report</h2>
                        <small style="color: var(--text-muted);">Detailed financial breakdown and invoice settlement log.</small>
                    </div>

                    <!-- Admin Filter Bar -->
                    <form action="<%= request.getContextPath() %>/reports" method="GET" class="filter-bar">
                        <input type="hidden" name="type" value="revenue">
                        <div class="filter-group">
                            <span class="filter-label">Date From:</span>
                            <input type="date" name="from" class="form-control" style="width: 150px;" value="<%= fromDateStr %>">

                            <span class="filter-label" style="margin-left: 6px;">Date To:</span>
                            <input type="date" name="to" class="form-control" style="width: 150px;" value="<%= toDateStr %>">

                            <span class="filter-label" style="margin-left: 6px;">Payment Status:</span>
                            <select name="status" class="form-control" style="width: 140px;">
                                <option value="All" <%= "All".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>All Statuses</option>
                                <option value="Paid" <%= "Paid".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Paid</option>
                                <option value="Pending" <%= "Pending".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Pending</option>
                                <option value="Partially Paid" <%= "Partially Paid".equalsIgnoreCase(selectedStatus) ? "selected" : "" %>>Partially Paid</option>
                            </select>

                            <span class="filter-label" style="margin-left: 6px;">Payment Method:</span>
                            <select name="method" class="form-control" style="width: 150px;">
                                <option value="All" <%= "All".equalsIgnoreCase(selectedMethod) ? "selected" : "" %>>All Methods</option>
                                <option value="Cash" <%= "Cash".equalsIgnoreCase(selectedMethod) ? "selected" : "" %>>Cash</option>
                                <option value="Credit / Debit Card" <%= "Credit / Debit Card".equalsIgnoreCase(selectedMethod) ? "selected" : "" %>>Credit / Debit Card</option>
                                <option value="Insurance" <%= "Insurance".equalsIgnoreCase(selectedMethod) ? "selected" : "" %>>Insurance</option>
                                <option value="Bank Transfer" <%= "Bank Transfer".equalsIgnoreCase(selectedMethod) ? "selected" : "" %>>Bank Transfer</option>
                            </select>
                        </div>
                        <div class="filter-group">
                            <button type="submit" class="btn btn-sm btn-primary">Filter</button>
                            <a href="<%= request.getContextPath() %>/reports?type=revenue" class="btn btn-sm btn-outline">Reset</a>
                        </div>
                    </form>

                    <div class="table-responsive">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Invoice Number</th>
                                    <th>Appt No.</th>
                                    <th>Patient</th>
                                    <th>Treatment / Services</th>
                                    <th style="text-align: right;">Subtotal</th>
                                    <th style="text-align: right;">Discount</th>
                                    <th style="text-align: right;">Total Amount</th>
                                    <th style="text-align: right;">Amount Paid</th>
                                    <th style="text-align: right;">Balance Due</th>
                                    <th style="text-align: center;">Payment Status</th>
                                    <th style="text-align: center;" class="no-print">Action</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (bills != null && !bills.isEmpty()) { 
                                    for (Bill b : bills) { 
                                        String status = b.getPaymentStatus() != null ? b.getPaymentStatus() : "Paid";
                                        String badgeClass = "badge-paid";
                                        if ("Pending".equalsIgnoreCase(status)) {
                                            badgeClass = "badge-pending";
                                        } else if ("Partially Paid".equalsIgnoreCase(status)) {
                                            badgeClass = "badge-partial";
                                        }
                                %>
                                    <tr>
                                        <td style="font-weight: 700; color: var(--primary); font-family: monospace;">
                                            <%= b.getBillNo() %>
                                        </td>
                                        <td style="font-weight: 600; font-family: monospace;">
                                            <%= b.getAppointmentNo() %>
                                        </td>
                                        <td style="font-weight: 600; color: var(--text-dark);"><%= b.getPatientName() %></td>
                                        <td style="color: var(--text-muted); font-size: 0.85rem; max-width: 180px;">
                                            <span style="display: inline-block; overflow: hidden; text-overflow: ellipsis; white-space: nowrap; max-width: 180px;" title="<%= b.getServicesSummary() %>">
                                                <%= b.getServicesSummary() %>
                                            </span>
                                        </td>
                                        <td style="text-align: right; color: var(--text-muted);">
                                            Rs. <%= String.format("%,.2f", b.getSubTotal()) %>
                                        </td>
                                        <td style="text-align: right; color: var(--text-muted);">
                                            Rs. <%= String.format("%,.2f", b.getDiscount()) %>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: var(--text-dark);">
                                            Rs. <%= String.format("%,.2f", b.getTotalAmount()) %>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #065f46;">
                                            Rs. <%= String.format("%,.2f", b.getAmountPaid()) %>
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #b91c1c;">
                                            Rs. <%= String.format("%,.2f", b.getBalanceDue()) %>
                                        </td>
                                        <td style="text-align: center;">
                                            <span class="badge <%= badgeClass %>"><%= status %></span>
                                        </td>
                                        <td style="text-align: center;" class="no-print">
                                            <a href="<%= request.getContextPath() %>/billing?action=receipt&billNo=<%= b.getBillNo() %>" class="btn btn-sm btn-outline" style="padding: 4px 10px; font-size: 0.8rem;">
                                                Receipt
                                            </a>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="11" style="text-align: center; color: var(--text-muted); padding: 40px 20px;">
                                            <div style="font-size: 1.8rem; margin-bottom: 6px;">📊</div>
                                            <div>No billing records found for the selected criteria.</div>
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                </div>
            <% } else { %>
                <!-- DEFAULT DASHBOARD OVERVIEW WHEN NO SPECIFIC TAB SELECTED -->
                <div class="card" style="text-align: center; padding: 40px 20px;">
                    <div style="font-size: 2.5rem; margin-bottom: 12px;">📊</div>
                    <h3 style="font-size: 1.25rem; font-weight: 700; color: var(--text-dark); margin-bottom: 8px;">
                        Select a Report Above to Begin
                    </h3>
                    <p style="color: var(--text-muted); max-width: 500px; margin: 0 auto 20px auto; font-size: 0.92rem;">
                        <%= isAdmin 
                            ? "Choose from Daily Appointments, Patient Directory, Treatment Usage, or Financial & Revenue reports." 
                            : "Choose from Daily Appointments, Patient Directory & History, Treatment & Service Report, or Pending Bills." %>
                    </p>
                </div>
            <% } %>

        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
</body>
</html>
