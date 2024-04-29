--------------------------------------------------------
--  DDL for Package Body IGS_FI_CHARGES_API_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_CHARGES_API_PVT" AS
/* $Header: IGSFI53B.pls 120.24 2006/06/27 14:17:12 skharida ship $ */
  ------------------------------------------------------------------
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who       When             What
  --skharida  26-Jun-2006      Bug 5208136 - Modified procedure create_charge, removed the obsoleted columns of the IGS_FI_INV_INT_PKG
  --akandreg  20-Jun-2006      Bug 5116519 - The Message 'IGS_FI_INVALID_FTCI' is modified .The old token FEE_CAL_TYPE
  --                           is replaced by new token CI_DESC and passed fee CI description to that. Also the cursor
  --                           cur_alt_cd_desc is modified to select another column igs_ca_inst_all.description.
  --pathipat  12-Jun-2006      Bug 5306868 - Modified create_charge - charge adjustment logic revamped
  --sapanigr  29-May-2006      Bug 5251760 Modified create_charge. Added new local function chk_charge_adjusted.
  --svuppala  05-May-2006      Bug 3924836 Precision Issue. Modified create_charge and validate_neg_amt
  --sapanigr  03-May-2006      Enh#3924836 Precision Issue. Modified create_charge
  --sapanigr  24-Feb-2006      Bug 5018036 - Removed cursor 'cur_ret' and cursor variable 'l_ret_rec'in procedure 'create_charge'.
  --sapanigr  09-Feb-2006      Bug 5018036 - Modified query procedure 'create_charge' for R12 Repository tuning issue.
  --abshriva  24-Oct-2005      Bug 4680553-Modification made in procedure create_charge
  --pathipat  05-Oct-2005      Bug 4383148 - Fees not assessed if attendance type cannot be derived
  --                           Removed functions validate_atd_mode and validate_atd_type and their invocation
  --gurprsin  13-Sep-2005      Bug 3627209, Modified existing logic as to return the new message in case if there is no credit type defined
  --                           for negative charge adjustment credit class.
  --svuppala  07-JUL-2005      Enh 3392095 - Tution Waivers build
  --                           Modified HEADER_REC_TYPE -- included waiver_name.
  --                           Modified create_charge
 --pmarada     26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
 --                            parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
 -- svuppala  9-JUN-2005       Enh 4213629 - Impact of automatic generation of the Receipt Number
 --                            changed logic for l_v_credit_number in procedure proc_neg_chg.
  --gurprsin  03-Jun-2005      Enh# 3442712  Modified call to igs_fi_prc_acct_pkg.build_accounts and igs_fi_invln_int_pkg.insert_row methods.
 -- svuppala  05-APR-2005      Bug# "4240402" Additional fix done as part of Time Zone impact
 --                            Changed the negative charge adjustment logic with ORDER BY application_id
 --                            instead of APPLY_DATE as time part of it is truncated.
  --pathipat  30-Sep-2004      Bug 3908040 - Modified proc_neg_chg() - Removed check on Manage Accounts = Other before application/unapplication
  --uudayapr  10-mar-2004      Bug#3478599,modified create_charge procedure
  --shtatiko  10-DEC-2003      Bug# 3288973, modified call_build_process.
  --vvutukur  27-Jun-2003      Bug#2849185.Modified create_charge procedure.
  --jbegum    20-Jun-2003      Bug# 2998266, NEXT_INVOICE_NUMBER in the IGS_FI_CONTROL table will not be used for
  --                           generating unique charge numbers. Next Value from a DB sequence will be used for
  --                           for generating unique charges numbers.
  --vvutukur  16-Jun-2003      Enh#2831582.Lockbox Build. Modified proc_neg_chg,create_charge.
  --vvutukur  26-May-2003      Enh#2831572.Financial Accounting Build. Modified procedure validate_course,
  --shtatiko  05-MAY-2003      Enh# 2831569, Modified proc_neg_chg and create_charge
  --pathipat  14-Apr-2003      Enh 2831569 - Commercial Receivables Interface build
  --                           Modified call to igs_fi_control_pkg.update_row in proc create_charge()
  --vvutukur     05-Apr-2003   Enh#2831554.Internal Credits API Build.Removed procedure validate_lkup,modified proc_neg_chg,create_charge.
  --agairola  11-Mar-2003      Bug 2762740: Modified validate_neg_amnt and create_charge
  --vchappid  03-Mar-2003      Bug: 2820197, In functions validate_ftci, validate_fcfl,Fee Structure Status validation
  --                           should be bypassed when the transaction type is either Assessment or Retention
  --smadathi   18-Feb-2002     Enh. Bug 2747329.Modified create_charge procedure.
  --vvutukur  12-Dec-2002      Enh#2584741.Deposits Build. Modified procedure proc_neg_chg.
  --pathipat  14-Nov-2002      Enh 2584986 -
  --                           1.  Modified create_charge(), added parameter p_d_gl_date
  --                               in call to igs_fi_invln_int.insert_row().
  --                           2.  Modified proc_neg_chg(), added p_gl_date and p_currency_cd as IN parameter. Passed gl_date
  --                               in calls to create_application() and create_credit() in proc_neg_chg
  --                           3.  Removed local procedure get_local_amount() - exchange_rate = 1 always.
  --                           4.  Modified function validate_cur()
  --vvutukur  30-Sep-2002      Enh#2562745.Modified create_charge procedure.
  --vvutukur  23-Sep-2002      Enh#2564643.removed the references to subaccount_id. ie.,removed
  --                           function validate_subaccount.Modified procedures proc_neg_chg,
  --                           create_charge.
  --smadathi  03-Jul-2002      Bug 2443082. Modified create_charge procedure.
  --agairola  10-Jun-2002       Bug Number: 2407624 Modified get_local_amount and create_charge
  --agairola  17-May-2002      Modified the Call_Build_Accounts procedure and Create Charge procedure for
  --                           bug 2323555
  -- agairola 30-Apr-2002      Added the fee structure status to the query and equated the s_fee_structure_status to ACTIVE
  --                              for bug fix 2348883 in validate_ftci and validate_fcfl
  --SYkrishn  15/APR/2002      Included column planned_credits_ind in the update_row call of IGS_FI_CONTROL_PKG
  --                             as part of ENh SFCR018 Build 2293676
  --smvk       08-Mar-2002     Updated the call to igs_fi_control_pkg as per the Bug No 2144600
  --vvutukur   27-02-2002      removed local function validate_person and placed call to igs_fi_gen_007.validate_person
  --                           in create_charge procedure.for bug:2238362
  --jbegum     20-Feb-02       As part Enh bug#2228910
  --                           Removed source_transaction_id column from calls to
  --                           IGS_FI_INV_INT_PKG.insert_row and IGS_FI_INVLN_INT_PKG.insert_row
  --vvutukur   18-feb-2002     added ar_int_org_id column in call to igs_fi_control_pkg
  --                           for bug:2222272.
  --jbegum     14-Feb-2001      As part of Enh bug # 2201081
  --                            Added call to IGS_FI_GEN_005.validate_psa and IGS_FI_PARTY_SA_PKG.insert_row
  --                            Removed Cursor cur_psa
  --sykrishn   14feb2002        SFCR020 Build - 2191470 - Added the 4 new params to Credits API call.
  --vchappid   20-Jan-2002     Enh # 2162747, Modified igs_fi_control table, introduced two columns
  --masehgal   15-Jan-2002     Enh # 2170429
  --                           Obsoletion of SPONSOR_CD
  --sarakshi   18-dec-2001     removed the parameters p_source_date,p_fee_type,p_credit_type_id from
  --                           the call to procedure Update_Balances and added parameter p_source_id
  --                           as a part of Enh. bug:2124001
  --smadathi   12-oct-2001     As part of enhancement bug#2042716 , create_charge
  --                           procedure modified .
  --nalkumar   19-Dec-2001     Changed the call to IGS_FI_PARTY_SUBACTS_PKG.insert_row.
  --                           This is as per the SF015 Holds DLD. Bug# 2126091.
  --agairola   12-Feb-2002     Added the functionality for negative charge creation for
  --                           SFCR003 DLD  Bug No 2195715
  ------------------------------------------------------------------
  g_active            CONSTANT     VARCHAR2(10) := 'ACTIVE';
  g_ind_no            CONSTANT     VARCHAR2(1)  := 'N';
  g_pkg_name          CONSTANT     VARCHAR2(30) := 'IGS_FI_CHARGES_API_PVT';
  g_transaction_type  CONSTANT     VARCHAR2(20) := 'TRANSACTION_TYPE';
  g_chg_method        CONSTANT     VARCHAR2(15) := 'CHG_METHOD';
  g_app               CONSTANT     VARCHAR2(5)  := 'APP';
  g_unapp             CONSTANT     VARCHAR2(5)  := 'UNAPP';
  g_ind_yes           CONSTANT     VARCHAR2(1)  := 'Y';
  g_standard          CONSTANT     VARCHAR2(10) := 'STANDARD';
  g_charge            CONSTANT     VARCHAR2(10) := 'CHARGE';
  g_neg_cr_class      CONSTANT     VARCHAR2(6)  := 'CHGADJ';
  g_null              CONSTANT     VARCHAR2(6)  := NULL;
  g_cleared           CONSTANT     VARCHAR2(30) := 'CLEARED';
  g_adj               CONSTANT     VARCHAR2(30) := 'ADJ';
  g_crd_char          CONSTANT     VARCHAR2(5)  := '-';

  g_c_assessment      CONSTANT     VARCHAR2(30) := 'ASSESSMENT';
  g_c_retention       CONSTANT     VARCHAR2(30) := 'RETENTION';

  g_inv_amt_due                    igs_fi_inv_int.invoice_amount_due%TYPE;
  g_curr_cd                        igs_fi_control.currency_cd%TYPE;
  g_v_manage_accounts              igs_fi_control_all.manage_accounts%TYPE;

FUNCTION chk_charge_adjusted(p_n_invoice_id IN igs_fi_inv_int_all.invoice_id%TYPE,
                             p_n_inv_amt    IN igs_fi_inv_int_all.invoice_amount%TYPE) RETURN BOOLEAN;

FUNCTION validate_ftci(p_c_fee_cal_type             IN              igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                       p_n_fee_ci_sequence_number   IN              igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                       p_c_fee_type                 IN              igs_fi_f_typ_ca_inst.fee_type%TYPE,
                       p_c_transaction_type         IN              igs_lookup_values.lookup_code%TYPE) RETURN BOOLEAN AS
/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Fee Type Calendar Instance.

Known limitations,enhancements,remarks:

Change History

Who       When        What
vchappid  03-Mar-2003 Bug: 2820197, Fee Structure Status validation should be bypassed when the transaction type is
                      either Assessment or Retention
agairola  30-Apr-2002 added the fee structure status to the query and equated the s_fee_structure_status to ACTIVE
                      for bug fix 2348883

********************************************************************************************** */
    l_temp              VARCHAR2(1);
    l_bool              BOOLEAN;

-- Cursor for validating the Fee Type Calendar Instance for active FTCI
    CURSOR cur_ftci(cp_c_fee_cal_type                igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                    cp_n_fee_ci_sequence_number      igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                    cp_c_fee_type                    igs_fi_f_typ_ca_inst.fee_type%TYPE,
                    cp_c_status                      VARCHAR2,
                    cp_c_transaction_type            igs_lookup_values.lookup_code%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_f_typ_ca_inst ftci,
             igs_fi_fee_str_stat  fsst
      WHERE  ftci.fee_cal_type                         = cp_c_fee_cal_type
      AND    ftci.fee_ci_sequence_number               = cp_n_fee_ci_sequence_number
      AND    ftci.fee_type                             = cp_c_fee_type
      AND    ftci.fee_type_ci_status                   = fsst.fee_structure_status
      AND    (
              (fsst.s_fee_structure_status              = cp_c_status
               AND
               cp_c_transaction_type NOT IN (g_c_assessment,g_c_retention)
              )
               OR
              (cp_c_transaction_type IN (g_c_assessment,g_c_retention))
             );
  BEGIN
    OPEN cur_ftci(p_c_fee_cal_type,
                  p_n_fee_ci_sequence_number,
                  p_c_fee_type,
                  g_active,
                  p_c_transaction_type);
    FETCH cur_ftci INTO l_temp;
    IF cur_ftci%NOTFOUND THEN
      l_bool  := FALSE;
    ELSE
      l_bool  := TRUE;
    END IF;
    CLOSE cur_ftci;

    RETURN l_bool;

  END validate_ftci;

  FUNCTION validate_fcfl(p_c_fee_cat                 IN                igs_fi_f_cat_fee_lbl.fee_cat%TYPE,
                         p_c_fee_type                IN                igs_fi_f_cat_fee_lbl.fee_type%TYPE,
                         p_c_transaction_type        IN                igs_lookup_values.lookup_code%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Fee Category Fee Liability.

Known limitations,enhancements,remarks:

Change History

Who     When        What
vchappid  03-Mar-2003 Bug: 2820197, Fee Structure Status validation should be bypassed when the transaction type is
                      either Assessment or Retention
agairola 30-Apr-2002 added the fee structure status to the query and equated the s_fee_structure_status to ACTIVE
                     for bug fix 2348883
********************************************************************************************** */
    l_temp              VARCHAR2(1);
    l_bool              BOOLEAN;


    -- Cursor for validating the Fee Category Fee Liability
    CURSOR cur_fcfl(cp_c_fee_cat             igs_fi_f_cat_fee_lbl.fee_cat%TYPE,
                    cp_c_fee_type            igs_fi_f_cat_fee_lbl.fee_type%TYPE,
                    cp_c_status              VARCHAR2,
                    cp_c_transaction_type    igs_lookup_values.lookup_code%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_f_cat_fee_lbl fcfl,
             igs_fi_fee_str_stat fsst
      WHERE  fcfl.fee_cat              = cp_c_fee_cat
      AND    fcfl.fee_type             = cp_c_fee_type
      AND    fcfl.fee_liability_status = fsst.fee_structure_status
      AND    (
              (fsst.s_fee_structure_status = cp_c_status
               AND
               cp_c_transaction_type NOT IN (g_c_assessment,g_c_retention)
              )
               OR
              (cp_c_transaction_type IN (g_c_assessment,g_c_retention))
             );

  BEGIN
    OPEN cur_fcfl(p_c_fee_cat,
                  p_c_fee_type,
                  g_active,
                  p_c_transaction_type);
    FETCH cur_fcfl INTO l_temp;
    IF cur_fcfl%NOTFOUND THEN
      l_bool := FALSE;
    ELSE
      l_bool := TRUE;
    END IF;
    CLOSE cur_fcfl;

    RETURN l_bool;
  END validate_fcfl;

  FUNCTION validate_course(p_course_cd  IN  igs_ps_ver.course_cd%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Program.

Known limitations,enhancements,remarks:

Change History

Who       When         What
vvutukur 26-May-2003  Bug#2869357.Modified cursor cur_course.
********************************************************************************************** */
    l_temp              VARCHAR2(1);
    l_bool              BOOLEAN;

-- Cursor for validating the program
    CURSOR cur_course(cp_course_cd    igs_ps_ver.course_cd%TYPE,
                      cp_status       VARCHAR2) IS
      SELECT 'x'
      FROM   igs_ps_ver pv, igs_ps_stat ps
      WHERE  pv.course_cd          = cp_course_cd
      AND    pv.course_status      = ps.course_status
      AND    ps.s_course_status    = cp_status;

  BEGIN

    OPEN cur_course(p_course_cd,g_active);
    FETCH cur_course INTO l_temp;
    IF cur_course%NOTFOUND THEN
      l_bool := FALSE;
    ELSE
      l_bool := TRUE;
    END IF;
    CLOSE cur_course;

    RETURN l_bool;
  END validate_course;

  --removed function validate_subaccount as part of subaccount removal build. enh#2564643.
  --removed function validate_lkup as part of Internal Credits API build. enh#2831554.


FUNCTION validate_cur(p_currency_cd  IN   igs_fi_control.currency_cd%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the currency code.

Known limitations,enhancements,remarks:

Change History

Who        When           What
pathipat   16-Nov-2002    Enh Bug: 2584986: Replaced cursor selecting from igs_fi_cur with generic
                          function to get the currency_cd set in igs_fi_control
********************************************************************************************** */
    l_bool               BOOLEAN;
    l_v_message_name       fnd_new_messages.message_name%TYPE;
    l_v_curr_desc          fnd_currencies_tl.name%TYPE;

  BEGIN

    -- Call generic function to get the currency_cd setup in igs_fi_control
    igs_fi_gen_gl.finp_get_cur( p_v_currency_cd  =>  g_curr_cd,
                                p_v_curr_desc    =>  l_v_curr_desc,
                                p_v_message_name =>  l_v_message_name
                              );
    IF l_v_message_name IS NULL THEN
      -- If the currency_cd passed is not same as currency_cd setup in the System options form
      -- then error is given
      IF g_curr_cd <> p_currency_cd THEN
          l_bool := FALSE;
      ELSE
          l_bool := TRUE;
      END IF;
    ELSE
      l_bool := FALSE;
    END IF;

    RETURN l_bool;

  END validate_cur;

  FUNCTION validate_uoo(p_uoo_id  IN igs_ps_unit_ofr_opt.uoo_id%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Unit Section .

Known limitations,enhancements,remarks:

Change History

Who     When       What
jbegum  24-Sep-01  The function has been modified to validate the uoo_id instead of the six UOO columns
                   ie. unit_cd , unit_version_number, unit_location_cd , cal_type ,
                       ci_sequence_number and unit_class .
                   Hence the function takes only the uoo_id as input parameter and not all the six UOO
                   columns , as was the case earlier.
                   This change was carried out as part of bug #1962286
************************************************************************************************/
    l_temp          VARCHAR2(1);
    l_bool          BOOLEAN;

-- Cursor for validating the unit section
    CURSOR cur_uoo(cp_uoo_id   igs_ps_unit_ofr_opt.uoo_id%TYPE ) IS
      SELECT 'x'
      FROM   igs_ps_unit_ofr_opt
      WHERE  uoo_id = cp_uoo_id;

  BEGIN

    OPEN cur_uoo(p_uoo_id);
    FETCH cur_uoo INTO l_temp;
    IF cur_uoo%NOTFOUND THEN
      l_bool := FALSE;
    ELSE
      l_bool := TRUE;
    END IF;
    CLOSE cur_uoo;

    RETURN l_bool;

  END validate_uoo;

  FUNCTION validate_org_unit_cd(p_org_unit_cd   IN   igs_or_unit.org_unit_cd%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Org Unit Code .

Known limitations,enhancements,remarks:

Change History

Who     When       What

********************************************************************************************** */
    l_temp          VARCHAR2(1);
    l_bool          BOOLEAN;

-- Cursor for validating the Org_Unit_Code
    CURSOR cur_org_unit(cp_org_unit_cd   igs_or_unit.org_unit_cd%TYPE) IS
      SELECT 'x'
      FROM   igs_or_unit
      WHERE  org_unit_cd = cp_org_unit_cd;
  BEGIN
    OPEN cur_org_unit(p_org_unit_cd);
    FETCH cur_org_unit INTO l_temp;
    IF cur_org_unit%NOTFOUND THEN
      l_bool := FALSE;
    ELSE
      l_bool := TRUE;
    END IF;
    CLOSE cur_org_unit;

    RETURN l_bool;
  END validate_org_unit_cd;

  FUNCTION validate_source_txn_id(p_source_txn_id  IN  igs_fi_inv_int.invoice_id%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This function validates the Source Transaction Id. This should be a valid Invoice Id .

Known limitations,enhancements,remarks:

Change History

Who     When       What

********************************************************************************************** */
    l_temp          VARCHAR2(1);
    l_bool          BOOLEAN;

-- Cursor for validating if the source transaction id is a valid invoice id
    CURSOR cur_txn_id(cp_source_txn_id        igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_inv_int
      WHERE  invoice_id  = cp_source_txn_id;
  BEGIN
    OPEN cur_txn_id(p_source_txn_id);
    FETCH cur_txn_id INTO l_temp;
    IF cur_txn_id%NOTFOUND THEN
      l_bool := FALSE;
    ELSE
      l_bool := TRUE;
    END IF;
    CLOSE cur_txn_id;

    RETURN l_bool;
  END validate_source_txn_id;

-- enh bug#2030448, removed accounting method function

-- enh bug#2584986, removed proc get_local_amount

  PROCEDURE call_build_process ( p_header_rec             IN  igs_fi_charges_api_pvt.header_rec_type,
                                 p_line_rec               IN  igs_fi_charges_api_pvt.line_rec_type,
                                 p_dr_gl_ccid          IN OUT NOCOPY  igs_fi_invln_int_all.rec_gl_ccid%TYPE,
                                 p_cr_gl_ccid          IN OUT NOCOPY  igs_fi_invln_int_all.rec_gl_ccid%TYPE,
                                 p_dr_account_cd       IN OUT NOCOPY  igs_fi_invln_int_all.rec_account_cd%TYPE,
                                 p_cr_account_cd       IN OUT NOCOPY  igs_fi_invln_int_all.rev_account_cd%TYPE,
                                 p_error_string           OUT NOCOPY  igs_fi_invln_int.error_string%TYPE,
                                 p_flag                   OUT NOCOPY  NUMBER
                               ) AS
  /**********************************************************************************************************************

  Created By:         kkillams

  Date Created By:    01-08-2001

  Purpose:            This function calls the build accounting process

  Known limitations,enhancements,remarks:

  Change History

  Who       When         What
  gurprsin   02-Jun-2005 Enh# 3442712, Modified the Call Build Process
                         Added new parameters to igs_fi_prc_acct_pkg.build_accounts to include unit level attributes.
  shtatiko  10-DEC-2003  Bug# 3288973, Replaced hard coded transaction type, 'CHARGE', with l_v_transaction_type.
  vvutukur  17-may-2003  Enh#2831572.Financial Accounting Build. Added 3 new parameters to the call to igs_fi_prc_acct_pkg.build_accounts.
  vvutukur  17-Sep-2002  Enh#2564643.Removed p_subacccount_id from igs_fi_prc_acct_pkg.build_accounts
                         call.
  agairola  17-May-2002  Following modifications were done for the bugs 2323555.
                         1. The parameters p_dr_gl_ccid, p_cr_gl_ccid , p_dr_account_cd and
                            p_cr_account_cd are made IN OUT NOCOPY from OUT NOCOPY type.
                         2. The values l_dr_rec_ccid, l_cr_rev_ccid, l_dr_account_cd, l_cr_account_cd
                            were assigned the values passed as input parameters.
                         3. After the Build Account Process is called, if the error type is 1 and
                            the return status is FALSE, make the account parameters as NULL.
  jbegum  24-Sep-01  As part of the bug #1962286 the following changes were done:
                     The local variable l_uoo_id was removed.
                     Two new local variables l_unit_cd and l_unit_version_number were added.
                     The cursors cur_uoo_id and cur_loc were removed and cursor cur_unit_cd_ver was added.
                     The cursor FOR loop for retrieving the uoo_id has been removed.
                     The IF condition which obtained the location_cd depending on the charge method method was removed
                     and now the value of location_cd was obtained directly from p_line_rec.p_location_cd.
                     The call to the procedure igs_fi_prc_acct_pkg.build_accounts was modified.
  **********************************************************************************************************************/


   l_dr_gl_ccid                  igs_fi_invln_int_all.rec_gl_ccid%TYPE;
   l_cr_gl_ccid                  igs_fi_invln_int_all.rev_gl_ccid%TYPE;
   l_dr_account_cd               igs_fi_invln_int_all.rec_account_cd%TYPE;
   l_cr_account_cd               igs_fi_invln_int_all.rev_account_cd%TYPE;
   l_err_string                  igs_fi_invln_int_all.error_string%TYPE;
   l_ret_status                  BOOLEAN;
   l_err_type                    NUMBER;
   l_version_number              igs_en_stdnt_ps_att.version_number%TYPE;
   l_st_date                     igs_or_unit.start_dt%TYPE;
   l_v_transaction_type          igs_fi_inv_int_all.transaction_type%TYPE;

   -- As part of the bug #1962286 the local variables l_unit_cd and l_unit_version_number were added

   l_unit_cd                     igs_ps_unit_ofr_opt.unit_cd%TYPE;
   l_unit_version_number         igs_ps_unit_ofr_opt.version_number%TYPE;

   -- cusor to get the version number form igs_en_stdnt_ps_att table for a person , course

   CURSOR cur_ver (l_course_cd  igs_fi_inv_int.course_Cd%TYPE,
                   l_person_id  igs_fi_inv_int.person_id%TYPE) IS
     SELECT version_number
     FROM   igs_en_stdnt_ps_att
     WHERE  course_cd = l_course_cd
     AND    person_id = l_person_id;

  --
  -- cursor to get the start date for  org_unit_cd from igs_or_unit
  --
   CURSOR cur_org_st_dt (l_org_unit_cd  igs_or_unit.org_unit_cd%TYPE) IS
     SELECT start_dt
     FROM igs_or_unit
     WHERE org_unit_cd = l_org_unit_cd;


  -- As part of the bug #1962286 the cursor cur_unit_cd_ver was added

  --
  -- cursor to get the unit_cd and unit_version_number for a given uoo_id from igs_ps_unit_ofr_opt
  --
   CURSOR cur_unit_cd_ver (l_uoo_id   igs_ps_unit_ofr_opt_all.uoo_id%TYPE ) IS
   SELECT unit_cd ,version_number
   FROM   igs_ps_unit_ofr_opt
   WHERE  uoo_id = l_uoo_id;


   BEGIN
     p_error_string   := NULL;
     p_flag           := 0;

     FOR rec_ver IN cur_ver(p_header_rec.p_course_cd,
                            p_header_rec.p_person_id )
     LOOP
         l_version_number := rec_ver.version_number;
     END LOOP;


     FOR rec_org_st_dt IN cur_org_st_dt ( p_line_rec.p_org_unit_cd)
     LOOP
         l_st_date:= rec_org_st_dt.start_dt;
     END LOOP;

     -- As part of bug #1962286 the following cursor FOR loop was added to fetch the
     -- unit_cd and unit_version_number values to pass in the call to igs_fi_prc_acct_pkg.build_accounts

     FOR rec_unit_cd_ver IN cur_unit_cd_ver ( p_line_rec.p_uoo_id)
     LOOP
         l_unit_cd:= rec_unit_cd_ver.unit_cd;
         l_unit_version_number:= rec_unit_cd_ver.version_number;
     END LOOP;

    -- As part of bug #1962286
    -- The IF condition which obtained the location_cd depending on the charge method method was removed
    -- and now the value of location_cd is obtained directly from p_line_rec.p_location_cd.Hence in the
    -- call to igs_fi_prc_acct_pkg.build_accounts p_line_rec.p_location_cd is being passed directly.


     -- As part of bug #1962286 the call to igs_fi_prc_acct_pkg.build_accounts was modified.
     -- Instead of p_line_rec.p_unit_cd , p_line_rec.p_unit_version_number , l_uoo_id being passed
     -- l_unit_cd , l_unit_version_number , p_line_rec.p_uoo_id are passed

     l_dr_gl_ccid := p_dr_gl_ccid;
     l_cr_gl_ccid := p_cr_gl_ccid;
     l_dr_account_cd := p_dr_account_cd;
     l_cr_account_cd := p_cr_account_cd;

     IF p_header_rec.p_transaction_type = 'RETENTION' THEN
       l_v_transaction_type := p_header_rec.p_transaction_type;
     ELSE
       l_v_transaction_type := 'CHARGE';
     END IF;

     igs_fi_prc_acct_pkg.build_accounts(
                          p_fee_type                      =>     p_header_rec.p_fee_type,
                          p_fee_cal_type                  =>     p_header_rec.p_fee_cal_type,
                          p_fee_ci_sequence_number        =>     p_header_rec.p_fee_ci_sequence_number,
                          p_course_cd                     =>     p_header_rec.p_course_cd,
                          p_course_version_number         =>     l_version_number,
                          p_org_unit_cd                   =>     p_line_rec.p_org_unit_cd,
                          p_org_start_dt                  =>     l_st_date,
                          p_unit_cd                       =>     l_unit_cd,
                          p_unit_version_number           =>     l_unit_version_number,
                          p_uoo_id                        =>     p_line_rec.p_uoo_id,
                          p_location_cd                   =>     p_line_rec.p_location_cd,
                          p_transaction_type              =>     l_v_transaction_type, -- replaced hard-coded string 'CHARGE' (Bug# 3288973)
                          p_credit_type_id                =>     NULL,
                          p_source_transaction_id         =>     NULL,
                          x_dr_gl_ccid                    =>     l_dr_gl_ccid,
                          x_cr_gl_ccid                    =>     l_cr_gl_ccid,
                          x_dr_account_cd                 =>     l_dr_account_cd,
                          x_cr_account_cd                 =>     l_cr_account_cd,
                          x_err_type                      =>     l_err_type,
                          x_err_string                    =>     l_err_string,
                          x_ret_status                    =>     l_ret_status,
                          p_v_attendance_type             =>     p_header_rec.p_attendance_type,
                          p_v_attendance_mode             =>     p_header_rec.p_attendance_mode,
                          p_v_residency_status_cd         =>     p_line_rec.p_residency_status_cd,
                          p_n_unit_type_id                =>     p_line_rec.p_unit_type_id,
                          p_v_unit_class                  =>     p_line_rec.p_unit_class,
                          p_v_unit_mode                   =>     p_line_rec.p_unit_mode,
                          p_v_unit_level                  =>     p_line_rec.p_unit_level,
                          p_v_waiver_name                 =>     p_header_rec.p_waiver_name
                         );

     IF NOT l_ret_status AND l_err_type = 1 THEN
        p_flag         := 1;
        p_error_string := l_err_string;
        p_dr_gl_ccid   := NULL;
        p_cr_gl_ccid   := NULL;
        p_dr_account_cd:= NULL;
        p_cr_account_cd:= NULL;
     ELSIF NOT l_ret_status AND l_err_type > 1 THEN
        p_flag         := 2;
        p_error_string := l_err_string;
        p_dr_gl_ccid   := l_dr_gl_ccid;
        p_cr_gl_ccid   := l_cr_gl_ccid;
        p_dr_account_cd:= l_dr_account_cd;
        p_cr_account_cd:= l_cr_account_cd;
     ELSIF l_ret_status THEN
        p_flag         := 0;
        p_dr_gl_ccid   := l_dr_gl_ccid;
        p_cr_gl_ccid   := l_cr_gl_ccid;
        p_dr_account_cd:= l_dr_account_cd;
        p_cr_account_cd:= l_cr_account_cd;
     END IF;
  END call_build_process;

  PROCEDURE proc_neg_chg(p_source_transaction_id     IN     NUMBER,
                         p_adj_amount                IN     NUMBER,
                         p_d_gl_date                 IN     DATE,
                         p_v_currency_cd             IN     VARCHAR2,
                         p_err_msg                  OUT NOCOPY     VARCHAR2,
                         p_status                   OUT NOCOPY     BOOLEAN) AS
/***********************************************************************************************

  Created By:         Amit Gairola

  Date Created By:    24-01-2002

  Purpose:            This procedure processes the negative charge creation if the invoice amount
                      passed as input to the procedure is negative.

  Known limitations,enhancements,remarks:

  Change History

  Who          When          What
  gurprsin  13-Sep-2005      Bug 3627209, Modified existing logic as to return the new message in case if there is no credit type defined
                             for negative charge adjustment credit class.
  pmarada     26-JUL-2005     Enh 3392095, modifed as per tution waiver build, passing p_api_version
                             parameter value as 2.1 to the igs_fi_credit_pvt.create_credit call
  svuppala     9-JUN-2005    Enh 3442712 - Impact of automatic generation of the Receipt Number
                             changed logic for l_v_credit_number
  pathipat     30-Sep-2004   Bug 3908040 - Removed condition checking for Manage Accounts = 'Other' since application/unapplication
                             would hereafter be allowed even if Manage Accounts = Other.
  vvutukur     16-Jun-2003   Enh#2831582.Lockbox Build. Added 3 new parameters(lockbox_interface_id,batch_name,deposit_date) to the record type
                             variable l_credit_rec in the call to credits api.
  shtatiko     05-MAY-2003   Enh# 2831569, Application and Unapplication of credits is done only if Manage Accounts System Option
                             has value STUDENT_FINANCE.
  vvutukur     05-Apr-2003   Enh#2831554.Internal Credits API Build. Replaced local function validate_lkp with the generic function call
                           igs_fi_crdapi_util.validate_igs_lkp for validating transaction type and charge method. Added check for validity of credit
                           instrument ADJ,fee calendar instance and existence of load calendar instance for a fee calendar instance.
                             Removed the call to igs_fi_credits_api_pub.create_credit, instead placed a call to private credits api with
                             validation level as none.
  vvutukur     12-Dec-2002   Enh#2584741.Deposits Build.Removed paramter p_validation_level and added 3 new parameters
                             p_v_check_number,p_v_source_tran_type,p_v_source_tran_ref_number in the call to Credits
                             API.
  pathipat     14-NOV-2002   EnhBug:2584986 - Added IN parameter, p_d_gl_date
                             Added parameter p_d_gl_date in the call to create_credit()
                             and create_application().
  vvutukur     17-sep-2002   Enh#2564643.Removed references to subaccount_id from i)cursor cur_crt and from its
                             usage in the for loop.ii)igs_fi_credits_api_pub.create_credit.
***********************************************************************************************/

-- Cursor for the selection of the Invoice Details from the
-- Charges table based on the Invoice Id being passed
    CURSOR cur_inv(cp_invoice_id      NUMBER) IS
      SELECT ROWID,
             inv.*
      FROM   igs_fi_inv_int inv
      WHERE  invoice_id = cp_invoice_id;

-- Cursor for the selection of the Application Id from the Application table
-- based on the Credits and the Credit Types
-- Changed the negative charge adjustment logic with ORDER BY application_id instead of APPLY_DATE
-- as it is truncated as part of Time Zone impact bug# "4240402"
    CURSOR cur_app(cp_invoice_id      NUMBER,
                   cp_app_type        VARCHAR2,
                   cp_credit_class    VARCHAR2,
                   cp_unapp_type      VARCHAR2) IS
      SELECT appl.application_id
      FROM   igs_fi_applications appl,
             igs_fi_credits fc,
             igs_fi_cr_types crt
      WHERE  appl.invoice_id   = cp_invoice_id
      AND    appl.credit_id    = fc.credit_id
      AND    fc.credit_type_id = crt.credit_type_id
      AND    crt.credit_class <> cp_credit_class
      AND    appl.application_type = cp_app_type
      AND    NOT EXISTS (SELECT 'x'
                         FROM   igs_fi_applications appl2
                         WHERE  appl2.application_type    = cp_unapp_type
                         AND    appl2.link_application_id = appl.application_id
                         AND    appl2.amount_applied      = - appl.amount_applied)
      ORDER BY appl.application_id DESC;

-- Cursor for selection of the Credit Type Id from the Credit Types table
-- based on the Sub Account and the Negative Charges Credit Class
    CURSOR cur_crt(cp_neg_credit_class      VARCHAR2,
                   cp_effective_date        DATE) IS
      SELECT credit_type_id
      FROM   igs_fi_cr_types
      WHERE  credit_class = cp_neg_credit_class
      AND    cp_effective_date BETWEEN effective_start_date AND NVL(effective_end_date,
                                                                    cp_effective_date);


    l_rec_crt            cur_crt%ROWTYPE;
    l_attr_rec           igs_fi_credits_api_pub.attribute_rec_type;
    l_adj_amount         igs_fi_inv_int.invoice_amount_due%TYPE;
    l_inv                cur_inv%ROWTYPE;
    l_ret_amount         igs_fi_applications.amount_applied%TYPE;
    l_inv_amt_due        igs_fi_inv_int.invoice_amount_due%TYPE;
    l_dr_gl_ccid         igs_fi_invln_int.rec_gl_ccid%TYPE;
    l_cr_gl_ccid         igs_fi_invln_int.rev_gl_ccid%TYPE;
    l_dr_account_cd      igs_fi_invln_int.rec_account_cd%TYPE;
    l_cr_account_cd      igs_fi_invln_int.rev_account_cd%TYPE;
    l_unapply_amt        igs_fi_applications.amount_applied%TYPE;
    l_unapp_amt          igs_fi_applications.amount_applied%TYPE;
    l_diff_amt           igs_fi_applications.amount_applied%TYPE;
    l_cr_desc            fnd_new_messages.message_text%TYPE;
    l_appl_rec_exists    BOOLEAN;
    l_appl_amt           igs_fi_applications.amount_applied%TYPE;
    l_credit_id          igs_fi_credits.credit_id%TYPE;
    l_v_credit_number    igs_fi_credits.credit_number%TYPE;
    l_credit_activity_id igs_fi_cr_activities.credit_activity_id%TYPE;
    l_rec_cntr           NUMBER(10);

    l_ret_status         VARCHAR2(1);
    l_msg_count          NUMBER(3);
    l_msg_data           VARCHAR2(2000);
    l_application_id     igs_fi_applications.application_id%TYPE;
    l_credit_rec         igs_fi_credit_pvt.credit_rec_type;

    l_v_ld_cal_type             igs_ca_inst.cal_type%TYPE;
    l_n_ld_ci_sequence_number   igs_ca_inst.sequence_number%TYPE;
    l_b_return_status           BOOLEAN;
    l_v_message_name            fnd_new_messages.message_name%TYPE;


  BEGIN

    -- If the adjustment amount is NULL, then raise the error message and exit out
    -- of the procedure
    IF p_adj_amount IS NULL THEN
      p_err_msg := 'IGS_FI_INVALID_INV_AMT';
      p_status  := FALSE;
    END IF;

    -- If the Source Transaction Id is null, then exit out of the procedure without any
    -- processing
    IF p_source_transaction_id IS NULL THEN
      p_err_msg := 'IGS_FI_INV_TXN_ID';
      p_status  := FALSE;
    END IF;

    -- Fetch the Invoice Details based on the Source Transaction Id
    OPEN cur_inv(p_source_transaction_id);
    FETCH cur_inv INTO l_inv;
    IF cur_inv%NOTFOUND THEN
      p_err_msg := 'IGS_FI_INV_TXN_ID';
      p_status  := FALSE;
    END IF;
    CLOSE cur_inv;

    IF NOT p_status THEN
      RETURN;
    END IF;

    l_adj_amount := NVL(p_adj_amount,0);

    -- If the Adjustment Amount passed as input to the procedure is
    -- less than the Invoice Amount Due of the procedure
    IF l_adj_amount > NVL(l_inv.invoice_amount_due,0) THEN

      -- Removed condition checking for Manage Accounts = Other
      -- Application/Unapplication by the Fee Assessment process would be allowed even
      -- when Manage Accounts = Other. (Bug 3908040)

        -- Calculate the Difference amount as Adjustment Amount minus the Invoice
        -- Amount Due
        l_diff_amt := l_adj_amount -
                      NVL(l_inv.invoice_amount_due,0);

        -- Loop through the Application Records for the Invoice Id
        FOR apprec IN cur_app(p_source_transaction_id,
                              g_app,
                              g_neg_cr_class,
                              g_unapp) LOOP
          l_appl_rec_exists := TRUE;

          -- Get the Application amount as returned by the procedure get_sum_appl_amnt
          -- This procedure shall sum up the amount applied for all the UNAPP records for the
          -- Application Id and then shall return the difference between the Amount Applied of the Application
          -- record and the UNAPP records
          l_appl_amt := igs_fi_gen_007.get_sum_appl_amnt(apprec.application_id);


          -- If the Difference amount is greater than the Application Amount, then
          IF l_diff_amt > NVL(l_appl_amt,0) THEN

            -- Then Unapplied Amount is the value of the Application record
            l_unapply_amt := NVL(l_appl_amt,0);
          ELSE
            -- Else the Unapply Amount is the Difference amount
            l_unapply_amt := l_diff_amt;
          END IF;

          -- Create an unapplication
          -- Enh 2584986 - Added parameter p_d_gl_date
          igs_fi_gen_007.create_application(p_application_id        => apprec.application_id,
                                            p_credit_id             => g_null,
                                            p_invoice_id            => g_null,
                                            p_amount_apply          => l_unapply_amt,
                                            p_appl_type             => g_unapp,
                                            p_appl_hierarchy_id     => g_null,
                                            p_validation            => g_ind_yes,
                                            p_unapp_amount          => l_unapp_amt,
                                            p_inv_amt_due           => l_inv_amt_due,
                                            p_dr_gl_ccid            => l_dr_gl_ccid,
                                            p_cr_gl_ccid            => l_cr_gl_ccid,
                                            p_dr_account_cd         => l_dr_account_cd,
                                            p_cr_account_cd         => l_cr_account_cd,
                                            p_err_msg               => p_err_msg,
                                            p_status                => p_status,
                                            p_d_gl_date             => p_d_gl_date
                                            );


          -- If the status returned by the create application procedure is FALSE, return
          IF NOT p_status THEN
            RETURN;
          END IF;

          -- The adjustment amount is reduced by the amount unapplied
          l_adj_amount := l_adj_amount - l_unapply_amt;

          -- If the Adjustment Amount is less than 0 then exit
          IF l_adj_amount <=0 THEN
            EXIT;
          END IF;
        END LOOP;

        IF NOT l_appl_rec_exists THEN
          p_status := FALSE;
          p_err_msg := 'IGS_FI_NO_APP_REC';
          RETURN;
        END IF;

    END IF; -- l_adj_amount > NVL(l_inv.invoice_amount_due,0)

    -- Loop through the Credit Types for the Sub Account id
    l_rec_cntr := 0;
    FOR crtrec IN cur_crt(g_neg_cr_class,TRUNC(SYSDATE))
    LOOP
      l_rec_cntr := l_rec_cntr + 1;
      --If there are more than one credit type records for the Negative Credit Class, then this is an error.
      IF l_rec_cntr > 1 THEN
        p_err_msg := 'IGS_FI_ONE_NCA_REC';
        p_status  := FALSE;
        EXIT;
      ELSE
        l_rec_crt := crtrec;
      END IF;
    END LOOP;

    --Bug 3627209, Modified the logic as to return the new message in case if there is no credit type defined for negative charge adjustment credit class.
    IF l_rec_cntr = 0 THEN
      p_err_msg := 'IGS_FI_NO_NCA_REC';
      p_status  := FALSE;
    END IF;

    IF NOT p_status THEN
      RETURN;
    END IF;

    --Get the description of the Credit to be created from the message
    fnd_message.set_name('IGS','IGS_FI_NEG_CHG_ADJ');
    l_cr_desc := fnd_message.get;

    l_credit_id := NULL;


    --Check for validity of the Fee Calendar Instance, whether it is active as on system date.
    IF NOT igs_fi_crdapi_util.validate_cal_inst( p_v_cal_type             => l_inv.fee_cal_type,
                                                 p_n_ci_sequence_number   => l_inv.fee_ci_sequence_number,
                                                 p_v_s_cal_cat            => 'FEE') THEN
    --if not active as on system date, raise error and stop processing further.
      p_status := FALSE;
      p_err_msg := 'IGS_FI_FCI_NOTFOUND';
      RETURN;
    END IF;


    l_v_message_name := NULL;
    --Check if there exists a relation between the Fee Calendar Instance and the Load Calendar Instance...
    igs_fi_crdapi_util.validate_fci_lci_reln( p_v_fee_cal_type            => l_inv.fee_cal_type,
                                              p_n_fee_ci_sequence_number  => l_inv.fee_ci_sequence_number,
                                              p_v_ld_cal_type             => l_v_ld_cal_type,
                                              p_n_ld_ci_sequence_number   => l_n_ld_ci_sequence_number,
                                              p_v_message_name            => l_v_message_name,
                                              p_b_return_stat             => l_b_return_status);
    --if no relation exists, then raise error and stop processing further.
    IF l_b_return_status = FALSE THEN
      p_status := FALSE;
      p_err_msg := l_v_message_name;
      RETURN;
    END IF;


    l_credit_rec.p_credit_status              := g_cleared;
    l_credit_rec.p_credit_source              := g_null;
    l_credit_rec.p_party_id                   := l_inv.person_id;
    l_credit_rec.p_credit_type_id             := l_rec_crt.credit_type_id;
    l_credit_rec.p_credit_instrument          := g_adj;
    l_credit_rec.p_description                := l_cr_desc;
    l_credit_rec.p_amount                     := NVL(p_adj_amount,0);
    l_credit_rec.p_currency_cd                := p_v_currency_cd;
    l_credit_rec.p_exchange_rate              := g_null;
    l_credit_rec.p_transaction_date           := TRUNC(SYSDATE);
    l_credit_rec.p_effective_date             := TRUNC(SYSDATE);
    l_credit_rec.p_source_transaction_id      := g_null;
    l_credit_rec.p_receipt_lockbox_number     := g_null;
    l_credit_rec.p_credit_card_code           := g_null;
    l_credit_rec.p_credit_card_holder_name    := g_null;
    l_credit_rec.p_credit_card_number         := g_null;
    l_credit_rec.p_credit_card_expiration_date:= g_null;
    l_credit_rec.p_credit_card_approval_code  := g_null;
    l_credit_rec.p_invoice_id                 := l_inv.invoice_id;
    l_credit_rec.p_awd_yr_cal_type            := g_null;
    l_credit_rec.p_awd_yr_ci_sequence_number  := g_null;
    l_credit_rec.p_fee_cal_type               := l_inv.fee_cal_type;
    l_credit_rec.p_fee_ci_sequence_number     := l_inv.fee_ci_sequence_number;
    l_credit_rec.p_check_number               := g_null;
    l_credit_rec.p_source_tran_type           := g_null;
    l_credit_rec.p_source_tran_ref_number     := g_null;
    l_credit_rec.p_gl_date                    := p_d_gl_date;
    l_credit_rec.p_v_credit_card_payee_cd     := NULL;
    l_credit_rec.p_v_credit_card_status_code  := NULL;
    l_credit_rec.p_v_credit_card_tangible_cd  := NULL;
    l_credit_rec.p_lockbox_interface_id       := NULL;
    l_credit_rec.p_batch_name                 := NULL;
    l_credit_rec.p_deposit_date               := NULL;

    --Create a credit by calling the Private Credits API with p_validation_level as fnd_api.g_valid_level_none.
    igs_fi_credit_pvt.create_credit(  p_api_version          => 2.1,
                                      p_init_msg_list        => fnd_api.g_false,
                                      p_commit               => fnd_api.g_false,
                                      p_validation_level     => fnd_api.g_valid_level_none,
                                      x_return_status        => l_ret_status,
                                      x_msg_count            => l_msg_count,
                                      x_msg_data             => l_msg_data,
                                      p_credit_rec           => l_credit_rec,
                                      p_attribute_record     => l_attr_rec,
                                      x_credit_id            => l_credit_id,
                                      x_credit_activity_id   => l_credit_activity_id,
                                      x_credit_number        => l_v_credit_number);

    --If the Private Credits API returns an error, then exit.
    IF l_ret_status <> 'S' THEN
      p_status  := FALSE;
      RETURN;
    END IF;

      -- Removed condition checking for Manage Accounts = Other
      -- Application/Unapplication by the Fee Assessment process would be allowed even
      -- when Manage Accounts = Other. (Bug 3908040)

      l_application_id := NULL;

      -- Create an application record
      -- Enh 2584986 - Added parameter p_d_gl_date

      igs_fi_gen_007.create_application(p_application_id        => l_application_id,
                                        p_credit_id             => l_credit_id,
                                        p_invoice_id            => l_inv.invoice_id,
                                        p_amount_apply          => NVL(p_adj_amount,0),
                                        p_appl_type             => g_app,
                                        p_appl_hierarchy_id     => g_null,
                                        p_validation            => g_ind_yes,
                                        p_unapp_amount          => l_unapp_amt,
                                        p_inv_amt_due           => l_inv_amt_due,
                                        p_dr_gl_ccid            => l_dr_gl_ccid,
                                        p_cr_gl_ccid            => l_cr_gl_ccid,
                                        p_dr_account_cd         => l_dr_account_cd,
                                        p_cr_account_cd         => l_cr_account_cd,
                                        p_err_msg               => p_err_msg,
                                        p_status                => p_status,
                                        p_d_gl_date             => p_d_gl_date
                                       );
      IF NOT p_status THEN
        RETURN;
      END IF;

    p_status  := TRUE;
    p_err_msg := NULL;
  END proc_neg_chg;

  FUNCTION validate_neg_amt(p_person_id              IN          igs_fi_inv_int.person_id%TYPE,
                            p_fee_type               IN          igs_fi_inv_int.fee_type%TYPE,
                            p_fee_cal_type           IN          igs_fi_inv_int.fee_cal_type%TYPE,
                            p_fee_ci_sequence_number IN          igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                            p_fee_cat                IN          igs_fi_inv_int.fee_cat%TYPE,
                            p_course_cd              IN          igs_fi_inv_int.course_Cd%TYPE,
                            p_uoo_id                 IN          igs_fi_invln_int.uoo_id%TYPE,
                            p_location_cd            IN          igs_fi_invln_int.location_cd%TYPE,
                            p_transaction_type       IN          igs_fi_inv_int.transaction_type%TYPE,
                            p_amt                    IN          igs_fi_inv_int.invoice_amount%TYPE,
                            p_source_txn_id          IN          igs_fi_inv_int.invoice_id%TYPE)
/***********************************************************************************************

  Created By:         Amit Gairola

  Date Created By:    24-01-2002

  Purpose:            This procedure validates if the amount passed for adjust

  Known limitations,enhancements,remarks:

  Change History

  Who        When          What
  svuppala  05-May-2006    Bug 3924836; Formated amounts by rounding off to currency precision
  agairola   11-Mar-2003   Bug 2762740: Following modifications were done
                           1. Modified the return type for this procedure from Boolean to
                              Number
                           2. Modified the cursor cur_val_chg to include error account and
                              group by
                           3. In case there are some error account transactions, return value
                              is 1.
                           4. For the existing validation related to amount, return value is 2.
                           5. For normal completion, return value is 0.

***********************************************************************************************/
  RETURN NUMBER AS

-- Cursor for getting the sum of the Invoice Amount and the Invoice Amount Due


    CURSOR cur_val_chg(cp_person_id              igs_pe_person.person_id%TYPE,
                       cp_fee_type               igs_fi_fee_type.fee_type%TYPE,
                       cp_fee_cal_type           igs_ca_inst.cal_type%TYPE,
                       cp_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                       cp_fee_cat                igs_fi_fee_cat.fee_cat%TYPE,
                       cp_course_cd              igs_ps_ver.course_cd%TYPE,
                       cp_uoo_id                 igs_fi_invln_int.uoo_id%TYPE,
                       cp_location_cd            igs_fi_invln_int.location_cd%TYPE,
                       cp_transaction_type       igs_fi_inv_int.transaction_type%TYPE,
                       cp_invoice_id             igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT SUM(invoice_amount) inv_amt,
             SUM(invoice_amount_due) inv_due,
             iln.error_account
      FROM   igs_fi_inv_int inv,
             igs_fi_invln_int iln
      WHERE  inv.invoice_id = iln.invoice_id
      AND    ((cp_invoice_id IS NULL
      AND    inv.person_id              = cp_person_id
      AND    inv.fee_type               = cp_fee_type
      AND    inv.fee_cal_type           = cp_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND    inv.transaction_type       = cp_transaction_type
      AND     ((inv.fee_cat = cp_fee_cat)
                OR (inv.fee_cat IS NULL and cp_fee_cat IS NULL))
      AND     ((iln.uoo_id = cp_uoo_id)
                OR (iln.uoo_id IS NULL and cp_uoo_id IS NULL))
      AND     ((iln.location_cd = cp_location_cd)
                OR (iln.location_cd IS NULL and cp_location_cd IS NULL))
      AND     ((inv.course_cd = cp_course_cd)
                OR (inv.course_cd IS NULL and cp_course_cd IS NULL)))
      OR      (inv.invoice_id = cp_invoice_id))
      AND     NOT EXISTS (SELECT 'x'
                          FROM   igs_fi_credits fc,
                                 igs_fi_cr_types crt,
                                 igs_fi_applications app
                          WHERE  app.invoice_id         = inv.invoice_id
                          AND    app.credit_id          = fc.credit_id
                          AND    fc.status              = g_cleared
                          AND    fc.credit_type_id      = crt.credit_type_id
                          AND    crt.credit_class       = g_neg_cr_class
                          AND    app.amount_applied     = inv.invoice_amount)
      GROUP BY iln.error_account;
    l_inv_amt        cur_val_chg%ROWTYPE;
    l_val_err        VARCHAR2(1);

    l_ret_val        NUMBER(2);

  BEGIN

-- Fetch the Invoice Amount and Invoice Amount due for the Cursor
    l_ret_val := 0;

    FOR l_chg_rec IN cur_val_chg(p_person_id,
                                 p_fee_type,
                                 p_fee_cal_type,
                                 p_fee_ci_sequence_number,
                                 p_fee_cat,
                                 p_course_cd,
                                 p_uoo_id,
                                 p_location_cd,
                                 p_transaction_type,
                                 p_source_txn_id) LOOP
      IF l_chg_rec.error_account = g_ind_yes THEN
        l_ret_val := 1;
        EXIT;
      ELSE
        l_chg_rec.inv_due := igs_fi_gen_gl.get_formatted_amount(l_chg_rec.inv_due);
        l_chg_rec.inv_amt := igs_fi_gen_gl.get_formatted_amount(l_chg_rec.inv_amt);
        l_inv_amt.inv_due := NVL(l_inv_amt.inv_due,0) + NVL(l_chg_rec.inv_due,0);
        l_inv_amt.inv_amt := NVL(l_inv_amt.inv_amt,0) + NVL(l_chg_rec.inv_amt,0);
      END IF;
    END LOOP;

    IF l_ret_val = 1 THEN
      RETURN l_ret_val;
    END IF;


-- Assign the due amount to the global variable for Invoice Amount Due
    g_inv_amt_due := l_inv_amt.inv_due;

-- If the Invoice Amount is less than the adjustment amount
    IF NVL(l_inv_amt.inv_amt,0) < ABS(NVL(p_amt,0)) THEN

-- then return
      RETURN 2;
    ELSE
      RETURN 0;
    END IF;

  END validate_neg_amt;

  PROCEDURE create_charge(p_api_version            IN               NUMBER,
                          p_init_msg_list          IN               VARCHAR2 := FND_API.G_FALSE,
                          p_commit                 IN               VARCHAR2 := FND_API.G_FALSE ,
                          p_validation_level       IN               NUMBER := FND_API.G_VALID_LEVEL_FULL ,
                          p_header_rec             IN               header_rec_type,
                          p_line_tbl               IN               Line_Tbl_Type,
                          x_invoice_id            OUT NOCOPY               NUMBER,
                          x_line_id_tbl           OUT NOCOPY               line_id_tbl_type,
                          x_return_status         OUT NOCOPY               VARCHAR2,
                          x_msg_count             OUT NOCOPY               NUMBER,
                          x_msg_data              OUT NOCOPY               VARCHAR2,
                          x_waiver_amount         OUT NOCOPY        NUMBER) AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    03-05-2001

Purpose:            This procedure is the main procedure for creating the charges.

Known limitations,enhancements,remarks:

Change History

Who        When        What
skharida  26-Jun-2006  Bug 5208136 - Removed the obsoleted columns of the table IGS_FI_INV_INT_ALL
akandreg  20-Jun-2006  Bug 5116519 - The Message 'IGS_FI_INVALID_FTCI' is modified .The old token FEE_CAL_TYPE
                       is replaced by new token CI_DESC and passed fee CI description to that. Also the cursor
                       cur_alt_cd_desc is modified to select another column 'description' from igs_ca_inst_all.
pathipat  12-Jun-2006  Bug 5306868 - Modified cursor cur_chg: Added filter on invoice_amount_due
                       and removed ORDER_BY on diff_amt
                       Added cursors cur_chgadj, cur_charges, associated code and local variables.
sapanigr  29-May-2006  Bug 5251760 Added cursor cur_chg_inv. Removed UNION in cur_chg. Modified related code appropriately
svuppala  05-May-2006  Bug 3924836; Added l_n_invoice_amount, l_n_amount variables to
                       format amounts by rounding off to currency precision
sapanigr  03-May-2006  Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_inv_int
                       and igs_fi_invln_int are now rounded off to currency precision
sapanigr  24-Feb-2006  Bug 5018036 - Removed cursor 'cur_ret' and cursor variable 'l_ret_rec' as it was not being used anywhere in the code.
sapanigr  09-Feb-2006  Bug 5018036 - Modifed cursor 'cur_ret' to take values from base table 'igs_fi_f_typ_ca_inst_all'.
                       The view igs_fi_f_typ_ca_inst_lkp_v used earlier lead to high shared memory usage.
abshriva  24-Oct-2005  Bug 4680553 - The Message 'IGS_FI_WAV_TRANS_CREATED'  was removed as it was being
                                      called in error page when waiver transaction was successful
pathipat  05-Oct-2005  Bug 4383148 - Fees not assessed if attendance type cannot be derived
                       Removed invocation of validate_atd_mode and validate_atd_type
svuppala  07-JUL-2005  Enh 3392095 - Tution Waivers build
                       Modified HEADER_REC_TYPE -- included waiver_name.
                       Modified l_api_version
gurprsin   02-Jun-2005 Enh# 3442712 Modified TBH call of table IGS_fi_invln_int_all
                       i.e. igs_fi_inv_int_pkg.insert_row to include unit_type_id and unti_level
pmarada    26-May-2005 Enh#3020586- added tax year code column as per 1098-t reporting build
uudayapr   08-Mar-2004 Bug#3478599.Added the code to prevent charge creation with
                                   error account as Y for Transaction Type as
                                   Document when Revenue Account Derivation fails.
vvutukur   27-Jun-2003 Bug#2849185.Bypassed unncessary validations in case of negative charge.
jbegum     20-Jun-2003 Bug# 2998266, NEXT_INVOICE_NUMBER in the IGS_FI_CONTROL table will not be used for
                       generating unique charge numbers. Next Value from a DB sequence will be used for
                       for generating unique charges numbers.
                       Removed the call to IGS_FI_CONTROL_PKG.update_row
vvutukur   16-Jun-2003 Enh#2831582.Lockbox Build. Removed 3 columns(lockbox_context,lockbox_number,attribute,ar_int_org_id)
                       from igs_fi_control_pkg.update_row.
vvutukur   26-May-2003 Enh#2831572.Financial Accounting Build. Changes as specified in TD.
shtatiko   05-MAY-2003 Enh# 2831569, Added check Manage Accounts System Option before creating a charge.
                       And updation of Holds or Standard balances is done only if its value is STUDENT_FINANCE.
pathipat   14-Apr-2003 Enh 2831569 - Commercial Receivables Interface build
                       Modified call to igs_fi_control_pkg.update_row
vvutukur   11-Apr-2003 Enh#2831554.Internal Credits API Build. Added checks to validate ADJ credit instrument,charge method and transaction type.
agairola   11-Mar-2003 Bug 2762740: 1. Modified the call to the validate_neg_amnt.
                                    2. Added a new variable l_val_neg_amnt and this variable
                                       gets the value from validate_neg_amnt
                                    3. Added the code to check for l_val_neg_amnt = 1
                                    4. Modified the code for the amount validation(l_val_neg_amnt=2)
smadathi   18-Feb-2002 Enh. Bug 2747329.Modified the TBH call to IGS_FI_CONTROL to Add new columns
                        rfnd_destination, ap_org_id, dflt_supplier_site_name
pathipat   14-Nov-2002 Enh Bug: 2584986 -
                       1.  Added parameters gl_date, gl_posted_date and posting_control_id
                           in the call to igs_fi_invln_int_pkg.insert_row()
                       2.  Added parameter p_gl_date in call to proc_neg_chg() for negative charges
                       3.  Removed calls to get_local_amount, passed the invoice_amount and currency_cd
                           directly from p_header_rec, instead of conversion to local currency
vvutukur   20-sep-2002 Enh#2562745.1)Added conv_process_run_ind parameter to call to igs_fi_control_pkg.
                       update_row.2)Added call to igs_fi_prc_balance.update_balances to update the Holds
                       Balance real time whenever a charge gets created.3)Added two new validations to
                       error out of charges api in the following scenarios.a)if holds conversion process
                       is running b)if no active balance rule exist for HOLDS.
vvutukur   16-Sep-2002 Enh#2564643.Removed references to subaccount_id.ie.,Removed call to the private
                       function validate_subaccount and its related code.Removed declaration of local
                       variables l_party_subaccount_id,l_subacc_name.Removed cursor cur_sa.Removed
                       reference to subaccount_id from the calls to IGS_FI_INV_INT_PKG.Insert_Row and
                       igs_fi_prc_balances.update_balances.Removed call to igs_fi_gen_005.validate_psa
                       since the function igs_fi_gen_005.validate_psa is being removed.Removed call to
                       igs_fi_party_sa_pkg.insert_row as the table igs_fi_party_sa is being obsoleted.
                       Also added 7 new parameters to the call to igs_fi_control_pkg.update_row.
smadathi   03-Jul-2002   Bug 2443082. Modified update_balances procedure call. Modified to pass transaction date
                         instead of system date.
agairola   10-Jun-2002 Bug Number: 2407624 Modified the call to the Get_Local_Amount
agairola   17-May-2002 Following modifications were done for the bug 2323555 - Call Build Accounts
                       procedure is called in all cases even if the accounts are passed.
                       Also assigned the value of the accounts passed as input to the Charges API
                       to the local variables used in the call to Call Build Accounts procedure
SYkrishn   15-APR-2002     Added planned_credits_ind to the IGS_FI_CONTROL_PKG.update_row call as part of Enh 2293676
smvk       08-Mar-2002  Added four attributes refund_dr_gl_ccid,refund_cr_gl_ccid,refund_dr_account_cd,
                        refund_cr_account_cd and removed three attributes last_account_trans,last_payment_trans,
                        last_pay_term_trans to the call to IGS_FI_CONTROL_PKG.Update_row as per Bug #2144600
vvutukur   27-02-2002   added call to igs_fi_gen_007.validate_person instead of calling local function
                        validate_person for bug:2238362
vvutukur   18-feb-2002  added ar_int_org_id column to igs_fi_control_pkg.update_row call. bug:2222272
jbegum     14-Feb-2001   As part of Enh bug # 2201081
                         Added call to IGS_FI_GEN_005.validate_psa and IGS_FI_PARTY_SA_PKG.insert_row
                         Removed cursor cur_psa
kkillams   01-08-2001  Modification done w.r.t student finance dld bug id :1882122
                       Build accounting process is calling only if these parameters are
                       don't have values p_override_dr_rec_ccid, p_override_cr_rev_ccid,
                       p_override_dr_rec_account_cd and p_override_cr_rev_account_cd
                       before inserting the data into igs_fi_invln_int.
jbegum     26-Sep-2001 As part of bug #1962286 the following changes were done:
                       Changed the call to the local function validate_uoo.
                       Changed the call to IGS_FI_INVLN_INT_PKG.Insert_row.
vchappid   05-Oct-2001 As a part of Enh Bug#2030448, the call to the calculate balances process is
                       replaced with a call to the new procedure Update_Balances created as a part
                       of the SFCR010. Limitation of the Accounting Method to CASH is removed,
                       Balance_Flag has been removed from IGS_FI_INV_INT_ALL, IGS_FI_CREDITS_ALL tables,
                       New column optional_fee_flag column is added in IGS_FI_INV_INT_ALL Table.
smadathi   12-oct-2001 As part of enhancement bug#2042716 , the TBH calls to
                       IGS_FI_PARTY_SUBACTS modified . Payment_plan_flag added.
jbegum     19-Nov-2001 As part of Enhancement bug #2113459 the following changes were done:
                       Added a new cursor cur_ret.
                       Added an if condition that checks for transaction type RETENTION.
                       If transaction type is RETENTION then creates the credit and debit side of
                       retention charge.

nalkumar  19-Dec-2001  Changed the call to IGS_FI_PARTY_SUBACTS_PKG.insert_row.
                       This is as per the SF015 Holds DLD. Bug# 2126091.
agairola  12-Feb-2002  Changed the functionality for creation of the negative charges as per the DLD
                       specfied for the negative charges. SFCR003 Bug No: 2195715
********************************************************************************************** */

    l_api_name       CONSTANT VARCHAR2(30) := 'Create_Charge';
    l_api_version    CONSTANT NUMBER       := 2.0;
    l_bool                    BOOLEAN;
    l_valid                   BOOLEAN := TRUE;
    l_line_cnt                NUMBER       := 1;
    l_var                     NUMBER;
    l_acnt_mthd               IGS_FI_CONTROL.Accounting_Method%TYPE;
    l_rowid                   VARCHAR2(25);
    l_application_id          igs_fi_applications.application_id%TYPE;
    l_unapplied_amount        igs_fi_credits.unapplied_amount%TYPE;
    l_invoice_lines_id        igs_fi_invln_int.invoice_lines_id%TYPE;
    l_invoice_id              igs_fi_inv_int.invoice_id%TYPE;
    l_temp                    VARCHAR2(1);
    l_org_id                  igs_fi_inv_int.org_id%TYPE := igs_ge_gen_003.get_org_id;
    l_ret                     VARCHAR2(1);
    l_adj_amt                 igs_fi_inv_int.invoice_amount%TYPE;
    l_amt_neg_chg             igs_fi_inv_int.invoice_amount%TYPE;
    l_err_msg                 VARCHAR2(100);
    l_status                  BOOLEAN;
    l_rec_exist               BOOLEAN;
 --
 -- these variable are added w.r.t finance accounting  bug no : 1882122
    l_error_string             igs_fi_invln_int.error_string%TYPE;
    l_flag                     NUMBER;
    l_error_account            VARCHAR2(1) := 'N';
    l_dr_gl_ccid               igs_fi_invln_int_all.rec_gl_ccid%TYPE;
    l_cr_gl_ccid               igs_fi_invln_int_all.rev_gl_ccid%TYPE;
    l_dr_account_cd            igs_fi_invln_int_all.rec_account_cd%TYPE;
    l_cr_account_cd            igs_fi_invln_int_all.rev_account_cd%TYPE;

    l_message_name             fnd_new_messages.message_name%TYPE := NULL;
    l_n_invoice_amount         igs_fi_inv_int_all.invoice_amount%TYPE;
    l_n_amount                 igs_fi_invln_int_all.amount%TYPE;

-- Cursor for getting the record from the Charges table based on the invoice id
-- passed to the cursor
    CURSOR cur_inv(cp_invoice_id        igs_fi_inv_int.Invoice_Id%TYPE) IS
      SELECT rowid,
             igs_fi_inv_int.*
      FROM   igs_fi_inv_int
      WHERE  invoice_id = cp_invoice_id;

-- Cursor for getting the records from the Applications table based on the
-- invoice id and the application type as APP
    CURSOR cur_app(cp_invoice_id        igs_fi_inv_int.Invoice_Id%TYPE,
                   cp_app               VARCHAR2) IS
      SELECT rowid,
             igs_fi_applications.*
      FROM   igs_fi_applications
      WHERE  invoice_id           = cp_invoice_id
      AND    application_type     = cp_app;

-- Cursor for getting the credit record.
    CURSOR cur_crd(cp_credit_id         igs_fi_credits.Credit_Id%TYPE) IS
      SELECT rowid,
             igs_fi_credits.*
      FROM   igs_fi_credits
      WHERE  credit_id      = cp_credit_id;

-- Cursor for getting the record from the IGS_FI_CONTROL table
    CURSOR cur_ctrl IS
      SELECT rowid,
             igs_fi_control.*
      FROM   igs_fi_control;

-- Cursor for selecting all the charges based on the Person Id, Fee Type, Fee Cal Type,
-- Fee Calendar Instance, Fee Category, Course Cd, Transaction type, Unit Section Id
-- and the location code. If the invoice id is passed as input to the cursor then this is
-- used to select the charges. The charges are ordered by the Invoice Amount Due in
-- descending order
    CURSOR cur_chg(cp_person_id              igs_pe_person.person_id%TYPE,
                   cp_fee_type               igs_fi_fee_type.fee_type%TYPE,
                   cp_fee_cal_type           igs_ca_inst_all.cal_type%TYPE,
                   cp_fee_ci_sequence_number igs_ca_inst_all.sequence_number%TYPE,
                   cp_fee_cat                igs_fi_fee_cat.fee_cat%TYPE,
                   cp_course_cd              igs_ps_ver.course_cd%TYPE,
                   cp_transaction_type       igs_fi_inv_int_all.transaction_type%TYPE,
                   cp_uoo_id                 igs_fi_invln_int_all.uoo_id%TYPE,
                   cp_location_cd            igs_fi_invln_int_all.location_cd%TYPE,
                   cp_invoice_id             igs_fi_inv_int_all.invoice_id%TYPE) IS
      SELECT inv.rowid row_id,
             inv.invoice_id invoice_id,
             inv.invoice_amount_due invoice_amount_due,
             inv.invoice_amount invoice_amount
      FROM   igs_fi_inv_int_all inv,
             igs_fi_invln_int_all iln
      WHERE  inv.invoice_id = iln.invoice_id
      AND    inv.person_id              = cp_person_id
      AND    inv.fee_type               = cp_fee_type
      AND    inv.fee_cal_type           = cp_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND    inv.transaction_type       = cp_transaction_type
      AND    iln.error_account         <> g_ind_yes
      AND    inv.invoice_amount_due > 0
      AND     ((iln.uoo_id = cp_uoo_id)
                OR (iln.uoo_id IS NULL AND cp_uoo_id IS NULL))
      AND     ((iln.location_cd = cp_location_cd)
                OR (iln.location_cd IS NULL AND cp_location_cd IS NULL))
      AND     ((fee_cat = cp_fee_cat)
                OR (fee_cat IS NULL and cp_fee_cat IS NULL))
      AND     ((course_cd = cp_course_cd)
                OR (course_cd IS NULL and cp_course_cd IS NULL))
      ORDER BY invoice_amount_due DESC;

    -- Cursor for selecting all the charges based on the Invoice ID. This is used if the invoice_id has been passed.
    CURSOR cur_chg_inv(cp_invoice_id   igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT inv.rowid row_id,
             inv.invoice_id,
             inv.invoice_amount_due,
             inv.invoice_amount
      FROM   igs_fi_inv_int_all inv
      WHERE  inv.invoice_id = cp_invoice_id
      AND    inv.invoice_amount_due > 0
      ORDER BY invoice_amount_due DESC;

     --3392095 cursor to check whether waiver programs exists or not
      CURSOR cur_waiver(cp_fee_cal_type                      igs_fi_inv_int.fee_cal_type%TYPE,
                        cp_fee_ci_sequence_number            igs_fi_inv_int.fee_ci_sequence_number%TYPE,
                        cp_waiver_name                       igs_fi_inv_int.waiver_name%TYPE) IS
      SELECT   'X'
      FROM     igs_fi_waiver_pgms fwp
      WHERE    fwp.fee_cal_type            = cp_fee_cal_type
      AND      fwp.fee_ci_sequence_number  = cp_fee_ci_sequence_number
      AND      fwp.waiver_name             = cp_waiver_name;

    l_n_waiver_amount       NUMBER;
    l_v_return_status       VARCHAR2(1);
    l_n_msg_count           NUMBER      ;
    l_v_msg_data            VARCHAR2(32767) ;
    l_v_waiver_exists       VARCHAR2(1);

    l_rec_chg_inv             cur_chg_inv%ROWTYPE;

    l_ctrl_rec                cur_ctrl%ROWTYPE;

    l_sum_amt_due             igs_fi_inv_int.invoice_amount_due%TYPE;

    l_validate_flag           BOOLEAN;
    l_valid_person            VARCHAR2(1);    --bug:2238362

    l_cnv_prc                 igs_fi_control.conv_process_run_ind%TYPE := NULL;
    l_hold_bal_type           CONSTANT igs_fi_balance_rules.balance_name%TYPE := 'HOLDS';
    l_action_active           CONSTANT VARCHAR2(10) := 'ACTIVE';
    l_version_number          igs_fi_balance_rules.version_number%TYPE;
    l_last_conversion_date    DATE;
    l_balance_rule_id         igs_fi_balance_rules.balance_rule_id%TYPE;

    l_val_neg_amnt            NUMBER(2);
    l_v_manage_accounts       igs_fi_control_all.manage_accounts%TYPE;
    l_v_message_name          fnd_new_messages.message_name%TYPE;


    -- Bug #2998266 Added the following cursor
    CURSOR c_get_nextval
    IS
    SELECT igs_fi_inv_int_all_s1.NEXTVAL
    FROM DUAL;
    l_n_get_nextval NUMBER;

    l_v_igs_fi_auto_calc_waivers             VARCHAR2(1);

    --Cursor to get alternate code, description to pass as token for IGS_FI_WAV_PGM_NO_REC_FOUND,
    --IGS_FI_INVALID_FTCI respectively
    CURSOR cur_alt_cd_desc(cp_fee_cal_type    igs_ca_inst_all.cal_type%TYPE,
                      cp_fee_ci_sequence_number  igs_ca_inst_all.sequence_number%TYPE) IS
    SELECT alternate_code , description
    FROM igs_ca_inst_all
    WHERE cal_type = cp_fee_cal_type
    AND sequence_number = cp_fee_ci_sequence_number;

    l_v_fee_alt_cd   igs_ca_inst_all.alternate_code%TYPE;
    l_v_fee_ci_desc   igs_ca_inst_all.description%TYPE;

    -- Cursor to pick up all charges following the unique key (or) for a
    -- specific invoice_id (similar to cur_chg, except the ORDER BY clause and check on invoice_amount_due)
    CURSOR cur_charges(cp_person_id              igs_pe_person.person_id%TYPE,
                   cp_fee_type               igs_fi_fee_type.fee_type%TYPE,
                   cp_fee_cal_type           igs_ca_inst.cal_type%TYPE,
                   cp_fee_ci_sequence_number igs_ca_inst.sequence_number%TYPE,
                   cp_fee_cat                igs_fi_fee_cat.fee_cat%TYPE,
                   cp_course_cd              igs_ps_ver.course_cd%TYPE,
                   cp_transaction_type       igs_fi_inv_int.transaction_type%TYPE,
                   cp_uoo_id                 igs_fi_invln_int.uoo_id%TYPE,
                   cp_location_cd            igs_fi_invln_int.location_cd%TYPE,
                   cp_invoice_id             igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT inv.rowid row_id,
             inv.invoice_id invoice_id,
             inv.invoice_amount_due invoice_amount_due,
             inv.invoice_amount invoice_amount
      FROM   igs_fi_inv_int inv,
             igs_fi_invln_int iln
      WHERE  inv.invoice_id = iln.invoice_id
      AND    cp_invoice_id IS NULL
      AND    inv.person_id              = cp_person_id
      AND    inv.fee_type               = cp_fee_type
      AND    inv.fee_cal_type           = cp_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND    inv.transaction_type       = cp_transaction_type
      AND    iln.error_account         <> g_ind_yes
      AND     ((iln.uoo_id = cp_uoo_id)
                OR (iln.uoo_id IS NULL AND cp_uoo_id IS NULL))
      AND     ((iln.location_cd = cp_location_cd)
                OR (iln.location_cd IS NULL AND cp_location_cd IS NULL))
      AND     ((fee_cat = cp_fee_cat)
                OR (fee_cat IS NULL and cp_fee_cat IS NULL))
      AND     ((course_cd = cp_course_cd)
                OR (course_cd IS NULL and cp_course_cd IS NULL))
      ORDER BY invoice_id ASC;

    -- Cursor for selecting all the charges based on the Invoice ID. This is used if the invoice_id has been passed.
    CURSOR cur_charges_inv(cp_invoice_id   igs_fi_inv_int.invoice_id%TYPE) IS
      SELECT inv.rowid row_id,
             inv.invoice_id,
             inv.invoice_amount_due,
             inv.invoice_amount
      FROM   igs_fi_inv_int_all inv
      WHERE  inv.invoice_id = cp_invoice_id
      ORDER BY invoice_id ASC;

      -- Cursor to fetch sum of all negative adjustment credits for a given invoice_id
      CURSOR cur_chgadj(cp_invoice_id   igs_fi_inv_int_all.invoice_id%TYPE) IS
        SELECT SUM(amount_applied)
        FROM   igs_fi_credits fc,
               igs_fi_cr_types crt,
               igs_fi_applications app
        WHERE  app.invoice_id         = cp_invoice_id
        AND    app.credit_id          = fc.credit_id
        AND    fc.status              = g_cleared
        AND    fc.credit_type_id      = crt.credit_type_id
        AND    crt.credit_class       = g_neg_cr_class;

    l_n_elg_amt        igs_fi_inv_int_all.invoice_amount%TYPE;
    l_n_chgadj_amt     igs_fi_applications.amount_applied%TYPE;

  BEGIN


-- Savepoint
    SAVEPOINT create_charge_pvt;
    l_v_igs_fi_auto_calc_waivers   := NVL(FND_PROFILE.VALUE('IGS_FI_AUTO_CALC_WAIVERS'),'N');

-- Check if the API call is compatible
    IF NOT fnd_api.compatible_api_call( l_api_version,
                                        p_api_version,
                                        l_api_name,
                                        g_pkg_name) THEN

-- If the call is incompatible, then raise the unexpected error
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    l_n_invoice_amount := igs_fi_gen_gl.get_formatted_amount(p_header_rec.p_invoice_amount);

-- initialise the table which returns the invice lines id
    x_line_id_tbl.DELETE;

-- If the p_init_msg_list is T, i.e. the calling program wants to initialise
-- the message list, then the message list is initialised using the API call
    IF fnd_api.to_boolean(p_init_msg_list) THEN
      fnd_msg_pub.initialize;
    END IF;

-- Set the return status as success for the api
    x_return_status := fnd_api.g_ret_sts_success;

    -- Get the value of "Manage Accounts" System Option value.
    -- If this value is NULL then this process should error out.
    igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc   => l_v_manage_accounts,
                                                  p_v_message_name => l_v_message_name );
    IF l_v_manage_accounts IS NULL THEN
      fnd_message.set_name ( 'IGS', l_v_message_name );
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    -- Fetch the record from the Control table.
    OPEN cur_ctrl;
    FETCH cur_ctrl INTO l_ctrl_rec;
    CLOSE cur_ctrl;
    --If Oracle General Ledger is not installed and Account Conversion Flag is null, raise error.
    IF l_ctrl_rec.rec_installed = 'N' AND l_ctrl_rec.acct_conv_flag IS NULL THEN
      fnd_message.set_name('IGS','IGS_FI_ACCT_CONV_NOTRUN');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;

    g_v_manage_accounts := l_v_manage_accounts;
    l_v_message_name := NULL;
    -- Check for Holds Balance Conversion Process and Existance of Balance Rule for Holds Balance
    -- are not required if Manage Accounts Option has value OTHER.
    IF l_v_manage_accounts <> 'OTHER' THEN
      igs_fi_gen_007.finp_get_conv_prc_run_ind(
                                p_n_conv_process_run_ind => l_cnv_prc,
                                p_v_message_name         => l_message_name
                                               );

      --If Holds Balance conversion process is running..error out from Charges API.
      IF l_cnv_prc = 1 AND l_message_name IS NULL THEN
        fnd_message.set_name('IGS','IGS_FI_REASS_BAL_PRC_RUN');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      IF l_message_name IS NOT NULL THEN
        fnd_message.set_name('IGS',l_message_name);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;

      --Get the latest active balance rule for 'HOLDS' balance type.
      igs_fi_gen_007.finp_get_balance_rule(
                                      p_v_balance_type    => l_hold_bal_type,
                                      p_v_action          => l_action_active,
                                      p_n_balance_rule_id => l_balance_rule_id,
                                      p_d_last_conversion_date=> l_last_conversion_date,
                                      p_n_version_number  => l_version_number
                                           );

      --If no active balance rule exists for 'HOLDS', error out Charges API.
      IF l_version_number = 0 THEN
        fnd_message.set_name('IGS','IGS_FI_CANNOT_CRT_TXN');
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

-- Check if there are records in the Lines table being input to API

  IF p_line_tbl.COUNT = 0 THEN
    IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
      fnd_message.set_name('IGS','IGS_FI_SAT_NO_ROWS_FOUND');
      fnd_msg_pub.add;
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;

  --Following validations are not necessary to be performed in case of negative charges
  --because in case of negative charges, only a credit will be created.
  IF ( NVL(l_n_invoice_amount,0) >= 0 ) THEN
-- Call the function for validating the person id
    l_valid_person:= igs_fi_gen_007.validate_person(p_header_rec.p_person_id); --bug:2238362

-- If the function returns false, then
    IF l_valid_person = 'N' THEN    --bug:2238362

-- Add the message to the Message list and error out.
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        l_valid := FALSE;
        fnd_message.set_name('IGS','IGS_FI_INVALID_PERSON');
        fnd_message.set_token('PERSON_ID',TO_CHAR(p_header_rec.p_person_id));
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;


-- Call the function for validating the Fee Type Calendar Instance
    l_bool := validate_ftci(p_header_rec.p_fee_cal_type,
                            p_header_rec.p_fee_ci_sequence_number,
                            p_header_rec.p_fee_type,
                            p_header_rec.p_transaction_type);

-- If the function returns false then
    IF NOT l_bool THEN
      -- Add the message to the message list and error out.
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
    --Fetch the cursor to get FEE CI description to pass as token for IGS_FI_INVALID_FTCI
          OPEN cur_alt_cd_desc(p_header_rec.p_fee_cal_type,
                               p_header_rec.p_fee_ci_sequence_number);
          FETCH cur_alt_cd_desc INTO  l_v_fee_alt_cd, l_v_fee_ci_desc;
          CLOSE cur_alt_cd_desc;

        l_valid := FALSE;
        fnd_message.set_name('IGS','IGS_FI_INVALID_FTCI');
        fnd_message.set_token('FEE_TYPE',p_header_rec.p_fee_type);
        fnd_message.set_token('CI_DESC',l_v_fee_ci_desc);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
-- call the function for validating the Fee Category Fee Liability
    IF p_header_rec.p_fee_cat IS NOT NULL THEN
      l_bool := validate_fcfl(p_header_rec.p_fee_cat,
                              p_header_rec.p_fee_type,
                              p_header_rec.p_transaction_type);

-- If the function returns false then
      IF NOT l_bool THEN
        -- Add the message to the Message list and error out.
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          l_valid := FALSE;
          fnd_message.set_name('IGS','IGS_FI_INVALID_FCFL');
          fnd_message.set_token('FEE_CAT',p_header_rec.p_fee_cat);
          fnd_message.set_token('FEE_TYPE',p_header_rec.p_fee_type);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;
-- Call the function for validating the Program
    IF p_header_rec.p_course_cd IS NOT NULL THEN
      l_bool := validate_course(p_header_rec.p_course_cd);

-- If the function returns false, then
      IF NOT l_bool THEN
        -- Add the message to the Message list and error out.
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          l_valid := FALSE;
          fnd_message.set_name('IGS','IGS_FI_INVALID_COURSE');
          fnd_message.set_token('COURSE_CD',p_header_rec.p_course_cd);
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

--Removed the code that deals with the validation of the parameter p_header_rec.p_subaccount_id as
--part of subaccount removal build. Enh#2564643.

-- Validate if the transaction type passed is a valid transaction type
    l_bool := igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type        => g_transaction_type,
                                                   p_v_lookup_code        => p_header_rec.p_transaction_type);

-- If the function returns false, then
    IF NOT l_bool THEN
      -- Add the message to the message stack and error out.
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        l_valid := FALSE;
        fnd_message.set_name('IGS','IGS_FI_INVALID_TXN_TYPE');
        fnd_message.set_token('TXN_TYPE',p_header_rec.p_transaction_type);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;

    -- Validate if the currency code passed is a valid currency code
    l_bool := validate_cur(p_header_rec.p_currency_cd);

    -- If the currency code is invalid, then
    IF NOT l_bool THEN
      -- Add the message to the message list and error out.
      -- Error message changed as part of bug 2584986
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        l_valid := FALSE;
        fnd_message.set_name('IGS','IGS_FI_INVALID_CUR');
        fnd_message.set_token('CUR_CD',p_header_rec.p_currency_cd);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;
    --3392095 check for waiver_name
    IF p_header_rec.p_waiver_name IS NOT NULL THEN

      OPEN cur_waiver(p_header_rec.p_fee_cal_type,
                      p_header_rec.p_fee_ci_sequence_number,
                      p_header_rec.p_waiver_name);

      FETCH cur_waiver INTO l_v_waiver_exists;
      IF cur_waiver%NOTFOUND THEN
        CLOSE cur_waiver;
          --Cursor to get alternate code to pass as token for IGS_FI_WAV_PGM_NO_REC_FOUND
          OPEN cur_alt_cd_desc(p_header_rec.p_fee_cal_type,
                          p_header_rec.p_fee_ci_sequence_number);
          FETCH cur_alt_cd_desc INTO l_v_fee_alt_cd, l_v_fee_ci_desc;
          CLOSE cur_alt_cd_desc;

        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            fnd_message.set_name('IGS','IGS_FI_WAV_PGM_NO_REC_FOUND');
            fnd_message.set_token('FEE_ALT_CD',l_v_fee_alt_cd);
            fnd_message.set_token('FEE_TYPE',p_header_rec.p_fee_type);
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
      CLOSE cur_waiver;

    END IF;


    --Check for validity of the credit instrument 'ADJ' as on system date.
    IF NOT igs_fi_crdapi_util.validate_igs_lkp( p_v_lookup_type => 'IGS_FI_CREDIT_INSTRUMENT',
                                                p_v_lookup_code => g_adj) THEN
      --If not valid, then raise error and stop processing further.
      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
        fnd_message.set_name('IGS','IGS_FI_CAPI_CRD_INSTR_NULL');
        fnd_message.set_token('CR_INSTR',g_adj);
        fnd_msg_pub.add;
        RAISE fnd_api.g_exc_error;
      END IF;
    END IF;


-- Loop through the table
    FOR l_var IN p_line_tbl.FIRST..p_line_tbl.LAST LOOP

-- Validate if the Charge Method passed is a valid lookup
      IF p_line_tbl(l_var).p_s_chg_method_type IS NOT NULL THEN
        l_bool := igs_fi_crdapi_util.validate_igs_lkp(p_v_lookup_type   => g_chg_method,
                                                      p_v_lookup_code   => p_line_tbl(l_var).p_s_chg_method_type);

-- If the charge method passed for one of the records is not valid, then
        IF NOT l_bool THEN
          -- Add the message to the message list and error out.
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            l_valid := FALSE;
            fnd_message.set_name('IGS','IGS_FI_INV_CHG_MTHD_TYPE');
            fnd_message.set_token('CHG_METHOD',p_line_tbl(l_var).p_s_chg_method_type);
            fnd_msg_pub.add;
            EXIT;
          END IF;
        END IF;
      END IF;
    END LOOP;

-- If the global variable has been set to false, then this means
-- that one of the charge methods were invalid, hence error out.
    IF NOT l_valid THEN
      RAISE fnd_api.g_exc_error;
    END IF;
-- Loop through the table for the Unit Section
    FOR l_var IN p_line_tbl.FIRST..p_line_tbl.LAST LOOP

-- If the unit section has been passed in the table, then
-- As part of the bug #1962286 p_uoo_id is being checked for NOT NULL instead of p_unit_cd

      IF p_line_tbl(l_var).p_uoo_id IS NOT NULL THEN

-- Call the function for validating the Unit Section

-- As part of the bug #1962286 the call to validate_uoo was modified.
-- Instead of passing all the six UOO columns only the uoo_id is being passed

        l_bool := validate_uoo(p_line_tbl(l_var).p_uoo_id );

-- If the function returns false, then
        IF NOT l_bool THEN
          -- Add the message to the message list
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            l_valid := FALSE;
            fnd_message.set_name('IGS','IGS_FI_INVALID_UOO_ID');
            fnd_msg_pub.add;
            EXIT;
          END IF;
        END IF;
      END IF;
    END LOOP;

-- If the global variable has been set to false, then this means
-- that one of the Unit Sections were invalid, hence error out.
    IF NOT l_valid THEN
      RAISE fnd_api.g_exc_error;
    END IF;


-- Loop through the table
    FOR l_var IN p_line_tbl.FIRST..p_line_tbl.LAST LOOP

-- If the Org_Unit_Cd is passed into the table then
      IF p_line_tbl(l_var).p_org_unit_cd IS NOT NULL THEN

-- Call the function for validating the Org_Unit_Cd
        l_bool := validate_org_unit_cd(p_line_tbl(l_var).p_org_unit_cd);

-- If the function returns false, then
        IF NOT l_bool THEN
          -- Add the message to the message list
          IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
            l_valid := FALSE;
            fnd_message.set_name('IGS','IGS_FI_INVALID_ORG_UNIT_CD');
            fnd_message.set_token('ORG_CD',p_line_tbl(l_var).p_org_unit_cd);
            fnd_msg_pub.add;
            EXIT;
          END IF;
        END IF;
      END IF;
    END LOOP;

-- If the global variable has been set to false, then this means
-- that one of the Org_Unit_Cd were invalid, hence error out.
    IF NOT l_valid THEN
      RAISE fnd_api.g_exc_error;
    END IF;


-- If the Source Transaction Id is not null
    IF p_header_rec.p_source_transaction_id IS NOT NULL THEN

-- Call the procedure for validating the Source Transaction Id
-- This source transaction id should be a valid Invoice Id in the
-- IGS_FI_INV_INT table
      l_bool := validate_source_txn_id(p_header_rec.p_source_transaction_id);

-- If the function returns false, then
      IF NOT l_bool THEN

-- Add the message to the message list and error out.
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          l_valid := FALSE;
          fnd_message.set_name('IGS','IGS_FI_INVALID_SRC_TXN_ID');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;
    END IF;

-- If the global boolean flag has been set, then
-- error out.
    IF NOT l_valid THEN
      RAISE fnd_api.g_exc_error;
    END IF;
  END IF;



-- If the Invoice Amount passed to the Charges API is negative, i.e. it is an adjustment over the
-- earlier charges, then the negative charges processing needs to be done.
    IF NVL(l_n_invoice_amount,0) < 0 THEN
      g_inv_amt_due := 0;

-- validate if the negative amount passed as input to the Charges API is
      l_val_neg_amnt := validate_neg_amt(p_person_id              => p_header_rec.p_person_id,
                                         p_fee_type               => p_header_rec.p_fee_type,
                                         p_fee_cal_type           => p_header_rec.p_fee_cal_type,
                                         p_fee_ci_sequence_number => p_header_rec.p_fee_ci_sequence_number,
                                         p_fee_cat                => p_header_rec.p_fee_cat,
                                         p_course_cd              => p_header_rec.p_course_cd,
                                         p_uoo_id                 => p_line_tbl(1).p_uoo_id,
                                         p_location_cd            => p_line_tbl(1).p_location_cd,
                                         p_transaction_type       => p_header_rec.p_transaction_type,
                                         p_source_txn_id          => p_header_rec.p_source_transaction_id,
                                         p_amt                    => l_n_invoice_amount);

-- If the validate negative amount procedure returns an error, then exit out of the charges api
      IF l_val_neg_amnt = 1 THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          l_valid := FALSE;
          fnd_message.set_name('IGS','IGS_FI_SRC_TXN_ACC_INV');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      ELSIF l_val_neg_amnt = 2 THEN
        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
          l_valid := FALSE;
          fnd_message.set_name('IGS','IGS_FI_INVALID_INV_AMT');
          fnd_msg_pub.add;
          RAISE fnd_api.g_exc_error;
        END IF;
      END IF;

      l_rec_exist := FALSE;
      l_adj_amt := NVL(ABS(l_n_invoice_amount),0);

      -- If Invoice ID has been passed, use cursor cur_chg_inv
      IF p_header_rec.p_source_transaction_id IS NOT NULL THEN
           OPEN cur_chg_inv(p_header_rec.p_source_transaction_id);
           FETCH cur_chg_inv INTO l_rec_chg_inv;
           IF cur_chg_inv%FOUND THEN
             CLOSE cur_chg_inv;
             IF NOT(chk_charge_adjusted(p_header_rec.p_source_transaction_id, l_rec_chg_inv.invoice_amount)) THEN
                l_rec_exist := TRUE;

                -- If the Adjustment Amount is greater than 0, then
                IF NVL(l_adj_amt,0) > 0 THEN
                        -- If the validate flag is true i.e. The invoice amount due is greater than the adjustment amount, then
                        -- If the Adjustment Amount is greater than the Invoice Amount Due, then
                        IF NVL(l_adj_amt,0) > NVL(l_rec_chg_inv.invoice_amount_due,0) THEN
                            -- Amount for the negative charge is the invoice amount due
                            l_amt_neg_chg := NVL(l_rec_chg_inv.invoice_amount_due,0);
                        ELSE
                             -- else the amount for the negative charge is the adjustment amount
                            l_amt_neg_chg := NVL(l_adj_amt,0);
                        END IF;

                    -- The adjustment amount is now reduced by the amount passed to the negative
                    -- charges procedure
                    l_adj_amt := NVL(l_adj_amt,0) - NVL(l_amt_neg_chg,0);
                    -- Call the procedure for the negative charges
                    proc_neg_chg(p_source_transaction_id => l_rec_chg_inv.invoice_id,
                                 p_adj_amount            => l_amt_neg_chg,
                                 p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                                 p_v_currency_cd         => p_header_rec.p_currency_cd,
                                 p_err_msg               => l_err_msg,
                                 p_status                => l_status);
                    -- If the procedure returns error, then raise the error message returned by the procedure.
                    -- If the procedure has not passed the error message then just raise the error
                    IF NOT l_status THEN
                        IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                            IF l_err_msg IS NOT NULL THEN
                                fnd_message.set_name('IGS',l_err_msg);
                                fnd_msg_pub.add;
                             END IF;
                             RAISE fnd_api.g_exc_error;
                        END IF;
                    END IF;
                END IF; -- End if for IF l_adj_amt > 0 THEN
             END IF; -- End if for IF NOT(chk_charge_adjusted())
           ELSE
             CLOSE cur_chg_inv;
           END IF;  -- End if for IF cur_chg_inv%FOUND THEN

      ELSE  -- Else for IF p_header_rec.p_source_transaction_id IS NOT NULL THEN

-- Loop through the Charges records
        FOR chgrec IN cur_chg(p_header_rec.p_person_id,
                              p_header_rec.p_fee_type,
                              p_header_rec.p_fee_cal_type,
                              p_header_rec.p_fee_ci_sequence_number,
                              p_header_rec.p_fee_cat,
                              p_header_rec.p_course_cd,
                              p_header_rec.p_transaction_type,
                              p_line_tbl(1).p_uoo_id,
                              p_line_tbl(1).p_location_cd,
                              p_header_rec.p_source_transaction_id) LOOP
          IF NOT(chk_charge_adjusted(p_header_rec.p_source_transaction_id, chgrec.invoice_amount)) THEN
            l_rec_exist := TRUE;
            chgrec.invoice_amount_due := igs_fi_gen_gl.get_formatted_amount(chgrec.invoice_amount_due);
            chgrec.invoice_amount := igs_fi_gen_gl.get_formatted_amount(chgrec.invoice_amount);

-- If the Adjustment Amount is greater than 0, then
            IF NVL(l_adj_amt,0) > 0 THEN

-- the invoice amount due is greater than the adjustment amount, then
-- If the Adjustment Amount is greater than the Invoice Amount Due, then
                IF NVL(l_adj_amt,0) > NVL(chgrec.invoice_amount_due,0) THEN
-- Amount for the negative charge is the invoice amount due
                  l_amt_neg_chg := NVL(chgrec.invoice_amount_due,0);
                ELSE
-- else the amount for the negative charge is the adjustment amount
                  l_amt_neg_chg := NVL(l_adj_amt,0);
                END IF;
  -- The adjustment amount is now reduced by the amount passed to the negative
  -- charges procedure
              l_adj_amt := NVL(l_adj_amt,0) - NVL(l_amt_neg_chg,0);

  -- Call the procedure for the negative charges
  -- Enh 2584986 - Added parameter p_gl_date

              proc_neg_chg(p_source_transaction_id => chgrec.invoice_id,
                           p_adj_amount            => l_amt_neg_chg,
                           p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                           p_v_currency_cd         => p_header_rec.p_currency_cd,
                           p_err_msg               => l_err_msg,
                           p_status                => l_status);

  -- If the procedure returns error, then raise the error message returned by the
  -- procedure. If the procedure has not passed the error message then just raise the
  -- error
              IF NOT l_status THEN
                IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                  IF l_err_msg IS NOT NULL THEN
                    fnd_message.set_name('IGS',l_err_msg);
                    fnd_msg_pub.add;
                  END IF;
                  RAISE fnd_api.g_exc_error;
                END IF;
              END IF;
            ELSE
              EXIT;
            END IF;
          END IF;  -- End if for IF NOT(chk_charge_adjusted())
        END LOOP;
      END IF;

-- In case of negative charge or adjustment creation, there is no invoice record created
-- hence the invoice id returned by the procedure is NULL
      x_invoice_id := NULL;

      -- If no charges were found in cur_chg or if the Adjustment Amount is still not zero, then
      -- (Changes as part of Bug 5234312)
      IF (l_rec_exist = FALSE OR NVL(l_adj_amt,0) > 0) THEN

         -- If Invoice ID has been passed, use cursor cur_chg_inv
         IF p_header_rec.p_source_transaction_id IS NOT NULL THEN

             -- Fetch charges in ascending order of Invoice_Id
             FOR rec_charges IN cur_charges_inv(p_header_rec.p_source_transaction_id) LOOP
                 IF NOT(chk_charge_adjusted(p_header_rec.p_source_transaction_id, rec_charges.invoice_amount)) THEN

                     -- If Adjustment Amount is not zero
                     IF (NVL(l_adj_amt,0) > 0) THEN
                           rec_charges.invoice_amount_due := igs_fi_gen_gl.get_formatted_amount(rec_charges.invoice_amount_due);
                           rec_charges.invoice_amount := igs_fi_gen_gl.get_formatted_amount(rec_charges.invoice_amount);

                           -- Fetch sum of all negative adjustment credits for the Invoice in context
                           OPEN cur_chgadj(rec_charges.invoice_id);
                           FETCH cur_chgadj INTO l_n_chgadj_amt;
                           CLOSE cur_chgadj;

                           -- Calculate Eligible Amount as difference between Invoice Amount and
                           -- Sum of all neg adj credits for the Invoice
                           l_n_elg_amt := NVL(rec_charges.invoice_amount,0) - NVL(l_n_chgadj_amt, 0);

                           -- Consider lesser of (Eligible Amount, Adjustment Amount) for l_amt_neg_chg
                           IF (NVL(l_n_elg_amt,0) <= NVL(l_adj_amt,0)) THEN
                               l_amt_neg_chg := NVL(l_n_elg_amt,0);
                           ELSE
                               l_amt_neg_chg := NVL(l_adj_amt,0);
                           END IF;

                           -- Decrease Adjustment Amount by the amount that is being adjusted (l_amt_neg_chg)
                           l_adj_amt := NVL(l_adj_amt,0) - NVL(l_amt_neg_chg,0);

                           proc_neg_chg(p_source_transaction_id => rec_charges.invoice_id,
                                        p_adj_amount            => l_amt_neg_chg,
                                        p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                                        p_v_currency_cd         => p_header_rec.p_currency_cd,
                                        p_err_msg               => l_err_msg,
                                        p_status                => l_status);
                           IF NOT l_status THEN
                              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                                  IF l_err_msg IS NOT NULL THEN
                                      fnd_message.set_name('IGS',l_err_msg);
                                      fnd_msg_pub.add;
                                  END IF;
                                  RAISE fnd_api.g_exc_error;
                              END IF;
                           END IF;
                     END IF; -- End if for IF (NVL(l_adj_amt,0) > 0) THEN
                  END IF;  -- End if for NOT(chk_charge_adjusted)
             END LOOP;
         ELSE
             -- If Invoice ID is not being passed, then use the UK to fetch the charges
             -- Fetch charges in ascending order of Invoice_Id
             FOR rec_charges IN cur_charges(p_header_rec.p_person_id,
                            p_header_rec.p_fee_type,
                            p_header_rec.p_fee_cal_type,
                            p_header_rec.p_fee_ci_sequence_number,
                            p_header_rec.p_fee_cat,
                            p_header_rec.p_course_cd,
                            p_header_rec.p_transaction_type,
                            p_line_tbl(1).p_uoo_id,
                            p_line_tbl(1).p_location_cd,
                            p_header_rec.p_source_transaction_id) LOOP

                 IF NOT(chk_charge_adjusted(p_header_rec.p_source_transaction_id, rec_charges.invoice_amount)) THEN

                     -- If Adjustment Amount is not zero
                     IF (NVL(l_adj_amt,0) > 0) THEN
                           rec_charges.invoice_amount_due := igs_fi_gen_gl.get_formatted_amount(rec_charges.invoice_amount_due);
                           rec_charges.invoice_amount := igs_fi_gen_gl.get_formatted_amount(rec_charges.invoice_amount);

                           -- Fetch sum of all negative adjustment credits for the Invoice in context
                           OPEN cur_chgadj(rec_charges.invoice_id);
                           FETCH cur_chgadj INTO l_n_chgadj_amt;
                           CLOSE cur_chgadj;

                           -- Calculate Eligible Amount as difference between Invoice Amount and
                           -- Sum of all neg adj credits for the Invoice
                           l_n_elg_amt := NVL(rec_charges.invoice_amount,0) - NVL(l_n_chgadj_amt, 0);

                           -- Consider lesser of (Eligible Amount, Adjustment Amount) for l_amt_neg_chg
                           IF (NVL(l_n_elg_amt,0) <= NVL(l_adj_amt,0)) THEN
                               l_amt_neg_chg := NVL(l_n_elg_amt,0);
                           ELSE
                               l_amt_neg_chg := NVL(l_adj_amt,0);
                           END IF;

                           -- Decrease Adjustment Amount by the amount that is being adjusted (l_amt_neg_chg)
                           l_adj_amt := NVL(l_adj_amt,0) - NVL(l_amt_neg_chg,0);

                           proc_neg_chg(p_source_transaction_id => rec_charges.invoice_id,
                                        p_adj_amount            => l_amt_neg_chg,
                                        p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                                        p_v_currency_cd         => p_header_rec.p_currency_cd,
                                        p_err_msg               => l_err_msg,
                                        p_status                => l_status);
                           IF NOT l_status THEN
                              IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                                  IF l_err_msg IS NOT NULL THEN
                                      fnd_message.set_name('IGS',l_err_msg);
                                      fnd_msg_pub.add;
                                  END IF;
                                  RAISE fnd_api.g_exc_error;
                              END IF;
                           END IF;
                     END IF; -- End if for IF (NVL(l_adj_amt,0) > 0) THEN
                  END IF;  -- End if for NOT(chk_charge_adjusted)
             END LOOP;
         END IF;  --  End if for p_header_rec.p_source_transaction_id IS NOT NULL

      END IF;

    END IF;  -- End if for NVL(l_n_invoice_amount,0) < 0

-- If the Invoice Amount passed to the Charges API is greater than zero,
-- this means that this is a positive charge and needs to be created normally
    IF NVL(l_n_invoice_amount,0) >= 0 THEN --bug :2222272

      -- Added following code for bug#2998266
      -- Fetch the sequence value which will be used to generate unique charge numbers.
      OPEN c_get_nextval;
      FETCH c_get_nextval INTO l_n_get_nextval;
      CLOSE c_get_nextval;

      l_rowid := NULL;
      l_invoice_id := NULL;
-- Call the table handler for the Charges table for creating the charges record
-- from the header record passed as input to the API

-- Modified by jbegum as part of Enh bug #2228910
-- Removed the column source_transaction_id in the call to IGS_FI_INV_INT_PKG.Insert_Row
-- Added column reversal_gl_date in call to insert_row part of bug 2584986

-- Call to igs_fi_gen_gl.get_formatted_amount formats amounts by rounding off to currency precision
      igs_fi_inv_int_pkg.insert_row(x_rowid                          => l_rowid,
                                    x_invoice_id                     => l_invoice_id,
                                    x_person_id                      => p_header_rec.p_person_id,
                                    x_fee_type                       => p_header_rec.p_fee_type,
                                    x_fee_cat                        => p_header_rec.p_fee_cat,
                                    x_fee_cal_type                   => p_header_rec.p_fee_cal_type,
                                    x_fee_ci_sequence_number         => p_header_rec.p_fee_ci_sequence_number,
                                    x_course_cd                      => p_header_rec.p_course_cd,
                                    x_attendance_mode                => p_header_rec.p_attendance_mode,
                                    x_attendance_type                => p_header_rec.p_attendance_type,
                                    x_invoice_amount_due             => l_n_invoice_amount,
                                    x_invoice_creation_date          => p_header_rec.p_invoice_creation_date,
                                    x_invoice_desc                   => p_header_rec.p_invoice_desc,
                                    x_transaction_type               => p_header_rec.p_transaction_type,
                                    x_currency_cd                    => p_header_rec.p_currency_cd,
                                    x_status                         => 'TODO',
                                    x_attribute_category             => NULL,
                                    x_attribute1                     => NULL,
                                    x_attribute2                     => NULL,
                                    x_attribute3                     => NULL,
                                    x_attribute4                     => NULL,
                                    x_attribute5                     => NULL,
                                    x_attribute6                     => NULL,
                                    x_attribute7                     => NULL,
                                    x_attribute8                     => NULL,
                                    x_attribute9                     => NULL,
                                    x_attribute10                    => NULL,
                                    x_invoice_amount                 => l_n_invoice_amount,
                                    x_bill_id                        => NULL,
                                    x_bill_number                    => NULL,
                                    x_bill_date                      => NULL,
                                    x_waiver_flag                    => p_header_rec.p_waiver_flag,   -- Enh BUG 2030448, Removed Balance Flag Column
                                    x_waiver_reason                  => p_header_rec.p_waiver_reason,
                                    x_effective_date                 => p_header_rec.p_effective_date,
                                    x_invoice_number                 => l_n_get_nextval,
                                    x_exchange_rate                  => 1,                                      -- Always passed as 1
                                    x_org_id                         => l_org_id,
                                    x_bill_payment_due_date          => NULL,
                                    x_optional_fee_flag              => NULL,
                                    x_reversal_gl_date               => NULL,
                                    x_tax_year_code                  => NULL,
                                    x_waiver_name                    => p_header_rec.p_waiver_name --Enh 3392095 Added waiver_name
                                    );

-- Loop through the PL/SQL table for the Charges Lines records
      FOR l_var IN p_line_tbl.FIRST..p_line_tbl.LAST LOOP
        l_rowid := NULL;
        l_invoice_lines_id := NULL;
        l_n_amount := igs_fi_gen_gl.get_formatted_amount(p_line_tbl(l_var).p_amount);

-- Modifacation done by kkillams; w.r.t to finance accounting dld bug id : 1882122
        l_dr_gl_ccid     := p_line_tbl(l_var).p_override_dr_rec_ccid;
        l_cr_gl_ccid     := p_line_tbl(l_var).p_override_cr_rev_ccid;
        l_dr_account_cd  := p_line_tbl(l_var).p_override_dr_rec_account_cd;
        l_cr_account_cd  := p_line_tbl(l_var).p_override_cr_rev_account_cd;

        l_error_string   := NULL;
        l_error_account  := NULL;

      -- Following If condition checking for transaction type was added as part of Enhancement bug#2113459
      -- Added by jbegum

         -- Bug# 3288973, Removed the check of Retention System Fee Type.
         -- Handling of Retention fee types is done in Build Accounts Process itself.
         call_build_process (p_header_rec             => p_header_rec,
                             p_line_rec               => p_line_tbl(l_var),
                             p_dr_gl_ccid             => l_dr_gl_ccid,
                             p_cr_gl_ccid             => l_cr_gl_ccid,
                             p_dr_account_cd          => l_dr_account_cd,
                             p_cr_account_cd          => l_cr_account_cd,
                             p_error_string           => l_error_string,
                             p_flag                   => l_flag);
         IF l_flag =1 THEN
           IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
             fnd_message.set_name('IGS',l_error_string);
             fnd_msg_pub.add;
             RAISE fnd_api.g_exc_error;
           END IF;
           l_error_account  := 'Y';
         ELSIF l_flag =2 THEN
           -- if the transaction type is Document then the user should not be allowed to create
           -- any charge with error account as 'Y' when revenue account segment derivation fails
           -- even after zero fill flag is provided
           l_error_account  := 'Y';
            IF p_header_rec.p_transaction_type = 'DOCUMENT' THEN
             IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
               fnd_message.set_name('IGS','IGS_FI_SRC_TXN_ACC_INV');
               fnd_msg_pub.add;
               RAISE fnd_api.g_exc_error;
             END IF;
           END IF;
         ELSE
           l_error_account  := 'N';
           l_error_string   := NULL;
         END IF;

-- As part of bug #1962286  the call to the IGS_FI_INVLN_INT_PKG.Insert_Row was modified.
-- The six UOO columns were removed and the two new columns location_cd and uoo_id were added in the call

-- Modified by jbegum as part of Enh bug #2228910
-- Removed the column source_transaction_id in the call to IGS_FI_INVLN_INT_PKG.Insert_Row

-- Call the Table Handler for creating the Charges Lines record
-- Enh bug 2584986: Added parameters gl_date, gl_posted_date and posting_control_id in call to insert_row

-- Call to igs_fi_gen_gl.get_formatted_amount formats amount by rounding off to currency precision
           igs_fi_invln_int_pkg.insert_row(x_rowid                         => l_rowid,
                                           x_invoice_lines_id              => l_invoice_lines_id,
                                           x_invoice_id                    => l_invoice_id,
                                           x_line_number                   => l_var,
                                           x_chg_elements                  => p_line_tbl(l_var).p_chg_elements,
                                           x_s_chg_method_type             => p_line_tbl(l_var).p_s_chg_method_type,
                                           x_description                   => p_line_tbl(l_var).p_description,
                                           x_amount                        => l_n_amount,
                                           x_unit_attempt_status           => p_line_tbl(l_var).p_unit_attempt_status,
                                           x_credit_points                 => p_line_tbl(l_var).p_credit_points,
                                           x_eftsu                         => p_line_tbl(l_var).p_eftsu,
                                           x_org_unit_cd                   => p_line_tbl(l_var).p_org_unit_cd,
                                           x_attribute_category            => p_line_tbl(l_var).p_attribute_category,
                                           x_attribute1                    => p_line_tbl(l_var).p_attribute1,
                                           x_attribute2                    => p_line_tbl(l_var).p_attribute2,
                                           x_attribute3                    => p_line_tbl(l_var).p_attribute3,
                                           x_attribute4                    => p_line_tbl(l_var).p_attribute4,
                                           x_attribute5                    => p_line_tbl(l_var).p_attribute5,
                                           x_attribute6                    => p_line_tbl(l_var).p_attribute6,
                                           x_attribute7                    => p_line_tbl(l_var).p_attribute7,
                                           x_attribute8                    => p_line_tbl(l_var).p_attribute8,
                                           x_attribute9                    => p_line_tbl(l_var).p_attribute9,
                                           x_attribute10                   => p_line_tbl(l_var).p_attribute10,
                                           x_attribute11                   => p_line_tbl(l_var).p_attribute11,
                                           x_attribute12                   => p_line_tbl(l_var).p_attribute12,
                                           x_attribute13                   => p_line_tbl(l_var).p_attribute13,
                                           x_attribute14                   => p_line_tbl(l_var).p_attribute14,
                                           x_attribute15                   => p_line_tbl(l_var).p_attribute15,
                                           x_attribute16                   => p_line_tbl(l_var).p_attribute16,
                                           x_attribute17                   => p_line_tbl(l_var).p_attribute17,
                                           x_attribute18                   => p_line_tbl(l_var).p_attribute18,
                                           x_attribute19                   => p_line_tbl(l_var).p_attribute19,
                                           x_attribute20                   => p_line_tbl(l_var).p_attribute20,
                                           x_org_id                        => l_org_id,
                                           x_rec_account_cd                => l_dr_account_cd,
                                           x_rev_account_cd                => l_cr_account_cd,
                                           x_rec_gl_ccid                   => l_dr_gl_ccid,
                                           x_rev_gl_ccid                   => l_cr_gl_ccid,
                                           x_posting_id                    => NULL,
                                           x_error_string                  => SUBSTR(l_error_string,1,1000),
                                           x_error_account                 => l_error_account,
                                           x_location_cd                   => p_line_tbl(l_var).p_location_cd,
                                           x_uoo_id                        => p_line_tbl(l_var).p_uoo_id,
                                           x_gl_date                       => p_line_tbl(1).p_d_gl_date,
                                           x_gl_posted_date                => NULL,
                                           x_posting_control_id            => NULL,
                                           x_unit_type_id                  => p_line_tbl(l_var).p_unit_type_id,
                                           x_unit_level                    => p_line_tbl(l_var).p_unit_level
                                           );

-- Add the Invoice Line Id to the output table
           x_line_id_tbl(l_line_cnt) := l_invoice_lines_id;
           l_line_cnt := l_line_cnt + 1;
      END LOOP;

-- Call the Balances Process for updating the Balances table
         BEGIN
           l_valid := TRUE;
           l_message_name := NULL;

           -- Enh BUG 2030448, Removed the call to the Calculate Balance Process. Call to Update_Balances has been added
           -- If any of the validations are failing then the process will return the error message
           -- Updation of Balances should not be done if Manage Accounts has value OTHER.
           IF l_v_manage_accounts <> 'OTHER' THEN
             igs_fi_prc_balances.update_balances ( p_party_id           => p_header_rec.p_person_id,
                                                   p_balance_type       => g_standard,
                                                   p_balance_date       => TRUNC(p_header_rec.p_invoice_creation_date),
                                                   p_amount             => l_n_invoice_amount,
                                                   p_source             => g_charge,
                                                   p_source_id          => l_invoice_id,
                                                   p_message_name       => l_message_name);

             -- Enh BUG 2030448, Check if the l_message_name is not null , If it is NOT NULL then there is an error occurred in
             -- the update_balances procedure
             IF l_message_name IS NOT NULL THEN
               IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
                 l_valid := FALSE;
                 fnd_message.set_name('IGS',l_message_name);
                 fnd_msg_pub.add;
                 RAISE fnd_api.g_exc_error;
               END IF;
             END IF;
           END IF;

         EXCEPTION

-- If the process has raised some errors then set the valid flag
-- to false
         WHEN OTHERS THEN
           l_valid := FALSE;
         END;

--removed the calls to igs_fi_gen_005.valiate_psa,igs_fi_party_sa_pkg.insert_row and related code,
--as part of subaccount removal build(enh#2564643),as the table igs_fi_party_sa has been obsoleted.

      BEGIN
        l_valid := TRUE;
        l_message_name := NULL;

        -- Updation of Balances should not be done if Manage Accounts has value OTHER.
        IF l_v_manage_accounts <> 'OTHER' THEN
          igs_fi_prc_balances.update_balances ( p_party_id           => p_header_rec.p_person_id,
                                                p_balance_type       => l_hold_bal_type,
                                                p_balance_date       => TRUNC(p_header_rec.p_invoice_creation_date),
                                                p_amount             => l_n_invoice_amount,
                                                p_source             => g_charge,
                                                p_source_id          => l_invoice_id,
                                                p_message_name       => l_message_name);

          -- Check if the l_message_name is not null , If it is NOT NULL then there is an error occurred in
          -- the update_balances procedure
          IF l_message_name IS NOT NULL THEN
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_error) THEN
              l_valid := FALSE;
              fnd_message.set_name('IGS',l_message_name);
              fnd_msg_pub.add;
              RAISE fnd_api.g_exc_error;
            END IF;
          END IF;
        END IF;
      EXCEPTION
        -- If the process has raised some errors then set the valid flag to false
        WHEN OTHERS THEN
          l_valid := FALSE;
      END;
      x_invoice_id := l_invoice_id;
    END IF;

   --Enh 3392095      Create_waivers
   -- check if Manage Accounts Option has value OTHER.
   IF g_v_manage_accounts <> 'OTHER' THEN
     /* Check if the IGS_FI_AUTO_CALC_WAIVERS profile is set to Y */
     IF l_v_igs_fi_auto_calc_waivers  = 'Y' THEN
       --checking P_REVERSE_FLAG holds a value other than "Y"
       IF (NVL(p_header_rec.p_reverse_flag,'N') <> 'Y') THEN
         IF p_header_rec.p_transaction_type NOT IN ('RETENTION', 'REFUND', 'SPONSOR', 'AID_ADJ',
                                                    'PAY_PLAN', 'WAIVER_ADJ', 'ASSESSMENT') THEN

             --Call create waivers routine
             igs_fi_prc_waivers.create_waivers( p_n_person_id           => p_header_rec.p_person_id,
                                                p_v_fee_type            => p_header_rec.p_fee_type,
                                                p_v_fee_cal_type        => p_header_rec.p_fee_cal_type,
                                                p_n_fee_ci_seq_number   => p_header_rec.p_fee_ci_sequence_number,
                                                p_v_waiver_name         => p_header_rec.p_waiver_name,
                                                p_v_currency_cd         => p_header_rec.p_currency_cd,
                                                p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                                                p_v_real_time_flag      => 'Y',
                                                p_v_process_mode        => NULL,
                                                p_v_career              => NULL,
                                                p_b_init_msg_list       => FALSE,
                                                p_validation_level      => 0,
                                                p_v_raise_wf_event      => 'Y',
                                                x_waiver_amount         => l_n_waiver_amount,
                                                x_return_status         => l_v_return_status,
                                                x_msg_count             => l_n_msg_count,
                                                x_msg_data              => l_v_msg_data
                                             );
             --If return status of Error
             IF l_v_return_status = 'E' THEN
                -- Message that no transactions have been carried out due to some error
                  fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
                  fnd_msg_pub.add;
                 x_waiver_amount := 0;
             --If return status of Success
             ELSIF l_v_return_status = 'S' THEN
                  x_waiver_amount := l_n_waiver_amount;
             END IF;
         END IF;
           -- If the P_REVERSE_FLAG holds a value "Y" and P_INVOICE_AMOUNT is less than zero
       ELSIF (NVL(p_header_rec.p_reverse_flag,'N') = 'Y' AND NVL(l_n_invoice_amount,0) < 0 )THEN
         IF p_header_rec.p_transaction_type NOT IN ('RETENTION', 'REFUND', 'SPONSOR', 'AID_ADJ',
                                                   'PAY_PLAN', 'WAIVER_ADJ') THEN
             --Call create waivers routine
             igs_fi_prc_waivers.create_waivers( p_n_person_id           => p_header_rec.p_person_id,
                                                p_v_fee_type            => p_header_rec.p_fee_type,
                                                p_v_fee_cal_type        => p_header_rec.p_fee_cal_type,
                                                p_n_fee_ci_seq_number   => p_header_rec.p_fee_ci_sequence_number,
                                                p_v_waiver_name         => p_header_rec.p_waiver_name,
                                                p_v_currency_cd         => p_header_rec.p_currency_cd,
                                                p_d_gl_date             => p_line_tbl(1).p_d_gl_date,
                                                p_v_real_time_flag      => 'Y',
                                                p_v_process_mode        => NULL,
                                                p_v_career              => NULL,
                                                p_b_init_msg_list       => FALSE,
                                                p_v_raise_wf_event      => 'Y',
                                                x_waiver_amount         => l_n_waiver_amount,
                                                x_return_status         => l_v_return_status,
                                                x_msg_count             => l_n_msg_count,
                                                x_msg_data              => l_v_msg_data
                                             );
             --If return status of Error
             IF l_v_return_status = 'E' THEN
                 -- Message that no transactions have been carried out due to some error
                 fnd_message.set_name('IGS','IGS_FI_WAV_NO_TRANS_CREATED');
                 fnd_msg_pub.add;
                 x_waiver_amount := 0;
              --If return status of Success
             ELSIF l_v_return_status = 'S' THEN
                  x_waiver_amount := l_n_waiver_amount;
             END IF;
         END IF;
       END IF;
     END IF;
   END IF;

-- If the p_commit parameter is set to True and no errors have been raised by the
-- balances process,
-- then commit the work
    IF ((fnd_api.to_boolean(p_commit)) AND (l_valid)) THEN
      COMMIT WORK;
    END IF;

    fnd_msg_pub.count_and_get(p_count      => x_msg_count,
                              p_data       => x_msg_data);

  EXCEPTION
    WHEN fnd_api.g_exc_error THEN
      ROLLBACK TO create_charge_pvt;
      x_return_status := fnd_api.g_ret_sts_error;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN fnd_api.g_exc_unexpected_error THEN
      ROLLBACK TO create_charge_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

    WHEN OTHERS THEN
      ROLLBACK TO create_charge_pvt;
      x_return_status := fnd_api.g_ret_sts_unexp_error;

      IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
        fnd_msg_pub.add_exc_msg(g_pkg_name,
                                l_api_name);
      END IF;
      fnd_msg_pub.count_and_get(  p_count          =>  x_msg_count,
                                  p_data           =>  x_msg_data);

  END create_charge;


FUNCTION chk_charge_adjusted(p_n_invoice_id IN igs_fi_inv_int_all.invoice_id%TYPE,
                             p_n_inv_amt    IN igs_fi_inv_int_all.invoice_amount%TYPE) RETURN BOOLEAN AS
/***********************************************************************************************
Created By:         Priya Athipatla
Date Created By:    29-03-2006
Purpose:            This function validates if the charge has been completely adjusted or not.
Known limitations,enhancements,remarks:
Change History
Who       When        What
********************************************************************************************** */

    -- Cursor to check if the invoice has been completely adjusted previously
    CURSOR cur_chk_adj(cp_invoice_id  igs_fi_inv_int_all.invoice_id%TYPE,
                       cp_inv_amt     igs_fi_inv_int_all.invoice_amount%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_credits_all fc,
             igs_fi_cr_types_all crt,
             igs_fi_applications app
      WHERE  app.invoice_id         = cp_invoice_id
      AND    app.credit_id          = fc.credit_id
      AND    fc.status              = g_cleared
      AND    fc.credit_type_id      = crt.credit_type_id
      AND    crt.credit_class       = g_neg_cr_class
      AND    app.amount_applied     = cp_inv_amt
      AND    ROWNUM = 1;

     l_v_chg_adjusted   VARCHAR2(1);

BEGIN

    -- If there is a negative adjustment credit against the charge, then return TRUE
    OPEN cur_chk_adj(p_n_invoice_id, p_n_inv_amt);
    FETCH cur_chk_adj INTO l_v_chg_adjusted;
    IF cur_chk_adj%FOUND THEN
       CLOSE cur_chk_adj;
       RETURN TRUE;
    ELSE
       CLOSE cur_chk_adj;
       RETURN FALSE;
    END IF;

END chk_charge_adjusted;

END igs_fi_charges_api_pvt;

/
