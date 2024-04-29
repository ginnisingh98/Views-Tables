--------------------------------------------------------
--  DDL for Package Body IGS_AD_APP_REQ_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APP_REQ_PKG" AS
/* $Header: IGSAIA2B.pls 120.7 2005/10/07 09:37:07 appldev ship $ */


  l_rowid VARCHAR2(25);
  old_references igs_ad_app_req%ROWTYPE;
  new_references igs_ad_app_req%ROWTYPE;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_app_req_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_applicant_fee_type IN NUMBER,
    x_applicant_fee_status IN NUMBER,
    x_fee_date IN DATE,
    x_fee_payment_method IN NUMBER,
    x_fee_amount IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER ,
    x_reference_num IN VARCHAR2  ,
    x_credit_card_code		     IN  VARCHAR2 ,
    x_credit_card_holder_name        IN  VARCHAR2 ,
    x_credit_card_number             IN  VARCHAR2 ,
    x_credit_card_expiration_date    IN  DATE     ,
    x_rev_gl_ccid                    IN  NUMBER   ,
    x_cash_gl_ccid                   IN  NUMBER   ,
    x_rev_account_cd                 IN  VARCHAR2 ,
    x_cash_account_cd                IN  VARCHAR2 ,
    x_gl_date                        IN  DATE     ,
    x_gl_posted_date                 IN  DATE     ,
    x_posting_control_id             IN  NUMBER   ,
    x_credit_card_tangible_cd        IN  VARCHAR2 ,
    x_credit_card_payee_cd           IN  VARCHAR2 ,
    x_credit_card_status_code        IN  VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
  smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APP_REQ
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.app_req_id := x_app_req_id;
    new_references.person_id := x_person_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.applicant_fee_type    := x_applicant_fee_type;
    new_references.applicant_fee_status  := x_applicant_fee_status;
    new_references.fee_date              := TRUNC(x_fee_date);
    new_references.fee_payment_method    := x_fee_payment_method;
    new_references.fee_amount            := x_fee_amount;
    new_references.reference_num         := x_reference_num;
    new_references.credit_card_code            := x_credit_card_code;
    new_references.credit_card_holder_name     := x_credit_card_holder_name;
    new_references.credit_card_number          := x_credit_card_number;
    new_references.credit_card_expiration_date := TRUNC(x_credit_card_expiration_date);
    new_references.rev_gl_ccid                 := x_rev_gl_ccid;
    new_references.cash_gl_ccid                := x_cash_gl_ccid;
    new_references.rev_account_cd              := x_rev_account_cd;
    new_references.cash_account_cd             := x_cash_account_cd;
    new_references.gl_date                     := TRUNC(x_gl_date);
    new_references.gl_posted_date              := TRUNC(x_gl_posted_date);
    new_references.posting_control_id          := x_posting_control_id;
    new_references.credit_card_tangible_cd     := x_credit_card_tangible_cd;
    new_references.credit_card_payee_cd        := x_credit_card_payee_cd;
    new_references.credit_card_status_code     := x_credit_card_status_code;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;

PROCEDURE beforerowinsertupdate1 (
                           p_inserting BOOLEAN,
                           p_updating BOOLEAN,
                           p_deleting BOOLEAN ) IS

 /*************************************************************
  Created By : Rishi Ghosh
  Date Created By : 17- apr-2003
  Purpose : This procedure will perform all the validations that were earler performed
                     in the library before inserting and updating (bug#2901627)
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  NSINHA          05-June-03      Enh# 2860854  Enh for 'sf commercial payables integration'
  NSINHA          01-July-03      Bug# 3017630 Ossuk15: sf commercial int: updating the existing enrollment deposit
  NSINHA          25-July-03      Bug# 3017800 OSSUK15: ss: ua: update application information page - fee information - app fee
  (reverse chronological order - newest change first)
  ***************************************************************/

-- Cursor to get the application processing status for an application
CURSOR c_appl_status (cp_person_id igs_ad_app_req.person_id%TYPE,
                                               cp_admission_appl_number igs_ad_app_req.admission_appl_number%TYPE) IS
      SELECT s_adm_appl_status
      FROM   igs_ad_appl_stat
      WHERE  adm_appl_status = ( SELECT adm_appl_status
                                 FROM   igs_ad_appl
                                 WHERE  person_id = cp_person_id
                                 AND    admission_appl_number = cp_admission_appl_number );

l_appl_status igs_ad_appl.adm_appl_status%TYPE;

-- Cursor to get the fee type
 CURSOR cur_enr_dpt(cp_applicant_fee_type igs_ad_app_req.applicant_fee_type%TYPE) IS
   SELECT system_status
   FROM   igs_ad_code_classes
   WHERE  code_id = cp_applicant_fee_type;

 -- Cursor to get the fee status
 CURSOR cur_ent_dpt_upd(cp_applicant_fee_status igs_ad_app_req.applicant_fee_status%TYPE) IS
   SELECT system_status
   FROM   igs_ad_code_classes
   WHERE  code_id =  cp_applicant_fee_status;

 l_fee_status         igs_ad_code_classes.system_status%TYPE;
 l_fee_type           igs_ad_code_classes.system_status%TYPE;

 -- Cursor to get the application date of the application
 CURSOR c_appl_dt(cp_person_id igs_ad_app_req.person_id%TYPE,
                                      cp_admission_appl_number  igs_ad_app_req.admission_appl_number%TYPE) IS
 SELECT appl_dt
 FROM igs_ad_appl
 where person_id = cp_person_id
 and admission_appl_number = cp_admission_appl_number;

  l_appl_dt          igs_ad_appl.appl_dt%TYPE;
  l_manage_acc       igs_fi_control_all.manage_accounts%TYPE;
  l_message_name     fnd_new_messages.message_name%TYPE;

BEGIN

IF NVL(igs_ad_gen_015.g_chk_ad_app_req,'N') = 'N' THEN  -- If this package is called from the  igs_ad_gen_015.create_enrollment_deposit then
                                                        -- no validations will be performed.-- rghosh (bug#2901627)

  OPEN cur_ent_dpt_upd(new_references.applicant_fee_status);
  FETCH cur_ent_dpt_upd INTO l_fee_status;
  CLOSE cur_ent_dpt_upd;

  OPEN cur_enr_dpt(new_references.applicant_fee_type);
  FETCH cur_enr_dpt INTO l_fee_type ;
  CLOSE cur_enr_dpt;

  IF NVL(p_updating,FALSE)  OR NVL(p_inserting,FALSE) THEN
    OPEN c_appl_status(new_references.person_id,new_references.admission_appl_number);
    FETCH c_appl_status INTO l_appl_status;
    CLOSE c_appl_status;
    -- for an withdrawn application , or for an complete application for which the offer response status is not 'Accepted' or
    -- the offer response status is  'Defferal' with deferment status as 'Confirmed' , the fee related information cannot be inserted.
/* removed the following validation for bug 3374937
    IF l_appl_status = 'WITHDRAWN' OR
      ( l_appl_status = 'COMPLETED' AND NOT  igs_ad_gen_002.valid_ofr_resp_status(new_references.person_id,new_references.admission_appl_number)) THEN
      fnd_message.set_name('IGS','IGS_AD_CANNOT_CHG_APPL_DTL');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    -- ADDED following check for Bug# 3017800
    ELS*/
    IF  ( l_appl_status = 'COMPLETED' AND igs_ad_gen_002.valid_ofr_resp_status(new_references.person_id,new_references.admission_appl_number) AND l_fee_type <> 'ENROLL_DEPOSIT' ) THEN
      fnd_message.set_name('IGS','IGS_AD_ENRDPT_UPD_CMP_APPL'); -- IGS_AD_ENRDPT_UPD_CMP_APPL: For a completed application only Enrollment Deposit fee records can be manupulated.
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    -- for an complete application for which the offer response status is 'Accepted' or the offer response status is
    -- 'Defferal' with deferment status as 'Confirmed' , only fee type of enroll_deposit can be entered. Also manual
    -- creation of paid or partial fee payment is not allowed.

    -- NSINHA 05-June-03 correctled the 'ENROLL_DEPOSIT' with 'PAID' and 'PARTIAL' fee status.
    IF igs_ad_gen_002.valid_ofr_resp_status(new_references.person_id,new_references.admission_appl_number) THEN
      -- NSINHA 05-June-03 Enh# 2860854  Enh for 'sf commercial payables integration'
      igs_fi_com_rec_interface.chk_manage_account( l_manage_acc, l_message_name);
      -- If manage_Accounts is STUDENT_FINANCE
      IF (l_manage_acc = 'STUDENT_FINANCE') THEN
       -- DO NOT Allow Manual creation of Enrollment Deposit record with Application Fee Status mapped to system status of Partial or Paid.
       IF NVL(p_inserting,FALSE) AND l_fee_type = 'ENROLL_DEPOSIT' AND l_fee_status IN ('PAID','PARTIAL') THEN
         -- Manual creation of Enrollment Deposit record with Application Fee Status mapped to system status of Partial or Paid is not allowed.
         fnd_message.set_name('IGS','IGS_AD_ENR_DPT_STATUS');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       END IF;

       IF NVL(p_updating,FALSE) AND l_fee_type = 'ENROLL_DEPOSIT'  AND l_fee_status IN ('PAID','PARTIAL') THEN
         -- Update of an Enrollment Deposit record with Application Fee Status mapped to system status of Partial or Paid is not allowed.
         fnd_message.set_name('IGS','IGS_AD_ENRDPT_UPD_NT_ALWD');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
       END IF;
      --  If manage_accounts is NULL or OTHER
      ELSIF (l_manage_acc IS NULL OR l_manage_acc = 'OTHER') THEN
        -- Allow Manual creation of Enrollment Deposit record with Application Fee Status mapped to system status of Partial or Paid.
	NULL;
     END IF;
    ELSE
      IF l_fee_type = 'ENROLL_DEPOSIT' THEN
        fnd_message.set_name('IGS','IGS_AD_ENR_DPT_CNT_PAY');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    OPEN c_appl_dt (new_references.person_id,new_references.admission_appl_number);
    FETCH c_appl_dt INTO l_appl_dt;
    CLOSE c_appl_dt;

    -- the fee date cannot be earlier than the application date
/*  relaxed this validation as per bug 4027871
    IF	new_references.fee_date	 < l_appl_dt THEN
	    fnd_message.set_name('IGS','IGS_AD_APPL_DATE_ERROR');
	    fnd_message.set_token ('NAME',fnd_message.get_string('IGS','IGS_AD_FEE_DATE'));
	    igs_ge_msg_stack.add;
	    app_exception.raise_exception;
    END	IF;
  */
    -- the fee date cannot be later than the system date
    IF	new_references.fee_date	> SYSDATE THEN
	    fnd_message.set_name('IGS','IGS_AD_DATE_SYSDATE');
	    fnd_message.set_token ('NAME',fnd_message.get_string('IGS','IGS_AD_FEE_DATE'));
	    igs_ge_msg_stack.add;
	    app_exception.raise_exception;
    END	IF;
  END IF; -- p_updating, p_inserting
END IF; -- igs_ad_gen_015.g_chk_ad_app_req
END beforerowinsertupdate1;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2 ,
		 Column_Value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'FEE_AMOUNT'  THEN
        new_references.fee_amount := IGS_GE_NUMBER.TO_NUM(column_value);
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'FEE_AMOUNT' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.fee_amount >= 0
              OR new_references.fee_amount IS NULL)  THEN
           Fnd_Message.Set_Name('IGS','IGS_AD_FEE_AMT_NON_NEGATIVE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;




  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smadathi        06-nov-2002     Enh. Bug 2584986. Added
                                  igs_fi_acc_pkg.get_pk_for_validation
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.fee_payment_method = new_references.fee_payment_method)) OR
        ((new_references.fee_payment_method IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.fee_payment_method ,
            'SYS_FEE_PAY_METHOD',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_FEE_PAY_METHOD'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.admission_appl_number = new_references.admission_appl_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.admission_appl_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Appl_Pkg.Get_PK_For_Validation (
        		new_references.person_id,
         		 new_references.admission_appl_number
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPL'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.applicant_fee_status = new_references.applicant_fee_status)) OR
        ((new_references.applicant_fee_status IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.applicant_fee_status ,
            'SYS_FEE_STATUS',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPLICANT_FEE_STAT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.applicant_fee_type = new_references.applicant_fee_type)) OR
        ((new_references.applicant_fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Code_Classes_Pkg.Get_UK2_For_Validation (
        		new_references.applicant_fee_type ,
            'SYS_FEE_TYPE',
            'N'
        )  THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_APPLICANT_FEE_TYPE'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_fi_acc_pkg.get_pk_for_validation (
               new_references.rev_account_cd
               ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_REV_ACCT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((old_references.cash_account_cd = new_references.cash_account_cd) OR
         (new_references.cash_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT igs_fi_acc_pkg.get_pk_for_validation (
               new_references.cash_account_cd
               ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CASH_ACCT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_app_req_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_app_req
      WHERE    app_req_id = x_app_req_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;


  PROCEDURE Get_FK_Igs_Ad_Appl (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_app_req
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAR_AA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Appl;

  PROCEDURE Get_FK_Igs_Ad_Code_Classes (
    x_code_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_app_req
      WHERE    applicant_fee_status = x_code_id ;

    lv_rowid cur_rowid%RowType;

    CURSOR cur_rowid2 IS
      SELECT   rowid
      FROM     igs_ad_app_req
      WHERE    applicant_fee_type = x_code_id ;

    lv_rowid2 cur_rowid2%RowType;

     CURSOR cur_rowid3 IS
      SELECT   rowid
      FROM     igs_ad_app_req
      WHERE    fee_payment_method = x_code_id ;

    lv_rowid3 cur_rowid3%RowType;


  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAR_ACDC_FK3');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  Open cur_rowid2;
    Fetch cur_rowid2 INTO lv_rowid2;
    IF (cur_rowid2%FOUND) THEN
      Close cur_rowid2;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAR_ACADC_FK1');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid2;

   Open cur_rowid3;
    Fetch cur_rowid3 INTO lv_rowid3;
    IF (cur_rowid3%FOUND) THEN
      Close cur_rowid3;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_AAR_ACDC_FK2');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid3;

  END Get_FK_Igs_Ad_Code_Classes;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_app_req_id IN NUMBER,
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_applicant_fee_type IN NUMBER,
    x_applicant_fee_status IN NUMBER,
    x_fee_date IN DATE,
    x_fee_payment_method IN NUMBER,
    x_fee_amount IN NUMBER,
    x_reference_num IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_credit_card_code		     IN  VARCHAR2 ,
    x_credit_card_holder_name        IN  VARCHAR2 ,
    x_credit_card_number             IN  VARCHAR2 ,
    x_credit_card_expiration_date    IN  DATE     ,
    x_rev_gl_ccid                    IN  NUMBER   ,
    x_cash_gl_ccid                   IN  NUMBER   ,
    x_rev_account_cd                 IN  VARCHAR2 ,
    x_cash_account_cd                IN  VARCHAR2 ,
    x_gl_date                        IN  DATE     ,
    x_gl_posted_date                 IN  DATE     ,
    x_posting_control_id             IN  NUMBER   ,
    x_credit_card_tangible_cd        IN  VARCHAR2 ,
    x_credit_card_payee_cd           IN  VARCHAR2 ,
    x_credit_card_status_code        IN  VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
   smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_app_req_id,
      x_person_id,
      x_admission_appl_number,
      x_applicant_fee_type,
      x_applicant_fee_status,
      x_fee_date,
      x_fee_payment_method,
      x_fee_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_reference_num,
      x_credit_card_code            ,
      x_credit_card_holder_name     ,
      x_credit_card_number          ,
      x_credit_card_expiration_date ,
      x_rev_gl_ccid                 ,
      x_cash_gl_ccid                ,
      x_rev_account_cd              ,
      x_cash_account_cd             ,
      x_gl_date                     ,
      x_gl_posted_date              ,
      x_posting_control_id          ,
      x_credit_card_tangible_cd     ,
      x_credit_card_payee_cd        ,
      x_credit_card_status_code
      );

igs_ad_app_req_pkg.g_pkg_cst_completed_chk := 'N';		-- this variable is called from the procedure igs_ad_gen_002.check_adm_appl_inst_stat (rghosh)

    igs_ad_gen_002.check_adm_appl_inst_stat(
      x_person_id,
      x_admission_appl_number
    );
igs_ad_app_req_pkg.g_pkg_cst_completed_chk := 'Y';

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.app_req_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      beforerowinsertupdate1( p_inserting => TRUE , p_updating => FALSE, p_deleting=> FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforerowinsertupdate1( p_inserting => FALSE , p_updating =>TRUE , p_deleting=> FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      NULL;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.app_req_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      beforerowinsertupdate1( p_inserting => TRUE , p_updating => FALSE, p_deleting=> FALSE);
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      beforerowinsertupdate1( p_inserting =>FALSE , p_updating => TRUE, p_deleting=> FALSE);
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      --Raise the Fee create Business Event
     igs_ad_wf_001.FEE_PAYMENT_CRT_EVENT
     (
      P_PERSON_ID               => NEW_REFERENCES.PERSON_ID,
      P_ADMISSION_APPL_NUMBER   => NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      P_APP_REQ_ID              => NEW_REFERENCES.APP_REQ_ID,
      P_APPLICANT_FEE_TYPE      => NEW_REFERENCES.APPLICANT_FEE_TYPE,
      P_APPLICANT_FEE_STATUS    => NEW_REFERENCES.APPLICANT_FEE_STATUS
     );

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      --Raise the Fee update Business Event
      IF(NEW_REFERENCES.APPLICANT_FEE_STATUS <> OLD_REFERENCES.APPLICANT_FEE_STATUS) THEN
         igs_ad_wf_001.FEE_PAYMENT_UPD_EVENT(
		P_PERSON_ID 			=> NEW_REFERENCES.PERSON_ID,
		P_ADMISSION_APPL_NUMBER		=> NEW_REFERENCES.ADMISSION_APPL_NUMBER,
		P_APP_REQ_ID			=> NEW_REFERENCES.APP_REQ_ID,
		P_APPLICANT_FEE_TYPE		=> NEW_REFERENCES.APPLICANT_FEE_TYPE,
		P_APPLICANT_FEE_STATUS_NEW	=> NEW_REFERENCES.APPLICANT_FEE_STATUS,
		P_APPLICANT_FEE_STATUS_OLD	=> OLD_REFERENCES.APPLICANT_FEE_STATUS);
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APP_REQ_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2,
       X_MODE IN VARCHAR2 ,
       x_credit_card_code		IN  VARCHAR2 ,
       x_credit_card_holder_name        IN  VARCHAR2 ,
       x_credit_card_number             IN  VARCHAR2 ,
       x_credit_card_expiration_date    IN  DATE     ,
       x_rev_gl_ccid                    IN  NUMBER   ,
       x_cash_gl_ccid                   IN  NUMBER   ,
       x_rev_account_cd                 IN  VARCHAR2 ,
       x_cash_account_cd                IN  VARCHAR2 ,
       x_gl_date                        IN  DATE     ,
       x_gl_posted_date                 IN  DATE     ,
       x_posting_control_id             IN  NUMBER   ,
       x_credit_card_tangible_cd        IN  VARCHAR2 ,
       x_credit_card_payee_cd           IN  VARCHAR2 ,
       x_credit_card_status_code        IN  VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  gurprsin       27-Sep-2005      Enh 4607540, Credit Card Enryption enhancement, Passed the encrypted value of credit_card_number to before_dml call.
  ravishar       30-May-05        Security related changes
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
   smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR C IS SELECT rowid FROM igs_ad_app_req
             WHERE                 APP_REQ_ID= X_APP_REQ_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
   --  l_v_cc_number           igs_fi_credits_all.credit_card_number%TYPE;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
      elsif (X_MODE IN ('R', 'S')) then
        X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
        if X_LAST_UPDATED_BY is NULL then
           X_LAST_UPDATED_BY := -1;
        end if;
        X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
        if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
        end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;

   X_APP_REQ_ID := -1;

    --Enh 4607540 , Calling iPayment API to get the encrypted value of Credit card number.
    --Bug 4660773 This Code logic is commented as the part of the Bug 4660773 Dont remove the commented Code
   /* IF x_credit_card_number IS NOT NULL THEN
      l_v_cc_number :=   IBY_CC_SECURITY_PUB.SECURE_CARD_NUMBER(p_commit => FND_API.G_FALSE , p_card_number => x_credit_card_number);
    ELSE
      l_v_cc_number := x_credit_card_number;
    END IF;*/
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_app_req_id=>X_APP_REQ_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_applicant_fee_type=>X_APPLICANT_FEE_TYPE,
 	       x_applicant_fee_status=>X_APPLICANT_FEE_STATUS,
 	       x_fee_date=>X_FEE_DATE,
 	       x_fee_payment_method=>X_FEE_PAYMENT_METHOD,
 	       x_fee_amount=>X_FEE_AMOUNT,
               x_reference_num=>X_REFERENCE_NUM,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_credit_card_code            => x_credit_card_code,
               x_credit_card_holder_name     => x_credit_card_holder_name,
               x_credit_card_number          => x_credit_card_number,
               x_credit_card_expiration_date => x_credit_card_expiration_date,
               x_rev_gl_ccid                 => x_rev_gl_ccid,
               x_cash_gl_ccid                => x_cash_gl_ccid,
               x_rev_account_cd              => x_rev_account_cd,
               x_cash_account_cd             => x_cash_account_cd,
               x_gl_date                     => x_gl_date,
               x_gl_posted_date              => x_gl_posted_date,
               x_posting_control_id          => x_posting_control_id,
               x_credit_card_tangible_cd     => x_credit_card_tangible_cd,
               x_credit_card_payee_cd        => x_credit_card_payee_cd,
               x_credit_card_status_code     => x_credit_card_status_code
	       );
 IF (x_mode = 'S') THEN
     igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO IGS_AD_APP_REQ (
		APP_REQ_ID
		,PERSON_ID
		,ADMISSION_APPL_NUMBER
		,APPLICANT_FEE_TYPE
		,APPLICANT_FEE_STATUS
		,FEE_DATE
		,FEE_PAYMENT_METHOD
		,FEE_AMOUNT
                ,REFERENCE_NUM
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN,
                credit_card_code            ,
                credit_card_holder_name     ,
                credit_card_number          ,
                credit_card_expiration_date ,
                rev_gl_ccid                 ,
                cash_gl_ccid                ,
                rev_account_cd              ,
                cash_account_cd             ,
                gl_date                     ,
                gl_posted_date              ,
                posting_control_id          ,
                credit_card_tangible_cd     ,
                credit_card_payee_cd        ,
                credit_card_status_code
        ) VALUES  (
	         IGS_AD_APP_REQ_S.NEXTVAL
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.ADMISSION_APPL_NUMBER
	        ,NEW_REFERENCES.APPLICANT_FEE_TYPE
	        ,NEW_REFERENCES.APPLICANT_FEE_STATUS
	        ,NEW_REFERENCES.FEE_DATE
	        ,NEW_REFERENCES.FEE_PAYMENT_METHOD
	        ,NEW_REFERENCES.FEE_AMOUNT
                ,NEW_REFERENCES.REFERENCE_NUM
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN,
                new_references.credit_card_code            ,
                new_references.credit_card_holder_name     ,
                new_references.credit_card_number          ,
                new_references.credit_card_expiration_date ,
                new_references.rev_gl_ccid                 ,
                new_references.cash_gl_ccid                ,
                new_references.rev_account_cd              ,
                new_references.cash_account_cd             ,
                new_references.gl_date                     ,
                new_references.gl_posted_date              ,
                new_references.posting_control_id          ,
                new_references.credit_card_tangible_cd     ,
                new_references.credit_card_payee_cd        ,
                new_references.credit_card_status_code

           ) RETURNING APP_REQ_ID INTO X_APP_REQ_ID;
           new_references.APP_REQ_ID := X_APP_REQ_ID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
     igs_sc_gen_001.unset_ctx('R');
  END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END insert_row;

 PROCEDURE lock_row (
      X_ROWID in  VARCHAR2,
       x_APP_REQ_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2,
       x_credit_card_code		IN  VARCHAR2 ,
       x_credit_card_holder_name        IN  VARCHAR2 ,
       x_credit_card_number             IN  VARCHAR2 ,
       x_credit_card_expiration_date    IN  DATE     ,
       x_rev_gl_ccid                    IN  NUMBER   ,
       x_cash_gl_ccid                   IN  NUMBER   ,
       x_rev_account_cd                 IN  VARCHAR2 ,
       x_cash_account_cd                IN  VARCHAR2 ,
       x_gl_date                        IN  DATE     ,
       x_gl_posted_date                 IN  DATE     ,
       x_posting_control_id             IN  NUMBER   ,
       x_credit_card_tangible_cd        IN  VARCHAR2 ,
       x_credit_card_payee_cd           IN  VARCHAR2 ,
       x_credit_card_status_code        IN  VARCHAR2
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
  smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      person_id
,      admission_appl_number
,      applicant_fee_type
,      applicant_fee_status
,      fee_date
,      fee_payment_method
,      fee_amount
,      reference_num,
       credit_card_code            ,
       credit_card_holder_name     ,
       credit_card_number          ,
       credit_card_expiration_date ,
       rev_gl_ccid                 ,
       cash_gl_ccid                ,
       rev_account_cd              ,
       cash_account_cd             ,
       gl_date                     ,
       gl_posted_date              ,
       posting_control_id          ,
       credit_card_tangible_cd     ,
       credit_card_payee_cd        ,
       credit_card_status_code

    FROM IGS_AD_APP_REQ
    WHERE rowid = x_rowid
    FOR UPDATE NOWAIT;
     tlinfo c1%ROWTYPE;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
IF ( (  tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER)
  AND (tlinfo.APPLICANT_FEE_TYPE = X_APPLICANT_FEE_TYPE)
  AND (tlinfo.APPLICANT_FEE_STATUS = X_APPLICANT_FEE_STATUS)
  AND (TRUNC(tlinfo.FEE_DATE) = TRUNC(X_FEE_DATE))
  AND ((tlinfo.fee_payment_method = X_FEE_PAYMENT_METHOD) OR ((tlinfo.fee_payment_method IS NULL) AND (X_FEE_PAYMENT_METHOD IS NULL)))
  AND (tlinfo.FEE_AMOUNT = X_FEE_AMOUNT)
  AND ((tlinfo.REFERENCE_NUM = x_reference_num)
 	OR ((tlinfo.reference_num is null)
		AND (x_reference_num is null)))
  AND ((tlinfo.credit_card_code        = x_credit_card_code) OR ((tlinfo.credit_card_code IS NULL) AND (x_credit_card_code IS NULL)))
  AND ((tlinfo.credit_card_holder_name = x_credit_card_holder_name) OR ((tlinfo.credit_card_holder_name IS NULL) AND (x_credit_card_holder_name IS NULL)))
  AND ((tlinfo.credit_card_number      = x_credit_card_number) OR ((tlinfo.credit_card_number IS NULL) AND (x_credit_card_number IS NULL)))
  AND ((TRUNC(tlinfo.credit_card_expiration_date)  = TRUNC(x_credit_card_expiration_date)) OR ((tlinfo.credit_card_expiration_date IS NULL) AND (x_credit_card_expiration_date IS NULL)))
  AND ((tlinfo.rev_gl_ccid             = x_rev_gl_ccid) OR ((tlinfo.rev_gl_ccid IS NULL) AND (x_rev_gl_ccid IS NULL)))
  AND ((tlinfo.cash_gl_ccid            = x_cash_gl_ccid) OR ((tlinfo.cash_gl_ccid IS NULL) AND (x_cash_gl_ccid IS NULL)))
  AND ((tlinfo.rev_account_cd          = x_rev_account_cd) OR ((tlinfo.rev_account_cd IS NULL) AND (x_rev_account_cd IS NULL)))
  AND ((tlinfo.cash_account_cd         = x_cash_account_cd) OR ((tlinfo.cash_account_cd IS NULL) AND (x_cash_account_cd IS NULL)))
  AND ((TRUNC(tlinfo.gl_date)          = TRUNC(x_gl_date)) OR ((tlinfo.gl_date IS NULL) AND (x_gl_date IS NULL)))
  AND ((TRUNC(tlinfo.gl_posted_date)          = TRUNC(x_gl_posted_date)) OR ((tlinfo.gl_posted_date IS NULL) AND (x_gl_posted_date IS NULL)))
  AND ((tlinfo.posting_control_id      = x_posting_control_id) OR ((tlinfo.posting_control_id IS NULL) AND (x_posting_control_id IS NULL)))
  AND ((tlinfo.credit_card_tangible_cd = x_credit_card_tangible_cd) OR ((tlinfo.credit_card_tangible_cd IS NULL) AND (x_credit_card_tangible_cd IS NULL)))
  AND ((tlinfo.credit_card_payee_cd    = x_credit_card_payee_cd) OR ((tlinfo.credit_card_payee_cd IS NULL) AND (x_credit_card_payee_cd IS NULL)))
  AND ((tlinfo.credit_card_status_code = x_credit_card_status_code) OR ((tlinfo.credit_card_status_code IS NULL) AND (x_credit_card_status_code IS NULL)))
  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
    app_exception.raise_exception;
  END IF;
  RETURN;
END lock_row;

 PROCEDURE update_row (
      X_ROWID in  VARCHAR2,
       x_APP_REQ_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2,
       X_MODE IN VARCHAR2  ,
       x_credit_card_code		IN  VARCHAR2 ,
       x_credit_card_holder_name        IN  VARCHAR2 ,
       x_credit_card_number             IN  VARCHAR2 ,
       x_credit_card_expiration_date    IN  DATE     ,
       x_rev_gl_ccid                    IN  NUMBER   ,
       x_cash_gl_ccid                   IN  NUMBER   ,
       x_rev_account_cd                 IN  VARCHAR2 ,
       x_cash_account_cd                IN  VARCHAR2 ,
       x_gl_date                        IN  DATE     ,
       x_gl_posted_date                 IN  DATE     ,
       x_posting_control_id             IN  NUMBER   ,
       x_credit_card_tangible_cd        IN  VARCHAR2 ,
       x_credit_card_payee_cd           IN  VARCHAR2 ,
       x_credit_card_status_code        IN  VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar       30-May-200      Security related changes
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
   smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE IN ('R', 'S')) then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_app_req_id=>X_APP_REQ_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_admission_appl_number=>X_ADMISSION_APPL_NUMBER,
 	       x_applicant_fee_type=>X_APPLICANT_FEE_TYPE,
 	       x_applicant_fee_status=>X_APPLICANT_FEE_STATUS,
 	       x_fee_date=>X_FEE_DATE,
 	       x_fee_payment_method=>X_FEE_PAYMENT_METHOD,
 	       x_fee_amount=>X_FEE_AMOUNT,
               x_reference_num=>X_REFERENCE_NUM,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_credit_card_code            => x_credit_card_code,
               x_credit_card_holder_name     => x_credit_card_holder_name,
               x_credit_card_number          => x_credit_card_number,
               x_credit_card_expiration_date => x_credit_card_expiration_date,
               x_rev_gl_ccid                 => x_rev_gl_ccid,
               x_cash_gl_ccid                => x_cash_gl_ccid,
               x_rev_account_cd              => x_rev_account_cd,
               x_cash_account_cd             => x_cash_account_cd,
               x_gl_date                     => x_gl_date,
               x_gl_posted_date              => x_gl_posted_date,
               x_posting_control_id          => x_posting_control_id,
               x_credit_card_tangible_cd     => x_credit_card_tangible_cd,
               x_credit_card_payee_cd        => x_credit_card_payee_cd,
               x_credit_card_status_code     => x_credit_card_status_code
	       );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_app_req SET
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      ADMISSION_APPL_NUMBER =  NEW_REFERENCES.ADMISSION_APPL_NUMBER,
      APPLICANT_FEE_TYPE =  NEW_REFERENCES.APPLICANT_FEE_TYPE,
      APPLICANT_FEE_STATUS =  NEW_REFERENCES.APPLICANT_FEE_STATUS,
      FEE_DATE =  NEW_REFERENCES.FEE_DATE,
      FEE_PAYMENT_METHOD =  NEW_REFERENCES.FEE_PAYMENT_METHOD,
      FEE_AMOUNT =  NEW_REFERENCES.FEE_AMOUNT,
      REFERENCE_NUM = NEW_REFERENCES.REFERENCE_NUM,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        credit_card_code            = new_references.credit_card_code ,
        credit_card_holder_name     = new_references.credit_card_holder_name,
        credit_card_number          = new_references.credit_card_number,
        credit_card_expiration_date = new_references.credit_card_expiration_date,
        rev_gl_ccid                 = new_references.rev_gl_ccid,
        cash_gl_ccid                = new_references.cash_gl_ccid,
        rev_account_cd              = new_references.rev_account_cd,
        cash_account_cd             = new_references.cash_account_cd,
        gl_date                     = new_references.gl_date,
        gl_posted_date              = new_references.gl_posted_date,
        posting_control_id          = new_references.posting_control_id,
        credit_card_tangible_cd     = new_references.credit_card_tangible_cd,
        credit_card_payee_cd        = new_references.credit_card_payee_cd,
        credit_card_status_code     = new_references.credit_card_status_code
  WHERE rowid = x_rowid;
	IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
	END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
     igs_sc_gen_001.unset_ctx('R');
  END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END update_row;

 PROCEDURE add_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_APP_REQ_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_ADMISSION_APPL_NUMBER IN NUMBER,
       x_APPLICANT_FEE_TYPE IN NUMBER,
       x_APPLICANT_FEE_STATUS IN NUMBER,
       x_FEE_DATE IN DATE,
       x_FEE_PAYMENT_METHOD IN NUMBER,
       x_FEE_AMOUNT IN NUMBER,
       x_REFERENCE_NUM IN VARCHAR2,
       X_MODE IN VARCHAR2 ,
       x_credit_card_code		IN  VARCHAR2 ,
       x_credit_card_holder_name        IN  VARCHAR2 ,
       x_credit_card_number             IN  VARCHAR2 ,
       x_credit_card_expiration_date    IN  DATE     ,
       x_rev_gl_ccid                    IN  NUMBER   ,
       x_cash_gl_ccid                   IN  NUMBER   ,
       x_rev_account_cd                 IN  VARCHAR2 ,
       x_cash_account_cd                IN  VARCHAR2 ,
       x_gl_date                        IN  DATE     ,
       x_gl_posted_date                 IN  DATE     ,
       x_posting_control_id             IN  NUMBER   ,
       x_credit_card_tangible_cd        IN  VARCHAR2 ,
       x_credit_card_payee_cd           IN  VARCHAR2 ,
       x_credit_card_status_code        IN  VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        16-Jun-2003    Enh 2831587 - FI210 Credit Card Fund Transfer build
                                 Added cols - credit_card_tangible_cd, credit_card_payee_cd
                                 and credit_card_status_code
   smadathi      06-nov-2002    Enh. Bug 2584986. Added new columns as specified
                               in GL Interface CS Document
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c1 IS
    SELECT rowid
    FROM   igs_ad_app_req
    WHERE  app_req_id= x_app_req_id
;
BEGIN
	OPEN c1;
		FETCH c1 INTO X_ROWID;
		IF (c1%NOTFOUND) THEN
	CLOSE c1;
    insert_row (
      X_ROWID,
       X_APP_REQ_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_APPLICANT_FEE_TYPE,
       X_APPLICANT_FEE_STATUS,
       X_FEE_DATE,
       X_FEE_PAYMENT_METHOD,
       X_FEE_AMOUNT,
       X_REFERENCE_NUM,
       X_MODE ,
       x_credit_card_code            ,
       x_credit_card_holder_name     ,
       x_credit_card_number          ,
       x_credit_card_expiration_date ,
       x_rev_gl_ccid                 ,
       x_cash_gl_ccid                ,
       x_rev_account_cd              ,
       x_cash_account_cd             ,
       x_gl_date                     ,
       x_gl_posted_date              ,
       x_posting_control_id          ,
       x_credit_card_tangible_cd     ,
       x_credit_card_payee_cd        ,
       x_credit_card_status_code
      );
     RETURN;
	END IF;
	   CLOSE c1;
update_row (
       X_ROWID,
       X_APP_REQ_ID,
       X_PERSON_ID,
       X_ADMISSION_APPL_NUMBER,
       X_APPLICANT_FEE_TYPE,
       X_APPLICANT_FEE_STATUS,
       X_FEE_DATE,
       X_FEE_PAYMENT_METHOD,
       X_FEE_AMOUNT,
       X_REFERENCE_NUM,
       X_MODE ,
       x_credit_card_code            ,
       x_credit_card_holder_name     ,
       x_credit_card_number          ,
       x_credit_card_expiration_date ,
       x_rev_gl_ccid                 ,
       x_cash_gl_ccid                ,
       x_rev_account_cd              ,
       x_cash_account_cd             ,
       x_gl_date                     ,
       x_gl_posted_date              ,
       x_posting_control_id          ,
       x_credit_card_tangible_cd     ,
       x_credit_card_payee_cd        ,
       x_credit_card_status_code
      );
END add_row;

PROCEDURE delete_row (
  x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  ravishar       30-May-200      Security related changes

  (reverse chronological order - newest change first)
  ***************************************************************/

BEGIN
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM IGS_AD_APP_REQ
 WHERE rowid = x_rowid;
  IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
       igs_sc_gen_001.set_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
END delete_row;

END igs_ad_app_req_pkg;

/
