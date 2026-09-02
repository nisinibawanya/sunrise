package com.sunrisedental.controller;

import com.sunrisedental.dao.DentistDAO;
import com.sunrisedental.model.Dentist;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "DentistServlet", urlPatterns = {"/dentists", "/dentists/*"})
public class DentistServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private DentistDAO dentistDAO;

    @Override
    public void init() throws ServletException {
        this.dentistDAO = new DentistDAO();
    }

    private boolean isAdmin(HttpServletRequest request) {
        HttpSession session = request.getSession(false);
        if (session == null) return false;
        String role = (String) session.getAttribute("userRole");
        return "Admin".equalsIgnoreCase(role) || "Administrator".equalsIgnoreCase(role);
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");
        if ("delete".equalsIgnoreCase(action)) {
            if (!isAdmin(request)) {
                response.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.sendRedirect(request.getContextPath() + "/dentists?error=access_denied");
                return;
            }
            deleteDentist(request, response);
            return;
        }

        List<Dentist> dentists = dentistDAO.getAllDentists();
        request.setAttribute("dentists", dentists);
        request.getRequestDispatcher("/WEB-INF/views/dentists.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.sendRedirect(request.getContextPath() + "/dentists?error=access_denied");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createDentist(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            updateDentist(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/dentists");
        }
    }

    private void createDentist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String name = request.getParameter("name");
            String specialization = request.getParameter("specialization");
            String contactNumber = request.getParameter("contactNumber");
            String email = request.getParameter("email");
            String roomNo = request.getParameter("roomNo");

            Dentist dentist = new Dentist();
            dentist.setName(name);
            dentist.setSpecialization(specialization);
            dentist.setContactNumber(contactNumber);
            dentist.setEmail(email);
            dentist.setRoomNo(roomNo != null && !roomNo.trim().isEmpty() ? roomNo : "Room 1");
            dentist.setActive(true);

            boolean success = dentistDAO.createDentist(dentist);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/dentists?success=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/dentists?error=create_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dentists?error=invalid_data");
        }
    }

    private void updateDentist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String specialization = request.getParameter("specialization");
            String contactNumber = request.getParameter("contactNumber");
            String email = request.getParameter("email");
            String roomNo = request.getParameter("roomNo");
            String activeParam = request.getParameter("active");
            boolean active = !"false".equalsIgnoreCase(activeParam);

            Dentist dentist = new Dentist();
            dentist.setId(id);
            dentist.setName(name);
            dentist.setSpecialization(specialization);
            dentist.setContactNumber(contactNumber);
            dentist.setEmail(email);
            dentist.setRoomNo(roomNo);
            dentist.setActive(active);

            boolean success = dentistDAO.updateDentist(dentist);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/dentists?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/dentists?error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dentists?error=invalid_data");
        }
    }

    private void deleteDentist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = dentistDAO.deleteDentist(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/dentists?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/dentists?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/dentists?error=invalid_id");
        }
    }
}
