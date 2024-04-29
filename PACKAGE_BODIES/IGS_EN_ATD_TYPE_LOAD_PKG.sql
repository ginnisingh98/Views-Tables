--------------------------------------------------------
--  DDL for Package Body IGS_EN_ATD_TYPE_LOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ATD_TYPE_LOAD_PKG" AS
/* $Header: IGSEI19B.pls 120.1 2005/09/08 14:28:01 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_ATD_TYPE_LOAD_ALL%RowType;
  new_references IGS_EN_ATD_TYPE_LOAD_ALL%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_lower_enr_load_range IN NUMBER DEFAULT NULL,
    x_upper_enr_load_range IN NUMBER DEFAULT NULL,
    x_default_eftsu IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ATD_TYPE_LOAD_ALL
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
    new_references.org_id := x_org_id;
    new_references.cal_type := x_cal_type;
    new_references.attendance_type := x_attendance_type;
    new_references.lower_enr_load_range := x_lower_enr_load_range;
    new_references.upper_enr_load_range := x_upper_enr_load_range;
    new_references.default_eftsu := x_default_eftsu;
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
	v_message_name		varchar2(30);
  BEGIN
	-- Validate that inserts/updates are allowed
	IF  p_inserting OR p_updating THEN
	    IF	IGS_AD_VAL_APCOO.CRSP_VAL_ATT_CLOSED(new_references.attendance_type
						,v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
	    END IF;
	    IF	IGS_PS_VAL_ATL.CRSP_VAL_ATL_CAT(new_references.cal_type
						,v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
	    END IF;
	END IF;


  END BeforeRowInsertUpdate1;
  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate attendance type load.
	-- Cannot call crsp_val_atl_range because trigger may be mutating.
	-- Save the rowid of the current row.
	-- Perform validation processing on all the rows affected by the statement.
	-- Validate attendance type load range.
	IF IGS_PS_VAL_ATL.crsp_val_atl_range (new_references.attendance_type,
			new_references.cal_type,
			new_references.lower_enr_load_range,
			new_references.upper_enr_load_range,
			v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
	END IF;
	v_rowid_saved := TRUE;
  END AfterRowInsertUpdate2;

procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
	   NULL;
	ELSIF upper(column_name) = 'UPPER_ENR_LOAD_RANGE' then
		new_references.upper_enr_load_range := igs_ge_number.to_num(column_value);
	ELSIF upper(column_name) = 'LOWER_ENR_LOAD_RANGE' then
		new_references.lower_enr_load_range := igs_ge_number.to_num(column_value);
	ELSIF upper(column_name) = 'ATTENDANCE_TYPE' then
		new_references.attendance_type := column_value;
	ELSIF upper(column_name) = 'CAL_TYPE' then
		new_references.cal_type := column_value;
	END IF;

	IF upper(column_name) = 'UPPER_ENR_LOAD_RANGE' OR
	 column_name is null then
	    if  new_references.upper_enr_load_range <0 OR
	     new_references.upper_enr_load_range > 999.999 then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	 App_Exception.Raise_Exception;
	     end if;
	end if;
	IF upper(column_name) = 'LOWER_ENR_LOAD_RANGE' OR
	 column_name is null then
	   if  new_references.lower_enr_load_range<0 OR
 		new_references.lower_enr_load_range >999.999 then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	 App_Exception.Raise_Exception;
	     end if;
	end if;
	IF upper(column_name) = 'ATTENDANCE_TYPE'  OR
	 column_name is null then
	   if new_references.attendance_type <> upper(new_references.attendance_type) then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	 App_Exception.Raise_Exception;
	     end if;
	end if;
	IF upper(column_name) = 'CAL_TYPE'  OR
	 column_name is null then
	   if new_references.cal_type <> upper(new_references.cal_type) then
	         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	 App_Exception.Raise_Exception;
	     end if;
	end if;
END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        ) THEN
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     end if;
    END IF;

    IF (((old_references.cal_type = new_references.cal_type)) OR
        ((new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.cal_type
        ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      end if;
    END IF;

  END Check_Parent_Existance;

 FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ATD_TYPE_LOAD_ALL
      WHERE    cal_type = x_cal_type
      AND      attendance_type = x_attendance_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ATD_TYPE_LOAD_ALL
      WHERE    attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ATL_ATT_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    )AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ATD_TYPE_LOAD_ALL
      WHERE    cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ATL_CAT_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_lower_enr_load_range IN NUMBER DEFAULT NULL,
    x_upper_enr_load_range IN NUMBER DEFAULT NULL,
    x_default_eftsu IN NUMBER DEFAULT NULL,
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
      x_org_id,
      x_cal_type,
      x_attendance_type,
      x_lower_enr_load_range,
      x_upper_enr_load_range,
      x_default_eftsu,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
 	   new_references.cal_type ,
  	   new_references.attendance_type
    	) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
 	   new_references.cal_type ,
  	   new_references.attendance_type
    	) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
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
  X_ORG_ID in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ATD_TYPE_LOAD_ALL
      where CAL_TYPE = X_CAL_TYPE
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE;
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
    x_org_id => igs_ge_gen_003.get_org_id,
    x_cal_type => X_CAL_TYPE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_lower_enr_load_range => X_LOWER_ENR_LOAD_RANGE,
    x_upper_enr_load_range => X_UPPER_ENR_LOAD_RANGE,
    x_default_eftsu => X_DEFAULT_EFTSU,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_EN_ATD_TYPE_LOAD_ALL (
    org_id,
    CAL_TYPE,
    ATTENDANCE_TYPE,
    LOWER_ENR_LOAD_RANGE,
    UPPER_ENR_LOAD_RANGE,
    DEFAULT_EFTSU,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.LOWER_ENR_LOAD_RANGE,
    NEW_REFERENCES.UPPER_ENR_LOAD_RANGE,
    NEW_REFERENCES.DEFAULT_EFTSU,
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
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER
) AS
  cursor c1 is select
      LOWER_ENR_LOAD_RANGE,
      UPPER_ENR_LOAD_RANGE,
      DEFAULT_EFTSU
    from IGS_EN_ATD_TYPE_LOAD_ALL
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

  if ( (tlinfo.LOWER_ENR_LOAD_RANGE = X_LOWER_ENR_LOAD_RANGE)
      AND (tlinfo.UPPER_ENR_LOAD_RANGE = X_UPPER_ENR_LOAD_RANGE)
      AND ((tlinfo.DEFAULT_EFTSU = X_DEFAULT_EFTSU)
           OR ((tlinfo.DEFAULT_EFTSU is null)
               AND (X_DEFAULT_EFTSU is null)))
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
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
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
    x_cal_type => X_CAL_TYPE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_lower_enr_load_range => X_LOWER_ENR_LOAD_RANGE,
    x_upper_enr_load_range => X_UPPER_ENR_LOAD_RANGE,
    x_default_eftsu => X_DEFAULT_EFTSU,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_ATD_TYPE_LOAD_ALL set
    LOWER_ENR_LOAD_RANGE = NEW_REFERENCES.LOWER_ENR_LOAD_RANGE,
    UPPER_ENR_LOAD_RANGE = NEW_REFERENCES.UPPER_ENR_LOAD_RANGE,
    DEFAULT_EFTSU = NEW_REFERENCES.DEFAULT_EFTSU,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
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
  X_ORG_ID in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_LOWER_ENR_LOAD_RANGE in NUMBER,
  X_UPPER_ENR_LOAD_RANGE in NUMBER,
  X_DEFAULT_EFTSU in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ATD_TYPE_LOAD_ALL
     where CAL_TYPE = X_CAL_TYPE
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     x_org_id,
     X_CAL_TYPE,
     X_ATTENDANCE_TYPE,
     X_LOWER_ENR_LOAD_RANGE,
     X_UPPER_ENR_LOAD_RANGE,
     X_DEFAULT_EFTSU,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_TYPE,
   X_ATTENDANCE_TYPE,
   X_LOWER_ENR_LOAD_RANGE,
   X_UPPER_ENR_LOAD_RANGE,
   X_DEFAULT_EFTSU,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (X_ROWID in VARCHAR2
) AS
begin
  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_ATD_TYPE_LOAD_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_EN_ATD_TYPE_LOAD_PKG;

/
