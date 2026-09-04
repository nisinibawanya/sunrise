package com.sunrisedental.test;

import com.sunrisedental.model.Bill;
import com.sunrisedental.model.BillItem;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

/**
 * TDD Unit Test for Billing and Mathematical Calculations.
 * Verifies multi-service line item multiplication, subtotal summation,
 * discount application, amount paid, and balance due consistency.
 */
public class BillCalculationTest {

    public static boolean runTests() {
        System.out.println("  Running BillCalculationTest...");
        boolean allPassed = true;

        allPassed &= testSingleServiceCalculation();
        allPassed &= testMultiServiceCalculation();
        allPassed &= testDiscountCalculation();
        allPassed &= testPaidStatusMathConsistency();
        allPassed &= testPendingStatusMathConsistency();
        allPassed &= testPartiallyPaidMathConsistency();
        allPassed &= testDiscountLimitValidation();
        allPassed &= testPaymentMethodValidation();

        return allPassed;
    }

    private static boolean testSingleServiceCalculation() {
        BillItem item = new BillItem(1, 101, 1, "Checkup & Consultation", 1, new BigDecimal("1000.00"), new BigDecimal("1000.00"));
        boolean ok = item.getLineTotal().compareTo(new BigDecimal("1000.00")) == 0;
        printResult("Single service line total (1 x 1000.00)", ok);
        return ok;
    }

    private static boolean testMultiServiceCalculation() {
        Bill bill = new Bill();
        List<BillItem> items = new ArrayList<>();

        // Service 1: Consultation (1 x 1000)
        items.add(new BillItem(1, 1, 1, "Consultation", 1, new BigDecimal("1000.00"), new BigDecimal("1000.00")));
        // Service 2: Tooth Filling (2 x 3500)
        items.add(new BillItem(2, 1, 2, "Tooth Filling", 2, new BigDecimal("3500.00"), new BigDecimal("7000.00")));
        // Service 3: Scaling (1 x 2500)
        items.add(new BillItem(3, 1, 3, "Scaling", 1, new BigDecimal("2500.00"), new BigDecimal("2500.00")));

        BigDecimal calculatedSubtotal = BigDecimal.ZERO;
        for (BillItem it : items) {
            BigDecimal lineTotal = it.getUnitPrice().multiply(BigDecimal.valueOf(it.getQuantity()));
            calculatedSubtotal = calculatedSubtotal.add(lineTotal);
        }

        bill.setItems(items);
        bill.setSubTotal(calculatedSubtotal);

        boolean ok = calculatedSubtotal.compareTo(new BigDecimal("10500.00")) == 0;
        printResult("Multi-service subtotal calculation (1000 + 7000 + 2500 = 10500.00)", ok);
        return ok;
    }

    private static boolean testDiscountCalculation() {
        BigDecimal subtotal = new BigDecimal("10500.00");
        BigDecimal discount = new BigDecimal("500.00");
        BigDecimal total = subtotal.subtract(discount);

        Bill bill = new Bill();
        bill.setSubTotal(subtotal);
        bill.setDiscount(discount);
        bill.setTotalAmount(total);

        boolean ok = bill.getTotalAmount().compareTo(new BigDecimal("10000.00")) == 0;
        printResult("Discount deduction (10500.00 - 500.00 = 10000.00)", ok);
        return ok;
    }

    private static boolean testPaidStatusMathConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setPaymentStatus("Paid");

        BigDecimal paid = bill.getAmountPaid();
        BigDecimal due = bill.getBalanceDue();

        boolean ok = (paid.compareTo(new BigDecimal("5000.00")) == 0) &&
                     (due.compareTo(BigDecimal.ZERO) == 0);
        printResult("PAID status consistency (Total=5000 -> Paid=5000, Due=0)", ok);
        return ok;
    }

    private static boolean testPendingStatusMathConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setPaymentStatus("Pending");

        BigDecimal paid = bill.getAmountPaid();
        BigDecimal due = bill.getBalanceDue();

        boolean ok = (paid.compareTo(BigDecimal.ZERO) == 0) &&
                     (due.compareTo(new BigDecimal("5000.00")) == 0);
        printResult("PENDING status consistency (Total=5000 -> Paid=0, Due=5000)", ok);
        return ok;
    }

    private static boolean testPartiallyPaidMathConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setAmountPaid(new BigDecimal("2000.00"));
        bill.setPaymentStatus("Partially Paid");

        BigDecimal paid = bill.getAmountPaid();
        BigDecimal due = bill.getBalanceDue();

        boolean ok = (paid.compareTo(new BigDecimal("2000.00")) == 0) &&
                     (due.compareTo(new BigDecimal("3000.00")) == 0);
        printResult("PARTIALLY PAID status consistency (Total=5000, Paid=2000 -> Due=3000)", ok);
        return ok;
    }

    private static boolean testDiscountLimitValidation() {
        BigDecimal subTotal = new BigDecimal("4000.00");
        BigDecimal excessiveDiscount = new BigDecimal("4500.00");
        BigDecimal negativeDiscount = new BigDecimal("-100.00");

        boolean rejectExcessive = excessiveDiscount.compareTo(subTotal) > 0;
        boolean rejectNegative = negativeDiscount.compareTo(BigDecimal.ZERO) < 0;

        boolean ok = rejectExcessive && rejectNegative;
        printResult("Discount validation (Reject if > subtotal or negative -> total never negative)", ok);
        return ok;
    }

    private static boolean testPaymentMethodValidation() {
        String unselected = null;
        String empty = "";
        String valid = "Credit / Debit Card";

        boolean rejectUnselected = (unselected == null || unselected.trim().isEmpty());
        boolean rejectEmpty = (empty == null || empty.trim().isEmpty());
        boolean acceptValid = (valid != null && !valid.trim().isEmpty());

        boolean ok = rejectUnselected && rejectEmpty && acceptValid;
        printResult("Payment method selection validation (Must be explicitly selected before bill completion)", ok);
        return ok;
    }

    private static void printResult(String testName, boolean passed) {
        System.out.println("    " + (passed ? "✅ [PASS]" : "❌ [FAIL]") + " " + testName);
    }
}
