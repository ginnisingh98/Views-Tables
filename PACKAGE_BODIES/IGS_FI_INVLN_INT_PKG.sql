--------------------------------------------------------
--  DDL for Package Body IGS_FI_INVLN_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_INVLN_INT_PKG" AS
/* $Header: IGSSI74B.pls 120.3 2005/07/08 05:25:19 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_fi_invln_int_all%RowType;
  new_references igs_fi_invln_int_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_invoice_id IN NUMBER ,
    x_line_number IN NUMBER ,
    x_invoice_lines_id IN NUMBER ,
    x_attribute2 IN VARCHAR2 ,
    x_chg_elements IN NUMBER ,
    x_amount IN NUMBER ,
    x_unit_attempt_status IN VARCHAR2 ,
    x_eftsu IN NUMBER ,
    x_credit_points IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_s_chg_method_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_REC_ACCOUNT_CD    IN VARCHAR2 ,
    x_REV_ACCOUNT_CD    IN VARCHAR2 ,
    x_REC_GL_CCID    IN NUMBER ,
    x_REV_GL_CCID    IN NUMBER ,
    x_ORG_UNIT_CD    IN VARCHAR2 ,
    x_POSTING_ID    IN NUMBER ,
    x_ATTRIBUTE11    IN VARCHAR2 ,
    x_ATTRIBUTE12    IN VARCHAR2 ,
    x_ATTRIBUTE13    IN VARCHAR2 ,
    x_ATTRIBUTE14    IN VARCHAR2 ,
    x_ATTRIBUTE15    IN VARCHAR2 ,
    x_ATTRIBUTE16    IN VARCHAR2 ,
    x_ATTRIBUTE17    IN VARCHAR2 ,
    x_ATTRIBUTE18    IN VARCHAR2 ,
    x_ATTRIBUTE19    IN VARCHAR2 ,
    x_ATTRIBUTE20    IN VARCHAR2 ,
    x_ERROR_STRING   IN VARCHAR2 ,
    x_ERROR_ACCOUNT  IN VARCHAR2 ,
    x_location_cd    IN VARCHAR2 ,
    x_uoo_id         IN NUMBER ,
    x_gl_date                IN     DATE,
    x_gl_posted_date         IN     DATE,
    x_posting_control_id     IN     NUMBER,
    x_unit_type_id           IN     NUMBER,
    x_unit_level             IN     VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  vchappid     23-Dec-2002        Enh#2720702, Error_Account is inserted as 'N' whenever it is found NULL
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_INVLN_INT_ALL
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
    new_references.line_number := x_line_number;
    new_references.invoice_lines_id := x_invoice_lines_id;
    new_references.attribute2 := x_attribute2;
    new_references.chg_elements := x_chg_elements;
    new_references.amount := x_amount;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.eftsu := x_eftsu;
    new_references.credit_points := x_credit_points;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.s_chg_method_type := x_s_chg_method_type;
    new_references.description := x_description;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.org_id := x_org_id;
    new_references.rec_account_cd := x_rec_account_cd;
    new_references.rev_account_cd := x_rev_account_cd;
    new_references.rec_gl_ccid := x_rec_gl_ccid;
    new_references.rev_gl_ccid := x_rev_gl_ccid;
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.posting_id := x_posting_id;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.error_string := x_error_string;
    new_references.error_account := NVL(x_error_account,'N');
    new_references.location_cd  := x_location_cd;
    new_references.uoo_id   := x_uoo_id;
    new_references.gl_date        := TRUNC(x_gl_date);
    new_references.gl_posted_date := x_gl_posted_date;
    new_references.posting_control_id    := x_posting_control_id;
    new_references.unit_type_id := x_unit_type_id;
    new_references.unit_level   := x_unit_level;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by    := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by    := x_created_by;
    END IF;
    new_references.last_update_date  := x_last_update_date;
    new_references.last_updated_by   := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END Set_Column_Values;



  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  ,
                 Column_Value IN VARCHAR2 ) AS
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
      ELSIF UPPER(column_name) ='ERROR_ACCOUNT' OR COLUMN_NAME IS NULL THEN
        new_references.error_account :=  column_value;
      END IF;

      IF UPPER(column_name) = 'ERROR_ACCOUNT' OR column_name IS NULL THEN
        IF NVL(new_references.error_account,'N') NOT IN ('Y','N') THEN
          FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
      END IF;

  END Check_Constraints;


 PROCEDURE Check_Uniqueness AS
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
                IF Get_Uk_For_Validation (
                    new_references.invoice_id,
                    new_references.line_number
                ) THEN
                  Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                  IGS_GE_MSG_STACK.ADD;
                  app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;


  FUNCTION Get_PK_For_Validation (
    x_invoice_lines_id IN NUMBER
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
      FROM     igs_fi_invln_int_all
      WHERE    invoice_lines_id = x_invoice_lines_id
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

  (reverse chronological order - newest change first)
  SVUPPALA        4-JUL-2005     Enh 3442712 - Added igs_ps_unit_type_lvl_pkg.get_pk_for_validation
  ***************************************************************/

  BEGIN

    IF ((old_references.rev_account_cd = new_references.rev_account_cd) OR
         (new_references.rev_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rev_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((old_references.rec_account_cd = new_references.rec_account_cd) OR
         (new_references.rec_account_cd IS NULL)) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_ACC_PKG.Get_PK_For_Validation (
               new_references.rec_account_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


    IF (((old_references.s_chg_method_type = new_references.s_chg_method_type) OR
         (new_references.s_chg_method_type IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
                        'CHG_METHOD',
                         new_references.s_chg_method_type
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

   IF (((old_references.posting_id = new_references.posting_id)) OR
        ((new_references.posting_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_posting_int_pkg.get_pk_for_validation (
                new_references.posting_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_type_id = new_references.unit_type_id)) OR
        ((new_references.unit_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_type_lvl_pkg.get_pk_for_validation (
                new_references.unit_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END Check_Parent_Existance;


  FUNCTION Get_UK_For_Validation (
    x_invoice_id IN NUMBER,
    x_line_number IN NUMBER
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
      FROM     igs_fi_invln_int_all
      WHERE    invoice_id = x_invoice_id
      AND      line_number = x_line_number      and      ((l_rowid is null) or (rowid <> l_rowid))

      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;


  PROCEDURE get_fk_igs_fi_posting_int_all (
    x_posting_id        IN     NUMBER
  ) AS
  /*
  ||  Created By : brajendr
  ||  Created On : 30-APR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_invln_int_all
      WHERE   ((posting_id = x_posting_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FI_PINT_INLI_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_fi_posting_int_all;


  PROCEDURE get_fk_igs_ps_unit_ofr_opt_all (
         x_uoo_id IN NUMBER
         ) AS
   /*
  ||  Created By : svuppala
  ||  Created On : 01-JUN-2005
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_invln_int_all
      WHERE   ((UOO_ID  = x_UOO_ID ));

    lv_rowid cur_rowid%RowType;

     BEGIN

       OPEN cur_rowid;
       FETCH cur_rowid INTO lv_rowid;
            IF (cur_rowid%FOUND) THEN
              CLOSE cur_rowid;
              fnd_message.set_name ('IGS', 'IGS_FI_INLI_UOO_FK');
              igs_ge_msg_stack.add;
              app_exception.raise_exception;
              RETURN;
            END IF;
     CLOSE cur_rowid;

END get_fk_igs_ps_unit_ofr_opt_all;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_invoice_id IN NUMBER ,
    x_line_number IN NUMBER ,
    x_invoice_lines_id IN NUMBER ,
    x_attribute2 IN VARCHAR2 ,
    x_chg_elements IN NUMBER ,
    x_amount IN NUMBER ,
    x_unit_attempt_status IN VARCHAR2 ,
    x_eftsu IN NUMBER ,
    x_credit_points IN NUMBER ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_s_chg_method_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_REC_ACCOUNT_CD    IN VARCHAR2 ,
    x_REV_ACCOUNT_CD    IN VARCHAR2 ,
    x_REC_GL_CCID    IN NUMBER ,
    x_REV_GL_CCID    IN NUMBER ,
    x_ORG_UNIT_CD    IN VARCHAR2 ,
    x_POSTING_ID    IN NUMBER ,
    x_ATTRIBUTE11    IN VARCHAR2 ,
    x_ATTRIBUTE12    IN VARCHAR2 ,
    x_ATTRIBUTE13    IN VARCHAR2 ,
    x_ATTRIBUTE14    IN VARCHAR2 ,
    x_ATTRIBUTE15    IN VARCHAR2 ,
    x_ATTRIBUTE16    IN VARCHAR2 ,
    x_ATTRIBUTE17    IN VARCHAR2 ,
    x_ATTRIBUTE18    IN VARCHAR2 ,
    x_ATTRIBUTE19    IN VARCHAR2 ,
    x_ATTRIBUTE20    IN VARCHAR2 ,
    x_ERROR_STRING   IN VARCHAR2 ,
    x_ERROR_ACCOUNT  IN VARCHAR2 ,
    x_location_cd    IN VARCHAR2 ,
    x_uoo_id         IN NUMBER   ,
    x_gl_date                IN     DATE,
    x_gl_posted_date         IN     DATE,
    x_posting_control_id     IN     NUMBER,
    x_unit_type_id           IN     NUMBER,
    x_unit_level             IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_invoice_id,
      x_line_number,
      x_invoice_lines_id,
      x_attribute2,
      x_chg_elements,
      x_amount,
      x_unit_attempt_status,
      x_eftsu,
      x_credit_points,
      x_attribute_category,
      x_attribute1,
      x_s_chg_method_type,
      x_description,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_rec_account_cd,
      x_rev_account_cd,
      x_rec_gl_ccid,
      x_rev_gl_ccid,
      x_org_unit_cd,
      x_posting_id,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_error_string,
      x_error_account,
      x_location_cd,
      x_uoo_id,
      x_gl_date,
      x_gl_posted_date,
      x_posting_control_id,
      x_unit_type_id,
      x_unit_level
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.invoice_lines_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.invoice_lines_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
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
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
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
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN out NOCOPY NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_org_id IN NUMBER,
       X_MODE in VARCHAR2 ,
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_error_string   IN VARCHAR2 ,
       x_error_account  IN VARCHAR2 ,
       x_location_cd    IN VARCHAR2 ,
       x_uoo_id         IN NUMBER ,
       x_gl_date                IN     DATE,
       x_gl_posted_date         IN     DATE,
       x_posting_control_id     IN     NUMBER,
       x_unit_type_id           IN     NUMBER,
       x_unit_level             IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_FI_INVLN_INT_ALL
             where                 INVOICE_LINES_ID= X_INVOICE_LINES_ID;

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
            IGS_FI_INVLN_INT_S.nextval
          INTO
            x_invoice_lines_id
          FROM
           dual;

   Before_DML(
               p_action=>'INSERT',
               x_rowid=>X_ROWID,
               x_invoice_id=>X_INVOICE_ID,
               x_line_number=>X_LINE_NUMBER,
               x_invoice_lines_id=>X_INVOICE_LINES_ID,
               x_attribute2=>X_ATTRIBUTE2,
               x_chg_elements=>X_CHG_ELEMENTS,
               x_amount=>X_AMOUNT,
               x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
               x_eftsu=>X_EFTSU,
               x_credit_points=>X_CREDIT_POINTS,
               x_attribute_category=>X_ATTRIBUTE_CATEGORY,
               x_attribute1=>X_ATTRIBUTE1,
               x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
               x_description=>X_DESCRIPTION,
               x_attribute3=>X_ATTRIBUTE3,
               x_attribute4=>X_ATTRIBUTE4,
               x_attribute5=>X_ATTRIBUTE5,
               x_attribute6=>X_ATTRIBUTE6,
               x_attribute7=>X_ATTRIBUTE7,
               x_attribute8=>X_ATTRIBUTE8,
               x_attribute9=>X_ATTRIBUTE9,
               x_attribute10=>X_ATTRIBUTE10,
               x_org_id=>igs_ge_gen_003.get_org_id,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_rec_account_cd=>X_REC_ACCOUNT_CD,
               x_rev_account_cd=>X_REV_ACCOUNT_Cd,
               x_rec_gl_ccid=>X_REC_GL_CCID,
               x_rev_gl_ccid=>X_REV_GL_CCID,
               x_org_unit_cd=>X_ORG_UNIT_CD,
               x_posting_id=>X_POSTING_ID,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_error_string => x_error_string,
               x_error_account => x_error_account,
               x_location_cd => x_location_cd,
               x_uoo_id  => x_uoo_id,
               x_gl_date               => x_gl_date,
               x_gl_posted_date        => x_gl_posted_date,
               x_posting_control_id    => x_posting_control_id,
               x_unit_type_id          => x_unit_type_id,
               x_unit_level            => x_unit_level
               );

     INSERT INTO IGS_FI_INVLN_INT_ALL (
                INVOICE_ID
                ,LINE_NUMBER
                ,INVOICE_LINES_ID
                ,ATTRIBUTE2
                ,CHG_ELEMENTS
                ,AMOUNT
                ,UNIT_ATTEMPT_STATUS
                ,EFTSU
                ,CREDIT_POINTS
                ,ATTRIBUTE_CATEGORY
                ,ATTRIBUTE1
                ,S_CHG_METHOD_TYPE
                ,DESCRIPTION
                ,ATTRIBUTE3
                ,ATTRIBUTE4
                ,ATTRIBUTE5
                ,ATTRIBUTE6
                ,ATTRIBUTE7
                ,ATTRIBUTE8
                ,ATTRIBUTE9
                ,ATTRIBUTE10
                ,ORG_ID
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,REC_ACCOUNT_CD
                ,REV_ACCOUNT_CD
                ,REC_GL_CCID
                ,REV_GL_CCID
                ,ORG_UNIT_CD
                ,POSTING_ID
                ,ATTRIBUTE11
                ,ATTRIBUTE12
                ,ATTRIBUTE13
                ,ATTRIBUTE14
                ,ATTRIBUTE15
                ,ATTRIBUTE16
                ,ATTRIBUTE17
                ,ATTRIBUTE18
                ,ATTRIBUTE19
                ,ATTRIBUTE20
                ,REQUEST_ID
                ,PROGRAM_ID
                ,PROGRAM_APPLICATION_ID
                ,PROGRAM_UPDATE_DATE
                ,error_string
                ,error_account
                ,LOCATION_CD
                ,UOO_ID
                ,GL_DATE
                ,GL_POSTED_DATE
                ,POSTING_CONTROL_ID
                ,UNIT_TYPE_ID
                ,UNIT_LEVEL
        ) VALUES
        (
                 NEW_REFERENCES.INVOICE_ID
                ,NEW_REFERENCES.LINE_NUMBER
                ,NEW_REFERENCES.INVOICE_LINES_ID
                ,NEW_REFERENCES.ATTRIBUTE2
                ,NEW_REFERENCES.CHG_ELEMENTS
                ,NEW_REFERENCES.AMOUNT
                ,NEW_REFERENCES.UNIT_ATTEMPT_STATUS
                ,NEW_REFERENCES.EFTSU
                ,NEW_REFERENCES.CREDIT_POINTS
                ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
                ,NEW_REFERENCES.ATTRIBUTE1
                ,NEW_REFERENCES.S_CHG_METHOD_TYPE
                ,NEW_REFERENCES.DESCRIPTION
                ,NEW_REFERENCES.ATTRIBUTE3
                ,NEW_REFERENCES.ATTRIBUTE4
                ,NEW_REFERENCES.ATTRIBUTE5
                ,NEW_REFERENCES.ATTRIBUTE6
                ,NEW_REFERENCES.ATTRIBUTE7
                ,NEW_REFERENCES.ATTRIBUTE8
                ,NEW_REFERENCES.ATTRIBUTE9
                ,NEW_REFERENCES.ATTRIBUTE10
                ,NEW_REFERENCES.ORG_ID
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,NEW_REFERENCES.REC_ACCOUNT_CD
                ,NEW_REFERENCES.REV_ACCOUNT_CD
                ,NEW_REFERENCES.REC_GL_CCID
                ,NEW_REFERENCES.REV_GL_CCID
                ,NEW_REFERENCES.ORG_UNIT_CD
                ,NEW_REFERENCES.POSTING_ID
                ,NEW_REFERENCES.ATTRIBUTE11
                ,NEW_REFERENCES.ATTRIBUTE12
                ,NEW_REFERENCES.ATTRIBUTE13
                ,NEW_REFERENCES.ATTRIBUTE14
                ,NEW_REFERENCES.ATTRIBUTE15
                ,NEW_REFERENCES.ATTRIBUTE16
                ,NEW_REFERENCES.ATTRIBUTE17
                ,NEW_REFERENCES.ATTRIBUTE18
                ,NEW_REFERENCES.ATTRIBUTE19
                ,NEW_REFERENCES.ATTRIBUTE20
                ,X_REQUEST_ID
                ,X_PROGRAM_ID
                ,X_PROGRAM_APPLICATION_ID
                ,X_PROGRAM_UPDATE_DATE
                ,new_references.error_string
                ,new_references.error_account
                ,NEW_REFERENCES.LOCATION_CD
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.GL_DATE
                ,NEW_REFERENCES.GL_POSTED_DATE
                ,NEW_REFERENCES.POSTING_CONTROL_ID
                ,NEW_REFERENCES.UNIT_TYPE_ID
                ,NEW_REFERENCES.UNIT_LEVEL
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


 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_error_string IN VARCHAR2 ,
       x_error_account IN VARCHAR2 ,
       x_location_cd    IN VARCHAR2 ,
       x_uoo_id         IN NUMBER ,
       x_gl_date             IN     DATE,
       x_gl_posted_date      IN     DATE,
       x_posting_control_id  IN     NUMBER,
       x_unit_type_id        IN     NUMBER,
       x_unit_level          IN     VARCHAR2
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select

      INVOICE_ID
,      LINE_NUMBER
,      ATTRIBUTE2
,      CHG_ELEMENTS
,      AMOUNT
,      UNIT_ATTEMPT_STATUS
,      EFTSU
,      CREDIT_POINTS
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      S_CHG_METHOD_TYPE
,      DESCRIPTION
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      REC_ACCOUNT_CD
,      REV_ACCOUNT_CD
,      REC_GL_CCID
,      REV_GL_CCID
,      ORG_UNIT_CD
,      POSTING_ID
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      error_string
,      error_account
,      LOCATION_CD
,      UOO_ID
,      gl_date
,      gl_posted_date
,      posting_control_id
,      unit_type_id
,      unit_level

    from IGS_FI_INVLN_INT_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
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
if (
  (  tlinfo.INVOICE_ID = X_INVOICE_ID)
  AND (tlinfo.LINE_NUMBER = X_LINE_NUMBER)
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
            OR ((tlinfo.ATTRIBUTE2 is null)
                AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.CHG_ELEMENTS = X_CHG_ELEMENTS)
            OR ((tlinfo.CHG_ELEMENTS is null)
                AND (X_CHG_ELEMENTS is null)))
  AND ((tlinfo.AMOUNT = X_AMOUNT)
            OR ((tlinfo.AMOUNT is null)
                AND (X_AMOUNT is null)))
  AND ((tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
            OR ((tlinfo.UNIT_ATTEMPT_STATUS is null)
                AND (X_UNIT_ATTEMPT_STATUS is null)))
  AND ((tlinfo.EFTSU = X_EFTSU)
            OR ((tlinfo.EFTSU is null)
                AND (X_EFTSU is null)))
  AND ((tlinfo.CREDIT_POINTS = X_CREDIT_POINTS)
            OR ((tlinfo.CREDIT_POINTS is null)
                AND (X_CREDIT_POINTS is null)))
  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
            OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
                AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
            OR ((tlinfo.ATTRIBUTE1 is null)
                AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
            OR ((tlinfo.S_CHG_METHOD_TYPE is null)
                AND (X_S_CHG_METHOD_TYPE is null)))
  AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
            OR ((tlinfo.DESCRIPTION is null)
                AND (X_DESCRIPTION is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
            OR ((tlinfo.ATTRIBUTE3 is null)
                AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
            OR ((tlinfo.ATTRIBUTE4 is null)
                AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
            OR ((tlinfo.ATTRIBUTE5 is null)
                AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
            OR ((tlinfo.ATTRIBUTE6 is null)
                AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
            OR ((tlinfo.ATTRIBUTE7 is null)
                AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
            OR ((tlinfo.ATTRIBUTE8 is null)
                AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
            OR ((tlinfo.ATTRIBUTE9 is null)
                AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
            OR ((tlinfo.ATTRIBUTE10 is null)
                AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.REC_ACCOUNT_CD = X_REC_ACCOUNT_CD)
            OR ((tlinfo.REC_ACCOUNT_CD is null)
                AND (X_REC_ACCOUNT_CD is null)))
  AND ((tlinfo.REV_ACCOUNT_CD = X_REV_ACCOUNT_CD)
            OR ((tlinfo.REV_ACCOUNT_CD is null)
                AND (X_REV_ACCOUNT_CD is null)))
  AND ((tlinfo.REC_GL_CCID = X_REC_GL_CCID)
            OR ((tlinfo.REC_GL_CCID is null)
                AND (X_REC_GL_CCID is null)))
  AND ((tlinfo.REV_GL_CCID = X_REV_GL_CCID)
            OR ((tlinfo.REV_GL_CCID is null)
                AND (X_REV_GL_CCID is null)))
  AND ((tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
            OR ((tlinfo.ORG_UNIT_CD is null)
                AND (X_ORG_UNIT_CD is null)))
  AND ((tlinfo.POSTING_ID = X_POSTING_ID)
            OR ((tlinfo.POSTING_ID is null)
                AND (X_POSTING_ID is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
            OR ((tlinfo.ATTRIBUTE11 is null)
                AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
            OR ((tlinfo.ATTRIBUTE12 is null)
                AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
            OR ((tlinfo.ATTRIBUTE13 is null)
                AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
            OR ((tlinfo.ATTRIBUTE14 is null)
                AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
            OR ((tlinfo.ATTRIBUTE15 is null)
                AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
            OR ((tlinfo.ATTRIBUTE16 is null)
                AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
            OR ((tlinfo.ATTRIBUTE17 is null)
                AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
            OR ((tlinfo.ATTRIBUTE18 is null)
                AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
            OR ((tlinfo.ATTRIBUTE19 is null)
                AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)
            OR ((tlinfo.ATTRIBUTE20 is null)
                AND (X_ATTRIBUTE20 is null)))
  AND ((tlinfo.error_string = x_error_string)
            OR ((tlinfo.error_string is null)
                AND (x_error_string is null)))
  AND ((tlinfo.error_account = x_error_account)
            OR ((tlinfo.error_account is null)
                AND (x_error_account is null)))
  AND ((tlinfo.LOCATION_CD = x_location_cd)
            OR ((tlinfo.LOCATION_CD is null)
                AND (x_location_cd is null)))
  AND ((tlinfo.UOO_ID = x_uoo_id)
            OR ((tlinfo.UOO_ID is null)
                AND (x_uoo_id is null)))
  AND ((TRUNC(tlinfo.gl_date) = TRUNC(x_gl_date)) OR ((tlinfo.gl_date IS NULL) AND (X_gl_date IS NULL)))
  AND ((tlinfo.gl_posted_date = x_gl_posted_date) OR ((tlinfo.gl_posted_date IS NULL) AND (X_gl_posted_date IS NULL)))
  AND ((tlinfo.posting_control_id = x_posting_control_id) OR ((tlinfo.posting_control_id IS NULL) AND (X_posting_control_id IS NULL)))
  AND ((tlinfo.unit_type_id = x_unit_type_id) OR ((tlinfo.unit_type_id IS NULL) AND (x_unit_type_id IS NULL)))
  AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL) AND (x_unit_level IS NULL)))
  ) THEN
    null;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
end LOCK_ROW;


 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       X_MODE in VARCHAR2 ,
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_error_string   IN VARCHAR2 ,
       x_error_account  IN VARCHAR2 ,
       x_location_cd    IN VARCHAR2 ,
       x_uoo_id         IN NUMBER ,
       x_gl_date                IN     DATE,
       x_gl_posted_date         IN     DATE,
       x_posting_control_id     IN     NUMBER,
       x_unit_type_id           IN     NUMBER,
       x_unit_level             IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  vchappid      23-Dec-2002        Bug#2720702,columns Error_String, Error_Account, location_cd, uoo_id
                                  are directly passed to the Update Statement instead of passing as
                                  new_references.error_string etc. Changed to pass as new_references.column_name
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
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
               p_action             =>'UPDATE',
               x_rowid              =>X_ROWID,
               x_invoice_id         =>X_INVOICE_ID,
               x_line_number        =>X_LINE_NUMBER,
               x_invoice_lines_id   =>X_INVOICE_LINES_ID,
               x_attribute2         =>X_ATTRIBUTE2,
               x_chg_elements       =>X_CHG_ELEMENTS,
               x_amount             =>X_AMOUNT,
               x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
               x_eftsu              =>X_EFTSU,
               x_credit_points      =>X_CREDIT_POINTS,
               x_attribute_category =>X_ATTRIBUTE_CATEGORY,
               x_attribute1         =>X_ATTRIBUTE1,
               x_s_chg_method_type  =>X_S_CHG_METHOD_TYPE,
               x_description        =>X_DESCRIPTION,
               x_attribute3         =>X_ATTRIBUTE3,
               x_attribute4         =>X_ATTRIBUTE4,
               x_attribute5         =>X_ATTRIBUTE5,
               x_attribute6         =>X_ATTRIBUTE6,
               x_attribute7         =>X_ATTRIBUTE7,
               x_attribute8         =>X_ATTRIBUTE8,
               x_attribute9         =>X_ATTRIBUTE9,
               x_attribute10        =>X_ATTRIBUTE10,
               x_creation_date      =>X_LAST_UPDATE_DATE,
               x_created_by         =>X_LAST_UPDATED_BY,
               x_last_update_date   =>X_LAST_UPDATE_DATE,
               x_last_updated_by    =>X_LAST_UPDATED_BY,
               x_last_update_login  =>X_LAST_UPDATE_LOGIN,
               x_rec_account_cd     =>X_REC_ACCOUNT_CD,
               x_rev_account_cd     =>X_REV_ACCOUNT_CD,
               x_rec_gl_ccid=>X_REC_GL_CCID,
               x_rev_gl_ccid=>X_REV_GL_CCID,
               x_org_unit_cd=>X_ORG_UNIT_CD,
               x_posting_id=>X_POSTING_ID,
               x_attribute11=>X_ATTRIBUTE11,
               x_attribute12=>X_ATTRIBUTE12,
               x_attribute13=>X_ATTRIBUTE13,
               x_attribute14=>X_ATTRIBUTE14,
               x_attribute15=>X_ATTRIBUTE15,
               x_attribute16=>X_ATTRIBUTE16,
               x_attribute17=>X_ATTRIBUTE17,
               x_attribute18=>X_ATTRIBUTE18,
               x_attribute19=>X_ATTRIBUTE19,
               x_attribute20=>X_ATTRIBUTE20,
               x_error_string =>x_error_string,
               x_error_account=>x_error_account,
               x_location_cd=>x_location_cd,
               x_uoo_id=>x_uoo_id,
               x_gl_date               => x_gl_date,
               x_gl_posted_date        => x_gl_posted_date,
               x_posting_control_id    => x_posting_control_id ,
               x_unit_type_id          => x_unit_type_id,
               x_unit_level            => x_unit_level
               );

   update IGS_FI_INVLN_INT_ALL set
      INVOICE_ID =  NEW_REFERENCES.INVOICE_ID,
      LINE_NUMBER =  NEW_REFERENCES.LINE_NUMBER,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      CHG_ELEMENTS =  NEW_REFERENCES.CHG_ELEMENTS,
      AMOUNT =  NEW_REFERENCES.AMOUNT,
      UNIT_ATTEMPT_STATUS =  NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
      EFTSU =  NEW_REFERENCES.EFTSU,
      CREDIT_POINTS =  NEW_REFERENCES.CREDIT_POINTS,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      S_CHG_METHOD_TYPE =  NEW_REFERENCES.S_CHG_METHOD_TYPE,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      REC_ACCOUNT_CD = NEW_REFERENCES.REC_ACCOUNT_CD,
      REV_ACCOUNT_CD = NEW_REFERENCES.REV_ACCOUNT_CD,
      REC_GL_CCID = NEW_REFERENCES.REC_GL_CCID,
      REV_GL_CCID = NEW_REFERENCES.REV_GL_CCID,
      ORG_UNIT_CD = NEW_REFERENCES.ORG_UNIT_CD,
      POSTING_ID = NEW_REFERENCES.POSTING_ID,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
      REQUEST_ID  =  X_REQUEST_ID,
      PROGRAM_ID  =  X_PROGRAM_ID,
      PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID,
      PROGRAM_UPDATE_DATE=X_PROGRAM_UPDATE_DATE,
      error_string = new_references.error_string,
      error_account = new_references.error_account,
      location_cd = new_references.location_cd,
      uoo_id = new_references.uoo_id,
      gl_date                           = new_references.gl_date,
      gl_posted_date                    = new_references.gl_posted_date,
      posting_control_id                = new_references.posting_control_id,
      unit_type_id                      = new_references.unit_type_id,
      unit_level                        = new_references.unit_level
      WHERE ROWID = X_ROWID;

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
       x_INVOICE_ID IN NUMBER,
       x_LINE_NUMBER IN NUMBER,
       x_INVOICE_LINES_ID IN out NOCOPY NUMBER,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ORG_ID IN NUMBER,
       X_MODE in VARCHAR2 ,
       x_REC_ACCOUNT_CD    IN VARCHAR2,
       x_REV_ACCOUNT_CD    IN VARCHAR2,
       x_REC_GL_CCID    IN NUMBER,
       x_REV_GL_CCID    IN NUMBER,
       x_ORG_UNIT_CD    IN VARCHAR2,
       x_POSTING_ID    IN NUMBER,
       x_ATTRIBUTE11    IN VARCHAR2,
       x_ATTRIBUTE12    IN VARCHAR2,
       x_ATTRIBUTE13    IN VARCHAR2,
       x_ATTRIBUTE14    IN VARCHAR2,
       x_ATTRIBUTE15    IN VARCHAR2,
       x_ATTRIBUTE16    IN VARCHAR2,
       x_ATTRIBUTE17    IN VARCHAR2,
       x_ATTRIBUTE18    IN VARCHAR2,
       x_ATTRIBUTE19    IN VARCHAR2,
       x_ATTRIBUTE20    IN VARCHAR2,
       x_error_string   IN VARCHAR2 ,
       x_error_account  IN VARCHAR2 ,
       x_location_cd    IN VARCHAR2 ,
       x_uoo_id         IN NUMBER   ,
       x_gl_date                IN     DATE,
       x_gl_posted_date         IN     DATE,
       x_posting_control_id     IN     NUMBER,
       x_unit_type_id           IN     NUMBER,
       x_unit_level             IN     VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svuppala      30-MAY-2005       Enh 3442712 - Added new columns Unit_Type_Id, Unit_Level
  smadathi     01-Nov-2002        Enh. Bug 2584986. Added new column GL_DATE,GL_POSTED_DATE,
                                  POSTING_CONTROL_ID. Also removed all DEFAULT CLAUSES
  msrinivi        17 Jul,2001    Added 2 new cols : error_string, error_account
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_FI_INVLN_INT_ALL
             where     INVOICE_LINES_ID= X_INVOICE_LINES_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_INVOICE_ID,
       X_LINE_NUMBER,
       X_INVOICE_LINES_ID,
       X_ATTRIBUTE2,
       X_CHG_ELEMENTS,
       X_AMOUNT,
       X_UNIT_ATTEMPT_STATUS,
       X_EFTSU,
       X_CREDIT_POINTS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_S_CHG_METHOD_TYPE,
       X_DESCRIPTION,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ORG_ID,
       X_MODE,
       X_REC_ACCOUNT_CD,
       X_REV_ACCOUNT_CD,
       X_REC_GL_CCID,
       X_REV_GL_CCID,
       X_ORG_UNIT_CD,
       X_POSTING_ID,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       x_error_string,
       x_error_account,
       X_LOCATION_CD,
       X_UOO_ID,
       x_gl_date,
       x_gl_posted_date,
       x_posting_control_id,
       x_unit_type_id,
       x_unit_level
       );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_INVOICE_ID,
       X_LINE_NUMBER,
       X_INVOICE_LINES_ID,
       X_ATTRIBUTE2,
       X_CHG_ELEMENTS,
       X_AMOUNT,
       X_UNIT_ATTEMPT_STATUS,
       X_EFTSU,
       X_CREDIT_POINTS,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_S_CHG_METHOD_TYPE,
       X_DESCRIPTION,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_MODE,
       X_REC_ACCOUNT_CD,
       X_REV_ACCOUNT_CD,
       X_REC_GL_CCID,
       X_REV_GL_CCID,
       X_ORG_UNIT_CD,
       X_POSTING_ID,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       x_error_string,
       x_error_account,
       X_LOCATION_CD,
       X_UOO_ID,
       x_gl_date,
       x_gl_posted_date,
       x_posting_control_id,
       x_unit_type_id,
       x_unit_level
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
 delete from IGS_FI_INVLN_INT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

END igs_fi_invln_int_pkg;

/
