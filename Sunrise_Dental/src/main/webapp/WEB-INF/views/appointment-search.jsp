<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Appointment" %>
<%
    request.setAttribute("activeMenu", "appointment-search");
    Appointment appt = (Appointment) request.getAttribute("appointment");
    String searchQuery = (String) request.getAttribute("searchQuery");
    if (searchQuery == null) searchQuery = "";
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Search Appointment - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
<div class="app-container">
    <jsp:include page="includes/sidebar.jsp" />

    <div class="main-wrapper">
        <jsp:include page="includes/header.jsp" />

        <main class="content-container">
            <nav class="breadcrumb">
                <a href="<%= request.getContextPath() %>/dashboard">Home</a>
                <span>/</span>
                <span>Search Appointment</span>
            </nav>

            <div class="page-header">
                <h1 class="page-title">Appointment Lookup</h1>
            </div>

            <!-- Flash Success / Error Messages -->
            <% if ("created".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success">
                    <span>✓</span>
                    <span>Appointment successfully registered! ✉️ Confirmation email with booking details (Date, Time, Doctor) has been sent to the patient.</span>
                </div>
            <% } else if ("updated".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success">
                    <span>✓</span>
                    <span>Appointment details successfully updated!</span>
                </div>
            <% } else if ("deleted".equals(request.getParameter("success"))) { %>
                <div class="alert alert-success">
                    <span>✓</span>
                    <span>Appointment successfully deleted!</span>
                </div>
            <% } %>

            <% String notFound = (String) request.getAttribute("notFoundMessage"); %>
            <% if (notFound != null) { %>
                <div class="alert alert-warning">
                    <span>⚠️</span>
                    <span><%= notFound %></span>
                </div>
            <% } %>

            <!-- Search Bar Wrapper -->
            <form action="<%= request.getContextPath() %>/appointments" method="GET" class="search-bar-wrapper">
                <input type="hidden" name="action" value="search">
                <div class="search-input-group">
                    <label style="font-weight: 600; font-size: 0.92rem; white-space: nowrap; color: var(--text-dark);">
                        Enter Appointment Number:
                    </label>
                    <input type="text" name="no" class="form-control" placeholder="e.g. A1002" value="<%= searchQuery %>" style="max-width: 280px;" required>
                </div>
                <button type="submit" class="btn btn-primary">Search</button>
            </form>

            <!-- Appointment Details Card (Screen 4) -->
            <% if (appt != null) { %>
            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Appointment Details</h2>
                    <span class="badge badge-confirmed" style="font-size: 0.85rem; padding: 6px 14px;">
                        <%= appt.getStatus() != null ? appt.getStatus() : "Confirmed" %>
                    </span>
                </div>

                <div class="details-grid">
                    <!-- Left Details -->
                    <div style="display: flex; flex-direction: column; gap: 18px;">
                        <div class="detail-item">
                            <span class="detail-label">Appointment Number</span>
                            <span class="detail-value" style="color: var(--primary); font-size: 1.1rem;"><%= appt.getAppointmentNo() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Patient Name</span>
                            <span class="detail-value"><%= appt.getPatientName() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Address</span>
                            <span class="detail-value"><%= appt.getPatientAddress() != null ? appt.getPatientAddress() : "-" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Contact Number</span>
                            <span class="detail-value"><%= appt.getPatientContact() %></span>
                        </div>
                    </div>

                    <!-- Right Details -->
                    <div style="display: flex; flex-direction: column; gap: 18px;">
                        <div class="detail-item">
                            <span class="detail-label">Dentist Name</span>
                            <span class="detail-value"><%= appt.getDentistName() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Treatment Type</span>
                            <span class="detail-value"><%= appt.getTreatmentName() %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Appointment Date</span>
                            <span class="detail-value"><%= appt.getAppointmentDate() != null ? dateFormat.format(appt.getAppointmentDate()) : "-" %></span>
                        </div>
                        <div class="detail-item">
                            <span class="detail-label">Appointment Time</span>
                            <span class="detail-value"><%= appt.getAppointmentTime() %></span>
                        </div>
                    </div>
                </div>

                <% if (appt.getNotes() != null && !appt.getNotes().trim().isEmpty()) { %>
                    <div class="detail-item" style="margin-bottom: 24px; padding-top: 14px; border-top: 1px dashed var(--border-color);">
                        <span class="detail-label">Clinical Notes</span>
                        <span class="detail-value" style="font-weight: normal; color: var(--text-muted);"><%= appt.getNotes() %></span>
                    </div>
                <% } %>

                <div class="form-actions" style="justify-content: flex-start; padding-top: 16px; border-top: 1px solid var(--border-color);">
                    <a href="<%= request.getContextPath() %>/appointments?action=edit&id=<%= appt.getId() %>" class="btn btn-primary">
                        <span>✏️</span> <span>Edit</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/appointments?action=delete&id=<%= appt.getId() %>" 
                       class="btn btn-danger" 
                       onclick="return confirm('Are you sure you want to delete appointment <%= appt.getAppointmentNo() %>?');">
                        <span>🗑️</span> <span>Delete</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/billing?no=<%= appt.getAppointmentNo() %>" class="btn btn-outline-primary">
                        <span>💳</span> <span>Proceed to Billing</span>
                    </a>
                    <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-outline" style="margin-left: auto;">
                        &larr; Back
                    </a>
                </div>
            </div>
            <% } %>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
