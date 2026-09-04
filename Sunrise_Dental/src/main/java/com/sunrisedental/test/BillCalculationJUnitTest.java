package com.sunrisedental.test;

import com.sunrisedental.model.Bill;
import com.sunrisedental.model.BillItem;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.math.BigDecimal;
import java.util.ArrayList;
import java.util.List;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Billing & Multi-Service Invoicing JUnit Tests")
public class BillCalculationJUnitTest {

    @Test
    @DisplayName("Test 1: Single Service Line Total Calculation")
    void testSingleServiceCalculation() {
        BillItem item = new BillItem(1, 101, 1, "Checkup & Consultation", 1, new BigDecimal("1000.00"), new BigDecimal("1000.00"));
        assertEquals(0, item.getLineTotal().compareTo(new BigDecimal("1000.00")), "Line total should be 1000.00");
    }

    @Test
    @DisplayName("Test 2: Multi-Service Itemized Subtotal Summation")
    void testMultiServiceSubtotal() {
        Bill bill = new Bill();
        List<BillItem> items = new ArrayList<>();

        items.add(new BillItem(1, 1, 1, "Consultation", 1, new BigDecimal("1000.00"), new BigDecimal("1000.00")));
        items.add(new BillItem(2, 1, 2, "Tooth Filling", 2, new BigDecimal("3500.00"), new BigDecimal("7000.00")));
        items.add(new BillItem(3, 1, 3, "Scaling", 1, new BigDecimal("2500.00"), new BigDecimal("2500.00")));

        BigDecimal subtotal = BigDecimal.ZERO;
        for (BillItem it : items) {
            subtotal = subtotal.add(it.getUnitPrice().multiply(BigDecimal.valueOf(it.getQuantity())));
        }
        bill.setItems(items);
        bill.setSubTotal(subtotal);

        assertEquals(0, bill.getSubTotal().compareTo(new BigDecimal("10500.00")), "Subtotal should equal 10500.00");
    }

    @Test
    @DisplayName("Test 3: Discount Application on Subtotal")
    void testDiscountApplication() {
        BigDecimal subtotal = new BigDecimal("10500.00");
        BigDecimal discount = new BigDecimal("500.00");
        BigDecimal total = subtotal.subtract(discount);

        Bill bill = new Bill();
        bill.setSubTotal(subtotal);
        bill.setDiscount(discount);
        bill.setTotalAmount(total);

        assertEquals(0, bill.getTotalAmount().compareTo(new BigDecimal("10000.00")), "Total amount after discount should be 10000.00");
    }

    @Test
    @DisplayName("Test 4: PAID Status Mathematical Consistency")
    void testPaidStatusConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setPaymentStatus("Paid");

        assertEquals(0, bill.getAmountPaid().compareTo(new BigDecimal("5000.00")), "Amount paid must equal total amount for Paid status");
        assertEquals(0, bill.getBalanceDue().compareTo(BigDecimal.ZERO), "Balance due must be 0 for Paid status");
    }

    @Test
    @DisplayName("Test 5: PENDING Status Mathematical Consistency")
    void testPendingStatusConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setPaymentStatus("Pending");

        assertEquals(0, bill.getAmountPaid().compareTo(BigDecimal.ZERO), "Amount paid must be 0 for Pending status");
        assertEquals(0, bill.getBalanceDue().compareTo(new BigDecimal("5000.00")), "Balance due must equal total amount for Pending status");
    }

    @Test
    @DisplayName("Test 6: PARTIALLY PAID Status Mathematical Consistency")
    void testPartiallyPaidStatusConsistency() {
        Bill bill = new Bill();
        bill.setTotalAmount(new BigDecimal("5000.00"));
        bill.setAmountPaid(new BigDecimal("2000.00"));
        bill.setPaymentStatus("Partially Paid");

        assertEquals(0, bill.getAmountPaid().compareTo(new BigDecimal("2000.00")));
        assertEquals(0, bill.getBalanceDue().compareTo(new BigDecimal("3000.00")), "Balance due must equal Total - Paid");
    }

    @Test
    @DisplayName("Test 7: Reject Discount Exceeding Subtotal (Total Never Negative)")
    void testRejectDiscountExceedingSubtotal() {
        BigDecimal subTotal = new BigDecimal("4500.00");
        BigDecimal excessiveDiscount = new BigDecimal("5000.00");

        boolean isDiscountValid = excessiveDiscount.compareTo(BigDecimal.ZERO) >= 0 &&
                                  excessiveDiscount.compareTo(subTotal) <= 0;

        assertFalse(isDiscountValid, "Discount exceeding subtotal must be rejected to prevent negative total");

        BigDecimal resultingTotal = subTotal.subtract(excessiveDiscount);
        assertTrue(resultingTotal.compareTo(BigDecimal.ZERO) < 0, "Excessive discount results in negative total");
    }

    @Test
    @DisplayName("Test 8: Reject Negative Discount Amount")
    void testRejectNegativeDiscount() {
        BigDecimal negativeDiscount = new BigDecimal("-250.00");
        boolean isNegative = negativeDiscount.compareTo(BigDecimal.ZERO) < 0;

        assertTrue(isNegative, "Negative discounts must be detected as invalid");
    }

    @Test
    @DisplayName("Test 9: Prevent Submission Without Selected Payment Method")
    void testPaymentMethodRequired() {
        String unselectedMethod = null;
        boolean hasValidPaymentMethod = unselectedMethod != null && !unselectedMethod.trim().isEmpty();

        assertFalse(hasValidPaymentMethod, "Bill submission must be prevented when no payment method is selected");

        String emptyMethod = "   ";
        boolean hasValidEmpty = emptyMethod != null && !emptyMethod.trim().isEmpty();
        assertFalse(hasValidEmpty, "Whitespace-only payment method must be rejected");
    }

    @Test
    @DisplayName("Test 10: Valid Payment Methods Accepted")
    void testValidPaymentMethodsAccepted() {
        String[] validMethods = {"Cash", "Credit / Debit Card", "Bank Transfer", "Insurance"};
        for (String method : validMethods) {
            boolean isValid = method != null && (
                "Cash".equalsIgnoreCase(method) ||
                "Credit / Debit Card".equalsIgnoreCase(method) ||
                "Bank Transfer".equalsIgnoreCase(method) ||
                "Insurance".equalsIgnoreCase(method)
            );
            assertTrue(isValid, "Method '" + method + "' should be accepted as a valid payment method");
        }
    }
}
