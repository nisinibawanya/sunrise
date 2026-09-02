<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Patient" %>
<%
    request.setAttribute("activeMenu", "patients");
    List<Patient> patients = (List<Patient>) request.getAttribute("patients");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Patients - Sunrise Dental Clinic</title>
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
                <span>Patients</span>
            </nav>

            <div class="page-header">
                <h1 class="page-title">Registered Patients</h1>
            </div>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Patient Directory</h2>
                    <a href="<%= request.getContextPath() %>/appointments?action=new" class="btn btn-primary btn-sm">+ New Appointment</a>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>ID</th>
                                <th>Name</th>
                                <th>Contact Number</th>
                                <th>Address</th>
                                <th>Last Visit</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (patients != null && !patients.isEmpty()) { 
                                for (Patient p : patients) { %>
                                <tr>
                                    <td>#<%= p.getId() %></td>
                                    <td style="font-weight: 700;"><%= p.getName() %></td>
                                    <td><%= p.getContactNumber() %></td>
                                    <td><%= p.getAddress() != null ? p.getAddress() : "-" %></td>
                                    <td><%= p.getLastVisit() != null ? dateFormat.format(p.getLastVisit()) : "-" %></td>
                                </tr>
                            <%   } 
                               } else { %>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                        No patients registered yet.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
