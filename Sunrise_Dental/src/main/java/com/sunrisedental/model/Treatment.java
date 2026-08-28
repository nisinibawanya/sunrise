package com.sunrisedental.model;

import java.io.Serializable;
import java.math.BigDecimal;

public class Treatment implements Serializable {
    private static final long serialVersionUID = 1L;

    private int id;
    private String name;
    private BigDecimal cost;
    private String description;

    public Treatment() {}

    public Treatment(int id, String name, BigDecimal cost, String description) {
        this.id = id;
        this.name = name;
        this.cost = cost;
        this.description = description;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public BigDecimal getCost() {
        return cost;
    }

    public void setCost(BigDecimal cost) {
        this.cost = cost;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }
}
