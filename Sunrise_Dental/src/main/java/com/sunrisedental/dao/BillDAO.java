package com.sunrisedental.dao;

import com.sunrisedental.model.Bill;
import com.sunrisedental.model.BillItem;
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

public class BillDAO {

    private final String BASE_SELECT =
        "SELECT b.id, b.bill_no, b.appointment_id, b.consultation_fee, b.treatment_fee, " +
        "b.material_fee, b.sub_total, b.discount, b.total_amount, b.payment_method, b.payment_status, " +
        "b.amount_paid, b.balance_due, b.user_invoice_no, b.billed_by, b.paid_at, b.created_at, " +
        "a.appointment_no, a.appointment_date, a.appointment_time, " +
        "p.name AS patient_name, p.address AS patient_address, p.contact_number AS patient_contact, " +
        "d.name AS dentist_name, t.name AS treatment_name " +
        "FROM bills b " +
        "JOIN appointments a ON b.appointment_id = a.id " +
        "JOIN patients p ON a.patient_id = p.id " +
        "JOIN dentists d ON a.dentist_id = d.id " +
        "JOIN treatments t ON a.treatment_id = t.id ";

    private Bill mapResultSet(ResultSet rs) throws SQLException {
        Bill b = new Bill();
        b.setId(rs.getInt("id"));
        b.setBillNo(rs.getString("bill_no"));
        b.setAppointmentId(rs.getInt("appointment_id"));
        b.setConsultationFee(rs.getBigDecimal("consultation_fee"));
        b.setTreatmentFee(rs.getBigDecimal("treatment_fee"));
        b.setMaterialFee(rs.getBigDecimal("material_fee"));
        b.setSubTotal(rs.getBigDecimal("sub_total"));
        b.setDiscount(rs.getBigDecimal("discount"));
        b.setTotalAmount(rs.getBigDecimal("total_amount"));
        try {
            b.setPaymentMethod(rs.getString("payment_method"));
        } catch (SQLException ignored) {
            b.setPaymentMethod("Cash");
        }
        b.setPaymentStatus(rs.getString("payment_status"));
        try {
            b.setAmountPaid(rs.getBigDecimal("amount_paid"));
        } catch (SQLException ignored) {}
        try {
            b.setBalanceDue(rs.getBigDecimal("balance_due"));
        } catch (SQLException ignored) {}
        b.setUserInvoiceNo(rs.getString("user_invoice_no"));
        b.setBilledBy(rs.getString("billed_by"));
        b.setPaidAt(rs.getTimestamp("paid_at"));
        try {
            b.setCreatedAt(rs.getTimestamp("created_at"));
        } catch (SQLException ignored) {}

        b.setAppointmentNo(rs.getString("appointment_no"));
        b.setAppointmentDate(rs.getDate("appointment_date"));
        b.setAppointmentTime(rs.getString("appointment_time"));
        b.setPatientName(rs.getString("patient_name"));
        b.setPatientAddress(rs.getString("patient_address"));
        b.setPatientContact(rs.getString("patient_contact"));
        b.setDentistName(rs.getString("dentist_name"));
        b.setTreatmentName(rs.getString("treatment_name"));
        return b;
    }

    public synchronized String getNextBillNo() {
        String sql = "SELECT bill_no FROM bills";
        Connection conn = null;
        Statement stmt = null;
        ResultSet rs = null;
        int maxNum = 0;

        try {
            conn = DBConnection.getConnection();
            stmt = conn.createStatement();
            rs = stmt.executeQuery(sql);
            while (rs.next()) {
                String bNo = rs.getString("bill_no");
                if (bNo != null) {
                    String digits = bNo.replaceAll("\\D+", "");
                    if (!digits.isEmpty()) {
                        try {
                            int n = Integer.parseInt(digits);
                            if (n > maxNum) maxNum = n;
                        } catch (NumberFormatException ignored) {}
                    }
                }
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, stmt, conn);
        }
        return String.format("INV-%06d", maxNum + 1);
    }

    public List<BillItem> getBillItems(int billId) {
        List<BillItem> list = new ArrayList<>();
        String sql = "SELECT id, bill_id, treatment_id, treatment_name, quantity, unit_price, line_total " +
                     "FROM bill_items WHERE bill_id = ? ORDER BY id ASC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, billId);
            rs = ps.executeQuery();
            while (rs.next()) {
                BillItem item = new BillItem();
                item.setId(rs.getInt("id"));
                item.setBillId(rs.getInt("bill_id"));
                int tId = rs.getInt("treatment_id");
                if (!rs.wasNull()) {
                    item.setTreatmentId(tId);
                }
                item.setTreatmentName(rs.getString("treatment_name"));
                item.setQuantity(rs.getInt("quantity"));
                item.setUnitPrice(rs.getBigDecimal("unit_price"));
                item.setLineTotal(rs.getBigDecimal("line_total"));
                list.add(item);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public boolean saveInvoiceWithTransaction(Bill bill, List<BillItem> items) {
        Connection conn = null;
        PreparedStatement psBill = null;
        PreparedStatement psDeleteItems = null;
        PreparedStatement psItem = null;
        ResultSet rsKeys = null;

        try {
            conn = DBConnection.getConnection();
            conn.setAutoCommit(false); // Start transaction

            Bill existing = getBillByAppointmentId(bill.getAppointmentId());
            int billId;

            if (existing != null) {
                billId = existing.getId();
                String updateSql = "UPDATE bills SET bill_no = ?, sub_total = ?, discount = ?, total_amount = ?, " +
                                   "payment_method = ?, payment_status = ?, user_invoice_no = ?, billed_by = ?, paid_at = CURRENT_TIMESTAMP " +
                                   "WHERE id = ?";
                psBill = conn.prepareStatement(updateSql);
                psBill.setString(1, bill.getBillNo());
                psBill.setBigDecimal(2, bill.getSubTotal());
                psBill.setBigDecimal(3, bill.getDiscount());
                psBill.setBigDecimal(4, bill.getTotalAmount());
                psBill.setString(5, bill.getPaymentMethod() != null ? bill.getPaymentMethod() : "Cash");
                psBill.setString(6, bill.getPaymentStatus() != null ? bill.getPaymentStatus() : "Paid");
                psBill.setString(7, bill.getUserInvoiceNo());
                psBill.setString(8, bill.getBilledBy());
                psBill.setInt(9, billId);
                psBill.executeUpdate();

                // Delete existing items for update
                psDeleteItems = conn.prepareStatement("DELETE FROM bill_items WHERE bill_id = ?");
                psDeleteItems.setInt(1, billId);
                psDeleteItems.executeUpdate();
            } else {
                String insertSql = "INSERT INTO bills (bill_no, appointment_id, consultation_fee, treatment_fee, material_fee, " +
                                   "sub_total, discount, total_amount, payment_method, payment_status, user_invoice_no, billed_by, paid_at) " +
                                   "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, CURRENT_TIMESTAMP)";
                psBill = conn.prepareStatement(insertSql, Statement.RETURN_GENERATED_KEYS);
                psBill.setString(1, bill.getBillNo());
                psBill.setInt(2, bill.getAppointmentId());
                psBill.setBigDecimal(3, bill.getConsultationFee() != null ? bill.getConsultationFee() : BigDecimal.ZERO);
                psBill.setBigDecimal(4, bill.getTreatmentFee() != null ? bill.getTreatmentFee() : BigDecimal.ZERO);
                psBill.setBigDecimal(5, bill.getMaterialFee() != null ? bill.getMaterialFee() : BigDecimal.ZERO);
                psBill.setBigDecimal(6, bill.getSubTotal());
                psBill.setBigDecimal(7, bill.getDiscount());
                psBill.setBigDecimal(8, bill.getTotalAmount());
                psBill.setString(9, bill.getPaymentMethod() != null ? bill.getPaymentMethod() : "Cash");
                psBill.setString(10, bill.getPaymentStatus() != null ? bill.getPaymentStatus() : "Paid");
                psBill.setString(11, bill.getUserInvoiceNo());
                psBill.setString(12, bill.getBilledBy());
                psBill.executeUpdate();

                rsKeys = psBill.getGeneratedKeys();
                if (rsKeys.next()) {
                    billId = rsKeys.getInt(1);
                } else {
                    throw new SQLException("Failed to retrieve generated invoice ID.");
                }
            }

            bill.setId(billId);

            // Save all line items
            if (items != null && !items.isEmpty()) {
                String itemSql = "INSERT INTO bill_items (bill_id, treatment_id, treatment_name, quantity, unit_price, line_total) " +
                                 "VALUES (?, ?, ?, ?, ?, ?)";
                psItem = conn.prepareStatement(itemSql);

                for (BillItem item : items) {
                    psItem.setInt(1, billId);
                    if (item.getTreatmentId() != null && item.getTreatmentId() > 0) {
                        psItem.setInt(2, item.getTreatmentId());
                    } else {
                        psItem.setNull(2, java.sql.Types.INTEGER);
                    }
                    psItem.setString(3, item.getTreatmentName());
                    psItem.setInt(4, item.getQuantity() > 0 ? item.getQuantity() : 1);
                    psItem.setBigDecimal(5, item.getUnitPrice());
                    psItem.setBigDecimal(6, item.getLineTotal());
                    psItem.addBatch();
                }
                psItem.executeBatch();
            }

            conn.commit(); // Commit transaction successfully
            return true;
        } catch (SQLException e) {
            System.err.println("Transaction failed in saveInvoiceWithTransaction: " + e.getMessage());
            e.printStackTrace();
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            return false;
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                } catch (SQLException ignored) {}
            }
            DBConnection.close(rsKeys, psBill, psDeleteItems, psItem, conn);
        }
    }

    public boolean createOrUpdateBill(Bill bill) {
        return saveInvoiceWithTransaction(bill, bill.getItems());
    }

    public Bill getBillByAppointmentId(int appointmentId) {
        String sql = BASE_SELECT + "WHERE b.appointment_id = ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, appointmentId);
            rs = ps.executeQuery();

            if (rs.next()) {
                Bill b = mapResultSet(rs);
                List<BillItem> items = getBillItems(b.getId());
                if (items.isEmpty()) {
                    // Build fallback items from legacy bill fields if not in bill_items
                    if (b.getConsultationFee() != null && b.getConsultationFee().compareTo(BigDecimal.ZERO) > 0) {
                        items.add(new BillItem(0, b.getId(), null, "Consultation Fee", 1, b.getConsultationFee(), b.getConsultationFee()));
                    }
                    if (b.getTreatmentFee() != null && b.getTreatmentFee().compareTo(BigDecimal.ZERO) > 0) {
                        String tName = b.getTreatmentName() != null ? b.getTreatmentName() : "Treatment Fee";
                        items.add(new BillItem(0, b.getId(), null, tName, 1, b.getTreatmentFee(), b.getTreatmentFee()));
                    }
                    if (b.getMaterialFee() != null && b.getMaterialFee().compareTo(BigDecimal.ZERO) > 0) {
                        items.add(new BillItem(0, b.getId(), null, "Materials / Other", 1, b.getMaterialFee(), b.getMaterialFee()));
                    }
                }
                b.setItems(items);
                return b;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public Bill getBillByBillNo(String billNo) {
        String sql = BASE_SELECT + "WHERE LOWER(TRIM(b.bill_no)) = LOWER(TRIM(?))";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setString(1, billNo.trim());
            rs = ps.executeQuery();

            if (rs.next()) {
                Bill b = mapResultSet(rs);
                List<BillItem> items = getBillItems(b.getId());
                if (items.isEmpty()) {
                    if (b.getConsultationFee() != null && b.getConsultationFee().compareTo(BigDecimal.ZERO) > 0) {
                        items.add(new BillItem(0, b.getId(), null, "Consultation Fee", 1, b.getConsultationFee(), b.getConsultationFee()));
                    }
                    if (b.getTreatmentFee() != null && b.getTreatmentFee().compareTo(BigDecimal.ZERO) > 0) {
                        String tName = b.getTreatmentName() != null ? b.getTreatmentName() : "Treatment Fee";
                        items.add(new BillItem(0, b.getId(), null, tName, 1, b.getTreatmentFee(), b.getTreatmentFee()));
                    }
                    if (b.getMaterialFee() != null && b.getMaterialFee().compareTo(BigDecimal.ZERO) > 0) {
                        items.add(new BillItem(0, b.getId(), null, "Materials / Other", 1, b.getMaterialFee(), b.getMaterialFee()));
                    }
                }
                b.setItems(items);
                return b;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return null;
    }

    public List<Bill> getAllBills() {
        List<Bill> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY b.paid_at DESC, b.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Bill b = mapResultSet(rs);
                b.setItems(getBillItems(b.getId()));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public List<Bill> getRecentBills(int limit) {
        List<Bill> list = new ArrayList<>();
        String sql = BASE_SELECT + "ORDER BY b.paid_at DESC, b.created_at DESC, b.id DESC LIMIT ?";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            ps.setInt(1, limit > 0 ? limit : 5);
            rs = ps.executeQuery();

            while (rs.next()) {
                Bill b = mapResultSet(rs);
                b.setItems(getBillItems(b.getId()));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public BigDecimal getTotalRevenue() {
        String sql = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'Paid'";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal sum = rs.getBigDecimal(1);
                return sum != null ? sum : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return BigDecimal.ZERO;
    }

    public BigDecimal getTodayRevenue() {
        String sql = "SELECT SUM(total_amount) FROM bills WHERE payment_status = 'Paid' AND (DATE(paid_at) = CURDATE() OR (paid_at IS NULL AND DATE(created_at) = CURDATE()))";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();
            if (rs.next()) {
                BigDecimal sum = rs.getBigDecimal(1);
                return sum != null ? sum : BigDecimal.ZERO;
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return BigDecimal.ZERO;
    }

    public int countPendingBills() {
        String sql = "SELECT COUNT(*) FROM bills WHERE LOWER(TRIM(payment_status)) != 'paid'";
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

    public List<Bill> getPendingBills() {
        List<Bill> list = new ArrayList<>();
        String sql = BASE_SELECT + "WHERE LOWER(TRIM(b.payment_status)) != 'paid' ORDER BY b.created_at DESC, b.id DESC";
        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql);
            rs = ps.executeQuery();

            while (rs.next()) {
                Bill b = mapResultSet(rs);
                b.setItems(getBillItems(b.getId()));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }

    public List<Bill> getFilteredBills(Date fromDate, Date toDate, String paymentStatus, String paymentMethod) {
        List<Bill> list = new ArrayList<>();
        StringBuilder sql = new StringBuilder(BASE_SELECT);
        List<Object> params = new ArrayList<>();
        List<String> conditions = new ArrayList<>();

        if (fromDate != null) {
            conditions.add("(DATE(b.paid_at) >= ? OR (b.paid_at IS NULL AND DATE(b.created_at) >= ?))");
            params.add(fromDate);
            params.add(fromDate);
        }
        if (toDate != null) {
            conditions.add("(DATE(b.paid_at) <= ? OR (b.paid_at IS NULL AND DATE(b.created_at) <= ?))");
            params.add(toDate);
            params.add(toDate);
        }
        if (paymentStatus != null && !paymentStatus.trim().isEmpty() && !"All".equalsIgnoreCase(paymentStatus.trim())) {
            conditions.add("LOWER(TRIM(b.payment_status)) = LOWER(TRIM(?))");
            params.add(paymentStatus.trim());
        }
        if (paymentMethod != null && !paymentMethod.trim().isEmpty() && !"All".equalsIgnoreCase(paymentMethod.trim())) {
            conditions.add("LOWER(TRIM(b.payment_method)) = LOWER(TRIM(?))");
            params.add(paymentMethod.trim());
        }

        if (!conditions.isEmpty()) {
            sql.append("WHERE ").append(String.join(" AND ", conditions)).append(" ");
        }
        sql.append("ORDER BY b.paid_at DESC, b.id DESC");

        Connection conn = null;
        PreparedStatement ps = null;
        ResultSet rs = null;

        try {
            conn = DBConnection.getConnection();
            ps = conn.prepareStatement(sql.toString());
            for (int i = 0; i < params.size(); i++) {
                Object p = params.get(i);
                if (p instanceof Date) {
                    ps.setDate(i + 1, (Date) p);
                } else if (p instanceof String) {
                    ps.setString(i + 1, (String) p);
                } else {
                    ps.setObject(i + 1, p);
                }
            }
            rs = ps.executeQuery();

            while (rs.next()) {
                Bill b = mapResultSet(rs);
                b.setItems(getBillItems(b.getId()));
                list.add(b);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        } finally {
            DBConnection.close(rs, ps, conn);
        }
        return list;
    }
}
