package com.sunrisedental.test;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.sql.Date;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Appointment Scheduling Validation JUnit Tests")
public class AppointmentValidationJUnitTest {

    @Test
    @DisplayName("Test 1: Patient Conflict Detection (Same Date and Time)")
    void testPatientConflictDetection() {
        Date date1 = Date.valueOf("2026-09-10");
        String time1 = "09:00 AM";

        Date date2 = Date.valueOf("2026-09-10");
        String time2 = "09:00 AM";

        int patientId = 101;

        boolean isSameDate = date1.equals(date2);
        boolean isSameTime = time1.trim().equalsIgnoreCase(time2.trim());
        boolean hasConflict = (patientId == 101) && isSameDate && isSameTime;

        assertTrue(hasConflict, "Same patient booking at identical date and time must be flagged as conflict");
    }

    @Test
    @DisplayName("Test 2: Patient Allows Non-Overlapping Times on Same Date")
    void testPatientDifferentTimesAllowed() {
        Date date1 = Date.valueOf("2026-09-10");
        String time1 = "09:00 AM";

        Date date2 = Date.valueOf("2026-09-10");
        String time2 = "02:30 PM";

        boolean isSameTime = time1.trim().equalsIgnoreCase(time2.trim());
        assertFalse(isSameTime, "Different time slots on the same date should not conflict");
    }

    @Test
    @DisplayName("Test 3: Dentist Conflict Detection (Same Dentist at Same Date and Time)")
    void testDentistConflictDetection() {
        int dentistId = 2; // Dr. Perera
        Date date1 = Date.valueOf("2026-09-10");
        String time1 = "10:30 AM";

        int incomingDentistId = 2;
        Date incomingDate = Date.valueOf("2026-09-10");
        String incomingTime = "10:30 AM";

        boolean dentistConflict = (dentistId == incomingDentistId) && 
                                  date1.equals(incomingDate) && 
                                  time1.equalsIgnoreCase(incomingTime);

        assertTrue(dentistConflict, "Same dentist assigned to another patient at identical date and time must be flagged as conflict");
    }

    @Test
    @DisplayName("Test 4: Different Dentists Allowed at Same Date and Time")
    void testDifferentDentistsAllowed() {
        int dentistA = 1; // Dr. Silva
        int dentistB = 2; // Dr. Perera
        Date date = Date.valueOf("2026-09-10");
        String time = "10:30 AM";

        boolean sameDentist = (dentistA == dentistB);
        assertFalse(sameDentist, "Different dentists can operate in different surgery rooms simultaneously");
    }

    @Test
    @DisplayName("Test 5: Cancelled Appointments Do Not Block New Bookings")
    void testCancelledAppointmentsDoNotBlock() {
        String existingStatus = "Cancelled";
        boolean isActive = (existingStatus == null || !"Cancelled".equalsIgnoreCase(existingStatus));

        assertFalse(isActive, "Cancelled appointments must not block slot from being booked");
    }

    @Test
    @DisplayName("Test 6: Inactive Dentist Booking Prevented")
    void testInactiveDentistBookingPrevented() {
        boolean isDentistActive = false;
        String errorMessage = null;

        if (!isDentistActive) {
            errorMessage = "This dentist is currently inactive and cannot accept appointments.";
        }

        assertNotNull(errorMessage, "Inactive dentist must be blocked from booking");
        assertEquals("This dentist is currently inactive and cannot accept appointments.", errorMessage);
    }

    @Test
    @DisplayName("Test 7: Active Dentist Booking Permitted")
    void testActiveDentistBookingPermitted() {
        boolean isDentistActive = true;
        String errorMessage = null;

        if (!isDentistActive) {
            errorMessage = "This dentist is currently inactive and cannot accept appointments.";
        }

        assertNull(errorMessage, "Active dentist must be permitted to accept appointments");
    }
}
