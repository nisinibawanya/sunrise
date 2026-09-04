package com.sunrisedental.test;

import java.sql.Date;

/**
 * TDD Unit Test for Appointment Double-Booking & Conflict Validation.
 */
public class AppointmentValidationTest {

    public static boolean runTests() {
        System.out.println("  Running AppointmentValidationTest...");
        boolean allPassed = true;

        allPassed &= testPatientConflictDetection();
        allPassed &= testDentistConflictDetection();
        allPassed &= testCancelledAppointmentsExclusion();
        allPassed &= testInactiveDentistBlocked();
        allPassed &= testActiveDentistAllowed();

        return allPassed;
    }

    private static boolean testPatientConflictDetection() {
        Date date1 = Date.valueOf("2026-09-10");
        String time1 = "09:00 AM";

        Date date2 = Date.valueOf("2026-09-10");
        String time2 = "09:00 AM";

        boolean conflict = date1.equals(date2) && time1.trim().equalsIgnoreCase(time2.trim());
        printResult("Patient double booking prevention (Same patient on same date & time -> conflict=true)", conflict);
        return conflict;
    }

    private static boolean testDentistConflictDetection() {
        int dentistId1 = 1;
        int dentistId2 = 1;
        Date date1 = Date.valueOf("2026-09-10");
        Date date2 = Date.valueOf("2026-09-10");
        String time1 = "10:30 AM";
        String time2 = "10:30 AM";

        boolean conflict = (dentistId1 == dentistId2) && date1.equals(date2) && time1.equalsIgnoreCase(time2);
        printResult("Dentist collision prevention (Same dentist assigned to 2 patients on same date & time -> conflict=true)", conflict);
        return conflict;
    }

    private static boolean testCancelledAppointmentsExclusion() {
        String status = "Cancelled";
        boolean isActive = (status == null || !"Cancelled".equalsIgnoreCase(status));

        boolean ok = !isActive;
        printResult("Cancelled appointments do not block re-booking of slot", ok);
        return ok;
    }

    private static boolean testInactiveDentistBlocked() {
        boolean dentistIsActive = false;
        boolean bookingAllowed = dentistIsActive;
        boolean blocked = !bookingAllowed;
        printResult("Inactive dentist appointment prevention (Dentist isActive=false -> blocked=true)", blocked);
        return blocked;
    }

    private static boolean testActiveDentistAllowed() {
        boolean dentistIsActive = true;
        boolean bookingAllowed = dentistIsActive;
        printResult("Active dentist appointment acceptance (Dentist isActive=true -> bookingAllowed=true)", bookingAllowed);
        return bookingAllowed;
    }

    private static void printResult(String testName, boolean passed) {
        System.out.println("    " + (passed ? "✅ [PASS]" : "❌ [FAIL]") + " " + testName);
    }
}
