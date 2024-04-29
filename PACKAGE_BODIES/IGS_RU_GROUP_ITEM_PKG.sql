--------------------------------------------------------
--  DDL for Package Body IGS_RU_GROUP_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_GROUP_ITEM_PKG" as
/* $Header: IGSUI05B.pls 115.7 2002/11/29 04:25:59 nsidana ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_RU_GROUP_ITEM%RowType;
  new_references IGS_RU_GROUP_ITEM%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rug_sequence_number IN NUMBER ,
    x_description_number IN NUMBER ,
    x_description_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_GROUP_ITEM
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN('IGS_RU_GROUP_ITEM : P_ACTION INSERT VALIDATE_INSERT   : IGSUI05B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.rug_sequence_number := x_rug_sequence_number;
    new_references.description_number := x_description_number;
    new_references.description_type := x_description_type;
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
  -- "OSS_TST".trg_rgi_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_RU_GROUP_ITEM
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) as
	v_message_name	VARCHAR2(30);
  BEGIN
	IF p_deleting
	THEN
		IGS_RU_VAL_RGI.rulp_set_rgi(old_references.rug_sequence_number,
					old_references.description_number,
					old_references.description_type);
	ELSE
		-- validate description and type
--Here the call to IGS_RU_GEN_003.RULP_VAL_DESC_RGI Is replaced with IGS_RU_GEN_006.RULP_VAL_DESC_RGI inroder to resolve the dependency issues for the build Seed Migration Bug : 2233951
		IF IGS_RU_GEN_006.RULP_VAL_DESC_RGI(new_references.description_number,
				new_references.description_type,
				v_message_name) IS NULL
		THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
		IGS_RU_VAL_RGI.rulp_set_rgi(new_references.rug_sequence_number,
					new_references.description_number,
					new_references.description_type);
	END IF;

  END BeforeRowInsertUpdateDelete1;

  -- Trigger description :-
  -- "OSS_TST".trg_rgi_as_iud
  -- AFTER INSERT OR DELETE OR UPDATE
  -- ON IGS_RU_GROUP_ITEM

  PROCEDURE AfterStmtInsertUpdateDelete2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) as
	v_message_name	VARCHAR2(30);
  BEGIN
  	-- validate for allowed group
  	IF IGS_RU_VAL_RGI.rulp_val_grp_rgi = FALSE
  	THEN
		v_message_name := 'IGS_GE_GROUP_INSERT_NOT_ALLOW';
		Fnd_Message.Set_Name('IGS',v_message_name);
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
  	END IF;
  	-- populate IGS_RU_GROUP_SET, trigger ancestor groups in IGS_RU_GROUP_ITEM
  	IGS_RU_VAL_RGI.rulp_ins_rgi;


  END AfterStmtInsertUpdateDelete2;

PROCEDURE   Check_Constraints (
                 Column_Name     IN   VARCHAR2    ,
                 Column_Value    IN   VARCHAR2    )  as
Begin
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'RUG_SEQUENCE_NUMBER' THEN
  new_references.RUG_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'DESCRIPTION_NUMBER' THEN
  new_references.DESCRIPTION_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'DESCRIPTION_TYPE' THEN
  new_references.DESCRIPTION_TYPE:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'RUG_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.RUG_SEQUENCE_NUMBER < 1 or new_references.RUG_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'DESCRIPTION_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.DESCRIPTION_NUMBER < 1 or new_references.DESCRIPTION_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'DESCRIPTION_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.DESCRIPTION_TYPE not in  ('RUG','RUD') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
	 IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;



 END Check_Constraints;


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.rug_sequence_number = new_references.rug_sequence_number)) OR
        ((new_references.rug_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_GROUP_PKG.Get_PK_For_Validation (
        new_references.rug_sequence_number
        ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN('IGS_RU_GROUP : P_ACTIONCheck_Parent_Existanc rug_sequence_number  : IGSUI05B.PLS');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

   FUNCTION Get_PK_For_Validation (
    x_rug_sequence_number IN NUMBER,
    x_description_number IN NUMBER,
    x_description_type IN VARCHAR2
    )  RETURN BOOLEAN
  as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_GROUP_ITEM
      WHERE    rug_sequence_number = x_rug_sequence_number
      AND      description_number = x_description_number
      AND      description_type = x_description_type
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

  PROCEDURE GET_FK_IGS_RU_GROUP (
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_GROUP_ITEM
      WHERE    rug_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RGI_RUG_FK');
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
    x_description_number IN NUMBER ,
    x_description_type IN VARCHAR2 ,
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
      x_description_number,
      x_description_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE );
      IF  Get_PK_For_Validation (
       new_references.rug_sequence_number ,
       new_references.description_number ,
       new_references.description_type
            ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		  IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 (p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.rug_sequence_number ,
         new_references.description_number ,
         new_references.description_type
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsertUpdateDelete2 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterStmtInsertUpdateDelete2 ( p_inserting => FALSE, p_updating => TRUE, p_deleting => FALSE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterStmtInsertUpdateDelete2 ( p_inserting => FALSE, p_updating => FALSE, p_deleting => TRUE );
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RU_GROUP_ITEM
      where RUG_SEQUENCE_NUMBER = X_RUG_SEQUENCE_NUMBER
      and DESCRIPTION_NUMBER = X_DESCRIPTION_NUMBER
      and DESCRIPTION_TYPE = X_DESCRIPTION_TYPE;
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
   x_description_number=>X_DESCRIPTION_NUMBER,
   x_description_type=>X_DESCRIPTION_TYPE,
   x_rug_sequence_number=>X_RUG_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  insert into IGS_RU_GROUP_ITEM (
    RUG_SEQUENCE_NUMBER,
    DESCRIPTION_NUMBER,
    DESCRIPTION_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.RUG_SEQUENCE_NUMBER,
    NEW_REFERENCES.DESCRIPTION_NUMBER,
    NEW_REFERENCES.DESCRIPTION_TYPE,
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
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2
) as
  cursor c1 is select ROWID
    from IGS_RU_GROUP_ITEM
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_GROUP_ITEM : P_ACTION LOCK_ROW   : IGSUI05B.PLS');
	 IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID  			in VARCHAR2,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_DESCRIPTION_NUMBER in NUMBER,
  X_DESCRIPTION_TYPE in VARCHAR2,
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
   x_description_number=>X_DESCRIPTION_NUMBER,
   x_description_type=>X_DESCRIPTION_TYPE,
   x_rug_sequence_number=>X_RUG_SEQUENCE_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  update IGS_RU_GROUP_ITEM set
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_RU_GROUP_ITEM
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_GROUP_ITEM_PKG;

/
