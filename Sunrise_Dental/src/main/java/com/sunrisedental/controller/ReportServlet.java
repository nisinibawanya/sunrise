package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Bill;
import com.sunrisedental.model.Patient;
import com.sunrisedental.model.Treatment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Date;
import java.time.LocalDate;
import java.util.List;

@WebServlet(name = "ReportServlet", urlPatterns = {"/reports", "/reports/*"})
public class ReportServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private TreatmentDAO treatmentDAO;
    private BillDAO billDAO;

    @Override
    public void init() throws ServletException {
        this.appointmentDAO = new AppointmentDAO();
        this.patientDAO = new PatientDAO();
        this.treatmentDAO = new TreatmentDAO();
        this.billDAO = new BillDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userRole = session != null ? (String) session.getAttribute("userRole") : null;
        boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);

        request.setAttribute("isAdmin", isAdmin);

        String type = request.getParameter("type");
        if (type == null || type.trim().isEmpty()) {
            type = "dashboard";
        } else {
            type = type.trim().toLowerCase();
        }

        // BACKEND ROLE SECURITY CHECK
        // If a non-admin attempts to access revenue/financial reports, reject access
        if (!isAdmin && ("revenue".equals(type) || "financial".equals(type))) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            request.setAttribute("errorMessage", "Access denied. Financial reports are available to Administrators only.");
            type = "dashboard";
        }

        try {
            switch (type) {
                case "daily": {
                    String dateStr = request.getParameter("date");
                    Date reportDate;
                    if (dateStr != null && !dateStr.trim().isEmpty()) {
                        try {
                            reportDate = Date.valueOf(dateStr.trim());
                        } catch (IllegalArgumentException e) {
                            reportDate = Date.valueOf(LocalDate.now());
                        }
                    } else {
                        reportDate = Date.valueOf(LocalDate.now());
                    }
                    List<Appointment> dailyList = appointmentDAO.getAppointmentsByDate(reportDate);
                    request.setAttribute("reportDate", reportDate.toString());
                    request.setAttribute("dailyAppointments", dailyList);
                    request.setAttribute("activeTab", "daily");
                    break;
                }

                case "patient": {
                    List<Patient> patients = patientDAO.getAllPatients();
                    request.setAttribute("patientsList", patients);
                    request.setAttribute("activeTab", "patient");
                    break;
                }

                case "treatment": {
                    String fromStr = request.getParameter("from");
                    String toStr = request.getParameter("to");
                    Date fromDate = null;
                    Date toDate = null;

                    if (fromStr != null && !fromStr.trim().isEmpty()) {
                        try {
                            fromDate = Date.valueOf(fromStr.trim());
                        } catch (IllegalArgumentException ignored) {}
                    }
                    if (toStr != null && !toStr.trim().isEmpty()) {
                        try {
                            toDate = Date.valueOf(toStr.trim());
                        } catch (IllegalArgumentException ignored) {}
                    }

                    List<Treatment> treatments = treatmentDAO.getTreatmentUsageReport(fromDate, toDate);
                    request.setAttribute("treatmentsList", treatments);
                    request.setAttribute("fromDateStr", fromStr != null ? fromStr.trim() : "");
                    request.setAttribute("toDateStr", toStr != null ? toStr.trim() : "");
                    request.setAttribute("activeTab", "treatment");
                    break;
                }

                case "pending":
                case "pending_bills": {
                    List<Bill> pendingBills = billDAO.getPendingBills();
                    request.setAttribute("pendingBillsList", pendingBills);
                    request.setAttribute("activeTab", "pending");
                    break;
                }

                case "revenue": {
                    // Handled only for Admin
                    String fromStr = request.getParameter("from");
                    String toStr = request.getParameter("to");
                    String status = request.getParameter("status");
                    String method = request.getParameter("method");

                    Date fromDate = null;
                    Date toDate = null;

                    if (fromStr != null && !fromStr.trim().isEmpty()) {
                        try {
                            fromDate = Date.valueOf(fromStr.trim());
                        } catch (IllegalArgumentException ignored) {}
                    }
                    if (toStr != null && !toStr.trim().isEmpty()) {
                        try {
                            toDate = Date.valueOf(toStr.trim());
                        } catch (IllegalArgumentException ignored) {}
                    }

                    List<Bill> bills = billDAO.getFilteredBills(fromDate, toDate, status, method);

                    BigDecimal totalInvoiced = BigDecimal.ZERO;
                    BigDecimal totalCollected = BigDecimal.ZERO;
                    BigDecimal outstandingBalance = BigDecimal.ZERO;

                    for (Bill b : bills) {
                        if (b.getTotalAmount() != null) {
                            totalInvoiced = totalInvoiced.add(b.getTotalAmount());
                        }
                        totalCollected = totalCollected.add(b.getAmountPaid());
                        outstandingBalance = outstandingBalance.add(b.getBalanceDue());
                    }

                    request.setAttribute("billsList", bills);
                    request.setAttribute("totalInvoiced", totalInvoiced);
                    request.setAttribute("totalCollected", totalCollected);
                    request.setAttribute("outstandingBalance", outstandingBalance);
                    request.setAttribute("fromDateStr", fromStr != null ? fromStr.trim() : "");
                    request.setAttribute("toDateStr", toStr != null ? toStr.trim() : "");
                    request.setAttribute("selectedStatus", status != null ? status.trim() : "All");
                    request.setAttribute("selectedMethod", method != null ? method.trim() : "All");
                    request.setAttribute("activeTab", "revenue");
                    break;
                }

                case "dashboard":
                default: {
                    int todayCount = appointmentDAO.countTodayAppointments();
                    int patientCount = patientDAO.countTotalPatients();
                    int apptCount = appointmentDAO.countTotalAppointments();

                    request.setAttribute("todayCount", todayCount);
                    request.setAttribute("patientCount", patientCount);
                    request.setAttribute("apptCount", apptCount);

                    if (isAdmin) {
                        BigDecimal revenue = billDAO.getTotalRevenue();
                        request.setAttribute("revenue", revenue);
                    } else {
                        int pendingBillsCount = billDAO.countPendingBills();
                        request.setAttribute("pendingBillsCount", pendingBillsCount);
                    }
                    request.setAttribute("activeTab", "dashboard");
                    break;
                }
            }
        } catch (Exception e) {
            System.err.println("Error generating report: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "An error occurred while generating the report. Please try again.");
            request.setAttribute("activeTab", "dashboard");
        }

        request.getRequestDispatcher("/WEB-INF/views/reports.jsp").forward(request, response);
    }
}
