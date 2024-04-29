--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_ITEMS_PKG" AS
/* $Header: IGSSI76B.pls 120.5 2005/10/05 16:48:38 appldev ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_fi_fee_as_items%RowType;
  new_references igs_fi_fee_as_items%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_ass_item_id IN NUMBER ,
    x_TRANSACTION_ID IN NUMBER ,
    x_person_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_RUL_SEQUENCE_NUMBER IN NUMBER ,
    x_s_chg_method_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_chg_elements IN NUMBER ,
    x_amount IN NUMBER ,
    x_fee_effective_dt IN DATE ,
    x_course_cd IN VARCHAR2 ,
    x_crs_version_number IN NUMBER ,
    x_course_attempt_status IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_unit_attempt_status IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_eftsu IN NUMBER ,
    x_credit_points IN NUMBER ,
    x_logical_delete_date IN DATE ,
    x_invoice_id  IN NUMBER ,
    X_ORG_UNIT_CD IN VARCHAR2,
    X_CLASS_STANDING IN VARCHAR2,
    X_RESIDENCY_STATUS_CD IN VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_uoo_id IN NUMBER,
    x_chg_rate IN VARCHAR,
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER,
    x_unit_type_id        IN NUMBER ,
    x_unit_class          IN VARCHAR2 ,
    x_unit_mode           IN VARCHAR2 ,
    x_unit_level          IN VARCHAR2,
    x_scope_rul_sequence_num IN NUMBER,
    x_elm_rng_order_name     IN VARCHAR2,
    x_max_chg_elements       IN NUMBER
  ) AS

  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_ITEMS
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
    new_references.fee_ass_item_id := x_fee_ass_item_id;
    new_references.transaction_id := x_transaction_id;
    new_references.person_id := x_person_id;
    new_references.status := x_status;
    new_references.fee_type := x_fee_type;
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.rul_sequence_number := x_rul_sequence_number;
    new_references.s_chg_method_type := x_s_chg_method_type;
    new_references.description := x_description;
    new_references.chg_elements := x_chg_elements;
    new_references.amount := x_amount;
    new_references.fee_effective_dt := x_fee_effective_dt;
    new_references.course_cd := x_course_cd;
    new_references.crs_version_number := x_crs_version_number;
    new_references.course_attempt_status := x_course_attempt_status;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.unit_attempt_status := x_unit_attempt_status;
    new_references.location_cd := x_location_cd;
    new_references.eftsu := x_eftsu;
    new_references.credit_points := x_credit_points;
    new_references.logical_delete_date := x_logical_delete_date;
    new_references.invoice_id := x_invoice_id;
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.class_standing := x_class_standing;
    new_references.residency_status_cd := x_residency_status_cd;
    new_references.uoo_id := x_uoo_id;
    new_references.chg_rate := x_chg_rate;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.unit_type_id      := x_unit_type_id;
    new_references.unit_class        := x_unit_class;
    new_references.unit_mode         := x_unit_mode;
    new_references.unit_level        := x_unit_level;
    new_references.scope_rul_sequence_num  :=   x_scope_rul_sequence_num;
    new_references.elm_rng_order_name      :=   x_elm_rng_order_name;
    new_references.max_chg_elements        :=   x_max_chg_elements;


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

  PROCEDURE Check_Constraints (
                 Column_Name IN VARCHAR2  ,
                 Column_Value IN VARCHAR2  ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  bannamal       08-Jul-2005     Enh#3392088 Campus Privilege Fee.
                                 Added 'I' while checking the status.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'STATUS'  THEN
        new_references.status := column_value;
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'STATUS' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.status IN ('O', 'E', 'I'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
                IF Get_Uk_For_Validation (
                 new_references.transaction_id
                ,new_references.person_id
                ,new_references.location_cd
                ,new_references.course_cd
                ,new_references.crs_version_number
                ,new_references.fee_cal_type
                ,new_references.fee_cat
                ,new_references.fee_ci_sequence_number
                ,new_references.fee_type
                ,new_references.uoo_id,
                new_references.org_unit_cd
                ) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
                        app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;

PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        18-Sep-2003     Enh 3108052 - Unit Sets in Rate Table build
                                  Added call to igs_en_unit_set_pkg.get_pk_for_validation
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (( (old_references.s_chg_method_type = new_references.s_chg_method_type)) OR
        ((new_references.s_chg_method_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation('CHG_METHOD',
        new_references.s_chg_method_type) THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

    IF ((old_references.person_id = new_references.person_id) AND
             (old_references.transaction_id = new_references.transaction_id)) THEN
          NULL;
        ELSE
          IF NOT IGS_FI_FEE_AS_PKG.Get_PK_For_Validation (
            new_references.person_id,
            new_references.transaction_id) THEN
                                  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
        END IF;
    END IF;

    IF ( ((old_references.unit_set_cd = new_references.unit_set_cd)
           AND (old_references.us_version_number = new_references.us_version_number))
         OR ((new_references.unit_set_cd IS NULL) OR (new_references.us_version_number IS NULL))
       ) THEN
          NULL;
    ELSE
         IF NOT igs_en_unit_set_pkg.Get_PK_For_Validation (
                           new_references.unit_set_cd,
                           new_references.us_version_number) THEN
               fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
               igs_ge_msg_stack.add;
               app_exception.raise_exception;
         END IF;
    END IF;

  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_fee_ass_item_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_fee_as_items
      WHERE    fee_ass_item_id = x_fee_ass_item_id
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


  ---added by syam
  PROCEDURE GET_FK_IGS_FI_FEE_AS (
      x_person_id IN NUMBER,
      x_transaction_id IN NUMBER
      ) AS

      CURSOR cur_rowid IS
        SELECT   rowid
        FROM     IGS_FI_FEE_AS_ITEMS
        WHERE    person_id = x_person_id
        AND      transaction_id = x_transaction_id;

      lv_rowid cur_rowid%RowType;

    BEGIN

      Open cur_rowid;
      Fetch cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
        Fnd_Message.Set_Name ('IGS', 'IGS_FI_AITM_FAS_FK');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
        Return;
      END IF;
      Close cur_rowid;

  END GET_FK_IGS_FI_FEE_AS;

  --added by syam

  FUNCTION Get_UK_For_Validation (
    x_TRANSACTION_ID IN NUMBER,
    x_person_id IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_crs_version_number IN NUMBER,
    x_fee_cal_type IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_uoo_id IN NUMBER,
    x_org_unit_cd  IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who       When            What
  pathipat  05-Oct-2005     Bug 4615626 - Unhandled exception when org unit is changed
                            Added ORG_UNIT_CD as part of UK
  (reverse chronological order - newest change first)
  ***************************************************************/
--to take care of unique keys which are nullable -syam
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_fee_as_items
      WHERE    person_id = x_person_id
      AND      transaction_id = x_TRANSACTION_ID
      AND ((LOCATION_CD = X_LOCATION_CD)  OR ((LOCATION_CD is null) AND (X_LOCATION_CD is null)))
      AND ((COURSE_CD = X_COURSE_CD) OR ((COURSE_CD is null) AND (X_COURSE_CD is null)))
      AND ((CRS_VERSION_NUMBER = X_CRS_VERSION_NUMBER) OR ((CRS_VERSION_NUMBER is null) AND (X_CRS_VERSION_NUMBER is null)))
      AND      fee_cal_type = x_fee_cal_type
      AND ((FEE_CAT = X_FEE_CAT) OR ((FEE_CAT is null) AND (X_FEE_CAT is null)))
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type    and      ((l_rowid is null) or (rowid <> l_rowid))
      AND ((UOO_ID = X_UOO_ID) OR ((UOO_ID is null) AND (X_UOO_ID is null)))
      AND ((org_unit_cd = x_org_unit_cd) OR ((org_unit_cd IS NULL) AND (org_unit_cd IS NULL)));

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


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_fee_ass_item_id IN NUMBER ,
    x_TRANSACTION_ID IN NUMBER ,
    x_person_id IN NUMBER ,
    x_status IN VARCHAR2 ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_RUL_SEQUENCE_NUMBER IN NUMBER ,
    x_s_chg_method_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_chg_elements IN NUMBER ,
    x_amount IN NUMBER ,
    x_fee_effective_dt IN DATE ,
    x_course_cd IN VARCHAR2 ,
    x_crs_version_number IN NUMBER ,
    x_course_attempt_status IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_unit_attempt_status IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_eftsu IN NUMBER ,
    x_credit_points IN NUMBER ,
    x_logical_delete_date IN DATE ,
    x_invoice_id  IN NUMBER,
    X_ORG_UNIT_CD IN VARCHAR2,
    X_CLASS_STANDING IN VARCHAR2,
    X_RESIDENCY_STATUS_CD IN VARCHAR2,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_uoo_id IN NUMBER,
    X_CHG_RATE IN VARCHAR2,
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER,
    x_unit_type_id        IN NUMBER,
    x_unit_class          IN VARCHAR2,
    x_unit_mode           IN VARCHAR2,
    x_unit_level          IN VARCHAR2,
    x_scope_rul_sequence_num IN NUMBER,
    x_elm_rng_order_name     IN VARCHAR2,
    x_max_chg_elements       IN NUMBER
  ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_ass_item_id,
      x_transaction_id,
      x_person_id,
      x_status,
      x_fee_type,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_rul_sequence_number,
      x_s_chg_method_type,
      x_description,
      x_chg_elements,
      x_amount,
      x_fee_effective_dt,
      x_course_cd,
      x_crs_version_number,
      x_course_attempt_status,
      x_attendance_mode,
      x_attendance_type,
      x_unit_attempt_status,
      x_location_cd,
      x_eftsu,
      x_credit_points,
      x_logical_delete_date,
      x_invoice_id,
      X_ORG_UNIT_CD,
      X_CLASS_STANDING,
      X_RESIDENCY_STATUS_CD,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_uoo_id,
      x_chg_rate,
      x_unit_set_cd,
      x_us_version_number,
      x_unit_type_id,
      x_unit_class,
      x_unit_mode,
      x_unit_level,
      x_scope_rul_sequence_num,
      x_elm_rng_order_name,
      x_max_chg_elements
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.fee_ass_item_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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

      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.fee_ass_item_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
  Created By :syam.krishnan
  Date Created By :6-jul-2000
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
       x_FEE_ASS_ITEM_ID IN OUT NOCOPY NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER ,
       X_ORG_UNIT_CD IN VARCHAR2,
       X_CLASS_STANDING IN VARCHAR2,
       X_RESIDENCY_STATUS_CD IN VARCHAR2,
       X_MODE in VARCHAR2,
       x_uoo_id IN NUMBER ,
       x_chg_rate IN VARCHAR2 ,
       x_unit_set_cd         IN VARCHAR2,
       x_us_version_number   IN NUMBER,
       x_unit_type_id        IN NUMBER,
       x_unit_class          IN VARCHAR2,
       x_unit_mode           IN VARCHAR2,
       x_unit_level          IN VARCHAR2,
       x_scope_rul_sequence_num IN NUMBER,
       x_elm_rng_order_name     IN VARCHAR2,
       x_max_chg_elements       IN NUMBER
  ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_FI_FEE_AS_ITEMS
             where                 FEE_ASS_ITEM_ID= X_FEE_ASS_ITEM_ID;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
    ----------------------------------
    SELECT igs_fi_fee_as_items_s.nextval
    INTO   X_FEE_ASS_ITEM_ID
    FROM   dual;
--------------------------------------

   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_fee_ass_item_id=>X_FEE_ASS_ITEM_ID,
               x_transaction_id=>X_TRANSACTION_ID,
               x_person_id=>X_PERSON_ID,
               x_status=>X_STATUS,
               x_fee_type=>X_FEE_TYPE,
               x_fee_cat=>X_FEE_CAT,
               x_fee_cal_type=>X_FEE_CAL_TYPE,
               x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
               x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
               x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
               x_description=>X_DESCRIPTION,
               x_chg_elements=>X_CHG_ELEMENTS,
               x_amount=>X_AMOUNT,
               x_fee_effective_dt=>X_FEE_EFFECTIVE_DT,
               x_course_cd=>X_COURSE_CD,
               x_crs_version_number=>X_CRS_VERSION_NUMBER,
               x_course_attempt_status=>X_COURSE_ATTEMPT_STATUS,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
               x_location_cd=>X_LOCATION_CD,
               x_eftsu=>X_EFTSU,
               x_credit_points=>X_CREDIT_POINTS,
               x_logical_delete_date=>X_LOGICAL_DELETE_DATE,
               x_invoice_id=>X_INVOICE_ID,
               X_ORG_UNIT_CD => x_org_unit_cd,
               X_CLASS_STANDING => x_class_standing,
               X_RESIDENCY_STATUS_CD => x_residency_status_cd,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_uoo_id => x_uoo_id,
               x_chg_rate => x_chg_rate,
               x_unit_set_cd        => x_unit_set_cd,
               x_us_version_number  => x_us_version_number,
               x_unit_type_id       => x_unit_type_id,
               x_unit_class         => x_unit_class,
               x_unit_mode          => x_unit_mode,
               x_unit_level         => x_unit_level,
               x_scope_rul_sequence_num =>   x_scope_rul_sequence_num,
               x_elm_rng_order_name     =>   x_elm_rng_order_name,
               x_max_chg_elements       =>   x_max_chg_elements
               );

     insert into IGS_FI_FEE_AS_ITEMS (
                 FEE_ASS_ITEM_ID
                ,TRANSACTION_ID
                ,PERSON_ID
                ,STATUS
                ,FEE_TYPE
                ,FEE_CAT
                ,FEE_CAL_TYPE
                ,FEE_CI_SEQUENCE_NUMBER
                ,RUL_SEQUENCE_NUMBER
                ,S_CHG_METHOD_TYPE
                ,DESCRIPTION
                ,CHG_ELEMENTS
                ,AMOUNT
                ,FEE_EFFECTIVE_DT
                ,COURSE_CD
                ,CRS_VERSION_NUMBER
                ,COURSE_ATTEMPT_STATUS
                ,ATTENDANCE_MODE
                ,ATTENDANCE_TYPE
                ,UNIT_ATTEMPT_STATUS
                ,LOCATION_CD
                ,EFTSU
                ,CREDIT_POINTS
                ,LOGICAL_DELETE_DATE
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,INVOICE_ID
                ,ORG_UNIT_CD
                ,CLASS_STANDING
                ,RESIDENCY_STATUS_CD
                ,uoo_id
                ,chg_rate,
                unit_set_cd,
                us_version_number,
                unit_type_id,
                unit_class,
                unit_mode,
                unit_level,
                scope_rul_sequence_num,
                elm_rng_order_name,
                max_chg_elements
                )
       values  (
                NEW_REFERENCES.FEE_ASS_ITEM_ID
                ,NEW_REFERENCES.TRANSACTION_ID
                ,NEW_REFERENCES.PERSON_ID
                ,NEW_REFERENCES.STATUS
                ,NEW_REFERENCES.FEE_TYPE
                ,NEW_REFERENCES.FEE_CAT
                ,NEW_REFERENCES.FEE_CAL_TYPE
                ,NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER
                ,NEW_REFERENCES.RUL_SEQUENCE_NUMBER
                ,NEW_REFERENCES.S_CHG_METHOD_TYPE
                ,NEW_REFERENCES.DESCRIPTION
                ,NEW_REFERENCES.CHG_ELEMENTS
                ,NEW_REFERENCES.AMOUNT
                ,NEW_REFERENCES.FEE_EFFECTIVE_DT
                ,NEW_REFERENCES.COURSE_CD
                ,NEW_REFERENCES.CRS_VERSION_NUMBER
                ,NEW_REFERENCES.COURSE_ATTEMPT_STATUS
                ,NEW_REFERENCES.ATTENDANCE_MODE
                ,NEW_REFERENCES.ATTENDANCE_TYPE
                ,NEW_REFERENCES.UNIT_ATTEMPT_STATUS
                ,NEW_REFERENCES.LOCATION_CD
                ,NEW_REFERENCES.EFTSU
                ,NEW_REFERENCES.CREDIT_POINTS
                ,NEW_REFERENCES.LOGICAL_DELETE_DATE
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,NEW_REFERENCES.INVOICE_ID
                ,NEW_REFERENCES.ORG_UNIT_CD
                ,NEW_REFERENCES.CLASS_STANDING
                ,NEW_REFERENCES.RESIDENCY_STATUS_CD
                ,NEW_REFERENCES.UOO_ID
                ,NEW_REFERENCES.CHG_RATE,
                new_references.unit_set_cd,
                new_references.us_version_number,
                new_references.unit_type_id,
                new_references.unit_class,
                new_references.unit_mode,
                new_references.unit_level,
                new_references.scope_rul_sequence_num,
                new_references.elm_rng_order_name,
                new_references.max_chg_elements
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
       x_FEE_ASS_ITEM_ID IN NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER,
       X_ORG_UNIT_CD IN VARCHAR2,
       X_CLASS_STANDING IN VARCHAR2,
       X_RESIDENCY_STATUS_CD IN VARCHAR2,
       X_UOO_ID IN NUMBER,
       x_chg_rate IN VARCHAR2,
       x_unit_set_cd         IN VARCHAR2,
       x_us_version_number   IN NUMBER,
       x_unit_type_id        IN NUMBER,
       x_unit_class          IN VARCHAR2,
       x_unit_mode           IN VARCHAR2,
       x_unit_level          IN VARCHAR2,
       x_scope_rul_sequence_num IN NUMBER,
       x_elm_rng_order_name     IN VARCHAR2,
       x_max_chg_elements       IN NUMBER
 )AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      transaction_id ,
      person_id,
      status,
      fee_type,
      fee_cat,
      fee_cal_type,
      fee_ci_sequence_number,
      rul_sequence_number,
      s_chg_method_type,
      description,
      chg_elements,
      amount,
      fee_effective_dt,
      course_cd,
      crs_version_number,
      course_attempt_status,
      attendance_mode,
      attendance_type,
      unit_attempt_status,
      location_cd,
      eftsu,
      credit_points,
      logical_delete_date,
      invoice_id,
      org_unit_cd,
      class_standing,
      residency_status_cd,
      uoo_id,
      chg_rate,
      unit_set_cd,
      us_version_number,
      unit_type_id,
      unit_class,
      unit_mode,
      unit_level,
      scope_rul_sequence_num,
      elm_rng_order_name,
      max_chg_elements
    FROM igs_fi_fee_as_items
    WHERE rowid = x_rowid
    FOR UPDATE NOWAIT;
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
if (  (tlinfo.TRANSACTION_ID = X_TRANSACTION_ID)
  AND (tlinfo.PERSON_ID = X_PERSON_ID)
  AND (tlinfo.STATUS = X_STATUS)
  AND (tlinfo.FEE_TYPE = X_FEE_TYPE)
  AND ((tlinfo.FEE_CAT = X_FEE_CAT)
            OR ((tlinfo.FEE_CAT is null)
                AND (X_FEE_CAT is null)))
  AND (tlinfo.FEE_CAL_TYPE = X_FEE_CAL_TYPE)
  AND (tlinfo.FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER)
  AND ((tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
            OR ((tlinfo.RUL_SEQUENCE_NUMBER is null)
                AND (X_RUL_SEQUENCE_NUMBER is null)))
  AND (tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
  AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
            OR ((tlinfo.DESCRIPTION is null)
                AND (X_DESCRIPTION is null)))
  AND ((tlinfo.CHG_ELEMENTS = X_CHG_ELEMENTS)
            OR ((tlinfo.CHG_ELEMENTS is null)
                AND (X_CHG_ELEMENTS is null)))
  AND ((tlinfo.AMOUNT = X_AMOUNT)
            OR ((tlinfo.AMOUNT is null)
                AND (X_AMOUNT is null)))
  AND ((tlinfo.FEE_EFFECTIVE_DT = X_FEE_EFFECTIVE_DT)
            OR ((tlinfo.FEE_EFFECTIVE_DT is null)
                AND (X_FEE_EFFECTIVE_DT is null)))
  AND ((tlinfo.COURSE_CD = X_COURSE_CD)
            OR ((tlinfo.COURSE_CD is null)
                AND (X_COURSE_CD is null)))
  AND ((tlinfo.CRS_VERSION_NUMBER = X_CRS_VERSION_NUMBER)
            OR ((tlinfo.CRS_VERSION_NUMBER is null)
                AND (X_CRS_VERSION_NUMBER is null)))
  AND ((tlinfo.COURSE_ATTEMPT_STATUS = X_COURSE_ATTEMPT_STATUS)
            OR ((tlinfo.COURSE_ATTEMPT_STATUS is null)
                AND (X_COURSE_ATTEMPT_STATUS is null)))
  AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
            OR ((tlinfo.ATTENDANCE_MODE is null)
                AND (X_ATTENDANCE_MODE is null)))
  AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
            OR ((tlinfo.ATTENDANCE_TYPE is null)
                AND (X_ATTENDANCE_TYPE is null)))
  AND ((tlinfo.UNIT_ATTEMPT_STATUS = X_UNIT_ATTEMPT_STATUS)
            OR ((tlinfo.UNIT_ATTEMPT_STATUS is null)
                AND (X_UNIT_ATTEMPT_STATUS is null)))
  AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
            OR ((tlinfo.LOCATION_CD is null)
                AND (X_LOCATION_CD is null)))
  AND ((tlinfo.EFTSU = X_EFTSU)
            OR ((tlinfo.EFTSU is null)
                AND (X_EFTSU is null)))
  AND ((tlinfo.CREDIT_POINTS = X_CREDIT_POINTS)
            OR ((tlinfo.CREDIT_POINTS is null)
                AND (X_CREDIT_POINTS is null)))
  AND ((tlinfo.LOGICAL_DELETE_DATE = X_LOGICAL_DELETE_DATE)
            OR ((tlinfo.LOGICAL_DELETE_DATE is null)
                AND (X_LOGICAL_DELETE_DATE is null)))
  AND ((tlinfo.INVOICE_ID = X_INVOICE_ID)
            OR ((tlinfo.INVOICE_ID is null)
                AND (X_INVOICE_ID is null)))
  AND ((tlinfo.ORG_UNIT_CD = X_ORG_UNIT_CD)
            OR ((tlinfo.ORG_UNIT_CD is null)
                AND (X_ORG_UNIT_CD is null)))
  AND ((tlinfo.CLASS_STANDING = X_CLASS_STANDING)
            OR ((tlinfo.CLASS_STANDING is null)
                AND (X_CLASS_STANDING is null)))
  AND ((tlinfo.RESIDENCY_STATUS_CD = X_RESIDENCY_STATUS_CD)
            OR ((tlinfo.RESIDENCY_STATUS_CD is null)
                AND (X_RESIDENCY_STATUS_CD is null)))
  AND ((tlinfo.UOO_ID = X_UOO_ID)
            OR ((tlinfo.UOO_ID is null)
                AND (X_UOO_ID is null)))
 AND ((tlinfo.CHG_RATE = X_CHG_RATE)
            OR ((tlinfo.CHG_RATE is null)
                AND (X_CHG_RATE is null)))
 AND ((tlinfo.unit_set_cd = x_unit_set_cd) OR ((tlinfo.unit_set_cd IS NULL) AND (x_unit_set_cd IS NULL)))
 AND ((tlinfo.us_version_number = x_us_version_number) OR ((tlinfo.us_version_number IS NULL) AND (x_us_version_number IS NULL)))
 AND ((tlinfo.unit_type_id = x_unit_type_id) OR ((tlinfo.unit_type_id IS NULL) AND (x_unit_type_id IS NULL)))
 AND ((tlinfo.unit_class = x_unit_class) OR ((tlinfo.unit_class IS NULL) AND (x_unit_class IS NULL)))
 AND ((tlinfo.unit_mode = x_unit_mode) OR ((tlinfo.unit_mode IS NULL) AND (x_unit_mode IS NULL)))
 AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL) AND (x_unit_level IS NULL)))
 AND ((tlinfo.scope_rul_sequence_num = x_scope_rul_sequence_num) OR ((tlinfo.scope_rul_sequence_num IS NULL) AND (x_scope_rul_sequence_num IS NULL)))
 AND ((tlinfo.elm_rng_order_name = x_elm_rng_order_name) OR ((tlinfo.elm_rng_order_name IS NULL) AND (x_elm_rng_order_name IS NULL)))
 AND ((tlinfo.max_chg_elements = x_max_chg_elements) OR ((tlinfo.max_chg_elements IS NULL) AND (x_max_chg_elements IS NULL)))
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
       x_FEE_ASS_ITEM_ID IN NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER,
       X_ORG_UNIT_CD IN VARCHAR2,
       X_CLASS_STANDING IN VARCHAR2,
       X_RESIDENCY_STATUS_CD IN VARCHAR2,
      X_MODE in VARCHAR2 ,
      X_UOO_ID IN NUMBER,
      X_CHG_RATE IN VARCHAR2,
       x_unit_set_cd         IN VARCHAR2,
       x_us_version_number   IN NUMBER,
       x_unit_type_id        IN NUMBER,
       x_unit_class          IN VARCHAR2,
       x_unit_mode           IN VARCHAR2,
       x_unit_level          IN VARCHAR2,
       x_scope_rul_sequence_num IN NUMBER,
       x_elm_rng_order_name     IN VARCHAR2,
       x_max_chg_elements       IN NUMBER
  ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
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
         elsif (X_MODE = 'R') then
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
               x_fee_ass_item_id=>X_FEE_ASS_ITEM_ID,
               x_transaction_id=>X_TRANSACTION_ID,
               x_person_id=>X_PERSON_ID,
               x_status=>X_STATUS,
               x_fee_type=>X_FEE_TYPE,
               x_fee_cat=>X_FEE_CAT,
               x_fee_cal_type=>X_FEE_CAL_TYPE,
               x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
               x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
               x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
               x_description=>X_DESCRIPTION,
               x_chg_elements=>X_CHG_ELEMENTS,
               x_amount=>X_AMOUNT,
               x_fee_effective_dt=>X_FEE_EFFECTIVE_DT,
               x_course_cd=>X_COURSE_CD,
               x_crs_version_number=>X_CRS_VERSION_NUMBER,
               x_course_attempt_status=>X_COURSE_ATTEMPT_STATUS,
               x_attendance_mode=>X_ATTENDANCE_MODE,
               x_attendance_type=>X_ATTENDANCE_TYPE,
               x_unit_attempt_status=>X_UNIT_ATTEMPT_STATUS,
               x_location_cd=>X_LOCATION_CD,
               x_eftsu=>X_EFTSU,
               x_credit_points=>X_CREDIT_POINTS,
               x_logical_delete_date=>X_LOGICAL_DELETE_DATE,
               x_invoice_id=>x_invoice_id,
               x_org_unit_cd =>x_org_unit_cd,
               x_class_standing =>x_class_standing,
               x_residency_status_cd =>x_residency_status_cd,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_uoo_id => x_uoo_id,
               x_chg_rate =>x_chg_rate,
               x_unit_set_cd         => x_unit_set_cd,
               x_us_version_number   => x_us_version_number,
               x_unit_type_id        => x_unit_type_id,
               x_unit_class          => x_unit_class,
               x_unit_mode           => x_unit_mode,
               x_unit_level          => x_unit_level,
               x_scope_rul_sequence_num => x_scope_rul_sequence_num,
               x_elm_rng_order_name     => x_elm_rng_order_name,
               x_max_chg_elements       => x_max_chg_elements
               );

   update IGS_FI_FEE_AS_ITEMS set
      TRANSACTION_ID =  NEW_REFERENCES.TRANSACTION_ID,
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      STATUS =  NEW_REFERENCES.STATUS,
      FEE_TYPE =  NEW_REFERENCES.FEE_TYPE,
      FEE_CAT =  NEW_REFERENCES.FEE_CAT,
      FEE_CAL_TYPE =  NEW_REFERENCES.FEE_CAL_TYPE,
      FEE_CI_SEQUENCE_NUMBER =  NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
      RUL_SEQUENCE_NUMBER =  NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
      S_CHG_METHOD_TYPE =  NEW_REFERENCES.S_CHG_METHOD_TYPE,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      CHG_ELEMENTS =  NEW_REFERENCES.CHG_ELEMENTS,
      AMOUNT =  NEW_REFERENCES.AMOUNT,
      FEE_EFFECTIVE_DT =  NEW_REFERENCES.FEE_EFFECTIVE_DT,
      COURSE_CD =  NEW_REFERENCES.COURSE_CD,
      CRS_VERSION_NUMBER =  NEW_REFERENCES.CRS_VERSION_NUMBER,
      COURSE_ATTEMPT_STATUS =  NEW_REFERENCES.COURSE_ATTEMPT_STATUS,
      ATTENDANCE_MODE =  NEW_REFERENCES.ATTENDANCE_MODE,
      ATTENDANCE_TYPE =  NEW_REFERENCES.ATTENDANCE_TYPE,
      UNIT_ATTEMPT_STATUS =  NEW_REFERENCES.UNIT_ATTEMPT_STATUS,
      LOCATION_CD =  NEW_REFERENCES.LOCATION_CD,
      EFTSU =  NEW_REFERENCES.EFTSU,
      CREDIT_POINTS =  NEW_REFERENCES.CREDIT_POINTS,
      LOGICAL_DELETE_DATE =  NEW_REFERENCES.LOGICAL_DELETE_DATE,
      INVOICE_ID = NEW_REFERENCES.INVOICE_ID,
      ORG_UNIT_CD = NEW_REFERENCES.ORG_UNIT_CD,
      CLASS_STANDING = NEW_REFERENCES.CLASS_STANDING,
      RESIDENCY_STATUS_CD = NEW_REFERENCES.RESIDENCY_STATUS_CD,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      UOO_ID = NEW_REFERENCES.UOO_ID,
      CHG_RATE = NEW_REFERENCES.CHG_RATE,
      unit_set_cd = new_references.unit_set_cd,
      us_version_number = new_references.us_version_number,
      unit_type_id = new_references.unit_type_id,
      unit_class   = new_references.unit_class,
      unit_mode    = new_references.unit_mode,
      unit_level   = new_references.unit_level,
      scope_rul_sequence_num = new_references.scope_rul_sequence_num,
      elm_rng_order_name     = new_references.elm_rng_order_name,
      max_chg_elements       = new_references.max_chg_elements
    where ROWID = X_ROWID;
        if (sql%notfound) then
                raise no_data_found;
        end if;

 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
END update_row;


 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_FEE_ASS_ITEM_ID IN OUT NOCOPY NUMBER,
       x_TRANSACTION_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_STATUS IN VARCHAR2,
       x_FEE_TYPE IN VARCHAR2,
       x_FEE_CAT IN VARCHAR2,
       x_FEE_CAL_TYPE IN VARCHAR2,
       x_FEE_CI_SEQUENCE_NUMBER IN NUMBER,
       x_RUL_SEQUENCE_NUMBER IN NUMBER,
       x_S_CHG_METHOD_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CHG_ELEMENTS IN NUMBER,
       x_AMOUNT IN NUMBER,
       x_FEE_EFFECTIVE_DT IN DATE,
       x_COURSE_CD IN VARCHAR2,
       x_CRS_VERSION_NUMBER IN NUMBER,
       x_COURSE_ATTEMPT_STATUS IN VARCHAR2,
       x_ATTENDANCE_MODE IN VARCHAR2,
       x_ATTENDANCE_TYPE IN VARCHAR2,
       x_UNIT_ATTEMPT_STATUS IN VARCHAR2,
       x_LOCATION_CD IN VARCHAR2,
       x_EFTSU IN NUMBER,
       x_CREDIT_POINTS IN NUMBER,
       x_LOGICAL_DELETE_DATE IN DATE,
       X_INVOICE_ID IN NUMBER,
       X_ORG_UNIT_CD IN VARCHAR2,
       X_CLASS_STANDING IN VARCHAR2,
       X_RESIDENCY_STATUS_CD IN VARCHAR2,
       X_MODE in VARCHAR2,
       X_UOO_ID IN NUMBER,
       X_CHG_RATE in VARCHAR2 ,
       x_unit_set_cd         IN VARCHAR2,
       x_us_version_number   IN NUMBER,
       x_unit_type_id        IN NUMBER,
       x_unit_class          IN VARCHAR2,
       x_unit_mode           IN VARCHAR2,
       x_unit_level          IN VARCHAR2,
       x_scope_rul_sequence_num IN NUMBER,
       x_elm_rng_order_name     IN VARCHAR2,
       x_max_chg_elements       IN NUMBER
  ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :06-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
                                  Added 2 new columns unit_set_cd and us_version_number
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR c1 IS
    SELECT rowid FROM igs_fi_fee_as_items
    WHERE  fee_ass_item_id = x_fee_ass_item_id;
  BEGIN
        OPEN c1;
        FETCH c1 INTO x_rowid;
        IF (C1%NOTFOUND) THEN
           CLOSE c1;
           insert_row (
               x_rowid,
               x_fee_ass_item_id,
               x_transaction_id,
               x_person_id,
               x_status,
               x_fee_type,
               x_fee_cat,
               x_fee_cal_type,
               x_fee_ci_sequence_number,
               x_rul_sequence_number,
               x_s_chg_method_type,
               x_description,
               x_chg_elements,
               x_amount,
               x_fee_effective_dt,
               x_course_cd,
               x_crs_version_number,
               x_course_attempt_status,
               x_attendance_mode,
               x_attendance_type,
               x_unit_attempt_status,
               x_location_cd,
               x_eftsu,
               x_credit_points,
               x_logical_delete_date,
               x_invoice_id,
               x_org_unit_cd,
               x_class_standing,
               x_residency_status_cd,
               x_mode,
               x_uoo_id,
               x_chg_rate,
               x_unit_set_cd,
               x_us_version_number,
               x_unit_type_id,
               x_unit_class,
               x_unit_mode,
               x_unit_level,
               x_scope_rul_sequence_num,
               x_elm_rng_order_name,
               x_max_chg_elements
               );
             RETURN;
        END IF;
        CLOSE c1;

      update_row (
               x_rowid,
               x_fee_ass_item_id,
               x_transaction_id,
               x_person_id,
               x_status,
               x_fee_type,
               x_fee_cat,
               x_fee_cal_type,
               x_fee_ci_sequence_number,
               x_rul_sequence_number,
               x_s_chg_method_type,
               x_description,
               x_chg_elements,
               x_amount,
               x_fee_effective_dt,
               x_course_cd,
               x_crs_version_number,
               x_course_attempt_status,
               x_attendance_mode,
               x_attendance_type,
               x_unit_attempt_status,
               x_location_cd,
               x_eftsu,
               x_credit_points,
               x_logical_delete_date,
               x_invoice_id,
               x_org_unit_cd,
               x_class_standing,
               x_residency_status_cd,
               x_mode,
               x_uoo_id,
               x_chg_rate ,
               x_unit_set_cd,
               x_us_version_number,
               x_unit_type_id,
               x_unit_class,
               x_unit_mode,
               x_unit_level,
               x_scope_rul_sequence_num,
               x_elm_rng_order_name,
               x_max_chg_elements
               );
  END add_row;

PROCEDURE delete_row ( x_rowid IN VARCHAR2 ) AS
  /*************************************************************
  Created By :syam.krishnan
  Date Created By :6-jul-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN
   before_dml (
               p_action => 'DELETE',
               x_rowid => x_rowid
              );

   DELETE FROM igs_fi_fee_as_items
   WHERE rowid = x_rowid;

   IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
   END IF;

   after_dml (
              p_action => 'DELETE',
              x_rowid => x_rowid
            );
END delete_row;

PROCEDURE get_fk_igs_en_unit_set_all (
           x_unit_set_cd       IN VARCHAR2,
           x_us_version_number IN NUMBER ) AS
  /*************************************************************
  Created By : Priya Athipatla
  Date Created By : 18-Sep-2003
  Purpose : FK relation with igs_en_unit_set_all
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR cur_rowid IS
    SELECT   rowid
    FROM     igs_fi_fee_as_items
    WHERE    unit_set_cd = x_unit_set_cd
    AND      us_version_number =  x_us_version_number;

  lv_rowid   cur_rowid%ROWTYPE;

BEGIN
      OPEN cur_rowid;
      FETCH cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        CLOSE cur_rowid;
        fnd_message.set_name('IGS', 'IGS_FI_FAI_EUS_FK');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
        RETURN;
      END IF;
      CLOSE cur_rowid;
END get_fk_igs_en_unit_set_all;

END igs_fi_fee_as_items_pkg;

/
