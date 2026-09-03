package com.sunrisedental.model;

import java.io.Serializable;
import java.sql.Timestamp;

public class Receptionist implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String receptionistCode; // e.g. REC-001
    private String fullName;
    private String contactNumber;
    private String email;
    private String status; // "Active" or "Inactive"
    private Timestamp createdAt;
    private Timestamp updatedAt;

    public Receptionist() {
        this.status = "Active";
    }

    public Receptionist(int id, String receptionistCode, String fullName, String contactNumber, 
                        String email, String status, Timestamp createdAt, Timestamp updatedAt) {
        this.id = id;
        this.receptionistCode = receptionistCode;
        this.fullName = fullName;
        this.contactNumber = contactNumber;
        this.email = email;
        this.status = status != null ? status : "Active";
        this.createdAt = createdAt;
        this.updatedAt = updatedAt;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getReceptionistCode() {
        return receptionistCode;
    }

    public void setReceptionistCode(String receptionistCode) {
        this.receptionistCode = receptionistCode;
    }

    public String getFullName() {
        return fullName;
    }

    public void setFullName(String fullName) {
        this.fullName = fullName;
    }

    public String getContactNumber() {
        return contactNumber;
    }

    public void setContactNumber(String contactNumber) {
        this.contactNumber = contactNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getStatus() {
        return status != null ? status : "Active";
    }

    public void setStatus(String status) {
        this.status = status;
    }

    public boolean isActive() {
        return "Active".equalsIgnoreCase(this.status);
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    public Timestamp getUpdatedAt() {
        return updatedAt;
    }

    public void setUpdatedAt(Timestamp updatedAt) {
        this.updatedAt = updatedAt;
    }
}
