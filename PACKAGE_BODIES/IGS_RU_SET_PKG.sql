--------------------------------------------------------
--  DDL for Package Body IGS_RU_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_SET_PKG" as
/* $Header: IGSUI12B.pls 115.9 2002/11/29 04:28:04 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_SET%RowType;
  new_references IGS_RU_SET%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_set_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_SET
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_SET  : P_ACTION INSERT VALIDATE_INSERT   : IGSUI12B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sequence_number := x_sequence_number;
    new_references.set_type := x_set_type;
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
   Column_Name IN VARCHAR2 ,
   Column_Value IN VARCHAR2
 )
 as
 BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' Then
     		new_references.sequence_number := igs_ge_number.to_num(COLUMN_VALUE);
	END IF;
	IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.sequence_number < 0 OR new_references.sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			 IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;

 PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_RU_ITEM_PKG.GET_FK_IGS_RU_SET (
      old_references.sequence_number
      );

    IGS_RU_SET_MEMBER_PKG.GET_FK_IGS_RU_SET (
      old_references.sequence_number
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
   x_sequence_number IN NUMBER
)return BOOLEAN as

   CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_SET
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
    x_rowid IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_set_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_sequence_number,
      x_set_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN

	   IF Get_PK_For_Validation (
		new_references.sequence_number
	  ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	  END IF;
	  Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
	  Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation (
	 	new_references.sequence_number
	  ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
 	  END IF;
	  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	  Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) as
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SET_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RU_SET
      where SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    l_sequence_number NUMBER;

    CURSOR cur_max_plus_one IS
      SELECT   (sequence_number + 1) sequence_number
      FROM     igs_ru_set
      WHERE    sequence_number =
        (SELECT   MAX (sequence_number)
         FROM     igs_ru_set
         WHERE    sequence_number < 499999)
      FOR UPDATE OF sequence_number NOWAIT;

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
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_set_type=>X_SET_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  --
  --  If the sequence number is passed as a NULL value then generate it.
  --
  IF (fnd_global.user_id = 1) THEN
    --
    --  If the sequence number is passed as a NULL value then generate it.
    --  If the User creating this record is DATAMERGE (id = 1) then
    --  Get the sequence as the existing maximum value + 1
    --
    IF (x_sequence_number IS NULL) THEN
      OPEN cur_max_plus_one;
      FETCH cur_max_plus_one INTO l_sequence_number;
      CLOSE cur_max_plus_one;
    ELSE
      l_sequence_number := x_sequence_number;
    END IF;
    --
    --  Seeded Sequences can go upto 499999 only else raise an error
    --
    IF (l_sequence_number > 499999) THEN
      Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_SET  : Sequence_number > 499999   : IGSUI12B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception ;
    END IF;
  ELSE
    l_sequence_number := NEW_REFERENCES.SEQUENCE_NUMBER;
  END IF;

  insert into IGS_RU_SET (
    SEQUENCE_NUMBER,
    SET_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    l_sequence_number,
    NEW_REFERENCES.SET_TYPE,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_SET_TYPE in VARCHAR2
) as
  cursor c1 is select
      SET_TYPE
    from IGS_RU_SET
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_SET  : P_ACTION LOCK_ROW   : IGSUI12B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.SET_TYPE = X_SET_TYPE)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_SET  : P_ACTION LOCK_ROW  FORM_RECORD_CHANGED : IGSUI12B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_SET_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
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

  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_sequence_number=>X_SEQUENCE_NUMBER,
   x_set_type=>X_SET_TYPE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_RU_SET set
    SET_TYPE = NEW_REFERENCES.SET_TYPE,
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_SET_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_RU_SET
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
     X_SET_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SEQUENCE_NUMBER,
   X_SET_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_SET
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_SET_PKG;

/
