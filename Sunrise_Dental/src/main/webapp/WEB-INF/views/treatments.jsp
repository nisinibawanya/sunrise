<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List" %>
<%@ page import="com.sunrisedental.model.Treatment" %>
<%
    request.setAttribute("activeMenu", "treatments");
    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Treatments - Sunrise Dental Clinic</title>
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
                <span>Treatments</span>
            </nav>

            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center;">
                <div>
                    <h1 class="page-title">Dental Treatments &amp; Services</h1>
                    <p class="page-subtitle">Manage treatment catalog, service descriptions, and standard pricing.</p>
                </div>
                <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                <button type="button" class="btn btn-primary" id="openAddTreatmentBtn">
                    <span>➕</span> <span>Add New Treatment</span>
                </button>
                <% } %>
            </div>

            <!-- Flash Alerts -->
            <% if ("created".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Treatment added successfully!</span></div>
            <% } else if ("updated".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Treatment updated successfully!</span></div>
            <% } else if ("deleted".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Treatment deleted successfully!</span></div>
            <% } else if ("delete_failed_appointments".equals(errorParam)) { %>
                <div class="alert alert-warning"><span>⚠️</span> <span>Cannot delete: this treatment has existing appointments linked to it.</span></div>
            <% } else if ("invalid_cost".equals(errorParam)) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Invalid cost value. Please enter a valid number (e.g. 3500.00).</span></div>
            <% } else if (errorParam != null) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Action failed. Please try again.</span></div>
            <% } %>

            <div class="card">
                <div class="card-header">
                    <h2 class="card-title">Treatments &amp; Pricing Catalog</h2>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>#</th>
                                <th>Treatment Name</th>
                                <th>Procedure Description</th>
                                <th style="text-align: right;">Standard Fee</th>
                                <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                                <th style="text-align: center;">Actions</th>
                                <% } %>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (treatments != null && !treatments.isEmpty()) {
                                for (Treatment t : treatments) { %>
                                <tr>
                                    <td><%= t.getId() %></td>
                                    <td style="font-weight: 700; color: var(--primary);">✂️ <%= t.getName() %></td>
                                    <td style="color: var(--text-muted); max-width: 300px;">
                                        <%= t.getDescription() != null && !t.getDescription().isEmpty() ? t.getDescription() : "-" %>
                                    </td>
                                    <td style="text-align: right; font-weight: 700; color: #065f46;">
                                        Rs. <%= String.format("%,.2f", t.getCost()) %>
                                    </td>
                                    <% if ("Admin".equalsIgnoreCase((String) session.getAttribute("userRole"))) { %>
                                    <td style="text-align: center;">
                                        <div style="display: inline-flex; gap: 6px;">
                                            <button type="button" class="btn btn-sm btn-outline-primary edit-treatment-btn"
                                                    data-id="<%= t.getId() %>"
                                                    data-name="<%= t.getName().replace("\"", "&quot;") %>"
                                                    data-cost="<%= t.getCost() %>"
                                                    data-description="<%= t.getDescription() != null ? t.getDescription().replace("\"", "&quot;") : "" %>">
                                                ✏️ Edit
                                            </button>
                                            <a href="<%= request.getContextPath() %>/treatments?action=delete&id=<%= t.getId() %>"
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Delete treatment \'<%= t.getName() %>\'? This cannot be undone.');">
                                                🗑️ Delete
                                            </a>
                                        </div>
                                    </td>
                                    <% } %>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="5" style="text-align: center; color: var(--text-muted); padding: 30px;">
                                        No treatments registered. Click "Add New Treatment" to create one.
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

<!-- ====== ADD TREATMENT MODAL ====== -->
<div class="modal-backdrop" id="addTreatmentModal">
    <div class="modal-box" style="max-width: 480px; text-align: left;">
        <h3 class="modal-title" style="margin-bottom: 20px;">✂️ Add New Treatment / Service</h3>
        <form action="<%= request.getContextPath() %>/treatments" method="POST">
            <input type="hidden" name="action" value="create">

            <div class="form-group">
                <label class="form-label">Treatment / Service Name <span class="required">*</span></label>
                <input type="text" name="name" class="form-control" placeholder="e.g. Dental Scaling" required>
            </div>

            <div class="form-group">
                <label class="form-label">Standard Fee (Rs.) <span class="required">*</span></label>
                <input type="number" name="cost" class="form-control" step="0.01" min="0" placeholder="e.g. 3500.00" required>
            </div>

            <div class="form-group">
                <label class="form-label">Procedure Description</label>
                <textarea name="description" class="form-control" rows="3" placeholder="Brief description of the procedure..."></textarea>
            </div>

            <div class="form-actions" style="justify-content: flex-end; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" id="closeAddTreatmentBtn">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Treatment</button>
            </div>
        </form>
    </div>
</div>

<!-- ====== EDIT TREATMENT MODAL ====== -->
<div class="modal-backdrop" id="editTreatmentModal">
    <div class="modal-box" style="max-width: 480px; text-align: left;">
        <h3 class="modal-title" style="margin-bottom: 20px;">✏️ Edit Treatment / Service</h3>
        <form action="<%= request.getContextPath() %>/treatments" method="POST">
            <input type="hidden" name="action" value="update">
            <input type="hidden" name="id" id="editTreatmentId">

            <div class="form-group">
                <label class="form-label">Treatment / Service Name <span class="required">*</span></label>
                <input type="text" name="name" id="editTreatmentName" class="form-control" required>
            </div>

            <div class="form-group">
                <label class="form-label">Standard Fee (Rs.) <span class="required">*</span></label>
                <input type="number" name="cost" id="editTreatmentCost" class="form-control" step="0.01" min="0" required>
            </div>

            <div class="form-group">
                <label class="form-label">Procedure Description</label>
                <textarea name="description" id="editTreatmentDescription" class="form-control" rows="3"></textarea>
            </div>

            <div class="form-actions" style="justify-content: flex-end; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" id="closeEditTreatmentBtn">Cancel</button>
                <button type="submit" class="btn btn-primary">Update Treatment</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />

<!-- ====== TREATMENT DATA for JavaScript (safe JSON) ====== -->
<script>
var treatmentData = {
<% if (treatments != null && !treatments.isEmpty()) {
    boolean first = true;
    for (Treatment t : treatments) {
        if (!first) out.print(",");
        first = false;
        String tName = t.getName().replace("\\", "\\\\").replace("\"", "\\\"");
        String tDesc = t.getDescription() != null ? t.getDescription().replace("\\", "\\\\").replace("\"", "\\\"") : "";
%>
    "<%= t.getId() %>": {
        "id": "<%= t.getId() %>",
        "name": "<%= tName %>",
        "cost": "<%= t.getCost() %>",
        "description": "<%= tDesc %>"
    }<%
    }
} %>
};

function closeModal(id) {
    document.getElementById(id).classList.remove('active');
}

// Add Treatment (Admin only)
var openAddBtn = document.getElementById('openAddTreatmentBtn');
if (openAddBtn) {
    openAddBtn.addEventListener('click', function() {
        document.getElementById('addTreatmentModal').classList.add('active');
    });
}
var closeAddBtn = document.getElementById('closeAddTreatmentBtn');
if (closeAddBtn) {
    closeAddBtn.addEventListener('click', function() {
        closeModal('addTreatmentModal');
    });
}

// Edit Treatment (Admin only)
document.querySelectorAll('.edit-treatment-btn').forEach(function(btn) {
    btn.addEventListener('click', function() {
        var id = btn.getAttribute('data-id');
        var t = treatmentData[String(id)];
        if (!t) { alert('Could not load treatment data.'); return; }
        document.getElementById('editTreatmentId').value = t.id;
        document.getElementById('editTreatmentName').value = t.name;
        document.getElementById('editTreatmentCost').value = t.cost;
        document.getElementById('editTreatmentDescription').value = t.description;
        document.getElementById('editTreatmentModal').classList.add('active');
    });
});
var closeEditBtn = document.getElementById('closeEditTreatmentBtn');
if (closeEditBtn) {
    closeEditBtn.addEventListener('click', function() {
        closeModal('editTreatmentModal');
    });
}

// Backdrop click to close
['addTreatmentModal', 'editTreatmentModal'].forEach(function(id) {
    var el = document.getElementById(id);
    if (el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) closeModal(id);
        });
    }
});
</script>
