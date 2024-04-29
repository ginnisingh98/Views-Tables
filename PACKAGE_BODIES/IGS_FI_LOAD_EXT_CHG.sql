--------------------------------------------------------
--  DDL for Package Body IGS_FI_LOAD_EXT_CHG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_LOAD_EXT_CHG" AS
/* $Header: IGSFI50B.pls 120.7 2006/05/16 04:17:18 akandreg ship $ */

  g_external          CONSTANT  VARCHAR2(20) := 'EXTERNAL';
  g_curr_desc         fnd_currencies_tl.name%TYPE;
  g_curr_cd           fnd_currencies_tl.currency_code%TYPE;

  /******************************************************************
  Created By         :Suraj Chakma
  Date Created By    :02-06-2000
  Purpose            :This procedure validates the data entered into
                      IGS_FI_EXT_INT_ALL Table. It is called from the
                      form IGSFI038.fmb - EXTERNAL CHARGES
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When          What
  akandreg  16-May-2006   Bug 5105131, modified cursor c_f_cal_typ. In function igs_fi_ext_val, the system defined
                          status (igs_ca_stat.S_CAL_STATUS) displayed on the Calendar Statuses form would be used in
                          the validation test instead of IGS_CA_INST.CAL_TYPE, which is user defined status.
  sapanigr  24-Feb-2006  Bug#5018036 - Replaced  cursor cur_person in igs_fi_extto_imp procedure by function call.
  sapanigr  12-Feb-2006  Bug#5018036 - Modified  cursor cur_person in igs_fi_extto_imp procedure. (R12 SQL Repository tuning)
  svuppala  09-AUG-2005   Enh 3392095 - Tution Waivers build
                          Impact of Charges API version Number change
                          Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  gurprsin  26-Jul-2005  Bug# 3392095.In IGS_FI_EXTTO_IMP procedure, Modified table habdler call igs_fi_prc_acct_pkg.build_accounts to
                         include waiver_name column parameter.
  bannamal  03-Jun-2005  Unit Level Fee Assessment Build. Modified the call to
                         igs_fi_prc_acct_pkg.build_accounts. Added new parameters.
  pmarada   29-Mar-2005  Bug 4270442, removed the cursor c_person instead of that calling
                         get_std_formerstd_ind function.
  pmarada   30-nov-2004  Bug 4003908, Added get_std_formerstd_ind funcation to return whether person is
                         of student and former student person type
  pmarada   16-Nov-2004  Bug 3902065, Added FORMER_STUDENT to the person types cursor to allow formaer students
  vvutukur  20-Jun-2003  Bug#2777502.Modified igs_fi_ext_val,igs_fi_extto_imp.
  vchappid  19-May-2003  Build Bug# 2831572, Financial Accounting Enhancements
                         New Parameters - Attendance Type, Attendance Mode, Residency Status Code
                         added in procedure igs_fi_extto_imp
  shtatiko  28-APR-2003  Enh# 2831569, Modified igs_fi_extto_imp.
  pathipat  07-Jan-2003  Bug: 2737666 - Modified igs_fi_extto_imp() - rearranged code.
  Sykrishn  31DEC2002    Bug 2682928 -- igs_fi_extto_imp Logging of parameters introduced
                         Also changed cur_person to point to IGS_FI_PARTIES_V
                         Also removed repetative loggin og fee_cal_type,start_dt and end_dt for each record in cur_fei loop as they
                         are fixed and are once  per process.
                         Used igs_ge_date.igschar(start_dt) ||'   '|| igs_ge_date.igschar(end_dt)
  SYKRISHn  30_DEC_2002  Bug 2727384 - Loggin details before validation errors are reported.
  pathipat 16-Nov-2002   Enh Bug 2584986
                         1.  Modified declaration of g_curr_desc to fnd_currencies_tl.name%TYPe from igs_fi_cur.description%TYPE
                         2.  Modified function igs_fi_Ext_val() - Added validation for gl_date, modified validations of currency_cd
                             Added parameter p_d_gl_date.
                         3.  Modified igs_fi_extto_imp - Removed insert_row into IGS_FI_IMP_CHGS and IGS_FI_IMGCHGS_LINES.
                             Added parameter p_d_gl_Date in call to create_charges() and charges_api call
                             Added call to igs_fi_prc_acct_pkg.build_accounts before calling charges_api
                         4.  Removed function lookup_Desc(). Used generic function igs_fi_gen_gl.get_lkp_meaning() instead.
  vvutukur 29-Jul-2002   Bug#2425767.Modified procedure igs_fi_extto_imp to remove the references to
                         chg_rate,chg_elements,transaction_type as these columns are obsolete.
  SYKRISHN 10_JUL_2002   Bug 2438874 - Procedure igs_fi_extto_imp modified to log Transaction Amount along with the other data elemets already present
                         Also Introduced currency descrption allong with the amount. - Log File looks imporoved - Hard coded english text remived
  sykrishn  03-JUL-220    Bug 2442163 - Procedure igs_fi_extto_imp modified to insert sysdate to
                          transaction_dt in the table igs_fi_impchgs_lines table
                          Reference to l_cur_fei.transaction_dt is removed as it will never be present.
                          Removed transaction_dt from igs_fi_ext_int_pkg.update_row

  smadathi  24-Jun-2002    Bug 2404720. Procedure igs_fi_extto_imp modified.
  jbegum    14-Jun-2002   BUG#2413574  Modified cursor cur_fei in procedure igs_fi_extto_imp.
  jbegum    12-Jun-2002   Bug#2403209 Removed code that calculated the transaction amount
                          as a product of Charge Rate and Charge Elements columns of IGS_FI_EXT_INT
                          table and inserted that value in the transaction amount column of the
                          IGS_FI_IMPCHGS_LINES table.
                          Now the transaction amount column value of IGS_FI_EXT_INT is directly
                          imported into the transaction amount column of the IGS_FI_IMPCHGS_LINES
                          table.
  agairola  04-Jun-2002  Bug 2395663 - Modified the TBH call for the IGS_FI_IMPCHGS_LINES_PKG
                         Added one function for validating the DFF
  SYKRISHn   22-MAY-2002  Bug 2385001 OSSTST15: TRANSACTION AND EFFECTIVE DATE IN EXTERNAL CHARGES FORM
                         Removed the validation for Transaction and Effective Date from the function
                         igs_fi_ext_val (Keeping the signature same for future use)
  SYKRISHN  19-APR-2002  Bug 2324088 - Introduced Desc Flex Field Validations and CCID validations.
  vchappid 12-APR-2001  Modified input parameters as per new Ancillary,External Charges DLD

   ******************************************************************/

  FUNCTION igs_fi_ext_val (p_person_id                 igs_fi_ext_int_all.person_id%TYPE,
                           p_fee_type                  igs_fi_ext_int_all.fee_type%TYPE,
                           p_fee_cal_type              igs_fi_ext_int_all.fee_cal_type%TYPE,
                           p_fee_ci_sequence_number    igs_fi_ext_int_all.fee_ci_sequence_number%TYPE,
                           p_transaction_dt            igs_fi_ext_int_all.effective_dt%TYPE ,
                           p_currency_cd               igs_fi_ext_int_all.currency_cd%TYPE,
                           p_effective_dt              igs_fi_ext_int_all.effective_dt%TYPE,
                           p_d_gl_date                 DATE,
                           p_message_name          OUT NOCOPY VARCHAR2)
                           RETURN BOOLEAN AS
  /***
  akandreg   16-May-2006  Bug 5105131, modified cursor c_f_cal_typ. In function igs_fi_ext_val, the system defined
                          status (igs_ca_stat.S_CAL_STATUS) displayed on the Calendar Statuses form would be used in
                          the validation test instead of IGS_CA_INST.CAL_TYPE, which is user defined status.
  pmarada    29-Mar-2005  Bug 4270442, removed the cursor c_person instead of that calling
                          get_std_formerstd_ind function.
  vvutukur   20-Jun-2003  Bug#2777502.Modified cursor c_fee_typ to exclude closed fee types.
  pathipat   16-Nov-2002  Enh Bug: 2584986 - Added parameter p_d_gl_Date and its validations
                          Modified validations for currency_cd
  SYKRISHn   22-MAY-2002  Bug 2385001 OSSTST15: TRANSACTION AND EFFECTIVE DATE IN EXTERNAL CHARGES FORM
                         Removed the validation for Transaction and Effective Date from the function
                         igs_fi_ext_val (Keeping the signature same for future use)
  SYKRISHN    03-JUL-2002  Bug 2442163
                         Definition of p_transaction_dt changed to Effective_dt%type - since transaction_dt is being made obsolete.

  ***/
    l_start_dt       igs_ca_inst.start_dt%TYPE;
    l_end_dt         igs_ca_inst.end_dt%TYPE;
    l_dummy          VARCHAR2(1);
    l_v_status       gl_period_statuses.closing_status%TYPE := NULL;
    l_message_name   fnd_new_messages.message_name%TYPE;

    CURSOR c_fee_typ
    IS
    SELECT 'x'
    FROM igs_fi_fee_type
    WHERE s_fee_type = 'EXTERNAL'
    AND fee_type     =  p_fee_type
    AND NVL(closed_ind,'N') = 'N';

    CURSOR c_f_cal_typ
    IS
    SELECT ci.start_dt,
           ci.end_dt
    FROM igs_ca_inst ci,
         igs_ca_type ct,
         igs_ca_stat st
    WHERE  ci.cal_type     = ct.cal_type
    AND ct.s_cal_cat       = 'FEE'
    AND ci.cal_status      = st.cal_status
    AND st.s_cal_status = 'ACTIVE'
    AND ci.cal_type        =  p_fee_cal_type
    AND ci.sequence_number =  p_fee_ci_sequence_number;

  BEGIN

     -- to validate person id
     -- check whether the person type of student or former student
    IF igs_fi_load_ext_chg.get_std_formerstd_ind(p_person_id) = 'N' THEN
       p_message_name :='IGS_FI_INVALID_PERSON_ID';
       RETURN FALSE;
    END IF;

    --to validate Fee Type
    OPEN c_fee_typ ;
    FETCH c_fee_typ INTO l_dummy;
    IF c_fee_typ%NOTFOUND THEN
      p_message_name :='IGS_FI_INVALID_FEE_TYPE';
      CLOSE c_fee_typ;
      RETURN FALSE;
    END IF;
    CLOSE c_fee_typ;

    --to validate Fee Cal type
    OPEN c_f_cal_typ ;
    FETCH c_f_cal_typ INTO l_start_dt, l_end_dt;
    IF c_f_cal_typ%NOTFOUND THEN
      p_message_name :='IGS_FI_INVALID_FEE_CAL_TYPE';
      CLOSE c_f_cal_typ;
      RETURN FALSE;
    END IF;
    CLOSE c_f_cal_typ;


    -- Modified as part of GL Interface build
    -- Validate if the currency_cd passed is same as the currency_cd in the System Options form
    -- So call function finp_get_cur which obtains the code and desc from igs_fi_control
    igs_fi_gen_gl.finp_get_cur( p_v_currency_cd  =>  g_curr_cd,
                                p_v_curr_desc    =>  g_curr_desc,
                                p_v_message_name =>  l_message_name
                              );
    IF l_message_name IS NULL THEN
      IF g_curr_cd <> p_currency_cd THEN
          p_message_name := 'IGS_FI_CUR_MISMATCH';
          RETURN FALSE;
      END IF;
    ELSE
      p_message_name := l_message_name;
      RETURN FALSE;
    END IF;


    -- to validate gl_Date to be in an open or future period
    -- added as part of Enh bug 2584986 - GL interface build
    IF p_d_gl_date IS NULL THEN
       p_message_name := 'IGS_FI_NO_GL_DATE';
       RETURN FALSE;
    END IF;

    igs_fi_gen_gl.get_period_status_for_date( p_d_date            => p_d_gl_date,
                                              p_v_closing_status  => l_v_status,
                                              p_v_message_name    => l_message_name
                                            );

    IF l_message_name IS NULL THEN
       IF l_v_status NOT IN ('O','F') THEN
          p_message_name := 'IGS_FI_INVALID_GL_DATE';
          RETURN FALSE;
       ELSE
          p_message_name := NULL;
          RETURN TRUE;
       END IF;
    ELSE
       p_message_name := l_message_name;
       RETURN FALSE;
    END IF;

  END igs_fi_ext_val;


FUNCTION validate_desc_flex
(
 p_attribute_category IN VARCHAR2,
 p_attribute1  IN VARCHAR2,
 p_attribute2  IN VARCHAR2,
 p_attribute3  IN VARCHAR2,
 p_attribute4  IN VARCHAR2,
 p_attribute5  IN VARCHAR2,
 p_attribute6  IN VARCHAR2,
 p_attribute7  IN VARCHAR2,
 p_attribute8  IN VARCHAR2,
 p_attribute9  IN VARCHAR2,
 p_attribute10  IN VARCHAR2,
 p_attribute11  IN VARCHAR2,
 p_attribute12  IN VARCHAR2,
 p_attribute13  IN VARCHAR2,
 p_attribute14  IN VARCHAR2,
 p_attribute15  IN VARCHAR2,
 p_attribute16  IN VARCHAR2,
 p_attribute17  IN VARCHAR2,
 p_attribute18  IN VARCHAR2,
 p_attribute19  IN VARCHAR2,
 p_attribute20  IN VARCHAR2,
 p_desc_flex_name IN VARCHAR2
) RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  agairola
  Date Created By:  04-Jun-2002
  Purpose        :  To validate the DFF. This has been created as the column names for the Attributes
                    of the DFF have names beginning with EXT_. This has been created for bug 2395663

  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */
        CURSOR app_cur IS
        SELECT
                application_short_name
        FROM
                fnd_application app, fnd_descriptive_flexs des
        WHERE
                app.application_id = des.application_id AND
                des.descriptive_flexfield_name = p_desc_flex_name;
        app_rec app_cur%ROWTYPE;
BEGIN
 fnd_flex_descval.clear_column_values;
 fnd_flex_descval.set_context_value(p_attribute_category);
 fnd_flex_descval.set_column_value('ATTRIBUTE1',p_attribute1);
 fnd_flex_descval.set_column_value('ATTRIBUTE2',p_attribute2);
 fnd_flex_descval.set_column_value('ATTRIBUTE3',p_attribute3);
 fnd_flex_descval.set_column_value('ATTRIBUTE4',p_attribute4);
 fnd_flex_descval.set_column_value('ATTRIBUTE5',p_attribute5);
 fnd_flex_descval.set_column_value('ATTRIBUTE6',p_attribute6);
 fnd_flex_descval.set_column_value('ATTRIBUTE7',p_attribute7);
 fnd_flex_descval.set_column_value('ATTRIBUTE8',p_attribute8);
 fnd_flex_descval.set_column_value('ATTRIBUTE9',p_attribute9);
 fnd_flex_descval.set_column_value('ATTRIBUTE10',p_attribute10);
 fnd_flex_descval.set_column_value('ATTRIBUTE11',p_attribute11);
 fnd_flex_descval.set_column_value('ATTRIBUTE12',p_attribute12);
 fnd_flex_descval.set_column_value('ATTRIBUTE13',p_attribute13);
 fnd_flex_descval.set_column_value('ATTRIBUTE14',p_attribute14);
 fnd_flex_descval.set_column_value('ATTRIBUTE15',p_attribute15);
 fnd_flex_descval.set_column_value('ATTRIBUTE16',p_attribute16);
 fnd_flex_descval.set_column_value('ATTRIBUTE17',p_attribute17);
 fnd_flex_descval.set_column_value('ATTRIBUTE18',p_attribute18);
 fnd_flex_descval.set_column_value('ATTRIBUTE19',p_attribute19);
 fnd_flex_descval.set_column_value('ATTRIBUTE20',p_attribute20);
 OPEN app_cur;
 FETCH app_cur INTO app_rec;
 CLOSE app_cur;
 IF (fnd_flex_descval.validate_desccols( app_rec.application_short_name, p_desc_flex_name, 'I',SYSDATE)) THEN
  RETURN TRUE;
 ELSE
  RETURN FALSE;
 END IF;
EXCEPTION
 WHEN OTHERS THEN
  IF app_cur%ISOPEN THEN
        CLOSE app_cur;
  END IF;
  RETURN FALSE;
END validate_desc_flex;


  PROCEDURE igs_fi_extto_imp(errbuf                  OUT NOCOPY  VARCHAR2,
                             retcode                 OUT NOCOPY  NUMBER,
                             p_org_id                     NUMBER,
                             p_person_id                  igs_fi_ext_int_all.person_id%TYPE ,
                             p_fee_type                   igs_fi_ext_int_all.fee_type%TYPE ,
                             p_fee_cal_type               igs_fi_ext_int_all.fee_cal_type%TYPE,
                             p_fee_ci_sequence_number     igs_fi_ext_int_all.fee_ci_sequence_number%TYPE
                             ) AS
 /******************************************************************
  Created By         :Suraj Chakma
  Date Created By    :02-06-2000
  Purpose            :This process is called by the concurrent manager
                      from concurrent program IGSFIJ21 to load data from
                      the IGS_FI_EXT_INT_ALL Table to the IGS_FI_IMP_CHGS_ALL
                      and IGS_FI_IMPCHGS_LINES Tables
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When         What
  sapanigr  24-Feb-2006  Bug#5018036 - Cursor cur_person replaced by call to function igs_fi_gen_008.get_party_number.
  sapanigr  12-Feb-2006  Bug#5018036 - Cursor cur_person now queries hz_parties instead of igs_fi_parties_v. (R12 SQL Repository tuning)
  svuppala  09-AUG-2005   Enh 3392095 - Tution Waivers build
                          Impact of Charges API version Number change
                          Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  gurprsin  26-Jul-2005  Bug# 3392095. Modified table habdler call igs_fi_prc_acct_pkg.build_accounts to include waiver_name column parameter.
  vvutukur  20-Jun-2003  Bug#2777502.Modified the code to concatenate all the error messages of interface record and update the newly added
                         error_msg column in interface table. Also cursor cur_fei is modified such that it picks up records with ERROR status
                         along with TODO status records.
  vchappid  19-May-2003  Build Bug# 2831572, Financial Accounting Enhancements
                         New Parameters - Attendance Type, Attendance Mode, Residency Status Code added
  shtatiko  28-APR-2003  Eng# 2831569, Added check for Manage Accounts System Option. If its
                         value is NULL then this process cannot be run.
  pathipat  07-Jan-2003  Bug:2737666 - Moved code for logging parameters to before calling
                         the validations. Moved code for incrementing record count to end of
                         procedure before doing a commit.
  Sykrishn  31DEC2002    Bug 2682928 -- igs_fi_extto_imp Logging of parameters introduced
                         Also changed cur_person to point to IGS_FI_PARTIES_V
                         Also removed repetative loggin og fee_cal_type,start_dt and end_dt for each record in cur_fei loop as they
                         are fixed and are once  per process.
                         Used igs_ge_date.igschar(start_dt) ||'   '|| igs_ge_date.igschar(end_dt)

  SYKRISHn  30_DEC_2002  Bug 2727384 - Loggin details before validation errors are reported.
  pathipat  15-NOV-2002  Enh# 2584986 - GL Interface build
                         1.  Removed insert_row into IGS_FI_IMP_CHGS and IGS_FI_IMPCHGS_LINES tables
                         2.  Added call to igs_fi_prc_acct_pkg.build_accounts before calling charges_api
                         3.  Added p_d_gl_date to be passed to charges_api, in p_line_tbl
                         4.  Added parameter p_d_gl_date in call to igs_fi_ext_val()
                         5.  DFF changed to IGS_FI_INVLN_INT_ALL_FLEX from IGS_FI_IMPCHGS_EXT_FLEX
                         6.  Removed cursor cur_imp_chgs and the associated local variables
  sarakshi 13-sep-2002   Enh#2564643,removed the reference of subaccount id from this procedure
 vvutukur  29-Jul-2002   Bug#2425767.removed parameters x_chg_rate,x_chg_elements from the calls to
                         igs_fi_impchgs_lines_pkg.insert_row and igs_fi_ext_int_pkg.update_row as these
                         columns are obsoleted.removed transaction_type from call to igs_fi_ext_int_pkg.update_row.
  SYKRISHN 10_JUL_2002   Bug 2438874 - Procedure igs_fi_extto_imp modified to log Transaction Amount along with
                         the other data elemets already present
                         Also Introduced currency descrption allong with the amount.
  sykrishn  03-JUL-220    Bug 2442163 - Procedure igs_fi_extto_imp modified to insert sysdate to
                          transaction_dt in the table igs_fi_impchgs_lines table
                          Reference to l_cur_fei.transaction_dt is removed as it will never be present.
                          Removed transaction_dt from igs_fi_ext_int_pkg.update_row
  smadathi  24-Jun-2002  Bug 2404720. The concatenated description comprising of fee desc
                         and transaction date which was initially passed as parameter to charges
                         API was modified to pass only fee type description.
  jbegum    14-Jun-2002  BUG#2413574 Modified the cursor cur_fei,by removing the and condition
                         "transaction_type = 'EXTERNAL'" from the where clause.
  agairola  04-Jun-2002  Bug 2395663 - Modified the TBH call for the IGS_FI_IMPCHGS_LINES_PKG
  SYKRISHN  19-APR-2002  Bug 2324088 - Introduced Desc Flex Field Validations and CCID validations.
  smadathi  27-Feb-2002  Bug 2238413. Reduced selection list for
                         rec installed flag to 'Y' and 'N'.Removed
                         reference of rec installed flag = 'E'.
  sarakshi  16-jan-2002  Remove the logic of fetching subaccount_id from igs_fi_f_typ_ca_inst,
                         now fetching using function igs_fi_gen_007.get_subaccount_id,also rectified hard coded
                         message logging in log file,  bug:2175865
  Syam      24-8-2000    Logic changes
  Schodava  4-12-2000    Removal of parameters Course_cd and Version_number
  vchappid  12-Apr-2001  Modified Logic as per new Ancillary,External Charges DLD
  ******************************************************************/

    l_ext_status        igs_fi_ext_int_all.status%TYPE;
    l_cst_success       CONSTANT igs_fi_ext_int_all.status%TYPE := 'SUCCESS';
    l_cst_error         CONSTANT igs_fi_ext_int_all.status%TYPE := 'ERROR';
    l_cst_todo          CONSTANT igs_fi_ext_int_all.status%TYPE := 'TODO';
    l_b_ext_val_flag    BOOLEAN ;

    -- New variable added by sykrishn to validate DFFs bug 2324088
    l_b_dff_validate      BOOLEAN ;
    -- Cursor for fetching records of TODO status
    CURSOR cur_fei (cp_person_id               igs_fi_ext_int.person_id%TYPE,
                    cp_fee_type                igs_fi_ext_int.fee_type%TYPE,
                    cp_fee_cal_type            igs_fi_ext_int.fee_cal_type%TYPE,
                    cp_fee_ci_sequence_number  igs_fi_ext_int.fee_ci_sequence_number%TYPE) IS
    SELECT *
    FROM igs_fi_ext_int
    WHERE (person_id             =  cp_person_id OR (cp_person_id IS NULL))
    AND   (fee_type              =  cp_fee_type OR  (cp_fee_type IS NULL))
    AND   fee_cal_type           =  cp_fee_cal_type
    AND   fee_ci_sequence_number =  cp_fee_ci_sequence_number
    AND   status                 IN (l_cst_error,l_cst_todo);


-- Variables added for the Charges API call
    l_header_rec                       igs_fi_charges_api_pvt.Header_Rec_Type;
    l_line_tbl                         igs_fi_charges_api_pvt.Line_Tbl_Type;
    l_line_id_tbl                      igs_fi_charges_api_pvt.Line_Id_Tbl_Type;
    l_invoice_id                       igs_fi_inv_int.invoice_id%TYPE;
    l_v_return_status                  VARCHAR2(1);
    l_n_msg_count                      NUMBER(3);
    l_v_msg_data                       VARCHAR2(2000);
    l_v_fee_desc                       VARCHAR2(100);
    l_cur_fei                          cur_fei%ROWTYPE;      -- Interface Table Row Type Variable
    l_v_rec_installed                  VARCHAR2(1); -- To find which type of Accounts receivables are installed at client side
    l_override_dr_rec_account_cd       igs_fi_ext_int.override_dr_rec_account_cd%TYPE;
    l_override_cr_rev_account_cd       igs_fi_ext_int.override_cr_rev_account_cd%TYPE;
    l_override_dr_rec_ccid             igs_fi_ext_int.override_dr_rec_ccid%TYPE;
    l_override_cr_rev_ccid             igs_fi_ext_int.override_cr_rev_ccid%TYPE;
    l_transaction_amount               igs_fi_ext_int.transaction_amount%TYPE;

    l_error_message                    fnd_new_messages.message_name%TYPE;
    l_n_err_type                       NUMBER;
    l_v_err_string                     igs_fi_invln_int.error_string%TYPE;
    l_b_return_status                  BOOLEAN;

    CURSOR cur_fee_desc(cp_fee_type    igs_fi_fee_type.fee_type%TYPE)  IS
      SELECT description
      FROM   igs_fi_fee_type
      WHERE  fee_type = cp_fee_type;

    l_n_record_count                   PLS_INTEGER :=0;
    l_b_flag                           BOOLEAN := TRUE;

    l_person_number       hz_parties.party_number%TYPE;

    CURSOR cur_fee_period(cp_cal_type  igs_ca_inst.cal_type%TYPE,cp_sequence_number  igs_ca_inst.sequence_number%TYPE) IS
      SELECT igs_ge_date.igschar(start_dt) ||'   '|| igs_ge_date.igschar(end_dt) string
      FROM   igs_ca_inst
      WHERE  cal_type=cp_cal_type
      AND    sequence_number=cp_sequence_number;

    l_cur_fee_period      cur_fee_period%ROWTYPE;
    l_v_message_name      fnd_new_messages.message_name%TYPE;
    l_v_manage_accounts   igs_fi_control.manage_accounts%TYPE;
    l_exception           EXCEPTION;

    l_v_msg         fnd_new_messages.message_text%TYPE;
    l_b_valid_ccid  BOOLEAN;

    l_n_waiver_amount NUMBER;

  BEGIN

    -- Set the Org Id
    igs_ge_gen_003.Set_Org_Id(p_org_id);

    -- SYKRISHN -- Bug 2682928 -- Logging of parameters introduced.. 31DEC2002
    IF p_person_id IS NOT NULL THEN
      l_person_number := igs_fi_gen_008.get_party_number(p_person_id);
    END IF;

    OPEN cur_fee_period(p_fee_cal_type,p_fee_ci_sequence_number);
    FETCH  cur_fee_period INTO l_cur_fee_period;
    CLOSE cur_fee_period;

    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
    fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'PERSON')   );
    fnd_message.set_token('PARM_CODE',l_person_number);
    fnd_file.put_line(fnd_file.log,fnd_message.get);


    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'FEE_TYPE')  );
    fnd_message.set_token('PARM_CODE',p_fee_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'FEE_CAL_TYPE')    );
    fnd_message.set_token('PARM_CODE',p_fee_cal_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'FEE_PERIOD')      );
    fnd_message.set_token('PARM_CODE',l_cur_fee_period.string);
    fnd_file.put_line(fnd_file.log,fnd_message.get);
    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));

    -- Get the value of "Manage Accounts" System Option value.
    -- If this value is NULL then this process should error out.
    igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc   => l_v_manage_accounts,
                                                  p_v_message_name => l_v_message_name );
    IF l_v_manage_accounts IS NULL THEN
      fnd_message.set_name ( 'IGS', l_v_message_name );
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exception;
    END IF;

    OPEN cur_fei ( p_person_id,
                   p_fee_type,
                   p_fee_cal_type,
                   p_fee_ci_sequence_number);
    LOOP
    FETCH cur_fei INTO l_cur_fei;
    EXIT WHEN cur_fei%NOTFOUND;

      l_b_ext_val_flag := TRUE;
      l_cur_fei.error_msg := NULL;

    -- Removed incrementing of record count from here to end of loop
    -- Increment to be done only on successful import for the particular record
    -- (pathipat) as part of bug 2737666

      l_person_number := igs_fi_gen_008.get_party_number(l_cur_fei.person_id);

      fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));
      -- Checking which Account Receivables is installed at the client side and insert into corresponding columns accordingly
      l_v_rec_installed := igs_fi_gen_005.finp_get_receivables_inst;

      IF l_v_rec_installed = 'Y' THEN
        l_override_dr_rec_account_cd := NULL;
        l_override_cr_rev_account_cd := NULL;
        l_override_dr_rec_ccid       := l_cur_fei.override_dr_rec_ccid;
        l_override_cr_rev_ccid       := l_cur_fei.override_cr_rev_ccid;
      ELSE
        l_override_dr_rec_account_cd := l_cur_fei.override_dr_rec_account_cd;
        l_override_cr_rev_account_cd := l_cur_fei.override_cr_rev_account_cd;
        l_override_dr_rec_ccid       := NULL;
        l_override_cr_rev_ccid       := NULL;
      END IF;

      l_b_valid_ccid := TRUE;

      -- resetting global variable to set before it gets assigned for every record
      g_curr_desc := NULL;
      g_curr_cd   := NULL;


      -- Following code for logging details moved here, before validations begin
      -- by pathipat for bug 2737666

      -- (pathipat) Removed code inserting record into IGS_FI_IMP_CHGS and IGS_FI_IMPCHGS_LINES
      -- as part of enh bug 2584986

      l_transaction_amount := l_cur_fei.transaction_amount;

      --  Used generic function to get lookup description, removed lookup_desc() function

      fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
      fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                        p_v_lookup_code => 'PERSON'));
      fnd_message.set_token('PARM_CODE', l_person_number);
      fnd_file.put_line(fnd_file.log, fnd_message.get);

      fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
      fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                        p_v_lookup_code => 'FEE_TYPE'));
      fnd_message.set_token('PARM_CODE', l_cur_fei.fee_type);
      fnd_file.put_line(fnd_file.log,  fnd_message.get);

      fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
      fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                        p_v_lookup_code => 'AMOUNT'));
      fnd_message.set_token('PARM_CODE', l_transaction_amount);
      fnd_file.put_line(fnd_file.log,  fnd_message.get);

      fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
      fnd_message.set_token('PARM_TYPE', igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                        p_v_lookup_code => 'CURRENCY'));
      -- Also changed  to display currency code instead of description top accomodate error currency code also.
      fnd_message.set_token('PARM_CODE', l_cur_fei.currency_cd);
      fnd_file.put_line(fnd_file.log,  fnd_message.get);
      fnd_file.new_line(fnd_file.log);

      -- Checking all Validations returns TRUE if all validations are passed else FALSE is returned
      l_b_ext_val_flag :=  igs_fi_load_ext_chg.igs_fi_ext_val(  p_person_id               => l_cur_fei.person_id,
                                                                p_fee_type                => l_cur_fei.fee_type,
                                                                p_fee_cal_type            => l_cur_fei.fee_cal_type,
                                                                p_fee_ci_sequence_number  => l_cur_fei.fee_ci_sequence_number,
                                                                p_transaction_dt          => SYSDATE,
                                                                p_currency_cd             => l_cur_fei.currency_cd,
                                                                p_d_gl_date               => l_cur_fei.gl_date,
                                                                p_message_name            => l_error_message);
      IF NOT l_b_ext_val_flag THEN
        IF l_error_message = 'IGS_FI_CUR_MISMATCH' THEN
          fnd_message.set_name('IGS', l_error_message);
          fnd_message.set_token('CUR1',l_cur_fei.currency_cd);
          fnd_message.set_token('CUR2',g_curr_cd);
        ELSIF l_error_message = 'IGS_FI_INVALID_GL_DATE' THEN
          fnd_message.set_name('IGS', l_error_message);
          fnd_message.set_token('GL_DATE',l_cur_fei.gl_date);
        ELSE
          fnd_message.set_name('IGS', l_error_message);
        END IF;

        l_v_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log,l_v_msg);
        l_cur_fei.error_msg := l_v_msg;
      END IF;

      -- Enh bug 2584986 Changed DFF name from IGS_FI_IMPCHGS_EXT_INT to IGS_FI_INVLN_INT_ALL_FLEX
      l_b_dff_validate := validate_desc_flex ( p_attribute_category => l_cur_fei.attribute_category,
                                               p_attribute1         => l_cur_fei.attribute1,
                                               p_attribute2         => l_cur_fei.attribute2,
                                               p_attribute3         => l_cur_fei.attribute3,
                                               p_attribute4         => l_cur_fei.attribute4,
                                               p_attribute5         => l_cur_fei.attribute5,
                                               p_attribute6         => l_cur_fei.attribute6,
                                               p_attribute7         => l_cur_fei.attribute7,
                                               p_attribute8         => l_cur_fei.attribute8,
                                               p_attribute9         => l_cur_fei.attribute9,
                                               p_attribute10        => l_cur_fei.attribute10,
                                               p_attribute11        => l_cur_fei.attribute11,
                                               p_attribute12        => l_cur_fei.attribute12,
                                               p_attribute13        => l_cur_fei.attribute13,
                                               p_attribute14        => l_cur_fei.attribute14,
                                               p_attribute15        => l_cur_fei.attribute15,
                                               p_attribute16        => l_cur_fei.attribute16,
                                               p_attribute17        => l_cur_fei.attribute17,
                                               p_attribute18        => l_cur_fei.attribute18,
                                               p_attribute19        => l_cur_fei.attribute19,
                                               p_attribute20        => l_cur_fei.attribute20,
                                               p_desc_flex_name     => 'IGS_FI_INVLN_INT_ALL_FLEX'
                                              );
      IF NOT l_b_dff_validate THEN
        l_b_ext_val_flag  :=  FALSE;
        fnd_message.set_name('IGS','IGS_AD_INVALID_DESC_FLEX');
        l_v_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log,l_v_msg);
        l_cur_fei.error_msg := l_cur_fei.error_msg||'.'||l_v_msg;
      END IF;

 -- If the above validations are successful we want to check if the Code Combination ID CCIDs are valid
 -- If CCIDs are invalid then sets l_b_ext_val_flag to FALSE so that no further processing happens
      IF l_override_dr_rec_ccid IS NOT NULL THEN
        IF NOT igs_fi_gen_002.finp_validate_ccid (l_override_dr_rec_ccid) THEN
          l_b_valid_ccid := FALSE;
        END IF;
      ELSIF l_override_cr_rev_ccid IS NOT NULL THEN
        IF NOT igs_fi_gen_002.finp_validate_ccid (l_override_cr_rev_ccid) THEN
          l_b_valid_ccid := FALSE;
        END IF;
      END IF;

      IF NOT l_b_valid_ccid THEN
        l_b_ext_val_flag  :=  FALSE;
        fnd_message.set_name('IGS','IGS_FI_INVALID_CCID');
        l_v_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log,l_v_msg);
        l_cur_fei.error_msg := l_cur_fei.error_msg||'.'||l_v_msg;
      END IF;

      IF l_b_ext_val_flag THEN
        igs_fi_prc_acct_pkg.build_accounts( p_fee_type                =>  l_cur_fei.fee_type,
                                            p_fee_cal_type            =>  l_cur_fei.fee_cal_type,
                                            p_fee_ci_sequence_number  =>  l_cur_fei.fee_ci_sequence_number,
                                            p_course_cd               =>  NULL,
                                            p_course_version_number   =>  NULL,
                                            p_org_unit_cd             =>  NULL,
                                            p_org_start_dt            =>  NULL,
                                            p_unit_cd                 =>  NULL,
                                            p_unit_version_number     =>  NULL,
                                            p_uoo_id                  =>  NULL,
                                            p_location_cd             =>  NULL,
                                            p_transaction_type        =>  'CHARGE',
                                            p_credit_type_id          =>  NULL,
                                            p_source_transaction_id   =>  NULL,
                                            x_dr_gl_ccid              =>  l_override_dr_rec_ccid,
                                            x_cr_gl_ccid              =>  l_override_cr_rev_ccid,
                                            x_dr_account_cd           =>  l_override_dr_rec_account_cd,
                                            x_cr_account_cd           =>  l_override_cr_rev_account_cd,
                                            x_err_type                =>  l_n_err_type,
                                            x_err_string              =>  l_v_err_string,
                                            x_ret_status              =>  l_b_return_status,
                                            p_v_attendance_type       =>  NULL,
                                            p_v_attendance_mode       =>  NULL,
                                            p_v_residency_status_cd   =>  NULL,
                                            p_n_unit_type_id          =>  NULL,
                                            p_v_unit_class            =>  NULL,
                                            p_v_unit_mode             =>  NULL,
                                            p_v_unit_level            =>  NULL,
                                            p_v_waiver_name           =>  NULL
                                           );
        IF (NOT l_b_return_status) OR (l_n_err_type IS NOT NULL) THEN
          l_b_ext_val_flag := FALSE;

          -- Error from build_accounts procedure
          -- Build Accounts Process will return error message name when the error type is 1
          -- Will return message string when the error type is greater than 1
          IF (l_v_err_string IS NOT NULL) THEN
            IF (l_n_err_type = 1) THEN
              fnd_message.set_name('IGS',l_v_err_string);
              l_v_msg := fnd_message.get;
              fnd_file.put_line(fnd_file.log,l_v_msg);
              l_cur_fei.error_msg := l_v_msg;
            ELSE
              fnd_file.put_line(fnd_file.log, l_v_err_string);
              l_cur_fei.error_msg := l_v_err_string;
            END IF;
          END IF;
        END IF;
      END IF;

      --If all the above validations are passed, then only charges api is called.
      IF l_b_ext_val_flag THEN

        OPEN cur_fee_desc(l_cur_fei.fee_type);
        FETCH cur_fee_desc INTO l_v_fee_desc;
        CLOSE cur_fee_desc;

        l_header_rec.p_person_id                     := l_cur_fei.person_id;
        l_header_rec.p_fee_cal_type                  := l_cur_fei.fee_cal_type;
        l_header_rec.p_fee_ci_sequence_number        := l_cur_fei.fee_ci_sequence_number;
        l_header_rec.p_fee_type                      := l_cur_fei.fee_type;
        l_header_rec.p_invoice_amount                := l_transaction_amount;
        l_header_rec.p_invoice_creation_date         := SYSDATE;
        l_header_rec.p_invoice_desc                  := l_v_fee_desc;
        l_header_rec.p_transaction_type              := g_external;
        l_header_rec.p_currency_cd                   := l_cur_fei.currency_cd;
        l_header_rec.p_exchange_rate                 := 1 ; -- Exchange rate passed as 1 in invoking charges_api
        l_header_rec.p_effective_date                := NVL(l_cur_fei.effective_dt,SYSDATE);

        l_line_tbl(1).p_description                  := l_v_fee_desc;
        l_line_tbl(1).p_amount                       := l_transaction_amount;

        l_line_tbl(1).p_attribute_category           := l_cur_fei.attribute_category;
        l_line_tbl(1).p_attribute1                   := l_cur_fei.attribute1;
        l_line_tbl(1).p_attribute2                   := l_cur_fei.attribute2;
        l_line_tbl(1).p_attribute3                   := l_cur_fei.attribute3;
        l_line_tbl(1).p_attribute4                   := l_cur_fei.attribute4;
        l_line_tbl(1).p_attribute5                   := l_cur_fei.attribute5;
        l_line_tbl(1).p_attribute6                   := l_cur_fei.attribute6;
        l_line_tbl(1).p_attribute7                   := l_cur_fei.attribute7;
        l_line_tbl(1).p_attribute8                   := l_cur_fei.attribute8;
        l_line_tbl(1).p_attribute9                   := l_cur_fei.attribute9;
        l_line_tbl(1).p_attribute10                  := l_cur_fei.attribute10;
        l_line_tbl(1).p_attribute11                  := l_cur_fei.attribute11;
        l_line_tbl(1).p_attribute12                  := l_cur_fei.attribute12;
        l_line_tbl(1).p_attribute13                  := l_cur_fei.attribute13;
        l_line_tbl(1).p_attribute14                  := l_cur_fei.attribute14;
        l_line_tbl(1).p_attribute15                  := l_cur_fei.attribute15;
        l_line_tbl(1).p_attribute16                  := l_cur_fei.attribute16;
        l_line_tbl(1).p_attribute17                  := l_cur_fei.attribute17;
        l_line_tbl(1).p_attribute18                  := l_cur_fei.attribute18;
        l_line_tbl(1).p_attribute19                  := l_cur_fei.attribute19;
        l_line_tbl(1).p_attribute20                  := l_cur_fei.attribute20;

        -- Added as part of GL Interface build
        -- Start of modifications
        l_line_tbl(1).p_d_gl_date                    := l_cur_fei.gl_date;

        l_line_tbl(1).p_override_dr_rec_ccid         := l_override_dr_rec_ccid;
        l_line_tbl(1).p_override_cr_rev_ccid         := l_override_cr_rev_ccid;
        l_line_tbl(1).p_override_dr_rec_account_cd   := l_override_dr_rec_account_cd;
        l_line_tbl(1).p_override_cr_rev_account_cd   := l_override_cr_rev_account_cd;

        -- End of modifications due to GL build

        igs_fi_charges_api_pvt.create_charge(p_api_version               => 2.0,
                                             p_init_msg_list             => 'T',
                                             p_commit                    => 'F',
                                             p_header_rec                => l_header_rec,
                                             p_line_tbl                  => l_line_tbl,
                                             x_line_id_tbl               => l_line_id_tbl,
                                             x_invoice_id                => l_invoice_id,
                                             x_return_status             => l_v_return_status,
                                             x_msg_count                 => l_n_msg_count,
                                             x_msg_data                  => l_v_msg_data,
                                             x_waiver_amount             => l_n_waiver_amount);
        IF l_v_return_status <> 'S' THEN
          l_b_ext_val_flag := FALSE;
          IF l_n_msg_count = 1 THEN
            fnd_message.set_encoded(l_v_msg_data);
            l_v_msg := fnd_message.get;
            fnd_file.put_line(fnd_file.log,l_v_msg);
            l_cur_fei.error_msg := l_v_msg;
          ELSE
            FOR l_var IN 1..l_n_msg_count LOOP
              fnd_message.set_encoded(fnd_msg_pub.get);
              l_v_msg := fnd_message.get;
              fnd_file.put_line(fnd_file.log,l_v_msg);
              l_cur_fei.error_msg := l_cur_fei.error_msg||'.'||l_v_msg;
            END LOOP;
          END IF;
        END IF;
      END IF;

      IF l_b_ext_val_flag THEN
        l_ext_status := l_cst_success;
        l_cur_fei.error_msg := NULL;
      ELSE
        l_ext_status := l_cst_error;
      END IF;

      -- Updating the TODO record status in IGS_FI_EXT_INT_ALL table to SUCCESS once the data is moved.
      --Modified by sarakshi, bug:2175865, now updating interface table if return status is success earlier code  was
      -- reverse of this
      -- Added gl_Date in call to update_row

      BEGIN
        igs_fi_ext_int_pkg.update_row (      x_rowid                                =>   l_cur_fei.row_id,
                                             x_external_fee_id                      =>   l_cur_fei.external_fee_id,
                                             x_person_id                            =>   l_cur_fei.person_id,
                                             x_status                               =>   l_ext_status,
                                             x_fee_type                             =>   l_cur_fei.fee_type,
                                             x_fee_cal_type                         =>   l_cur_fei.fee_cal_type,
                                             x_fee_ci_sequence_number               =>   l_cur_fei.fee_ci_sequence_number,
                                             x_course_cd                            =>   l_cur_fei.course_cd,
                                             x_crs_version_number                   =>   l_cur_fei.crs_version_number,
                                             x_transaction_amount                   =>   l_cur_fei.transaction_amount,
                                             x_currency_cd                          =>   l_cur_fei.currency_cd,
                                             x_exchange_rate                        =>   l_cur_fei.exchange_rate,
                                             x_effective_dt                         =>   l_cur_fei.effective_dt,
                                             x_comments                             =>   l_cur_fei.comments,
                                             x_logical_delete_dt                    =>   l_cur_fei.logical_delete_dt,
                                             x_override_dr_rec_account_cd           =>   l_cur_fei.override_dr_rec_account_cd,
                                             x_override_dr_rec_ccid                 =>   l_cur_fei.override_dr_rec_ccid,
                                             x_override_cr_rev_account_cd           =>   l_cur_fei.override_cr_rev_account_cd,
                                             x_override_cr_rev_ccid                 =>   l_cur_fei.override_cr_rev_ccid,
                                             x_attribute_category                   =>   l_cur_fei.attribute_category,
                                             x_attribute1                           =>   l_cur_fei.attribute1,
                                             x_attribute2                           =>   l_cur_fei.attribute2,
                                             x_attribute3                           =>   l_cur_fei.attribute3,
                                             x_attribute4                           =>   l_cur_fei.attribute4,
                                             x_attribute5                           =>   l_cur_fei.attribute5,
                                             x_attribute6                           =>   l_cur_fei.attribute6,
                                             x_attribute7                           =>   l_cur_fei.attribute7,
                                             x_attribute8                           =>   l_cur_fei.attribute8,
                                             x_attribute9                           =>   l_cur_fei.attribute9,
                                             x_attribute10                          =>   l_cur_fei.attribute10,
                                             x_attribute11                          =>   l_cur_fei.attribute11,
                                             x_attribute12                          =>   l_cur_fei.attribute12,
                                             x_attribute13                          =>   l_cur_fei.attribute13,
                                             x_attribute14                          =>   l_cur_fei.attribute14,
                                             x_attribute15                          =>   l_cur_fei.attribute15,
                                             x_attribute16                          =>   l_cur_fei.attribute16,
                                             x_attribute17                          =>   l_cur_fei.attribute17,
                                             x_attribute18                          =>   l_cur_fei.attribute18,
                                             x_attribute19                          =>   l_cur_fei.attribute19,
                                             x_attribute20                          =>   l_cur_fei.attribute20,
                                             x_mode                                 =>   'R',
                                             x_gl_date                              =>   l_cur_fei.gl_date,
                                             x_error_msg                            =>   SUBSTR(LTRIM(l_cur_fei.error_msg,'.'),1,2000)
                                           ) ;
      EXCEPTION
        WHEN OTHERS THEN
          l_b_flag := FALSE;
          l_b_ext_val_flag := FALSE;
      END;

      --Added by sarakshi, bug:2175865
      --If Entire transaction is successful then commit else rollback
      IF l_b_flag = FALSE THEN
        ROLLBACK;
      ELSE
        COMMIT;
      END IF;

      -- Records processed count to be done only on successful passing of all validations and import
      -- Hence moved here from beginning of loop
      -- part of bug 2737666
      IF l_b_ext_val_flag THEN
        l_n_record_count := l_n_record_count + 1;
      END IF;
    END LOOP;
    CLOSE cur_fei;

    fnd_file.put_line(fnd_file.log,fnd_message.get_string ('IGS','IGS_GE_TOTAL_REC_PROCESSED')||TO_CHAR(l_n_record_count));
    fnd_file.put_line(fnd_file.log,RPAD('-',77,'-'));

  EXCEPTION
    WHEN l_exception THEN
      retcode := 2;
    WHEN OTHERS THEN
      ROLLBACK;
      retcode := 2;
      errbuf := fnd_message.get_string('IGS','IGS_GE_UNHANDLED_EXCEPTION')||' : '||SQLERRM;
      igs_ge_msg_stack.add;
      igs_ge_msg_stack.conc_exception_hndl;
  END igs_fi_extto_imp;

FUNCTION get_std_formerstd_ind(p_person_id IN igs_pe_typ_instances_all.person_id%TYPE )
RETURN VARCHAR2 AS
 /******************************************************************
  Created By         :Prasad marada
  Date Created By    :30-Nov-2004
  Purpose            :This procedure is called for validating if the
                      passed Person Id has an active type instance of
                      STUDENT or FORMER Student
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who       When         What

  ********************************************************************/
        l_n_count         NUMBER;
        l_v_output        VARCHAR2(1);

        CURSOR  c_person_typ (cp_person_id  igs_pe_typ_instances_all.person_id%TYPE) IS
                SELECT  1
                FROM    igs_pe_typ_instances_all pti, igs_pe_person_types pty
                WHERE   pti.person_type_code = pty.person_type_code AND
                        pty.system_type IN  ('STUDENT','FORMER_STUDENT') AND
                        pti.person_id = cp_person_id;

BEGIN
        -- This funcation returns Y if person of type student or former student
        -- else return N

        OPEN  c_person_typ (p_person_id);
        FETCH c_person_typ INTO l_n_count;
        IF c_person_typ%FOUND THEN
          l_v_output := 'Y';
        ELSE
          l_v_output := 'N';
        END IF;
        CLOSE c_person_typ;
        RETURN l_v_output;

END get_std_formerstd_ind;

 -- end of package body
END igs_fi_load_ext_chg;

/
