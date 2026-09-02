<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.time.LocalDate" %>
<%@ page import="com.sunrisedental.model.Dentist, com.sunrisedental.model.Treatment" %>
<%
    request.setAttribute("activeMenu", "appointment-new");
    List<Dentist> dentists = (List<Dentist>) request.getAttribute("dentists");
    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
    String nextApptNo = (String) request.getAttribute("nextApptNo");
    if (nextApptNo == null) nextApptNo = "A1006";
    String todayDate = LocalDate.now().toString();
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>New Appointment - Sunrise Dental Clinic</title>
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
                <span>New Appointment</span>
            </nav>

            <div class="page-header">
                <h1 class="page-title">Register New Appointment</h1>
            </div>

            <% String error = (String) request.getAttribute("errorMessage"); %>
            <% if (error != null) { %>
                <div class="alert alert-danger">
                    <span>⚠️</span>
                    <span><%= error %></span>
                </div>
            <% } %>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Patient &amp; Appointment Details</h2>
                </div>

                <form action="<%= request.getContextPath() %>/appointments" method="POST" id="appointmentForm">
                    <input type="hidden" name="action" value="create">

                    <div class="grid-2">
                        <!-- Left Column -->
                        <div>
                            <div class="form-group">
                                <label class="form-label">Appointment Number <span class="required">*</span></label>
                                <input type="text" name="appointmentNo" class="form-control" value="<%= nextApptNo %>" readonly required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Patient Name <span class="required">*</span></label>
                                <input type="text" name="patientName" class="form-control" placeholder="e.g. Tharindu Weerasinghe" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Address <span class="required">*</span></label>
                                <input type="text" name="address" class="form-control" placeholder="e.g. 45, Flower Road, Colombo 07" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Contact Number <span class="required">*</span></label>
                                <input type="tel" name="contactNumber" class="form-control" placeholder="e.g. 077 123 4567" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Patient Email Address <span class="required">*</span></label>
                                <input type="email" name="patientEmail" class="form-control" placeholder="e.g. patient@gmail.com" required>
                                <small style="display: block; margin-top: 4px; color: var(--primary); font-size: 0.8rem; font-weight: 500;">
                                    ✉️ Appointment confirmation (date, time &amp; doctor) will be sent to this email.
                                </small>
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div>
                            <div class="form-group">
                                <label class="form-label">Dentist Name <span class="required">*</span></label>
                                <select name="dentistId" class="form-control" required>
                                    <option value="" disabled>-- Select Dentist --</option>
                                    <% if (dentists != null) { 
                                        for (Dentist d : dentists) { %>
                                        <option value="<%= d.getId() %>"><%= d.getName() %> (<%= d.getSpecialization() %>)</option>
                                    <%   } 
                                       } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Treatment Type <span class="required">*</span></label>
                                <select name="treatmentId" id="treatmentSelect" class="form-control" required>
                                    <option value="" disabled>-- Select Treatment --</option>
                                    <% if (treatments != null) { 
                                        for (Treatment t : treatments) { %>
                                        <option value="<%= t.getId() %>" data-cost="<%= t.getCost() %>"><%= t.getName() %> - Rs. <%= t.getCost() %></option>
                                    <%   } 
                                       } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Appointment Date <span class="required">*</span></label>
                                <input type="date" name="appointmentDate" class="form-control" value="<%= todayDate %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Appointment Time <span class="required">*</span></label>
                                <input type="text" name="appointmentTime" class="form-control" placeholder="e.g. 03:30 PM" value="03:30 PM" required>
                            </div>
                        </div>
                    </div>

                    <div class="form-group" style="margin-top: 10px;">
                        <label class="form-label">Clinical Notes / Comments (Optional)</label>
                        <textarea name="notes" class="form-control" rows="2" placeholder="Enter any medical history or special requests..."></textarea>
                    </div>

                    <div class="form-actions" style="justify-content: flex-start;">
                        <button type="submit" class="btn btn-primary">Save Appointment</button>
                        <button type="reset" class="btn btn-secondary">Clear</button>
                        <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-outline" style="margin-left: auto;">&larr; Back</a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
