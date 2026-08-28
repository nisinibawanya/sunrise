package com.sunrisedental.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    private static final String URL = System.getProperty("db.url", 
            System.getenv("DB_URL") != null ? System.getenv("DB_URL") 
            : "jdbc:mysql://localhost:3306/sunrise_dental?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC");

    private static final String USER = System.getProperty("db.user", 
            System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root");

    private static final String PASSWORD = System.getProperty("db.password", 
            System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "");

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        // Try configured password first
        try {
            return DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (SQLException e) {
            // Try common fallback passwords if default fails
            String[] fallbacks = new String[]{"root", "1234", "123456", "admin", "password"};
            for (String fallbackPass : fallbacks) {
                if (!fallbackPass.equals(PASSWORD)) {
                    try {
                        return DriverManager.getConnection(URL, USER, fallbackPass);
                    } catch (SQLException ignored) {}
                }
            }
            throw e;
        }
    }

    public static void close(AutoCloseable... resources) {
        for (AutoCloseable res : resources) {
            if (res != null) {
                try {
                    res.close();
                } catch (Exception e) {
                    System.err.println("Error closing resource: " + e.getMessage());
                }
            }
        }
    }
}
