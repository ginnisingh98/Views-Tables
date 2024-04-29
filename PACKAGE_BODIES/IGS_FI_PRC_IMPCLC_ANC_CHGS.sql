--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_IMPCLC_ANC_CHGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_IMPCLC_ANC_CHGS" AS
/* $Header: IGSFI52B.pls 120.4 2006/05/15 07:44:51 sapanigr ship $ */

/**********************************************************************************************************
  Who       When         What
  sapanigr  03-May-2006  Enh#3924836 Precision Issue. Modified finp_imp_calc_anc_charges
  sapanigr  15-Feb-2006  Bug#5018036. Cursor cur_person_id in function finp_validate_input_data replaced by function call.
  sapanigr  14-Feb-2006  Bug#5018036. Cursor Cursor cur_person_id in function finp_validate_input_data modified for R12 Repository tuning.
  svuppala
  svuppala  04-AUG-2005  Enh 3392095 - Tution Waivers build
                         Impact of Charges API version Number change
                         Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
  pathipat  30-Sep-2003  Bug 3166888 - Modified finp_imp_calc_anc_charges() - modified cursor cur_inv_int
  vvutukur  20-Jun-2003  Enh#2777404.Modified finp_validate_input_data,finp_imp_calc_anc_charges.
  shtatiko  29-APR-2003  Enh# 2831569, Modified check_person_id, finp_imp_calc_anc_charges and finp_validate_input_data
  vvutukur  23-Jan-20033 Bug#2750566.Modifications done in finp_imp_calc_anc_charges.
  vvutukur  07-Jan-2003  Bug#2737714.Modified procedure finp_imp_calc_anc_charges.
  pathipat  20-Nov-2002  Enh bug 2584986 - GL Interface build
                         1.  Modified proc finp_imp_calc_anc_charges
                         2.  Removed lookup_desc, instead used generic func to get lookup description
                         3.  Modified finp_validate_input_data - added check for status in cur_ftci
  vvutukur  24-Jul-02    Bug#2425767.Procedure finp_imp_calc_anc_charges modified for removing references to
                         obsoleted columns chg_rate and chg_elements.
  sykrishn  03-JUL-02    Bug 2442163 - Procedure finp_imp_calc_anc_charges modified to insert sysdate to
                          transaction_dt in the table igs_fi_impchgs_lines table
                          Reference to anc_int table.transaction_dt is removed as it will never be present.
                          Removed transaction_dt from igs_fi_anc_int_pkg.update_row
                          Call to charges api changed to pass sysdate for invoice creation date instead of transaction_dt
  sykrishn  10-JUL-02    Bug 2454128 - Procedure finp_imp_calc_anc_charges
                         Call to charges api changed to pass Fee Type Description for invoice description
                         (l_header_rec.p_invoice_desc) instead of null.
*************************************************************************************************************/

  g_ancillary               CONSTANT VARCHAR2(30) := 'ANCILLARY';
  g_todo                    CONSTANT VARCHAR2(30) := 'TODO';
  g_success                 CONSTANT VARCHAR2(30) := 'SUCCESS';
  g_error                   CONSTANT VARCHAR2(30) := 'ERROR';
  g_active                  CONSTANT VARCHAR2(30) := 'ACTIVE';
  g_v_cleared               CONSTANT VARCHAR2(30) := 'CLEARED';
  g_v_chgadj                CONSTANT VARCHAR2(30) := 'CHGADJ';

  l_rowid                   VARCHAR2(25) := NULL;

  -- Added new parameter p_person_id as part of Enh# 2831569.
  FUNCTION Check_Person_Id(p_person_id               IN  igs_pe_person.person_id%TYPE,
                           p_person_id_type          IN  igs_pe_person.Person_Id_Type%TYPE,
                           p_api_person_id           IN  igs_pe_person.Api_Person_Id%TYPE) RETURN BOOLEAN;

  FUNCTION Get_Person_Number(p_person_id             IN  igs_pe_person.Person_Id%TYPE) RETURN IGS_PE_PERSON.Person_Number%TYPE;

  FUNCTION finp_get_anc_rate(p_fee_cal_type            IN igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                             p_fee_ci_sequence_number  IN igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE,
                             p_fee_type                IN igs_fi_anc_rates.Fee_Type%TYPE,
                             p_ancillary_attribute1    IN igs_fi_anc_rates.ancillary_attribute1%TYPE ,
                             p_ancillary_attribute2    IN igs_fi_anc_rates.ancillary_attribute2%TYPE ,
                             p_ancillary_attribute3    IN igs_fi_anc_rates.ancillary_attribute3%TYPE ,
                             p_ancillary_attribute4    IN igs_fi_anc_rates.ancillary_attribute4%TYPE ,
                             p_ancillary_attribute5    IN igs_fi_anc_rates.ancillary_attribute5%TYPE ,
                             p_ancillary_attribute6    IN igs_fi_anc_rates.ancillary_attribute6%TYPE ,
                             p_ancillary_attribute7    IN igs_fi_anc_rates.ancillary_attribute7%TYPE ,
                             p_ancillary_attribute8    IN igs_fi_anc_rates.ancillary_attribute8%TYPE ,
                             p_ancillary_attribute9    IN igs_fi_anc_rates.ancillary_attribute9%TYPE ,
                             p_ancillary_attribute10   IN igs_fi_anc_rates.ancillary_attribute10%TYPE ,
                             p_ancillary_attribute11   IN igs_fi_anc_rates.ancillary_attribute11%TYPE ,
                             p_ancillary_attribute12   IN igs_fi_anc_rates.ancillary_attribute12%TYPE ,
                             p_ancillary_attribute13   IN igs_fi_anc_rates.ancillary_attribute13%TYPE ,
                             p_ancillary_attribute14   IN igs_fi_anc_rates.ancillary_attribute14%TYPE ,
                             p_ancillary_attribute15   IN igs_fi_anc_rates.ancillary_attribute15%TYPE ,
                             p_ancillary_chg_rate     OUT NOCOPY igs_fi_anc_rates.Ancillary_Chg_Rate%TYPE) RETURN BOOLEAN AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    12-04-2001

Purpose:            This function gets the Ancillary Rate based on the Ancillary Segments
                    and the fee type calendar instance passed

Known limitations,enhancements,remarks:

Change History

Who     When       What

********************************************************************************************** */
    l_anc_rate            igs_fi_anc_rates.Ancillary_Chg_Rate%TYPE := 0;
    l_bool                BOOLEAN := FALSE;

-- Cursor for fetching the Ancillary Rate based on the Fee Type, Fee Calendar
-- and the Ancillary Attributes Passed
    CURSOR cur_anc_rates(cp_fee_cal_type            igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                         cp_fee_ci_sequence_number  igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE,
                         cp_fee_type                igs_fi_anc_rates.Fee_Type%TYPE,
                         cp_ancillary_attribute1    igs_fi_anc_rates.Ancillary_Attribute1%TYPE ,
                         cp_ancillary_attribute2    igs_fi_anc_rates.Ancillary_Attribute2%TYPE ,
                         cp_ancillary_attribute3    igs_fi_anc_rates.Ancillary_Attribute3%TYPE ,
                         cp_ancillary_attribute4    igs_fi_anc_rates.Ancillary_Attribute4%TYPE ,
                         cp_ancillary_attribute5    igs_fi_anc_rates.Ancillary_Attribute5%TYPE ,
                         cp_ancillary_attribute6    igs_fi_anc_rates.Ancillary_Attribute6%TYPE ,
                         cp_ancillary_attribute7    igs_fi_anc_rates.Ancillary_Attribute7%TYPE ,
                         cp_ancillary_attribute8    igs_fi_anc_rates.Ancillary_Attribute8%TYPE ,
                         cp_ancillary_attribute9    igs_fi_anc_rates.Ancillary_Attribute9%TYPE ,
                         cp_ancillary_attribute10   igs_fi_anc_rates.Ancillary_Attribute10%TYPE ,
                         cp_ancillary_attribute11   igs_fi_anc_rates.Ancillary_Attribute11%TYPE ,
                         cp_ancillary_attribute12   igs_fi_anc_rates.Ancillary_Attribute12%TYPE ,
                         cp_ancillary_attribute13   igs_fi_anc_rates.Ancillary_Attribute13%TYPE ,
                         cp_ancillary_attribute14   igs_fi_anc_rates.Ancillary_Attribute14%TYPE ,
                         cp_ancillary_attribute15   igs_fi_anc_rates.Ancillary_Attribute15%TYPE ) IS
      SELECT ancillary_chg_rate
      FROM   igs_fi_anc_rates
      WHERE  fee_cal_type             = cp_fee_cal_type
      AND    fee_ci_sequence_number   = cp_fee_ci_sequence_number
      AND    fee_type                 = cp_fee_type
      AND    NVL(enabled_flag,'N')    = 'Y'
      AND    ((ancillary_attribute1   = cp_ancillary_attribute1)
               OR ((cp_ancillary_attribute1 IS NULL) AND (ancillary_attribute1 IS NULL)))
      AND    ((ancillary_attribute2   = cp_ancillary_attribute2)
               OR ((cp_ancillary_attribute2 IS NULL)AND (ancillary_attribute2 IS NULL)))
      AND    ((ancillary_attribute3   = cp_ancillary_attribute3)
               OR ((cp_ancillary_attribute3 IS NULL) AND (ancillary_attribute3 IS NULL)))
      AND    ((ancillary_attribute4   = cp_ancillary_attribute4)
               OR ((cp_ancillary_attribute4 IS NULL) AND (ancillary_attribute4 IS NULL)))
      AND    ((ancillary_attribute5   = cp_ancillary_attribute5)
               OR ((cp_ancillary_attribute5 IS NULL) AND (ancillary_attribute5 IS NULL)))
      AND    ((ancillary_attribute6   = cp_ancillary_attribute6)
               OR ((cp_ancillary_attribute6 IS NULL) AND (ancillary_attribute6 IS NULL)))
      AND    ((ancillary_attribute7   = cp_ancillary_attribute7)
               OR ((cp_ancillary_attribute7 IS NULL) AND (ancillary_attribute7 IS NULL)))
      AND    ((ancillary_attribute8   = cp_ancillary_attribute8)
               OR ((cp_ancillary_attribute8 IS NULL) AND (ancillary_attribute8 IS NULL)))
      AND    ((ancillary_attribute9   = cp_ancillary_attribute9)
               OR ((cp_ancillary_attribute9 IS NULL) AND (ancillary_attribute9 IS NULL)))
      AND    ((ancillary_attribute10  = cp_ancillary_attribute10)
               OR ((cp_ancillary_attribute10 IS NULL) AND (ancillary_attribute10 IS NULL)))
      AND    ((ancillary_attribute11  = cp_ancillary_attribute11)
               OR ((cp_ancillary_attribute11 IS NULL) AND (ancillary_attribute11 IS NULL)))
      AND    ((ancillary_attribute12  = cp_ancillary_attribute12)
               OR ((cp_ancillary_attribute12 IS NULL) AND (ancillary_attribute12 IS NULL)))
      AND    ((ancillary_attribute13  = cp_ancillary_attribute13)
               OR ((cp_ancillary_attribute13 IS NULL) AND (ancillary_attribute13 IS NULL)))
      AND    ((ancillary_attribute14  = cp_ancillary_attribute14)
               OR ((cp_ancillary_attribute14 IS NULL) AND (ancillary_attribute14 IS NULL)))
      AND    ((ancillary_attribute15  = cp_ancillary_attribute15)
               OR ((cp_ancillary_attribute15 IS NULL) AND (ancillary_attribute15 IS NULL)));
  BEGIN

-- Fetch the Ancillary Rate from the Ancillary Rates table
    OPEN cur_anc_rates(p_fee_cal_type,
                       p_fee_ci_sequence_number,
                       p_fee_type,
                       p_ancillary_attribute1,
                       p_ancillary_attribute2,
                       p_ancillary_attribute3,
                       p_ancillary_attribute4,
                       p_ancillary_attribute5,
                       p_ancillary_attribute6,
                       p_ancillary_attribute7,
                       p_ancillary_attribute8,
                       p_ancillary_attribute9,
                       p_ancillary_attribute10,
                       p_ancillary_attribute11,
                       p_ancillary_attribute12,
                       p_ancillary_attribute13,
                       p_ancillary_attribute14,
                       p_ancillary_attribute15);
    FETCH cur_anc_rates INTO l_anc_rate;

-- If the Ancillary Rate is not found, then
    IF cur_anc_rates%NOTFOUND THEN

-- Set the Ancillary Rate local variable to 0 and the boolean variable to False
      l_anc_rate := 0;
      l_bool     := FALSE;
    ELSE

-- Else set the Boolean Variable to TRUE
      l_bool     := TRUE;
    END IF;
    CLOSE cur_anc_rates;

-- Assign the Ancillary Rate fetched to the Out NOCOPY variable of the function
-- and return the boolean variable
    p_ancillary_chg_rate := l_anc_rate;
    RETURN l_bool;
  END finp_get_anc_rate;


  FUNCTION finp_validate_input_data(p_fee_cal_type            IN igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                                    p_fee_ci_sequence_number  IN igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE,
                                    p_fee_type                IN igs_fi_anc_rates.Fee_Type%TYPE,
                                    p_person_id               IN igs_pe_person.Person_Id%TYPE      ,
                                    p_person_id_type          IN igs_pe_person.Person_Id_Type%TYPE ,
                                    p_api_person_id           IN igs_pe_person.Api_Person_Id%TYPE  ,
                                    p_err_msg_name           OUT NOCOPY VARCHAR2) RETURN BOOLEAN AS
/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    12-04-2001

Purpose:            This function validates the Input Data basde on the fee type calendar instance
                    and the Person details passed

Known limitations,enhancements,remarks:

Change History

Who       When         What
sapanigr  15-Feb-2006  Bug#5018036. Cursor cur_person_id replaced by call to function igs_en_gen_007.enrp_get_student_ind
sapanigr  14-Feb-2006  Bug#5018036. Cursor cur_person_id modified to take values from base tables directly.
vvutukur  20-Jun-2003  Enh#2777404.Modified cursor cur_fee_type to exclude closed fee types.
shtatiko  29-APR-2003  Enh# 2831569, Removed cursor cur_api_pers_id as its not used anywhere.
                       Added p_person_id in call to check_person_id
pathipat  20-Nov-2002  Enh bug 2584986 - Modified cursor cur_ftci - added check for active status
                       of the ftci.
********************************************************************************************** */

    l_temp            VARCHAR2(1);

-- Cursor for validating whether the Fee Calendar is a valid Calendar
    CURSOR cur_cal_type(cp_cal_type     igs_fi_anc_rates.fee_cal_type%TYPE) IS
      SELECT 'x'
      FROM   igs_ca_type
      WHERE  cal_type  = cp_cal_type;

-- Cursor for validating the Calendar Instance
    CURSOR cur_cal_inst(cp_cal_type            igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                        cp_ci_sequence_number  igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE) IS
      SELECT 'x'
      FROM   igs_ca_inst
      WHERE  cal_type           = cp_cal_type
      AND    sequence_number = cp_ci_sequence_number;

-- Cursor for validating whether the Fee Type is an active fee type
-- and the System fee Type is Ancillary
    CURSOR cur_fee_type(cp_fee_type       igs_fi_anc_rates.fee_type%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_fee_type
      WHERE  fee_type   = cp_fee_type
      AND    s_fee_type = g_ancillary
      AND    NVL(closed_ind,'N') = 'N';

-- Cursor for validating the Fee Type Calendar Instance
    CURSOR cur_ftci(cp_cal_type                  igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                    cp_ci_sequence_number        igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE,
                    cp_fee_type                  igs_fi_anc_rates.Fee_Type%TYPE) IS
      SELECT 'x'
      FROM   igs_fi_f_typ_ca_inst ftci, igs_fi_fee_str_stat fss
      WHERE  ftci.fee_cal_type               = cp_cal_type
      AND    ftci.fee_ci_sequence_number     = cp_ci_sequence_number
      AND    ftci.fee_type                   = cp_fee_type
      AND    fss.fee_structure_status        = ftci.fee_type_ci_status
      AND    fss.s_fee_structure_status      = g_active;

  BEGIN

-- Validate the Calendar
    OPEN cur_cal_type(p_fee_cal_type);
    FETCH cur_cal_type INTO l_temp;

-- If the Calendar is not valid then
    IF cur_cal_type%NOTFOUND THEN

-- Return the Error Message and the Function returns False
      CLOSE cur_cal_type;
      p_err_msg_name := 'IGS_FI_FEE_CAL_NOTFOUND';
      RETURN FALSE;
    END IF;
    CLOSE cur_cal_type;

-- Validate the Calendar instance
    OPEN cur_cal_inst(p_fee_cal_type,
                      p_fee_ci_sequence_number);
    FETCH cur_cal_inst INTO l_temp;

-- If the Calendar Instance is not valid then
    IF cur_cal_inst%NOTFOUND THEN
-- Return the Error Message and the Function returns False
      CLOSE cur_cal_inst;
      p_err_msg_name := 'IGS_FI_FEE_CAL_INST_NOTFOUND';
      RETURN FALSE;
    END IF;
    CLOSE cur_cal_inst;

-- Validate the Fee Type
    OPEN cur_fee_type(p_fee_type);
    FETCH cur_fee_type INTO l_temp;

-- If the Fee Type is not valid, then
    IF cur_fee_type%NOTFOUND THEN
-- Return the Error Message and the Function returns False
      CLOSE cur_fee_type;
      p_err_msg_name := 'IGS_FI_NO_FEE_TYPE';
      RETURN FALSE;
    END IF;
    CLOSE cur_fee_type;

-- Validate the Fee Type Calendar Instance
    OPEN cur_ftci(p_fee_cal_type,
                  p_fee_ci_sequence_number,
                  p_fee_type);
    FETCH cur_ftci INTO l_temp;

-- If the Fee Type Calendar Instance is Not Valid then
    IF cur_ftci%NOTFOUND THEN

-- Return the Error Message and the Function returns False
      CLOSE cur_ftci;
      p_err_msg_name := 'IGS_FI_FTCI_NOTFOUND';
      RETURN FALSE;
    END IF;
    CLOSE cur_ftci;

-- If the Person Id is not null then
    IF (p_person_id IS NOT NULL) THEN

-- Validate if the Person is a Student.
      IF NVL(igs_en_gen_007.enrp_get_student_ind(p_person_id),'N')<>'Y' THEN
-- If not a valid Student, then return the Error Message and the Function returns False.
          p_err_msg_name := 'IGS_FI_PERSON_NOTFOUND';
          RETURN FALSE;
      END IF;
    END IF;

-- If the Person Id type and the Alternate Person Id are not valid
    IF (( p_person_id_type IS NOT NULL) AND (p_api_person_id IS NOT NULL)) THEN

-- Validate the Person Id Type and the Alternate Person Id
      IF NOT Check_person_Id(p_person_id,
                             p_person_id_type,
                             p_api_person_id) THEN
        p_err_msg_name := 'IGS_FI_ALT_PRS_NOTFOUND';
        RETURN FALSE;
      END IF;
    END IF;

    p_err_msg_name := NULL;

    RETURN TRUE;
  END finp_validate_input_data;

  PROCEDURE finp_imp_calc_anc_charges(errbuf                   OUT NOCOPY VARCHAR2,
                                      retcode                  OUT NOCOPY NUMBER,
                                      p_person_id               IN igs_pe_person.Person_Id%TYPE      ,
                                      p_person_id_type          IN igs_pe_person.Person_Id_Type%TYPE ,
                                      p_api_person_id           IN igs_pe_person.Api_Person_Id%TYPE  ,
                                      p_fee_cal_type            IN igs_fi_anc_rates.Fee_Cal_Type%TYPE,
                                      p_fee_ci_sequence_number  IN igs_fi_anc_rates.Fee_Ci_Sequence_Number%TYPE,
                                      p_fee_type                IN igs_fi_anc_rates.Fee_Type%TYPE     ,
                                      p_org_id                  IN NUMBER) AS
/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    12-04-2001

Purpose:            This procedure imports the ancillary charges from the Ancillary Interface tables
                    based on the fee type calendar instance and the Person details passed

Known limitations,enhancements,remarks:

Change History

Who       When         What
sapanigr  03-May-2006  Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_impchgs_lines
                       are now rounded off to currency precision
svuppala  04-AUG-2005  Enh 3392095 - Tution Waivers build
                       Impact of Charges API version Number change
                       Modified igs_fi_charges_api_pvt.create_charge - version 2.0 and x_waiver_amount
pathipat  30-Sep-2003  Bug 3166888 - Modified cur_inv_int to sum invoice_amount instead of invoice_amount_due
                       and added 'not exists' clause
vvutukur  20-Jun-2003  Enh#2777404.Modified the logic such that all the error messages pertaining to an ancillary record
                       being processed from interface table are logged in the log file and error_msg field in the interface table
                       is updated with the concatenated error message texts.
shtatiko  29-APR-2003  Enh# 2831569, Added check for Manage Accounts System Option. If its value is NULL then
                       this process cannot be run.
vvutukur  23-Jan-20033 Bug#2750566.Modified the code to update the error_msg column in Interface record with appropriate message text.
vvutukur  06-Jan-2003  Bug#2737714.Used fnd_message.set_encoded to encode the message after charges api call,if charges api returns an error.
                       Also shown the no. of successfully imported records instead of showing no. of records processsed from interface table.
pathipat  20-NOV-2002  Enh#2584986 - GL Interface build
                       1.  Removed override account columns from calls to insert_row of IGS_FI_IMP_CHGS and
                           IGS_FI_IMPCHGS_LINES and update_row of IGS_FI_ANC_INT.
                           Also removed the corresponding validations and local variables.
                       2.  Removed ext_attribute columns from calls to insert_row of IGS_FI_IMPCHGS_LINES
                       3.  Removed cursor cur_currency and its usage. Derived local currency using generic
                           function igs_fi_gen_gl.finp_get_cur()
                       4.  Passed sysdate to p_d_gl_date in call to charges_api.  Passed null to override account
                           codes before calling charges_api.
saraskhi  13-sep-2002  Enh#2564643, removed the reference of subaccount
vvutukur  24-Jul-2002  Bug#2425767.Removed references to obsoleted columns chg_rate,chg_elements from
                       call to igs_fi_impchgs_lines.insert_row procedure.
sykrishn  10-JUL-02    Bug 2454128 - Procedure finp_imp_calc_anc_charges
                         Call to charges api changed to pass Fee Type Description for invoice description
                         (l_header_rec.p_invoice_desc) instead of null.
jbegum    12-Jun-02    Bug#2400189 - Added a local valriable l_rec_cntr to count the number of
                                     records processed and log that in the log file
agairola  04-Jun-2002  Bug 2395663 - Modified the TBH call for the IGS_FI_IMPCHGS_LINES_PKG
SYKRISHN  19-APR-2002  Bug 2324088 - Introduced Desc Flex Field Validations and CCID validations.
smadathi 27-Feb-2002   Bug 2238413. Reduced selection list for
                         rec installed flag to 'Y' and 'N'.Removed
                         reference of rec installed flag = 'E'.
sarakshi  16-jan-2002  Modified the logic of fetching subaccount_id as a part of bug:2175865
********************************************************************************************** */

-- Variables of type VARCHAR2
    l_error_msg                   VARCHAR2(2000);
    l_person_id                   igs_pe_alt_pers_id.pe_person_id%TYPE;
    l_rec_installed               igs_fi_control.rec_installed%TYPE;
    l_exception_flag              VARCHAR2(1);
    l_message                     VARCHAR2(2000);
    l_person_number               igs_pe_person.person_number%TYPE;

-- Variables of type NUMBER
    l_diff_amount                 igs_fi_inv_int.invoice_amount_due%TYPE;
    l_import_charges_id           igs_fi_imp_chgs.import_charges_id%TYPE;
    l_impchgs_lines_id            igs_fi_impchgs_lines.impchg_lines_id%TYPE;
    l_ancillary_chg_rate          igs_fi_anc_rates.ancillary_chg_rate%TYPE;
    l_rec_cntr                    NUMBER(10);

-- Variables of type BOOLEAN
    l_validate       BOOLEAN;
    l_anc_rate_out   BOOLEAN;

-- New variable defined as part of 2324088
    l_dff_validate   BOOLEAN;

-- Variables of type DATE
    l_effective_dt     igs_fi_anc_int.Effective_Dt%TYPE;

-- Variables for Charges API Integration
    l_header_rec     igs_fi_charges_api_pvt.header_rec_type;
    l_line_tbl       igs_fi_charges_api_pvt.line_tbl_type;
    l_line_tbl_dummy igs_fi_charges_api_pvt.line_tbl_type;
    l_line_id_tbl    igs_fi_charges_api_pvt.line_id_tbl_type;
    l_invoice_id     igs_fi_inv_int.Invoice_Id%TYPE;
    l_msg_count      NUMBER(3);
    l_msg_data       VARCHAR2(2000);
    l_return_status  VARCHAR2(1);
    l_prev_amount    igs_fi_inv_int.invoice_amount%TYPE;
    l_var            NUMBER(3);
    l_fee_desc       igs_fi_fee_type.description%TYPE;

    l_v_local_currency igs_fi_control.currency_cd%TYPE;
    l_n_curr_cd        igs_fi_control.currency_cd%TYPE;
    l_v_curr_desc      fnd_currencies_tl.name%TYPE;

    l_appl_name        VARCHAR2(5);
    l_msg_name         fnd_new_messages.message_name%TYPE;

    l_v_message_name   fnd_new_messages.message_name%TYPE;
    l_msg              fnd_new_messages.message_text%TYPE;
    l_v_manage_accounts   igs_fi_control_all.manage_accounts%TYPE;
    l_exception        EXCEPTION;

    l_n_waiver_amount NUMBER;
-- Cursor for getting the todo records from the Ancillary Interface table
    CURSOR cur_anc_int(cp_person_id              IGS_PE_PERSON.Person_Id%TYPE,
                       cp_person_id_type          IGS_PE_PERSON.Person_Id_Type%TYPE,
                       cp_api_person_id           IGS_PE_PERSON.Api_Person_Id%TYPE,
                       cp_fee_cal_type            IGS_FI_ANC_RATES.Fee_Cal_Type%TYPE,
                       cp_fee_ci_sequence_number  IGS_FI_ANC_RATES.Fee_Ci_Sequence_Number%TYPE,
                       cp_fee_type                IGS_FI_ANC_RATES.Fee_Type%TYPE) IS
      SELECT rowid,
             IGS_FI_ANC_INT.*
      FROM   IGS_FI_ANC_INT
      WHERE  ((fee_cal_type           = cp_fee_cal_type)
              OR (cp_fee_cal_type IS NULL))
      AND    ((fee_ci_sequence_number = cp_fee_ci_sequence_number)
              OR (cp_fee_ci_sequence_number IS NULL))
      AND    status                 = g_todo
      AND    ((person_id            = cp_person_id)
               OR (cp_person_id IS NULL))
      AND    ((person_id_type       = cp_person_id_type)
               OR (cp_person_id_type IS NULL))
      AND    ((api_person_id        = cp_api_person_id)
               OR (cp_api_person_id IS NULL))
      AND    ((fee_type             = cp_fee_type)
               OR (cp_fee_type IS NULL));

-- Cursor for getting the Person Id from Alternate Person Id table based on the
-- Person Id Type and Alternate Person Id
    CURSOR cur_person(cp_person_id_type      IGS_PE_PERSON.Person_Id_Type%TYPE,
                      cp_api_person_id       IGS_PE_PERSON.Api_Person_Id%TYPE) IS
      SELECT pe_person_id
      FROM   igs_pe_alt_pers_id
      WHERE  person_id_type = cp_person_id_type
      AND    api_person_id  = cp_api_person_id;

-- Cursor for checking whether the record exists in the Import Charges table
    CURSOR cur_impchgs(cp_person_id               IGS_PE_PERSON.Person_Id%TYPE,
                       cp_fee_cal_type            IGS_FI_F_TYP_CA_INST.Fee_Cal_Type%TYPE,
                       cp_fee_ci_sequence_number  IGS_FI_F_TYP_CA_INST.Fee_Ci_Sequence_Number%TYPE,
                       cp_fee_type                IGS_FI_F_TYP_CA_INST.Fee_Type%TYPE,
                       cp_transaction_type        VARCHAR2) IS
      SELECT import_charges_id
      FROM   igs_fi_imp_chgs
      WHERE  person_id              = cp_person_id
      AND    fee_cal_type           = cp_fee_cal_type
      AND    fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND    fee_type               = cp_fee_type
      AND    transaction_type       = cp_transaction_type;

    -- Cursor for summing up the values from the Invoice Interface table
    -- Charges that were reversed or declined are not to be
    -- considered while summing the invoice_amount values.
    CURSOR cur_inv_int(cp_person_id               IGS_PE_PERSON.Person_Id%TYPE,
                       cp_fee_cal_type            IGS_FI_F_TYP_CA_INST.Fee_Cal_Type%TYPE,
                       cp_fee_ci_sequence_number  IGS_FI_F_TYP_CA_INST.Fee_Ci_Sequence_Number%TYPE,
                       cp_fee_type                IGS_FI_F_TYP_CA_INST.Fee_Type%TYPE,
                       cp_transaction_type        VARCHAR2) IS
      SELECT SUM(invoice_amount)
      FROM   igs_fi_inv_int inv
      WHERE  inv.person_id              = cp_person_id
      AND    inv.fee_cal_type           = cp_fee_cal_type
      AND    inv.fee_ci_sequence_number = cp_fee_ci_sequence_number
      AND    inv.fee_type               = cp_fee_type
      AND    inv.transaction_type       = cp_transaction_type
      AND    NOT EXISTS( SELECT 'X'
                         FROM  igs_fi_credits fc,
                               igs_fi_cr_types crt,
                               igs_fi_applications app
                         WHERE app.invoice_id = inv.invoice_id
                         AND   app.credit_id = fc.credit_id
                         AND   fc.status = g_v_cleared
                         AND   fc.credit_type_id = crt.credit_type_id
                         AND   crt.credit_class = g_v_chgadj
                         AND   app.amount_applied = inv.invoice_amount);

-- Cursor for fetching the Fee Type description
    CURSOR cur_fee(cp_fee_type      IGS_FI_FEE_TYPE.Fee_Type%TYPE) IS
      SELECT description
      FROM   igs_fi_fee_type
      WHERE  fee_type   = cp_fee_type;

  BEGIN

-- Set the Org Id
    IGS_GE_GEN_003.Set_Org_Id(p_org_id);

    l_rec_installed := IGS_FI_GEN_005.finp_get_receivables_inst;
-- Logging the Paramteres in the Log File

    FND_MESSAGE.Set_Name('IGS','IGS_FI_ANC_LOG_PARM');
    FND_FILE.Put_Line(FND_FILE.Log,FND_MESSAGE.Get);

    IF p_person_id IS NOT NULL THEN
      l_person_number := Get_Person_Number(p_person_id);
    END IF;

-- Removed usage of lookup_desc, instead used generic function to get the lookup description
    fnd_message.set_name('IGS', 'IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'PERSON')
                          );
    fnd_message.set_token('PARM_CODE',l_person_number);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'PERSON_ID_TYPE')
                          );
    fnd_message.set_token('PARM_CODE',p_person_id_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'ALTERNATE_PERSON_ID')
                          );
    fnd_message.set_token('PARM_CODE',p_api_person_id);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'FEE_TYPE')
                          );
    fnd_message.set_token('PARM_CODE',p_fee_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    fnd_message.set_name('IGS','IGS_FI_IMP_CHGS_PARAMETER');
    fnd_message.set_token('PARM_TYPE',igs_fi_gen_gl.get_lkp_meaning (p_v_lookup_type => 'IGS_FI_LOCKBOX',
                                                                     p_v_lookup_code => 'FEE_CAL_TYPE')
                         );
    fnd_message.set_token('PARM_CODE',p_fee_cal_type);
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    -- Get the value of "Manage Accounts" System Option value.
    -- If this value is NULL then this process should error out.
    igs_fi_com_rec_interface.chk_manage_account ( p_v_manage_acc => l_v_manage_accounts,
                                                  p_v_message_name => l_v_message_name );
    IF l_v_manage_accounts IS NULL THEN
      fnd_message.set_name ( 'IGS', l_v_message_name );
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      RAISE l_exception;
    END IF;

-- If the Person Id is not null then
    IF p_person_id IS NOT NULL THEN

-- Person Id Type and Alternate Person Id cannot be specified
-- If the Person Id Type and the Alternate Person Id are input to the process
-- then raise an error
      IF ((p_person_id_type IS NOT NULL) OR (p_api_person_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name('IGS', 'IGS_FI_PERS_INFO_NOT_NULL');
        FND_MESSAGE.Set_Token('PERSON_ID', l_person_number);
        FND_MESSAGE.Set_Token('PERS_ID_TYPE', p_person_id_type);
        FND_MESSAGE.Set_Token('API_PERS_ID', p_api_person_id);
        l_message := FND_MESSAGE.Get;
        FND_FILE.Put_Line(FND_FILE.Log, l_message);
        APP_EXCEPTION.Raise_Exception;
      END IF;
    ELSE

-- If the Person Id is null
-- And the Person Id Type is NOT NULL and Api Person Id IS NULL
-- then log an error message and exit
      IF ((p_person_id_type IS NOT NULL) AND (p_api_person_id IS NULL)) THEN
        FND_MESSAGE.Set_Name('IGS','IGS_FI_API_PERS_ID_NULL');
        FND_MESSAGE.Set_Token('PERS_ID_TYPE', p_person_id_type);
        l_message := FND_MESSAGE.Get;
        FND_FILE.Put_Line(FND_FILE.Log, l_message);
        APP_EXCEPTION.Raise_Exception;

-- Else if the Person Id Type is NULL and the API Person Id is NOT NULL then
-- Log this as an error
      ELSIF ((p_person_id_type IS NULL) AND (p_api_person_id IS NOT NULL)) THEN
        FND_MESSAGE.Set_Name('IGS', 'IGS_FI_PERS_ID_TYPE_NULL');
        FND_MESSAGE.Set_Token('API_PERS_ID',  p_api_person_id);
        l_message := FND_MESSAGE.Get;
        FND_FILE.Put_Line(FND_FILE.Log,  l_message);
        APP_EXCEPTION.Raise_Exception;
      END IF;
    END IF;

    -- Obtain the currency_cd setup in the system.  (Added as part of bug 2584986)
    igs_fi_gen_gl.finp_get_cur( p_v_currency_cd  =>  l_n_curr_cd,
                                p_v_curr_desc    =>  l_v_curr_desc,
                                p_v_message_name =>  l_v_message_name
                              );
    IF l_v_message_name IS NOT NULL THEN
      fnd_message.set_name('IGS',l_v_message_name);
      fnd_file.put_line(fnd_file.Log,fnd_message.get);
      app_exception.raise_exception;
    ELSE
      l_v_local_currency  := l_n_curr_cd;
    END IF;

    l_rec_cntr := 0;
-- Loop through the Ancillary Interface records which have a status of TODO
    FOR ancrec IN cur_anc_int(p_person_id,
                              p_person_id_type,
                              p_api_person_id,
                              p_fee_cal_type,
                              p_fee_ci_sequence_number,
                              p_fee_type)  LOOP

-- IF the Person Id is not null then this person id should be used for
-- creating the records in the Import Charges table
-- Else the Person Id should be derived from the Person Id Type and
-- Alternate Person ID
      IF ancrec.person_id IS NOT NULL THEN
        l_person_id := ancrec.person_id;
      ELSE

-- Get the Person Id based on the Person Id Type and Api Person Id
        OPEN cur_person(ancrec.person_id_type,
                        ancrec.api_person_id);
        FETCH cur_person INTO l_person_id;
        CLOSE cur_person;
      END IF;

      ancrec.error_msg := NULL;

      l_validate := TRUE;

      l_person_number := Get_Person_Number(l_person_id);

-- Log the record Details
      fnd_file.new_line(fnd_file.log);
      FND_MESSAGE.Set_name('IGS','IGS_FI_ANC_REC_DTLS');
      FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);

      FND_MESSAGE.Set_Name('IGS','IGS_FI_ANC_CHG_REC1');
      FND_MESSAGE.Set_Token('TOKEN',l_person_number);
      FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);

      FND_MESSAGE.Set_Name('IGS','IGS_FI_ANC_CHG_REC2');
      FND_MESSAGE.Set_Token('TOKEN', ancrec.fee_cal_type);
      FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);

      FND_MESSAGE.Set_Name('IGS','IGS_FI_ANC_CHG_REC3');
      FND_MESSAGE.Set_Token('TOKEN', ancrec.fee_type);
      FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);

-- If the validation flag is set to N then
      IF NVL(ancrec.validation_flag,'N') = 'N' THEN

-- Make a call to finp_validate_input_data for validating the input data
        l_validate := finp_validate_input_data(p_fee_cal_type                => ancrec.fee_cal_type,
                                               p_fee_ci_sequence_number      => ancrec.fee_ci_sequence_number,
                                               p_fee_type                    => ancrec.fee_type,
                                               p_person_id                   => l_person_id,  -- Passed l_person_id instead of ancrec.person_id (Enh# 2831569)
                                               p_person_id_type              => ancrec.person_id_type,
                                               p_api_person_id               => ancrec.api_person_id,
                                               p_err_msg_name                => l_error_msg);
        IF NOT l_validate THEN
          fnd_message.set_name('IGS',l_error_msg);
          l_msg := fnd_message.get;
          fnd_file.put_line(fnd_file.log,l_msg);
          ancrec.error_msg := l_msg;
          ancrec.status := g_error;
        END IF;

 -- sykrishn Modifications due to 2324088
 -- If the above validations are successful we want to check if the DFF is valid
 -- If DFF is invalid then sets l_validate to FALSE so that no further processing happens
        l_dff_validate := igs_ad_imp_018.validate_desc_flex (
                               p_attribute_category => ancrec.attribute_category,
                               p_attribute1  =>        ancrec.attribute1,
                               p_attribute2  =>        ancrec.attribute2,
                               p_attribute3  =>        ancrec.attribute3,
                               p_attribute4  =>        ancrec.attribute4,
                               p_attribute5  =>        ancrec.attribute5,
                               p_attribute6  =>        ancrec.attribute6,
                               p_attribute7  =>        ancrec.attribute7,
                               p_attribute8  =>        ancrec.attribute8,
                               p_attribute9  =>        ancrec.attribute9,
                               p_attribute10 =>        ancrec.attribute10,
                               p_attribute11 =>        ancrec.attribute11,
                               p_attribute12 =>        ancrec.attribute12,
                               p_attribute13 =>        ancrec.attribute13,
                               p_attribute14 =>        ancrec.attribute14,
                               p_attribute15 =>        ancrec.attribute15,
                               p_attribute16 =>        ancrec.attribute16,
                               p_attribute17 =>        ancrec.attribute17,
                               p_attribute18 =>        ancrec.attribute18,
                               p_attribute19 =>        ancrec.attribute19,
                               p_attribute20 =>        ancrec.attribute20,
                               p_desc_flex_name => 'IGS_FI_IMPCHGS_FLEX');

        IF NOT l_dff_validate THEN
          l_validate  :=  FALSE;
          ancrec.status := g_error;
          fnd_message.set_name('IGS','IGS_AD_INVALID_DESC_FLEX');
          l_msg := fnd_message.get;
          fnd_file.put_line(fnd_file.log,l_msg);
          ancrec.error_msg := ancrec.error_msg||'.'||l_msg;
        END IF;
      END IF;


-- make a call to the finp_get_anc_rate procedure
-- for getting the Ancillary Rate
      l_anc_rate_out := finp_get_anc_rate(  p_fee_cal_type                           => ancrec.fee_cal_type,
                                            p_fee_ci_sequence_number                 => ancrec.fee_ci_sequence_number,
                                            p_fee_type                               => ancrec.fee_type,
                                            p_ancillary_attribute1                   => ancrec.ancillary_attribute1,
                                            p_ancillary_attribute2                   => ancrec.ancillary_attribute2,
                                            p_ancillary_attribute3                   => ancrec.ancillary_attribute3,
                                            p_ancillary_attribute4                   => ancrec.ancillary_attribute4,
                                            p_ancillary_attribute5                   => ancrec.ancillary_attribute5,
                                            p_ancillary_attribute6                   => ancrec.ancillary_attribute6,
                                            p_ancillary_attribute7                   => ancrec.ancillary_attribute7,
                                            p_ancillary_attribute8                   => ancrec.ancillary_attribute8,
                                            p_ancillary_attribute9                   => ancrec.ancillary_attribute9,
                                            p_ancillary_attribute10                  => ancrec.ancillary_attribute10,
                                            p_ancillary_attribute11                  => ancrec.ancillary_attribute11,
                                            p_ancillary_attribute12                  => ancrec.ancillary_attribute12,
                                            p_ancillary_attribute13                  => ancrec.ancillary_attribute13,
                                            p_ancillary_attribute14                  => ancrec.ancillary_attribute14,
                                            p_ancillary_attribute15                  => ancrec.ancillary_attribute15,
                                            p_ancillary_chg_rate                     => l_ancillary_chg_rate);

-- If the rate is not found then
      IF NOT l_anc_rate_out THEN
-- The record should be updated to error with the error message
-- and the concurrent manager's log file should be updated
        l_validate  :=  FALSE;
        ancrec.status := g_error;
        fnd_message.set_name('IGS','IGS_FI_ANCRATE_NOT_FOUND');
        l_msg := fnd_message.get;
        fnd_file.put_line(fnd_file.log,l_msg);
        ancrec.error_msg := ancrec.error_msg||'.'||l_msg;
      END IF;

      IF l_validate THEN

-- The Ancillary Rates have been found and all the validations are done
        BEGIN

-- Set the Effective Date
-- If the values in the record are null, then they are defaulted to
-- SYSDATE
          l_effective_dt   := NVL(ancrec.effective_dt,SYSDATE);

-- Check if the record already exists in the Import Charges table based
-- on the Person_Id, Fee Type Calendar Instance and of transaction type
-- as ancillary
          OPEN cur_impchgs(l_person_id,
                           ancrec.fee_cal_type,
                           ancrec.fee_ci_sequence_number,
                           ancrec.fee_type,
                           g_ancillary);
          FETCH cur_impchgs INTO l_import_charges_id;

          IF cur_impchgs%NOTFOUND THEN
-- if the records are not found in the Import Charges table,
-- then insert has to be done in both header and detail table
            l_import_charges_id := NULL;
            l_rowid := NULL;

-- Call the TBH for creating a record in the Import Charges Table
            igs_fi_imp_chgs_pkg.Insert_Row(      x_rowid                                => l_rowid,
                                                 x_import_charges_id                    => l_import_charges_id,
                                                 x_person_id                            => l_person_id,
                                                 x_fee_type                             => ancrec.fee_type,
                                                 x_fee_cal_type                         => ancrec.fee_cal_type,
                                                 x_fee_ci_sequence_number               => ancrec.fee_ci_sequence_number,
                                                 x_transaction_type                     => g_ancillary);


            l_rowid := NULL;
            l_impchgs_lines_id := NULL;

            FND_MESSAGE.Set_Name('IGS','IGS_FI_ANC_CHG_REC4');
            FND_MESSAGE.Set_Token('TOKEN',to_char(l_ancillary_chg_rate));
            FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);

-- Call the TBH for creating a record in the Import Charges Lines table

-- Passed l_v_local_currency derived to the currency_cd field (part of enh bug 2584986)
-- Obsoleted columns override account codes and ext_attributes
-- Call to igs_fi_gen_gl.get_formatted_amount formats l_ancillary_chg_rate by rounding off to currency precision
            igs_fi_impchgs_lines_pkg.Insert_Row(  x_rowid                               => l_rowid,
                                                  x_impchg_lines_id                     => l_impchgs_lines_id,
                                                  x_import_charges_id                   => l_import_charges_id,
                                                  x_transaction_dt                      => SYSDATE,
                                                  x_effective_dt                        => l_effective_dt,
                                                  x_transaction_amount                  => igs_fi_gen_gl.get_formatted_amount(l_ancillary_chg_rate),
                                                  x_currency_cd                         => l_v_local_currency,
                                                  x_exchange_rate                       => NULL,
                                                  x_comments                            => NULL,
                                                  x_ancillary_attribute1                => ancrec.ancillary_attribute1,
                                                  x_ancillary_attribute2                => ancrec.ancillary_attribute2,
                                                  x_ancillary_attribute3                => ancrec.ancillary_attribute3,
                                                  x_ancillary_attribute4                => ancrec.ancillary_attribute4,
                                                  x_ancillary_attribute5                => ancrec.ancillary_attribute5,
                                                  x_ancillary_attribute6                => ancrec.ancillary_attribute6,
                                                  x_ancillary_attribute7                => ancrec.ancillary_attribute7,
                                                  x_ancillary_attribute8                => ancrec.ancillary_attribute8,
                                                  x_ancillary_attribute9                => ancrec.ancillary_attribute9,
                                                  x_ancillary_attribute10               => ancrec.ancillary_attribute10,
                                                  x_ancillary_attribute11               => ancrec.ancillary_attribute11,
                                                  x_ancillary_attribute12               => ancrec.ancillary_attribute12,
                                                  x_ancillary_attribute13               => ancrec.ancillary_attribute13,
                                                  x_ancillary_attribute14               => ancrec.ancillary_attribute14,
                                                  x_ancillary_attribute15               => ancrec.ancillary_attribute15,
                                                  x_attribute_category                  => ancrec.attribute_category,
                                                  x_attribute1                          => ancrec.attribute1,
                                                  x_attribute2                          => ancrec.attribute2,
                                                  x_attribute3                          => ancrec.attribute3,
                                                  x_attribute4                          => ancrec.attribute4,
                                                  x_attribute5                          => ancrec.attribute5,
                                                  x_attribute6                          => ancrec.attribute6,
                                                  x_attribute7                          => ancrec.attribute7,
                                                  x_attribute8                          => ancrec.attribute8,
                                                  x_attribute9                          => ancrec.attribute9,
                                                  x_attribute10                         => ancrec.attribute10,
                                                  x_attribute11                         => ancrec.attribute11,
                                                  x_attribute12                         => ancrec.attribute12,
                                                  x_attribute13                         => ancrec.attribute13,
                                                  x_attribute14                         => ancrec.attribute14,
                                                  x_attribute15                         => ancrec.attribute15,
                                                  x_attribute16                         => ancrec.attribute16,
                                                  x_attribute17                         => ancrec.attribute17,
                                                  x_attribute18                         => ancrec.attribute18,
                                                  x_attribute19                         => ancrec.attribute19,
                                                  x_attribute20                         => ancrec.attribute20
                                          );

          ELSE

-- The records need to be created in the Import Charges Lines table
            l_rowid := NULL;
            l_impchgs_lines_id := NULL;

            FND_MESSAGE.Set_Name('IGS', 'IGS_FI_ANC_CHG_REC4');
            FND_MESSAGE.Set_Token('TOKEN', to_char(l_ancillary_chg_rate));
            FND_FILE.Put_Line(FND_FILE.Log, FND_MESSAGE.Get);


-- Call the TBH for creating a record in the Import Charges Lines table

-- Passed l_v_local_currency derived to the currency_cd field (part of enh bug 2584986)
-- Obsoleted columns override account codes and ext_attributes
-- Call to igs_fi_gen_gl.get_formatted_amount formats l_ancillary_chg_rate by rounding off to currency precision
            igs_fi_impchgs_lines_pkg.Insert_Row(  x_rowid                               => l_rowid,
                                                  x_impchg_lines_id                     => l_impchgs_lines_id,
                                                  x_import_charges_id                   => l_import_charges_id,
                                                  x_transaction_dt                      => SYSDATE,
                                                  x_effective_dt                        => l_effective_dt,
                                                  x_transaction_amount                  => igs_fi_gen_gl.get_formatted_amount(l_ancillary_chg_rate),
                                                  x_currency_cd                         => l_v_local_currency,
                                                  x_exchange_rate                       => NULL,
                                                  x_comments                            => NULL,
                                                  x_ancillary_attribute1                => ancrec.ancillary_attribute1,
                                                  x_ancillary_attribute2                => ancrec.ancillary_attribute2,
                                                  x_ancillary_attribute3                => ancrec.ancillary_attribute3,
                                                  x_ancillary_attribute4                => ancrec.ancillary_attribute4,
                                                  x_ancillary_attribute5                => ancrec.ancillary_attribute5,
                                                  x_ancillary_attribute6                => ancrec.ancillary_attribute6,
                                                  x_ancillary_attribute7                => ancrec.ancillary_attribute7,
                                                  x_ancillary_attribute8                => ancrec.ancillary_attribute8,
                                                  x_ancillary_attribute9                => ancrec.ancillary_attribute9,
                                                  x_ancillary_attribute10               => ancrec.ancillary_attribute10,
                                                  x_ancillary_attribute11               => ancrec.ancillary_attribute11,
                                                  x_ancillary_attribute12               => ancrec.ancillary_attribute12,
                                                  x_ancillary_attribute13               => ancrec.ancillary_attribute13,
                                                  x_ancillary_attribute14               => ancrec.ancillary_attribute14,
                                                  x_ancillary_attribute15               => ancrec.ancillary_attribute15,
                                                  x_attribute_category                  => ancrec.attribute_category,
                                                  x_attribute1                          => ancrec.attribute1,
                                                  x_attribute2                          => ancrec.attribute2,
                                                  x_attribute3                          => ancrec.attribute3,
                                                  x_attribute4                          => ancrec.attribute4,
                                                  x_attribute5                          => ancrec.attribute5,
                                                  x_attribute6                          => ancrec.attribute6,
                                                  x_attribute7                          => ancrec.attribute7,
                                                  x_attribute8                          => ancrec.attribute8,
                                                  x_attribute9                          => ancrec.attribute9,
                                                  x_attribute10                         => ancrec.attribute10,
                                                  x_attribute11                         => ancrec.attribute11,
                                                  x_attribute12                         => ancrec.attribute12,
                                                  x_attribute13                         => ancrec.attribute13,
                                                  x_attribute14                         => ancrec.attribute14,
                                                  x_attribute15                         => ancrec.attribute15,
                                                  x_attribute16                         => ancrec.attribute16,
                                                  x_attribute17                         => ancrec.attribute17,
                                                  x_attribute18                         => ancrec.attribute18,
                                                  x_attribute19                         => ancrec.attribute19,
                                                  x_attribute20                         => ancrec.attribute20
                                                );
          END IF;
          CLOSE cur_impchgs;

-- Code for the Charges API

-- Get the Summed Up Invoice Amount from the Invoice table
-- for the Ancillary Type of Charges
          OPEN cur_inv_int(l_person_id,
                           ancrec.fee_cal_type,
                           ancrec.fee_ci_sequence_number,
                           ancrec.fee_type,
                           g_ancillary);
          FETCH cur_inv_int INTO l_prev_amount;
          CLOSE cur_inv_int;


-- Get the Fee Description
          OPEN cur_fee(ancrec.fee_type);
          FETCH cur_fee INTO l_fee_desc;
          CLOSE cur_fee;

-- Initialize the Header Record and the PL/SQL table
          l_header_rec := NULL;
          l_line_tbl   := l_line_tbl_dummy;
          l_line_tbl.DELETE;

-- Calculate the Charge Amount. This will be the difference of the Amount already
-- posted to the charges table and the current amount
          l_diff_amount := NVL(l_ancillary_chg_rate,0) - NVL(l_prev_amount,0);

          l_header_rec.p_person_id                   := l_person_id;
          l_header_rec.p_fee_type                    := ancrec.fee_type;
          l_header_rec.p_fee_cat                     := NULL;
          l_header_rec.p_fee_cal_type                := ancrec.fee_cal_type;
          l_header_rec.p_fee_ci_sequence_number      := ancrec.fee_ci_sequence_number;
          l_header_rec.p_invoice_amount              := l_diff_amount;
          l_header_rec.p_invoice_creation_date       := SYSDATE;
          l_header_rec.p_invoice_desc                := l_fee_desc;
          l_header_rec.p_transaction_type            := g_ancillary;
          l_header_rec.p_currency_cd                 := l_v_local_currency;
          l_header_rec.p_exchange_rate               := 1;
          l_header_rec.p_effective_date              := l_effective_dt;

          l_line_tbl(1).p_description                := l_fee_desc;
          l_line_tbl(1).p_amount                     := l_diff_amount;

-- This code has been added by aiyer as a part of the code fix for the bug #1954101
-- Values are being assigned to the l_line_tbl variable which gets passed to the
-- igs_fi_charges_api_pvt.create_charge procedure.

-- Start of additions as part of bug 2584986
-- gl_date always passed as sysdate, without any validations

          l_line_tbl(1).p_d_gl_date                  := TRUNC(SYSDATE);

-- override account codes are passed as null and derived in charges api
          l_line_tbl(1).p_override_dr_rec_ccid       := NULL;
          l_line_tbl(1).p_override_cr_rev_ccid       := NULL;
          l_line_tbl(1).p_override_dr_rec_account_cd := NULL;
          l_line_tbl(1).p_override_cr_rev_account_cd := NULL;

-- End of modifications

          l_line_tbl(1).p_attribute_category         := ancrec.attribute_category;
          l_line_tbl(1).p_attribute1                 := ancrec.attribute1;
          l_line_tbl(1).p_attribute2                 := ancrec.attribute2;
          l_line_tbl(1).p_attribute3                 := ancrec.attribute3;
          l_line_tbl(1).p_attribute4                 := ancrec.attribute4;
          l_line_tbl(1).p_attribute5                 := ancrec.attribute5;
          l_line_tbl(1).p_attribute6                 := ancrec.attribute6;
          l_line_tbl(1).p_attribute7                 := ancrec.attribute7;
          l_line_tbl(1).p_attribute8                 := ancrec.attribute8;
          l_line_tbl(1).p_attribute9                 := ancrec.attribute9;
          l_line_tbl(1).p_attribute10                := ancrec.attribute10;
          l_line_tbl(1).p_attribute11                := ancrec.attribute11;
          l_line_tbl(1).p_attribute12                := ancrec.attribute12;
          l_line_tbl(1).p_attribute13                := ancrec.attribute13;
          l_line_tbl(1).p_attribute14                := ancrec.attribute14;
          l_line_tbl(1).p_attribute15                := ancrec.attribute15;
          l_line_tbl(1).p_attribute16                := ancrec.attribute16;
          l_line_tbl(1).p_attribute17                := ancrec.attribute17;
          l_line_tbl(1).p_attribute18                := ancrec.attribute18;
          l_line_tbl(1).p_attribute19                := ancrec.attribute19;
          l_line_tbl(1).p_attribute20                := ancrec.attribute20;

-- If there is a difference in amount, then
          IF l_diff_amount <> 0 THEN
-- Call the Charges API
            igs_fi_charges_api_pvt.Create_Charge(p_api_version        => 2.0,
                                                 p_init_msg_list      => 'T',
                                                 p_commit             => 'F',
                                                 p_header_rec         => l_header_rec,
                                                 p_line_tbl           => l_line_tbl,
                                                 x_invoice_id         => l_invoice_id,
                                                 x_line_id_tbl        => l_line_id_tbl,
                                                 x_return_status      => l_return_status,
                                                 x_msg_count          => l_msg_count,
                                                 x_msg_data           => l_msg_data,
                                                 x_waiver_amount      => l_n_waiver_amount);

-- If the Charges API returns a Status other than S
-- this means that the Charges API has resulted in an
-- Error and this must be logged.
            IF l_return_status <> 'S' THEN
              l_exception_flag := 'Y';
              IF l_msg_count = 1 THEN
                fnd_message.set_encoded(l_msg_data);
                ancrec.error_msg := fnd_message.get;
              ELSE
                FOR l_var IN 1..l_msg_count LOOP
                  fnd_message.parse_encoded(fnd_msg_pub.get, l_appl_name, l_msg_name);
                  fnd_message.set_name(l_appl_name, l_msg_name);
                  ancrec.error_msg := ancrec.error_msg||'.'||fnd_message.get;
                END LOOP;
              END IF;
            END IF;

          END IF;
-- Ends here
-- l_diff_amount is needed to be passed to the Charges API
          EXCEPTION
            WHEN OTHERS THEN
              l_exception_flag := 'Y';
              ROLLBACK;
        END;
-- If an error happened while creating the records, then
-- Set the Ancillary Record Status to ERROR and update the Error Message
-- Field to the proper error message
        IF l_exception_flag = 'Y' THEN
          l_exception_flag := 'N';
          ancrec.status := g_error;
          IF ancrec.error_msg IS NULL THEN
            l_msg := fnd_message.get;
            IF l_msg IS NULL THEN
              fnd_message.set_name('IGS','IGS_FI_RECORD_IN_ERROR');
              ancrec.error_msg := fnd_message.get;
            ELSE
              ancrec.error_msg := l_msg;
            END IF;
            l_msg := NULL;
          END IF;
          fnd_file.put_line(fnd_file.log,ancrec.error_msg);
        END IF;
      END IF;

-- If the Ancillary Record Status is TODO then no error has occured
-- and should be updated to SUCCESS
      IF ancrec.status <> g_error THEN
        fnd_message.set_name('IGS','IGS_FI_ANC_REC_SUCCESS');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        ancrec.status := g_success;
        ancrec.error_msg:= null;
        l_rec_cntr := NVL(l_rec_cntr,0) + 1;
      ELSE
        fnd_message.set_name('IGS', 'IGS_FI_ANC_REC_IN_ERROR');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
      END IF;


-- The Record in the Ancillary Interface table to be updated with
-- the status and the error message
-- Call the TBH for updating the record
      igs_fi_anc_int_pkg.update_row(  x_rowid                                => ancrec.rowid,
                                      x_ancillary_int_id                     => ancrec.ancillary_int_id,
                                      x_person_id                            => ancrec.person_id,
                                      x_person_id_type                       => ancrec.person_id_type,
                                      x_api_person_id                        => ancrec.api_person_id,
                                      x_status                               => ancrec.status,
                                      x_fee_type                             => ancrec.fee_type,
                                      x_fee_cal_type                         => ancrec.fee_cal_type,
                                      x_fee_ci_sequence_number               => ancrec.fee_ci_sequence_number,
                                      x_ancillary_attribute1                 => ancrec.ancillary_attribute1,
                                      x_ancillary_attribute2                 => ancrec.ancillary_attribute2,
                                      x_ancillary_attribute3                 => ancrec.ancillary_attribute3,
                                      x_ancillary_attribute4                 => ancrec.ancillary_attribute4,
                                      x_ancillary_attribute5                 => ancrec.ancillary_attribute5,
                                      x_ancillary_attribute6                 => ancrec.ancillary_attribute6,
                                      x_ancillary_attribute7                 => ancrec.ancillary_attribute7,
                                      x_ancillary_attribute8                 => ancrec.ancillary_attribute8,
                                      x_ancillary_attribute9                 => ancrec.ancillary_attribute9,
                                      x_ancillary_attribute10                => ancrec.ancillary_attribute10,
                                      x_ancillary_attribute11                => ancrec.ancillary_attribute11,
                                      x_ancillary_attribute12                => ancrec.ancillary_attribute12,
                                      x_ancillary_attribute13                => ancrec.ancillary_attribute13,
                                      x_ancillary_attribute14                => ancrec.ancillary_attribute14,
                                      x_ancillary_attribute15                => ancrec.ancillary_attribute15,
                                      x_attribute_category                   => ancrec.attribute_category,
                                      x_attribute1                           => ancrec.attribute1,
                                      x_attribute2                           => ancrec.attribute2,
                                      x_attribute3                           => ancrec.attribute3,
                                      x_attribute4                           => ancrec.attribute4,
                                      x_attribute5                           => ancrec.attribute5,
                                      x_attribute6                           => ancrec.attribute6,
                                      x_attribute7                           => ancrec.attribute7,
                                      x_attribute8                           => ancrec.attribute8,
                                      x_attribute9                           => ancrec.attribute9,
                                      x_attribute10                          => ancrec.attribute10,
                                      x_attribute11                          => ancrec.attribute11,
                                      x_attribute12                          => ancrec.attribute12,
                                      x_attribute13                          => ancrec.attribute13,
                                      x_attribute14                          => ancrec.attribute14,
                                      x_attribute15                          => ancrec.attribute15,
                                      x_attribute16                          => ancrec.attribute16,
                                      x_attribute17                          => ancrec.attribute17,
                                      x_attribute18                          => ancrec.attribute18,
                                      x_attribute19                          => ancrec.attribute19,
                                      x_attribute20                          => ancrec.attribute20,
                                      x_effective_dt                         => ancrec.effective_dt,
                                      x_error_msg                            => SUBSTR(LTRIM(ancrec.error_msg,'.'),1,2000),
                                      x_validation_flag                      => ancrec.validation_flag,
                                      x_mode                                 => 'R');
      COMMIT;
    END LOOP;
    fnd_file.put_line(fnd_file.log,fnd_message.get_string ('IGS','IGS_GE_TOTAL_REC_PROCESSED')||TO_CHAR(l_rec_cntr));
    retcode :=0;

  EXCEPTION
    WHEN l_exception THEN
      retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      fnd_message.set_name('IGS','IGS_FI_ANC_REC_IN_ERROR');
      errbuf := fnd_message.Get;
      igs_ge_msg_stack.conc_exception_hndl;
  END finp_imp_calc_anc_charges;

  FUNCTION Check_Person_Id(p_person_id               IN  igs_pe_person.person_id%TYPE,
                           p_person_id_type          IN  igs_pe_person.person_id_type%TYPE,
                           p_api_person_id           IN  igs_pe_person.api_person_id%TYPE) RETURN BOOLEAN  AS
/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    12-04-2001

Purpose:            This function checks whether the Person Id specified by the Person Id Type and
                    the Alternate Person Id is present in the Person table.

Known limitations,enhancements,remarks:

Change History

Who             When            What
shtatiko        29-APR-2003     Enh# 2831569, Added new parameter p_person_id so that validation
                                of person_id_type and api_person_id combination is done against
                                given person_id i.e., now this function validates whether
                                person_id_type and api_person_id combination is exists for a given
                                person_id.
********************************************************************************************** */

    l_temp          VARCHAR2(1);
    l_ret           BOOLEAN;

-- Cursor for checking the Person Id in IGS_PE_ALT_PERS_ID table for the
-- Person Id Type and the Alternate Person Id exists in the Person table
    CURSOR cur_person(cp_person_id         igs_pe_person.person_id%TYPE,
                      cp_person_id_type    IGS_PE_PERSON.Person_Id_Type%TYPE,
                      cp_api_person_id     IGS_PE_PERSON.Api_Person_Id%TYPE) IS
      SELECT 'x'
      FROM   igs_pe_person_base_v ppv,
             igs_pe_alt_pers_id api
      WHERE  ppv.person_id      = api.pe_person_id
      AND    ppv.person_id      = cp_person_id
      AND    api.person_id_type = cp_person_id_type
      AND    api.api_person_id  = cp_api_person_id;
  BEGIN

-- Open the cursor
    OPEN cur_person(p_person_id,
                    p_person_id_type,
                    p_api_person_id);
    FETCH cur_person INTO l_temp;

-- If the Person is not found then
    IF cur_person%NOTFOUND THEN

-- Return False
      l_ret := FALSE;
    ELSE

-- Else return true
      l_ret := TRUE;
    END IF;
    CLOSE cur_person;

    RETURN l_ret;
  END check_person_id;

  FUNCTION get_person_number(p_person_id     IN  igs_pe_person.person_id%TYPE) RETURN igs_pe_person.person_number%TYPE AS

/***********************************************************************************************

Created By:         Amit Gairola

Date Created By:    12-04-2001

Purpose:            This function returns the Person Number based on the Person Id passed

Known limitations,enhancements,remarks:

Change History

Who     When       What

********************************************************************************************** */

    l_person_number         igs_pe_person.person_number%TYPE;

-- Cursor for geeting the Person Number from the Person Id
    CURSOR cur_person(cp_person_id      igs_pe_person.person_id%TYPE) IS
      SELECT person_number
      FROM   igs_pe_person_base_v
      WHERE  person_id   = cp_person_id;
  BEGIN

-- Fetch the Person Number based on the Person Id passed
    OPEN cur_person(p_person_id);
    FETCH cur_person INTO l_person_number;
    CLOSE cur_person;
    RETURN l_person_number;
  END get_person_number;

END igs_fi_prc_impclc_anc_chgs;

/
