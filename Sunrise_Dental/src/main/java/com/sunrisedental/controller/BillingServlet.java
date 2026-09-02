package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.ReceptionistDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Bill;
import com.sunrisedental.model.BillItem;
import com.sunrisedental.model.Receptionist;
import com.sunrisedental.model.Treatment;
import com.sunrisedental.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

@WebServlet(name = "BillingServlet", urlPatterns = {"/billing", "/billing/*"})
public class BillingServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private BillDAO billDAO;
    private AppointmentDAO appointmentDAO;
    private ReceptionistDAO receptionistDAO;
    private TreatmentDAO treatmentDAO;

    @Override
    public void init() throws ServletException {
        this.billDAO = new BillDAO();
        this.appointmentDAO = new AppointmentDAO();
        this.receptionistDAO = new ReceptionistDAO();
        this.treatmentDAO = new TreatmentDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("receipt".equalsIgnoreCase(action)) {
            showReceipt(request, response);
            return;
        }

        String apptNo = request.getParameter("no");
        String billNo = request.getParameter("billNo");
        Appointment appointment = null;
        Bill bill = null;

        if (billNo != null && !billNo.trim().isEmpty()) {
            bill = billDAO.getBillByBillNo(billNo.trim());
            if (bill != null) {
                appointment = appointmentDAO.getAppointmentById(bill.getAppointmentId());
            }
        } else if (apptNo != null && !apptNo.trim().isEmpty()) {
            appointment = appointmentDAO.getAppointmentByNo(apptNo.trim());
            if (appointment != null) {
                bill = billDAO.getBillByAppointmentId(appointment.getId());
            }
        } else {
            // Default sample load: A1002 or first today appointment
            appointment = appointmentDAO.getAppointmentByNo("A1002");
            if (appointment != null) {
                bill = billDAO.getBillByAppointmentId(appointment.getId());
            }
        }

        if (appointment == null) {
            List<Appointment> today = appointmentDAO.getTodayAppointments();
            if (!today.isEmpty()) {
                appointment = today.get(0);
                bill = billDAO.getBillByAppointmentId(appointment.getId());
            }
        }

        List<Treatment> treatments = treatmentDAO.getAllTreatments();
        List<Receptionist> activeReceptionists = receptionistDAO.getActiveReceptionists();

        HttpSession session = request.getSession(false);
        User currentUser = session != null ? (User) session.getAttribute("currentUser") : null;
        String defaultReceptionistId = "REC-001";
        String defaultBilledBy = "Receptionist";

        if (activeReceptionists != null && !activeReceptionists.isEmpty()) {
            defaultReceptionistId = activeReceptionists.get(0).getReceptionistCode();
            defaultBilledBy = activeReceptionists.get(0).getFullName();
        } else if (currentUser != null) {
            defaultReceptionistId = currentUser.getInvoiceNo() != null ? currentUser.getInvoiceNo() : "REC-001";
            defaultBilledBy = currentUser.getFullName();
        }

        // Setup default calculated line items if bill doesn't exist yet
        if (appointment != null && bill == null) {
            bill = new Bill();
            bill.setBillNo(billDAO.getNextBillNo());
            bill.setAppointmentId(appointment.getId());
            bill.setPaymentMethod("Cash");
            bill.setPaymentStatus("Paid");
            bill.setUserInvoiceNo(defaultReceptionistId);
            bill.setBilledBy(defaultBilledBy);

            // Copy joined appointment fields
            bill.setAppointmentNo(appointment.getAppointmentNo());
            bill.setPatientName(appointment.getPatientName());
            bill.setPatientAddress(appointment.getPatientAddress());
            bill.setPatientContact(appointment.getPatientContact());
            bill.setDentistName(appointment.getDentistName());
            bill.setTreatmentName(appointment.getTreatmentName());
            bill.setAppointmentDate(appointment.getAppointmentDate());
            bill.setAppointmentTime(appointment.getAppointmentTime());

            // Add dynamic initial service items
            List<BillItem> initialItems = new ArrayList<>();
            BigDecimal subTotal = BigDecimal.ZERO;

            // 1. Consultation Service
            BigDecimal consultFee = new BigDecimal("1000.00");
            initialItems.add(new BillItem(0, 0, null, "Checkup & Consultation", 1, consultFee, consultFee));
            subTotal = subTotal.add(consultFee);

            // 2. Primary treatment from appointment if not already consultation
            if (appointment.getTreatmentName() != null && !appointment.getTreatmentName().toLowerCase().contains("consultation")) {
                BigDecimal treatFee = appointment.getTreatmentCost() != null ? appointment.getTreatmentCost() : new BigDecimal("3500.00");
                initialItems.add(new BillItem(0, 0, appointment.getTreatmentId(), appointment.getTreatmentName(), 1, treatFee, treatFee));
                subTotal = subTotal.add(treatFee);
            }

            bill.setItems(initialItems);
            bill.setSubTotal(subTotal);
            bill.setDiscount(BigDecimal.ZERO);
            bill.setTotalAmount(subTotal);
        } else if (bill != null) {
            if (bill.getUserInvoiceNo() == null || bill.getUserInvoiceNo().isEmpty()) {
                bill.setUserInvoiceNo(defaultReceptionistId);
                bill.setBilledBy(defaultBilledBy);
            }
            if (bill.getItems() == null || bill.getItems().isEmpty()) {
                List<BillItem> loadedItems = billDAO.getBillItems(bill.getId());
                bill.setItems(loadedItems);
            }
        }

        request.setAttribute("appointment", appointment);
        request.setAttribute("bill", bill);
        request.setAttribute("treatments", treatments);
        request.setAttribute("activeReceptionists", activeReceptionists);
        request.setAttribute("userInvoiceNo", defaultReceptionistId);
        request.setAttribute("billedBy", defaultBilledBy);
        request.getRequestDispatcher("/WEB-INF/views/billing.jsp").forward(request, response);
    }

    private void showReceipt(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String billNo = request.getParameter("billNo");
        String apptNo = request.getParameter("no");
        Bill bill = null;

        if (billNo != null && !billNo.trim().isEmpty()) {
            bill = billDAO.getBillByBillNo(billNo.trim());
        } else if (apptNo != null && !apptNo.trim().isEmpty()) {
            Appointment appt = appointmentDAO.getAppointmentByNo(apptNo.trim());
            if (appt != null) {
                bill = billDAO.getBillByAppointmentId(appt.getId());
            }
        }

        if (bill == null) {
            bill = billDAO.getBillByBillNo("INV-000001");
        }

        request.setAttribute("bill", bill);
        request.getRequestDispatcher("/WEB-INF/views/bill-receipt.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int appointmentId = Integer.parseInt(request.getParameter("appointmentId"));
            String billNo = request.getParameter("billNo");
            String userInvoiceNo = request.getParameter("userInvoiceNo"); // Receptionist ID
            String billedBy = request.getParameter("billedBy");
            String paymentMethod = request.getParameter("paymentMethod");
            String paymentStatus = request.getParameter("paymentStatus");

            String discountStr = request.getParameter("discount");
            BigDecimal discount = BigDecimal.ZERO;
            if (discountStr != null && !discountStr.trim().isEmpty()) {
                try {
                    discount = new BigDecimal(discountStr.trim());
                    if (discount.compareTo(BigDecimal.ZERO) < 0) {
                        discount = BigDecimal.ZERO;
                    }
                } catch (NumberFormatException ignored) {}
            }

            // Parse Line Items
            String[] itemTreatmentIds = request.getParameterValues("itemTreatmentId");
            String[] itemTreatmentNames = request.getParameterValues("itemTreatmentName");
            String[] itemQuantities = request.getParameterValues("itemQuantity");
            String[] itemUnitPrices = request.getParameterValues("itemUnitPrice");

            if (itemTreatmentNames == null || itemTreatmentNames.length == 0) {
                response.sendRedirect(request.getContextPath() + "/billing?error=no_items");
                return;
            }

            List<BillItem> items = new ArrayList<>();
            BigDecimal subTotal = BigDecimal.ZERO;

            for (int i = 0; i < itemTreatmentNames.length; i++) {
                String name = itemTreatmentNames[i] != null ? itemTreatmentNames[i].trim() : "";
                if (name.isEmpty()) continue;

                Integer tId = null;
                if (itemTreatmentIds != null && i < itemTreatmentIds.length && itemTreatmentIds[i] != null && !itemTreatmentIds[i].trim().isEmpty()) {
                    try {
                        tId = Integer.parseInt(itemTreatmentIds[i].trim());
                    } catch (NumberFormatException ignored) {}
                }

                int qty = 1;
                if (itemQuantities != null && i < itemQuantities.length && itemQuantities[i] != null) {
                    try {
                        qty = Integer.parseInt(itemQuantities[i].trim());
                        if (qty < 1) qty = 1;
                    } catch (NumberFormatException ignored) {}
                }

                BigDecimal price = BigDecimal.ZERO;
                if (itemUnitPrices != null && i < itemUnitPrices.length && itemUnitPrices[i] != null) {
                    try {
                        price = new BigDecimal(itemUnitPrices[i].trim());
                        if (price.compareTo(BigDecimal.ZERO) < 0) price = BigDecimal.ZERO;
                    } catch (NumberFormatException ignored) {}
                }

                BigDecimal lineTotal = price.multiply(new BigDecimal(qty));
                subTotal = subTotal.add(lineTotal);

                BillItem item = new BillItem();
                item.setTreatmentId(tId);
                item.setTreatmentName(name);
                item.setQuantity(qty);
                item.setUnitPrice(price);
                item.setLineTotal(lineTotal);
                items.add(item);
            }

            if (items.isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/billing?error=no_valid_items");
                return;
            }

            if (discount.compareTo(subTotal) > 0) {
                discount = subTotal; // Cap discount to subtotal
            }

            BigDecimal totalAmount = subTotal.subtract(discount);
            if (totalAmount.compareTo(BigDecimal.ZERO) < 0) {
                totalAmount = BigDecimal.ZERO;
            }

            if (billNo == null || billNo.trim().isEmpty()) {
                billNo = billDAO.getNextBillNo();
            }

            if (userInvoiceNo == null || userInvoiceNo.trim().isEmpty()) {
                userInvoiceNo = "REC-001";
            }
            if (billedBy == null || billedBy.trim().isEmpty()) {
                billedBy = "Receptionist";
            }
            if (paymentMethod == null || paymentMethod.trim().isEmpty()) {
                paymentMethod = "Cash";
            }
            if (paymentStatus == null || paymentStatus.trim().isEmpty()) {
                paymentStatus = "Paid";
            }

            Bill bill = new Bill();
            bill.setBillNo(billNo.trim());
            bill.setAppointmentId(appointmentId);
            bill.setSubTotal(subTotal);
            bill.setDiscount(discount);
            bill.setTotalAmount(totalAmount);
            bill.setPaymentMethod(paymentMethod.trim());
            bill.setPaymentStatus(paymentStatus.trim());
            bill.setUserInvoiceNo(userInvoiceNo.trim());
            bill.setBilledBy(billedBy.trim());
            bill.setItems(items);

            boolean success = billDAO.saveInvoiceWithTransaction(bill, items);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/billing?action=receipt&billNo=" + bill.getBillNo());
            } else {
                response.sendRedirect(request.getContextPath() + "/billing?error=save_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/billing?error=invalid_data");
        }
    }
}
