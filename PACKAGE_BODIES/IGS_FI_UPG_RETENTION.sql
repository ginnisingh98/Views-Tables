--------------------------------------------------------
--  DDL for Package Body IGS_FI_UPG_RETENTION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_UPG_RETENTION" AS
/* $Header: IGSFI90B.pls 120.6 2006/05/04 07:53:45 abshriva noship $ */

    /******************************************************************
     Created By      :   Shirish Tatikonda
     Date Created By :   11-DEC-2003
     Purpose         :   Package Body for upgrade of Retention Charge Accounts.

     Known limitations,enhancements,remarks:
     Change History
     Who        When          What
     abshriva   4-May-2006   Bug 5178077: Modification done in PROCEDURE upg_accts
     svuppala   30-MAY-2005   Enh 3442712 - Done the TBH modifications by adding
                              new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all
     shtatiko   11-DEC-2003  Bug# 3288973, Created this process
    ***************************************************************** */

  TYPE ret_invoice_rec IS RECORD( invoice_id  igs_fi_inv_int_all.invoice_id%TYPE,
                                  ftci_rec_account_cd igs_fi_f_typ_ca_inst.rec_account_cd%TYPE,
                                  ftci_rec_gl_ccid    igs_fi_f_typ_ca_inst.rec_gl_ccid%TYPE,
                                  ftci_ret_account_cd igs_fi_f_typ_ca_inst.ret_account_cd%TYPE,
                                  ftci_ret_gl_ccid    igs_fi_f_typ_ca_inst.ret_gl_ccid%TYPE );
  TYPE ret_invoice_tab_type IS TABLE OF ret_invoice_rec
    INDEX BY BINARY_INTEGER;

  FUNCTION find_invoice ( p_n_invoice_id igs_fi_inv_int_all.invoice_id%TYPE,
                          p_invoice_tab  ret_invoice_tab_type) RETURN BOOLEAN IS

  BEGIN

    IF p_invoice_tab.COUNT > 0 THEN
      FOR i IN p_invoice_tab.FIRST..p_invoice_tab.LAST LOOP
        IF p_invoice_tab.EXISTS(i) THEN
          IF p_invoice_tab(i).invoice_id = p_n_invoice_id THEN
            RETURN TRUE;
          END IF;
        END IF;
      END LOOP;
    END IF;

    RETURN FALSE;

  END find_invoice;

  FUNCTION get_credit_class( p_n_credit_id igs_fi_credits_all.credit_id%TYPE ) RETURN VARCHAR2 IS

-- bug 5018036 :  joined IGS_FI_CREDITS_ALL , IGS_FI_CR_TYPES instead using IGS_FI_CREDITS_V
 CURSOR c_crd_class (cp_n_credit_id igs_fi_credits_all.credit_id%TYPE) IS
      SELECT credit_class credit_class_code
      FROM igs_fi_credits_all crd, igs_fi_cr_types ct
      WHERE crd.credit_id = cp_n_credit_id AND
	ct.credit_type_id=crd.credit_type_id;
    rec_crd_class c_crd_class%ROWTYPE;


  BEGIN

    OPEN c_crd_class ( p_n_credit_id );
    FETCH c_crd_class INTO rec_crd_class;
    CLOSE c_crd_class;

    RETURN rec_crd_class.credit_class_code;

  END get_credit_class;

  FUNCTION get_credit_number( p_n_credit_id igs_fi_credits_all.credit_id%TYPE ) RETURN VARCHAR2 IS

    CURSOR c_crd_number (cp_n_credit_id igs_fi_credits_all.credit_id%TYPE) IS
      SELECT credit_number
      FROM igs_fi_credits_all
      WHERE credit_id = cp_n_credit_id;
    rec_crd_number c_crd_number%ROWTYPE;

  BEGIN

    OPEN c_crd_number ( p_n_credit_id );
    FETCH c_crd_number INTO rec_crd_number;
    CLOSE c_crd_number;

    RETURN rec_crd_number.credit_number;

  END get_credit_number;

  PROCEDURE upg_accts(errbuf            OUT NOCOPY VARCHAR2,
                      retcode           OUT NOCOPY NUMBER ) AS
    /******************************************************************
     Created By      :   Shirish Tatikonda
     Date Created By :   11-DEC-2003
     Purpose         :   Main procedure for upgrade of Retention Charge Accounts.

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     abshriva   4-May-2006   Bug 5178077: Introduced igs_ge_gen_003.set_org_id
     skharida   13-Feb-2006  APPSPERF:  bug 5018036, Replaced igs_fi_f_typ_ca_inst_lkp_v  by a join of igs_fi_f_typ_ca_inst and igs_ca_inst
     svuppala   30-MAY-2005  Enh 3442712 - Done the TBH modifications by adding
                             new columns Unit_Type_Id, Unit_Level in igs_fi_invln_int_all

     shtatiko   11-DEC-2003  Bug# 3288973, Created this process
    ***************************************************************** */

    -- Fetch Receivables Account Information from System Options Level
    CURSOR c_sys_opt_rec_acct IS
      SELECT rec_installed, rec_gl_ccid, rec_account_cd, accounting_method
      FROM igs_fi_control_all;

-- Bug 5018036, SQL ID 14794917: replaced igs_fi_f_typ_ca_inst_lkp_v  by a join of igs_fi_f_typ_ca_inst and igs_ca_inst
    CURSOR c_upd_charges IS
      SELECT a.invoice_id,
             a.fee_type,
             a.fee_cal_type,
             a.fee_ci_sequence_number,
             ci.start_dt,
             ci.end_dt,
             b.rec_gl_ccid    inv_rec_gl_ccid,
             b.rec_account_cd inv_rec_account_cd,
             b.rev_gl_ccid    inv_rev_gl_ccid,
             b.rev_account_cd inv_rev_account_cd,
             c.rec_gl_ccid    ftci_rec_gl_ccid,
             c.rec_account_cd ftci_rec_account_cd,
             c.ret_gl_ccid    ftci_ret_gl_ccid,
             c.ret_account_cd ftci_ret_account_cd
      FROM igs_fi_inv_int_all  a,
           igs_fi_invln_int_all  b,
	   igs_fi_f_typ_ca_inst  c,
           igs_ca_inst ci
      WHERE a.invoice_id = b.invoice_id
      AND a.transaction_type = 'RETENTION'
      AND b.error_account = 'Y'
      AND a.fee_type = c.fee_type
      AND a.fee_cal_type = c.fee_cal_type
      AND a.fee_ci_sequence_number = c.fee_ci_sequence_number
       And ci.cal_type=c.fee_cal_type
       And ci.sequence_number = c.fee_ci_sequence_number
      ORDER BY a.fee_type, a.fee_cal_type, a.fee_ci_sequence_number;

-- Bug 5018036: Instead using igs_fi_f_typ_ca_inst_lkp_v joined igs_fi_f_typ_ca_inst and igs_ca_inst
    CURSOR c_upd_applications IS
      SELECT app.invoice_id ,
             app.application_id ,
             inv.fee_type ,
             inv.fee_cal_type ,
             inv.fee_ci_sequence_number ,
             app.dr_gl_code_ccid    app_dr_gl_code_ccid,
             app.dr_account_cd      app_dr_account_cd,
             app.cr_gl_code_ccid    app_cr_gl_code_ccid,
             app.cr_account_cd    app_cr_account_cd,
             ftci.rec_gl_ccid    ftci_rec_gl_ccid,
             ftci.rec_account_cd ftci_rec_account_cd,
             ftci.ret_gl_ccid    ftci_ret_gl_ccid,
             ftci.ret_account_cd ftci_ret_account_cd,
             ci.start_dt,
	     ci.end_dt
      FROM igs_fi_applications app,
           igs_fi_inv_int_all inv,
	   igs_fi_f_typ_ca_inst ftci,
	   igs_ca_inst ci
      WHERE app.invoice_id = inv.invoice_id
      AND inv.transaction_type = 'RETENTION'
      AND inv.fee_type = ftci.fee_type
      AND inv.fee_cal_type = ftci.fee_cal_type
      AND inv.fee_ci_sequence_number = ftci.fee_ci_sequence_number
      AND ((app.dr_gl_code_ccid IS NULL AND app.dr_account_cd IS NULL)
            OR (app.cr_gl_code_ccid IS NULL AND app.cr_account_cd IS NULL)
          )
      And ci.cal_type=ftci.fee_cal_type
      And ci.sequence_number = ftci.fee_ci_sequence_number
      ORDER BY inv.fee_type, inv.fee_cal_type, inv.fee_ci_sequence_number;


    CURSOR c_invoice_details ( cp_n_invoice_id igs_fi_inv_int_all.invoice_id%TYPE ) IS
      SELECT ROWID, inv.*
      FROM igs_fi_invln_int_all inv
      WHERE invoice_id = cp_n_invoice_id;
    rec_invoice_details c_invoice_details%ROWTYPE;

    CURSOR c_application_details ( cp_n_invoice_id igs_fi_inv_int_all.invoice_id%TYPE ) IS
      SELECT ROWID, app.*
      FROM igs_fi_applications app
      WHERE invoice_id = cp_n_invoice_id;

    CURSOR c_cr_act_details ( cp_n_credit_id igs_fi_credits_all.credit_id%TYPE ) IS
      SELECT ROWID, crd.*
      FROM igs_fi_cr_activities crd
      WHERE credit_id = cp_n_credit_id;
    rec_cr_act_details c_cr_act_details%ROWTYPE;

    CURSOR c_gl_interface ( cp_v_ref_23 VARCHAR2, cp_v_ref_30 VARCHAR2) IS
      SELECT rowid, accounted_cr, accounted_dr, code_combination_id
      FROM gl_interface
      WHERE reference23 = cp_v_ref_23
      AND reference30 = cp_v_ref_30;

    CURSOR c_posting_int ( cp_n_source_tran_id NUMBER, cp_v_source_tran_type VARCHAR2) IS
      SELECT ROWID, post.*
      FROM igs_fi_posting_int_all post
      WHERE source_transaction_id = cp_n_source_tran_id
      AND source_transaction_type = cp_v_source_tran_type;

    l_v_rec_installed     igs_fi_control_all.rec_installed%TYPE;
    l_v_accounting_method igs_fi_control_all.accounting_method%TYPE;

    l_v_fee_type        igs_fi_inv_int_all.fee_type%TYPE;
    l_v_fee_cal_type    igs_fi_inv_int_all.fee_cal_type%TYPE;
    l_n_fee_ci_sequence_number  igs_fi_inv_int_all.fee_ci_sequence_number%TYPE;

    l_n_rec_gl_ccid_sys     igs_fi_control_all.rec_gl_ccid%TYPE;
    l_n_upd_rec_gl_ccid     igs_fi_control_all.rec_gl_ccid%TYPE;
    l_n_upd_rev_gl_ccid     igs_fi_control_all.rec_gl_ccid%TYPE;
    l_n_upd_dr_gl_ccid      igs_fi_control_all.rec_gl_ccid%TYPE;
    l_n_upd_cr_gl_code_ccid igs_fi_control_all.rec_gl_ccid%TYPE;

    l_v_rec_account_cd_sys  igs_fi_control_all.rec_account_cd%TYPE;
    l_v_upd_rec_account_cd  igs_fi_control_all.rec_account_cd%TYPE;
    l_v_upd_rev_account_cd  igs_fi_control_all.rec_account_cd%TYPE;
    l_v_upd_dr_account_cd   igs_fi_control_all.rec_account_cd%TYPE;
    l_v_upd_cr_account_cd   igs_fi_control_all.rec_account_cd%TYPE;

    l_b_sys_opt_defined BOOLEAN := FALSE;
    l_b_invoice_found   BOOLEAN := FALSE;
    l_b_no_ftci_setup   BOOLEAN := FALSE;
    l_b_upd             BOOLEAN := FALSE;
    l_b_rec_setup       BOOLEAN := FALSE;
    l_b_ret_setup       BOOLEAN := FALSE;
    l_b_upgrade_done    BOOLEAN := FALSE;
    l_org_id     VARCHAR2(15);
    l_n_cntr NUMBER;

    l_v_lkp_fee_type igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_TYPE');
    l_v_lkp_fee_cal_type igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'FEE_CAL_TYPE');
    l_v_lkp_start_dt igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'START_DT');
    l_v_lkp_end_dt igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'END_DT');

    l_v_lkp_dr_account igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'DR_ACCOUNT');
    l_v_lkp_cr_account igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CR_ACCOUNT');

    l_v_lkp_charge_number igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CHARGE_NUMBER');
    l_v_lkp_credit_number igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CREDIT_NUMBER');
    l_v_lkp_application_id igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'APPLICATION_ID');

    l_v_lkp_status igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'STATUS');
    l_v_lkp_error igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('STATUS', 'ERROR');
    l_v_lkp_success igs_lookup_values.meaning%TYPE := igs_fi_gen_gl.get_lkp_meaning('STATUS', 'SUCCESS');

    ret_invoice_tab ret_invoice_tab_type;

  BEGIN
    BEGIN
      l_org_id := NULL;
      igs_ge_gen_003.set_org_id(l_org_id);
    EXCEPTION
    WHEN OTHERS THEN
       fnd_file.put_line (fnd_file.log, fnd_message.get);
       retcode:=2;
       RETURN;
    END;
    l_b_no_ftci_setup := FALSE;
    ret_invoice_tab.DELETE;

    OPEN c_sys_opt_rec_acct;
    FETCH c_sys_opt_rec_acct INTO l_v_rec_installed,
                                  l_n_rec_gl_ccid_sys,
                                  l_v_rec_account_cd_sys,
                                  l_v_accounting_method;
    CLOSE c_sys_opt_rec_acct;

    IF l_n_rec_gl_ccid_sys IS NULL AND l_v_rec_account_cd_sys IS NULL THEN
      l_b_sys_opt_defined := FALSE;
    ELSE
      l_b_sys_opt_defined := TRUE;
    END IF;

    ----------------------------------------------------------------------------------------------
    -- En-list all FTCIs, which does not have Receivables or Retention or both account information.
    ----------------------------------------------------------------------------------------------

    -- Process Charge Records to en-list

    l_n_cntr := 0;
    l_v_fee_type := 'NULL';
    l_v_fee_cal_type := 'NULL';
    l_n_fee_ci_sequence_number := 0;
    l_b_ret_setup := FALSE;
    l_b_rec_setup := FALSE;

    FOR rec_upd_charges IN c_upd_charges LOOP
      IF (l_v_fee_type <> rec_upd_charges.fee_type OR
          l_v_fee_cal_type <> rec_upd_charges.fee_cal_type OR
          l_n_fee_ci_sequence_number <> rec_upd_charges.fee_ci_sequence_number) THEN

        -- Check whether Receivables setup is there
        IF (l_b_sys_opt_defined = FALSE AND rec_upd_charges.ftci_rec_gl_ccid IS NULL AND rec_upd_charges.ftci_rec_account_cd IS NULL) THEN
          l_b_rec_setup := TRUE;
        END IF;

        -- Check if Retention account setup is there at FTCI
        IF (rec_upd_charges.ftci_ret_gl_ccid IS NULL AND rec_upd_charges.ftci_ret_account_cd IS NULL ) THEN
          l_b_ret_setup := TRUE;
        END IF;

        IF l_b_rec_setup OR l_b_ret_setup THEN
          l_b_no_ftci_setup := TRUE;

          fnd_file.new_line(fnd_file.LOG );
          fnd_file.put_line(fnd_file.LOG, l_v_lkp_fee_type || ' : ' || rec_upd_charges.fee_type );
          fnd_file.put_line(fnd_file.LOG, l_v_lkp_fee_cal_type || ' : ' || rec_upd_charges.fee_cal_type );
          fnd_file.put_line(fnd_file.LOG, l_v_lkp_start_dt || ' : ' || rec_upd_charges.start_dt );
          fnd_file.put_line(fnd_file.LOG, l_v_lkp_end_dt || ' : ' || rec_upd_charges.end_dt );

          IF l_b_rec_setup THEN
            fnd_file.put_line( fnd_file.LOG, fnd_message.get_string('IGS', 'IGS_FI_NO_REC_ACCT_CD_FTCI') );
          END IF;

          IF l_b_ret_setup THEN
            fnd_file.put_line( fnd_file.LOG, fnd_message.get_string('IGS', 'IGS_FI_NO_RETENTION_ACC') );
          END IF;
        END IF;
        l_b_ret_setup := FALSE;
        l_b_rec_setup := FALSE;
      END IF;
      l_v_fee_type := rec_upd_charges.fee_type;
      l_v_fee_cal_type := rec_upd_charges.fee_cal_type;
      l_n_fee_ci_sequence_number := rec_upd_charges.fee_ci_sequence_number;

      ret_invoice_tab(l_n_cntr).invoice_id := rec_upd_charges.invoice_id;
      ret_invoice_tab(l_n_cntr).ftci_rec_gl_ccid := rec_upd_charges.ftci_rec_gl_ccid;
      ret_invoice_tab(l_n_cntr).ftci_rec_account_cd := rec_upd_charges.ftci_rec_account_cd;
      ret_invoice_tab(l_n_cntr).ftci_ret_gl_ccid := rec_upd_charges.ftci_ret_gl_ccid;
      ret_invoice_tab(l_n_cntr).ftci_ret_account_cd := rec_upd_charges.ftci_ret_account_cd;
      l_n_cntr := l_n_cntr + 1;
    END LOOP;

    -- Process Application records to en-list

    l_v_fee_type := 'NULL';
    l_v_fee_cal_type := 'NULL';
    l_n_fee_ci_sequence_number := 0;
    l_b_ret_setup := FALSE;
    l_b_rec_setup := FALSE;

    FOR rec_upd_applications IN c_upd_applications LOOP

      l_b_invoice_found := find_invoice(rec_upd_applications.invoice_id, ret_invoice_tab);

      -- If the invoice is already there in the table, proceed with the next application record.
      IF l_b_invoice_found = FALSE THEN

        IF (l_v_fee_type <> rec_upd_applications.fee_type
            OR l_v_fee_cal_type <> rec_upd_applications.fee_cal_type
            OR l_n_fee_ci_sequence_number <> rec_upd_applications.fee_ci_sequence_number) THEN

          -- Check whether Receivables setup is there
          IF (l_b_sys_opt_defined = FALSE AND rec_upd_applications.ftci_rec_gl_ccid IS NULL AND rec_upd_applications.ftci_rec_account_cd IS NULL) THEN
            l_b_rec_setup := TRUE;
          END IF;

          -- Check if Retention account setup is there at FTCI
          IF (rec_upd_applications.ftci_ret_gl_ccid IS NULL AND rec_upd_applications.ftci_ret_account_cd IS NULL ) THEN
            l_b_ret_setup := TRUE;
          END IF;

          IF l_b_rec_setup OR l_b_ret_setup THEN
            l_b_no_ftci_setup := TRUE;

            fnd_file.new_line(fnd_file.LOG );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_fee_type || ' : ' || rec_upd_applications.fee_type );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_fee_cal_type || ' : ' || rec_upd_applications.fee_cal_type );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_start_dt || ' : ' || rec_upd_applications.start_dt );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_end_dt || ' : ' || rec_upd_applications.end_dt );

            IF l_b_rec_setup THEN
              fnd_file.put_line( fnd_file.LOG, fnd_message.get_string('IGS', 'IGS_FI_NO_REC_ACCT_CD_FTCI') );
            END IF;

            IF l_b_ret_setup THEN
              fnd_file.put_line( fnd_file.LOG, fnd_message.get_string('IGS', 'IGS_FI_NO_RETENTION_ACC') );
            END IF;
          END IF;
          l_b_ret_setup := FALSE;
          l_b_rec_setup := FALSE;
        END IF;

        l_v_fee_type := rec_upd_applications.fee_type;
        l_v_fee_cal_type := rec_upd_applications.fee_cal_type;
        l_n_fee_ci_sequence_number := rec_upd_applications.fee_ci_sequence_number;

        ret_invoice_tab(l_n_cntr).invoice_id := rec_upd_applications.invoice_id;
        ret_invoice_tab(l_n_cntr).ftci_rec_gl_ccid := rec_upd_applications.ftci_rec_gl_ccid;
        ret_invoice_tab(l_n_cntr).ftci_rec_account_cd := rec_upd_applications.ftci_rec_account_cd;
        ret_invoice_tab(l_n_cntr).ftci_ret_gl_ccid := rec_upd_applications.ftci_ret_gl_ccid;
        ret_invoice_tab(l_n_cntr).ftci_ret_account_cd := rec_upd_applications.ftci_ret_account_cd;
        l_n_cntr := l_n_cntr + 1;
      END IF; /* l_b_invoice_found */
    END LOOP;

    -- See whether you have any records to Upgrade
    IF ret_invoice_tab.COUNT = 0 THEN
      l_b_upgrade_done := TRUE;
      fnd_file.new_line(fnd_file.LOG );
      fnd_file.put_line( fnd_file.LOG, fnd_message.get_string('IGS', 'IGS_GE_NO_DATA_FOUND'));
      fnd_file.new_line(fnd_file.LOG );
    END IF;

    -----------------------
    -- Actual Upgrade Logic
    -----------------------

    -- Upgrade needs to be done only if we don't find any FTCIs with missing information.
    IF l_b_no_ftci_setup = FALSE AND ret_invoice_tab.COUNT > 0 THEN
      FOR l_n_cntr IN ret_invoice_tab.FIRST..ret_invoice_tab.LAST LOOP
        IF ret_invoice_tab.EXISTS(l_n_cntr) THEN

          -- ====== UPDATE Invoice Line Record. ====== --

          OPEN c_invoice_details( ret_invoice_tab(l_n_cntr).invoice_id );
          FETCH c_invoice_details INTO rec_invoice_details;
          CLOSE c_invoice_details;

          l_v_upd_rec_account_cd := NVL(NVL(rec_invoice_details.rec_account_cd, ret_invoice_tab(l_n_cntr).ftci_rec_account_cd), l_v_rec_account_cd_sys);
          l_n_upd_rec_gl_ccid := NVL( NVL(rec_invoice_details.rec_gl_ccid, ret_invoice_tab(l_n_cntr).ftci_rec_gl_ccid), l_n_rec_gl_ccid_sys);
          l_v_upd_rev_account_cd := NVL(rec_invoice_details.rev_account_cd, ret_invoice_tab(l_n_cntr).ftci_ret_account_cd);
          l_n_upd_rev_gl_ccid := NVL(rec_invoice_details.rev_gl_ccid, ret_invoice_tab(l_n_cntr).ftci_ret_gl_ccid);

          l_b_upd := FALSE;

          IF l_v_rec_installed = 'Y' THEN
            IF (((rec_invoice_details.rev_gl_ccid <> l_n_upd_rev_gl_ccid) OR (rec_invoice_details.rev_gl_ccid IS NULL)) OR
                ((rec_invoice_details.rec_gl_ccid <> l_n_upd_rec_gl_ccid) OR (rec_invoice_details.rec_gl_ccid IS NULL))) THEN
              l_b_upd := TRUE;
            END IF;
          ELSE
            IF (((rec_invoice_details.rev_account_cd <> l_v_upd_rev_account_cd) OR (rec_invoice_details.rev_account_cd IS NULL)) OR
                ((rec_invoice_details.rec_account_cd <> l_v_upd_rec_account_cd) OR (rec_invoice_details.rec_account_cd IS NULL))) THEN
              l_b_upd := TRUE;
            END IF;
          END IF;

          IF l_b_upd THEN
            l_b_upgrade_done := TRUE;
            igs_fi_invln_int_pkg.update_row( x_rowid                        => rec_invoice_details.rowid,
                                             x_invoice_id                   => rec_invoice_details.invoice_id,
                                             x_line_number                  => rec_invoice_details.line_number,
                                             x_invoice_lines_id             => rec_invoice_details.invoice_lines_id,
                                             x_attribute2                   => rec_invoice_details.attribute2,
                                             x_chg_elements                 => rec_invoice_details.chg_elements,
                                             x_amount                       => rec_invoice_details.amount,
                                             x_unit_attempt_status          => rec_invoice_details.unit_attempt_status,
                                             x_eftsu                        => rec_invoice_details.eftsu,
                                             x_credit_points                => rec_invoice_details.credit_points,
                                             x_attribute_category           => rec_invoice_details.attribute_category,
                                             x_attribute1                   => rec_invoice_details.attribute1,
                                             x_s_chg_method_type            => rec_invoice_details.s_chg_method_type,
                                             x_description                  => rec_invoice_details.description,
                                             x_attribute3                   => rec_invoice_details.attribute3,
                                             x_attribute4                   => rec_invoice_details.attribute4,
                                             x_attribute5                   => rec_invoice_details.attribute5,
                                             x_attribute6                   => rec_invoice_details.attribute6,
                                             x_attribute7                   => rec_invoice_details.attribute7,
                                             x_attribute8                   => rec_invoice_details.attribute8,
                                             x_attribute9                   => rec_invoice_details.attribute9,
                                             x_attribute10                  => rec_invoice_details.attribute10,
                                             x_rec_account_cd               => l_v_upd_rec_account_cd,
                                             x_rev_account_cd               => l_v_upd_rev_account_cd,
                                             x_rec_gl_ccid                  => l_n_upd_rec_gl_ccid,
                                             x_rev_gl_ccid                  => l_n_upd_rev_gl_ccid,
                                             x_org_unit_cd                  => rec_invoice_details.org_unit_cd,
                                             x_posting_id                   => rec_invoice_details.posting_id,
                                             x_attribute11                  => rec_invoice_details.attribute11,
                                             x_attribute12                  => rec_invoice_details.attribute12,
                                             x_attribute13                  => rec_invoice_details.attribute13,
                                             x_attribute14                  => rec_invoice_details.attribute14,
                                             x_attribute15                  => rec_invoice_details.attribute15,
                                             x_attribute16                  => rec_invoice_details.attribute16,
                                             x_attribute17                  => rec_invoice_details.attribute17,
                                             x_attribute18                  => rec_invoice_details.attribute18,
                                             x_attribute19                  => rec_invoice_details.attribute19,
                                             x_attribute20                  => rec_invoice_details.attribute20,
                                             x_error_string                 => rec_invoice_details.error_string,
                                             x_error_account                => 'N',
                                             x_location_cd                  => rec_invoice_details.location_cd,
                                             x_uoo_id                       => rec_invoice_details.uoo_id,
                                             x_gl_date                      => rec_invoice_details.gl_date,
                                             x_gl_posted_date               => rec_invoice_details.gl_posted_date,
                                             x_posting_control_id           => rec_invoice_details.posting_control_id,
                                             x_mode                         => 'R',
                                             x_unit_type_id                 => rec_invoice_details.unit_type_id,
                                             x_unit_level                   => rec_invoice_details.unit_level
                                             );

            fnd_file.new_line(fnd_file.LOG );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_charge_number || ': ' || igs_fi_gen_008.get_invoice_number(rec_invoice_details.invoice_id) );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_dr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(l_n_upd_rec_gl_ccid), l_v_upd_rec_account_cd) );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_cr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(l_n_upd_rev_gl_ccid), l_v_upd_rev_account_cd) );
            fnd_file.put_line(fnd_file.LOG, l_v_lkp_status || ' : ' || l_v_lkp_success );

            -- Check if this charge has been posted to GL Interface or Posting Interface
            IF rec_invoice_details.posting_control_id IS NOT NULL THEN
              IF l_v_rec_installed = 'Y' THEN
                FOR rec_gl_interface IN c_gl_interface( rec_invoice_details.invoice_lines_id, 'IGS_FI_INVLN_INT' ) LOOP

                  -- Update GL Interface with above derived accounting information
                  IF rec_gl_interface.accounted_dr IS NOT NULL
                     AND rec_gl_interface.code_combination_id IS NULL THEN

                    UPDATE gl_interface
                    SET code_combination_id = NVL(code_combination_id, l_n_upd_rec_gl_ccid)
                    WHERE rowid = rec_gl_interface.rowid;
                    l_b_upgrade_done := TRUE;

                  ELSIF rec_gl_interface.accounted_cr IS NOT NULL
                        AND rec_gl_interface.code_combination_id IS NULL THEN

                    UPDATE gl_interface
                    SET code_combination_id = NVL(code_combination_id, l_n_upd_rev_gl_ccid)
                    WHERE rowid = rec_gl_interface.rowid;
                    l_b_upgrade_done := TRUE;

                  END IF;

                END LOOP;

              ELSE -- GL is not Installed, so Check Posting Interface Table
                FOR rec_posting_int IN c_posting_int( rec_invoice_details.invoice_lines_id, 'CHARGE' ) LOOP
                  IF rec_posting_int.dr_account_cd IS NULL
                     OR rec_posting_int.cr_account_cd IS NULL THEN
                    l_b_upgrade_done := TRUE;
                    igs_fi_posting_int_pkg.update_row (
                              x_rowid                        => rec_posting_int.ROWID,
                              x_posting_control_id           => rec_posting_int.posting_control_id,
                              x_posting_id                   => rec_posting_int.posting_id,
                              x_batch_name                   => rec_posting_int.batch_name,
                              x_accounting_date              => rec_posting_int.accounting_date,
                              x_transaction_date             => rec_posting_int.transaction_date,
                              x_currency_cd                  => rec_posting_int.currency_cd,
                              x_dr_account_cd                => NVL(rec_posting_int.dr_account_cd, l_v_upd_rec_account_cd),
                              x_cr_account_cd                => NVL(rec_posting_int.cr_account_cd, l_v_upd_rev_account_cd),
                              x_dr_gl_code_ccid              => rec_posting_int.dr_gl_code_ccid,
                              x_cr_gl_code_ccid              => rec_posting_int.cr_gl_code_ccid,
                              x_amount                       => rec_posting_int.amount,
                              x_source_transaction_id        => rec_posting_int.source_transaction_id,
                              x_source_transaction_type      => rec_posting_int.source_transaction_type,
                              x_status                       => rec_posting_int.status,
                              x_orig_appl_fee_ref            => rec_posting_int.orig_appl_fee_ref,
                              x_mode                         => 'R');

                  END IF;
                END LOOP;
              END IF; /* GL Installed */
            END IF; /* Posting Control ID */
          END IF; /* End If for l_b_upd */

          -- ====== UPDATE Applications Records. ====== --

          FOR rec_application_details IN c_application_details ( ret_invoice_tab(l_n_cntr).invoice_id ) LOOP

            -- === Regular Payments/Credits applied to Rentention Charges  - Type 1
            -- === Targeted Applications of the Negative Charge Adjustments - Type 2

            IF l_v_accounting_method = 'ACCRUAL' THEN

              /*
               === Debit side: Unapplied ( From Credit ) -- Need not be upgraded as it comes from Credit Types
               === Credit side: Receivables ( From Charge )
              */
              l_v_upd_cr_account_cd := NVL(NVL(rec_application_details.cr_account_cd, ret_invoice_tab(l_n_cntr).ftci_rec_account_cd), l_v_rec_account_cd_sys);
              l_n_upd_cr_gl_code_ccid := NVL( NVL(rec_application_details.cr_gl_code_ccid, ret_invoice_tab(l_n_cntr).ftci_rec_gl_ccid), l_n_rec_gl_ccid_sys);

            ELSIF l_v_accounting_method = 'CASH' THEN

              /*
               === Debit side: Unapplied ( From Credit ) -- Need not be upgraded as it comes from Credit Types
               === Credit side: Revenue ( From Charge )
              */
              l_v_upd_cr_account_cd := NVL(rec_application_details.cr_account_cd, ret_invoice_tab(l_n_cntr).ftci_ret_account_cd);
              l_n_upd_cr_gl_code_ccid := NVL(rec_application_details.cr_gl_code_ccid, ret_invoice_tab(l_n_cntr).ftci_ret_gl_ccid);

            END IF; /* Accounting Method */

            l_b_upd := FALSE;

            IF l_v_rec_installed = 'Y' THEN
              IF ((rec_application_details.cr_gl_code_ccid <> l_n_upd_cr_gl_code_ccid) OR (rec_application_details.cr_gl_code_ccid IS NULL)) THEN
                l_b_upd := TRUE;
              END IF;
            ELSE
              IF ((rec_application_details.cr_account_cd <> l_v_upd_cr_account_cd) OR (rec_application_details.cr_account_cd IS NULL)) THEN
                l_b_upd := TRUE;
              END IF;
            END IF;

            IF l_b_upd THEN

              l_b_upgrade_done := TRUE;
              igs_fi_applications_pkg.update_row(x_rowid                          => rec_application_details.rowid,
                                                 x_application_id                 => rec_application_details.application_id,
                                                 x_application_type               => rec_application_details.application_type,
                                                 x_invoice_id                     => rec_application_details.invoice_id,
                                                 x_credit_id                      => rec_application_details.credit_id,
                                                 x_credit_activity_id             => rec_application_details.credit_activity_id,
                                                 x_amount_applied                 => rec_application_details.amount_applied,
                                                 x_apply_date                     => rec_application_details.apply_date,
                                                 x_link_application_id            => rec_application_details.link_application_id,
                                                 x_dr_account_cd                  => rec_application_details.dr_account_cd,
                                                 x_cr_account_cd                  => l_v_upd_cr_account_cd,
                                                 x_dr_gl_code_ccid                => rec_application_details.dr_gl_code_ccid,
                                                 x_cr_gl_code_ccid                => l_n_upd_cr_gl_code_ccid,
                                                 x_applied_invoice_lines_id       => rec_application_details.applied_invoice_lines_id,
                                                 x_appl_hierarchy_id              => rec_application_details.appl_hierarchy_id,
                                                 x_posting_id                     => rec_application_details.posting_id,
                                                 x_gl_date                        => rec_application_details.gl_date,
                                                 x_gl_posted_date                 => rec_application_details.gl_posted_date,
                                                 x_posting_control_id             => rec_application_details.posting_control_id);

              fnd_file.new_line(fnd_file.LOG );
              fnd_file.put_line(fnd_file.LOG, l_v_lkp_application_id || ': ' || rec_application_details.application_id );
              fnd_file.put_line(fnd_file.LOG, l_v_lkp_dr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(rec_application_details.dr_gl_code_ccid), rec_application_details.dr_account_cd) );
              fnd_file.put_line(fnd_file.LOG, l_v_lkp_cr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(l_n_upd_cr_gl_code_ccid), l_v_upd_cr_account_cd) );
              fnd_file.put_line(fnd_file.LOG, l_v_lkp_status || ' : ' || l_v_lkp_success );

              -- Check if this Application Record has been posted to GL Interface or Posting Interface
              IF rec_application_details.posting_control_id IS NOT NULL THEN
                IF l_v_rec_installed = 'Y' THEN
                  FOR rec_gl_interface IN c_gl_interface( rec_application_details.application_id, 'IGS_FI_APPLICATIONS' ) LOOP
                    IF rec_application_details.application_type = 'APP'
                       AND rec_gl_interface.accounted_cr IS NOT NULL
                       AND rec_gl_interface.code_combination_id IS NULL THEN
                      UPDATE gl_interface
                      SET code_combination_id = NVL(code_combination_id, l_n_upd_cr_gl_code_ccid)
                      WHERE rowid = rec_gl_interface.rowid;
                      l_b_upgrade_done := TRUE;

                    -- This code is executed for UNAPP Record transfered to GL.
                    ELSIF rec_application_details.application_type = 'UNAPP'
                          AND rec_gl_interface.accounted_dr IS NOT NULL
                          AND rec_gl_interface.code_combination_id IS NULL THEN
                      UPDATE gl_interface
                      SET code_combination_id = NVL(code_combination_id, l_n_upd_cr_gl_code_ccid)
                      WHERE rowid = rec_gl_interface.rowid;
                      l_b_upgrade_done := TRUE;
                    END IF;
                  END LOOP;

                ELSE -- GL is not Installed, so Check Posting Interface Table
                  FOR rec_posting_int IN c_posting_int( rec_application_details.application_id, 'APPLICATION' ) LOOP
                    IF rec_posting_int.dr_account_cd IS NULL
                       OR rec_posting_int.cr_account_cd IS NULL THEN
                      IF rec_application_details.application_type = 'UNAPP' THEN
                        l_v_upd_dr_account_cd := NVL(rec_posting_int.dr_account_cd, l_v_upd_cr_account_cd); -- For UNAPP, rec_posting_int.dr_account_cd will be NULL
                        l_v_upd_cr_account_cd := rec_posting_int.cr_account_cd;
                      ELSE
                        l_v_upd_dr_account_cd := rec_posting_int.dr_account_cd;
                        l_v_upd_cr_account_cd := NVL(rec_posting_int.cr_account_cd, l_v_upd_cr_account_cd); -- For App, rec_posting_int.cr_account_cd will be NULL
                      END IF;

                      l_b_upgrade_done := TRUE;
                      igs_fi_posting_int_pkg.update_row (
                                x_rowid                        => rec_posting_int.ROWID,
                                x_posting_control_id           => rec_posting_int.posting_control_id,
                                x_posting_id                   => rec_posting_int.posting_id,
                                x_batch_name                   => rec_posting_int.batch_name,
                                x_accounting_date              => rec_posting_int.accounting_date,
                                x_transaction_date             => rec_posting_int.transaction_date,
                                x_currency_cd                  => rec_posting_int.currency_cd,
                                x_dr_account_cd                => l_v_upd_dr_account_cd,
                                x_cr_account_cd                => l_v_upd_cr_account_cd,
                                x_dr_gl_code_ccid              => rec_posting_int.dr_gl_code_ccid,
                                x_cr_gl_code_ccid              => rec_posting_int.cr_gl_code_ccid,
                                x_amount                       => rec_posting_int.amount,
                                x_source_transaction_id        => rec_posting_int.source_transaction_id,
                                x_source_transaction_type      => rec_posting_int.source_transaction_type,
                                x_status                       => rec_posting_int.status,
                                x_orig_appl_fee_ref            => rec_posting_int.orig_appl_fee_ref,
                                x_mode                         => 'R');
                    END IF;
                  END LOOP;
                END IF; /* GL Installed */
              END IF; /* Posting Control ID */

              -- ====== UPDATE Credit Activity Records. ====== --

              IF l_v_accounting_method = 'ACCRUAL' AND get_credit_class( rec_application_details.credit_id ) = 'CHGADJ' THEN
                OPEN c_cr_act_details( rec_application_details.credit_id );
                FETCH c_cr_act_details INTO rec_cr_act_details;
                CLOSE c_cr_act_details;

                l_v_upd_dr_account_cd := NVL( rec_cr_act_details.dr_account_cd, ret_invoice_tab(l_n_cntr).ftci_ret_account_cd );
                l_n_upd_dr_gl_ccid := NVL( rec_cr_act_details.dr_gl_ccid, ret_invoice_tab(l_n_cntr).ftci_ret_gl_ccid );

                l_b_upd := FALSE;
                IF l_v_rec_installed = 'Y' THEN
                  IF ((l_n_upd_dr_gl_ccid <> rec_cr_act_details.dr_gl_ccid) OR (rec_cr_act_details.dr_gl_ccid IS NULL)) THEN
                    l_b_upd := TRUE;
                  END IF;
                ELSE
                  IF ((l_v_upd_dr_account_cd <> rec_cr_act_details.dr_account_cd) OR (rec_cr_act_details.dr_account_cd IS NULL)) THEN
                    l_b_upd := TRUE;
                  END IF;
                END IF;

                IF l_b_upd = TRUE THEN
                  l_b_upgrade_done := TRUE;
                  igs_fi_cr_activities_pkg.update_row(x_rowid                   => rec_cr_act_details.rowid,
                                                      x_credit_activity_id      => rec_cr_act_details.credit_activity_id,
                                                      x_credit_id               => rec_cr_act_details.credit_id,
                                                      x_status                  => rec_cr_act_details.status,
                                                      x_transaction_date        => rec_cr_act_details.transaction_date,
                                                      x_amount                  => rec_cr_act_details.amount,
                                                      x_dr_account_cd           => l_v_upd_dr_account_cd,
                                                      x_cr_account_cd           => rec_cr_act_details.cr_account_cd,
                                                      x_dr_gl_ccid              => l_n_upd_dr_gl_ccid,
                                                      x_cr_gl_ccid              => rec_cr_act_details.cr_gl_ccid,
                                                      x_bill_id                 => rec_cr_act_details.bill_id,
                                                      x_bill_number             => rec_cr_act_details.bill_number,
                                                      x_bill_date               => rec_cr_act_details.bill_date,
                                                      x_posting_id              => rec_cr_act_details.posting_id,
                                                      x_posting_control_id      => rec_cr_act_details.posting_control_id,
                                                      x_gl_date                 => rec_cr_act_details.gl_date,
                                                      x_gl_posted_date          => rec_cr_act_details.gl_posted_date);


                  fnd_file.new_line(fnd_file.LOG );
                  fnd_file.put_line(fnd_file.LOG, l_v_lkp_credit_number || ': ' || get_credit_number(rec_cr_act_details.credit_id) );
                  fnd_file.put_line(fnd_file.LOG, l_v_lkp_dr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(l_n_upd_dr_gl_ccid), l_v_upd_dr_account_cd) );
                  fnd_file.put_line(fnd_file.LOG, l_v_lkp_cr_account || ': ' || NVL(igs_fi_gen_007.get_ccid_concat(rec_cr_act_details.cr_gl_ccid), rec_cr_act_details.cr_account_cd) );
                  fnd_file.put_line(fnd_file.LOG, l_v_lkp_status || ' : ' || l_v_lkp_success );

                  -- Check if this Credit Activity Record has been posted to GL Interface or Posting Interface
                  IF rec_cr_act_details.posting_control_id IS NOT NULL THEN
                    IF l_v_rec_installed = 'Y' THEN

                      FOR rec_gl_interface IN c_gl_interface( rec_cr_act_details.credit_activity_id, 'IGS_FI_CR_ACTIVITIES' ) LOOP
                        IF rec_gl_interface.accounted_dr IS NOT NULL
                           AND rec_gl_interface.code_combination_id IS NULL THEN
                          UPDATE gl_interface
                          SET code_combination_id = NVL(code_combination_id, l_n_upd_dr_gl_ccid)
                          WHERE rowid = rec_gl_interface.rowid;
                          l_b_upgrade_done := TRUE;
                        END IF;
                      END LOOP;

                    ELSE -- GL is not Installed, so Check Posting Interface Table
                      FOR rec_posting_int IN c_posting_int( rec_cr_act_details.credit_activity_id, 'CREDIT' ) LOOP
                        IF rec_posting_int.dr_account_cd IS NULL THEN
                          l_b_upgrade_done := TRUE;
                          igs_fi_posting_int_pkg.update_row (
                                    x_rowid                        => rec_posting_int.ROWID,
                                    x_posting_control_id           => rec_posting_int.posting_control_id,
                                    x_posting_id                   => rec_posting_int.posting_id,
                                    x_batch_name                   => rec_posting_int.batch_name,
                                    x_accounting_date              => rec_posting_int.accounting_date,
                                    x_transaction_date             => rec_posting_int.transaction_date,
                                    x_currency_cd                  => rec_posting_int.currency_cd,
                                    x_dr_account_cd                => NVL(rec_posting_int.dr_account_cd, l_v_upd_dr_account_cd),
                                    x_cr_account_cd                => rec_posting_int.cr_account_cd,
                                    x_dr_gl_code_ccid              => rec_posting_int.dr_gl_code_ccid,
                                    x_cr_gl_code_ccid              => rec_posting_int.cr_gl_code_ccid,
                                    x_amount                       => rec_posting_int.amount,
                                    x_source_transaction_id        => rec_posting_int.source_transaction_id,
                                    x_source_transaction_type      => rec_posting_int.source_transaction_type,
                                    x_status                       => rec_posting_int.status,
                                    x_orig_appl_fee_ref            => rec_posting_int.orig_appl_fee_ref,
                                    x_mode                         => 'R');

                        END IF;
                      END LOOP;
                    END IF; /* GL Installed */
                  END IF; /* Posting Control ID */
                END IF; /* l_b_upd */
              END IF; /* Accounting Method and Credit Class */

            END IF; /* l_b_upd */
          END LOOP; /* Updation of Application Records */
        END IF; /* ret_invoice_tab.EXISTS(l_n_cntr) */
      END LOOP;

      COMMIT;

    ELSIF l_b_no_ftci_setup = TRUE THEN
      retcode := 1;
      RETURN;
    END IF; /* l_b_no_ftci_setup = FALSE AND ret_invoice_tab.COUNT > 0 */

    IF l_b_upgrade_done = FALSE THEN
      fnd_file.put_line( fnd_file.LOG, l_v_lkp_status || ' : ' || l_v_lkp_error );
    END IF;

  EXCEPTION

    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      errbuf  := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||sqlerrm;
      igs_ge_msg_stack.conc_exception_hndl;

  END upg_accts;

END igs_fi_upg_retention;

/
