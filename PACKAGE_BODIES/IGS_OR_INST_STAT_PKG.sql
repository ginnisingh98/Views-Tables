--------------------------------------------------------
--  DDL for Package Body IGS_OR_INST_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_INST_STAT_PKG" AS
/* $Header: IGSOI05B.pls 120.0 2005/06/01 23:09:01 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_OR_INST_STAT%RowType;
  new_references IGS_OR_INST_STAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_institution_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_institution_status IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_INST_STAT
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.institution_status := x_institution_status;
    new_references.description := x_description;
    new_references.s_institution_status := x_s_institution_status;
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
    IGS_OR_INSTITUTION_PKG.GET_FK_IGS_OR_INST_STAT (
      old_references.institution_status
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_institution_status IN VARCHAR2
    )RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_INST_STAT
      WHERE    institution_status = x_institution_status
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
        Close cur_rowid;
 		RETURN(TRUE);
	ELSE
        Close cur_rowid;
	    RETURN(FALSE);
	END IF;
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_institution_status IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_institution_status IN VARCHAR2 DEFAULT NULL,
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
      x_institution_status,
      x_description,
      x_s_institution_status,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

  IF Get_PK_For_Validation (
     new_references.institution_status
    ) then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
  END IF;

  Check_Constraints ;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
  Check_Constraints ;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;

   ELSIF (p_action = 'VALIDATE_INSERT') THEN

      if Get_PK_For_Validation (
        new_references.institution_status
		) then

        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      end if;

       Check_Constraints ;

  	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints ;

  	ELSIF (p_action = 'VALIDATE_DELETE') THEN

       Check_Child_Existance ;


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
  X_INSTITUTION_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_INSTITUTION_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_OR_INST_STAT
      where INSTITUTION_STATUS = X_INSTITUTION_STATUS;
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
    app_exception.raise_exception;
  end if;
 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_closed_ind=>NVL(X_CLOSED_IND,'N'),
  x_description=>X_DESCRIPTION,
  x_institution_status=>X_INSTITUTION_STATUS,
  x_s_institution_status=>X_S_INSTITUTION_STATUS,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_OR_INST_STAT (
    INSTITUTION_STATUS,
    DESCRIPTION,
    S_INSTITUTION_STATUS,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.INSTITUTION_STATUS,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_INSTITUTION_STATUS,
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
  After_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_INSTITUTION_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_INSTITUTION_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_INSTITUTION_STATUS,
      CLOSED_IND
    from IGS_OR_INST_STAT
    where ROWID = X_ROWID
    for update nowait ;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.S_INSTITUTION_STATUS = X_S_INSTITUTION_STATUS)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_INSTITUTION_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_INSTITUTION_STATUS in VARCHAR2,
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
    app_exception.raise_exception;
  end if;
  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_closed_ind=>NVL(X_CLOSED_IND,'N'),
   x_description=>X_DESCRIPTION,
   x_institution_status=>X_INSTITUTION_STATUS,
   x_s_institution_status=>X_S_INSTITUTION_STATUS,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGS_OR_INST_STAT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_INSTITUTION_STATUS = NEW_REFERENCES.S_INSTITUTION_STATUS,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID
    );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_INSTITUTION_STATUS in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_INSTITUTION_STATUS in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_OR_INST_STAT
     where INSTITUTION_STATUS = X_INSTITUTION_STATUS
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_INSTITUTION_STATUS,
     X_DESCRIPTION,
     X_S_INSTITUTION_STATUS,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_INSTITUTION_STATUS,
   X_DESCRIPTION,
   X_S_INSTITUTION_STATUS,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) AS
begin
  Before_DML(
   p_action=>'DELETE',
   x_rowid=>X_ROWID
   );
  delete from IGS_OR_INST_STAT
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'DELETE',
    x_rowid=>X_ROWID
    );
end DELETE_ROW;

procedure Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
 begin
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'CLOSED_IND' THEN
  new_references.CLOSED_IND:= COLUMN_VALUE ;
ELSIF upper(Column_name) = 'INSTITUTION_STATUS' THEN
  new_references.INSTITUTION_STATUS:= COLUMN_VALUE ;
ELSIF upper(Column_name) = 'S_INSTITUTION_STATUS' THEN
  new_references.S_INSTITUTION_STATUS:= COLUMN_VALUE ;
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
IF upper(Column_name) = 'INSTITUTION_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.INSTITUTION_STATUS<> upper(new_references.INSTITUTION_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;
IF upper(Column_name) = 'S_INSTITUTION_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_INSTITUTION_STATUS<> upper(new_references.S_INSTITUTION_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
  IF new_references.S_INSTITUTION_STATUS NOT IN ( 'INACTIVE' , 'ACTIVE' ) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;
END IF ;
end Check_Constraints ;
end IGS_OR_INST_STAT_PKG;

/
