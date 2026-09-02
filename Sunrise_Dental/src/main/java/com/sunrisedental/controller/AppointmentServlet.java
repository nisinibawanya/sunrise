package com.sunrisedental.controller;

import com.sunrisedental.dao.AppointmentDAO;
import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.dao.PatientDAO;
import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Appointment;
import com.sunrisedental.model.Dentist;
import com.sunrisedental.model.Treatment;
import com.sunrisedental.util.EmailService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.Date;
import java.util.List;

@WebServlet(name = "AppointmentServlet", urlPatterns = {"/appointments", "/appointments/*"})
public class AppointmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private AppointmentDAO appointmentDAO;
    private DentistDAO dentistDAO;
    private TreatmentDAO treatmentDAO;
    private PatientDAO patientDAO;

    @Override
    public void init() throws ServletException {
        this.appointmentDAO = new AppointmentDAO();
        this.dentistDAO = new DentistDAO();
        this.treatmentDAO = new TreatmentDAO();
        this.patientDAO = new PatientDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if (action == null) {
            action = "search";
        }

        switch (action) {
            case "new":
                showNewForm(request, response);
                break;
            case "search":
                searchAppointment(request, response);
                break;
            case "edit":
                showEditForm(request, response);
                break;
            case "delete":
                deleteAppointment(request, response);
                break;
            case "list":
            default:
                listAllAppointments(request, response);
                break;
        }
    }

    private void showNewForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String nextApptNo = appointmentDAO.getNextAppointmentNo();
        List<Dentist> dentists = dentistDAO.getAllDentists();
        List<Treatment> treatments = treatmentDAO.getAllTreatments();

        request.setAttribute("nextApptNo", nextApptNo);
        request.setAttribute("dentists", dentists);
        request.setAttribute("treatments", treatments);
        request.getRequestDispatcher("/WEB-INF/views/appointment-new.jsp").forward(request, response);
    }

    private void searchAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String apptNo = request.getParameter("no");
        String query = request.getParameter("query");

        if (apptNo != null && !apptNo.trim().isEmpty()) {
            Appointment appt = appointmentDAO.getAppointmentByNo(apptNo.trim());
            request.setAttribute("appointment", appt);
            request.setAttribute("searchQuery", apptNo.trim());
            if (appt == null) {
                request.setAttribute("notFoundMessage", "No appointment found with Number: " + apptNo);
            }
        } else if (query != null && !query.trim().isEmpty()) {
            Appointment appt = appointmentDAO.getAppointmentByNo(query.trim());
            if (appt != null) {
                request.setAttribute("appointment", appt);
            } else {
                List<Appointment> results = appointmentDAO.searchAppointments(query.trim());
                if (!results.isEmpty()) {
                    request.setAttribute("appointment", results.get(0));
                    request.setAttribute("searchResults", results);
                } else {
                    request.setAttribute("notFoundMessage", "No appointments matching: " + query);
                }
            }
            request.setAttribute("searchQuery", query.trim());
        } else {
            // Default sample load: try A1002 or first today appointment if available
            Appointment appt = appointmentDAO.getAppointmentByNo("A1002");
            if (appt == null) {
                List<Appointment> today = appointmentDAO.getTodayAppointments();
                if (!today.isEmpty()) {
                    appt = today.get(0);
                }
            }
            if (appt != null) {
                request.setAttribute("appointment", appt);
                request.setAttribute("searchQuery", appt.getAppointmentNo());
            }
        }

        request.getRequestDispatcher("/WEB-INF/views/appointment-search.jsp").forward(request, response);
    }

    private void showEditForm(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String noParam = request.getParameter("no");
        Appointment appt = null;

        if (idParam != null) {
            try {
                appt = appointmentDAO.getAppointmentById(Integer.parseInt(idParam));
            } catch (NumberFormatException ignored) {}
        } else if (noParam != null) {
            appt = appointmentDAO.getAppointmentByNo(noParam);
        }

        if (appt != null) {
            List<Dentist> dentists = dentistDAO.getAllDentists();
            List<Treatment> treatments = treatmentDAO.getAllTreatments();
            request.setAttribute("appointment", appt);
            request.setAttribute("dentists", dentists);
            request.setAttribute("treatments", treatments);
            request.getRequestDispatcher("/WEB-INF/views/appointment-edit.jsp").forward(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/appointments?action=search&error=notfound");
        }
    }

    private void deleteAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String idParam = request.getParameter("id");
        String noParam = request.getParameter("no");
        boolean deleted = false;

        if (idParam != null) {
            try {
                deleted = appointmentDAO.deleteAppointment(Integer.parseInt(idParam));
            } catch (NumberFormatException ignored) {}
        } else if (noParam != null) {
            deleted = appointmentDAO.deleteAppointmentByNo(noParam);
        }

        if (deleted) {
            response.sendRedirect(request.getContextPath() + "/appointments?action=search&success=deleted");
        } else {
            response.sendRedirect(request.getContextPath() + "/appointments?action=search&error=delete_failed");
        }
    }

    private void listAllAppointments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Appointment> list = appointmentDAO.getAllAppointments();
        request.setAttribute("appointmentsList", list);
        request.getRequestDispatcher("/WEB-INF/views/appointment-search.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createAppointment(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            updateAppointment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/appointments?action=search");
        }
    }

    private void createAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            String apptNo = request.getParameter("appointmentNo");
            String dentistIdStr = request.getParameter("dentistId");
            String patientName = request.getParameter("patientName");
            String treatmentIdStr = request.getParameter("treatmentId");
            String address = request.getParameter("address");
            String contactNumber = request.getParameter("contactNumber");
            String patientEmail = request.getParameter("patientEmail");
            String apptDateStr = request.getParameter("appointmentDate");
            String apptTime = request.getParameter("appointmentTime");
            String notes = request.getParameter("notes");

            if (apptNo == null || apptNo.trim().isEmpty()) {
                apptNo = appointmentDAO.getNextAppointmentNo();
            }

            Date apptDate = Date.valueOf(apptDateStr);
            int dentistId = Integer.parseInt(dentistIdStr);
            int treatmentId = Integer.parseInt(treatmentIdStr);

            // Find or create patient with email
            int patientId = patientDAO.findOrCreatePatient(patientName, address, contactNumber, patientEmail, apptDate);

            Appointment appt = new Appointment();
            appt.setAppointmentNo(apptNo.trim());
            appt.setPatientId(patientId);
            appt.setDentistId(dentistId);
            appt.setTreatmentId(treatmentId);
            appt.setAppointmentDate(apptDate);
            appt.setAppointmentTime(apptTime != null ? apptTime.trim() : "09:00 AM");
            appt.setStatus("Confirmed");
            appt.setNotes(notes);

            boolean success = appointmentDAO.createAppointment(appt);
            if (success) {
                // Send automated email confirmation to patient
                Dentist dentist = dentistDAO.getDentistById(dentistId);
                Treatment treatment = treatmentDAO.getTreatmentById(treatmentId);
                String dentistName = dentist != null ? dentist.getName() : "Dr. Silva";
                String treatmentName = treatment != null ? treatment.getName() : "Dental Care";

                EmailService.sendAppointmentConfirmation(
                    patientEmail, 
                    patientName, 
                    apptNo, 
                    dentistName, 
                    treatmentName, 
                    apptDate.toString(), 
                    apptTime
                );

                response.sendRedirect(request.getContextPath() + "/appointments?action=search&no=" + apptNo + "&success=created");
            } else {
                request.setAttribute("errorMessage", "Could not save appointment. Please verify details.");
                showNewForm(request, response);
            }
        } catch (Exception e) {
            e.printStackTrace();
            request.setAttribute("errorMessage", "Error processing appointment: " + e.getMessage());
            showNewForm(request, response);
        }
    }

    private void updateAppointment(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String apptNo = request.getParameter("appointmentNo");
            int dentistId = Integer.parseInt(request.getParameter("dentistId"));
            int treatmentId = Integer.parseInt(request.getParameter("treatmentId"));
            int patientId = Integer.parseInt(request.getParameter("patientId"));
            String patientName = request.getParameter("patientName");
            String address = request.getParameter("address");
            String contactNumber = request.getParameter("contactNumber");
            String patientEmail = request.getParameter("patientEmail");
            Date apptDate = Date.valueOf(request.getParameter("appointmentDate"));
            String apptTime = request.getParameter("appointmentTime");
            String status = request.getParameter("status");
            String notes = request.getParameter("notes");

            // Update patient details with email
            patientDAO.updatePatientDetails(patientId, address, contactNumber, patientEmail, apptDate);

            Appointment appt = new Appointment();
            appt.setId(id);
            appt.setAppointmentNo(apptNo);
            appt.setPatientId(patientId);
            appt.setDentistId(dentistId);
            appt.setTreatmentId(treatmentId);
            appt.setAppointmentDate(apptDate);
            appt.setAppointmentTime(apptTime);
            appt.setStatus(status != null ? status : "Confirmed");
            appt.setNotes(notes);

            boolean success = appointmentDAO.updateAppointment(appt);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/appointments?action=search&no=" + apptNo + "&success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/appointments?action=edit&id=" + id + "&error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/appointments?action=search&error=invalid_data");
        }
    }
}
