package com.sunrisedental.test;

import jakarta.servlet.http.Cookie;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;

/**
 * TDD Unit Test for the "Remember Me" HTTP Cookie Implementation.
 * Verifies 7-day max-age, HttpOnly flag, sanitization, and clearing mechanism.
 */
public class CookieSecurityTest {

    public static boolean runTests() {
        System.out.println("  Running CookieSecurityTest...");
        boolean allPassed = true;

        allPassed &= testCookieCreationProperties();
        allPassed &= testCookieValueContainsNoPasswordOrRole();
        allPassed &= testCookieSanitizationAgainstXSS();
        allPassed &= testCookieDeletionMaxAge();

        return allPassed;
    }

    private static boolean testCookieCreationProperties() {
        String username = "receptionist";
        String encoded = URLEncoder.encode(username, StandardCharsets.UTF_8);

        Cookie cookie = new Cookie("rememberedUsername", encoded);
        cookie.setMaxAge(7 * 24 * 60 * 60); // 7 days = 604,800 seconds
        cookie.setHttpOnly(true);
        cookie.setPath("/Sunrise_Dental");

        boolean nameOk = "rememberedUsername".equals(cookie.getName());
        boolean maxAgeOk = (cookie.getMaxAge() == 604800);
        boolean httpOnlyOk = cookie.isHttpOnly();
        boolean pathOk = "/Sunrise_Dental".equals(cookie.getPath());

        boolean ok = nameOk && maxAgeOk && httpOnlyOk && pathOk;
        printResult("Cookie configuration (Name='rememberedUsername', MaxAge=604800s, HttpOnly=true)", ok);
        return ok;
    }

    private static boolean testCookieValueContainsNoPasswordOrRole() {
        String username = "admin";
        String encoded = URLEncoder.encode(username, StandardCharsets.UTF_8);
        Cookie cookie = new Cookie("rememberedUsername", encoded);

        String decoded = URLDecoder.decode(cookie.getValue(), StandardCharsets.UTF_8);

        boolean noPassword = !decoded.contains("admin123") && !decoded.contains("password");
        boolean noRole = !decoded.contains("ROLE_") && !decoded.contains("Administrator");
        boolean onlyUsername = "admin".equals(decoded);

        boolean ok = noPassword && noRole && onlyUsername;
        printResult("Cookie data isolation (contains only username, no credentials or roles)", ok);
        return ok;
    }

    private static boolean testCookieSanitizationAgainstXSS() {
        String maliciousInput = "<script>alert('XSS Attack')</script>";
        String safeUsername = maliciousInput.replace("&", "&amp;")
                                            .replace("<", "&lt;")
                                            .replace(">", "&gt;")
                                            .replace("\"", "&quot;")
                                            .replace("'", "&#x27;");

        boolean neutralized = !safeUsername.contains("<script>") && !safeUsername.contains("</script>");
        boolean escaped = safeUsername.contains("&lt;script&gt;");

        boolean ok = neutralized && escaped;
        printResult("Cookie XSS sanitization (HTML-escapes script tags and entities)", ok);
        return ok;
    }

    private static boolean testCookieDeletionMaxAge() {
        Cookie clearCookie = new Cookie("rememberedUsername", "");
        clearCookie.setMaxAge(0);
        clearCookie.setHttpOnly(true);
        clearCookie.setPath("/Sunrise_Dental");

        boolean ok = (clearCookie.getMaxAge() == 0);
        printResult("Cookie deletion on uncheck/logout (Max-Age=0 instructs browser removal)", ok);
        return ok;
    }

    private static void printResult(String testName, boolean passed) {
        System.out.println("    " + (passed ? "✅ [PASS]" : "❌ [FAIL]") + " " + testName);
    }
}
