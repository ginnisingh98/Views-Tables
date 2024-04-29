--------------------------------------------------------
--  DDL for Package Body IGS_GE_S_ERROR_LOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_S_ERROR_LOG_PKG" as
/* $Header: IGSMI07B.pls 115.3 2002/11/29 01:10:40 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GE_S_ERROR_LOG%RowType;
  new_references IGS_GE_S_ERROR_LOG%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_program_unit IN VARCHAR2 DEFAULT NULL,
    x_sql_error_num IN NUMBER DEFAULT NULL,
    x_sql_error_message IN VARCHAR2 DEFAULT NULL,
    x_other_detail IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_S_ERROR_LOG
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
    new_references.sequence_number := x_sequence_number;
    new_references.program_unit := x_program_unit;
    new_references.sql_error_num := x_sql_error_num;
    new_references.sql_error_message := x_sql_error_message;
    new_references.other_detail := x_other_detail;
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

  FUNCTION GET_PK_FOR_VALIDATION (
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_S_ERROR_LOG
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
    x_program_unit IN VARCHAR2 DEFAULT NULL,
    x_sql_error_num IN NUMBER DEFAULT NULL,
    x_sql_error_message IN VARCHAR2 DEFAULT NULL,
    x_other_detail IN VARCHAR2 DEFAULT NULL,
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
      x_sequence_number,
      x_program_unit,
      x_sql_error_num,
      x_sql_error_message,
      x_other_detail,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
		new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation(
		new_references.sequence_number
	)THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Null;
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
  X_PROGRAM_UNIT in VARCHAR2,
  X_SQL_ERROR_NUM in NUMBER,
  X_SQL_ERROR_MESSAGE in VARCHAR2,
  X_OTHER_DETAIL in VARCHAR2,
  x_creation_date IN DATE ,
  x_created_by IN NUMBER ,
  X_LAST_UPDATE_DATE IN DATE ,
  X_LAST_UPDATED_BY IN NUMBER ,
  X_LAST_UPDATE_LOGIN IN NUMBER ,
  X_REQUEST_ID IN NUMBER ,
  X_PROGRAM_ID IN NUMBER ,
  X_PROGRAM_APPLICATION_ID IN NUMBER ,
  X_PROGRAM_UPDATE_DATE IN DATE ,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_GE_S_ERROR_LOG
      where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;


begin

  Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_program_unit => X_PROGRAM_UNIT,
    x_sql_error_num => X_SQL_ERROR_NUM,
    x_sql_error_message => X_SQL_ERROR_MESSAGE,
    x_other_detail => X_OTHER_DETAIL,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);


  insert into IGS_GE_S_ERROR_LOG (
    SEQUENCE_NUMBER,
    PROGRAM_UNIT,
    SQL_ERROR_NUM,
    SQL_ERROR_MESSAGE,
    OTHER_DETAIL,
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
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.PROGRAM_UNIT,
    NEW_REFERENCES.SQL_ERROR_NUM,
    NEW_REFERENCES.SQL_ERROR_MESSAGE,
    NEW_REFERENCES.OTHER_DETAIL,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_PROGRAM_UNIT in VARCHAR2,
  X_SQL_ERROR_NUM in NUMBER,
  X_SQL_ERROR_MESSAGE in VARCHAR2,
  X_OTHER_DETAIL in VARCHAR2
) as
  cursor c1 is select
      PROGRAM_UNIT,
      SQL_ERROR_NUM,
      SQL_ERROR_MESSAGE,
      OTHER_DETAIL
    from IGS_GE_S_ERROR_LOG
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

      if ( ((tlinfo.PROGRAM_UNIT = X_PROGRAM_UNIT)
           OR ((tlinfo.PROGRAM_UNIT is null)
               AND (X_PROGRAM_UNIT is null)))
      AND ((tlinfo.SQL_ERROR_NUM = X_SQL_ERROR_NUM)
           OR ((tlinfo.SQL_ERROR_NUM is null)
               AND (X_SQL_ERROR_NUM is null)))
      AND ((tlinfo.SQL_ERROR_MESSAGE = X_SQL_ERROR_MESSAGE)
           OR ((tlinfo.SQL_ERROR_MESSAGE is null)
               AND (X_SQL_ERROR_MESSAGE is null)))
      AND ((tlinfo.OTHER_DETAIL = X_OTHER_DETAIL)
           OR ((tlinfo.OTHER_DETAIL is null)
               AND (X_OTHER_DETAIL is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_PROGRAM_UNIT in VARCHAR2,
  X_SQL_ERROR_NUM in NUMBER,
  X_SQL_ERROR_MESSAGE in VARCHAR2,
  X_OTHER_DETAIL in VARCHAR2,
  x_creation_date IN DATE ,
  x_created_by IN NUMBER ,
  X_LAST_UPDATE_DATE IN DATE ,
  X_LAST_UPDATED_BY IN NUMBER ,
  X_LAST_UPDATE_LOGIN IN NUMBER ,
  X_REQUEST_ID IN NUMBER ,
  X_PROGRAM_ID IN NUMBER ,
  X_PROGRAM_APPLICATION_ID IN NUMBER ,
  X_PROGRAM_UPDATE_DATE IN DATE ,
  X_MODE in VARCHAR2 default 'R'
  ) as

begin

  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_program_unit => X_PROGRAM_UNIT,
    x_sql_error_num => X_SQL_ERROR_NUM,
    x_sql_error_message => X_SQL_ERROR_MESSAGE,
    x_other_detail => X_OTHER_DETAIL,
    x_created_by => X_LAST_UPDATED_BY,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_update_login => X_LAST_UPDATE_LOGIN
);

  update IGS_GE_S_ERROR_LOG set
    PROGRAM_UNIT =   NEW_REFERENCES.PROGRAM_UNIT,
    SQL_ERROR_NUM =   NEW_REFERENCES.SQL_ERROR_NUM,
    SQL_ERROR_MESSAGE =   NEW_REFERENCES.SQL_ERROR_MESSAGE,
    OTHER_DETAIL =   NEW_REFERENCES.OTHER_DETAIL,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_PROGRAM_UNIT in VARCHAR2,
  X_SQL_ERROR_NUM in NUMBER,
  X_SQL_ERROR_MESSAGE in VARCHAR2,
  X_OTHER_DETAIL in VARCHAR2,
  x_creation_date IN DATE ,
  x_created_by IN NUMBER ,
  X_LAST_UPDATE_DATE IN DATE ,
  X_LAST_UPDATED_BY IN NUMBER ,
  X_LAST_UPDATE_LOGIN IN NUMBER ,
  X_REQUEST_ID IN NUMBER ,
  X_PROGRAM_ID IN NUMBER ,
  X_PROGRAM_APPLICATION_ID IN NUMBER ,
  X_PROGRAM_UPDATE_DATE IN DATE ,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_GE_S_ERROR_LOG
     where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SEQUENCE_NUMBER,
     X_PROGRAM_UNIT,
     X_SQL_ERROR_NUM,
     X_SQL_ERROR_MESSAGE,
     X_OTHER_DETAIL,
     x_creation_date  ,
     x_created_by  ,
     X_LAST_UPDATE_DATE  ,
     X_LAST_UPDATED_BY  ,
     X_LAST_UPDATE_LOGIN  ,
     X_REQUEST_ID ,
     X_PROGRAM_ID ,
     X_PROGRAM_APPLICATION_ID ,
     X_PROGRAM_UPDATE_DATE ,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
  X_ROWID,
   X_SEQUENCE_NUMBER,
   X_PROGRAM_UNIT,
   X_SQL_ERROR_NUM,
   X_SQL_ERROR_MESSAGE,
   X_OTHER_DETAIL,
     x_creation_date  ,
     x_created_by  ,
     X_LAST_UPDATE_DATE  ,
     X_LAST_UPDATED_BY  ,
     X_LAST_UPDATE_LOGIN  ,
     X_REQUEST_ID ,
     X_PROGRAM_ID ,
     X_PROGRAM_APPLICATION_ID ,
     X_PROGRAM_UPDATE_DATE ,
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

  delete from IGS_GE_S_ERROR_LOG
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_GE_S_ERROR_LOG_PKG;

/
