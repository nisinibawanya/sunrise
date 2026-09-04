package com.sunrisedental.model;

import java.io.Serializable;
import java.math.BigDecimal;
import java.sql.Date;
import java.sql.Timestamp;
import java.util.ArrayList;
import java.util.List;

public class Bill implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String billNo;
    private int appointmentId;
    private BigDecimal consultationFee;
    private BigDecimal treatmentFee;
    private BigDecimal materialFee;
    private BigDecimal subTotal;
    private BigDecimal discount;
    private BigDecimal totalAmount;
    private String paymentStatus;
    private String userInvoiceNo;
    private String billedBy;
    private Timestamp paidAt;
    private Timestamp createdAt;

    // Joined fields for display/receipt
    private String appointmentNo;
    private String patientName;
    private String patientAddress;
    private String patientContact;
    private String dentistName;
    private String treatmentName;
    private Date appointmentDate;
    private String appointmentTime;

    private String paymentMethod;
    private BigDecimal amountPaid;
    private BigDecimal balanceDue;
    private List<BillItem> items = new ArrayList<>();

    public Bill() {}

    public Bill(int id, String billNo, int appointmentId, BigDecimal consultationFee, BigDecimal treatmentFee,
                BigDecimal materialFee, BigDecimal subTotal, BigDecimal discount, BigDecimal totalAmount,
                String paymentStatus, String userInvoiceNo, String billedBy, Timestamp paidAt) {
        this.id = id;
        this.billNo = billNo;
        this.appointmentId = appointmentId;
        this.consultationFee = consultationFee;
        this.treatmentFee = treatmentFee;
        this.materialFee = materialFee;
        this.subTotal = subTotal;
        this.discount = discount;
        this.totalAmount = totalAmount;
        this.paymentStatus = paymentStatus;
        this.userInvoiceNo = userInvoiceNo;
        this.billedBy = billedBy;
        this.paidAt = paidAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getBillNo() {
        return billNo;
    }

    public void setBillNo(String billNo) {
        this.billNo = billNo;
    }

    public int getAppointmentId() {
        return appointmentId;
    }

    public void setAppointmentId(int appointmentId) {
        this.appointmentId = appointmentId;
    }

    public BigDecimal getConsultationFee() {
        return consultationFee;
    }

    public void setConsultationFee(BigDecimal consultationFee) {
        this.consultationFee = consultationFee;
    }

    public BigDecimal getTreatmentFee() {
        return treatmentFee;
    }

    public void setTreatmentFee(BigDecimal treatmentFee) {
        this.treatmentFee = treatmentFee;
    }

    public BigDecimal getMaterialFee() {
        return materialFee;
    }

    public void setMaterialFee(BigDecimal materialFee) {
        this.materialFee = materialFee;
    }

    public BigDecimal getSubTotal() {
        return subTotal;
    }

    public void setSubTotal(BigDecimal subTotal) {
        this.subTotal = subTotal;
    }

    public BigDecimal getDiscount() {
        return discount;
    }

    public void setDiscount(BigDecimal discount) {
        this.discount = discount;
    }

    public BigDecimal getTotalAmount() {
        return totalAmount;
    }

    public void setTotalAmount(BigDecimal totalAmount) {
        this.totalAmount = totalAmount;
    }

    public String getPaymentStatus() {
        return paymentStatus;
    }

    public void setPaymentStatus(String paymentStatus) {
        this.paymentStatus = paymentStatus;
    }

    public String getUserInvoiceNo() {
        return userInvoiceNo;
    }

    public void setUserInvoiceNo(String userInvoiceNo) {
        this.userInvoiceNo = userInvoiceNo;
    }

    public String getBilledBy() {
        return billedBy;
    }

    public void setBilledBy(String billedBy) {
        this.billedBy = billedBy;
    }

    public Timestamp getPaidAt() {
        return paidAt;
    }

    public void setPaidAt(Timestamp paidAt) {
        this.paidAt = paidAt;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public String getAppointmentNo() {
        return appointmentNo;
    }

    public void setAppointmentNo(String appointmentNo) {
        this.appointmentNo = appointmentNo;
    }

    public String getPatientName() {
        return patientName;
    }

    public void setPatientName(String patientName) {
        this.patientName = patientName;
    }

    public String getPatientAddress() {
        return patientAddress;
    }

    public void setPatientAddress(String patientAddress) {
        this.patientAddress = patientAddress;
    }

    public String getPatientContact() {
        return patientContact;
    }

    public void setPatientContact(String patientContact) {
        this.patientContact = patientContact;
    }

    public String getDentistName() {
        return dentistName;
    }

    public void setDentistName(String dentistName) {
        this.dentistName = dentistName;
    }

    public String getTreatmentName() {
        return treatmentName;
    }

    public void setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
    }

    public Date getAppointmentDate() {
        return appointmentDate;
    }

    public void setAppointmentDate(Date appointmentDate) {
        this.appointmentDate = appointmentDate;
    }

    public String getAppointmentTime() {
        return appointmentTime;
    }

    public void setAppointmentTime(String appointmentTime) {
        this.appointmentTime = appointmentTime;
    }

    public String getPaymentMethod() {
        return paymentMethod;
    }

    public void setPaymentMethod(String paymentMethod) {
        this.paymentMethod = paymentMethod;
    }

    public BigDecimal getAmountPaid() {
        if (amountPaid != null) {
            return amountPaid;
        }
        BigDecimal tot = totalAmount != null ? totalAmount : BigDecimal.ZERO;
        if ("Paid".equalsIgnoreCase(paymentStatus)) {
            return tot;
        } else if ("Pending".equalsIgnoreCase(paymentStatus)) {
            return BigDecimal.ZERO;
        } else if ("Partially Paid".equalsIgnoreCase(paymentStatus)) {
            return tot.divide(BigDecimal.valueOf(2), 2, java.math.RoundingMode.HALF_UP);
        }
        return tot;
    }

    public void setAmountPaid(BigDecimal amountPaid) {
        this.amountPaid = amountPaid;
    }

    public BigDecimal getBalanceDue() {
        if (balanceDue != null) {
            return balanceDue;
        }
        BigDecimal tot = totalAmount != null ? totalAmount : BigDecimal.ZERO;
        BigDecimal paid = getAmountPaid();
        BigDecimal due = tot.subtract(paid);
        return due.compareTo(BigDecimal.ZERO) < 0 ? BigDecimal.ZERO : due;
    }

    public void setBalanceDue(BigDecimal balanceDue) {
        this.balanceDue = balanceDue;
    }

    public List<BillItem> getItems() {
        if (items == null) {
            items = new ArrayList<>();
        }
        return items;
    }

    public void setItems(List<BillItem> items) {
        this.items = items != null ? items : new ArrayList<>();
    }

    public void addItem(BillItem item) {
        if (this.items == null) {
            this.items = new ArrayList<>();
        }
        if (item != null) {
            this.items.add(item);
        }
    }

    /**
     * Helper to get a concise formatted string of all services/treatments on this invoice.
     */
    public String getServicesSummary() {
        if (items != null && !items.isEmpty()) {
            StringBuilder sb = new StringBuilder();
            for (int i = 0; i < items.size(); i++) {
                if (i > 0) sb.append(", ");
                sb.append(items.get(i).getTreatmentName());
                if (items.get(i).getQuantity() > 1) {
                    sb.append(" (x").append(items.get(i).getQuantity()).append(")");
                }
            }
            return sb.toString();
        }
        return treatmentName != null ? treatmentName : "General Dental Service";
    }
}
