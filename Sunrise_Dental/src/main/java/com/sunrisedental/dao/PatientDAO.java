package com.sunrisedental.dao;

import com.sunrisedental.model.Patient;
import com.sunrisedental.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class PatientDAO {

    public List<Patient> getAllPatients() {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT id, name, address, contact_number, email, last_visit, created_at FROM patients ORDER BY last_visit DESC, id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new Patient(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("address"),
                    rs.getString("contact_number"),
                    rs.getString("email"),
                    rs.getDate("last_visit"),
                    rs.getTimestamp("created_at")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public List<Patient> getRecentPatients(int limit) {
        List<Patient> list = new ArrayList<>();
        String sql = "SELECT id, name, address, contact_number, email, last_visit, created_at FROM patients ORDER BY last_visit DESC, id DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new Patient(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("address"),
                    rs.getString("contact_number"),
                    rs.getString("email"),
                    rs.getDate("last_visit"),
                    rs.getTimestamp("created_at")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public Patient getPatientById(int id) {
        String sql = "SELECT id, name, address, contact_number, email, last_visit, created_at FROM patients WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Patient(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("address"),
                    rs.getString("contact_number"),
                    rs.getString("email"),
                    rs.getDate("last_visit"),
                    rs.getTimestamp("created_at")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public Patient getPatientByNameAndContact(String name, String contact) {
        String sql = "SELECT id, name, address, contact_number, email, last_visit, created_at FROM patients WHERE LOWER(name) = LOWER(?) AND contact_number = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name.trim());
            ps.setString(2, contact.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Patient(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getString("address"),
                    rs.getString("contact_number"),
                    rs.getString("email"),
                    rs.getDate("last_visit"),
                    rs.getTimestamp("created_at")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public int findOrCreatePatient(String name, String address, String contact, String email, Date visitDate) {
        Patient existing = getPatientByNameAndContact(name, contact);
        if (existing != null) {
            updatePatientDetails(existing.getId(), address, contact, email, visitDate);
            return existing.getId();
        }

        String sql = "INSERT INTO patients (name, address, contact_number, email, last_visit) VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, name.trim());
            ps.setString(2, address != null ? address.trim() : "");
            ps.setString(3, contact.trim());
            ps.setString(4, email != null ? email.trim() : "");
            ps.setDate(5, visitDate != null ? visitDate : new Date(System.currentTimeMillis()));
            ps.executeUpdate();

            rs = ps.getGeneratedKeys();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return -1;
    }

    public int findOrCreatePatient(String name, String address, String contact, Date visitDate) {
        return findOrCreatePatient(name, address, contact, "", visitDate);
    }

    public void updatePatientDetails(int patientId, String address, String contact, String email, Date visitDate) {
        String sql = "UPDATE patients SET address = ?, contact_number = ?, email = ?, last_visit = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, address);
            ps.setString(2, contact);
            ps.setString(3, email != null ? email.trim() : "");
            ps.setDate(4, visitDate != null ? visitDate : new Date(System.currentTimeMillis()));
            ps.setInt(5, patientId);
            ps.executeUpdate();
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public void updatePatientDetails(int patientId, String address, String contact, Date visitDate) {
        updatePatientDetails(patientId, address, contact, "", visitDate);
    }

    public int countTotalPatients() {
        String sql = "SELECT COUNT(*) FROM patients";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return 0;
    }
}
