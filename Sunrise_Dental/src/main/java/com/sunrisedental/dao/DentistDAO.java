package com.sunrisedental.dao;

import com.sunrisedental.model.Dentist;
import com.sunrisedental.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

public class DentistDAO {

    public List<Dentist> getAllDentists() {
        List<Dentist> list = new ArrayList<>();
        String sql = "SELECT * FROM dentists ORDER BY name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Dentist dentist = mapDentist(rs);
                list.add(dentist);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public Dentist getDentistById(int id) {
        String sql = "SELECT * FROM dentists WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapDentist(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public Dentist getDentistByName(String name) {
        String sql = "SELECT * FROM dentists WHERE name = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            rs = ps.executeQuery();

            if (rs.next()) {
                return mapDentist(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    private Dentist mapDentist(ResultSet rs) throws SQLException {
        Dentist dentist = new Dentist(
            rs.getInt("id"),
            rs.getString("name"),
            rs.getString("specialization"),
            rs.getString("contact_number"),
            rs.getString("email"),
            rs.getString("room_no"),
            rs.getBoolean("is_active")
        );
        try {
            dentist.setUpdatedAt(rs.getTimestamp("updated_at"));
        } catch (SQLException ignored) {}
        return dentist;
    }

    public boolean createDentist(Dentist dentist) {
        String sql = "INSERT INTO dentists (name, specialization, contact_number, email, room_no, is_active) VALUES (?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dentist.getName() != null ? dentist.getName().trim() : "");
            ps.setString(2, dentist.getSpecialization() != null ? dentist.getSpecialization().trim() : "");
            ps.setString(3, dentist.getContactNumber() != null ? dentist.getContactNumber().trim() : "");
            ps.setString(4, dentist.getEmail() != null ? dentist.getEmail().trim() : "");
            ps.setString(5, dentist.getRoomNo() != null && !dentist.getRoomNo().trim().isEmpty() ? dentist.getRoomNo().trim() : "Room 1");
            ps.setBoolean(6, true);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean updateDentist(Dentist dentist) {
        String sql = "UPDATE dentists SET name = ?, specialization = ?, contact_number = ?, email = ?, room_no = ?, is_active = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, dentist.getName() != null ? dentist.getName().trim() : "");
            ps.setString(2, dentist.getSpecialization() != null ? dentist.getSpecialization().trim() : "");
            ps.setString(3, dentist.getContactNumber() != null ? dentist.getContactNumber().trim() : "");
            ps.setString(4, dentist.getEmail() != null ? dentist.getEmail().trim() : "");
            ps.setString(5, dentist.getRoomNo() != null && !dentist.getRoomNo().trim().isEmpty() ? dentist.getRoomNo().trim() : "Room 1");
            ps.setBoolean(6, dentist.isActive());
            ps.setInt(7, dentist.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean deleteDentist(int id) {
        String sqlCheck = "SELECT COUNT(*) FROM appointments WHERE dentist_id = ?";
        String sqlSoftDelete = "UPDATE dentists SET is_active = FALSE WHERE id = ?";
        String sqlHardDelete = "DELETE FROM dentists WHERE id = ?";
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psDelete = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setInt(1, id);
            rs = psCheck.executeQuery();

            boolean hasAppointments = rs.next() && rs.getInt(1) > 0;
            if (hasAppointments) {
                psDelete = conn.prepareStatement(sqlSoftDelete);
            } else {
                psDelete = conn.prepareStatement(sqlHardDelete);
            }
            psDelete.setInt(1, id);
            return psDelete.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(rs, psCheck, psDelete, conn);
        }
    }

    public int countActiveDentists() {
        String sql = "SELECT COUNT(*) FROM dentists WHERE is_active = TRUE";
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
