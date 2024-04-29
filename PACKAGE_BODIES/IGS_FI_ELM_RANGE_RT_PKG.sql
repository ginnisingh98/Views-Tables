--------------------------------------------------------
--  DDL for Package Body IGS_FI_ELM_RANGE_RT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_ELM_RANGE_RT_PKG" AS
/* $Header: IGSSI67B.pls 115.6 2003/04/22 09:13:05 vvutukur ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_FI_ELM_RANGE_RT%RowType;
  new_references IGS_FI_ELM_RANGE_RT%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ERR_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_rate_number IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_ELM_RANGE_RT
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
    new_references.ERR_ID := x_ERR_ID;
    new_references.fee_type := x_fee_type;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.range_number := x_range_number;
    new_references.rate_number := x_rate_number;
    new_references.create_dt := x_create_dt;
    new_references.fee_cat := x_fee_cat;
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
  -- ON IGS_FI_ELM_RANGE_RT
  -- FOR EACH ROW
  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate Elements Range Rate can be created.
	IF p_inserting THEN
		-- Validate elements range rate can only be matched to a fee_ass_rate
		-- at the same level (ie FTCI or FCFL).
		IF IGS_FI_VAL_ERR.finp_val_err_ins (
				new_references.fee_type,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.s_relation_type,
				new_references.rate_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		-- Validate elements range rate can only be created when the parent records
		-- (elements_range and fee_ass_rate are not logically deleted).
		IF IGS_FI_VAL_ERR.finp_val_err_create (
				new_references.fee_type,
				new_references.fee_cal_type,
				new_references.fee_ci_sequence_number,
				new_references.s_relation_type,
				new_references.fee_cat,
				new_references.range_number,
				new_references.rate_number,
				v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;
  -- Trigger description :-
  -- AFTER INSERT OR UPDATE
  -- ON IGS_FI_ELM_RANGE_RT
  PROCEDURE AfterStmtInsertUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
	v_message_string VARCHAR2(512);
  BEGIN
	-- Validate for open rates.
  	IF p_inserting OR p_updating THEN
  		IF IGS_FI_VAL_ERR.finp_val_err_active(new_references.fee_type,
  		    	              new_references.fee_cal_type,
  			              new_references.fee_ci_sequence_number,
  		    	              new_references.fee_cat,
  			              new_references.range_number,
  			              new_references.rate_number,
  		    	              new_references.s_relation_type,
  		    	              new_references.create_dt,
  			              v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate3;
  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF (Get_UK1_For_Validation (
          new_references.fee_type,
          new_references.fee_cal_type,
          new_references.fee_ci_sequence_number,
          new_references.range_number,
          new_references.rate_number,
          new_references.create_dt,
          new_references.fee_cat
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
    IF (Get_UK2_For_Validation (
          new_references.err_id
        )) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;
  END Check_Uniqueness;
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
  ||  vvutukur   21-Apr-2003       Bug#2885575. Modified the upper limit check to 999999999 for field rate_number.
  ||  vvutukur        18-May-2002  removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'FEE_CAL_TYPE') THEN
      new_references.fee_cal_type := column_value;
    ELSIF (UPPER (column_name) = 'S_RELATION_TYPE') THEN
      new_references.s_relation_type := column_value;
    ELSIF (UPPER (column_name) = 'FEE_CI_SEQUENCE_NUMBER') THEN
      new_references.fee_ci_sequence_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'RANGE_NUMBER') THEN
      new_references.range_number := igs_ge_number.To_Num (column_value);
    ELSIF (UPPER (column_name) = 'RATE_NUMBER') THEN
      new_references.rate_number := igs_ge_number.to_num (column_value);
    END IF;
    IF ((UPPER (column_name) = 'FEE_CAL_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.fee_cal_type <> UPPER (new_references.fee_cal_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'S_RELATION_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.s_relation_type NOT IN ('FCFL', 'FTCI')) THEN
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
    IF ((UPPER (column_name) = 'RANGE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.range_number < 1) OR (new_references.range_number > 999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'RATE_NUMBER') OR (column_name IS NULL)) THEN
      IF ((new_references.rate_number < 1) OR (new_references.rate_number > 999999999)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.s_relation_type = new_references.s_relation_type) AND
         (old_references.range_number = new_references.range_number) AND
         (old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.s_relation_type IS NULL) OR
         (new_references.range_number IS NULL) OR
         (new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_EL_RNG_PKG.Get_UK2_For_Validation (
               new_references.fee_type,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.s_relation_type,
               new_references.range_number,
               new_references.fee_cat
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF (((old_references.fee_type = new_references.fee_type) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.s_relation_type = new_references.s_relation_type) AND
         (old_references.rate_number = new_references.rate_number) AND
         (old_references.fee_cat = new_references.fee_cat)) OR
        ((new_references.fee_type IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.s_relation_type IS NULL) OR
         (new_references.rate_number IS NULL) OR
         (new_references.fee_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FEE_AS_RATE_PKG.Get_UK2_For_Validation (
               new_references.fee_type,
               new_references.fee_cal_type,
               new_references.fee_ci_sequence_number,
               new_references.s_relation_type,
               new_references.rate_number,
               new_references.fee_cat
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  FUNCTION Get_PK_For_Validation (
    x_ERR_ID NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_RT
      WHERE    ERR_ID = x_ERR_ID
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
    x_fee_ci_sequence_number IN VARCHAR2,
    x_range_number IN VARCHAR2,
    x_rate_number IN VARCHAR2,
    x_create_dt IN VARCHAR2,
    x_fee_cat IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_RT
      WHERE    fee_type = x_fee_type
	  AND      fee_cal_type = x_fee_cal_type
	  AND      fee_ci_sequence_number = x_fee_ci_sequence_number
	  AND      range_number = x_range_number
	  AND      rate_number = x_rate_number
	  AND      create_dt = x_create_dt
	  AND      fee_cat = x_fee_cat
	  AND      fee_cal_type = x_fee_cal_type
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
  FUNCTION Get_UK2_For_Validation (
    x_ERR_ID NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_RT
      WHERE    ERR_ID = x_ERR_ID
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
  PROCEDURE GET_UFK_IGS_FI_ELM_RANGE (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_range_number IN NUMBER,
    x_fee_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_RT
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      range_number = x_range_number
      AND      fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_ERR_ER_UK_FK');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_FI_ELM_RANGE;
  PROCEDURE GET_UFK_IGS_FI_FEE_AS_RATE (
    x_fee_type IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type IN VARCHAR2,
    x_rate_number IN NUMBER,
    x_fee_cat IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_ELM_RANGE_RT
      WHERE    fee_type = x_fee_type
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      s_relation_type = x_s_relation_type
      AND      rate_number = x_rate_number
      AND      fee_cat = x_fee_cat ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_ERR_FAR_UK_FK');
        IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_UFK_IGS_FI_FEE_AS_RATE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_ERR_ID IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_range_number IN NUMBER DEFAULT NULL,
    x_rate_number IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
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
      x_ERR_ID,
      x_fee_type,
      x_fee_cal_type,
      x_fee_ci_sequence_number,
      x_s_relation_type,
      x_range_number,
      x_rate_number,
      x_create_dt,
      x_fee_cat,
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
            new_references.err_id
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
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.err_id
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
      AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdate3 ( p_updating => TRUE );
    END IF;
  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ERR_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C (cp_range_id IN NUMBER) is select ROWID from IGS_FI_ELM_RANGE_RT
      where ERR_ID = cp_range_id;
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
  SELECT   IGS_FI_ELM_RANGE_RT_ERR_ID_S.NextVal
  INTO     x_ERR_ID
  FROM     dual;
  Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_ERR_ID => x_ERR_ID,
 x_create_dt=>NVL(X_CREATE_DT,sysdate),
 x_fee_cal_type=>X_FEE_CAL_TYPE,
 x_fee_cat=>X_FEE_CAT,
 x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
 x_fee_type=>X_FEE_TYPE,
 x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
 x_range_number=>X_RANGE_NUMBER,
 x_rate_number=>X_RATE_NUMBER,
 x_s_relation_type=>X_S_RELATION_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  insert into IGS_FI_ELM_RANGE_RT (
    ERR_ID,
    FEE_TYPE,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    RANGE_NUMBER,
    RATE_NUMBER,
    CREATE_DT,
    FEE_CAT,
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
    NEW_REFERENCES.ERR_ID,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.RANGE_NUMBER,
    NEW_REFERENCES.RATE_NUMBER,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.FEE_CAT,
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
  open c (x_ERR_ID);
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
  x_ERR_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      FEE_TYPE,
      FEE_CAL_TYPE,
      FEE_CI_SEQUENCE_NUMBER,
      S_RELATION_TYPE,
      RANGE_NUMBER,
      RATE_NUMBER,
      CREATE_DT,
      FEE_CAT,
      LOGICAL_DELETE_DT
    from IGS_FI_ELM_RANGE_RT
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
  if ( (tlinfo.FEE_CAL_TYPE = X_FEE_CAL_TYPE)
      AND (tlinfo.FEE_TYPE = x_FEE_TYPE)
      AND (tlinfo.FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER)
      AND (tlinfo.S_RELATION_TYPE = X_S_RELATION_TYPE)
      AND (tlinfo.RANGE_NUMBER = X_RANGE_NUMBER)
      AND (tlinfo.RATE_NUMBER = X_RATE_NUMBER)
      AND (tlinfo.CREATE_DT = X_CREATE_DT)
      AND ((tlinfo.FEE_CAT = X_FEE_CAT)
           OR ((tlinfo.FEE_CAT is null)
               AND (X_FEE_CAT is null)))
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
  x_ERR_ID IN NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
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
  x_ERR_ID => x_ERR_ID,
  x_create_dt=>X_CREATE_DT,
  x_fee_cal_type=>X_FEE_CAL_TYPE,
  x_fee_cat=>X_FEE_CAT,
  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,
  x_fee_type=>X_FEE_TYPE,
  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
  x_range_number=>X_RANGE_NUMBER,
  x_rate_number=>X_RATE_NUMBER,
  x_s_relation_type=>X_S_RELATION_TYPE,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  update IGS_FI_ELM_RANGE_RT set
    FEE_TYPE = NEW_REFERENCES.FEE_TYPE,
    FEE_CAL_TYPE = NEW_REFERENCES.FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER = NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    S_RELATION_TYPE = NEW_REFERENCES.S_RELATION_TYPE,
    RANGE_NUMBER = NEW_REFERENCES.RANGE_NUMBER,
    RATE_NUMBER = NEW_REFERENCES.RATE_NUMBER,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    FEE_CAT = NEW_REFERENCES.FEE_CAT,
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
  x_ERR_ID IN OUT NOCOPY NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_RANGE_NUMBER in NUMBER,
  X_RATE_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_CAT in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_ELM_RANGE_RT
     where ERR_ID = x_ERR_ID
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ERR_ID,
     X_FEE_TYPE,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_RANGE_NUMBER,
     X_RATE_NUMBER,
     X_CREATE_DT,
     X_FEE_CAT,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   x_ERR_ID,
   X_FEE_TYPE,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_RANGE_NUMBER,
   X_RATE_NUMBER,
   X_CREATE_DT,
   X_FEE_CAT,
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
  delete from IGS_FI_ELM_RANGE_RT
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_ELM_RANGE_RT_PKG;

/
