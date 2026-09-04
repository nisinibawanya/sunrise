package com.sunrisedental.test;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Sequential Identifier Formatting JUnit Tests")
public class SequentialIdGeneratorJUnitTest {

    @Test
    @DisplayName("Test 1: Invoice Number Formatting (INV-%06d)")
    void testInvoiceNumberFormat() {
        int sequence = 5;
        String formatted = String.format("INV-%06d", sequence);
        assertEquals("INV-000005", formatted);
        assertEquals(10, formatted.length());
    }

    @Test
    @DisplayName("Test 2: Receptionist Code Formatting (REC-%03d)")
    void testReceptionistCodeFormat() {
        int sequence = 3;
        String formatted = String.format("REC-%03d", sequence);
        assertEquals("REC-003", formatted);
        assertEquals(7, formatted.length());
    }

    @Test
    @DisplayName("Test 3: Appointment Number Formatting (A%04d)")
    void testAppointmentNumberFormat() {
        int sequence = 1008;
        String formatted = String.format("A%04d", sequence);
        assertEquals("A1008", formatted);
    }
}
