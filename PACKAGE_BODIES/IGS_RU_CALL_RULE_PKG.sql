--------------------------------------------------------
--  DDL for Package Body IGS_RU_CALL_RULE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_CALL_RULE_PKG" as
/* $Header: IGSUI02B.pls 115.7 2002/11/29 04:24:58 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_RU_CALL_RULE%RowType;
  new_references IGS_RU_CALL_RULE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_called_rule_cd IN VARCHAR2 ,
    x_nr_rul_sequence_number IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_CALL_RULE
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
      IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL_RULE : P_ACTION  INSERT, VALIDATE_INSERT  : IGSUI02B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.called_rule_cd := x_called_rule_cd;
    new_references.nr_rul_sequence_number := x_nr_rul_sequence_number;
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

FUNCTION GET_UK1_FOR_VALIDATION(
	x_nr_rul_sequence_number IN NUMBER
	) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL_RULE
      WHERE    nr_rul_sequence_number = x_nr_rul_sequence_number
      AND	   ((l_rowid IS NULL) OR (rowid <> l_rowid))
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
END  GET_UK1_FOR_VALIDATION;
PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.nr_rul_sequence_number = new_references.nr_rul_sequence_number)) OR
        ((new_references.nr_rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_NAMED_RULE_PKG.Get_PK_For_Validation (
        new_references.nr_rul_sequence_number
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_RU_GEN_006.SET_TOKEN('IGS_RU_NAMED_RULE : P_ACTION  Check_Parent_Existance  new_references.nr_rul_sequence_number : IGSUI02B.PLS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;


FUNCTION Get_PK_For_Validation (
    x_called_rule_cd IN VARCHAR2
    )RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL_RULE
      WHERE    called_rule_cd = x_called_rule_cd
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

PROCEDURE GET_FK_IGS_RU_NAMED_RULE (
    x_rul_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL_RULE
      WHERE    nr_rul_sequence_number = x_rul_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_SCR_NR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_NAMED_RULE;

  PROCEDURE CHECK_UNIQUENESS AS
  BEGIN

   IF GET_UK1_FOR_VALIDATION(new_references.nr_rul_sequence_number) THEN
      FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;
   END IF;
  END CHECK_UNIQUENESS;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
	) as
    BEGIN
	IF Column_Name is null THEN
    	 NULL;
	ELSIF upper(Column_name) = 'CALLED_RULE_CD' THEN
  	 new_references.called_rule_cd := COLUMN_VALUE ;
	ELSIF upper(Column_name) = 'NR_RUL_SEQUENCE_NUMBER' THEN
  	 new_references.nr_rul_sequence_number:= igs_ge_number.to_num(COLUMN_VALUE) ;
      END IF;

  	IF upper(Column_name) = 'CALLED_RULE_CD' OR COLUMN_NAME IS NULL THEN
  	 IF new_references.called_rule_cd <> UPPER(new_references.called_rule_cd) THEN
    	  Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    	  IGS_GE_MSG_STACK.ADD;
    	  App_Exception.Raise_Exception ;
  	 END IF;
     END IF ;

	IF upper(Column_name) = 'NR_RUL_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
       IF new_references.nr_rul_sequence_number < 1 or new_references.nr_rul_sequence_number > 999999 THEN
        Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception ;
  	 END IF;
  	END IF ;
END Check_Constraints;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_called_rule_cd IN VARCHAR2 ,
    x_nr_rul_sequence_number IN NUMBER ,
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
      x_called_rule_cd,
      x_nr_rul_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF GET_PK_FOR_VALIDATION(
        new_references.called_rule_cd )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_uniqueness;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_uniqueness;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.called_rule_cd
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      Check_uniqueness;
      check_constraints;
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
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RU_CALL_RULE
      where CALLED_RULE_CD = X_CALLED_RULE_CD;
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
    x_rowid  => X_ROWID,
    x_called_rule_cd =>X_CALLED_RULE_CD,
    x_nr_rul_sequence_number =>X_NR_RUL_SEQUENCE_NUMBER,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  insert into IGS_RU_CALL_RULE (
    CALLED_RULE_CD,
    NR_RUL_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CALLED_RULE_CD,
    NEW_REFERENCES.NR_RUL_SEQUENCE_NUMBER,
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
    x_rowid  => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select
      NR_RUL_SEQUENCE_NUMBER
    from IGS_RU_CALL_RULE
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL_RULE : P_ACTION  LOCK_ROW   : IGSUI02B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.NR_RUL_SEQUENCE_NUMBER = X_NR_RUL_SEQUENCE_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL_RULE : P_ACTION  LOCK_ROW   FORM_RECORD_CHANGED : IGSUI02B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
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

 Before_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID,
    x_called_rule_cd =>X_CALLED_RULE_CD,
    x_nr_rul_sequence_number =>X_NR_RUL_SEQUENCE_NUMBER,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  update IGS_RU_CALL_RULE set
    NR_RUL_SEQUENCE_NUMBER = NEW_REFERENCES.NR_RUL_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

After_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CALLED_RULE_CD in VARCHAR2,
  X_NR_RUL_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_RU_CALL_RULE
     where CALLED_RULE_CD = X_CALLED_RULE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CALLED_RULE_CD,
     X_NR_RUL_SEQUENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CALLED_RULE_CD,
   X_NR_RUL_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
    X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );

  delete from IGS_RU_CALL_RULE
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );
end DELETE_ROW;

end IGS_RU_CALL_RULE_PKG;

/
