--------------------------------------------------------
--  DDL for Package Body IGS_RU_LOV_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_LOV_PKG" as
/* $Header: IGSUI08B.pls 115.8 2002/11/29 04:26:52 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_LOV%RowType;
  new_references IGS_RU_LOV%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_description IN VARCHAR2 ,
    x_help_text IN VARCHAR2 ,
    x_selectable IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) IS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_LOV
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_LOV  : P_ACTION INSERT VALIDATE_INSERT   : IGSUI08B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
    new_references.description := x_description;
    new_references.help_text := x_help_text;
    new_references.selectable := x_selectable;
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

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	,
	 Column_Value 	IN	VARCHAR2
)
 IS
 BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' THEN
  new_references.SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SELECTABLE' THEN
  new_references.SELECTABLE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SEQUENCE_NUMBER < 1 or new_references.SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SELECTABLE' OR COLUMN_NAME IS NULL THEN
  IF new_references.SELECTABLE not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
 END Check_Constraints;

FUNCTION Get_PK_For_Validation (
    x_description IN VARCHAR2,
    x_sequence_number IN NUMBER
    )RETURN BOOLEAN
 IS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_LOV
      WHERE    description = x_description
      AND      sequence_number = x_sequence_number
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_description IN VARCHAR2 ,
    x_help_text IN VARCHAR2 ,
    x_selectable IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) IS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_sequence_number,
      x_description,
      x_help_text,
      x_selectable,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
       /** Removed Call to Get_PK_for_Validation .
           Reason : After insert - in actual code - it is having NULL in dup_val_on_index. i.e. if
	  	        duplicate record found then dont raise any error and continue with next case
           Date   : 25-jan-2000
      **/
      Check_Constraints;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
       /** Removed Call to Get_PK_for_Validation .
           Reason : After insert - in actual code - it is having NULL in dup_val_on_index. i.e. if
	  	        duplicate record found then dont raise any error and continue with next case
           Date   : 25-jan-2000
      **/
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
 END IF;
 END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
    cursor C is select ROWID from IGS_RU_LOV
      where DESCRIPTION = X_DESCRIPTION
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_description=>X_DESCRIPTION,
   x_help_text=>X_HELP_TEXT,
   x_selectable=>X_SELECTABLE,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_RU_LOV (
    SEQUENCE_NUMBER,
    DESCRIPTION,
    HELP_TEXT,
    SELECTABLE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.HELP_TEXT,
    NEW_REFERENCES.SELECTABLE,
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
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2
) is
  cursor c1 is select
      HELP_TEXT,
      SELECTABLE
    from IGS_RU_LOV
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_LOV  : P_ACTION LOCK_ROW   : IGSUI08B.PLS');
	 IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.HELP_TEXT = X_HELP_TEXT)
           OR ((tlinfo.HELP_TEXT is null)
               AND (X_HELP_TEXT is null)))
      AND ((tlinfo.SELECTABLE = X_SELECTABLE)
           OR ((tlinfo.SELECTABLE is null)
               AND (X_SELECTABLE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_LOV  : P_ACTION LOCK_ROW FORM_RECORD_CHANGED  : IGSUI08B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
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
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_description=>X_DESCRIPTION,
   x_help_text=>X_HELP_TEXT,
   x_selectable=>X_SELECTABLE,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_RU_LOV set
    HELP_TEXT = NEW_REFERENCES.HELP_TEXT,
    SELECTABLE = NEW_REFERENCES.SELECTABLE,
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
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_HELP_TEXT in VARCHAR2,
  X_SELECTABLE in VARCHAR2,
  X_MODE in VARCHAR2
  ) is
  cursor c1 is select rowid from IGS_RU_LOV
     where DESCRIPTION = X_DESCRIPTION
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DESCRIPTION,
     X_SEQUENCE_NUMBER,
     X_HELP_TEXT,
     X_SELECTABLE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DESCRIPTION,
   X_SEQUENCE_NUMBER,
   X_HELP_TEXT,
   X_SELECTABLE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_LOV
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_LOV_PKG;

/
