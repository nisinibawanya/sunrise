package com.sunrisedental.controller;

import com.sunrisedental.dao.ReceptionistDAO;
import com.sunrisedental.dao.UserDAO;
import com.sunrisedental.model.Receptionist;
import com.sunrisedental.model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet(name = "UserServlet", urlPatterns = {"/users", "/users/*"})
public class UserServlet extends HttpServlet {
    private static final long serialVersionUID = 1L;
    private UserDAO userDAO;
    private ReceptionistDAO receptionistDAO;

    @Override
    public void init() throws ServletException {
        this.userDAO = new UserDAO();
        this.receptionistDAO = new ReceptionistDAO();
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
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.sendRedirect(request.getContextPath() + "/dashboard?error=access_denied");
            return;
        }

        String action = request.getParameter("action");
        if ("delete_receptionist".equalsIgnoreCase(action)) {
            deleteReceptionist(request, response);
            return;
        } else if ("toggle_status".equalsIgnoreCase(action)) {
            toggleReceptionistStatus(request, response);
            return;
        }

        List<User> users = userDAO.getAllUsers();
        List<Receptionist> receptionists = receptionistDAO.getAllReceptionists();
        String nextCode = receptionistDAO.getNextReceptionistCode();

        request.setAttribute("users", users);
        request.setAttribute("receptionists", receptionists);
        request.setAttribute("nextReceptionistCode", nextCode);
        request.getRequestDispatcher("/WEB-INF/views/users.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        if (!isAdmin(request)) {
            response.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.sendRedirect(request.getContextPath() + "/dashboard?error=access_denied");
            return;
        }

        String action = request.getParameter("action");
        if ("register_receptionist".equalsIgnoreCase(action)) {
            registerReceptionist(request, response);
        } else if ("update_receptionist".equalsIgnoreCase(action)) {
            updateReceptionist(request, response);
        } else if ("toggle_status".equalsIgnoreCase(action)) {
            toggleReceptionistStatus(request, response);
        } else if ("delete_receptionist".equalsIgnoreCase(action)) {
            deleteReceptionist(request, response);
        } else if ("change_password".equalsIgnoreCase(action) || "update".equalsIgnoreCase(action)) {
            changeUserPassword(request, response);
        } else {
            response.sendRedirect(request.getContextPath() + "/users");
        }
    }

    private void registerReceptionist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            String fullName = request.getParameter("fullName");
            String contactNumber = request.getParameter("contactNumber");
            String email = request.getParameter("email");
            String status = request.getParameter("status");

            if (fullName == null || fullName.trim().isEmpty() ||
                contactNumber == null || contactNumber.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/users?error=required_fields");
                return;
            }

            // Check for duplicate contact number or email
            if (receptionistDAO.isDuplicate(contactNumber.trim(), email != null ? email.trim() : "", null)) {
                response.sendRedirect(request.getContextPath() + "/users?error=duplicate_entry");
                return;
            }

            String code = receptionistDAO.getNextReceptionistCode();
            Receptionist r = new Receptionist();
            r.setReceptionistCode(code);
            r.setFullName(fullName.trim());
            r.setContactNumber(contactNumber.trim());
            r.setEmail(email != null ? email.trim() : "");
            r.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "Active");

            boolean success = receptionistDAO.createReceptionist(r);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/users?success=receptionist_created&code=" + code);
            } else {
                response.sendRedirect(request.getContextPath() + "/users?error=create_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/users?error=invalid_data");
        }
    }

    private void updateReceptionist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String fullName = request.getParameter("fullName");
            String contactNumber = request.getParameter("contactNumber");
            String email = request.getParameter("email");
            String status = request.getParameter("status");

            if (fullName == null || fullName.trim().isEmpty() ||
                contactNumber == null || contactNumber.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/users?error=required_fields");
                return;
            }

            // Check duplicate excluding self
            if (receptionistDAO.isDuplicate(contactNumber.trim(), email != null ? email.trim() : "", id)) {
                response.sendRedirect(request.getContextPath() + "/users?error=duplicate_entry");
                return;
            }

            Receptionist r = receptionistDAO.getReceptionistById(id);
            if (r == null) {
                response.sendRedirect(request.getContextPath() + "/users?error=not_found");
                return;
            }

            r.setFullName(fullName.trim());
            r.setContactNumber(contactNumber.trim());
            r.setEmail(email != null ? email.trim() : "");
            r.setStatus(status != null && !status.trim().isEmpty() ? status.trim() : "Active");

            boolean success = receptionistDAO.updateReceptionist(r);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/users?success=receptionist_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/users?error=update_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/users?error=invalid_data");
        }
    }

    private void toggleReceptionistStatus(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String newStatus = request.getParameter("status");

            if (newStatus == null || newStatus.trim().isEmpty()) {
                Receptionist r = receptionistDAO.getReceptionistById(id);
                if (r != null) {
                    newStatus = r.isActive() ? "Inactive" : "Active";
                } else {
                    newStatus = "Active";
                }
            }

            boolean success = receptionistDAO.updateStatus(id, newStatus);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/users?success=status_updated");
            } else {
                response.sendRedirect(request.getContextPath() + "/users?error=status_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/users?error=invalid_id");
        }
    }

    private void deleteReceptionist(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            boolean success = receptionistDAO.deleteReceptionist(id);
            if (success) {
                response.sendRedirect(request.getContextPath() + "/users?success=receptionist_deleted");
            } else {
                response.sendRedirect(request.getContextPath() + "/users?error=delete_failed");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/users?error=invalid_id");
        }
    }

    private void changeUserPassword(HttpServletRequest request, HttpServletResponse response)
            throws IOException {
        try {
            int id = Integer.parseInt(request.getParameter("id"));
            String password = request.getParameter("password");

            if (password == null || password.trim().isEmpty()) {
                response.sendRedirect(request.getContextPath() + "/users?error=empty_password");
                return;
            }

            User user = userDAO.getUserById(id);
            if (user != null) {
                user.setPassword(password.trim());
                boolean success = userDAO.updateUser(user);
                if (success) {
                    response.sendRedirect(request.getContextPath() + "/users?success=password_updated");
                } else {
                    response.sendRedirect(request.getContextPath() + "/users?error=password_failed");
                }
            } else {
                response.sendRedirect(request.getContextPath() + "/users?error=user_not_found");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.sendRedirect(request.getContextPath() + "/users?error=invalid_data");
        }
    }
}
