package com.sunrisedental.util;

import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.sql.Statement;

public class DBConnection {

    private static final String DEFAULT_HOST = "localhost";
    private static final String DEFAULT_DB = "sunrise_dental";
    private static final String PARAMS = "?useSSL=false&allowPublicKeyRetrieval=true&serverTimezone=UTC";

    private static final String CONFIGURED_URL = System.getProperty("db.url", 
            System.getenv("DB_URL") != null ? System.getenv("DB_URL") : null);

    private static final String CONFIGURED_USER = System.getProperty("db.user", 
            System.getenv("DB_USER") != null ? System.getenv("DB_USER") : "root");

    private static final String CONFIGURED_PASSWORD = System.getProperty("db.password", 
            System.getenv("DB_PASSWORD") != null ? System.getenv("DB_PASSWORD") : "");

    private static String workingUrl = null;
    private static String workingUser = null;
    private static String workingPassword = null;
    private static boolean migrated = false;

    static {
        try {
            Class.forName("com.mysql.cj.jdbc.Driver");
        } catch (ClassNotFoundException e) {
            System.err.println("MySQL JDBC Driver not found: " + e.getMessage());
        }
    }

    public static Connection getConnection() throws SQLException {
        // If we already found a working connection configuration, try it first
        if (workingUrl != null) {
            try {
                return DriverManager.getConnection(workingUrl, workingUser, workingPassword);
            } catch (SQLException ignored) {
                // If it fails (e.g. server restarted on another port), reset and scan
                workingUrl = null;
            }
        }

        SQLException lastException = null;

        // Try explicitly configured URL first if provided
        if (CONFIGURED_URL != null) {
            try {
                Connection conn = DriverManager.getConnection(CONFIGURED_URL, CONFIGURED_USER, CONFIGURED_PASSWORD);
                workingUrl = CONFIGURED_URL;
                workingUser = CONFIGURED_USER;
                workingPassword = CONFIGURED_PASSWORD;
                if (!migrated) runAutoMigrations(conn);
                return conn;
            } catch (SQLException e) {
                lastException = e;
            }
        }

        // Try standard MySQL ports: 3306, 3308, 3307
        int[] ports = new int[]{3306, 3308, 3307};
        String[] passwords = new String[]{CONFIGURED_PASSWORD, "", "root", "1234", "123456", "admin", "password"};

        for (int port : ports) {
            String testUrl = "jdbc:mysql://" + DEFAULT_HOST + ":" + port + "/" + DEFAULT_DB + PARAMS;
            for (String pass : passwords) {
                try {
                    Connection conn = DriverManager.getConnection(testUrl, CONFIGURED_USER, pass);
                    workingUrl = testUrl;
                    workingUser = CONFIGURED_USER;
                    workingPassword = pass;
                    if (!migrated) {
                        runAutoMigrations(conn);
                    }
                    return conn;
                } catch (SQLException e) {
                    lastException = e;
                }
            }
        }

        if (lastException != null) {
            throw lastException;
        }
        throw new SQLException("Could not connect to MySQL database on ports 3306, 3308, or 3307.");
    }

    private static synchronized void runAutoMigrations(Connection conn) {
        if (migrated) return;
        Statement stmt = null;
        try {
            stmt = conn.createStatement();
            
            // Add updated_at to dentists if not present
            try {
                stmt.executeUpdate("ALTER TABLE dentists ADD COLUMN updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP");
            } catch (SQLException ignored) {}

            // Add room_no to dentists if not present
            try {
                stmt.executeUpdate("ALTER TABLE dentists ADD COLUMN room_no VARCHAR(20) DEFAULT 'Room 1'");
            } catch (SQLException ignored) {}

            // Add created_at to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP");
            } catch (SQLException ignored) {}

            // Add payment_method to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN payment_method VARCHAR(50) DEFAULT 'Cash'");
            } catch (SQLException ignored) {}

            // Add user_invoice_no to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN user_invoice_no VARCHAR(50) DEFAULT 'REC-001'");
            } catch (SQLException ignored) {}

            // Add billed_by to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN billed_by VARCHAR(100) DEFAULT 'Receptionist'");
            } catch (SQLException ignored) {}

            // Add amount_paid to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN amount_paid DECIMAL(10,2) DEFAULT NULL");
            } catch (SQLException ignored) {}

            // Add balance_due to bills if not present
            try {
                stmt.executeUpdate("ALTER TABLE bills ADD COLUMN balance_due DECIMAL(10,2) DEFAULT NULL");
            } catch (SQLException ignored) {}

            // Ensure bill_items table exists for multi-service invoices
            try {
                stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS bill_items (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  bill_id INT NOT NULL," +
                    "  treatment_id INT," +
                    "  treatment_name VARCHAR(100) NOT NULL," +
                    "  quantity INT NOT NULL DEFAULT 1," +
                    "  unit_price DECIMAL(10,2) NOT NULL DEFAULT 0.00," +
                    "  line_total DECIMAL(10,2) NOT NULL DEFAULT 0.00," +
                    "  FOREIGN KEY (bill_id) REFERENCES bills(id) ON DELETE CASCADE" +
                    ") ENGINE=InnoDB"
                );
            } catch (SQLException ignored) {}

            // Add invoice_no to users if not present
            try {
                stmt.executeUpdate("ALTER TABLE users ADD COLUMN invoice_no VARCHAR(50) DEFAULT 'INV-1001'");
            } catch (SQLException ignored) {}

            // Ensure receptionists table exists
            try {
                stmt.executeUpdate(
                    "CREATE TABLE IF NOT EXISTS receptionists (" +
                    "  id INT AUTO_INCREMENT PRIMARY KEY," +
                    "  receptionist_code VARCHAR(20) NOT NULL UNIQUE," +
                    "  full_name VARCHAR(100) NOT NULL," +
                    "  contact_number VARCHAR(20) NOT NULL," +
                    "  email VARCHAR(100)," +
                    "  status VARCHAR(20) DEFAULT 'Active'," +
                    "  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP," +
                    "  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP" +
                    ") ENGINE=InnoDB"
                );

                // Seed sample receptionists if table is empty
                ResultSet rsRec = stmt.executeQuery("SELECT COUNT(*) FROM receptionists");
                if (rsRec.next() && rsRec.getInt(1) == 0) {
                    stmt.executeUpdate(
                        "INSERT INTO receptionists (receptionist_code, full_name, contact_number, email, status) VALUES " +
                        "('REC-001', 'Sahan Silva', '077 123 4567', 'sahan@sunrisedental.com', 'Active'), " +
                        "('REC-002', 'Kavindu Perera', '071 987 6543', 'kavindu@sunrisedental.com', 'Active')"
                    );
                }
                rsRec.close();
            } catch (SQLException ignored) {}

            // Ensure only 2 accounts exist: admin and the single shared receptionist
            try {
                // Insert the shared receptionist account if it doesn't exist
                stmt.executeUpdate("INSERT IGNORE INTO users (username, password, full_name, role, email, invoice_no) VALUES ('admin', 'admin123', 'Admin', 'Admin', 'admin@sunrisedental.com', 'INV-ADMIN-001')");
                stmt.executeUpdate("INSERT IGNORE INTO users (username, password, full_name, role, email, invoice_no) VALUES ('receptionist', 'rec123', 'Receptionist', 'Receptionist', 'receptionist@sunrisedental.com', 'INV-REC-001')");
                // Fix admin account
                stmt.executeUpdate("UPDATE users SET full_name = 'Admin', role = 'Admin' WHERE username = 'admin'");
                // Fix shared receptionist account
                stmt.executeUpdate("UPDATE users SET full_name = 'Receptionist', role = 'Receptionist' WHERE username = 'receptionist'");
                // DELETE all other accounts (old individual receptionist accounts, staff, etc.)
                stmt.executeUpdate("DELETE FROM users WHERE username NOT IN ('admin', 'receptionist')");
            } catch (SQLException ignored) {}

            migrated = true;
        } catch (Exception e) {
            System.err.println("Auto migration check: " + e.getMessage());
        } finally {
            if (stmt != null) {
                try { stmt.close(); } catch (Exception ignored) {}
            }
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
