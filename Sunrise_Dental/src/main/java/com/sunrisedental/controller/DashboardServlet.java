package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.ReceptionistDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Bill;
import com.sunrisedental.model.Patient;
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

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private BillDAO billDAO;
    private DentistDAO dentistDAO;
    private TreatmentDAO treatmentDAO;
    private ReceptionistDAO receptionistDAO;

    @Override
    public void init() throws ServletException {
        this.appointmentDAO = new AppointmentDAO();
        this.patientDAO = new PatientDAO();
        this.billDAO = new BillDAO();
        this.dentistDAO = new DentistDAO();
        this.treatmentDAO = new TreatmentDAO();
        this.receptionistDAO = new ReceptionistDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        HttpSession session = request.getSession(false);
        String userRole = session != null ? (String) session.getAttribute("userRole") : null;
        boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);

        List<Appointment> todayAppointments = new ArrayList<>();
        List<Patient> recentPatients = new ArrayList<>();
        int todayApptCount = 0;
        int totalPatients = 0;
        int upcomingApptCount = 0;
        int pendingBillsCount = 0;

        // Admin-only metrics and lists
        BigDecimal todayRevenue = BigDecimal.ZERO;
        BigDecimal totalRevenue = BigDecimal.ZERO;
        int activeReceptionistsCount = 0;
        int activeDentistsCount = 0;
        int availableTreatmentsCount = 0;
        List<Bill> recentBills = new ArrayList<>();

        try {
            todayAppointments = appointmentDAO.getTodayAppointments();
            recentPatients = patientDAO.getRecentPatients(5);
            todayApptCount = appointmentDAO.countTodayAppointments();
            totalPatients = patientDAO.countTotalPatients();
            upcomingApptCount = appointmentDAO.countUpcomingAppointments();
            pendingBillsCount = billDAO.countPendingBills();

            if (isAdmin) {
                todayRevenue = billDAO.getTodayRevenue();
                totalRevenue = billDAO.getTotalRevenue();
                activeReceptionistsCount = receptionistDAO.countActiveReceptionists();
                activeDentistsCount = dentistDAO.countActiveDentists();
                availableTreatmentsCount = treatmentDAO.countTotalTreatments();
                recentBills = billDAO.getRecentBills(5);
            }
        } catch (Exception e) {
            System.err.println("Error loading dashboard data: " + e.getMessage());
            e.printStackTrace();
            request.setAttribute("errorMessage", "Some dashboard metrics could not be loaded. Please refresh.");
        }

        request.setAttribute("isAdmin", isAdmin);
        request.setAttribute("todayAppointments", todayAppointments);
        request.setAttribute("recentPatients", recentPatients);
        request.setAttribute("todayApptCount", todayApptCount);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("upcomingApptCount", upcomingApptCount);
        request.setAttribute("pendingBillsCount", pendingBillsCount);

        // Admin-only attributes
        request.setAttribute("todayRevenue", todayRevenue);
        request.setAttribute("totalRevenue", totalRevenue);
        request.setAttribute("activeReceptionistsCount", activeReceptionistsCount);
        request.setAttribute("activeDentistsCount", activeDentistsCount);
        request.setAttribute("availableTreatmentsCount", availableTreatmentsCount);
        request.setAttribute("recentBills", recentBills);

        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}
