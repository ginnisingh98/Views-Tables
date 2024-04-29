--------------------------------------------------------
--  DDL for Package Body IGS_FI_1098T_EXTRACT_DATA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_1098T_EXTRACT_DATA" AS
/* $Header: IGSFI91B.pls 120.11 2006/06/27 14:15:37 skharida noship $ */

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   14-Apr-2005
     Purpose         :   Package for the 1098T Extract Data

     Known limitations,enhancements,remarks:
     Change History
     Who            When          What
     skharida       26/06/2006   Bug 5208136  Modified procedures with new igs_fi_inv_int_pkg signatiure.
     skharida       22/05/2006   Bug 5213590: Added changes to check for waiver name for box 4,5 charges
                                  and credits
     abshriva       12/05/2006   Bug 5217319: Amount Precision changein extract_data_main
     abshriva       30/11/05     Bug:4768071 - Modification made in procedure 'insert_1098t_data'
     agairola       23/11/05      Bug:4747419 - Modified box45_credits and box45_charges
     abshriva       9/11/05       Bug:4695680-Modification made in procedure'insert_1098t_data'
     abshriva       26/10/05      Bug: 4697644-Modification made in procedure 'insert_1098t_data'
    ***************************************************************** */

  g_v_label_tax_year             igs_lookup_values.meaning%TYPE;
  g_v_label_person               igs_lookup_values.meaning%TYPE;
  g_v_label_persgrp              igs_lookup_values.meaning%TYPE;
  g_v_label_override_excl        igs_lookup_values.meaning%TYPE;
  g_v_label_file_addr            igs_lookup_values.meaning%TYPE;
  g_v_label_test_run             igs_lookup_values.meaning%TYPE;
  g_v_label_stdnt_name           igs_lookup_values.meaning%TYPE;
  g_v_line_sep                   CONSTANT  VARCHAR2(100) := '+'||RPAD('-',75,'-')||'+';

  g_b_non_zero_credits_flag      BOOLEAN;
  g_b_chg_crd_found              BOOLEAN;

  g_v_validation_status          igs_fi_1098t_data.status_code%TYPE;

  g_v_label_name_control         igs_lookup_values.meaning%TYPE;
  g_v_label_tin                  igs_lookup_values.meaning%TYPE;
  g_v_label_val_status           igs_lookup_values.meaning%TYPE;
  g_v_label_err_desc             igs_lookup_values.meaning%TYPE;
  g_v_label_correct_ret          igs_lookup_values.meaning%TYPE;
  g_v_label_box2                 igs_lookup_values.meaning%TYPE;
  g_v_label_box3                 igs_lookup_values.meaning%TYPE;
  g_v_label_box4                 igs_lookup_values.meaning%TYPE;
  g_v_label_box5                 igs_lookup_values.meaning%TYPE;
  g_v_label_box6                 igs_lookup_values.meaning%TYPE;
  g_v_label_box8                 igs_lookup_values.meaning%TYPE;
  g_v_label_box9                 igs_lookup_values.meaning%TYPE;
  g_v_label_boxval               igs_lookup_values.meaning%TYPE;

  g_v_package_name               VARCHAR2(100) := 'igs.plsql.igs_fi_1098t_extract_data.';

  e_resource_busy      EXCEPTION;

  PRAGMA EXCEPTION_INIT(e_resource_busy, -0054);

  CURSOR cur_1098t_setup(cp_v_tax_year_name    igs_fi_1098t_setup.tax_year_name%TYPE) IS
    SELECT *
    FROM   igs_fi_1098t_setup
    WHERE  tax_year_name = cp_v_tax_year_name;

  CURSOR cur_chk_1098t_sfts(cp_v_tax_year_name      igs_fi_1098t_setup.tax_year_name%TYPE,
                            cp_v_sys_fund_type      igf_aw_fund_cat_all.sys_fund_type%TYPE) IS
    SELECT 'x'
    FROM   igs_fi_1098t_sfts
    WHERE  tax_year_name  = cp_v_tax_year_name
    AND    sys_fund_type  = cp_v_sys_fund_type;

  g_rec_1098t_setup    cur_1098t_setup%ROWTYPE;

  TYPE r_1098t_drilldown IS RECORD(transaction_id       igs_fi_1098t_dtls.transaction_id%TYPE,
                                   transaction_code     igs_fi_1098t_dtls.transaction_code%TYPE,
                                   box_num              igs_fi_1098t_dtls.box_num%TYPE);
  TYPE t_1098t_drilldown IS TABLE OF r_1098t_drilldown
  INDEX BY BINARY_INTEGER;

  l_t_1098t_drilldown      t_1098t_drilldown;
  l_n_cntr                 PLS_INTEGER;

  PROCEDURE log_to_fnd ( p_v_module IN VARCHAR2,
                         p_v_string IN VARCHAR2 ) IS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for logging

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN

    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, g_v_package_name||p_v_module, p_v_string);
    END IF;

  END log_to_fnd;

  PROCEDURE set_validation_status(p_v_validation_status       VARCHAR2) AS
      /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for setting validation status

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN
    IF g_v_validation_status <> 'DNT_RPT' OR g_v_validation_status IS NULL THEN
      g_v_validation_status := p_v_validation_status;
    END IF;
  END set_validation_status;

  FUNCTION validate_namecontrol(p_v_name_control        igs_fi_1098t_data.stu_name_control%TYPE) RETURN VARCHAR2 AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for validating Name Control

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_v_ret_val     VARCHAR2(1);
    l_n_asc_val     NUMBER;
  BEGIN
    l_v_ret_val := 'Y';

-- If Name Control is Null,return 'Y'
    IF p_v_name_control IS NULL THEN
      RETURN 'Y';
    END IF;

-- If the length of Name Control is > 4, then return N
    IF LENGTH(p_v_name_control) > 4 THEN
      RETURN 'N';
    END IF;

-- Check for invalid characters. Valid characters are
-- 0 to 9, A to Z, a to z , ampersand and -

    FOR l_n_strlen IN 1..LENGTH(p_v_name_control) LOOP
      l_n_asc_val := ASCII(SUBSTR(p_v_name_control,l_n_strlen,1));
      IF NOT ((l_n_asc_val BETWEEN 48 AND 57) OR
              (l_n_asc_val BETWEEN 65 AND 90) OR
              (l_n_asc_val BETWEEN 97 AND 122) OR
              (l_n_asc_val IN (38,45))) THEN
        l_v_ret_val := 'N';
        EXIT;
      END IF;
    END LOOP;

    RETURN l_v_ret_val;
  END validate_namecontrol;

  FUNCTION validate_tin(p_v_api_pers_id                igs_pe_alt_pers_id.api_person_id%TYPE) RETURN BOOLEAN AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   04-Aug-2005
     Purpose         :   Procedure for validating TIN

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_n_cntr      NUMBER(5);
    l_v_str1      VARCHAR2(1);

    l_b_bool      BOOLEAN;
  BEGIN
    l_v_str1 := SUBSTR(p_v_api_pers_id,1,1);

    l_b_bool := FALSE;

    FOR l_n_cntr IN 2..LENGTH(p_v_api_pers_id) LOOP
      IF l_v_str1 <> SUBSTR(p_v_api_pers_id,l_n_cntr,1) THEN
        l_b_bool := TRUE;
        EXIT;
      END IF;
    END LOOP;

    RETURN l_b_bool;
  END validate_tin;

  PROCEDURE update_credits(p_n_person_id                 igs_pe_person_base_v.person_id%TYPE,
                           p_v_tax_year                  igs_fi_1098t_setup.tax_year_code%TYPE) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for updating Credits

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */

-- Cursor for selecting all the records from the credits table for the person id
-- having the tax_year_name as the current tax year
    CURSOR cur_crd(cp_n_person_id        igs_pe_person_base_v.person_id%TYPE,
                   cp_v_tax_year         igs_fi_1098t_setup.tax_year_code%TYPE) IS
      SELECT crd.rowid row_id,
             crd.*
      FROM   igs_fi_credits_all crd
      WHERE  party_id      = cp_n_person_id
      AND    tax_year_code = cp_v_tax_year
      FOR UPDATE OF tax_year_code NOWAIT;


  BEGIN
    log_to_fnd(p_v_module  => 'update_credits',
               p_v_string  => 'Updating Credit transactions');

    FOR l_rec_crd IN cur_crd(p_n_person_id,
                             p_v_tax_year) LOOP
      igs_fi_credits_pkg.update_row(x_rowid                       => l_rec_crd.row_id,
                                    x_credit_id                   => l_rec_crd.credit_id,
                                    x_credit_number               => l_rec_crd.credit_number,
                                    x_status                      => l_rec_crd.status,
                                    x_credit_source               => l_rec_crd.credit_source,
                                    x_party_id                    => l_rec_crd.party_id,
                                    x_credit_type_id              => l_rec_crd.credit_type_id,
                                    x_credit_instrument           => l_rec_crd.credit_instrument,
                                    x_description                 => l_rec_crd.description,
                                    x_amount                      => l_rec_crd.amount,
                                    x_currency_cd                 => l_rec_crd.currency_cd,
                                    x_exchange_rate               => l_rec_crd.exchange_rate,
                                    x_transaction_date            => l_rec_crd.transaction_date,
                                    x_effective_date              => l_rec_crd.effective_date,
                                    x_reversal_date               => l_rec_crd.reversal_date,
                                    x_reversal_reason_code        => l_rec_crd.reversal_reason_code,
                                    x_reversal_comments           => l_rec_crd.reversal_comments,
                                    x_unapplied_amount            => l_rec_crd.unapplied_amount,
                                    x_source_transaction_id       => l_rec_crd.source_transaction_id,
                                    x_receipt_lockbox_number      => l_rec_crd.receipt_lockbox_number,
                                    x_merchant_id                 => l_rec_crd.merchant_id,
                                    x_credit_card_code            => l_rec_crd.credit_card_code,
                                    x_credit_card_holder_name     => l_rec_crd.credit_card_holder_name,
                                    x_credit_card_number          => l_rec_crd.credit_card_number,
                                    x_credit_card_expiration_date => l_rec_crd.credit_card_expiration_date,
                                    x_credit_card_approval_code   => l_rec_crd.credit_card_approval_code,
                                    x_awd_yr_cal_type             => l_rec_crd.awd_yr_cal_type,
                                    x_awd_yr_ci_sequence_number   => l_rec_crd.awd_yr_ci_sequence_number,
                                    x_fee_cal_type                => l_rec_crd.fee_cal_type,
                                    x_fee_ci_sequence_number      => l_rec_crd.fee_ci_sequence_number,
                                    x_attribute_category          => l_rec_crd.attribute_category,
                                    x_attribute1                  => l_rec_crd.attribute1,
                                    x_attribute2                  => l_rec_crd.attribute2,
                                    x_attribute3                  => l_rec_crd.attribute3,
                                    x_attribute4                  => l_rec_crd.attribute4,
                                    x_attribute5                  => l_rec_crd.attribute5,
                                    x_attribute6                  => l_rec_crd.attribute6,
                                    x_attribute7                  => l_rec_crd.attribute7,
                                    x_attribute8                  => l_rec_crd.attribute8,
                                    x_attribute9                  => l_rec_crd.attribute9,
                                    x_attribute10                 => l_rec_crd.attribute10,
                                    x_attribute11                 => l_rec_crd.attribute11,
                                    x_attribute12                 => l_rec_crd.attribute12,
                                    x_attribute13                 => l_rec_crd.attribute13,
                                    x_attribute14                 => l_rec_crd.attribute14,
                                    x_attribute15                 => l_rec_crd.attribute15,
                                    x_attribute16                 => l_rec_crd.attribute16,
                                    x_attribute17                 => l_rec_crd.attribute17,
                                    x_attribute18                 => l_rec_crd.attribute18,
                                    x_attribute19                 => l_rec_crd.attribute19,
                                    x_attribute20                 => l_rec_crd.attribute20,
                                    x_gl_date                     => l_rec_crd.gl_date,
                                    x_check_number                => l_rec_crd.check_number,
                                    x_source_transaction_type     => l_rec_crd.source_transaction_type,
                                    x_source_transaction_ref      => l_rec_crd.source_transaction_ref,
                                    x_credit_card_status_code     => l_rec_crd.credit_card_status_code,
                                    x_credit_card_payee_cd        => l_rec_crd.credit_card_payee_cd,
                                    x_credit_card_tangible_cd     => l_rec_crd.credit_card_tangible_cd,
                                    x_lockbox_interface_id        => l_rec_crd.lockbox_interface_id,
                                    x_batch_name                  => l_rec_crd.batch_name,
                                    x_deposit_date                => l_rec_crd.deposit_date,
                                    x_source_invoice_id           => l_rec_crd.source_invoice_id,
                                    x_tax_year_code               => null,
                                    x_waiver_name                 => l_rec_crd.waiver_name);
    END LOOP;
  END update_credits;

  PROCEDURE  update_charges(p_n_person_id                 igs_pe_person_base_v.person_id%TYPE,
                            p_v_tax_year                  igs_fi_1098t_setup.tax_year_code%TYPE) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for updating Charges

     Known limitations,enhancements,remarks:
     Change History
     Who     When         What
     skharida 26-Jun-2006    Bug 5208136 - Removed the obsoleted columns of the table IGS_FI_INV_INT_ALL
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */

-- Cursor for selecting all the Charge records for the person and tax year.
    CURSOR cur_chg(cp_n_person_id        igs_pe_person_base_v.person_id%TYPE,
                   cp_v_tax_year         igs_fi_1098t_setup.tax_year_code%TYPE) IS
      SELECT inv.rowid row_id, inv.*
      FROM   igs_fi_inv_int_all inv
      WHERE  person_id     = cp_n_person_id
      AND    tax_year_code = cp_v_tax_year
      FOR UPDATE OF tax_year_code NOWAIT;

  BEGIN
    log_to_fnd(p_v_module  => 'update_charges',
               p_v_string  => 'Updating Charge transactions');

    FOR l_rec_chg IN cur_chg(p_n_person_id,
                             p_v_tax_year) LOOP
      igs_fi_inv_int_pkg.update_row(x_rowid                         => l_rec_chg.row_id,
                                    x_invoice_id                    => l_rec_chg.invoice_id,
                                    x_person_id                     => l_rec_chg.person_id,
                                    x_fee_type                      => l_rec_chg.fee_type,
                                    x_fee_cat                       => l_rec_chg.fee_cat,
                                    x_fee_cal_type                  => l_rec_chg.fee_cal_type,
                                    x_fee_ci_sequence_number        => l_rec_chg.fee_ci_sequence_number,
                                    x_course_cd                     => l_rec_chg.course_cd,
                                    x_attendance_mode               => l_rec_chg.attendance_mode,
                                    x_attendance_type               => l_rec_chg.attendance_type,
                                    x_invoice_amount_due            => l_rec_chg.invoice_amount_due,
                                    x_invoice_creation_date         => l_rec_chg.invoice_creation_date,
                                    x_invoice_desc                  => l_rec_chg.invoice_desc,
                                    x_transaction_type              => l_rec_chg.transaction_type,
                                    x_currency_cd                   => l_rec_chg.currency_cd,
                                    x_status                        => l_rec_chg.status,
                                    x_attribute_category            => l_rec_chg.attribute_category,
                                    x_attribute1                    => l_rec_chg.attribute1,
                                    x_attribute2                    => l_rec_chg.attribute2,
                                    x_attribute3                    => l_rec_chg.attribute3,
                                    x_attribute4                    => l_rec_chg.attribute4,
                                    x_attribute5                    => l_rec_chg.attribute5,
                                    x_attribute6                    => l_rec_chg.attribute6,
                                    x_attribute7                    => l_rec_chg.attribute7,
                                    x_attribute8                    => l_rec_chg.attribute8,
                                    x_attribute9                    => l_rec_chg.attribute9,
                                    x_attribute10                   => l_rec_chg.attribute10,
                                    x_invoice_amount                => l_rec_chg.invoice_amount,
                                    x_bill_id                       => l_rec_chg.bill_id,
                                    x_bill_number                   => l_rec_chg.bill_number,
                                    x_bill_date                     => l_rec_chg.bill_date,
                                    x_waiver_flag                   => l_rec_chg.waiver_flag,
                                    x_waiver_reason                 => l_rec_chg.waiver_reason,
                                    x_effective_date                => l_rec_chg.effective_date,
                                    x_invoice_number                => l_rec_chg.invoice_number,
                                    x_exchange_rate                 => l_rec_chg.exchange_rate,
                                    x_bill_payment_due_date         => l_rec_chg.bill_payment_due_date,
                                    x_optional_fee_flag             => l_rec_chg.optional_fee_flag,
                                    x_reversal_gl_date              => l_rec_chg.reversal_gl_date,
                                    x_tax_year_code                 => NULL,
                                    x_waiver_name                   => l_rec_chg.waiver_name);
    END LOOP;
  END update_charges;

  FUNCTION chk_prior_lps(p_v_load_cal_type        igs_ca_inst.cal_type%TYPE,
                         p_n_load_ci_seq          igs_ca_inst.sequence_number%TYPE,
                         p_d_txn_date             DATE) RETURN BOOLEAN AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for checking Prior Load Period

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */

    CURSOR cur_prior_lps(cp_v_load_cal_type        igs_ca_inst.cal_type%TYPE,
                         cp_n_load_ci_seq_num      igs_ca_inst.sequence_number%TYPE,
                         cp_d_end_date             igs_fi_1098t_setup.end_date%TYPE) IS
      SELECT stp.tax_year_name
      FROM   igs_fi_1098t_lps lps,
             igs_fi_1098t_setup stp
      WHERE  lps.cal_type = cp_v_load_cal_type
      AND    lps.sequence_number = cp_n_load_ci_seq_num
      AND    lps.tax_year_name   = stp.tax_year_name
      AND    TRUNC(stp.end_date) <= TRUNC(cp_d_end_date)
      ORDER BY stp.end_date DESC;

    l_b_ret_val        BOOLEAN;
    l_rec_prior_lps    cur_prior_lps%ROWTYPE;
    l_b_rec_found      BOOLEAN;
  BEGIN
    log_to_fnd(p_v_module  => 'chk_prior_lps',
               p_v_string  => 'Checking Prior Load Period for Load Cal = '||p_v_load_cal_type||' and seq '||p_n_load_ci_seq);
    l_b_ret_val := TRUE;
    l_b_rec_found := FALSE;

-- Select the Latest Tax Year for which the Load Period is associated
    OPEN cur_prior_lps(p_v_load_cal_type,
                       p_n_load_ci_seq,
                       g_rec_1098t_setup.end_date);
    FETCH cur_prior_lps INTO l_rec_prior_lps;
    IF cur_prior_lps%FOUND THEN
      l_b_rec_found := TRUE;
    END IF;
    CLOSE cur_prior_lps;

-- If this load period is not associated to any tax year, then
-- it should not be reported
    IF NOT l_b_rec_found THEN
      RETURN FALSE;
    END IF;

-- IF the Transaction Date is between the Tax Year Start Date and End Date then
    IF TRUNC(p_d_txn_date) BETWEEN TRUNC(g_rec_1098t_setup.start_date) AND
                                   TRUNC(g_rec_1098t_setup.end_date) THEN

-- If there was a record found then report the transaction
      IF l_b_rec_found THEN
        l_b_ret_val := TRUE;
      END IF;

-- The Transaction Date is earlier than the start date of the tax year in context
    ELSE

-- If the latest tax year value is Null, then this should return false.
      IF l_rec_prior_lps.tax_year_name <> g_rec_1098t_setup.tax_year_name THEN
        log_to_fnd(p_v_module  => 'chk_prior_lps',
                   p_v_string  => 'Tax Year fetched '||l_rec_prior_lps.tax_year_name||' does not match with current tax year');
        l_b_ret_val := FALSE;
      END IF;
    END IF;

    RETURN l_b_ret_val;
  END chk_prior_lps;

  PROCEDURE init AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for initializing

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN

-- Initialize the different global variables

    log_to_fnd(p_v_module  => 'Init',
               p_v_string  => 'Initializing variables');
    g_v_label_tax_year := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'TAX_YEAR');
    g_v_label_person   := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'PERSON');
    g_v_label_persgrp  := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'PERSON_GROUP');
    g_v_label_override_excl := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                             'OVERRIDE_EXCL');
    g_v_label_file_addr := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                         'FILE_CORRECTION');
    g_v_label_test_run := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'TEST_RUN');
    g_v_label_stdnt_name := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                          'STUDENT_NAME');

    g_v_label_name_control :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'NAME_CONTROL');
    g_v_label_tin          :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'TIN');
    g_v_label_val_status   :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'VAL_STATUS');
    g_v_label_err_desc     :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'ERR_DESC');
    g_v_label_correct_ret  :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'CORRECTED_RETURN');
    g_v_label_box2         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX2');
    g_v_label_box3         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX3');
    g_v_label_box4         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX4');
    g_v_label_box5         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX5');
    g_v_label_box6         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX6');
    g_v_label_box8         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX8');
    g_v_label_box9         :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOX9');
    g_v_label_boxval       :=    igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                               'BOXVAL');
  END init;

  PROCEDURE log_line(p_v_parm_name               VARCHAR2,
                     p_v_parm_value              VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for logging a line

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      p_v_parm_name||' : '||p_v_parm_value);
  END log_line;

  FUNCTION chk_non_credit_course(p_n_person_id         igs_pe_person_base_v.person_id%TYPE,
                                 p_v_override_excl     VARCHAR2,
                                 p_v_load_cal_type     igs_ca_inst.cal_type%TYPE,
                                 p_n_load_ci_seq       igs_ca_inst.sequence_number%TYPE) RETURN BOOLEAN AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for checking Non Credit Courses

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_v_attendance          igs_en_atd_type.attendance_type%TYPE;
    l_n_credit_pts          igs_fi_invln_int.credit_points%TYPE;
    l_n_fte                 igs_fi_invln_int.eftsu%TYPE;
  BEGIN
    IF p_v_override_excl = 'N' THEN
      IF g_rec_1098t_setup.excl_non_credit_course_flag = 'Y' THEN

-- Call EN API for Institution Attendance Type
        igs_en_prc_load.enrp_get_inst_latt(p_person_id             => p_n_person_id,
                                           p_load_cal_type         => p_v_load_cal_type,
                                           p_load_seq_number       => p_n_load_ci_seq,
                                           p_attendance            => l_v_attendance,
                                           p_credit_points         => l_n_credit_pts,
                                           p_fte                   => l_n_fte);

-- If there are some credit points, then return true else return false
        IF l_n_credit_pts > 0 THEN
          RETURN TRUE;
        ELSE
          RETURN FALSE;
        END IF;
      END IF;
    END IF;

    RETURN TRUE;
  END chk_non_credit_course;

  PROCEDURE log_params(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                       p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                       p_n_person_grp_id        igs_pe_persid_group_all.group_id%TYPE,
                       p_v_override_excl        VARCHAR2,
                       p_v_file_addr_correction VARCHAR2,
                       p_v_test_run             VARCHAR2) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for logging parameters

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_v_party_number       hz_parties.party_number%TYPE;

    CURSOR cur_persid_grp(cp_n_person_grp_id   igs_pe_persid_group_all.group_id%TYPE) IS
      SELECT group_cd
      FROM   igs_pe_persid_group_all
      WHERE  group_id = cp_n_person_grp_id;

    l_v_group_cd       igs_pe_persid_group_all.group_cd%TYPE;
  BEGIN

-- Log the parameters
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get_string('IGS',
                                             'IGS_FI_ANC_LOG_PARM'));
    log_line(g_v_label_tax_year, p_v_tax_year_name);

    IF p_n_person_id IS NOT NULL THEN
      l_v_party_number := igs_fi_gen_008.get_party_number(p_n_person_id);
    END IF;

    log_line(g_v_label_person, l_v_party_number);

    IF p_n_person_grp_id IS NOT NULL THEN
      OPEN cur_persid_grp(p_n_person_grp_id);
      FETCH cur_persid_grp INTO l_v_group_cd;
      CLOSE cur_persid_grp;
    END IF;
    log_line(g_v_label_persgrp, l_v_group_cd);

    log_line(g_v_label_override_excl,
             igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_v_override_excl));

    log_line(g_v_label_file_addr,
             igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_v_file_addr_correction));

    log_line(g_v_label_test_run,
             igs_fi_gen_gl.get_lkp_meaning('YES_NO',p_v_test_run));
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
  END log_params;

  FUNCTION validate_params(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                           p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                           p_n_person_grp_id        igs_pe_persid_group_all.group_id%TYPE,
                           p_v_override_excl        VARCHAR2,
                           p_v_file_addr_correction VARCHAR2,
                           p_v_test_run             VARCHAR2) RETURN BOOLEAN AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for validating Parameters

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_b_validate   BOOLEAN;
    l_c_val        VARCHAR2(1);

    CURSOR cur_val_person_id(cp_n_person_id    igs_pe_person_base_v.person_id%TYPE) IS
      SELECT 'x'
      FROM igs_pe_person_base_v
      WHERE person_id = cp_n_person_id;

    CURSOR cur_val_persgrp(cp_n_pers_grp_id    igs_pe_persid_group_all.group_id%TYPE,
                           cp_v_closed_ind     igs_pe_persid_group_all.closed_ind%TYPE) IS
      SELECT 'x'
      FROM igs_pe_persid_group_all
      WHERE group_id = cp_n_pers_grp_id
      AND closed_ind = cp_v_closed_ind;

    CURSOR cur_val_one_lps(cp_v_tax_year_name    igs_fi_1098t_setup.tax_year_name%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_1098t_lps
      WHERE  tax_year_name = cp_v_tax_year_name;

    CURSOR cur_val_one_ft(cp_v_tax_year_name    igs_fi_1098t_setup.tax_year_name%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_1098t_fts
      WHERE  tax_year_name = cp_v_tax_year_name;

  BEGIN
    l_b_validate := TRUE;

-- Validate if the Person ID and Person ID Group are both passed
    IF ((p_n_person_id IS NOT NULL) AND (p_n_person_grp_id IS NOT NULL)) THEN
      l_b_validate := FALSE;
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      fnd_message.set_name('IGS',
                           'IGS_FI_NO_PERS_PGRP');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

-- Validate if neither Person ID nor Person ID Group is passed
    IF ((p_n_person_id IS NULL) AND (p_n_person_grp_id IS NULL)) THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_PRS_PRSIDGRP_NULL');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

-- Validate Tax Year
    OPEN cur_1098t_setup(p_v_tax_year_name);
    FETCH cur_1098t_setup INTO g_rec_1098t_setup;
    IF cur_1098t_setup%NOTFOUND THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',
                            g_v_label_tax_year);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
    CLOSE cur_1098t_setup;

-- Validate Person Id if passed
    IF p_n_person_id IS NOT NULL THEN
      OPEN cur_val_person_id(p_n_person_id);
      FETCH cur_val_person_id INTO l_c_val;
      IF cur_val_person_id%NOTFOUND THEN
        fnd_message.set_module(g_v_package_name||'validate_parameters');
        l_b_validate := FALSE;
        fnd_message.set_name('IGS',
                             'IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',
                              g_v_label_person);
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
      CLOSE cur_val_person_id;
    END IF;

-- Validate Person Id Group if Passed
    IF p_n_person_grp_id IS NOT NULL THEN
      OPEN cur_val_persgrp(p_n_person_grp_id,
                           'N');
      FETCH cur_val_persgrp INTO l_c_val;
      IF cur_val_persgrp%NOTFOUND THEN
        fnd_message.set_module(g_v_package_name||'validate_parameters');
        l_b_validate := FALSE;
        fnd_message.set_name('IGS',
                             'IGS_FI_INVALID_PARAMETER');
        fnd_message.set_token('PARAMETER',
                              g_v_label_persgrp);
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
      CLOSE cur_val_persgrp;
    END IF;

-- Validate if atleast one load period is associated to the tax year
    OPEN cur_val_one_lps(p_v_tax_year_name);
    FETCH cur_val_one_lps INTO l_c_val;
    IF cur_val_one_lps%NOTFOUND THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_1098T_NO_LPS');
      fnd_message.set_token('TAX_YEAR_NAME',
                             p_v_tax_year_name);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
    CLOSE cur_val_one_lps;

-- Validate if atleast one Fee Type is associated with the tax year
    OPEN cur_val_one_ft(p_v_tax_year_name);
    FETCH cur_val_one_ft INTO l_c_val;
    IF cur_val_one_ft%NOTFOUND THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_1098T_NO_FTS');
      fnd_message.set_token('TAX_YEAR_NAME',
                             p_v_tax_year_name);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
    CLOSE cur_val_one_ft;

    IF p_v_override_excl NOT IN ('Y','N') THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',
                             g_v_label_override_excl);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

    IF p_v_file_addr_correction NOT IN ('Y','N') THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',
                             g_v_label_file_addr);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

    IF p_v_test_run NOT IN ('Y','N') THEN
      fnd_message.set_module(g_v_package_name||'validate_parameters');
      l_b_validate := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_INVALID_PARAMETER');
      fnd_message.set_token('PARAMETER',
                             g_v_label_test_run);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

    RETURN l_b_validate;
  END validate_params;

  FUNCTION get_sys_fund_type(p_n_credit_id        igs_fi_credits_all.credit_id%TYPE,
                             p_n_invoice_id       igs_fi_inv_int_all.invoice_id%TYPE) RETURN VARCHAR2 AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for getting System Fund Type

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */

    CURSOR cur_fund_id_crd(cp_n_credit_id       igs_fi_credits_all.credit_id%TYPE) IS
      SELECT awd.fund_id
      FROM   igf_db_awd_disb_dtl_all disb,
             igf_aw_award_all awd
      WHERE  awd.award_id = disb.award_id
      AND    disb.sf_credit_id = cp_n_credit_id;

    CURSOR cur_fund_id_inv(cp_n_invoice_id       igs_fi_inv_int_all.invoice_id%TYPE) IS
      SELECT awd.fund_id
      FROM   igf_db_awd_disb_dtl_all disb,
             igf_aw_award_all awd
      WHERE  awd.award_id = disb.award_id
      AND    disb.sf_invoice_num = cp_n_invoice_id;

    CURSOR cur_sys_fund_type(cp_n_fund_id        igf_aw_award_all.fund_id%TYPE) IS
      SELECT fcat.sys_fund_type
      FROM   igf_aw_fund_mast_all fmast,
             igf_aw_fund_cat_all fcat
      WHERE  fmast.fund_id = cp_n_fund_id
      AND    fmast.fund_code = fcat.fund_code;

    l_v_sys_fund_type         igf_aw_fund_cat_all.sys_fund_type%TYPE;
    l_n_fund_id               igf_aw_award_all.fund_id%TYPE;

  BEGIN

-- Fetch the Fund ID from the Disbursements table
    IF p_n_credit_id IS NOT NULL THEN
      OPEN cur_fund_id_crd(p_n_credit_id);
      FETCH cur_fund_id_crd INTO l_n_fund_id;
      CLOSE cur_fund_id_crd;
    ELSIF p_n_invoice_id IS NOT NULL THEN
      OPEN cur_fund_id_inv(p_n_invoice_id);
      FETCH cur_fund_id_inv INTO l_n_fund_id;
      CLOSE cur_fund_id_inv;
    END IF;

-- get the system fund type based on the fund id determined earlier
    OPEN cur_sys_fund_type(l_n_fund_id);
    FETCH cur_sys_fund_type INTO l_v_sys_fund_type;
    CLOSE cur_sys_fund_type;

    RETURN l_v_sys_fund_type;
  END get_sys_fund_type;

  PROCEDURE get_alt_person_id(p_n_person_id                     igs_pe_person_base_v.person_id%TYPE,
                              p_v_person_id_type                igs_pe_person_id_typ.person_id_type%TYPE,
                              p_v_s_person_id_type              igs_pe_person_id_typ.s_person_id_type%TYPE,
                              p_v_api_pers_id       OUT NOCOPY  igs_pe_alt_pers_id.api_person_id%TYPE,
                              p_v_api_pers_id_uf    OUT NOCOPY  igs_pe_alt_pers_id.api_person_id_uf%TYPE) AS

      /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for getting Alternate Person Id

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_api_pid1(cp_n_person_id               igs_pe_person_base_v.person_id%TYPE,
                        cp_v_s_person_id_type        igs_pe_person_id_typ.s_person_id_type%TYPE) IS
      SELECT altid.api_person_id,
             altid.api_person_id_uf
      FROM   igs_pe_alt_pers_id altid,
             igs_pe_person_id_typ pid
      WHERE  altid.pe_person_id = cp_n_person_id
      AND    altid.person_id_type = pid.person_id_type
      AND    pid.s_person_id_type = cp_v_s_person_id_type
      AND    sysdate BETWEEN altid.start_dt AND NVL(altid.end_dt, sysdate)
      AND    pid.closed_ind = 'N';

    CURSOR cur_api_pid2(cp_n_person_id               igs_pe_person_base_v.person_id%TYPE,
                        cp_v_person_id_type          igs_pe_person_id_typ.person_id_type%TYPE,
                        cp_v_s_person_id_type        igs_pe_person_id_typ.s_person_id_type%TYPE) IS
      SELECT altid.api_person_id,
             altid.api_person_id_uf
      FROM   igs_pe_alt_pers_id altid,
             igs_pe_person_id_typ pid
      WHERE  altid.pe_person_id = cp_n_person_id
      AND    altid.person_id_type = pid.person_id_type
      AND    pid.s_person_id_type = cp_v_s_person_id_type
      AND    altid.person_id_type = cp_v_person_id_type
      AND    sysdate BETWEEN altid.start_dt AND NVL(altid.end_dt, sysdate)
      AND    pid.closed_ind = 'N';

    l_v_api_person_id        igs_pe_alt_pers_id.api_person_id%TYPE;
    l_v_api_person_id_uf     igs_pe_alt_pers_id.api_person_id_uf%TYPE;

  BEGIN
    IF p_v_s_person_id_type IN ('SSN','NAME_CONTROL') THEN
      OPEN cur_api_pid1(p_n_person_id,
                        p_v_s_person_id_type);
      FETCH cur_api_pid1 INTO l_v_api_person_id,l_v_api_person_id_uf ;
      CLOSE cur_api_pid1;
    ELSIF p_v_s_person_id_type = 'TAXID' THEN
      OPEN cur_api_pid2(p_n_person_id,
                        p_v_person_id_type,
                        p_v_s_person_id_type);
      FETCH cur_api_pid2 INTO l_v_api_person_id,l_v_api_person_id_uf;
      CLOSE cur_api_pid2;
    END IF;

    p_v_api_pers_id    := l_v_api_person_id;
    p_v_api_pers_id_uf := l_v_api_person_id_uf;

  END get_alt_person_id;

  PROCEDURE box236_credits(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                           p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                           p_v_override_excl        VARCHAR2,
                           p_n_orig_credit      OUT NOCOPY NUMBER,
                           p_n_adj_credit       OUT NOCOPY NUMBER)  AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for Box 2 and 3 Credits

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */
    l_n_orig_credit        NUMBER;
    l_n_adj_credit         NUMBER;
    l_v_load_cal_type      igs_ca_inst.cal_type%TYPE;
    l_n_load_ci_seq        igs_ca_inst.sequence_number%TYPE;

-- Cursor for selecting the Negative Charge Adjustment credits, where the fee type is associated
-- to the current tax year being processed
    CURSOR cur_qtre_crd(cp_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                        cp_d_end_date             DATE,
                        cp_n_person_id            igs_pe_person_base_v.person_id%TYPE) IS
      SELECT crd.*,
             crd.rowid row_id,
             fts.fee_type,
             inv.invoice_id
      FROM   igs_fi_credits_all crd,
             igs_fi_cr_types_all crt,
             igs_fi_1098t_fts fts,
             igs_fi_inv_int_all inv,
             igs_fi_applications app
      WHERE  crd.credit_type_id = crt.credit_type_id
      AND    crt.credit_class = 'CHGADJ'
      AND    crd.party_id = cp_n_person_id
      AND    inv.invoice_id = app.invoice_id
      AND    crd.credit_id  = app.credit_id
      AND    inv.fee_type   = fts.fee_type
      AND    fts.tax_year_name = cp_v_tax_year_name
      AND    TRUNC(crd.transaction_date) <= TRUNC(cp_d_end_date)
      AND    crd.tax_year_code IS NULL
      ORDER  BY crd.fee_ci_sequence_number;

-- Cursor for checking if any charge for the same person and having the same FTCI was
-- reported in a prior year
    CURSOR cur_chk_inv(cp_v_fee_cal_type           igs_ca_inst.cal_type%TYPE,
                       cp_n_fee_ci_seq             igs_ca_inst.sequence_number%TYPE,
                       cp_n_person_id              igs_pe_person_base_v.person_id%TYPE,
                       cp_v_fee_type               igs_fi_fee_type.fee_type%TYPE,
                       cp_d_start_date             DATE) IS
      SELECT 'x'
      FROM   igs_fi_inv_int_all inv,
             igs_fi_1098t_setup stp
      WHERE  inv.person_id = cp_n_person_id
      AND    inv.fee_type  = cp_v_fee_type
      AND    inv.fee_cal_type = cp_v_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    TRUNC(invoice_creation_date) < TRUNC(cp_d_start_date)
      AND    inv.tax_year_code IS NOT NULL
      AND    inv.tax_year_code = stp.tax_year_code
      AND    TRUNC(stp.end_date) < TRUNC(cp_d_start_date);

    l_b_process_credit             BOOLEAN;
    l_b_non_zero_credits_flag      BOOLEAN;
    l_v_message_name               VARCHAR2(2000);
    l_b_bool                       BOOLEAN;
    l_var                          VARCHAR2(1);
    l_n_box_num                    NUMBER(5);

    l_n_prev_fee_ci_seq            igs_ca_inst.sequence_number%TYPE;

  BEGIN
    l_n_orig_credit := 0;
    l_n_adj_credit := 0;

    l_n_prev_fee_ci_seq   := null;

    log_to_fnd(p_v_module  => 'box236_credits',
               p_v_string  => 'Looping for the eligible credit records');

-- Loop across all the negative adjustment credits whose source invoices are identified as
-- QTRE
    FOR l_rec_crd IN cur_qtre_crd(p_v_tax_year_name,
                                  g_rec_1098t_setup.end_date,
                                  p_n_person_id) LOOP

      log_to_fnd(p_v_module  => 'box236_credits',
                 p_v_string  => 'Credit Record Found : '||l_rec_crd.credit_number);

      IF l_n_prev_fee_ci_seq IS NULL OR l_n_prev_fee_ci_seq <> l_rec_crd.fee_ci_sequence_number THEN
        l_n_prev_fee_ci_seq := l_rec_crd.fee_ci_sequence_number;

        l_b_process_credit := TRUE;

-- Get the load period mapping for the fee period of the Source charge transaction
        l_b_bool := igs_fi_gen_001.finp_get_lfci_reln(p_cal_type                => l_rec_crd.fee_cal_type,
                                                      p_ci_sequence_number      => l_rec_crd.fee_ci_sequence_number,
                                                      p_cal_category            => 'FEE',
                                                      p_ret_cal_type            => l_v_load_cal_type,
                                                      p_ret_ci_sequence_number  => l_n_load_ci_seq,
                                                      p_message_name            => l_v_message_name);

        IF l_v_message_name IS NOT NULL THEN
          fnd_message.set_name('IGS',
                               l_v_message_name);
          fnd_message.set_module(g_v_package_name||'box236_credits');
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
          l_b_process_credit := FALSE;
        END IF;
      END IF;

      IF l_b_process_credit THEN

-- Check for the Prior Load Period
          log_to_fnd(p_v_module  => 'box236_credits',
                     p_v_string  => 'Checking for prior Load Period');
          l_b_process_credit := chk_prior_lps(p_v_load_cal_type     => l_v_load_cal_type,
                                              p_n_load_ci_seq       => l_n_load_ci_seq,
                                              p_d_txn_date          => l_rec_crd.transaction_date);
      END IF;

      IF l_b_process_credit THEN
        g_b_chg_crd_found := TRUE;

        IF g_b_non_zero_credits_flag = FALSE THEN

-- Check for Non Credit Courses
          IF chk_non_credit_course(p_n_person_id,
                                   p_v_override_excl,
                                   l_v_load_cal_type,
                                   l_n_load_ci_seq) THEN

            g_b_non_zero_credits_flag := TRUE;
            log_to_fnd(p_v_module  => 'box236_credits',
                       p_v_string  => 'Non Zero Credits Flag set to FALSE');
          END IF;
        END IF;


-- Check if the Source Invoice Id has been reported in a prior tax year
        OPEN cur_chk_inv(l_rec_crd.fee_cal_type,
                         l_rec_crd.fee_ci_sequence_number,
                         l_rec_crd.party_id,
                         l_rec_crd.fee_type,
                         g_rec_1098t_setup.start_date);
        FETCH cur_chk_inv INTO l_var;
        IF cur_chk_inv%FOUND THEN

-- If yes, then the credit should be marked for Box 3
          l_n_adj_credit := NVL(l_n_adj_credit,0) +
                            NVL(l_rec_crd.amount,0);
          l_n_box_num := 3;
          log_to_fnd(p_v_module  => 'box236_credits',
                     p_v_string  => 'Charge Record Found for Box 3');
        ELSE

-- Else the credit should be marked for Box 2
          l_n_orig_credit := NVL(l_n_orig_credit,0) +
                             NVL(l_rec_crd.amount,0);

          l_n_box_num := 2;
          log_to_fnd(p_v_module  => 'box236_credits',
                     p_v_string  => 'Charge Record Not Found. Hence marking for Box 2');
        END IF;
        CLOSE cur_chk_inv;

        l_n_cntr := l_n_cntr + 1;
        l_t_1098t_drilldown(l_n_cntr).transaction_id := l_rec_crd.credit_id;
        l_t_1098t_drilldown(l_n_cntr).transaction_code := 'C';
        l_t_1098t_drilldown(l_n_cntr).box_num := l_n_box_num;

        log_to_fnd(p_v_module  => 'box236_credits',
                   p_v_string  => 'Updating the Credits Record. Credit Number :'||l_rec_crd.credit_number);

        igs_fi_credits_pkg.update_row(x_rowid                       => l_rec_crd.row_id,
                                      x_credit_id                   => l_rec_crd.credit_id,
                                      x_credit_number               => l_rec_crd.credit_number,
                                      x_status                      => l_rec_crd.status,
                                      x_credit_source               => l_rec_crd.credit_source,
                                      x_party_id                    => l_rec_crd.party_id,
                                      x_credit_type_id              => l_rec_crd.credit_type_id,
                                      x_credit_instrument           => l_rec_crd.credit_instrument,
                                      x_description                 => l_rec_crd.description,
                                      x_amount                      => l_rec_crd.amount,
                                      x_currency_cd                 => l_rec_crd.currency_cd,
                                      x_exchange_rate               => l_rec_crd.exchange_rate,
                                      x_transaction_date            => l_rec_crd.transaction_date,
                                      x_effective_date              => l_rec_crd.effective_date,
                                      x_reversal_date               => l_rec_crd.reversal_date,
                                      x_reversal_reason_code        => l_rec_crd.reversal_reason_code,
                                      x_reversal_comments           => l_rec_crd.reversal_comments,
                                      x_unapplied_amount            => l_rec_crd.unapplied_amount,
                                      x_source_transaction_id       => l_rec_crd.source_transaction_id,
                                      x_receipt_lockbox_number      => l_rec_crd.receipt_lockbox_number,
                                      x_merchant_id                 => l_rec_crd.merchant_id,
                                      x_credit_card_code            => l_rec_crd.credit_card_code,
                                      x_credit_card_holder_name     => l_rec_crd.credit_card_holder_name,
                                      x_credit_card_number          => l_rec_crd.credit_card_number,
                                      x_credit_card_expiration_date => l_rec_crd.credit_card_expiration_date,
                                      x_credit_card_approval_code   => l_rec_crd.credit_card_approval_code,
                                      x_awd_yr_cal_type             => l_rec_crd.awd_yr_cal_type,
                                      x_awd_yr_ci_sequence_number   => l_rec_crd.awd_yr_ci_sequence_number,
                                      x_fee_cal_type                => l_rec_crd.fee_cal_type,
                                      x_fee_ci_sequence_number      => l_rec_crd.fee_ci_sequence_number,
                                      x_attribute_category          => l_rec_crd.attribute_category,
                                      x_attribute1                  => l_rec_crd.attribute1,
                                      x_attribute2                  => l_rec_crd.attribute2,
                                      x_attribute3                  => l_rec_crd.attribute3,
                                      x_attribute4                  => l_rec_crd.attribute4,
                                      x_attribute5                  => l_rec_crd.attribute5,
                                      x_attribute6                  => l_rec_crd.attribute6,
                                      x_attribute7                  => l_rec_crd.attribute7,
                                      x_attribute8                  => l_rec_crd.attribute8,
                                      x_attribute9                  => l_rec_crd.attribute9,
                                      x_attribute10                 => l_rec_crd.attribute10,
                                      x_attribute11                 => l_rec_crd.attribute11,
                                      x_attribute12                 => l_rec_crd.attribute12,
                                      x_attribute13                 => l_rec_crd.attribute13,
                                      x_attribute14                 => l_rec_crd.attribute14,
                                      x_attribute15                 => l_rec_crd.attribute15,
                                      x_attribute16                 => l_rec_crd.attribute16,
                                      x_attribute17                 => l_rec_crd.attribute17,
                                      x_attribute18                 => l_rec_crd.attribute18,
                                      x_attribute19                 => l_rec_crd.attribute19,
                                      x_attribute20                 => l_rec_crd.attribute20,
                                      x_gl_date                     => l_rec_crd.gl_date,
                                      x_check_number                => l_rec_crd.check_number,
                                      x_source_transaction_type     => l_rec_crd.source_transaction_type,
                                      x_source_transaction_ref      => l_rec_crd.source_transaction_ref,
                                      x_credit_card_status_code     => l_rec_crd.credit_card_status_code,
                                      x_credit_card_payee_cd        => l_rec_crd.credit_card_payee_cd,
                                      x_credit_card_tangible_cd     => l_rec_crd.credit_card_tangible_cd,
                                      x_lockbox_interface_id        => l_rec_crd.lockbox_interface_id,
                                      x_batch_name                  => l_rec_crd.batch_name,
                                      x_deposit_date                => l_rec_crd.deposit_date,
                                      x_source_invoice_id           => l_rec_crd.source_invoice_id,
                                      x_tax_year_code               => g_rec_1098t_setup.tax_year_code,
                                      x_waiver_name                 => l_rec_crd.waiver_name);
      END IF;
    END LOOP;

    log_to_fnd(p_v_module  => 'box236_credits',
               p_v_string  => 'Original Credit '||l_n_orig_credit);

    log_to_fnd(p_v_module  => 'box236_credits',
               p_v_string  => 'Adjustment Credit '||l_n_adj_credit);

    p_n_orig_credit := l_n_orig_credit;
    p_n_adj_credit  := l_n_adj_credit;

  END box236_credits;

  PROCEDURE box236_charges(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                           p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                           p_v_override_excl        VARCHAR2,
                           p_n_orig_charge      OUT NOCOPY NUMBER,
                           p_n_adj_charge       OUT NOCOPY NUMBER,
                           p_v_next_acad_flag   OUT NOCOPY VARCHAR2)  AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for Box 2, 3 and 6 from Charges

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     skharida 26-Jun-2006    Bug 5208136 - Removed the obsoleted columns of the table IGS_FI_INV_INT_ALL
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */
    l_n_orig_chg           NUMBER;
    l_n_adj_chg            NUMBER;
    l_v_load_cal_type      igs_ca_inst.cal_type%TYPE;
    l_n_load_ci_seq        igs_ca_inst.sequence_number%TYPE;

    CURSOR cur_chg(cp_n_person_id                   igs_pe_person_base_v.person_id%TYPE,
                   cp_v_tax_year_name               igs_fi_1098t_setup.tax_year_name%TYPE,
                   cp_d_end_date                    DATE) IS
      SELECT inv.*, inv.rowid row_id
      FROM   igs_fi_inv_int_all inv,
             igs_fi_1098t_fts fts
      WHERE  inv.fee_type = fts.fee_type
      AND    inv.person_id = cp_n_person_id
      AND    fts.tax_year_name = cp_v_tax_year_name
      AND    TRUNC(inv.invoice_creation_date) <= TRUNC(cp_d_end_date)
      AND    inv.tax_year_code IS NULL
      ORDER BY inv.fee_ci_sequence_number;

    CURSOR cur_next_acad_flag(cp_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                              cp_v_load_cal_type        igs_ca_inst.cal_type%TYPE,
                              cp_n_load_ci_seq          igs_ca_inst.sequence_number%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_1098t_lps
      WHERE  tax_year_name = cp_v_tax_year_name
      AND    cal_type      = cp_v_load_cal_type
      AND    sequence_number = cp_n_load_ci_seq
      AND    next_acad_flag = 'Y';

    CURSOR cur_chk_chg(cp_n_person_id                   igs_pe_person_base_v.person_id%TYPE,
                       cp_v_fee_type                    igs_fi_fee_type.fee_type%TYPE,
                       cp_v_fee_cal_type                igs_ca_inst.cal_type%TYPE,
                       cp_n_fee_ci_seq                  igs_ca_inst.sequence_number%TYPE,
                       cp_d_start_date                  DATE) IS
      SELECT 'x'
      FROM   igs_fi_inv_int_all inv,
             igs_fi_1098t_setup stp
      WHERE  inv.person_id = cp_n_person_id
      AND    inv.fee_type  = cp_v_fee_type
      AND    inv.fee_cal_type = cp_v_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    inv.tax_year_code IS NOT NULL
      AND    inv.tax_year_code = stp.tax_year_code
      AND    TRUNC(stp.end_date) < TRUNC(cp_d_start_date)
      AND    TRUNC(invoice_creation_date) < TRUNC(cp_d_start_date);

    l_b_prc_chg                   BOOLEAN;
    l_v_next_acad_flag            igs_fi_1098t_lps.next_acad_flag%TYPE;
    l_b_non_zero_credits_flag     BOOLEAN;
    l_v_message_name              VARCHAR2(2000);
    l_var                         VARCHAR2(1);
    l_b_bool                      BOOLEAN;
    l_n_box_num                   NUMBER(5);
    l_n_prev_fee_ci_seq           igs_ca_inst.sequence_number%TYPE;
  BEGIN
    l_v_next_acad_flag := 'N';
    l_b_non_zero_credits_flag := FALSE;
    l_n_orig_chg := 0;
    l_n_adj_chg  := 0;
    l_n_prev_fee_ci_seq := null;

    log_to_fnd(p_v_module  => 'box236_charges',
               p_v_string  => 'Inside Box236 Charges');

-- Loop across all the QTRE charges with null tax year
    FOR l_rec_chg IN cur_chg(p_n_person_id,
                             p_v_tax_year_name,
                             g_rec_1098t_setup.end_date) LOOP
      log_to_fnd(p_v_module  => 'box236_charges',
                 p_v_string  => 'Found the Charge transaction'||l_rec_chg.invoice_id);
      IF l_n_prev_fee_ci_seq IS NULL OR l_n_prev_fee_ci_seq <> l_rec_chg.fee_ci_sequence_number THEN
        l_b_prc_chg := TRUE;

-- Get the load period for the charge fee period
        l_b_bool := igs_fi_gen_001.finp_get_lfci_reln(p_cal_type                => l_rec_chg.fee_cal_type,
                                                      p_ci_sequence_number      => l_rec_chg.fee_ci_sequence_number,
                                                      p_cal_category            => 'FEE',
                                                      p_ret_cal_type            => l_v_load_cal_type,
                                                      p_ret_ci_sequence_number  => l_n_load_ci_seq,
                                                      p_message_name            => l_v_message_name);
        IF l_v_message_name IS NOT NULL THEN
          l_b_prc_chg := FALSE;
          fnd_message.set_module(g_v_package_name||'box236_charges');
          fnd_message.set_name('IGS',
                               l_v_message_name);
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
        END IF;
      END IF;

-- Check for the Prior Load Period
      IF l_b_prc_chg THEN
        l_b_prc_chg := chk_prior_lps(p_v_load_cal_type     => l_v_load_cal_type,
                                     p_n_load_ci_seq       => l_n_load_ci_seq,
                                     p_d_txn_date          => l_rec_chg.invoice_creation_date);
      END IF;

      IF l_b_prc_chg THEN
        g_b_chg_crd_found := TRUE;
        log_to_fnd(p_v_module  => 'box236_charges',
                   p_v_string  => 'Charge validations successful');

-- Calculate the Next Academic Flag
        IF l_v_next_acad_flag = 'N' THEN
          OPEN cur_next_acad_flag(p_v_tax_year_name,
                                  l_v_load_cal_type,
                                  l_n_load_ci_seq);
          FETCH cur_next_acad_flag INTO l_var;
          IF cur_next_acad_flag%FOUND THEN
            l_v_next_acad_flag := 'Y';
          END IF;
          CLOSE cur_next_acad_flag;
        END IF;

        log_to_fnd(p_v_module  => 'box236_charges',
                   p_v_string  => 'Next acad flag '||l_v_next_acad_flag);

        IF NOT g_b_non_zero_credits_flag THEN

-- Check for Non Credit Course
          IF chk_non_credit_course(p_n_person_id         => l_rec_chg.person_id,
                                   p_v_override_excl     => p_v_override_excl,
                                   p_v_load_cal_type     => l_v_load_cal_type,
                                   p_n_load_ci_seq       => l_n_load_ci_seq) THEN
            g_b_non_zero_credits_flag := TRUE;
          END IF;
        END IF;

-- Check if the charge is an original or adjustment charge
        OPEN cur_chk_chg(l_rec_chg.person_id,
                         l_rec_chg.fee_type,
                         l_rec_chg.fee_cal_type,
                         l_rec_chg.fee_ci_sequence_number,
                         g_rec_1098t_setup.start_date);
        FETCH cur_chk_chg INTO l_var;
        IF cur_chk_chg%FOUND THEN
          l_n_adj_chg := NVL(l_n_adj_chg,0) +
                         NVL(l_rec_chg.invoice_amount,0);
          l_n_box_num := 3;
        ELSE
          l_n_orig_chg := NVL(l_n_orig_chg,0) +
                          NVL(l_rec_chg.invoice_amount,0);
          l_n_box_num := 2;
        END IF;
        CLOSE cur_chk_chg;


        l_n_cntr := l_n_cntr + 1;
        l_t_1098t_drilldown(l_n_cntr).transaction_id := l_rec_chg.invoice_id;
        l_t_1098t_drilldown(l_n_cntr).transaction_code := 'D';
        l_t_1098t_drilldown(l_n_cntr).box_num := l_n_box_num;

        log_to_fnd(p_v_module  => 'box236_charges',
                   p_v_string  => 'Updating Invoice record '||l_rec_chg.invoice_id);
        igs_fi_inv_int_pkg.update_row(x_rowid                         => l_rec_chg.row_id,
                                      x_invoice_id                    => l_rec_chg.invoice_id,
                                      x_person_id                     => l_rec_chg.person_id,
                                      x_fee_type                      => l_rec_chg.fee_type,
                                      x_fee_cat                       => l_rec_chg.fee_cat,
                                      x_fee_cal_type                  => l_rec_chg.fee_cal_type,
                                      x_fee_ci_sequence_number        => l_rec_chg.fee_ci_sequence_number,
                                      x_course_cd                     => l_rec_chg.course_cd,
                                      x_attendance_mode               => l_rec_chg.attendance_mode,
                                      x_attendance_type               => l_rec_chg.attendance_type,
                                      x_invoice_amount_due            => l_rec_chg.invoice_amount_due,
                                      x_invoice_creation_date         => l_rec_chg.invoice_creation_date,
                                      x_invoice_desc                  => l_rec_chg.invoice_desc,
                                      x_transaction_type              => l_rec_chg.transaction_type,
                                      x_currency_cd                   => l_rec_chg.currency_cd,
                                      x_status                        => l_rec_chg.status,
                                      x_attribute_category            => l_rec_chg.attribute_category,
                                      x_attribute1                    => l_rec_chg.attribute1,
                                      x_attribute2                    => l_rec_chg.attribute2,
                                      x_attribute3                    => l_rec_chg.attribute3,
                                      x_attribute4                    => l_rec_chg.attribute4,
                                      x_attribute5                    => l_rec_chg.attribute5,
                                      x_attribute6                    => l_rec_chg.attribute6,
                                      x_attribute7                    => l_rec_chg.attribute7,
                                      x_attribute8                    => l_rec_chg.attribute8,
                                      x_attribute9                    => l_rec_chg.attribute9,
                                      x_attribute10                   => l_rec_chg.attribute10,
                                      x_invoice_amount                => l_rec_chg.invoice_amount,
                                      x_bill_id                       => l_rec_chg.bill_id,
                                      x_bill_number                   => l_rec_chg.bill_number,
                                      x_bill_date                     => l_rec_chg.bill_date,
                                      x_waiver_flag                   => l_rec_chg.waiver_flag,
                                      x_waiver_reason                 => l_rec_chg.waiver_reason,
                                      x_effective_date                => l_rec_chg.effective_date,
                                      x_invoice_number                => l_rec_chg.invoice_number,
                                      x_exchange_rate                 => l_rec_chg.exchange_rate,
                                      x_bill_payment_due_date         => l_rec_chg.bill_payment_due_date,
                                      x_optional_fee_flag             => l_rec_chg.optional_fee_flag,
                                      x_reversal_gl_date              => l_rec_chg.reversal_gl_date,
                                      x_tax_year_code                 => g_rec_1098t_setup.tax_year_code,
                                      x_waiver_name                   => l_rec_chg.waiver_name);
      END IF;
    END LOOP;

    p_n_orig_charge    := l_n_orig_chg;
    p_n_adj_charge     := l_n_adj_chg;
    p_v_next_acad_flag := l_v_next_acad_flag;
  END box236_charges;

  PROCEDURE box45_credits(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                          p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                          p_n_orig_credit      OUT NOCOPY NUMBER,
                          p_n_adj_credit       OUT NOCOPY NUMBER) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for Box 4 and 5 for Credits

     Known limitations,enhancements,remarks:
     Change History
     Who      When           What
     skharida 22/05/06       Bug 5213590 - Added changes to check for waiver name
     agairola 23/11/05       Bug:4747419 - Modified logic for Waiver Credits
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */
    l_n_aid_orig_credit         NUMBER;
    l_n_aid_adj_credit          NUMBER;
    l_b_party_sponsor           BOOLEAN;
    l_b_process_credit          BOOLEAN;
    l_v_load_cal_type           igs_ca_inst.cal_type%TYPE;
    l_n_load_ci_seq             igs_ca_inst.sequence_number%TYPE;

    l_v_crd_sys_fund_type       igf_aw_fund_cat_all.sys_fund_type%TYPE;
    l_v_orig_crd_sys_fund_type  igf_aw_fund_cat_all.sys_fund_type%TYPE;
    l_v_message_name            VARCHAR2(2000);
    l_var                       VARCHAR2(1);
    l_n_box_num                 NUMBER(5);

    CURSOR cur_chk_spn(cp_n_person_id                igs_pe_person_base_v.person_id%TYPE,
                       cp_v_sys_fund_type            igf_aw_fund_cat_all.sys_fund_type%TYPE) IS
      SELECT 'x'
      FROM   igf_aw_fund_mast_all fmast,
             igf_aw_fund_cat_all  fcat
      WHERE  fmast.fund_code  = fcat.fund_code
      AND    fcat.sys_fund_type = cp_v_sys_fund_type
      AND    fmast.party_id = cp_n_person_id;

    CURSOR cur_crd(cp_n_person_id                igs_pe_person_base_v.person_id%TYPE,
                   cp_d_start_date               DATE,
                   cp_d_end_date                 DATE) IS
      SELECT crd.*,
             crd.rowid row_id,
             crt.credit_class
      FROM   igs_fi_credits_all crd,
             igs_fi_cr_types_all crt
      WHERE  crd.credit_type_id = crt.credit_type_id
      AND    crd.status = 'CLEARED'
      AND    crd.party_id = cp_n_person_id
      AND    crt.credit_class IN ('SPNSP','EXTFA','INTFA','WAIVER')
      AND    TRUNC(crd.transaction_date) BETWEEN TRUNC(cp_d_start_date) AND TRUNC(cp_d_end_date)
      AND    crd.tax_year_code IS NULL;

    CURSOR cur_chk_adj(cp_n_credit_id                 igs_fi_credits_all.credit_id%TYPE) IS
      SELECT 'x'
      FROM   igf_db_awd_disb_dtl_all
      WHERE  spnsr_credit_id = cp_n_credit_id;

    CURSOR cur_chk_orig_credit(cp_n_person_id                igs_pe_person_base_v.person_id%TYPE,
                               cp_v_fee_cal_type             igs_ca_inst.cal_type%TYPE,
                               cp_n_fee_ci_seq               igs_ca_inst.sequence_number%TYPE,
                               cp_d_start_date               DATE) IS
      SELECT crd.credit_id,
             crd.waiver_name
      FROM   igs_fi_credits_all crd,
             igs_fi_1098t_setup stp
      WHERE  party_id  = cp_n_person_id
      AND    fee_cal_type = cp_v_fee_cal_type
      AND    fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    TRUNC(transaction_date) < TRUNC(cp_d_start_date)
      AND    crd.tax_year_code IS NOT NULL
      AND    crd.tax_year_code = stp.tax_year_code
      AND    TRUNC(stp.end_date) < TRUNC(cp_d_start_date);

    l_rec_orig_crd         cur_chk_orig_credit%ROWTYPE;
    l_b_orig_credit        BOOLEAN;
    l_b_rec_found          BOOLEAN;
  BEGIN
    l_n_aid_orig_credit := 0;
    l_n_aid_adj_credit  := 0;
    l_b_party_sponsor   := FALSE;

    log_to_fnd(p_v_module  => 'box45_credits',
               p_v_string  => 'Inside Box 45 Credits');

-- Check if the party is a sponsor
    OPEN cur_chk_spn(p_n_person_id,
                     'SPONSOR');
    FETCH cur_chk_spn INTO l_var;
    IF cur_chk_spn%FOUND THEN
      l_b_party_sponsor := TRUE;
    END IF;
    CLOSE cur_chk_spn;

    IF l_b_party_sponsor THEN
      log_to_fnd(p_v_module  => 'box45_credits',
                 p_v_string  => 'Party '||p_n_person_id||'  is a Sponsor');
    END IF;


-- Loop across all credits that have null value for tax year
    FOR l_rec_crd IN cur_crd(p_n_person_id,
                             g_rec_1098t_setup.start_date,
                             g_rec_1098t_setup.end_date) LOOP
      l_b_process_credit := TRUE;

      IF l_rec_crd.credit_class <> 'WAIVER' THEN
-- Get the System Fund Type
        l_v_crd_sys_fund_type := get_sys_fund_type(p_n_credit_id         => l_rec_crd.credit_id,
                                                   p_n_invoice_id        => null);
        log_to_fnd(p_v_module  => 'box45_credits',
                   p_v_string  => 'System Fund Type'||l_v_crd_sys_fund_type);

-- Check if the System Fund Type is associated with the tax year
        OPEN cur_chk_1098t_sfts(p_v_tax_year_name,
                                l_v_crd_sys_fund_type);
        FETCH cur_chk_1098t_sfts INTO l_var;
        IF cur_chk_1098t_sfts%NOTFOUND THEN
          log_to_fnd(p_v_module  => 'box45_credits',
                     p_v_string  => 'System Fund Type is not associated with the Tax Year');

          l_b_process_credit := FALSE;
        END IF;
        CLOSE cur_chk_1098t_sfts;
      END IF;

-- If the party is a sponsor, then check if the credit is due to downward adjustment of
-- Sponsorship
      IF l_b_party_sponsor THEN
        OPEN cur_chk_adj(l_rec_crd.credit_id);
        FETCH cur_chk_adj INTO l_var;
        IF cur_chk_adj%FOUND THEN
          log_to_fnd(p_v_module  => 'box45_credits',
                     p_v_string  => 'For the sponsor, this credit is due to a downward adj of sponsorship. Hence it is not reported');
          l_b_process_credit := FALSE;
        END IF;
        CLOSE cur_chk_adj;
      END IF;

-- Check for original or adjustment credit
      IF l_b_process_credit THEN
        l_b_orig_credit := TRUE;
        FOR l_rec_orig_crd IN cur_chk_orig_credit(p_n_person_id,
                                                  l_rec_crd.fee_cal_type,
                                                  l_rec_crd.fee_ci_sequence_number,
                                                  g_rec_1098t_setup.start_date) LOOP
          l_b_rec_found := TRUE;

          IF l_rec_crd.credit_class = 'WAIVER' THEN
            log_to_fnd(p_v_module  => 'box45_credits',
                       p_v_string  => 'Waiver Credit '||l_rec_crd.credit_id||' is an adjustment credit');
            IF ((l_rec_orig_crd.waiver_name IS NOT NULL)
                 AND (l_rec_orig_crd.waiver_name = l_rec_crd.waiver_name)) THEN
              l_b_orig_credit := FALSE;
              EXIT;
            END IF;
          ELSE

            l_v_orig_crd_sys_fund_type := get_sys_fund_type(p_n_credit_id         => l_rec_orig_crd.credit_id,
                                                          p_n_invoice_id        => null);
            IF l_v_orig_crd_sys_fund_type = l_v_crd_sys_fund_type THEN
              log_to_fnd(p_v_module  => 'box45_credits',
                       p_v_string  => 'Credit '||l_rec_crd.credit_id||' is an adjustment credit');
              l_b_orig_credit := FALSE;
              EXIT;
            END IF;
          END IF;
        END LOOP;

-- If it is original credit, then it is identified for Box4 else
-- it is an adjustment credit and it is identified for Box5
        IF l_b_orig_credit THEN
          l_n_aid_orig_credit := NVL(l_n_aid_orig_credit,0) +
                                 NVL(l_rec_crd.amount,0);
          l_n_box_num := 4;
        ELSE
          l_n_aid_adj_credit := NVL(l_n_aid_adj_credit,0) +
                                NVL(l_rec_crd.amount,0);
          l_n_box_num := 5;
        END IF;

        l_n_cntr := l_n_cntr + 1;
        l_t_1098t_drilldown(l_n_cntr).transaction_id := l_rec_crd.credit_id;
        l_t_1098t_drilldown(l_n_cntr).transaction_code := 'C';
        l_t_1098t_drilldown(l_n_cntr).box_num := l_n_box_num;

        l_n_box_num := null;

        log_to_fnd(p_v_module  => 'box45_credits',
                   p_v_string  => 'Updating the Credit '||l_rec_crd.credit_id);
        igs_fi_credits_pkg.update_row(x_rowid                       => l_rec_crd.row_id,
                                      x_credit_id                   => l_rec_crd.credit_id,
                                      x_credit_number               => l_rec_crd.credit_number,
                                      x_status                      => l_rec_crd.status,
                                      x_credit_source               => l_rec_crd.credit_source,
                                      x_party_id                    => l_rec_crd.party_id,
                                      x_credit_type_id              => l_rec_crd.credit_type_id,
                                      x_credit_instrument           => l_rec_crd.credit_instrument,
                                      x_description                 => l_rec_crd.description,
                                      x_amount                      => l_rec_crd.amount,
                                      x_currency_cd                 => l_rec_crd.currency_cd,
                                      x_exchange_rate               => l_rec_crd.exchange_rate,
                                      x_transaction_date            => l_rec_crd.transaction_date,
                                      x_effective_date              => l_rec_crd.effective_date,
                                      x_reversal_date               => l_rec_crd.reversal_date,
                                      x_reversal_reason_code        => l_rec_crd.reversal_reason_code,
                                      x_reversal_comments           => l_rec_crd.reversal_comments,
                                      x_unapplied_amount            => l_rec_crd.unapplied_amount,
                                      x_source_transaction_id       => l_rec_crd.source_transaction_id,
                                      x_receipt_lockbox_number      => l_rec_crd.receipt_lockbox_number,
                                      x_merchant_id                 => l_rec_crd.merchant_id,
                                      x_credit_card_code            => l_rec_crd.credit_card_code,
                                      x_credit_card_holder_name     => l_rec_crd.credit_card_holder_name,
                                      x_credit_card_number          => l_rec_crd.credit_card_number,
                                      x_credit_card_expiration_date => l_rec_crd.credit_card_expiration_date,
                                      x_credit_card_approval_code   => l_rec_crd.credit_card_approval_code,
                                      x_awd_yr_cal_type             => l_rec_crd.awd_yr_cal_type,
                                      x_awd_yr_ci_sequence_number   => l_rec_crd.awd_yr_ci_sequence_number,
                                      x_fee_cal_type                => l_rec_crd.fee_cal_type,
                                      x_fee_ci_sequence_number      => l_rec_crd.fee_ci_sequence_number,
                                      x_attribute_category          => l_rec_crd.attribute_category,
                                      x_attribute1                  => l_rec_crd.attribute1,
                                      x_attribute2                  => l_rec_crd.attribute2,
                                      x_attribute3                  => l_rec_crd.attribute3,
                                      x_attribute4                  => l_rec_crd.attribute4,
                                      x_attribute5                  => l_rec_crd.attribute5,
                                      x_attribute6                  => l_rec_crd.attribute6,
                                      x_attribute7                  => l_rec_crd.attribute7,
                                      x_attribute8                  => l_rec_crd.attribute8,
                                      x_attribute9                  => l_rec_crd.attribute9,
                                      x_attribute10                 => l_rec_crd.attribute10,
                                      x_attribute11                 => l_rec_crd.attribute11,
                                      x_attribute12                 => l_rec_crd.attribute12,
                                      x_attribute13                 => l_rec_crd.attribute13,
                                      x_attribute14                 => l_rec_crd.attribute14,
                                      x_attribute15                 => l_rec_crd.attribute15,
                                      x_attribute16                 => l_rec_crd.attribute16,
                                      x_attribute17                 => l_rec_crd.attribute17,
                                      x_attribute18                 => l_rec_crd.attribute18,
                                      x_attribute19                 => l_rec_crd.attribute19,
                                      x_attribute20                 => l_rec_crd.attribute20,
                                      x_gl_date                     => l_rec_crd.gl_date,
                                      x_check_number                => l_rec_crd.check_number,
                                      x_source_transaction_type     => l_rec_crd.source_transaction_type,
                                      x_source_transaction_ref      => l_rec_crd.source_transaction_ref,
                                      x_credit_card_status_code     => l_rec_crd.credit_card_status_code,
                                      x_credit_card_payee_cd        => l_rec_crd.credit_card_payee_cd,
                                      x_credit_card_tangible_cd     => l_rec_crd.credit_card_tangible_cd,
                                      x_lockbox_interface_id        => l_rec_crd.lockbox_interface_id,
                                      x_batch_name                  => l_rec_crd.batch_name,
                                      x_deposit_date                => l_rec_crd.deposit_date,
                                      x_source_invoice_id           => l_rec_crd.source_invoice_id,
                                      x_tax_year_code               => g_rec_1098t_setup.tax_year_code,
                                      x_waiver_name                 => l_rec_crd.waiver_name);
      END IF;
    END LOOP;

    p_n_orig_credit := l_n_aid_orig_credit;
    p_n_adj_credit  := l_n_aid_adj_credit;
  END box45_credits;

  PROCEDURE box45_charges(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                          p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                          p_n_orig_charge      OUT NOCOPY NUMBER,
                          p_n_adj_charge       OUT NOCOPY NUMBER) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for box 4 and 5 charges

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     skharida 26/06/06       Bug 5208136 - Removed the obsoleted columns of the table IGS_FI_INV_INT_ALL
     skharida 22/05/06       Bug 5213590 - Added changes to check for waiver name
     agairola 23/11/05       Bug:4747419 - Modified logic for Waiver Adjustment Charges
     agairola 05-Aug-2005    Changes as per Waiver build: 3392095
    ***************************************************************** */
    l_n_aid_orig_charge         NUMBER;
    l_n_aid_adj_charge          NUMBER;

    CURSOR cur_chg(cp_n_person_id       igs_pe_person_base_v.person_id%TYPE,
                   cp_d_start_date      DATE,
                   cp_d_end_date        DATE) IS
      SELECT inv.rowid row_id,
             inv.*,
             ft.s_fee_type
      FROM   igs_fi_inv_int_all inv,
             igs_fi_fee_type ft
      WHERE  inv.person_id = cp_n_person_id
      AND    ft.fee_type  = inv.fee_type
      AND    inv.tax_year_code IS NULL
      AND    TRUNC(inv.invoice_creation_date) BETWEEN TRUNC(cp_d_start_date) AND TRUNC(cp_d_end_date)
      AND    ft.s_fee_type IN ('AID_ADJ','WAIVER_ADJ');

    CURSOR cur_chk_orig_credit(cp_n_person_id                igs_pe_person_base_v.person_id%TYPE,
                               cp_v_fee_cal_type             igs_ca_inst.cal_type%TYPE,
                               cp_n_fee_ci_seq               igs_ca_inst.sequence_number%TYPE,
                               cp_d_start_date               DATE) IS
      SELECT crd.credit_id,
             crd.waiver_name
      FROM   igs_fi_credits_all crd,
             igs_fi_1098t_setup stp
      WHERE  crd.party_id  = cp_n_person_id
      AND    crd.fee_cal_type = cp_v_fee_cal_type
      AND    crd.fee_ci_sequence_number = cp_n_fee_ci_seq
      AND    TRUNC(transaction_date) < TRUNC(cp_d_start_date)
      AND    crd.tax_year_code IS NOT NULL
      AND    crd.tax_year_code = stp.tax_year_code
      AND    TRUNC(stp.end_date) < TRUNC(cp_d_start_date);

    l_rec_orig_crd                 cur_chk_orig_credit%ROWTYPE;
    l_b_process_charge             BOOLEAN;
    l_v_chg_sys_fund_type          igf_aw_fund_cat_all.sys_fund_type%TYPE;
    l_v_orig_crd_sys_fund_type     igf_aw_fund_cat_all.sys_fund_type%TYPE;
    l_b_orig_credit                BOOLEAN;
    l_n_box_num                    NUMBER;
    l_var                          VARCHAR2(1);
  BEGIN
    l_n_aid_orig_charge := 0;
    l_n_aid_adj_charge  := 0;

    log_to_fnd(p_v_module  => 'box45_charges',
               p_v_string  => 'Inside Box 45 Charges');

-- Loop through the Aid Adjustment charges
    FOR l_rec_chg IN cur_chg(p_n_person_id,
                             g_rec_1098t_setup.start_date,
                             g_rec_1098t_setup.end_date) LOOP
      l_b_process_charge := TRUE;

      IF l_rec_chg.s_fee_type <> 'WAIVER_ADJ' THEN
        l_v_chg_sys_fund_type := get_sys_fund_type(p_n_credit_id         => null,
                                                   p_n_invoice_id        => l_rec_chg.invoice_id);
        log_to_fnd(p_v_module  => 'box45_charges',
                   p_v_string  => 'Processing Invoice Id '||l_rec_chg.invoice_id||' For this invoice, system fund type is '||l_v_chg_sys_fund_type);

-- Check if the System Fund Type is associated to the Tax Year
        OPEN cur_chk_1098t_sfts(p_v_tax_year_name,
                                l_v_chg_sys_fund_type);
        FETCH cur_chk_1098t_sfts INTO l_var;
        IF cur_chk_1098t_sfts%NOTFOUND THEN
          log_to_fnd(p_v_module  => 'box45_charges',
                     p_v_string  => 'System Fund Type not associated to the tax year');
          l_b_process_charge := FALSE;
        END IF;
        CLOSE cur_chk_1098t_sfts;
      END IF;


      IF l_b_process_charge THEN
        l_b_orig_credit := TRUE;

-- Evaluate if the Charge selected is an original or adjustment charge
        FOR l_rec_orig_crd IN cur_chk_orig_credit(p_n_person_id,
                                                  l_rec_chg.fee_cal_type,
                                                  l_rec_chg.fee_ci_sequence_number,
                                                  g_rec_1098t_setup.start_date) LOOP

          IF l_rec_chg.s_fee_type = 'WAIVER_ADJ' THEN
            log_to_fnd(p_v_module  => 'box45_charges',
                       p_v_string  => 'For the waiver adjustment charge, identified it is adjustment');
            IF ((l_rec_orig_crd.waiver_name = l_rec_chg.waiver_name)
                 AND (l_rec_orig_crd.waiver_name IS NOT NULL)) THEN
              l_b_orig_credit := FALSE;
              EXIT;
            END IF;
          ELSE

            l_v_orig_crd_sys_fund_type := get_sys_fund_type(p_n_credit_id         => l_rec_orig_crd.credit_id,
                                                          p_n_invoice_id        => null);

            IF l_v_orig_crd_sys_fund_type = l_v_chg_sys_fund_type THEN
              log_to_fnd(p_v_module  => 'box45_charges',
                       p_v_string  => 'System Fund Type not associated to the tax year');
              l_b_orig_credit := FALSE;
            EXIT;
            END IF;
          END IF;
        END LOOP;

        IF l_b_orig_credit THEN
          l_n_aid_orig_charge := NVL(l_n_aid_orig_charge,0) +
                                 NVL(l_rec_chg.invoice_amount,0);
          l_n_box_num := 4;
        ELSE
          l_n_aid_adj_charge := NVL(l_n_aid_adj_charge,0) +
                                NVL(l_rec_chg.invoice_amount,0);
          l_n_box_num := 5;
        END IF;

        l_n_cntr := l_n_cntr + 1;
        l_t_1098t_drilldown(l_n_cntr).transaction_id := l_rec_chg.invoice_id;
        l_t_1098t_drilldown(l_n_cntr).transaction_code := 'D';
        l_t_1098t_drilldown(l_n_cntr).box_num := l_n_box_num;

        log_to_fnd(p_v_module  => 'box45_charges',
                   p_v_string  => 'Updating Charge transaction '||l_rec_chg.invoice_id);
        igs_fi_inv_int_pkg.update_row(x_rowid                         => l_rec_chg.row_id,
                                      x_invoice_id                    => l_rec_chg.invoice_id,
                                      x_person_id                     => l_rec_chg.person_id,
                                      x_fee_type                      => l_rec_chg.fee_type,
                                      x_fee_cat                       => l_rec_chg.fee_cat,
                                      x_fee_cal_type                  => l_rec_chg.fee_cal_type,
                                      x_fee_ci_sequence_number        => l_rec_chg.fee_ci_sequence_number,
                                      x_course_cd                     => l_rec_chg.course_cd,
                                      x_attendance_mode               => l_rec_chg.attendance_mode,
                                      x_attendance_type               => l_rec_chg.attendance_type,
                                      x_invoice_amount_due            => l_rec_chg.invoice_amount_due,
                                      x_invoice_creation_date         => l_rec_chg.invoice_creation_date,
                                      x_invoice_desc                  => l_rec_chg.invoice_desc,
                                      x_transaction_type              => l_rec_chg.transaction_type,
                                      x_currency_cd                   => l_rec_chg.currency_cd,
                                      x_status                        => l_rec_chg.status,
                                      x_attribute_category            => l_rec_chg.attribute_category,
                                      x_attribute1                    => l_rec_chg.attribute1,
                                      x_attribute2                    => l_rec_chg.attribute2,
                                      x_attribute3                    => l_rec_chg.attribute3,
                                      x_attribute4                    => l_rec_chg.attribute4,
                                      x_attribute5                    => l_rec_chg.attribute5,
                                      x_attribute6                    => l_rec_chg.attribute6,
                                      x_attribute7                    => l_rec_chg.attribute7,
                                      x_attribute8                    => l_rec_chg.attribute8,
                                      x_attribute9                    => l_rec_chg.attribute9,
                                      x_attribute10                   => l_rec_chg.attribute10,
                                      x_invoice_amount                => l_rec_chg.invoice_amount,
                                      x_bill_id                       => l_rec_chg.bill_id,
                                      x_bill_number                   => l_rec_chg.bill_number,
                                      x_bill_date                     => l_rec_chg.bill_date,
                                      x_waiver_flag                   => l_rec_chg.waiver_flag,
                                      x_waiver_reason                 => l_rec_chg.waiver_reason,
                                      x_effective_date                => l_rec_chg.effective_date,
                                      x_invoice_number                => l_rec_chg.invoice_number,
                                      x_exchange_rate                 => l_rec_chg.exchange_rate,
                                      x_bill_payment_due_date         => l_rec_chg.bill_payment_due_date,
                                      x_optional_fee_flag             => l_rec_chg.optional_fee_flag,
                                      x_reversal_gl_date              => l_rec_chg.reversal_gl_date,
                                      x_tax_year_code                 => g_rec_1098t_setup.tax_year_code,
                                      x_waiver_name                   => l_rec_chg.waiver_name);
      END IF;
    END LOOP;

    p_n_orig_charge := l_n_aid_orig_charge;
    p_n_adj_charge  := l_n_aid_adj_charge;

  END box45_charges;

  FUNCTION compute_box8(p_n_person_id             igs_pe_person_base_v.person_id%TYPE,
                        p_v_tax_year_name         igs_fi_1098t_setup.tax_year_name%TYPE) RETURN VARCHAR2 AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for Box 8

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_lps(cp_v_tax_year_name      igs_fi_1098t_setup.tax_year_name%TYPE) IS
      SELECT cal_type,
             sequence_number
      FROM   igs_fi_1098t_lps
      WHERE  tax_year_name = cp_v_tax_year_name
      AND    half_time_flag = 'Y';

    CURSOR cur_ats(cp_v_tax_year_name      igs_fi_1098t_setup.tax_year_name%TYPE,
                   cp_v_att_type           igs_en_atd_type.attendance_type%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_1098t_ats
      WHERE  tax_year_name = cp_v_tax_year_name
      AND    attendance_type = cp_v_att_type;

    l_v_att_type             igs_en_atd_type.attendance_type%TYPE;
    l_n_cp                   igs_fi_invln_int_all.credit_points%TYPE;
    l_n_fte                  igs_fi_invln_int_all.eftsu%TYPE;
    l_v_half_time_flag       igs_fi_1098t_data.half_time_flag%TYPE;
    l_var                    VARCHAR2(1);
  BEGIN
    l_v_half_time_flag := 'N';

    log_to_fnd(p_v_module  => 'compute_box8',
               p_v_string  => 'Inside Box 8');

-- Call the EN API to check for the Institution Attendance Type
-- for all the Load Periods associated to the tax year
    FOR l_rec_lps IN cur_lps(p_v_tax_year_name) LOOP
      igs_en_prc_load.enrp_get_inst_latt(p_person_id         => p_n_person_id,
                                         p_load_cal_type     => l_rec_lps.cal_type,
                                         p_load_seq_number   => l_rec_lps.sequence_number,
                                         p_attendance        => l_v_att_type,
                                         p_credit_points     => l_n_cp,
                                         p_fte               => l_n_fte);

-- Check if the Attendance Type is associated to the Tax Year
      OPEN cur_ats(p_v_tax_year_name,
                   l_v_att_type);
      FETCH cur_ats INTO l_var;
      IF cur_ats%FOUND THEN
        l_v_half_time_flag := 'Y';
      END IF;
      CLOSE cur_ats;

      IF l_v_half_time_flag = 'Y' THEN
        exit;
      END IF;
    END LOOP;

    log_to_fnd(p_v_module  => 'compute_box8',
               p_v_string  => 'Half time flag computed to '||l_v_half_time_flag);

    RETURN l_v_half_time_flag;
  END compute_box8;

  FUNCTION compute_box9(p_n_person_id             igs_pe_person_base_v.person_id%TYPE,
                        p_v_tax_year_name         igs_fi_1098t_setup.tax_year_name%TYPE) RETURN VARCHAR2 AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Function for Box 9

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */

    CURSOR cur_lps(cp_v_tax_year_name      igs_fi_1098t_setup.tax_year_name%TYPE) IS
      SELECT cal_type,
             sequence_number
      FROM   igs_fi_1098t_lps
      WHERE  tax_year_name = cp_v_tax_year_name
      AND    grad_flag = 'Y';

    CURSOR cur_load_teach(cp_v_cal_type          igs_ca_inst.cal_type%TYPE,
                          cp_n_ci_seq            igs_ca_inst.sequence_number%TYPE) IS
      SELECT teach_cal_type,
             teach_ci_sequence_number
      FROM   igs_ca_load_to_teach_v
      WHERE  load_cal_type = cp_v_cal_type
      AND    load_ci_sequence_number = cp_n_ci_seq;

    CURSOR cur_en_su_att(cp_n_person_id          igs_pe_person_base_v.person_id%TYPE,
                         cp_v_tax_year_name      igs_fi_1098t_setup.tax_year_name%TYPE,
                         cp_v_teach_cal_type     igs_ca_inst.cal_type%TYPE,
                         cp_n_teach_ci_seq       igs_ca_inst.sequence_number%TYPE) IS
      SELECT 'x'
      FROM   igs_en_su_attempt_all sua,
             igs_ps_ver ps,
             igs_fi_1098t_pts pts
      WHERE  sua.person_id = cp_n_person_id
      AND    sua.cal_type  = cp_v_teach_cal_type
      AND    sua.ci_sequence_number = cp_n_teach_ci_seq
      AND    sua.unit_attempt_status NOT IN ('UNCONFIRM',
                                             'WAITLISTED')
      AND    ps.course_cd = sua.course_cd
      AND    pts.course_type = ps.course_type
      AND    pts.tax_year_name = cp_v_tax_year_name;

    l_v_grad_flag           VARCHAR2(1);
    l_var                   VARCHAR2(1);
  BEGIN
    l_v_grad_flag := 'N';
    log_to_fnd(p_v_module  => 'compute_box9',
               p_v_string  => 'Inside Box 9');

-- Loop across the Load Periods for the tax year
    FOR l_rec_lps IN cur_lps(p_v_tax_year_name) LOOP

-- Fetch the teaching periods associated to the load period
      FOR l_rec_teach IN cur_load_teach(l_rec_lps.cal_type,
                                        l_rec_lps.sequence_number) LOOP

-- Verify if there exists a unit section for the student program attempt
-- for the teaching period identified where the program type is setup as
-- graduate program type in 1098T setup
        OPEN cur_en_su_att(p_n_person_id,
                           p_v_tax_year_name,
                           l_rec_teach.teach_cal_type,
                           l_rec_teach.teach_ci_sequence_number);
        FETCH cur_en_su_att INTO l_var;
        IF cur_en_su_att%FOUND THEN
          l_v_grad_flag := 'Y';
        END IF;
        CLOSE cur_en_su_att;

        IF l_v_grad_flag = 'Y' THEN
          EXIT;
        END IF;
      END LOOP;

      IF l_v_grad_flag = 'Y' THEN
        EXIT;
      END IF;
    END LOOP;

    log_to_fnd(p_v_module  => 'compute_box9',
               p_v_string  => 'Grad Flag computed to '||l_v_grad_flag);

    RETURN l_v_grad_flag;
  END compute_box9;

  PROCEDURE insert_1098t_data(p_v_tax_year_name          igs_fi_1098t_setup.tax_year_name%TYPE,
                              p_n_person_id              igs_pe_person_base_v.person_id%TYPE,
                              p_v_full_name              igs_pe_person_base_v.full_name%TYPE,
                              p_n_box2                   igs_fi_1098t_data.billed_amt%TYPE,
                              p_n_box3                   igs_fi_1098t_data.adj_amt%TYPE,
                              p_n_box4                   igs_fi_1098t_data.fin_aid_amt%TYPE,
                              p_n_box5                   igs_fi_1098t_data.fin_aid_adj_amt%TYPE,
                              p_v_box6                   igs_fi_1098t_data.next_acad_flag%TYPE,
                              p_v_box8                   igs_fi_1098t_data.half_time_flag%TYPE,
                              p_v_box9                   igs_fi_1098t_data.grad_flag%TYPE,
                              p_v_file_addr_correction   VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Procedure for creating 1098t records

     Known limitations,enhancements,remarks:
     Change History
     Who            When        What
    abshriva  30/11/05      Bug:4768071-Modification in where clause of cursor cur_party_sites
     abshriva  9/11/05        Bug:4695680-Modification in where clause and inclusion of new table
                                               'igs_pe_hz_pty_sites' in cursor 'cur_party_sites'
     abshriva     26/10/05      Bug:4697644-Modification in where clause for cursor 'cur_party_sites'

    ***************************************************************** */

    CURSOR cur_data_exists(cp_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                           cp_n_person_id            igs_pe_person_base_v.person_id%TYPE) IS
      SELECT tdata.rowid row_id, tdata.*
      FROM   igs_fi_1098t_data tdata
      WHERE  tdata.party_id = cp_n_person_id
      AND    tdata.tax_year_name = cp_v_tax_year_name
      AND    tdata.status_code <> 'DNT_RPT'
      ORDER BY tdata.stu_1098t_id desc
      FOR UPDATE NOWAIT;

    l_rec_1098t_data      cur_data_exists%ROWTYPE;

    l_v_api_pers_id        igs_pe_alt_pers_id.api_person_id%TYPE;
    l_v_api_pers_id_uf     igs_pe_alt_pers_id.api_person_id_uf%TYPE;

    l_v_rowid              VARCHAR2(2000);

    CURSOR cur_party_sites(cp_n_person_id                 igs_pe_person_base_v.person_id%TYPE,
                           cp_v_party_site_use_code       igs_fi_1098t_setup.perm_party_site_use_code%TYPE) IS
      SELECT ps.location_id,
             ps.identifying_address_flag,
             ps.status
      FROM   hz_party_site_uses hps,
             hz_party_sites  ps,
              igs_pe_hz_pty_sites igsps
      WHERE  ps.party_id = cp_n_person_id
      AND    ps.party_site_id = hps.party_site_id
      AND    hps.site_use_type = cp_v_party_site_use_code
      AND    hps.status = 'A'
      AND    igsps.party_site_id(+)=ps.party_site_id
      AND        TRUNC(sysdate)
      BETWEEN TRUNC(NVL(igsps.start_date,sysdate))
      AND      TRUNC(NVL(igsps.end_date,sysdate));

    CURSOR cur_locations(cp_location_id         hz_party_sites.location_id%TYPE) IS
      SELECT loc.address1,
             loc.address2,
             loc.address3,
             loc.address4,
             loc.country,
             loc.city,
             loc.state,
             loc.postal_code,
             loc.province,
             loc.county,
             loc.delivery_point_code
      FROM   hz_locations loc
      WHERE  location_id = cp_location_id;

    l_rec_locations             cur_locations%ROWTYPE;

    l_n_perm_cntr               PLS_INTEGER;
    l_n_temp_cntr               PLS_INTEGER;
    l_n_location_id             hz_locations.location_id%TYPE;
    l_v_error_code              igs_fi_1098t_data.error_code%TYPE;

    l_b_rec_exists              BOOLEAN;

    CURSOR cur_1098t_dtl(cp_n_stu_1098t_id          igs_fi_1098t_data.stu_1098t_id%TYPE) IS
      SELECT rowid
      FROM   igs_fi_1098t_dtls
      WHERE  stu_1098t_id = cp_n_stu_1098t_id;

    CURSOR cur_1098t_data_lat(cp_n_person_id        igs_pe_person_base_v.person_id%TYPE,
                              cp_v_tax_year_name    igs_fi_1098t_data.tax_year_name%TYPE) IS
      SELECT dat.*, dat.rowid row_id
      FROM   igs_fi_1098t_data dat
      WHERE  party_id = cp_n_person_id
      AND    tax_year_name = cp_v_tax_year_name
      AND    irs_filed_flag = 'Y'
      AND    status_code <> 'DNT_RPT'
      ORDER BY stu_1098t_id DESC;


    l_rec_1098t_data_lat     cur_1098t_data_lat%ROWTYPE;
    l_b_perm_addr            BOOLEAN;
    l_b_temp_addr            BOOLEAN;
    l_v_name_control         igs_pe_alt_pers_id.api_person_id%TYPE;
    l_v_name_control_uf      igs_pe_alt_pers_id.api_person_id_uf%TYPE;
    l_b_correction_record    BOOLEAN;
    l_v_correction_flag      igs_fi_1098t_data.correction_flag%TYPE;
    l_v_correction_code      igs_fi_1098t_data.correction_type_code%TYPE;
    l_n_stu_1098t_id         igs_fi_1098t_data.stu_1098t_id%TYPE;
    l_b_txn                  BOOLEAN;

    l_v_val_name_ctrl        VARCHAR2(1);

  BEGIN
    l_v_val_name_ctrl := 'Y';
    log_to_fnd(p_v_module  => 'insert_1098t_data',
               p_v_string  => 'Inside creating 1098t transactions');

-- Get the alternate Person Id.
    get_alt_person_id(p_n_person_id,
                      null,
                      'SSN',
                      l_v_api_pers_id,
                      l_v_api_pers_id_uf);

    l_v_correction_flag := 'N';
    l_v_error_code := null;

    IF l_v_api_pers_id IS NULL THEN
      get_alt_person_id(p_n_person_id,
                        g_rec_1098t_setup.person_id_type,
                        'TAXID',
                        l_v_api_pers_id,
                        l_v_api_pers_id_uf);
    END IF;


    log_to_fnd(p_v_module  => 'insert_1098t_data',
               p_v_string  => 'API Person Id calculated as '||l_v_api_pers_id);

    l_b_txn := FALSE;

-- If alternate person id is null, then mark the status as Failed with Invalid TIN as
-- error code
    IF l_v_api_pers_id IS NULL THEN
      set_validation_status('FAILED');
      l_v_error_code := 'INVALID_TIN';
    ELSE

-- Else validate the API Person Id
      IF NOT igf_ap_li_isir_imp_proc.val_ssn(l_value  => l_v_api_pers_id_uf) THEN
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Call to igf procedure for validating SSN failed');
        set_validation_status('FAILED');
        l_v_error_code := 'INVALID_TIN';
      ELSE
        IF NOT validate_tin(l_v_api_pers_id_uf) THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                     p_v_string  => 'Call to validate_tin failed');
          set_validation_status('FAILED');
          l_v_error_code := 'INVALID_TIN';
        END IF;
      END IF;
    END IF;

    l_n_perm_cntr := 0;
    l_n_temp_cntr := 0;

    l_b_perm_addr := FALSE;

-- Loop across the Party Sites for the person id and the permanent party site use code
    FOR l_rec_party_sites IN cur_party_sites(p_n_person_id,
                                             g_rec_1098t_setup.perm_party_site_use_code) LOOP
      l_n_perm_cntr := l_n_perm_cntr + 1;

-- if the identifying_address_flag flag is set and the status is Active, then the permanent address
-- is found
      IF (l_rec_party_sites.identifying_address_flag = 'Y' AND l_rec_party_sites.status = 'A') THEN
        l_n_location_id := l_rec_party_sites.location_id;
        l_b_perm_addr := TRUE;
        EXIT;
      END IF;
    END LOOP;

-- If there were multiple party sites identified but none of them had the identifying_address_flag
-- flag set with status as active then mark the record as FAILED with INVALID_ADD
    IF l_n_perm_cntr >= 1 AND NOT l_b_perm_addr THEN
      log_to_fnd(p_v_module  => 'insert_1098t_data',
                 p_v_string  => 'Permanent Address could not be identified. Hence Invalid Address');
      set_validation_status('FAILED');
      l_v_error_code := 'INVALID_ADD';
    END IF;

-- If there were no records found, then use the temporary party site use code.
    IF l_n_perm_cntr = 0 THEN
      l_b_temp_addr := FALSE;
      FOR l_rec_party_sites IN cur_party_sites(p_n_person_id,
                                               g_rec_1098t_setup.temp_party_site_use_code) LOOP
        l_n_perm_cntr := l_n_perm_cntr + 1;
        IF (l_rec_party_sites.identifying_address_flag = 'Y' AND l_rec_party_sites.status = 'A') THEN
          l_n_location_id := l_rec_party_sites.location_id;
          l_b_temp_addr := TRUE;
          EXIT;
        END IF;
      END LOOP;

      IF l_n_perm_cntr >= 1 AND NOT l_b_temp_addr THEN
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Temporary Address could not be identified. Hence Invalid Address');
        set_validation_status('FAILED');
        l_v_error_code := 'INVALID_ADD';
      END IF;
    END IF;

-- If there are no addresses defined for the address usage, then
    IF l_n_perm_cntr = 0 THEN
      log_to_fnd(p_v_module  => 'insert_1098t_data',
                 p_v_string  => 'Neither temporary nor permanent address could be identified. Hence Invalid Address');
      set_validation_status('FAILED');
      l_v_error_code := 'INVALID_ADD';
    END IF;

-- Fetch the location values
    IF l_n_location_id IS NOT NULL THEN
      OPEN cur_locations(l_n_location_id);
      FETCH cur_locations INTO l_rec_locations;
      CLOSE cur_locations;
    END IF;

    IF l_rec_locations.country IS NULL OR
       l_rec_locations.city IS NULL OR
       l_rec_locations.state IS NULL OR
       l_rec_locations.postal_code IS NULL THEN
      set_validation_status('FAILED');
      l_v_error_code := 'INVALID_ADD';
    END IF;

-- Get the name control
    get_alt_person_id(p_n_person_id            => p_n_person_id,
                      p_v_person_id_type       => null,
                      p_v_s_person_id_type     => 'NAME_CONTROL',
                      p_v_api_pers_id          => l_v_name_control,
                      p_v_api_pers_id_uf       => l_v_name_control_uf);

-- Validate Name Control.
    l_v_val_name_ctrl := validate_namecontrol(p_v_name_control     => l_v_name_control);

    log_to_fnd(p_v_module  => 'insert_1098t_data',
               p_v_string  => 'Name Control = '||l_v_name_control);

-- If the name control is invalid, then status is failed and error code is
-- set to INVALID_NAME_CONTROL

    IF l_v_val_name_ctrl = 'N' THEN
      set_validation_status('FAILED');
      l_v_error_code := 'INVALID_NAME_CONTROL';
    END IF;

    l_b_rec_exists := FALSE;

-- Check if a record exists for the person and tax year
    OPEN cur_data_exists(p_v_tax_year_name,
                         p_n_person_id);
    FETCH cur_data_exists INTO l_rec_1098t_data;
    IF cur_data_exists%FOUND THEN
      l_b_rec_exists := TRUE;
    END IF;
    CLOSE cur_data_exists;

    log_line(g_v_label_name_control,
             l_v_name_control);

    log_line(g_v_label_tin,
             l_v_api_pers_id);

    fnd_file.new_line(fnd_file.log);

    IF NOT l_b_rec_exists THEN

-- If there are no records existing, then create a new record in the 1098T Extract table
-- and 1098T Details table

      log_to_fnd(p_v_module  => 'insert_1098t_data',
                 p_v_string  => 'There is no 1098T record existing. Hence creating a new record.');

      l_v_rowid := null;
      l_n_stu_1098t_id := null;
      l_b_txn := TRUE;
      igs_fi_1098t_data_pkg.insert_row( x_rowid                  => l_v_rowid,
                                        x_stu_1098t_id           => l_n_stu_1098t_id,
                                        x_tax_year_name          => p_v_tax_year_name,
                                        x_party_id               => p_n_person_id,
                                        x_extract_date           => trunc(sysdate),
                                        x_party_name             => p_v_full_name,
                                        x_taxid                  => l_v_api_pers_id,
                                        x_stu_name_control       => l_v_name_control,
                                        x_country                => l_rec_locations.country,
                                        x_address1               => l_rec_locations.address1,
                                        x_address2               => l_rec_locations.address2,
                                        x_refund_amt             => 0,
                                        x_half_time_flag         => p_v_box8,
                                        x_grad_flag              => p_v_box9,
                                        x_special_data_entry     => null,
                                        x_status_code            => g_v_validation_status,
                                        x_error_code             => l_v_error_code,
                                        x_file_name              => null,
                                        x_irs_filed_flag         => 'N',
                                        x_correction_flag        => 'N',
                                        x_correction_type_code   => null,
                                        x_stmnt_print_flag       => 'N',
                                        x_override_flag          => 'N',
                                        x_address3               => l_rec_locations.address3,
                                        x_address4               => l_rec_locations.address4,
                                        x_city                   => l_rec_locations.city,
                                        x_postal_code            => l_rec_locations.postal_code,
                                        x_state                  => l_rec_locations.state,
                                        x_province               => l_rec_locations.province,
                                        x_county                 => l_rec_locations.county,
                                        x_delivery_point_code    => l_rec_locations.delivery_point_code,
                                        x_payment_amt            => 0,
                                        x_billed_amt             => p_n_box2,
                                        x_adj_amt                => p_n_box3,
                                        x_fin_aid_amt            => p_n_box4,
                                        x_fin_aid_adj_amt        => p_n_box5,
                                        x_next_acad_flag         => p_v_box6,
                                        x_batch_id               => null,
                                        x_mode                   => 'R');
      IF l_t_1098t_drilldown.COUNT > 0 THEN
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Creating '||l_t_1098t_drilldown.COUNT||' detail records for the 1098T record');
        FOR l_n_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
          IF l_t_1098t_drilldown.EXISTS(l_n_rec_cntr) THEN
            l_v_rowid := null;
            igs_fi_1098t_dtls_pkg.insert_row(x_rowid            => l_v_rowid,
                                             x_stu_1098t_id     => l_n_stu_1098t_id,
                                             x_transaction_id   => l_t_1098t_drilldown(l_n_rec_cntr).transaction_id,
                                             x_transaction_code => l_t_1098t_drilldown(l_n_rec_cntr).transaction_code,
                                             x_box_num          => l_t_1098t_drilldown(l_n_rec_cntr).box_num);
          END IF;
        END LOOP;
      END IF;
    ELSE
      log_to_fnd(p_v_module  => 'insert_1098t_data',
                 p_v_string  => '1098T Data record exists for the person');

-- If the record exists, then check if it has already been filed to IRS
      IF l_rec_1098t_data.irs_filed_flag = 'Y' THEN
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Original Record has been filed to IRS');
        l_b_correction_record := FALSE;

-- Check if any of the box amounts have changed. If yes, then set the flag for
-- correction record identification
        IF (l_rec_1098t_data.billed_amt <> p_n_box2 OR
            l_rec_1098t_data.adj_amt  <> p_n_box3 OR
            l_rec_1098t_data.fin_aid_amt <> p_n_box4 OR
            l_rec_1098t_data.fin_aid_adj_amt <> p_n_box5 OR
            l_rec_1098t_data.next_acad_flag <> p_v_box6 OR
            l_rec_1098t_data.half_time_flag <> p_v_box8 OR
            l_rec_1098t_data.grad_flag <> p_v_box9
            ) THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                    p_v_string  => 'Correction record needs to be created as the box values are different');

          l_b_correction_record := TRUE;
          l_v_correction_flag := 'Y';
          l_v_correction_code := '1';
        END IF;

-- If the file address correction parameter has been passed as Yes, then check if there is a change in
-- the address details
        IF p_v_file_addr_correction = 'Y' AND NOT l_b_correction_record THEN
          IF (((l_rec_1098t_data.address1 = l_rec_locations.address1) OR
               (l_rec_1098t_data.address1 IS NULL AND l_rec_locations.address1 IS NULL)) AND
              ((l_rec_1098t_data.address2 = l_rec_locations.address2) OR
               (l_rec_1098t_data.address2 IS NULL AND l_rec_locations.address2 IS NULL)) AND
              ((l_rec_1098t_data.address3 = l_rec_locations.address3) OR
               (l_rec_1098t_data.address3 IS NULL AND l_rec_locations.address3 IS NULL)) AND
              ((l_rec_1098t_data.address4 = l_rec_locations.address4) OR
               (l_rec_1098t_data.address4 IS NULL AND l_rec_locations.address4 IS NULL)) AND
              ((l_rec_1098t_data.city = l_rec_locations.city) OR
               (l_rec_1098t_data.city IS NULL AND l_rec_locations.city IS NULL)) AND
              ((l_rec_1098t_data.state = l_rec_locations.state) OR
               (l_rec_1098t_data.state IS NULL AND l_rec_locations.state IS NULL)) AND
              ((l_rec_1098t_data.province = l_rec_locations.province) OR
               (l_rec_1098t_data.province IS NULL AND l_rec_locations.province IS NULL)) AND
              ((l_rec_1098t_data.county = l_rec_locations.county) OR
               (l_rec_1098t_data.county IS NULL AND l_rec_locations.county IS NULL)) AND
              ((l_rec_1098t_data.country = l_rec_locations.country) OR
               (l_rec_1098t_data.country IS NULL AND l_rec_locations.country IS NULL)) AND
              ((l_rec_1098t_data.postal_code = l_rec_locations.postal_code) OR
               (l_rec_1098t_data.postal_code IS NULL AND l_rec_locations.postal_code IS NULL)) AND
              ((l_rec_1098t_data.delivery_point_code = l_rec_locations.delivery_point_code) OR
               (l_rec_1098t_data.delivery_point_code IS NULL AND l_rec_locations.delivery_point_code IS NULL))) THEN
            null;
          ELSE
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Correction record needs to be created as the address has changed');
            l_b_correction_record := TRUE;
            l_v_correction_flag := 'Y';
            l_v_correction_code := '1';
          END IF;
        END IF;

-- Check if there is a change in the Tax ID. If yes, then set the flag for correction record
        IF ((l_rec_1098t_data.taxid <> l_v_api_pers_id)) THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                    p_v_string  => 'Correction record needs to be created as the Alternate Person Id has changed');
          l_b_correction_record := TRUE;
          l_v_correction_flag := 'Y';
          l_v_correction_code := '2';
        END IF;

-- Check if there is a change in the Full Name. If yes, then set the flag for correction record
        IF ((l_rec_1098t_data.party_name <> p_v_full_name)) THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                    p_v_string  => 'Correction record needs to be created as full name has changed');
          l_b_correction_record := TRUE;
          l_v_correction_flag := 'Y';
          l_v_correction_code := '2';
        END IF;

        IF NOT l_b_correction_record THEN
          fnd_message.set_name('IGS',
                               'IGS_FI_1098T_REC_NOT_CREATED');
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                     p_v_string  => 'Correction Record does not need to be created. Hence exiting from this procedure');
          RETURN;
        END IF;

        l_v_rowid := null;
        l_n_stu_1098t_id := null;
        l_b_txn := TRUE;
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Creating a new correction record');

-- Creating a new record as the original has already been filed to IRS
        igs_fi_1098t_data_pkg.insert_row( x_rowid                  => l_v_rowid,
                                          x_stu_1098t_id           => l_n_stu_1098t_id,
                                          x_tax_year_name          => p_v_tax_year_name,
                                          x_party_id               => p_n_person_id,
                                          x_extract_date           => trunc(sysdate),
                                          x_party_name             => p_v_full_name,
                                          x_taxid                  => l_v_api_pers_id,
                                          x_stu_name_control       => l_v_name_control,
                                          x_country                => l_rec_locations.country,
                                          x_address1               => l_rec_locations.address1,
                                          x_address2               => l_rec_locations.address2,
                                          x_refund_amt             => l_rec_1098t_data.refund_amt,
                                          x_half_time_flag         => p_v_box8,
                                          x_grad_flag              => p_v_box9,
                                          x_special_data_entry     => l_rec_1098t_data.special_data_entry,
                                          x_status_code            => g_v_validation_status,
                                          x_error_code             => l_v_error_code,
                                          x_file_name              => null,
                                          x_irs_filed_flag         => 'N',
                                          x_correction_flag        => l_v_correction_flag,
                                          x_correction_type_code   => l_v_correction_code,
                                          x_stmnt_print_flag       => 'N',
                                          x_override_flag          => 'N',
                                          x_address3               => l_rec_locations.address3,
                                          x_address4               => l_rec_locations.address4,
                                          x_city                   => l_rec_locations.city,
                                          x_postal_code            => l_rec_locations.postal_code,
                                          x_state                  => l_rec_locations.state,
                                          x_province               => l_rec_locations.province,
                                          x_county                 => l_rec_locations.county,
                                          x_delivery_point_code    => l_rec_locations.delivery_point_code,
                                          x_payment_amt            => l_rec_1098t_data.payment_amt,
                                          x_billed_amt             => p_n_box2,
                                          x_adj_amt                => p_n_box3,
                                          x_fin_aid_amt            => p_n_box4,
                                          x_fin_aid_adj_amt        => p_n_box5,
                                          x_next_acad_flag         => p_v_box6,
                                          x_batch_id               => null,
                                          x_mode                   => 'R');

        IF l_t_1098t_drilldown.COUNT > 0 THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                     p_v_string  => 'Creating '||l_t_1098t_drilldown.COUNT||' detail records for the 1098T record');
          FOR l_n_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
            IF l_t_1098t_drilldown.EXISTS(l_n_rec_cntr) THEN
              l_v_rowid := null;
              igs_fi_1098t_dtls_pkg.insert_row(x_rowid            => l_v_rowid,
                                               x_stu_1098t_id     => l_n_stu_1098t_id,
                                               x_transaction_id   => l_t_1098t_drilldown(l_n_rec_cntr).transaction_id,
                                               x_transaction_code => l_t_1098t_drilldown(l_n_rec_cntr).transaction_code,
                                               x_box_num          => l_t_1098t_drilldown(l_n_rec_cntr).box_num);
            END IF;
          END LOOP;
        END IF;
      ELSE

-- If the record has not been filed to IRS,
        log_to_fnd(p_v_module  => 'insert_1098t_data',
                   p_v_string  => 'Original Record has not been filed to IRS');

-- Check if the correction flag has been set for the 1098t record
        IF l_rec_1098t_data.correction_flag = 'N' THEN
          log_to_fnd(p_v_module  => 'insert_1098t_data',
                    p_v_string  => 'Correction flag has not been set. Hence delete all detail records.');

-- If it is No, then delete all the records in the 1098T details table
          FOR l_rec_dtl IN cur_1098t_dtl(l_rec_1098t_data.stu_1098t_id) LOOP
            igs_fi_1098t_dtls_pkg.delete_row(x_rowid    => l_rec_dtl.rowid);
          END LOOP;

          l_b_txn := TRUE;

          log_to_fnd(p_v_module  => 'insert_1098t_data',
                    p_v_string  => 'Update the 1098T Transaction record');

-- Update the 1098T record and create new records in the details table
          igs_fi_1098t_data_pkg.update_row(x_rowid                  => l_rec_1098t_data.row_id,
                                           x_stu_1098t_id           => l_rec_1098t_data.stu_1098t_id,
                                           x_tax_year_name          => p_v_tax_year_name,
                                           x_party_id               => l_rec_1098t_data.party_id,
                                           x_extract_date           => trunc(sysdate),
                                           x_party_name             => p_v_full_name,
                                           x_taxid                  => l_v_api_pers_id,
                                           x_stu_name_control       => l_v_name_control,
                                           x_country                => l_rec_locations.country,
                                           x_address1               => l_rec_locations.address1,
                                           x_address2               => l_rec_locations.address2,
                                           x_refund_amt             => l_rec_1098t_data.refund_amt,
                                           x_half_time_flag         => p_v_box8,
                                           x_grad_flag              => p_v_box9,
                                           x_special_data_entry     => l_rec_1098t_data.special_data_entry,
                                           x_status_code            => g_v_validation_status,
                                           x_error_code             => l_v_error_code,
                                           x_file_name              => null,
                                           x_irs_filed_flag         => 'N',
                                           x_correction_flag        => l_rec_1098t_data.correction_flag,
                                           x_correction_type_code   => l_rec_1098t_data.correction_type_code,
                                           x_stmnt_print_flag       => 'N',
                                           x_override_flag          => 'N',
                                           x_address3               => l_rec_locations.address3,
                                           x_address4               => l_rec_locations.address4,
                                           x_city                   => l_rec_locations.city,
                                           x_postal_code            => l_rec_locations.postal_code,
                                           x_state                  => l_rec_locations.state,
                                           x_province               => l_rec_locations.province,
                                           x_county                 => l_rec_locations.county,
                                           x_delivery_point_code    => l_rec_locations.delivery_point_code,
                                           x_payment_amt            => l_rec_1098t_data.payment_amt,
                                           x_billed_amt             => p_n_box2,
                                           x_adj_amt                => p_n_box3,
                                           x_fin_aid_amt            => p_n_box4,
                                           x_fin_aid_adj_amt        => p_n_box5,
                                           x_next_acad_flag         => p_v_box6,
                                           x_batch_id               => null,
                                           x_mode                   => 'R');
          IF l_t_1098t_drilldown.COUNT > 0 THEN
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Creating '||l_t_1098t_drilldown.COUNT||' detail records for the 1098T record');
            FOR l_n_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
              IF l_t_1098t_drilldown.EXISTS(l_n_rec_cntr) THEN
                l_v_rowid := null;
                igs_fi_1098t_dtls_pkg.insert_row(x_rowid            => l_v_rowid,
                                                 x_stu_1098t_id     => l_rec_1098t_data.stu_1098t_id,
                                                 x_transaction_id   => l_t_1098t_drilldown(l_n_rec_cntr).transaction_id,
                                                 x_transaction_code => l_t_1098t_drilldown(l_n_rec_cntr).transaction_code,
                                                 x_box_num          => l_t_1098t_drilldown(l_n_rec_cntr).box_num);
              END IF;
            END LOOP;
          END IF;
        ELSE


          log_to_fnd(p_v_module  => 'insert_1098t_data',
                     p_v_string  => 'Correction Flag has been set.');
          OPEN cur_1098t_data_lat(p_n_person_id,
                                  p_v_tax_year_name);
          FETCH cur_1098t_data_lat INTO l_rec_1098t_data_lat;
          CLOSE cur_1098t_data_lat;

          l_b_correction_record := FALSE;

-- Check if the box amounts have changed.
          IF (l_rec_1098t_data_lat.billed_amt <> p_n_box2 OR
              l_rec_1098t_data_lat.adj_amt <> p_n_box3 OR
              l_rec_1098t_data_lat.fin_aid_amt <> p_n_box4 OR
              l_rec_1098t_data_lat.fin_aid_adj_amt <> p_n_box5 OR
              l_rec_1098t_data_lat.next_acad_flag <> p_v_box6 OR
              l_rec_1098t_data_lat.half_time_flag <> p_v_box8 OR
              l_rec_1098t_data_lat.grad_flag <> p_v_box9
             ) THEN
             log_to_fnd(p_v_module  => 'insert_1098t_data',
                        p_v_string  => 'Correction record needs to be created as the box values have changed');
             l_v_correction_flag := 'Y';
             l_v_correction_code := '1';
             l_b_correction_record := TRUE;
          END IF;

-- If the file address correction has been passed as Y, check for address change
          IF (p_v_file_addr_correction = 'Y' AND NOT l_b_correction_record) THEN
            IF (((l_rec_1098t_data_lat.address1 = l_rec_locations.address1) OR
                 (l_rec_1098t_data_lat.address1 IS NULL AND l_rec_locations.address1 IS NULL)) AND
                ((l_rec_1098t_data_lat.address2 = l_rec_locations.address2) OR
                 (l_rec_1098t_data_lat.address2 IS NULL AND l_rec_locations.address2 IS NULL)) AND
                ((l_rec_1098t_data_lat.address3 = l_rec_locations.address3) OR
                 (l_rec_1098t_data_lat.address3 IS NULL AND l_rec_locations.address3 IS NULL)) AND
                ((l_rec_1098t_data_lat.address4 = l_rec_locations.address4) OR
                 (l_rec_1098t_data_lat.address4 IS NULL AND l_rec_locations.address4 IS NULL)) AND
                ((l_rec_1098t_data_lat.city = l_rec_locations.city) OR
                 (l_rec_1098t_data_lat.city IS NULL AND l_rec_locations.city IS NULL)) AND
                ((l_rec_1098t_data_lat.state = l_rec_locations.state) OR
                 (l_rec_1098t_data_lat.state IS NULL AND l_rec_locations.state IS NULL)) AND
                ((l_rec_1098t_data_lat.province = l_rec_locations.province) OR
                 (l_rec_1098t_data_lat.province IS NULL AND l_rec_locations.province IS NULL)) AND
                ((l_rec_1098t_data_lat.county = l_rec_locations.county) OR
                 (l_rec_1098t_data_lat.county IS NULL AND l_rec_locations.county IS NULL)) AND
                ((l_rec_1098t_data_lat.country = l_rec_locations.country) OR
                 (l_rec_1098t_data_lat.country IS NULL AND l_rec_locations.country IS NULL)) AND
                ((l_rec_1098t_data_lat.postal_code = l_rec_locations.postal_code) OR
                 (l_rec_1098t_data_lat.postal_code IS NULL AND l_rec_locations.postal_code IS NULL)) AND
                ((l_rec_1098t_data_lat.delivery_point_code = l_rec_locations.delivery_point_code) OR
                 (l_rec_1098t_data_lat.delivery_point_code IS NULL AND l_rec_locations.delivery_point_code IS NULL))) THEN
              null;
            ELSE
              log_to_fnd(p_v_module  => 'insert_1098t_data',
                         p_v_string  => 'Correction record needs to be created as the address has changed');
              l_b_correction_record := TRUE;
              l_v_correction_flag := 'Y';
              l_v_correction_code := '1';
            END IF;
          END IF;

-- Check for change in Alternate Person Id
          IF ((l_rec_1098t_data_lat.taxid <> l_v_api_pers_id)) THEN
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Correction record needs to be created as Alternate Person Id has changed');
            l_b_correction_record := TRUE;
            l_v_correction_flag := 'Y';
            l_v_correction_code := '2';
          END IF;

-- Check for change in the Party Name
          IF l_rec_1098t_data_lat.party_name <> p_v_full_name THEN
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Correction record needs to be created as the address has changed');
            l_b_correction_record := TRUE;
            l_v_correction_flag := 'Y';
            l_v_correction_code := '2';
          END IF;

          IF NOT l_b_correction_record THEN
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Correction record needs not be created. Hence updating the record with DNT_RPT status');
            l_b_txn := TRUE;

            g_v_validation_status := 'DNT_RPT';

-- If there is no change, then update the record with status as DNT_RPT
            igs_fi_1098t_data_pkg.update_row(x_rowid                  => l_rec_1098t_data.row_id,
                                             x_stu_1098t_id           => l_rec_1098t_data.stu_1098t_id,
                                             x_tax_year_name          => l_rec_1098t_data.tax_year_name,
                                             x_party_id               => l_rec_1098t_data.party_id,
                                             x_extract_date           => l_rec_1098t_data.extract_date,
                                             x_party_name             => l_rec_1098t_data.party_name,
                                             x_taxid                  => l_rec_1098t_data.taxid,
                                             x_stu_name_control       => l_rec_1098t_data.stu_name_control,
                                             x_country                => l_rec_1098t_data.country,
                                             x_address1               => l_rec_1098t_data.address1,
                                             x_address2               => l_rec_1098t_data.address2,
                                             x_refund_amt             => l_rec_1098t_data.refund_amt,
                                             x_half_time_flag         => l_rec_1098t_data.half_time_flag,
                                             x_grad_flag              => l_rec_1098t_data.grad_flag,
                                             x_special_data_entry     => l_rec_1098t_data.special_data_entry,
                                             x_status_code            => 'DNT_RPT',
                                             x_error_code             => l_rec_1098t_data.error_code,
                                             x_file_name              => l_rec_1098t_data.file_name,
                                             x_irs_filed_flag         => l_rec_1098t_data.irs_filed_flag,
                                             x_correction_flag        => l_rec_1098t_data.correction_flag,
                                             x_correction_type_code   => l_rec_1098t_data.correction_type_code,
                                             x_stmnt_print_flag       => l_rec_1098t_data.stmnt_print_flag,
                                             x_override_flag          => l_rec_1098t_data.override_flag,
                                             x_address3               => l_rec_1098t_data.address3,
                                             x_address4               => l_rec_1098t_data.address4,
                                             x_city                   => l_rec_1098t_data.city,
                                             x_postal_code            => l_rec_1098t_data.postal_code,
                                             x_state                  => l_rec_1098t_data.state,
                                             x_province               => l_rec_1098t_data.province,
                                             x_county                 => l_rec_1098t_data.county,
                                             x_delivery_point_code    => l_rec_1098t_data.delivery_point_code,
                                             x_payment_amt            => l_rec_1098t_data.payment_amt,
                                             x_billed_amt             => l_rec_1098t_data.billed_amt,
                                             x_adj_amt                => l_rec_1098t_data.adj_amt,
                                             x_fin_aid_amt            => l_rec_1098t_data.fin_aid_amt,
                                             x_fin_aid_adj_amt        => l_rec_1098t_data.fin_aid_adj_amt,
                                             x_next_acad_flag         => l_rec_1098t_data.next_acad_flag,
                                             x_batch_id               => l_rec_1098t_data.batch_id,
                                             x_mode                   => 'R');
          ELSE

            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Correction record needs to be created. Hence delete all detail records');

-- If there is a change, then delete records from the 1098T detail table
            FOR l_rec_dtl IN cur_1098t_dtl(l_rec_1098t_data.stu_1098t_id) LOOP
              igs_fi_1098t_dtls_pkg.delete_row(x_rowid    => l_rec_dtl.rowid);
            END LOOP;

            l_b_txn := TRUE;
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Updating the 1098T record');

-- Update the 1098T table and create new detail records
            igs_fi_1098t_data_pkg.update_row(x_rowid                  => l_rec_1098t_data.row_id,
                                             x_stu_1098t_id           => l_rec_1098t_data.stu_1098t_id,
                                             x_tax_year_name          => p_v_tax_year_name,
                                             x_party_id               => l_rec_1098t_data.party_id,
                                             x_extract_date           => trunc(sysdate),
                                             x_party_name             => p_v_full_name,
                                             x_taxid                  => l_v_api_pers_id,
                                             x_stu_name_control       => l_v_name_control,
                                             x_country                => l_rec_locations.country,
                                             x_address1               => l_rec_locations.address1,
                                             x_address2               => l_rec_locations.address2,
                                             x_refund_amt             => l_rec_1098t_data.refund_amt,
                                             x_half_time_flag         => p_v_box8,
                                             x_grad_flag              => p_v_box9,
                                             x_special_data_entry     => l_rec_1098t_data.special_data_entry,
                                             x_status_code            => g_v_validation_status,
                                             x_error_code             => l_v_error_code,
                                             x_file_name              => null,
                                             x_irs_filed_flag         => 'N',
                                             x_correction_flag        => l_v_correction_flag,
                                             x_correction_type_code   => l_v_correction_code,
                                             x_stmnt_print_flag       => 'N',
                                             x_override_flag          => 'N',
                                             x_address3               => l_rec_locations.address3,
                                             x_address4               => l_rec_locations.address4,
                                             x_city                   => l_rec_locations.city,
                                             x_postal_code            => l_rec_locations.postal_code,
                                             x_state                  => l_rec_locations.state,
                                             x_province               => l_rec_locations.province,
                                             x_county                 => l_rec_locations.county,
                                             x_delivery_point_code    => l_rec_locations.delivery_point_code,
                                             x_payment_amt            => l_rec_1098t_data.payment_amt,
                                             x_billed_amt             => p_n_box2,
                                             x_adj_amt                => p_n_box3,
                                             x_fin_aid_amt            => p_n_box4,
                                             x_fin_aid_adj_amt        => p_n_box5,
                                             x_next_acad_flag         => p_v_box6,
                                             x_batch_id               => null,
                                             x_mode                   => 'R');
            IF l_t_1098t_drilldown.COUNT > 0 THEN
            log_to_fnd(p_v_module  => 'insert_1098t_data',
                       p_v_string  => 'Creating '||l_t_1098t_drilldown.COUNT||' detail records for the 1098T record');
              FOR l_n_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
                IF l_t_1098t_drilldown.EXISTS(l_n_rec_cntr) THEN
                  l_v_rowid := null;
                  igs_fi_1098t_dtls_pkg.insert_row(x_rowid            => l_v_rowid,
                                                   x_stu_1098t_id     => l_rec_1098t_data.stu_1098t_id,
                                                   x_transaction_id   => l_t_1098t_drilldown(l_n_rec_cntr).transaction_id,
                                                   x_transaction_code => l_t_1098t_drilldown(l_n_rec_cntr).transaction_code,
                                                   x_box_num          => l_t_1098t_drilldown(l_n_rec_cntr).box_num);
                END IF;
              END LOOP;
            END IF;
          END IF;
        END IF; -- Correction Flag
      END IF; -- Record has not been filed with IRS
    END IF; -- Record Exists

-- Log the details if there is a 1098T record created or updated
    IF l_b_txn THEN
      log_line(g_v_label_val_status,
               igs_fi_gen_gl.get_lkp_meaning('IGS_FI_1098T_STATUS_CODE',
                                              g_v_validation_status));
      log_line(g_v_label_err_desc,
               igs_fi_gen_gl.get_lkp_meaning('IGS_FI_1098T_ERR_CODE',
                                             l_v_error_code));
      log_line(g_v_label_correct_ret,
               igs_fi_gen_gl.get_lkp_meaning('YES_NO',
                                             NVL(l_v_correction_flag,l_rec_1098t_data.correction_flag)));
      fnd_file.new_line(fnd_file.log);
      log_line(g_v_label_boxval,null);
      log_line(g_v_label_box2,
               p_n_box2);
      log_line(g_v_label_box3,
               p_n_box3);
      log_line(g_v_label_box4,
               p_n_box4);
      log_line(g_v_label_box5,
               p_n_box5);
      log_line(g_v_label_box6,
               p_v_box6);
      log_line(g_v_label_box8,
               p_v_box8);
      log_line(g_v_label_box9,
               p_v_box9);

-- If the 1098T transaction has invalid address error code then
-- log the message to the log file
      IF l_v_error_code = 'INVALID_ADD' THEN
        fnd_file.put_line(fnd_file.log,fnd_message.get_string('IGS','IGS_FI_INV_NOT_FILE'));
      END IF;

-- If the name control is invalid, then log the message
      IF l_v_val_name_ctrl = 'N' THEN
        fnd_file.put_line(fnd_file.log, fnd_message.get_string('IGS','IGS_FI_INVALID_NAME_CTRL'));
      END IF;
    END IF;
  END insert_1098t_data;

  PROCEDURE extract_data_main(p_v_tax_year_name        igs_fi_1098t_setup.tax_year_name%TYPE,
                              p_n_person_id            igs_pe_person_base_v.person_id%TYPE,
                              p_v_override_excl        VARCHAR2,
                              p_v_file_addr_correction VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Main procedure for a person id

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
     abshriva    12-May-2006   Bug 5217319: Amount Precision change, added API call to allow correct precison into DB
    ***************************************************************** */

    CURSOR cur_pers_dtl(cp_n_person_id        igs_pe_person_base_v.person_id%TYPE) IS
      SELECT person_number,
             first_name,
             last_name
      FROM   igs_pe_person_base_v
      WHERE  person_id = cp_n_person_id;

    l_rec_pers_dtl      cur_pers_dtl%ROWTYPE;

    CURSOR cur_chk_rec_exists(cp_n_person_id     igs_pe_person_base_v.person_id%TYPE,
                              cp_v_tax_year_name igs_fi_1098t_setup.tax_year_name%TYPE,
                              cp_v_status        igs_fi_1098t_data.status_code%TYPE) IS
      SELECT dat.override_flag, dat.irs_filed_flag
      FROM   igs_fi_1098t_data dat
      WHERE  dat.party_id = cp_n_person_id
      AND    dat.tax_year_name = cp_v_tax_year_name
      AND    dat.status_code <> cp_v_status
      ORDER BY stu_1098t_id DESC;

    l_rec_1098t_data     cur_chk_rec_exists%ROWTYPE;

    CURSOR cur_non_res_alien(cp_n_person_id      igs_pe_person_base_v.person_id%TYPE,
                             cp_d_start_date     DATE,
                             cp_d_end_date       DATE) IS
      SELECT 'x'
      FROM   igs_pe_typ_instances_all ptyp,
             igs_pe_person_types ptm
      WHERE  ptyp.person_id = cp_n_person_id
      AND    ptyp.person_type_code = ptm.person_type_code
      AND    ptm.system_type IN ('EXCHG_VISITOR','NONIMG_STUDENT')
      AND    TRUNC(ptyp.start_date) <= TRUNC(cp_d_start_date)
      AND    ((TRUNC(ptyp.end_date) >= TRUNC(cp_d_end_date)) OR (ptyp.end_date IS NULL));

    l_b_new_run          BOOLEAN;
    l_n_box2             igs_fi_1098t_data.billed_amt%TYPE;
    l_n_box3             igs_fi_1098t_data.adj_amt%TYPE;
    l_n_box4             igs_fi_1098t_data.fin_aid_amt%TYPE;
    l_n_box5             igs_fi_1098t_data.fin_aid_adj_amt%TYPE;
    l_v_box6             igs_fi_1098t_data.next_acad_flag%TYPE;
    l_v_box8             igs_fi_1098t_data.half_time_flag%TYPE;
    l_v_box9             igs_fi_1098t_data.grad_flag%TYPE;
    l_var                VARCHAR2(1);
    l_n_orig_credit      NUMBER;
    l_n_adj_credit       NUMBER;
    l_n_orig_charge      NUMBER;
    l_n_adj_charge       NUMBER;
    l_v_next_acad_flag   igs_fi_1098t_data.next_acad_flag%TYPE;

    l_n_orig_billed_amt  NUMBER;
    l_n_adj_billed_amt   NUMBER;
    l_n_aid_orig_credit  NUMBER;
    l_n_aid_adj_credit   NUMBER;
    l_n_aid_orig_charge  NUMBER;
    l_n_aid_adj_charge   NUMBER;
    l_n_orig_spgrant_amt NUMBER;
    l_n_adj_spgrant_amt  NUMBER;
    l_v_full_name        igs_fi_1098t_data.party_name%TYPE;

  BEGIN
    l_b_new_run := FALSE;
    set_validation_status('PASSED');
    l_n_cntr := 0;
    l_t_1098t_drilldown.DELETE;
    l_n_box2 := 0;
    l_n_box3 := 0;
    l_n_box4 := 0;
    l_n_box5 := 0;
    l_v_box6 := null;
    l_v_box8 := null;
    l_v_box9 := null;
    g_b_non_zero_credits_flag := FALSE;
    g_b_chg_crd_found := FALSE;

-- Get the person details
    OPEN cur_pers_dtl(p_n_person_id);
    FETCH cur_pers_dtl INTO l_rec_pers_dtl;
    CLOSE cur_pers_dtl;

    l_v_full_name := l_rec_pers_dtl.last_name||' '||l_rec_pers_dtl.first_name;

    fnd_file.new_line(fnd_file.log);

    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
    log_line(g_v_label_person,
             l_rec_pers_dtl.person_number);
    log_line(g_v_label_stdnt_name,
             l_v_full_name);

-- Check if 1098T record exists with the values overridden
    OPEN cur_chk_rec_exists(p_n_person_id,
                            p_v_tax_year_name,
                            'DNT_RPT');
    FETCH cur_chk_rec_exists INTO l_rec_1098t_data;
    IF cur_chk_rec_exists%NOTFOUND THEN
      l_b_new_run := TRUE;
    END IF;
    CLOSE cur_chk_rec_exists;

    IF NOT l_b_new_run THEN
      IF l_rec_1098t_data.override_flag = 'Y' THEN
        fnd_message.set_module(g_v_package_name||'extract_data_main');
        fnd_message.set_name('IGS',
                             'IGS_FI_1098T_STU_OVERRIDDEN');
        fnd_message.set_token('TAX_YEAR_NAME',
                              p_v_tax_year_name);
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
        RETURN;
      END IF;
    END IF;

-- IF the override Exclusions parameter is passed as No
    IF p_v_override_excl = 'N' THEN

-- Check if the Exclude Non Resident Alien flag is checked at
-- 1098T setup
      IF g_rec_1098t_setup.excl_non_res_alien_flag = 'Y' THEN

-- Check if the person is Exchange visitor or Non Immigrant Student
        OPEN cur_non_res_alien(p_n_person_id,
                               g_rec_1098t_setup.start_date,
                               g_rec_1098t_setup.end_date);
        FETCH cur_non_res_alien INTO l_var;
        CLOSE cur_non_res_alien;

        IF l_var IS NOT NULL THEN
          fnd_message.set_module(g_v_package_name||'extract_data_main');
          fnd_message.set_name('IGS',
                               'IGS_FI_1098T_STU_EXCL_ALIEN');
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
          RETURN;
        END IF;
      END IF;
    END IF;

-- Update all charges and credits for the person and tax year
-- set the tax year to null
    update_charges(p_n_person_id             => p_n_person_id,
                   p_v_tax_year              => g_rec_1098t_setup.tax_year_code);

    update_credits(p_n_person_id        => p_n_person_id,
                   p_v_tax_year         => g_rec_1098t_setup.tax_year_code);


-- calculate box 2 and 3 amounts from the credits
    box236_credits(p_v_tax_year_name    => p_v_tax_year_name,
                   p_n_person_id        => p_n_person_id,
                   p_v_override_excl    => p_v_override_excl,
                   p_n_orig_credit      => l_n_orig_credit,
                   p_n_adj_credit       => l_n_adj_credit);

-- calculate box 2 and 3 amounts from the charges
    box236_charges(p_v_tax_year_name    => p_v_tax_year_name,
                   p_n_person_id        => p_n_person_id,
                   p_v_override_excl    => p_v_override_excl,
                   p_n_orig_charge      => l_n_orig_charge,
                   p_n_adj_charge       => l_n_adj_charge,
                   p_v_next_acad_flag   => l_v_next_acad_flag);

-- If the override exclusions parameter is set to No
    IF p_v_override_excl = 'N' THEN

-- Check if the Non Zero credits global variable has been set to FALSE
-- If yes, then log message and return
      IF g_b_chg_crd_found THEN
        IF NOT g_b_non_zero_credits_flag THEN
          fnd_message.set_module(g_v_package_name||'extract_data_main');
          fnd_message.set_name('IGS',
                               'IGS_FI_1098T_STU_EXCL_COURSE');
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
          RETURN;
        END IF;
      END IF;
    END IF;

-- Calculate Original and Adjustment Billed Amount
    l_n_orig_billed_amt := NVL(l_n_orig_charge,0) -
                           NVL(l_n_orig_credit,0);

    l_n_adj_billed_amt  := NVL(l_n_adj_charge,0) -
                           NVL(l_n_adj_credit,0);

-- If Adjustment Billed Amount > 0 then box 3 is 0
-- box 2 = orig billed + adj billed
    IF l_n_adj_billed_amt >= 0 THEN
      l_n_box2 := l_n_orig_billed_amt +
                  l_n_adj_billed_amt;
      l_n_box3 := 0;

-- update all records in the PLSQL table where box number is 3 to 2
      IF l_t_1098t_drilldown.COUNT > 0 THEN
        FOR l_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
          IF l_t_1098t_drilldown.EXISTS(l_rec_cntr) THEN
            IF l_t_1098t_drilldown(l_rec_cntr).box_num = 3 THEN
              l_t_1098t_drilldown(l_rec_cntr).box_num := 2;
            END IF;
          END IF;
        END LOOP;
      END IF;
    ELSE
-- Otherwise box2 = original billed amt
-- box3 = absolute value of Adjustment Billed Amount
      l_n_box2 := l_n_orig_billed_amt;
      l_n_box3 := ABS(l_n_adj_billed_amt);
    END IF;

-- Calculate Box 4 and 5 amounts from credits and charges
    box45_credits(p_v_tax_year_name        => p_v_tax_year_name,
                  p_n_person_id            => p_n_person_id,
                  p_n_orig_credit          => l_n_aid_orig_credit,
                  p_n_adj_credit           => l_n_aid_adj_credit);

    box45_charges(p_v_tax_year_name        => p_v_tax_year_name,
                  p_n_person_id            => p_n_person_id,
                  p_n_orig_charge          => l_n_aid_orig_charge,
                  p_n_adj_charge           => l_n_aid_adj_charge);

-- Calculate Original and Adjustment Sponsorship grant amount
    l_n_orig_spgrant_amt := NVL(l_n_aid_orig_credit,0) -
                            NVL(l_n_aid_orig_charge,0);

    l_n_adj_spgrant_amt := NVL(l_n_aid_adj_credit,0) -
                           NVL(l_n_aid_adj_charge,0);

-- If the adjustment amount > 0, then box 5 is 0
    IF l_n_adj_spgrant_amt >=0 THEN
      l_n_box4 := l_n_orig_spgrant_amt +
                  l_n_adj_spgrant_amt;
      l_n_box5 := 0;

      IF l_t_1098t_drilldown.COUNT > 0 THEN
        FOR l_rec_cntr IN l_t_1098t_drilldown.FIRST..l_t_1098t_drilldown.LAST LOOP
          IF l_t_1098t_drilldown.EXISTS(l_rec_cntr) THEN
            IF l_t_1098t_drilldown(l_rec_cntr).box_num = 5 THEN
              l_t_1098t_drilldown(l_rec_cntr).box_num := 4;
            END IF;
          END IF;
        END LOOP;
      END IF;
    ELSE
      l_n_box4 := l_n_orig_spgrant_amt;
      l_n_box5 := ABS(l_n_adj_spgrant_amt);
    END IF;

-- If all box2,3,4 and 5 are 0, then no record needs to be created
    IF l_n_box4 = 0 AND l_n_box5 = 0 AND l_n_box2 = 0 AND l_n_box3 = 0 THEN
      fnd_message.set_module(g_v_package_name||'extract_data_main');
      fnd_message.set_name('IGS',
                           'IGS_FI_1098T_BOX_ZERO');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      RETURN;
    END IF;

-- If the override Exclusions parameter is set to No and
-- Exclude Tuition Waiver flag is yes
    IF p_v_override_excl = 'N' THEN
      IF g_rec_1098t_setup.excl_tuit_waiv_flag = 'Y' THEN

-- Check if Box4 is greater than or equal to Box 2
        IF l_n_box4 >= l_n_box2 THEN

-- If there are no records existing in the 1098T table
-- then log the message and return
          IF l_b_new_run THEN
            fnd_message.set_module(g_v_package_name||'extract_data_main');
            fnd_message.set_name('IGS',
                                 'IGS_FI_1098T_STU_EXCL_WAIVE');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
            RETURN;
          ELSE
-- Else check for IRS filed flag. If it is set to N, then validation status
-- is Do Not Report
            IF l_rec_1098t_data.irs_filed_flag = 'N' THEN
              g_v_validation_status := 'DNT_RPT';
            END IF;
          END IF;
        END IF;
      END IF;
    END IF;

-- Derive box 6,8 and 9
    l_v_box6 := l_v_next_acad_flag;

    l_v_box8 := compute_box8(p_n_person_id          => p_n_person_id,
                             p_v_tax_year_name      => p_v_tax_year_name);

    l_v_box9 := compute_box9(p_n_person_id          => p_n_person_id,
                             p_v_tax_year_name      => p_v_tax_year_name);

    l_n_box2 := igs_fi_gen_gl.get_formatted_amount(l_n_box2);
    l_n_box3 := igs_fi_gen_gl.get_formatted_amount(l_n_box3);
    l_n_box4 := igs_fi_gen_gl.get_formatted_amount(l_n_box4);
    l_n_box5 := igs_fi_gen_gl.get_formatted_amount(l_n_box5);

-- Create 1098T Transactions
    insert_1098t_data(p_v_tax_year_name         => p_v_tax_year_name,
                      p_n_person_id             => p_n_person_id,
                      p_v_full_name             => l_v_full_name,
                      p_n_box2                  => l_n_box2,
                      p_n_box3                  => l_n_box3,
                      p_n_box4                  => l_n_box4,
                      p_n_box5                  => l_n_box5,
                      p_v_box6                  => l_v_box6,
                      p_v_box8                  => l_v_box8,
                      p_v_box9                  => l_v_box9,
                      p_v_file_addr_correction  => p_v_file_addr_correction);


  END extract_data_main;

  PROCEDURE extract(errbuf               OUT NOCOPY VARCHAR2,
                    retcode              OUT NOCOPY NUMBER,
                    p_v_tax_year_name        VARCHAR2,
                    p_n_person_id            NUMBER,
                    p_n_person_grp_id        NUMBER,
                    p_v_override_excl        VARCHAR2,
                    p_v_file_addr_correction VARCHAR2,
                    p_v_test_run             VARCHAR2) AS

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   06-May-2005
     Purpose         :   Main procedure called from Concurrent Manager

     Known limitations,enhancements,remarks:
     Change History
     Who     When         What
     ridas   14-Feb-2006  Bug #5021084. Added new parameter lv_group_type
                          in call to igf_ap_ss_pkg.get_pid
    ***************************************************************** */
    TYPE c_per_grp_cur   IS REF CURSOR;

    cur_per_grp   c_per_grp_cur;
    l_n_party_id        hz_parties.party_id%TYPE;
    l_v_stmnt           VARCHAR2(32767);
    l_v_status          VARCHAR2(2000);
    lv_group_type       igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
    SAVEPOINT SP_EXTRACT_1098T_DATA;
    retcode := 0;

-- Initialize the variables
    init;

-- Log parameters
    log_params(p_v_tax_year_name          => p_v_tax_year_name,
               p_n_person_id              => p_n_person_id,
               p_n_person_grp_id          => p_n_person_grp_id,
               p_v_override_excl          => p_v_override_excl,
               p_v_file_addr_correction   => p_v_file_addr_correction,
               p_v_test_run               => p_v_test_run);

-- Validate parameters
    IF NOT validate_params(p_v_tax_year_name        => p_v_tax_year_name,
                           p_n_person_id            => p_n_person_id,
                           p_n_person_grp_id        => p_n_person_grp_id,
                           p_v_override_excl        => p_v_override_excl,
                           p_v_file_addr_correction => p_v_file_addr_correction,
                           p_v_test_run             => p_v_test_run) THEN
      retcode := 2;
      RETURN;
    END IF;

-- If person Id is not null then call the extract_data_main for the person id passed
    IF p_n_person_id IS NOT NULL THEN
      BEGIN
        extract_data_main(p_v_tax_year_name        => p_v_tax_year_name,
                          p_n_person_id            => p_n_person_id,
                          p_v_override_excl        => p_v_override_excl,
                          p_v_file_addr_correction => p_v_file_addr_correction);
      EXCEPTION
        WHEN OTHERS THEN
                retcode := 2;
                ROLLBACK TO SAVEPOINT SP_EXTRACT_1098T_DATA;
          fnd_message.set_module(g_v_package_name||'extract_data');
          fnd_file.put_line(fnd_file.log,
                            sqlerrm);
      END;
    ELSE

      -- If the person id group is not null, then loop across all the persons in the person
      -- group and extract the 1098T data for them
      -- Bug #5021084
      l_v_stmnt := igf_ap_ss_pkg.get_pid(p_pid_grp    => p_n_person_grp_id,
                                         p_status     => l_v_status,
                                         p_group_type => lv_group_type);

      IF l_v_status <> 'S' THEN
        fnd_file.put_line(fnd_file.log, l_v_stmnt);
        retcode := 2;
        RETURN;
      END IF;

      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN cur_per_grp FOR l_v_stmnt USING p_n_person_grp_id;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN cur_per_grp FOR l_v_stmnt;
      END IF;

      LOOP
      FETCH cur_per_grp INTO l_n_party_id;
        EXIT WHEN cur_per_grp%NOTFOUND;
        BEGIN
          SAVEPOINT SP_EXTRACT_MAIN;
          extract_data_main(p_v_tax_year_name        => p_v_tax_year_name,
                            p_n_person_id            => l_n_party_id,
                            p_v_override_excl        => p_v_override_excl,
                            p_v_file_addr_correction => p_v_file_addr_correction);
        EXCEPTION
          WHEN OTHERS THEN
            retcode := 1;
            ROLLBACK TO SP_EXTRACT_MAIN;
            fnd_message.set_module(g_v_package_name||'extract_data');
            fnd_file.put_line(fnd_file.log,
                              sqlerrm);
        END;
      END LOOP;
      CLOSE cur_per_grp;
    END IF;

-- If the Test Run is Yes, then rollback the transactions else commit
    IF p_v_test_run = 'Y' THEN
      ROLLBACK TO SP_EXTRACT_1098T_DATA;
      fnd_message.set_name('IGS',
                           'IGS_FI_PRC_TEST_RUN');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    ELSE
      COMMIT;
    END IF;

  EXCEPTION
    WHEN e_resource_busy THEN
      ROLLBACK TO SP_EXTRACT_1098T_DATA;
      retcode := 2;
      fnd_message.set_module(g_v_package_name||'extract');
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.new_line(fnd_file.log);
    WHEN OTHERS THEN
      retcode := 2;
      ROLLBACK TO SP_EXTRACT_1098T_DATA;
      fnd_message.set_module(g_v_package_name||'extract');
      igs_ge_msg_stack.conc_exception_hndl;
      fnd_file.put_line(fnd_file.log, fnd_message.get || ' - ' || SQLERRM);
  END extract;
END igs_fi_1098t_extract_data;

/
