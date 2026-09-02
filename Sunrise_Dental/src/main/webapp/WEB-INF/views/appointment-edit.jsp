<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.sunrisedental.model.Appointment, com.sunrisedental.model.Dentist, com.sunrisedental.model.Treatment" %>
<%
    request.setAttribute("activeMenu", "appointment-search");
    Appointment appt = (Appointment) request.getAttribute("appointment");
    List<Dentist> dentists = (List<Dentist>) request.getAttribute("dentists");
    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Edit Appointment - Sunrise Dental Clinic</title>
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
                <a href="<%= request.getContextPath() %>/appointments?action=search&no=<%= appt.getAppointmentNo() %>">Appointment</a>
                <span>/</span>
                <span>Edit</span>
            </nav>

            <div class="page-header">
                <h1 class="page-title">Edit Appointment <%= appt.getAppointmentNo() %></h1>
            </div>

            <div class="card">
                <form action="<%= request.getContextPath() %>/appointments" method="POST">
                    <input type="hidden" name="action" value="update">
                    <input type="hidden" name="id" value="<%= appt.getId() %>">
                    <input type="hidden" name="appointmentNo" value="<%= appt.getAppointmentNo() %>">
                    <input type="hidden" name="patientId" value="<%= appt.getPatientId() %>">

                    <div class="grid-2">
                        <!-- Left Column -->
                        <div>
                            <div class="form-group">
                                <label class="form-label">Appointment Number</label>
                                <input type="text" class="form-control" value="<%= appt.getAppointmentNo() %>" readonly>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Patient Name <span class="required">*</span></label>
                                <input type="text" name="patientName" class="form-control" value="<%= appt.getPatientName() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Address <span class="required">*</span></label>
                                <input type="text" name="address" class="form-control" value="<%= appt.getPatientAddress() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Contact Number <span class="required">*</span></label>
                                <input type="tel" name="contactNumber" class="form-control" value="<%= appt.getPatientContact() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Patient Email Address</label>
                                <input type="email" name="patientEmail" class="form-control" value="<%= appt.getPatientEmail() != null ? appt.getPatientEmail() : "" %>" placeholder="patient@gmail.com">
                            </div>
                        </div>

                        <!-- Right Column -->
                        <div>
                            <div class="form-group">
                                <label class="form-label">Dentist Name <span class="required">*</span></label>
                                <select name="dentistId" class="form-control" required>
                                    <% if (dentists != null) { 
                                        for (Dentist d : dentists) { %>
                                        <option value="<%= d.getId() %>" <%= d.getId() == appt.getDentistId() ? "selected" : "" %>>
                                            <%= d.getName() %> (<%= d.getSpecialization() %>)
                                        </option>
                                    <%   } 
                                       } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Treatment Type <span class="required">*</span></label>
                                <select name="treatmentId" class="form-control" required>
                                    <% if (treatments != null) { 
                                        for (Treatment t : treatments) { %>
                                        <option value="<%= t.getId() %>" <%= t.getId() == appt.getTreatmentId() ? "selected" : "" %>>
                                            <%= t.getName() %> - Rs. <%= t.getCost() %>
                                        </option>
                                    <%   } 
                                       } %>
                                </select>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Appointment Date <span class="required">*</span></label>
                                <input type="date" name="appointmentDate" class="form-control" value="<%= appt.getAppointmentDate() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Appointment Time <span class="required">*</span></label>
                                <input type="text" name="appointmentTime" class="form-control" value="<%= appt.getAppointmentTime() %>" required>
                            </div>

                            <div class="form-group">
                                <label class="form-label">Status</label>
                                <select name="status" class="form-control">
                                    <option value="Confirmed" <%= "Confirmed".equalsIgnoreCase(appt.getStatus()) ? "selected" : "" %>>Confirmed</option>
                                    <option value="Pending" <%= "Pending".equalsIgnoreCase(appt.getStatus()) ? "selected" : "" %>>Pending</option>
                                    <option value="Completed" <%= "Completed".equalsIgnoreCase(appt.getStatus()) ? "selected" : "" %>>Completed</option>
                                    <option value="Cancelled" <%= "Cancelled".equalsIgnoreCase(appt.getStatus()) ? "selected" : "" %>>Cancelled</option>
                                </select>
                            </div>
                        </div>
                    </div>

                    <div class="form-group">
                        <label class="form-label">Clinical Notes</label>
                        <textarea name="notes" class="form-control" rows="2"><%= appt.getNotes() != null ? appt.getNotes() : "" %></textarea>
                    </div>

                    <div class="form-actions">
                        <button type="submit" class="btn btn-primary">Update Appointment</button>
                        <a href="<%= request.getContextPath() %>/appointments?action=search&no=<%= appt.getAppointmentNo() %>" class="btn btn-outline">Cancel</a>
                    </div>
                </form>
            </div>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
