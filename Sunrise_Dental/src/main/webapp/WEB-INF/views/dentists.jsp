<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.Dentist" %>
<%
    request.setAttribute("activeMenu", "dentists");
    List<Dentist> dentists = (List<Dentist>) request.getAttribute("dentists");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dentists - Sunrise Dental Clinic</title>
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
                <span>Dentists</span>
            </nav>

            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 class="page-title">Dental Medical Staff</h1>
                    <p class="page-subtitle">Manage clinic dentists, specializations, room allocations, and schedules.</p>
                </div>
                <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                <button type="button" class="btn btn-primary" onclick="openAddDentist()">
                    <span>➕</span> <span>Add New Dentist</span>
                </button>
                <% } %>
            </div>

            <!-- Flash Alerts -->
            <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Dentist profile added successfully!</span></div>
            <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Dentist details updated successfully!</span></div>
            <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Dentist record removed successfully!</span></div>
            <% } else if ("delete_failed".equals(errorParam)) { %>
                <div class="alert alert-warning"><span>⚠️</span> <span>Could not delete: this dentist has existing appointments.</span></div>
            <% } else if (errorParam != null) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Action failed. Please check your data and try again.</span></div>
            <% } %>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Registered Dentists</h2>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Dentist Name</th>
                                <th>Specialization</th>
                                <th>Contact Number</th>
                                <th>Email</th>
                                <th>Room No</th>
                                <th>Status</th>
                                <th>Last Updated</th>
                                <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                                <th style="text-align: center;">Actions</th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (dentists != null && !dentists.isEmpty()) {
                                for (Dentist d : dentists) { %>
                                <tr>
                                    <td><%= d.getId() %></td>
                                    <td style="font-weight: 700; color: var(--primary);">👨‍⚕️ <%= d.getName() %></td>
                                    <td><%= d.getSpecialization() != null ? d.getSpecialization() : "-" %></td>
                                    <td><%= d.getContactNumber() != null ? d.getContactNumber() : "-" %></td>
                                    <td><%= d.getEmail() != null && !d.getEmail().isEmpty() ? d.getEmail() : "-" %></td>
                                    <td><span class="badge" style="background: #f1f5f9; color: var(--text-dark); font-weight: 600;"><%= d.getRoomNo() != null ? d.getRoomNo() : "Room 1" %></span></td>
                                    <td>
                                        <% if (d.isActive()) { %>
                                            <span class="badge badge-confirmed">Active</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Inactive</span>
                                        <% } %>
                                    </td>
                                    <td style="font-size: 0.85rem; color: var(--text-muted);">
                                        <%= d.getUpdatedAt() != null ? dateTimeFormat.format(d.getUpdatedAt()) : "Recently" %>
                                    </td>
                                    <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                                    <td style="text-align: center;">
                                        <div style="display: inline-flex; gap: 6px;">
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    onclick="openEditDentist(<%= d.getId() %>)">
                                                ✏️ Edit
                                            </button>
                                            <a href="<%= request.getContextPath() %>/dentists?action=delete&id=<%= d.getId() %>"
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Are you sure you want to remove Dr. <%= d.getName().replace("'", "\\'") %>?');">
                                                🗑️ Delete
                                            </a>
                                        </div>
                                    </td>
                                    <% } %>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="9" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                        No dentists registered. Click "Add New Dentist" to register doctors.
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

<!-- ====== ADD DENTIST MODAL ====== -->
<div class="modal-backdrop" id="addDentistModal">
    <div class="modal-box" style="max-width: 500px; text-align: left;">
        <h3 class="modal-title" style="margin-bottom: 20px;">👨‍⚕️ Add New Dentist</h3>
        <form action="<%= request.getContextPath() %>/dentists" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label class="form-label">Full Name <span class="required">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="e.g. Dr. Kamal Perera" required>
            </div>
            <div class="form-group">
                <label class="form-label">Specialization <span class="required">*</span></label>
                <input type="text" name="specialization" class="form-control" placeholder="e.g. Orthodontist" required>
            </div>
            <div class="form-group">
                <label class="form-label">Contact Number <span class="required">*</span></label>
                <input type="tel" name="contactNumber" class="form-control" placeholder="e.g. 077 111 2233" required>
            </div>
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" class="form-control" placeholder="e.g. doctor@sunrisedental.com">
            </div>
            <div class="form-group">
                <label class="form-label">Room Allocation <span class="required">*</span></label>
                <input type="text" name="roomNo" class="form-control" placeholder="e.g. Room 101" value="Room 101" required>
            </div>

            <div class="form-actions" style="justify-content: flex-end; margin-top: 24px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('addDentistModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Dentist</button>
            </div>
        </form>
    </div>
</div>

<!-- ====== EDIT DENTIST MODAL ====== -->
<div class="modal-backdrop" id="editDentistModal">
    <div class="modal-box" style="max-width: 500px; text-align: left;">
        <h3 class="modal-title" style="margin-bottom: 20px;">✏️ Edit Dentist Details</h3>
        <form action="<%= request.getContextPath() %>/dentists" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editDentistId">

            <div class="form-group">
                <label class="form-label">Full Name <span class="required">*</span></label>
                <input type="text" name="name" id="editDentistName" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="form-label">Specialization <span class="required">*</span></label>
                <input type="text" name="specialization" id="editDentistSpec" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="form-label">Contact Number <span class="required">*</span></label>
                <input type="tel" name="contactNumber" id="editDentistContact" class="form-control" required>
            </div>
            <div class="form-group">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" id="editDentistEmail" class="form-control">
            </div>
            <div class="grid-2" style="gap: 12px;">
                <div class="form-group">
                    <label class="form-label">Room Allocation <span class="required">*</span></label>
                    <input type="text" name="roomNo" id="editDentistRoom" class="form-control" placeholder="e.g. Room 101" required>
                </div>
                <div class="form-group">
                    <label class="form-label">Status</label>
                    <select name="active" id="editDentistActive" class="form-control">
                        <option value="true">Active</option>
                        <option value="false">Inactive</option>
                    </select>
                </div>
            </div>

            <div class="form-group" id="editDentistTimeGroup" style="display: none; margin-top: 5px;">
                <label class="form-label" style="font-size: 0.82rem; color: var(--text-muted);">Last Updated Date &amp; Time</label>
                <div id="editDentistUpdatedDisplay" style="font-size: 0.88rem; color: var(--primary); font-weight: 600; padding: 6px 12px; background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 6px;"></div>
            </div>

            <div class="form-actions" style="justify-content: flex-end; margin-top: 24px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('editDentistModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Update Dentist</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />

<!-- ====== DENTIST DATA for JavaScript (safe JSON) ====== -->
<script>
var dentistData = {
<% if (dentists != null && !dentists.isEmpty()) {
    boolean first = true;
    for (Dentist d : dentists) {
        if (!first) out.print(",");
        first = false;
        String dName = d.getName().replace("\\", "\\\\").replace("\"", "\\\"");
        String dSpec = d.getSpecialization() != null ? d.getSpecialization().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String dContact = d.getContactNumber() != null ? d.getContactNumber().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String dEmail = d.getEmail() != null ? d.getEmail().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String dRoom = d.getRoomNo() != null ? d.getRoomNo().replace("\\", "\\\\").replace("\"", "\\\"") : "Room 1";
        String dTime = d.getUpdatedAt() != null ? dateTimeFormat.format(d.getUpdatedAt()) : "";
%>
    "<%= d.getId() %>": {
        "id": "<%= d.getId() %>",
        "name": "<%= dName %>",
        "spec": "<%= dSpec %>",
        "contact": "<%= dContact %>",
        "email": "<%= dEmail %>",
        "room": "<%= dRoom %>",
        "active": "<%= d.isActive() %>",
        "updatedAt": "<%= dTime %>"
    }<%
    }
} %>
};

function openAddDentist() {
    document.getElementById('addDentistModal').classList.add('active');
}

function openEditDentist(id) {
    var d = dentistData[String(id)];
    if (!d) { alert('Could not load dentist data.'); return; }
    document.getElementById('editDentistId').value = d.id;
    document.getElementById('editDentistName').value = d.name;
    document.getElementById('editDentistSpec').value = d.spec;
    document.getElementById('editDentistContact').value = d.contact;
    document.getElementById('editDentistEmail').value = d.email;
    document.getElementById('editDentistRoom').value = d.room ? d.room : "Room 1";
    document.getElementById('editDentistActive').value = d.active;

    var timeGroup = document.getElementById('editDentistTimeGroup');
    var timeDisplay = document.getElementById('editDentistUpdatedDisplay');
    if (d.updatedAt && d.updatedAt.trim() !== '') {
        timeGroup.style.display = 'block';
        timeDisplay.innerText = '🕒 ' + d.updatedAt;
    } else {
        timeGroup.style.display = 'none';
    }

    document.getElementById('editDentistModal').classList.add('active');
}

function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}

// Close modals on backdrop click
['addDentistModal', 'editDentistModal'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) closeModal(id);
        });
    }
});
</script>
</body>
</html>
