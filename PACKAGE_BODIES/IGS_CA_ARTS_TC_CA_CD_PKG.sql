--------------------------------------------------------
--  DDL for Package Body IGS_CA_ARTS_TC_CA_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_ARTS_TC_CA_CD_PKG" AS
/* $Header: IGSCI01B.pls 115.3 2002/11/28 22:59:23 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_ARTS_TC_CA_CD%RowType;
  new_references IGS_CA_ARTS_TC_CA_CD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_arts_teaching_cal_type_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_ARTS_TC_CA_CD
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
    new_references.arts_teaching_cal_type_cd := x_arts_teaching_cal_type_cd;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
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


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_CA_TYPE_PKG.GET_FK_IGS_CA_ARTS_TC_CA_CD (
      old_references.arts_teaching_cal_type_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_arts_teaching_cal_type_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_ARTS_TC_CA_CD
      WHERE    arts_teaching_cal_type_cd = x_arts_teaching_cal_type_cd
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

PROCEDURE Check_Constraints (
	Column_Name	    IN  VARCHAR2		DEFAULT NULL,
	Column_Value    IN  VARCHAR2		DEFAULT NULL
				) AS
		BEGIN
			IF  column_name is null then
                        NULL;
                  ELSIF UPPER(column_name) = 'CLOSED_IND' Then
				new_references.closed_ind := column_value;
			Elsif UPPER(column_name) = 'ARTS_TEACHING_CAL_TYPE_CD' Then
				new_references.arts_teaching_cal_type_cd := column_value;
			end if;
			If upper(column_name) = 'CLOSED_IND' or column_name is null Then
				if new_references.closed_ind not in ('Y', 'N') then
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
				end if;
			end if;
			if upper(column_name) = 'ARTS_TEACHING_CAL_TYPE_CD'  or column_name is null Then
				if new_references.arts_teaching_cal_type_cd   <> upper(new_references.arts_teaching_cal_type_cd ) then
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
				end if;
			end if;

END Check_Constraints;


PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_arts_teaching_cal_type_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE  DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_arts_teaching_cal_type_cd,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       IF  Get_PK_For_Validation ( new_references.arts_teaching_cal_type_cd ) THEN
  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
  		IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;
	 END IF;
	Check_Constraints;
      ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation ( new_references.arts_teaching_cal_type_cd ) THEN
  		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
  		IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
    	ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
      ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
   END IF;

  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_ARTS_TC_CA_CD
      where ARTS_TEACHING_CAL_TYPE_CD = X_ARTS_TEACHING_CAL_TYPE_CD;
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
    x_arts_teaching_cal_type_cd =>X_ARTS_TEACHING_CAL_TYPE_CD,
    x_description =>X_DESCRIPTION,
    x_closed_ind =>NVL(X_CLOSED_IND,'N'),
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_ARTS_TC_CA_CD (
    ARTS_TEACHING_CAL_TYPE_CD,
    DESCRIPTION,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ARTS_TEACHING_CAL_TYPE_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CLOSED_IND,
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
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      CLOSED_IND
    from IGS_CA_ARTS_TC_CA_CD
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_ROWID in  VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
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
    x_arts_teaching_cal_type_cd =>X_ARTS_TEACHING_CAL_TYPE_CD,
    x_description =>X_DESCRIPTION,
    x_closed_ind =>X_CLOSED_IND,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  update IGS_CA_ARTS_TC_CA_CD set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_ARTS_TC_CA_CD
     where ARTS_TEACHING_CAL_TYPE_CD = X_ARTS_TEACHING_CAL_TYPE_CD
  ;
  begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ARTS_TEACHING_CAL_TYPE_CD,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ARTS_TEACHING_CAL_TYPE_CD,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW(X_ROWID in  VARCHAR2) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_ARTS_TC_CA_CD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_CA_ARTS_TC_CA_CD_PKG;

/
