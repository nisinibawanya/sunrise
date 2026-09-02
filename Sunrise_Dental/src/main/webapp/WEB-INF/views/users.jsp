<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.util.List, java.text.SimpleDateFormat" %>
<%@ page import="com.sunrisedental.model.User, com.sunrisedental.model.Receptionist" %>
<%
    request.setAttribute("activeMenu", "users");
    List<User> users = (List<User>) request.getAttribute("users");
    List<Receptionist> receptionists = (List<Receptionist>) request.getAttribute("receptionists");
    String nextReceptionistCode = (String) request.getAttribute("nextReceptionistCode");
    if (nextReceptionistCode == null || nextReceptionistCode.isEmpty()) {
        nextReceptionistCode = "REC-001";
    }
    User loggedInUser = (User) session.getAttribute("currentUser");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    SimpleDateFormat dateTimeFormat = new SimpleDateFormat("dd MMM yyyy, hh:mm a");
    String successParam = request.getParameter("success");
    String errorParam = request.getParameter("error");
    String codeParam = request.getParameter("code");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>User &amp; Receptionist Management - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <style>
        .rec-id-badge {
            display: inline-flex;
            align-items: center;
            gap: 4px;
            font-family: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, monospace;
            font-size: 0.85rem;
            font-weight: 700;
            padding: 3px 10px;
            border-radius: 6px;
            background: #eef2ff;
            color: #4338ca;
            border: 1px solid #c7d2fe;
            letter-spacing: 0.5px;
        }
        .info-callout {
            background: linear-gradient(135deg, #f0fdf4 0%, #e0f2fe 100%);
            border: 1px solid #bae6fd;
            border-left: 4px solid #0284c7;
            border-radius: 10px;
            padding: 16px 20px;
            margin-bottom: 24px;
            box-shadow: var(--shadow-sm);
        }
        .info-callout-title {
            font-size: 0.95rem;
            font-weight: 700;
            color: #0369a1;
            display: flex;
            align-items: center;
            gap: 8px;
            margin-bottom: 4px;
        }
        .info-callout-body {
            font-size: 0.88rem;
            color: #334155;
            line-height: 1.5;
            margin: 0;
        }
        .section-header {
            display: flex;
            justify-content: space-between;
            align-items: center;
            margin-bottom: 12px;
        }
        .section-title {
            font-size: 1.15rem;
            font-weight: 700;
            color: var(--text-dark);
            display: flex;
            align-items: center;
            gap: 8px;
        }
        .read-only-preview {
            background-color: #f1f5f9 !important;
            border-color: #cbd5e1 !important;
            color: #475569 !important;
            font-weight: 700;
            font-family: monospace;
            cursor: not-allowed;
        }
        .detail-row-grid {
            display: grid;
            grid-template-columns: 140px 1fr;
            gap: 10px;
            padding: 8px 0;
            border-bottom: 1px solid #f1f5f9;
            font-size: 0.9rem;
        }
        .detail-row-grid:last-child {
            border-bottom: none;
        }
        .detail-label-title {
            font-weight: 600;
            color: var(--text-muted);
        }
        .detail-value-text {
            color: var(--text-dark);
            font-weight: 500;
        }
    </style>
</head>
<body>
<div class="app-container">
    <jsp:include page="includes/sidebar.jsp" />

    <div class="main-wrapper">
        <jsp:include page="includes/header.jsp" />

        <main class="content-container">
            <!-- Breadcrumb Navigation -->
            <nav class="breadcrumb">
                <a href="<%= request.getContextPath() %>/dashboard">Home</a>
                <span>/</span>
                <span>User Management</span>
            </nav>

            <!-- Page Title Bar with Action Button -->
            <div class="page-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 16px;">
                <div>
                    <h1 class="page-title">User &amp; Receptionist Management</h1>
                    <p class="page-subtitle">Manage system login accounts and register unique Receptionist IDs for billing and transaction records.</p>
                </div>
                <button type="button" class="btn btn-primary" onclick="openRegisterReceptionistModal()" style="display: inline-flex; align-items: center; gap: 8px; font-weight: 600; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.25);">
                    <span style="font-size: 1.1rem;">➕</span> <span>Register New Receptionist</span>
                </button>
            </div>

            <!-- Flash Alert Notifications -->
            <% if ("receptionist_created".equals(successParam)) { %>
                <div class="alert alert-success">
                    <span>✓</span> 
                    <span>New receptionist registered successfully with ID: <strong><%= codeParam != null ? codeParam : "Generated" %></strong>!</span>
                </div>
            <% } else if ("receptionist_updated".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Receptionist profile details updated successfully!</span></div>
            <% } else if ("status_updated".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Receptionist active status toggled successfully!</span></div>
            <% } else if ("receptionist_deleted".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Receptionist record removed from directory!</span></div>
            <% } else if ("password_updated".equals(successParam)) { %>
                <div class="alert alert-success"><span>✓</span> <span>Shared receptionist account password updated successfully!</span></div>
            <% } else if ("duplicate_entry".equals(errorParam)) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>A receptionist with this contact number or email address already exists.</span></div>
            <% } else if ("required_fields".equals(errorParam)) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Please fill in all required fields (Full Name and Contact Number).</span></div>
            <% } else if ("invalid_data".equals(errorParam)) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Invalid form data submitted. Please check inputs and try again.</span></div>
            <% } else if (errorParam != null) { %>
                <div class="alert alert-danger"><span>⚠️</span> <span>Action could not be completed. Please try again.</span></div>
            <% } %>

            <!-- Business Rule Information Callout Box -->
            <div class="info-callout">
                <div class="info-callout-title">
                    <span>💡</span> <span>System Access &amp; Invoice Tracking Architecture</span>
                </div>
                <p class="info-callout-body">
                    <strong>All receptionists use the shared Receptionist login.</strong> Each receptionist is assigned a unique <strong>Receptionist ID</strong> (e.g. <code>REC-001</code>, <code>REC-002</code>) for transaction and invoice identification when creating patient appointments and issuing bills.
                </p>
            </div>

            <!-- ========================================================
                 SECTION 1: SYSTEM AUTHENTICATION ACCOUNTS (2 Fixed Roles)
                 ======================================================== -->
            <div class="card" style="margin-bottom: 30px;">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                    <div class="section-title">
                        <span>🔐</span> <span>System Login Accounts</span>
                    </div>
                    <span class="badge badge-info" style="font-size: 0.78rem;">2 Authentication Portals</span>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Account</th>
                                <th>Login Username</th>
                                <th>Role</th>
                                <th>System Email</th>
                                <th>Assigned Default ID</th>
                                <th style="text-align: center;">Account Security</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (users != null && !users.isEmpty()) {
                                for (User u : users) {
                                    boolean isAdmin = "Admin".equalsIgnoreCase(u.getRole()) || "Administrator".equalsIgnoreCase(u.getRole());
                                    boolean isCurrent = loggedInUser != null && loggedInUser.getId() == u.getId();
                            %>
                            <tr>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 10px;">
                                        <span style="font-size: 1.4rem;"><%= isAdmin ? "🛡️" : "👥" %></span>
                                        <div>
                                            <div style="font-weight: 700; color: var(--text-dark);"><%= u.getFullName() %></div>
                                            <div style="font-size: 0.75rem; color: var(--text-muted);">Account ID #<%= u.getId() %></div>
                                        </div>
                                    </div>
                                </td>
                                <td>
                                    <span style="font-weight: 700; color: var(--primary); font-family: monospace; font-size: 0.95rem;">
                                        <%= u.getUsername() %>
                                    </span>
                                    <% if (isCurrent) { %>
                                        <span class="badge badge-info" style="font-size: 0.7rem; padding: 2px 6px; margin-left: 4px;">Current Session</span>
                                    <% } %>
                                </td>
                                <td>
                                    <% if (isAdmin) { %>
                                        <span class="badge badge-danger">Admin</span>
                                    <% } else { %>
                                        <span class="badge badge-warning">Shared Receptionist</span>
                                    <% } %>
                                </td>
                                <td style="color: var(--text-muted); font-size: 0.88rem;"><%= u.getEmail() != null && !u.getEmail().isEmpty() ? u.getEmail() : "-" %></td>
                                <td>
                                    <span class="badge badge-confirmed" style="font-family: monospace; font-size: 0.82rem;">
                                        <%= u.getInvoiceNo() != null ? u.getInvoiceNo() : "INV-REC-001" %>
                                    </span>
                                </td>
                                <td style="text-align: center;">
                                    <% if (!isAdmin) { %>
                                    <button type="button" class="btn btn-sm btn-outline-primary"
                                            onclick="openChangePasswordModal(<%= u.getId() %>, '<%= u.getUsername() %>')">
                                        🔑 Change Shared Password
                                    </button>
                                    <% } else { %>
                                    <span style="font-size: 0.82rem; color: var(--text-muted); font-style: italic;">
                                        🔒 Primary Admin
                                    </span>
                                    <% } %>
                                </td>
                            </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="6" style="text-align: center; color: var(--text-muted); padding: 25px;">
                                        No login accounts loaded.
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>
            </div>

            <!-- ========================================================
                 SECTION 2: RECEPTIONIST DIRECTORY (Staff & Unique IDs)
                 ======================================================== -->
            <div class="card">
                <div class="card-header" style="display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 10px;">
                    <div class="section-title">
                        <span>📋</span> <span>Receptionist Staff Directory &amp; Assigned IDs</span>
                    </div>
                    <div>
                        <span class="badge badge-info" style="font-size: 0.82rem; font-weight: 600;">
                            <%= receptionists != null ? receptionists.size() : 0 %> Registered Receptionists
                        </span>
                    </div>
                </div>

                <div class="table-responsive">
                    <table class="custom-table">
                        <thead>
                            <tr>
                                <th>Receptionist ID</th>
                                <th>Full Name</th>
                                <th>Contact Number</th>
                                <th>Email Address</th>
                                <th>Status</th>
                                <th>Registered Date</th>
                                <th style="text-align: center;">Actions</th>
                            </tr>
                        </thead>
                        <tbody>
                            <% if (receptionists != null && !receptionists.isEmpty()) {
                                for (Receptionist r : receptionists) { %>
                                <tr>
                                    <td>
                                        <span class="rec-id-badge">
                                            🆔 <%= r.getReceptionistCode() %>
                                        </span>
                                    </td>
                                    <td style="font-weight: 700; color: var(--primary);">
                                        👩‍💼 <%= r.getFullName() %>
                                    </td>
                                    <td style="font-weight: 600;">
                                        <%= r.getContactNumber() %>
                                    </td>
                                    <td style="color: var(--text-muted); font-size: 0.88rem;">
                                        <%= r.getEmail() != null && !r.getEmail().isEmpty() ? r.getEmail() : "-" %>
                                    </td>
                                    <td>
                                        <% if (r.isActive()) { %>
                                            <span class="badge badge-confirmed">Active</span>
                                        <% } else { %>
                                            <span class="badge badge-danger">Inactive</span>
                                        <% } %>
                                    </td>
                                    <td style="font-size: 0.85rem; color: var(--text-muted);">
                                        <%= r.getCreatedAt() != null ? dateFormat.format(r.getCreatedAt()) : "Recently" %>
                                    </td>
                                    <td style="text-align: center;">
                                        <div style="display: inline-flex; gap: 6px; align-items: center;">
                                            <!-- View Details Button -->
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    onclick="openViewReceptionist(<%= r.getId() %>)"
                                                    title="View full receptionist details">
                                                👁️ View
                                            </button>

                                            <!-- Edit Details Button -->
                                            <button type="button" class="btn btn-sm btn-secondary"
                                                    onclick="openEditReceptionist(<%= r.getId() %>)"
                                                    title="Edit profile & contact details">
                                                ✏️ Edit
                                            </button>

                                            <!-- Activate / Deactivate Toggle Button -->
                                            <% if (r.isActive()) { %>
                                            <button type="button" class="btn btn-sm btn-warning"
                                                    onclick="confirmToggleStatus(<%= r.getId() %>, '<%= r.getFullName().replace("'", "\\'") %>', 'Active')"
                                                    title="Deactivate this receptionist">
                                                ⏸️ Deactivate
                                            </button>
                                            <% } else { %>
                                            <button type="button" class="btn btn-sm btn-outline-primary"
                                                    style="color: var(--success); border-color: var(--success);"
                                                    onclick="confirmToggleStatus(<%= r.getId() %>, '<%= r.getFullName().replace("'", "\\'") %>', 'Inactive')"
                                                    title="Activate this receptionist">
                                                ▶️ Activate
                                            </button>
                                            <% } %>

                                            <!-- Delete Button -->
                                            <a href="<%= request.getContextPath() %>/users?action=delete_receptionist&id=<%= r.getId() %>"
                                               class="btn btn-sm btn-danger"
                                               onclick="return confirm('Are you sure you want to permanently delete receptionist <%= r.getFullName().replace("'", "\\'") %> (<%= r.getReceptionistCode() %>)?');"
                                               title="Remove receptionist record">
                                                🗑️
                                            </a>
                                        </div>
                                    </td>
                                </tr>
                            <%  }
                               } else { %>
                                <tr>
                                    <td colspan="7" style="text-align: center; color: var(--text-muted); padding: 36px 20px;">
                                        <div style="font-size: 2rem; margin-bottom: 8px;">👩‍💼</div>
                                        <div style="font-weight: 600; margin-bottom: 4px;">No receptionists registered yet</div>
                                        <div style="font-size: 0.88rem; margin-bottom: 16px;">Click the button below to register receptionist staff with auto-generated IDs.</div>
                                        <button type="button" class="btn btn-primary" onclick="openRegisterReceptionistModal()">
                                            <span>➕</span> <span>Register New Receptionist</span>
                                        </button>
                                    </td>
                                </tr>
                            <% } %>
                        </tbody>
                    </table>
                </div>

                <div style="padding: 14px 20px; background: #f8fafc; border-top: 1px solid #e2e8f0; border-radius: 0 0 12px 12px; display: flex; justify-content: space-between; align-items: center; flex-wrap: wrap; gap: 8px;">
                    <span style="font-size: 0.82rem; color: var(--text-muted);">
                        🔒 Next auto-assigned Receptionist ID: <strong style="color: var(--primary); font-family: monospace;"><%= nextReceptionistCode %></strong>
                    </span>
                    <span style="font-size: 0.82rem; color: var(--text-muted);">
                        Note: Receptionist IDs are automatically associated with bills generated during transactions.
                    </span>
                </div>
            </div>
        </main>
    </div>
</div>

<!-- ========================================================
     MODAL 1: REGISTER NEW RECEPTIONIST
     ======================================================== -->
<div class="modal-backdrop" id="registerReceptionistModal">
    <div class="modal-box" style="max-width: 520px; text-align: left;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; border-bottom: 1px solid #f1f5f9; padding-bottom: 12px;">
            <h3 class="modal-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                <span>➕</span> <span>Register New Receptionist</span>
            </h3>
            <button type="button" style="background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--text-muted);" onclick="closeModal('registerReceptionistModal')">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/users" method="POST" id="registerReceptionistForm" onsubmit="return validateRegisterForm();">
            <input type="hidden" name="action" value="register_receptionist">

            <!-- Read-only Auto Generated ID -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" style="display: flex; justify-content: space-between; align-items: center;">
                    <span>Receptionist ID <span style="font-size: 0.78rem; font-weight: normal; color: var(--text-muted);">(System Generated)</span></span>
                    <span class="badge badge-info" style="font-size: 0.72rem;">🔒 Auto-Assigned</span>
                </label>
                <input type="text" name="receptionistCode" class="form-control read-only-preview" 
                       value="<%= nextReceptionistCode %>" readonly tabindex="-1">
                <small style="color: var(--text-muted); font-size: 0.78rem; margin-top: 4px; display: block;">
                    Unique staff code automatically assigned to this receptionist.
                </small>
            </div>

            <!-- Full Name -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Full Name <span class="required">*</span></label>
                <input type="text" name="fullName" id="regFullName" class="form-control" 
                       placeholder="e.g. Sahan Silva" required autofocus>
                <div id="regNameError" style="color: var(--danger); font-size: 0.78rem; display: none; margin-top: 2px;">Please enter full name.</div>
            </div>

            <!-- Contact Number & Status in 2-column grid -->
            <div class="grid-2" style="gap: 12px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label">Contact Number <span class="required">*</span></label>
                    <input type="tel" name="contactNumber" id="regContact" class="form-control" 
                           placeholder="e.g. 077 123 4567" required>
                    <div id="regContactError" style="color: var(--danger); font-size: 0.78rem; display: none; margin-top: 2px;">Please enter valid contact number.</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Status <span class="required">*</span></label>
                    <select name="status" class="form-control" required>
                        <option value="Active" selected>Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <!-- Email Address -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" id="regEmail" class="form-control" 
                       placeholder="e.g. sahan@sunrisedental.com">
                <div id="regEmailError" style="color: var(--danger); font-size: 0.78rem; display: none; margin-top: 2px;">Please enter a valid email format.</div>
            </div>

            <!-- Informative Banner inside modal -->
            <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 8px; padding: 10px 14px; margin-bottom: 20px; font-size: 0.82rem; color: var(--text-muted);">
                ℹ️ <em>This registration will create a staff profile. Receptionists log into the system using the clinic's shared <code>receptionist</code> credentials.</em>
            </div>

            <div class="form-actions" style="justify-content: flex-end; gap: 10px; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('registerReceptionistModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Register Receptionist</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================
     MODAL 2: EDIT RECEPTIONIST
     ======================================================== -->
<div class="modal-backdrop" id="editReceptionistModal">
    <div class="modal-box" style="max-width: 520px; text-align: left;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 18px; border-bottom: 1px solid #f1f5f9; padding-bottom: 12px;">
            <h3 class="modal-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                <span>✏️</span> <span>Edit Receptionist Profile</span>
            </h3>
            <button type="button" style="background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--text-muted);" onclick="closeModal('editReceptionistModal')">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/users" method="POST" id="editReceptionistForm" onsubmit="return validateEditForm();">
            <input type="hidden" name="action" value="update_receptionist">
            <input type="hidden" name="id" id="editRecId">

            <!-- Read-only Receptionist ID -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label" style="display: flex; justify-content: space-between; align-items: center;">
                    <span>Receptionist ID</span>
                    <span class="badge badge-info" style="font-size: 0.72rem;">🔒 Fixed Identifier</span>
                </label>
                <input type="text" id="editRecCode" class="form-control read-only-preview" readonly tabindex="-1">
            </div>

            <!-- Full Name -->
            <div class="form-group" style="margin-bottom: 16px;">
                <label class="form-label">Full Name <span class="required">*</span></label>
                <input type="text" name="fullName" id="editRecFullName" class="form-control" required>
                <div id="editNameError" style="color: var(--danger); font-size: 0.78rem; display: none; margin-top: 2px;">Please enter full name.</div>
            </div>

            <!-- Contact Number & Status -->
            <div class="grid-2" style="gap: 12px; margin-bottom: 16px;">
                <div class="form-group">
                    <label class="form-label">Contact Number <span class="required">*</span></label>
                    <input type="tel" name="contactNumber" id="editRecContact" class="form-control" required>
                    <div id="editContactError" style="color: var(--danger); font-size: 0.78rem; display: none; margin-top: 2px;">Please enter valid contact number.</div>
                </div>

                <div class="form-group">
                    <label class="form-label">Status <span class="required">*</span></label>
                    <select name="status" id="editRecStatus" class="form-control" required>
                        <option value="Active">Active</option>
                        <option value="Inactive">Inactive</option>
                    </select>
                </div>
            </div>

            <!-- Email Address -->
            <div class="form-group" style="margin-bottom: 20px;">
                <label class="form-label">Email Address</label>
                <input type="email" name="email" id="editRecEmail" class="form-control">
            </div>

            <div class="form-actions" style="justify-content: flex-end; gap: 10px; margin-top: 20px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('editReceptionistModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Save Changes</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================
     MODAL 3: VIEW RECEPTIONIST DETAILS
     ======================================================== -->
<div class="modal-backdrop" id="viewReceptionistModal">
    <div class="modal-box" style="max-width: 480px; text-align: left;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 12px;">
            <h3 class="modal-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                <span>👩‍💼</span> <span>Receptionist Profile</span>
            </h3>
            <button type="button" style="background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--text-muted);" onclick="closeModal('viewReceptionistModal')">&times;</button>
        </div>

        <div style="background: #f8fafc; border: 1px solid #e2e8f0; border-radius: 10px; padding: 16px; margin-bottom: 18px;">
            <div class="detail-row-grid">
                <span class="detail-label-title">Receptionist ID</span>
                <span class="detail-value-text"><span class="rec-id-badge" id="viewRecCode">REC-001</span></span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Full Name</span>
                <span class="detail-value-text" id="viewRecFullName" style="font-weight: 700; color: var(--primary);">-</span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Contact Number</span>
                <span class="detail-value-text" id="viewRecContact">-</span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Email Address</span>
                <span class="detail-value-text" id="viewRecEmail">-</span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Status</span>
                <span class="detail-value-text" id="viewRecStatusBadge">-</span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Registered Date</span>
                <span class="detail-value-text" id="viewRecCreatedAt">-</span>
            </div>
            <div class="detail-row-grid">
                <span class="detail-label-title">Last Updated</span>
                <span class="detail-value-text" id="viewRecUpdatedAt">-</span>
            </div>
        </div>

        <div class="form-actions" style="justify-content: flex-end; gap: 10px;">
            <button type="button" class="btn btn-secondary" onclick="closeModal('viewReceptionistModal')">Close</button>
            <button type="button" class="btn btn-primary" id="viewEditQuickBtn">✏️ Edit Profile</button>
        </div>
    </div>
</div>

<!-- ========================================================
     MODAL 4: CHANGE SHARED RECEPTIONIST PASSWORD
     ======================================================== -->
<div class="modal-backdrop" id="changePasswordModal">
    <div class="modal-box" style="max-width: 440px; text-align: left;">
        <div style="display: flex; justify-content: space-between; align-items: center; margin-bottom: 16px; border-bottom: 1px solid #f1f5f9; padding-bottom: 12px;">
            <h3 class="modal-title" style="margin: 0; display: flex; align-items: center; gap: 8px;">
                <span>🔑</span> <span>Change Shared Password</span>
            </h3>
            <button type="button" style="background: none; border: none; font-size: 1.25rem; cursor: pointer; color: var(--text-muted);" onclick="closeModal('changePasswordModal')">&times;</button>
        </div>

        <form action="<%= request.getContextPath() %>/users" method="POST">
            <input type="hidden" name="action" value="change_password">
            <input type="hidden" name="id" id="pwdUserId">

            <div style="background: #f0fdf4; border: 1px solid #bbf7d0; border-radius: 8px; padding: 12px 16px; margin-bottom: 18px;">
                <p style="margin: 0; font-size: 0.88rem; color: #166534;">
                    🔒 Account: <strong>Shared Receptionist</strong><br>
                    <strong>Username:</strong> <code id="pwdUsernameDisplay">receptionist</code>
                </p>
            </div>

            <div class="form-group" style="margin-bottom: 20px;">
                <label class="form-label">New Shared Password <span class="required">*</span></label>
                <input type="password" name="password" id="newSharedPassword" class="form-control" 
                       placeholder="Enter new password" required autocomplete="new-password">
                <small style="color: var(--text-muted); font-size: 0.78rem; margin-top: 4px; display: block;">
                    All front-desk receptionists will use this new password to sign in.
                </small>
            </div>

            <div class="form-actions" style="justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('changePasswordModal')">Cancel</button>
                <button type="submit" class="btn btn-primary">Update Password</button>
            </div>
        </form>
    </div>
</div>

<!-- ========================================================
     MODAL 5: TOGGLE STATUS CONFIRMATION
     ======================================================== -->
<div class="modal-backdrop" id="toggleStatusModal">
    <div class="modal-box" style="max-width: 440px; text-align: left;">
        <h3 class="modal-title" style="margin-bottom: 14px; display: flex; align-items: center; gap: 8px;" id="toggleStatusTitle">
            <span>🔄</span> <span>Confirm Status Change</span>
        </h3>
        <p style="font-size: 0.92rem; color: var(--text-dark); line-height: 1.5; margin-bottom: 20px;" id="toggleStatusMessage">
            Are you sure you want to change the status of this receptionist?
        </p>

        <form action="<%= request.getContextPath() %>/users" method="POST" id="toggleStatusForm">
            <input type="hidden" name="action" value="toggle_status">
            <input type="hidden" name="id" id="toggleStatusId">
            <input type="hidden" name="status" id="toggleStatusTarget">

            <div class="form-actions" style="justify-content: flex-end; gap: 10px;">
                <button type="button" class="btn btn-secondary" onclick="closeModal('toggleStatusModal')">Cancel</button>
                <button type="submit" class="btn btn-primary" id="toggleConfirmSubmitBtn">Confirm</button>
            </div>
        </form>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />

<!-- ========================================================
     CLIENT DATA & JAVASCRIPT CONTROLLERS
     ======================================================== -->
<script>
// JSON cache for receptionists
var receptionistData = {
<% if (receptionists != null && !receptionists.isEmpty()) {
    boolean first = true;
    for (Receptionist r : receptionists) {
        if (!first) out.print(",");
        first = false;
        String rCode = r.getReceptionistCode() != null ? r.getReceptionistCode().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String rName = r.getFullName() != null ? r.getFullName().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String rContact = r.getContactNumber() != null ? r.getContactNumber().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String rEmail = r.getEmail() != null ? r.getEmail().replace("\\", "\\\\").replace("\"", "\\\"") : "";
        String rStatus = r.getStatus() != null ? r.getStatus().replace("\\", "\\\\").replace("\"", "\\\"") : "Active";
        String rCreated = r.getCreatedAt() != null ? dateTimeFormat.format(r.getCreatedAt()) : "-";
        String rUpdated = r.getUpdatedAt() != null ? dateTimeFormat.format(r.getUpdatedAt()) : "-";
%>
    "<%= r.getId() %>": {
        "id": <%= r.getId() %>,
        "code": "<%= rCode %>",
        "name": "<%= rName %>",
        "contact": "<%= rContact %>",
        "email": "<%= rEmail %>",
        "status": "<%= rStatus %>",
        "createdAt": "<%= rCreated %>",
        "updatedAt": "<%= rUpdated %>"
    }<%
    }
} %>
};

// Modal helpers
function openModal(id) {
    var el = document.getElementById(id);
    if (el) el.classList.add('active');
}

function closeModal(id) {
    var el = document.getElementById(id);
    if (el) el.classList.remove('active');
}

// 1. Open Register Modal
function openRegisterReceptionistModal() {
    var form = document.getElementById('registerReceptionistForm');
    if (form) form.reset();
    document.getElementById('regNameError').style.display = 'none';
    document.getElementById('regContactError').style.display = 'none';
    document.getElementById('regEmailError').style.display = 'none';
    openModal('registerReceptionistModal');
    setTimeout(function() {
        var input = document.getElementById('regFullName');
        if (input) input.focus();
    }, 150);
}

// 2. Open Edit Modal
function openEditReceptionist(id) {
    var r = receptionistData[String(id)];
    if (!r) { alert('Could not find receptionist data.'); return; }
    document.getElementById('editRecId').value = r.id;
    document.getElementById('editRecCode').value = r.code;
    document.getElementById('editRecFullName').value = r.name;
    document.getElementById('editRecContact').value = r.contact;
    document.getElementById('editRecEmail').value = r.email;
    document.getElementById('editRecStatus').value = r.status;
    document.getElementById('editNameError').style.display = 'none';
    document.getElementById('editContactError').style.display = 'none';
    closeModal('viewReceptionistModal');
    openModal('editReceptionistModal');
}

// 3. Open View Modal
function openViewReceptionist(id) {
    var r = receptionistData[String(id)];
    if (!r) { alert('Could not find receptionist data.'); return; }
    document.getElementById('viewRecCode').innerText = r.code;
    document.getElementById('viewRecFullName').innerText = r.name;
    document.getElementById('viewRecContact').innerText = r.contact;
    document.getElementById('viewRecEmail').innerText = r.email ? r.email : "(Not provided)";
    
    var statusEl = document.getElementById('viewRecStatusBadge');
    if (r.status.toLowerCase() === 'active') {
        statusEl.innerHTML = '<span class="badge badge-confirmed">Active</span>';
    } else {
        statusEl.innerHTML = '<span class="badge badge-danger">Inactive</span>';
    }
    
    document.getElementById('viewRecCreatedAt').innerText = r.createdAt;
    document.getElementById('viewRecUpdatedAt').innerText = r.updatedAt;

    var editBtn = document.getElementById('viewEditQuickBtn');
    editBtn.onclick = function() {
        openEditReceptionist(r.id);
    };

    openModal('viewReceptionistModal');
}

// 4. Open Change Password Modal
function openChangePasswordModal(userId, username) {
    document.getElementById('pwdUserId').value = userId;
    document.getElementById('pwdUsernameDisplay').innerText = username;
    document.getElementById('newSharedPassword').value = '';
    openModal('changePasswordModal');
    setTimeout(function() {
        var p = document.getElementById('newSharedPassword');
        if (p) p.focus();
    }, 150);
}

// 5. Confirm Toggle Status
function confirmToggleStatus(id, name, currentStatus) {
    var isCurrentlyActive = (currentStatus.toLowerCase() === 'active');
    var targetStatus = isCurrentlyActive ? 'Inactive' : 'Active';
    
    document.getElementById('toggleStatusId').value = id;
    document.getElementById('toggleStatusTarget').value = targetStatus;
    
    var titleEl = document.getElementById('toggleStatusTitle');
    var msgEl = document.getElementById('toggleStatusMessage');
    var btnEl = document.getElementById('toggleConfirmSubmitBtn');
    
    if (isCurrentlyActive) {
        titleEl.innerHTML = '<span>⏸️</span> <span>Deactivate Receptionist</span>';
        msgEl.innerHTML = 'Are you sure you want to <strong>deactivate</strong> receptionist <strong>' + escapeHtml(name) + '</strong>? This receptionist will be marked as inactive.';
        btnEl.className = 'btn btn-warning';
        btnEl.innerText = 'Yes, Deactivate';
    } else {
        titleEl.innerHTML = '<span>▶️</span> <span>Activate Receptionist</span>';
        msgEl.innerHTML = 'Are you sure you want to <strong>activate</strong> receptionist <strong>' + escapeHtml(name) + '</strong>?';
        btnEl.className = 'btn btn-primary';
        btnEl.innerText = 'Yes, Activate';
    }
    
    openModal('toggleStatusModal');
}

// Validation helpers
function validateRegisterForm() {
    var name = document.getElementById('regFullName').value.trim();
    var contact = document.getElementById('regContact').value.trim();
    var email = document.getElementById('regEmail').value.trim();
    var isValid = true;

    if (!name) {
        document.getElementById('regNameError').style.display = 'block';
        isValid = false;
    } else {
        document.getElementById('regNameError').style.display = 'none';
    }

    if (!contact || contact.length < 7) {
        document.getElementById('regContactError').style.display = 'block';
        isValid = false;
    } else {
        document.getElementById('regContactError').style.display = 'none';
    }

    if (email && !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
        document.getElementById('regEmailError').style.display = 'block';
        isValid = false;
    } else {
        document.getElementById('regEmailError').style.display = 'none';
    }

    return isValid;
}

function validateEditForm() {
    var name = document.getElementById('editRecFullName').value.trim();
    var contact = document.getElementById('editRecContact').value.trim();
    var isValid = true;

    if (!name) {
        document.getElementById('editNameError').style.display = 'block';
        isValid = false;
    } else {
        document.getElementById('editNameError').style.display = 'none';
    }

    if (!contact || contact.length < 7) {
        document.getElementById('editContactError').style.display = 'block';
        isValid = false;
    } else {
        document.getElementById('editContactError').style.display = 'none';
    }

    return isValid;
}

function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}

// Close modals when clicking background overlay
['registerReceptionistModal', 'editReceptionistModal', 'viewReceptionistModal', 'changePasswordModal', 'toggleStatusModal'].forEach(function(modalId) {
    var el = document.getElementById(modalId);
    if (el) {
        el.addEventListener('click', function(e) {
            if (e.target === el) closeModal(modalId);
        });
    }
});
</script>
</body>
</html>
