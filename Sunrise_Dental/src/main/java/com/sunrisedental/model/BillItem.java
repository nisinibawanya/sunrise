package com.sunrisedental.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class BillItem implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private int billId;
    private Integer treatmentId;
    private String treatmentName;
    private int quantity;
    private BigDecimal unitPrice;
    private BigDecimal lineTotal;

    public BillItem() {
        this.quantity = 1;
        this.unitPrice = BigDecimal.ZERO;
        this.lineTotal = BigDecimal.ZERO;
    }

    public BillItem(int id, int billId, Integer treatmentId, String treatmentName, int quantity, BigDecimal unitPrice, BigDecimal lineTotal) {
        this.id = id;
        this.billId = billId;
        this.treatmentId = treatmentId;
        this.treatmentName = treatmentName;
        this.quantity = quantity;
        this.unitPrice = unitPrice;
        this.lineTotal = lineTotal;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getBillId() {
        return billId;
    }

    public void setBillId(int billId) {
        this.billId = billId;
    }

    public Integer getTreatmentId() {
        return treatmentId;
    }

    public void setTreatmentId(Integer treatmentId) {
        this.treatmentId = treatmentId;
    }

    public String getTreatmentName() {
        return treatmentName;
    }

    public void setTreatmentName(String treatmentName) {
        this.treatmentName = treatmentName;
    }

    public int getQuantity() {
        return quantity;
    }

    public void setQuantity(int quantity) {
        this.quantity = quantity;
    }

    public BigDecimal getUnitPrice() {
        return unitPrice != null ? unitPrice : BigDecimal.ZERO;
    }

    public void setUnitPrice(BigDecimal unitPrice) {
        this.unitPrice = unitPrice;
    }

    public BigDecimal getLineTotal() {
        return lineTotal != null ? lineTotal : BigDecimal.ZERO;
    }

    public void setLineTotal(BigDecimal lineTotal) {
        this.lineTotal = lineTotal;
    }
}
