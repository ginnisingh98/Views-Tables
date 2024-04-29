--------------------------------------------------------
--  DDL for Package Body IGS_PS_VER_RU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VER_RU_PKG" AS
 /* $Header: IGSPI45B.pls 115.4 2002/11/29 02:28:49 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_VER_RU%RowType;
  new_references IGS_PS_VER_RU%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_VER_RU
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.s_rule_call_cd := x_s_rule_call_cd;
    new_references.rul_sequence_number := x_rul_sequence_number;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate the insert/update/delete
	IF p_inserting OR p_updating THEN
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				new_references.course_cd,
				new_references.version_number,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	ELSE
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				old_references.course_cd,
				old_references.version_number,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate IGS_PS_COURSE Version IGS_RU_RULE
	IF p_inserting OR p_updating THEN
/*
||  Bug ID 1956374 - Removal of Duplicate Program Units from OSS.
||  Changed the reference of "IGS_PS_VAL_CVR.RULP_VAL_RUL_SRC" to program unit "IGS_FI_VAL_FDFR.RULP_VAL_RUL_SRC". -- kdande
*/
		IF  IGS_FI_VAL_FDFR.rulp_val_rul_src(
				new_references.s_rule_call_cd,
				'COURSE',
				new_references.rul_sequence_number,
				v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  ) IS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'COURSE_CD' THEN
	   new_references.course_cd := column_value;
	ELSIF upper(column_name) = 'S_RULE_CALL_CD' THEN
	   new_references.s_rule_call_cd:= column_value;
	ELSIF upper(column_name) = 'RUL_SEQUENCE_NUMBER' THEN
	   new_references.rul_sequence_number:= igs_ge_number.to_num(column_value);
	END IF;
	IF upper(column_name)= 'COURSE_CD' OR
		column_name is null THEN
		IF new_references.course_cd <> UPPER(new_references.course_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'S_RULE_CALL_CD' OR
		column_name is null THEN
		IF new_references.s_rule_call_cd <> UPPER(new_references.s_rule_call_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
                IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(column_name)= 'RUL_SEQUENCE_NUMBER' OR
		column_name is null THEN
		IF new_references.rul_sequence_number < 1 OR
		 new_references.rul_sequence_number > 999999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
        new_references.rul_sequence_number
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.s_rule_call_cd = new_references.s_rule_call_cd)) OR
        ((new_references.s_rule_call_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_CALL_PKG.Get_PK_For_Validation (
        new_references.s_rule_call_cd
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_s_rule_call_cd IN VARCHAR2
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_RU
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      s_rule_call_cd = x_s_rule_call_cd
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

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_RU
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CVR_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_RU
      WHERE    rul_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CVR_RUL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_RULE;

  PROCEDURE GET_FK_IGS_RU_CALL (
    x_s_rule_call_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_VER_RU
      WHERE    s_rule_call_cd = x_s_rule_call_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CVR_SRC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_CALL;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_s_rule_call_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
         	IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number,
		new_references.s_rule_call_cd
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
       Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number,
		new_references.s_rule_call_cd
   	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
     	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     	Check_Constraints;

    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_VER_RU
      where COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and S_RULE_CALL_CD = X_S_RULE_CALL_CD;
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
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_course_cd => X_COURSE_CD,
  x_version_number => X_VERSION_NUMBER,
  x_s_rule_call_cd => X_S_RULE_CALL_CD,
  x_rul_sequence_number => X_RUL_SEQUENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_PS_VER_RU (
    COURSE_CD,
    VERSION_NUMBER,
    S_RULE_CALL_CD,
    RUL_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.S_RULE_CALL_CD,
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
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
  After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER
) AS
  cursor c1 is select
      RUL_SEQUENCE_NUMBER
    from IGS_PS_VER_RU
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
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
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_course_cd => X_COURSE_CD,
  x_version_number => X_VERSION_NUMBER,
  x_s_rule_call_cd => X_S_RULE_CALL_CD,
  x_rul_sequence_number => X_RUL_SEQUENCE_NUMBER,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_PS_VER_RU set
    RUL_SEQUENCE_NUMBER = NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_VER_RU
     where COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
     and S_RULE_CALL_CD = X_S_RULE_CALL_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_S_RULE_CALL_CD,
     X_RUL_SEQUENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_S_RULE_CALL_CD,
   X_RUL_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_PS_VER_RU
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_VER_RU_PKG;

/
