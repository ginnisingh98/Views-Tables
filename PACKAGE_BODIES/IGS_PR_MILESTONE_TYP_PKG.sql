--------------------------------------------------------
--  DDL for Package Body IGS_PR_MILESTONE_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_MILESTONE_TYP_PKG" AS
/* $Header: IGSQI03B.pls 115.4 2003/05/19 04:46:22 ijeddy ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PR_MILESTONE_TYP%RowType;
  new_references IGS_PR_MILESTONE_TYP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_ntfctn_imminent_days IN NUMBER DEFAULT NULL,
    x_ntfctn_reminder_days IN NUMBER DEFAULT NULL,
    x_ntfctn_re_reminder_days IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_MILESTONE_TYP
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.milestone_type := x_milestone_type;
    new_references.description := x_description;
    new_references.ntfctn_imminent_days := x_ntfctn_imminent_days;
    new_references.ntfctn_reminder_days := x_ntfctn_reminder_days;
    new_references.ntfctn_re_reminder_days := x_ntfctn_re_reminder_days;
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

  -- Trigger description :-
  -- "OSS_TST".trg_mty_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_MILESTONE_TYP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	IF p_inserting OR
	   (p_updating AND
	    (NVL(old_references.ntfctn_reminder_days,-1) <> NVL(new_references.ntfctn_reminder_days,-1) OR
	     NVL(old_references.ntfctn_re_reminder_days,-1) <>
					NVL(new_references.ntfctn_re_reminder_days,-1))) THEN
		IF IGS_RE_VAL_MTY.resp_val_mty_days(
					new_references.ntfctn_reminder_days,
					new_references.ntfctn_re_reminder_days,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_RE_DFLT_MS_SET_PKG.GET_FK_IGS_PR_MILESTONE_TYP (
      old_references.milestone_type
      );

    IGS_PR_MILESTONE_PKG.GET_FK_IGS_PR_MILESTONE_TYPE (
      old_references.milestone_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_milestone_type IN VARCHAR2
    )  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_MILESTONE_TYP
      WHERE    milestone_type = x_milestone_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close Cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_milestone_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_ntfctn_imminent_days IN NUMBER DEFAULT NULL,
    x_ntfctn_reminder_days IN NUMBER DEFAULT NULL,
    x_ntfctn_re_reminder_days IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_milestone_type,
      x_description,
      x_ntfctn_imminent_days,
      x_ntfctn_reminder_days,
      x_ntfctn_re_reminder_days,
      x_closed_ind,
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
         new_references.milestone_type
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
         new_references.milestone_type
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
       END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    END IF;

/*
The (L_ROWID := null) was added by ijeddy on the 12-apr-2003 as
part of the bug fix for bug no 2868726, (Uniqueness Check at Item Level)
*/

L_ROWID := null;

  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MILESTONE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_NTFCTN_REMINDER_DAYS in NUMBER,
  X_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PR_MILESTONE_TYP
      where MILESTONE_TYPE = X_MILESTONE_TYPE;
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
    x_rowid => x_rowid,
    x_milestone_type => x_milestone_type,
    x_description => x_description,
    x_ntfctn_imminent_days => x_ntfctn_imminent_days,
    x_ntfctn_reminder_days => x_ntfctn_reminder_days,
    x_ntfctn_re_reminder_days => x_ntfctn_re_reminder_days,
    x_closed_ind => nvl( x_closed_ind, 'N'),
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login
  );

  insert into IGS_PR_MILESTONE_TYP (
    MILESTONE_TYPE,
    DESCRIPTION,
    NTFCTN_IMMINENT_DAYS,
    NTFCTN_REMINDER_DAYS,
    NTFCTN_RE_REMINDER_DAYS,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.MILESTONE_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.NTFCTN_IMMINENT_DAYS,
    NEW_REFERENCES.NTFCTN_REMINDER_DAYS,
    NEW_REFERENCES.NTFCTN_RE_REMINDER_DAYS,
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
  X_MILESTONE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_NTFCTN_REMINDER_DAYS in NUMBER,
  X_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      NTFCTN_IMMINENT_DAYS,
      NTFCTN_REMINDER_DAYS,
      NTFCTN_RE_REMINDER_DAYS,
      CLOSED_IND
    from IGS_PR_MILESTONE_TYP
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.NTFCTN_IMMINENT_DAYS = X_NTFCTN_IMMINENT_DAYS)
           OR ((tlinfo.NTFCTN_IMMINENT_DAYS is null)
               AND (X_NTFCTN_IMMINENT_DAYS is null)))
      AND ((tlinfo.NTFCTN_REMINDER_DAYS = X_NTFCTN_REMINDER_DAYS)
           OR ((tlinfo.NTFCTN_REMINDER_DAYS is null)
               AND (X_NTFCTN_REMINDER_DAYS is null)))
      AND ((tlinfo.NTFCTN_RE_REMINDER_DAYS = X_NTFCTN_RE_REMINDER_DAYS)
           OR ((tlinfo.NTFCTN_RE_REMINDER_DAYS is null)
               AND (X_NTFCTN_RE_REMINDER_DAYS is null)))
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
  X_ROWID in VARCHAR2,
  X_MILESTONE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_NTFCTN_REMINDER_DAYS in NUMBER,
  X_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_CLOSED_IND in VARCHAR2,
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
    x_rowid => x_rowid,
    x_milestone_type => x_milestone_type,
    x_description => x_description,
    x_ntfctn_imminent_days => x_ntfctn_imminent_days,
    x_ntfctn_reminder_days => x_ntfctn_reminder_days,
    x_ntfctn_re_reminder_days => x_ntfctn_re_reminder_days,
    x_closed_ind => x_closed_ind,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login
  );


  update IGS_PR_MILESTONE_TYP set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    NTFCTN_IMMINENT_DAYS = NEW_REFERENCES.NTFCTN_IMMINENT_DAYS,
    NTFCTN_REMINDER_DAYS = NEW_REFERENCES.NTFCTN_REMINDER_DAYS,
    NTFCTN_RE_REMINDER_DAYS = NEW_REFERENCES.NTFCTN_RE_REMINDER_DAYS,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_MILESTONE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_NTFCTN_IMMINENT_DAYS in NUMBER,
  X_NTFCTN_REMINDER_DAYS in NUMBER,
  X_NTFCTN_RE_REMINDER_DAYS in NUMBER,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PR_MILESTONE_TYP
     where MILESTONE_TYPE = X_MILESTONE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_MILESTONE_TYPE,
     X_DESCRIPTION,
     X_NTFCTN_IMMINENT_DAYS,
     X_NTFCTN_REMINDER_DAYS,
     X_NTFCTN_RE_REMINDER_DAYS,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_MILESTONE_TYPE,
   X_DESCRIPTION,
   X_NTFCTN_IMMINENT_DAYS,
   X_NTFCTN_REMINDER_DAYS,
   X_NTFCTN_RE_REMINDER_DAYS,
   X_CLOSED_IND,
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

  delete from IGS_PR_MILESTONE_TYP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
) AS
BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'DESCRIPTION' THEN
  new_references.DESCRIPTION:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'MILESTONE_TYPE' THEN
  new_references.MILESTONE_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'NTFCTN_IMMINENT_DAYS' THEN
  new_references.NTFCTN_IMMINENT_DAYS:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'NTFCTN_REMINDER_DAYS' THEN
  new_references.NTFCTN_REMINDER_DAYS:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'NTFCTN_RE_REMINDER_DAYS' THEN
  new_references.NTFCTN_RE_REMINDER_DAYS:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'CLOSED_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CLOSED_IND<> upper(new_references.CLOSED_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.CLOSED_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;



IF upper(Column_name) = 'MILESTONE_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.MILESTONE_TYPE<> upper(new_references.MILESTONE_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NTFCTN_IMMINENT_DAYS' OR COLUMN_NAME IS NULL THEN
  IF new_references.NTFCTN_IMMINENT_DAYS < 0 or new_references.NTFCTN_IMMINENT_DAYS > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NTFCTN_REMINDER_DAYS' OR COLUMN_NAME IS NULL THEN
  IF new_references.NTFCTN_REMINDER_DAYS < 0 or new_references.NTFCTN_REMINDER_DAYS > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'NTFCTN_RE_REMINDER_DAYS' OR COLUMN_NAME IS NULL THEN
  IF new_references.NTFCTN_RE_REMINDER_DAYS < 0 or new_references.NTFCTN_RE_REMINDER_DAYS > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
END Check_Constraints;

end IGS_PR_MILESTONE_TYP_PKG;

/
