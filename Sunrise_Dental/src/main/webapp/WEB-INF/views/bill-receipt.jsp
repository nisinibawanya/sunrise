<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.List" %>
<%@ page import="com.sunrisedental.model.Bill, com.sunrisedental.model.BillItem" %>
<%
    request.setAttribute("activeMenu", "billing");
    Bill bill = (Bill) request.getAttribute("bill");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMMM yyyy");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Invoice Receipt - <%= bill != null ? bill.getBillNo() : "Sunrise Dental" %></title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
</head>
<body>
<div class="app-container">
    <jsp:include page="includes/sidebar.jsp" />

    <div class="main-wrapper">
        <jsp:include page="includes/header.jsp" />

        <main class="content-container">
            <nav class="breadcrumb no-print">
                <a href="<%= request.getContextPath() %>/dashboard">Home</a>
                <span>/</span>
                <a href="<%= request.getContextPath() %>/billing">Billing</a>
                <span>/</span>
                <span>Receipt</span>
            </nav>

            <% if (bill != null) { %>
            <!-- Receipt Card (Screen 6) -->
            <div class="receipt-container">
                <div class="receipt-header">
                    <div class="receipt-logo">🦷</div>
                    <div class="receipt-clinic-name">SUNRISE DENTAL CLINIC</div>
                    <div class="receipt-clinic-tag">Care with a Smile</div>
                    <div class="receipt-clinic-address">
                        321, Union Place, Colombo 02<br>
                        Tel: 011 234 5678 &bull; Email: info@sunrisedental.lk
                    </div>
                    <div class="receipt-badge-title">OFFICIAL RECEIPT / INVOICE</div>
                </div>

                <div class="receipt-info-grid">
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Invoice No.</span>
                        <span class="receipt-info-val" style="font-family: monospace; font-weight: 700; color: var(--primary);">: <%= bill.getBillNo() %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Appointment No.</span>
                        <span class="receipt-info-val" style="font-family: monospace; font-weight: 700;">: <%= bill.getAppointmentNo() %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Patient Name</span>
                        <span class="receipt-info-val" style="font-weight: 600;">: <%= bill.getPatientName() %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Dentist Name</span>
                        <span class="receipt-info-val">: <%= bill.getDentistName() %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Appointment Date</span>
                        <span class="receipt-info-val">: <%= bill.getAppointmentDate() != null ? dateFormat.format(bill.getAppointmentDate()) : "-" %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Appointment Time</span>
                        <span class="receipt-info-val">: <%= bill.getAppointmentTime() %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Payment Method</span>
                        <span class="receipt-info-val" style="font-weight: 600;">: <%= bill.getPaymentMethod() != null ? bill.getPaymentMethod() : "Cash" %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Payment Status</span>
                        <span class="receipt-info-val" style="font-weight: 700; color: #065f46;">: <%= bill.getPaymentStatus() != null ? bill.getPaymentStatus() : "Paid" %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Receptionist ID</span>
                        <span class="receipt-info-val" style="font-family: monospace; font-weight: 700; color: var(--primary);">: <%= bill.getUserInvoiceNo() != null ? bill.getUserInvoiceNo() : "REC-001" %></span>
                    </div>
                    <div class="receipt-info-row">
                        <span class="receipt-info-label">Billed By</span>
                        <span class="receipt-info-val">: <%= bill.getBilledBy() != null ? bill.getBilledBy() : "Receptionist" %></span>
                    </div>
                    <div class="receipt-info-row" style="grid-column: 1 / -1;">
                        <span class="receipt-info-label">Receipt Generated</span>
                        <span class="receipt-info-val">: <%= bill.getPaidAt() != null ? new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(bill.getPaidAt()) : new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(new java.util.Date()) %></span>
                    </div>
                </div>

                <!-- Multi-Service Itemized Receipt Table -->
                <table class="bill-summary-table" style="margin-top: 10px;">
                    <thead>
                        <tr>
                            <th style="text-align: left; width: 48%;">Service / Treatment</th>
                            <th style="text-align: center; width: 12%;">Qty</th>
                            <th style="text-align: right; width: 20%;">Price (Rs.)</th>
                            <th style="text-align: right; width: 20%;">Total (Rs.)</th>
                        </tr>
                    </thead>
                    <tbody>
                        <% 
                        List<BillItem> items = bill.getItems();
                        if (items != null && !items.isEmpty()) {
                            for (BillItem item : items) {
                        %>
                        <tr>
                            <td style="font-weight: 600;"><%= item.getTreatmentName() %></td>
                            <td style="text-align: center;"><%= item.getQuantity() %></td>
                            <td style="text-align: right;"><%= String.format("%,.2f", item.getUnitPrice()) %></td>
                            <td style="text-align: right; font-weight: 700;"><%= String.format("%,.2f", item.getLineTotal()) %></td>
                        </tr>
                        <%  }
                        } else { %>
                        <tr>
                            <td style="font-weight: 600;">Dental Services / Consultation</td>
                            <td style="text-align: center;">1</td>
                            <td style="text-align: right;"><%= String.format("%,.2f", bill.getSubTotal()) %></td>
                            <td style="text-align: right; font-weight: 700;"><%= String.format("%,.2f", bill.getSubTotal()) %></td>
                        </tr>
                        <% } %>

                        <!-- Subtotal Row -->
                        <tr style="border-top: 2px solid var(--border-color); font-weight: 600; background-color: #fafafa;">
                            <td colspan="3" style="text-align: right; padding-right: 14px;">Subtotal:</td>
                            <td style="text-align: right; font-weight: 700;">Rs. <%= String.format("%,.2f", bill.getSubTotal()) %></td>
                        </tr>

                        <!-- Discount Row -->
                        <tr style="background-color: #fafafa;">
                            <td colspan="3" style="text-align: right; padding-right: 14px; color: var(--text-muted);">Discount:</td>
                            <td style="text-align: right; color: var(--text-muted);">Rs. <%= String.format("%,.2f", bill.getDiscount() != null ? bill.getDiscount() : java.math.BigDecimal.ZERO) %></td>
                        </tr>
                    </tbody>
                </table>

                <!-- Highlighted Total Amount -->
                <div class="bill-total-highlight" style="margin-top: 14px; padding: 14px 20px;">
                    <span>TOTAL AMOUNT PAID</span>
                    <span>Rs. <%= String.format("%,.2f", bill.getTotalAmount()) %></span>
                </div>

                <div class="receipt-footer-note">
                    <p style="font-weight: 700; color: var(--text-dark); margin-bottom: 4px;">
                        Thank you for visiting Sunrise Dental Clinic!
                    </p>
                    <p style="font-size: 0.85rem; color: var(--text-muted); margin: 0;">Care with a Smile &bull; Please retain this receipt for your medical records.</p>
                </div>

                <!-- Print Actions (Hidden when printing) -->
                <div class="form-actions no-print" style="justify-content: center; gap: 14px; margin-top: 28px;">
                    <button type="button" class="btn btn-primary" onclick="window.print();" style="padding: 12px 32px; font-size: 1rem; font-weight: 700; box-shadow: 0 4px 12px rgba(79, 70, 229, 0.3);">
                        <span>🖨️</span> <span>Print Receipt</span>
                    </button>
                    <a href="<%= request.getContextPath() %>/billing?no=<%= bill.getAppointmentNo() %>" class="btn btn-outline" style="padding: 12px 24px;">
                        &larr; Back to Billing
                    </a>
                </div>
            </div>
            <% } else { %>
                <div class="card" style="text-align: center; padding: 48px 20px;">
                    <div style="font-size: 2.5rem; margin-bottom: 12px;">🧾</div>
                    <h3 style="color: var(--text-dark); margin-bottom: 8px;">Receipt Not Found</h3>
                    <p style="color: var(--text-muted); margin-bottom: 20px;">The requested invoice or receipt could not be located.</p>
                    <a href="<%= request.getContextPath() %>/billing" class="btn btn-primary">Go to Billing</a>
                </div>
            <% } %>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />
</body>
</html>
