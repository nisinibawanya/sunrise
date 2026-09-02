package com.sunrisedental.util;

import jakarta.mail.Authenticator;
import jakarta.mail.Message;
import jakarta.mail.PasswordAuthentication;
import jakarta.mail.Session;
import jakarta.mail.Transport;
import jakarta.mail.internet.InternetAddress;
import jakarta.mail.internet.MimeMessage;

import java.util.Properties;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class EmailService {

    private static final ExecutorService EXECUTOR = Executors.newFixedThreadPool(3);

    private static final String SMTP_HOST = System.getProperty("smtp.host", 
            System.getenv("SMTP_HOST") != null ? System.getenv("SMTP_HOST") : "smtp.gmail.com");
    private static final String SMTP_PORT = System.getProperty("smtp.port", 
            System.getenv("SMTP_PORT") != null ? System.getenv("SMTP_PORT") : "587");
    private static final String SMTP_USER = System.getProperty("smtp.user", 
            System.getenv("SMTP_USER") != null ? System.getenv("SMTP_USER") : "onalironaya@gmail.com");
    private static final String SMTP_PASS = System.getProperty("smtp.password", 
            System.getenv("SMTP_PASS") != null ? System.getenv("SMTP_PASS") : "aataewidgtncccaf");
    private static final String FROM_EMAIL = System.getProperty("smtp.from", 
            System.getenv("SMTP_FROM") != null ? System.getenv("SMTP_FROM") : "onalironaya@gmail.com");

    /**
     * Asynchronously sends appointment confirmation email to the patient with full details.
     */
    public static void sendAppointmentConfirmation(String recipientEmail, String patientName, 
                                                   String appointmentNo, String dentistName, 
                                                   String treatmentName, String appointmentDate, 
                                                   String appointmentTime) {
        if (recipientEmail == null || recipientEmail.trim().isEmpty() || !recipientEmail.contains("@")) {
            System.out.println("[EmailService] No valid recipient email provided for patient: " + patientName);
            return;
        }

        EXECUTOR.submit(() -> {
            try {
                System.out.println("[EmailService] Preparing appointment confirmation email for: " + recipientEmail);

                String subject = "Appointment Confirmation - Sunrise Dental Clinic (" + appointmentNo + ")";
                
                String htmlContent = "<div style=\"font-family: 'Segoe UI', Roboto, Helvetica, Arial, sans-serif; max-width: 600px; margin: 0 auto; border: 1px solid #e2e8f0; border-radius: 12px; overflow: hidden; background: #ffffff; box-shadow: 0 4px 6px -1px rgba(0, 0, 0, 0.1);\">"
                    + "<div style=\"background: linear-gradient(135deg, #1e1b4b, #4338ca); color: #ffffff; padding: 28px 24px; text-align: center;\">"
                    + "  <h1 style=\"margin: 0; font-size: 22px; font-weight: 700; letter-spacing: 0.5px;\">&#129463; SUNRISE DENTAL CLINIC</h1>"
                    + "  <p style=\"margin: 6px 0 0; font-size: 13px; color: #c7d2fe;\">Care with a Smile &bull; Official Appointment Confirmation</p>"
                    + "</div>"
                    + "<div style=\"padding: 28px 24px;\">"
                    + "  <h2 style=\"color: #1e293b; font-size: 18px; margin-top: 0;\">Dear " + escapeHtml(patientName) + ",</h2>"
                    + "  <p style=\"color: #475569; font-size: 14px; line-height: 1.6;\">Your dental appointment has been confirmed. Below are your scheduled appointment details:</p>"
                    + "  <table style=\"width: 100%; border-collapse: collapse; margin: 20px 0; font-size: 14px; border: 1px solid #e2e8f0; border-radius: 8px; overflow: hidden;\">"
                    + "    <tr style=\"background: #f8fafc; border-bottom: 1px solid #e2e8f0;\"><td style=\"padding: 12px 14px; font-weight: 600; width: 40%; color: #334155;\">Appointment No:</td><td style=\"padding: 12px 14px; color: #4338ca; font-weight: 700; font-size: 15px;\">" + escapeHtml(appointmentNo) + "</td></tr>"
                    + "    <tr style=\"border-bottom: 1px solid #e2e8f0;\"><td style=\"padding: 12px 14px; font-weight: 600; color: #334155;\">Attending Doctor:</td><td style=\"padding: 12px 14px; color: #0f172a; font-weight: 600;\">" + escapeHtml(dentistName) + "</td></tr>"
                    + "    <tr style=\"background: #f8fafc; border-bottom: 1px solid #e2e8f0;\"><td style=\"padding: 12px 14px; font-weight: 600; color: #334155;\">Treatment / Service:</td><td style=\"padding: 12px 14px; color: #0f172a;\">" + escapeHtml(treatmentName) + "</td></tr>"
                    + "    <tr style=\"border-bottom: 1px solid #e2e8f0;\"><td style=\"padding: 12px 14px; font-weight: 600; color: #334155;\">Appointment Date:</td><td style=\"padding: 12px 14px; color: #0f172a; font-weight: 600;\">" + escapeHtml(appointmentDate) + "</td></tr>"
                    + "    <tr style=\"background: #f8fafc;\"><td style=\"padding: 12px 14px; font-weight: 600; color: #334155;\">Scheduled Time:</td><td style=\"padding: 12px 14px; color: #059669; font-weight: 700;\">" + escapeHtml(appointmentTime) + "</td></tr>"
                    + "  </table>"
                    + "  <div style=\"background: #eff6ff; border-left: 4px solid #3b82f6; padding: 14px; border-radius: 6px; font-size: 13px; color: #1e40af; margin-top: 18px;\">"
                    + "    <strong>Important:</strong> Please arrive 10-15 minutes prior to your scheduled consultation time. If you need to reschedule or cancel, please contact the clinic at least 24 hours in advance."
                    + "  </div>"
                    + "  <div style=\"margin-top: 24px; padding-top: 16px; border-top: 1px solid #e2e8f0; font-size: 13px; color: #64748b; line-height: 1.5;\">"
                    + "    <strong style=\"color: #334155;\">Sunrise Dental Clinic</strong><br>"
                    + "    Address: 321, Union Place, Colombo 02<br>"
                    + "    Tel: 011 234 5678 | Email: info@sunrisedental.lk"
                    + "  </div>"
                    + "</div>"
                    + "<div style=\"background: #f8fafc; color: #94a3b8; text-align: center; padding: 14px; font-size: 12px; border-top: 1px solid #e2e8f0;\">"
                    + "  &copy; Sunrise Dental Clinic. All rights reserved."
                    + "</div>"
                    + "</div>";

                if (SMTP_USER != null && !SMTP_USER.trim().isEmpty() && SMTP_PASS != null && !SMTP_PASS.trim().isEmpty()) {
                    Properties props = new Properties();
                    props.put("mail.smtp.auth", "true");
                    props.put("mail.smtp.starttls.enable", "true");
                    props.put("mail.smtp.starttls.required", "true");
                    props.put("mail.smtp.ssl.protocols", "TLSv1.2 TLSv1.3");
                    props.put("mail.smtp.host", SMTP_HOST);
                    props.put("mail.smtp.port", SMTP_PORT);
                    props.put("mail.smtp.connectiontimeout", "10000");
                    props.put("mail.smtp.timeout", "10000");

                    Session session = Session.getInstance(props, new Authenticator() {
                        @Override
                        protected PasswordAuthentication getPasswordAuthentication() {
                            return new PasswordAuthentication(SMTP_USER.trim(), SMTP_PASS.replaceAll("\\s+", "").trim());
                        }
                    });

                    Message message = new MimeMessage(session);
                    message.setFrom(new InternetAddress(FROM_EMAIL.trim(), "Sunrise Dental Clinic"));
                    message.setRecipients(Message.RecipientType.TO, InternetAddress.parse(recipientEmail.trim()));
                    message.setSubject(subject);
                    message.setContent(htmlContent, "text/html; charset=utf-8");

                    Transport.send(message);
                    System.out.println("[EmailService] Live email successfully dispatched to " + recipientEmail);
                } else {
                    // Simulated / Console Delivery
                    System.out.println("=================================================");
                    System.out.println("[EmailService - SIMULATED DELIVERY]");
                    System.out.println("To: " + recipientEmail);
                    System.out.println("Subject: " + subject);
                    System.out.println("Appointment Code: " + appointmentNo);
                    System.out.println("Patient: " + patientName);
                    System.out.println("Doctor: " + dentistName + " | Date: " + appointmentDate + " | Time: " + appointmentTime);
                    System.out.println("Status: EMAIL READY (Configure SMTP credentials in EmailService.java for live sending)");
                    System.out.println("=================================================");
                }
            } catch (Exception e) {
                System.err.println("[EmailService] Error dispatching email to " + recipientEmail + ": " + e.getMessage());
            }
        });
    }

    private static String escapeHtml(String input) {
        if (input == null) return "";
        return input.replace("&", "&amp;")
                    .replace("<", "&lt;")
                    .replace(">", "&gt;")
                    .replace("\"", "&quot;");
    }
}
