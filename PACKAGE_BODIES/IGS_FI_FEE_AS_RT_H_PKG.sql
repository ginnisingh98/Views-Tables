--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_AS_RT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_AS_RT_H_PKG" AS
/* $Header: IGSSI21B.pls 120.2 2006/05/26 13:42:37 skharida noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_AS_RT_H_ALL%RowType;
  new_references IGS_FI_FEE_AS_RT_H_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_chg_rate IN NUMBER ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_s_relation_type IN VARCHAR2 ,
    x_rate_number IN NUMBER ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_order_of_precedence IN NUMBER ,
    x_govt_hecs_payment_option IN VARCHAR2 ,
    x_govt_hecs_cntrbtn_band IN NUMBER ,
    x_unit_class IN VARCHAR2 ,
    x_residency_status_cd  IN VARCHAR2 ,
    x_course_cd  IN VARCHAR2 ,
    x_version_number  IN NUMBER ,
    x_org_party_id  IN NUMBER ,
    x_class_standing  IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER,
    x_unit_cd                   IN VARCHAR2 ,
    x_unit_version_number       IN NUMBER   ,
    x_unit_level                IN VARCHAR2 ,
    x_unit_type_id              IN NUMBER   ,
    x_unit_mode                 IN VARCHAR2

  ) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala     31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_FEE_AS_RT_H_ALL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.chg_rate := x_chg_rate;
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.rate_number := x_rate_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.fee_cat := x_fee_cat;
    new_references.location_cd := x_location_cd;
    new_references.attendance_type := x_attendance_type;
    new_references.attendance_mode := x_attendance_mode;
    new_references.order_of_precedence := x_order_of_precedence;
    new_references.govt_hecs_payment_option := x_govt_hecs_payment_option;
    new_references.govt_hecs_cntrbtn_band := x_govt_hecs_cntrbtn_band;
    new_references.unit_class := x_unit_class;
    new_references.residency_status_cd := x_residency_status_cd;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.org_party_id := x_org_party_id;
    new_references.class_standing := x_class_standing;
    new_references.org_id := x_org_id;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
    new_references.unit_cd                  := x_unit_cd  ;
    new_references.unit_version_number      := x_unit_version_number ;
    new_references.unit_level               := x_unit_level   ;
    new_references.unit_type_id             := x_unit_type_id ;
    new_references.unit_mode                := x_unit_mode    ;


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

PROCEDURE Check_Uniqueness AS
   Begin
   IF  Get_UK_For_Validation (
      new_references.fee_type ,
      new_references.fee_cal_type ,
      new_references.fee_ci_sequence_number ,
      new_references.rate_number ,
      new_references.hist_start_dt ,
        new_references.fee_cat
       ) THEN
            Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END IF;
   End Check_Uniqueness;


PROCEDURE Check_Constraints (
 Column_Name    IN      VARCHAR2        ,
 Column_Value   IN      VARCHAR2
 ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  skharida        26-May-2006    Bug 5217319 Removed the hardcoded precision check
  || svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
  ||                                 Unit Version and Unit Level
  ||  pathipat        10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
  ||                                  Added 2 new columns unit_set_cd and us_version_number
  ||  vvutukur       21-Apr-2003      Bug#2885575.Modified the upper limit check to 999999999 for fields rate_number and order_of_precedence.
  ||  SYKRISHn       10APR03          ORDER_OF_PRECEDENCE - Changes limit check to 9999
  ||  vvutukur        17-May-2002     removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
 BEGIN
  IF  column_name is null then
     NULL;
  ELSIF upper(Column_name) = 'CHG_RATE' then
     new_references.chg_rate := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'FEE_CI_SEQUENCE_NUMBER' then
     new_references.fee_ci_sequence_number := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'ORDER_OF_PRECEDENCE' then
     new_references.order_of_precedence := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
     new_references.attendance_mode := column_value;
 ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
     new_references.attendance_type := column_value;
  ELSIF upper(Column_name) = 'FEE_CAL_TYPE' then
     new_references.fee_cal_type := column_value;
 ELSIF upper(Column_name) = 'GOVT_HECS_PAYMENT_OPTION' then
     new_references.govt_hecs_payment_option := column_value;
  ELSIF upper(Column_name) = 'LOCATION_CD' then
     new_references.location_cd := column_value;
 ELSIF upper(Column_name) = 'S_RELATION_TYPE' then
     new_references.s_relation_type := column_value;
  ELSIF upper(Column_name) = 'GOVT_HECS_CNTRBTN_BAND' then
     new_references.govt_hecs_cntrbtn_band := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'RATE_NUMBER' then
     new_references.rate_number := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
  ELSIF upper(Column_name) = 'VERSION_NUMBER' then
     new_references.version_number := igs_ge_number.to_num(column_value);
  ELSIF upper(Column_name) = 'CLASS_STANDING' then
     new_references.class_standing := column_value;
  ELSIF upper(Column_name) = 'UNIT_SET_CD' then
     new_references.unit_set_cd := column_value;
  ELSIF upper(Column_name) = 'US_VERSION_NUMBER' then
     new_references.us_version_number := igs_ge_number.to_num(column_value);
  ELSIF (UPPER(column_name) = 'UNIT_VERSION_NUMBER') THEN
      new_references.unit_version_number := igs_ge_number.to_num(column_value);
  ELSIF (UPPER(column_name) = 'UNIT_TYPE_ID') THEN
      new_references.unit_type_id := igs_ge_number.to_num(column_value);
 ELSIF (UPPER (column_name) = 'UNIT_CD') THEN
      new_references.unit_cd  := column_value;
 ELSIF (UPPER (column_name) = 'UNIT_LEVEL') THEN
      new_references.unit_level := column_value;
 ELSIF (UPPER (column_name) = 'UNIT_CLASS') THEN
     new_references.unit_class := column_value;
 ELSIF (UPPER(column_name) = 'UNIT_MODE') THEN
      new_references.unit_mode := column_value;
  END IF;

  IF upper(column_name) = 'CHG_RATE' OR
       column_name is null Then
       IF new_references.chg_rate  < 0 Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
  END IF;
IF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.fee_ci_sequence_number  < 1 OR
          new_references.fee_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'ORDER_OF_PRECEDENCE' OR
     column_name is null Then
     IF new_references.order_of_precedence  < 1 OR
          new_references.order_of_precedence > 999999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'GOVT_HECS_CNTRBTN_BAND' OR
     column_name is null Then
     IF new_references.govt_hecs_cntrbtn_band  < 1 OR
          new_references.govt_hecs_cntrbtn_band > 99 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'RATE_NUMBER' OR
     column_name is null Then
     IF new_references.rate_number  < 1 OR
          new_references.rate_number > 999999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_MODE' OR
     column_name is null Then
     IF new_references.attendance_mode <>
        UPPER(new_references.attendance_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'ATTENDANCE_TYPE' OR
     column_name is null Then
     IF new_references.attendance_type <>
        UPPER(new_references.attendance_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'FEE_CAL_TYPE' OR
     column_name is null Then
     IF new_references.fee_cal_type <>
        UPPER(new_references.fee_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'GOVT_HECS_PAYMENT_OPTION' OR
     column_name is null Then
     IF new_references.govt_hecs_payment_option <>
        UPPER(new_references.govt_hecs_payment_option) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.location_cd <>
        UPPER(new_references.location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'S_RELATION_TYPE' OR
     column_name is null Then
     IF new_references.s_relation_type <>
        UPPER(new_references.s_relation_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <>
        UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'VERSION_NUMBER' OR
     column_name is null Then
     IF new_references.version_number  < 1 OR
          new_references.version_number > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'CLASS_STANDING' OR
     column_name is null Then
     IF new_references.class_standing <>
        UPPER(new_references.class_standing) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF UPPER(column_name) = 'UNIT_SET_CD' OR column_name IS NULL THEN
     IF new_references.unit_set_cd <>  UPPER(new_references.unit_set_cd) THEN
         fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
     END IF;
END IF;
IF UPPER(column_name) = 'US_VERSION_NUMBER' OR column_name IS NULL THEN
     IF new_references.us_version_number  < 1 OR  new_references.us_version_number > 999 Then
         fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
         igs_ge_msg_stack.add;
         app_exception.raise_exception;
     END IF;
END IF;

IF ((UPPER(column_name) = 'UNIT_VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.unit_version_number < 0) OR (new_references.unit_version_number > 999)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_TYPE_ID') OR (column_name IS NULL)) THEN
      IF (new_references.unit_type_id < 0) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_cd <> UPPER (new_references.unit_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_LEVEL') OR (column_name IS NULL)) THEN
      IF (new_references.unit_level <> UPPER(new_references.unit_level)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CLASS') OR (column_name IS NULL)) THEN
      IF (new_references.unit_class <> UPPER (new_references.unit_class)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER(column_name) = 'UNIT_MODE') OR (column_name IS NULL)) THEN
      IF (new_references.unit_mode <> UPPER(new_references.unit_mode)) THEN
        fnd_message.set_name('IGS', 'IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

END Check_Constraints;


PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
        )       THEN
             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
        END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF  NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
        new_references.fee_type,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number
        )       THEN
             Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
        END IF;
    END IF;
  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_rate_number IN NUMBER,
    x_hist_start_dt IN DATE
    ) Return Boolean
        AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_AS_RT_H_ALL
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      rate_number = x_rate_number
      AND      hist_start_dt = x_hist_start_dt
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
 ELSE
       Close cur_rowid;
       Return (FALSE);
 END IF;
 END Get_PK_For_Validation;


FUNCTION Get_UK_For_Validation (
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_rate_number IN NUMBER ,
    x_hist_start_dt IN DATE ,
    x_fee_cat IN VARCHAR2
        ) Return Boolean
        AS
     CURSOR cur_rowid IS
       SELECT   rowid
       FROM     IGS_FI_FEE_AS_RT_H_ALL
         WHERE    fee_type = x_fee_type
         AND      fee_cal_type = x_fee_cal_type
         AND      fee_ci_sequence_number = x_fee_ci_sequence_number
         AND      rate_number = x_rate_number
         AND      hist_start_dt = x_hist_start_dt
         AND      fee_cat = x_fee_cat
         AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

     lv_rowid cur_rowid%RowType;
   BEGIN
     Open cur_rowid;
     Fetch cur_rowid INTO lv_rowid;
      IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
        Return (TRUE);
  ELSE
        Close cur_rowid;
        Return (FALSE);
  END IF;
  END Get_UK_For_Validation;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_chg_rate IN NUMBER ,
    x_fee_type IN VARCHAR2 ,
    x_fee_cal_type IN VARCHAR2 ,
    x_fee_ci_sequence_number IN NUMBER ,
    x_s_relation_type IN VARCHAR2 ,
    x_rate_number IN NUMBER ,
    x_hist_start_dt IN DATE ,
    x_hist_end_dt IN DATE ,
    x_hist_who IN VARCHAR2 ,
    x_fee_cat IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_order_of_precedence IN NUMBER ,
    x_govt_hecs_payment_option IN VARCHAR2 ,
    x_govt_hecs_cntrbtn_band IN NUMBER ,
    x_unit_class IN VARCHAR2 ,
    x_residency_status_cd  IN VARCHAR2 ,
    x_course_cd  IN VARCHAR2 ,
    x_version_number  IN NUMBER ,
    x_org_party_id  IN NUMBER ,
    x_class_standing  IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER,
    x_unit_cd                     IN VARCHAR2 ,
    x_unit_version_number         IN NUMBER   ,
    x_unit_level                  IN VARCHAR2 ,
    x_unit_type_id                IN NUMBER   ,
    x_unit_mode                   IN VARCHAR2
  ) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala     31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_chg_rate,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_rate_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_fee_cat,
      x_location_cd,
      x_attendance_type,
      x_attendance_mode,
      x_order_of_precedence,
      x_govt_hecs_payment_option,
      x_govt_hecs_cntrbtn_band,
      x_unit_class,
      x_residency_status_cd,
      x_course_cd,
      x_version_number,
      x_org_party_id,
      x_class_standing,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_unit_set_cd,
      x_us_version_number,
      x_unit_cd ,
      x_unit_version_number,
      x_unit_level,
      x_unit_type_id,
      x_unit_mode
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
                IF  Get_PK_For_Validation (
                    new_references.fee_type ,
                    new_references.fee_cal_type ,
                    new_references.fee_ci_sequence_number ,
                    new_references.s_relation_type ,
                    new_references.rate_number ,
                    new_references.hist_start_dt
                    ) THEN
                         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                          IGS_GE_MSG_STACK.ADD;
                          App_Exception.Raise_Exception;
                END IF;
                Check_Constraints;
                 Check_Uniqueness;
                         Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
                Check_Constraints;
                 Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
        ELSIF (p_action = 'VALIDATE_INSERT') THEN
              IF  Get_PK_For_Validation (
                    new_references.fee_type ,
                    new_references.fee_cal_type ,
                    new_references.fee_ci_sequence_number ,
                    new_references.s_relation_type ,
                    new_references.rate_number ,
                    new_references.hist_start_dt
                         ) THEN
                 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
                 IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
              END IF;
              Check_Constraints;
              Check_Uniqueness;
        ELSIF (p_action = 'VALIDATE_UPDATE') THEN
               Check_Constraints;
               Check_Uniqueness;
        ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Null;
    END IF;
  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 ,
  X_COURSE_CD  in VARCHAR2 ,
  X_VERSION_NUMBER in NUMBER ,
  X_ORG_PARTY_ID in NUMBER ,
  X_CLASS_STANDING  in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2,
  x_unit_set_cd         IN VARCHAR2,
  x_us_version_number   IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_mode                   IN VARCHAR2
  ) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala     31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
    cursor C is select ROWID from IGS_FI_FEE_AS_RT_H_ALL
      where FEE_TYPE = X_FEE_TYPE
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and S_RELATION_TYPE = X_S_RELATION_TYPE
      and HIST_START_DT = X_HIST_START_DT
      and RATE_NUMBER = X_RATE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_govt_hecs_cntrbtn_band=>X_GOVT_HECS_CNTRBTN_BAND,
  x_govt_hecs_payment_option=>X_GOVT_HECS_PAYMENT_OPTION,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_location_cd=>X_LOCATION_CD,
  x_order_of_precedence=>X_ORDER_OF_PRECEDENCE,
  x_rate_number=>X_RATE_NUMBER,
  x_s_relation_type=>X_S_RELATION_TYPE,
  x_unit_class => X_UNIT_CLASS,
  x_residency_status_cd => X_RESIDENCY_STATUS_CD,
  x_course_cd => X_COURSE_CD,
  x_version_number => X_VERSION_NUMBER,
  x_org_party_id => X_ORG_PARTY_ID,
  x_class_standing => X_CLASS_STANDING,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_unit_set_cd         => x_unit_set_cd,
  x_us_version_number   => x_us_version_number,
  x_unit_cd                   => x_unit_cd,
  x_unit_version_number       => x_unit_version_number,
  x_unit_level                => x_unit_level ,
  x_unit_type_id              => x_unit_type_id,
  x_unit_mode                 => x_unit_mode
  );

  insert into IGS_FI_FEE_AS_RT_H_ALL (
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    RATE_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    FEE_CAT,
    LOCATION_CD,
    ATTENDANCE_TYPE,
    ATTENDANCE_MODE,
    ORDER_OF_PRECEDENCE,
    GOVT_HECS_PAYMENT_OPTION,
    GOVT_HECS_CNTRBTN_BAND,
    CHG_RATE,
    UNIT_CLASS,
    RESIDENCY_STATUS_CD,
    COURSE_CD,
    VERSION_NUMBER,
    ORG_PARTY_ID,
    CLASS_STANDING,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    unit_set_cd,
    us_version_number,
    unit_cd ,
    unit_version_number,
    unit_level  ,
    unit_type_id,
    unit_mode
  ) values (
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.RATE_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ORDER_OF_PRECEDENCE,
    NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    NEW_REFERENCES.GOVT_HECS_CNTRBTN_BAND,
    NEW_REFERENCES.CHG_RATE,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.RESIDENCY_STATUS_CD,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.ORG_PARTY_ID,
    NEW_REFERENCES.CLASS_STANDING,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    new_references.unit_set_cd,
    new_references.us_version_number,
    new_references.unit_cd,
    new_references.unit_version_number,
    new_references.unit_level ,
    new_references.unit_type_id ,
    new_references.unit_mode
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;


procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS IN VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 ,
  X_COURSE_CD  in VARCHAR2 ,
  X_VERSION_NUMBER in NUMBER ,
  X_ORG_PARTY_ID in NUMBER ,
  X_CLASS_STANDING  in VARCHAR2,
  x_unit_set_cd         IN VARCHAR2,
  x_us_version_number   IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_mode                   IN VARCHAR2
) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      FEE_CAT,
      LOCATION_CD,
      ATTENDANCE_TYPE,
      ATTENDANCE_MODE,
      ORDER_OF_PRECEDENCE,
      GOVT_HECS_PAYMENT_OPTION,
      GOVT_HECS_CNTRBTN_BAND,
      CHG_RATE,
      UNIT_CLASS,
      RESIDENCY_STATUS_CD,
      COURSE_CD,
      VERSION_NUMBER,
      ORG_PARTY_ID,
      CLASS_STANDING,
      unit_set_cd,
      us_version_number,
      unit_cd,
      unit_version_number,
      unit_level  ,
      unit_type_id ,
      unit_mode
    from IGS_FI_FEE_AS_RT_H_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.ORDER_OF_PRECEDENCE = X_ORDER_OF_PRECEDENCE)
           OR ((tlinfo.ORDER_OF_PRECEDENCE is null)
               AND (X_ORDER_OF_PRECEDENCE is null)))
      AND ((tlinfo.GOVT_HECS_PAYMENT_OPTION = X_GOVT_HECS_PAYMENT_OPTION)
           OR ((tlinfo.GOVT_HECS_PAYMENT_OPTION is null)
               AND (X_GOVT_HECS_PAYMENT_OPTION is null)))
      AND ((tlinfo.GOVT_HECS_CNTRBTN_BAND = X_GOVT_HECS_CNTRBTN_BAND)
           OR ((tlinfo.GOVT_HECS_CNTRBTN_BAND is null)
               AND (X_GOVT_HECS_CNTRBTN_BAND is null)))
      AND ((tlinfo.CHG_RATE = X_CHG_RATE)
           OR ((tlinfo.CHG_RATE is null)
               AND (X_CHG_RATE is null)))
      AND (tlinfo.UNIT_CLASS = X_UNIT_CLASS
           OR (tlinfo.UNIT_CLASS is null
               AND X_UNIT_CLASS is null))
      AND (tlinfo.RESIDENCY_STATUS_CD = X_RESIDENCY_STATUS_CD
           OR (tlinfo.RESIDENCY_STATUS_CD is null
               AND X_RESIDENCY_STATUS_CD is null))
      AND (tlinfo.COURSE_CD = X_COURSE_CD
           OR (tlinfo.COURSE_CD is null
               AND X_COURSE_CD is null))
      AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER
           OR (tlinfo.VERSION_NUMBER is null
               AND X_VERSION_NUMBER is null))
      AND (tlinfo.ORG_PARTY_ID = X_ORG_PARTY_ID OR (tlinfo.ORG_PARTY_ID is null AND X_ORG_PARTY_ID is null))
      AND (tlinfo.CLASS_STANDING = X_CLASS_STANDING OR (tlinfo.CLASS_STANDING is null AND X_CLASS_STANDING is null))
      AND (tlinfo.unit_set_cd = x_unit_set_cd OR (tlinfo.unit_set_cd IS NULL AND x_unit_set_cd IS NULL))
      AND (tlinfo.us_version_number = x_us_version_number OR (tlinfo.us_version_number IS NULL AND x_us_version_number IS NULL))
      AND ((tlinfo.unit_cd = x_unit_cd) OR ((tlinfo.unit_cd IS NULL) AND (x_unit_cd IS NULL)))
      AND ((tlinfo.unit_version_number = x_unit_version_number) OR ((tlinfo.unit_version_number IS NULL) AND (x_unit_version_number IS NULL)))
      AND ((tlinfo.unit_level = x_unit_level) OR ((tlinfo.unit_level IS NULL)  AND (x_unit_level IS NULL)))
      AND ((tlinfo.unit_type_id = x_unit_type_id) OR ((tlinfo.unit_type_id IS NULL) AND (x_unit_type_id IS NULL)))
      AND ((tlinfo.unit_mode = x_unit_mode) OR ((tlinfo.unit_mode IS NULL) AND (x_unit_mode IS NULL)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;


procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 ,
  X_COURSE_CD  in VARCHAR2 ,
  X_VERSION_NUMBER in NUMBER ,
  X_ORG_PARTY_ID in NUMBER ,
  X_CLASS_STANDING  in VARCHAR2 ,
  X_MODE in VARCHAR2,
  x_unit_set_cd         IN VARCHAR2,
  x_us_version_number   IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_mode                   IN VARCHAR2
  ) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala     31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_chg_rate=>X_CHG_RATE,
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_govt_hecs_cntrbtn_band=>X_GOVT_HECS_CNTRBTN_BAND,
  x_govt_hecs_payment_option=>X_GOVT_HECS_PAYMENT_OPTION,
  x_hist_end_dt=>X_HIST_END_DT,
  x_hist_start_dt=>X_HIST_START_DT,
  x_hist_who=>X_HIST_WHO,
  x_location_cd=>X_LOCATION_CD,
  x_order_of_precedence=>X_ORDER_OF_PRECEDENCE,
  x_rate_number=>X_RATE_NUMBER,
  x_s_relation_type=>X_S_RELATION_TYPE,
  x_unit_class => X_UNIT_CLASS,
  x_residency_status_cd => X_RESIDENCY_STATUS_CD,
  x_course_cd => X_COURSE_CD,
  x_version_number => X_VERSION_NUMBER,
  x_org_party_id => X_ORG_PARTY_ID,
  x_class_standing => X_CLASS_STANDING,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_unit_set_cd         => x_unit_set_cd,
  x_us_version_number   => x_us_version_number,
  x_unit_cd                     => x_unit_cd,
  x_unit_version_number         => x_unit_version_number,
  x_unit_level                  => x_unit_level ,
  x_unit_type_id                => x_unit_type_id,
  x_unit_mode                   => x_unit_mode
  );
  update IGS_FI_FEE_AS_RT_H_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ORDER_OF_PRECEDENCE = NEW_REFERENCES.ORDER_OF_PRECEDENCE,
    GOVT_HECS_PAYMENT_OPTION = NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    GOVT_HECS_CNTRBTN_BAND = NEW_REFERENCES.GOVT_HECS_CNTRBTN_BAND,
    CHG_RATE = NEW_REFERENCES.CHG_RATE,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    RESIDENCY_STATUS_CD = NEW_REFERENCES.RESIDENCY_STATUS_CD,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    ORG_PARTY_ID = NEW_REFERENCES.ORG_PARTY_ID,
    CLASS_STANDING = NEW_REFERENCES.CLASS_STANDING,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    unit_set_cd       = new_references.unit_set_cd,
    us_version_number = new_references.us_version_number,
    unit_cd                  = new_references.unit_cd,
    unit_version_number      = new_references.unit_version_number,
    unit_level               = new_references.unit_level ,
    unit_type_id             = new_references.unit_type_id,
    unit_mode                = new_references.unit_mode
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;


procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_RATE_NUMBER in NUMBER,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ORDER_OF_PRECEDENCE in NUMBER,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_CNTRBTN_BAND in NUMBER,
  X_CHG_RATE in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_RESIDENCY_STATUS_CD  in  VARCHAR2 ,
  X_COURSE_CD  in VARCHAR2 ,
  X_VERSION_NUMBER in NUMBER ,
  X_ORG_PARTY_ID in NUMBER ,
  X_CLASS_STANDING  in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2,
  x_unit_set_cd         IN VARCHAR2,
  x_us_version_number   IN NUMBER,
  x_unit_cd                     IN VARCHAR2 ,
  x_unit_version_number         IN NUMBER   ,
  x_unit_level                  IN VARCHAR2 ,
  x_unit_type_id                IN NUMBER   ,
  x_unit_mode                   IN VARCHAR2
  ) AS
 /************************************************************************************
 | HISTORY
 | Who         When             What
 | svuppala         31-MAY-2005    Enh 3442712: Added Unit Program Type Level, Unit Mode, Unit Class, Unit Code,
 |                                 Unit Version and Unit Level
 | pathipat     10-Sep-2003     Enh 3108052 - Add Unit Sets to Rate Table
 |                              Added 2 new columns unit_set_cd and us_version_number
**************************************************************************************/
  cursor c1 is select rowid from IGS_FI_FEE_AS_RT_H_ALL
     where FEE_TYPE = X_FEE_TYPE
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and S_RELATION_TYPE = X_S_RELATION_TYPE
     and HIST_START_DT = X_HIST_START_DT
     and RATE_NUMBER = X_RATE_NUMBER ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_HIST_START_DT,
     X_RATE_NUMBER,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_FEE_CAT,
     X_LOCATION_CD,
     X_ATTENDANCE_TYPE,
     X_ATTENDANCE_MODE,
     X_ORDER_OF_PRECEDENCE,
     X_GOVT_HECS_PAYMENT_OPTION,
     X_GOVT_HECS_CNTRBTN_BAND,
     X_CHG_RATE,
     X_UNIT_CLASS,
     X_RESIDENCY_STATUS_CD,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_ORG_PARTY_ID,
     X_CLASS_STANDING,
     X_ORG_ID,
     X_MODE,
     x_unit_set_cd,
     x_us_version_number,
     x_unit_cd,
     x_unit_version_number,
     x_unit_level,
     x_unit_type_id,
     x_unit_mode
     );
    return;
  end if;

  close c1;

  UPDATE_ROW (
   X_ROWID,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_HIST_START_DT,
   X_RATE_NUMBER,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_FEE_CAT,
   X_LOCATION_CD,
   X_ATTENDANCE_TYPE,
   X_ATTENDANCE_MODE,
   X_ORDER_OF_PRECEDENCE,
   X_GOVT_HECS_PAYMENT_OPTION,
   X_GOVT_HECS_CNTRBTN_BAND,
   X_CHG_RATE,
   X_UNIT_CLASS,
   X_RESIDENCY_STATUS_CD,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_ORG_PARTY_ID,
   X_CLASS_STANDING,
   X_MODE,
   x_unit_set_cd,
   x_us_version_number,
   x_unit_cd,
   x_unit_version_number,
   x_unit_level,
   x_unit_type_id,
   x_unit_mode
   );
END add_row;


PROCEDURE delete_row (
  X_ROWID in VARCHAR2
) AS
BEGIN
   Before_DML(
               p_action => 'DELETE',
               x_rowid  => X_ROWID
             );
  DELETE FROM igs_fi_fee_as_rt_h_all
  WHERE rowid = x_rowid;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
END delete_row;

END igs_fi_fee_as_rt_h_pkg;

/
