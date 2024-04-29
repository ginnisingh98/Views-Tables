--------------------------------------------------------
--  DDL for Package Body IGS_GE_S_LOG_ENTRY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_S_LOG_ENTRY_PKG" as
/* $Header: IGSMI11B.pls 120.1 2005/10/17 04:40:46 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --sarakshi    14-Oct-2005     Bug#4657596, changed the check_constraint such that UPPER is not checked for KEY
  -- kumma      13-JUN-2002     Removed Procedure GET_FK_IGS_ESSAGE, 2410165
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_GE_S_LOG_ENTRY%RowType;
  new_references IGS_GE_S_LOG_ENTRY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_log_type IN VARCHAR2 DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_key IN VARCHAR2 DEFAULT NULL,
    x_message_name IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_S_LOG_ENTRY
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
    new_references.s_log_type := x_s_log_type;
    new_references.creation_dt := x_creation_dt;
    new_references.sequence_number := x_sequence_number;
    new_references.key := x_key;
    new_references.message_name := x_message_name;
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

  END Set_Column_Values;

 PROCEDURE Check_Constraints(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
 ) as
  BEGIN

   IF column_name is null then
	NULL;
   ELSIF upper(Column_name) = 'S_LOG_TYPE' then
	new_references.s_log_type := column_value;
   END IF;
   IF upper(Column_name) = 'S_LOG_TYPE' OR column_name is null then
	IF new_references.s_log_type  <> UPPER(new_references.s_log_type) then
   	    Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
   	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
   END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.s_log_type = new_references.s_log_type) AND
         (old_references.creation_dt = new_references.creation_dt)) OR
        ((new_references.s_log_type IS NULL) OR
         (new_references.creation_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GE_S_LOG_PKG.Get_PK_For_Validation (
        new_references.s_log_type,
        new_references.creation_dt
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_s_log_type IN VARCHAR2,
    x_creation_dt IN DATE,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_LOG_ENTRY
      WHERE    s_log_type = x_s_log_type
      AND      creation_dt = x_creation_dt
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_GE_S_LOG (
    x_s_log_type IN VARCHAR2,
    x_creation_dt IN DATE
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_LOG_ENTRY
      WHERE    s_log_type = x_s_log_type
      AND      creation_dt = x_creation_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_SLE_LOG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GE_S_LOG;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_log_type IN VARCHAR2 DEFAULT NULL,
    x_creation_dt IN DATE DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_key IN VARCHAR2 DEFAULT NULL,
    x_message_name IN VARCHAR2 DEFAULT NULL,
    x_text IN VARCHAR2 DEFAULT NULL,
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
      x_s_log_type,
      x_creation_dt,
      x_sequence_number,
      x_key,
      x_message_name,
      x_text,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
		new_references.s_log_type,
	      new_references.creation_dt ,
	      new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
		new_references.s_log_type,
	      new_references.creation_dt ,
	      new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF	;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
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
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_GE_S_LOG_ENTRY
      where S_LOG_TYPE = X_S_LOG_TYPE
      and CREATION_DT = X_CREATION_DT
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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

    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := NULL;
      X_PROGRAM_ID := NULL;
      X_PROGRAM_APPLICATION_ID := NULL;
      X_PROGRAM_UPDATE_DATE := NULL;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;

  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_s_log_type => X_S_LOG_TYPE,
    x_creation_dt => X_CREATION_DT,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_key => X_KEY,
    x_message_name => X_MESSAGE_NAME,
    x_text => X_TEXT,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);
  insert into IGS_GE_S_LOG_ENTRY (
    S_LOG_TYPE,
    CREATION_DT,
    SEQUENCE_NUMBER,
    KEY,
    MESSAGE_NAME,
    TEXT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.S_LOG_TYPE,
    NEW_REFERENCES.CREATION_DT,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.KEY,
    NEW_REFERENCES.MESSAGE_NAME,
    NEW_REFERENCES.TEXT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
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
  X_ROWID in VARCHAR2,
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2
) as
  cursor c1 is select
      KEY,
      MESSAGE_NAME,
      TEXT
    from IGS_GE_S_LOG_ENTRY
    where ROWID = X_ROWID
    for update  nowait;
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

  if ( (tlinfo.KEY = X_KEY)
      AND ((tlinfo.MESSAGE_NAME = X_MESSAGE_NAME)
           OR ((tlinfo.MESSAGE_NAME is null)
               AND (X_MESSAGE_NAME is null)))
      AND ((tlinfo.TEXT = X_TEXT)
           OR ((tlinfo.TEXT is null)
               AND (X_TEXT is null)))
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
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
    x_s_log_type => X_S_LOG_TYPE,
    x_creation_dt => X_CREATION_DT,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_key => X_KEY,
    x_message_name => X_MESSAGE_NAME,
    x_text => X_TEXT,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  if(X_MODE='R') then
    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
   end if;
  update IGS_GE_S_LOG_ENTRY set
    KEY = X_KEY,
    MESSAGE_Name = NEW_REFERENCES.MESSAGE_NAME,
    TEXT = NEW_REFERENCES.TEXT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
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
  X_S_LOG_TYPE in VARCHAR2,
  X_CREATION_DT in DATE,
  X_SEQUENCE_NUMBER in NUMBER,
  X_KEY in VARCHAR2,
  X_MESSAGE_NAME in VARCHAR2,
  X_TEXT in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_GE_S_LOG_ENTRY
     where S_LOG_TYPE = X_S_LOG_TYPE
     and CREATION_DT = X_CREATION_DT
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_LOG_TYPE,
     X_CREATION_DT,
     X_SEQUENCE_NUMBER,
     X_KEY,
     X_MESSAGE_NAME,
     X_TEXT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_LOG_TYPE,
   X_CREATION_DT,
   X_SEQUENCE_NUMBER,
   X_KEY,
   X_MESSAGE_NAME,
   X_TEXT,
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
  delete from IGS_GE_S_LOG_ENTRY
      where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_GE_S_LOG_ENTRY_PKG;

/