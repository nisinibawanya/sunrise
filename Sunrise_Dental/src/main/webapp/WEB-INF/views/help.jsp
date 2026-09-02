<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    request.setAttribute("activeMenu", "help");
    String activeTopic = (String) request.getAttribute("activeTopic");
    if (activeTopic == null || activeTopic.trim().isEmpty()) {
        activeTopic = "login";
    }
    String userRole = (String) session.getAttribute("userRole");
    boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Help Section - Sunrise Dental Clinic</title>
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
                <span>Help &amp; Documentation</span>
            </nav>

            <div class="page-header">
                <h1 class="page-title">Help &amp; System Documentation</h1>
                <p class="page-subtitle">Standard operating procedures, clinical workflow guides, and administration instructions.</p>
            </div>

            <div class="help-layout">
                <!-- Topics Sidebar Menu -->
                <div>
                    <h3 style="font-size: 0.95rem; font-weight: 700; margin-bottom: 12px; color: var(--text-dark);">Topics</h3>
                    <ul class="help-topic-list">
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=login" class="help-topic-item <%= "login".equals(activeTopic) ? "active" : "" %>">
                                1. Login &amp; Security
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=appointment" class="help-topic-item <%= "appointment".equals(activeTopic) ? "active" : "" %>">
                                2. New Appointment
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=search" class="help-topic-item <%= "search".equals(activeTopic) ? "active" : "" %>">
                                3. Search &amp; Manage
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=billing" class="help-topic-item <%= "billing".equals(activeTopic) ? "active" : "" %>">
                                4. Multi-Service Billing
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=reports" class="help-topic-item <%= "reports".equals(activeTopic) ? "active" : "" %>">
                                5. Reports &amp; Analytics
                            </a>
                        </li>
                        <% if (isAdmin) { %>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=dentists" class="help-topic-item <%= "dentists".equals(activeTopic) ? "active" : "" %>">
                                6. Dentist Management <span style="font-size: 0.72rem; color: var(--primary); font-weight: 700;">[Admin]</span>
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=treatments" class="help-topic-item <%= "treatments".equals(activeTopic) ? "active" : "" %>">
                                7. Treatment &amp; Tariff <span style="font-size: 0.72rem; color: var(--primary); font-weight: 700;">[Admin]</span>
                            </a>
                        </li>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=users" class="help-topic-item <%= "users".equals(activeTopic) ? "active" : "" %>">
                                8. User Management <span style="font-size: 0.72rem; color: var(--primary); font-weight: 700;">[Admin]</span>
                            </a>
                        </li>
                        <% } %>
                        <li>
                            <a href="<%= request.getContextPath() %>/help?topic=logout" class="help-topic-item <%= "logout".equals(activeTopic) ? "active" : "" %>">
                                <%= isAdmin ? "9. Logout" : "6. Logout" %>
                            </a>
                        </li>
                    </ul>
                </div>

                <!-- Topic Detailed Guide -->
                <div class="help-content-card">
                    <% if ("login".equals(activeTopic)) { %>
                        <h2 class="help-topic-title">1. Login &amp; System Accounts</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">How system authentication and role-based accounts work:</p>
                        <ol class="help-steps">
                            <li>The clinic operates with two primary login roles: <strong>Admin</strong> (Management, Financial, Staff Control) and a shared <strong>Receptionist</strong> login.</li>
                            <li>Enter your designated <strong>Username</strong> and <strong>Password</strong> on the login screen.</li>
                            <li>Click on the <strong>Sign In</strong> button.</li>
                            <li>Upon successful verification, you will be redirected to your role-specific <strong>Dashboard</strong>.</li>
                            <li>To change system account credentials, the Administrator can update passwords via the User Management module.</li>
                        </ol>
                        <div class="help-note-box">
                            <span>ℹ️</span>
                            <span><strong>Note:</strong> All front-desk staff log in with the shared receptionist credentials, but select their assigned Receptionist Code (e.g. REC-001) during invoice generation for transaction tracking.</span>
                        </div>

                    <% } else if ("appointment".equals(activeTopic)) { %>
                        <h2 class="help-topic-title">2. Register New Appointment</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">To schedule a new patient appointment:</p>
                        <ol class="help-steps">
                            <li>Navigate to <strong>New Appointment</strong> from the sidebar.</li>
                            <li>The system auto-generates the next sequential <strong>Appointment Number</strong> (e.g., A1006).</li>
                            <li>Fill in the patient's full name, address, and mobile contact number.</li>
                            <li>Select the assigned <strong>Dentist</strong> and required <strong>Treatment Type</strong> from the dropdowns.</li>
                            <li>Pick the appointment date and set the consultation time.</li>
                            <li>Click <strong>Save Appointment</strong> to confirm the booking.</li>
                        </ol>
                        <div class="help-note-box">
                            <span>💡</span>
                            <span><strong>Tip:</strong> If the patient has visited before, their profile will be automatically linked and updated via contact number.</span>
                        </div>

                    <% } else if ("search".equals(activeTopic)) { %>
                        <h2 class="help-topic-title">3. Search &amp; Manage Appointments</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">How to find and modify existing appointments:</p>
                        <ol class="help-steps">
                            <li>Click on <strong>Search Appointment</strong> in the sidebar.</li>
                            <li>Enter the Appointment Number (e.g. <code>A1002</code>), patient name, contact number, or doctor name, and click <strong>Search</strong>.</li>
                            <li>View the detailed patient card with treatment and doctor information.</li>
                            <li>Click <strong>Edit</strong> to modify the time, doctor, or treatment if the patient requests a reschedule.</li>
                            <li>Click <strong>Delete</strong> if the patient cancelled the appointment (requires confirmation).</li>
                        </ol>

                    <% } else if ("billing".equals(activeTopic)) { %>
                        <h2 class="help-topic-title">4. Multi-Service Billing &amp; Invoicing</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Processing payments and itemized receipts:</p>
                        <ol class="help-steps">
                            <li>Navigate to <strong>Billing</strong> from the sidebar or click "Proceed to Billing" from an appointment.</li>
                            <li>Select an appointment to bill. The primary consultation and scheduled service will pre-populate in the invoice.</li>
                            <li>Click <strong>➕ Add Service</strong> to add additional clinical procedures or supplies to the same invoice.</li>
                            <li>Adjust quantities or unit prices as needed. The system automatically computes <code>Quantity × Unit Price</code> for each line.</li>
                            <li>Enter any applicable discount. Select the <strong>Payment Method</strong> (Cash, Card, Bank Transfer, Insurance) and <strong>Payment Status</strong> (Paid, Pending).</li>
                            <li>Select your assigned <strong>Receptionist ID</strong> for transaction audit trails.</li>
                            <li>Click <strong>Save &amp; Generate Invoice</strong> to create the invoice transaction.</li>
                            <li>Click <strong>Print Receipt</strong> to view or print the official branded patient receipt.</li>
                        </ol>

                    <% } else if ("reports".equals(activeTopic)) { %>
                        <h2 class="help-topic-title">5. Reports &amp; Analytics</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Accessing clinical and financial reports:</p>
                        <ol class="help-steps">
                            <li>Navigate to <strong>Reports</strong> from the sidebar.</li>
                            <li><strong>Daily Appointments Report:</strong> Select any date to inspect scheduled appointments, assigned dentists, and statuses.</li>
                            <li><strong>Patient Directory &amp; History:</strong> Review registered patient contact details and visit history.</li>
                            <li><strong>Treatment &amp; Service Report:</strong> Filter by date range to view operational utilization counts for each treatment type.</li>
                            <li><strong>Pending Bills Report:</strong> Review all outstanding balances, amounts paid, and pending payment statuses.</li>
                            <% if (isAdmin) { %>
                            <li><strong>Financial &amp; Revenue Report (Admin Only):</strong> Filter by date range, payment status, and payment method to view Total Invoiced, Total Collected, and Outstanding Balance summaries.</li>
                            <% } %>
                        </ol>

                    <% } else if ("dentists".equals(activeTopic) && isAdmin) { %>
                        <h2 class="help-topic-title">6. Dentist Management (Admin Only)</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Managing clinic dental specialists and surgery allocations:</p>
                        <ol class="help-steps">
                            <li>Go to <strong>Dentists</strong> in the sidebar.</li>
                            <li>Click <strong>➕ Add New Dentist</strong> to register a new doctor with name, specialization, contact, email, and assigned room number.</li>
                            <li>Click <strong>✏️ Edit</strong> next to any doctor to update their phone number, room allocation, specialization, or toggle their status between <strong>Active</strong> and <strong>Inactive</strong>.</li>
                            <li>Click <strong>🗑️ Delete</strong> to remove a doctor. The system will prompt for confirmation. (If the doctor has existing appointments, they will be safely marked as Inactive instead of corrupting historical records).</li>
                        </ol>
                        <div class="help-note-box">
                            <span>🛡️</span>
                            <span><strong>Admin Security:</strong> Receptionists can view the dentist directory to check room numbers and schedules, but cannot add, edit, or delete doctors.</span>
                        </div>

                    <% } else if ("treatments".equals(activeTopic) && isAdmin) { %>
                        <h2 class="help-topic-title">7. Treatment &amp; Tariff Management (Admin Only)</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Managing dental procedures, services catalog, and standard pricing:</p>
                        <ol class="help-steps">
                            <li>Go to <strong>Treatments</strong> in the sidebar.</li>
                            <li>Click <strong>➕ Add New Treatment</strong> to register a new procedure name, standard fee (Rs.), and procedure description.</li>
                            <li>Click <strong>✏️ Edit</strong> to adjust the standard price or update procedure details. Updated standard fees will automatically apply to future appointments and invoices.</li>
                            <li>Click <strong>🗑️ Delete</strong> to remove a treatment (requires confirmation; blocked if existing appointments reference it).</li>
                        </ol>

                    <% } else if ("users".equals(activeTopic) && isAdmin) { %>
                        <h2 class="help-topic-title">8. User Management (Admin Only)</h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Managing staff directory and system account security:</p>
                        <ol class="help-steps">
                            <li>Go to <strong>User Management</strong> in the sidebar (accessible exclusively by Administrators).</li>
                            <li>Click <strong>➕ Register New Receptionist</strong> to onboard new front-desk staff. The system auto-generates sequential Receptionist IDs (e.g. <code>REC-001</code>, <code>REC-002</code>, <code>REC-003</code>).</li>
                            <li>Edit staff phone numbers, emails, or toggle their status between <strong>Active</strong> and <strong>Inactive</strong>.</li>
                            <li>In the System Accounts section, Administrators can change passwords for the <code>admin</code> or shared <code>receptionist</code> system accounts.</li>
                        </ol>
                        <div class="help-note-box">
                            <span>🛡️</span>
                            <span><strong>Security Policy:</strong> Receptionist staff cannot access User Management. Direct URL requests are blocked by the controller layer.</span>
                        </div>

                    <% } else if ("logout".equals(activeTopic)) { %>
                        <h2 class="help-topic-title"><%= isAdmin ? "9. Exit System / Logout" : "6. Exit System / Logout" %></h2>
                        <p style="color: var(--text-muted); margin-bottom: 16px;">Safely ending your session:</p>
                        <ol class="help-steps">
                            <li>Click on <strong>Logout</strong> at the bottom of the navigation sidebar.</li>
                            <li>An exit confirmation dialog will pop up.</li>
                            <li>Click <strong>Yes, Exit</strong> to terminate your active session and return to the login screen.</li>
                        </ol>
                    <% } %>
                </div>
            </div>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
</body>
</html>
