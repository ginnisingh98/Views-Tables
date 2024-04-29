--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_OFFCNT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_OFFCNT_PKG" AS
/* $Header: IGSCI08B.pls 120.1 2006/01/25 09:17:52 skpandey noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_DA_OFFCNT%RowType;
  new_references IGS_CA_DA_OFFCNT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_s_dt_offset_constraint_type IN VARCHAR2 DEFAULT NULL,
    x_constraint_condition IN VARCHAR2 DEFAULT NULL,
    x_constraint_resolution IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS


    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA_OFFCNT
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
    new_references.dt_alias := x_dt_alias;
    new_references.offset_dt_alias := x_offset_dt_alias;
    new_references.s_dt_offset_constraint_type := x_s_dt_offset_constraint_type;
    new_references.constraint_condition := x_constraint_condition;
    new_references.constraint_resolution := x_constraint_resolution;
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
  -- "OSS_TST".trg_daoc_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_CA_DA_OFFCNT
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name  varchar2(30);
  BEGIN
	IF p_inserting
	THEN
		-- Validate constraint type is not closed.
		IF IGS_CA_VAL_DAIOC.calp_val_sdoct_clsd(
					new_references.s_dt_offset_constraint_type,
					v_message_name) = FALSE
		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_daoc_as_iu
  -- AFTER INSERT OR UPDATE
  -- ON IGS_CA_DA_OFFCNT

  PROCEDURE AfterStmtInsertUpdate3(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
  	-- Validate the dt alias offset constraint.
  	IF p_inserting or p_updating THEN
  		IF IGS_CA_VAL_DAIOC.calp_val_sdoct_clash (new_references.dt_alias,
  		    	              new_references.offset_dt_alias,
  			              null, null, null, null, null, null,
  			              new_references.s_dt_offset_constraint_type,
  			              new_references.constraint_condition,
  			              new_references.constraint_resolution,
  			              v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  	END IF;
  END AfterStmtInsertUpdate3;

  PROCEDURE Check_Constraints (
    column_name  IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL) AS
  BEGIN
  		IF column_name is null then
			null;
		ELSIF upper(Column_name)= 'CONSTRAINT_CONDITION' Then
			new_references.constraint_condition := column_value;
		ELSIF upper(column_name) = 'CONSTRAINT_RESOLUTION' Then
			new_references.constraint_resolution := igs_ge_number.to_num(column_value);
		ELSIF upper(column_name) = 'DT_ALIAS' Then
			new_references.dt_alias := column_value;
		ELSIF upper(column_name) = 'OFFSET_DT_ALIAS' Then
			new_references.offset_dt_alias := column_value;
		ELSIF upper(column_name) = 'S_DT_OFFSET_CONSTRAINT_TYPE' Then
			new_references.s_dt_offset_constraint_type := column_value;
		End if;

		If upper(Column_name)= 'CONSTRAINT_CONDITION' Or column_name is null then
			if new_references.constraint_condition NOT IN ( 'MUST' , 'MUST NOT' )Then
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
        		App_Exception.Raise_Exception;
			End if;
		End if;

		If upper(Column_name)= 'CONSTRAINT_RESOLUTION' Or column_name is null then
			If new_references.constraint_resolution < -9 or new_references.constraint_resolution > 9 Then
					  Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
					  IGS_GE_MSG_STACK.ADD;
        			  App_Exception.Raise_Exception;
			End if;
		End if;

		If upper(Column_name)= 'DT_ALIAS' Or column_name is null then
			If UPPER(new_references.dt_alias) <> new_references.dt_alias Then
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
        		App_Exception.Raise_Exception;
			End if;
		End if;

		If upper(Column_name)= 'OFFSET_DT_ALIAS' Or column_name is null then
			If UPPER(new_references.offset_dt_alias) <> new_references.offset_dt_alias Then
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
        		App_Exception.Raise_Exception;
			End if;
		End if;

		If upper(Column_name)= 'S_DT_OFFSET_CONSTRAINT_TYPE' Or column_name is null then
			If UPPER(new_references.s_dt_offset_constraint_type) <> new_references.s_dt_offset_constraint_type Then
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
        		App_Exception.Raise_Exception;
			End if;
		End if;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.offset_dt_alias = new_references.offset_dt_alias)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.offset_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      If NOT IGS_CA_DA_OFST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.offset_dt_alias
        ) Then
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
      END IF;
   END IF;
    IF (((old_references.s_dt_offset_constraint_type = new_references.s_dt_offset_constraint_type)) OR
        ((new_references.s_dt_offset_constraint_type IS NULL))) THEN
      NULL;
    ELSE
      If NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	 'DT_OFFSET_CONSTRAINT_TYPE',
        new_references.s_dt_offset_constraint_type
        ) Then
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
       END IF;
    END IF;
  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_offset_dt_alias IN VARCHAR2,
    x_s_dt_offset_constraint_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_OFFCNT
      WHERE    dt_alias = x_dt_alias
      AND      offset_dt_alias = x_offset_dt_alias
      AND      s_dt_offset_constraint_type = x_s_dt_offset_constraint_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
	Else
	  Close cur_rowid;
	  Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

--skpandey; Bug#3686538: Stubbed as a part of query optimization
  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_dt_offset_constraint_type IN VARCHAR2
    ) AS
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;


  PROCEDURE GET_FK_IGS_CA_DA_OFST (
    x_dt_alias IN VARCHAR2,
    x_offset_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_OFFCNT
      WHERE    dt_alias = x_dt_alias
      AND      offset_dt_alias = x_offset_dt_alias ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAOC_DAO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_OFST;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_offset_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_s_dt_offset_constraint_type IN VARCHAR2 DEFAULT NULL,
    x_constraint_condition IN VARCHAR2 DEFAULT NULL,
    x_constraint_resolution IN NUMBER DEFAULT NULL,
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
      x_dt_alias,
      x_offset_dt_alias,
      x_s_dt_offset_constraint_type,
      x_constraint_condition,
      x_constraint_resolution,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      if get_pk_for_validation(
    		new_references.dt_alias ,
    		new_references.offset_dt_alias ,
    		new_references.s_dt_offset_constraint_type
    		) Then
		fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
	  end if;
	  check_constraints;
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
		if get_pk_for_validation(
		    		new_references.dt_alias ,
		    		new_references.offset_dt_alias ,
		    		new_references.s_dt_offset_constraint_type
		    		) Then
				fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
				IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
        end if;
	    check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	  Check_Constraints;
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
      AfterStmtInsertUpdate3 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdate3 ( p_updating => TRUE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_DA_OFFCNT
      where DT_ALIAS = X_DT_ALIAS
      and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
      and S_DT_OFFSET_CONSTRAINT_TYPE = X_S_DT_OFFSET_CONSTRAINT_TYPE;
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_s_dt_offset_constraint_type =>X_S_DT_OFFSET_CONSTRAINT_TYPE,
    x_constraint_condition =>X_CONSTRAINT_CONDITION,
    x_constraint_resolution =>X_CONSTRAINT_RESOLUTION,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_DA_OFFCNT (
    DT_ALIAS,
    OFFSET_DT_ALIAS,
    S_DT_OFFSET_CONSTRAINT_TYPE,
    CONSTRAINT_CONDITION,
    CONSTRAINT_RESOLUTION,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.OFFSET_DT_ALIAS,
    NEW_REFERENCES.S_DT_OFFSET_CONSTRAINT_TYPE,
    NEW_REFERENCES.CONSTRAINT_CONDITION,
    NEW_REFERENCES.CONSTRAINT_RESOLUTION,
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER
) AS
  cursor c1 is select
	DT_ALIAS,
  	OFFSET_DT_ALIAS,
  	S_DT_OFFSET_CONSTRAINT_TYPE,
      CONSTRAINT_CONDITION,
      CONSTRAINT_RESOLUTION
    from IGS_CA_DA_OFFCNT
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

  if (( tlinfo.DT_ALIAS=X_DT_ALIAS)
  	AND (tlinfo.OFFSET_DT_ALIAS=X_OFFSET_DT_ALIAS)
  	AND (tlinfo.S_DT_OFFSET_CONSTRAINT_TYPE=X_S_DT_OFFSET_CONSTRAINT_TYPE)
	AND (tlinfo.CONSTRAINT_CONDITION = X_CONSTRAINT_CONDITION)
      AND (tlinfo.CONSTRAINT_RESOLUTION = X_CONSTRAINT_RESOLUTION)
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
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
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
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_dt_alias =>X_DT_ALIAS,
    x_offset_dt_alias =>X_OFFSET_DT_ALIAS,
    x_s_dt_offset_constraint_type =>X_S_DT_OFFSET_CONSTRAINT_TYPE,
    x_constraint_condition =>X_CONSTRAINT_CONDITION,
    x_constraint_resolution =>X_CONSTRAINT_RESOLUTION,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_DA_OFFCNT set
    CONSTRAINT_CONDITION = NEW_REFERENCES.CONSTRAINT_CONDITION,
    CONSTRAINT_RESOLUTION = NEW_REFERENCES.CONSTRAINT_RESOLUTION,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID
  );


end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_OFFSET_DT_ALIAS in VARCHAR2,
  X_S_DT_OFFSET_CONSTRAINT_TYPE in VARCHAR2,
  X_CONSTRAINT_CONDITION in VARCHAR2,
  X_CONSTRAINT_RESOLUTION in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_DA_OFFCNT
     where DT_ALIAS = X_DT_ALIAS
     and OFFSET_DT_ALIAS = X_OFFSET_DT_ALIAS
     and S_DT_OFFSET_CONSTRAINT_TYPE = X_S_DT_OFFSET_CONSTRAINT_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DT_ALIAS,
     X_OFFSET_DT_ALIAS,
     X_S_DT_OFFSET_CONSTRAINT_TYPE,
     X_CONSTRAINT_CONDITION,
     X_CONSTRAINT_RESOLUTION,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DT_ALIAS,
   X_OFFSET_DT_ALIAS,
   X_S_DT_OFFSET_CONSTRAINT_TYPE,
   X_CONSTRAINT_CONDITION,
   X_CONSTRAINT_RESOLUTION,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA_OFFCNT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );

end DELETE_ROW;

end IGS_CA_DA_OFFCNT_PKG;

/
