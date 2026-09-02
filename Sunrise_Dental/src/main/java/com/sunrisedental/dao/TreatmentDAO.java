package com.sunrisedental.dao;

import com.sunrisedental.model.Treatment;
import com.sunrisedental.util.DBConnection;

import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class TreatmentDAO {

    public List<Treatment> getAllTreatments() {
        List<Treatment> list = new ArrayList<>();
        String sql = "SELECT id, name, cost, description FROM treatments ORDER BY name ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                list.add(new Treatment(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getBigDecimal("cost"),
                    rs.getString("description")
                ));
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public Treatment getTreatmentById(int id) {
        String sql = "SELECT id, name, cost, description FROM treatments WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, id);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Treatment(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getBigDecimal("cost"),
                    rs.getString("description")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public Treatment getTreatmentByName(String name) {
        String sql = "SELECT id, name, cost, description FROM treatments WHERE name = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, name);
            rs = ps.executeQuery();

            if (rs.next()) {
                return new Treatment(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getBigDecimal("cost"),
                    rs.getString("description")
                );
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public boolean createTreatment(Treatment treatment) {
        String sql = "INSERT INTO treatments (name, cost, description) VALUES (?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS);
            ps.setString(1, treatment.getName().trim());
            ps.setBigDecimal(2, treatment.getCost());
            ps.setString(3, treatment.getDescription() != null ? treatment.getDescription().trim() : "");
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean updateTreatment(Treatment treatment) {
        String sql = "UPDATE treatments SET name = ?, cost = ?, description = ? WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, treatment.getName().trim());
            ps.setBigDecimal(2, treatment.getCost());
            ps.setString(3, treatment.getDescription() != null ? treatment.getDescription().trim() : "");
            ps.setInt(4, treatment.getId());
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean deleteTreatment(int id) {
        // Check for existing appointments using this treatment
        String sqlCheck = "SELECT COUNT(*) FROM appointments WHERE treatment_id = ?";
        String sqlDelete = "DELETE FROM treatments WHERE id = ?";
        Connection conn = null;
        PreparedStatement psCheck = null;
        PreparedStatement psDelete = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            psCheck = conn.prepareStatement(sqlCheck);
            psCheck.setInt(1, id);
            rs = psCheck.executeQuery();

            if (rs.next() && rs.getInt(1) > 0) {
                // Has appointments - cannot delete
                return false;
            }

            psDelete = conn.prepareStatement(sqlDelete);
            psDelete.setInt(1, id);
            return psDelete.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(rs, psCheck, psDelete, conn);
        }
    }

    public int countTotalTreatments() {
        String sql = "SELECT COUNT(*) FROM treatments";
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

    public List<Treatment> getTreatmentUsageReport(Date fromDate, Date toDate) {
        List<Treatment> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(
            "SELECT t.id, t.name, t.cost, t.description, COUNT(a.id) AS usage_count " +
            "FROM treatments t " +
            "LEFT JOIN appointments a ON t.id = a.treatment_id "
        );
        List<Date> params = new ArrayList<>();
        if (fromDate != null && toDate != null) {
            sql.append("AND a.appointment_date BETWEEN ? AND ? ");
            params.add(fromDate);
            params.add(toDate);
        } else if (fromDate != null) {
            sql.append("AND a.appointment_date >= ? ");
            params.add(fromDate);
        } else if (toDate != null) {
            sql.append("AND a.appointment_date <= ? ");
            params.add(toDate);
        }
        sql.append("GROUP BY t.id, t.name, t.cost, t.description ");
        sql.append("ORDER BY usage_count DESC, t.name ASC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                ps.setDate(i + 1, params.get(i));
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                Treatment t = new Treatment(
                    rs.getInt("id"),
                    rs.getString("name"),
                    rs.getBigDecimal("cost"),
                    rs.getString("description"),
                    rs.getInt("usage_count")
                );
                list.add(t);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }
}
