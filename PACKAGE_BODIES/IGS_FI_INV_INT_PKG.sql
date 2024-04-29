--------------------------------------------------------
--  DDL for Package Body IGS_FI_INV_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_INV_INT_PKG" AS
/* $Header: IGSSI73B.pls 120.3 2006/06/27 14:08:37 skharida ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_fi_inv_int_all%RowType;
  new_references igs_fi_inv_int_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_invoice_id IN NUMBER,
    x_person_id IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_invoice_amount_due IN NUMBER,
    x_invoice_creation_date IN DATE,
    x_invoice_desc IN VARCHAR2,
    x_transaction_type IN VARCHAR2,
    x_currency_cd IN VARCHAR2,
    x_status IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_ORG_ID IN NUMBER,
    x_invoice_amount IN NUMBER,
    x_bill_id IN NUMBER,
    x_bill_number IN VARCHAR2,
    x_bill_date IN DATE,
    x_waiver_flag IN VARCHAR2,
    x_waiver_reason IN VARCHAR2,
    x_effective_date IN DATE,
    x_invoice_number IN VARCHAR2,
    x_exchange_rate IN NUMBER,
    x_bill_payment_due_date IN DATE,
    x_OPTIONAL_FEE_FLAG IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_reversal_gl_date IN DATE,
    x_tax_year_code  IN VARCHAR2,
    x_waiver_name IN VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skharida        26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  pathipat        30-Jun-2003     Bug: 3026125 - Waiver flag inserted as NULL for Ancillary Charges
                                  Added NVL clause for waiver_flag value
  shtatiko        11-MAR2003      Bug# 2734441, Added TRUNC call before assigning the value of
                                  x_invoice_creation_date.
  smadathi        06-Nov-2002     Enh. Bug 2584986. Added new column reversal_gl_date
  vvutukur        17-Sep-2002     Enh#2564643.Removed references to column subaccount_id.Also removed
                                  DEFAULT clause from procedure parameters to avoid gscc warnings.
  masehgal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  smadathi        05-oct-2001     Balance Flag reference removed .
                                  Enhancement Bug No. 2030448
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_INV_INT_ALL
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
    new_references.invoice_id := x_invoice_id;
    new_references.person_id := x_person_id;
    new_references.fee_type := x_fee_type;
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.course_cd := x_course_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.invoice_amount_due := x_invoice_amount_due;
    -- Added TRUNC as part of Bug# 2734441 by shtatiko on 11-MAR-2003
    new_references.invoice_creation_date := TRUNC( x_invoice_creation_date );
    new_references.invoice_desc := x_invoice_desc;
    new_references.transaction_type := x_transaction_type;
    new_references.currency_cd := x_currency_cd;
    new_references.status := x_status;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.org_id      := x_org_id;
    new_references.invoice_amount := x_invoice_amount ;
    new_references.bill_id := x_bill_id ;
    new_references.bill_number := x_bill_number ;
    new_references.bill_date := x_bill_date ;

    -- Waiver flag is set to 'N' if passed as NULL (pathipat)
    new_references.waiver_flag := NVL(x_waiver_flag,'N') ;

    new_references.waiver_reason := x_waiver_reason ;
    -- Added TRUNC as part of Bug# 2734441 by shtatiko on 24-MAR-2003
    new_references.effective_date := TRUNC(x_effective_date) ;
    new_references.invoice_number :=  x_invoice_number ;
    new_references.exchange_rate := x_exchange_rate ;
    new_references.bill_payment_due_date := x_bill_payment_due_date ;
    new_references.optional_fee_flag := x_optional_fee_flag ;
    new_references.reversal_gl_date  := TRUNC(x_reversal_gl_date);
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
    new_references.tax_year_code := x_tax_year_code;
    new_references.waiver_name := x_waiver_name;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2,
                 Column_Value IN VARCHAR2) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 (reverse chronological order - newest change first)
 skharida     26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
 vvutukur     17-sep-2002     Enh#2564643.Removed DEFAULT clause from parameters list to avoid gscc
                              warnings in order to comply with 9i standards.
  ***************************************************************/

  BEGIN

     IF column_name IS NULL THEN
        NULL;
     END IF;

  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_invoice_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skharida     26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_inv_int_all
      WHERE    invoice_id = x_invoice_id
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

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :schodava
  Date Created By :2000/05/11
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  vvutukur    23-Sep-2002    Enh#2564643.Removed references to subaccount_id.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.waiver_reason = new_references.waiver_reason)) OR
        ((new_references.waiver_reason IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'IGS_FI_WAIVER_REASON',
          new_references.waiver_reason
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.status = new_references.status) OR
         (new_references.status IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
                        'STATUS',
                         new_references.status
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.transaction_type = new_references.transaction_type) OR
         (new_references.transaction_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
                        'TRANSACTION_TYPE',
                         new_references.transaction_type
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.bill_id = new_references.bill_id)) OR
        ((new_references.bill_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_bill_pkg.get_pk_for_validation (
                new_references.bill_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  -- Following code added as part of the Enhancement Bug#1754956
  --removed reference to subaccount_id,ie., code which calls IGS_FI_SUBACCTS_PKG.Get_PK_For_Validation.

    --Bug# 3392095, PK validation from IGS_FI_WAIVER_PGMS table.
    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.waiver_name = new_references.waiver_name)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.waiver_name IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_fi_waiver_pgms_Pkg.Get_PK_For_Validation (
                         new_references.fee_cal_type,
                         new_references.fee_ci_sequence_number,
                         new_references.waiver_name
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS

  BEGIN
    --modified by sarakshi, all new_references are made old_references
    IGS_FI_APPLICATIONS_PKG.GET_FK_IGS_FI_INV_INT_ALL (
      old_references.invoice_id
    );

    IGS_FI_OTC_CHARGES_PKG.GET_FK_IGS_FI_INV_INT_ALL (
      old_references.invoice_id
    );

    IGS_FI_BILL_TRNSCTNS_PKG.GET_FK_IGS_FI_INV_INT (
      old_references.invoice_id
    );

    --added by sarakshi, bug:2124001
    IGS_FI_INV_WAV_DET_PKG.GET_FK_IGS_FI_INV_INT_ALL(
      old_references.invoice_id
    );

    -- Added Enh#2144600
    igs_fi_refunds_pkg.get_fk_igs_fi_inv_int( old_references.invoice_id);

    -- Added Enh#2144600
    igs_fi_refund_int_pkg.get_fk_igs_fi_inv_int( old_references.invoice_id);

  END Check_Child_Existance;

  PROCEDURE beforeRowInsertUpdateDelete(  p_inserting IN BOOLEAN DEFAULT FALSE,
                                          p_updating  IN BOOLEAN DEFAULT FALSE,
                                          p_deleting  IN BOOLEAN DEFAULT FALSE
					) AS
  /*
  ||  Created By : vvutukur
  ||  Created On : 19-NOV-2003
  ||  Purpose :    To carryout the actions before insert/update/delete a record in igs_fi_inv_int_all table.
  ||               Created as part of bugfix#3249288.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


    --Cursor to fetch the value of Optional Payment Indicator value from Fee Type Setup.
    CURSOR c_igs_fi_fee_type(cp_v_fee_type igs_fi_fee_type.fee_type%TYPE) IS
      SELECT ft.optional_payment_ind
      FROM   igs_fi_fee_type ft
      WHERE  ft.fee_type = cp_v_fee_type;

    l_v_optional_payment_ind igs_fi_fee_type.optional_payment_ind%TYPE;

  BEGIN

    IF (p_inserting) THEN
      -- Based on the optional payment indicator value set in the fee type
      -- set up form, the value of the OPTIONAL_FEE_FLAG column in the charges table
      -- will be set as either 'O' or 'N'. For all charges created with a Non-optional
      -- fee type, the value of OPTIONAL_FEE_FLAG column in the charges table will be
      -- assigned as 'N'.For all charges created with an optional
      -- fee type, the value of OPTIONAL_FEE_FLAG column in the charges table will be
      -- assigned as 'O'.

      OPEN  c_igs_fi_fee_type(new_references.fee_type);
      FETCH c_igs_fi_fee_type INTO l_v_optional_payment_ind;
      CLOSE c_igs_fi_fee_type;

      IF l_v_optional_payment_ind = 'N' THEN
        new_references.optional_fee_flag := 'N';
      ELSIF l_v_optional_payment_ind = 'Y' THEN
        new_references.optional_fee_flag := 'O';
      END IF;
    END IF;
  END beforeRowInsertUpdateDelete;

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 23-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_bill_trnsctns
      WHERE   ((bill_id = x_bill_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_INVI_FBLLA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_bill;

--removed procedure get_fk_igs_fi_subaccts_all as part of subaccount removal build. enh#2564643.

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_invoice_id IN NUMBER,
    x_person_id IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2,
    x_invoice_amount_due IN NUMBER,
    x_invoice_creation_date IN DATE,
    x_invoice_desc IN VARCHAR2,
    x_transaction_type IN VARCHAR2,
    x_currency_cd IN VARCHAR2,
    x_status IN VARCHAR2,
    x_attribute_category IN VARCHAR2,
    x_attribute1 IN VARCHAR2,
    x_attribute2 IN VARCHAR2,
    x_attribute3 IN VARCHAR2,
    x_attribute4 IN VARCHAR2,
    x_attribute5 IN VARCHAR2,
    x_attribute6 IN VARCHAR2,
    x_attribute7 IN VARCHAR2,
    x_attribute8 IN VARCHAR2,
    x_attribute9 IN VARCHAR2,
    x_attribute10 IN VARCHAR2,
    x_ORG_ID IN NUMBER,
    x_invoice_amount IN NUMBER,
    x_bill_id IN NUMBER,
    x_bill_number IN VARCHAR2,
    x_bill_date IN DATE,
    x_waiver_flag IN VARCHAR2,
    x_waiver_reason IN VARCHAR2,
    x_effective_date IN DATE,
    x_invoice_number IN VARCHAR2,
    x_exchange_rate IN NUMBER,
    x_bill_payment_due_date IN DATE,
    x_OPTIONAL_FEE_FLAG     IN VARCHAR2,
    x_creation_date         IN DATE,
    x_created_by            IN NUMBER,
    x_last_update_date      IN DATE,
    x_last_updated_by       IN NUMBER,
    x_last_update_login     IN NUMBER,
    x_reversal_gl_date      IN DATE,
    x_tax_year_code         IN VARCHAR2,
    x_waiver_name           IN VARCHAR2
    ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  vvutukur        19-Nov-2003     Bug#3249288.Added call to newly created procedure beforeRowInsertUpdateDelete.
  smadathi        05-oct-2002     Enh. Bug 2584986. Added new column reversal_gl_date
  vvutukur        17-Sep-2002     Enh#2564643.Removed references to column subaccount_id.Also removed
                                  DEFAULT clause from parameter list to avoid gscc warnings.
  maseghal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  smadathi        05-oct-2001     Balance Flag reference removed .
                                  Enhancement Bug No. 2030448
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_invoice_id,
      x_person_id,
      x_fee_type,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_course_cd,
      x_attendance_mode,
      x_attendance_type,
      x_invoice_amount_due,
      x_invoice_creation_date,
      x_invoice_desc,
      x_transaction_type,
      x_currency_cd,
      x_status,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_org_id,
      x_invoice_amount,
      x_bill_id,
      x_bill_number,
      x_bill_date,
      x_waiver_flag,
      x_waiver_reason,
      x_effective_date,
      x_invoice_number,
      x_exchange_rate,
      x_bill_payment_due_date,
      x_optional_fee_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_reversal_gl_date,
      x_tax_year_code,
      x_waiver_name
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.invoice_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Parent_Existance;
      beforeRowInsertUpdateDelete(p_inserting => TRUE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.invoice_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
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
  skharida        26-Jun-2006     Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  masehgal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_INVOICE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_INVOICE_AMOUNT_DUE IN NUMBER,
       x_INVOICE_CREATION_DATE IN DATE,
       x_INVOICE_DESC IN VARCHAR2,
       x_TRANSACTION_TYPE IN VARCHAR2,
       x_CURRENCY_CD IN VARCHAR2,
       x_STATUS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_INVOICE_AMOUNT IN NUMBER,
       x_BILL_ID IN NUMBER,
       x_BILL_NUMBER IN VARCHAR2,
       x_BILL_DATE      IN DATE,
       x_WAIVER_FLAG    IN VARCHAR2,
       x_WAIVER_REASON  IN VARCHAR2,
       x_EFFECTIVE_DATE IN DATE,
       x_INVOICE_NUMBER IN VARCHAR2,
       x_EXCHANGE_RATE  IN NUMBER,
       x_BILL_PAYMENT_DUE_DATE IN DATE,
       x_ORG_ID             IN NUMBER,
       x_OPTIONAL_FEE_FLAG  IN VARCHAR2,
       X_MODE               IN VARCHAR2,
       X_REVERSAL_GL_DATE   IN DATE,
       x_tax_year_code      IN VARCHAR2,
       x_waiver_name        IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skharida      26-Jun-2006       Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  smadathi      06-Nov-2002       Enh. Bug 2584986. Added new column
                                  REVERSAL_GL_DATE
  vvutukur        17-Sep-2002     Enh#2564643.Removed references to subaccount_id.Also removed DEFAULT
                                  clause from package body to avoid gscc warnings.
  masehgal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  smadathi        05-oct-2001     Balance Flag reference removed .
                                  Enhancement Bug No. 2030448
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_FI_INV_INT_ALL
             where                 INVOICE_ID= X_INVOICE_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
      elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
          if X_LAST_UPDATE_LOGIN is NULL then
             X_LAST_UPDATE_LOGIN := -1;
          end if;
          X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
          X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
          X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
          if (X_REQUEST_ID = -1 ) then
           X_REQUEST_ID:=NULL;
           X_PROGRAM_ID:=NULL;
           X_PROGRAM_APPLICATION_ID:=NULL;
           X_PROGRAM_UPDATE_DATE:=NULL;
         else
           X_PROGRAM_UPDATE_DATE:=SYSDATE;
         end if;
      else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
        IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
      end if;

          SELECT
            IGS_FI_INV_INT_S.nextval
          INTO
            x_invoice_id
          FROM
           dual;

   Before_DML(
               p_action=>'INSERT',
               x_rowid=>X_ROWID,
               x_invoice_id=>X_INVOICE_ID,
               x_person_id=>X_PERSON_ID,
               x_fee_type=>X_FEE_TYPE,
               x_fee_cat=>X_FEE_CAT,
               x_fee_cal_type=>X_FEE_CAL_TYPE,
               x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
               x_course_cd=>X_COURSE_CD,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_invoice_amount_due=>X_INVOICE_AMOUNT_DUE,
               x_invoice_creation_date=>X_INVOICE_CREATION_DATE,
               x_invoice_desc=>X_INVOICE_DESC,
               x_transaction_type=>X_TRANSACTION_TYPE,
               x_currency_cd=>X_CURRENCY_CD,
               x_status=>X_STATUS,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_org_id=>igs_ge_gen_003.get_org_id,
               x_invoice_amount         => X_INVOICE_AMOUNT,
               x_bill_id                => X_BILL_ID,
               x_bill_number            => X_BILL_NUMBER ,
               x_bill_date              => X_BILL_DATE,
               x_waiver_flag            => X_WAIVER_FLAG,
               x_waiver_reason          => X_WAIVER_REASON,
               x_effective_date         => X_EFFECTIVE_DATE,
               x_invoice_number         => X_INVOICE_NUMBER ,
               x_exchange_rate          => X_EXCHANGE_RATE,
               x_bill_payment_due_date  => X_BILL_PAYMENT_DUE_DATE,
               x_optional_fee_flag      => X_OPTIONAL_FEE_FLAG,
               x_creation_date          => X_LAST_UPDATE_DATE,
               x_created_by             => X_LAST_UPDATED_BY,
               x_last_update_date       => X_LAST_UPDATE_DATE,
               x_last_updated_by        => X_LAST_UPDATED_BY,
               x_last_update_login      => X_LAST_UPDATE_LOGIN,
               x_reversal_gl_date       => x_reversal_gl_date,
	       x_tax_year_code          => x_tax_year_code,
               x_waiver_name            => x_waiver_name
               );

     insert into IGS_FI_INV_INT_ALL (
                INVOICE_ID
                ,PERSON_ID
                ,FEE_TYPE
                ,FEE_CAT
                ,FEE_CAL_TYPE
                ,FEE_CI_SEQUENCE_NUMBER
                ,COURSE_CD
                ,ATTENDANCE_MODE
                ,ATTENDANCE_TYPE
                ,INVOICE_AMOUNT_DUE
                ,INVOICE_CREATION_DATE
                ,INVOICE_DESC
                ,TRANSACTION_TYPE
                ,CURRENCY_CD
                ,STATUS
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,ATTRIBUTE2
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ORG_ID
                ,INVOICE_AMOUNT
                ,BILL_ID
                ,BILL_NUMBER
                ,BILL_DATE
                ,WAIVER_FLAG
                ,WAIVER_REASON
                ,EFFECTIVE_DATE
                ,INVOICE_NUMBER
                ,EXCHANGE_RATE
                ,BILL_PAYMENT_DUE_DATE
                ,OPTIONAL_FEE_FLAG
                ,REQUEST_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_ID
                ,PROGRAM_UPDATE_DATE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,REVERSAL_GL_DATE
		,TAX_YEAR_CODE
                ,WAIVER_NAME
        ) values  (
                NEW_REFERENCES.INVOICE_ID
                ,NEW_REFERENCES.PERSON_ID
                ,NEW_REFERENCES.FEE_TYPE
                ,NEW_REFERENCES.FEE_CAT
                ,NEW_REFERENCES.FEE_CAL_TYPE
                ,NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER
                ,NEW_REFERENCES.COURSE_CD
                ,NEW_REFERENCES.ATTENDANCE_MODE
                ,NEW_REFERENCES.ATTENDANCE_TYPE
                ,NEW_REFERENCES.INVOICE_AMOUNT_DUE
                ,NEW_REFERENCES.INVOICE_CREATION_DATE
                ,NEW_REFERENCES.INVOICE_DESC
                ,NEW_REFERENCES.TRANSACTION_TYPE
                ,NEW_REFERENCES.CURRENCY_CD
                ,NEW_REFERENCES.STATUS
                ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
                ,NEW_REFERENCES.ATTRIBUTE1
                ,NEW_REFERENCES.ATTRIBUTE2
                ,NEW_REFERENCES.ATTRIBUTE3
                ,NEW_REFERENCES.ATTRIBUTE4
                ,NEW_REFERENCES.ATTRIBUTE5
                ,NEW_REFERENCES.ATTRIBUTE6
                ,NEW_REFERENCES.ATTRIBUTE7
                ,NEW_REFERENCES.ATTRIBUTE8
                ,NEW_REFERENCES.ATTRIBUTE9
                ,NEW_REFERENCES.ATTRIBUTE10
                ,NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.INVOICE_AMOUNT
                ,NEW_REFERENCES.BILL_ID
                ,NEW_REFERENCES.BILL_NUMBER
                ,NEW_REFERENCES.BILL_DATE
                ,NEW_REFERENCES.WAIVER_FLAG
                ,NEW_REFERENCES.WAIVER_REASON
                ,NEW_REFERENCES.EFFECTIVE_DATE
                ,NEW_REFERENCES.INVOICE_NUMBER
                ,NEW_REFERENCES.EXCHANGE_RATE
                ,NEW_REFERENCES.BILL_PAYMENT_DUE_DATE
                ,NEW_REFERENCES.OPTIONAL_FEE_FLAG
                ,X_REQUEST_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_UPDATE_DATE
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,new_references.reversal_gl_date
		,new_references.tax_year_code
                ,new_references.waiver_name
);
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
end INSERT_ROW;

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cat                           IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_invoice_amount_due                IN     NUMBER,
    x_invoice_creation_date             IN     DATE,
    x_invoice_desc                      IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_currency_cd                       IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_invoice_amount                    IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_waiver_flag                       IN     VARCHAR2,
    x_waiver_reason                     IN     VARCHAR2,
    x_effective_date                    IN     DATE,
    x_invoice_number                    IN     VARCHAR2,
    x_exchange_rate                     IN     NUMBER,
    x_bill_payment_due_date             IN     DATE,
    x_OPTIONAL_FEE_FLAG                 IN     VARCHAR2,
    x_reversal_gl_date                  IN     DATE,
    x_tax_year_code                     IN     VARCHAR2,
    x_waiver_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jabeen.begum@oracle.com
  ||  Created On : 03-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When             What
  ||  skharida        26-Jun-2006      Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  ||  smadathi        06-Nov-2002      Enh. Bug 2584986. Added new column REVERSAL_GL_DATE
  ||  vvutukur        17-Sep-2002      Enh#2564643.Removed references to column subaccount_id.Also
  ||                                   removed DEFAULT clause for parametr x_optional_fee_flag to
  ||                                   avoid gscc warning.
  ||  masehgal        10-JAN-2002      Enh # 2170429
  ||                                   Obsoletion of SPONSOR_CD
  ||  smadathi        05-oct-2001      Balance Flag reference removed .
  ||                                   Enhancement Bug No. 2030448
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        fee_type,
        fee_cat,
        fee_cal_type,
        fee_ci_sequence_number,
        course_cd,
        attendance_mode,
        attendance_type,
        invoice_amount_due,
        invoice_creation_date,
        invoice_desc,
        transaction_type,
        currency_cd,
        status,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        invoice_amount,
        bill_id,
        bill_number,
        bill_date,
        waiver_flag,
        waiver_reason,
        effective_date,
        invoice_number,
        exchange_rate,
        bill_payment_due_date,
        optional_fee_flag,
        reversal_gl_date,
	tax_year_code,
        waiver_name
      FROM  igs_fi_inv_int_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.fee_type = x_fee_type)
        AND ((tlinfo.fee_cat = x_fee_cat) OR ((tlinfo.fee_cat IS NULL) AND (X_fee_cat IS NULL)))
        AND (tlinfo.fee_cal_type = x_fee_cal_type)
        AND (tlinfo.fee_ci_sequence_number = x_fee_ci_sequence_number)
        AND ((tlinfo.course_cd = x_course_cd) OR ((tlinfo.course_cd IS NULL) AND (X_course_cd IS NULL)))
        AND ((tlinfo.attendance_mode = x_attendance_mode) OR ((tlinfo.attendance_mode IS NULL) AND (X_attendance_mode IS NULL)))
        AND ((tlinfo.attendance_type = x_attendance_type) OR ((tlinfo.attendance_type IS NULL) AND (X_attendance_type IS NULL)))
        AND (tlinfo.invoice_amount_due = x_invoice_amount_due)
        AND (trunc(tlinfo.invoice_creation_date) = trunc(x_invoice_creation_date))
        AND ((tlinfo.invoice_desc = x_invoice_desc) OR ((tlinfo.invoice_desc IS NULL) AND (X_invoice_desc IS NULL)))
        AND (tlinfo.transaction_type = x_transaction_type)
        AND (tlinfo.currency_cd = x_currency_cd)
        AND (tlinfo.status = x_status)
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.invoice_amount = x_invoice_amount) OR ((tlinfo.invoice_amount IS NULL) AND (X_invoice_amount IS NULL)))
        AND ((tlinfo.bill_id = x_bill_id) OR ((tlinfo.bill_id IS NULL) AND (X_bill_id IS NULL)))
        AND ((tlinfo.bill_number = x_bill_number) OR ((tlinfo.bill_number IS NULL) AND (X_bill_number IS NULL)))
        AND ((trunc(tlinfo.bill_date) = trunc(x_bill_date)) OR ((tlinfo.bill_date IS NULL) AND (X_bill_date IS NULL)))
        AND ((tlinfo.waiver_flag = x_waiver_flag) OR ((tlinfo.waiver_flag IS NULL) AND (X_waiver_flag IS NULL)))
        AND ((tlinfo.waiver_reason = x_waiver_reason) OR ((tlinfo.waiver_reason IS NULL) AND (X_waiver_reason IS NULL)))
        AND ((trunc(tlinfo.effective_date) = trunc(x_effective_date)) OR ((tlinfo.effective_date IS NULL) AND (X_effective_date IS NULL)))
        AND ((tlinfo.invoice_number = x_invoice_number) OR ((tlinfo.invoice_number IS NULL) AND (X_invoice_number IS NULL)))
        AND ((tlinfo.exchange_rate = x_exchange_rate) OR ((tlinfo.exchange_rate IS NULL) AND (X_exchange_rate IS NULL)))
        AND ((trunc(tlinfo.bill_payment_due_date) = trunc(x_bill_payment_due_date)) OR ((tlinfo.bill_payment_due_date IS NULL) AND (X_bill_payment_due_date IS NULL)))
        AND ((tlinfo.optional_fee_flag = x_optional_fee_flag) OR ((tlinfo.optional_fee_flag IS NULL) AND (X_optional_fee_flag IS NULL)))
        AND ((TRUNC(tlinfo.reversal_gl_date) = TRUNC(x_reversal_gl_date)) OR ((tlinfo.reversal_gl_date IS NULL) AND (X_reversal_gl_date IS NULL)))
	AND ((tlinfo.tax_year_code = x_tax_year_code) OR ((tlinfo.tax_year_code IS NULL) AND (x_tax_year_code IS NULL)))
        AND ((tlinfo.waiver_name = x_waiver_name) OR ((tlinfo.waiver_name IS NULL) AND (X_waiver_name IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_INVOICE_AMOUNT_DUE IN NUMBER,
       x_INVOICE_CREATION_DATE IN DATE,
       x_INVOICE_DESC IN VARCHAR2,
       x_TRANSACTION_TYPE IN VARCHAR2,
       x_CURRENCY_CD IN VARCHAR2,
       x_STATUS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_INVOICE_AMOUNT IN NUMBER,
       x_BILL_ID IN NUMBER,
       x_BILL_NUMBER IN VARCHAR2,
       x_BILL_DATE IN DATE,
       x_WAIVER_FLAG IN VARCHAR2,
       x_WAIVER_REASON IN VARCHAR2,
       x_EFFECTIVE_DATE IN DATE,
       x_INVOICE_NUMBER IN VARCHAR2,
       x_EXCHANGE_RATE IN NUMBER,
       x_BILL_PAYMENT_DUE_DATE IN DATE,
       x_OPTIONAL_FEE_FLAG IN VARCHAR2,
       X_MODE              IN VARCHAR2,
       x_reversal_gl_date  IN DATE,
       x_tax_year_code     IN VARCHAR2,
       x_waiver_name       IN VARCHAR2
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skharida     26-Jun-2006        Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  smadathi     06-Nov-2002        Enh. Bug 2584986. Added new column REVERSAL_GL_DATE
  vvutukur        17-Sep-2002     Enh#2564643.Removed references to column subaccount_id.Also removed
                                  DEFAULT clause from procedure parameters to avoid gscc warnings.
  masehgal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  smadathi        05-oct-2001     Balance Flag reference removed .
                                  Enhancement Bug No. 2030448
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
      if(X_MODE = 'I') then
        X_LAST_UPDATED_BY := 1;
        X_LAST_UPDATE_LOGIN := 0;
         elsif (X_MODE = 'R') then
               X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
            if X_LAST_UPDATED_BY is NULL then
                X_LAST_UPDATED_BY := -1;
            end if;
            X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
         if X_LAST_UPDATE_LOGIN is NULL then
            X_LAST_UPDATE_LOGIN := -1;
          end if;
          X_REQUEST_ID:=FND_GLOBAL.CONC_REQUEST_ID;
          X_PROGRAM_ID:=FND_GLOBAL.CONC_PROGRAM_ID;
          X_PROGRAM_APPLICATION_ID:=FND_GLOBAL.PROG_APPL_ID;
          if (X_REQUEST_ID = -1 ) then
            X_REQUEST_ID:=OLD_REFERENCES.REQUEST_ID;
            X_PROGRAM_ID:=OLD_REFERENCES.PROGRAM_ID;
            X_PROGRAM_APPLICATION_ID:=OLD_REFERENCES.PROGRAM_APPLICATION_ID;
            X_PROGRAM_UPDATE_DATE:=OLD_REFERENCES.PROGRAM_UPDATE_DATE;
         else
            X_PROGRAM_UPDATE_DATE:=SYSDATE;
         end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
               p_action      =>'UPDATE',
               x_rowid       =>X_ROWID,
               x_invoice_id  =>X_INVOICE_ID,
               x_person_id   =>X_PERSON_ID,
               x_fee_type    =>X_FEE_TYPE,
               x_fee_cat     =>X_FEE_CAT,
               x_fee_cal_type=>X_FEE_CAL_TYPE,
               x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
               x_course_cd   =>X_COURSE_CD,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_invoice_amount_due=>X_INVOICE_AMOUNT_DUE,
               x_invoice_creation_date=>X_INVOICE_CREATION_DATE,
               x_invoice_desc=>X_INVOICE_DESC,
               x_transaction_type=>X_TRANSACTION_TYPE,
               x_currency_cd=>X_CURRENCY_CD,
               x_status=>X_STATUS,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_attribute2=>X_ATTRIBUTE2,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_invoice_amount         => X_INVOICE_AMOUNT,
               x_bill_id                => X_BILL_ID,
               x_bill_number            => X_BILL_NUMBER ,
               x_bill_date              => X_BILL_DATE,
               x_waiver_flag            => X_WAIVER_FLAG,
               x_waiver_reason          => X_WAIVER_REASON,
               x_effective_date         => X_EFFECTIVE_DATE,
               x_invoice_number         => X_INVOICE_NUMBER ,
               x_exchange_rate          => X_EXCHANGE_RATE,
               x_bill_payment_due_date  => X_BILL_PAYMENT_DUE_DATE,
               x_optional_fee_flag      => X_OPTIONAL_FEE_FLAG,
               x_creation_date          => X_LAST_UPDATE_DATE,
               x_created_by             => X_LAST_UPDATED_BY,
               x_last_update_date       => X_LAST_UPDATE_DATE,
               x_last_updated_by        => X_LAST_UPDATED_BY,
               x_last_update_login      => X_LAST_UPDATE_LOGIN,
               x_reversal_gl_date       => x_reversal_gl_date,
	       x_tax_year_code          => x_tax_year_code,
               x_waiver_name            => x_waiver_name
               );

   update IGS_FI_INV_INT_ALL set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      FEE_TYPE =  NEW_REFERENCES.FEE_TYPE,
      FEE_CAT =  NEW_REFERENCES.FEE_CAT,
      FEE_CAL_TYPE =  NEW_REFERENCES.FEE_CAL_TYPE,
      FEE_CI_SEQUENCE_NUMBER =  NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
      COURSE_CD =  NEW_REFERENCES.COURSE_CD,
      ATTENDANCE_MODE =  NEW_REFERENCES.ATTENDANCE_MODE,
      ATTENDANCE_TYPE =  NEW_REFERENCES.ATTENDANCE_TYPE,
      INVOICE_AMOUNT_DUE =  NEW_REFERENCES.INVOICE_AMOUNT_DUE,
      INVOICE_CREATION_DATE =  NEW_REFERENCES.INVOICE_CREATION_DATE,
      INVOICE_DESC =  NEW_REFERENCES.INVOICE_DESC,
      TRANSACTION_TYPE =  NEW_REFERENCES.TRANSACTION_TYPE,
      CURRENCY_CD =  NEW_REFERENCES.CURRENCY_CD,
      STATUS =  NEW_REFERENCES.STATUS,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      INVOICE_AMOUNT =     NEW_REFERENCES.INVOICE_AMOUNT,
      BILL_ID      =  NEW_REFERENCES.BILL_ID ,
      BILL_NUMBER  =  NEW_REFERENCES.BILL_NUMBER ,
      BILL_DATE    =  NEW_REFERENCES.BILL_DATE ,
      WAIVER_FLAG  =  NEW_REFERENCES.WAIVER_FLAG ,
      WAIVER_REASON  =  NEW_REFERENCES.WAIVER_REASON ,
      EFFECTIVE_DATE  =   NEW_REFERENCES.EFFECTIVE_DATE ,
      INVOICE_NUMBER          = NEW_REFERENCES.INVOICE_NUMBER ,
      EXCHANGE_RATE           = NEW_REFERENCES.EXCHANGE_RATE ,
      BILL_PAYMENT_DUE_DATE   = NEW_REFERENCES.BILL_PAYMENT_DUE_DATE ,
      OPTIONAL_FEE_FLAG       = NEW_REFERENCES.OPTIONAL_FEE_FLAG,
      REQUEST_ID              = NEW_REFERENCES.REQUEST_ID ,
      PROGRAM_APPLICATION_ID  = NEW_REFERENCES.PROGRAM_APPLICATION_ID ,
      PROGRAM_ID              = NEW_REFERENCES.PROGRAM_ID ,
      PROGRAM_UPDATE_DATE     = NEW_REFERENCES.PROGRAM_UPDATE_DATE ,
      LAST_UPDATE_DATE        = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY         = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN       = X_LAST_UPDATE_LOGIN,
      reversal_gl_date        = new_references.reversal_gl_date,
      tax_year_code           = new_references.tax_year_code,
      waiver_name             = new_references.waiver_name
          where ROWID = X_ROWID;
        if (sql%notfound) then
                raise no_data_found;
        end if;

 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
end UPDATE_ROW;

 procedure ADD_ROW (
       X_ROWID in out NOCOPY VARCHAR2,
       x_INVOICE_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_COURSE_CD IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_INVOICE_AMOUNT_DUE IN NUMBER,
       x_INVOICE_CREATION_DATE IN DATE,
       x_INVOICE_DESC IN VARCHAR2,
       x_TRANSACTION_TYPE IN VARCHAR2,
       x_CURRENCY_CD IN VARCHAR2,
       x_STATUS IN VARCHAR2,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ORG_ID IN NUMBER,
       x_INVOICE_AMOUNT         IN NUMBER,
       x_BILL_ID                IN NUMBER,
       x_BILL_NUMBER            IN VARCHAR2,
       x_BILL_DATE              IN DATE,
       x_WAIVER_FLAG            IN VARCHAR2,
       x_WAIVER_REASON          IN VARCHAR2,
       x_EFFECTIVE_DATE         IN DATE,
       x_INVOICE_NUMBER         IN VARCHAR2,
       x_EXCHANGE_RATE          IN NUMBER,
       x_BILL_PAYMENT_DUE_DATE  IN DATE,
       x_OPTIONAL_FEE_FLAG      IN VARCHAR2,
       X_MODE                   IN VARCHAR2,
       x_reversal_gl_date       IN DATE,
       x_tax_year_code          IN VARCHAR2,
       x_waiver_name            IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skharida     26-Jun-2006        Bug# 5208136 - Removed the obsoleted columns from the table IGS_FI_INV_INT_ALL
  smadathi     06-Nov-2002        Enh. Bug 2584986. Added new column REVERSAL_GL_DATE
  vvutukur        17-Sep-2002     Enh#2564643.Removed references to column subaccount_id.Also removed
                                  DEFAULT clause from procedure parameters to avoid gscc warnings.
  masehgal        10-JAN-2002     Enh # 2170429
                                  Obsoletion of SPONSOR_CD
  smadathi        05-oct-2001     Balance Flag reference removed .
                                  Enhancement Bug No. 2030448
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_FI_INV_INT_ALL
             where     INVOICE_ID= X_INVOICE_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_INVOICE_ID,
       X_PERSON_ID,
       X_FEE_TYPE,
       X_FEE_CAT,
       X_FEE_CAL_TYPE,
       X_FEE_CI_SEQUENCE_NUMBER,
       X_COURSE_CD,
       X_ATTENDANCE_MODE,
       X_ATTENDANCE_TYPE,
       X_INVOICE_AMOUNT_DUE,
       X_INVOICE_CREATION_DATE,
       X_INVOICE_DESC,
       X_TRANSACTION_TYPE,
       X_CURRENCY_CD,
       X_STATUS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_INVOICE_AMOUNT ,
       X_BILL_ID  ,
       X_BILL_NUMBER ,
       X_BILL_DATE ,
       X_WAIVER_FLAG ,
       X_WAIVER_REASON ,
       X_EFFECTIVE_DATE ,
       X_INVOICE_NUMBER ,
       X_EXCHANGE_RATE ,
       X_BILL_PAYMENT_DUE_DATE,
       X_ORG_ID,
       x_OPTIONAL_FEE_FLAG,
       X_MODE ,
       X_REVERSAL_GL_DATE,
       x_tax_year_code,
       x_waiver_name
       );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_INVOICE_ID,
       X_PERSON_ID,
       X_FEE_TYPE,
       X_FEE_CAT,
       X_FEE_CAL_TYPE,
       X_FEE_CI_SEQUENCE_NUMBER,
       X_COURSE_CD,
       X_ATTENDANCE_MODE,
       X_ATTENDANCE_TYPE,
       X_INVOICE_AMOUNT_DUE,
       X_INVOICE_CREATION_DATE,
       X_INVOICE_DESC,
       X_TRANSACTION_TYPE,
       X_CURRENCY_CD,
       X_STATUS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_INVOICE_AMOUNT ,
       X_BILL_ID  ,
       X_BILL_NUMBER ,
       X_BILL_DATE ,
       X_WAIVER_FLAG ,
       X_WAIVER_REASON ,
       X_EFFECTIVE_DATE ,
       X_INVOICE_NUMBER ,
       X_EXCHANGE_RATE ,
       X_BILL_PAYMENT_DUE_DATE,
       x_OPTIONAL_FEE_FLAG,
       X_MODE,
       X_REVERSAL_GL_DATE,
       x_tax_year_code,
       x_waiver_name
       );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
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

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_FI_INV_INT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_fi_inv_int_pkg;

/
