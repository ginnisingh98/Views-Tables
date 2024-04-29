--------------------------------------------------------
--  DDL for Package Body IGS_FI_UNIT_FEE_TRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_UNIT_FEE_TRG_PKG" AS
/* $Header: IGSSI64B.pls 120.6 2006/05/25 08:28:19 abshriva ship $ */
 l_rowid VARCHAR2(25);
  old_references IGS_FI_UNIT_FEE_TRG%RowType;
  new_references IGS_FI_UNIT_FEE_TRG%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_UNIT_FEE_TRG
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
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type := x_fee_type;
    new_references.unit_cd := x_unit_cd;
    new_references.sequence_number := x_sequence_number;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.create_dt := x_create_dt;
    new_references.fee_trigger_group_number := x_fee_trigger_group_number;
    new_references.logical_delete_dt := x_logical_delete_dt;
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


   -- Trigger description :-
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_FI_UNIT_FEE_TRG
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

    v_message_name varchar2(30);
  BEGIN
        IF p_inserting THEN
                -- Validate unit fee trigger can be inserted
                IF IGS_FI_VAL_UFT.finp_val_uft_ins (
                                new_references.fee_type,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;

       -- Bug# 5070980. Not able to delete Unit Fee Trigger When Unit Version Is Inactive.
       -- Added a condition to avoid validating unit status while deleting a record.
       IF  NOT (new_references.LOGICAL_DELETE_DT IS NOT NULL AND p_updating ) THEN
        -- Validate unit version is is active or planned.
          IF (new_references.unit_cd IS NOT NULL AND
               new_references.version_number IS NOT NULL) THEN
               -- As part of the bug# 1956374 changed to the below call from IGS_FI_VAL_UFT.crsp_val_uv_sys_sts
                  IF IGS_PS_VAL_CALUL.crsp_val_uv_sys_sts (
                                  new_references.unit_cd,
                                  new_references.version_number,
                                  v_message_name) = FALSE THEN
                          Fnd_Message.Set_Name('IGS',v_message_name);
                          IGS_GE_MSG_STACK.ADD;
                          App_Exception.Raise_Exception;
                  END IF;
          END IF;
        END IF;
        -- Validate fee trigger group can be defined.
        IF (new_references.fee_trigger_group_number IS NOT NULL) THEN
                IF IGS_FI_VAL_UFT.finp_val_uft_ftg (
                                new_references.fee_type,
                                new_references.fee_trigger_group_number,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate calendar type is not closed and is of type teaching.
        IF (new_references.cal_type IS NOT NULL) THEN

        -- As part of the bug# 1956374 changed to the below call from IGS_FI_VAL_UFT.crsp_val_posp_cat
                IF IGS_PS_VAL_POSP.crsp_val_posp_cat (
                                new_references.cal_type,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate calendar instance is not inactive.
        IF (new_references.cal_type IS NOT NULL AND
             new_references.ci_sequence_number IS NOT NULL)  THEN
             -- BUG #1956374 , Procedure assp_val_ci_status reference is changed
                IF IGS_AS_VAL_EVSA.assp_val_ci_status (
                                new_references.cal_type,
                                new_references.ci_sequence_number,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate location code is not closed and is of type campus.
        IF (new_references.location_cd IS NOT NULL) THEN
        -- As part of the bug# 1956374 changed to the below call from IGS_FI_VAL_UFT.crsp_val_loc_cd
                IF IGS_PS_VAL_UOO.crsp_val_loc_cd (
                                new_references.location_cd,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
        -- Validate unit class is not closed.
        IF (new_references.unit_class IS NOT NULL) THEN
        -- As part of the bug# 1956374 changed to the below call from IGS_FI_VAL_UFT.crsp_val_ucl_closed
                IF IGS_AS_VAL_UAI.crsp_val_ucl_closed (
                                new_references.unit_class,
                                v_message_name) = FALSE THEN
                        Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
                        App_Exception.Raise_Exception;
                END IF;
        END IF;
  END BeforeRowInsertUpdate1;
  -- Trigger description :-
  -- AFTER UPDATE
  -- ON IGS_FI_UNIT_FEE_TRG
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  BEGIN
        -- create a history
        IGS_FI_GEN_002.FINP_INS_UFT_HIST( old_references.fee_cat,
                old_references.fee_cal_type,
                old_references.fee_ci_sequence_number,
                old_references.fee_type,
                old_references.unit_cd,
                old_references.sequence_number,
                new_references.version_number,
                old_references.version_number,
                new_references.cal_type,
                old_references.cal_type,
                new_references.ci_sequence_number,
                old_references.ci_sequence_number,
                new_references.location_cd,
                old_references.location_cd,
                new_references.unit_class,
                old_references.unit_class,
                new_references.create_dt,
                old_references.create_dt,
                new_references.fee_trigger_group_number,
                old_references.fee_trigger_group_number,
                new_references.last_updated_by,
                old_references.last_updated_by,
                new_references.last_update_date,
                old_references.last_update_date);
  END AfterRowUpdate3;
  -- Trigger description :-
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_UNIT_FEE_TRG
  PROCEDURE AfterStmtInsertUpdate4(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
        v_message_name varchar2(30);
        v_message_string VARCHAR2(512);
  BEGIN
        -- Validate for open ended IGS_FI_UNIT_FEE_TRG records.
        IF (p_inserting OR p_updating) THEN
                IF new_references.logical_delete_dt IS NULL THEN
                        IF IGS_FI_VAL_UFT.finp_val_uft_open(
                                        new_references.fee_cat,
                                        new_references.fee_cal_type,
                                        new_references.fee_ci_sequence_number,
                                        new_references.fee_type,
                                        new_references.unit_cd,
                                        new_references.sequence_number,
                                        new_references.version_number,
                                        new_references.cal_type,
                                        new_references.ci_sequence_number,
                                        new_references.unit_class,
                                        new_references.location_cd,
                                        new_references.create_dt,
                                        new_references.fee_trigger_group_number,
                                        v_message_name) = FALSE THEN
                                Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
                                App_Exception.Raise_Exception;
                        END IF;
                END IF;
        END IF;
  END AfterStmtInsertUpdate4;
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        18-May-2002  removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'SEQUENCE_NUMBER') THEN
      new_references.sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'CI_SEQUENCE_NUMBER') THEN
      new_references.ci_sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'VERSION_NUMBER') THEN
      new_references.version_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'FEE_TRIGGER_GROUP_NUMBER') THEN
      new_references.fee_trigger_group_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'CAL_TYPE') THEN
      new_references.cal_type := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'LOCATION_CD') THEN
      new_references.location_cd := column_value;
    ELSIF (UPPER (column_name) = 'UNIT_CD') THEN
      new_references.unit_cd := column_value;
    ELSIF (UPPER (column_name) = 'UNIT_CLASS') THEN
      new_references.unit_class := column_value;
    END IF;
    IF ((UPPER (column_name) = 'SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.sequence_number < 1) OR (new_references.sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.ci_sequence_number < 1) OR (new_references.ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'VERSION_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.version_number < 1) OR (new_references.version_number > 999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_TRIGGER_GROUP_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_trigger_group_number < 1) OR (new_references.fee_trigger_group_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.fee_ci_sequence_number < 1) OR (new_references.fee_ci_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.cal_type <> UPPER (new_references.cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'LOCATION_CD') OR (column_name IS NULL)) THEN
      IF (new_references.location_cd <> UPPER (new_references.location_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CD') OR (column_name IS NULL)) THEN
      IF (new_references.unit_cd <> UPPER (new_references.unit_cd)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UNIT_CLASS') OR (column_name IS NULL)) THEN
      IF (new_references.unit_class <> UPPER (new_references.unit_class)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF (Get_UK1_For_Validation (
          new_references.fee_cat,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.fee_type,
          new_references.unit_cd,
          new_references.version_number,
          new_references.cal_type,
          new_references.ci_sequence_number,
          new_references.location_cd,
          new_references.unit_class,
          new_references.create_dt
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.cal_type = new_references.cal_type)) OR
        ((new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
               new_references.cal_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
               new_references.cal_type,
               new_references.ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
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
      IF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
               new_references.fee_cat,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.fee_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_trigger_group_number = new_references.fee_trigger_group_number)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL) OR
         (new_references.fee_trigger_group_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_TRG_GRP_PKG.Get_PK_For_Validation (
               new_references.fee_cat,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.fee_type,
               new_references.fee_trigger_group_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
               new_references.location_cd ,
               'N'
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_class = new_references.unit_class)) OR
        ((new_references.unit_class IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_UNIT_CLASS_PKG.Get_PK_For_Validation (
               new_references.unit_class
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_cd = new_references.unit_cd)) OR
        ((new_references.unit_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_PKG.Get_PK_For_Validation (
               new_references.unit_cd
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_UNIT_VER_PKG.Get_PK_For_Validation (
               new_references.unit_cd,
               new_references.version_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      unit_cd = x_unit_cd
      AND      sequence_number = x_sequence_number
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
  FUNCTION Get_UK1_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_unit_class IN VARCHAR2,
    x_create_dt IN DATE
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      unit_class = x_unit_class
      AND      create_dt = x_create_dt
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
  END Get_UK1_For_Validation;
  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    cal_type = x_cal_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_CAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_TYPE;
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    cal_type = x_cal_type
      AND      ci_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_FI_FEE_TRG_GRP (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_trigger_group_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      fee_trigger_group_number = x_fee_trigger_group_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_FTG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_TRG_GRP;
  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    location_cd = x_location_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_AD_LOCATION;
  PROCEDURE GET_FK_IGS_PS_UNIT (
    x_unit_cd IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    unit_cd = x_unit_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_UN_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_UNIT;
  PROCEDURE GET_FK_IGS_PS_UNIT_VER (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_UNIT_FEE_TRG
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_UFT_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_PS_UNIT_VER;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
     x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_type,
      x_unit_cd,
      x_sequence_number,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_class,
      x_create_dt,
      x_fee_trigger_group_number,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF (Get_PK_For_Validation (
            new_references.fee_cat,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number,
            new_references.fee_type,
            new_references.unit_cd,
            new_references.sequence_number
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.fee_cat,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number,
            new_references.fee_type,
            new_references.unit_cd,
            new_references.sequence_number
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    END IF;
  END Before_DML;
  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsertUpdate4 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate3 ( p_updating => TRUE );
      AfterStmtInsertUpdate4 ( p_updating => TRUE );
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_UNIT_FEE_TRG
      where FEE_CAT = X_FEE_CAT
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and FEE_TYPE = X_FEE_TYPE;
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
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_create_dt=>NVL(X_CREATE_DT,sysdate),
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_trigger_group_number=>X_FEE_TRIGGER_GROUP_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_location_cd=>X_LOCATION_CD,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_version_number=>X_VERSION_NUMBER,
  x_logical_delete_dt => X_LOGICAL_DELETE_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_UNIT_FEE_TRG (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    UNIT_CD,
    SEQUENCE_NUMBER,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    UNIT_CLASS,
    CREATE_DT,
    FEE_TRIGGER_GROUP_NUMBER,
    LOGICAL_DELETE_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      LOCATION_CD,
      UNIT_CLASS,
      CREATE_DT,
      FEE_TRIGGER_GROUP_NUMBER,
      LOGICAL_DELETE_DT
    from IGS_FI_UNIT_FEE_TRG
    where ROWID=X_ROWID
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
      if ( ((tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
           OR ((tlinfo.VERSION_NUMBER is null)
               AND (X_VERSION_NUMBER is null)))
      AND ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE is null)
               AND (X_CAL_TYPE is null)))
      AND ((tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.CI_SEQUENCE_NUMBER is null)
               AND (X_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.UNIT_CLASS = X_UNIT_CLASS)
           OR ((tlinfo.UNIT_CLASS is null)
               AND (X_UNIT_CLASS is null)))
      AND (tlinfo.CREATE_DT = X_CREATE_DT)
      AND ((tlinfo.FEE_TRIGGER_GROUP_NUMBER = X_FEE_TRIGGER_GROUP_NUMBER)
           OR ((tlinfo.FEE_TRIGGER_GROUP_NUMBER is null)
               AND (X_FEE_TRIGGER_GROUP_NUMBER is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
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
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_create_dt=>X_CREATE_DT,
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_trigger_group_number=>X_FEE_TRIGGER_GROUP_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_location_cd=>X_LOCATION_CD,
  x_sequence_number=>X_SEQUENCE_NUMBER,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_version_number=>X_VERSION_NUMBER,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  update IGS_FI_UNIT_FEE_TRG set
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_CLASS = NEW_REFERENCES.UNIT_CLASS,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    FEE_TRIGGER_GROUP_NUMBER = NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
   p_action =>'UPDATE',
   x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_UNIT_FEE_TRG
     where FEE_CAT = X_FEE_CAT
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and UNIT_CD = X_UNIT_CD
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and FEE_TYPE = X_FEE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_SEQUENCE_NUMBER,
     X_FEE_TYPE,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_UNIT_CLASS,
     X_CREATE_DT,
     X_FEE_TRIGGER_GROUP_NUMBER,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_SEQUENCE_NUMBER,
   X_FEE_TYPE,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_UNIT_CLASS,
   X_CREATE_DT,
   X_FEE_TRIGGER_GROUP_NUMBER,
   X_LOGICAL_DELETE_DT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  delete from IGS_FI_UNIT_FEE_TRG
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_UNIT_FEE_TRG_PKG;

/
