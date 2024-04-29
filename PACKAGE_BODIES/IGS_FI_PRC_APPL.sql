--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_APPL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_APPL" AS
/* $Header: IGSFI56B.pls 120.7 2006/05/25 10:02:57 akandreg ship $ */

/******************************************************************
Created By        : Vinay Chappidi
Date Created By   : 25-Apr-2001
Purpose           : This function is used when the user has not passed
                    any low date, returns the min effective date from the
                    credits table

Known limitations,
enhancements,
remarks            :
Change History
Who        When          What
akandreg  17-May-2006  Bug 5134636 - Modifications for locking the records
sapanigr  24-Feb-2006  Bug#5018036 - Cursor cur_person changed in mass_apply procedure (R12 SQL Repository tuning)
sapanigr  12-Feb-2006  Bug#5018036 - Modified  cursor cur_fund_auth in mass_apply procedure. (R12 SQL Repository tuning)
pathipat  04-Nov-2005  Bug 4634950 - Modified CUR_CREDITS in procedure mass_apply
sapanigr  20-Sep-2005  Enh#4228665. Modified CUR_CREDITS, CUR_HIERARCHIES and
                       code logic in mass_apply() function.
svuppala  07-JUL-2005  Enh 3392095 - Tution Waivers build
                       Modified CUR_CREDITS in mass_apply() function.
pathipat  23-Apr-2003  Enh 2831569 - Commercial Receivables build
                       Modified mass_apply() - added call to chk_manage_Account()
sarakshi  06-Mar-2003  Bug#2767522,added validation related to credit dates in mass_apply procedure
pathipat  21-Jan-2003  Bug: 2686680 - Modified mass_apply - changed error message logged
smadathi  9-Jan-2003   Bug 2722096. Modified procedures mass_apply and mass_application.
vvutukur  13-Dec-2002  Enh#2584741.Deposits Build. Modifications done in eff_max_date,eff_min_date,mass_apply.
smadathi  20-NOV-2002  Enh. Bug 2584986. Added new parameter GL Date to procedure mass_application
                       and mass_apply.Private function lookup_desc removed and usage replaced by
                       igs_fi_gen_gl.get_lkp_meaning function.
schodava   19-Sep-2002   Enh # 2564643 - Subaccount Removal
                         Modified procedures mass_application, mass_apply
agairola   23-May-2002   Added the procedure get_cal_details for the bug 2378182. Modified
                         the code in the procedure mass_apply
agairola    21-May-2002  Modified the procedure mass_apply for bug 2377976
vvutukur    26-apr-2002  Changed the case of fnd_file.put_line to lower and
                         used fnd_file.new_line instead of writing a null string by fnd_file.put_line.
                         bug#2326163.
vvutukur    22-APR-2002  Modified as part of bug#2326163 not to show ids in log file but
                         numbers and names.
smadathi    28-Feb-2002  Bug. 2238413. modified mass _application procedure.
sarakshi    27-Feb-2002   bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v
masehgal    17-Jan-2002   ENH # 2170429
                         Obsoletion of SPONSOR_CD from UPDATE_ROW Call to IGS_FI_INV_INT Tablehandler
msrinivi    13 aug,2001   bug 1882122: Take only ch_lns with err_acc ='N'
sykrishn    28-JAN       changes to mass application - sfcr020 - 2191470
******************************************************************/

--global variable to know whether Oracle Financials is Yes Or No in System Options form.
g_rec_installed     igs_fi_control.rec_installed%TYPE;
e_lock_exception                EXCEPTION;
PRAGMA                          EXCEPTION_INIT(e_lock_exception, -0054);
g_v_lock                        VARCHAR2(1);


FUNCTION eff_min_date RETURN DATE IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 25-Apr-2001
  Purpose           : This function is used when the user has not passed
                      any low date, returns the min effective date from the
                      credits table

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When         What
  vvutukur  13-Dec-2002 Enh#2584741.Modified cursor cur_min_date to exclude deposit transactions from Credits Table.
   ******************************************************************/

  CURSOR cur_min_date
  IS
  SELECT MIN(effective_date) min_date
  FROM igs_fi_credits a,
       igs_fi_cr_types b
  WHERE a.credit_type_id = b.credit_type_id
  AND   b.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT');

  l_min_date  cur_min_date%ROWTYPE;

  BEGIN
    OPEN cur_min_date;
    FETCH cur_min_date INTO l_min_date;
    CLOSE cur_min_date;

    RETURN(l_min_date.min_date);
  END eff_min_date;


FUNCTION eff_max_date RETURN DATE IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created By   : 25-Apr-2001
  Purpose           : This function is used when the user has not passed
                      any high date, returns the max effective date from the
                      credits table

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When        What
  vvutukur 13-Dec-2002 Enh#2584741.Modified cursor cur_max_date to exclude deposit transactions
                       from Credits Table.
   ******************************************************************/

  CURSOR cur_max_date
  IS
  SELECT MAX(effective_date) max_date
  FROM igs_fi_credits a,
       igs_fi_cr_types b
  WHERE a.credit_type_id = b.credit_type_id
  AND   b.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT');

  l_max_date  cur_max_date%ROWTYPE;

  BEGIN
    OPEN cur_max_date;
    FETCH cur_max_date INTO l_max_date;
    CLOSE cur_max_date;

    RETURN(l_max_date.max_date);
  END eff_max_date;

PROCEDURE apply_and_log_messages (
                 p_invoice_id              IN igs_fi_inv_int_all.invoice_id%TYPE,
                 p_credit_id               IN igs_fi_credits.credit_id%TYPE,
                 p_fee_type                IN igs_fi_inv_int_all.fee_type%TYPE,
                 p_fee_cal_type            IN igs_fi_inv_int_all.fee_cal_type%TYPE,
                 p_unapplied_amount        IN  OUT NOCOPY igs_fi_credits.unapplied_amount%TYPE,
                 p_orig_invoice_amount_due IN igs_fi_inv_int_all.invoice_amount_due%TYPE,
                 p_invoice_amount_due      IN  OUT NOCOPY igs_fi_inv_int_all.invoice_amount_due%TYPE,
                 p_amount_applied          IN igs_fi_applications.amount_applied%TYPE,
                 p_appl_hierarchy_id       IN igs_fi_applications.appl_hierarchy_id%TYPE,
                 P_counter                 IN OUT NOCOPY NUMBER ,
                 p_d_gl_date               IN DATE
                 ) IS
  /******************************************************************
  Created By        : sykrishn
  Date Created By   : 24-JAN-2001
  Purpose           : This procedure invokes the generic application process and logs appropriate messages
  Known limitations,
  enhancements,
  remarks            :Local Procedure
  Change History
  Who      When          What
  akandreg  17-May-2006  Bug 5134636: Removed commit for each application record
  smadathi  20-NOV-2002  Enh. Bug 2584986. Added new parameter GL Date to procedure. Added cursors
                         c_igs_fi_invln_int and c_igs_fi_credits to obtain the charge and credit
                         GL Dates.
  vvutukur 26-apr-2002   fnd_file.put_line is changed to lower case and fnd_file.new_line is used
                         instead of  writing null string by fnd_file.put_line.bug#2326163.
  vvutukur 22-apr-2002   Removed the code showing log horizontally. Modified to show numbers and
                         names in the log file instead of ids. bug#2326163.
  ****************************************************************/

  --added by vvutukur for bug 2326163
  CURSOR cur_invoice_number(cp_invoice_id igs_fi_inv_int.invoice_number%TYPE) IS
  SELECT invoice_number
  FROM   igs_fi_inv_int
  WHERE  invoice_id = cp_invoice_id;

  CURSOR c_igs_fi_invln_int(cp_n_invoice_id igs_fi_inv_int.invoice_id%TYPE) IS
  SELECT gl_date
  FROM   igs_fi_invln_int
  WHERE  invoice_id = cp_n_invoice_id;

  CURSOR c_igs_fi_credits(cp_n_credit_id igs_fi_credits.credit_id%TYPE) IS
  SELECT gl_date
  FROM   igs_fi_credits
  WHERE  credit_id = cp_n_credit_id;

  rec_c_igs_fi_invln_int c_igs_fi_invln_int%ROWTYPE;
  rec_c_igs_fi_credits   c_igs_fi_credits%ROWTYPE;

  l_invoice_number                igs_fi_inv_int.invoice_number%TYPE;
  l_dr_ccid_str                   VARCHAR2(230);
  l_cr_ccid_str                   VARCHAR2(230);

  l_msg_str_2                      VARCHAR2(2000);
  l_msg_str_3                      VARCHAR2(2000);
  l_v_app_error_message            fnd_new_messages.message_name%TYPE;
  l_n_application_id               igs_fi_applications.application_id%TYPE;
  l_v_dr_account_cd                igs_fi_applications.dr_account_cd%TYPE;
  l_v_cr_account_cd                igs_fi_applications.cr_account_cd%TYPE;
  l_n_cr_gl_ccid                   igs_fi_applications.cr_gl_code_ccid%TYPE;
  l_n_dr_gl_ccid                   igs_fi_applications.dr_gl_code_ccid%TYPE;
  l_b_status                       BOOLEAN :=  FALSE ;
  l_dummy_unapplied_amount         igs_fi_credits.unapplied_amount%TYPE;
  l_dummy_invoice_amount_due       igs_fi_inv_int_all.invoice_amount_due%TYPE;

BEGIN

  --added by vvutukur for bug#2326163
  OPEN cur_invoice_number(p_invoice_id);
  FETCH cur_invoice_number INTO l_invoice_number;
  CLOSE cur_invoice_number;

/* This procedure invokes the generic application process and logs appropriate messages  */

   /* Call the generic applications procedure to create applications */
   -- The call has been modified as part of enh. Bug 2584986 to pass p_validation
   -- parameter value as 'Y'
        igs_fi_gen_007.create_application(
                                           p_application_id =>l_n_application_id, --IN OUT NOCOPY param
                                           p_credit_id      =>p_credit_id,
                                           p_invoice_id     =>p_invoice_id,
                                           p_amount_apply   =>p_amount_applied,
                                           p_appl_type      =>'APP',
                                           p_appl_hierarchy_id => p_appl_hierarchy_id,
                                           p_validation     =>'Y',
                                           p_unapp_amount   => p_unapplied_amount,
                                           p_inv_amt_due    => p_invoice_amount_due,
                                           p_dr_gl_ccid     => l_n_dr_gl_ccid,
                                           p_cr_gl_ccid     => l_n_cr_gl_ccid,
                                           p_dr_account_cd  => l_v_dr_account_cd,
                                           p_cr_account_cd  => l_v_cr_account_cd,
                                           p_err_msg        => l_v_app_error_message,
                                           p_status         => l_b_status,
                                           p_d_gl_date      => TRUNC(p_d_gl_date)
                                           );
        IF l_b_status THEN
        /*Success **/
          -- if the  generic applications procedure to create application returns the message IGS_FI_CHG_CRD_GL_DATE
          -- log this message and proceed.
          IF l_v_app_error_message = 'IGS_FI_CHG_CRD_GL_DATE' THEN
            OPEN  c_igs_fi_invln_int(p_invoice_id);
            FETCH c_igs_fi_invln_int INTO rec_c_igs_fi_invln_int;
            CLOSE c_igs_fi_invln_int;

            OPEN   c_igs_fi_credits(p_credit_id);
            FETCH  c_igs_fi_credits INTO rec_c_igs_fi_credits;
            CLOSE  c_igs_fi_credits;

            fnd_message.set_name('IGS',l_v_app_error_message);
            fnd_message.set_token('GL_DATE',p_d_gl_date);
            fnd_message.set_token('CHG_GL_DATE',rec_c_igs_fi_invln_int.gl_date);
            fnd_message.set_token('CRD_GL_DATE',rec_c_igs_fi_credits.gl_date);
            fnd_file.put_line(fnd_file.log,fnd_message.Get);
          END IF;

          P_counter := NVL(P_counter,0) + 1;
          /** logging Invoice table details **/

          --added by vvutukur for bug# 2326163
          --populate the debit and credit accounts into local variables.
          IF g_rec_installed = 'Y' THEN
            l_dr_ccid_str := igs_fi_gen_007.get_ccid_concat(l_n_dr_gl_ccid);
            l_cr_ccid_str := igs_fi_gen_007.get_ccid_concat(l_n_cr_gl_ccid);
          ELSE
            l_dr_ccid_str := l_v_dr_account_cd;
            l_cr_ccid_str := l_v_cr_account_cd;
          END IF;

          --Show log for invoice and application details.
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','INVOICE_NUMBER')||' : '||l_invoice_number);
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPE')||' : '||p_fee_type);
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_CAL_TYPE')||' : '||p_fee_cal_type);
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','INVOICE_AMOUNT_DUE')||' : '||TO_CHAR(p_orig_invoice_amount_due));
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','INVOICE_AMOUNT_APPLIED')||' : '||NVL(TO_CHAR(p_invoice_amount_due),0));

          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','AMOUNT_APPLIED')||' : '||NVL(TO_CHAR(p_amount_applied),0));
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','DR_ACCOUNT')||' : '||l_dr_ccid_str);
          fnd_file.put_line(fnd_file.log,'        '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CR_ACCOUNT')||' : '||l_cr_ccid_str);
          fnd_file.new_line(fnd_file.log);

       ELSE
         /*Failure*/
         fnd_message.Set_Name('IGS',l_v_app_error_message);
         fnd_file.put_line(fnd_file.log,  fnd_message.Get);
         fnd_file.put_line(fnd_file.log,' ');
       END IF;

       EXCEPTION
         WHEN OTHERS THEN
         fnd_message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
         fnd_file.put_line(fnd_file.log, fnd_message.Get);
         RETURN;
END apply_and_log_messages;

PROCEDURE get_cal_details(p_fee_cal_type        igs_ca_inst.cal_type%TYPE,
                          p_fee_seq             igs_ca_inst.sequence_number%TYPE,
                          p_end_dt         OUT NOCOPY  igs_ca_inst.end_dt%TYPE,
                          p_message        OUT NOCOPY  fnd_new_messages.message_name%TYPE,
                          p_status         OUT NOCOPY  BOOLEAN) AS
  /******************************************************************
    Created By        : agairola
    Date Created By   : 23-May-2002
    Purpose           : This procedure fetches the End Date of the Load Calendar for the
                        Fee Calendar passed as input.
    Known limitations,
    enhancements,
    remarks            :Local Procedure
    Change History
    Who      When          What

  ****************************************************************/

  CURSOR cur_cal(cp_cal_type      igs_ca_inst.cal_type%TYPE,
                 cp_seq_num       igs_ca_inst.sequence_number%TYPE) IS
    SELECT end_dt
    FROM   igs_ca_inst
    WHERE  cal_type = cp_cal_type
    AND    sequence_number = cp_seq_num;

  l_load_cal_type   igs_ca_inst.cal_type%TYPE;
  l_load_seq        igs_ca_inst.sequence_number%TYPE;
  l_message_name    fnd_new_messages.message_name%TYPE;
  l_end_dt          igs_ca_inst.end_dt%TYPE;
BEGIN
  p_status := TRUE;

-- Call the API for getting the Load Calendar from the Fee Calendar
-- If the status is returned to FALSE, then make the p_status as FALSE
  IF NOT igs_fi_gen_001.finp_get_lfci_reln(p_cal_type   => p_fee_cal_type,
                                           p_ci_sequence_number => p_fee_seq,
                                           p_cal_category => 'FEE',
                                           p_ret_cal_type => l_load_cal_type,
                                           p_ret_ci_sequence_number => l_load_seq,
                                           p_message_name => l_message_name) THEN
    p_status := FALSE;
  ELSE

-- Else get the End Date of the Load Calendar
    OPEN cur_cal(l_load_cal_type,
                 l_load_seq);
    FETCH cur_cal INTO l_end_dt;
    IF cur_cal%NOTFOUND THEN
      p_status := FALSE;
    END IF;
    CLOSE cur_cal;
  END IF;

  IF NOT p_status THEN
    p_message := l_message_name;
    p_end_dt := NULL;
  ELSE
    p_message := NULL;
    p_end_dt        := l_end_dt;
  END IF;
END get_cal_details;

PROCEDURE mass_application ( errbuf           OUT NOCOPY  VARCHAR2,
                             retcode          OUT NOCOPY  NUMBER,
                             p_org_id              NUMBER,
                             p_person_id           igs_fi_inv_int_all.person_id%TYPE,
                             p_person_id_grp       igs_pe_prsid_grp_mem_all.group_id%TYPE,
                             p_credit_number       igs_fi_credits_all.credit_number%TYPE,
                             p_credit_type_id      igs_fi_credits_all.credit_type_id%TYPE,
                             p_credit_date_low     VARCHAR2,
                             p_credit_date_high    VARCHAR2,
                             p_d_gl_date           VARCHAR2
                             ) IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created      : 25-Apr-2001
  Purpose           : This procedure will apply all the unapplied amount
                      that is found in the credits table into the invoice
                      tables for the given person id, subaccount id and fee type
                      Records will be filtered depending on the parameters
                      that are passed into the procedure.

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who      When        What
  akandreg  17-May-2006  Bug 5134636: Added logic for setting the retcode
  sarakshi  05-Feb-2003  bug#2767532,modifed the outermost exception
  smadathi  9-Jan-2003   Bug 2722096. All the  exceptions raised by the mass_apply procedure
                         is masked and handled these in the user defined exception.
  smadathi  20-NOV-2002  Enh. Bug 2584986. Added new parameter GL Date to procedure mass_application
  schodava  19-Sep-2002  Enh # 2564643 - Subaccount Removal
                         Removed all references to subaccount.
  vvutukur 22-apr-2002  Populated rec_installed value into g_rec_installed for bug#2326163
  smadathi 28-Feb-2002  Bug. 2238413. The call to igs_fi_gen_005.finp_get_receivables_inst and
                                      logging of message is removed since this check has been moved
                                      to CREATE_APPLICATION procedure.
  vchappid 05-OCT-2001 As per Enh#2030448, Call to calculate balances process has been removed,
                       Balance_Flag column reference has been removed from updation of Credits,
                       Charges TBH's
                       Account GL codes assigned depending on the Accounting Method in case of
                       CR_GL_CODE_CCID, DR_GL_CODE_CCID

  sykrishn 26-JAN-2002  Enhancements due to SFCR020 - 2191470 -
   ******************************************************************/
    l_d_gl_date       igs_fi_applications.gl_date%TYPE ;
    l_err_exception   EXCEPTION;
  BEGIN

    retcode :=0;
    -- Set the Org Id
    igs_ge_gen_003.set_org_id(p_org_id);

    --Populate the rec_installed value into g_rec_installed to know whether Oracle Financials is
    --set to Yes or No in System Options Form.
    g_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;
    l_d_gl_date     :=  TRUNC(igs_ge_date.igsdate(p_d_gl_date)) ;

   -- the exceptions raised in the mass_apply is masked in the block so that
   -- the same can be captured and raised in the the user defined excpetion handler.
   -- in case of any un handled exception raised in mass apply procedure, this will not be
   -- captured in the user defined exception handler, but will be captured in the
   -- when others handler
   BEGIN
    g_v_lock := 'N';
    mass_apply(p_person_id                => p_person_id,
               p_person_id_grp            => p_person_id_grp,
               p_credit_number            => p_credit_number,
               p_credit_type_id           => p_credit_type_id,
               p_credit_date_low          => p_credit_date_low,
               p_credit_date_high         => p_credit_date_high,
               p_d_gl_date                => l_d_gl_date
               );
    IF g_v_lock = 'Y' THEN
    retcode := 1;
    END IF;
    COMMIT;


  EXCEPTION
    WHEN OTHERS THEN
      IF IGS_GE_MSG_STACK.COUNT_MSG <> 0 THEN
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        RAISE l_err_exception;
       ELSE
        RAISE;
      END IF;
  END ;

  EXCEPTION
    WHEN l_err_exception THEN
       retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      fnd_message.set_name('IGS','IGS_GE_UNHANDLED_EXCEPTION');
      errbuf := fnd_message.get;
      fnd_file.put_line(fnd_file.log,sqlerrm);
      IGS_GE_MSG_STACK.CONC_EXCEPTION_HNDL;
END mass_application;

PROCEDURE mass_apply(p_person_id           igs_fi_inv_int_all.person_id%TYPE,
                     p_person_id_grp       igs_pe_prsid_grp_mem_all.group_id%TYPE,
                     p_credit_number       igs_fi_credits_all.credit_number%TYPE,
                     p_credit_type_id      igs_fi_credits_all.credit_type_id%TYPE,
                     p_credit_date_low     VARCHAR2,
                     p_credit_date_high    VARCHAR2,
                     p_d_gl_date           DATE
                     ) IS
  /******************************************************************
  Created By        : Vinay Chappidi
  Date Created      : 25-Apr-2001
  Purpose           :

  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who        When         What
  akandreg   17-May-2006  Bug 5134636: Added code logic for locking and trapping the exception
  sapanigr  24-Feb-2006  Bug#5018036 - Cursor cur_person broken into three separate cursors: cur_person_group_id, cur_person_id, cur_all_person_id.
                         to resolve non mergable view.
  sapanigr  12-Feb-2006  Bug#5018036 - Cursor cur_fund_auth now uses base tables directly instead of igs_fi_parties_v. (R12 SQL Repository tuning)
  pathipat  04-Nov-2005  Bug 4634950 - Modified CUR_CREDITS - removed unwanted join with igs_fi_cr_types_all
  sapanigr  20-Sep-2005  Enh#4228665. Modified CUR_CREDITS to select APPL_HIERARCHY_ID also from table IGS_FI_CR_TYPES_ALL
                         Modified CUR_HIERARCHIES.
                         Modified code logic to pass APPL_HIERARCHY_ID from CUR_CREDITS to CUR_HIERARCHIES
  svuppala  07-JUL-2005  Enh 3392095 - Tution Waivers build
                         Modified CUR_CREDITS -- exclude credit class of 'Waiver'.
  pathipat  23-Apr-2003  Enh 2831569 - Commercial Receivables build
                         Added validation for manage_account - call to chk_manage_account()
  sarakshi  06-Mar-2003  Bug#2767522,added validation for checking credit date low cannot be greater than credit date high
  pathipat  21-Jan-2003  Bug: 2686680 - When person_id and person_id grp are both specified
                         changed the error message logged from IGS_FI_PRS_OR_PRSIDGRP to IGS_FI_NO_PERS_PGRP
  smadathi  9-Jan-2003   Bug 2722096. Removed the logging of person group id. Instead
                         used call to igs_fi_gen_005.finp_get_prsid_grp_code to
                         log person group code. Logging of the error message for invalid
                         parameters passed have been removed and same has been taken cared in mass_application procedure.
                         Moreover, call to igs_ge_msg_stack.add has been incorporated wherever explicit handling for
                         invalid parameter values have been done.
  vvutukur  13-Dec-2002  Enh#2584741.Modified cursor cur_credits to exclude deposit transactions while selecting
                         rows from Credits Table.
  smadathi  20-NOV-2002  Enh. Bug 2584986. Added new parameter GL Date to procedure mass_apply
  schodava  19-Sep-2002   Enh # 2564643 - Subaccount Removal
                          Removed all references to subaccount.
  agairola   23-May-2002  Modified the code for the bug 2378182
                          1. For the Charges being selected for the Fee Periods other than that of
                          the Fee Period of the Credit Record, the End Date of the Load Calendar
                          for the Fee Period of the Charge record should be less than or equal to
                          the End Date of the Load Calendar of the Credit Record's Fee Period.
  agairola   21-May-2002  Modified the cursor cur_charge_not_fp to include the OR condition
                          instead of the AND condition for the Fee Period- Bug No 2377976
  vvutukur  22-apr-2002   Modified code to show numbers and names in the log file instead of ids.
                          bug#2326163.(added cursors cur_subaccount_name,cur_credit_type).
  ******************************************************************/

  -- cursor for getting the person_id when person group id is passed
  CURSOR cur_person_group_id(cp_person_grp  igs_pe_prsid_grp_mem_all.group_id%TYPE)
  IS
  SELECT person_id
  FROM igs_pe_prsid_grp_mem
  WHERE group_id = cp_person_grp
  ORDER BY 1;

  -- cursor for getting the person_id when person id is passed
  CURSOR cur_person_id(cp_person_id  hz_parties.party_id%TYPE)
  IS
  SELECT party_id
  FROM   hz_parties
  WHERE party_id = cp_person_id
  ORDER BY 1;

  -- cursor for getting the person_id when neither of person id or
  -- person grp id is passed
  CURSOR cur_all_person_id
  IS
  SELECT DISTINCT party_id
  FROM igs_fi_credits
  WHERE unapplied_amount>0
  ORDER BY 1;

  -- cursor for getting all the positive unapplied amount depending on the
  -- parameters passed by the user --
  -- Those credits that have CHGADJ as credit type with credit class
  CURSOR cur_credits( cp_person_id  igs_fi_inv_int_all.person_id%TYPE,
                      cp_credit_date_low DATE,
                      cp_credit_date_high DATE)
  IS
  SELECT cr.rowid, cr.*,crt.credit_type_name,crt.appl_hierarchy_id
  FROM igs_fi_credits cr,igs_fi_cr_types crt
  WHERE
  (cr.party_id = cp_person_id OR (cp_person_id IS NULL)) AND
  (cr.credit_number = p_credit_number OR (p_credit_number IS NULL)) AND
  (cr.credit_type_id = p_credit_type_id OR (p_credit_type_id IS NULL)) AND
  (TRUNC(cr.effective_date) BETWEEN TRUNC(cp_credit_date_low) AND TRUNC(cp_credit_date_high)) AND
   cr.unapplied_amount > 0  AND
  cr.credit_type_id = crt.credit_type_id AND
  crt.credit_class NOT IN ('ENRDEPOSIT','OTHDEPOSIT','CHGADJ','WAIVER')
  ORDER BY party_id, effective_date
  FOR UPDATE NOWAIT;

  -- cursor for getting the application hierarchy id for the given credit type id
  --changed this cursor to sort by version number to get the latest  record.
  CURSOR cur_hierarchies(cp_appl_hierarchy_id  igs_fi_a_hierarchies.credit_type_id%TYPE)
  IS
  SELECT appl_hierarchy_id, hierarchy_name, effective_start_date, effective_end_date
  FROM igs_fi_a_hierarchies
  WHERE  appl_hierarchy_id = cp_appl_hierarchy_id
  ORDER by version_number desc;

  -- cursor for getting all the fee types ordered based on the rule sequence identified
  -- for the application hierarchy id
  CURSOR cur_app_rules(cp_appl_hierarchy_id  igs_fi_app_rules.appl_hierarchy_id%TYPE)
  IS
  SELECT rule_sequence, fee_type, enabled_flag
  FROM   igs_fi_app_rules_v
  WHERE  appl_hierarchy_id = cp_appl_hierarchy_id AND
         enabled_flag = 'Y'
  ORDER BY rule_sequence;

  -- cursor for getting all the fee types ordered based on the rule sequence identified
  -- for the application hierarchy id in the Additional Authorized tab
  CURSOR cur_adl_app_rules(cp_appl_hierarchy_id  igs_fi_app_rules.appl_hierarchy_id%TYPE)
  IS
  SELECT rule_sequence, fee_type, enabled_flag
  FROM   igs_fi_adl_app_rul_v
  WHERE  appl_hierarchy_id = cp_appl_hierarchy_id AND
         enabled_flag = 'Y'
  ORDER BY rule_sequence;

  -- cursor for getting all the charge records that can be applied for the
  -- various enabled fee types for a person for the fee period  (which do not have error account)
  CURSOR cur_charges(cp_fee_type      IN igs_fi_inv_int_all.fee_type%TYPE,
                     cp_person_id     IN igs_fi_inv_int_all.person_id%TYPE,
                     cp_fee_cal_type    IN   igs_fi_inv_int_all.fee_cal_type%TYPE,
                     cp_fee_ci_sequence_number  IN    igs_fi_inv_int_all.fee_ci_sequence_number%TYPE)
  IS
  SELECT rowid, inv.*
  FROM  igs_fi_inv_int inv
  WHERE person_id          = cp_person_id     AND
        fee_type           = cp_fee_type      AND
        fee_cal_type       = cp_fee_cal_type  AND
        fee_ci_sequence_number = cp_fee_ci_sequence_number AND
        invoice_amount_due > 0
        AND NOT EXISTS (SELECT 'X'
                        FROM igs_fi_invln_int
                        WHERE  invoice_id = inv.invoice_id
                        AND NVL(error_account,'N') =  'Y')
         ORDER BY invoice_creation_date
         FOR UPDATE NOWAIT;

  -- cursor for getting all the charges records that can be applied for
  -- various enabled fee types for a person NOT In the fee period  (which do not have error account)

  CURSOR cur_charges_not_fp(cp_fee_type       IN igs_fi_inv_int_all.fee_type%TYPE,
                            cp_person_id      IN igs_fi_inv_int_all.person_id%TYPE,
                            cp_fee_cal_type   IN   igs_fi_inv_int_all.fee_cal_type%TYPE,
                            cp_fee_ci_sequence_number  IN    igs_fi_inv_int_all.fee_ci_sequence_number%TYPE)
  IS
  SELECT rowid, inv.*
  FROM  igs_fi_inv_int inv
  WHERE person_id          = cp_person_id     AND
        fee_type           = cp_fee_type      AND
        (fee_cal_type       <> cp_fee_cal_type  OR
        fee_ci_sequence_number <> cp_fee_ci_sequence_number) AND
        invoice_amount_due > 0
        AND NOT EXISTS (SELECT 'X'
                        FROM igs_fi_invln_int
                        WHERE  invoice_id = inv.invoice_id
                        AND NVL(error_account,'N') =  'Y')
  ORDER BY invoice_creation_date
  FOR UPDATE NOWAIT;


  -- cursor for getting all the charges records that can be applied
  -- for various enabled fee types for a person across all the fee periods (which do not have error account)

  CURSOR cur_charges_normal (cp_fee_type       IN igs_fi_inv_int_all.fee_type%TYPE,
                             cp_person_id      IN igs_fi_inv_int_all.person_id%TYPE )
  IS
  SELECT rowid, inv.*
  FROM  igs_fi_inv_int inv
  WHERE person_id          = cp_person_id     AND
        fee_type           = cp_fee_type      AND
        invoice_amount_due > 0
        AND NOT EXISTS (SELECT 'X'
                        FROM igs_fi_invln_int
                        WHERE  invoice_id = inv.invoice_id
                        AND NVL(error_account,'N') =  'Y')
         ORDER BY invoice_creation_date
         FOR UPDATE NOWAIT;


   /* cursor for getting the title IV ind for the credit type id */
  CURSOR cur_title4_ind (cp_credit_type_id IN igs_fi_cr_types.credit_type_id%TYPE)
  IS
  SELECT title4_type_ind
  FROM   igs_fi_cr_types
  WHERE  credit_type_id = cp_credit_type_id;

   /* cursor for getting the funds authorization for the person_id */
  CURSOR cur_fund_auth (cp_person_id  IN igs_pe_person_v.person_id%TYPE)
  IS
SELECT pd.fund_authorization, p.party_number
  --bug:2238362, changed the view igs_pe_person_v to igs_fi_parties_v
  --bug:5018036, replaced igs_fi_person_v by base tables
FROM hz_parties p, igs_pe_hz_parties pd
WHERE p.party_id = cp_person_id
AND p.party_id = pd.party_id;

  --added by vvutukur

  CURSOR cur_credit_type (cp_credit_type_id igs_fi_cr_types.credit_type_id%TYPE) IS
  SELECT credit_type_name
  FROM   igs_fi_cr_types
  WHERE  credit_type_id = cp_credit_type_id;

  TYPE tab_party_rec IS TABLE OF hz_parties.party_id%TYPE INDEX BY BINARY_INTEGER;
  v_tab_party_rec tab_party_rec ;
  l_person_id        hz_parties.party_id%TYPE;

  l_person_number    igs_fi_parties_v.person_number%TYPE;
  l_credit_type_name igs_fi_cr_types.credit_type_name%TYPE;

  -- cursor rowtype variables
  l_credits                        cur_credits%ROWTYPE;
  l_hierarchies                    cur_hierarchies%ROWTYPE;
  l_app_rules                      cur_app_rules%ROWTYPE;
  l_charges                        cur_charges%ROWTYPE;
  l_title4_ind                     cur_title4_ind%ROWTYPE;
  l_fund_auth                      cur_fund_auth%ROWTYPE;
  l_adl_app_rules                  cur_adl_app_rules%ROWTYPE;
  l_charges_not_fp                 cur_charges_not_fp%ROWTYPE;
  l_charges_normal                 cur_charges_normal%ROWTYPE;
  -- table type variables
  l_charges_amount                 igs_fi_inv_int_all.invoice_amount_due%TYPE;
  l_credits_amount                 igs_fi_credits_all.unapplied_amount%TYPE;
  l_invoice_amount_due             igs_fi_inv_int_all.invoice_amount_due%TYPE;
  l_credits_unapplied_amount       igs_fi_credits_all.unapplied_amount%TYPE;
  l_applications_rowid             VARCHAR2(25); -- OUT NOCOPY parameter from the applications table Insert TBH
  l_rec_installed                  VARCHAR2(1);  -- variable captures the value returned from the
                                                 -- function which checks AR is installed or not
  l_credit_date_low                DATE; -- VARCHAR2 datatypes will be made DATE types
  l_credit_date_high               DATE;
  -- Boolean Flags
  l_b_f_period_missing             BOOLEAN := FALSE;
  -- Message Variables
   l_msg_str_0                     VARCHAR2(2000);
   l_msg_str_1                     VARCHAR2(2000);
   l_n_charges_app_count           NUMBER := 0;

   /** Below code is Addition due to SFCr020 - 2191470 */
  l_v_fund_auth_profile             VARCHAR2(1) := NVL(FND_PROFILE.VALUE('IGS_FI_FUND_AUTH'),'N');
   /** Profile value taken as N if not Set - hence used NVL */

  l_process_credit                  BOOLEAN;
  l_cur_cal_end_dt                  igs_ca_inst.end_dt%TYPE;
  l_fee_cal_end_dt                  igs_ca_inst.end_dt%TYPE;
  l_status                          BOOLEAN;
  l_message_name                    fnd_new_messages.message_name%TYPE;
  l_c_closing_status                gl_period_statuses.closing_status%TYPE;

  l_v_manage_acc      igs_fi_control_all.manage_accounts%TYPE  := NULL;
  l_v_message_name    fnd_new_messages.message_name%TYPE       := NULL;

  BEGIN

     --added by vvutukur for bug#2326163

     OPEN cur_credit_type(p_credit_type_id);
     FETCH cur_credit_type INTO l_credit_type_name;
     CLOSE cur_credit_type;

    /* Logging of Parameters of the procedure */

    /* Get the party number*/
    OPEN  cur_fund_auth(p_person_id);
    FETCH cur_fund_auth INTO l_fund_auth;
    CLOSE cur_fund_auth;

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PARTY'));
    fnd_message.set_token('PARM_VALUE', l_fund_auth.party_number);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PERSON_GROUP'));
    fnd_message.set_token('PARM_VALUE',igs_fi_gen_005.finp_get_prsid_grp_code(p_person_id_grp));
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_NUMBER'));
    fnd_message.set_token('PARM_VALUE', p_credit_number);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CREDIT_TYPE_NAME'));
    fnd_message.set_token('PARM_VALUE', l_credit_type_name);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX', 'CREDIT_DATE_LOW'));
    fnd_message.set_token('PARM_VALUE', p_credit_date_low);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_DATE_HIGH'));
    fnd_message.set_token('PARM_VALUE', p_credit_date_high);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);

    fnd_message.set_name('IGS','IGS_FI_GEN_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','GL_DATE'));
    fnd_message.set_token('PARM_VALUE', p_d_gl_date);
    fnd_file.put_line(fnd_file.log,  fnd_message.Get);


    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_v_message_name);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
    END IF;

    -- validate whether GL Date is provided by the user. If the user has not
    -- provided the GL Date parameter error out NOCOPY of the process

    IF  p_d_gl_date IS NULL THEN
      fnd_message.set_name('IGS','IGS_GE_INSUFFICIENT_PARAMETER');
       igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- Check if both person id and person group id is passed as parameters
    -- if both are passed then error is logged in the log file and returned
    IF (p_person_id IS NOT NULL AND p_person_id_grp IS NOT NULL) THEN
      fnd_message.Set_Name('IGS','IGS_FI_NO_PERS_PGRP');
       igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

   -- validate the GL Date parameter passed to the process
   -- This procedure returns the derived Closing status of the period in which the passed GL Date belongs to
       igs_fi_gen_gl.get_period_status_for_date (p_d_date               =>   p_d_gl_date,
                                                 p_v_closing_status     =>   l_c_closing_status,
                                                 p_v_message_name       =>   l_message_name
                                                );
     -- if the derived closing status is other than 'F' or 'O' , log the error and error out NOCOPY of the process
     IF l_c_closing_status IN ('C','N','W')
     THEN
       fnd_message.set_name('IGS','IGS_FI_INVALID_GL_DATE');
       fnd_message.set_token('GL_DATE',p_d_gl_date);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;
     IF l_c_closing_status IS NULL AND l_message_name IS NOT NULL
     THEN
       fnd_message.set_name('IGS',l_message_name);
       igs_ge_msg_stack.add;
       app_exception.raise_exception;
     END IF;

    -- Set the values of high and low dates when
    IF p_credit_date_low IS NOT NULL THEN
      l_credit_date_low := igs_ge_date.igsdate(p_credit_date_low);
    ELSE
      l_credit_date_low := eff_min_date();
    END IF;

    IF p_credit_date_high IS NOT NULL THEN
      l_credit_date_high := igs_ge_date.igsdate(p_credit_date_high);
    ELSE
      l_credit_date_high := eff_max_date();
    END IF;

    --If both credit date high and credit date low are specified then high date should be greater than or equal to low date
    IF p_credit_date_low IS NOT NULL AND p_credit_date_high IS NOT NULL THEN
      IF TRUNC(l_credit_date_low) > TRUNC(l_credit_date_high) THEN
        fnd_message.Set_Name('IGS','IGS_FI_TRAN_LOW_HIGH');
        fnd_message.set_token('DATE_LOW',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_DATE_LOW'));
        fnd_message.set_token('DATE_HIGH',igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_DATE_HIGH'));
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    /* Open person cursors to loop across the persons in context */

    IF p_person_id_grp IS NOT NULL THEN
       OPEN cur_person_group_id(p_person_id_grp);
       FETCH cur_person_group_id BULK COLLECT INTO v_tab_party_rec;
       CLOSE cur_person_group_id;
    ELSIF p_person_id IS NOT NULL THEN
       OPEN  cur_person_id(p_person_id);
       FETCH cur_person_id BULK COLLECT INTO v_tab_party_rec;
       CLOSE cur_person_id;
    ELSE
       OPEN  cur_all_person_id;
       FETCH cur_all_person_id BULK COLLECT INTO v_tab_party_rec;
       CLOSE cur_all_person_id;
    END IF;

    IF v_tab_party_rec.COUNT > 0 THEN
      -- Loop across all the Person ids identified for processing for Refunds
      FOR l_n_cntr IN v_tab_party_rec.FIRST..v_tab_party_rec.LAST
      LOOP
        l_person_id := v_tab_party_rec(l_n_cntr);
      BEGIN
          SAVEPOINT APPL_SP1;
           /* Get the value of funds authorization for the person  l_person_id */
          OPEN  cur_fund_auth(l_person_id);
          FETCH cur_fund_auth INTO l_fund_auth;
          CLOSE cur_fund_auth;

          -- Get all the unapplied credits that are to be applied depending on the parameters the user entered
          OPEN  cur_credits(l_person_id,l_credit_date_low,l_credit_date_high);
          LOOP
          FETCH cur_credits INTO l_credits;
          EXIT WHEN cur_credits%NOTFOUND;

          l_b_f_period_missing := FALSE;
          l_n_charges_app_count := 0;


           /* Get title 4 ind of the credit record */
             OPEN cur_title4_ind(l_credits.credit_type_id);
             FETCH cur_title4_ind INTO l_title4_ind;
             CLOSE cur_title4_ind;

          l_msg_str_0 := '----------------------------------------------------------------------------------------';

          fnd_file.put_line(fnd_file.log,l_msg_str_0);
          fnd_file.new_line(fnd_file.log);

          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PARTY')||' : '||l_fund_auth.party_number);
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_NUMBER')||' : '||l_credits.credit_number);
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','CREDIT_TYPE_NAME')||' : '||l_credits.credit_type_name);
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','UNAPPLIED_AMOUNT')||' : '||TO_CHAR(l_credits.unapplied_amount));
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','TITLE4_IND')||' : '||NVL(l_title4_ind.title4_type_ind,'N'));
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FUND_AUTH')||' : '||NVL(l_fund_auth.fund_authorization,'N'));
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_PERIOD')||' : '||l_credits.fee_cal_type||' '||TO_CHAR(l_credits.fee_ci_sequence_number));
          fnd_file.new_line(fnd_file.log);

          -- Capture the credits unapplied amount before the application to charges begin
          l_credits_unapplied_amount := l_credits.unapplied_amount;

          l_process_credit := TRUE;

-- If the Fee Period fields of the Credit Record are not null then
-- derive the End Date of the Load Calendar for the Fee Period.
          IF ((l_credits.fee_cal_type IS NOT NULL) AND
              (l_credits.fee_ci_sequence_number IS NOT NULL)) THEN
            get_cal_details(p_fee_cal_type       => l_credits.fee_cal_type,
                            p_fee_seq            => l_credits.fee_ci_sequence_number,
                            p_end_dt             => l_cur_cal_end_dt,
                            p_message            => l_message_name,
                            p_status             => l_status);
            IF NOT l_status THEN
              fnd_message.set_name('IGS',l_message_name);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
              l_process_credit := FALSE;
            END IF;
          END IF;

-- If the Credit has to be processed.
          IF l_process_credit THEN

           /* Get  the  latest (version Number) unique application hierarchy id from the application hierarchy table
             for the credit_type_id  */
              OPEN cur_hierarchies(l_credits.appl_hierarchy_id);
              FETCH cur_hierarchies INTO l_hierarchies;
              IF cur_hierarchies%NOTFOUND THEN
                fnd_message.set_name('IGS','IGS_FI_NO_APPL_HIER');
                fnd_message.set_token('CREDIT_ID',l_credits.credit_number);
                fnd_file.put_line(fnd_file.log,fnd_message.Get);
                fnd_file.new_line(fnd_file.log);
              END IF;
              CLOSE cur_hierarchies;

              l_msg_str_1 :=igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','APPL_HIER_NAME') || l_hierarchies.hierarchy_name;
              fnd_file.put_line(fnd_file.log,l_msg_str_1);
              fnd_file.new_line(fnd_file.log);

              /* Check if the IGS_FI_FUND_AUTH profile is set to Y */
              IF l_v_fund_auth_profile = 'Y' THEN
              /* Check if the credit is title 4 */
                IF NVL(l_title4_ind.title4_type_ind,'N') = 'Y' THEN
                /* For title 4 if credits fee period is null log error */
                  IF (l_credits.fee_cal_type IS NULL OR l_credits.fee_ci_sequence_number IS NULL)  THEN
                    l_b_f_period_missing := TRUE;
                    fnd_message.set_name('IGS','IGS_FI_FEEPERIOD_NULL');
                    fnd_message.set_token('CREDIT_ID', l_credits.credit_number );
                    fnd_file.put_line(fnd_file.log,'     '||fnd_message.Get);
                    fnd_file.new_line(fnd_file.log);
                  END IF;
                /* Proceed only if the fee period is present for Title IV Credits */
                  IF NOT l_b_f_period_missing  THEN
                  /* Check if the person has funds authorization */
                    IF NVL(l_fund_auth.fund_authorization,'N') = 'Y' THEN
                     /** This section is for profile Y , title4 Y and fund auth Y **/
                      fnd_file.put_line(fnd_file.log,'     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RULE_TYPE','ALLOW'));
                      OPEN cur_app_rules(l_hierarchies.appl_hierarchy_id); -- All Allowed rules
                      LOOP
                        FETCH cur_app_rules INTO l_app_rules;
                        EXIT WHEN ( cur_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);
                        l_msg_str_1 := '     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPES') || l_app_rules.fee_type ||','|| igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','RULE_SEQ') ||to_char( l_app_rules.rule_sequence);
                        fnd_file.put_line(fnd_file.log,l_msg_str_1);

                      -- Get the records from the charges table for a fee_type, person id and fee period
                        l_charges_amount := 0;
                        OPEN cur_charges(l_app_rules.fee_type,l_credits.party_id,l_credits.fee_cal_type,l_credits.fee_ci_sequence_number);
                        LOOP
                          FETCH cur_charges INTO l_charges;
                          EXIT WHEN (cur_charges%NOTFOUND OR l_credits_unapplied_amount = 0);
                          IF (l_credits_unapplied_amount >= l_charges.invoice_amount_due) THEN
                            l_charges_amount := l_charges.invoice_amount_due;
                            l_invoice_amount_due := 0;
                            l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges.invoice_amount_due;
                          ELSE
                            l_charges_amount := l_credits_unapplied_amount;
                            l_invoice_amount_due := l_charges.invoice_amount_due - l_credits_unapplied_amount;
                            l_credits_unapplied_amount := 0;
                          END IF;
                          /* If an eligible  charge is found then invoke application procedure */
                          apply_and_log_messages(
                                                  p_invoice_id      => l_charges.invoice_id,
                                                  p_credit_id       => l_credits.credit_id,
                                                  p_fee_type        => l_app_rules.fee_type,
                                                  p_fee_cal_type    => l_charges.fee_cal_type,
                                                  p_unapplied_amount=> l_credits_unapplied_amount,
                                                  p_orig_invoice_amount_due => l_charges.invoice_amount_due,
                                                  p_invoice_amount_due => l_invoice_amount_due,
                                                  p_amount_applied     => l_charges_amount,
                                                  p_appl_hierarchy_id  => l_hierarchies.appl_hierarchy_id,
                                                  P_counter            => l_n_charges_app_count,
                                                  p_d_gl_date          => p_d_gl_date
                                                 );
                        END LOOP;     -- Endloop for Charges for each app rule
                        CLOSE cur_charges;
                      END LOOP; -- Endloop for appl rules in Allowable
                      CLOSE cur_app_rules;

                    /**** If local varible unapplied amount is still left then proceed to pick up from Additional Authorized****/
                      IF l_credits_unapplied_amount > 0 THEN
                        fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RULE_TYPE','ADDITION'));
                        OPEN cur_adl_app_rules(l_hierarchies.appl_hierarchy_id);
                        LOOP
                          FETCH cur_adl_app_rules INTO l_adl_app_rules;
                          EXIT WHEN ( cur_adl_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);

                          l_msg_str_1 := '     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPES') || l_adl_app_rules.fee_type  ||
                                        ','|| igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','RULE_SEQ') ||to_char( l_adl_app_rules.rule_sequence);
                          fnd_file.put_line(fnd_file.log,l_msg_str_1);

                        -- Get the records from the charges table for a fee_type, person id and fee period
                          l_charges_amount := 0;
                          OPEN cur_charges(l_adl_app_rules.fee_type,l_credits.party_id,l_credits.fee_cal_type,l_credits.fee_ci_sequence_number);
                          LOOP
                            FETCH cur_charges INTO l_charges;
                            EXIT WHEN (cur_charges%NOTFOUND OR l_credits_unapplied_amount = 0);
                            IF (l_credits_unapplied_amount >= l_charges.invoice_amount_due) THEN
                              l_charges_amount := l_charges.invoice_amount_due;
                              l_invoice_amount_due := 0;
                              l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges.invoice_amount_due;
                            ELSE
                              l_charges_amount := l_credits_unapplied_amount;
                              l_invoice_amount_due := l_charges.invoice_amount_due - l_credits_unapplied_amount;
                              l_credits_unapplied_amount := 0;
                            END IF;

                          /* If an eligible  charge is found then invoke application procedure */

                          apply_and_log_messages(
                                                    p_invoice_id => l_charges.invoice_id,
                                                    p_credit_id => l_credits.credit_id,
                                                    p_fee_type => l_adl_app_rules.fee_type,
                                                    p_fee_cal_type => l_charges.fee_cal_type,
                                                    p_unapplied_amount => l_credits_unapplied_amount,
                                                    p_orig_invoice_amount_due => l_charges.invoice_amount_due,
                                                    p_invoice_amount_due => l_invoice_amount_due,
                                                    p_amount_applied  => l_charges_amount,
                                                    p_appl_hierarchy_id => l_hierarchies.appl_hierarchy_id,
                                                    P_counter  => l_n_charges_app_count,
                                                    p_d_gl_date  => p_d_gl_date
                                                    );
                          END LOOP;    -- Endloop for Charges for each adl app rule
                          CLOSE cur_charges;
                        END LOOP; -- Endloop for appl rules in Additional tab
                        CLOSE cur_adl_app_rules;
                      END IF; -- Unapplied amount

                    /**** If unapplied amount is still left then proceed to pick up from Allowed tab again****/
                      IF l_credits_unapplied_amount > 0 THEN
                        OPEN cur_app_rules(l_hierarchies.appl_hierarchy_id); -- All Allowed rules
                        LOOP
                          FETCH cur_app_rules INTO l_app_rules;
                          EXIT WHEN ( cur_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);

                        -- Get the records from the charges table for a fee_type, person id and NOT IN fee period
                          l_charges_amount := 0;
                          OPEN cur_charges_not_fp(l_app_rules.fee_type,l_credits.party_id,l_credits.fee_cal_type,l_credits.fee_ci_sequence_number);
                          LOOP
                            FETCH cur_charges_not_fp INTO l_charges_not_fp;
                            EXIT WHEN (cur_charges_not_fp%NOTFOUND OR l_credits_unapplied_amount = 0);
                            l_status := TRUE;
                            l_message_name := NULL;
                            l_fee_cal_end_dt := NULL;
                            get_cal_details(p_fee_cal_type       => l_charges_not_fp.fee_cal_type,
                                            p_fee_seq            => l_charges_not_fp.fee_ci_sequence_number,
                                            p_end_dt             => l_fee_cal_end_dt,
                                            p_message            => l_message_name,
                                            p_status             => l_status);

                            IF (TRUNC(l_fee_cal_end_dt) <= TRUNC(l_cur_cal_end_dt) AND l_status) THEN

                              IF (l_credits_unapplied_amount >= l_charges_not_fp.invoice_amount_due) THEN
                                  l_charges_amount := l_charges_not_fp.invoice_amount_due;
                                  l_invoice_amount_due := 0;
                                  l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges_not_fp.invoice_amount_due;
                              ELSE
                                l_charges_amount := l_credits_unapplied_amount;
                                l_invoice_amount_due := l_charges_not_fp.invoice_amount_due - l_credits_unapplied_amount;
                                l_credits_unapplied_amount := 0;
                              END IF;
                          /* If an eligible  charge is found then invoke application procedure */
                              apply_and_log_messages(
                                                      p_invoice_id => l_charges_not_fp.invoice_id,
                                                      p_credit_id => l_credits.credit_id,
                                                      p_fee_type => l_app_rules.fee_type,
                                                      p_fee_cal_type => l_charges_not_fp.fee_cal_type,
                                                      p_unapplied_amount => l_credits_unapplied_amount,
                                                      p_orig_invoice_amount_due => l_charges_not_fp.invoice_amount_due,
                                                      p_invoice_amount_due => l_invoice_amount_due,
                                                      p_amount_applied  => l_charges_amount,
                                                      p_appl_hierarchy_id => l_hierarchies.appl_hierarchy_id,
                                                      P_counter  => l_n_charges_app_count,
                                                       p_d_gl_date => p_d_gl_date
                                                      );
                            END IF; -- End if for End Dates
                          END LOOP;   -- Endloop for Charges for each adl app rule
                          CLOSE cur_charges_not_fp;
                        END LOOP; -- Endloop for appl rules in Additional tab
                        CLOSE cur_app_rules;
                      END IF; -- Unapplied amount

                    /**** If unapplied amount is still left then proceed to pick up from Allowed tab again****/
                      IF l_credits_unapplied_amount > 0 THEN
                        OPEN cur_adl_app_rules(l_hierarchies.appl_hierarchy_id);
                        LOOP
                        FETCH cur_adl_app_rules INTO l_adl_app_rules;
                        EXIT WHEN ( cur_adl_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);

                      -- Get the records from the charges table for a fee_type, person id and NOT IN fee period
                        l_charges_amount := 0;
                          OPEN cur_charges_not_fp(l_adl_app_rules.fee_type,l_credits.party_id,l_credits.fee_cal_type,l_credits.fee_ci_sequence_number);
                          LOOP
                          FETCH cur_charges_not_fp INTO l_charges_not_fp;
                          EXIT WHEN (cur_charges_not_fp%NOTFOUND OR l_credits_unapplied_amount = 0);
                          l_status := TRUE;
                          l_message_name := NULL;
                          l_fee_cal_end_dt := NULL;

                          get_cal_details(p_fee_cal_type       => l_charges_not_fp.fee_cal_type,
                                          p_fee_seq            => l_charges_not_fp.fee_ci_sequence_number,
                                          p_end_dt             => l_fee_cal_end_dt,
                                          p_message            => l_message_name,
                                          p_status             => l_status);

                          IF (TRUNC(l_fee_cal_end_dt) <= TRUNC(l_cur_cal_end_dt) AND l_status) THEN
                            IF (l_credits_unapplied_amount >= l_charges_not_fp.invoice_amount_due) THEN
                              l_charges_amount := l_charges_not_fp.invoice_amount_due;
                              l_invoice_amount_due := 0;
                              l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges_not_fp.invoice_amount_due;
                            ELSE
                              l_charges_amount := l_credits_unapplied_amount;
                              l_invoice_amount_due := l_charges_not_fp.invoice_amount_due - l_credits_unapplied_amount;
                              l_credits_unapplied_amount := 0;
                            END IF;

                          /* If an eligible  charge is found then invoke application procedure */
                            apply_and_log_messages(
                                                    p_invoice_id => l_charges_not_fp.invoice_id,
                                                    p_credit_id => l_credits.credit_id,
                                                    p_fee_type => l_adl_app_rules.fee_type,
                                                    p_fee_cal_type => l_charges_not_fp.fee_cal_type,
                                                    p_unapplied_amount => l_credits_unapplied_amount,
                                                    p_orig_invoice_amount_due => l_charges_not_fp.invoice_amount_due,
                                                    p_invoice_amount_due => l_invoice_amount_due,
                                                    p_amount_applied  => l_charges_amount,
                                                    p_appl_hierarchy_id => l_hierarchies.appl_hierarchy_id,
                                                    P_counter  => l_n_charges_app_count,
                                                    p_d_gl_date    => p_d_gl_date
                                                 );
                            END IF; -- End if for the End Date check
                          END LOOP;     -- Endloop for Charges for each adl app rule
                          CLOSE cur_charges_not_fp;
                        END LOOP; -- Endloop for appl rules in Additional tab
                        CLOSE cur_adl_app_rules;
                      END IF; -- Unapplied amount
                    ELSIF NVL(l_fund_auth.fund_authorization,'N') = 'N' THEN
                      /** This section is for profile Y , title4 Y and fund auth N **/
                      fnd_file.put_line(fnd_file.log,'     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RULE_TYPE','ALLOW'));
                      OPEN cur_app_rules(l_hierarchies.appl_hierarchy_id);
                      LOOP
                        FETCH cur_app_rules INTO l_app_rules;
                        EXIT WHEN ( cur_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);

                        l_msg_str_1 := '     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPES') || l_app_rules.fee_type
                                      ||','|| igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','RULE_SEQ') ||to_char( l_app_rules.rule_sequence);
                        fnd_file.put_line(fnd_file.log,l_msg_str_1);
                        -- Get the records from the charges table for a fee_type, person id for the fee period only
                        l_charges_amount := 0;
                        OPEN cur_charges(l_app_rules.fee_type,l_credits.party_id,l_credits.fee_cal_type,l_credits.fee_ci_sequence_number);
                        LOOP
                          FETCH cur_charges INTO l_charges;
                          EXIT WHEN (cur_charges%NOTFOUND OR l_credits_unapplied_amount = 0);
                          IF (l_credits_unapplied_amount >= l_charges.invoice_amount_due) THEN
                            l_charges_amount := l_charges.invoice_amount_due;
                            l_invoice_amount_due := 0;
                            l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges.invoice_amount_due;
                          ELSE
                            l_charges_amount := l_credits_unapplied_amount;
                            l_invoice_amount_due := l_charges.invoice_amount_due - l_credits_unapplied_amount;
                            l_credits_unapplied_amount := 0;
                          END IF;
                        /* If an eligible  charge is found then invoke application procedure */
                          apply_and_log_messages(
                                                  p_invoice_id => l_charges.invoice_id,
                                                  p_credit_id => l_credits.credit_id,
                                                  p_fee_type => l_app_rules.fee_type,
                                                  p_fee_cal_type => l_charges.fee_cal_type,
                                                  p_unapplied_amount => l_credits_unapplied_amount,
                                                  p_orig_invoice_amount_due => l_charges.invoice_amount_due,
                                                  p_invoice_amount_due => l_invoice_amount_due,
                                                  p_amount_applied  => l_charges_amount,
                                                  p_appl_hierarchy_id => l_hierarchies.appl_hierarchy_id,
                                                  P_counter  => l_n_charges_app_count,
                                                  p_d_gl_date          => p_d_gl_date
                                                  );
                        END LOOP;     -- Endloop for Charges for each app rule
                        CLOSE cur_charges;
                      END LOOP; -- Endloop for appl rules in Allowable
                      CLOSE cur_app_rules;
                    END IF; -- For fund Auth
                  END IF; -- For Fee Period Present
                END IF; --For title4 = 'Y'
              END IF; --For Profile = 'Y'
              IF (l_v_fund_auth_profile = 'N' OR NVL(l_title4_ind.title4_type_ind,'N') = 'N')   THEN
                fnd_file.put_line(fnd_file.log,'     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_RULE_TYPE','ALLOW'));
                OPEN cur_app_rules(l_hierarchies.appl_hierarchy_id); -- All Allowed rules
                LOOP
                  FETCH cur_app_rules INTO l_app_rules;
                  EXIT WHEN ( cur_app_rules%NOTFOUND OR l_credits_unapplied_amount = 0);

                  l_msg_str_1 := '     '||igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','FEE_TYPES') || l_app_rules.fee_type ||','|| igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','RULE_SEQ') ||to_char( l_app_rules.rule_sequence);
                  fnd_file.put_line(fnd_file.log,l_msg_str_1);

                  -- Get the records from the charges table for a fee_type, person id w/o considering  fee period at all - Fund Authorization also need not considered
                  l_charges_amount := 0;
                  OPEN cur_charges_normal(l_app_rules.fee_type,l_credits.party_id);
                  LOOP
                    FETCH cur_charges_normal INTO l_charges_normal;
                    EXIT WHEN (cur_charges_normal%NOTFOUND OR l_credits_unapplied_amount = 0);
                      IF (l_credits_unapplied_amount >= l_charges_normal.invoice_amount_due) THEN
                        l_charges_amount := l_charges_normal.invoice_amount_due;
                        l_invoice_amount_due := 0;
                        l_credits_unapplied_amount := l_credits_unapplied_amount - l_charges_normal.invoice_amount_due;
                      ELSE
                        l_charges_amount := l_credits_unapplied_amount;
                        l_invoice_amount_due := l_charges_normal.invoice_amount_due - l_credits_unapplied_amount;
                        l_credits_unapplied_amount := 0;
                      END IF;

                      /* If an eligible  charge is found then invoke application procedure */
                      apply_and_log_messages(
                                               p_invoice_id => l_charges_normal.invoice_id,
                                               p_credit_id => l_credits.credit_id,
                                               p_fee_type => l_app_rules.fee_type,
                                               p_fee_cal_type => l_charges_normal.fee_cal_type,
                                               p_unapplied_amount => l_credits_unapplied_amount,
                                               p_orig_invoice_amount_due => l_charges_normal.invoice_amount_due,
                                               p_invoice_amount_due => l_invoice_amount_due,
                                               p_amount_applied  => l_charges_amount,
                                               p_appl_hierarchy_id => l_hierarchies.appl_hierarchy_id,
                                               P_counter  => l_n_charges_app_count,
                                               p_d_gl_date          => p_d_gl_date
                                            );
                  END LOOP;    -- Endloop for Charges for each app rule
                  CLOSE cur_charges_normal;
                END LOOP; -- Endloop for appl rules in Allowable
                CLOSE cur_app_rules;
              END IF; --For Profile = 'Y' and title = N

            /* log message for " no eligible charge for application if the counter l_n_charges_app_count is Zero - no charges were found" */
              IF l_n_charges_app_count = 0 THEN
                fnd_message.set_name('IGS','IGS_FI_NO_ELIG_CHGAPP');
                fnd_message.set_token('PERSON_ID', l_fund_auth.party_number);
                fnd_message.set_token('CREDIT_ID', l_credits.credit_number);
                fnd_file.put_line(fnd_file.log,'     '||fnd_message.Get);
                fnd_file.new_line(fnd_file.log);
              END IF;
          END IF; -- For the l_process_credit
        END LOOP;
        CLOSE cur_credits;
      EXCEPTION
        WHEN e_lock_exception THEN
          ROLLBACK TO APPL_SP1;
          g_v_lock := 'Y';
          fnd_file.put_line(fnd_file.log,igs_fi_gen_gl.get_lkp_meaning('IGS_FI_LOCKBOX','PARTY')||' : '||l_fund_auth.party_number);
          fnd_message.set_name('IGS',
                               'IGS_FI_APPL_PRC_RUN');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
      END;
      END LOOP;
    END IF; -- End if of IF checking for v_tab_party_rec.COUNT > 0
  END mass_apply;

 -- end of package body
END igs_fi_prc_appl;

/
