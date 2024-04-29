--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_LOCKBOX
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_LOCKBOX" AS
/* $Header: IGSFI85B.pls 120.3 2006/05/15 06:24:01 svuppala ship $ */

    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Package Body for the Lockbox Processes

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     svuppala    12-May-2006  Bug 5217319 Added call to format amounts by rounding off to currency precision
                             in the igs_fi_lb_ovfl_errs_pkg.insert_row and igs_fi_lb_rect_errs_pkg.insert_row calls
     pmarada    26-JUL-2005  Enh 3392095, modifed as per tution waiver build, passing p_api_version
                             parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
     svuppala   9-JUN-2005    Enh 3442712 - Impact of automatic generation of the Receipt Number.
                              changed logic for credit_number in invoke_credits_api_pvt().
     shtatiko   27-AUG-2003  Enh# 3045007, Modified valtype2_and_import_rects and initialize.
                             Added two new parameters p_n_credit_type_id, p_n_receipt_amt to invoke_credits_api_pvt
                             And added g_v_inst_payment, g_v_label_bal_amnt and g_v_label_dflt_cr_type.
     pathipat   21-Aug-2003  Enh 3076768 - Auto Release of Holds
                             Modified invoke_credits_api_pvt() and
                             valtype2_and_import_rects()
     agairola   07-Jul-03    Bug: 3032415 Modified validate_type1 procedure
    ***************************************************************** */

  g_v_ind_no                   CONSTANT  VARCHAR2(5) := 'N';
  g_v_line_sep                 CONSTANT  VARCHAR2(100) := '+'||RPAD('-',75,'-')||'+';
  g_v_label_lb_name            igs_lookup_values.meaning%TYPE;
  g_v_noval                    CONSTANT  VARCHAR2(10) := 'NOVALUE';
  g_n_retcode                  NUMBER(1) := 0;
  g_v_gl_date_source           igs_fi_lockboxes.gl_date_source_code%TYPE;
  g_v_user_supp_dt             CONSTANT VARCHAR2(30) := 'USER_SUPPLIED_DATE';
  g_v_deposit_date             CONSTANT VARCHAR2(30) := 'DEPOSIT_DATE';
  g_v_imp_date                 CONSTANT VARCHAR2(30) := 'IMPORT_DATE';
  g_v_currency_cd              igs_fi_control.currency_cd%TYPE;

  g_b_rec_exists               BOOLEAN;

  g_lb_int_tab                 lb_int_tab;
  g_t_rec_tab                  lb_receipt_tab;
  g_v_app                      CONSTANT VARCHAR2(5)  := 'APP';
  g_v_enr_deposit              CONSTANT VARCHAR2(15) := 'ENRDEPOSIT';
  g_v_oth_deposit              CONSTANT VARCHAR2(15) := 'OTHDEPOSIT';
  g_v_inst_payment             CONSTANT VARCHAR2(30) := 'INSTALLMENT_PAYMENTS';
  g_v_fee                      CONSTANT VARCHAR2(5) := 'FEE';
  g_v_adm                      CONSTANT VARCHAR2(5) := 'ADM';
  g_v_success                  CONSTANT VARCHAR2(10) := 'SUCCESS';
  g_v_error                    CONSTANT VARCHAR2(10) := 'ERROR';
  g_v_todo                     CONSTANT VARCHAR2(10) := 'TODO';
  g_v_receipt                  CONSTANT VARCHAR2(30) := 'RECEIPT';
  g_v_receipt_oflow            CONSTANT VARCHAR2(30) := 'RECEIPT_OFLOW';
  g_v_batch_header             CONSTANT VARCHAR2(30) := 'BATCH_HEADER';
  g_v_tran_header              CONSTANT VARCHAR2(30) := 'TRAN_HEADER';
  g_v_lock_header              CONSTANT VARCHAR2(30) := 'LOCK_HEADER';

  g_v_test_run_val             igs_lookup_values.meaning%TYPE;
  g_v_label_test_run           igs_lookup_values.meaning%TYPE;
  g_v_label_batch              igs_lookup_values.meaning%TYPE;
  g_v_label_item               igs_lookup_values.meaning%TYPE;
  g_v_label_status             igs_lookup_values.meaning%TYPE;
  g_v_label_success            igs_lookup_values.meaning%TYPE;
  g_v_label_err                igs_lookup_values.meaning%TYPE;
  g_v_label_party              igs_lookup_values.meaning%TYPE;
  g_v_label_rec_amnt           igs_lookup_values.meaning%TYPE;
  g_v_label_bal_amnt           igs_lookup_values.meaning%TYPE;
  g_v_label_cr_type            igs_lookup_values.meaning%TYPE;
  g_v_label_dflt_cr_type       igs_lookup_values.meaning%TYPE;
  g_v_label_fee_prd            igs_lookup_values.meaning%TYPE;
  g_v_label_gl_date            igs_lookup_values.meaning%TYPE;
  g_v_label_adm_appl_num       igs_lookup_values.meaning%TYPE;
  g_v_label_charge_code        igs_lookup_values.meaning%TYPE;
  g_v_label_bank_app_amt       igs_lookup_values.meaning%TYPE;
  g_v_label_act_app_amt        igs_lookup_values.meaning%TYPE;
  g_v_label_num_rec            igs_lookup_values.meaning%TYPE;
  g_v_label_cur_rec            igs_lookup_values.meaning%TYPE;
  g_v_label_type1              igs_lookup_values.meaning%TYPE;
  g_v_cr_desc                  igs_lookup_values.meaning%TYPE;
  g_b_log_head                 BOOLEAN := FALSE;
  g_v_label_type2              igs_lookup_values.meaning%TYPE;

  g_v_holds_message            fnd_new_messages.message_text%TYPE := NULL;

  PROCEDURE log_line(p_v_label       VARCHAR2,
                     p_v_value       VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for logging a single line

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN
    fnd_file.put_line(fnd_file.log,
                      p_v_label||' : '||p_v_value);
  END log_line;

  PROCEDURE initialize AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for initializing variables

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_lb_int_tab                 lb_int_tab;
    l_t_rec_tab                  lb_receipt_tab;
  BEGIN

-- Procedure for initializing the global variables and the
-- initializing of the PL/SQL tables
    g_lb_int_tab := l_lb_int_tab;
    g_t_rec_tab := l_t_rec_tab;
    g_b_log_head := FALSE;
    g_n_retcode := 0;
    g_v_cr_desc := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                 'LOCKBOX_PAYMENT');
    g_v_label_test_run := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'TEST_RUN');
    g_v_label_lb_name := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'LOCKBOX_NUMBER');
    g_v_label_batch := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                     'BATCH_NAME');
    g_v_label_item := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                    'ITEM_NUMBER');
    g_v_label_status := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                      'STATUS');
    g_v_label_success := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'SUCCESS');
    g_v_label_err := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                   'ERROR');
    g_v_label_party := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                     'PARTY');
    g_v_label_rec_amnt := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'REC_AMOUNT');
    g_v_label_bal_amnt := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                        'BALANCE_AMOUNT');
    g_v_label_cr_type := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'CREDIT_TYPE_NAME');
    g_v_label_dflt_cr_type := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'DFLT_CREDIT_TYPE_NAME');
    g_v_label_fee_prd := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'FEE_PERIOD');
    g_v_label_gl_date := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'GL_DATE');
    g_v_label_adm_appl_num := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                            'ADM_APPL_NUM');
    g_v_label_charge_code := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                           'CHARGE_NUMBER');
    g_v_label_bank_app_amt := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                            'BANK_APPL_AMT');
    g_v_label_act_app_amt := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                           'ACT_APPL_AMT');
    g_v_label_num_rec := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'REC_PROCESS');
    g_v_label_cur_rec := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                       'AMT_PROCESS');
    g_v_label_type1 := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                     'TYPE1_ERR');
    g_v_label_type2 := igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX',
                                                     'TYPE2_ERR');
    g_b_rec_exists := FALSE;
  END initialize;

  PROCEDURE log_type2_err(p_v_lockbox_name           VARCHAR2,
                          p_v_batch_name             VARCHAR2,
                          p_v_item_number            VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for logging type2 error headers

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  BEGIN

-- g_b_log_head is a global boolean variable used if the
-- Lockbox Name, BatchName, Item Number and status have to be logged
-- for type 2 validations
    IF NOT g_b_log_head THEN
      fnd_file.new_line(fnd_file.log);
      log_line(g_v_label_lb_name,
               p_v_lockbox_name);
      log_line(g_v_label_batch,
               p_v_batch_name);
      log_line(g_v_label_item,
               p_v_item_number);
      log_line(g_v_label_status,
               g_v_label_err);
      g_b_log_head := TRUE;
    END IF;
  END log_type2_err;

  FUNCTION validate_parameters(p_v_lockbox_name      VARCHAR2,
                               p_d_gl_date           DATE,
                               p_v_test_run          VARCHAR2) RETURN BOOLEAN AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for validating parameters

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_lockbox(cp_lockbox_name   VARCHAR2,
                       cp_ind_yn         VARCHAR2) IS
      SELECT gl_date_source_code
      FROM   igs_fi_lockboxes
      WHERE  lockbox_name = cp_lockbox_name
      AND    closed_flag = cp_ind_yn;

    l_b_val_parm         BOOLEAN;
    l_v_manage_acc       igs_fi_control.manage_accounts%TYPE;
    l_v_message_name     fnd_new_messages.message_name%TYPE;
    l_v_closing_status   VARCHAR2(10);
    l_v_curr_desc        fnd_currencies.description%TYPE;
    l_v_message_text     VARCHAR2(2000);
  BEGIN
    l_b_val_parm := TRUE;
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get_string('IGS',
                                             'IGS_FI_ANC_LOG_PARM'));
    fnd_file.new_line(fnd_file.log);

    g_v_test_run_val := igs_fi_gen_gl.get_lkp_meaning('YES_NO',
                                                      p_v_test_run);

-- Log the parameters
    log_line(g_v_label_lb_name,
             p_v_lockbox_name);
    log_line(g_v_label_gl_date,
             p_d_gl_date);
    log_line(g_v_label_test_run,
             NVL(g_v_test_run_val,p_v_test_run));

    fnd_file.new_line(fnd_file.log);
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);

-- Check for Manage Account
    igs_fi_com_rec_interface.chk_manage_account(p_v_manage_acc   => l_v_manage_acc,
                                                p_v_message_name => l_v_message_name);

-- If Manage Accounts is NULL or is OTHER then error has to be raised
    IF ((l_v_manage_acc IS NULL) OR (l_v_manage_acc =  'OTHER')) THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS',
                           l_v_message_name);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      RETURN l_b_val_parm;
    END IF;

    l_v_message_name := null;
    igs_fi_gen_gl.finp_get_cur(p_v_currency_cd    => g_v_currency_cd,
                               p_v_curr_desc      => l_v_curr_desc,
                               p_v_message_name   => l_v_message_text);
    IF l_v_message_text IS NOT NULL THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS',
                           l_v_message_name);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

-- Validate if the Lockbox Name is valid
    OPEN cur_lockbox(p_v_lockbox_name,
                     'N');
    FETCH cur_lockbox INTO g_v_gl_date_source;
    IF cur_lockbox%NOTFOUND THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_FI_CAPI_INVALID_LOCKBOX');
      fnd_message.set_token('LOCKBOX_NAME',
                            p_v_lockbox_name);
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;
    CLOSE cur_lockbox;

-- If the gl date source is user supplied and gl_date is not passed as input
-- then error needs to be raised.
    IF g_v_gl_date_source = g_v_user_supp_dt THEN
      IF p_d_gl_date IS NULL THEN
        l_b_val_parm := FALSE;
        fnd_message.set_name('IGS',
                             'IGS_FI_GL_DATE_REQD');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      ELSE

-- If the GL Date is passed then, check if the GL Date is in an open/future period
        igs_fi_gen_gl.get_period_status_for_date(p_d_date            => p_d_gl_date,
                                                 p_v_closing_status  => l_v_closing_status,
                                                 p_v_message_name    => l_v_message_name);
        IF l_v_message_name IS NOT NULL THEN
          l_b_val_parm := FALSE;
          fnd_message.set_name('IGS',
                               l_v_message_name);
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
        ELSE
          IF l_v_closing_status NOT IN ('O','F') THEN
            fnd_message.set_name('IGS',
                                 'IGS_FI_INVALID_GL_DATE');
            fnd_message.set_token('GL_DATE',
                                  p_d_gl_date);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
            l_b_val_parm := FALSE;
          END IF;
        END IF;
      END IF;
    ELSE

-- Log message to the user that the GL Date has been disregarded because the
-- gl date source for the lockbox is not user supplied
      IF p_d_gl_date IS NOT NULL THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_GL_DATE_DISRGD');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
    END IF;

-- validate for Test Run
    IF p_v_test_run NOT IN ('Y','N') THEN
      l_b_val_parm := FALSE;
      fnd_message.set_name('IGS',
                           'IGS_GE_INVALID_VALUE');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
    END IF;

    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
    RETURN l_b_val_parm;
  END validate_parameters;

  FUNCTION get_credit_type_name(p_n_credit_type_id      igs_fi_cr_types.credit_type_id%TYPE) RETURN VARCHAR2 AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Function for getting the credit type name

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_crt(cp_credit_type_id        igs_fi_cr_types.credit_type_id%TYPE) IS
      SELECT credit_type_name
      FROM igs_fi_cr_types
      WHERE credit_type_id = cp_credit_type_id;

    l_v_cr_type_name     igs_fi_cr_types.credit_type_name%TYPE;
  BEGIN
    OPEN cur_crt(p_n_credit_type_id);
    FETCH cur_crt INTO l_v_cr_type_name;
    CLOSE cur_crt;

    RETURN l_v_cr_type_name;
  END get_credit_type_name;

  FUNCTION get_fee_period(p_v_cal_type      igs_ca_inst.cal_type%TYPE,
                          p_n_cal_seq       igs_ca_inst.sequence_number%TYPE) RETURN VARCHAR2 AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Function for getting the fee period

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_fee_prd(cp_cal_type          igs_ca_inst.cal_type%TYPE,
                       cp_cal_seq           igs_ca_inst.sequence_number%TYPE) IS
      SELECT description
      FROM igs_ca_inst
      WHERE cal_type = cp_cal_type
      AND   sequence_number = cp_cal_seq;

    l_v_desc      igs_ca_inst.description%TYPE;
  BEGIN
    IF p_v_cal_type IS NULL OR p_n_cal_seq IS NULL THEN
      l_v_desc := NULL;
    ELSE
      OPEN cur_fee_prd(p_v_cal_type,
                       p_n_cal_seq);
      FETCH cur_fee_prd INTO l_v_desc;
      CLOSE cur_fee_prd;
    END IF;

    RETURN l_v_desc;
  END get_fee_period;

  FUNCTION get_record_type_meaning(p_v_lockbox_name          igs_fi_lockboxes.lockbox_name%TYPE,
                                   p_v_record_identifier_cd  igs_fi_lockbox_ints.record_identifier_cd%TYPE) RETURN VARCHAR2 AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Function for getting the record type meaning

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_rc_type(cp_lockbox_name       igs_fi_lockboxes.lockbox_name%TYPE,
                       cp_rec_identifier_cd  igs_fi_lockbox_ints.record_identifier_cd%TYPE) IS
      SELECT record_type_code
      FROM   igs_fi_lb_rec_types
      WHERE  lockbox_name = cp_lockbox_name
      AND    record_identifier_cd = cp_rec_identifier_cd;

    l_v_rc_type   igs_fi_lb_rec_types.record_type_code%TYPE;
  BEGIN
    l_v_rc_type := NULL;
    OPEN cur_rc_type(p_v_lockbox_name,
                     p_v_record_identifier_cd);
    FETCH cur_rc_type INTO l_v_rc_type;
    CLOSE cur_rc_type;

    RETURN NVL(l_v_rc_type, g_v_noval);
  END get_record_type_meaning;

  FUNCTION populate_lb_interface(p_v_lockbox_name      igs_fi_lockboxes.lockbox_name%TYPE) RETURN BOOLEAN AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Function for populating the global PL/SQL interface table

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */

-- Cursor for getting the TODO records for the Lockbox Name passed as input
-- from the Interface table
    CURSOR cur_lb_ints(cp_lockbox_name      VARCHAR2,
                       cp_status            VARCHAR2) IS
      SELECT rowid row_id, lb.*
      FROM   igs_fi_lockbox_ints lb
      WHERE  lockbox_name = cp_lockbox_name
      AND    record_status = cp_status
      FOR UPDATE NOWAIT
      ORDER BY lockbox_interface_id;

-- Cursor for getting the TODO records for the Batch Name passed as input
-- from the Interface table where lockbox name is null
    CURSOR cur_lb_batch(cp_batch_name      igs_fi_lockbox_ints.batch_name%TYPE,
                        cp_status          VARCHAR2) IS
      SELECT rowid  row_id,
             lb.*
      FROM   igs_fi_lockbox_ints lb
      WHERE  batch_name = cp_batch_name
      AND    record_status = cp_status
      AND    lockbox_name IS NULL
      FOR UPDATE NOWAIT
      ORDER BY lockbox_interface_id;

    l_b_upd_err              BOOLEAN;
    l_n_cntr                 NUMBER(38);
    l_n_cntr1                NUMBER(38);
    l_b_batch_head_exists    BOOLEAN;
    l_v_rec_type_meaning     igs_fi_lb_rec_types.record_type_code%TYPE;
  BEGIN
    l_b_upd_err := FALSE;
    l_b_batch_head_exists := FALSE;

    l_n_cntr := 0;
    l_n_cntr1 := 0;

-- Loop across the TODO records in the Interface table for the lockbox name
    FOR l_rec_lb_ints IN cur_lb_ints(p_v_lockbox_name,g_v_todo) LOOP

-- For each record selected, add the record to the PL/SQL table
      g_b_rec_exists := TRUE;

      l_n_cntr1 := l_n_cntr1+1;

      IF  l_n_cntr1 = 1 THEN
        fnd_file.put_line(fnd_file.log,
                          g_v_line_sep);
        fnd_file.put_line(fnd_file.log,
                          g_v_label_type1);
        fnd_file.put_line(fnd_file.log,
                          g_v_line_sep);
        fnd_file.new_line(fnd_file.log);
      END IF;

      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).row_id := l_rec_lb_ints.row_id;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_interface_id  := l_rec_lb_ints.lockbox_interface_id;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).record_identifier_cd := l_rec_lb_ints.record_identifier_cd;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).record_status := l_rec_lb_ints.record_status;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).deposit_date := l_rec_lb_ints.deposit_date;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).transmission_record_count := l_rec_lb_ints.transmission_record_count;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).transmission_amt := l_rec_lb_ints.transmission_amt;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_name := l_rec_lb_ints.lockbox_name;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_batch_count := l_rec_lb_ints.lockbox_batch_count;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_record_count := l_rec_lb_ints.lockbox_record_count;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_amt := l_rec_lb_ints.lockbox_amt;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_name := l_rec_lb_ints.batch_name;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_record_count := l_rec_lb_ints.batch_record_count;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_amt := l_rec_lb_ints.batch_amt;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).item_number := l_rec_lb_ints.item_number;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).receipt_amt := l_rec_lb_ints.receipt_amt;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).check_cd := l_rec_lb_ints.check_cd;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).party_number := l_rec_lb_ints.party_number;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).payer_name := l_rec_lb_ints.payer_name;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd1 := l_rec_lb_ints.charge_cd1;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd2 := l_rec_lb_ints.charge_cd2;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd3 := l_rec_lb_ints.charge_cd3;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd4 := l_rec_lb_ints.charge_cd4;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd5 := l_rec_lb_ints.charge_cd5;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd6 := l_rec_lb_ints.charge_cd6;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd7 := l_rec_lb_ints.charge_cd7;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd8 := l_rec_lb_ints.charge_cd8;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt1 := l_rec_lb_ints.applied_amt1;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt2 := l_rec_lb_ints.applied_amt2;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt3 := l_rec_lb_ints.applied_amt3;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt4 := l_rec_lb_ints.applied_amt4;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt5 := l_rec_lb_ints.applied_amt5;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt6 := l_rec_lb_ints.applied_amt6;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt7 := l_rec_lb_ints.applied_amt7;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt8 := l_rec_lb_ints.applied_amt8;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).credit_type_cd := l_rec_lb_ints.credit_type_cd;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).fee_cal_instance_cd := l_rec_lb_ints.fee_cal_instance_cd;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).adm_application_id := l_rec_lb_ints.adm_application_id;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute_category := l_rec_lb_ints.attribute_category;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute1 := l_rec_lb_ints.attribute1;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute2 := l_rec_lb_ints.attribute2;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute3 := l_rec_lb_ints.attribute3;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute4 := l_rec_lb_ints.attribute4;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute5 := l_rec_lb_ints.attribute5;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute6 := l_rec_lb_ints.attribute6;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute7 := l_rec_lb_ints.attribute7;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute8 := l_rec_lb_ints.attribute8;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute9 := l_rec_lb_ints.attribute9;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute10 := l_rec_lb_ints.attribute10;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute11 := l_rec_lb_ints.attribute11;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute12 := l_rec_lb_ints.attribute12;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute13 := l_rec_lb_ints.attribute13;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute14 := l_rec_lb_ints.attribute14;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute15 := l_rec_lb_ints.attribute15;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute16 := l_rec_lb_ints.attribute16;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute17 := l_rec_lb_ints.attribute17;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute18 := l_rec_lb_ints.attribute18;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute19 := l_rec_lb_ints.attribute19;
      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute20 := l_rec_lb_ints.attribute20;

-- Get the Record Type Meaning for the Lockbox Name and the Record Identifier of the
-- Interface table record.
      l_v_rec_type_meaning := NULL;
      l_v_rec_type_meaning := get_record_type_meaning(p_v_lockbox_name,
                                                      l_rec_lb_ints.record_identifier_cd);

      g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).system_record_identifier := l_v_rec_type_meaning;

-- If the record type meaning is NOVALUE, then there is an error and the set of Interface records should be marked as
-- Error
      IF l_v_rec_type_meaning = g_v_noval THEN
        fnd_message.set_name('IGS','IGS_FI_INVALID_RECORD_ID');
        fnd_message.set_token('RECORD_IDENTIFIER',
                              l_rec_lb_ints.record_identifier_cd);
        fnd_message.set_token('LOCKBOX_NAME',
                              p_v_lockbox_name);
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
        l_b_upd_err := TRUE;
      END IF;

-- Check if Batch Headers exist. Will be used in the next step. This has been kept to improve the
-- performance in case there are no batch headers
      IF l_v_rec_type_meaning = g_v_batch_header THEN
        l_b_batch_head_exists := TRUE;
      END IF;
    END LOOP;

-- If the batch headers exist in the first selection of interface records, then
    IF l_b_batch_head_exists THEN
      l_n_cntr := null;

-- For the batch name in the batch header, loop across the table to select the receipt and receipt overflow
-- records that have the same batch name and null lockbox name
      FOR l_n_cntr IN g_lb_int_tab.FIRST..g_lb_int_tab.LAST LOOP
        IF g_lb_int_tab.EXISTS(l_n_cntr) THEN
          IF ((g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_batch_header) AND
               g_lb_int_tab(l_n_cntr).batch_name IS NOT NULL) THEN
            FOR l_rec_lb_ints IN cur_lb_batch(g_lb_int_tab(l_n_cntr).batch_name,g_v_todo) LOOP
              IF NOT g_lb_int_tab.EXISTS(l_rec_lb_ints.lockbox_interface_id) THEN
                l_v_rec_type_meaning := NULL;
                l_v_rec_type_meaning := get_record_type_meaning(p_v_lockbox_name,
                                                                l_rec_lb_ints.record_identifier_cd);

-- If the record type meaning is NOVALUE, then there is an error and the set of Interface records should be marked as
-- Error
                IF l_v_rec_type_meaning = g_v_noval THEN
                  fnd_message.set_name('IGS','IGS_FI_INVALID_RECORD_ID');
                  fnd_message.set_token('RECORD_IDENTIFIER',
                                        l_rec_lb_ints.record_identifier_cd);
                  fnd_message.set_token('LOCKBOX_NAME',
                                         p_v_lockbox_name);
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get);
                  l_b_upd_err := TRUE;
                END IF;

 -- If the record type meaning is either Receipt/Receipt Overflow/Novalue, then add the record to the
 -- Interface table
                IF l_v_rec_type_meaning IN (g_v_receipt,
                                            g_v_receipt_oflow,
                                            g_v_noval) THEN
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).row_id := l_rec_lb_ints.row_id;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_interface_id  := l_rec_lb_ints.lockbox_interface_id;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).record_identifier_cd := l_rec_lb_ints.record_identifier_cd;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).record_status := l_rec_lb_ints.record_status;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).deposit_date := l_rec_lb_ints.deposit_date;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).transmission_record_count := l_rec_lb_ints.transmission_record_count;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).transmission_amt := l_rec_lb_ints.transmission_amt;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_name := p_v_lockbox_name;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_batch_count := l_rec_lb_ints.lockbox_batch_count;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_record_count := l_rec_lb_ints.lockbox_record_count;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).lockbox_amt := l_rec_lb_ints.lockbox_amt;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_name := l_rec_lb_ints.batch_name;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_amt := l_rec_lb_ints.batch_amt;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).batch_record_count := l_rec_lb_ints.batch_record_count;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).item_number := l_rec_lb_ints.item_number;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).receipt_amt := l_rec_lb_ints.receipt_amt;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).check_cd := l_rec_lb_ints.check_cd;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).party_number := l_rec_lb_ints.party_number;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).payer_name := l_rec_lb_ints.payer_name;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd1 := l_rec_lb_ints.charge_cd1;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd2 := l_rec_lb_ints.charge_cd2;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd3 := l_rec_lb_ints.charge_cd3;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd4 := l_rec_lb_ints.charge_cd4;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd5 := l_rec_lb_ints.charge_cd5;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd6 := l_rec_lb_ints.charge_cd6;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd7 := l_rec_lb_ints.charge_cd7;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).charge_cd8 := l_rec_lb_ints.charge_cd8;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt1 := l_rec_lb_ints.applied_amt1;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt2 := l_rec_lb_ints.applied_amt2;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt3 := l_rec_lb_ints.applied_amt3;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt4 := l_rec_lb_ints.applied_amt4;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt5 := l_rec_lb_ints.applied_amt5;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt6 := l_rec_lb_ints.applied_amt6;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt7 := l_rec_lb_ints.applied_amt7;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).applied_amt8 := l_rec_lb_ints.applied_amt8;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).credit_type_cd := l_rec_lb_ints.credit_type_cd;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).fee_cal_instance_cd := l_rec_lb_ints.fee_cal_instance_cd;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).adm_application_id := l_rec_lb_ints.adm_application_id;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute_category := l_rec_lb_ints.attribute_category;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute1 := l_rec_lb_ints.attribute1;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute2 := l_rec_lb_ints.attribute2;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute3 := l_rec_lb_ints.attribute3;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute4 := l_rec_lb_ints.attribute4;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute5 := l_rec_lb_ints.attribute5;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute6 := l_rec_lb_ints.attribute6;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute7 := l_rec_lb_ints.attribute7;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute8 := l_rec_lb_ints.attribute8;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute9 := l_rec_lb_ints.attribute9;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute10 := l_rec_lb_ints.attribute10;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute11 := l_rec_lb_ints.attribute11;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute12 := l_rec_lb_ints.attribute12;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute13 := l_rec_lb_ints.attribute13;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute14 := l_rec_lb_ints.attribute14;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute15 := l_rec_lb_ints.attribute15;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute16 := l_rec_lb_ints.attribute16;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute17 := l_rec_lb_ints.attribute17;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute18 := l_rec_lb_ints.attribute18;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute19 := l_rec_lb_ints.attribute19;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).attribute20 := l_rec_lb_ints.attribute20;
                  g_lb_int_tab(l_rec_lb_ints.lockbox_interface_id).system_record_identifier := l_v_rec_type_meaning;
                END IF;
              END IF;
            END LOOP;
          END IF;
        END IF;
      END LOOP;
    END IF;

    RETURN l_b_upd_err;
  END populate_lb_interface;

  FUNCTION validate_type1 RETURN VARCHAR2 AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Function for type 1 validations

     Known limitations,enhancements,remarks:
     Change History
     Who        When       What
     agairola   07-Jul-03  Bug: 3032415 Added the check for the negative amount
                           for the receipt and receipt overflow records
     agairola   01-Jul-03  Bug: 3030453 Added the check for the batch name
                           also when the Amount is being summed up
    ***************************************************************** */
    l_t_th_tab      lb_int_tab;
    l_n_th_cntr     NUMBER(38) := 0;

    l_t_lh_tab      lb_int_tab;
    l_n_lh_cntr     NUMBER(38) := 0;

    l_t_bh_tab      lb_int_tab;
    l_n_bh_cntr     NUMBER(38) := 0;

    l_t_rc_tab      lb_int_tab;
    l_n_rc_cntr     NUMBER(38) := 0;

    l_t_ro_tab      lb_int_tab;
    l_n_ro_cntr     NUMBER(38) := 0;

    l_n_cntr        NUMBER(38) := 0;
    l_n_cntr1       NUMBER(38) := 0;
    l_v_val_status  VARCHAR2(1);

    TYPE t_distinct_batch IS TABLE OF igs_fi_lockbox_ints.batch_name%TYPE
      INDEX BY BINARY_INTEGER;

    l_t_distinct_batch        t_distinct_batch;
    l_n_receipt_amount        igs_fi_credits.amount%TYPE;
    l_b_distinct_batch_found  BOOLEAN := FALSE;
    l_n_batch_count           NUMBER(38);
    l_n_batch_amount          igs_fi_credits.amount%TYPE;
    l_b_rec_batch             BOOLEAN;
    l_b_batch_unq             BOOLEAN;
    l_b_chg_amt_match         BOOLEAN;
    l_n_amt_appl              igs_fi_lockbox_ints.applied_amt1%TYPE;
    l_b_rc_ro_match           BOOLEAN;
    l_b_ro_chg_appl           BOOLEAN;
    l_n_distinct_batch_count  NUMBER(38);
    l_b_dup_batches           BOOLEAN;

    l_b_ro_identified         BOOLEAN;
  BEGIN

-- Here, in this procedure, the main interface PL/SQL table is broken down into
-- different PL/SQL tables in order to segregate the different types of records
-- This has been done to improve the performance of the process.
    l_t_th_tab.DELETE;
    l_t_bh_tab.DELETE;
    l_t_lh_tab.DELETE;
    l_t_rc_tab.DELETE;
    l_t_ro_tab.DELETE;
    l_t_distinct_batch.DELETE;

    l_v_val_status := 'S';

-- If there are any records in the PL/SQL table, then loop across the records
-- and for each type of record, add it to the corresponding PL/SQL table
    IF g_lb_int_tab.COUNT > 0 THEN
      l_n_cntr := 0;
      FOR l_n_cntr IN g_lb_int_tab.FIRST..g_lb_int_tab.LAST LOOP
        IF g_lb_int_tab.EXISTS(l_n_cntr) THEN
          IF g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_tran_header THEN
            l_n_th_cntr := l_n_th_cntr + 1;
            l_t_th_tab(l_n_th_cntr) := g_lb_int_tab(l_n_cntr);
          ELSIF g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_lock_header THEN
            l_n_lh_cntr := l_n_lh_cntr + 1;
            l_t_lh_tab(l_n_lh_cntr) := g_lb_int_tab(l_n_cntr);
          ELSIF g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_batch_header THEN
            l_n_bh_cntr := l_n_bh_cntr + 1;
            l_t_bh_tab(l_n_bh_cntr) := g_lb_int_tab(l_n_cntr);
          ELSIF g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_receipt THEN
            l_n_rc_cntr := l_n_rc_cntr + 1;
            l_t_rc_tab(l_n_rc_cntr) := g_lb_int_tab(l_n_cntr);

-- Sum up the Receipt Amount
            l_n_receipt_amount := NVL(l_n_receipt_amount,0) +
                                  NVL(g_lb_int_tab(l_n_cntr).receipt_amt,0);
          ELSIF g_lb_int_tab(l_n_cntr).system_record_identifier = g_v_receipt_oflow THEN
            l_n_ro_cntr := l_n_ro_cntr + 1;
            l_t_ro_tab(l_n_ro_cntr) := g_lb_int_tab(l_n_cntr);
          END IF;
        END IF;
      END LOOP;
    END IF;

-- If there are records in the Transaction Header PL/SQL table
    IF l_t_th_tab.COUNT > 0 THEN
      l_n_cntr := 0;

-- Loop across the Transaction Header PL/SQL table
      FOR l_n_cntr IN l_t_th_tab.FIRST..l_t_th_tab.LAST LOOP
        IF l_t_th_tab.EXISTS(l_n_cntr) THEN

-- If the transmission record count is not null and the
-- transmission record count  is not equal to the number of receipts then
-- Log the error in the log file. This is a type 1 validation error.
          IF ((l_t_th_tab(l_n_cntr).transmission_record_count IS NOT NULL) AND
              (l_t_th_tab(l_n_cntr).transmission_record_count <> l_n_rc_cntr)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_TH_COUNT_MISMATCH');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If the Transmission Amount is not null and the transmission amount is not equal to the
-- receipt amount, then this error message is logged in the log file.
          IF ((l_t_th_tab(l_n_cntr).transmission_amt IS NOT NULL) AND
              (l_t_th_tab(l_n_cntr).transmission_amt <> l_n_receipt_amount)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_TH_AMOUNT_MISMATCH');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
        END IF;
      END LOOP;
    END IF;

    l_n_cntr := 0;

-- If there are records in the Lockbox Header
    IF l_t_lh_tab.COUNT > 0 THEN
      l_n_cntr := 0;

-- Loop across the Lockbox Header record PL/SQL table
      FOR l_n_cntr IN l_t_lh_tab.FIRST..l_t_lh_tab.LAST LOOP
        IF l_t_lh_tab.EXISTS(l_n_cntr) THEN

-- If the lockbox batch count is not null
          IF l_t_lh_tab(l_n_cntr).lockbox_batch_count IS NOT NULL THEN

-- If there are batch headers, then check if the batch header count is
-- equal to the lockbox batch count.
            IF l_n_bh_cntr > 0 THEN
              IF l_t_lh_tab(l_n_cntr).lockbox_batch_count <> l_n_bh_cntr THEN
                l_v_val_status := 'E';
                fnd_message.set_name('IGS',
                                     'IGS_FI_LH_COUNT_MISMATCH');
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
            ELSE

-- If there are no batch headers, then if there are any records in the receipts
              IF l_t_rc_tab.COUNT > 0 THEN
                l_n_cntr1 := 0;

-- Loop across all the receipts records and count the distinct batches
                FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
                  IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN

-- Logic for counting the distinct batches by using a PL/SQL table
                    IF (l_t_rc_tab(l_n_cntr1).batch_name IS NOT NULL) THEN
                      IF l_t_distinct_batch.COUNT = 0 THEN
                        l_t_distinct_batch(1) := l_t_rc_tab(l_n_cntr1).batch_name;
                      ELSE
                        FOR l_n_cntr2 IN l_t_distinct_batch.FIRST..l_t_distinct_batch.LAST LOOP
                          IF l_t_distinct_batch.EXISTS(l_n_cntr2) THEN
                            IF l_t_distinct_batch(l_n_cntr2) = l_t_rc_tab(l_n_cntr1).batch_name THEN
                              l_b_distinct_batch_found := TRUE;
                            ELSE
                              l_b_distinct_batch_found := FALSE;
                            END IF;
                          END IF;
                        END LOOP;

                        IF NOT l_b_distinct_batch_found THEN
                          l_n_distinct_batch_count := l_t_distinct_batch.COUNT;
                          l_t_distinct_batch(l_n_distinct_batch_count+1) := l_t_rc_tab(l_n_cntr1).batch_name;
                        END IF;
                      END IF;
                    ELSE

-- If the receipt record does not have a batch, then log the error message.
                      l_v_val_status := 'E';
                      fnd_message.set_name('IGS',
                                           'IGS_FI_LH_BATCH_MISSING');
                      fnd_file.put_line(fnd_file.log,
                                        fnd_message.get);
                    END IF;
                  END IF;
                END LOOP;
              ELSE
                l_v_val_status := 'E';
                fnd_message.set_name('IGS',
                                     'IGS_FI_LH_COUNT_MISMATCH');
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;

-- If the distinct batch count PL/SQL table has some records and the count does not match the Lockbox Batch Count,
-- then it is an error condition
              IF ((l_t_distinct_batch.COUNT <> l_t_lh_tab(l_n_cntr).lockbox_batch_count) AND
                  (l_t_distinct_batch.COUNT > 0)) THEN
                l_v_val_status := 'E';
                fnd_message.set_name('IGS',
                                     'IGS_FI_LH_COUNT_MISMATCH');
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
              l_t_distinct_batch.DELETE;
            END IF;
          END IF;

-- If the Lockbox Amount is not null and is not equal to the receipt amount, then
-- log this as error message
          IF ((l_t_lh_tab(l_n_cntr).lockbox_amt IS NOT NULL) AND
              (l_t_lh_tab(l_n_cntr).lockbox_amt <> l_n_receipt_amount)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_LH_AMOUNT_MISMATCH');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If the Lockbox Record Count is not equal to the receipt count, then log this as
-- error in the log file
          IF ((l_t_lh_tab(l_n_cntr).lockbox_record_count IS NOT NULL) AND
              (l_t_lh_tab(l_n_cntr).lockbox_record_count <> l_n_rc_cntr)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_LH_RECCOUNT_MISMATCH');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
        END IF;
      END LOOP;
    END IF;

    l_b_dup_batches := FALSE;

-- If there are any batch header records then
    IF l_n_bh_cntr > 0 THEN

-- Loop across the Batch Header table
      FOR l_n_cntr IN l_t_bh_tab.FIRST..l_t_bh_tab.LAST LOOP

-- If the batch name is not null, then
        IF l_t_bh_tab(l_n_cntr).batch_name IS NOT NULL THEN

-- Loop across the Batch Header table again to identify if there are any duplicate batches
-- If the duplicate batches exist then this is an error and log it in the log file.
          FOR l_n_cntr1 IN l_t_bh_tab.FIRST..l_t_bh_tab.LAST LOOP
            IF ((l_t_bh_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                (l_t_bh_tab(l_n_cntr1).batch_name = l_t_bh_tab(l_n_cntr).batch_name) AND
                (l_t_bh_tab(l_n_cntr1).lockbox_interface_id <> l_t_bh_tab(l_n_cntr).lockbox_interface_id)) THEN
              l_v_val_status := 'E';
              fnd_message.set_name('IGS',
                                   'IGS_FI_DUP_BATCHES');
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
              l_b_dup_batches := TRUE;
              EXIT;
            END IF;
          END LOOP;

          IF l_b_dup_batches THEN
            EXIT;
          END IF;
        END IF;
      END LOOP;

-- Loop across the Batch Header table records
      FOR l_n_cntr IN l_t_bh_tab.FIRST..l_t_bh_tab.LAST LOOP
        l_n_batch_count := 0;
        l_n_batch_amount := 0;

-- If the batch name is not null then
        IF l_t_bh_tab(l_n_cntr).batch_name IS NOT NULL THEN

-- If either the batch record count is not null or the batch amount is not
-- null, then loop across the receipt record for the same batch name and count
-- the receipt record count for the batch and sum up the receipt amount for the batch
          IF ((l_t_bh_tab(l_n_cntr).batch_record_count IS NOT NULL) OR
              (l_t_bh_tab(l_n_cntr).batch_amt IS NOT NULL)) THEN
            FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
              IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                IF ((l_t_rc_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                    (l_t_rc_tab(l_n_cntr1).batch_name = l_t_bh_tab(l_n_cntr).batch_name)) THEN
                   l_n_batch_count := NVL(l_n_batch_count,0) + 1;
                   l_n_batch_amount := NVL(l_n_batch_amount,0) +
                                       NVL(l_t_rc_tab(l_n_cntr1).receipt_amt,0);
                END IF;
              END IF;
            END LOOP;

-- If the batch count does not match the receipt count, then this is an error condition
            IF l_n_batch_count > 0 THEN
              IF ((l_n_batch_count <> l_t_bh_tab(l_n_cntr).batch_record_count) AND
                  (l_t_bh_tab(l_n_cntr).batch_record_count IS NOT NULL)) THEN
                l_v_val_status := 'E';
                fnd_message.set_name('IGS',
                                     'IGS_FI_BH_COUNT_MISMATCH');
                fnd_message.set_token('BATCH_NAME',
                                       l_t_bh_tab(l_n_cntr).batch_name);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
            ELSE

-- If there are no records in the receipts PL/SQL table for the batch name
-- then this is an error condition and log this in the log file
              l_v_val_status := 'E';
              fnd_message.set_name('IGS',
                                   'IGS_FI_NO_REC_IN_BATCH');
              fnd_message.set_token('BATCH_NAME',
                                     l_t_bh_tab(l_n_cntr).batch_name);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;

-- If the batch amount is not equal to the batch amount of the batch header record then
-- log this in the log file
            IF ((l_n_batch_amount <> l_t_bh_tab(l_n_cntr).batch_amt) AND
                (l_t_bh_tab(l_n_cntr).batch_amt IS NOT NULL)) THEN
              l_v_val_status := 'E';
              fnd_message.set_name('IGS',
                                   'IGS_FI_BH_AMOUNT_MISMATCH');
              fnd_message.set_token('BATCH_NAME',
                                     l_t_bh_tab(l_n_cntr).batch_name);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;

            l_n_batch_count := 0;
            l_n_batch_amount := 0;
          END IF;
        END IF;
      END LOOP;
    END IF;

-- If there are any receipt records, then
    IF l_n_rc_cntr > 0 THEN

-- Loop across the receipt PL/SQL table
      FOR l_n_cntr IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
        l_b_rec_batch := FALSE;
        IF l_t_rc_tab.EXISTS(l_n_cntr) THEN

-- If there is a batch name mentioned for the receipt record and there are any
-- batch header records
          IF l_t_rc_tab(l_n_cntr).batch_name IS NOT NULL AND l_n_bh_cntr > 0 THEN

-- Loop across the batch header records to identify if the batch name mentioned in the
-- receipts record matches the batch name in any batch header record. If it matches, then
-- exit.
            FOR l_n_cntr1 IN l_t_bh_tab.FIRST..l_t_bh_tab.LAST LOOP
              IF l_t_bh_tab.EXISTS(l_n_cntr1) THEN
                IF ((l_t_bh_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                    (l_t_bh_tab(l_n_cntr1).batch_name = l_t_rc_tab(l_n_cntr).batch_name)) THEN
                  l_b_rec_batch := TRUE;
                  EXIT;
                END IF;
              END IF;
            END LOOP;

-- If the batch header record match does not happen then log the message in the log file.
            IF NOT l_b_rec_batch THEN
              l_v_val_status := 'E';
              fnd_message.set_name('IGS',
                                   'IGS_FI_NO_REC_BATCH_LINK');
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;
          END IF;

-- If the item number of the receipt record is null, then this has to be logged in the log file
-- as error
          IF l_t_rc_tab(l_n_cntr).item_number IS NULL THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_REC_ITEMS_MISSING');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If the receipt amount is less than 0 or the receipt amount is null, then log this in the log file
          IF ((l_t_rc_tab(l_n_cntr).receipt_amt <0) OR (l_t_rc_tab(l_n_cntr).receipt_amt IS NULL)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_REC_AMT_NOT_VALID');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If the party number in the receipt record is null, then log this as an error in the log file
          IF l_t_rc_tab(l_n_cntr).party_number IS NULL THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_REC_PARTY_MISSING');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- The following logic determines if the item number as mentioned in the receipt record is unique across
-- the receipts records at the batch level(if batch name is provided) or at the lockbox level.
-- If the records are not unique, then the error is logged in the log file.
          l_b_batch_unq := FALSE;
          IF l_t_rc_tab.COUNT > 0 THEN
            FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
              IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                IF l_t_rc_tab(l_n_cntr).batch_name IS NOT NULL THEN
                  IF ((l_t_rc_tab(l_n_cntr).item_number IS NOT NULL) AND
                      (l_t_rc_tab(l_n_cntr1).item_number IS NOT NULL)) THEN
                    IF ((l_t_rc_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                        (l_t_rc_tab(l_n_cntr1).batch_name = l_t_rc_tab(l_n_cntr).batch_name) AND
                        (l_t_rc_tab(l_n_cntr1).item_number = l_t_rc_tab(l_n_cntr).item_number) AND
                        (l_t_rc_tab(l_n_cntr1).lockbox_interface_id <> l_t_rc_tab(l_n_cntr).lockbox_interface_id)) THEN
                       l_b_batch_unq := TRUE;
                       EXIT;
                    END IF;
                  END IF;
                ELSE
                  IF ((l_t_rc_tab(l_n_cntr).item_number IS NOT NULL) AND
                      (l_t_rc_tab(l_n_cntr1).item_number IS NOT NULL)) THEN
                    IF ((l_t_rc_tab(l_n_cntr1).item_number = l_t_rc_tab(l_n_cntr).item_number) AND
                        (l_t_rc_tab(l_n_cntr1).lockbox_interface_id <> l_t_rc_tab(l_n_cntr).lockbox_interface_id)) THEN
                      l_b_batch_unq := TRUE;
                      EXIT;
                    END IF;
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;

          IF l_b_batch_unq THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_DUP_ITEM_NUMBER');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If any of the combination pairs of the Charge Code(1-8) and Applied Amount(1-8)
-- has the charge code provided but the corresponding applied amount not provided
-- or vice-versa, then this is an error condition and is logged in the log file.
          l_b_chg_amt_match := TRUE;
          IF (((l_t_rc_tab(l_n_cntr).charge_cd1 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt1 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd1 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt1 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd2 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt2 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd2 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt2 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd3 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt3 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd3 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt3 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd4 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt4 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd4 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt4 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd5 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt5 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd5 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt5 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd6 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt6 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd6 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt6 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd7 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt7 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd7 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt7 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF (((l_t_rc_tab(l_n_cntr).charge_cd8 IS NOT NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt8 IS NULL)) OR
              ((l_t_rc_tab(l_n_cntr).charge_cd8 IS NULL) AND
               (l_t_rc_tab(l_n_cntr).applied_amt8 IS NOT NULL))) THEN
            l_b_chg_amt_match := FALSE;
          END IF;

          IF NOT l_b_chg_amt_match THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_REC_CHG_APPL_MISSING');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- The following logic checks for the negative amount for the Charge Amount
-- for the receipt record
          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt1,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd1);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt2,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd2);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt3,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd3);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt4,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd4);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt5,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd5);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt6,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd6);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt7,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd7);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_rc_tab(l_n_cntr).applied_amt8,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_rc_tab(l_n_cntr).charge_cd8);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- Sum up the Applied Amount (1-8) of the receipt record
          l_n_amt_appl := NVL(l_t_rc_tab(l_n_cntr).applied_amt1,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt2,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt3,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt4,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt5,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt6,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt7,0) +
                          NVL(l_t_rc_tab(l_n_cntr).applied_amt8,0);

-- In addition to the summed up Applied Amounts from the Charge record,
-- Loop across the receipt overflow records for the receipt record
-- and sum up the applied amount (1-8) for the overflow record
          IF l_n_ro_cntr > 0 THEN
            l_n_cntr1 := 0;
            FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
              IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                l_b_ro_identified := FALSE;
                IF l_t_rc_tab(l_n_cntr).batch_name IS NOT NULL THEN
                  IF ((l_t_ro_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                      (l_t_ro_tab(l_n_cntr1).batch_name = l_t_rc_tab(l_n_cntr).batch_name) AND
                      (l_t_ro_tab(l_n_cntr1).item_number IS NOT NULL) AND
                      (l_t_ro_tab(l_n_cntr1).item_number = l_t_rc_tab(l_n_cntr).item_number)) THEN
                    l_b_ro_identified := TRUE;
                  END IF;
                ELSE
                  IF ((l_t_ro_tab(l_n_cntr1).item_number IS NOT NULL) AND
                      (l_t_ro_tab(l_n_cntr1).batch_name IS NULL) AND
                      (l_t_ro_tab(l_n_cntr1).item_number = l_t_rc_tab(l_n_cntr).item_number)) THEN
                    l_b_ro_identified := TRUE;
                  END IF;
                END IF;

                IF l_b_ro_identified THEN
                  l_n_amt_appl := NVL(l_n_amt_appl,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt1,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt2,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt3,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt4,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt5,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt6,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt7,0) +
                                  NVL(l_t_ro_tab(l_n_cntr1).applied_amt8,0);
                END IF;
              END IF;
            END LOOP;
          END IF;

-- If the amount to be applied is greater than the receipt amount then log the error in the log file
          IF l_n_amt_appl > NVL(l_t_rc_tab(l_n_cntr).receipt_amt,0) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_DESG_AMNT_MISMATCH');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_rc_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_rc_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
        END IF;
      END LOOP;
    END IF;

-- If there are any receipt overflow records, then
    IF l_n_ro_cntr > 0 THEN
-- Loop across the receipt overflow record and
      FOR l_n_cntr IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
        IF l_t_ro_tab.EXISTS(l_n_cntr) THEN

-- If the item number is not null, then log the error message in the log file
          IF l_t_ro_tab(l_n_cntr).item_number IS NULL THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_REC_ITEMS_MISSING');
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- The following logic checks for the negative amount for the Charge Amount
-- for the receipt overflow record
          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt1,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd1);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt2,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd2);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt3,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd3);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt4,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd4);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt5,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd5);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt6,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd6);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt7,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd7);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          IF NVL(l_t_ro_tab(l_n_cntr).applied_amt8,0) < 0 THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_CHG_AMT_NEG');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_message.set_token('CHARGE_CODE',
                                  l_t_ro_tab(l_n_cntr).charge_cd8);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          l_n_cntr1 := 0;
          l_b_rc_ro_match := FALSE;

-- If the batch name in the receipt overflow is not null, then check if the receipt overflow record
-- can be associated with a receipt record that has a valid batch name
          IF ((l_t_ro_tab(l_n_cntr).batch_name IS NOT NULL) AND
              (l_n_rc_cntr > 0)) THEN
            FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
              IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                IF (l_t_rc_tab(l_n_cntr1).batch_name IS NOT NULL) THEN
                  IF ((l_t_rc_tab(l_n_cntr1).batch_name = l_t_ro_tab(l_n_cntr).batch_name) AND
                      (l_t_rc_tab(l_n_cntr1).item_number = l_t_ro_tab(l_n_cntr).item_number)) THEN
                    l_b_rc_ro_match := TRUE;
                    EXIT;
                  END IF;
                END IF;
              END IF;
            END LOOP;

            IF l_b_rc_ro_match THEN
              IF l_t_bh_tab.COUNT > 0 THEN
                l_b_rc_ro_match := FALSE;
                FOR l_n_cntr2 IN l_t_bh_tab.FIRST..l_t_bh_tab.LAST LOOP
                  IF l_t_bh_tab.EXISTS(l_n_cntr2) THEN
                    IF l_t_bh_tab(l_n_cntr2).batch_name = l_t_ro_tab(l_n_cntr).batch_name THEN
                      l_b_rc_ro_match := TRUE;
                    END IF;
                  END IF;
                END LOOP;
              END IF;
            END IF;

-- Else if the the batch name is null then validate if the receipt overflow record can be associated
-- with a receipt record with null batch name
          ELSIF ((l_t_ro_tab(l_n_cntr).batch_name IS NULL) AND
                 (l_n_rc_cntr > 0)) THEN
            l_b_rc_ro_match := FALSE;
            FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
              IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                IF ((l_t_rc_tab(l_n_cntr1).batch_name IS NULL) AND
                     (l_t_rc_tab(l_n_cntr1).item_number = l_t_ro_tab(l_n_cntr).item_number)) THEN
                  l_b_rc_ro_match := TRUE;
                END IF;
              END IF;
            END LOOP;

-- Else if there are no receipt records then this is an error message
          ELSIF (l_n_rc_cntr = 0) THEN
            l_b_rc_ro_match := FALSE;
          END IF;

          IF NOT l_b_rc_ro_match THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_NO_OVFL_REC_LINK');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

          l_b_ro_chg_appl := TRUE;

-- If any of the combination pairs of the Charge Code(1-8) and Applied Amount(1-8)
-- has the charge code provided but the corresponding applied amount not provided
-- or vice-versa, then this is an error condition and is logged in the log file.

          IF (((l_t_ro_tab(l_n_cntr).charge_cd1 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt1 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd1 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt1 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd2 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt2 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd2 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt2 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd3 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt3 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd3 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt3 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd4 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt4 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd4 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt4 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd5 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt5 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd5 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt5 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd6 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt6 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd6 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt6 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd7 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt7 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd7 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt7 IS NOT NULL))) THEN
              l_b_ro_chg_appl := FALSE;
          END IF;

          IF (((l_t_ro_tab(l_n_cntr).charge_cd8 IS NOT NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt8 IS NULL))OR
              ((l_t_ro_tab(l_n_cntr).charge_cd8 IS NULL) AND
               (l_t_ro_tab(l_n_cntr).applied_amt8 IS NOT NULL))) THEN
            l_b_ro_chg_appl := FALSE;
          END IF;

          IF NOT l_b_ro_chg_appl THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_OVFL_REC_NO_CHG_APPL');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- If none of the charge code(1-8) and applied amount(1-8) is provided
-- then this is an error .
          IF ((l_t_ro_tab(l_n_cntr).charge_cd1 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt1 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd2 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt2 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd3 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt3 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd4 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt4 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd5 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt5 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd6 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt6 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd7 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt7 IS NULL)) AND
             ((l_t_ro_tab(l_n_cntr).charge_cd8 IS NULL) AND
              (l_t_ro_tab(l_n_cntr).applied_amt8 IS NULL)) THEN
            l_v_val_status := 'E';
            fnd_message.set_name('IGS',
                                 'IGS_FI_OVFL_REC_NO_CHG_APPL');
            fnd_message.set_token('ITEM_NUMBER',
                                   l_t_ro_tab(l_n_cntr).item_number);
            fnd_message.set_token('BATCH_NAME',
                                   l_t_ro_tab(l_n_cntr).batch_name);
            fnd_message.set_token('LOCKBOX_NAME',
                                   l_t_ro_tab(l_n_cntr).lockbox_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
        END IF;
      END LOOP;
    END IF;
    fnd_file.new_line(fnd_file.log);

    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
    return l_v_val_status;
  END validate_type1;

  PROCEDURE update_lbint_status(p_v_status       igs_fi_lockbox_ints.record_status%TYPE) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for updating the interface table record status.

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_n_rec_cntr     NUMBER(38);
  BEGIN
    IF g_lb_int_tab.COUNT > 0 THEN
      FOR l_n_rec_cntr IN g_lb_int_tab.FIRST..g_lb_int_tab.LAST LOOP
        IF g_lb_int_tab.EXISTS(l_n_rec_cntr) THEN
          igs_fi_lockbox_ints_pkg.update_row(x_rowid                     => g_lb_int_tab(l_n_rec_cntr).row_id,
                                             x_lockbox_interface_id      => g_lb_int_tab(l_n_rec_cntr).lockbox_interface_id,
                                             x_record_identifier_cd      => g_lb_int_tab(l_n_rec_cntr).record_identifier_cd,
                                             x_record_status             => p_v_status,
                                             x_deposit_date              => g_lb_int_tab(l_n_rec_cntr).deposit_date,
                                             x_transmission_record_count => g_lb_int_tab(l_n_rec_cntr).transmission_record_count,
                                             x_transmission_amt          => g_lb_int_tab(l_n_rec_cntr).transmission_amt,
                                             x_lockbox_name              => g_lb_int_tab(l_n_rec_cntr).lockbox_name,
                                             x_lockbox_batch_count       => g_lb_int_tab(l_n_rec_cntr).lockbox_batch_count,
                                             x_lockbox_record_count      => g_lb_int_tab(l_n_rec_cntr).lockbox_record_count,
                                             x_lockbox_amt               => g_lb_int_tab(l_n_rec_cntr).lockbox_amt,
                                             x_batch_name                => g_lb_int_tab(l_n_rec_cntr).batch_name,
                                             x_batch_amt                 => g_lb_int_tab(l_n_rec_cntr).batch_amt,
                                             x_batch_record_count        => g_lb_int_tab(l_n_rec_cntr).batch_record_count,
                                             x_item_number               => g_lb_int_tab(l_n_rec_cntr).item_number,
                                             x_receipt_amt               => g_lb_int_tab(l_n_rec_cntr).receipt_amt,
                                             x_check_cd                  => g_lb_int_tab(l_n_rec_cntr).check_cd,
                                             x_party_number              => g_lb_int_tab(l_n_rec_cntr).party_number,
                                             x_payer_name                => g_lb_int_tab(l_n_rec_cntr).payer_name,
                                             x_charge_cd1                => g_lb_int_tab(l_n_rec_cntr).charge_cd1,
                                             x_charge_cd2                => g_lb_int_tab(l_n_rec_cntr).charge_cd2,
                                             x_charge_cd3                => g_lb_int_tab(l_n_rec_cntr).charge_cd3,
                                             x_charge_cd4                => g_lb_int_tab(l_n_rec_cntr).charge_cd4,
                                             x_charge_cd5                => g_lb_int_tab(l_n_rec_cntr).charge_cd5,
                                             x_charge_cd6                => g_lb_int_tab(l_n_rec_cntr).charge_cd6,
                                             x_charge_cd7                => g_lb_int_tab(l_n_rec_cntr).charge_cd7,
                                             x_charge_cd8                => g_lb_int_tab(l_n_rec_cntr).charge_cd8,
                                             x_applied_amt1              => g_lb_int_tab(l_n_rec_cntr).applied_amt1,
                                             x_applied_amt2              => g_lb_int_tab(l_n_rec_cntr).applied_amt2,
                                             x_applied_amt3              => g_lb_int_tab(l_n_rec_cntr).applied_amt3,
                                             x_applied_amt4              => g_lb_int_tab(l_n_rec_cntr).applied_amt4,
                                             x_applied_amt5              => g_lb_int_tab(l_n_rec_cntr).applied_amt5,
                                             x_applied_amt6              => g_lb_int_tab(l_n_rec_cntr).applied_amt6,
                                             x_applied_amt7              => g_lb_int_tab(l_n_rec_cntr).applied_amt7,
                                             x_applied_amt8              => g_lb_int_tab(l_n_rec_cntr).applied_amt8,
                                             x_credit_type_cd            => g_lb_int_tab(l_n_rec_cntr).credit_type_cd,
                                             x_fee_cal_instance_cd       => g_lb_int_tab(l_n_rec_cntr).fee_cal_instance_cd,
                                             x_adm_application_id        => g_lb_int_tab(l_n_rec_cntr).adm_application_id,
                                             x_attribute_category        => g_lb_int_tab(l_n_rec_cntr).attribute_category,
                                             x_attribute1                => g_lb_int_tab(l_n_rec_cntr).attribute1,
                                             x_attribute2                => g_lb_int_tab(l_n_rec_cntr).attribute2,
                                             x_attribute3                => g_lb_int_tab(l_n_rec_cntr).attribute3,
                                             x_attribute4                => g_lb_int_tab(l_n_rec_cntr).attribute4,
                                             x_attribute5                => g_lb_int_tab(l_n_rec_cntr).attribute5,
                                             x_attribute6                => g_lb_int_tab(l_n_rec_cntr).attribute6,
                                             x_attribute7                => g_lb_int_tab(l_n_rec_cntr).attribute7,
                                             x_attribute8                => g_lb_int_tab(l_n_rec_cntr).attribute8,
                                             x_attribute9                => g_lb_int_tab(l_n_rec_cntr).attribute9,
                                             x_attribute10               => g_lb_int_tab(l_n_rec_cntr).attribute10,
                                             x_attribute11               => g_lb_int_tab(l_n_rec_cntr).attribute11,
                                             x_attribute12               => g_lb_int_tab(l_n_rec_cntr).attribute12,
                                             x_attribute13               => g_lb_int_tab(l_n_rec_cntr).attribute13,
                                             x_attribute14               => g_lb_int_tab(l_n_rec_cntr).attribute14,
                                             x_attribute15               => g_lb_int_tab(l_n_rec_cntr).attribute15,
                                             x_attribute16               => g_lb_int_tab(l_n_rec_cntr).attribute16,
                                             x_attribute17               => g_lb_int_tab(l_n_rec_cntr).attribute17,
                                             x_attribute18               => g_lb_int_tab(l_n_rec_cntr).attribute18,
                                             x_attribute19               => g_lb_int_tab(l_n_rec_cntr).attribute19,
                                             x_attribute20               => g_lb_int_tab(l_n_rec_cntr).attribute20);
        END IF;
      END LOOP;
    END IF;
  END update_lbint_status;

  PROCEDURE populate_lb_receipts AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for populating the receipt and overflow
                         records

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_n_cntr           NUMBER(38);
    l_n_rec_cntr       NUMBER(38);
  BEGIN
    l_n_rec_cntr := 0;
    IF g_lb_int_tab.COUNT > 0 THEN
      FOR l_n_cntr IN g_lb_int_tab.FIRST..g_lb_int_tab.LAST LOOP
        IF g_lb_int_tab.EXISTS(l_n_cntr) THEN
          IF g_lb_int_tab(l_n_cntr).system_record_identifier IN (g_v_receipt,
                                                                 g_v_receipt_oflow) THEN
            l_n_rec_cntr := l_n_rec_cntr + 1;
            g_t_rec_tab(l_n_rec_cntr).row_id := g_lb_int_tab(l_n_cntr).row_id;
            g_t_rec_tab(l_n_rec_cntr).system_record_identifier := g_lb_int_tab(l_n_cntr).system_record_identifier;
            g_t_rec_tab(l_n_rec_cntr).lockbox_interface_id := g_lb_int_tab(l_n_cntr).lockbox_interface_id;
            g_t_rec_tab(l_n_rec_cntr).deposit_date := g_lb_int_tab(l_n_cntr).deposit_date;
            g_t_rec_tab(l_n_rec_cntr).lockbox_name := g_lb_int_tab(l_n_cntr).lockbox_name;
            g_t_rec_tab(l_n_rec_cntr).batch_name := g_lb_int_tab(l_n_cntr).batch_name;
            g_t_rec_tab(l_n_rec_cntr).item_number := g_lb_int_tab(l_n_cntr).item_number;
            g_t_rec_tab(l_n_rec_cntr).receipt_amt := g_lb_int_tab(l_n_cntr).receipt_amt;
            g_t_rec_tab(l_n_rec_cntr).check_cd := g_lb_int_tab(l_n_cntr).check_cd;
            g_t_rec_tab(l_n_rec_cntr).party_number := g_lb_int_tab(l_n_cntr).party_number;
            g_t_rec_tab(l_n_rec_cntr).mapped_party_id := null;
            g_t_rec_tab(l_n_rec_cntr).payer_name := g_lb_int_tab(l_n_cntr).payer_name;
            g_t_rec_tab(l_n_rec_cntr).credit_type_cd := g_lb_int_tab(l_n_cntr).credit_type_cd;
            g_t_rec_tab(l_n_rec_cntr).mapped_credit_type_id := null;
            g_t_rec_tab(l_n_rec_cntr).fee_cal_instance_cd := g_lb_int_tab(l_n_cntr).fee_cal_instance_cd;
            g_t_rec_tab(l_n_rec_cntr).mapped_fee_cal_type := null;
            g_t_rec_tab(l_n_rec_cntr).mapped_fee_ci_sequence_number := null;
            g_t_rec_tab(l_n_rec_cntr).charge_cd1 := g_lb_int_tab(l_n_cntr).charge_cd1;
            g_t_rec_tab(l_n_rec_cntr).charge_cd2 := g_lb_int_tab(l_n_cntr).charge_cd2;
            g_t_rec_tab(l_n_rec_cntr).charge_cd3 := g_lb_int_tab(l_n_cntr).charge_cd3;
            g_t_rec_tab(l_n_rec_cntr).charge_cd4 := g_lb_int_tab(l_n_cntr).charge_cd4;
            g_t_rec_tab(l_n_rec_cntr).charge_cd5 := g_lb_int_tab(l_n_cntr).charge_cd5;
            g_t_rec_tab(l_n_rec_cntr).charge_cd6 := g_lb_int_tab(l_n_cntr).charge_cd6;
            g_t_rec_tab(l_n_rec_cntr).charge_cd7 := g_lb_int_tab(l_n_cntr).charge_cd7;
            g_t_rec_tab(l_n_rec_cntr).charge_cd8 := g_lb_int_tab(l_n_cntr).charge_cd8;
            g_t_rec_tab(l_n_rec_cntr).applied_amt1 := g_lb_int_tab(l_n_cntr).applied_amt1;
            g_t_rec_tab(l_n_rec_cntr).applied_amt2 := g_lb_int_tab(l_n_cntr).applied_amt2;
            g_t_rec_tab(l_n_rec_cntr).applied_amt3 := g_lb_int_tab(l_n_cntr).applied_amt3;
            g_t_rec_tab(l_n_rec_cntr).applied_amt4 := g_lb_int_tab(l_n_cntr).applied_amt4;
            g_t_rec_tab(l_n_rec_cntr).applied_amt5 := g_lb_int_tab(l_n_cntr).applied_amt5;
            g_t_rec_tab(l_n_rec_cntr).applied_amt6 := g_lb_int_tab(l_n_cntr).applied_amt6;
            g_t_rec_tab(l_n_rec_cntr).applied_amt7 := g_lb_int_tab(l_n_cntr).applied_amt7;
            g_t_rec_tab(l_n_rec_cntr).applied_amt8 := g_lb_int_tab(l_n_cntr).applied_amt8;
            g_t_rec_tab(l_n_rec_cntr).adm_application_id := g_lb_int_tab(l_n_cntr).adm_application_id;
            g_t_rec_tab(l_n_rec_cntr).attribute_category := g_lb_int_tab(l_n_cntr).attribute_category;
            g_t_rec_tab(l_n_rec_cntr).attribute1 := g_lb_int_tab(l_n_cntr).attribute1;
            g_t_rec_tab(l_n_rec_cntr).attribute2 := g_lb_int_tab(l_n_cntr).attribute2;
            g_t_rec_tab(l_n_rec_cntr).attribute3 := g_lb_int_tab(l_n_cntr).attribute3;
            g_t_rec_tab(l_n_rec_cntr).attribute4 := g_lb_int_tab(l_n_cntr).attribute4;
            g_t_rec_tab(l_n_rec_cntr).attribute5 := g_lb_int_tab(l_n_cntr).attribute5;
            g_t_rec_tab(l_n_rec_cntr).attribute6 := g_lb_int_tab(l_n_cntr).attribute6;
            g_t_rec_tab(l_n_rec_cntr).attribute7 := g_lb_int_tab(l_n_cntr).attribute7;
            g_t_rec_tab(l_n_rec_cntr).attribute8 := g_lb_int_tab(l_n_cntr).attribute8;
            g_t_rec_tab(l_n_rec_cntr).attribute9 := g_lb_int_tab(l_n_cntr).attribute9;
            g_t_rec_tab(l_n_rec_cntr).attribute10 := g_lb_int_tab(l_n_cntr).attribute10;
            g_t_rec_tab(l_n_rec_cntr).attribute11 := g_lb_int_tab(l_n_cntr).attribute11;
            g_t_rec_tab(l_n_rec_cntr).attribute12 := g_lb_int_tab(l_n_cntr).attribute12;
            g_t_rec_tab(l_n_rec_cntr).attribute13 := g_lb_int_tab(l_n_cntr).attribute13;
            g_t_rec_tab(l_n_rec_cntr).attribute14 := g_lb_int_tab(l_n_cntr).attribute14;
            g_t_rec_tab(l_n_rec_cntr).attribute15 := g_lb_int_tab(l_n_cntr).attribute15;
            g_t_rec_tab(l_n_rec_cntr).attribute16 := g_lb_int_tab(l_n_cntr).attribute16;
            g_t_rec_tab(l_n_rec_cntr).attribute17 := g_lb_int_tab(l_n_cntr).attribute17;
            g_t_rec_tab(l_n_rec_cntr).attribute18 := g_lb_int_tab(l_n_cntr).attribute18;
            g_t_rec_tab(l_n_rec_cntr).attribute19 := g_lb_int_tab(l_n_cntr).attribute19;
            g_t_rec_tab(l_n_rec_cntr).attribute20 := g_lb_int_tab(l_n_cntr).attribute20;
            g_t_rec_tab(l_n_rec_cntr).receipt_number := null;
            g_t_rec_tab(l_n_rec_cntr).record_status := g_v_todo;
            g_t_rec_tab(l_n_rec_cntr).eligible_to_apply_yn := 'N';
          END IF;
        END IF;
      END LOOP;
    END IF;
  END populate_lb_receipts;

  PROCEDURE val_charge_number_for_app(p_v_charge_code         igs_fi_inv_int.invoice_number%TYPE,
                                      p_v_party_number        hz_parties.party_number%TYPE,
                                      p_n_party_id            pls_integer,
                                      p_v_fee_type        OUT NOCOPY igs_fi_fee_type.fee_type%TYPE,
                                      p_n_invoice_id      OUT NOCOPY igs_fi_inv_int.invoice_id%TYPE,
                                      p_v_message_name    OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for validating the charge number and party combination

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_inv(cp_invoice_number      igs_fi_inv_int.invoice_number%TYPE,
                   cp_party_id            igs_fi_inv_int.person_id%TYPE) IS
      SELECT invoice_id,
             fee_type
      FROM   igs_fi_inv_int
      WHERE  person_id = cp_party_id
      AND    invoice_number = cp_invoice_number;

    CURSOR cur_ft(cp_fee_type      igs_fi_fee_type.fee_type%TYPE) IS
      SELECT designated_payment_flag
      FROM   igs_fi_fee_type
      WHERE  fee_type = cp_fee_type;

    l_v_fee_type              igs_fi_fee_type.fee_type%TYPE;
    l_n_inv_id                igs_fi_inv_int.invoice_id%TYPE;
    l_v_designated_pay_flag   igs_fi_fee_type.designated_payment_flag%TYPE;
  BEGIN

-- Validate if the Party Id and the charge code exist in the Charges table.
-- If not, then it is an error condition
    OPEN cur_inv(p_v_charge_code,
                 p_n_party_id);
    FETCH cur_inv INTO l_n_inv_id,
                       l_v_fee_type;
    IF cur_inv%NOTFOUND THEN
      CLOSE cur_inv;
      p_n_invoice_id := null;
      p_v_fee_type := null;
      fnd_message.set_name('IGS',
                           'IGS_FI_INV_CHG_CODE');
      fnd_message.set_token('CHARGE_NUMBER',
                             p_v_charge_code);
      fnd_message.set_token('PARTY_NUMBER',
                             p_v_party_number);
      p_v_message_name := fnd_message.get;
      RETURN;
    END IF;
    CLOSE cur_inv;

-- Validate if the Fee Type has the designated payment flag checked
    OPEN cur_ft(l_v_fee_type);
    FETCH cur_ft INTO l_v_designated_pay_flag;
    CLOSE cur_ft;

    IF NVL(l_v_designated_pay_flag,'N') = 'N' THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_CHG_FT_NOT_DESG');
      fnd_message.set_token('CHARGE_NUMBER',
                             p_v_charge_code);
      fnd_message.set_token('FEE_TYPE',
                             l_v_fee_type);
      p_v_message_name := fnd_message.get;
    END IF;

    p_n_invoice_id := l_n_inv_id;
    p_v_fee_type := l_v_fee_type;
  END val_charge_number_for_app;

  PROCEDURE invoke_target_appl(p_n_credit_id                PLS_INTEGER,
                               p_v_charge_code              igs_fi_inv_int.invoice_number%TYPE,
                               p_n_target_invoice_id        PLS_INTEGER,
                               p_n_amount_applied           NUMBER,
                               p_d_gl_date                  DATE,
                               p_n_act_amnt_applied     OUT NOCOPY NUMBER,
                               p_n_application_id       OUT NOCOPY PLS_INTEGER,
                               p_v_err_message          OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for invoking the applications API

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_inv(cp_invoice_id             igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT invoice_amount_due
      FROM   igs_fi_inv_int
      WHERE  invoice_id = cp_invoice_id;


    l_n_inv_amt_due        igs_fi_inv_int.invoice_amount_due%TYPE;
    l_n_app_id             igs_fi_applications.application_id%TYPE;
    l_n_act_apply_amount   igs_fi_applications.amount_applied%TYPE;
    l_n_dr_gl_ccid         igs_fi_applications.dr_gl_code_ccid%TYPE;
    l_n_cr_gl_ccid         igs_fi_applications.cr_gl_code_ccid%TYPE;
    l_v_dr_acc_cd          igs_fi_applications.dr_account_cd%TYPE;
    l_v_cr_acc_cd          igs_fi_applications.cr_account_cd%TYPE;
    l_n_unapp_amount       igs_fi_credits.unapplied_amount%TYPE;
    l_n_inv_amount_due     igs_fi_inv_int.invoice_amount_due%TYPE;
    l_v_err_msg            VARCHAR2(2000);
    l_b_status             BOOLEAN := FALSE;
  BEGIN

 -- Fetch the Invoice Amount Due from the Charges table
    OPEN cur_inv(p_n_target_invoice_id);
    FETCH cur_inv INTO l_n_inv_amt_due;
    CLOSE cur_inv;

-- If the Invoice Amount Due is less than or equal to 0, then log this in the log file
    IF l_n_inv_amt_due <= 0 THEN
      p_n_act_amnt_applied := null;
      p_n_application_id := null;
      fnd_message.set_name('IGS',
                           'IGS_FI_INV_AMT_DUE_NIL');
      fnd_message.set_token('CHARGE_NUMBER',
                             p_v_charge_code);
      p_v_err_message := fnd_message.get;
      RETURN;
    ELSE

-- Else identify if the amount applied is greater than the Invoice Amount Due.
-- If it is, then appply only the Invoice Amount Due
      IF p_n_amount_applied > l_n_inv_amt_due THEN
        l_n_act_apply_amount := l_n_inv_amt_due;
      ELSE
        l_n_act_apply_amount := p_n_amount_applied;
      END IF;
    END IF;

-- Call the API for application creation
    l_n_app_id := null;
    l_n_unapp_amount := 0;
    igs_fi_gen_007.create_application(p_application_id           => l_n_app_id,
                                      p_credit_id                => p_n_credit_id,
                                      p_invoice_id               => p_n_target_invoice_id,
                                      p_amount_apply             => l_n_act_apply_amount,
                                      p_appl_type                => g_v_app,
                                      p_appl_hierarchy_id        => null,
                                      p_validation               => 'N',
                                      p_dr_gl_ccid               => l_n_dr_gl_ccid,
                                      p_cr_gl_ccid               => l_n_cr_gl_ccid,
                                      p_dr_account_cd            => l_v_dr_acc_cd,
                                      p_cr_account_cd            => l_v_cr_acc_cd,
                                      p_unapp_amount             => l_n_unapp_amount,
                                      p_inv_amt_due              => l_n_inv_amount_due,
                                      p_err_msg                  => l_v_err_msg,
                                      p_status                   => l_b_status,
                                      p_d_gl_date                => p_d_gl_date);
    IF l_b_status THEN
      p_n_act_amnt_applied := l_n_act_apply_amount;
      p_n_application_id := l_n_app_id;
      p_v_err_message := null;
    ELSE
      p_n_act_amnt_applied := null;
      p_n_application_id := null;
      p_v_err_message := fnd_message.get_string('IGS',
                                                 l_v_err_msg);
    END IF;
  END invoke_target_appl;

  PROCEDURE insert_lb_errors(p_r_receipt_rec             lb_receipt_rec,
                             p_n_receipt_error_id    OUT NOCOPY PLS_INTEGER) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for inserting data in igs_fi_lb_rect_errs
                         table

     Known limitations,enhancements,remarks:
     Change History
     Who             When       What
     svuppala    12-May-2006   Bug 5217319 Added call to format amount by rounding off to currency precision
                              in the igs_fi_lb_rect_errs_pkg.insert_row call
    ***************************************************************** */
    l_v_rowid                       VARCHAR2(25);
    l_n_lockbox_receipt_error_id    igs_fi_lb_rect_errs.lockbox_receipt_error_id%TYPE;
  BEGIN

-- Create a record in the IGS_FI_LB_RECT_ERRS table
    l_v_rowid := null;
    l_n_lockbox_receipt_error_id := null;

 -- Bug 5217319 Added call to format amount by rounding off to currency precision
    igs_fi_lb_rect_errs_pkg.insert_row(x_rowid                      => l_v_rowid,
                                       x_lockbox_receipt_error_id   => l_n_lockbox_receipt_error_id,
                                       x_lockbox_interface_id       => p_r_receipt_rec.lockbox_interface_id,
                                       x_item_number                => p_r_receipt_rec.item_number,
                                       x_lockbox_name               => p_r_receipt_rec.lockbox_name,
                                       x_receipt_amt                => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.receipt_amt),
                                       x_batch_name                 => p_r_receipt_rec.batch_name,
                                       x_party_number               => p_r_receipt_rec.party_number,
                                       x_payer_name                 => p_r_receipt_rec.payer_name,
                                       x_check_cd                   => p_r_receipt_rec.check_cd,
                                       x_deposit_date               => p_r_receipt_rec.deposit_date,
                                       x_credit_type_cd             => p_r_receipt_rec.credit_type_cd,
                                       x_fee_cal_instance_cd        => p_r_receipt_rec.fee_cal_instance_cd,
                                       x_charge_cd1                 => p_r_receipt_rec.charge_cd1,
                                       x_charge_cd2                 => p_r_receipt_rec.charge_cd2,
                                       x_charge_cd3                 => p_r_receipt_rec.charge_cd3,
                                       x_charge_cd4                 => p_r_receipt_rec.charge_cd4,
                                       x_charge_cd5                 => p_r_receipt_rec.charge_cd5,
                                       x_charge_cd6                 => p_r_receipt_rec.charge_cd6,
                                       x_charge_cd7                 => p_r_receipt_rec.charge_cd7,
                                       x_charge_cd8                 => p_r_receipt_rec.charge_cd8,
                                       x_applied_amt1               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt1),
                                       x_applied_amt2               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt2),
                                       x_applied_amt3               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt3),
                                       x_applied_amt4               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt4),
                                       x_applied_amt5               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt5),
                                       x_applied_amt6               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt6),
                                       x_applied_amt7               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt7),
                                       x_applied_amt8               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt8),
                                       x_adm_application_id         => p_r_receipt_rec.adm_application_id,
                                       x_attribute_category         => p_r_receipt_rec.attribute_category,
                                       x_attribute1                 => p_r_receipt_rec.attribute1,
                                       x_attribute2                 => p_r_receipt_rec.attribute2,
                                       x_attribute3                 => p_r_receipt_rec.attribute3,
                                       x_attribute4                 => p_r_receipt_rec.attribute4,
                                       x_attribute5                 => p_r_receipt_rec.attribute5,
                                       x_attribute6                 => p_r_receipt_rec.attribute6,
                                       x_attribute7                 => p_r_receipt_rec.attribute7,
                                       x_attribute8                 => p_r_receipt_rec.attribute8,
                                       x_attribute9                 => p_r_receipt_rec.attribute9,
                                       x_attribute10                => p_r_receipt_rec.attribute10,
                                       x_attribute11                => p_r_receipt_rec.attribute11,
                                       x_attribute12                => p_r_receipt_rec.attribute12,
                                       x_attribute13                => p_r_receipt_rec.attribute13,
                                       x_attribute14                => p_r_receipt_rec.attribute14,
                                       x_attribute15                => p_r_receipt_rec.attribute15,
                                       x_attribute16                => p_r_receipt_rec.attribute16,
                                       x_attribute17                => p_r_receipt_rec.attribute17,
                                       x_attribute18                => p_r_receipt_rec.attribute18,
                                       x_attribute19                => p_r_receipt_rec.attribute19,
                                       x_attribute20                => p_r_receipt_rec.attribute20);
    p_n_receipt_error_id := l_n_lockbox_receipt_error_id;
  END insert_lb_errors;

  PROCEDURE insert_lb_ovfl_errors(p_r_receipt_rec           lb_receipt_rec,
                                  p_n_receipt_error_id      PLS_INTEGER) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for inserting data in igs_fi_lb_ovfl_errs
                         table

     Known limitations,enhancements,remarks:
     Change History
     Who            When       What
     svuppala    12-May-2006  Bug 5217319 Added call to format amount by rounding off to currency precision
                             in the igs_fi_lb_ovfl_errs_pkg.insert_row call
    ***************************************************************** */
    l_v_rowid                       VARCHAR2(25);
    l_n_rec_oflow_err_id            igs_fi_lb_ovfl_errs.receipt_overflow_error_id%TYPE;
  BEGIN
    l_v_rowid := null;
    l_n_rec_oflow_err_id := null;

-- Create a record in the IGS_FI_LB_OVFL_ERRS table
-- Bug 5217319 Added call to format amount by rounding off to currency precision
    igs_fi_lb_ovfl_errs_pkg.insert_row(x_rowid                      => l_v_rowid,
                                       x_receipt_overflow_error_id  => l_n_rec_oflow_err_id,
                                       x_lockbox_receipt_error_id   => p_n_receipt_error_id,
                                       x_charge_cd1                 => p_r_receipt_rec.charge_cd1,
                                       x_charge_cd2                 => p_r_receipt_rec.charge_cd2,
                                       x_charge_cd3                 => p_r_receipt_rec.charge_cd3,
                                       x_charge_cd4                 => p_r_receipt_rec.charge_cd4,
                                       x_charge_cd5                 => p_r_receipt_rec.charge_cd5,
                                       x_charge_cd6                 => p_r_receipt_rec.charge_cd6,
                                       x_charge_cd7                 => p_r_receipt_rec.charge_cd7,
                                       x_charge_cd8                 => p_r_receipt_rec.charge_cd8,
                                       x_applied_amt1               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt1),
                                       x_applied_amt2               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt2),
                                       x_applied_amt3               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt3),
                                       x_applied_amt4               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt4),
                                       x_applied_amt5               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt5),
                                       x_applied_amt6               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt6),
                                       x_applied_amt7               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt7),
                                       x_applied_amt8               => igs_fi_gen_gl.get_formatted_amount(p_r_receipt_rec.applied_amt8));
  END insert_lb_ovfl_errors;

  PROCEDURE delete_err_success(p_r_rowid                 rowid) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for deleting the successful records

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    CURSOR cur_lb_err(cp_rowid              rowid) IS
      SELECT lockbox_receipt_error_id
      FROM   igs_fi_lb_rect_errs
      WHERE  rowid = cp_rowid;

    CURSOR cur_lb_oflow(cp_lb_rec_err_id       igs_fi_lb_ovfl_errs.lockbox_receipt_error_id%TYPE) IS
      SELECT rowid row_id
      FROM igs_fi_lb_ovfl_errs
      WHERE lockbox_receipt_error_id = cp_lb_rec_err_id;

    l_n_receipt_error_id         igs_fi_lb_rect_errs.lockbox_receipt_error_id%TYPE;
  BEGIN

-- For the rowid passed, identifiy the receipt error_id
    OPEN cur_lb_err(p_r_rowid);
    FETCH cur_lb_err INTO l_n_receipt_error_id;
    CLOSE cur_lb_err;

-- For the receipt error id, loop across the records in the Overflow table
    FOR l_oflow_rec IN cur_lb_oflow(l_n_receipt_error_id) LOOP

-- delete the records in the Overflow table
      igs_fi_lb_ovfl_errs_pkg.delete_row(l_oflow_rec.row_id);
    END LOOP;

-- Delete the records in the main IGS_FI_LB_RECT_ERRS errors
    igs_fi_lb_rect_errs_pkg.delete_row(p_r_rowid);
  END delete_err_success;

  PROCEDURE invoke_credits_api_pvt(p_r_receipt_rec        lb_receipt_rec,
                                   p_n_credit_type_id     NUMBER,
                                   p_n_receipt_amt        NUMBER,
                                   p_n_credit_id      OUT NOCOPY PLS_INTEGER,
                                   p_v_status         OUT NOCOPY VARCHAR2,
                                   p_v_message_text   OUT NOCOPY VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for invoking Private Credits API

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     pmarada    26-JUL-2005  Enh 3392095, modifed as per tution waiver build, passing p_api_version
                             parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
     svuppala   9-JUN-2005   Enh 3442712 - Impact of automatic generation of the Receipt Number.
                             changed logic for credit_number.
     shtatiko   26-AUG-2003  Enh# 3045007, Added two new parameters, p_n_credit_type_id and p_n_receipt_amt.
     pathipat   21-Aug-2003  Enh 3076768 - Auto Release of Holds
                             Added code to get message even if
                             credits_api returns with status = 'S'
    ***************************************************************** */
    l_attribute_rec                igs_fi_credits_api_pub.attribute_rec_type;
    l_credit_rec                   igs_fi_credit_pvt.credit_rec_type;
    l_v_status                     VARCHAR2(1);
    l_n_msg_count                  NUMBER(10);
    l_v_msg_data                   VARCHAR2(2000);
    l_n_credit_id                  igs_fi_credits.credit_id%TYPE;
    l_n_cr_activity_id             igs_fi_cr_activities.credit_activity_id%TYPE;
    l_v_msg_txt                    VARCHAR2(2000);
    l_v_credit_number                igs_fi_credits_all.credit_number%TYPE;



  BEGIN

-- Invoke the Credits API for the receipt record
    l_attribute_rec.p_attribute_category := p_r_receipt_rec.attribute_category;
    l_attribute_rec.p_attribute1 := p_r_receipt_rec.attribute1;
    l_attribute_rec.p_attribute2 := p_r_receipt_rec.attribute2;
    l_attribute_rec.p_attribute3 := p_r_receipt_rec.attribute3;
    l_attribute_rec.p_attribute4 := p_r_receipt_rec.attribute4;
    l_attribute_rec.p_attribute5 := p_r_receipt_rec.attribute5;
    l_attribute_rec.p_attribute6 := p_r_receipt_rec.attribute6;
    l_attribute_rec.p_attribute7 := p_r_receipt_rec.attribute7;
    l_attribute_rec.p_attribute8 := p_r_receipt_rec.attribute8;
    l_attribute_rec.p_attribute9 := p_r_receipt_rec.attribute9;
    l_attribute_rec.p_attribute10 := p_r_receipt_rec.attribute10;
    l_attribute_rec.p_attribute11 := p_r_receipt_rec.attribute11;
    l_attribute_rec.p_attribute12 := p_r_receipt_rec.attribute12;
    l_attribute_rec.p_attribute13 := p_r_receipt_rec.attribute13;
    l_attribute_rec.p_attribute14 := p_r_receipt_rec.attribute14;
    l_attribute_rec.p_attribute15 := p_r_receipt_rec.attribute15;
    l_attribute_rec.p_attribute16 := p_r_receipt_rec.attribute16;
    l_attribute_rec.p_attribute17 := p_r_receipt_rec.attribute17;
    l_attribute_rec.p_attribute18 := p_r_receipt_rec.attribute18;
    l_attribute_rec.p_attribute19 := p_r_receipt_rec.attribute19;
    l_attribute_rec.p_attribute20 := p_r_receipt_rec.attribute20;


-- At present the deposit date, batch name and lockbox interface id columns are commented
-- due to the changes pending for the Credits API
    l_credit_rec.p_credit_status := 'CLEARED';
    l_credit_rec.p_credit_source := null;
    l_credit_rec.p_party_id      := p_r_receipt_rec.mapped_party_id;
    l_credit_rec.p_credit_instrument := 'LOCKBOX';
    l_credit_rec.p_description := g_v_cr_desc;
    l_credit_rec.p_currency_cd := g_v_currency_cd;
    l_credit_rec.p_exchange_rate := 1;
    l_credit_rec.p_transaction_date := trunc(sysdate);
    l_credit_rec.p_effective_date := trunc(sysdate);
    l_credit_rec.p_receipt_lockbox_number := p_r_receipt_rec.lockbox_name;
    l_credit_rec.p_fee_cal_type := p_r_receipt_rec.mapped_fee_cal_type;
    l_credit_rec.p_fee_ci_sequence_number := p_r_receipt_rec.mapped_fee_ci_sequence_number;
    l_credit_rec.p_check_number := p_r_receipt_rec.check_cd;
    l_credit_rec.p_source_tran_type := p_r_receipt_rec.source_transaction_type;
    l_credit_rec.p_source_tran_ref_number := p_r_receipt_rec.adm_application_id;
    l_credit_rec.p_gl_date := p_r_receipt_rec.gl_date;
    l_credit_rec.p_deposit_date := p_r_receipt_rec.deposit_date;
    l_credit_rec.p_batch_name := p_r_receipt_rec.batch_name;
    l_credit_rec.p_lockbox_interface_id := p_r_receipt_rec.lockbox_interface_id;

    -- Assign passed Credit Type Id and Receipt Amount.
    l_credit_rec.p_credit_type_id := p_n_credit_type_id;
    l_credit_rec.p_amount := p_n_receipt_amt;

    l_n_credit_id := null;
    l_n_cr_activity_id := null;
    igs_fi_credit_pvt.create_credit(p_api_version               => 2.1,
                                    p_init_msg_list             => fnd_api.g_true,
                                    p_commit                    => fnd_api.g_false,
                                    p_validation_level          => fnd_api.g_valid_level_none,
                                    x_return_status             => l_v_status,
                                    x_msg_count                 => l_n_msg_count,
                                    x_msg_data                  => l_v_msg_data,
                                    p_credit_rec                => l_credit_rec,
                                    p_attribute_record          => l_attribute_rec,
                                    x_credit_id                 => l_n_credit_id,
                                    x_credit_activity_id        => l_n_cr_activity_id,
                                    x_credit_number             => l_v_credit_number);
    IF l_v_status = 'S' THEN
       p_n_credit_id := l_n_credit_id;
       p_v_status := l_v_status;
       -- If Holds Release fails, then status = 'S' but msg count will be > 0
       -- Show the message on the stack in such a case
       IF l_n_msg_count <> 0 THEN
          FOR l_n_cntr IN 1..l_n_msg_count LOOP
              l_v_msg_txt := fnd_msg_pub.get(p_msg_index => l_n_cntr, p_encoded => 'T');
              fnd_message.set_encoded(l_v_msg_txt);
              p_v_message_text := p_v_message_text||fnd_message.get;
          END LOOP;
       END IF;
    ELSE
      -- If the credits API returns an error, then pass the error message out
      p_n_credit_id := null;
      p_v_status := l_v_status;
      IF l_n_msg_count = 1 THEN
        fnd_message.set_encoded(l_v_msg_data);
        p_v_message_text := fnd_message.get;
      ELSE
        FOR l_n_cntr IN 1..l_n_msg_count LOOP
          l_v_msg_txt := fnd_msg_pub.get(p_msg_index => l_n_cntr, p_encoded => 'T');
          fnd_message.set_encoded(l_v_msg_txt);
          p_v_message_text := p_v_message_text||fnd_message.get;
        END LOOP;
      END IF;
    END IF;
  END invoke_credits_api_pvt;

  PROCEDURE valtype2_and_import_rects(p_t_lb_rec_tab          lb_receipt_tab,
                                      p_v_test_run            VARCHAR2,
                                      p_d_gl_date             DATE,
                                      p_v_invoked_from        VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Procedure for type2 validations

     Known limitations,enhancements,remarks:
     Change History
     Who        When         What
     shtatiko   27-AUG-2003  Enh# 3045007, Added logic for creating Installment Credits.
     pathipat   21-Aug-2003  Enh 3076768 - Auto Release of Holds
                             Logged message even if invoke_credits_api_pvt() returns Success
                             for Holds-related actions
     agairola   01-Jul-03    Bug: 3030453 changed the call to the l_t_ro_tab.DELETE
                             to execute only if the receipt number matches the counter
     agairola   01-Jul-03    Bug: 3030673 assigned g_n_retcode = 1 when credits API
                             invocation fails
    ***************************************************************** */
    l_b_val_err       BOOLEAN;

-- In this cursor, HZ_PARTIES has been directly used to improve performance
    CURSOR cur_party(cp_party_number     hz_parties.party_number%TYPE) IS
      SELECT party_id person_id
      FROM   hz_parties
      WHERE  party_number = cp_party_number;

    CURSOR cur_lb_crt(cp_lockbox_name    igs_fi_lockboxes.lockbox_name%TYPE) IS
      SELECT default_credit_type_id
      FROM   igs_fi_lockboxes
      WHERE  lockbox_name = cp_lockbox_name;

    CURSOR cur_fcmap(cp_lockbox_name            igs_fi_lockboxes.lockbox_name%TYPE,
                     cp_bank_cd                 igs_fi_lb_fcis.bank_cd%TYPE) IS
      SELECT fee_cal_type,
             fee_ci_sequence_number
      FROM   igs_fi_lb_fcis
      WHERE  lockbox_name = cp_lockbox_name
      AND    bank_cd = cp_bank_cd;

    CURSOR cur_lb_crt_map(cp_lockbox_name      igs_fi_lb_cr_types.lockbox_name%TYPE,
                          cp_bank_cd           igs_fi_lb_cr_types.bank_cd%TYPE) IS
      SELECT credit_type_id
      FROM   igs_fi_lb_cr_types
      WHERE  bank_cd = cp_bank_cd
      AND    lockbox_name = cp_lockbox_name;

    l_t_rc_tab              lb_receipt_tab;
    l_n_rc_cntr             NUMBER(38) := 0;

    l_t_ro_tab              lb_receipt_tab;
    l_n_ro_cntr             NUMBER(38) := 0;
    l_v_credit_class        igs_fi_cr_types.credit_class%TYPE;
    l_b_ret_stat            BOOLEAN;
    l_b_ro_rec_found        BOOLEAN;
    l_n_pay_cr_type_id      igs_fi_cr_types.credit_type_id%TYPE;
    l_v_closing_status      VARCHAR2(5);
    l_v_message_name        VARCHAR2(2000);
    l_v_ld_cal_type         igs_ca_inst.cal_type%TYPE;
    l_n_ld_seq_num          igs_ca_inst.sequence_number%TYPE;
    l_v_fee_type            igs_fi_fee_type.fee_type%TYPE;
    l_n_invoice_id          igs_fi_inv_int.invoice_id%TYPE;
    l_v_message_text        VARCHAR2(2000);
    l_b_ro_rec_match        BOOLEAN;
    l_n_rec_err_id          igs_fi_lb_rect_errs.lockbox_receipt_error_id%TYPE;
    l_n_credit_id           igs_fi_credits.credit_id%TYPE;
    l_v_status              VARCHAR2(1);
    l_n_act_amnt_applied    igs_fi_applications.amount_applied%TYPE;
    l_n_app_id              igs_fi_applications.application_id%TYPE;
    l_n_rec_amnt_prc        igs_fi_credits.amount%TYPE;
    l_n_rec_cntr            NUMBER(38);
    l_n_receipt_number      NUMBER(38);
    l_n_cntr                NUMBER(38);
    l_n_cntr1               NUMBER(38);
    l_b_rec_succ            BOOLEAN;

    l_n_amount_api          igs_fi_credits_all.amount%TYPE;
    l_n_cr_type_id_api      igs_fi_cr_types_all.credit_type_id%TYPE;
    l_n_dflt_cr_type_id     igs_fi_cr_types_all.credit_type_id%TYPE;
    l_v_act_plan_name       igs_fi_pp_std_attrs.payment_plan_name%TYPE;
    l_n_act_plan_id         igs_fi_pp_std_attrs.student_plan_id%TYPE;
    l_n_plan_balance        igs_fi_pp_instlmnts.due_amt%TYPE;
    l_n_diff_amount         NUMBER := 0;

  BEGIN

-- Log the message for the Type 2 validation errors.
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);
    fnd_file.put_line(fnd_file.log,
                      g_v_label_type2);
    fnd_message.set_name('IGS',
                         'IGS_FI_REC_IMP_ERRS');
    fnd_file.put_line(fnd_file.log,
                      fnd_message.get);
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);

-- Divide the PL/SQL table into Receipt and Receipt Overflow records.
    IF p_t_lb_rec_tab.COUNT > 0 THEN
      FOR l_n_cntr IN p_t_lb_rec_tab.FIRST..p_t_lb_rec_tab.LAST LOOP
        IF p_t_lb_rec_tab.EXISTS(l_n_cntr) THEN
          IF p_t_lb_rec_tab(l_n_cntr).system_record_identifier = g_v_receipt THEN
            l_n_rc_cntr := l_n_rc_cntr + 1;
            l_t_rc_tab(l_n_rc_cntr) := p_t_lb_rec_tab(l_n_cntr);
          ELSE
            l_n_ro_cntr := l_n_ro_cntr + 1;
            l_t_ro_tab(l_n_ro_cntr) := p_t_lb_rec_tab(l_n_cntr);
          END IF;
        END IF;
      END LOOP;
    END IF;

-- The following logic associates a Receipt Overflow to a Receipt by setting the receipt
-- number field in the Receipt Overflow PL/SQL table to the index of the receipt record in
-- the receipt table. If the batch name is present for the receipt overflow, then the
-- combination of batch name and item number is checked. if the batch name is not present,
-- then null batch name and item number is checked.
    IF l_n_ro_cntr > 0 THEN
      FOR l_n_cntr IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
        IF l_t_ro_tab.EXISTS(l_n_cntr) THEN
          l_b_ro_rec_found := FALSE;
          IF l_t_ro_tab(l_n_cntr).batch_name IS NOT NULL THEN
            IF l_n_rc_cntr > 0 THEN
              FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
                IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                  IF ((l_t_rc_tab(l_n_cntr1).batch_name IS NOT NULL) AND
                      (l_t_rc_tab(l_n_cntr1).batch_name = l_t_ro_tab(l_n_cntr).batch_name) AND
                      (l_t_rc_tab(l_n_cntr1).item_number = l_t_ro_tab(l_n_cntr).item_number)) THEN
                      l_b_ro_rec_found := TRUE;
                      l_n_receipt_number := l_n_cntr1;
                      EXIT;
                  END IF;
                END IF;
              END LOOP;
            END IF;
            IF l_b_ro_rec_found THEN
              l_t_ro_tab(l_n_cntr).receipt_number := l_n_receipt_number;
            END IF;
            l_n_receipt_number := null;
          ELSE
            IF l_n_rc_cntr > 0 THEN
              FOR l_n_cntr1 IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
                IF l_t_rc_tab.EXISTS(l_n_cntr1) THEN
                  IF ((l_t_rc_tab(l_n_cntr1).batch_name IS NULL) AND
                      (l_t_rc_tab(l_n_cntr1).item_number = l_t_ro_tab(l_n_cntr).item_number)) THEN
                    l_b_ro_rec_found := TRUE;
                    l_n_receipt_number := l_n_cntr1;
                    EXIT;
                  END IF;
                END IF;
              END LOOP;
            END IF;
            IF l_b_ro_rec_found THEN
              l_t_ro_tab(l_n_cntr).receipt_number := l_n_receipt_number;
            END IF;
            l_n_receipt_number := null;
          END IF;
        END IF;
      END LOOP;
    END IF;

-- Loop across the receipt records
    IF l_n_rc_cntr > 0 THEN
      FOR l_n_cntr IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
        l_b_val_err := FALSE;
        g_b_log_head := FALSE;
        IF l_t_rc_tab.EXISTS(l_n_cntr) THEN

-- Validate if the party id is a valid party
          OPEN cur_party(l_t_rc_tab(l_n_cntr).party_number);
          FETCH cur_party INTO l_t_rc_tab(l_n_cntr).mapped_party_id;
          IF cur_party%NOTFOUND THEN
            l_b_val_err := TRUE;
            log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                          l_t_rc_tab(l_n_cntr).batch_name,
                          l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_name('IGS',
                                 'IGS_FI_INV_PARTY_NUMBER');
            fnd_message.set_token('PARTY_NUMBER',
                                   l_t_rc_tab(l_n_cntr).party_number);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;
          CLOSE cur_party;

-- Validate if the Credit Type is valid credit type
          IF l_t_rc_tab(l_n_cntr).credit_type_cd IS NULL THEN

-- Get the default credit type id from the lockbox
            OPEN cur_lb_crt(l_t_rc_tab(l_n_cntr).lockbox_name);
            FETCH cur_lb_crt INTO l_t_rc_tab(l_n_cntr).mapped_credit_type_id;
            CLOSE cur_lb_crt;

-- If the mapped credit type id is null, then it is a type 2 validation error
            IF l_t_rc_tab(l_n_cntr).mapped_credit_type_id IS NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_message.set_name('IGS',
                                   'IGS_FI_NO_DEF_CR_TYPE');
              fnd_message.set_token('LOCKBOX_NAME',
                                    l_t_rc_tab(l_n_cntr).lockbox_name);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;
          ELSE

-- For the Credit type code, get the mapped credit type id from the credit type
-- mapping table
            OPEN cur_lb_crt_map(l_t_rc_tab(l_n_cntr).lockbox_name,
                                l_t_rc_tab(l_n_cntr).credit_type_cd);
            FETCH cur_lb_crt_map INTO l_t_rc_tab(l_n_cntr).mapped_credit_type_id;

-- If the mapping could not be found, then it is a type 2 validation error
            IF cur_lb_crt_map%NOTFOUND THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_message.set_name('IGS',
                                   'IGS_FI_NO_CR_TYPE_MAP');
              fnd_message.set_token('CREDIT_TYPE_BANK_CODE',
                                    l_t_rc_tab(l_n_cntr).credit_type_cd);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;
            CLOSE cur_lb_crt_map;
          END IF;

-- If the mapped credit type id is not null then
          IF l_t_rc_tab(l_n_cntr).mapped_credit_type_id IS NOT NULL THEN
            l_v_credit_class := null;
            l_b_ret_stat := null;

-- Validate the Credit Type Id and get the credit class
            igs_fi_crdapi_util.validate_credit_type(p_n_credit_type_id     => l_t_rc_tab(l_n_cntr).mapped_credit_type_id,
                                                    p_v_credit_class       => l_v_credit_class,
                                                    p_b_return_stat        => l_b_ret_stat);
            IF NOT l_b_ret_stat THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_message.set_name('IGS',
                                   'IGS_FI_CAPI_CR_TYPE_INVALID');
              fnd_message.set_token('CR_TYPE',
                                    get_credit_type_name(l_t_rc_tab(l_n_cntr).mapped_credit_type_id));
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;

-- If the Credit Class is Enrollment Deposit or Other Deposit, then check if the Charge Code and Charge Amount
-- are provided. If they are provided then it is an error.
-- Added g_v_inst_payment to the following condition as part of Enh# 3045007 as Receipt Record with credit class
-- Installment Payment cannot have designated payments associated with it.
            IF l_v_credit_class IN (g_v_enr_deposit,
                                    g_v_oth_deposit,
                                    g_v_inst_payment) THEN
              IF ((l_t_rc_tab(l_n_cntr).charge_cd1 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt1 IS  NOT NULL)) OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd2 IS  NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt2 IS  NOT NULL)) OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd3 IS  NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt3 IS NOT NULL))  OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd4 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt4 IS NOT NULL))  OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd5 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt5 IS NOT NULL))  OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd6 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt6 IS NOT NULL))  OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd7 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt7 IS NOT NULL))  OR
                 ((l_t_rc_tab(l_n_cntr).charge_cd8 IS NOT NULL) AND
                  (l_t_rc_tab(l_n_cntr).applied_amt8 IS NOT NULL)) THEN
                -- Added code to set l_b_val_err as part of Enh# 3045007 so that application does not happen after credit creation.
                l_b_val_err := TRUE;
                log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                              l_t_rc_tab(l_n_cntr).batch_name,
                              l_t_rc_tab(l_n_cntr).item_number);
                fnd_message.set_name('IGS',
                                     'IGS_FI_DEP_NO_OVFLOW');
                fnd_message.set_token('CREDIT_CLASS',
                                      igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CLASS', l_v_credit_class));
                fnd_file.put_line(fnd_file.LOG, fnd_message.get);
              END IF;

-- Also check if there are any overflow records for the receipt in case of Enrollment Deposit or Other Deposit
-- If there are any overflow records then it is a type 2 error.
              IF l_n_ro_cntr > 0 THEN
                l_b_ro_rec_found := FALSE;
                l_n_cntr1 := 0;
                FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
                  IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                    IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                      l_b_ro_rec_found := TRUE;
                      EXIT;
                    END IF;
                  END IF;
                END LOOP;

                IF l_b_ro_rec_found THEN
                  l_b_val_err := TRUE;
                  log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                l_t_rc_tab(l_n_cntr).batch_name,
                                l_t_rc_tab(l_n_cntr).item_number);
                  fnd_message.set_name('IGS',
                                       'IGS_FI_DEP_NO_OVFLOW');
                  fnd_message.set_token('CREDIT_CLASS',
                                        igs_fi_gen_gl.get_lkp_meaning('IGS_FI_CREDIT_CLASS', l_v_credit_class));
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get);
                END IF;
              END IF;

              IF l_v_credit_class IN (g_v_enr_deposit,
                                      g_v_oth_deposit ) THEN

    -- Validate if the Credit Class is Enrollment Deposit, then the mapped party should be a Student
    -- If the creidt class is Other Deposit, then the mapped party should be a person
                IF NOT igs_fi_crdapi_util.validate_party_id(p_n_party_id       => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                                            p_v_credit_class   => l_v_credit_class) THEN
                  l_b_val_err := TRUE;
                  log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                l_t_rc_tab(l_n_cntr).batch_name,
                                l_t_rc_tab(l_n_cntr).item_number);
                  IF l_v_credit_class = g_v_enr_deposit THEN
                    fnd_message.set_name('IGS',
                                         'IGS_FI_PARTY_STUDENT');
                    fnd_message.set_token('PARTY_NUMBER',
                                          l_t_rc_tab(l_n_cntr).party_number);
                    fnd_file.put_line(fnd_file.log,
                                      fnd_message.get);
                  ELSIF l_v_credit_class = g_v_oth_deposit THEN
                    fnd_message.set_name('IGS',
                                         'IGS_FI_PARTY_PERSON');
                    fnd_message.set_token('PARTY_NUMBER',
                                          l_t_rc_tab(l_n_cntr).party_number);
                    fnd_file.put_line(fnd_file.log,
                                      fnd_message.get);
                  END IF;
                END IF;
                l_b_ret_stat := null;
                l_n_pay_cr_type_id := null;

    -- Validate the Payment Credit Type for the Mapped Credit Type
                igs_fi_crdapi_util.validate_dep_crtype(p_n_credit_type_id      => l_t_rc_tab(l_n_cntr).mapped_credit_type_id,
                                                       p_n_pay_credit_type_id  => l_n_pay_cr_type_id,
                                                       p_b_return_stat         => l_b_ret_stat);

    -- If the payment credit type is not valid or is closed, then log the error in the log file
                IF NOT l_b_ret_stat THEN
                  l_b_val_err := TRUE;
                  log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                l_t_rc_tab(l_n_cntr).batch_name,
                                l_t_rc_tab(l_n_cntr).item_number);
                  fnd_message.set_name('IGS',
                                       'IGS_FI_PCT_DCT_INVALID');
                  fnd_message.set_token('PAY_CR_TYPE',
                                        get_credit_type_name(l_n_pay_cr_type_id));
                  fnd_message.set_token('DEP_CR_TYPE',
                                        get_credit_type_name(l_t_rc_tab(l_n_cntr).mapped_credit_type_id));
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get);
                END IF;

    -- If the credit class is ENRDEPOSIT, then validate if the Admission Application Id is valid. If not, log the error in the
    -- log file.
                IF l_v_credit_class = g_v_enr_deposit THEN
                  IF NOT igs_fi_crdapi_util.validate_source_tran_ref_num(p_n_party_id             => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                                                     p_n_source_tran_ref_num  => l_t_rc_tab(l_n_cntr).adm_application_id) THEN
                    l_b_val_err := TRUE;
                    log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                  l_t_rc_tab(l_n_cntr).batch_name,
                                  l_t_rc_tab(l_n_cntr).item_number);
                    fnd_message.set_name('IGS',
                                         'IGS_FI_INV_ADM_APPL_ID');
                    fnd_message.set_token('ADMISSION_APPLICATION_ID',
                                           l_t_rc_tab(l_n_cntr).adm_application_id);
                    fnd_message.set_token('PARTY_NUMBER',
                                          l_t_rc_tab(l_n_cntr).party_number);
                    fnd_file.put_line(fnd_file.log,
                                      fnd_message.get);
                  ELSE
                    l_t_rc_tab(l_n_cntr).source_transaction_type := g_v_adm;
                  END IF;
                END IF;
              END IF;
            END IF; -- End if for the Credit Class
          END IF; -- Check for the Mapped Credit Id being present

-- If the GL Date Source is Deposit Date, then
          IF g_v_gl_date_source = g_v_deposit_date THEN

-- Validate if the Deposit Date is null. If yes, then log this error in the log file.
            IF l_t_rc_tab(l_n_cntr).deposit_date IS NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_message.set_name('IGS',
                                   'IGS_FI_GL_DATE_MISSING');
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            ELSE

-- Else, validate if the deposit date is in an Open or Future Period or is in a valid accounting period.
              l_t_rc_tab(l_n_cntr).gl_date  := trunc(l_t_rc_tab(l_n_cntr).deposit_date);
              igs_fi_gen_gl.get_period_status_for_date(p_d_date           => l_t_rc_tab(l_n_cntr).gl_date,
                                                       p_v_closing_status => l_v_closing_status,
                                                       p_v_message_name   => l_v_message_name);
              IF l_v_message_name IS NOT NULL THEN
                l_b_val_err := TRUE;
                log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                              l_t_rc_tab(l_n_cntr).batch_name,
                              l_t_rc_tab(l_n_cntr).item_number);
                fnd_message.set_name('IGS',
                                     l_v_message_name);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              ELSIF l_v_closing_status NOT IN ('O','F') THEN
                l_b_val_err := TRUE;
                log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                              l_t_rc_tab(l_n_cntr).batch_name,
                              l_t_rc_tab(l_n_cntr).item_number);
                fnd_message.set_name('IGS',
                                     'IGS_FI_INVALID_GL_DATE');
                fnd_message.set_token('GL_DATE',
                                      l_t_rc_tab(l_n_cntr).gl_date);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
            END IF;
          ELSIF g_v_gl_date_source = g_v_imp_date THEN

-- If the GL Date Source is Import Date, then System Date is used for the gl date
            l_t_rc_tab(l_n_cntr).gl_date  := trunc(sysdate);
          ELSIF g_v_gl_date_source = g_v_user_supp_dt THEN

-- If the GL Date Source is User Supplied Date, then the input parameter p_d_gl_date is taken as GL Date
            l_t_rc_tab(l_n_cntr).gl_date  := p_d_gl_date;
          END IF;

-- If the fee calendar instance code is provided, then
          IF l_t_rc_tab(l_n_cntr).fee_cal_instance_cd IS NOT NULL THEN

-- Get the mapped Fee Calendar Instance for the lockbox
            OPEN cur_fcmap(l_t_rc_tab(l_n_cntr).lockbox_name,
                           l_t_rc_tab(l_n_cntr).fee_cal_instance_cd);
            FETCH cur_fcmap INTO l_t_rc_tab(l_n_cntr).mapped_fee_cal_type,
                                 l_t_rc_tab(l_n_cntr).mapped_fee_ci_sequence_number;

-- If the mapping is not available, then log the message in the log file.
            IF cur_fcmap%NOTFOUND THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_message.set_name('IGS',
                                   'IGS_FI_NO_FCI_MAP');
              fnd_message.set_token('FEE_CAL_INSTANCE_CODE',
                                     l_t_rc_tab(l_n_cntr).fee_cal_instance_cd);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            END IF;
            CLOSE cur_fcmap;

-- If the Mapped Fee Cal Type can be derived, then check if it is a valid Fee calendar.
            IF ((l_t_rc_tab(l_n_cntr).mapped_fee_cal_type IS NOT NULL) AND
                (l_t_rc_tab(l_n_cntr).mapped_fee_ci_sequence_number IS NOT NULL)) THEN
              IF NOT igs_fi_crdapi_util.validate_cal_inst(p_v_cal_type             => l_t_rc_tab(l_n_cntr).mapped_fee_cal_type,
                                                          p_n_ci_sequence_number   => l_t_rc_tab(l_n_cntr).mapped_fee_ci_sequence_number,
                                                          p_v_s_cal_cat            => g_v_fee) THEN
                l_b_val_err := TRUE;
                log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                              l_t_rc_tab(l_n_cntr).batch_name,
                              l_t_rc_tab(l_n_cntr).item_number);
                fnd_message.set_name('IGS',
                                     'IGS_FI_FCI_INVALID');
                fnd_message.set_token('FEE_CAL_INSTANCE_CODE',
                                       l_t_rc_tab(l_n_cntr).fee_cal_instance_cd);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;

-- Check if the Mapped Fee Calendar Instance has a valid Load Calendar Instance
              l_v_ld_cal_type := null;
              l_n_ld_seq_num  := null;
              l_v_message_name := null;
              l_b_ret_stat := null;
              igs_fi_crdapi_util.validate_fci_lci_reln(p_v_fee_cal_type            => l_t_rc_tab(l_n_cntr).mapped_fee_cal_type,
                                                       p_n_fee_ci_sequence_number  => l_t_rc_tab(l_n_cntr).mapped_fee_ci_sequence_number,
                                                       p_v_ld_cal_type             => l_v_ld_cal_type,
                                                       p_n_ld_ci_sequence_number   => l_n_ld_seq_num,
                                                       p_v_message_name            => l_v_message_name,
                                                       p_b_return_stat             => l_b_ret_stat);
              IF NOT l_b_ret_stat THEN
                l_b_val_err := TRUE;
                log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                              l_t_rc_tab(l_n_cntr).batch_name,
                              l_t_rc_tab(l_n_cntr).item_number);
                fnd_message.set_name('IGS',
                                     l_v_message_name);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
            END IF;
          END IF;

-- Validate the Receipt Amount
          l_v_message_name := null;
          l_b_ret_stat := null;
          igs_fi_crdapi_util.validate_amount(p_n_amount         => l_t_rc_tab(l_n_cntr).receipt_amt,
                                             p_b_return_status  => l_b_ret_stat,
                                             p_v_message_name   => l_v_message_name);
          IF NOT l_b_ret_stat THEN
            l_b_val_err := TRUE;
            log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                          l_t_rc_tab(l_n_cntr).batch_name,
                          l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_name('IGS',
                                 l_v_message_name);
            fnd_file.put_line(fnd_file.log,
                              fnd_message.get);
          END IF;

-- Validate the DFF
          IF NOT igs_fi_crdapi_util.validate_desc_flex(p_v_attribute_category     => l_t_rc_tab(l_n_cntr).attribute_category,
                                                       p_v_attribute1             => l_t_rc_tab(l_n_cntr).attribute1,
                                                       p_v_attribute2             => l_t_rc_tab(l_n_cntr).attribute2,
                                                       p_v_attribute3             => l_t_rc_tab(l_n_cntr).attribute3,
                                                       p_v_attribute4             => l_t_rc_tab(l_n_cntr).attribute4,
                                                       p_v_attribute5             => l_t_rc_tab(l_n_cntr).attribute5,
                                                       p_v_attribute6             => l_t_rc_tab(l_n_cntr).attribute6,
                                                       p_v_attribute7             => l_t_rc_tab(l_n_cntr).attribute7,
                                                       p_v_attribute8             => l_t_rc_tab(l_n_cntr).attribute8,
                                                       p_v_attribute9             => l_t_rc_tab(l_n_cntr).attribute9,
                                                       p_v_attribute10            => l_t_rc_tab(l_n_cntr).attribute10,
                                                       p_v_attribute11            => l_t_rc_tab(l_n_cntr).attribute11,
                                                       p_v_attribute12            => l_t_rc_tab(l_n_cntr).attribute12,
                                                       p_v_attribute13            => l_t_rc_tab(l_n_cntr).attribute13,
                                                       p_v_attribute14            => l_t_rc_tab(l_n_cntr).attribute14,
                                                       p_v_attribute15            => l_t_rc_tab(l_n_cntr).attribute15,
                                                       p_v_attribute16            => l_t_rc_tab(l_n_cntr).attribute16,
                                                       p_v_attribute17            => l_t_rc_tab(l_n_cntr).attribute17,
                                                       p_v_attribute18            => l_t_rc_tab(l_n_cntr).attribute18,
                                                       p_v_attribute19            => l_t_rc_tab(l_n_cntr).attribute19,
                                                       p_v_attribute20            => l_t_rc_tab(l_n_cntr).attribute20,
                                                       p_v_desc_flex_name         => 'IGS_FI_CREDITS_ALL_FLEX') THEN
            l_b_val_err := TRUE;
            log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                          l_t_rc_tab(l_n_cntr).batch_name,
                          l_t_rc_tab(l_n_cntr).item_number);
            fnd_message.set_name('IGS',
                                 'IGS_AD_INVALID_DESC_FLEX');
            fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
          END IF;

-- If any of the Charge Codes is not null, then validate if the charge number can be applied and is a valid charge
-- If not then it is an error message.
          IF l_t_rc_tab(l_n_cntr).charge_cd1 IS NOT NULL THEN
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd1,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id1 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd2 IS NOT NULL THEN
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd2,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id2 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd3 IS NOT NULL THEN
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd3,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id3 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd4 IS NOT NULL THEN
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd4,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id4 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd5 IS NOT NULL THEN
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd5,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id5 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd6 IS NOT NULL THEN
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd6,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id6 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd7 IS NOT NULL THEN
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd7,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id1 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

          IF l_t_rc_tab(l_n_cntr).charge_cd8 IS NOT NULL THEN
            l_v_fee_type := null;
            l_n_invoice_id := null;
            l_v_message_text := null;
            l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            val_charge_number_for_app(p_v_charge_code        => l_t_rc_tab(l_n_cntr).charge_cd8,
                                      p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                      p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                      p_v_fee_type           => l_v_fee_type,
                                      p_n_invoice_id         => l_n_invoice_id,
                                      p_v_message_name       => l_v_message_text);
            IF l_v_message_text IS NOT NULL THEN
              l_b_val_err := TRUE;
              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                            l_t_rc_tab(l_n_cntr).batch_name,
                            l_t_rc_tab(l_n_cntr).item_number);
              fnd_file.put_line(fnd_file.log,
                                l_v_message_text);
            ELSE
              l_t_rc_tab(l_n_cntr).target_invoice_id8 := l_n_invoice_id;
              l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
            END IF;
          END IF;

-- Also, loop across the receipt overflow records for the receipt and validate if the Charge Code
-- is not null, then check if charge can be applied and is a valid charge.
          IF l_n_ro_cntr > 0 THEN
            l_n_cntr1 := 0;
            FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
              IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                  IF l_t_ro_tab(l_n_cntr1).charge_cd1 IS NOT NULL THEN
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd1,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id1 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd2 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd2,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id2 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd3 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd3,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id3 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd4 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd4,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id4 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;
                  IF l_t_ro_tab(l_n_cntr1).charge_cd5 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd5,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id5 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd6 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd6,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id6 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd7 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd7,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id7 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_t_ro_tab(l_n_cntr1).charge_cd8 IS NOT NULL THEN
                    l_v_fee_type := null;
                    l_n_invoice_id := null;
                    l_v_message_text := null;
                    l_t_rc_tab(l_n_cntr).eligible_to_apply_yn := 'Y';
                    val_charge_number_for_app(p_v_charge_code        => l_t_ro_tab(l_n_cntr1).charge_cd8,
                                              p_v_party_number       => l_t_rc_tab(l_n_cntr).party_number,
                                              p_n_party_id           => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                              p_v_fee_type           => l_v_fee_type,
                                              p_n_invoice_id         => l_n_invoice_id,
                                              p_v_message_name       => l_v_message_text);
                    IF l_v_message_text IS NOT NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      IF l_b_val_err THEN
                        l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                      ELSE
                        l_t_ro_tab(l_n_cntr1).target_invoice_id8 := l_n_invoice_id;
                        l_t_ro_tab(l_n_cntr1).eligible_to_apply_yn := 'Y';
                      END IF;
                    END IF;
                  END IF;

                  IF l_b_val_err THEN
                    g_n_retcode := 1;
                    l_t_ro_tab(l_n_cntr1).record_status := g_v_error;
                  END IF;
                END IF;
              END IF;
            END LOOP;
          END IF;

-- If there is any validation error, then update the receipt record status to Error
-- If the test run is No and the process has been invoked from Interface Process, then
-- create record in the Lockbox Error tables.
-- Remove the erroneous records from the PL/SQL table.
          IF l_b_val_err THEN
            g_n_retcode := 1;
            l_t_rc_tab(l_n_cntr).record_status := g_v_error;
            IF p_v_test_run = 'N' AND p_v_invoked_from = 'I' THEN
                l_n_rec_err_id := null;
                insert_lb_errors(p_r_receipt_rec       => l_t_rc_tab(l_n_cntr),
                                 p_n_receipt_error_id  => l_n_rec_err_id);
            END IF;
            l_n_cntr1 := null;
            IF l_t_ro_tab.COUNT > 0 THEN
              FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
                IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                  IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                    IF p_v_test_run = 'N' AND p_v_invoked_from = 'I' THEN
                      insert_lb_ovfl_errors(p_r_receipt_rec       => l_t_ro_tab(l_n_cntr1),
                                            p_n_receipt_error_id  => l_n_rec_err_id);
                    END IF;
                    l_t_ro_tab.DELETE(l_n_cntr1);
                  END IF;
                END IF;
              END LOOP;
            END IF;
            l_t_rc_tab.DELETE(l_n_cntr);
            l_n_rc_cntr := l_t_rc_tab.COUNT;
            l_n_ro_cntr := l_t_ro_tab.COUNT;
          ELSE

-- Else if there is no error, then
            BEGIN
              SAVEPOINT SP_LOCKBOX_TYPE2;
              l_n_credit_id := null;
              l_v_status := null;
              l_v_message_text := null;

              IF l_v_credit_class <> g_v_inst_payment THEN
                l_n_cr_type_id_api := l_t_rc_tab(l_n_cntr).mapped_credit_type_id;
                l_n_amount_api := l_t_rc_tab(l_n_cntr).receipt_amt;
              ELSE
                -- If Credit Class is Installment Payments then carry on following validations.

                -- Check if the person is on Active Payment Plan or Not.
                igs_fi_gen_008.get_plan_details ( p_n_person_id     => l_t_rc_tab(l_n_cntr).mapped_party_id,
                                                  p_n_act_plan_id   => l_n_act_plan_id,
                                                  p_v_act_plan_name => l_v_act_plan_name );
                IF l_v_act_plan_name IS NULL THEN
                  -- If the person is not on any active Payment Plan then check for existence of Defauly Credit Type Id for the Lockbox in the context
                  OPEN cur_lb_crt (l_t_rc_tab(l_n_cntr).lockbox_name);
                  FETCH cur_lb_crt INTO l_n_dflt_cr_type_id;
                  CLOSE cur_lb_crt;
                  IF l_n_dflt_cr_type_id IS NULL THEN
                    -- If Lockbox does not have Default Credit Type associated, then log error.
                    l_b_val_err := TRUE;
                    log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                  l_t_rc_tab(l_n_cntr).batch_name,
                                  l_t_rc_tab(l_n_cntr).item_number);
                    l_t_rc_tab(l_n_cntr).record_status := g_v_error;

                    fnd_message.set_name( 'IGS', 'IGS_FI_PP_NO_DEF_CRT' );
                    fnd_message.set_token( 'LOCKBOX_NAME', l_t_rc_tab(l_n_cntr).lockbox_name );
                    fnd_file.put_line(fnd_file.LOG, fnd_message.get);
                  ELSE
                    -- If Default Credit Type is present then proceed with credit creation.
                    l_n_cr_type_id_api := l_n_dflt_cr_type_id;
                    l_t_rc_tab(l_n_cntr).mapped_credit_type_id := l_n_dflt_cr_type_id;
                    l_n_amount_api := l_t_rc_tab(l_n_cntr).receipt_amt;
                  END IF;
                ELSE
                  -- If Person is on Active Payment Plan, get the plan balance
                  l_n_plan_balance := igs_fi_gen_008.get_plan_balance( p_n_act_plan_id    => l_n_act_plan_id,
                                                                       p_d_effective_date => NULL );

                  -- Check the difference between Receipt Amount of the Receipt record and Plan Balance.
                  l_n_diff_amount := NVL(l_t_rc_tab(l_n_cntr).receipt_amt, 0) - NVL(l_n_plan_balance, 0);
                  IF l_n_diff_amount <= 0 THEN
                    -- Create credit for the given amount with INSTALLMENT_PAYMENTS Credit Class.
                    l_n_amount_api := l_t_rc_tab(l_n_cntr).receipt_amt;
                    l_n_cr_type_id_api := l_t_rc_tab(l_n_cntr).mapped_credit_type_id;
                  ELSE
                    -- If the receipt amount is greater than plan balance,
                    -- then, create normal credit record for difference amount using default credit type of lockbox.
                    --      and Installment credit should be created for plan balance.
                    OPEN cur_lb_crt (l_t_rc_tab(l_n_cntr).lockbox_name);
                    FETCH cur_lb_crt INTO l_n_dflt_cr_type_id;
                    CLOSE cur_lb_crt;
                    IF l_n_dflt_cr_type_id IS NULL THEN
                      -- If Lockbox does not have Default Credit Type associated, then log error.
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      l_t_rc_tab(l_n_cntr).record_status := g_v_error;

                      fnd_message.set_name( 'IGS', 'IGS_FI_PP_NO_DEF_CRT' );
                      fnd_message.set_token( 'LOCKBOX_NAME', l_t_rc_tab(l_n_cntr).lockbox_name );
                      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
                    ELSE
                      -- If Default Credit Type is present then proceed with credit creation for the difference amount.
                      l_n_cr_type_id_api := l_n_dflt_cr_type_id;
                      l_n_amount_api := l_n_diff_amount;

                      -- Assign this extra amount and default credit type to l_t_rc_tab(l_n_cntr) so that this info is logged later on.
                      l_t_rc_tab(l_n_cntr).balance_amount := l_n_amount_api;
                      l_t_rc_tab(l_n_cntr).dflt_cr_type_id := l_n_dflt_cr_type_id;

                      -- Invoke the Credits API for creating the credit
                      invoke_credits_api_pvt(p_r_receipt_rec          => l_t_rc_tab(l_n_cntr),
                                             p_n_credit_type_id       => l_n_cr_type_id_api,   /* Default Credit Type */
                                             p_n_receipt_amt          => l_n_amount_api,       /* Difference Amount */
                                             p_n_credit_id            => l_n_credit_id,
                                             p_v_status               => l_v_status,
                                             p_v_message_text         => l_v_message_text);
                      IF l_v_status <> 'S' THEN
                        l_b_val_err := TRUE;
                        log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                      l_t_rc_tab(l_n_cntr).batch_name,
                                      l_t_rc_tab(l_n_cntr).item_number);
                        l_t_rc_tab(l_n_cntr).record_status := g_v_error;

                        fnd_file.put_line(fnd_file.LOG, l_v_message_text);
                      ELSE
                        -- Even when status = 'S', there might be a message if holds release failed.
                        l_b_val_err := FALSE;
                        l_n_credit_id := NULL;
                        l_v_status := NULL;
                        l_v_message_text := NULL;
                        l_n_cr_type_id_api := l_t_rc_tab(l_n_cntr).mapped_credit_type_id;
                        l_n_amount_api := l_n_plan_balance;
                        l_t_rc_tab(l_n_cntr).receipt_amt := l_n_plan_balance;
                      END IF;
                    END IF;
                  END IF;  -- End of checking the difference between receipt amount and plan balance.
                END IF; -- Checking for person on active payment plan.
              END IF;  -- Check of Credit Class

              IF NOT l_b_val_err THEN
    -- Invoke the Credits API for creating the credit
                invoke_credits_api_pvt(p_r_receipt_rec          => l_t_rc_tab(l_n_cntr),
                                       p_n_credit_type_id       => l_n_cr_type_id_api,
                                       p_n_receipt_amt          => l_n_amount_api,
                                       p_n_credit_id            => l_n_credit_id,
                                       p_v_status               => l_v_status,
                                       p_v_message_text         => l_v_message_text);
                IF l_v_status <> 'S' THEN
    -- If the credit API returns with an error, then log the error in the log file.
                  l_b_val_err := TRUE;
                  log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                l_t_rc_tab(l_n_cntr).batch_name,
                                l_t_rc_tab(l_n_cntr).item_number);
                  l_t_rc_tab(l_n_cntr).record_status := g_v_error;

                  fnd_file.put_line(fnd_file.log,
                                    l_v_message_text);
                ELSE
                  -- Even when status = 'S', there might be a message if holds release failed.
                  l_b_val_err := FALSE;
                  l_t_rc_tab(l_n_cntr).credit_id := l_n_credit_id;
                  l_t_rc_tab(l_n_cntr).holds_released_yn := 'Y';
                  -- Record status would be success since the record is imported
                  -- irrespective of holds release failing
                  l_t_rc_tab(l_n_cntr).record_status := g_v_success;
                  IF l_v_message_text IS NOT NULL THEN
                     -- Hence, log the message (Auto Release of Holds build)
                     l_t_rc_tab(l_n_cntr).holds_released_yn := 'N';
                     g_v_holds_message := l_v_message_text;
                  END IF;
                END IF;
              END IF;

-- If there have been no errors, then
              IF NOT l_b_val_err THEN

-- If the eligible to apply flag is set to N, then record status is updated to success
                IF l_t_rc_tab(l_n_cntr).eligible_to_apply_yn = 'N' THEN
                  l_t_rc_tab(l_n_cntr).record_status := g_v_success;
                ELSE
-- Else if the eligible to apply flag is set to Y, then for each charge record,
-- Invoke the application procedure. If the application procedure returns error then the whole receipt record is marked as error
                  IF l_t_rc_tab(l_n_cntr).charge_cd1 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd1,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id1,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt1,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt1 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd2 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd2,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id2,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt2,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt2 := l_n_act_amnt_applied;
                    END IF;
                  END IF;

                  IF l_t_rc_tab(l_n_cntr).charge_cd3 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd3,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id3,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt3,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt3 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd4 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd4,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id4,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt4,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt4 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd5 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd5,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id5,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt5,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt5 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd6 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd6,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id6,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt6,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt6 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd7 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd7,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id7,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt7,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt7 := l_n_act_amnt_applied;
                    END IF;
                  END IF;
                  IF l_t_rc_tab(l_n_cntr).charge_cd8 IS NOT NULL THEN
                    l_v_message_text := null;
                    l_n_act_amnt_applied := null;
                    l_n_app_id := null;
                    invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                       p_v_charge_code           => l_t_rc_tab(l_n_cntr).charge_cd8,
                                       p_n_target_invoice_id     => l_t_rc_tab(l_n_cntr).target_invoice_id8,
                                       p_n_amount_applied        => l_t_rc_tab(l_n_cntr).applied_amt8,
                                       p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                       p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                       p_n_application_id        => l_n_app_id,
                                       p_v_err_message           => l_v_message_text);
                    IF l_n_app_id IS NULL THEN
                      l_b_val_err := TRUE;
                      log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                    l_t_rc_tab(l_n_cntr).batch_name,
                                    l_t_rc_tab(l_n_cntr).item_number);
                      fnd_file.put_line(fnd_file.log,
                                        l_v_message_text);
                    ELSE
                      l_t_rc_tab(l_n_cntr).act_applied_amt8 := l_n_act_amnt_applied;
                    END IF;
                  END IF;

-- For each of the receipt overflow record for the reciept, invoke the Applications procedure. Incase of error
-- the receipt and the receipt overflow would be marked as error
                  IF l_t_ro_tab.COUNT > 0 THEN
                    FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
                      IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                        IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                          IF l_t_ro_tab(l_n_cntr1).charge_cd1 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd1,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id1,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt1,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt1 := l_n_act_amnt_applied;
                            END IF;
                          END IF;

                          IF l_t_ro_tab(l_n_cntr1).charge_cd2 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd2,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id2,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt2,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                              p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt2 := l_n_act_amnt_applied;
                            END IF;
                          END IF;

                          IF l_t_ro_tab(l_n_cntr1).charge_cd3 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd3,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id3,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt3,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt3 := l_n_act_amnt_applied;
                            END IF;
                          END IF;

                          IF l_t_ro_tab(l_n_cntr1).charge_cd4 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd1,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id4,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt4,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt4 := l_n_act_amnt_applied;
                            END IF;
                          END IF;

                          IF l_t_ro_tab(l_n_cntr1).charge_cd5 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd5,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id5,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt5,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt5 := l_n_act_amnt_applied;
                            END IF;
                          END IF;

                          IF l_t_ro_tab(l_n_cntr1).charge_cd6 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd6,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id6,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt6,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt6 := l_n_act_amnt_applied;
                            END IF;
                          END IF;
                          IF l_t_ro_tab(l_n_cntr1).charge_cd7 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd7,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id7,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt7,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt7 := l_n_act_amnt_applied;
                            END IF;
                          END IF;
                          IF l_t_ro_tab(l_n_cntr1).charge_cd8 IS NOT NULL THEN
                            l_v_message_text := null;
                            l_n_act_amnt_applied := null;
                            l_n_app_id := null;
                            invoke_target_appl(p_n_credit_id             => l_t_rc_tab(l_n_cntr).credit_id,
                                               p_v_charge_code           => l_t_ro_tab(l_n_cntr1).charge_cd8,
                                               p_n_target_invoice_id     => l_t_ro_tab(l_n_cntr1).target_invoice_id8,
                                               p_n_amount_applied        => l_t_ro_tab(l_n_cntr1).applied_amt8,
                                               p_d_gl_date               => l_t_rc_tab(l_n_cntr).gl_date,
                                               p_n_act_amnt_applied      => l_n_act_amnt_applied,
                                               p_n_application_id        => l_n_app_id,
                                               p_v_err_message           => l_v_message_text);
                            IF l_n_app_id IS NULL THEN
                              l_b_val_err := TRUE;
                              log_type2_err(l_t_rc_tab(l_n_cntr).lockbox_name,
                                            l_t_rc_tab(l_n_cntr).batch_name,
                                            l_t_rc_tab(l_n_cntr).item_number);
                              fnd_file.put_line(fnd_file.log,
                                                l_v_message_text);
                            ELSE
                              l_t_ro_tab(l_n_cntr1).act_applied_amt8 := l_n_act_amnt_applied;
                            END IF;
                          END IF;
                        END IF;
                      END IF;
                    END LOOP;
                  END IF;

                  IF l_b_val_err THEN
                    ROLLBACK TO SP_LOCKBOX_TYPE2;
                    l_t_rc_tab(l_n_cntr).record_status := g_v_error;
                  ELSE
                    l_t_rc_tab(l_n_cntr).record_status := g_v_success;
                  END IF;
                END IF;
              END IF;
            EXCEPTION
              WHEN OTHERS THEN
                l_b_val_err := TRUE;
                ROLLBACK TO SP_LOCKBOX_TYPE2;
            END;

-- If there have been any errors, then
-- If the test run is No and the process has been invoked from Interface Process, then
-- create record in the Lockbox Error tables.
-- Remove the erroneous records from the PL/SQL table.
            IF l_b_val_err THEN
              g_n_retcode := 1;
              IF p_v_test_run = 'N' AND p_v_invoked_from = 'I' THEN
                l_n_rec_err_id := null;
                insert_lb_errors(p_r_receipt_rec       => l_t_rc_tab(l_n_cntr),
                                 p_n_receipt_error_id  => l_n_rec_err_id);
              END IF;
              l_n_cntr1 := null;
              IF l_t_ro_tab.COUNT > 0 THEN
                FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
                  IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                    IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                      IF p_v_test_run = 'N' AND p_v_invoked_from = 'I' THEN
                        insert_lb_ovfl_errors(p_r_receipt_rec       => l_t_ro_tab(l_n_cntr1),
                                              p_n_receipt_error_id  => l_n_rec_err_id);
                      END IF;
                      l_t_ro_tab.DELETE(l_n_cntr1);
                    END IF;
                  END IF;
                END LOOP;
              END IF;
              l_t_rc_tab.DELETE(l_n_cntr);
              l_n_rc_cntr := l_t_rc_tab.COUNT;
              l_n_ro_cntr := l_t_ro_tab.COUNT;
            END IF;
          END IF;
          l_b_val_err := FALSE;
        END IF; -- End if for check of EXISTS
      END LOOP;
    END IF;

    IF l_t_rc_tab.COUNT = 0 THEN
      fnd_file.put_line(fnd_file.log,
                        g_v_line_sep);
    END IF;


-- Following logic writes the successfully imported records details in the
-- concurrent manager log file

    l_b_rec_succ := FALSE;
    IF l_t_rc_tab.COUNT > 0 THEN
      -- All erraneous records are deleted from PL/SQL table above, so l_t_rc_tab contains all success records.
      l_b_rec_succ := TRUE;
      fnd_file.new_line(fnd_file.log);
      fnd_file.put_line(fnd_file.log,
                        g_v_line_sep);
      fnd_message.set_name('IGS',
                           'IGS_FI_REC_IMP_SUCC');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      fnd_file.put_line(fnd_file.log,
                        g_v_line_sep);
      l_n_rec_cntr := 0;
      FOR l_n_cntr IN l_t_rc_tab.FIRST..l_t_rc_tab.LAST LOOP
        IF l_t_rc_tab.EXISTS(l_n_cntr) THEN
          IF l_t_rc_tab(l_n_cntr).record_status = g_v_success THEN
            l_n_rec_cntr := l_n_rec_cntr + 1;
            l_n_rec_amnt_prc := NVL(l_n_rec_amnt_prc,0) +
                                NVL(l_t_rc_tab(l_n_cntr).receipt_amt,0);
            log_line(g_v_label_lb_name,
                     l_t_rc_tab(l_n_cntr).lockbox_name);
            log_line(g_v_label_batch,
                     l_t_rc_tab(l_n_cntr).batch_name);
            log_line(g_v_label_item,
                     l_t_rc_tab(l_n_cntr).item_number);
            log_line(g_v_label_status,
                     g_v_label_success);
            log_line(g_v_label_party,
                     l_t_rc_tab(l_n_cntr).party_number);
            log_line(g_v_label_rec_amnt,
                     l_t_rc_tab(l_n_cntr).receipt_amt);
            log_line(g_v_label_cr_type,
                     get_credit_type_name(l_t_rc_tab(l_n_cntr).mapped_credit_type_id));
            -- Log amount and credit type name if there is balance amount after creating Installment Credit.
            IF l_t_rc_tab(l_n_cntr).dflt_cr_type_id IS NOT NULL THEN
              log_line(g_v_label_bal_amnt,
                       l_t_rc_tab(l_n_cntr).balance_amount);
              log_line(g_v_label_dflt_cr_type,
                       get_credit_type_name(l_t_rc_tab(l_n_cntr).dflt_cr_type_id));
            END IF;

            log_line(g_v_label_fee_prd,
                     get_fee_period(l_t_rc_tab(l_n_cntr).mapped_fee_cal_type,
                                    l_t_rc_tab(l_n_cntr).mapped_fee_ci_sequence_number));
            log_line(g_v_label_gl_date,
                     l_t_rc_tab(l_n_cntr).gl_date);
            log_line(g_v_label_adm_appl_num,
                     l_t_rc_tab(l_n_cntr).adm_application_id);
            fnd_file.new_line(fnd_file.log);

            IF l_t_rc_tab(l_n_cntr).charge_cd1 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd1);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt1);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt1);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd2 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd2);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt2);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt2);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd3 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd3);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt3);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt3);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd4 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd4);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt4);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt4);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd5 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd5);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt5);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt5);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd6 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd6);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt6);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt6);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd7 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd7);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt7);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt7);
              fnd_file.new_line(fnd_file.log);
            END IF;

            IF l_t_rc_tab(l_n_cntr).charge_cd8 IS NOT NULL THEN
              log_line(g_v_label_charge_code,
                       l_t_rc_tab(l_n_cntr).charge_cd8);
              log_line(g_v_label_bank_app_amt,
                       l_t_rc_tab(l_n_cntr).applied_amt8);
              log_line(g_v_label_act_app_amt,
                       l_t_rc_tab(l_n_cntr).act_applied_amt8);
              fnd_file.new_line(fnd_file.log);
            END IF;

            l_n_cntr1 := 0;
            IF l_t_ro_tab.COUNT > 0 THEN
              FOR l_n_cntr1 IN l_t_ro_tab.FIRST..l_t_ro_tab.LAST LOOP
                IF l_t_ro_tab.EXISTS(l_n_cntr1) THEN
                  IF l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr THEN
                    IF l_t_ro_tab(l_n_cntr1).charge_cd1 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd1);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt1);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt1);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd2 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd2);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt2);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt2);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd3 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd3);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt3);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt3);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd4 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd4);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt4);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt4);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd5 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd5);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt5);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt5);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd6 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd6);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt6);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt6);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd7 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd7);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt7);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt7);
                      fnd_file.new_line(fnd_file.log);
                    END IF;

                    IF l_t_ro_tab(l_n_cntr1).charge_cd8 IS NOT NULL THEN
                      log_line(g_v_label_charge_code,
                               l_t_ro_tab(l_n_cntr1).charge_cd8);
                      log_line(g_v_label_bank_app_amt,
                               l_t_ro_tab(l_n_cntr1).applied_amt8);
                      log_line(g_v_label_act_app_amt,
                               l_t_ro_tab(l_n_cntr1).act_applied_amt8);
                      fnd_file.new_line(fnd_file.log);
                    END IF;
                  END IF;  -- End if for l_t_ro_tab(l_n_cntr1).receipt_number = l_n_cntr
                END IF;  -- End if for l_t_ro_tab.EXISTS(l_n_cntr1)
              END LOOP;
            END IF;  -- End if for l_t_ro_tab.COUNT > 0

            -- If holds could not be released after credit creation,
            -- display message conveying the same.
            IF l_t_rc_tab(l_n_cntr).holds_released_yn = 'N' THEN
               fnd_file.put_line(fnd_file.log,g_v_holds_message);
               fnd_file.new_line(fnd_file.log);
            END IF;

          END IF;  -- End if for l_t_rc_tab(l_n_cntr).record_status = g_v_success


          -- If the Procedure has been invoked from the Error resolution process and the
          -- test run is No, then delete the successful records from the lockbox error tables
          IF p_v_invoked_from = 'E' AND p_v_test_run = 'N' THEN
            delete_err_success(p_r_rowid  => l_t_rc_tab(l_n_cntr).row_id);
          END IF;
        END IF;  -- End if for l_t_rc_tab.EXISTS(l_n_cntr)
      END LOOP;
    END IF;

-- Log the final summary of transactions
    fnd_file.new_line(fnd_file.log,2);
    log_line(g_v_label_num_rec,
             NVL(l_n_rec_cntr,0));
    log_line(g_v_label_cur_rec,
             NVL(l_n_rec_amnt_prc,0));
    fnd_file.put_line(fnd_file.log,
                      g_v_line_sep);

    l_n_rec_cntr := 0;
    l_n_rec_amnt_prc := 0;

-- Setting the g_n_retcode appropriately
    IF p_v_invoked_from = 'E' THEN
      IF NOT l_b_rec_succ THEN
        g_n_retcode := 2;
      ELSE
        IF g_n_retcode = 0 THEN
          g_n_retcode := 0;
        ELSE
          g_n_retcode := 1;
        END IF;
      END IF;
    END IF;
  END valtype2_and_import_rects;

  PROCEDURE populate_err_rec( p_v_lockbox_name IN  igs_fi_lockboxes.lockbox_name%TYPE,
                              p_t_err_rec_tab  OUT NOCOPY lb_receipt_tab) AS

    /******************************************************************
     Created By      :   Shirish Tatikonda
     Date Created By :   12-Jun-2003
     Purpose         :   Function for populating the Error Reciept/Overflow records

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  CURSOR cur_err_rec( cp_v_lockbox_name igs_fi_lockboxes.lockbox_name%TYPE ) IS
    SELECT ROWID row_id, lre.*
    FROM igs_fi_lb_rect_errs lre
    WHERE lockbox_name = cp_v_lockbox_name
    FOR UPDATE NOWAIT;

    l_err_rec cur_err_rec%ROWTYPE;

  CURSOR cur_err_ro( cp_n_lre_id igs_fi_lb_ovfl_errs.lockbox_receipt_error_id%TYPE ) IS
    SELECT ROWID row_id, loe.*
    FROM igs_fi_lb_ovfl_errs loe
    WHERE lockbox_receipt_error_id = cp_n_lre_id
    FOR UPDATE NOWAIT;

    l_err_ro cur_err_ro%ROWTYPE;
    l_n_cntr         NUMBER := 0;

  BEGIN

    -- Populate Receipt Records from igs_fi_lb_rect_errs into PL/SQL Table.
    FOR l_err_rec IN cur_err_rec( p_v_lockbox_name ) LOOP
      l_n_cntr := l_n_cntr + 1;

      p_t_err_rec_tab(l_n_cntr).record_status := g_v_todo;
      p_t_err_rec_tab(l_n_cntr).row_id := l_err_rec.row_id;
      p_t_err_rec_tab(l_n_cntr).lockbox_interface_id := l_err_rec.lockbox_interface_id;
      p_t_err_rec_tab(l_n_cntr).system_record_identifier := g_v_receipt;
      p_t_err_rec_tab(l_n_cntr).deposit_date := l_err_rec.deposit_date;
      p_t_err_rec_tab(l_n_cntr).lockbox_name := l_err_rec.lockbox_name;
      p_t_err_rec_tab(l_n_cntr).batch_name := l_err_rec.batch_name;
      p_t_err_rec_tab(l_n_cntr).item_number := l_err_rec.item_number;
      p_t_err_rec_tab(l_n_cntr).receipt_amt := l_err_rec.receipt_amt;
      p_t_err_rec_tab(l_n_cntr).check_cd := l_err_rec.check_cd;
      p_t_err_rec_tab(l_n_cntr).party_number := l_err_rec.party_number;
      p_t_err_rec_tab(l_n_cntr).mapped_party_id := NULL;
      p_t_err_rec_tab(l_n_cntr).payer_name := l_err_rec.payer_name;
      p_t_err_rec_tab(l_n_cntr).credit_type_cd := l_err_rec.credit_type_cd;
      p_t_err_rec_tab(l_n_cntr).mapped_credit_type_id := NULL;
      p_t_err_rec_tab(l_n_cntr).fee_cal_instance_cd := l_err_rec.fee_cal_instance_cd;
      p_t_err_rec_tab(l_n_cntr).mapped_fee_cal_type := NULL;
      p_t_err_rec_tab(l_n_cntr).mapped_fee_ci_sequence_number := NULL;
      p_t_err_rec_tab(l_n_cntr).charge_cd1 := l_err_rec.charge_cd1;
      p_t_err_rec_tab(l_n_cntr).charge_cd2 := l_err_rec.charge_cd2;
      p_t_err_rec_tab(l_n_cntr).charge_cd3 := l_err_rec.charge_cd3;
      p_t_err_rec_tab(l_n_cntr).charge_cd4 := l_err_rec.charge_cd4;
      p_t_err_rec_tab(l_n_cntr).charge_cd5 := l_err_rec.charge_cd5;
      p_t_err_rec_tab(l_n_cntr).charge_cd6 := l_err_rec.charge_cd6;
      p_t_err_rec_tab(l_n_cntr).charge_cd7 := l_err_rec.charge_cd7;
      p_t_err_rec_tab(l_n_cntr).charge_cd8 := l_err_rec.charge_cd8;
      p_t_err_rec_tab(l_n_cntr).applied_amt1 := l_err_rec.applied_amt1;
      p_t_err_rec_tab(l_n_cntr).applied_amt2 := l_err_rec.applied_amt2;
      p_t_err_rec_tab(l_n_cntr).applied_amt3 := l_err_rec.applied_amt3;
      p_t_err_rec_tab(l_n_cntr).applied_amt4 := l_err_rec.applied_amt4;
      p_t_err_rec_tab(l_n_cntr).applied_amt5 := l_err_rec.applied_amt5;
      p_t_err_rec_tab(l_n_cntr).applied_amt6 := l_err_rec.applied_amt6;
      p_t_err_rec_tab(l_n_cntr).applied_amt7 := l_err_rec.applied_amt7;
      p_t_err_rec_tab(l_n_cntr).applied_amt8 := l_err_rec.applied_amt8;
      p_t_err_rec_tab(l_n_cntr).adm_application_id := l_err_rec.adm_application_id;
      p_t_err_rec_tab(l_n_cntr).attribute_category := l_err_rec.attribute_category;
      p_t_err_rec_tab(l_n_cntr).attribute1 := l_err_rec.attribute1;
      p_t_err_rec_tab(l_n_cntr).attribute2 := l_err_rec.attribute2;
      p_t_err_rec_tab(l_n_cntr).attribute3 := l_err_rec.attribute3;
      p_t_err_rec_tab(l_n_cntr).attribute4 := l_err_rec.attribute4;
      p_t_err_rec_tab(l_n_cntr).attribute5 := l_err_rec.attribute5;
      p_t_err_rec_tab(l_n_cntr).attribute6 := l_err_rec.attribute6;
      p_t_err_rec_tab(l_n_cntr).attribute7 := l_err_rec.attribute7;
      p_t_err_rec_tab(l_n_cntr).attribute8 := l_err_rec.attribute8;
      p_t_err_rec_tab(l_n_cntr).attribute9 := l_err_rec.attribute9;
      p_t_err_rec_tab(l_n_cntr).attribute10 := l_err_rec.attribute10;
      p_t_err_rec_tab(l_n_cntr).attribute11 := l_err_rec.attribute11;
      p_t_err_rec_tab(l_n_cntr).attribute12 := l_err_rec.attribute12;
      p_t_err_rec_tab(l_n_cntr).attribute13 := l_err_rec.attribute13;
      p_t_err_rec_tab(l_n_cntr).attribute14 := l_err_rec.attribute14;
      p_t_err_rec_tab(l_n_cntr).attribute15 := l_err_rec.attribute15;
      p_t_err_rec_tab(l_n_cntr).attribute16 := l_err_rec.attribute16;
      p_t_err_rec_tab(l_n_cntr).attribute17 := l_err_rec.attribute17;
      p_t_err_rec_tab(l_n_cntr).attribute18 := l_err_rec.attribute18;
      p_t_err_rec_tab(l_n_cntr).attribute19 := l_err_rec.attribute19;
      p_t_err_rec_tab(l_n_cntr).attribute20 := l_err_rec.attribute20;
      p_t_err_rec_tab(l_n_cntr).credit_id := NULL;
      p_t_err_rec_tab(l_n_cntr).gl_date := NULL;
      p_t_err_rec_tab(l_n_cntr).source_transaction_type := NULL;
      p_t_err_rec_tab(l_n_cntr).eligible_to_apply_yn := NULL;
      p_t_err_rec_tab(l_n_cntr).receipt_number := NULL;

      -- Populate Receipt Overflow Records found for each Receipt Record from igs_fi_lb_ovfl_errs into PL/SQL Table.
      FOR l_err_ro IN cur_err_ro( l_err_rec.lockbox_receipt_error_id ) LOOP
        l_n_cntr := l_n_cntr + 1;

        p_t_err_rec_tab(l_n_cntr).record_status := g_v_todo;
        p_t_err_rec_tab(l_n_cntr).row_id := l_err_ro.row_id;
        p_t_err_rec_tab(l_n_cntr).lockbox_interface_id := NULL;
        p_t_err_rec_tab(l_n_cntr).system_record_identifier := g_v_receipt_oflow;
        p_t_err_rec_tab(l_n_cntr).deposit_date := NULL;
        p_t_err_rec_tab(l_n_cntr).lockbox_name := l_err_rec.lockbox_name;
        p_t_err_rec_tab(l_n_cntr).batch_name := l_err_rec.batch_name;
        p_t_err_rec_tab(l_n_cntr).item_number := l_err_rec.item_number;
        p_t_err_rec_tab(l_n_cntr).receipt_amt := NULL;
        p_t_err_rec_tab(l_n_cntr).check_cd := NULL;
        p_t_err_rec_tab(l_n_cntr).party_number := NULL;
        p_t_err_rec_tab(l_n_cntr).mapped_party_id := NULL;
        p_t_err_rec_tab(l_n_cntr).payer_name := NULL;
        p_t_err_rec_tab(l_n_cntr).credit_type_cd := NULL;
        p_t_err_rec_tab(l_n_cntr).mapped_credit_type_id := NULL;
        p_t_err_rec_tab(l_n_cntr).fee_cal_instance_cd := NULL;
        p_t_err_rec_tab(l_n_cntr).mapped_fee_cal_type := NULL;
        p_t_err_rec_tab(l_n_cntr).mapped_fee_ci_sequence_number := NULL;
        p_t_err_rec_tab(l_n_cntr).charge_cd1 := l_err_ro.charge_cd1;
        p_t_err_rec_tab(l_n_cntr).charge_cd2 := l_err_ro.charge_cd2;
        p_t_err_rec_tab(l_n_cntr).charge_cd3 := l_err_ro.charge_cd3;
        p_t_err_rec_tab(l_n_cntr).charge_cd4 := l_err_ro.charge_cd4;
        p_t_err_rec_tab(l_n_cntr).charge_cd5 := l_err_ro.charge_cd5;
        p_t_err_rec_tab(l_n_cntr).charge_cd6 := l_err_ro.charge_cd6;
        p_t_err_rec_tab(l_n_cntr).charge_cd7 := l_err_ro.charge_cd7;
        p_t_err_rec_tab(l_n_cntr).charge_cd8 := l_err_ro.charge_cd8;
        p_t_err_rec_tab(l_n_cntr).applied_amt1 := l_err_ro.applied_amt1;
        p_t_err_rec_tab(l_n_cntr).applied_amt2 := l_err_ro.applied_amt2;
        p_t_err_rec_tab(l_n_cntr).applied_amt3 := l_err_ro.applied_amt3;
        p_t_err_rec_tab(l_n_cntr).applied_amt4 := l_err_ro.applied_amt4;
        p_t_err_rec_tab(l_n_cntr).applied_amt5 := l_err_ro.applied_amt5;
        p_t_err_rec_tab(l_n_cntr).applied_amt6 := l_err_ro.applied_amt6;
        p_t_err_rec_tab(l_n_cntr).applied_amt7 := l_err_ro.applied_amt7;
        p_t_err_rec_tab(l_n_cntr).applied_amt8 := l_err_ro.applied_amt8;
        p_t_err_rec_tab(l_n_cntr).adm_application_id := NULL;
        p_t_err_rec_tab(l_n_cntr).credit_id := NULL;
        p_t_err_rec_tab(l_n_cntr).gl_date := NULL;
        p_t_err_rec_tab(l_n_cntr).source_transaction_type := NULL;
        p_t_err_rec_tab(l_n_cntr).eligible_to_apply_yn := NULL;
        p_t_err_rec_tab(l_n_cntr).receipt_number := NULL;
      END LOOP;
    END LOOP;

  END populate_err_rec;


  PROCEDURE import_interface_lockbox(errbuf            OUT NOCOPY VARCHAR2,
                                     retcode           OUT NOCOPY NUMBER,
                                     p_v_lockbox_name      VARCHAR2,
                                     p_d_gl_date           VARCHAR2,
                                     p_v_test_run          VARCHAR2) AS
    /******************************************************************
     Created By      :   Amit Gairola
     Date Created By :   12-Jun-2003
     Purpose         :   Main procedure for Concurrent Process

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
    l_d_gl_date         DATE;
    l_v_type1_status    VARCHAR2(1);
    l_b_prc_err         BOOLEAN := FALSE;
    e_resource_busy       EXCEPTION;

    PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
  BEGIN

-- Create a savepoint
    SAVEPOINT SP_LOCKBOX_MAIN;
    retcode := 0;

    l_d_gl_date := TRUNC(igs_ge_date.igsdate(p_d_gl_date));

-- Call the initialize procedure to initialize the global variables
-- and the PL/SQL tables
    initialize;

-- Validate the parameters. Incase of error exit
    IF NOT validate_parameters(p_v_lockbox_name,
                               l_d_gl_date,
                               p_v_test_run) THEN
      retcode := 2;
      RETURN;
    END IF;

-- Populate the Lockbox Interface PL/SQL table
    IF populate_lb_interface(p_v_lockbox_name) THEN
      update_lbint_status(g_v_error);
      g_n_retcode := 2;
      l_b_prc_err := TRUE;
    END IF;

-- If there have been no errors and there are records in the Lockbox Interface
-- PL/SQL table
    IF (NOT l_b_prc_err) AND g_b_rec_exists THEN

-- Call the procedure for type1 validations
      l_v_type1_status := validate_type1;

-- If the procedure returns an error, then the retcode is set to 2
-- and the interface records are set to Error
      IF (l_v_type1_status='E') THEN
        update_lbint_status(g_v_error);
        g_n_retcode := 2;
      ELSIF (l_v_type1_status='S') THEN
-- Else the interface records are set to Success
        update_lbint_status(g_v_success);
      END IF;

-- If type1 validations have been successful
      IF l_v_type1_status = 'S' THEN

-- Populate the Receipts PL/SQL table
        populate_lb_receipts;

-- Call the Type2 validations procedure
        valtype2_and_import_rects(p_t_lb_rec_tab      => g_t_rec_tab,
                                  p_v_test_run        => p_v_test_run,
                                  p_d_gl_date         => l_d_gl_date,
                                  p_v_invoked_from    => 'I');
      END IF;
    END IF;

    retcode := g_n_retcode;

-- If the test run is 'Y', then rollback all the transactions
    IF p_v_test_run = 'Y' THEN
      ROLLBACK TO SP_LOCKBOX_MAIN;

-- If records exist then log the message than the Records have been rolled back
      IF g_b_rec_exists THEN
        fnd_message.set_name('IGS',
                             'IGS_FI_PRC_TEST_RUN');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      ELSE

-- Else log no data found
        fnd_message.set_name('IGS',
                             'IGS_GE_NO_DATA_FOUND');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
    ELSE

-- If the test run is No and records exist, then commit
      IF g_b_rec_exists THEN
        COMMIT;
      ELSE
-- Elsif records do not exist, then log no data found
        fnd_message.set_name('IGS',
                             'IGS_GE_NO_DATA_FOUND');
        fnd_file.put_line(fnd_file.log,
                          fnd_message.get);
      END IF;
    END IF;

-- Clear the global PL/SQL tables
    g_t_rec_tab.DELETE;
    g_lb_int_tab.DELETE;
  EXCEPTION

-- Handle the Locking exception
    WHEN e_resource_busy THEN
      ROLLBACK TO SP_LOCKBOX_MAIN;
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.new_line(fnd_file.log);
    WHEN OTHERS THEN
-- Handling the When Others Condition
      retcode := 2;
      ROLLBACK TO SP_LOCKBOX_MAIN;
      fnd_message.set_name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get||' - '||sqlerrm);
  END import_interface_lockbox;

  PROCEDURE import_error_lockbox( errbuf                OUT NOCOPY VARCHAR2,
                                  retcode               OUT NOCOPY NUMBER,
                                  p_v_lockbox_name      IN  VARCHAR2,
                                  p_d_gl_date           IN  VARCHAR2,
                                  p_v_test_run          IN  VARCHAR2) AS
    /******************************************************************
     Created By      :   Shirish Tatikonda
     Date Created By :   12-Jun-2003
     Purpose         :   Main Procedure for Import Error Lockbox

     Known limitations,enhancements,remarks:
     Change History
     Who     When       What
    ***************************************************************** */
  l_d_gl_date          DATE;
  l_v_manage_account   igs_fi_control.manage_accounts%TYPE;
  l_v_message_name     fnd_new_messages.message_name%TYPE;
  l_t_err_rec_tab      lb_receipt_tab;
  l_n_record_count     NUMBER;
  e_resource_busy       EXCEPTION;

  PRAGMA EXCEPTION_INIT(e_resource_busy, -54);
  BEGIN
    -- Create a Savepoint
    SAVEPOINT SP_LOCKBOX_ERROR;
    retcode := 0;

    l_d_gl_date := igs_ge_date.igsdate(p_d_gl_date);
    -- Call initialize to set all the global variables.
    initialize;

    -- Log and Validate Parameters
    IF NOT validate_parameters(p_v_lockbox_name,
                               l_d_gl_date,
                               p_v_test_run) THEN
      retcode := 2;
      RETURN;
    END IF;

    -- Populate Receipt and Receipt Overflow records
    populate_err_rec( p_v_lockbox_name, l_t_err_rec_tab );
    -- Fetch the number of records found
    l_n_record_count := l_t_err_rec_tab.COUNT;

    -- Pass populated records for Type II validations
    IF l_n_record_count > 0 THEN
      valtype2_and_import_rects(p_t_lb_rec_tab      => l_t_err_rec_tab,
                                p_v_test_run        => p_v_test_run,
                                p_d_gl_date         => l_d_gl_date,
                                p_v_invoked_from    => 'E');
    END IF;

    retcode := g_n_retcode;

    IF( l_n_record_count > 0 ) THEN
      -- If Test Run is Y, log generic message saying that all transactions are rolled back
      IF( p_v_test_run = 'Y' ) THEN
        ROLLBACK TO SP_LOCKBOX_ERROR;
        fnd_message.set_name('IGS', 'IGS_FI_PRC_TEST_RUN');
        fnd_file.put_line(fnd_file.LOG, fnd_message.get);
      ELSE
        -- If Test Run is N, commit.
        COMMIT;
      END IF;
    ELSE
      -- If no records found for processing log the message saying so.
      fnd_message.set_name('IGS', 'IGS_GE_NO_DATA_FOUND');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get);
    END IF;

    l_t_err_rec_tab.DELETE;

  EXCEPTION
    -- Handle the Locking exception
    WHEN e_resource_busy THEN
      ROLLBACK TO SP_LOCKBOX_ERROR;
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,fnd_message.get());
      fnd_file.new_line(fnd_file.log);

    -- Handle Other Exceptions
    WHEN OTHERS THEN
      retcode := 2;
      ROLLBACK TO SP_LOCKBOX_ERROR;
      fnd_message.set_name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_file.put_line(fnd_file.LOG, fnd_message.get || ' - ' || SQLERRM);
  END import_error_lockbox;
END igs_fi_prc_lockbox;

/
