--------------------------------------------------------
--  DDL for Package Body IGS_RU_CALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_CALL_PKG" AS
/* $Header: IGSUI01B.pls 115.11 2002/11/29 04:24:40 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_RU_CALL%RowType;
  new_references IGS_RU_CALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_s_rule_call_cd IN VARCHAR2 ,
    x_s_rule_type_cd IN VARCHAR2 ,
    x_rud_sequence_number IN NUMBER ,
    x_true_message IN VARCHAR2 ,
    x_false_message IN VARCHAR2 ,
    x_default_rule IN NUMBER ,
    x_rug_sequence_number IN NUMBER ,
    x_select_group IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_CALL
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
      IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL : P_ACTION  Insert, validate Insert : IGSUI01B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.s_rule_call_cd := x_s_rule_call_cd;
    new_references.s_rule_type_cd := x_s_rule_type_cd;
    new_references.rud_sequence_number := x_rud_sequence_number;
    new_references.true_message := x_true_message;
    new_references.false_message := x_false_message;
    new_references.default_rule := x_default_rule;
    new_references.rug_sequence_number := x_rug_sequence_number;
    new_references.select_group := x_select_group;
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


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.default_rule = new_references.default_rule)) OR
        ((new_references.default_rule IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_NAMED_RULE_PKG.Get_PK_For_Validation (
        new_references.default_rule
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_RU_GEN_006.SET_TOKEN('IGS_RU_NAMED_RULE : P_ACTION  Check_Parent_Existance  new_references.default_rule  : IGSUI01B.PLS');
      		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.rud_sequence_number = new_references.rud_sequence_number)) OR
        ((new_references.rud_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_DESCRIPTION_PKG.Get_PK_For_Validation (
        new_references.rud_sequence_number
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_RU_GEN_006.SET_TOKEN('IGS_RU_DESCRIPTION : P_ACTION  Check_Parent_Existance  new_references.rud_sequence_number  : IGSUI01B.PLS');
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
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_RU_GEN_006.SET_TOKEN('IGS_RU_GROUP : P_ACTION  Check_Parent_Existance  new_references.rug_sequence_number  : IGSUI01B.PLS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.select_group = new_references.select_group)) OR
        ((new_references.select_group IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_GROUP_PKG.Get_PK_For_Validation (
        new_references.select_group
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_RU_GEN_006.SET_TOKEN('IGS_RU_GROUP : P_ACTION  Check_Parent_Existance  new_references.select_group  : IGSUI01B.PLS');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_UK_Child_Existance AS
  BEGIN

    IF (old_references.rud_sequence_number = new_references.rud_sequence_number)  OR
        (old_references.rud_sequence_number IS NULL)
    THEN
      NULL;
    ELSE
      IGS_RU_ITEM_PKG.GET_UFK_IGS_RU_CALL(
        old_references.rud_sequence_number
        );
    END IF;

  END Check_UK_Child_Existance;


  FUNCTION Get_PK_For_Validation (
    x_s_rule_call_cd IN VARCHAR2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL
      WHERE    s_rule_call_cd = x_s_rule_call_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return TRUE;
    ELSE
      Close cur_rowid;
      Return FALSE;
    END IF;

  END Get_PK_For_Validation;



  FUNCTION Get_UK1_For_Validation (
   x_rud_sequence_number IN NUMBER
    )
  RETURN BOOLEAN AS
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL
      WHERE    rud_sequence_number = x_rud_sequence_number
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));


         lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return TRUE;
    ELSE
      Close cur_rowid;
      Return FALSE;
    END IF;
 END Get_UK1_For_Validation;


  PROCEDURE GET_FK_IGS_RU_NAMED_RULE (
    x_rul_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL
      WHERE    default_rule = x_rul_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_SRC_NR_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_NAMED_RULE;

  PROCEDURE GET_FK_IGS_RU_DESCRIPTION (
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL
      WHERE    rud_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_SRC_RUD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_DESCRIPTION;


  PROCEDURE GET_FK_IGS_RU_GROUP_SG (
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_CALL
      WHERE    rug_sequence_number = x_sequence_number
      OR       select_group = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_SRC_RUG_SG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_GROUP_SG;

 PROCEDURE Get_FK_IGS_RU_GROUP_SEQ (
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ru_call
      WHERE    rug_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
END Get_FK_IGS_RU_GROUP_SEQ ;

  PROCEDURE CHECK_UNIQUENESS AS

  BEGIN

    IF GET_UK1_FOR_VALIDATION(
     new_references.rud_sequence_number) THEN
     FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
     IGS_GE_MSG_STACK.ADD;
     APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;


  END CHECK_UNIQUENESS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_s_rule_call_cd IN VARCHAR2 ,
    x_s_rule_type_cd IN VARCHAR2 ,
    x_rud_sequence_number IN NUMBER ,
    x_true_message IN VARCHAR2 ,
    x_false_message IN VARCHAR2 ,
    x_default_rule IN NUMBER ,
    x_rug_sequence_number IN NUMBER ,
    x_select_group IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_rule_call_cd,
      x_s_rule_type_cd,
      x_rud_sequence_number,
      x_true_message,
      x_false_message,
      x_default_rule,
      x_rug_sequence_number,
      x_select_group,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF GET_PK_FOR_VALIDATION(
        new_references.s_rule_call_cd )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      --Check_Unique (x_rowid);
      Check_uniqueness;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_uniqueness;
      Check_constraints;
      Check_Parent_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      --
      -- svenkata - This table handler is released as part of IGS specific forms in SEED . As a consequence ,
      -- the procedure Check_Child_Existance originally a part of this  package , has been moved to Igs_Ru_Gen_005 .
      -- This was done 'cos Check_Child_Existance makes calls to other procedures which are not being shipped !
      -- Check_Child_Existance is called only when the user is not DATAMERGE . Hence , the proc.
      -- Check_Child_Existance_ru_rule is being called using execute immediate only if the user is not DATAMERGE .
      -- Bug # 2233951
      --
     IF (fnd_global.user_id <>  1) THEN
       -- do execute immediate
        EXECUTE IMMEDIATE 'BEGIN  Igs_Ru_Gen_005.Check_Child_Existance_Ru_Call(:1,:2); END;'
	  USING
	     old_references.rud_sequence_number ,
	     old_references.s_rule_call_cd  ;
     END IF;

     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.s_rule_call_cd
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
      Check_uk_child_existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      --
      -- svenkata - This table handler is released as part of IGS specific forms in SEED . As a consequence ,
      -- the procedure Check_Child_Existance originally a part of this  package , has been moved to Igs_Ru_Gen_005 .
      -- This was done 'cos Check_Child_Existance makes calls to other procedures which are not being shipped !
      -- Check_Child_Existance is called only when the user is not DATAMERGE . Hence , the proc.
      -- Check_Child_Existance_ru_rule is being called using execute immediate only if the user is not DATAMERGE .
      -- Bug # 2233951
      --
     IF (fnd_global.user_id <>  1) THEN
       -- do execute immediate
        EXECUTE IMMEDIATE 'BEGIN  Igs_Ru_Gen_005.Check_Child_Existance_Ru_Call(:1,:2); END;'
	  USING
	     old_references.rud_sequence_number ,
	     old_references.s_rule_call_cd  ;
     END IF;

    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    l_rowid := NULL;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_RU_CALL
      where S_RULE_CALL_CD = X_S_RULE_CALL_CD;
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
    x_s_rule_call_cd =>X_S_RULE_CALL_CD,
    x_s_rule_type_cd =>X_S_RULE_TYPE_CD,
    x_rud_sequence_number =>X_RUD_SEQUENCE_NUMBER,
    x_true_message =>X_TRUE_MESSAGE,
    x_false_message =>X_FALSE_MESSAGE,
    x_default_rule =>X_DEFAULT_RULE,
    x_rug_sequence_number =>X_RUG_SEQUENCE_NUMBER,
    x_select_group =>X_SELECT_GROUP,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  insert into IGS_RU_CALL (
    S_RULE_TYPE_CD,
    S_RULE_CALL_CD,
    RUD_SEQUENCE_NUMBER,
    SELECT_GROUP,
    TRUE_MESSAGE,
    FALSE_MESSAGE,
    DEFAULT_RULE,
    RUG_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.S_RULE_TYPE_CD,
    NEW_REFERENCES.S_RULE_CALL_CD,
    NEW_REFERENCES.RUD_SEQUENCE_NUMBER,
    NEW_REFERENCES.SELECT_GROUP,
    NEW_REFERENCES.TRUE_MESSAGE,
    NEW_REFERENCES.FALSE_MESSAGE,
    NEW_REFERENCES.DEFAULT_RULE,
    NEW_REFERENCES.RUG_SEQUENCE_NUMBER,
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
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER
) AS
  cursor c1 is select
      S_RULE_TYPE_CD,
      RUD_SEQUENCE_NUMBER,
      SELECT_GROUP,
      TRUE_MESSAGE,
      FALSE_MESSAGE,
      DEFAULT_RULE,
      RUG_SEQUENCE_NUMBER
    from IGS_RU_CALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL : P_ACTION  LOCK_ROW  : IGSUI01B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.S_RULE_TYPE_CD = X_S_RULE_TYPE_CD)
      AND (tlinfo.RUD_SEQUENCE_NUMBER = X_RUD_SEQUENCE_NUMBER)
      AND (tlinfo.SELECT_GROUP = X_SELECT_GROUP)
      AND ((tlinfo.TRUE_MESSAGE = X_TRUE_MESSAGE)
           OR ((tlinfo.TRUE_MESSAGE is null)
               AND (X_TRUE_MESSAGE is null)))
      AND ((tlinfo.FALSE_MESSAGE = X_FALSE_MESSAGE)
           OR ((tlinfo.FALSE_MESSAGE is null)
               AND (X_FALSE_MESSAGE is null)))
      AND ((tlinfo.DEFAULT_RULE = X_DEFAULT_RULE)
           OR ((tlinfo.DEFAULT_RULE is null)
               AND (X_DEFAULT_RULE is null)))
      AND ((tlinfo.RUG_SEQUENCE_NUMBER = X_RUG_SEQUENCE_NUMBER)
           OR ((tlinfo.RUG_SEQUENCE_NUMBER is null)
               AND (X_RUG_SEQUENCE_NUMBER is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_CALL : P_ACTION  LOCK_ROW FORM_RECORD_CHANGED  : IGSUI01B.PLS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID,
    x_s_rule_call_cd =>X_S_RULE_CALL_CD,
    x_s_rule_type_cd =>X_S_RULE_TYPE_CD,
    x_rud_sequence_number =>X_RUD_SEQUENCE_NUMBER,
    x_true_message =>X_TRUE_MESSAGE,
    x_false_message =>X_FALSE_MESSAGE,
    x_default_rule =>X_DEFAULT_RULE,
    x_rug_sequence_number =>X_RUG_SEQUENCE_NUMBER,
    x_select_group =>X_SELECT_GROUP,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );

  update IGS_RU_CALL set
    S_RULE_TYPE_CD = NEW_REFERENCES.S_RULE_TYPE_CD,
    RUD_SEQUENCE_NUMBER = NEW_REFERENCES.RUD_SEQUENCE_NUMBER,
    SELECT_GROUP = NEW_REFERENCES.SELECT_GROUP,
    TRUE_MESSAGE = NEW_REFERENCES.TRUE_MESSAGE,
    FALSE_MESSAGE = NEW_REFERENCES.FALSE_MESSAGE,
    DEFAULT_RULE = NEW_REFERENCES.DEFAULT_RULE,
    RUG_SEQUENCE_NUMBER = NEW_REFERENCES.RUG_SEQUENCE_NUMBER,
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
  X_S_RULE_CALL_CD in VARCHAR2,
  X_S_RULE_TYPE_CD in VARCHAR2,
  X_RUD_SEQUENCE_NUMBER in NUMBER,
  X_SELECT_GROUP in NUMBER,
  X_TRUE_MESSAGE in VARCHAR2,
  X_FALSE_MESSAGE in VARCHAR2,
  X_DEFAULT_RULE in NUMBER,
  X_RUG_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_RU_CALL
     where S_RULE_CALL_CD = X_S_RULE_CALL_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_RULE_CALL_CD,
     X_S_RULE_TYPE_CD,
     X_RUD_SEQUENCE_NUMBER,
     X_SELECT_GROUP,
     X_TRUE_MESSAGE,
     X_FALSE_MESSAGE,
     X_DEFAULT_RULE,
     X_RUG_SEQUENCE_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_RULE_CALL_CD,
   X_S_RULE_TYPE_CD,
   X_RUD_SEQUENCE_NUMBER,
   X_SELECT_GROUP,
   X_TRUE_MESSAGE,
   X_FALSE_MESSAGE,
   X_DEFAULT_RULE,
   X_RUG_SEQUENCE_NUMBER,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

Before_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );

  delete from IGS_RU_CALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid  => X_ROWID
  );
end DELETE_ROW;


PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
	) AS
    BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'DEFAULT_RULE' THEN
  new_references.DEFAULT_RULE:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'RUD_SEQUENCE_NUMBER' THEN
  new_references.RUD_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'RUG_SEQUENCE_NUMBER' THEN
  new_references.RUG_SEQUENCE_NUMBER:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SELECT_GROUP' THEN
  new_references.SELECT_GROUP:= igs_ge_number.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'S_RULE_CALL_CD' THEN
  new_references.S_RULE_CALL_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'S_RULE_TYPE_CD' THEN
  new_references.S_RULE_TYPE_CD:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'DEFAULT_RULE' OR COLUMN_NAME IS NULL THEN
  IF new_references.DEFAULT_RULE < 1 or new_references.DEFAULT_RULE > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

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

IF upper(Column_name) = 'SELECT_GROUP' OR COLUMN_NAME IS NULL THEN
  IF new_references.SELECT_GROUP < 1 or new_references.SELECT_GROUP > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_RULE_CALL_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_RULE_CALL_CD<> upper(new_references.S_RULE_CALL_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_RULE_TYPE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_RULE_TYPE_CD<> upper(new_references.S_RULE_TYPE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
END Check_Constraints;

end IGS_RU_CALL_PKG;

/
