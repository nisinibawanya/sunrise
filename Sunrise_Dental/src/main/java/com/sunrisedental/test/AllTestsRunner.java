package com.sunrisedental.test;

/**
 * Master Test Suite Runner for Sunrise Dental Clinic.
 * Executes all automated unit and integration tests and outputs structured results.
 */
public class AllTestsRunner {

    public static void main(String[] args) {
        System.out.println("===============================================================================");
        System.out.println("       SUNRISE DENTAL CLINIC - TEST-DRIVEN DEVELOPMENT (TDD) TEST SUITE        ");
        System.out.println("===============================================================================");
        System.out.println();

        long startTime = System.currentTimeMillis();
        int totalSuites = 5;
        int passedSuites = 0;

        // 1. Billing and Mathematical Calculation Tests
        System.out.println("[SUITE 1/5] BILLING & MULTI-SERVICE INVOICING CALCULATIONS");
        boolean billingPassed = BillCalculationTest.runTests();
        if (billingPassed) passedSuites++;
        System.out.println();

        // 2. Cookie Security and Remember Me Tests
        System.out.println("[SUITE 2/5] REMEMBER ME HTTP COOKIE & XSS SECURITY");
        boolean cookiePassed = CookieSecurityTest.runTests();
        if (cookiePassed) passedSuites++;
        System.out.println();

        // 3. Role-Based Authorization & Security Tests
        System.out.println("[SUITE 3/5] ROLE-BASED ACCESS CONTROL (ADMIN VS RECEPTIONIST)");
        boolean authPassed = RoleAuthorizationTest.runTests();
        if (authPassed) passedSuites++;
        System.out.println();

        // 4. Sequential Identifier Generator Tests
        System.out.println("[SUITE 4/5] SEQUENTIAL IDENTIFIER GENERATION (INV, REC, APPT)");
        boolean idPassed = SequentialIdGeneratorTest.runTests();
        if (idPassed) passedSuites++;
        System.out.println();

        // 5. Appointment Validation Tests
        System.out.println("[SUITE 5/5] APPOINTMENT VALIDATION & CONFLICT DETECTION");
        boolean apptPassed = AppointmentValidationTest.runTests();
        if (apptPassed) passedSuites++;
        System.out.println();

        long duration = System.currentTimeMillis() - startTime;

        System.out.println("===============================================================================");
        System.out.println("                              TEST EXECUTION SUMMARY                           ");
        System.out.println("===============================================================================");
        System.out.println("  Total Test Suites  : " + totalSuites);
        System.out.println("  Passed Suites      : " + passedSuites);
        System.out.println("  Failed Suites      : " + (totalSuites - passedSuites));
        System.out.println("  Execution Time     : " + duration + " ms");
        System.out.println("  Overall Status     : " + (passedSuites == totalSuites ? "ALL TESTS PASSED ✅" : "SOME TESTS FAILED ❌"));
        System.out.println("===============================================================================");

        if (passedSuites != totalSuites) {
            System.exit(1);
        }
    }
}
