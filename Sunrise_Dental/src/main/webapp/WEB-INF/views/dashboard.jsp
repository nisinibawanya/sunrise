<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Appointment, com.sunrisedental.model.Patient" %>
<%
    request.setAttribute("activeMenu", "dashboard");
    List<Appointment> todayAppointments = (List<Appointment>) request.getAttribute("todayAppointments");
    List<Patient> recentPatients = (List<Patient>) request.getAttribute("recentPatients");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
<div class="app-container">
    <jsp:include page="includes/sidebar.jsp" />

    <div class="main-wrapper">
        <jsp:include page="includes/header.jsp" />

        <main class="content-container">
            <div class="page-header">
                <h1 class="page-title">Dashboard</h1>
                <p class="page-subtitle">Welcome, <%= session.getAttribute("userName") != null ? session.getAttribute("userName") : "Staff User" %></p>
            </div>

            <!-- Stats Bar -->
            <div class="grid-4" style="margin-bottom: 24px;">
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-purple">📅</div>
                    <div class="stat-info">
                        <span class="stat-value"><%= request.getAttribute("todayApptCount") != null ? request.getAttribute("todayApptCount") : "0" %></span>
                        <span class="stat-label">Today's Appointments</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-blue">👥</div>
                    <div class="stat-info">
                        <span class="stat-value"><%= request.getAttribute("totalPatients") != null ? request.getAttribute("totalPatients") : "0" %></span>
                        <span class="stat-label">Registered Patients</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-green">📝</div>
                    <div class="stat-info">
                        <span class="stat-value"><%= request.getAttribute("totalApptCount") != null ? request.getAttribute("totalApptCount") : "0" %></span>
                        <span class="stat-label">Total Bookings</span>
                    </div>
                </div>
                <div class="stat-card">
                    <div class="stat-icon-wrapper stat-icon-orange">💳</div>
                    <div class="stat-info">
                        <span class="stat-value">Rs. <%= request.getAttribute("totalRevenue") != null ? request.getAttribute("totalRevenue") : "0.00" %></span>
                        <span class="stat-label">Total Revenue</span>
                    </div>
                </div>
            </div>

            <!-- Main Two-Column Grid: Today's Appointments & Recent Patients -->
            <div class="grid-2">
                <!-- Today's Appointments Table Card -->
                <div class="card" style="display: flex; flex-direction: column;">
                    <div class="card-header">
                        <h2 class="card-title">Today's Appointments</h2>
                        <a href="<%= request.getContextPath() %>/appointments?action=new" class="btn btn-sm btn-primary">+ New</a>
                    </div>
                    <div class="table-responsive" style="flex-grow: 1;">
                        <table class="custom-table">
                            <thead>
                                <tr>
                                    <th>Appt No.</th>
                                    <th>Patient Name</th>
                                    <th>Time</th>
                                    <th>Dentist</th>
                                    <th>Status</th>
                                </tr>
                            </thead>
                            <tbody>
                                <% if (todayAppointments != null && !todayAppointments.isEmpty()) { 
                                    for (Appointment a : todayAppointments) { %>
                                    <tr>
                                        <td>
                                            <a href="<%= request.getContextPath() %>/appointments?action=search&no=<%= a.getAppointmentNo() %>" style="font-weight: 700; color: var(--primary); text-decoration: none;">
                                                <%= a.getAppointmentNo() %>
                                            </a>
                                        </td>
                                        <td><%= a.getPatientName() %></td>
                                        <td><%= a.getAppointmentTime() %></td>
                                        <td><%= a.getDentistName() %></td>
                                        <td>
                                            <span class="badge badge-confirmed"><%= a.getStatus() %></span>
                                        </td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                            No appointments scheduled for today.
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div style="text-align: center; margin-top: 20px;">
                        <a href="<%= request.getContextPath() %>/appointments?action=search" class="btn btn-outline-primary btn-sm">
                            View All Appointments
                        </a>
                    </div>
                </div>

                <!-- Recent Patients Table Card -->
                <div class="card" style="display: flex; flex-direction: column;">
                    <div class="card-header">
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
                                        <td style="font-weight: 600;"><%= p.getName() %></td>
                                        <td><%= p.getLastVisit() != null ? dateFormat.format(p.getLastVisit()) : "-" %></td>
                                    </tr>
                                <%   } 
                                   } else { %>
                                    <tr>
                                        <td colspan="2" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                            No patients found.
                                        </td>
                                    </tr>
                                <% } %>
                            </tbody>
                        </table>
                    </div>
                    <div style="text-align: center; margin-top: 20px;">
                        <a href="<%= request.getContextPath() %>/patients" class="btn btn-outline-primary btn-sm">
                            View All Patients
                        </a>
                    </div>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
