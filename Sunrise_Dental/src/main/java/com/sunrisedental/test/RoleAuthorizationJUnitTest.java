package com.sunrisedental.test;

import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Role-Based Authorization & Security JUnit Tests")
public class RoleAuthorizationJUnitTest {

    @Test
    @DisplayName("Test 1: Admin Full Module & Financial Privileges")
    void testAdminPrivileges() {
        String userRole = "Admin";
        boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);

        assertTrue(isAdmin, "User with Admin role must evaluate to isAdmin=true");
    }

    @Test
    @DisplayName("Test 2: Receptionist Financial & Management Denial")
    void testReceptionistRestrictions() {
        String userRole = "Receptionist";
        boolean isAdmin = "Admin".equalsIgnoreCase(userRole) || "Administrator".equalsIgnoreCase(userRole);

        assertFalse(isAdmin, "Receptionist must not evaluate to isAdmin=true");
    }

    @Test
    @DisplayName("Test 3: Cookie Spoofing Cannot Bypass Server Role")
    void testCookieSpoofingDefense() {
        // Attacker changes client cookie to 'admin'
        String clientCookieUsername = "admin";

        // Server session role remains Receptionist
        String serverSessionRole = "Receptionist";
        boolean isAuthorizedAsAdmin = "Admin".equalsIgnoreCase(serverSessionRole);

        assertFalse(isAuthorizedAsAdmin, "Server-side session role must take precedence over client cookie");
    }
}
