/**
 * SUNRISE DENTAL CLINIC - CLIENT APPLICATION JAVASCRIPT
 */

document.addEventListener('DOMContentLoaded', () => {
    // 1. Password Visibility Toggle
    const togglePasswordBtn = document.getElementById('togglePassword');
    const passwordInput = document.getElementById('passwordInput');
    if (togglePasswordBtn && passwordInput) {
        togglePasswordBtn.addEventListener('click', () => {
            const isPassword = passwordInput.type === 'password';
            passwordInput.type = isPassword ? 'text' : 'password';
            togglePasswordBtn.textContent = isPassword ? '🙈' : '👁';
        });
    }

    // 2. Exit System Modal Handling
    const exitModal = document.getElementById('exitModal');
    const openExitModalBtns = document.querySelectorAll('.trigger-exit-modal');
    const closeExitModalBtns = document.querySelectorAll('.close-exit-modal');

    if (exitModal) {
        openExitModalBtns.forEach(btn => {
            btn.addEventListener('click', (e) => {
                e.preventDefault();
                exitModal.classList.add('active');
            });
        });

        closeExitModalBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                exitModal.classList.remove('active');
            });
        });

        exitModal.addEventListener('click', (e) => {
            if (e.target === exitModal) {
                exitModal.classList.remove('active');
            }
        });
    }

    // 3. Dynamic Billing Calculator (Screen 5)
    const consultationInput = document.getElementById('consultationFee');
    const treatmentInput = document.getElementById('treatmentFee');
    const materialInput = document.getElementById('materialFee');
    const discountInput = document.getElementById('discountAmount');
    const subTotalDisplay = document.getElementById('subTotalDisplay');
    const totalAmountDisplay = document.getElementById('totalAmountDisplay');

    function calculateBill() {
        if (!consultationInput || !treatmentInput || !materialInput || !discountInput) return;
        
        const consultation = parseFloat(consultationInput.value) || 0;
        const treatment = parseFloat(treatmentInput.value) || 0;
        const material = parseFloat(materialInput.value) || 0;
        const discount = parseFloat(discountInput.value) || 0;

        const subTotal = consultation + treatment + material;
        const grandTotal = Math.max(0, subTotal - discount);

        if (subTotalDisplay) {
            subTotalDisplay.textContent = subTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
        if (totalAmountDisplay) {
            totalAmountDisplay.textContent = 'Rs. ' + grandTotal.toLocaleString('en-US', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
        }
    }

    if (consultationInput && treatmentInput && materialInput && discountInput) {
        [consultationInput, treatmentInput, materialInput, discountInput].forEach(input => {
            input.addEventListener('input', calculateBill);
        });
        calculateBill();
    }

    // 4. Print Trigger
    const printReceiptBtn = document.getElementById('printReceiptBtn');
    if (printReceiptBtn) {
        printReceiptBtn.addEventListener('click', () => {
            window.print();
        });
    }

    // 5. Treatment Select Auto-fill cost (New Appointment Screen 3)
    const treatmentSelect = document.getElementById('treatmentSelect');
    const treatmentFeePreview = document.getElementById('treatmentFeePreview');
    if (treatmentSelect && treatmentFeePreview) {
        treatmentSelect.addEventListener('change', () => {
            const selectedOption = treatmentSelect.options[treatmentSelect.selectedIndex];
            const cost = selectedOption.getAttribute('data-cost');
            if (cost) {
                treatmentFeePreview.textContent = 'Rs. ' + parseFloat(cost).toLocaleString('en-US', { minimumFractionDigits: 2 });
            } else {
                treatmentFeePreview.textContent = '-';
            }
        });
    }

    // 6. Dentist Management Modals
    const addDentistModal = document.getElementById('addDentistModal');
    const openAddDentistBtn = document.getElementById('openAddDentistBtn');
    const closeDentistModalBtns = document.querySelectorAll('.close-dentist-modal');
    const editDentistModal = document.getElementById('editDentistModal');
    const editDentistBtns = document.querySelectorAll('.edit-dentist-btn');

    if (openAddDentistBtn && addDentistModal) {
        openAddDentistBtn.addEventListener('click', () => {
            addDentistModal.classList.add('active');
        });
    }

    closeDentistModalBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            if (addDentistModal) addDentistModal.classList.remove('active');
            if (editDentistModal) editDentistModal.classList.remove('active');
        });
    });

    if (editDentistModal && editDentistBtns) {
        editDentistBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const id = btn.getAttribute('data-id');
                const name = btn.getAttribute('data-name');
                const spec = btn.getAttribute('data-spec');
                const contact = btn.getAttribute('data-contact');
                const email = btn.getAttribute('data-email');
                const room = btn.getAttribute('data-room');

                document.getElementById('editDentistId').value = id;
                document.getElementById('editDentistName').value = name;
                document.getElementById('editDentistSpec').value = spec;
                document.getElementById('editDentistContact').value = contact;
                document.getElementById('editDentistEmail').value = email;
                document.getElementById('editDentistRoom').value = room;

                editDentistModal.classList.add('active');
            });
        });
    }

    // 7. User Management Modals (Admin Panel)
    const addUserModal = document.getElementById('addUserModal');
    const openAddUserBtn = document.getElementById('openAddUserBtn');
    const closeUserModalBtns = document.querySelectorAll('.close-user-modal');
    const editUserModal = document.getElementById('editUserModal');
    const editUserBtns = document.querySelectorAll('.edit-user-btn');

    if (openAddUserBtn && addUserModal) {
        openAddUserBtn.addEventListener('click', () => {
            addUserModal.classList.add('active');
        });
    }

    closeUserModalBtns.forEach(btn => {
        btn.addEventListener('click', () => {
            if (addUserModal) addUserModal.classList.remove('active');
            if (editUserModal) editUserModal.classList.remove('active');
        });
    });

    if (editUserModal && editUserBtns) {
        editUserBtns.forEach(btn => {
            btn.addEventListener('click', () => {
                const id = btn.getAttribute('data-id');
                const username = btn.getAttribute('data-username');
                const password = btn.getAttribute('data-password');
                const fullname = btn.getAttribute('data-fullname');
                const role = btn.getAttribute('data-role');
                const email = btn.getAttribute('data-email');
                const invoiceno = btn.getAttribute('data-invoiceno');

                document.getElementById('editUserId').value = id;
                document.getElementById('displayUserId').value = '#' + id;
                document.getElementById('editUserUsername').value = username;
                document.getElementById('editUserPassword').value = password;
                document.getElementById('editUserFullName').value = fullname;
                document.getElementById('editUserRole').value = role;
                document.getElementById('editUserEmail').value = email;
                document.getElementById('editUserInvoiceNo').value = invoiceno;

                editUserModal.classList.add('active');
            });
        });
    }
});
