<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ page import="java.text.SimpleDateFormat, java.util.List, java.math.BigDecimal" %>
<%@ page import="com.sunrisedental.model.Appointment, com.sunrisedental.model.Bill, com.sunrisedental.model.BillItem, com.sunrisedental.model.Treatment, com.sunrisedental.model.Receptionist" %>
<%
    request.setAttribute("activeMenu", "billing");
    Appointment appt = (Appointment) request.getAttribute("appointment");
    Bill bill = (Bill) request.getAttribute("bill");
    String userInvoiceNo = (String) request.getAttribute("userInvoiceNo");
    String billedBy = (String) request.getAttribute("billedBy");
    List<Receptionist> activeReceptionists = (List<Receptionist>) request.getAttribute("activeReceptionists");
    List<Treatment> treatments = (List<Treatment>) request.getAttribute("treatments");
    SimpleDateFormat dateFormat = new SimpleDateFormat("dd MMM yyyy");
    String errorParam = request.getParameter("error");
%>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Billing &amp; Invoices - Sunrise Dental Clinic</title>
    <link rel="stylesheet" href="<%= request.getContextPath() %>/assets/css/style.css">
    <style>
        .invoice-items-table {
            width: 100%;
            border-collapse: collapse;
            font-size: 0.9rem;
            margin-bottom: 16px;
        }
        .invoice-items-table th {
            background: #f8fafc;
            padding: 10px 12px;
            font-weight: 600;
            color: var(--text-muted);
            border-bottom: 2px solid var(--border-color);
            text-align: left;
            font-size: 0.82rem;
            text-transform: uppercase;
            letter-spacing: 0.5px;
        }
        .invoice-items-table td {
            padding: 10px 12px;
            border-bottom: 1px solid var(--border-color);
            vertical-align: middle;
        }
        .invoice-items-table tr:hover {
            background-color: #f8fafc;
        }
        .btn-remove-item {
            background: #fee2e2;
            color: #dc2626;
            border: 1px solid #fca5a5;
            border-radius: 6px;
            padding: 4px 8px;
            font-size: 0.85rem;
            cursor: pointer;
            transition: var(--transition);
        }
        .btn-remove-item:hover {
            background: #dc2626;
            color: #fff;
        }
        .bill-calc-row {
            display: flex;
            justify-content: space-between;
            align-items: center;
            padding: 8px 0;
            font-size: 0.95rem;
            border-bottom: 1px solid #f1f5f9;
        }
        .bill-calc-row:last-child {
            border-bottom: none;
        }
    </style>
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
                <span>Billing &amp; Invoices</span>
            </nav>

            <div class="page-header" style="margin-bottom: 20px;">
                <h1 class="page-title">Invoice &amp; Multi-Service Billing</h1>
                <p class="page-subtitle">Add dental treatments, calculate itemized invoice totals, and print official patient receipts.</p>
            </div>

            <!-- Flash Error Messages -->
            <% if ("discount_too_high".equals(errorParam) || "discount_exceeds_subtotal".equals(errorParam)) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Validation Error: Discount cannot exceed the applicable subtotal amount. The final bill total must never be negative.</span>
                </div>
            <% } else if ("negative_discount".equals(errorParam) || "invalid_discount".equals(errorParam)) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Validation Error: Please enter a valid non-negative discount amount.</span>
                </div>
            <% } else if ("missing_payment_method".equals(errorParam) || "invalid_payment_method".equals(errorParam)) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Validation Error: Payment information must be selected before the bill can be completed. Please select a valid payment method.</span>
                </div>
            <% } else if ("no_items".equals(errorParam) || "no_valid_items".equals(errorParam)) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Please add at least one valid service or treatment before generating the invoice.</span>
                </div>
            <% } else if ("save_failed".equals(errorParam)) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Failed to save invoice. Transaction rolled back. Please try again.</span>
                </div>
            <% } else if (errorParam != null) { %>
                <div class="alert alert-danger" style="margin-bottom: 20px; font-weight: 500;">
                    <span>⚠️ Action could not be completed. Please check your data.</span>
                </div>
            <% } %>

            <!-- Quick Appointment Lookup for billing -->
            <form action="<%= request.getContextPath() %>/billing" method="GET" class="search-bar-wrapper no-print" style="margin-bottom: 24px;">
                <div class="search-input-group">
                    <label style="font-weight: 600; font-size: 0.92rem; white-space: nowrap; color: var(--text-dark);">
                        Load Appointment:
                    </label>
                    <input type="text" name="no" class="form-control" placeholder="e.g. A1002" value="<%= appt != null ? appt.getAppointmentNo() : "" %>" style="max-width: 250px;">
                </div>
                <button type="submit" class="btn btn-primary">Load Appointment</button>
            </form>

            <% if (appt != null && bill != null) { %>
            <form action="<%= request.getContextPath() %>/billing" method="POST" id="billingForm" onsubmit="return validateInvoiceForm();">
                <input type="hidden" name="appointmentId" value="<%= appt.getId() %>">
                <input type="hidden" name="billNo" value="<%= bill.getBillNo() %>">
                <input type="hidden" name="userInvoiceNo" id="hiddenUserInvoiceNo" value="<%= bill.getUserInvoiceNo() != null ? bill.getUserInvoiceNo() : userInvoiceNo %>">
                <input type="hidden" name="billedBy" id="hiddenBilledBy" value="<%= bill.getBilledBy() != null ? bill.getBilledBy() : billedBy %>">

                <div class="grid-2">
                    <!-- Left Card: Appointment & Staff Information -->
                    <div class="card">
                        <div class="card-header">
                            <h2 class="card-title">Appointment Information</h2>
                            <span class="badge badge-confirmed"><%= appt.getStatus() != null ? appt.getStatus() : "Confirmed" %></span>
                        </div>

                        <div style="display: flex; flex-direction: column; gap: 14px;">
                            <div class="detail-item">
                                <span class="detail-label">Appointment No.</span>
                                <span class="detail-value" style="color: var(--primary); font-size: 1.05rem; font-family: monospace; font-weight: 700;">
                                    : <%= appt.getAppointmentNo() %>
                                </span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Patient Name</span>
                                <span class="detail-value" style="font-weight: 600;">: <%= appt.getPatientName() %></span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Dentist Name</span>
                                <span class="detail-value">: <%= appt.getDentistName() %></span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Treatment Type</span>
                                <span class="detail-value">: <%= appt.getTreatmentName() %></span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Date</span>
                                <span class="detail-value">: <%= appt.getAppointmentDate() != null ? dateFormat.format(appt.getAppointmentDate()) : "-" %></span>
                            </div>

                            <div class="detail-item">
                                <span class="detail-label">Time</span>
                                <span class="detail-value">: <%= appt.getAppointmentTime() %></span>
                            </div>

                            <!-- Handling Receptionist Identification Box -->
                            <div style="margin-top: 10px; padding: 14px; background: #eff6ff; border-radius: 8px; border: 1px solid #bfdbfe;">
                                <div style="font-size: 0.8rem; font-weight: 700; color: #1e40af; text-transform: uppercase; margin-bottom: 8px;">
                                    👩‍💼 Handling Receptionist ID
                                </div>
                                <% if (activeReceptionists != null && !activeReceptionists.isEmpty()) { %>
                                <div style="margin-bottom: 10px;">
                                    <label style="font-size: 0.78rem; font-weight: 600; color: #1e3a8a; display: block; margin-bottom: 4px;">Assigned Receptionist:</label>
                                    <select class="form-control" style="font-size: 0.88rem; padding: 6px 10px; background: #fff;" onchange="updateReceptionistBilling(this)">
                                        <% for (Receptionist r : activeReceptionists) {
                                            String curInv = bill.getUserInvoiceNo() != null ? bill.getUserInvoiceNo() : userInvoiceNo;
                                            boolean isSelected = curInv != null && curInv.equalsIgnoreCase(r.getReceptionistCode());
                                        %>
                                        <option value="<%= r.getReceptionistCode() %>" data-name="<%= r.getFullName() %>" <%= isSelected ? "selected" : "" %>>
                                            <%= r.getReceptionistCode() %> - <%= r.getFullName() %>
                                        </option>
                                        <% } %>
                                    </select>
                                </div>
                                <% } %>
                                <div style="font-size: 0.88rem; color: #1e3a8a;">
                                    <strong>Receptionist ID:</strong> 
                                    <span class="badge badge-info" id="displayInvoiceNo" style="font-family: monospace; font-size: 0.85rem;">
                                        <%= bill.getUserInvoiceNo() != null ? bill.getUserInvoiceNo() : userInvoiceNo %>
                                    </span>
                                </div>
                                <div style="font-size: 0.85rem; color: #1e3a8a; margin-top: 4px;">
                                    <strong>Billed By:</strong> <span id="displayBilledBy"><%= bill.getBilledBy() != null ? bill.getBilledBy() : billedBy %></span>
                                </div>
                                <div style="font-size: 0.85rem; color: #1e3a8a; margin-top: 4px;">
                                    <strong>Billing Time:</strong> 
                                    <span style="font-weight: 600; color: #1d4ed8;">🕒 <%= new SimpleDateFormat("dd MMM yyyy, hh:mm a").format(new java.util.Date()) %></span>
                                </div>
                            </div>
                        </div>
                    </div>

                    <!-- Right Card: Bill Summary & Multi-Service Line Items -->
                    <div class="card">
                        <div class="card-header" style="display: flex; justify-content: space-between; align-items: center;">
                            <h2 class="card-title">Bill Summary</h2>
                            <span class="badge badge-info" style="font-family: monospace; font-size: 0.85rem;">Invoice No: <%= bill.getBillNo() %></span>
                        </div>

                        <!-- Dynamic Line Items Table -->
                        <div class="table-responsive">
                            <table class="invoice-items-table" id="itemsTable">
                                <thead>
                                    <tr>
                                        <th style="width: 44%;">Service / Treatment</th>
                                        <th style="width: 14%; text-align: center;">Qty</th>
                                        <th style="width: 20%; text-align: right;">Unit Price (Rs.)</th>
                                        <th style="width: 22%; text-align: right;">Total (Rs.)</th>
                                        <th style="width: 5%; text-align: center;"></th>
                                    </tr>
                                </thead>
                                <tbody id="itemsTableBody">
                                    <% 
                                    List<BillItem> currentItems = bill.getItems();
                                    if (currentItems != null && !currentItems.isEmpty()) {
                                        for (int i = 0; i < currentItems.size(); i++) {
                                            BillItem item = currentItems.get(i);
                                    %>
                                    <tr class="item-row">
                                        <td>
                                            <input type="hidden" name="itemTreatmentId" class="row-treatment-id" value="<%= item.getTreatmentId() != null ? item.getTreatmentId() : "" %>">
                                            <select class="form-control row-treatment-select" onchange="onTreatmentSelect(this)" style="font-size: 0.85rem;">
                                                <option value="" data-price="0.00" data-name="Custom Service">-- Select Service --</option>
                                                <% if (treatments != null) {
                                                    for (Treatment t : treatments) {
                                                        boolean sel = (item.getTreatmentId() != null && item.getTreatmentId() == t.getId()) ||
                                                                      (item.getTreatmentName() != null && item.getTreatmentName().equalsIgnoreCase(t.getName()));
                                                %>
                                                <option value="<%= t.getId() %>" data-price="<%= t.getCost() %>" data-name="<%= t.getName() %>" <%= sel ? "selected" : "" %>>
                                                    <%= t.getName() %> (Rs. <%= String.format("%,.2f", t.getCost()) %>)
                                                </option>
                                                <%  }
                                                } %>
                                            </select>
                                            <input type="hidden" name="itemTreatmentName" class="row-treatment-name" value="<%= item.getTreatmentName() %>">
                                        </td>
                                        <td style="text-align: center;">
                                            <input type="number" name="itemQuantity" class="form-control row-qty" min="1" step="1" value="<%= item.getQuantity() > 0 ? item.getQuantity() : 1 %>" oninput="calculateInvoiceTotals()" style="text-align: center; width: 65px; display: inline-block;">
                                        </td>
                                        <td style="text-align: right;">
                                            <input type="number" name="itemUnitPrice" class="form-control row-unit-price" min="0" step="0.01" value="<%= item.getUnitPrice() %>" oninput="calculateInvoiceTotals()" style="text-align: right; width: 105px; display: inline-block;">
                                        </td>
                                        <td style="text-align: right; font-weight: 700; color: #065f46;">
                                            <span class="row-line-total-display"><%= String.format("%,.2f", item.getLineTotal()) %></span>
                                        </td>
                                        <td style="text-align: center;">
                                            <button type="button" class="btn-remove-item" onclick="removeServiceRow(this)" title="Remove service">✕</button>
                                        </td>
                                    </tr>
                                    <%  }
                                    } %>
                                </tbody>
                            </table>
                        </div>

                        <!-- Add Service Button -->
                        <div style="margin-bottom: 20px;">
                            <button type="button" class="btn btn-sm btn-outline-primary" onclick="addServiceRow()" style="font-weight: 600;">
                                <span>➕</span> <span>Add Service</span>
                            </button>
                        </div>

                        <!-- Invoice Calculation Section -->
                        <div style="background: #f8fafc; border: 1px solid var(--border-color); border-radius: 8px; padding: 16px; margin-bottom: 20px;">
                            <div class="bill-calc-row">
                                <span style="font-weight: 600; color: var(--text-dark);">Subtotal:</span>
                                <span style="font-weight: 700; font-size: 1.05rem;" id="subTotalDisplay">
                                    Rs. <%= String.format("%,.2f", bill.getSubTotal() != null ? bill.getSubTotal() : BigDecimal.ZERO) %>
                                </span>
                            </div>

                            <div class="bill-calc-row">
                                <span style="font-weight: 600; color: var(--text-dark);">Discount (Rs.):</span>
                                <div style="text-align: right;">
                                    <input type="number" step="0.01" min="0" id="discountInput" name="discount" 
                                           class="form-control" style="width: 140px; text-align: right; font-weight: 600; display: inline-block;" 
                                           value="<%= bill.getDiscount() != null ? bill.getDiscount() : "0.00" %>" 
                                           oninput="calculateInvoiceTotals()" onchange="validateAndRejectDiscount(this)" required>
                                    <div id="discountErrorMsg" style="display: none; color: #dc2626; font-size: 0.78rem; font-weight: 600; margin-top: 4px; max-width: 250px; text-align: right;"></div>
                                </div>
                            </div>

                            <div class="bill-calc-row" style="margin-top: 10px; padding-top: 12px; border-top: 2px solid var(--border-color);">
                                <span style="font-size: 1.15rem; font-weight: 800; color: var(--primary);">TOTAL AMOUNT:</span>
                                <span style="font-size: 1.3rem; font-weight: 800; color: #065f46;" id="totalAmountDisplay">
                                    Rs. <%= String.format("%,.2f", bill.getTotalAmount() != null ? bill.getTotalAmount() : BigDecimal.ZERO) %>
                                </span>
                            </div>
                        </div>

                        <!-- Payment Method & Payment Status -->
                        <div class="grid-2" style="gap: 14px; margin-bottom: 20px;">
                            <div class="form-group">
                                <label class="form-label" style="font-size: 0.85rem;">Payment Method <span class="required">*</span></label>
                                <select name="paymentMethod" id="paymentMethodSelect" class="form-control" style="font-weight: 600;" required>
                                    <option value="" disabled <%= (bill.getPaymentMethod() == null || bill.getPaymentMethod().trim().isEmpty()) ? "selected" : "" %>>-- Select Payment Method --</option>
                                    <option value="Cash" <%= "Cash".equalsIgnoreCase(bill.getPaymentMethod()) ? "selected" : "" %>>💵 Cash</option>
                                    <option value="Credit / Debit Card" <%= "Credit / Debit Card".equalsIgnoreCase(bill.getPaymentMethod()) ? "selected" : "" %>>💳 Credit / Debit Card</option>
                                    <option value="Bank Transfer" <%= "Bank Transfer".equalsIgnoreCase(bill.getPaymentMethod()) ? "selected" : "" %>>🏦 Bank Transfer</option>
                                    <option value="Insurance" <%= "Insurance".equalsIgnoreCase(bill.getPaymentMethod()) ? "selected" : "" %>>🛡️ Insurance</option>
                                </select>
                                <small id="paymentMethodHelp" style="display: block; margin-top: 4px; color: var(--text-muted); font-size: 0.8rem;">
                                    Required: Select payment instrument before completing the bill.
                                </small>
                            </div>

                            <div class="form-group">
                                <label class="form-label" style="font-size: 0.85rem;">Payment Status <span class="required">*</span></label>
                                <select name="paymentStatus" class="form-control" style="font-weight: 600;">
                                    <option value="Paid" <%= "Paid".equalsIgnoreCase(bill.getPaymentStatus()) ? "selected" : "" %>>✓ Paid</option>
                                    <option value="Pending" <%= "Pending".equalsIgnoreCase(bill.getPaymentStatus()) ? "selected" : "" %>>⏳ Pending</option>
                                </select>
                            </div>
                        </div>

                        <!-- Action Buttons: Preview & Save/Print -->
                        <div class="form-actions" style="justify-content: flex-end; gap: 12px;">
                            <a href="<%= request.getContextPath() %>/dashboard" class="btn btn-outline" style="padding: 10px 20px;">
                                &larr; Back
                            </a>
                            <button type="submit" class="btn btn-primary" style="padding: 10px 28px; font-weight: 700;">
                                <span>🖨️</span> <span>Save &amp; Print Receipt</span>
                            </button>
                        </div>
                    </div>
                </div>
            </form>
            <% } else { %>
                <div class="card" style="text-align: center; padding: 48px 20px;">
                    <div style="font-size: 2.5rem; margin-bottom: 12px;">💳</div>
                    <h3 style="margin-bottom: 8px; color: var(--text-dark);">No Appointment Loaded</h3>
                    <p style="color: var(--text-muted); font-size: 0.95rem; margin-bottom: 20px;">
                        Please enter an Appointment Number above (e.g. <code>A1001</code>) to generate or view the multi-service bill.
                    </p>
                    <a href="<%= request.getContextPath() %>/appointments?action=search" class="btn btn-primary">Find Appointments</a>
                </div>
            <% } %>
        </main>
    </div>
</div>

<jsp:include page="includes/exit-modal.jsp" />
<jsp:include page="includes/footer.jsp" />

<!-- Treatment Catalog Data for Client Javascript -->
<script>
var treatmentCatalog = [
<% if (treatments != null && !treatments.isEmpty()) {
    boolean first = true;
    for (Treatment t : treatments) {
        if (!first) out.print(",");
        first = false;
%>
    { "id": <%= t.getId() %>, "name": "<%= t.getName().replace("\\", "\\\\").replace("\"", "\\\"") %>", "cost": <%= t.getCost() %> }<%
    }
} %>
];

function updateReceptionistBilling(sel) {
    if (!sel) return;
    var code = sel.value;
    var name = sel.options[sel.selectedIndex].getAttribute('data-name');
    var hiddenCode = document.getElementById('hiddenUserInvoiceNo');
    var hiddenName = document.getElementById('hiddenBilledBy');
    var displayCode = document.getElementById('displayInvoiceNo');
    var displayName = document.getElementById('displayBilledBy');
    if (hiddenCode) hiddenCode.value = code;
    if (hiddenName) hiddenName.value = name;
    if (displayCode) displayCode.innerText = code;
    if (displayName) displayName.innerText = name;
}

function buildTreatmentOptionsHtml(selectedId) {
    var html = '<option value="" data-price="0.00" data-name="Custom Service">-- Select Service --</option>';
    for (var i = 0; i < treatmentCatalog.length; i++) {
        var t = treatmentCatalog[i];
        var isSel = (selectedId && parseInt(selectedId) === t.id) ? 'selected' : '';
        html += '<option value="' + t.id + '" data-price="' + t.cost + '" data-name="' + escapeHtml(t.name) + '" ' + isSel + '>' + escapeHtml(t.name) + ' (Rs. ' + t.cost.toLocaleString('en-US', {minimumFractionDigits: 2}) + ')</option>';
    }
    return html;
}

function addServiceRow(treatmentId, customName, price, qty) {
    var tbody = document.getElementById('itemsTableBody');
    if (!tbody) return;

    var defaultPrice = price ? price : 0.00;
    var defaultQty = qty ? qty : 1;
    var initialTreatmentId = treatmentId ? treatmentId : "";
    var initialTreatmentName = customName ? customName : "";

    var tr = document.createElement('tr');
    tr.className = 'item-row';
    tr.innerHTML = 
        '<td>' +
            '<input type="hidden" name="itemTreatmentId" class="row-treatment-id" value="' + initialTreatmentId + '">' +
            '<select class="form-control row-treatment-select" onchange="onTreatmentSelect(this)" style="font-size: 0.85rem;">' +
                buildTreatmentOptionsHtml(initialTreatmentId) +
            '</select>' +
            '<input type="hidden" name="itemTreatmentName" class="row-treatment-name" value="' + escapeHtml(initialTreatmentName) + '">' +
        '</td>' +
        '<td style="text-align: center;">' +
            '<input type="number" name="itemQuantity" class="form-control row-qty" min="1" step="1" value="' + defaultQty + '" oninput="calculateInvoiceTotals()" style="text-align: center; width: 65px; display: inline-block;">' +
        '</td>' +
        '<td style="text-align: right;">' +
            '<input type="number" name="itemUnitPrice" class="form-control row-unit-price" min="0" step="0.01" value="' + defaultPrice + '" oninput="calculateInvoiceTotals()" style="text-align: right; width: 105px; display: inline-block;">' +
        '</td>' +
        '<td style="text-align: right; font-weight: 700; color: #065f46;">' +
            '<span class="row-line-total-display">0.00</span>' +
        '</td>' +
        '<td style="text-align: center;">' +
            '<button type="button" class="btn-remove-item" onclick="removeServiceRow(this)" title="Remove service">✕</button>' +
        '</td>';

    tbody.appendChild(tr);
    calculateInvoiceTotals();
}

function removeServiceRow(btn) {
    var tbody = document.getElementById('itemsTableBody');
    var rows = tbody.querySelectorAll('.item-row');
    if (rows.length <= 1) {
        alert('Invoice must contain at least one service item.');
        return;
    }
    var tr = btn.closest('tr');
    if (tr) {
        tr.remove();
        calculateInvoiceTotals();
    }
}

function onTreatmentSelect(selectEl) {
    var tr = selectEl.closest('tr');
    var opt = selectEl.options[selectEl.selectedIndex];
    var tId = selectEl.value;
    var price = parseFloat(opt.getAttribute('data-price')) || 0;
    var name = opt.getAttribute('data-name') || '';

    // Check duplicate selection
    if (tId && tId !== '') {
        var allSelects = document.querySelectorAll('.row-treatment-select');
        var duplicateFound = false;
        allSelects.forEach(function(s) {
            if (s !== selectEl && s.value === tId) {
                duplicateFound = true;
                // Automatically increment the existing row quantity
                var otherTr = s.closest('tr');
                var otherQtyInput = otherTr.querySelector('.row-qty');
                if (otherQtyInput) {
                    otherQtyInput.value = parseInt(otherQtyInput.value || 1) + 1;
                }
            }
        });

        if (duplicateFound) {
            alert('This treatment is already on the invoice. Quantity has been increased on the existing item.');
            // Remove or reset this duplicate row
            var tbody = document.getElementById('itemsTableBody');
            var rows = tbody.querySelectorAll('.item-row');
            if (rows.length > 1) {
                tr.remove();
            } else {
                selectEl.value = '';
                tr.querySelector('.row-treatment-id').value = '';
                tr.querySelector('.row-treatment-name').value = '';
                tr.querySelector('.row-unit-price').value = '0.00';
            }
            calculateInvoiceTotals();
            return;
        }
    }

    tr.querySelector('.row-treatment-id').value = tId;
    tr.querySelector('.row-treatment-name').value = name;
    tr.querySelector('.row-unit-price').value = price.toFixed(2);
    calculateInvoiceTotals();
}

function calculateInvoiceTotals() {
    var rows = document.querySelectorAll('.item-row');
    var subTotal = 0;

    rows.forEach(function(row) {
        var qtyInput = row.querySelector('.row-qty');
        var priceInput = row.querySelector('.row-unit-price');
        var displayEl = row.querySelector('.row-line-total-display');

        var qty = parseInt(qtyInput.value) || 0;
        if (qty < 1) {
            qty = 1;
            qtyInput.value = 1;
        }

        var price = parseFloat(priceInput.value) || 0;
        if (price < 0) {
            price = 0;
            priceInput.value = 0;
        }

        var lineTotal = qty * price;
        subTotal += lineTotal;

        if (displayEl) {
            displayEl.innerText = lineTotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
        }
    });

    var discountInput = document.getElementById('discountInput');
    var discountErrorMsg = document.getElementById('discountErrorMsg');
    var discount = 0;
    var discountInvalid = false;

    if (discountInput) {
        var rawDiscount = discountInput.value.trim();
        discount = parseFloat(rawDiscount);

        if (rawDiscount === '' || isNaN(discount)) {
            discount = 0;
            if (discountErrorMsg) {
                discountErrorMsg.innerText = '⚠️ Please enter a valid discount amount.';
                discountErrorMsg.style.display = 'block';
            }
            discountInput.style.borderColor = '#dc2626';
            discountInvalid = true;
        } else if (discount < 0) {
            if (discountErrorMsg) {
                discountErrorMsg.innerText = '⚠️ Discount cannot be negative.';
                discountErrorMsg.style.display = 'block';
            }
            discountInput.style.borderColor = '#dc2626';
            discountInvalid = true;
        } else if (discount > subTotal) {
            if (discountErrorMsg) {
                discountErrorMsg.innerText = '⚠️ Discount (Rs. ' + discount.toFixed(2) + ') exceeds subtotal (Rs. ' + subTotal.toFixed(2) + '). Total cannot be negative.';
                discountErrorMsg.style.display = 'block';
            }
            discountInput.style.borderColor = '#dc2626';
            discountInvalid = true;
        } else {
            if (discountErrorMsg) {
                discountErrorMsg.innerText = '';
                discountErrorMsg.style.display = 'none';
            }
            discountInput.style.borderColor = '';
        }
    }

    var total = subTotal - (discountInvalid ? 0 : discount);
    if (total < 0) total = 0;

    var subTotalDisplay = document.getElementById('subTotalDisplay');
    var totalAmountDisplay = document.getElementById('totalAmountDisplay');

    if (subTotalDisplay) {
        subTotalDisplay.innerText = 'Rs. ' + subTotal.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
    }
    if (totalAmountDisplay) {
        if (discountInvalid && discount > subTotal) {
            totalAmountDisplay.innerText = 'Rs. 0.00 (Invalid Discount)';
            totalAmountDisplay.style.color = '#dc2626';
        } else {
            totalAmountDisplay.innerText = 'Rs. ' + total.toLocaleString('en-US', {minimumFractionDigits: 2, maximumFractionDigits: 2});
            totalAmountDisplay.style.color = '#065f46';
        }
    }
}

function validateAndRejectDiscount(input) {
    if (!input) return;
    var raw = input.value.trim();
    var d = parseFloat(raw);

    // Calculate current subtotal from row items
    var rows = document.querySelectorAll('.item-row');
    var subTotal = 0;
    rows.forEach(function(row) {
        var qty = parseInt(row.querySelector('.row-qty').value) || 0;
        var price = parseFloat(row.querySelector('.row-unit-price').value) || 0;
        subTotal += (qty * price);
    });

    if (raw === '' || isNaN(d) || d < 0) {
        alert('⚠️ Validation Error: Discount cannot be negative or invalid. The discount has been rejected and reset to 0.00.');
        input.value = '0.00';
        calculateInvoiceTotals();
        input.focus();
        return;
    }

    if (d > subTotal) {
        alert('⚠️ Validation Error: Discount (Rs. ' + d.toFixed(2) + ') exceeds the applicable amount (Rs. ' + subTotal.toFixed(2) + '). The discount has been rejected because the final bill total must never be negative.');
        input.value = '0.00';
        calculateInvoiceTotals();
        input.focus();
        return;
    }
}

function validateInvoiceForm() {
    var rows = document.querySelectorAll('.item-row');
    if (rows.length === 0) {
        alert('Please add at least one service item.');
        return false;
    }

    var computedSubTotal = 0;

    for (var i = 0; i < rows.length; i++) {
        var row = rows[i];
        var nameInput = row.querySelector('.row-treatment-name');
        var selectInput = row.querySelector('.row-treatment-select');
        var qtyInput = row.querySelector('.row-qty');
        var priceInput = row.querySelector('.row-unit-price');

        var name = (nameInput && nameInput.value.trim() !== '') ? nameInput.value.trim() : (selectInput ? selectInput.options[selectInput.selectedIndex].getAttribute('data-name') : '');
        if (!name || name === 'Custom Service' || (selectInput && selectInput.value === '')) {
            alert('Please select a valid service/treatment for row #' + (i + 1));
            if (selectInput) selectInput.focus();
            return false;
        }

        var qty = parseInt(qtyInput.value);
        if (isNaN(qty) || qty < 1) {
            alert('Quantity for row #' + (i + 1) + ' must be at least 1.');
            qtyInput.focus();
            return false;
        }

        var price = parseFloat(priceInput.value);
        if (isNaN(price) || price < 0) {
            alert('Unit price for row #' + (i + 1) + ' cannot be negative.');
            priceInput.focus();
            return false;
        }

        computedSubTotal += (qty * price);
    }

    // 1. Discount Validation
    var discountInput = document.getElementById('discountInput');
    if (discountInput) {
        var rawDiscount = discountInput.value.trim();
        var d = parseFloat(rawDiscount);
        if (rawDiscount === '' || isNaN(d)) {
            alert('⚠️ Validation Error: Please enter a valid discount amount (enter 0.00 for no discount).');
            discountInput.focus();
            return false;
        }
        if (d < 0) {
            alert('⚠️ Validation Error: Discount cannot be negative.');
            discountInput.focus();
            return false;
        }
        if (d > computedSubTotal) {
            alert('⚠️ Validation Error: The discount (Rs. ' + d.toFixed(2) + ') exceeds the applicable subtotal amount (Rs. ' + computedSubTotal.toFixed(2) + '). The final bill total must never be negative.');
            discountInput.focus();
            return false;
        }
    }

    // 2. Payment Method Validation (Payment information must be selected before completing the bill)
    var paymentMethodSelect = document.getElementById('paymentMethodSelect');
    if (!paymentMethodSelect || !paymentMethodSelect.value || paymentMethodSelect.value.trim() === '') {
        alert('⚠️ Validation Error: Payment information must be selected before the bill can be completed. Please select a valid payment method.');
        if (paymentMethodSelect) paymentMethodSelect.focus();
        return false;
    }

    return true;
}

function escapeHtml(str) {
    if (!str) return '';
    return str.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;').replace(/"/g, '&quot;').replace(/'/g, '&#039;');
}

// Initial calculation on page load
document.addEventListener('DOMContentLoaded', function() {
    calculateInvoiceTotals();
});
</script>
</body>
</html>
