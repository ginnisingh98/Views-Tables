--------------------------------------------------------
--  DDL for Package Body IGS_GE_S_GEN_CAL_CON_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_S_GEN_CAL_CON_PKG" as
/* $Header: IGSMI08B.pls 115.3 2002/11/29 01:10:59 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GE_S_GEN_CAL_CON%RowType;
  new_references IGS_GE_S_GEN_CAL_CON%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_census_dt_alias IN VARCHAR2 DEFAULT NULL,
    crs_completion_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_S_GEN_CAL_CON
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
    new_references.s_control_num := x_s_control_num;
    new_references.census_dt_alias := x_census_dt_alias;
    new_references.crs_completion_cutoff_dt_alias := crs_completion_cutoff_dt_alias;
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as

	v_message_name varchar2(30);
  BEGIN
	-- Validate the date alias values.
	-- IGS_PS_COURSE Completion Cutoff Date Alias.
	IF p_inserting OR
			((NVL(old_references.crs_completion_cutoff_dt_alias, 'NULL') <>
				NVL(new_references.crs_completion_cutoff_dt_alias, 'NULL')) AND
			new_references.crs_completion_cutoff_dt_alias IS NOT NULL) THEN
	NULL;
	END IF;
	-- Census Date Alias.
	IF p_inserting OR
			(NVL(old_references.census_dt_alias, 'NULL') <>
				NVL(new_references.census_dt_alias, 'NULL')) THEN
	NULL;
	END IF;
  END BeforeRowInsertUpdate1;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 )as
  BEGIN
	IF column_name is null then
	   NULL;
	ELSIF upper(Column_name) = 'S_CONTROL_NUM' then
		new_references.S_CONTROL_NUM := column_value;
	ELSIF upper(Column_name) = 'CENSUS_DT_ALIAS' then
		new_references.census_dt_alias := column_value;
	ELSIF upper(Column_name) = 'CRS_COMPLETION_CUTOFF_DT_ALIAS' then
		new_references.CRS_COMPLETION_CUTOFF_DT_ALIAS := column_value;
	END IF;
	IF upper(Column_name) = 'CENSUS_DT_ALIAS' OR column_name is null then
		IF new_references.census_dt_alias<> UPPER(new_references.census_dt_alias) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_name) = 'CRS_COMPLETION_CUTOFF_DT_ALIAS' OR column_name is null then
		IF new_references.CRS_COMPLETION_CUTOFF_DT_ALIAS<> UPPER(new_references.CRS_COMPLETION_CUTOFF_DT_ALIAS) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_name) = 'S_CONTROL_NUM' OR column_name is null then
		IF new_references.s_control_num <> 1 THEN
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.census_dt_alias = new_references.census_dt_alias)) OR
        ((new_references.census_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.census_dt_alias
	   ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.crs_completion_cutoff_dt_alias = new_references.crs_completion_cutoff_dt_alias)) OR
        ((new_references.crs_completion_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.crs_completion_cutoff_dt_alias
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_s_control_num IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_GEN_CAL_CON
      WHERE    s_control_num = x_s_control_num
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

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_GEN_CAL_CON
      WHERE    census_dt_alias = x_dt_alias
	OR crs_completion_cutoff_dt_alias = x_dt_alias ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_SGCC_DA_CENSUS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_census_dt_alias IN VARCHAR2 DEFAULT NULL,
    crs_completion_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_census_dt_alias,
      crs_completion_cutoff_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(new_references.s_control_num)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
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
	IF Get_PK_For_Validation(new_references.s_control_num)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML
;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
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
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_GE_S_GEN_CAL_CON
      where S_CONTROL_NUM = NEW_REFERENCES.S_CONTROL_NUM;
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
    x_s_control_num => NVL(X_S_CONTROL_NUM,1),
    x_census_dt_alias => X_CENSUS_DT_ALIAS,
    crs_completion_cutoff_dt_alias => crs_completion_cutoff_dt_ali,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

   insert into IGS_GE_S_GEN_CAL_CON (
    S_CONTROL_NUM,
    CENSUS_DT_ALIAS,
    CRS_COMPLETION_CUTOFF_DT_ALIAS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.S_CONTROL_NUM,
    NEW_REFERENCES.CENSUS_DT_ALIAS,
    NEW_REFERENCES.CRS_COMPLETION_CUTOFF_DT_ALIAS,
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

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  X_CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2
) as
  cursor c1 is select
      CENSUS_DT_ALIAS,
      CRS_COMPLETION_CUTOFF_DT_ALIAS
    from IGS_GE_S_GEN_CAL_CON
        where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.CENSUS_DT_ALIAS = X_CENSUS_DT_ALIAS)
      AND ((tlinfo.CRS_COMPLETION_CUTOFF_DT_ALIAS = X_CRS_COMPLETION_CUTOFF_DT_ALI)
           OR ((tlinfo.CRS_COMPLETION_CUTOFF_DT_ALIAS is null)
               AND (X_CRS_COMPLETION_CUTOFF_DT_ALI is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
    x_s_control_num => X_S_CONTROL_NUM,
    x_census_dt_alias => X_CENSUS_DT_ALIAS,
    crs_completion_cutoff_dt_alias => CRS_COMPLETION_CUTOFF_DT_ALI,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);
  update IGS_GE_S_GEN_CAL_CON set
    CENSUS_DT_ALIAS =   NEW_REFERENCES.CENSUS_DT_ALIAS,
    CRS_COMPLETION_CUTOFF_DT_ALIAS =   NEW_REFERENCES.CRS_COMPLETION_CUTOFF_DT_ALIAS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
        where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
);
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_CENSUS_DT_ALIAS in VARCHAR2,
  X_CRS_COMPLETION_CUTOFF_DT_ALI in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_GE_S_GEN_CAL_CON
     where S_CONTROL_NUM = NVL(X_S_CONTROL_NUM,1)
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_CONTROL_NUM,
     X_CENSUS_DT_ALIAS,
     X_CRS_COMPLETION_CUTOFF_DT_ALI,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_CONTROL_NUM,
   X_CENSUS_DT_ALIAS,
   X_CRS_COMPLETION_CUTOFF_DT_ALI,
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
  delete from IGS_GE_S_GEN_CAL_CON
      where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_GE_S_GEN_CAL_CON_PKG;

/
