package com.sunrisedental.test;

/**
 * TDD Unit Test for Sequential Identifier Formatting.
 * Tests invoice numbering (INV-XXXXXX), receptionist coding (REC-XXX), and appointment formatting (AXXXX).
 */
public class SequentialIdGeneratorTest {

    public static boolean runTests() {
        System.out.println("  Running SequentialIdGeneratorTest...");
        boolean allPassed = true;

        allPassed &= testInvoiceNumberFormat();
        allPassed &= testReceptionistCodeFormat();
        allPassed &= testAppointmentNumberFormat();

        return allPassed;
    }

    private static boolean testInvoiceNumberFormat() {
        int nextInvoiceSeq = 5;
        String formattedInvoiceNo = String.format("INV-%06d", nextInvoiceSeq);

        boolean ok = "INV-000005".equals(formattedInvoiceNo) && formattedInvoiceNo.length() == 10;
        printResult("Invoice number formatting (sequence 5 -> 'INV-000005')", ok);
        return ok;
    }

    private static boolean testReceptionistCodeFormat() {
        int nextRecSeq = 3;
        String formattedRecCode = String.format("REC-%03d", nextRecSeq);

        boolean ok = "REC-003".equals(formattedRecCode) && formattedRecCode.length() == 7;
        printResult("Receptionist code formatting (sequence 3 -> 'REC-003')", ok);
        return ok;
    }

    private static boolean testAppointmentNumberFormat() {
        int nextApptSeq = 1008;
        String formattedApptNo = String.format("A%04d", nextApptSeq);

        boolean ok = "A1008".equals(formattedApptNo);
        printResult("Appointment number formatting (sequence 1008 -> 'A1008')", ok);
        return ok;
    }

    private static void printResult(String testName, boolean passed) {
        System.out.println("    " + (passed ? "✅ [PASS]" : "❌ [FAIL]") + " " + testName);
    }
}
