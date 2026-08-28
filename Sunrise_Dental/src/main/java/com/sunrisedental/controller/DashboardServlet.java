package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.BillDAO;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Patient;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "DashboardServlet", urlPatterns = {"/dashboard"})
public class DashboardServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private AppointmentDAO appointmentDAO;
    private PatientDAO patientDAO;
    private BillDAO billDAO;

    @Override
    public void init() throws ServletException {
        this.appointmentDAO = new AppointmentDAO();
        this.patientDAO = new PatientDAO();
        this.billDAO = new BillDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Appointment> todayAppointments = appointmentDAO.getTodayAppointments();
        List<Patient> recentPatients = patientDAO.getRecentPatients(5);
        int totalPatients = patientDAO.countTotalPatients();
        int todayApptCount = appointmentDAO.countTodayAppointments();
        int totalApptCount = appointmentDAO.countTotalAppointments();
        BigDecimal totalRevenue = billDAO.getTotalRevenue();

        request.setAttribute("todayAppointments", todayAppointments);
        request.setAttribute("recentPatients", recentPatients);
        request.setAttribute("totalPatients", totalPatients);
        request.setAttribute("todayApptCount", todayApptCount);
        request.setAttribute("totalApptCount", totalApptCount);
        request.setAttribute("totalRevenue", totalRevenue);

        request.getRequestDispatcher("/WEB-INF/views/dashboard.jsp").forward(request, response);
    }
}
