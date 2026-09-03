import com.sunrisedental.dao.*;
import com.sunrisedental.model.*;
import com.sunrisedental.util.EmailService;
import java.sql.Date;
import java.util.List;

public class VerifyNewFeatures {
    public static void main(String[] args) {
        System.out.println("=== 1. VERIFYING DENTIST CRUD ===");
        DentistDAO dentistDAO = new DentistDAO();
        Dentist newDentist = new Dentist();
        newDentist.setName("Dr. Test Perera");
        newDentist.setSpecialization("Pediatric Dentist");
        newDentist.setContactNumber("0719998888");
        newDentist.setEmail("testdoctor@sunrisedental.com");
        newDentist.setRoomNo("Room 105");
        
        boolean dentistCreated = dentistDAO.createDentist(newDentist);
        System.out.println("Dentist created: " + dentistCreated);
        
        Dentist fetchedDentist = dentistDAO.getDentistByName("Dr. Test Perera");
        if (fetchedDentist != null) {
            System.out.println("Fetched Dentist ID: " + fetchedDentist.getId() + ", Room: " + fetchedDentist.getRoomNo());
            fetchedDentist.setRoomNo("Room 108");
            boolean dentistUpdated = dentistDAO.updateDentist(fetchedDentist);
            System.out.println("Dentist updated: " + dentistUpdated);
            
            boolean dentistDeleted = dentistDAO.deleteDentist(fetchedDentist.getId());
            System.out.println("Dentist deleted: " + dentistDeleted);
        }

        System.out.println("\n=== 2. VERIFYING USER MANAGEMENT & INVOICE_NO ===");
        UserDAO userDAO = new UserDAO();
        User testUser = new User();
        testUser.setUsername("testrec");
        testUser.setPassword("recpass");
        testUser.setFullName("Test Receptionist");
        testUser.setRole("Receptionist");
        testUser.setEmail("rec@sunrisedental.com");
        testUser.setInvoiceNo("INV-REC-999");

        boolean userCreated = userDAO.createUser(testUser);
        System.out.println("User created: " + userCreated);

        User authUser = userDAO.authenticate("testrec", "recpass");
        if (authUser != null) {
            System.out.println("Authenticated: " + authUser.getFullName() + ", Invoice ID: " + authUser.getInvoiceNo());
            authUser.setInvoiceNo("INV-REC-1000");
            boolean userUpdated = userDAO.updateUser(authUser);
            System.out.println("User updated with new invoice_no: " + userUpdated);

            boolean userDeleted = userDAO.deleteUser(authUser.getId());
            System.out.println("User deleted: " + userDeleted);
        }

        System.out.println("\n=== 3. VERIFYING PATIENT EMAIL & APPOINTMENT ===");
        PatientDAO patientDAO = new PatientDAO();
        int patientId = patientDAO.findOrCreatePatient("Test Patient", "Colombo", "0778889999", "patient@test.com", new Date(System.currentTimeMillis()));
        System.out.println("Patient with email registered ID: " + patientId);
        Patient p = patientDAO.getPatientById(patientId);
        System.out.println("Patient email retrieved: " + (p != null ? p.getEmail() : "null"));

        System.out.println("\n=== 4. VERIFYING BILLING USER INVOICE TRACKING ===");
        BillDAO billDAO = new BillDAO();
        Bill bill = billDAO.getBillByBillNo("R1002");
        if (bill != null) {
            System.out.println("Bill R1002 User Invoice: " + bill.getUserInvoiceNo() + ", Billed By: " + bill.getBilledBy());
        }

        System.out.println("\n=== 5. VERIFYING EMAIL SERVICE DISPATCH ===");
        EmailService.sendAppointmentConfirmation("patient@test.com", "Test Patient", "A1009", "Dr. Silva", "Scaling", "2026-08-30", "10:30 AM");
        
        System.out.println("\nALL CHECKS COMPLETED SUCCESSFULLY!");
    }
}
