--------------------------------------------------------
--  DDL for Package Body IGS_CA_DA_PAIR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_DA_PAIR_PKG" AS
/* $Header: IGSCI10B.pls 115.4 2002/11/28 23:01:56 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_DA_PAIR%RowType;
  new_references IGS_CA_DA_PAIR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_related_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_DA_PAIR
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
    new_references.related_dt_alias := x_related_dt_alias;
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
  -- "OSS_TST".trg_dap_br_i
  -- BEFORE INSERT
  -- ON IGS_CA_DA_PAIR
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name  varchar2(30);
  BEGIN
	-- Validate that the related_dt_alias is not closed
	IF IGS_CA_VAL_DAP.calp_val_dap_da(
		new_references.related_dt_alias,
		v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;



  END BeforeRowInsert1;

  PROCEDURE Check_Constraints (
      column_name  IN VARCHAR2 DEFAULT NULL,
      column_value IN VARCHAR2 DEFAULT NULL)
  AS
   BEGIN

    	IF column_name is null then
  			null;
  		ELSIF upper(column_name) = 'RELATED_DT_ALIAS' Then
  			new_references.related_dt_alias := column_value;
  		ELSIF upper(column_name) = 'DT_ALIAS' Then
  			new_references.dt_alias := column_value;
   		End if;

  		If upper(Column_name)= 'RELATED_DT_ALIAS' Or column_name is null then
		  			If UPPER(new_references.related_dt_alias) <> new_references.related_dt_alias Then
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

  		If  column_name is null then
  			If new_references.related_dt_alias = new_references.dt_alias Then
  				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
  				IGS_GE_MSG_STACK.ADD;
          		App_Exception.Raise_Exception;
  			End if;
  		End if;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.dt_alias = new_references.dt_alias)) OR
        ((new_references.dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.dt_alias
        )  Then
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
       END IF;
    END IF;

    IF (((old_references.related_dt_alias = new_references.related_dt_alias)) OR
        ((new_references.related_dt_alias IS NULL))) THEN
      NULL;
    ELSE
        IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.related_dt_alias
        )  Then
		fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
        END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_dt_alias IN VARCHAR2,
    x_related_dt_alias IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_PAIR
      WHERE    dt_alias = x_dt_alias
      AND      related_dt_alias = x_related_dt_alias
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

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_DA_PAIR
      WHERE    dt_alias = x_dt_alias
	OR	   related_dt_alias = x_dt_alias;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_DAP_DA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_related_dt_alias IN VARCHAR2 DEFAULT NULL,
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
      x_related_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	   BeforeRowInsert1 ( p_inserting => TRUE );
	        if get_pk_for_validation(
                 new_references.dt_alias ,
   				 new_references.related_dt_alias
	      		) Then
	  		fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	  		IGS_GE_MSG_STACK.ADD;
	  		app_exception.raise_exception;
	  	  end if;
	  check_constraints;
	  Check_Parent_Existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;

	   ELSIF (p_action = 'VALIDATE_INSERT') THEN
	   	  		if get_pk_for_validation(
	       			  new_references.dt_alias ,
   				 new_references.related_dt_alias
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

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_RELATED_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_DA_PAIR
    where DT_ALIAS = X_DT_ALIAS
    and RELATED_DT_ALIAS = X_RELATED_DT_ALIAS;
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
    x_related_dt_alias =>X_RELATED_DT_ALIAS,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_DA_PAIR (
    DT_ALIAS,
    RELATED_DT_ALIAS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.RELATED_DT_ALIAS,
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
  X_DT_ALIAS in VARCHAR2,
  X_RELATED_DT_ALIAS in VARCHAR2
) AS
  cursor c1 is select ROWID
    from IGS_CA_DA_PAIR
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
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_DA_PAIR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_CA_DA_PAIR_PKG;

/
