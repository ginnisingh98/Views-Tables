--------------------------------------------------------
--  DDL for Package Body IGS_FI_EL_RNG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_EL_RNG_PKG" AS
/* $Header: IGSSI66B.pls 120.1 2005/07/05 21:52:05 appldev ship $*/
  l_rowid VARCHAR2(25) ;
  old_references IGS_FI_ELM_RANGE%RowType;
  new_references IGS_FI_ELM_RANGE%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ER_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ELM_RANGE
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
    new_references.ER_ID := x_ER_ID;
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.range_number := x_range_number;
    new_references.fee_cat := x_fee_cat;
    new_references.lower_range := x_lower_range;
    new_references.upper_range := x_upper_range;
    new_references.s_chg_method_type := x_s_chg_method_type;
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
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_FI_ELM_RANGE
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate Elements Range can be created.
	IF p_inserting THEN
		-- If IGS_FI_FEE_TYPE.s_fee_trigger_cat = 'INSTITUTN' or
		-- IGS_FI_FEE_TYPE.s_fee_type = 'HECS',  then element ranges
		-- can only be defined against FTCI's.
		IF new_references.s_relation_type <> 'FTCI' THEN
			IF IGS_FI_VAL_ER.finp_val_er_ins (
					new_references.fee_type,
					v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- If charge method type of parent record is 'FLATRATE' or fee_type.s_fee_type
		-- is 'HECS' then elements ranges cannot be defined.
		IF IGS_FI_VAL_ER.finp_val_er_create (
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.fee_type,
				new_references.fee_cat,
				v_message_name) = FALSE THEN
			        Fnd_Message.Set_Name('IGS',v_message_name);
                                IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate fee category is only set when the relation type = 'FCFL'.
	IF p_inserting OR p_updating THEN
		IF IGS_FI_VAL_ER.finp_val_er_rltn (
					new_references.s_relation_type,
					new_references.fee_cat,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		IF IGS_FI_VAL_ER.finp_val_er_ranges (
					new_references.lower_range,
					new_references.upper_range,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;
  -- Trigger description :-
  -- AFTER UPDATE
  -- ON IGS_FI_ELM_RANGE
  -- FOR EACH ROW
  PROCEDURE AfterRowUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  BEGIN
	-- create a history
		IGS_FI_GEN_002.FINP_INS_ER_HIST(old_references.fee_type,
			old_references.fee_cal_type,
			old_references.fee_ci_sequence_number,
			old_references.s_relation_type,
			old_references.range_number,
			new_references.fee_cat,
			old_references.fee_cat,
			new_references.lower_range,
			old_references.lower_range,
			new_references.upper_range,
			old_references.upper_range,
			new_references.s_chg_method_type,
			old_references.s_chg_method_type,
			new_references.last_updated_by,
			old_references.last_updated_by,
			new_references.last_update_date,
			old_references.last_update_date);
  END AfterRowUpdate3;
  -- Trigger description :-
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_ELM_RANGE
  PROCEDURE AfterStmtInsertUpdate4(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
	v_message_string VARCHAR2(512);
  BEGIN
	-- Validate if elements_range can be created and if so, then
  	-- validate the range value for overlaps.
  	IF p_inserting OR p_updating THEN
  		IF IGS_FI_VAL_ER.finp_val_er_defn(new_references.fee_type,
   			              new_references.fee_cal_type,
  			              new_references.fee_ci_sequence_number,
  		    	              new_references.s_relation_type,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  		IF IGS_FI_VAL_ER.finp_val_er_ovrlp(new_references.fee_type,
  		    	              new_references.fee_cal_type,
  			              new_references.fee_ci_sequence_number,
  		    	              new_references.s_relation_type,
  		    	              new_references.fee_cat,
  			              new_references.range_number,
  		    	              new_references.lower_range,
  		    	              new_references.upper_range,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
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
  ||  svuppala        24-JUN-2005   Bug 3392088 Modifications as part of CPF build
  ||                                Added Incremental check also for override Charge Method
  ||  vvutukur        18-May-2002   removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'S_RELATION_TYPE') THEN
      new_references.s_relation_type := column_value;
    ELSIF (UPPER (column_name) = 'RANGE_NUMBER') THEN
      new_references.range_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'UPPER_RANGE') THEN
      new_references.upper_range := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'S_CHG_METHOD_TYPE') THEN
      new_references.s_chg_method_type := column_value;
    ELSIF (UPPER (column_name) = 'LOWER_RANGE') THEN
      new_references.lower_range := igs_ge_number.To_Num (column_value);
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
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
    IF ((UPPER (column_name) = 'S_RELATION_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_relation_type NOT IN ('FTCI', 'FCFL')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RANGE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.range_number < 1) OR (new_references.range_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'UPPER_RANGE') OR (column_name IS NULL)) THEN
      IF ((new_references.upper_range < 0) OR (new_references.upper_range > 9999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_CHG_METHOD_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_chg_method_type NOT IN ('FLATRATE','INCREMENTAL')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'LOWER_RANGE') OR (column_name IS NULL)) THEN
      IF ((new_references.lower_range < 0) OR (new_references.lower_range > 9999.999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF (Get_UK1_For_Validation (
          new_references.fee_type,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.range_number,
          new_references.fee_cat
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
    IF (Get_UK2_For_Validation (
          new_references.fee_type,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.s_relation_type,
          new_references.range_number,
          new_references.fee_cat
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
    IF (Get_UK3_For_Validation (
          new_references.er_id
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
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
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_F_TYP_CA_INST_PKG.Get_PK_For_Validation (
               new_references.fee_type,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.s_chg_method_type = new_references.s_chg_method_type)) OR
        ((new_references.s_chg_method_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
               'CHG_METHOD',
		       new_references.s_chg_method_type
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_FI_ELM_RANGE_RT_PKG.GET_UFK_IGS_FI_ELM_RANGE (
      new_references.fee_type,
      new_references.fee_cal_type,
      new_references.fee_ci_sequence_number,
      new_references.s_relation_type,
      new_references.range_number,
      new_references.fee_cat
    );
  END Check_Child_Existance;
  PROCEDURE Check_UK_Child_Existance AS
  BEGIN
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.s_relation_type = new_references.s_relation_type) AND
         (old_references.range_number = new_references.range_number) AND
         (old_references.fee_cat = new_references.fee_cat)) OR
        ((old_references.fee_type = Null) AND
         (old_references.fee_cal_type = Null) AND
         (old_references.fee_ci_sequence_number = Null) AND
         (old_references.s_relation_type = Null) AND
         (old_references.range_number = Null) AND
         (old_references.fee_cat = Null))) THEN
      Null;
    ELSE
      IGS_FI_ELM_RANGE_RT_PKG.GET_UFK_IGS_FI_ELM_RANGE (
        old_references.fee_type,
        old_references.fee_cal_type,
        old_references.fee_ci_sequence_number,
        old_references.s_relation_type,
        old_references.range_number,
        old_references.fee_cat
      );
    END IF;
  END Check_UK_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_ER_ID NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE
      WHERE    ER_ID = x_ER_ID
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
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      range_number = x_range_number
      AND      fee_cat = x_fee_cat
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
      Close cur_rowid;
      Return (FALSE);
    END IF;
  END Get_UK1_For_Validation;
  FUNCTION Get_UK2_For_Validation (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE
      WHERE    fee_type = x_fee_type
     AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      range_number = x_range_number
      AND     ( fee_cat = x_fee_cat or fee_cat is null)
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
  END Get_UK2_For_Validation;
  FUNCTION Get_UK3_For_Validation (
    x_er_id IN NUMBER
  ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE
      WHERE    er_id = x_er_id
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
  END Get_UK3_For_Validation;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_chg_method_type IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE
      WHERE    s_chg_method_type = x_s_chg_method_type ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_ER_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_LOOKUPS_VIEW;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ER_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_lower_range IN NUMBER DEFAULT NULL,
    x_upper_range IN NUMBER DEFAULT NULL,
    x_s_chg_method_type IN VARCHAR2 DEFAULT NULL,
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
      x_ER_ID,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_range_number,
      x_fee_cat,
      x_lower_range,
      x_upper_range,
      x_s_chg_method_type,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF (Get_PK_For_Validation (
            new_references.er_id
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
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.er_id
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
      Check_UK_Child_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
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
    l_rowid := NULL;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ER_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C (cp_range_id IN NUMBER) is select ROWID from IGS_FI_ELM_RANGE
      where ER_ID = cp_range_id;
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
  SELECT   IGS_FI_ELM_RANGE_ER_ID_S.NextVal
  INTO     X_ER_ID
  FROM     dual;
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_ER_ID => X_ER_ID,
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_lower_range=>X_LOWER_RANGE,
  x_range_number=>X_RANGE_NUMBER,
  x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
  x_s_relation_type=>X_S_RELATION_TYPE,
  x_upper_range=>X_UPPER_RANGE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_FI_ELM_RANGE (
    ER_ID,
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    RANGE_NUMBER,
    FEE_CAT,
    LOWER_RANGE,
    UPPER_RANGE,
    S_CHG_METHOD_TYPE,
    LOGICAL_DELETE_DT,
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
    NEW_REFERENCES.ER_ID,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.RANGE_NUMBER,
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.LOWER_RANGE,
    NEW_REFERENCES.UPPER_RANGE,
    NEW_REFERENCES.S_CHG_METHOD_TYPE,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
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
  open c (X_ER_ID);
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
After_DML(
   p_action =>'INSERT',
   x_rowid => X_ROWID
);
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ER_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      FEE_TYPE,
      FEE_CAL_TYPE,
      FEE_CI_SEQUENCE_NUMBER,
      S_RELATION_TYPE,
      RANGE_NUMBER,
      FEE_CAT,
      LOWER_RANGE,
      UPPER_RANGE,
      S_CHG_METHOD_TYPE,
      LOGICAL_DELETE_DT
    from IGS_FI_ELM_RANGE
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
  if ( (tlinfo.FEE_TYPE = X_FEE_TYPE)
      AND (tlinfo.FEE_CAL_TYPE = X_FEE_CAL_TYPE)
      AND (tlinfo.FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER)
      AND (tlinfo.S_RELATION_TYPE = X_S_RELATION_TYPE)
      AND (tlinfo.RANGE_NUMBER = X_RANGE_NUMBER)
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
      AND ((tlinfo.LOWER_RANGE = X_LOWER_RANGE)
           OR ((tlinfo.LOWER_RANGE is null)
               AND (X_LOWER_RANGE is null)))
      AND ((tlinfo.UPPER_RANGE = X_UPPER_RANGE)
           OR ((tlinfo.UPPER_RANGE is null)
               AND (X_UPPER_RANGE is null)))
      AND ((tlinfo.S_CHG_METHOD_TYPE = X_S_CHG_METHOD_TYPE)
           OR ((tlinfo.S_CHG_METHOD_TYPE is null)
               AND (X_S_CHG_METHOD_TYPE is null)))
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
  X_ER_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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
   x_ER_ID => X_ER_ID,
   x_fee_cal_type=>X_FEE_CAL_TYPE,
   x_fee_cat=>X_FEE_CAT,
   x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
   x_fee_type=>X_FEE_TYPE,
   x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
   x_lower_range=>X_LOWER_RANGE,
   x_range_number=>X_RANGE_NUMBER,
   x_s_chg_method_type=>X_S_CHG_METHOD_TYPE,
   x_s_relation_type=>X_S_RELATION_TYPE,
   x_upper_range=>X_UPPER_RANGE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGS_FI_ELM_RANGE set
    FEE_CAL_TYPE = NEW_REFERENCES.FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER = NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE = NEW_REFERENCES.FEE_TYPE,
    S_RELATION_TYPE = NEW_REFERENCES.S_RELATION_TYPE,
    RANGE_NUMBER = NEW_REFERENCES.RANGE_NUMBER,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
    LOWER_RANGE = NEW_REFERENCES.LOWER_RANGE,
    UPPER_RANGE = NEW_REFERENCES.UPPER_RANGE,
    S_CHG_METHOD_TYPE = NEW_REFERENCES.S_CHG_METHOD_TYPE,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
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
After_DML(
   p_action =>'UPDATE',
   x_rowid => X_ROWID
);
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ER_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_FEE_CAT in VARCHAR2,
  X_LOWER_RANGE in NUMBER,
  X_UPPER_RANGE in NUMBER,
  X_S_CHG_METHOD_TYPE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_ELM_RANGE
     where ER_ID = X_ER_ID;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ER_ID,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_RANGE_NUMBER,
     X_FEE_CAT,
     X_LOWER_RANGE,
     X_UPPER_RANGE,
     X_S_CHG_METHOD_TYPE,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ER_ID,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_RANGE_NUMBER,
   X_FEE_CAT,
   X_LOWER_RANGE,
   X_UPPER_RANGE,
   X_S_CHG_METHOD_TYPE,
   X_LOGICAL_DELETE_DT,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
   Before_DML(
   p_action =>'DELETE',
   x_rowid => X_ROWID
);
  delete from IGS_FI_ELM_RANGE
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_EL_RNG_PKG;

/
