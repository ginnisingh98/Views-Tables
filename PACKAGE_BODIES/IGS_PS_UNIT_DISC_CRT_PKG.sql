--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_DISC_CRT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_DISC_CRT_PKG" as
/* $Header: IGSPI78B.pls 115.6 2003/10/30 13:31:28 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_UNIT_DISC_CRT%RowType;
  new_references IGS_PS_UNIT_DISC_CRT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_discont_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_delete_ind IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_DISC_CRT
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
    new_references.unit_discont_dt_alias := x_unit_discont_dt_alias;
    new_references.administrative_unit_status := x_administrative_unit_status;
    new_references.delete_ind := x_delete_ind;
    new_references.dflt_ind := x_dflt_ind;
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
    ) AS
	v_message_name		Varchar2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_AUS_CLOSED(new_references.administrative_unit_status
						,v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_AUS_DISCONT(new_references.administrative_unit_status,
					v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_TEACHING_DA(new_references.unit_discont_dt_alias,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	    END IF;
	    IF	IGS_EN_VAL_UDDC.ENRP_VAL_UDDC_FIELDS(new_references.administrative_unit_status						,new_references.delete_ind
			,v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	    END IF;
	END IF;


  END BeforeRowInsertUpdate1;

PROCEDURE Check_Constraints(
				Column_Name 	IN	VARCHAR2	DEFAULT NULL,
				Column_Value 	IN	VARCHAR2	DEFAULT NULL)
AS
BEGIN

	IF Column_Name IS NULL Then
		NULL;
	ELSIF Upper(Column_Name)='ADMINISTRATIVE_UNIT_STATUS' Then
		New_References.administrative_unit_status := Column_Value;
	ELSIF Upper(Column_Name)='UNIT_DISCONT_DT_ALIAS' Then
		New_References.unit_discont_dt_alias := Column_Value;
	ELSIF Upper(Column_Name)='DFLT_IND' Then
		New_References.dflt_ind := Column_Value;
	ELSIF Upper(Column_Name)='DELETE_IND' Then
		New_References.delete_ind := Column_Value;
	END IF;

	IF Upper(Column_Name)='ADMINISTRATIVE_UNIT_STATUS' OR Column_Name IS NULL Then
		IF New_References.administrative_unit_status <> UPPER(New_References.administrative_unit_status) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='UNIT_DISCONT_DT_ALIAS' OR Column_Name IS NULL Then
		IF New_References.unit_discont_dt_alias <> UPPER(New_References.unit_discont_dt_alias) Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='DFLT_IND' OR Column_Name IS NULL Then
		IF New_References.dflt_ind NOT IN ('Y','N') Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF Upper(Column_Name)='DELETE_IND' OR Column_Name IS NULL Then
		IF New_References.delete_ind NOT IN ('Y','N') Then
			        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
		END IF;
	END IF;

END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.administrative_unit_status = new_references.administrative_unit_status)) OR
        ((new_references.administrative_unit_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_ADM_UNIT_STAT_PKG.Get_PK_For_Validation (new_references.administrative_unit_status , 'N') THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.unit_discont_dt_alias = new_references.unit_discont_dt_alias)) OR
        ((new_references.unit_discont_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (new_references.unit_discont_dt_alias) THEN
				  Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
			        App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_discont_dt_alias IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_DISC_CRT
      WHERE    unit_discont_dt_alias = x_unit_discont_dt_alias
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
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_UNIT_DISC_CRT
      WHERE    unit_discont_dt_alias = x_dt_alias ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UDDC_DA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_discont_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_administrative_unit_status IN VARCHAR2 DEFAULT NULL,
    x_delete_ind IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
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
      x_unit_discont_dt_alias,
      x_administrative_unit_status,
      x_delete_ind,
      x_dflt_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	 IF Get_PK_For_Validation (New_References.unit_discont_dt_alias) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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

ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation (New_References.unit_discont_dt_alias) THEN
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
  X_UNIT_DISCONT_DT_ALIAS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_UNIT_DISC_CRT
      where UNIT_DISCONT_DT_ALIAS = X_UNIT_DISCONT_DT_ALIAS;
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
  x_rowid =>  X_ROWID,
  x_unit_discont_dt_alias => X_UNIT_DISCONT_DT_ALIAS,
  x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
  x_delete_ind => NVL(X_DELETE_IND,'N'),
  x_dflt_ind => NVL(X_DFLT_IND,'Y'),
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_PS_UNIT_DISC_CRT (
    UNIT_DISCONT_DT_ALIAS,
    ADMINISTRATIVE_UNIT_STATUS,
    DELETE_IND,
    DFLT_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.UNIT_DISCONT_DT_ALIAS,
    NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    NEW_REFERENCES.DELETE_IND,
    NEW_REFERENCES.DFLT_IND,
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
  X_ROWID IN VARCHAR2,
  X_UNIT_DISCONT_DT_ALIAS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_DFLT_IND in VARCHAR2
) AS
  cursor c1 is select
      ADMINISTRATIVE_UNIT_STATUS,
      DELETE_IND,
      DFLT_IND
    from IGS_PS_UNIT_DISC_CRT
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

      if ( ((tlinfo.ADMINISTRATIVE_UNIT_STATUS = X_ADMINISTRATIVE_UNIT_STATUS)
           OR ((tlinfo.ADMINISTRATIVE_UNIT_STATUS is null)
               AND (X_ADMINISTRATIVE_UNIT_STATUS is null)))
      AND (tlinfo.DELETE_IND = X_DELETE_IND)
      AND (tlinfo.DFLT_IND = X_DFLT_IND)
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
  X_ROWID IN VARCHAR2,
  X_UNIT_DISCONT_DT_ALIAS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
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
  x_rowid =>  X_ROWID,
  x_unit_discont_dt_alias => X_UNIT_DISCONT_DT_ALIAS,
  x_administrative_unit_status => X_ADMINISTRATIVE_UNIT_STATUS,
  x_delete_ind => X_DELETE_IND,
  x_dflt_ind => X_DFLT_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_PS_UNIT_DISC_CRT set
    ADMINISTRATIVE_UNIT_STATUS = NEW_REFERENCES.ADMINISTRATIVE_UNIT_STATUS,
    DELETE_IND = NEW_REFERENCES.DELETE_IND,
    DFLT_IND = NEW_REFERENCES.DFLT_IND,
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
  X_UNIT_DISCONT_DT_ALIAS in VARCHAR2,
  X_ADMINISTRATIVE_UNIT_STATUS in VARCHAR2,
  X_DELETE_IND in VARCHAR2,
  X_DFLT_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_UNIT_DISC_CRT
     where UNIT_DISCONT_DT_ALIAS = X_UNIT_DISCONT_DT_ALIAS
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_UNIT_DISCONT_DT_ALIAS,
     X_ADMINISTRATIVE_UNIT_STATUS,
     X_DELETE_IND,
     X_DFLT_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_UNIT_DISCONT_DT_ALIAS,
   X_ADMINISTRATIVE_UNIT_STATUS,
   X_DELETE_IND,
   X_DFLT_IND,
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
  delete from IGS_PS_UNIT_DISC_CRT
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_PS_UNIT_DISC_CRT_PKG;

/
