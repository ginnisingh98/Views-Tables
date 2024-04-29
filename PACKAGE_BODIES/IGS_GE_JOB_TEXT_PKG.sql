--------------------------------------------------------
--  DDL for Package Body IGS_GE_JOB_TEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_JOB_TEXT_PKG" as
/* $Header: IGSMI15B.pls 115.6 2002/11/29 01:12:55 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_GE_JOB_TEXT_ALL%RowType;
  new_references IGS_GE_JOB_TEXT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_job_execution_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_JOB_TEXT_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ( 'INSERT','VALIDATE_INSERT' )) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
    new_references.job_execution_name := x_job_execution_name;
    new_references.description := x_description;
    new_references.text := x_text;
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
    new_references.org_id := x_org_id;

  END Set_Column_Values;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) as
  BEGIN
   IF column_name is null then
	NULL;
-- ELSIF upper(Column_name) = 'DESCRIPTION' then
--	new_references.description := column_value ;
   ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
	new_references.SEQUENCE_NUMBER := column_value ;
   END IF;
--   IF upper(Column_name) = 'DESCRIPTION' OR column_name is null then
--	IF new_references.description <> UPPER(new_references.description ) then
--   	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
--   	    IGS_GE_MSG_STACK.ADD;
--	    App_Exception.Raise_Exception;
--	END IF;
--   END IF;
   IF upper(Column_name) = 'SEQUENCE_NUMBER' OR column_name is null then
	   IF new_references.sequence_number < 1 OR  new_references.sequence_number > 999999 then
       		Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       		IGS_GE_MSG_STACK.ADD;
		   App_Exception.Raise_Exception;
	   END IF ;
  END IF;
  END Check_Constraints;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_JOB_TEXT_ALL
      WHERE    sequence_number = x_sequence_number
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_job_execution_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_sequence_number,
      x_job_execution_name,
      x_description,
      x_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
		new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
		new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

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
  X_SEQUENCE_NUMBER in NUMBER,
  X_JOB_EXECUTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_GE_JOB_TEXT_ALL
      where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_job_execution_name => X_JOB_EXECUTION_NAME,
    x_description => X_DESCRIPTION,
    x_text => X_TEXT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_GE_JOB_TEXT_ALL (
    SEQUENCE_NUMBER,
    JOB_EXECUTION_NAME,
    DESCRIPTION,
    TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.JOB_EXECUTION_NAME,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.TEXT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
   x_rowid  => X_ROWID
 );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_JOB_EXECUTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT in VARCHAR2
) as
  cursor c1 is select
      JOB_EXECUTION_NAME,
      DESCRIPTION,
      TEXT
    from IGS_GE_JOB_TEXT_ALL
    where ROWID = X_ROWID
    for update  nowait;
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

  if ( (tlinfo.JOB_EXECUTION_NAME = X_JOB_EXECUTION_NAME)
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.TEXT = X_TEXT)
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_JOB_EXECUTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT in VARCHAR2,
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
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_job_execution_name => X_JOB_EXECUTION_NAME,
    x_description => X_DESCRIPTION,
    x_text => X_TEXT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_GE_JOB_TEXT_ALL set
    JOB_EXECUTION_NAME = NEW_REFERENCES.JOB_EXECUTION_NAME,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    TEXT = NEW_REFERENCES.TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
   p_action => 'UPDATE',
   x_rowid  => X_ROWID
 );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_JOB_EXECUTION_NAME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
  cursor c1 is select rowid from IGS_GE_JOB_TEXT_ALL
     where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SEQUENCE_NUMBER,
     X_JOB_EXECUTION_NAME,
     X_DESCRIPTION,
     X_TEXT,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SEQUENCE_NUMBER,
   X_JOB_EXECUTION_NAME,
   X_DESCRIPTION,
   X_TEXT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

Before_DML(
   p_action => 'DELETE',
   x_rowid  => X_ROWID
 );

  delete from IGS_GE_JOB_TEXT_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML(
   p_action => 'DELETE',
   x_rowid  => X_ROWID
 );

end DELETE_ROW;

end IGS_GE_JOB_TEXT_PKG;

/
