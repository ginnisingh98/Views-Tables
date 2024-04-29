--------------------------------------------------------
--  DDL for Package Body IGS_RU_GROUP_SET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GROUP_SET_PKG" as
/* $Header: IGSUI06B.pls 115.8 2003/10/14 10:53:40 nsinha ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_RU_GROUP_SET%RowType;
  new_references IGS_RU_GROUP_SET%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rug_sequence_number IN NUMBER ,
    x_rud_sequence_number IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_GROUP_SET
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_GROUP_SET  : P_ACTION INSERT VALIDATE_INSERT   : IGSUI06B.PLS');
	   IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.rug_sequence_number := x_rug_sequence_number;
    new_references.rud_sequence_number := x_rud_sequence_number;
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

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    ,
                 Column_Value    IN   VARCHAR2
)  as
Begin
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'RUD_SEQUENCE_NUMBER' THEN
  new_references.RUD_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'RUG_SEQUENCE_NUMBER' THEN
  new_references.RUG_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'RUD_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.RUD_SEQUENCE_NUMBER < 1 or new_references.RUD_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'RUG_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.RUG_SEQUENCE_NUMBER < 1 or new_references.RUG_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;

PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.rud_sequence_number = new_references.rud_sequence_number)) OR
        ((new_references.rud_sequence_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT  IGS_RU_DESCRIPTION_PKG.Get_PK_For_Validation (
        new_references.rud_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_DESCRIPTION  : P_ACTION Check_Parent_Existance  .rud_sequence_number : IGSUI06B.PLS');
		 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.rug_sequence_number = new_references.rug_sequence_number)) OR
        ((new_references.rug_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_GROUP_PKG.Get_PK_For_Validation (
        new_references.rug_sequence_number
        ) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_GROUP  : P_ACTION Check_Parent_Existance  .rug_sequence_number : IGSUI06B.PLS');
		  IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_rug_sequence_number IN NUMBER,
    x_rud_sequence_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_GROUP_SET
      WHERE    rug_sequence_number = x_rug_sequence_number
      AND      rud_sequence_number = x_rud_sequence_number
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

  PROCEDURE GET_FK_IGS_RU_DESCRIPTION (
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_GROUP_SET
      WHERE    rud_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
     Close cur_rowid;
     Fnd_Message.Set_Name ('IGS', 'IGS_RU_RGS_RUD_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_DESCRIPTION;

  PROCEDURE GET_FK_IGS_RU_GROUP (
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_GROUP_SET
      WHERE    rug_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RGS_RUG_FK');
	   IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_GROUP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rug_sequence_number IN NUMBER ,
    x_rud_sequence_number IN NUMBER ,
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
      x_rug_sequence_number,
      x_rud_sequence_number,
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
       new_references.rug_sequence_number ,
       new_references.rud_sequence_number
       ) THEN
       RAISE DUP_VAL_ON_INDEX; 	-- Changed By: Navin.Sinha On: 10/9/2003 Bug#: 3193855 Fix: Replaced IGS_GE_RECORD_ALREADY_EXISTS with DUP_VAL_ON_INDEX.
     END IF;
        Check_Constraints;
        Check_Parent_Existance;
     ELSIF (p_action = 'UPDATE') THEN
        -- Call all the procedures related to Before Update.
        Check_Constraints;
        Check_Parent_Existance;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.rug_sequence_number ,
         new_references.rud_sequence_number
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
  ) as
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RU_GROUP_SET
      where RUD_SEQUENCE_NUMBER = X_RUD_SEQUENCE_NUMBER
      and RUG_SEQUENCE_NUMBER = X_RUG_SEQUENCE_NUMBER;
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
   x_rud_sequence_number=>X_RUD_SEQUENCE_NUMBER,
   x_rug_sequence_number=>X_RUG_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_RU_GROUP_SET (
    RUG_SEQUENCE_NUMBER,
    RUD_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.RUG_SEQUENCE_NUMBER,
    NEW_REFERENCES.RUD_SEQUENCE_NUMBER,
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
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER
) as
  cursor c1 is select ROWID
    from IGS_RU_GROUP_SET
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_GROUP_SET  : P_ACTION LOCK_ROW : IGSUI06B.PLS');
	 IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_GROUP_SET
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_GROUP_SET_PKG;

/
