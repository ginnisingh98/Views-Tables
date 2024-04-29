--------------------------------------------------------
--  DDL for Package Body IGS_FI_F_CAT_CA_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_F_CAT_CA_INST_PKG" as
/* $Header: IGSSI44B.pls 115.8 2002/11/29 03:48:12 nsidana ship $*/

/******************************
Removed calls to IGS_FI_FEE_ENCMB_PKG and IGS_FI_FEE_ENCMB_H_PKG as these 2 tables are obsleted as part of bug 2126091 -sykrishn -30112001
***************************/
  l_rowid VARCHAR2(25);
  old_references IGS_FI_F_CAT_CA_INST%RowType;
  new_references IGS_FI_F_CAT_CA_INST%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_cat_ci_status IN VARCHAR2,
    x_start_dt_alias IN VARCHAR2,
    x_start_dai_sequence_number IN NUMBER,
    x_end_dt_alias IN VARCHAR2,
    x_end_dai_sequence_number IN NUMBER,
    x_retro_dt_alias IN VARCHAR2,
    x_retro_dai_sequence_number IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_F_CAT_CA_INST
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
    new_references.fee_cat_ci_status := x_fee_cat_ci_status;
    new_references.start_dt_alias := x_start_dt_alias;
    new_references.start_dai_sequence_number := x_start_dai_sequence_number;
    new_references.end_dt_alias := x_end_dt_alias;
    new_references.end_dai_sequence_number := x_end_dai_sequence_number;
    new_references.retro_dt_alias := x_retro_dt_alias;
    new_references.retro_dai_sequence_number := x_retro_dai_sequence_number;
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
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_F_CAT_CA_INST
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     02-Sep-2002     Bug#2531390. Removed DEFAULT from parameters to avoid gscc warnings.
  ----------------------------------------------------------------------------*/
	v_message_name varchar2(30);
  BEGIN
	-- Validate Calendar Instance.
	IF p_inserting THEN
		IF IGS_FI_VAL_FCCI.finp_val_ci_fee (
					new_references.fee_cal_type,
					new_references.fee_ci_sequence_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate Fee Structure Status.
	IF (p_inserting OR (old_references.fee_cat_ci_status) <>
			(new_references.fee_cat_ci_status)) THEN
		IF IGS_FI_VAL_FCCI.finp_val_fss_closed (
					new_references.fee_cat_ci_status,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		IF IGS_FI_VAL_FCCI.finp_val_fcci_active (
				new_references.fee_cat_ci_status,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		IF IGS_FI_VAL_FCCI.finp_val_fcci_status (
				new_references.fee_cat,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_cat_ci_status,
				old_references.fee_cat_ci_status,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate Date Alias Values.
	IF (p_inserting OR ((old_references.start_dt_alias) <> (new_references.start_dt_alias) OR
		                (old_references.end_dt_alias) <> (new_references.end_dt_alias) OR
		                (old_references.retro_dt_alias) <> (new_references.retro_dt_alias))) THEN
		IF IGS_FI_VAL_FCCI.finp_val_fcci_dates (
					new_references.fee_cal_type,
					new_references.fee_ci_sequence_number,
					new_references.start_dt_alias,
					new_references.start_dai_sequence_number,
					new_references.end_dt_alias,
					new_references.end_dai_sequence_number,
					new_references.retro_dt_alias,
					new_references.retro_dai_sequence_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;
  -- Trigger description :-
  -- AFTER UPDATE
  -- ON IGS_FI_F_CAT_CA_INST
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate2(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
 /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur     02-Sep-2002     Bug#2531390. Removed DEFAULT from parameters to avoid gscc warnings.
  ----------------------------------------------------------------------------*/
  BEGIN
	-- create a history
	IGS_FI_GEN_002.FINP_INS_FCCI_HIST(old_references.fee_cat,
		old_references.fee_cal_type,
		old_references.fee_ci_sequence_number,
		new_references.fee_cat_ci_status,
		old_references.fee_cat_ci_status,
		new_references.start_dt_alias,
		old_references.start_dt_alias,
		new_references.start_dai_sequence_number,
		old_references.start_dai_sequence_number,
		new_references.end_dt_alias,
		old_references.end_dt_alias,
		new_references.end_dai_sequence_number,
		old_references.end_dai_sequence_number,
		new_references.retro_dt_alias,
		old_references.retro_dt_alias,
		new_references.retro_dai_sequence_number,
		old_references.retro_dai_sequence_number,
		new_references.last_updated_by,
		old_references.last_updated_by,
		new_references.last_update_date,
		old_references.last_update_date);
  END AfterRowUpdate2;
  PROCEDURE Check_Constraints (
    column_name  IN VARCHAR2,
    column_value IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        20-May-2002   removed upper check on fee_cat,fee_cat_ci_status
  ||                                (alias of fee_structure_status)columns .bug#2344826.
  ----------------------------------------------------------------------------*/

  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'RETRO_DAI_SEQUENCE_NUMBER') THEN
      new_references.retro_dai_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'END_DAI_SEQUENCE_NUMBER') THEN
      new_references.end_dai_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'END_DT_ALIAS') THEN
      new_references.end_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'RETRO_DT_ALIAS') THEN
      new_references.retro_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'START_DT_ALIAS') THEN
      new_references.start_dt_alias := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.to_num (column_value);
    ELSIF (UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') THEN
      new_references.start_dai_sequence_number := igs_ge_number.to_num (column_value);
    END IF;
    IF ((UPPER (column_name) = 'RETRO_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.retro_dai_sequence_number < 1) OR (new_references.retro_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'END_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.end_dai_sequence_number < 1) OR (new_references.end_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'END_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.end_dt_alias <> UPPER (new_references.end_dt_alias)) THEN
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
    IF ((UPPER (column_name) = 'RETRO_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.retro_dt_alias <> UPPER (new_references.retro_dt_alias)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'START_DT_ALIAS') OR (column_name IS NULL)) THEN
      IF (new_references.start_dt_alias <> UPPER (new_references.start_dt_alias)) THEN
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
    IF ((UPPER (column_name) = 'START_DAI_SEQUENCE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.start_dai_sequence_number < 1) OR (new_references.start_dai_sequence_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.start_dt_alias = new_references.start_dt_alias) AND
         (old_references.start_dai_sequence_number = new_references.start_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.start_dt_alias IS NULL) OR
         (new_references.start_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.start_dt_alias,
               new_references.start_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.end_dt_alias = new_references.end_dt_alias) AND
         (old_references.end_dai_sequence_number = new_references.end_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.end_dt_alias IS NULL) OR
         (new_references.end_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.end_dt_alias,
               new_references.end_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_CAT_PKG.Get_PK_For_Validation (
               new_references.fee_cat
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_cat_ci_status = new_references.fee_cat_ci_status)) OR
        ((new_references.fee_cat_ci_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_STR_STAT_PKG.Get_PK_For_Validation (
               new_references.fee_cat_ci_status
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.retro_dt_alias = new_references.retro_dt_alias) AND
         (old_references.retro_dai_sequence_number = new_references.retro_dai_sequence_number) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.retro_dt_alias IS NULL) OR
         (new_references.retro_dai_sequence_number IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
               new_references.retro_dt_alias,
               new_references.retro_dai_sequence_number,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur      26-Aug-2002 Bug#2531390.Removed the call to IGS_FI_FEE_PAY_SCHD_PKG.GET_FK_IGS_FI_F_CAT_CA_INST
  ||                            and IGS_FI_F_PAY_SCHD_HT_PKG.GET_FK_IGS_FI_F_CAT_CA_INST.
  ----------------------------------------------------------------------------*/
  BEGIN
    IGS_FI_F_CAT_FEE_LBL_PKG.GET_FK_IGS_FI_F_CAT_CA_INST (
      old_references.fee_cat,
      old_references.fee_cal_type,
      old_references.fee_ci_sequence_number
      );
 --Removed calls to IGS_FI_FEE_ENCMB_PKG and IGS_FI_FEE_ENCMB_H_PKG as these 2 tables are obsleted as part of bug 2126091 -sykrishn -30112001

    IGS_FI_F_RET_SCHD_HT_PKG.GET_FK_IGS_FI_F_CAT_CA_INST (
      old_references.fee_cat,
      old_references.fee_cal_type,
      old_references.fee_ci_sequence_number
      );
    IGS_FI_FEE_RET_SCHD_PKG.GET_FK_IGS_FI_F_CAT_CA_INST (
      old_references.fee_cat,
      old_references.fee_cal_type,
      old_references.fee_ci_sequence_number
      );
  END Check_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_CA_INST
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
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
  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_CA_INST
      WHERE    (start_dt_alias = x_dt_alias
      AND      start_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_ci_sequence_number)
      OR       (end_dt_alias = x_dt_alias
      AND      end_dai_sequence_number = x_sequence_number
      AND      fee_cal_type = x_cal_type
      AND      Fee_ci_sequence_number = x_ci_sequence_number);
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCCI_END_DAI_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_DA_INST;
  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_CA_INST
      WHERE    fee_cal_type = x_cal_type
      AND      fee_ci_sequence_number = x_sequence_number ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCCI_CI_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_CA_INST;
  PROCEDURE GET_FK_IGS_FI_FEE_CAT (
    x_fee_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_CA_INST
      WHERE    fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCCI_FC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_CAT;
  PROCEDURE GET_FK_IGS_FI_FEE_STR_STAT (
    x_fee_structure_status IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_F_CAT_CA_INST
      WHERE    fee_cat_ci_status = x_fee_structure_status ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FCCI_FSST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_FEE_STR_STAT;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_cat_ci_status IN VARCHAR2,
    x_start_dt_alias IN VARCHAR2,
    x_start_dai_sequence_number IN NUMBER,
    x_end_dt_alias IN VARCHAR2,
    x_end_dai_sequence_number IN NUMBER,
    x_retro_dt_alias IN VARCHAR2,
    x_retro_dai_sequence_number IN NUMBER,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who          When            What
  ||  (reverse chronological order - newest change first)
  || vvutukur    02-Sep-2002 Bug#2531390. Modified the calls to procedure BeforeRowInsertUpdateDelete1
  ||                         to pass FALSE for the parameters which were defaulting to false in that
  ||                         procedure previously. This is done because we removed DEFAULT from package
  ||                         body to avoid gscc warning.
  ----------------------------------------------------------------------------*/
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_fee_cat,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_fee_cat_ci_status,
      x_start_dt_alias,
      x_start_dai_sequence_number,
      x_end_dt_alias,
      x_end_dai_sequence_number,
      x_retro_dt_alias,
      x_retro_dai_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,
                                     p_updating  => FALSE,
				     p_deleting  => FALSE);
      IF (Get_PK_For_Validation (
            new_references.fee_cat,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => TRUE,
				     p_deleting  => FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,
                                     p_updating  => FALSE,
                                     p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.fee_cat,
            new_references.fee_cal_type,
            new_references.fee_ci_sequence_number
            )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;
  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  VVUTUKUR      02-Sep-2002   Bug#2531390. Modified call to afterrowupdate2 and provided FALSE
  ||                              for the parameters which used to default to FALSE in that procedure
  ||                              previously.Done because the DEFAULT is removed from package body
  ||                              due to gscc warning.
  ----------------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowUpdate2 ( p_inserting => FALSE,
                        p_updating => TRUE,
			p_deleting => FALSE);
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_FI_F_CAT_CA_INST
      where FEE_CAT = X_FEE_CAT
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_cat_ci_status=>X_FEE_CAT_CI_STATUS,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_F_CAT_CA_INST (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_CAT_CI_STATUS,
    START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_CAT_CI_STATUS,
    NEW_REFERENCES.START_DT_ALIAS,
    NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.END_DT_ALIAS,
    NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.RETRO_DT_ALIAS,
    NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML (
 p_action => 'INSERT',
 x_rowid => X_ROWID
);
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select
      FEE_CAT_CI_STATUS,
      START_DT_ALIAS,
      START_DAI_SEQUENCE_NUMBER,
      END_DT_ALIAS,
      END_DAI_SEQUENCE_NUMBER,
      RETRO_DT_ALIAS,
      RETRO_DAI_SEQUENCE_NUMBER
    from IGS_FI_F_CAT_CA_INST
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
  if ( (tlinfo.FEE_CAT_CI_STATUS = X_FEE_CAT_CI_STATUS)
      AND (tlinfo.START_DT_ALIAS = X_START_DT_ALIAS)
      AND (tlinfo.START_DAI_SEQUENCE_NUMBER = X_START_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.END_DT_ALIAS = X_END_DT_ALIAS)
      AND (tlinfo.END_DAI_SEQUENCE_NUMBER = X_END_DAI_SEQUENCE_NUMBER)
      AND ((tlinfo.RETRO_DT_ALIAS = X_RETRO_DT_ALIAS)
           OR ((tlinfo.RETRO_DT_ALIAS is null)
               AND (X_RETRO_DT_ALIAS is null)))
      AND ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER = X_RETRO_DAI_SEQUENCE_NUMBER)
           OR ((tlinfo.RETRO_DAI_SEQUENCE_NUMBER is null)
               AND (X_RETRO_DAI_SEQUENCE_NUMBER is null)))
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
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_end_dai_sequence_number=>X_END_DAI_SEQUENCE_NUMBER,
 x_end_dt_alias=>X_END_DT_ALIAS,
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_cat_ci_status=>X_FEE_CAT_CI_STATUS,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_retro_dai_sequence_number=>X_RETRO_DAI_SEQUENCE_NUMBER,
 x_retro_dt_alias=>X_RETRO_DT_ALIAS,
 x_start_dai_sequence_number=>X_START_DAI_SEQUENCE_NUMBER,
 x_start_dt_alias=>X_START_DT_ALIAS,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_F_CAT_CA_INST set
    FEE_CAT_CI_STATUS = NEW_REFERENCES.FEE_CAT_CI_STATUS,
    START_DT_ALIAS = NEW_REFERENCES.START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS = NEW_REFERENCES.END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    RETRO_DT_ALIAS = NEW_REFERENCES.RETRO_DT_ALIAS,
    RETRO_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.RETRO_DAI_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID=X_REQUEST_ID,
    PROGRAM_ID=X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID=X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE=X_PROGRAM_UPDATE_DATE
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_CAT_CI_STATUS in VARCHAR2,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_RETRO_DT_ALIAS in VARCHAR2,
  X_RETRO_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_FI_F_CAT_CA_INST
     where FEE_CAT = X_FEE_CAT
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
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
     X_FEE_CAT_CI_STATUS,
     X_START_DT_ALIAS,
     X_START_DAI_SEQUENCE_NUMBER,
     X_END_DT_ALIAS,
     X_END_DAI_SEQUENCE_NUMBER,
     X_RETRO_DT_ALIAS,
     X_RETRO_DAI_SEQUENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FEE_CAT,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_CAT_CI_STATUS,
   X_START_DT_ALIAS,
   X_START_DAI_SEQUENCE_NUMBER,
   X_END_DT_ALIAS,
   X_END_DAI_SEQUENCE_NUMBER,
   X_RETRO_DT_ALIAS,
   X_RETRO_DAI_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_F_CAT_CA_INST
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
end IGS_FI_F_CAT_CA_INST_PKG;

/
