--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_015
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_015" AS
/* $Header: IGSADC4B.pls 120.1 2005/09/30 04:52:44 appldev ship $ */
/******************************************************************
Created By: Navin Sinha
Date Created By: 07-Oct-2002
Purpose: BUG NO : 2602077 : HQ: release of build for td sf integrarion.
         New Package to Insert record in the table IGS_AD_APP_REQ
         (Application Fee )  whenever an Enrollment Deposit is
         Recorded in the Student Finance .
Known limitations,enhancements,remarks:
Change History
Who        When          What
Navin.sinha 10/1/2003	BUG NO : 3160036 : OSSTST15: enrollment deposit fee error in sf gl interface process
			Added New procedure to updare record in the table IGS_AD_APP_REQ.
pathipat  14-Jun-2003   Enh 2831587 - FI210 Credit Card Fund Transfer build
                        Modified create_enrollment_deposit() - igs_ad_app_req_pkg.insert_row() call
pathipat  06-Jan-2003  Bug: 2728620 and 2734574 - Removed exception section
                       in create_enrollment_deposit() and check_ad_code_classes_setup()
vvutukur  27-Nov-2002  Enh#2584986.Modified procedure create_enrollment_deposit.
******************************************************************/
--Fwd Declarations
PROCEDURE check_ad_code_classes_setup (
                  p_class_type   IN igs_ad_code_classes.class%TYPE                         --      APPLICATION_FEES
                , p_class        IN igs_ad_code_classes.class%TYPE                         --      FEE_PAYMENT_METHODS, FEE_STATUS, FEE_TYPES
                , p_std_sys_stat IN igs_ad_code_classes.system_status%TYPE                 --      SYS_FEE_STATUS, SYS_FEE_TYPE, SYS_FEE_PAY_METHOD
                , p_sys_stat     IN igs_ad_code_classes.system_status%TYPE                 --      PAID, ENROLL_DEPOSIT, CHECK
                , p_code_id     OUT NOCOPY igs_ad_code_classes.code_id%TYPE                       --      Return value: CODE_ID
                );

--Procedure Definitions
PROCEDURE create_enrollment_deposit(
  p_person_id                   IN      NUMBER,
  p_admission_appl_number       IN      NUMBER,
  p_enrollment_deposit_amount   IN      NUMBER,
  p_payment_date                IN      DATE,
  p_fee_payment_method          IN      VARCHAR2,
  p_reference_number            IN      VARCHAR2 ) IS

/******************************************************************
Created By: Navin Sinha
Date Created By: 07-Oct-2002
Purpose: BUG NO : 2602077 : HQ: release of build for td sf integrarion.
         New Procedure to Insert record in the table IGS_AD_APP_REQ
         (Application Fee )  whenever an Enrollment Deposit is
         Recorded in the Student Finance .
Known limitations,enhancements,remarks:
Change History
Who        When          What
pathipat  14-Jun-2003   Enh 2831587 - Credit Card Fund Transfer build
                        Modified call to igs_ad_app_req_pkg.insert_row - added 3 new parameters
pathipat  06-Jan-2003   Bug: 2728620 - Removed exception section
vvutukur  27-Nov-2002   Enh#2584986.Modified the tbh call to igs_ad_app_req.insert_row to include 11 new
                        columns. NULL is being passed to all the 11 columns.
******************************************************************/

        cst_paid                CONSTANT VARCHAR2(5)  := 'PAID';
        cst_partial             CONSTANT VARCHAR2(10) := 'PARTIAL';
        cst_application_fees    CONSTANT VARCHAR2(20) := 'APPL_FEES';
        cst_fee_status          CONSTANT VARCHAR2(20) := 'SYS_FEE_STATUS';
        cst_sys_fee_status      CONSTANT VARCHAR2(20) := 'SYS_FEE_STATUS';
        cst_fee_types           CONSTANT VARCHAR2(20) := 'SYS_FEE_TYPE';
        cst_sys_fee_type        CONSTANT VARCHAR2(20) := 'SYS_FEE_TYPE';
        cst_enroll_deposit      CONSTANT VARCHAR2(20) := 'ENROLL_DEPOSIT';
        cst_fee_payment_methods CONSTANT VARCHAR2(20) := 'SYS_FEE_PAY_METHOD';
        cst_sys_fee_pay_method  CONSTANT VARCHAR2(20) := 'SYS_FEE_PAY_METHOD';

        -- Cursor to Check if an enrollment deposit record(with system fee status as PARTIAL, PAID) already exists for this application.
        -- SUM (fee_amount) > 0 will indicate that above condition is TRUE.
        CURSOR c_paid_partial IS
        SELECT NVL(SUM (fee_amount),0) total_fee_amount
        FROM   igs_ad_app_req
        WHERE  person_id = p_person_id
        AND    admission_appl_number = p_admission_appl_number
        AND    applicant_fee_status IN (SELECT code_id FROM igs_ad_code_classes WHERE class = cst_fee_status AND system_status IN (cst_paid,cst_partial) AND closed_ind = 'N' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES')
        AND    applicant_fee_type IN (SELECT code_id FROM igs_ad_code_classes WHERE class = cst_fee_types AND system_status = cst_enroll_deposit  AND closed_ind = 'N' AND CLASS_TYPE_CODE='ADM_CODE_CLASSES');

        c_paid_partial_rec c_paid_partial%ROWTYPE;

        -- Cursor to get the enroll_deposit_amount for the application type
        CURSOR c_en_deposit_amt IS
        SELECT sat.enroll_deposit_amount enroll_deposit_amount
        FROM   igs_ad_ss_appl_typ sat,
               igs_ad_appl aa
        WHERE  aa.person_id = p_person_id
        AND    aa.admission_appl_number = p_admission_appl_number
        AND    sat.admission_application_type = aa.application_type;

        c_en_deposit_amt_rec c_en_deposit_amt%ROWTYPE;

        l_fee_payment_method            igs_lookups_view.lookup_code%TYPE;
        l_rowid                         VARCHAR2(25);
        l_app_req_id                    NUMBER;
        l_paid_record_created           BOOLEAN;
        l_request_id                    NUMBER;
        l_paid_fee_stat_code_id         igs_ad_code_classes.code_id%TYPE;
        l_partial_fee_stat_code_id      igs_ad_code_classes.code_id%TYPE;
        l_final_sys_dflt_fee_stat       igs_ad_code_classes.code_id%TYPE;
        l_fee_type_code_id              igs_ad_code_classes.code_id%TYPE;
        l_pay_mthd_code_id              igs_ad_code_classes.code_id%TYPE;

BEGIN
    -- Performing mandatory Admissions system setup check...
    -- Check if set-up information exists for system defaulted user defined Fee Status with System Status: Paid.
    check_ad_code_classes_setup (
                      cst_application_fees      --      APPLICATION_FEES
                    , cst_fee_status            --      FEE_STATUS
                    , cst_sys_fee_status        --      SYS_FEE_STATUS
                    , cst_paid                  --      PAID
                    , l_paid_fee_stat_code_id   --      Return value: CODE_ID
                    );

    -- Check if set-up information exists for system defaulted user defined Fee Status with System Status: Partial Paid.
    check_ad_code_classes_setup (
                      cst_application_fees         --      APPLICATION_FEES
                    , cst_fee_status               --      FEE_STATUS
                    , cst_sys_fee_status           --      SYS_FEE_STATUS
                    , cst_partial                  --      PARTIAL
                    , l_partial_fee_stat_code_id   --      Return value: CODE_ID
                    );

    -- Check if set-up information exists for system defaulted user defined Fee Type with System Status: Enrollment Deposit.
    check_ad_code_classes_setup (
                      cst_application_fees      --      APPLICATION_FEES
                    , cst_fee_types             --      FEE_TYPES
                    , cst_sys_fee_type          --      SYS_FEE_TYPE
                    , cst_enroll_deposit        --      ENROLL_DEPOSIT
                    , l_fee_type_code_id        --      Return value: CODE_ID
                    );

    -- Start Processing for creation of enrollment deposit record...
    -- Check if an enrollment deposit record(with system fee status as PARTIAL, PAID) already exists for this application.
    OPEN  c_paid_partial;
    FETCH c_paid_partial INTO c_paid_partial_rec;
    CLOSE c_paid_partial;

    -- Get the enroll_deposit_amount for the application type
    OPEN  c_en_deposit_amt;
    FETCH c_en_deposit_amt INTO c_en_deposit_amt_rec;
    IF (c_en_deposit_amt_rec.enroll_deposit_amount IS NOT NULL
        AND ((p_enrollment_deposit_amount + c_paid_partial_rec.total_fee_amount) < c_en_deposit_amt_rec.enroll_deposit_amount)) THEN
        -- Set status = system default for PARTIAL PAYMENT
        l_final_sys_dflt_fee_stat := l_partial_fee_stat_code_id;
        l_paid_record_created := FALSE;
    ELSE
        -- Set status = system default for PAID
        l_final_sys_dflt_fee_stat := l_paid_fee_stat_code_id;
        l_paid_record_created := TRUE;
    END IF;
    CLOSE c_en_deposit_amt;

    -- Get the system defaulted user defined fee payment method.
    IF    p_fee_payment_method = 'CC' THEN
      l_fee_payment_method := 'CREDIT_CARD';
    ELSIF p_fee_payment_method IN ('CASH', 'CHECK') THEN
      l_fee_payment_method := p_fee_payment_method;
    ELSE
      l_fee_payment_method := 'OTHER';
    END IF;

    -- Check if set-up information exists for system defaulted user defined Fee Payment Methods with System Status: l_fee_payment_method.
    check_ad_code_classes_setup (
                    cst_application_fees      --      APPLICATION_FEES
                  , cst_fee_payment_methods   --      FEE_PAYMENT_METHODS
                  , cst_sys_fee_pay_method    --      SYS_FEE_PAY_METHOD
                  , l_fee_payment_method      --      CHECK
                  , l_pay_mthd_code_id        --      Return value: CODE_ID
                  );

    igs_ad_gen_015.g_chk_ad_app_req := 'Y';   -- Based on the value of this variable , some of the validation wont be perform in igs_ad_app_req_pkg(bug#2901627 -- rghosh)

    -- Create an fee payment record in the AD table
    igs_ad_app_req_pkg.insert_row (
      X_Mode                              => 'R',
      X_RowId                             => l_rowid,
      X_App_Req_Id                        => l_app_req_id,
      X_Person_Id                         => p_person_id,
      X_Admission_Appl_Number             => p_admission_appl_number,
      X_Applicant_Fee_Type                => l_fee_type_code_id,
      X_Applicant_Fee_Status              => l_final_sys_dflt_fee_stat,
      X_Fee_Date                          => p_payment_date,
      X_Fee_Payment_Method                => l_pay_mthd_code_id,
      X_Fee_Amount                        => p_enrollment_deposit_amount,
      X_Reference_Num                     => p_reference_number,
      x_credit_card_code                  => NULL,
      x_credit_card_holder_name           => NULL,
      x_credit_card_number                => NULL,
      x_credit_card_expiration_date       => NULL,
      x_rev_gl_ccid                       => NULL,
      x_cash_gl_ccid                      => NULL,
      x_rev_account_cd                    => NULL,
      x_cash_account_cd                   => NULL,
      x_gl_date                           => NULL,
      x_gl_posted_date                    => NULL,
      x_posting_control_id                => NULL,
      x_credit_card_tangible_cd           => NULL,
      x_credit_card_payee_cd              => NULL,
      x_credit_card_status_code           => NULL
    );

      igs_ad_gen_015.g_chk_ad_app_req := 'N';

    -- Call the Admissions Tracking Item Completion job if a record with "Paid" Fee status is successfully created.
    IF l_paid_record_created AND l_rowid IS NOT NULL THEN
        -- Call Job Igs_ad_ti_comp.upd_trk_itm_st (Admissions Tracking Item Completion job)
        l_request_id := FND_REQUEST.SUBMIT_REQUEST(
          APPLICATION                => 'IGS',
          PROGRAM                    => 'IGSADJ14',
          DESCRIPTION                => 'Admission Tracking Item Completion',
          START_TIME                 => NULL,
          SUB_REQUEST                => FALSE,
          ARGUMENT1                  => p_person_id,
          ARGUMENT2                  => NULL,
          ARGUMENT3                  => p_admission_appl_number,
          ARGUMENT4                  => NULL,
          ARGUMENT5                  => NULL,
          ARGUMENT6                  => NULL,
          ARGUMENT7                  => NULL,
          ARGUMENT8                  => FND_PROFILE.VALUE('ORG_ID'),
          ARGUMENT9                  => CHR(0),
          ARGUMENT10                 => NULL,
          ARGUMENT11                 => NULL,
          ARGUMENT12                 => NULL,
          ARGUMENT13                 => NULL,
          ARGUMENT14                 => NULL,
          ARGUMENT15                 => NULL,
          ARGUMENT16                 => NULL,
          ARGUMENT17                 => NULL,
          ARGUMENT18                 => NULL,
          ARGUMENT19                 => NULL,
          ARGUMENT20                 => NULL,
          ARGUMENT21                 => NULL,
          ARGUMENT22                 => NULL,
          ARGUMENT23                 => NULL,
          ARGUMENT24                 => NULL,
          ARGUMENT25                 => NULL,
          ARGUMENT26                 => NULL,
          ARGUMENT27                 => NULL,
          ARGUMENT28                 => NULL,
          ARGUMENT29                 => NULL,
          ARGUMENT30                 => NULL,
          ARGUMENT31                 => NULL,
          ARGUMENT32                 => NULL,
          ARGUMENT33                 => NULL,
          ARGUMENT34                 => NULL,
          ARGUMENT35                 => NULL,
          ARGUMENT36                 => NULL,
          ARGUMENT37                 => NULL,
          ARGUMENT38                 => NULL,
          ARGUMENT39                 => NULL,
          ARGUMENT40                 => NULL,
          ARGUMENT41                 => NULL,
          ARGUMENT42                 => NULL,
          ARGUMENT43                 => NULL,
          ARGUMENT44                 => NULL,
          ARGUMENT45                 => NULL,
          ARGUMENT46                 => NULL,
          ARGUMENT47                 => NULL,
          ARGUMENT48                 => NULL,
          ARGUMENT49                 => NULL,
          ARGUMENT50                 => NULL,
          ARGUMENT51                 => NULL,
          ARGUMENT52                 => NULL,
          ARGUMENT53                 => NULL,
          ARGUMENT54                 => NULL,
          ARGUMENT55                 => NULL,
          ARGUMENT56                 => NULL,
          ARGUMENT57                 => NULL,
          ARGUMENT58                 => NULL,
          ARGUMENT59                 => NULL,
          ARGUMENT60                 => NULL,
          ARGUMENT61                 => NULL,
          ARGUMENT62                 => NULL,
          ARGUMENT63                 => NULL,
          ARGUMENT64                 => NULL,
          ARGUMENT65                 => NULL,
          ARGUMENT66                 => NULL,
          ARGUMENT67                 => NULL,
          ARGUMENT68                 => NULL,
          ARGUMENT69                 => NULL,
          ARGUMENT70                 => NULL,
          ARGUMENT71                 => NULL,
          ARGUMENT72                 => NULL,
          ARGUMENT73                 => NULL,
          ARGUMENT74                 => NULL,
          ARGUMENT75                 => NULL,
          ARGUMENT76                 => NULL,
          ARGUMENT77                 => NULL,
          ARGUMENT78                 => NULL,
          ARGUMENT79                 => NULL,
          ARGUMENT80                 => NULL,
          ARGUMENT81                 => NULL,
          ARGUMENT82                 => NULL,
          ARGUMENT83                 => NULL,
          ARGUMENT84                 => NULL,
          ARGUMENT85                 => NULL,
          ARGUMENT86                 => NULL,
          ARGUMENT87                 => NULL,
          ARGUMENT88                 => NULL,
          ARGUMENT89                 => NULL,
          ARGUMENT90                 => NULL,
          ARGUMENT91                 => NULL,
          ARGUMENT92                 => NULL,
          ARGUMENT93                 => NULL,
          ARGUMENT94                 => NULL,
          ARGUMENT95                 => NULL,
          ARGUMENT96                 => NULL,
          ARGUMENT97                 => NULL,
          ARGUMENT98                 => NULL,
          ARGUMENT99                 => NULL,
          ARGUMENT100                => NULL
        );

        IF l_request_id = 0 THEN
          fnd_message.set_name('FND','CONC-REQUEST SUBMISSION FAILED');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        ELSE
          fnd_message.set_name('FND','CONC-SUBMITTED REQUEST');
          fnd_message.set_token('REQUEST_ID',IGS_GE_NUMBER.TO_CANN(l_request_id), FALSE);
          igs_ge_msg_stack.add;
        END IF;
    END IF;

END create_enrollment_deposit;

PROCEDURE check_ad_code_classes_setup (
                  p_class_type   IN igs_ad_code_classes.class%TYPE                         --      APPLICATION_FEES
                , p_class        IN igs_ad_code_classes.class%TYPE                         --      FEE_PAYMENT_METHODS, FEE_STATUS, FEE_TYPES
                , p_std_sys_stat IN igs_ad_code_classes.system_status%TYPE                 --      SYS_FEE_STATUS, SYS_FEE_TYPE, SYS_FEE_PAY_METHOD
                , p_sys_stat     IN igs_ad_code_classes.system_status%TYPE                 --      PAID, ENROLL_DEPOSIT, CHECK
                , p_code_id     OUT NOCOPY igs_ad_code_classes.code_id%TYPE                       --      Return value: CODE_ID
                ) IS

/******************************************************************
Created By: Navin Sinha
Date Created By: 08-Oct-2002
Purpose: BUG NO : 2602077 : HQ: release of build for td sf integrarion.
         Procedure for Performing mandatory Admissions system setup check.
Known limitations,enhancements,remarks:
Change History
Who        When          What
pathipat  06-Jan-2003  Bug: 2734574 - Removed exception section
******************************************************************/

    -- Cursor to check set for igs_ad_code_classes are done on client site.
    CURSOR c_ad_cd_class IS
    SELECT code_id
    FROM   igs_ad_code_classes
    WHERE  class = p_class
    AND    system_status = p_sys_stat
    AND    NVL(system_default, 'N') = 'Y'
    AND    closed_ind = 'N'
    AND    CLASS_TYPE_CODE='ADM_CODE_CLASSES';

    -- Cursor to get the meaning for lookup code
    CURSOR c_lkup_cd_mean(cp_lookup_type igs_lookups_view.lookup_type%TYPE, cp_lookup_code igs_lookups_view.lookup_code%TYPE) IS
    SELECT meaning
    FROM   igs_lookups_view
    WHERE  lookup_type = cp_lookup_type
    AND    lookup_code = cp_lookup_code;

    l_class_meaning    igs_lookups_view.meaning%TYPE;
    l_sys_stat_meaning igs_lookups_view.meaning%TYPE;
BEGIN
    OPEN c_ad_cd_class;
    FETCH c_ad_cd_class INTO p_code_id;
    IF c_ad_cd_class%NOTFOUND THEN
      CLOSE c_ad_cd_class;

      -- Get the value for message token CLASS_MEANING
      OPEN  c_lkup_cd_mean(p_class_type, p_class);
      FETCH c_lkup_cd_mean INTO l_class_meaning;
      CLOSE c_lkup_cd_mean;

      -- Get the value for message token SYS_STAT_MEANING
      OPEN  c_lkup_cd_mean(p_std_sys_stat, p_sys_stat);
      FETCH c_lkup_cd_mean INTO l_sys_stat_meaning;
      CLOSE c_lkup_cd_mean;

      fnd_message.set_name('IGS','IGS_AD_INCOMP_SETUP_CD_CLASS');
      fnd_message.set_token('CLASS_MEANING', l_class_meaning);
      fnd_message.set_token('SYS_STAT_MEANING', l_sys_stat_meaning);
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;
    CLOSE c_ad_cd_class;

END check_ad_code_classes_setup;

 PROCEDURE update_igs_ad_app_req (
       p_rowid                          IN VARCHAR2,
       p_app_req_id                     IN NUMBER,
       p_person_id                      IN NUMBER,
       p_admission_appl_number          IN NUMBER,
       p_applicant_fee_type             IN NUMBER,
       p_applicant_fee_status           IN NUMBER,
       p_fee_date                       IN DATE,
       p_fee_payment_method             IN NUMBER,
       p_fee_amount                     IN NUMBER,
       p_reference_num                  IN VARCHAR2,
       p_credit_card_code               IN VARCHAR2,
       p_credit_card_holder_name        IN VARCHAR2,
       p_credit_card_number             IN VARCHAR2,
       p_credit_card_expiration_date    IN DATE,
       p_rev_gl_ccid                    IN NUMBER,
       p_cash_gl_ccid                   IN NUMBER,
       p_rev_account_cd                 IN VARCHAR2,
       p_cash_account_cd                IN VARCHAR2,
       p_posting_control_id             IN NUMBER,
       p_gl_date                        IN DATE,
       p_gl_posted_date                 IN DATE,
       p_credit_card_tangible_cd        IN VARCHAR2,
       p_credit_card_payee_cd           IN VARCHAR2,
       p_credit_card_status_code        IN VARCHAR2,
       p_mode                           IN VARCHAR2
  ) AS
  /*************************************************************
  Created By: Navin Sinha
  Date Created By: 01-Oct-2003
  Purpose: BUG NO : 3160036 : OSSTST15: enrollment deposit fee error in sf gl interface process
         New procedure to updare record in the table IGS_AD_APP_REQ.
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN
    igs_ad_gen_015.g_chk_ad_app_req := 'Y';   -- Based on the value of this variable , some of the validation wont be perform in igs_ad_app_req_pkg(bug#2901627 -- rghosh)

    -- Update the fee payment record in the AD table
    igs_ad_app_req_pkg.update_row (
                     x_rowid                         => p_rowid,
                     x_app_req_id                    => p_app_req_id,
                     x_person_id                     => p_person_id,
                     x_admission_appl_number         => p_admission_appl_number,
                     x_applicant_fee_type            => p_applicant_fee_type,
                     x_applicant_fee_status          => p_applicant_fee_status,
                     x_fee_date                      => p_fee_date,
                     x_fee_payment_method            => p_fee_payment_method,
                     x_fee_amount                    => p_fee_amount,
                     x_reference_num                 => p_reference_num,
                     x_credit_card_code              => p_credit_card_code,
                     x_credit_card_holder_name       => p_credit_card_holder_name,
                     x_credit_card_number            => p_credit_card_number,
                     x_credit_card_expiration_date   => p_credit_card_expiration_date,
                     x_rev_gl_ccid                   => p_rev_gl_ccid,
                     x_cash_gl_ccid                  => p_cash_gl_ccid,
                     x_rev_account_cd                => p_rev_account_cd,
                     x_cash_account_cd               => p_cash_account_cd,
                     x_posting_control_id            => p_posting_control_id,
                     x_gl_date                       => p_gl_date,
                     x_gl_posted_date                => p_gl_posted_date,
                     x_credit_card_tangible_cd       => p_credit_card_tangible_cd,
                     x_credit_card_payee_cd          => p_credit_card_payee_cd,
                     x_credit_card_status_code       => p_credit_card_status_code,
                     x_mode                          => p_mode
                     );

   igs_ad_gen_015.g_chk_ad_app_req := 'N';
END update_igs_ad_app_req;

END igs_ad_gen_015;

/
