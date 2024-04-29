--------------------------------------------------------
--  DDL for Package Body IGS_RU_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_ITEM_PKG" as
/* $Header: IGSUI07B.pls 120.2 2006/02/20 04:34:17 sarakshi noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_ITEM%RowType;
  new_references IGS_RU_ITEM%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rul_sequence_number IN NUMBER ,
    x_item IN NUMBER ,
    x_turin_function IN VARCHAR2 ,
    x_named_rule IN NUMBER ,
    x_rule_number IN NUMBER ,
    x_set_number IN NUMBER ,
    x_value IN VARCHAR2 ,
    x_derived_rule IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_ITEM
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_ITEM  : P_ACTION INSERT VALIDATE_INSERT   : IGSUI07B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.rul_sequence_number := x_rul_sequence_number;
    new_references.item := x_item;
    new_references.turin_function := x_turin_function;
    new_references.named_rule := x_named_rule;
    new_references.rule_number := x_rule_number;
    new_references.set_number := x_set_number;
    new_references.value := x_value;
    new_references.derived_rule := x_derived_rule;
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
as
 BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'RUL_SEQUENCE_NUMBER' THEN
  new_references.RUL_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SET_NUMBER' THEN
  new_references.SET_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'ITEM' THEN
  new_references.ITEM:= igs_ge_number.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'RUL_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.RUL_SEQUENCE_NUMBER < 0 or new_references.RUL_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SET_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SET_NUMBER < 0 or new_references.SET_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'ITEM' OR COLUMN_NAME IS NULL THEN
  IF new_references.ITEM < 0 or new_references.ITEM > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
 END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.named_rule = new_references.named_rule)) OR
        ((new_references.named_rule IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_NAMED_RULE_PKG.Get_PK_For_Validation (
        new_references.named_rule
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_NAMED_RULE  : P_ACTION Check_Parent_Existance  named_rule   : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
        new_references.rul_sequence_number
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_RULE  : P_ACTION Check_Parent_Existance  rul_sequence_number   : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.rule_number = new_references.rule_number)) OR
        ((new_references.rule_number IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
        new_references.rule_number
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_RULE  : P_ACTION Check_Parent_Existance  rule_number   : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.set_number = new_references.set_number)) OR
        ((new_references.set_number IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_SET_PKG.Get_PK_For_Validation (
        new_references.set_number
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_SET  : P_ACTION Check_Parent_Existance  set_number   : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.derived_rule = new_references.derived_rule)) OR
        ((new_references.derived_rule IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_CALL_PKG.Get_UK1_For_Validation (
        new_references.derived_rule
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_CALL  : P_ACTION Check_Parent_Existance  derived_rule    : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

    IF (((old_references.turin_function = new_references.turin_function)) OR
        ((new_references.turin_function IS NULL))) THEN
      NULL;
    ELSE
IF NOT IGS_RU_TURIN_FNC_PKG.Get_PK_For_Validation (
        new_references.turin_function
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_TURIN_FNC  : P_ACTION Check_Parent_Existance  turin_function    : IGSUI07B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_rul_sequence_number IN NUMBER,
    x_item IN NUMBER
    ) RETURN BOOLEAN
as
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    rul_sequence_number = x_rul_sequence_number
      AND      item = x_item
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
    x_rul_sequence_number IN VARCHAR2
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    named_rule = x_rul_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUI_NR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_NAMED_RULE;

  PROCEDURE GET_FK_IGS_RU_RULE (
    x_sequence_number IN NUMBER
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    rul_sequence_number = x_sequence_number
      OR 	   rule_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUI_RUL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_RULE;

  PROCEDURE GET_FK_IGS_RU_SET (
    x_sequence_number IN NUMBER
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    set_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUI_RUL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_SET;

  PROCEDURE GET_UFK_IGS_RU_CALL (
    x_rud_sequence_number IN NUMBER
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    derived_rule = x_rud_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUI_SRC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_RU_CALL;

  PROCEDURE GET_FK_IGS_RU_TURIN_FNC (
    x_s_turin_function IN VARCHAR2
    )as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_ITEM
      WHERE    turin_function = x_s_turin_function ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RUI_STF_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_TURIN_FNC;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rul_sequence_number IN NUMBER ,
    x_item IN NUMBER ,
    x_turin_function IN VARCHAR2 ,
    x_named_rule IN NUMBER ,
    x_rule_number IN NUMBER ,
    x_set_number IN NUMBER ,
    x_value IN VARCHAR2 ,
    x_derived_rule IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  )as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_rul_sequence_number,
      x_item,
      x_turin_function,
      x_named_rule,
      x_rule_number,
      x_set_number,
      x_value,
      x_derived_rule,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
	Null;
      IF  Get_PK_For_Validation (
          new_references.rul_sequence_number,
          new_references.item
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
     ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Check_Constraints;
       Check_Parent_Existance;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.rul_sequence_number,
          new_references.item
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
     END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  )as
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2
  )as
    cursor C is select ROWID from IGS_RU_ITEM
      where RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER
      and ITEM = X_ITEM;
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
   x_derived_rule=>X_DERIVED_RULE,
   x_item=>X_ITEM,
   x_named_rule=>X_NAMED_RULE,
   x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
   x_rule_number=>X_RULE_NUMBER,
   x_set_number=>X_SET_NUMBER,
   x_turin_function=>X_TURIN_FUNCTION,
   x_value=>X_VALUE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_RU_ITEM (
    RUL_SEQUENCE_NUMBER,
    ITEM,
    TURIN_FUNCTION,
    NAMED_RULE,
    RULE_NUMBER,
    SET_NUMBER,
    VALUE,
    DERIVED_RULE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    NEW_REFERENCES.ITEM,
    NEW_REFERENCES.TURIN_FUNCTION,
    NEW_REFERENCES.NAMED_RULE,
    NEW_REFERENCES.RULE_NUMBER,
    NEW_REFERENCES.SET_NUMBER,
    NEW_REFERENCES.VALUE,
    NEW_REFERENCES.DERIVED_RULE,
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
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER
)as
  cursor c1 is select
      TURIN_FUNCTION,
      NAMED_RULE,
      RULE_NUMBER,
      SET_NUMBER,
      VALUE,
      DERIVED_RULE
    from IGS_RU_ITEM
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_ITEM  : P_ACTION LOCK_ROW   : IGSUI07B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.TURIN_FUNCTION = X_TURIN_FUNCTION)
           OR ((tlinfo.TURIN_FUNCTION is null)
               AND (X_TURIN_FUNCTION is null)))
      AND ((tlinfo.NAMED_RULE = X_NAMED_RULE)
           OR ((tlinfo.NAMED_RULE is null)
               AND (X_NAMED_RULE is null)))
      AND ((tlinfo.RULE_NUMBER = X_RULE_NUMBER)
           OR ((tlinfo.RULE_NUMBER is null)
               AND (X_RULE_NUMBER is null)))
      AND ((tlinfo.SET_NUMBER = X_SET_NUMBER)
           OR ((tlinfo.SET_NUMBER is null)
               AND (X_SET_NUMBER is null)))
      AND ((tlinfo.VALUE = X_VALUE)
           OR ((tlinfo.VALUE is null)
               AND (X_VALUE is null)))
      AND ((tlinfo.DERIVED_RULE = X_DERIVED_RULE)
           OR ((tlinfo.DERIVED_RULE is null)
               AND (X_DERIVED_RULE is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_ITEM  : P_ACTION LOCK_ROW  FORM_RECORD_CHANGED : IGSUI07B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2
  )as
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
   x_derived_rule=>X_DERIVED_RULE,
   x_item=>X_ITEM,
   x_named_rule=>X_NAMED_RULE,
   x_rul_sequence_number=>X_RUL_SEQUENCE_NUMBER,
   x_rule_number=>X_RULE_NUMBER,
   x_set_number=>X_SET_NUMBER,
   x_turin_function=>X_TURIN_FUNCTION,
   x_value=>X_VALUE,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_RU_ITEM set
    TURIN_FUNCTION = NEW_REFERENCES.TURIN_FUNCTION,
    NAMED_RULE = NEW_REFERENCES.NAMED_RULE,
    RULE_NUMBER = NEW_REFERENCES.RULE_NUMBER,
    SET_NUMBER = NEW_REFERENCES.SET_NUMBER,
    VALUE = NEW_REFERENCES.VALUE,
    DERIVED_RULE = NEW_REFERENCES.DERIVED_RULE,
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
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ITEM in NUMBER,
  X_TURIN_FUNCTION in VARCHAR2,
  X_NAMED_RULE in NUMBER,
  X_RULE_NUMBER in NUMBER,
  X_SET_NUMBER in NUMBER,
  X_VALUE in VARCHAR2,
  X_DERIVED_RULE in NUMBER,
  X_MODE in VARCHAR2
  )as
  cursor c1 is select rowid from IGS_RU_ITEM
     where RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER
     and ITEM = X_ITEM
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_RUL_SEQUENCE_NUMBER,
     X_ITEM,
     X_TURIN_FUNCTION,
     X_NAMED_RULE,
     X_RULE_NUMBER,
     X_SET_NUMBER,
     X_VALUE,
     X_DERIVED_RULE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_RUL_SEQUENCE_NUMBER,
   X_ITEM,
   X_TURIN_FUNCTION,
   X_NAMED_RULE,
   X_RULE_NUMBER,
   X_SET_NUMBER,
   X_VALUE,
   X_DERIVED_RULE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
)as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_ITEM
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

  PROCEDURE LOAD_ROW (
    x_rul_sequence_number IN NUMBER,
    x_item                IN NUMBER,
    x_turin_function      IN VARCHAR2,
    x_named_rule          IN NUMBER,
    x_rule_number         IN NUMBER,
    x_set_number          IN NUMBER,
    x_value               IN VARCHAR2,
    x_derived_rule        IN NUMBER,
    x_owner               IN VARCHAR2,
    x_last_update_date    IN VARCHAR2,
    x_custom_mode         IN VARCHAR2  ) IS

    f_luby    number;  -- entity owner in file
    f_ludate  date;    -- entity update date in file
    db_luby   number;  -- entity owner in db
    db_ludate date;    -- entity update date in db

    CURSOR c_ru_item(cp_rul_sequence_number  igs_ru_item.rul_sequence_number%TYPE,
                     cp_item                 igs_ru_item.item%TYPE) IS
    SELECT last_updated_by, last_update_date
    FROM   igs_ru_item
    WHERE  rul_sequence_number = cp_rul_sequence_number
    AND    item = cp_item
    AND    rul_sequence_number <= 500000; -- this is the addtional check put to filter out the customer defined rules, bug 2421803


  BEGIN

    -- Translate owner to file_last_updated_by
    f_luby := fnd_load_util.owner_id(x_owner);

    -- Translate char last_update_date to date
    f_ludate := nvl(to_date(x_last_update_date, 'YYYY/MM/DD'), sysdate);


    OPEN  c_ru_item(x_rul_sequence_number,x_item);
    FETCH c_ru_item INTO db_luby, db_ludate;
    IF c_ru_item%FOUND THEN
      IF (TRUNC(f_ludate) > TRUNC(db_ludate)) THEN

	-- Delete all the old entries for the currenly processed RUL_SEQUENCE_NUMBER
	-- Added as part of bug fix 2421803, nshee
	DELETE FROM IGS_RU_ITEM
	WHERE  RUL_SEQUENCE_NUMBER = x_rul_sequence_number;

	INSERT INTO igs_ru_item
	(
	  RUL_SEQUENCE_NUMBER,
	  ITEM,
	  TURIN_FUNCTION,
	  NAMED_RULE,
	  RULE_NUMBER,
	  SET_NUMBER,
	  VALUE,
	  DERIVED_RULE,
	  CREATED_BY,
	  CREATION_DATE,
	  LAST_UPDATED_BY,
	  LAST_UPDATE_DATE,
	  LAST_UPDATE_LOGIN
	)
	VALUES
	(
	  x_rul_sequence_number,
	  x_item,
	  x_turin_function,
	  x_named_rule,
	  x_rule_number,
	  x_set_number,
	  x_value,
	  x_derived_rule,
	  f_luby,
	  f_ludate,
	  f_luby,
	  f_ludate,
	  0
	);

      END IF;
    ELSE
      INSERT INTO igs_ru_item
      (
	RUL_SEQUENCE_NUMBER,
	ITEM,
	TURIN_FUNCTION,
	NAMED_RULE,
	RULE_NUMBER,
	SET_NUMBER,
	VALUE,
	DERIVED_RULE,
	CREATED_BY,
	CREATION_DATE,
	LAST_UPDATED_BY,
	LAST_UPDATE_DATE,
	LAST_UPDATE_LOGIN
      )
      VALUES
      (
	x_rul_sequence_number,
	x_item,
	x_turin_function,
	x_named_rule,
	x_rule_number,
	x_set_number,
	x_value,
	x_derived_rule,
	f_luby,
	f_ludate,
	f_luby,
	f_ludate,
	0
      );
    END IF;
    CLOSE c_ru_item;

  END LOAD_ROW;


  PROCEDURE LOAD_SEED_ROW (
    x_upload_mode         IN VARCHAR2,
    x_rul_sequence_number IN NUMBER,
    x_item                IN NUMBER,
    x_turin_function      IN VARCHAR2,
    x_named_rule          IN NUMBER,
    x_rule_number         IN NUMBER,
    x_set_number          IN NUMBER,
    x_value               IN VARCHAR2,
    x_derived_rule        IN NUMBER,
    x_owner               IN VARCHAR2,
    x_last_update_date    IN VARCHAR2,
    x_custom_mode         IN VARCHAR2  ) IS

  BEGIN

	 IF (x_upload_mode = 'NLS') THEN
	   NULL; --For translated record call Table_pkg.TRANSLATE_ROW
         ELSE
	   igs_ru_item_pkg.load_row(
	      x_rul_sequence_number => x_rul_sequence_number ,
	      x_item                => x_item ,
	      x_turin_function      => x_turin_function ,
	      x_named_rule          => x_named_rule,
	      x_rule_number         => x_rule_number ,
	      x_set_number          => x_set_number ,
	      x_value               => x_value ,
	      x_derived_rule        => x_derived_rule ,
	      x_owner               => x_owner ,
	      x_last_update_date    => x_last_update_date ,
	      x_custom_mode	    => x_custom_mode );
	 END IF;

  END LOAD_SEED_ROW;

end IGS_RU_ITEM_PKG;

/
