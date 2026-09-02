package com.sunrisedental.controller;

import com.sunrisedental.dao.TreatmentDAO;
import com.sunrisedental.model.Treatment;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.util.List;

@WebServlet(name = "TreatmentServlet", urlPatterns = {"/treatments", "/treatments/*"})
public class TreatmentServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private TreatmentDAO treatmentDAO;

    @Override
    public void init() throws ServletException {
        this.treatmentDAO = new TreatmentDAO();
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
                response.sendRedirect(request.getContextPath() + "/treatments?error=access_denied");
                return;
            }
            deleteTreatment(request, response);
            return;
        }
        listTreatments(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.sendRedirect(request.getContextPath() + "/treatments?error=access_denied");
            return;
        }

        String action = request.getParameter("action");
        if ("create".equalsIgnoreCase(action)) {
            createTreatment(request, response);
        } else if ("update".equalsIgnoreCase(action)) {
            updateTreatment(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/treatments");
        }
    }

    private void listTreatments(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        List<Treatment> treatments = treatmentDAO.getAllTreatments();
        request.setAttribute("treatments", treatments);
        request.getRequestDispatcher("/WEB-INF/views/treatments.jsp").forward(request, response);
    }

    private void createTreatment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String name = request.getParameter("name");
            String costStr = request.getParameter("cost");
            String description = request.getParameter("description");

            if (name == null || name.trim().isEmpty() || costStr == null || costStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/treatments?error=missing_fields");
                return;
            }

            Treatment t = new Treatment();
            t.setName(name.trim());
            t.setCost(new BigDecimal(costStr.trim()));
            t.setDescription(description);

            boolean success = treatmentDAO.createTreatment(t);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/treatments?success=created");
            } else {
                response.sendRedirect(request.getContextPath() + "/treatments?error=create_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/treatments?error=invalid_cost");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/treatments?error=server_error");
        }
    }

    private void updateTreatment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String name = request.getParameter("name");
            String costStr = request.getParameter("cost");
            String description = request.getParameter("description");

            if (name == null || name.trim().isEmpty() || costStr == null || costStr.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/treatments?error=missing_fields");
                return;
            }

            Treatment t = new Treatment();
            t.setId(id);
            t.setName(name.trim());
            t.setCost(new BigDecimal(costStr.trim()));
            t.setDescription(description);

            boolean success = treatmentDAO.updateTreatment(t);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/treatments?success=updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/treatments?error=update_failed");
            }
        } catch (NumberFormatException e) {
            response.sendRedirect(request.getContextPath() + "/treatments?error=invalid_data");
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/treatments?error=server_error");
        }
    }

    private void deleteTreatment(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = treatmentDAO.deleteTreatment(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/treatments?success=deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/treatments?error=delete_failed_appointments");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/treatments?error=invalid_id");
        }
    }
}
