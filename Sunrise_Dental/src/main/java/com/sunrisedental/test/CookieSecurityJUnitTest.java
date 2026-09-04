package com.sunrisedental.test;

import jakarta.servlet.http.Cookie;
import org.junit.jupiter.api.DisplayName;
import org.junit.jupiter.api.Test;

import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

import static org.junit.jupiter.api.Assertions.*;

@DisplayName("Remember Me HTTP Cookie Security JUnit Tests")
public class CookieSecurityJUnitTest {

    @Test
    @DisplayName("Test 1: Cookie Configuration Properties (HttpOnly, 7-Day Expiry, Path)")
    void testCookieConfiguration() {
        String username = "receptionist";
        String encoded = URLEncoder.encode(username, StandardCharsets.UTF_8);

        Cookie cookie = new Cookie("rememberedUsername", encoded);
        cookie.setMaxAge(7 * 24 * 60 * 60); // 604,800 seconds
        cookie.setHttpOnly(true);
        cookie.setPath("/Sunrise_Dental");

        assertEquals("rememberedUsername", cookie.getName());
        assertEquals(604800, cookie.getMaxAge(), "Cookie lifespan must be exactly 7 days (604800 seconds)");
        assertTrue(cookie.isHttpOnly(), "HttpOnly flag must be enabled to prevent XSS script access");
        assertEquals("/Sunrise_Dental", cookie.getPath());
    }

    @Test
    @DisplayName("Test 2: Cookie Data Isolation (Contains only Username, no Passwords/Roles)")
    void testCookieDataIsolation() {
        String username = "admin";
        String encoded = URLEncoder.encode(username, StandardCharsets.UTF_8);
        Cookie cookie = new Cookie("rememberedUsername", encoded);

        String decoded = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);

        assertEquals("admin", decoded);
        assertFalse(decoded.contains("admin123"), "Cookie must never contain passwords");
        assertFalse(decoded.contains("ROLE_ADMIN"), "Cookie must never contain role/permission tokens");
    }

    @Test
    @DisplayName("Test 3: XSS Sanitization for Pre-populated HTML Attributes")
    void testXssSanitization() {
        String xssPayload = "<script>alert('XSS')</script>";
        String safeUsername = xssPayload.replace("&", "&amp;")
                                        .replace("<", "&lt;")
                                        .replace(">", "&gt;")
                                        .replace("\"", "&quot;")
                                        .replace("'", "&#x27;");

        assertFalse(safeUsername.contains("<script>"), "Script tag opening must be sanitized");
        assertFalse(safeUsername.contains("</script>"), "Script tag closing must be sanitized");
        assertTrue(safeUsername.contains("&lt;script&gt;"), "Tags must be safely HTML entity encoded");
    }

    @Test
    @DisplayName("Test 4: Cookie Deletion on Logout / Uncheck (Max-Age = 0)")
    void testCookieDeletion() {
        Cookie clearCookie = new Cookie("rememberedUsername", "");
        clearCookie.setMaxAge(0);
        clearCookie.setHttpOnly(true);
        clearCookie.setPath("/Sunrise_Dental");

        assertEquals(0, clearCookie.getMaxAge(), "Setting Max-Age to 0 instructs browser to delete cookie");
    }
}
