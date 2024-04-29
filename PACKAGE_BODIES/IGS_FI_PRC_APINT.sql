--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_APINT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_APINT" AS
/* $Header: IGSFI78B.pls 120.4 2006/06/27 14:21:57 skharida noship $ */
  /****************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida     26-Jun-2006        Bug# 5208136 -Modified update_refund_rec,  removed the obsoleted columns
  ||                                  from igs_fi_refunds_pkg.update_row.
  ||  abshriva            12-MAY-2006  Bug 5217319 Amount precision change in create_ap_int_rec
  ||  agairola            20-Feb-2006     Bug 5046245: Commenting out of the Vendor API
  ||  shtatiko        30-APR-2003     Enh# 2831569, Modified validate_parameters
  *****************************************************************/

  g_v_other               CONSTANT VARCHAR2(10) := 'OTHER';
  g_v_item                CONSTANT VARCHAR2(10) := 'ITEM';
  g_v_vendor_type         CONSTANT VARCHAR2(20) := 'VENDOR TYPE';
  g_v_pay_group           CONSTANT VARCHAR2(20) := 'PAY GROUP';
  g_v_stdnt_system        CONSTANT VARCHAR2(30) := 'STUDENT SYSTEM';
  g_v_automatic           CONSTANT VARCHAR2(10) := 'AUTOMATIC';
  g_v_credit              CONSTANT VARCHAR2(10) := 'CREDIT';
  g_v_standard            CONSTANT VARCHAR2(10) := 'STANDARD';
  g_v_todo                CONSTANT VARCHAR2(30) := 'TODO';
  g_v_offset              CONSTANT VARCHAR2(30) := 'OFFSET';
  g_v_transferred         CONSTANT VARCHAR2(30) := 'TRANSFERRED';
  g_v_ind_a               CONSTANT VARCHAR2(5)  := 'A';
  g_v_pay_to              CONSTANT VARCHAR2(10)  := 'PAY_TO';

  g_v_lbl_error           igs_lookup_values.meaning%TYPE;
  g_v_lbl_person_group    igs_lookup_values.meaning%TYPE;
  g_v_lbl_create_suppl    igs_lookup_values.meaning%TYPE;
  g_v_lbl_suppl_type      igs_lookup_values.meaning%TYPE;
  g_v_lbl_pay_grp         igs_lookup_values.meaning%TYPE;
  g_v_lbl_inv_term        igs_lookup_values.meaning%TYPE;
  g_v_lbl_test_run        igs_lookup_values.meaning%TYPE;
  g_v_lbl_party           igs_lookup_values.meaning%TYPE;
  g_v_lbl_pay             igs_lookup_values.meaning%TYPE;
  g_v_lbl_vchr            igs_lookup_values.meaning%TYPE;
  g_v_lbl_status          igs_lookup_values.meaning%TYPE;
  g_v_lbl_todo            igs_lookup_values.meaning%TYPE;
  g_v_lbl_offset          igs_lookup_values.meaning%TYPE;
  g_v_lbl_transferred     igs_lookup_values.meaning%TYPE;
  g_n_org_id              igs_fi_control.ap_org_id%TYPE;
  g_v_cur_code            igs_fi_control.currency_cd%TYPE;
  g_v_sup_num             po_vendors.segment1%TYPE;
  g_v_sup_name            po_vendors.vendor_name%TYPE;
  g_v_pay_rfnd_vchr       igs_lookup_values.lookup_code%TYPE;
  g_v_dflt_sup_site       igs_fi_control.dflt_supplier_site_name%TYPE;
  g_v_supplier_type       po_vendors.vendor_type_lookup_code%TYPE;
  g_v_ven_num_code        financials_system_params_all.user_defined_vendor_num_code%TYPE;
  g_v_create_supplier     VARCHAR2(1);
  g_b_data_found          BOOLEAN;

  e_resource_busy         EXCEPTION;
  PRAGMA                  exception_init(e_resource_busy,-0054);

  CURSOR c_refunds IS
    SELECT rfnd.rowid, rfnd.*
    FROM igs_fi_refunds rfnd;

  TYPE r_party_rel_rec IS RECORD (p_n_party_id         hz_parties.party_id%TYPE,
                                  p_n_vendor_id        igs_fi_party_vendrs.vendor_id%TYPE,
                                  p_n_vendor_site_id   igs_fi_party_vendrs.vendor_site_id%TYPE);

  TYPE t_party_rel IS TABLE OF r_party_rel_rec INDEX BY BINARY_INTEGER;

  t_party_vendors    t_party_rel;
  t_party_dummy      t_party_rel;

PROCEDURE log_transaction(p_n_party_id      PLS_INTEGER,
                          p_n_payee_id      PLS_INTEGER,
			  p_n_refund_id     PLS_INTEGER) AS
  /********************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for logging the transaction data
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  *********************************************************/
  CURSOR c_party(cp_n_party_id     hz_parties.party_id%TYPE) IS
    SELECT party_number
    FROM   hz_parties
    WHERE  party_id = cp_n_party_id;

  l_n_party_num     hz_parties.party_number%TYPE;

  l_v_status        igs_lookup_values.meaning%TYPE;

BEGIN
  l_n_party_num := NULL;
  OPEN c_party(p_n_party_id);
  FETCH c_party INTO l_n_party_num;
  CLOSE c_party;

  fnd_file.new_line(fnd_file.log);

  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_party||' : '||l_n_party_num);

  l_n_party_num := NULL;
  OPEN c_party(p_n_payee_id);
  FETCH c_party INTO l_n_party_num;
  CLOSE c_party;

  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_pay||' : '||l_n_party_num);
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_vchr||' : '||p_n_refund_id);

END log_transaction;

PROCEDURE update_refund_rec(p_r_rfnd_rec    c_refunds%ROWTYPE) AS
  /****************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Updates the Refund transaction status
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  skharida    26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_REFUNDS
  ||  (reverse chronological order - newest change first)
  *****************************************************************/
BEGIN
  igs_fi_refunds_pkg.update_row(x_rowid                  => p_r_rfnd_rec.rowid,
                                x_refund_id              => p_r_rfnd_rec.refund_id,
                                x_voucher_date           => p_r_rfnd_rec.voucher_date,
                                x_person_id              => p_r_rfnd_rec.person_id,
				x_pay_person_id          => p_r_rfnd_rec.pay_person_id,
				x_dr_gl_ccid             => p_r_rfnd_rec.dr_gl_ccid,
				x_cr_gl_ccid             => p_r_rfnd_rec.cr_gl_ccid,
				x_dr_account_cd          => p_r_rfnd_rec.dr_account_cd,
				x_cr_account_cd          => p_r_rfnd_rec.cr_account_cd,
				x_refund_amount          => p_r_rfnd_rec.refund_amount,
				x_fee_type               => p_r_rfnd_rec.fee_type,
				x_fee_cal_type           => p_r_rfnd_rec.fee_cal_type,
				x_fee_ci_sequence_number => p_r_rfnd_rec.fee_ci_sequence_number,
				x_source_refund_id       => p_r_rfnd_rec.source_refund_id,
				x_invoice_id             => p_r_rfnd_rec.invoice_id,
				x_transfer_status        => p_r_rfnd_rec.transfer_status,
				x_reversal_ind           => p_r_rfnd_rec.reversal_ind,
				x_reason                 => p_r_rfnd_rec.reason,
				x_attribute_category     => p_r_rfnd_rec.attribute_category,
				x_attribute1             => p_r_rfnd_rec.attribute1,
				x_attribute2             => p_r_rfnd_rec.attribute2,
				x_attribute3             => p_r_rfnd_rec.attribute3,
				x_attribute4             => p_r_rfnd_rec.attribute4,
				x_attribute5             => p_r_rfnd_rec.attribute5,
				x_attribute6             => p_r_rfnd_rec.attribute6,
				x_attribute7             => p_r_rfnd_rec.attribute7,
				x_attribute8             => p_r_rfnd_rec.attribute8,
				x_attribute9             => p_r_rfnd_rec.attribute9,
				x_attribute10            => p_r_rfnd_rec.attribute10,
				x_attribute11            => p_r_rfnd_rec.attribute11,
				x_attribute12            => p_r_rfnd_rec.attribute12,
				x_attribute13            => p_r_rfnd_rec.attribute13,
				x_attribute14            => p_r_rfnd_rec.attribute14,
				x_attribute15            => p_r_rfnd_rec.attribute15,
				x_attribute16            => p_r_rfnd_rec.attribute16,
				x_attribute17            => p_r_rfnd_rec.attribute17,
				x_attribute18            => p_r_rfnd_rec.attribute18,
				x_attribute19            => p_r_rfnd_rec.attribute19,
				x_attribute20            => p_r_rfnd_rec.attribute20,
				x_gl_date                => p_r_rfnd_rec.gl_date,
				x_reversal_gl_date       => p_r_rfnd_rec.reversal_gl_date);
END update_refund_rec;

PROCEDURE initialize AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for initializing the global variables
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  agairola        11-Mar-2003     Bug 2838757: Initialized g_b_data_found
  ||                                  to false
  ||  (reverse chronological order - newest change first)
  ******************************************************************/
  CURSOR c_lkp(cp_lookup_type      ap_lookup_codes.lookup_type%TYPE,
               cp_lookup_code      ap_lookup_codes.lookup_code%TYPE) IS
    SELECT displayed_field
    FROM   ap_lookup_codes
    WHERE  lookup_type = cp_lookup_type
    AND    lookup_code = cp_lookup_code;
BEGIN

 -- Initialize all the constant lables/translatable text for the process
  g_v_lbl_party := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                'PARTY');
  g_v_lbl_person_group := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'PERSON_GROUP');
  g_v_lbl_create_suppl := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'CREATE_SUPPLIER');
  g_v_lbl_suppl_type := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                      'SUPPLIER_TYPE');
  g_v_lbl_pay_grp := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                  'INV_PAY_GROUP');
  g_v_lbl_inv_term := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                    'INV_PAY_TERM');
  g_v_lbl_test_run := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                'TEST_RUN');
  g_v_lbl_pay   := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                'PAYEE_PARTY_NUMBER');
  g_v_lbl_vchr  := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                'REFUND_ID');
  g_v_lbl_status := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                'STATUS');
  g_v_lbl_todo := igs_fi_gen_gl.get_lkp_meaning('REFUND_TRANSFER_STATUS',
                                                 g_v_todo);
  g_v_lbl_offset := igs_fi_gen_gl.get_lkp_meaning('REFUND_TRANSFER_STATUS',
                                                  g_v_offset);
  g_v_lbl_transferred := igs_fi_gen_gl.get_lkp_meaning('REFUND_TRANSFER_STATUS',
                                                        g_v_transferred);

  g_v_lbl_error := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','ERROR');

  g_b_data_found := FALSE;

  t_party_vendors := t_party_dummy;
END initialize;

PROCEDURE get_payto_add(p_n_party_id       PLS_INTEGER,
                        p_v_party_number   VARCHAR2,
                        p_n_location_id    OUT NOCOPY PLS_INTEGER,
                        p_b_status         OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for determining the pay to address
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmaheswa       19-nov-2003    Bug 3227107 address changes. Modified cursor c_hz_site to select dates
  ||                                from igs_pe_hz_pty_sites instead of hz_party_sites.
  ||  (reverse chronological order - newest change first)
  ******************************************************************/

-- Cursor for selecting an Active Pay to Usage address for a party
  CURSOR c_hz_site(cp_n_party_id          hz_parties.party_id%TYPE) IS
    SELECT ps.location_id
    FROM   hz_party_sites ps,
           hz_party_site_uses psu,
	   igs_pe_hz_pty_sites ips
    WHERE  ps.party_site_id = ips.party_site_id(+)
    AND    ps.party_id = cp_n_party_id
    AND   (ps.status = g_v_ind_a AND
          (SYSDATE BETWEEN NVL(ips.start_date,SYSDATE) AND NVL(ips.end_date,SYSDATE)) )
    AND    psu.party_site_id = ps.party_site_id
    AND    psu.site_use_type = g_v_pay_to
    AND    psu.status = g_v_ind_a;

  l_n_hz_cntr      NUMBER := 0;
BEGIN
  l_n_hz_cntr := 0;

-- Loop across all the active Pay To usage address for the
-- party
  FOR l_c_hz_site IN c_hz_site(p_n_party_id) LOOP
    p_n_location_id := l_c_hz_site.location_id;
    l_n_hz_cntr := l_n_hz_cntr + 1;
  END LOOP;

-- If there are no active pay to usage addresses for the
-- party, then a supplier site cannot be created and hence is an error
-- condition
  IF l_n_hz_cntr = 0 THEN
    fnd_file.put_line(fnd_file.log,
                      g_v_lbl_status||' : '||g_v_lbl_todo);
    fnd_message.set_name('IGS','IGS_FI_HZ_NO_PAY_ADD');
    fnd_message.set_token('PAYEE_NUM',p_v_party_number);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
    p_b_status := FALSE;
    RETURN;
  END IF;

-- If there are more than one active pay to usage addresses for the
-- party, then a supplier site cannot be created and hence is an error
-- condition
  IF l_n_hz_cntr > 1 THEN
    fnd_file.put_line(fnd_file.log,
                      g_v_lbl_status||' : '||g_v_lbl_todo);
    fnd_message.set_name('IGS','IGS_FI_HZ_UNQ_PAY_ADD');
    fnd_message.set_token('PAYEE_NUM',p_v_party_number);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
    p_b_status := FALSE;
    RETURN;
  END IF;

-- Return True
  p_b_status := TRUE;
END get_payto_add;

FUNCTION  validate_parameters(p_n_party_id          IN  NUMBER,
                              p_n_person_group_id   IN  NUMBER,
                              p_v_create_supplier   IN  VARCHAR2,
                              p_v_supplier_type     IN  VARCHAR2,
                              p_v_inv_pay_group     IN  VARCHAR2,
                              p_n_inv_pay_term      IN  NUMBER,
                              p_v_test_run          IN  VARCHAR2) RETURN BOOLEAN AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for validating the input parameters are the conditions for the process to
  ||            run
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  shtatiko        30-APR-2003     Enh# 2831569, Added check for Manage Accounts System Option.
  ||                                  If its value is NULL or OTHER then log the message and return
  ||                                  back without executing other validations.
  ******************************************************************/

-- Cursor for fetching the Org Id and the default
-- supplier site name
  CURSOR c_ctrl IS
    SELECT ap_org_id, dflt_supplier_site_name
    FROM   igs_fi_control;

-- Cursor for selecting the party number from hz_parties
-- for a party id
  CURSOR c_party(cp_n_party_id    hz_parties.party_id%TYPE) IS
    SELECT party_number
    FROM hz_parties
    WHERE party_id = cp_n_party_id;

  l_c_party   c_party%ROWTYPE;

-- Cursor for validating the Person Group
  CURSOR c_pers_id_grp(cp_n_pers_grp_id   igs_pe_all_persid_group_v.group_id%TYPE) IS
    SELECT group_cd, closed_ind
    FROM igs_pe_all_persid_group_v
    WHERE group_id = cp_n_pers_grp_id;

  l_c_pers_id_grp   c_pers_id_grp%ROWTYPE;

-- Cursor for validating a valid lookup code for a lookup type in PO Lookups
  CURSOR c_po_lkp(cp_v_lookup_type       igs_lookup_values.lookup_type%TYPE,
                  cp_v_lookup_code       igs_lookup_values.lookup_code%TYPE) IS
    SELECT displayed_field meaning, inactive_date
    FROM po_lookup_codes
    WHERE lookup_type = cp_v_lookup_type
    AND   lookup_code = cp_v_lookup_code;

-- Cursor foe selecting the User Defined Vendor Numbering Code
-- from Financials System Parameters all
  CURSOR c_fsp IS
    SELECT user_defined_vendor_num_code
    FROM   financials_system_params_all
    WHERE  ((org_id = g_n_org_id) OR (org_id IS NULL AND g_n_org_id IS NULL));

  l_c_sup_type   c_po_lkp%ROWTYPE;
  l_c_grp_type   c_po_lkp%ROWTYPE;

-- Cursor for selecting the data from AP terms for the input parameter
  CURSOR c_ap_term(cp_n_term_id        ap_terms.term_id%TYPE) IS
    SELECT name,
           start_date_active,
           end_date_active
    FROM   ap_terms
    WHERE  term_id = cp_n_term_id;

-- Cursor for selecting the multi org flag from the FND_PRODUCT_GROUPS
  CURSOR c_fnd_prod IS
    SELECT multi_org_flag
    FROM   fnd_product_groups;

  l_v_rfnd_destination      igs_fi_control.rfnd_destination%TYPE;
  l_c_ap_term               c_ap_term%ROWTYPE;
  l_c_fnd_prod              c_fnd_prod%ROWTYPE;
  l_v_curr_desc             igs_fi_control_v.name%TYPE;
  l_v_message_name          fnd_new_messages.message_name%TYPE;
  l_b_term_flag             BOOLEAN := TRUE;
  l_b_party_flag            BOOLEAN := TRUE;
  l_b_pers_grp_flag         BOOLEAN := TRUE;
  l_b_sup_type_flag         BOOLEAN := TRUE;
  l_b_inv_pay_grp_flag      BOOLEAN := TRUE;
  l_b_inv_pay_term_flag     BOOLEAN := TRUE;
  l_b_val_parm              BOOLEAN := TRUE;
  l_v_manage_accounts       igs_fi_control_all.manage_accounts%TYPE;
  l_b_run_process           BOOLEAN := TRUE;

BEGIN

  -- Get the value of "Manage Accounts" System Option value.
  -- If this value is NULL or OTHER then this process should error out.
  igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                p_v_message_name => l_v_message_name );
  IF l_v_manage_accounts IS NULL OR l_v_manage_accounts = 'OTHER' THEN
    fnd_message.set_name ( 'IGS', l_v_message_name );
    -- mark that process shouldn't run anymore.
    l_b_run_process := FALSE;
  END IF;

  -- Fetch the details from AP terms for the term id passed as input
  -- Incase no data is found, then this is an error condition
  OPEN c_ap_term(p_n_inv_pay_term);
  FETCH c_ap_term INTO l_c_ap_term;
  IF c_ap_term%NOTFOUND THEN
    l_b_term_flag := FALSE;
  END IF;
  CLOSE c_ap_term;

  -- validate if the party exists.
  IF p_n_party_id IS NOT NULL THEN
    OPEN c_party(p_n_party_id);
    FETCH c_party INTO l_c_party;
    IF c_party%NOTFOUND THEN
      l_b_party_flag := FALSE;
    END IF;
    CLOSE c_party;
  END IF;

  -- validate if the person group if passed is
  -- a valid person group
  IF p_n_person_group_id IS NOT NULL THEN
    OPEN c_pers_id_grp(p_n_person_group_id);
    FETCH c_pers_id_grp INTO l_c_pers_id_grp;
    IF c_pers_id_grp%NOTFOUND THEN
      l_b_pers_grp_flag := FALSE;
    END IF;
    CLOSE c_pers_id_grp;
  END IF;

  -- Validate if the supplier type is a valid
  -- supplier type
  IF p_v_supplier_type IS NOT NULL THEN
    OPEN c_po_lkp(g_v_vendor_type,
                  p_v_supplier_type);
    FETCH c_po_lkp INTO l_c_sup_type;
    IF c_po_lkp%NOTFOUND THEN
      l_b_sup_type_flag := FALSE;
    END IF;
    CLOSE c_po_lkp;
  END IF;

  -- Validate if the Invoice Pay Group is a valid
  -- Invoice Pay group in AP
  IF p_v_inv_pay_group IS NOT NULL THEN
    OPEN c_po_lkp(g_v_pay_group,
                  p_v_inv_pay_group);
    FETCH c_po_lkp INTO l_c_grp_type;
    IF c_po_lkp%NOTFOUND THEN
      l_b_inv_pay_grp_flag := FALSE;
    END IF;
    CLOSE c_po_lkp;
  END IF;

  -- Logging the parameters
  fnd_file.put_line(fnd_file.log,
                    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PROCESS_PARM'));
  fnd_file.put_line(fnd_file.log,
                    RPAD('-',80,'-'));
  fnd_file.new_line(fnd_file.log);

  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_party||' : '||NVL(l_c_party.party_number, p_n_party_id));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_person_group||' : '||NVL(l_c_pers_id_grp.group_cd, p_n_person_group_id));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_create_suppl||' : '||NVL(igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_v_create_supplier),p_v_create_supplier));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_suppl_type||' : '||NVL(l_c_sup_type.meaning,p_v_supplier_type));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_pay_grp||' : '||NVL(l_c_grp_type.meaning,g_v_lbl_pay_grp));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_inv_term||' : '||NVL(l_c_ap_term.name,p_n_inv_pay_term));
  fnd_file.put_line(fnd_file.log,
                    g_v_lbl_test_run||' : '||NVL(igs_fi_gen_gl.get_lkp_meaning('YES_NO', p_v_test_run),p_v_test_run));

  fnd_file.new_line(fnd_file.log);

  -- If Manage Accounts validation fails then log the message and return false
  IF NOT l_b_run_process THEN
    fnd_file.put_line ( fnd_file.LOG, fnd_message.get );
    RETURN FALSE;
  END IF;

  -- get the refund destination
  l_v_rfnd_destination := igs_fi_gen_apint.get_rfnd_destination;

  -- If the Refund Destination is OTHER or is NULL then log the error message
  IF l_v_rfnd_destination = g_v_other OR l_v_rfnd_destination IS NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS',
                         'IGS_FI_RFND_DST_PAY');
    fnd_file.put_line(fnd_file.log,
	                  fnd_message.get);
    l_b_val_parm := FALSE;
    RETURN l_b_val_parm;
  END IF;

-- Fetch the Payables Org Id and the default supplier Site Name
  OPEN c_ctrl;
  FETCH c_ctrl INTO g_n_org_id, g_v_dflt_sup_site;
  IF c_ctrl%NOTFOUND THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS',
                         'IGS_FI_SYSTEM_OPT_SETUP');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;
  CLOSE c_ctrl;

-- If the payables operating unit is not set up, then check if the
-- application is Multi-Org enabled. If the application is Multi-Org
-- enabled and the Payables Operating Unit is not setup, then the
-- error should be logged in the log file.
  IF g_n_org_id IS NULL THEN
    OPEN c_fnd_prod;
    FETCH c_fnd_prod INTO l_c_fnd_prod;
    CLOSE c_fnd_prod;

    IF l_c_fnd_prod.multi_org_flag = 'Y' THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_AP_ORG_ID_NOTSETUP');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
  END IF;

-- Set the Org Id
  igs_ge_gen_003.set_org_id(g_n_org_id);

-- If the create supplier parameter is Null or the test run parameter is null or
-- Invoice Payment Term parameter is NULL, then log an error message in the log file
  IF p_v_create_supplier IS NULL OR p_v_test_run IS NULL OR p_n_inv_pay_term IS NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS',
                         'IGS_FI_PARAMETER_NULL');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- If the Supplier Type parameter is not null but the create supplier parameter
-- has value as N, then error message should be logged.
  IF p_v_supplier_type IS NOT NULL and p_v_create_supplier = 'N' THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS',
                         'IGS_FI_INV_SUP_TYPE');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- If party validation has failed earlier
  IF NOT l_b_party_flag THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_party);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- If the person group validation has failed earlier or the person group
-- is closed, then error message is logged
  IF NOT l_b_pers_grp_flag OR NVL(l_c_pers_id_grp.closed_ind,'N') = 'Y' THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_person_group);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- If the Supplier Type validation has failed earlier or the inactive date of the
-- supplier type is less than System Date, then error message is logged
  IF (NOT l_b_sup_type_flag) OR NOT (TRUNC(NVL(l_c_sup_type.inactive_date,sysdate)) >= TRUNC(sysdate)) THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_suppl_type);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- The Invoice Pay group parameter validation has failed earlier or the inactive date of the
-- Invoice Pay group is less than the current date, then error message is logged
  IF (NOT l_b_inv_pay_grp_flag) OR NOT (TRUNC(NVL(l_c_grp_type.inactive_date,sysdate)) >= TRUNC(sysdate)) THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_pay_grp);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- If the Term Id passed as input parameter does not exist
  IF NOT l_b_term_flag THEN
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_pay_grp);
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  END IF;

-- If the sysdate is not within the Start date active and end date active
-- of the Term passed as input, log an error message in the log file
  IF NOT (TRUNC(sysdate) BETWEEN TRUNC(NVL(l_c_ap_term.start_date_active, sysdate)) AND
          TRUNC(NVL(l_c_ap_term.end_date_active, sysdate))) THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_AP_TERM_INACTIVE');
    fnd_message.set_token('TERM_NAME',l_c_ap_term.name);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- If the create supplier parameter is not in Y/N, then log the
-- error message in the log file
  IF p_v_create_supplier NOT IN ('Y','N') THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_create_suppl);
    fnd_file.put_line(fnd_file.log,
                     fnd_message.get);
  END IF;

-- If the test run parameter is not in Y/N, then log the
-- error message in the log file
  IF p_v_test_run NOT IN ('Y','N') THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_INVALID_PARAMETER');
    fnd_message.set_token('PARAMETER',g_v_lbl_test_run);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- call the procedure for getting the currency code
  igs_fi_gen_gl.finp_get_cur(g_v_cur_code,
                             l_v_curr_desc,
                             l_v_message_name);

-- If the currency code is not null, then log the
-- error message in the log file
  IF g_v_cur_code IS NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS',l_v_message_name);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- Get the value of the Supplier Number parameter
  g_v_sup_num := fnd_profile.value('IGS_FI_SUPPLIER_NUMBER');

-- Get the value of the User Defined Vendor Numbering Code
-- from Financial System params all
  OPEN c_fsp;
  FETCH c_fsp INTO g_v_ven_num_code;
  CLOSE c_fsp;

-- If the value of the profile for Supplier Number is null, then check
-- if the value for the Vendor Number Code in AP is set to other than
-- Automatic. If yes, then log error message in the log file.
  IF g_v_sup_num IS NULL THEN
    IF NVL(g_v_ven_num_code,g_v_automatic) <> g_v_automatic THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS','IGS_FI_PROFL_SUP_NUM_NOT_SET');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
  END IF;

-- Get the value of the Supplier Name profile.
  g_v_sup_name := fnd_profile.value('IGS_FI_SUPPLIER_NAME');

-- If the profile value for the supplier name is not set up
-- then log the error message in the log file.
  IF g_v_sup_name IS NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_PROFL_SUP_NAME_NOT_SET');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- Get the value of the profile 'Student Finance Pay Voucher Alone'
  g_v_pay_rfnd_vchr := fnd_profile.value('IGS_FI_PAY_RFND_VOUCHER');

-- If the value of the profile is not set up, then log error message
-- in the log file
  IF g_v_pay_rfnd_vchr IS NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_PROFL_PAY_RFND_NOT_SET');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- If the Party Id and the Person Group both are passed as input to
-- the process, then log error message
  IF p_n_party_id IS NOT NULL AND p_n_person_group_id IS NOT NULL THEN
    l_b_val_parm := FALSE;
    fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

-- If any of the validations has failed, then RETURN False
  IF l_b_term_flag AND l_b_party_flag AND l_b_pers_grp_flag AND
     l_b_sup_type_flag AND l_b_inv_pay_grp_flag AND l_b_inv_pay_term_flag AND
     l_b_val_parm THEN
    RETURN TRUE;
  ELSE
    RETURN FALSE;
  END IF;

END validate_parameters;

FUNCTION derive_vendor_name(p_v_party_name       VARCHAR2,
                            p_v_party_type       VARCHAR2,
                            p_v_first_name       VARCHAR2,
                            p_v_last_name        VARCHAR2) RETURN VARCHAR2 AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for deriving the supplier name
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************/
  l_v_supplier_name      po_vendors.vendor_name%TYPE;
BEGIN

-- If the party type of the party is Organization or
-- if the party type is person and the profile value is set to First Name, Last Name
-- derive the supplier name from party name
  IF ((p_v_party_type = 'ORGANIZATION') OR (p_v_party_type = 'PERSON' AND g_v_sup_name = 'FIRST_LAST'))THEN
    l_v_supplier_name :=  p_v_party_name;
  ELSIF (p_v_party_type = 'PERSON' AND g_v_sup_name = 'LAST_FIRST') THEN

-- Else if the profile is set to Last Name, First Name, then derive
-- the supplier name by appending the first name to the last name
    IF g_v_sup_name = 'LAST_FIRST' THEN
      l_v_supplier_name := p_v_last_name||' '||p_v_first_name;
    END IF;
  END IF;

  RETURN l_v_supplier_name;
END derive_vendor_name;

PROCEDURE derive_vendor_num(p_n_party_id       PLS_INTEGER,
                            p_v_party_number   VARCHAR2,
                            p_v_sup_num    OUT NOCOPY po_vendors.segment1%TYPE,
                            p_b_status     OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for deriving the supplier number
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ******************************************************************/

-- cursor for fetching the alternate person id from igs_pe_alt_pers_id
  CURSOR c_api_pers(cp_n_party_id          hz_parties.party_id%TYPE,
                    cp_v_pers_id_type      igs_pe_alt_pers_id.person_id_type%TYPE) IS
    SELECT api_person_id
    FROM   igs_pe_alt_pers_id
    WHERE  pe_person_id = cp_n_party_id
    AND    person_id_type = g_v_sup_num
    AND    sysdate BETWEEN start_dt AND NVL(end_dt,sysdate);

  l_v_sup_num         po_vendors.segment1%TYPE;
  l_v_api_person_id   igs_pe_alt_pers_id.api_person_id%TYPE;

BEGIN
  p_b_status := TRUE;

-- If the User Defined Vendor Code is not automatic in Financial
-- System parameters, then
  IF NVL(g_v_ven_num_code,g_v_automatic) <> g_v_automatic THEN

-- Validate if the value of the profile is PARTY. If the value
-- is party, then the party number is the vendor number
    IF g_v_sup_num = 'PARTY' THEN
      l_v_sup_num := p_v_party_number;
    ELSE

-- Else, derive the vendor number from the Alternate Person Id
      OPEN c_api_pers(p_n_party_id,
                      p_v_party_number);
      FETCH c_api_pers INTO l_v_api_person_id;
      IF c_api_pers%NOTFOUND THEN
        p_b_status := FALSE;
      ELSE
        l_v_sup_num := l_v_api_person_id;
      END IF;
      CLOSE c_api_pers;
    END IF;
  ELSE
    l_v_sup_num := NULL;
  END IF;

  p_v_sup_num := l_v_sup_num;
END derive_vendor_num;

PROCEDURE create_supplier(p_n_party_id       PLS_INTEGER,
                          p_n_vendor_id      OUT NOCOPY PLS_INTEGER,
                          p_n_vendor_site_id OUT NOCOPY PLS_INTEGER,
                          p_b_status         OUT NOCOPY BOOLEAN) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for creating the supplier and the supplier site
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  agairola        10-Mar-2003     Bug# 2838892: Initialized the local
  ||                                  variables for the Vendor and vendor site
  ||                                  id
  ||  (reverse chronological order - newest change first)
  agairola            20-Feb-2006     Bug 5046245: Commenting out of the Vendor API
  ******************************************************************/
  CURSOR c_prty_rel(cp_n_party_id         hz_parties.party_id%TYPE) IS
    SELECT a.rowid, a.*
    FROM igs_fi_party_vendrs a
    WHERE a.party_id = cp_n_party_id;

  CURSOR c_po_active(cp_n_vendor_id       igs_fi_party_vendrs.vendor_id%TYPE) IS
    SELECT 'x'
    FROM po_vendors
    WHERE vendor_id = cp_n_vendor_id
    AND   TRUNC(SYSDATE) <= TRUNC(NVL(END_DATE_ACTIVE,sysdate));

  CURSOR c_vendor_sites(cp_vendor_site_id      igs_fi_party_vendrs.vendor_site_id%TYPE) IS
    SELECT 'x'
    FROM   po_vendor_sites_all po
    WHERE  ((po.org_id = g_n_org_id) OR (po.org_id IS NULL AND g_n_org_id IS NULL))
    AND    po.vendor_site_id = cp_vendor_site_id
    AND    TRUNC(SYSDATE) <= TRUNC(NVL(po.inactive_date, sysdate));

  CURSOR c_hz_party(cp_n_party_id       hz_parties.party_id%TYPE) IS
    SELECT party_type,
           party_number,
           party_name,
 	   person_first_name,
	   person_last_name
    FROM   hz_parties
    WHERE  party_id = cp_n_party_id;

  CURSOR c_hz_loc_addr(cp_n_location_id         hz_locations.location_id%TYPE) IS
    SELECT substr (address1,1,35) address1,
           substr (address2,1,35) address2,
           substr (address3,1,35) address3,
           substr (address4,1,35) address4,
           substr (city,1,25) city,
           substr (state,1,25) state,
           substr (postal_code,1,20) postal_code,
           substr (province,1,25) province,
           substr (county,1,25) county,
           substr (country,1,25) country
    FROM   hz_locations
    WHERE  location_id = cp_n_location_id;

  l_c_hz_party         c_hz_party%ROWTYPE;
  l_c_prty_rel         c_prty_rel%ROWTYPE;
  l_b_prty_rel         BOOLEAN := TRUE;
  l_c_hz_loc_addr      c_hz_loc_addr%ROWTYPE;

  l_v_var              VARCHAR2(1);
  l_n_location_id      hz_locations.location_id%TYPE;

  l_b_addr_stat        BOOLEAN := TRUE;
  l_b_vendor_site      BOOLEAN := TRUE;
  l_b_status           BOOLEAN := TRUE;
  l_v_msg              VARCHAR2(2000);
  l_n_vendor_id        igs_fi_party_vendrs.vendor_id%TYPE;
  l_n_vendor_site_id   igs_fi_party_vendrs.vendor_id%TYPE;
  l_v_vendor_name      po_vendors.vendor_name%TYPE;
  l_v_sup_num          po_vendors.segment1%TYPE;
  l_v_site_status      VARCHAR2(100);
  l_v_vendor_status    VARCHAR2(100);

  l_v_rowid            VARCHAR2(50);

  l_n_cntr             NUMBER(10);

BEGIN
  p_b_status := TRUE;

  l_n_cntr:= null;

  IF t_party_vendors.COUNT > 0 THEN
    FOR l_n_cntr IN t_party_vendors.FIRST..t_party_vendors.LAST LOOP
      IF t_party_vendors.EXISTS(l_n_cntr) THEN
        IF t_party_vendors(l_n_cntr).p_n_party_id = p_n_party_id THEN
          p_n_vendor_id := t_party_vendors(l_n_cntr).p_n_vendor_id;
          p_n_vendor_site_id := t_party_vendors(l_n_cntr).p_n_vendor_site_id;
          p_b_status := TRUE;
          RETURN;
        END IF;
      END IF;
    END LOOP;
  END IF;

-- Get the party details from the hz_parties
  OPEN c_hz_party(p_n_party_id);
  FETCH c_hz_party INTO l_c_hz_party;
  CLOSE c_hz_party;

-- Get the party relationships from the Supplier Relationship
-- table
  OPEN c_prty_rel(p_n_party_id);
  FETCH c_prty_rel INTO l_c_prty_rel;
  IF c_prty_rel%FOUND THEN
    l_b_prty_rel := TRUE;
  ELSE
    l_b_prty_rel := FALSE;
  END IF;
  CLOSE c_prty_rel;

-- If the party relationship exists, then
  IF l_b_prty_rel THEN

    l_n_vendor_id := l_c_prty_rel.vendor_id;
    l_n_vendor_site_id := l_c_prty_rel.vendor_site_id;

-- Validate if the vendor is active in AP
-- If the vendor is not active in AP, then log error and return false
    OPEN c_po_active(l_c_prty_rel.vendor_id);
    FETCH c_po_active INTO l_v_var;
    IF c_po_active%NOTFOUND THEN
      p_b_status := FALSE;
      fnd_file.put_line(fnd_file.log,
                        g_v_lbl_status||' : '||g_v_lbl_todo);
      fnd_message.set_name('IGS','IGS_FI_SUPPLIER_INACTIVE');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
    CLOSE c_po_active;

    IF NOT p_b_status THEN
      RETURN;
    END IF;

-- Get the Pay To Address for the Party
    get_payto_add(p_n_party_id     => p_n_party_id,
                  p_v_party_number => l_c_hz_party.party_number,
                  p_n_location_id  => l_n_location_id,
                  p_b_status       => l_b_addr_stat);

-- If the Pay To Address procedure returns FALSE, then exit
    IF NOT l_b_addr_stat THEN
      p_b_status := FALSE;
      RETURN;
    END IF;

-- Get the location details
    OPEN c_hz_loc_addr(l_n_location_id);
    FETCH c_hz_loc_addr INTO l_c_hz_loc_addr;
    CLOSE c_hz_loc_addr;

    l_b_vendor_site := TRUE;

-- Get the vendor site details. If the Vendor Site is not active
-- a new vendor site needs to be created.
    OPEN c_vendor_sites(l_c_prty_rel.vendor_site_id);
    FETCH c_vendor_sites INTO l_v_var;
    IF c_vendor_sites%NOTFOUND THEN
      l_b_vendor_site := FALSE;
    END IF;
    CLOSE c_vendor_sites;

-- If the vendor site is active, then update the address of the
-- vendor site from the address details in TCA
    IF l_b_vendor_site THEN
      BEGIN
        l_v_site_status := null;
 	l_v_msg := null;
	/*
    	ap_po_vendors_apis_pkg.update_vendor_site(p_vendor_site_code        => NULL,
                                                  p_vendor_site_id          => l_c_prty_rel.vendor_site_id,
						  p_address_line1           => l_c_hz_loc_addr.address1,
                                                  p_address_line2           => l_c_hz_loc_addr.address2,
						  p_address_line3           => l_c_hz_loc_addr.address3,
						  p_address_line4           => l_c_hz_loc_addr.address4,
						  p_city                    => l_c_hz_loc_addr.city,
						  p_state                   => l_c_hz_loc_addr.state,
						  p_zip                     => l_c_hz_loc_addr.postal_code,
						  p_province                => l_c_hz_loc_addr.province,
                                                  p_county                  => l_c_hz_loc_addr.county,
                                                  p_country                 => l_c_hz_loc_addr.country,
						  p_area_code               => null,
						  p_phone                   => null,
						  p_fax_area_code           => null,
						  p_fax                     => null,
						  p_email_address           => null,
						  x_status                  => l_v_site_status,
						  x_exception_msg           => l_v_msg); */
      EXCEPTION
      WHEN OTHERS THEN
        l_v_site_status := 'F';
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_file.put_line(fnd_file.log, l_v_msg||sqlerrm);
      END;
      IF l_v_site_status <> 'S' THEN
        fnd_message.set_name('IGS','IGS_FI_VEN_SITE_NOT_UPD');
	fnd_message.set_token('PARTY_NUM',l_c_hz_party.party_number);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
	p_b_status := FALSE;
	RETURN;
      END IF;
    ELSE

-- The vendor site is inactive in AP. Hence, a new vendor site is created with the
-- details of the address from TCA. This site has the Pay_Site_flag set.
      BEGIN
        l_n_vendor_site_id := null;
	l_v_site_status := null;
	l_v_msg := null;
	/*
        ap_po_vendors_apis_pkg.insert_new_vendor_site(p_vendor_site_code       => g_v_dflt_sup_site,
                                                      p_vendor_id              => l_c_prty_rel.vendor_id,
                                                      p_org_id                 => g_n_org_id,
                                                      p_address_line1          => l_c_hz_loc_addr.address1,
                                                      p_address_line2          => l_c_hz_loc_addr.address2,
                                                      p_address_line3          => l_c_hz_loc_addr.address3,
                                                      p_address_line4          => l_c_hz_loc_addr.address4,
                                                      p_city                   => l_c_hz_loc_addr.city,
                                                      p_state                  => l_c_hz_loc_addr.state,
                                                      p_zip                    => l_c_hz_loc_addr.postal_code,
                                                      p_province               => l_c_hz_loc_addr.province,
                                                      p_county                 => l_c_hz_loc_addr.county,
                                                      p_country                => l_c_hz_loc_addr.country,
                                                      p_area_code              => null,
                                                      p_phone                  => null,
                                                      p_fax_area_code          => null,
                                                      p_fax                    => null,
                                                      p_email_address          => null,
                                                      p_purchasing_site_flag   => null,
                                                      p_pay_site_flag          => 'Y',
                                                      p_rfq_only_site_flag     => null,
                                                      x_vendor_site_id         => l_n_vendor_site_id,
                                                      x_status                 => l_v_site_status,
                                                      x_exception_msg          => l_v_msg);
						      */
      EXCEPTION
      WHEN OTHERS THEN
        l_v_site_status := 'F';
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_file.put_line(fnd_file.log, l_v_msg||sqlerrm);
      END;
      IF l_v_site_status <> 'S' THEN
        fnd_message.set_name('IGS','IGS_FI_VEN_SITE_NOT_CREATED');
	fnd_message.set_name('PARTY_NUM',l_c_hz_party.party_number);
        fnd_file.put_line(fnd_file.log, fnd_message.get);
	p_b_status := FALSE;
	RETURN;
      END IF;

-- Update the vendor site in the Party vendors table
      igs_fi_party_vendrs_pkg.update_row(x_rowid               => l_c_prty_rel.rowid,
                                         x_party_id            => l_c_prty_rel.party_id,
					 x_vendor_id           => l_c_prty_rel.vendor_id,
					 x_vendor_site_id      => l_n_vendor_site_id);

    END IF;
  ELSE

-- For the party, if the vendor relationship does not exist and the
-- create supplier parameter is N, then exit
    IF g_v_create_supplier = 'N' THEN
      fnd_file.put_line(fnd_file.log,
                        g_v_lbl_status||' : '||g_v_lbl_todo);
      fnd_message.set_name('IGS','IGS_FI_CREATE_SUPL_NO');
      fnd_message.set_token('PAYEE_NUM',l_c_hz_party.party_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_status := FALSE;
      RETURN;
    END IF;

-- get the pay to address for the party
    l_n_location_id := null;
    l_b_addr_stat := TRUE;
    get_payto_add(p_n_party_id     => p_n_party_id,
                  p_v_party_number => l_c_hz_party.party_number,
                  p_n_location_id  => l_n_location_id,
		  p_b_status       => l_b_addr_stat);

-- If the Pay To Address procedure returns FALSE, then exit
    IF NOT l_b_addr_stat THEN
      p_b_status := FALSE;
      RETURN;
    END IF;

-- Get the location details from HZ
    OPEN c_hz_loc_addr(l_n_location_id);
    FETCH c_hz_loc_addr INTO l_c_hz_loc_addr;
    CLOSE c_hz_loc_addr;

-- Derive the Vendor Name
    l_v_vendor_name := derive_vendor_name(p_v_party_name   => l_c_hz_party.party_name,
					  p_v_party_type   => l_c_hz_party.party_type,
					  p_v_first_name   => l_c_hz_party.person_first_name,
					  p_v_last_name    => l_c_hz_party.person_last_name);

-- Derive the Vendor Number
    l_v_sup_num := null;
      l_b_status := TRUE;
      derive_vendor_num(p_n_party_id     => p_n_party_id,
                        p_v_party_number => l_c_hz_party.party_number,
                        p_v_sup_num      => l_v_sup_num,
                        p_b_status       => l_b_status);

-- If the vendor number cannot be derived, then exit.
      IF NOT l_b_status THEN
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_message.set_name('IGS','IGS_FI_SUP_NUM_NOT_DERIVED');
        fnd_message.set_token('PARTY_NUM',l_c_hz_party.party_number);
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
        p_b_status := FALSE;
        RETURN;
      END IF;

-- Create a New vendor
    BEGIN
      l_n_vendor_id := null;
      l_v_vendor_status := null;
      l_v_msg := null;
      /*
      ap_po_vendors_apis_pkg.insert_new_vendor(p_vendor_name                  => l_v_vendor_name,
                                               p_taxpayer_id                  => null,
                                               p_tax_registration_id          => null,
                                               p_women_owned_flag             => null,
                                               p_small_business_flag          => null,
                                               p_minority_group_lookup_code   => null,
                                               p_vendor_type_lookup_code      => g_v_supplier_type,
                                               p_supplier_number              => l_v_sup_num,
                                               x_vendor_id                    => l_n_vendor_id,
                                               x_status                       => l_v_vendor_status,
                                               x_exception_msg                => l_v_msg); */
    EXCEPTION
      WHEN OTHERS THEN
        l_v_vendor_status := 'F';
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_file.put_line(fnd_file.log, l_v_msg||sqlerrm);
    END;
    IF l_v_vendor_status <> 'S' THEN
      fnd_message.set_name('IGS','IGS_FI_VENDOR_NOT_CREATED');
      fnd_message.set_token('PARTY_NUM',l_c_hz_party.party_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_status := FALSE;
      RETURN;
    END IF;

-- Create a new vendor site based on the address details from HZ
    BEGIN
      l_n_vendor_site_id := null;
      l_v_site_status := null;
      l_v_msg := null;
      /*
      ap_po_vendors_apis_pkg.insert_new_vendor_site(p_vendor_site_code       => g_v_dflt_sup_site,
                                                    p_vendor_id              => l_n_vendor_id,
                                                    p_org_id                 => g_n_org_id,
						    p_address_line1          => l_c_hz_loc_addr.address1,
                                                    p_address_line2          => l_c_hz_loc_addr.address2,
                                                    p_address_line3          => l_c_hz_loc_addr.address3,
						    p_address_line4          => l_c_hz_loc_addr.address4,
						    p_city                   => l_c_hz_loc_addr.city,
						    p_state                  => l_c_hz_loc_addr.state,
						    p_zip                    => l_c_hz_loc_addr.postal_code,
						    p_province               => l_c_hz_loc_addr.province,
   						    p_county                 => l_c_hz_loc_addr.county,
	    					    p_country                => l_c_hz_loc_addr.country,
		    				    p_area_code              => null,
			    			    p_phone                  => null,
				    		    p_fax_area_code          => null,
					    	    p_fax                    => null,
                                                    p_email_address          => null,
						    p_purchasing_site_flag   => null,
						    p_pay_site_flag          => 'Y',
						    p_rfq_only_site_flag     => null,
						    x_vendor_site_id         => l_n_vendor_site_id,
						    x_status                 => l_v_site_status,
    						    x_exception_msg          => l_v_msg); */
    EXCEPTION
      WHEN OTHERS THEN
        l_v_site_status := 'F';
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_file.put_line(fnd_file.log, l_v_msg||sqlerrm);
    END;
    IF l_v_site_status <> 'S' THEN
      fnd_message.set_name('IGS','IGS_FI_VEN_SITE_NOT_CREATED');
      fnd_message.set_token('PARTY_NUM',l_c_hz_party.party_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);
      p_b_status := FALSE;
      RETURN;
    END IF;

-- Create a new record in the vendor relationships table
    l_v_rowid := null;
    igs_fi_party_vendrs_pkg.insert_row(x_rowid               => l_v_rowid,
                                       x_party_id            => p_n_party_id,
                                       x_vendor_id           => l_n_vendor_id,
                                       x_vendor_site_id      => l_n_vendor_site_id);
  END IF;

  l_n_cntr := t_party_vendors.COUNT + 1;
  t_party_vendors(l_n_cntr).p_n_party_id := p_n_party_id;
  t_party_vendors(l_n_cntr).p_n_vendor_id := l_n_vendor_id;
  t_party_vendors(l_n_cntr).p_n_vendor_site_id := l_n_vendor_site_id;
  p_n_vendor_id      := l_n_vendor_id;
  p_n_vendor_site_id := l_n_vendor_site_id;
  p_b_status         := TRUE;

END create_supplier;

PROCEDURE create_ap_int_rec(p_n_refund_id                  PLS_INTEGER,
                            p_d_vchr_date                  DATE,
                            p_n_vendor_id                  PLS_INTEGER,
                            p_n_vendor_site_id             PLS_INTEGER,
                            p_n_rfnd_amnt                  NUMBER,
                            p_n_terms_id                   PLS_INTEGER,
                            p_v_grp_code                   VARCHAR2,
                            p_d_gl_date                    DATE,
                            p_gl_dr_ccid                   PLS_INTEGER,
                            p_gl_cr_ccid                   PLS_INTEGER) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for creating a record in the AP_INVOICES_INTERFACE and
  ||            AP_INVOICE_LINES_INTERFACE
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || abshriva    12-MAy-2006   Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
  ||  (reverse chronological order - newest change first)
  ******************************************************************/
  CURSOR c_inv_int IS
    SELECT AP_INVOICES_INTERFACE_S.NEXTVAL
    FROM   dual;

  l_n_inv_id      ap_invoices_interface.invoice_id%TYPE;
  l_v_inv_lkp     igs_lookup_values.lookup_code%TYPE;
  l_n_rfnd_amt    NUMBER := 0;
BEGIN

-- Get the new Invoice Id from the AP_INVOICES_INTERFACE_S sequence
  OPEN c_inv_int;
  FETCH c_inv_int INTO l_n_inv_id;
  CLOSE c_inv_int;

-- If the Refund Amount is negative, then the Invoice Type is
-- Credit else it is standard
  IF p_n_rfnd_amnt < 0 THEN
    l_v_inv_lkp := g_v_credit;
  ELSE
    l_v_inv_lkp := g_v_standard;
  END IF;
  l_n_rfnd_amt :=igs_fi_gen_gl.get_formatted_amount(p_n_rfnd_amnt);
-- Create a transaction in AP_INVOICES_INTERFACE
  INSERT INTO ap_invoices_interface(invoice_id,
                                    invoice_num,
                                    invoice_type_lookup_code,
                                    invoice_date,
                                    vendor_id,
                                    vendor_site_id,
                                    invoice_amount,
                                    invoice_currency_code,
                                    terms_id,
                                    source,
                                    pay_group_lookup_code,
                                    gl_date,
                                    accts_pay_code_combination_id,
                                    exclusive_payment_flag,
                                    org_id,
                                    terms_date)
                             VALUES(l_n_inv_id,
                                    p_n_refund_id,
                                    l_v_inv_lkp,
                                    p_d_vchr_date,
                                    p_n_vendor_id,
                                    p_n_vendor_site_id,
                                    l_n_rfnd_amt,
                                    g_v_cur_code,
                                    p_n_terms_id,
                                    g_v_stdnt_system,
                                    p_v_grp_code,
                                    p_d_gl_date,
                                    p_gl_cr_ccid,
                                    g_v_pay_rfnd_vchr,
                                    g_n_org_id,
                                    p_d_vchr_date);

-- Create a transaction in AP_INVOICE_LINES_INTERFACE
  INSERT INTO ap_invoice_lines_interface(invoice_id,
                                         invoice_line_id,
					 line_number,
					 line_type_lookup_code,
					 accounting_date,
					 amount,
					 dist_code_combination_id,
					 org_id)
				  VALUES(l_n_inv_id,
				         NULL,
					 1,
					 g_v_item,
					 p_d_gl_date,
					 l_n_rfnd_amt,
					 p_gl_dr_ccid,
					 g_n_org_id);


END create_ap_int_rec;


PROCEDURE process_refunds(p_n_party_id          PLS_INTEGER,
                          p_v_inv_pay_group     VARCHAR2,
                          p_n_inv_pay_term      NUMBER) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Procedure for processing the refund transactions
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  agairola        11-Mar-2003     Bug# 2838757: Set the variable
  ||                                  g_b_data_found to true when records
  ||                                  are processed
  ||  (reverse chronological order - newest change first)
  ******************************************************************/

-- Cursor to get all the refund transactions that have been
-- created due to reversal of a refund transaction and have TODO status
  CURSOR c_rfnd(cp_n_party_id            hz_parties.party_id%TYPE) IS
    SELECT rfnd.rowid, rfnd.*
    FROM   igs_fi_refunds rfnd
    WHERE  rfnd.person_id = cp_n_party_id
    AND    rfnd.transfer_status    = g_v_todo
    AND    rfnd.source_refund_id IS NOT NULL
    ORDER BY rfnd.pay_person_id
    FOR UPDATE NOWAIT;

-- Get the refund voucher details for the Refund Id
  CURSOR c_rfnd_org(cp_n_refund_id          igs_fi_refunds.refund_id%TYPE) IS
    SELECT rfnd.rowid, rfnd.*
    FROM   igs_fi_refunds rfnd
    WHERE  rfnd.refund_id = cp_n_refund_id
    FOR UPDATE NOWAIT;

-- Get all the refund transactions that have not been reversed and have
-- status of TODO
  CURSOR c_rfnd1(cp_n_party_id            hz_parties.party_id%TYPE) IS
    SELECT rfnd.rowid, rfnd.*
    FROM   igs_fi_refunds rfnd
    WHERE  rfnd.person_id = cp_n_party_id
    AND    rfnd.transfer_status    = g_v_todo
    AND    rfnd.source_refund_id IS NULL
    ORDER BY rfnd.pay_person_id
    FOR UPDATE NOWAIT;

  l_c_rfnd_org         c_rfnd_org%ROWTYPE;
  l_b_status           BOOLEAN := TRUE;
  l_n_vendor_id        igs_fi_party_vendrs.vendor_id%TYPE;
  l_n_vendor_site_id   igs_fi_party_vendrs.vendor_site_id%TYPE;
BEGIN

-- Loop across all the refund transactions
  FOR l_c_rfnd_rec IN c_rfnd(p_n_party_id) LOOP

    g_b_data_found := TRUE;
-- Get the status of the original refund transaction
    OPEN c_rfnd_org(l_c_rfnd_rec.source_refund_id);
    FETCH c_rfnd_org INTO l_c_rfnd_org;
    CLOSE c_rfnd_org;

-- If the status is TODO, then both the current transaction
-- and the original transaction have to be updated to status OFFSET
    IF l_c_rfnd_org.transfer_status = g_v_todo THEN
      l_c_rfnd_rec.transfer_status := g_v_offset;
      log_transaction(p_n_party_id     => l_c_rfnd_rec.person_id,
                      p_n_payee_id     => l_c_rfnd_rec.pay_person_id,
                      p_n_refund_id    => l_c_rfnd_rec.refund_id);
      fnd_file.put_line(fnd_file.log,
                        g_v_lbl_status||' : '||g_v_lbl_offset);
      fnd_file.new_line(fnd_file.log);
      update_refund_rec(l_c_rfnd_rec);

      l_c_rfnd_org.transfer_status := g_v_offset;
      log_transaction(p_n_party_id     => l_c_rfnd_org.person_id,
	              p_n_payee_id     => l_c_rfnd_org.pay_person_id,
	              p_n_refund_id    => l_c_rfnd_org.refund_id);
      fnd_file.put_line(fnd_file.log,
                        g_v_lbl_status||' : '||g_v_lbl_offset);
      fnd_file.new_line(fnd_file.log);
      update_refund_rec(l_c_rfnd_org);

    ELSIF l_c_rfnd_org.transfer_status = 'TRANSFERRED' THEN

-- Else if the original transaction was transferred, this refund transaction
-- also needs to be transferred.
      log_transaction(p_n_party_id     => l_c_rfnd_rec.person_id,
	              p_n_payee_id     => l_c_rfnd_rec.pay_person_id,
	              p_n_refund_id    => l_c_rfnd_rec.refund_id);

-- Call the create supplier procedure for creating a supplier for the refund payee
      create_supplier(p_n_party_id        => l_c_rfnd_rec.pay_person_id,
                      p_n_vendor_id       => l_n_vendor_id,
                      p_n_vendor_site_id  => l_n_vendor_site_id,
                      p_b_status          => l_b_status);

      BEGIN
        SAVEPOINT SP_PROCESS;

-- If the create supplier procedure returns TRUE, then
        IF l_b_status THEN

-- Create a transaction in AP
          create_ap_int_rec(p_n_refund_id        => l_c_rfnd_rec.refund_id,
                            p_d_vchr_date        => l_c_rfnd_rec.voucher_date,
  			    p_n_vendor_id        => l_n_vendor_id,
  			    p_n_vendor_site_id   => l_n_vendor_site_id,
  			    p_n_rfnd_amnt        => l_c_rfnd_rec.refund_amount,
  			    p_n_terms_id         => p_n_inv_pay_term,
  			    p_v_grp_code         => p_v_inv_pay_group,
  			    p_d_gl_date          => l_c_rfnd_rec.gl_date,
			    p_gl_dr_ccid         => l_c_rfnd_rec.dr_gl_ccid,
			    p_gl_cr_ccid         => l_c_rfnd_rec.cr_gl_ccid);
          l_c_rfnd_rec.transfer_status := g_v_transferred;

-- Update the refund transaction to TRANSFERRED status
          update_refund_rec(l_c_rfnd_rec);
          fnd_file.put_line(fnd_file.log,
                            g_v_lbl_status||' : '||g_v_lbl_transferred);
          fnd_file.new_line(fnd_file.log);
        END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ROLLBACK TO SP_PROCESS;
          fnd_file.put_line(fnd_file.log,
                            g_v_lbl_status||' : '||g_v_lbl_todo);
          fnd_file.put_line(fnd_file.log,
                            g_v_lbl_error||':'||sqlerrm);
          fnd_file.new_line(fnd_file.log);
      END;
    END IF;
  END LOOP;

-- Loop across all the refund transactions that have not been reversed.
  FOR l_c_rfnd_rec IN c_rfnd1(p_n_party_id) LOOP

    g_b_data_found := TRUE;
    log_transaction(p_n_party_id     => l_c_rfnd_rec.person_id,
                    p_n_payee_id     => l_c_rfnd_rec.pay_person_id,
                    p_n_refund_id    => l_c_rfnd_rec.refund_id);

-- call the supplier creation procedure
    create_supplier(p_n_party_id        => l_c_rfnd_rec.pay_person_id,
                    p_n_vendor_id       => l_n_vendor_id,
                    p_n_vendor_site_id  => l_n_vendor_site_id,
                    p_b_status          => l_b_status);

    BEGIN
      SAVEPOINT SP_PROCESS;
-- If the supplier creation is sucessful, then
      IF l_b_status THEN

-- Create a transaction in AP
        create_ap_int_rec(p_n_refund_id        => l_c_rfnd_rec.refund_id,
                          p_d_vchr_date        => l_c_rfnd_rec.voucher_date,
  		          p_n_vendor_id        => l_n_vendor_id,
			  p_n_vendor_site_id   => l_n_vendor_site_id,
			  p_n_rfnd_amnt        => l_c_rfnd_rec.refund_amount,
			  p_n_terms_id         => p_n_inv_pay_term,
			  p_v_grp_code         => p_v_inv_pay_group,
			  p_d_gl_date          => l_c_rfnd_rec.gl_date,
			  p_gl_dr_ccid         => l_c_rfnd_rec.dr_gl_ccid,
			  p_gl_cr_ccid         => l_c_rfnd_rec.cr_gl_ccid);

-- Update the refund transaction to the status of Transferred
        l_c_rfnd_rec.transfer_status := g_v_transferred;
        update_refund_rec(l_c_rfnd_rec);
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_transferred);
      END IF;
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO SP_PROCESS;
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_status||' : '||g_v_lbl_todo);
        fnd_file.put_line(fnd_file.log,
                          g_v_lbl_error||':'||sqlerrm);
        fnd_file.new_line(fnd_file.log);
    END;
  END LOOP;
END process_refunds;

PROCEDURE transfer(errbuf                OUT NOCOPY VARCHAR2,
                   retcode               OUT NOCOPY NUMBER,
                   p_n_party_id          IN  NUMBER,
                   p_n_person_group_id   IN  NUMBER,
                   p_v_create_supplier   IN  VARCHAR2,
                   p_v_supplier_type     IN  VARCHAR2,
                   p_v_inv_pay_group     IN  VARCHAR2,
                   p_n_inv_pay_term      IN  NUMBER,
                   p_v_test_run          IN  VARCHAR2) AS
  /******************************************************************
  ||  Created By : Amit.Gairola@oracle.com
  ||  Created On : 18-FEB-2003
  ||  Purpose : Main procedure for the concurrent manager
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ridas           14-Feb-2006     Bug #5021084. Added new parameter lv_group_type
  ||                                  in call to igf_ap_ss_pkg.get_pid
  ||  agairola        11-Mar-2003     Bug 2838757: Modified the code to
  ||                                  log the message no data found when
  ||                                  no records are found
  ||  (reverse chronological order - newest change first)
  ******************************************************************/
  CURSOR c_rfnd_per IS
    SELECT DISTINCT person_id
    FROM   igs_fi_refunds
    WHERE  transfer_status = g_v_todo;

  TYPE c_per_grp_cur   IS REF CURSOR;

  l_v_stmnt         VARCHAR2(32767);

  l_c_per_grp_cur   c_per_grp_cur;
  l_b_val_parm      BOOLEAN ;

  l_n_party_id      hz_parties.party_id%TYPE;

  l_v_status        VARCHAR2(10);
  lv_group_type     igs_pe_persid_group_v.group_type%TYPE;

BEGIN

-- Create a save point for the process
  SAVEPOINT  SP_TRANSFER;

  retcode := 0;
  errbuf := null;

  l_b_val_parm := TRUE;
  g_v_create_supplier := p_v_create_supplier;

-- call the initialization procedure
  initialize;

-- validate input parameters
  l_b_val_parm := validate_parameters(p_n_party_id          => p_n_party_id,
                                      p_n_person_group_id   => p_n_person_group_id,
                                      p_v_create_supplier   => p_v_create_supplier,
                                      p_v_supplier_type     => p_v_supplier_type,
                                      p_v_inv_pay_group     => p_v_inv_pay_group,
                                      p_n_inv_pay_term      => p_n_inv_pay_term,
                                      p_v_test_run          => p_v_test_run);

  IF NOT l_b_val_parm THEN
    retcode := 2;
    RETURN;
  END IF;

  g_v_supplier_type := p_v_supplier_type;

-- If the party id passed as input is NOT NULL, then pass
-- the party id to the process_refunds procedure
  IF p_n_party_id IS NOT NULL THEN

    process_refunds(p_n_party_id          => p_n_party_id,
                    p_v_inv_pay_group     => p_v_inv_pay_group,
                    p_n_inv_pay_term      => p_n_inv_pay_term);

  ELSIF p_n_person_group_id IS NOT NULL THEN
-- If the Person Group is Not null, then
-- fetch the query for the dynamic person groups
    --Bug #5021084
    l_v_stmnt := igf_ap_ss_pkg.get_pid(p_pid_grp    => p_n_person_group_id,
	                                     p_status     => l_v_status,
                                       p_group_type => lv_group_type);

    IF l_v_status <> 'S' THEN
      fnd_file.put_line(fnd_file.log, l_v_stmnt);
      RETURN;
    END IF;

-- Execute the query returned by the procedure and for all the person id
-- returned by the query, transfer the refund transactions

    --Bug #5021084. Passing Group ID if the group type is STATIC.
    IF lv_group_type = 'STATIC' THEN
      OPEN l_c_per_grp_cur FOR l_v_stmnt USING p_n_person_group_id;
    ELSIF lv_group_type = 'DYNAMIC' THEN
      OPEN l_c_per_grp_cur FOR l_v_stmnt;
    END IF;

    LOOP
    FETCH l_c_per_grp_cur INTO l_n_party_id;
    EXIT WHEN l_c_per_grp_cur%NOTFOUND;
      process_refunds(p_n_party_id          => l_n_party_id,
                      p_v_inv_pay_group     => p_v_inv_pay_group,
                      p_n_inv_pay_term      => p_n_inv_pay_term);
    END LOOP;
    CLOSE l_c_per_grp_cur;

  ELSIF p_n_person_group_id IS NULL and p_n_party_id IS NULL THEN

-- Else if the person group is null and the party id is also null, the
-- process refunds for all the parties having a TODO record in the
-- Refunds
    FOR l_c_rfnd_per IN c_rfnd_per LOOP
      process_refunds(p_n_party_id          => l_c_rfnd_per.person_id,
                      p_v_inv_pay_group     => p_v_inv_pay_group,
                      p_n_inv_pay_term      => p_n_inv_pay_term);
    END LOOP;
  END IF;

-- If the test run parameter = 'Y', then rollback all the transactions
-- and exit.
  IF (p_v_test_run = 'Y' AND g_b_data_found) THEN
    ROLLBACK TO SP_TRANSFER;
    fnd_message.set_name('IGS',
	                 'IGS_FI_PRC_TEST_RUN');
    fnd_file.put_line(fnd_file.log,
	              fnd_message.get);
  ELSE
    COMMIT;
  END IF;

-- If there are no records found then log the message No Data Found
  IF NOT g_b_data_found THEN
    fnd_message.set_name('IGS',
                         'IGS_GE_NO_DATA_FOUND');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
  END IF;

EXCEPTION
  WHEN e_resource_busy THEN
    retcode := 2;
    fnd_message.set_name('IGS',
                         'IGS_FI_RFND_REC_LOCK');
    fnd_file.put_line(fnd_file.log, fnd_message.get);
  WHEN OTHERS THEN
    retcode := 2;
    ROLLBACK TO SP_TRANSFER;
    fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get||' - '||sqlerrm);
END transfer;

END igs_fi_prc_apint;

/
