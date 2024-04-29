--------------------------------------------------------
--  DDL for Package Body IGS_EN_UNITSETFEETRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_UNITSETFEETRG_PKG" as
/* $Header: IGSEI11B.pls 115.5 2003/02/12 10:21:21 shtatiko ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_EN_UNITSETFEETRG%RowType;
  new_references IGS_EN_UNITSETFEETRG%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
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
      FROM     IGS_EN_UNITSETFEETRG
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
    new_references.fee_cat := x_fee_cat;
    new_references.fee_cal_type := x_fee_cal_type;
    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;
    new_references.fee_type := x_fee_type;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.version_number := x_version_number;
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
  -- "OSS_TST".trg_usft_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_EN_UNITSETFEETRG
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

      v_message_name  varchar2(30);
  BEGIN
	IF p_inserting THEN
		-- Validate UNIT fee trigger can be inserted
		IF IGS_EN_VAL_USFT.finp_val_usft_ins (
				new_references.fee_type,
				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
		-- Validate the UNIT set is not inactive
		IF IGS_EN_VAL_USFT.finp_val_us_status (
				new_references.unit_set_cd,
				new_references.version_number,
				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate fee trigger group can be defined.
	IF (new_references.fee_trigger_group_number IS NOT NULL) THEN
		IF IGS_EN_VAL_USFT.finp_val_usft_ftg (
				new_references.fee_type,
				new_references.fee_trigger_group_number,
				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  -- Trigger description :-
  -- "OSS_TST".trg_usft_ar_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_EN_UNITSETFEETRG
  -- FOR EACH ROW

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS

      v_message_name  varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate for open UNIT Set Fee Trig records.
	IF (new_references.logical_delete_dt IS NULL) THEN

		IF IGS_EN_VAL_USFT.finp_val_usft_open(new_references.fee_cat,
  				new_references.fee_cal_type,
  				new_references.fee_ci_sequence_number,
  				new_references.fee_type,
  				new_references.unit_set_cd,
  				new_references.version_number,
  				new_references.create_dt,
  				new_references.fee_trigger_group_number,
  				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
		END IF;

		v_rowid_saved := TRUE;
	END IF;


  END AfterRowInsertUpdate2;


  PROCEDURE Check_Constraints(
  	Column_Name in Varchar2 Default NULL,
  	Column_Value in Varchar2 default NULL
  )  AS
  /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        19-May-2002   removed upper check constraint on fee_cat,fee_type columns.bug#2344826.
  ----------------------------------------------------------------------------*/
  Begin

	IF column_name is null then
	      NULL;
	ELSIF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' THEN
	      new_references.fee_ci_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'FEE_TRIGGER_GROUP_NUMBER' THEN
	      new_references.fee_trigger_group_number := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'FEE_CAL_TYPE' THEN
	      new_references.fee_cal_type := column_value;
	ELSIF upper(column_name) = 'UNIT_SET_CD' THEN
	      new_references.unit_set_cd := column_value;
	END IF;


	IF upper(column_name) = 'FEE_CI_SEQUENCE_NUMBER' OR
	       Column_name is null THEN
	       IF new_references.fee_ci_sequence_number  NOT  BETWEEN 1 AND 999999  THEN
		      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	       END IF;
	END IF;

	IF upper(column_name) = 'FEE_TRIGGER_GROUP_NUMBER' OR
	       Column_name is null THEN
	       IF new_references.fee_trigger_group_number  NOT  BETWEEN 1 AND 999999  THEN
		      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	       END IF;
	END IF;

	IF upper(column_name) = 'FEE_CAL_TYPE' OR
	       Column_name is null THEN
	       IF new_references.fee_cal_type <> UPPER(new_references.fee_cal_type)  THEN
		      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	       END IF;
	END IF;

	IF upper(column_name) = 'UNIT_SET_CD' OR
	       Column_name is null THEN
	       IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd)  THEN
		      Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
		      App_Exception.Raise_Exception;
	       END IF;
	END IF;

  END Check_constraints;


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
        ) Then
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF  ;
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
        )  Then
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
      END IF  ;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.version_number
        )Then
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
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_create_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNITSETFEETRG
      WHERE    fee_cat= x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number
      AND      create_dt = x_create_dt
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

  PROCEDURE GET_FK_IGS_FI_FEE_TRG_GRP (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_trigger_group_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNITSETFEETRG
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
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_USFT_FTG_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_FEE_TRG_GRP;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_UNITSETFEETRG
      WHERE    unit_set_cd = x_unit_set_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_USFT_US_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_fee_cat IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_fee_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
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
      x_unit_set_cd,
      x_version_number,
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
	 If Get_PK_For_Validation(
	    new_references.fee_cat ,
	    new_references.fee_cal_type ,
	    new_references.fee_ci_sequence_number ,
	    new_references.fee_type ,
	    new_references.unit_set_cd ,
	    new_references.version_number ,
	    new_references.create_dt
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END if;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      If Get_PK_For_Validation(
	    new_references.fee_cat ,
	    new_references.fee_cal_type ,
	    new_references.fee_ci_sequence_number ,
	    new_references.fee_type ,
	    new_references.unit_set_cd ,
	    new_references.version_number ,
	    new_references.create_dt
         ) THEN
         FND_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END if;
      Check_constraints;
    ELSif (p_action = 'VALIDATE_UPDATE') THEN
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      null;
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
      AfterRowInsertUpdate2 ( p_inserting => TRUE );

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_updating => TRUE );

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CREATE_DT in out NOCOPY DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_UNITSETFEETRG
      where FEE_CAT = X_FEE_CAT
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and FEE_TYPE = X_FEE_TYPE
      and UNIT_SET_CD = X_UNIT_SET_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CREATE_DT = NEW_REFERENCES.CREATE_DT;
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
  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_version_number => X_VERSION_NUMBER,
    x_create_dt => NVL(X_CREATE_DT,SYSDATE),
    x_fee_trigger_group_number => X_FEE_TRIGGER_GROUP_NUMBER,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_UNITSETFEETRG (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    UNIT_SET_CD,
    VERSION_NUMBER,
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
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.VERSION_NUMBER,
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
After_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in  VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CREATE_DT in DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      FEE_TRIGGER_GROUP_NUMBER,
      LOGICAL_DELETE_DT
    from IGS_EN_UNITSETFEETRG
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

      if ( ((tlinfo.FEE_TRIGGER_GROUP_NUMBER = X_FEE_TRIGGER_GROUP_NUMBER)
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
  X_FEE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_fee_cat => X_FEE_CAT,
    x_fee_cal_type => X_FEE_CAL_TYPE,
    x_fee_ci_sequence_number => X_FEE_CI_SEQUENCE_NUMBER,
    x_fee_type => X_FEE_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_version_number => X_VERSION_NUMBER,
    x_create_dt => X_CREATE_DT,
    x_fee_trigger_group_number => X_FEE_TRIGGER_GROUP_NUMBER,
    x_logical_delete_dt => X_LOGICAL_DELETE_DT,
    x_creation_date => X_LAST_UPDATE_DATE ,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_UNITSETFEETRG set
    FEE_TRIGGER_GROUP_NUMBER = NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
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
  X_FEE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CREATE_DT in out NOCOPY DATE,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_UNITSETFEETRG
     where FEE_CAT = X_FEE_CAT
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and FEE_TYPE = X_FEE_TYPE
     and UNIT_SET_CD = X_UNIT_SET_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and CREATE_DT = nvl(X_CREATE_DT,SYSDATE)
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
     X_FEE_TYPE,
     X_UNIT_SET_CD,
     X_VERSION_NUMBER,
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
   X_FEE_TYPE,
   X_UNIT_SET_CD,
   X_VERSION_NUMBER,
   X_CREATE_DT,
   X_FEE_TRIGGER_GROUP_NUMBER,
   X_LOGICAL_DELETE_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_UNITSETFEETRG
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_EN_UNITSETFEETRG_PKG;

/
