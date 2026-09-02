package com.sunrisedental.dao;

import com.sunrisedental.model.Receptionist;
import com.sunrisedental.util.DBConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class ReceptionistDAO {

    private Receptionist mapResultSet(ResultSet rs) throws SQLException {
        return new Receptionist(
            rs.getInt("id"),
            rs.getString("receptionist_code"),
            rs.getString("full_name"),
            rs.getString("contact_number"),
            rs.getString("email"),
            rs.getString("status"),
            rs.getTimestamp("created_at"),
            rs.getTimestamp("updated_at")
        );
    }

    public List<Receptionist> getAllReceptionists() {
        List<Receptionist> list = new ArrayList<>();
        String sql = "SELECT id, receptionist_code, full_name, contact_number, email, status, created_at, updated_at " +
                     "FROM receptionists ORDER BY id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public List<Receptionist> getActiveReceptionists() {
        List<Receptionist> list = new ArrayList<>();
        String sql = "SELECT id, receptionist_code, full_name, contact_number, email, status, created_at, updated_at " +
                     "FROM receptionists WHERE status = 'Active' ORDER BY id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapResultSet(rs));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public Receptionist getReceptionistById(int id) {
        String sql = "SELECT id, receptionist_code, full_name, contact_number, email, status, created_at, updated_at " +
                     "FROM receptionists WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public Receptionist getReceptionistByCode(String code) {
        String sql = "SELECT id, receptionist_code, full_name, contact_number, email, status, created_at, updated_at " +
                     "FROM receptionists WHERE receptionist_code = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, code);
            rs = ps.executeQuery();
            if (rs.next()) {
                return mapResultSet(rs);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public synchronized String getNextReceptionistCode() {
        String sql = "SELECT receptionist_code FROM receptionists";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        int maxNum = 0;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                String code = rs.getString("receptionist_code");
                if (code != null && code.toUpperCase().startsWith("REC-")) {
                    try {
                        int num = Integer.parseInt(code.substring(4).trim());
                        if (num > maxNum) {
                            maxNum = num;
                        }
                    } catch (NumberFormatException ignored) {}
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, stmt, conn);
        }

        return String.format("REC-%03d", maxNum + 1);
    }

    public boolean isDuplicate(String contactNumber, String email, Integer excludeId) {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM receptionists WHERE (contact_number = ? ");
        boolean hasEmail = email != null && !email.trim().isEmpty();
        if (hasEmail) {
            sql.append("OR email = ? ");
        }
        sql.append(")");
        if (excludeId != null) {
            sql.append(" AND id != ?");
        }

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            int idx = 1;
            ps.setString(idx++, contactNumber.trim());
            if (hasEmail) {
                ps.setString(idx++, email.trim());
            }
            if (excludeId != null) {
                ps.setInt(idx++, excludeId);
            }
            rs = ps.executeQuery();
            if (rs.next()) {
                return rs.getInt(1) > 0;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return false;
    }

    public boolean createReceptionist(Receptionist r) {
        String sql = "INSERT INTO receptionists (receptionist_code, full_name, contact_number, email, status) " +
                     "VALUES (?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, r.getReceptionistCode() != null ? r.getReceptionistCode().trim() : getNextReceptionistCode());
            ps.setString(2, r.getFullName().trim());
            ps.setString(3, r.getContactNumber().trim());
            ps.setString(4, r.getEmail() != null ? r.getEmail().trim() : "");
            ps.setString(5, r.getStatus() != null ? r.getStatus().trim() : "Active");

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean updateReceptionist(Receptionist r) {
        String sql = "UPDATE receptionists SET full_name = ?, contact_number = ?, email = ?, status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, r.getFullName().trim());
            ps.setString(2, r.getContactNumber().trim());
            ps.setString(3, r.getEmail() != null ? r.getEmail().trim() : "");
            ps.setString(4, r.getStatus() != null ? r.getStatus().trim() : "Active");
            ps.setInt(5, r.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean updateStatus(int id, String status) {
        String sql = "UPDATE receptionists SET status = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, status != null ? status.trim() : "Active");
            ps.setInt(2, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean deleteReceptionist(int id) {
        String sql = "DELETE FROM receptionists WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public int countActiveReceptionists() {
        String sql = "SELECT COUNT(*) FROM receptionists WHERE status = 'Active'";
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
