package com.sunrisedental.dao;

import com.sunrisedental.model.Appointment;
import com.sunrisedental.util.DBConnection;

import java.sql.Connection;
import java.sql.Date;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;
import java.util.ArrayList;
import java.util.List;

public class AppointmentDAO {

    private final String BASE_SELECT = 
        "SELECT a.id, a.appointment_no, a.patient_id, a.dentist_id, a.treatment_id, " +
        "a.appointment_date, a.appointment_time, a.status, a.notes, a.created_at, " +
        "p.name AS patient_name, p.address AS patient_address, p.contact_number AS patient_contact, p.email AS patient_email, " +
        "d.name AS dentist_name, d.specialization AS dentist_specialization, " +
        "t.name AS treatment_name, t.cost AS treatment_cost " +
        "FROM appointments a " +
        "JOIN patients p ON a.patient_id = p.id " +
        "JOIN dentists d ON a.dentist_id = d.id " +
        "JOIN treatments t ON a.treatment_id = t.id ";

    private Appointment mapResultSet(ResultSet rs) throws SQLException {
        Appointment a = new Appointment();
        a.setId(rs.getInt("id"));
        a.setAppointmentNo(rs.getString("appointment_no"));
        a.setPatientId(rs.getInt("patient_id"));
        a.setDentistId(rs.getInt("dentist_id"));
        a.setTreatmentId(rs.getInt("treatment_id"));
        a.setAppointmentDate(rs.getDate("appointment_date"));
        a.setAppointmentTime(rs.getString("appointment_time"));
        a.setStatus(rs.getString("status"));
        a.setNotes(rs.getString("notes"));
        a.setCreatedAt(rs.getTimestamp("created_at"));

        a.setPatientName(rs.getString("patient_name"));
        a.setPatientAddress(rs.getString("patient_address"));
        a.setPatientContact(rs.getString("patient_contact"));
        a.setPatientEmail(rs.getString("patient_email"));
        a.setDentistName(rs.getString("dentist_name"));
        a.setDentistSpecialization(rs.getString("dentist_specialization"));
        a.setTreatmentName(rs.getString("treatment_name"));
        a.setTreatmentCost(rs.getBigDecimal("treatment_cost"));
        return a;
    }

    public synchronized String getNextAppointmentNo() {
        String sql = "SELECT appointment_no FROM appointments ORDER BY id DESC LIMIT 1";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            if (rs.next()) {
                String lastNo = rs.getString("appointment_no");
                if (lastNo != null && lastNo.startsWith("A")) {
                    try {
                        int num = Integer.parseInt(lastNo.substring(1));
                        return String.format("A%04d", num + 1);
                    } catch (NumberFormatException ignored) {}
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return "A1001";
    }

    public boolean createAppointment(Appointment appt) {
        String sql = "INSERT INTO appointments (appointment_no, patient_id, dentist_id, treatment_id, appointment_date, appointment_time, status, notes) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, appt.getAppointmentNo());
            ps.setInt(2, appt.getPatientId());
            ps.setInt(3, appt.getDentistId());
            ps.setInt(4, appt.getTreatmentId());
            ps.setDate(5, appt.getAppointmentDate());
            ps.setString(6, appt.getAppointmentTime());
            ps.setString(7, appt.getStatus() != null ? appt.getStatus() : "Confirmed");
            ps.setString(8, appt.getNotes());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean updateAppointment(Appointment appt) {
        String sql = "UPDATE appointments SET patient_id = ?, dentist_id = ?, treatment_id = ?, appointment_date = ?, appointment_time = ?, status = ?, notes = ? " +
                     "WHERE id = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appt.getPatientId());
            ps.setInt(2, appt.getDentistId());
            ps.setInt(3, appt.getTreatmentId());
            ps.setDate(4, appt.getAppointmentDate());
            ps.setString(5, appt.getAppointmentTime());
            ps.setString(6, appt.getStatus());
            ps.setString(7, appt.getNotes());
            ps.setInt(8, appt.getId());

            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public boolean deleteAppointment(int id) {
        String sql = "DELETE FROM appointments WHERE id = ?";
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

    public boolean deleteAppointmentByNo(String appointmentNo) {
        String sql = "DELETE FROM appointments WHERE appointment_no = ?";
        Connection conn = null;
        PreparedStatement ps = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, appointmentNo);
            return ps.executeUpdate() > 0;
        } catch (SQLException e) {
            e.printStackTrace();
            return false;
        } finally {
            DBConnection.close(ps, conn);
        }
    }

    public Appointment getAppointmentById(int id) {
        String sql = BASE_SELECT + "WHERE a.id = ?";
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

    public Appointment getAppointmentByNo(String apptNo) {
        if (apptNo == null) return null;
        String sql = BASE_SELECT + "WHERE LOWER(TRIM(a.appointment_no)) = LOWER(TRIM(?))";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, apptNo.trim());
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

    public List<Appointment> getTodayAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE a.appointment_date = CURDATE() ORDER BY a.appointment_time ASC, a.id ASC";
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

    public List<Appointment> getAllAppointments() {
        List<Appointment> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY a.appointment_date DESC, a.id DESC";
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

    public List<Appointment> getAppointmentsByDate(Date date) {
        List<Appointment> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE a.appointment_date = ? ORDER BY a.appointment_time ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setDate(1, date);
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

    public List<Appointment> searchAppointments(String query) {
        List<Appointment> list = new ArrayList<>();
        if (query == null || query.trim().isEmpty()) {
            return getAllAppointments();
        }
        String pattern = "%" + query.trim().toLowerCase() + "%";
        String sql = BASE_SELECT + 
            "WHERE LOWER(a.appointment_no) LIKE ? OR LOWER(p.name) LIKE ? OR LOWER(p.contact_number) LIKE ? OR LOWER(d.name) LIKE ? " +
            "ORDER BY a.appointment_date DESC, a.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, pattern);
            ps.setString(2, pattern);
            ps.setString(3, pattern);
            ps.setString(4, pattern);
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

    public int countTodayAppointments() {
        String sql = "SELECT COUNT(*) FROM appointments WHERE appointment_date = CURDATE()";
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

    public int countTotalAppointments() {
        String sql = "SELECT COUNT(*) FROM appointments";
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

    public int countUpcomingAppointments() {
        String sql = "SELECT COUNT(*) FROM appointments WHERE appointment_date > CURDATE()";
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
