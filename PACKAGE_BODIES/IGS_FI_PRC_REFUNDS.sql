--------------------------------------------------------
--  DDL for Package Body IGS_FI_PRC_REFUNDS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PRC_REFUNDS" AS
/* $Header: IGSFI65B.pls 120.6 2006/06/27 14:20:31 skharida noship $ */
/* **********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This package contains the procedures for processing the Refunds for the
                    Excess Unapplied Credits
  Known limitations,enhancements,remarks:
  Change History
  Who         When       What
  skharida   26-Jun-2006 Bug# 5208136 - Modified pocess_plus and process_batch procedure,
                         removed the obsoleted columns from the IGS_FI_REFUNDS_PKG
  abshriva   9-JUN-2006  Bug 5076169 Modified procedure process_batch
  sapanigr   03-May-2006 Enh#3924836 Precision Issue. Modified process_batch and process_plus.
  sapanigr   24-Feb-2006 Bug 5018036 - Removed cur_pnum in process_batch for R12 repository performance tuning
  sapanigr   14-Feb-2006 Bug 5018036. Cursors modified in procedure process_batch for R12 repository performance tuning
  smadathi   25-AUG-2003 Enh. Bug 3045007. Modified process_batch
  pathipat   24-Apr-2003 Enh 2831569 - Commercial Receivables build
                         Modified process_batch() and process_plus() - Added call to chk_manage_account()
  smadathi    21-Feb-2002 Enh. Bug 2747329. Modified Process_batch and process_plus procedures.
                          Added public cursor c_refund_cr_glccid
  shtatiko  28-JAN-2003  Bug# 2734316, modified process_plus procedure
  smadathi  15-Jan-2003    Bug 2722096. Modified process_plus procedure.
  agairola    23-Dec-02  Bug 2718029: Modified the code in Process_batch to remove the app_exception
                         .raise_exception for parameter validation and replaced it by setting retcode=2
                         and RETURN
  vvutukur  19-Nov-2002    Enh#2584986.Modified the procedures process_plus,process_batch.
  shtatiko    24-Sep-2002 Bug# 2564643, Removed references and instances of Sub Account Id.
  vvutukur     28-Jun-2002 Modified process_batch.Modified IGS_FI_TOL_LIM_DEFIED message token from REF_AMNT to
                           REF_AMOUNT.bug#2427999.
  vchappid    13-Jun-02  Bug#2411529, Incorrectly used message name has been modified
  agairola    11-Jun-02  Bug No: 2408221 modified Process_Plus
  agairola    15-May-02  Modified the process_batch procedure for bug 2373855
  rnirwani   13-Sep-2004  changed cursor cur_inst to not consider logically deleted records Bug# 3885804
********************************************************************************************** */

  g_ind_yes            CONSTANT VARCHAR2(1)  := 'Y';
  g_ind_no             CONSTANT VARCHAR2(1)  := 'N';
  g_cleared            CONSTANT VARCHAR2(30) := 'CLEARED';
  g_borrower           CONSTANT VARCHAR2(30) := 'BORROWER';
  g_student            CONSTANT VARCHAR2(30) := 'STUDENT';
  g_on_acc             CONSTANT VARCHAR2(30) := 'ON_ACCOUNT';
  g_null               CONSTANT VARCHAR2(10) := NULL;
  g_todo               CONSTANT VARCHAR2(30) := 'TODO';
  g_app                CONSTANT VARCHAR2(30) := 'APP';
  g_sponsor            CONSTANT VARCHAR2(30) := 'SPONSOR';
  g_intermit           CONSTANT VARCHAR2(30) := 'INTERMIT';
  g_dlp                CONSTANT VARCHAR2(10) := 'DLP';
  g_flp                CONSTANT VARCHAR2(10) := 'FLP';
  g_msg_lkp            CONSTANT VARCHAR2(30) := 'IGS_FI_LOCKBOX';
  g_check_add_drop     CONSTANT VARCHAR2(30) := 'CHECK_ADD_DROP';
  g_yes_no             CONSTANT VARCHAR2(30) := 'YES_NO';
  g_gl_date            CONSTANT VARCHAR2(30) := 'GL_DATE';

  g_amnt_high          igs_fi_refund_setup.amount_high%TYPE;
  g_amnt_low           igs_fi_refund_setup.amount_low%TYPE;
  e_resource_busy      EXCEPTION;
  PRAGMA               EXCEPTION_INIT(e_resource_busy,-0054);

-- PL/SQL record for the Credit Information
  TYPE crdrec IS RECORD(credit_id                 IGS_FI_CREDITS.Credit_Id%TYPE,
                        credit_class              IGS_FI_CR_TYPES.Credit_Class%TYPE,
                        unapplied_amount          IGS_FI_CREDITS.Unapplied_Amount%TYPE,
                        fee_type                  IGS_FI_FEE_TYPE.Fee_Type%TYPE,
                        fee_cal_type              IGS_CA_INST.Cal_Type%TYPE,
                        fee_ci_sequence_number    IGS_CA_INST.Sequence_Number%TYPE,
                        credit_number             IGS_FI_CREDITS.Credit_Number%TYPE);

-- PL/SQL table for storing the credit records which are to be processed for
-- refunds
  TYPE crdtab  IS TABLE OF crdrec
    INDEX BY BINARY_INTEGER;

  refund_calc   crdtab;

  l_rfnd_cntr   NUMBER(15);

-- PL/SQL record for the distinct Sub Account and FTCI combination
  TYPE rfndfee IS RECORD(fee_type                 IGS_FI_FEE_TYPE.Fee_Type%TYPE,
                         fee_cal_type             IGS_CA_INST.Cal_Type%TYPE,
                         fee_ci_sequence_number   IGS_CA_INST.Sequence_Number%TYPE);

-- PL/SQL table for storing the distinct fee periods to be refunded
  TYPE rfndtab IS TABLE OF rfndfee
    INDEX BY BINARY_INTEGER;

  refund_fee_prd    rfndtab;
  l_trm_cntr        NUMBER(15);

  CURSOR  c_refund_cr_glccid IS
  SELECT  refund_cr_gl_ccid
  FROM    igs_fi_control;


  FUNCTION get_meaning(p_lookup_type    IN  VARCHAR2,
                       p_lookup_code    IN  VARCHAR2) RETURN VARCHAR2 AS

/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This function will  fetch the meaning for the lookup type and code
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

-- Select the meaning from the Lookups table for the Lookup Type and the Lookup Code
--
    CURSOR cur_lkp(cp_lookup_type   VARCHAR2,
                   cp_lookup_code   VARCHAR2) IS
      SELECT meaning
      FROM   igs_lookups_view
      WHERE  lookup_type = cp_lookup_type
      AND    lookup_code = cp_lookup_code;

    l_meaning  igs_lookups_view.meaning%TYPE;
  BEGIN
-- Fetch the meaning from the Lookups table
    OPEN cur_lkp(p_lookup_type,
                 p_lookup_code);
    FETCH cur_lkp INTO l_meaning;
    CLOSE cur_lkp;

    RETURN l_meaning;
  END get_meaning;

  PROCEDURE log_message(p_lookup_type   IN  VARCHAR2,
                        p_lookup_code   IN  VARCHAR2,
                        p_value         IN  VARCHAR2,
                        p_level         IN  NUMBER) AS

/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This procedure will log the message in the log file of the concurrent manager
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

    l_meaning  igs_lookups_view.meaning%TYPE;
    l_message  varchar2(2000);
  BEGIN

    l_meaning := get_meaning(p_lookup_type,
                             p_lookup_code);

-- Based on the value of the level passed as input to the procedure
-- prepare the Log file line
    l_message := lpad(l_meaning,length(l_meaning)+p_level*3,' ')||':'||p_value;

-- Update the concurrent manager's log file
    fnd_file.put_line(fnd_file.log,
                      l_message);
  END log_message;

  FUNCTION val_rfnd_lim(p_refund_amnt    igs_fi_refunds.refund_amount%TYPE) RETURN BOOLEAN AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This function will validate if the Refund Amount is greater or lesser than the
                    tolerance limits
  Known limitations,enhancements,remarks:
  Change History
  Who     When       What

********************************************************************************************** */

-- Select the High and the Low Limits from the refund setup table
    CURSOR cur_rfnd_limits IS
      SELECT amount_high,
             amount_low
      FROM   igs_fi_refund_setup
      WHERE  TRUNC(sysdate) BETWEEN TRUNC(START_DATE) AND TRUNC(NVL(END_DATE,sysdate));

    l_return             BOOLEAN;
  BEGIN
    g_amnt_high := NULL;
    g_amnt_low  := NULL;

-- Fetch the Upper and the Lower limit from the Refunds Setup table into the global
-- variables for the Upper and Lower limits
    OPEN cur_rfnd_limits;
    FETCH cur_rfnd_limits INTO g_amnt_high,
                               g_amnt_low;
    CLOSE cur_rfnd_limits;

    l_return := TRUE;

-- If the upper limit fetched by the cursor is not null and the refund amount is
-- higher than the Upper limit, the function should return false
    IF ((g_amnt_high IS NOT NULL) AND (p_refund_amnt > g_amnt_high)) THEN
      l_return := FALSE;
    END IF;

-- If the lowe limit fetched by the cursor is not null and the refund amount is
-- less than the lower limit, the function should return false
    IF ((g_amnt_low IS NOT NULL) AND (p_refund_amnt < g_amnt_low)) THEN
      l_return := FALSE;
    END IF;

    RETURN l_return;
  END val_rfnd_lim;

  PROCEDURE process_plus(p_credit_id    IN   NUMBER,
                         p_borrower_id  IN   NUMBER,
                         p_err_message  OUT NOCOPY  VARCHAR2,
                         p_status       OUT NOCOPY  BOOLEAN,
			 p_d_gl_date    IN   DATE
			 ) AS

/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  11-Mar-2002
  Purpose        :  This procedure is to be called from the Financial Aid Integration process.
                    This procedure processes the refunds for the PLUS loan.
  Known limitations,enhancements,remarks:
  Change History
  Who        When          What
  skharida   26-Jun-2006   Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_REFUNDS
  sapanigr   03-May-2006   Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_refunds
                           is now rounded off to currency precision
  pathipat   24-Apr-2003   Enh 2831569 - Commercial Receivables build
                           Added check for manage_accounts - call to chk_manage_account()
  smadathi   21-Feb-2002   Enh. Bug 2747329. Added validation for refund_cr_gl_ccid
  shtatiko   28-JAN-2003   Bug# 2734316, changed message name to IGS_FI_PARAMETER_NULL from IGS_FI_INVALID_PARM
  smadathi   15-Jan-2003   Bug 2722096. Incorporated logging of error message raised by the mass_apply
                           process call.
  vvutukur  19-Nov-2002    Enh#2584986.Code added to validate the mandatory newly added IN parameter p_d_gl_date.
                           Passed this p_d_gl_date parameter to the calls to i)igs_fi_prc_appl.mass_apply,
			   ii)igs_fi_refunds_pkg.insert_row iii)igs_fi_gen_007.create_application.
  shtatiko   24-Sep-2002   Bug No: 2564643 Removed references to Subaccount_id.
  agairola   13-Jun-2002   Bug No: 2408221 For the Application Hierarchy, added the check for effective
                           start and end date
  agairola   11-Jun-2002   Bug No: 2408221 added the validation for Application Hierarchy

********************************************************************************************** */

-- Cursor for validating the credits
    CURSOR cur_val_crd(cp_credit_id IN NUMBER,
                       cp_status    IN VARCHAR2) IS
      SELECT crd.party_id,
             crd.credit_type_id,
             crd.effective_date
      FROM   igs_fi_credits crd,
             igs_fi_cr_types crt
      WHERE  crd.credit_id = cp_credit_id
      AND    crd.credit_type_id = crt.credit_type_id
      AND    crd.status = cp_status
      AND    NVL(crt.refund_allowed,g_ind_no) = g_ind_yes;

-- Cursor for selecting the credit information from the Credits table based on whether the refund is
-- allowed for the Credit Id passed as input to the procedure
    CURSOR cur_crd(cp_credit_id     IN  NUMBER,
                   cp_status        IN  VARCHAR2) IS
      SELECT CRD.PARTY_ID,
             CRD.UNAPPLIED_AMOUNT,
             CRD.FEE_CAL_TYPE,
             CRD.FEE_CI_SEQUENCE_NUMBER
      FROM   igs_fi_credits crd
      WHERE  crd.credit_id = p_credit_id
      AND    crd.status = cp_status
      FOR UPDATE NOWAIT;

-- Cursor for fetching the Application Hierarchy for the Credit Type
   CURSOR cur_appl_hier(cp_credit_type_id       igs_fi_cr_types.credit_type_id%TYPE,
                        cp_effective_date       igs_fi_credits.effective_date%TYPE) IS
     SELECT 'x'
     FROM   igs_fi_a_hierarchies
     WHERE  credit_type_id = cp_credit_type_id
     AND    cp_effective_date BETWEEN effective_start_date AND NVL(effective_end_date,cp_effective_date);

-- Variables of data type as the column of a table
    l_fee_type                     igs_fi_fee_type.fee_type%TYPE;
    l_fee_cal_type                 igs_ca_inst.cal_type%TYPE;
    l_fee_ci_sequence_number       igs_ca_inst.sequence_number%TYPE;
    l_dr_gl_ccid                   igs_fi_refunds.dr_gl_ccid%TYPE;
    l_cr_gl_ccid                   igs_fi_refunds.cr_gl_ccid%TYPE;
    l_dr_account_cd                igs_fi_refunds.dr_account_cd%TYPE;
    l_cr_account_cd                igs_fi_refunds.cr_account_cd%TYPE;
    l_rowid                        igs_fi_refunds_v.row_id%TYPE;
    l_refund_id                    igs_fi_refunds.refund_id%TYPE;
    l_invoice_id                   igs_fi_inv_int.invoice_id%TYPE;
    l_dr_ccid                      igs_fi_refunds.dr_gl_ccid%TYPE;
    l_cr_ccid                      igs_fi_refunds.cr_gl_ccid%TYPE;
    l_dr_acc_cd                    igs_fi_refunds.dr_account_cd%TYPE;
    l_cr_acc_cd                    igs_fi_refunds.cr_account_cd%TYPE;
    l_inv_amt_due                  igs_fi_inv_int.invoice_amount_due%TYPE;
    l_unapp_amount                 igs_fi_credits.unapplied_amount%TYPE;
    l_application_id               igs_fi_applications.application_id%TYPE;
    l_payee_id                     igs_fi_parties_v.person_id%TYPE;
    l_reason                       fnd_new_messages.message_text%TYPE;
    l_party_id                     igs_fi_parties_v.person_id%TYPE;
    l_determination                igs_lookups_view.lookup_code%TYPE;
    l_credit_type_id               igs_fi_cr_types.credit_type_id%TYPE;
    l_effective_date               igs_fi_credits.effective_date%TYPE;

-- Varchar2 variables
    l_err_msg                      VARCHAR2(2000);
    l_var                          VARCHAR2(1);

-- Boolean variables
    l_status                       BOOLEAN;
    l_exception                    BOOLEAN;

-- Variable of Cursor Rowtype
    l_crd_rec                      cur_crd%ROWTYPE;
    l_v_message_name               fnd_new_messages.message_name%TYPE;
    l_v_closing_status             gl_period_statuses.closing_status%TYPE;

    --- Cursor variable for publec cursor c_refund_cr_glccid
    rec_c_refund_cr_glccid         c_refund_cr_glccid%ROWTYPE;

    l_v_manage_acc                 igs_fi_control_all.manage_accounts%TYPE  := NULL;

  BEGIN

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
        p_status := FALSE;
        p_err_message := l_v_message_name;
        RETURN;
    END IF;

    SAVEPOINT RFND_PRC_PLUS;

    OPEN  c_refund_cr_glccid;
    FETCH c_refund_cr_glccid INTO rec_c_refund_cr_glccid;
    CLOSE c_refund_cr_glccid;

    -- if refund_cr_gl_ccid is set in System Options form, check if refund_cr_gl_ccid passed is of type Liability.
    IF rec_c_refund_cr_glccid.refund_cr_gl_ccid IS NOT NULL THEN
      -- if the function to check validity of Liability Account returns false
      -- return the status to flase and set the error message
      IF NOT (igs_fi_gen_apint.chk_liability_acc(p_n_ccid => rec_c_refund_cr_glccid.refund_cr_gl_ccid)) THEN
        p_status := FALSE;
        p_err_message := 'IGS_FI_INV_ACC_LIABL';
        RETURN;
      END IF;
    END IF;

-- If the Credit Id is NULL or GL Date is NULL then this is an error condition
-- and the procedure should return an error message. As these are manadatory
-- parameters.

    IF p_credit_id IS NULL OR p_d_gl_date IS NULL THEN
      p_status := FALSE;
-- Changed the message name to IGS_FI_PARAMTER_NULL from IGS_FI_INVALID_PARM
      p_err_message := 'IGS_FI_PARAMETER_NULL';
      RETURN;
    END IF;

    igs_fi_gen_gl.get_period_status_for_date(p_d_date            => p_d_gl_date,
                                             p_v_closing_status  => l_v_closing_status,
					     p_v_message_name    => l_v_message_name
					     );
    IF l_v_message_name IS NOT NULL THEN
      p_status := FALSE;
      p_err_message := l_v_message_name;
      RETURN;
    END IF;

    IF l_v_closing_status NOT IN ('O','F') THEN
      p_status := FALSE;
      p_err_message := 'IGS_FI_INVALID_GL_DATE';
      RETURN;
    END IF;

    OPEN cur_val_crd(p_credit_id,
                     g_cleared);
    FETCH cur_val_crd INTO l_party_id,
                           l_credit_type_id,
                           l_effective_date;
    IF cur_val_crd%NOTFOUND THEN
      p_status := FALSE;
      p_err_message := 'IGS_FI_RFND_NOT_ALWD';
      CLOSE cur_val_crd;
      RETURN;
    END IF;
    CLOSE cur_val_crd;


-- Call the procedure for getting the Borrower Determination
    IGS_FI_GEN_REFUNDS.Get_Borw_Det(p_credit_id       => p_credit_id,
                                    p_determination   => l_determination,
                                    p_err_message     => l_err_msg,
                                    p_status          => l_status);
-- If the procedure for Borrower Determination returns false, then
-- the Plus loans process should exit
    IF NOT l_status  THEN
      p_err_message := l_err_msg;
      p_status      := l_status;
      RETURN;
    END IF;


-- If the determination is Borrower, then the Payee should be the Borrower Id
-- passed as input to the procedure
    IF l_determination = g_borrower THEN
      l_payee_id := p_borrower_id;

-- Else if the determination is Student, then the Payee should be the Party Id
-- of the credit record
    ELSIF l_determination = g_student THEN
      l_payee_id := l_party_id;
    ELSIF l_determination = g_on_acc THEN

-- Elsif the Determination is On Account, then the procedure should return without processing
-- any refunds. The borrower has determined that the excess credit should be left on the student
-- account
      p_err_message := 'IGS_FI_RFND_ON_ACC';
      p_status := TRUE;
      RETURN;
    END IF;

-- If there are no application hierarchies defined for the Credit Type
-- then no refunds should be allowed
    OPEN cur_appl_hier(l_credit_type_id,
                       l_effective_date);
    FETCH cur_appl_hier INTO l_var;
    IF cur_appl_hier%NOTFOUND THEN
      CLOSE cur_appl_hier;
      p_status := FALSE;
      p_err_message := 'IGS_FI_NO_APPL_HIER_REFUND';
      RETURN;
    END IF;
    CLOSE cur_appl_hier;

    BEGIN

-- Call the procedure for the Mass Application of all the credits and the charges for the
-- person
-- Added logging of the error message raised by the procedure Mass Apply

      fnd_message.set_name('IGS','IGS_FI_RFND_MASS_APP_START');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log,1);

      igs_fi_prc_appl.mass_apply(p_person_id        => l_party_id,
      		                 p_person_id_grp    => g_null,
      				 p_credit_number    => g_null,
      				 p_credit_type_id   => g_null,
      				 p_credit_date_low  => g_null,
      				 p_credit_date_high => g_null,
				 p_d_gl_date        => p_d_gl_date);
      fnd_file.new_line(fnd_file.log,1);
      fnd_message.set_name('IGS','IGS_FI_RFND_MASS_APP_END');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      fnd_file.new_line(fnd_file.log,1);
    EXCEPTION
      WHEN OTHERS THEN
        ROLLBACK TO RFND_PRC_PLUS;
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_exception := TRUE;
    END;

-- If there is an error, then the procedure should exit with the status as FALSE
    IF l_exception THEN
      p_err_message := 'IGS_FI_APPL_ERR';
      p_status := FALSE;
      RETURN;
    END IF;


-- Select the credit information from the credits table
    OPEN cur_crd(p_credit_id,
                 g_cleared);
    FETCH cur_crd INTO l_crd_rec;

-- If the cursor does not return any records then this is an error condition
-- and the procedure should exit with an error message
    IF cur_crd%NOTFOUND THEN
      p_status := FALSE;
      p_err_message := 'IGS_FI_RFND_NOT_ALWD';
      CLOSE cur_crd;
      RETURN;
    END IF;
    CLOSE cur_crd;


-- If the Unapplied Amount of the credit record is less than 0
    IF l_crd_rec.unapplied_amount <= 0 THEN
      p_status := TRUE;
      RETURN;
    END IF;

    l_fee_cal_type := l_crd_rec.fee_cal_type;
    l_fee_ci_sequence_number := l_crd_rec.fee_ci_sequence_number;

-- Call the procedure for derivation of the FTCI for the Credit Record
    igs_fi_gen_refunds.get_fee_prd(p_fee_type                => l_fee_type,
                                   p_fee_cal_type            => l_fee_cal_type,
                                   p_fee_ci_sequence_number  => l_fee_ci_sequence_number,
                                   p_status                  => l_status);

-- If the status returned by the Get Fee Period is False, then the procedure should exit
    IF NOT l_status THEN
      p_status := l_status;
      p_err_message := 'IGS_FI_REFUND_FTCI';
      RETURN;
    END IF;

-- Call the procedure for determining the Refund Accounts
    igs_fi_gen_refunds.get_refund_acc(p_dr_gl_ccid           => l_dr_gl_ccid,
                                      p_cr_gl_ccid           => l_cr_gl_ccid,
                                      p_dr_account_cd        => l_dr_account_cd,
                                      p_cr_account_cd        => l_cr_account_cd,
    		                                  p_err_message          => l_err_msg,
                                      p_status               => l_status);

-- If the status returned by the Get Refund Account procedure is False, then the
-- procedure should exit
    IF NOT l_status THEN
      p_status := l_status;
      p_err_message := l_err_msg;
      RETURN;
    END IF;

-- Get the reason for the creation of refund transaction from the message
    fnd_message.set_name('IGS',
                         'IGS_FI_REFUND_REASON_PLUS');
    l_reason := fnd_message.get;

    SAVEPOINT REFUNDS;

    l_rowid := NULL;
    l_refund_id := NULL;
    l_invoice_id := NULL;

-- Call the Refunds table TBH for creating a record in the
-- refunds table
-- Call to igs_fi_gen_gl.get_formatted_amount formats refund_amount by rounding off to currency precision
    igs_fi_refunds_pkg.insert_row(X_ROWID                      => l_rowid,
                                  X_REFUND_ID                  => l_refund_id,
                                  X_VOUCHER_DATE               => TRUNC(sysdate),
                                  X_PERSON_ID                  => l_crd_rec.party_id,
                                  X_PAY_PERSON_ID              => l_payee_id,
                                  X_DR_GL_CCID                 => l_dr_gl_ccid,
                                  X_CR_GL_CCID                 => l_cr_gl_ccid,
                                  X_DR_ACCOUNT_CD              => l_dr_account_cd,
                                  X_CR_ACCOUNT_CD              => l_cr_account_cd,
                                  X_REFUND_AMOUNT              => igs_fi_gen_gl.get_formatted_amount(l_crd_rec.unapplied_amount),
                                  X_FEE_TYPE                   => l_fee_type,
                                  X_FEE_CAL_TYPE               => l_fee_cal_type,
                                  X_FEE_CI_SEQUENCE_NUMBER     => l_fee_ci_sequence_number,
                                  X_SOURCE_REFUND_ID           => g_null,
                                  X_INVOICE_ID                 => l_invoice_id,
                                  X_TRANSFER_STATUS            => g_todo,
                                  X_REVERSAL_IND               => g_ind_no,
                                  X_REASON                     => l_reason,
                                  X_ATTRIBUTE_CATEGORY         => g_null,
                                  X_ATTRIBUTE1                 => g_null,
                                  X_ATTRIBUTE2                 => g_null,
                                  X_ATTRIBUTE3                 => g_null,
                                  X_ATTRIBUTE4                 => g_null,
                                  X_ATTRIBUTE5                 => g_null,
                                  X_ATTRIBUTE6                 => g_null,
                                  X_ATTRIBUTE7                 => g_null,
                                  X_ATTRIBUTE8                 => g_null,
                                  X_ATTRIBUTE9                 => g_null,
                                  X_ATTRIBUTE10                => g_null,
                                  X_ATTRIBUTE11                => g_null,
                                  X_ATTRIBUTE12                => g_null,
                                  X_ATTRIBUTE13                => g_null,
                                  X_ATTRIBUTE14                => g_null,
                                  X_ATTRIBUTE15                => g_null,
                                  X_ATTRIBUTE16                => g_null,
                                  X_ATTRIBUTE17                => g_null,
                                  X_ATTRIBUTE18                => g_null,
                                  X_ATTRIBUTE19                => g_null,
                                  X_ATTRIBUTE20                => g_null,
				  X_GL_DATE                    => p_d_gl_date,
				  X_REVERSAL_GL_DATE           => NULL);

-- Call the Applications procedure for applying the Refund Charge to the Credit being refunded
    l_application_id := NULL;
    igs_fi_gen_007.create_application(p_credit_id             => p_credit_id,
                                      p_invoice_id            => l_invoice_id,
                                      p_amount_apply          => l_crd_rec.unapplied_amount,
                                      p_appl_type             => g_app,
                                      p_appl_hierarchy_id     => g_null,
                                      p_application_id        => l_application_id,
                                      p_validation            => g_ind_yes,
                                      p_dr_gl_ccid            => l_dr_ccid,
                                      p_cr_gl_ccid            => l_cr_ccid,
                                      p_dr_account_cd         => l_dr_acc_cd,
                                      p_cr_account_cd         => l_cr_acc_cd,
                                      p_unapp_amount          => l_unapp_amount,
                                      p_inv_amt_due           => l_inv_amt_due,
                                      p_err_msg               => l_err_msg,
                                      p_status                => l_status,
				      p_d_gl_date             => p_d_gl_date);

-- If the Applications procedure gives an error message, then the procedure should exit
    IF NOT l_status THEN
      p_err_message := l_err_msg;
      p_status      := l_status;
      ROLLBACK TO REFUNDS;
      RETURN;
    END IF;

-- If the Invoice Amount Due or the Unapplied Amount of the Credit Transaction as returned by
-- the Applications API is more than 0, then this is an error and the procedure should exit
    IF ((l_inv_amt_due > 0) OR (l_unapp_amount > 0)) THEN
      p_err_message := 'IGS_FI_REFUND_APPL_ERR';
      p_status      := FALSE;
      ROLLBACK TO REFUNDS;
      RETURN;
    END IF;

    p_err_message := NULL;
    p_status      := TRUE;
  EXCEPTION
    WHEN e_resource_busy THEN
      p_err_message := 'IGS_FI_RFND_REC_LOCK';
      p_status      := FALSE;
      ROLLBACK TO RFND_PRC_PLUS;
  END process_plus;

  PROCEDURE process_batch(errbuf               OUT NOCOPY   VARCHAR2,
                          retcode              OUT NOCOPY   NUMBER,
                          p_person_id           IN   NUMBER,
                          p_person_id_grp       IN   NUMBER,
                          p_add_drop            IN   VARCHAR2,
                          p_test_run            IN   VARCHAR2,
                          p_d_gl_date           IN   VARCHAR2) AS
/***********************************************************************************************

  Created By     :  Amit Gairola
  Date Created By:  10-Mar-2002
  Purpose        :  This procedure is used for batch processing.
  Known limitations,enhancements,remarks:
  Change History
  Who          When       What
  skharida   26-Jun-2006  Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_REFUNDS
  abshriva   9-Jun-2006 Bug:5076169  Modified code to  log message in log file in case student is not having Refund Allowed checked Credits.
  sapanigr   03-May-2006   Enh#3924836 Precision Issue. Amount values being inserted into igs_fi_refunds
                           is now rounded off to currency precision
  pmarada     19-jul-04   Bug 3775620, Logging credit number in log file, if there is no fee period for the refund fee type.
  smadathi    25-AUG-2003 Enh. Bug 3045007. Added business logic to check if the Person for which the Refunds is being processed
                          is on an Active Payment Plan
  pathipat    24-Apr-2003 Enh 2831569 - Commercial Receivables build
                          Added check for manage_accounts - call to chk_manage_account()
  smadathi    21-Feb-2002 Bug 2747329. Cursor select cur_pers was modified to replace table igs_pe_persid_group reference to
                          igs_pe_all_persid_group_v. Added validation for refund_cr_gl_ccid.
  agairola    23-Dec-02  Bug 2718029: Modified the code in Process_batch to remove the app_exception
                         .raise_exception for parameter validation and replaced it by setting retcode=2
                         and RETURN
  vvutukur     19-Nov-2002 Enh#2584986.Added mandatory IN parameter p_d_gl_date.Code added to validate GL Date.
                           Modified the calls to igs_fi_refunds_pkg.insert_row and igs_fi_gen_007.create_application to include new parameter p_d_gl_date also. Modified IGS_GE_UNHANDLED_EXCEP message to
                           IGS_GE_UNHANDLED_EXCEPTION.
  vvutukur     28-Jun-2002 modified IGS_FI_TOL_LIM_DEFIED message token from REF_AMNT to
                           REF_AMOUNT.bug#2427999.
  sarakshi     14-Jun-02  bug#2400617,the check of refunds not be processed if student is studying
                          at another instution or the student is inactive should be there irrespective
                          of the financial aid student or not.
  vchappid     13-Jun-02  Bug#2411529, Incorrectly used message name has been modified
  agairola     15-May-02  For the bug 2373855, following modifications were done
                          1.  Removed the CLOSE cur_spnsr statement from inside IF Cur_spnsr%FOUND
                              as it was already happening outside the %FOUND statements
                          2.  Added a new variable l_hld_exsts as the process was displaying that
                              Holds exist even though there were no holds because the variable
                              l_process_party was set to FALSE. Hence added the additional check.

********************************************************************************************** */

-- Cursor for validating the person id
    CURSOR cur_val_party(cp_party_id    IN igs_fi_parties_v.person_id%TYPE) IS
      SELECT person_number
      FROM   igs_fi_parties_v pe
      WHERE  pe.person_id = cp_party_id;

-- Cursor for validating the Person Id Group
      CURSOR cur_pers(cp_person_id_grp  igs_pe_persid_group.group_id%TYPE) IS
      SELECT group_cd
      FROM   igs_pe_all_persid_group_v
      WHERE  group_id=cp_person_id_grp
      AND    closed_ind <> g_ind_yes;

-- Cursor for getting the Person Ids for which the Refunds have to be
-- processed
-- Bug 5018036 - Cursor cur_party broken into cur_party and cur_party_all.
    CURSOR cur_party(cp_person_id     igs_fi_parties_v.person_id%TYPE) IS
      SELECT party_id person_id
      FROM   hz_parties
      WHERE  party_id = cp_person_id;

-- Cursor for getting the Person Ids for which the Refunds have to be
-- processed if no person id given
    CURSOR cur_party_all IS
      SELECT DISTINCT crd.party_id person_id
      FROM   igs_fi_credits crd,
             igs_fi_cr_types crt
      WHERE  crd.credit_type_id = crt.credit_type_id
      AND    crd.status         = g_cleared
      AND    NVL(crt.refund_allowed,g_ind_no) = g_ind_yes
      AND    crd.unapplied_amount > 0;

-- Cursor for validating whether the Person being processed is not a sponsor
    CURSOR cur_spnsr(cp_person_id    igs_fi_parties_v.person_id%TYPE) IS
      SELECT 'x'
      FROM   igf_aw_fund_mast fund,
             igf_aw_fund_cat  fcat
      WHERE  fund.fund_code     = fcat.fund_code
      AND    fcat.sys_fund_type = g_sponsor
      AND    fund.party_id      = cp_person_id;

-- Cursor for getting the credit records for the Person Id
    CURSOR cur_crd(cp_person_id    igs_fi_parties_v.person_id%TYPE,
                   cp_status       igs_fi_credits.status%TYPE
                   ) IS
      SELECT crd.*, crt.credit_class
      FROM   igs_fi_credits crd,
             igs_fi_cr_types crt,
	     igs_fi_cr_activities cra
      WHERE  crd.credit_type_id = crt.credit_type_id
      AND    crd.status         = cp_status
      AND    crd.party_id       = cp_person_id
      AND    NVL(crt.refund_allowed,g_ind_no) = g_ind_yes
      AND    crt.credit_class <> 'SPNSP'
      AND    crd.unapplied_amount > 0
      AND    cra.credit_id = crd.credit_id;

-- Cursor for validating if any program attempt of the person is in INTERMIT state and the
-- intermission type has the study at another institution flag set
    CURSOR cur_inst(cp_person_id      igs_fi_parties_v.person_id%TYPE,
                    cp_crs_stat       igs_en_stdnt_ps_att.course_attempt_status%TYPE) IS
      SELECT 'x'
      FROM   igs_en_stdnt_ps_att spa,
             igs_en_intm_types intm,
             igs_en_stdnt_ps_intm spi
      WHERE  spa.person_id = cp_person_id
      AND    spa.person_id = spi.person_id
      AND    spa.course_cd = spi.course_cd
      AND    spa.course_attempt_status = cp_crs_stat
      AND    spi.intermission_type = intm.intermission_type
      AND    spi.logical_delete_date = TO_DATE('31-12-4712','DD-MM-YYYY')
      AND    intm.study_antr_inst_ind = g_ind_yes;

-- Cursor for validating if there is any program attempt of the person in
-- status INACTIVE or ENROLLED. This validation is required to validate if the Person
-- is active in the system
    CURSOR cur_crs(cp_person_id     igs_fi_parties_v.person_id%TYPE) IS
      SELECT 'x'
      FROM   igs_en_stdnt_ps_att
      WHERE  person_id = cp_person_id
      AND    course_attempt_status IN ('INACTIVE','ENROLLED');

-- Cursor for getting the Fee Calendar Instance details.
    CURSOR cur_cal(cp_cal_type    VARCHAR2,
                   cp_seq_num     NUMBER) IS
      SELECT cal_type||'  '||to_char(start_dt)||'   '||to_char(end_dt) fee_prd
      FROM   igs_ca_inst
      WHERE  cal_type        = cp_cal_type
      AND    sequence_number = cp_seq_num;

-- Cursor for getting the Invoice Number based on the Invoice Id
    CURSOR cur_inv(cp_invoice_id   NUMBER) IS
      SELECT invoice_number
      FROM   igs_fi_inv_int
      WHERE  invoice_id = cp_invoice_id;


-- Variables of the database column type
    l_dr_gl_ccid                   igs_fi_refunds.dr_gl_ccid%TYPE;
    l_cr_gl_ccid                   igs_fi_refunds.cr_gl_ccid%TYPE;
    l_dr_account_cd                igs_fi_refunds.dr_account_cd%TYPE;
    l_cr_account_cd                igs_fi_refunds.cr_account_cd%TYPE;
    l_rowid                        igs_fi_refunds_v.row_id%TYPE;
    l_refund_id                    igs_fi_refunds.refund_id%TYPE;
    l_invoice_id                   igs_fi_inv_int.invoice_id%TYPE;
    l_dr_ccid                      igs_fi_refunds.dr_gl_ccid%TYPE;
    l_cr_ccid                      igs_fi_refunds.cr_gl_ccid%TYPE;
    l_dr_acc_cd                    igs_fi_refunds.dr_account_cd%TYPE;
    l_cr_acc_cd                    igs_fi_refunds.cr_account_cd%TYPE;
    l_inv_amt_due                  igs_fi_inv_int.invoice_amount_due%TYPE;
    l_unapp_amount                 igs_fi_credits.unapplied_amount%TYPE;
    l_application_id               igs_fi_applications.application_id%TYPE;
    l_payee_id                     igs_fi_parties_v.person_id%TYPE;
    l_reason                       fnd_new_messages.message_text%TYPE;
    l_err_msg                      fnd_new_messages.message_name%TYPE;
    l_determination                igs_lookups_view.lookup_code%TYPE;
    l_fee_type                     igs_fi_fee_type.fee_type%TYPE;
    l_fee_cal_type                 igs_ca_inst.cal_type%TYPE;
    l_fee_ci_sequence_number       igs_ca_inst.sequence_number%TYPE;
    l_rfnd_amnt                    igs_fi_refunds.refund_amount%TYPE;
    l_party_number                 igs_fi_parties_v.person_number%TYPE;
    l_invoice_number               igs_fi_inv_int.invoice_number%TYPE;
    l_group_cd                     igs_pe_all_persid_group_v.group_cd%TYPE;
    l_v_message_name               fnd_new_messages.message_name%TYPE;
    l_v_closing_status             gl_period_statuses.closing_status%TYPE;
    l_d_gl_date                    igs_fi_credits_all.gl_date%TYPE;
    l_n_party_id                   hz_parties.party_id%TYPE;
    l_v_manage_acc                 igs_fi_control_all.manage_accounts%TYPE  := NULL;

-- Variables holding number type data
    l_n_cntr                       NUMBER(15) := 0;
    l_cntr                         NUMBER(15);
    l_rfndcntr                     NUMBER(15);
    l_trm_cntr                     NUMBER(15);
    l_loop                         NUMBER(15);
    l_msg_count                    NUMBER(15);

-- Variables holding Varchar2 type data
    l_var                          VARCHAR2(1);
    l_msg_text                     VARCHAR2(2000);
    l_v_sql_stmnt                  VARCHAR2(32767) ;
    l_v_status                     VARCHAR2(32767);

-- Variables of type BOOLEAN
    l_rec_match                    BOOLEAN := FALSE;
    l_party_process                BOOLEAN := FALSE;
    l_status                       BOOLEAN;
    l_rec_found                    BOOLEAN;
    l_fa_received                  BOOLEAN;
    l_process_flag                 BOOLEAN;
    l_exception_flag               BOOLEAN;
    l_val_parameters               BOOLEAN := TRUE;
    l_hld_exsts                    BOOLEAN := FALSE;

    -- Rowtype variables
    l_fee_prd    cur_cal%ROWTYPE;

    -- cursor variable for cursor c_refund_cr_glccid
    rec_c_refund_cr_glccid  c_refund_cr_glccid%ROWTYPE;

    TYPE r_c_grp_cur IS REF CURSOR ;
    TYPE tab_party_rec IS TABLE OF hz_parties.party_id%TYPE INDEX BY BINARY_INTEGER;
    c_ref_grp_cur  r_c_grp_cur;
    v_tab_party_rec tab_party_rec ;

    l_n_act_plan_id       igs_fi_pp_std_attrs.student_plan_id%TYPE;
    l_v_act_plan_name     igs_fi_pp_templates.payment_plan_name%TYPE;
    lv_group_type         igs_pe_persid_group_v.group_type%TYPE;

  BEGIN
    igs_ge_gen_003.set_org_id(g_null);

    retcode := 0;
    errbuf  := NULL;

    -- Obtain the value of manage_accounts in the System Options form
    -- If it is null or 'OTHER', then this process is not available, so error out.
    igs_fi_com_rec_interface.chk_manage_account( p_v_manage_acc   => l_v_manage_acc,
                                                 p_v_message_name => l_v_message_name
                                               );
    IF (l_v_manage_acc = 'OTHER') OR (l_v_manage_acc IS NULL) THEN
       fnd_message.set_name('IGS',l_v_message_name);
       fnd_file.put_line(fnd_file.log,fnd_message.get());
       fnd_file.new_line(fnd_file.log);
       retcode := 2;
       RETURN;
    END IF;

    SAVEPOINT RFND_PRC_BATCH;

    l_val_parameters := TRUE;

-- Initialize the PL/SQL tables
    refund_calc.delete;
    refund_fee_prd.delete;

-- Log the Input parameters
    fnd_message.set_name('IGS','IGS_FI_ANC_LOG_PARM');
    fnd_file.put_line(fnd_file.log,fnd_message.get);

    l_var := NULL;

-- If the person id is not null, then validate the Person id
    OPEN cur_val_party(p_person_id);
    FETCH cur_val_party INTO l_party_number;
    log_message(g_msg_lkp,
                'PERSON',
                l_party_number,
                1);
    IF (cur_val_party%NOTFOUND AND p_person_id IS NOT NULL) THEN
      fnd_message.set_name('IGS','IGS_FI_INVALID_PERSON_ID');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_val_parameters := FALSE;
    END IF;
    CLOSE cur_val_party;

    l_var := NULL;

-- If the Person id Group is not null, then validate the Person Id Group
    OPEN cur_pers(p_person_id_grp);
    FETCH cur_pers INTO l_group_cd;
    log_message(g_msg_lkp,
                'PERSON_GROUP',
                l_group_cd,
                1);

    IF (cur_pers%NOTFOUND AND p_person_id_grp IS NOT NULL) THEN

      fnd_message.set_name('IGS','IGS_FI_INVPERS_ID_GRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_val_parameters := FALSE;

    END IF;
    CLOSE cur_pers;

    --GL Date parameter is mandatory to this concurrent job, hence it is passed as null, error out NOCOPY the job.
    IF p_d_gl_date IS NULL THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_PARAMETER_NULL');
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      l_val_parameters := FALSE;
    END IF;

    --Convert the parameter p_d_gl_date from VARCHAR2 to DATE datatype.
    l_d_gl_date := IGS_GE_DATE.IGSDATE(p_d_gl_date);

    log_message(g_msg_lkp,
                'VAL_ADD_DROP',
                get_meaning(g_check_add_drop,p_add_drop),
                1);

    log_message(g_msg_lkp,
                'GL_DATE',
                l_d_gl_date,
		1);

    log_message(g_msg_lkp,
                'TEST_MODE',
                get_meaning(g_yes_no,p_test_run),
                1);


-- If the Person Id and the Person id Group are passed, then the process should
-- error out NOCOPY
-- IGS_FI_PRS_PRSIDGRP_NULL message replaced by IGS_FI_NO_PERS_PGRP
    IF p_person_id IS NOT NULL AND p_person_id_grp IS NOT NULL THEN
      fnd_message.set_name('IGS','IGS_FI_NO_PERS_PGRP');
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      l_val_parameters := FALSE;
    END IF;

    --Validate the GL Date.
    igs_fi_gen_gl.get_period_status_for_date(p_d_date            => l_d_gl_date,
                                             p_v_closing_status  => l_v_closing_status,
					     p_v_message_name    => l_v_message_name
					     );
    IF l_v_message_name IS NOT NULL THEN
      FND_MESSAGE.SET_NAME('IGS',l_v_message_name);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      l_val_parameters := FALSE;
    END IF;

    --Error out NOCOPY the concurrent process if the GL Date is not a valid one.
    IF l_v_closing_status NOT IN ('O','F') THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_FI_INVALID_GL_DATE');
      FND_MESSAGE.SET_TOKEN('GL_DATE',l_d_gl_date);
      FND_FILE.PUT_LINE(FND_FILE.LOG,FND_MESSAGE.GET);
      l_val_parameters := FALSE;
    END IF;

    OPEN  c_refund_cr_glccid;
    FETCH c_refund_cr_glccid INTO rec_c_refund_cr_glccid;
    CLOSE c_refund_cr_glccid;

    IF rec_c_refund_cr_glccid.refund_cr_gl_ccid IS NOT NULL THEN
      -- if the function to check validity of Liability Account CCID combination returns false
      -- log the message and errors out
      IF NOT (igs_fi_gen_apint.chk_liability_acc(p_n_ccid => rec_c_refund_cr_glccid.refund_cr_gl_ccid)) THEN
        fnd_message.set_name('IGS','IGS_FI_INV_ACC_LIABL');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_val_parameters := FALSE;
      END IF;
    END IF;


    fnd_file.new_line(fnd_file.log,2);

    IF NOT l_val_parameters THEN
      retcode := 2;
      RETURN;
    END IF;

-- Derive the Refunds Accounting
    igs_fi_gen_refunds.get_refund_acc(p_dr_gl_ccid       => l_dr_gl_ccid,
                                      p_cr_gl_ccid       => l_cr_gl_ccid,
                                      p_dr_account_cd    => l_dr_account_cd,
                                      p_cr_account_cd    => l_cr_account_cd,
                                      p_err_message      => l_err_msg,
                                      p_status           => l_status);

-- If the Refunds Accounting procedure returns an error, then
-- the process should log this in the log file of the concurrent manager
    IF NOT l_status THEN
      fnd_message.set_name('IGS',l_err_msg);
      fnd_file.put_line(fnd_file.log,fnd_message.get);
      app_exception.raise_exception;
    END IF;

    IF p_person_id_grp IS NOT NULL THEN
      --Bug #5021084
      l_v_sql_stmnt := igf_ap_ss_pkg.get_pid(p_person_id_grp, l_v_status ,lv_group_type);

      --Bug #5021084. Passing Group ID if the group type is STATIC.
      IF lv_group_type = 'STATIC' THEN
        OPEN  c_ref_grp_cur FOR l_v_sql_stmnt USING p_person_id_grp;
      ELSIF lv_group_type = 'DYNAMIC' THEN
        OPEN  c_ref_grp_cur FOR l_v_sql_stmnt;
      END IF;

      LOOP
        FETCH c_ref_grp_cur INTO l_n_party_id;
        EXIT WHEN c_ref_grp_cur%NOTFOUND;
        v_tab_party_rec(l_n_cntr) := l_n_party_id;
        l_n_cntr := NVL(l_n_cntr,0) +1;
      END LOOP;
      CLOSE c_ref_grp_cur;
    -- If person_id passed then open cur_party and if no ID info given
    -- then open cur_party_all to process all records with extra credits
    ELSIF p_person_id IS NOT NULL THEN
        OPEN  cur_party(p_person_id);
        FETCH cur_party BULK COLLECT INTO v_tab_party_rec;
        CLOSE cur_party;
    ELSE
        OPEN  cur_party_all;
        FETCH cur_party_all BULK COLLECT INTO v_tab_party_rec;
        CLOSE cur_party_all;
    END IF;

    l_n_cntr := v_tab_party_rec.FIRST;
   IF v_tab_party_rec.COUNT > 0 THEN
    -- Loop across all the Person ids identified for processing for Refunds
    FOR l_n_cntr IN v_tab_party_rec.FIRST..v_tab_party_rec.LAST
    LOOP
       l_n_party_id := v_tab_party_rec(l_n_cntr);
     -- Fetch the Party Number for the Person Id being passed as input
      l_party_number := igs_fi_gen_008.get_party_number(l_n_party_id);

      log_message(g_msg_lkp,
                  'PERSON',
                  l_party_number,
                  1);

      l_party_process := TRUE;

-- Validate if the Party exists as a sponsor in the system. If the party is a sponsor
-- then no refunds should be done for the party and the process should proceed for
-- refunds for the next person
      OPEN cur_spnsr(l_n_party_id);
      FETCH cur_spnsr INTO l_var;
      IF cur_spnsr%FOUND THEN
        fnd_message.set_name('IGS','IGS_FI_RFND_NOT_SPNSR');
        fnd_file.put_line(fnd_file.log,fnd_message.get);
        l_party_process := FALSE;
      END IF;
      CLOSE cur_spnsr;


--bug#2400617,the check of refunds not be processed if student is studyng at another instution or the
--student is inactive should be there irrespective of the financial aid student or not.

-- If the Refunds have to be processed as per the validations earlier, in case of Financial Aid
-- received for the period, then automatic refunds should not be done in the following cases
-- 1.  Student is studying at another institution
-- 2.  Student is inactive in the system i.e. if any program attempt status of the student
--     is INACTIVE or ENROLLED, then the student is active in the system

      IF l_party_process THEN

         -- Validate if the Student is studying at another institution. If yes, then no automatic refunds
         -- have to be processed for the student
         OPEN cur_inst(l_n_party_id,
                       g_intermit);
         FETCH cur_inst INTO l_var;
         IF cur_inst%FOUND THEN
           fnd_message.set_name('IGS','IGS_FI_PRG_INTERMIT');
           fnd_file.new_line(fnd_file.log,1);
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
           l_party_process:= FALSE;
         END IF;
         CLOSE cur_inst;

         -- If the earlier validation is passed, i.e. the l_process_flag is not set to FALSE
         IF l_party_process THEN

           -- validate if any program attempt of the student is INACTIVE or ENROLLED
           OPEN cur_crs(l_n_party_id);
           FETCH cur_crs INTO l_var;

           -- If there are none, then refunds should not be processed for the student
           IF cur_crs%NOTFOUND THEN
             fnd_message.set_name('IGS','IGS_FI_STDNT_NOT_ACTIVE');
             fnd_file.new_line(fnd_file.log,1);
             fnd_file.put_line(fnd_file.log,fnd_message.get);
             fnd_file.new_line(fnd_file.log,1);
             l_party_process:= FALSE;
           END IF;
           CLOSE cur_crs;
         END IF;
       END IF;


-- validate if the Person has any holds of STOPREFUNDS
      IF igs_fi_gen_refunds.get_rfnd_hold(p_person_id => l_n_party_id) THEN
        l_hld_exsts := TRUE;
        l_party_process := FALSE;
      END IF;

      l_rfnd_cntr := 0;
      l_trm_cntr  := 0;

      refund_calc.DELETE;
      refund_fee_prd.DELETE;

-- If the refunds have to be processed for the person, then
      IF l_party_process THEN

        -- check if the Person for which the Refunds is being processed is on an Active Payment Plan.
        -- If the person is on an active payment plan, then a warning needs to be logged in the log file.
        -- The process will continue after logging this warning message
        -- Invoke the Generic procedure
        igs_fi_gen_008.get_plan_details (p_n_person_id      => l_n_party_id,
                                         p_n_act_plan_id    => l_n_act_plan_id,
                                         p_v_act_plan_name  => l_v_act_plan_name
                                        );

        IF l_v_act_plan_name IS NOT NULL THEN
           fnd_message.set_name('IGS','IGS_FI_PP_RFND_WARN');
           fnd_file.new_line(fnd_file.log,1);
           fnd_file.put_line(fnd_file.log,fnd_message.get);
           fnd_file.new_line(fnd_file.log,1);
	   retcode := 1;
        END IF;

        l_rec_found := FALSE;

-- Fetch all the cleared credit records for the Person Id being processed
        FOR reccrd IN cur_crd(l_n_party_id,
                              g_cleared) LOOP
          l_rec_found := TRUE;

          l_cntr := 0;

-- If the credit source of the Credit Record is DLP or FLP, then
          IF ((reccrd.credit_source IS NOT NULL) AND (reccrd.credit_source IN (g_dlp,g_flp))) THEN

            l_err_msg       := NULL;
            l_status        := TRUE;
            l_determination := NULL;

-- This means that the Credit Record being processed is a PLUS loan which should not have been
-- selected because if any refunds were to be done for this credit record, then it should have already
-- been done in the Plus loans process. However, if there is a borrower determination for the
-- credit to be in Student Account, then nothing needs to be done for this credit. Else
-- the process should log this as error in the concurrent manager log file

-- Determine the Borrower's determination for the PLUS loan
            igs_fi_gen_refunds.get_borw_det(p_credit_id       => reccrd.credit_id,
	                                    p_determination   => l_determination,
	                                    p_err_message     => l_err_msg,
                                            p_status          => l_status);

-- If the Borrower's Determination process results in an error, then
-- this error message should be logged in the log file of the concurrent manager.
            IF NOT l_status THEN
              fnd_message.set_name('IGS',
                                   l_err_msg);
              fnd_file.put_line(fnd_file.log,
                                fnd_message.get);
            ELSE

-- if the borrower determination procedure returns success, then validate the determination
-- if the borrower determination is ON ACCOUNT, then log this in the log file of the
-- concurrent manager and no refunds need to be processed for this
              IF l_determination = g_on_acc THEN
                fnd_message.set_name('IGS',
                                     'IGS_FI_RFND_CRD_ACC');
                fnd_message.set_token('CRD_NUM',
                                      reccrd.credit_number);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              ELSE

-- else this credit record has had errors when the PLUS loan process tried to process it.
-- Hence, this should be logged in the log file of the concurrent manager
                fnd_message.set_name('IGS',
                                     'IGS_FI_RFND_CRD_PLUS');
                fnd_message.set_token('CREDIT_NUMBER',
                                      reccrd.credit_number);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
              END IF;
            END IF;
          ELSE
            l_fee_cal_type           := reccrd.fee_cal_type;
            l_fee_ci_sequence_number := reccrd.fee_ci_sequence_number;
            l_fee_type               := NULL;
            l_status                 := TRUE;

            OPEN cur_cal(l_fee_cal_type,
                         l_fee_ci_sequence_number);
            FETCH cur_cal INTO l_fee_prd;
            CLOSE cur_cal;

-- Determine the Fee Type, Fee Calendar Instance for the Sub Account
            igs_fi_gen_refunds.get_fee_prd(p_fee_type               => l_fee_type,
                                           p_fee_cal_type           => l_fee_cal_type,
                                           p_fee_ci_sequence_number => l_fee_ci_sequence_number,
                                           p_status                 => l_status);

-- If the procedure returns with an error, then this should be logged in the log file
-- of the concurrent manager
            IF NOT l_status THEN
               -- Log the processing Credit number in log file, bug 3775620
               log_message(g_msg_lkp,
                          'CREDIT_NUMBER',
                           reccrd.credit_number,
                           1);
               fnd_message.set_name('IGS','IGS_FI_REFUND_FTCI');
               fnd_file.put_line(fnd_file.log,fnd_message.get);
               l_fee_prd := NULL;
               fnd_file.put_line(fnd_file.log,fnd_message.get);
            ELSE

-- Else this should be added to the PL/SQL table for the Refunds processing
              l_rfnd_cntr := l_rfnd_cntr + 1;
              refund_calc(l_rfnd_cntr).fee_type               := l_fee_type;
              refund_calc(l_rfnd_cntr).fee_cal_type           := l_fee_cal_type;
              refund_calc(l_rfnd_cntr).fee_ci_sequence_number := l_fee_ci_sequence_number;
              refund_calc(l_rfnd_cntr).credit_class           := reccrd.credit_class;
              refund_calc(l_rfnd_cntr).unapplied_amount       := reccrd.unapplied_amount;
              refund_calc(l_rfnd_cntr).credit_id              := reccrd.credit_id;
              refund_calc(l_rfnd_cntr).credit_number          := reccrd.credit_number;
            END IF;
          END IF;
        END LOOP;

        refund_fee_prd.DELETE;

        l_trm_cntr := 0;

-- if there are any records in the Refunds PL/SQL table, then get the distinct Fee Calendar Instance,
-- from the PL/SQL table. These distinct values are the Fee Calendar Instances for which
-- the refunds need to be processed
        IF refund_calc.COUNT > 0 THEN

-- Loop across all the credits being identified for refunds
-- The following code determines the distinct combination of the Sub Account, Fee Type, Fee Cal Type
-- and Fee Ci Sequence Number and puts all such distinct combinations into another PL/SQL table
          FOR l_loop IN refund_calc.FIRST..refund_calc.LAST LOOP

-- If it is the first record being processed, then add the Sub Account, Fee Type, Fee Cal Type and
-- Fee CI Sequence Number to the Refunds Fee Periods PL/SQL table
            IF refund_fee_prd.COUNT = 0 THEN
              l_trm_cntr := l_trm_cntr + 1;
              refund_fee_prd(l_trm_cntr).fee_type                := refund_calc(l_loop).fee_type;
              refund_fee_prd(l_trm_cntr).fee_cal_type            := refund_calc(l_loop).fee_cal_type;
              refund_fee_prd(l_trm_cntr).fee_ci_sequence_number  :=
                 refund_calc(l_loop).fee_ci_sequence_number;
            ELSE

-- Else if there are any records in the Refunds Fee Periods PL/SQL table, then the code identifies whether
-- the combination already exists in the PL/SQL table or not. If it exists, then no need to do anything
-- else the combination needs to be added in the PL/SQL table for Refunds Fee Periods
              IF refund_fee_prd.COUNT > 0 THEN
                l_rec_match := FALSE;
                FOR l_cntr IN refund_fee_prd.FIRST..refund_fee_prd.LAST LOOP
                  IF ((refund_fee_prd(l_cntr).fee_type = refund_calc(l_loop).fee_type) AND
                      (refund_fee_prd(l_cntr).fee_cal_type = refund_calc(l_loop).fee_cal_type) AND
                      (refund_fee_prd(l_cntr).fee_ci_sequence_number =
                       refund_calc(l_loop).fee_ci_sequence_number)) THEN
                    l_rec_match := TRUE;
                  END IF;
                END LOOP;

                IF NOT l_rec_match THEN
                  l_trm_cntr := l_trm_cntr + 1;
                  refund_fee_prd(l_trm_cntr).fee_type                := refund_calc(l_loop).fee_type;
                  refund_fee_prd(l_trm_cntr).fee_cal_type            := refund_calc(l_loop).fee_cal_type;
                  refund_fee_prd(l_trm_cntr).fee_ci_sequence_number  :=
                    refund_calc(l_loop).fee_ci_sequence_number;
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;

-- If there are some records in the Refunds Fee Periods then
        IF refund_fee_prd.COUNT > 0 THEN

-- Loop across all such records in the Refunds Fee Periods table
          FOR l_loop IN refund_fee_prd.FIRST..refund_fee_prd.LAST LOOP
            l_fee_type               := refund_fee_prd(l_loop).fee_type;
            l_fee_cal_type           := refund_fee_prd(l_loop).fee_cal_type;
            l_fee_ci_sequence_number := refund_fee_prd(l_loop).fee_ci_sequence_number;

            l_fa_received := FALSE;
            l_cntr := 0;
            l_rfnd_amnt := 0;

            OPEN cur_cal(l_fee_cal_type,
	                 l_fee_ci_sequence_number);
	    FETCH cur_cal INTO l_fee_prd;
	    CLOSE cur_cal;

-- For each of the combination of Sub Account and FTCI in the Refunds Fee Periods table,
-- loop across all the records in the Refunds Calculation PL/SQL table which match the combination
            FOR l_cntr IN refund_calc.FIRST..refund_calc.LAST LOOP
	      IF ((refund_calc(l_cntr).fee_type      = l_fee_type) AND
	          (refund_calc(l_cntr).fee_cal_type  = l_fee_cal_type) AND
                  (refund_calc(l_cntr).fee_ci_sequence_number = l_fee_ci_sequence_number)) THEN

-- Calculate the total amount to be refunded by summing up the total unapplied amount of the credits
                l_rfnd_amnt := NVL(l_rfnd_amnt,0)+
                               NVL(refund_calc(l_cntr).unapplied_amount,0);

              END IF;
            END LOOP;
-- If any of the credits in the Refunds Calculation PL/SQL table has a Financial Aid or Sponsorship
-- Credit Class, then set the flag for the Financial Aid received for the Fee Period
            FOR l_cntr IN refund_calc.FIRST..refund_calc.LAST LOOP
               IF ((refund_calc(l_cntr).fee_cal_type = l_fee_cal_type) AND
                   (refund_calc(l_cntr).fee_ci_sequence_number =l_fee_ci_sequence_number)) THEN

                 -- If any of the credits in the Refunds Calculation PL/SQL table has a Financial Aid or Sponsorship
                 -- Credit Class, then set the flag for the Financial Aid received for the Fee Period
                 IF refund_calc(l_cntr).credit_class in ('EXTFA','INTFA','SPNSP') THEN
                    l_fa_received := TRUE;
                 END IF;
               END IF;
            END LOOP;


            l_process_flag := TRUE;

            IF l_rfnd_amnt <= 0 THEN
              l_process_flag := FALSE;
            END IF;



-- If the Financial Aid is Received then validate if the Add Drop period is specified
            IF (l_fa_received AND l_process_flag) THEN

-- If the Add Drop parameter is not null and the add drop parameter value is ALL or FINAID, then
              IF ((p_add_drop IS NOT NULL) AND (p_add_drop IN ('ALL','FINAID'))) THEN

-- Call the function for validating the Add Drop for the Fee Period
                IF IGS_FI_GEN_REFUNDS.Val_Add_Drop(l_fee_cal_type,
                                                   l_fee_ci_sequence_number) THEN

-- If the function returns true, then this fee period should not be processed for refunds as it is still
-- in the Add Drop period
                  fnd_message.set_name('IGS',
                                       'IGS_FI_ADD_DROP');
                  fnd_message.set_token('FEE_PRD',
                                        l_fee_prd.fee_prd);
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get);
                  l_process_flag := FALSE;
                END IF;
              END IF;
            ELSIF ((l_process_flag) AND (l_fa_received = FALSE)) THEN

-- Else if the Financial Aid is not received in the Fee Period, then validate if
-- the Add Drop period is there for the Fee Calendar Instance
              IF ((p_add_drop IS NOT NULL) AND (p_add_drop = 'ALL')) THEN
                IF IGS_FI_GEN_REFUNDS.Val_Add_Drop(l_fee_cal_type,
                                                   l_fee_ci_sequence_number) THEN
                  fnd_message.set_name('IGS',
                                       'IGS_FI_ADD_DROP');
                  fnd_message.set_token('FEE_PRD',
                                        l_fee_prd.fee_prd);
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get);

-- If the Add Drop period is valid, then set the l_process_flag to FALSE
-- Based on this l_process_flag, the refunds are processed
                  l_process_flag := FALSE;
	        END IF;
              END IF;
            END IF;

-- If the l_process_flag is set to TRUE, then
            IF l_process_flag THEN

-- Validate if the Refund Amount is within the Tolerance limits if setup
-- call the function val_rfnd_lim to validate if the refund amount is within the Tolerance
-- limits. If the refund amount is not within the Tolerance limits then refunds should not be
-- processed and the log file of the concurrent manager should be updated appropriately
              IF NOT val_rfnd_lim(l_rfnd_amnt) THEN
                fnd_message.set_name('IGS',
                                     'IGS_FI_TOL_LIM_DEFIED');
                fnd_message.set_token('REF_AMOUNT',
                                      To_Char(l_rfnd_amnt));
                fnd_message.set_token('HIGH_LIM',
                                      To_Char(g_amnt_high));
                fnd_message.set_token('LOW_LIM',
                                      To_Char(g_amnt_low));
                fnd_file.new_line(fnd_file.log,
                                  1);
                fnd_file.put_line(fnd_file.log,
                                  fnd_message.get);
                fnd_file.new_line(fnd_file.log,
                                  1);
              ELSE

-- Call the Refunds table handler for creating a record in the Refunds table
                l_rowid := g_null;
                l_refund_id := g_null;
                l_invoice_id := g_null;
                fnd_message.set_name('IGS',
	                             'IGS_FI_REFUND_REASON_BATCH');
                l_reason := fnd_message.get;

                SAVEPOINT REFUNDS;
                BEGIN
                  l_exception_flag := FALSE;

               -- Call to igs_fi_gen_gl.get_formatted_amount formats refund_amount by rounding off to currency precision
                l_rfnd_amnt := igs_fi_gen_gl.get_formatted_amount(l_rfnd_amnt);

                  igs_fi_refunds_pkg.insert_row(X_ROWID                      => l_rowid,
                                                X_REFUND_ID                  => l_refund_id,
                                                X_VOUCHER_DATE               => TRUNC(sysdate),
                                                X_PERSON_ID                  => l_n_party_id,
                                                X_PAY_PERSON_ID              => l_n_party_id,
                                                X_DR_GL_CCID                 => l_dr_gl_ccid,
                                                X_CR_GL_CCID                 => l_cr_gl_ccid,
                                                X_DR_ACCOUNT_CD              => l_dr_account_cd,
                                                X_CR_ACCOUNT_CD              => l_cr_account_cd,
                                                X_REFUND_AMOUNT              => l_rfnd_amnt,
                                                X_FEE_TYPE                   => l_fee_type,
                                                X_FEE_CAL_TYPE               => l_fee_cal_type,
                                                X_FEE_CI_SEQUENCE_NUMBER     => l_fee_ci_sequence_number,
                                                X_SOURCE_REFUND_ID           => g_null,
                                                X_INVOICE_ID                 => l_invoice_id,
                                                X_TRANSFER_STATUS            => g_todo,
                                                X_REVERSAL_IND               => g_ind_no,
                                                X_REASON                     => l_reason,
                                                X_ATTRIBUTE_CATEGORY         => g_null,
                                                X_ATTRIBUTE1                 => g_null,
                                                X_ATTRIBUTE2                 => g_null,
                                                X_ATTRIBUTE3                 => g_null,
                                                X_ATTRIBUTE4                 => g_null,
                                                X_ATTRIBUTE5                 => g_null,
                                                X_ATTRIBUTE6                 => g_null,
                                                X_ATTRIBUTE7                 => g_null,
                                                X_ATTRIBUTE8                 => g_null,
                                                X_ATTRIBUTE9                 => g_null,
                                                X_ATTRIBUTE10                => g_null,
                                                X_ATTRIBUTE11                => g_null,
                                                X_ATTRIBUTE12                => g_null,
                                                X_ATTRIBUTE13                => g_null,
                                                X_ATTRIBUTE14                => g_null,
                                                X_ATTRIBUTE15                => g_null,
                                                X_ATTRIBUTE16                => g_null,
                                                X_ATTRIBUTE17                => g_null,
                                                X_ATTRIBUTE18                => g_null,
                                                X_ATTRIBUTE19                => g_null,
                                                X_ATTRIBUTE20                => g_null,
						X_GL_DATE                    => l_d_gl_date,
                                                X_REVERSAL_GL_DATE           => NULL);

-- Log the Refund details in the concurrent manager log file
                  log_message(g_msg_lkp,
                              'REFUND_ID',
                              l_refund_id,
                              2);
                  log_message(g_msg_lkp,
                              'FEE_TYPE',
                              l_fee_type,
                              2);
                  log_message(g_msg_lkp,
                              'FEE_CAL_TYPE',
                              l_fee_cal_type,
                              2);
                  log_message(g_msg_lkp,
		              'FEE_PERIOD',
		              l_fee_prd.fee_prd,
                              2);
                  log_message(g_msg_lkp,
                              'AMOUNT',
                              l_rfnd_amnt,
                              2);
                  log_message(g_msg_lkp,
                              'PAYEE',
                              l_party_number,
                              2);
                  log_message(g_msg_lkp,
                              'VOUCHER_DATE',
                              to_char(sysdate),
                              2);

-- Fetch the Invoice Number for the Invoice created
                  OPEN cur_inv(l_invoice_id);
                  FETCH cur_inv INTO l_invoice_number;
                  CLOSE cur_inv;

                  log_message(g_msg_lkp,
                              'INVOICE_NUMBER',
                              l_invoice_number,
                              2);

-- Loop across all the identified credit records for the FTCI and the Sub Account
                  FOR l_cntr IN refund_calc.FIRST..refund_calc.LAST LOOP
                    IF ((refund_calc(l_cntr).fee_type      = l_fee_type) AND
                        (refund_calc(l_cntr).fee_cal_type  = l_fee_cal_type) AND
                        (refund_calc(l_cntr).fee_ci_sequence_number = l_fee_ci_sequence_number)) THEN

                        log_message(g_msg_lkp,
                                    'CREDIT_NUMBER',
                                    refund_calc(l_cntr).credit_number,
                                    3);
                        log_message(g_msg_lkp,
                                    'UNAPPLIED_AMOUNT',
                                    refund_calc(l_cntr).unapplied_amount,
                                    3);

-- Apply the Credit records to the Invoice created by calling the
-- Applications general procedure
                        l_application_id := NULL;
                        igs_fi_gen_007.create_application(p_credit_id             =>
                                                            refund_calc(l_cntr).credit_id,
                                                          p_invoice_id            => l_invoice_id,
                                                          p_amount_apply          =>
                                                            refund_calc(l_cntr).unapplied_amount,
                                                          p_appl_type             => g_app,
                                                          p_appl_hierarchy_id     => g_null,
                                                          p_application_id        => l_application_id,
                                                          p_validation            => g_ind_yes,
                                                          p_dr_gl_ccid            => l_dr_ccid,
                                                          p_cr_gl_ccid            => l_cr_ccid,
                                                          p_dr_account_cd         => l_dr_acc_cd,
                                                          p_cr_account_cd         => l_cr_acc_cd,
                                                          p_unapp_amount          => l_unapp_amount,
                                                          p_inv_amt_due           => l_inv_amt_due,
                                                          p_err_msg               => l_err_msg,
                                                          p_status                => l_status,
							  p_d_gl_date             => l_d_gl_date);

-- If the Applications procedure returns an error message, then this should be logged to the log file
-- of the concurrent manager
                      IF NOT l_status THEN
                        fnd_message.set_name('IGS',
                                             l_err_msg);
                        l_msg_text := fnd_message.get;
                        fnd_file.put_line(fnd_file.log,
                                          lpad(l_msg_text,length(l_msg_text)+6,' '));
                        app_exception.raise_exception;
                      END IF;
                      l_unapp_amount := NULL;
                      l_inv_amt_due  := NULL;
                      l_dr_acc_cd    := NULL;
                      l_cr_acc_cd    := NULL;
                      l_dr_ccid      := NULL;
                      l_cr_ccid      := NULL;

                    END IF;
                  END LOOP;
                  fnd_file.new_line(fnd_file.log);
                EXCEPTION
                  WHEN OTHERS THEN

-- If an error happens, then log the error message in the log file and rollback to
-- the save point of Refunds
                    fnd_file.put_line(fnd_file.log,
                                      sqlerrm);
                    ROLLBACK TO REFUNDS;
                    l_msg_count := FND_MSG_PUB.Count_Msg;
                    FOR l_msg_cntr IN 1..l_msg_count LOOP
                      fnd_file.put_line(fnd_file.log,
                                        fnd_msg_pub.get(p_msg_index => l_msg_cntr,
                                                        p_encoded => 'T'));
                    END LOOP;
                    l_exception_flag := TRUE;
                END;

-- If an exception happens, then log the message in the log file of the
-- Concurrent Manager
                IF l_exception_flag THEN
                  fnd_message.set_name('IGS',
                                       'IGS_FI_REFUND_ERR');
                  fnd_file.put_line(fnd_file.log,
                                    fnd_message.get||sqlerrm);
                END IF;
              END IF;
            END IF;
          END LOOP;
        END IF;

-- If no credits have been found for processing then
-- log the message in the log file of the concurrent manager
        IF (NOT l_party_process) THEN
          fnd_message.set_name('IGS','IGS_FI_RFND_PRC_NULL');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;

        IF (NOT l_rec_found) THEN
          fnd_message.set_name('IGS','IGS_FI_NO_RFND_EXCESS_AMT');
          fnd_file.put_line(fnd_file.log, fnd_message.get);
        END IF;
      ELSE

-- This means that the holds of STOPREFUNDS exist for the person and no automatic refund
-- processing needs to be done for the Person
        IF l_hld_exsts THEN
          fnd_message.set_name('IGS',
                               'IGS_FI_RFND_HLD_EXSTS');
          fnd_message.set_token('PARTY_NUM',
                                l_party_number);
          fnd_file.put_line(fnd_file.log,
                            fnd_message.get);
        END IF;
      END IF;
    END LOOP;
   END IF;
-- If the Process is run in Test Run Mode, then the process should rollback
    IF p_test_run = 'N' THEN
      COMMIT WORK;
    ELSE
      ROLLBACK TO RFND_PRC_BATCH;
    END IF;

  EXCEPTION
    WHEN e_resource_busy THEN
      fnd_message.set_name('IGS',
                           'IGS_FI_RFND_REC_LOCK');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      ROLLBACK TO RFND_PRC_BATCH;
      retcode := 2;
    WHEN OTHERS THEN
      retcode := 2;
      errbuf := 'IGS_GE_UNHANDLED_EXCEPTION';
      ROLLBACK TO RFND_PRC_BATCH;
      fnd_message.set_name('IGS',
                           'IGS_GE_UNHANDLED_EXCEPTION');
      fnd_file.put_line(fnd_file.log,
                        fnd_message.get);
      fnd_file.put_line(fnd_file.log,
                        sqlerrm);
      igs_ge_msg_stack.conc_exception_hndl;
  END process_batch;

END igs_fi_prc_refunds;

/
