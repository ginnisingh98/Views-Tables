--------------------------------------------------------
--  DDL for Package Body IGS_AV_STND_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_STND_CONF_PKG" as
/* $Header: IGSBI03B.pls 115.11 2003/01/07 07:22:04 nalkumar ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AV_STND_CONF_ALL%RowType;
  new_references IGS_AV_STND_CONF_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_s_control_num IN NUMBER,
    x_expiry_dt_increment IN NUMBER,
    x_adv_stnd_expiry_dt_alias IN VARCHAR2,
    x_adv_stnd_basis_inst IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AV_STND_CONF_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.s_control_num := x_s_control_num;
    new_references.expiry_dt_increment := x_expiry_dt_increment;
    new_references.adv_stnd_expiry_dt_alias := x_adv_stnd_expiry_dt_alias;
    new_references.adv_stnd_basis_inst := x_adv_stnd_basis_inst;
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
    new_references.org_id := x_org_id;

  END Set_Column_Values;
--*
---
PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2,
 Column_Value 	IN	VARCHAR2
)
 AS
 BEGIN
 IF  column_name is null then
        NULL;
    ELSIF upper(Column_name) = 'EXPIRY_DT_INCREMENT' then
       new_references.EXPIRY_DT_INCREMENT := igs_ge_number.to_num(column_value);
    ELSIF upper(Column_name) = 'S_CONTROL_NUM' then
       new_references.S_CONTROL_NUM := TO_NUMBER(column_value);
    ELSIF upper(Column_name) = 'ADV_STND_EXPIRY_DT_ALIAS' then
       new_references.ADV_STND_EXPIRY_DT_ALIAS := column_value;
    ELSIF upper(Column_name) = 'ADV_STND_BASIS_INST' then
       new_references.ADV_STND_BASIS_INST  := column_value;
    END IF ;

IF upper(column_name) = 'EXPIRY_DT_INCREMENT' OR
     column_name is null Then
     IF new_references.EXPIRY_DT_INCREMENT  < 1 OR
          new_references.EXPIRY_DT_INCREMENT > 99 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'S_CONTROL_NUM' OR
     column_name is null Then
     IF new_references.S_CONTROL_NUM  < 1 OR
          new_references.S_CONTROL_NUM > 1 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       Igs_Ge_Msg_Stack.Add;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADV_STND_EXPIRY_DT_ALIAS' OR
     column_name is null Then
     IF new_references.ADV_STND_EXPIRY_DT_ALIAS <> UPPER(new_references.ADV_STND_EXPIRY_DT_ALIAS) Then
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADV_STND_BASIS_INST' OR
     column_name is null Then
     IF new_references.ADV_STND_BASIS_INST <> UPPER(new_references.ADV_STND_BASIS_INST) Then
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
     END IF;
END IF;

END Check_Constraints;
---

  FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
    ) RETURN BOOLEAN
    AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_STND_CONF_ALL
      WHERE    s_control_num = x_s_control_num
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
---
           IF (cur_rowid%FOUND) THEN
                 Close cur_rowid;
                 Return (TRUE);
           ELSE
                Close cur_rowid;
           Return (FALSE);
           END IF;
---
  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2,
    x_s_control_num IN NUMBER,
    x_expiry_dt_increment IN NUMBER,
    x_adv_stnd_expiry_dt_alias IN VARCHAR2,
    x_adv_stnd_basis_inst IN VARCHAR2,
    x_creation_date IN DATE,
    x_created_by IN NUMBER,
    x_last_update_date IN DATE,
    x_last_updated_by IN NUMBER,
    x_last_update_login IN NUMBER,
    x_org_id IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_expiry_dt_increment,
      x_adv_stnd_expiry_dt_alias,
      x_adv_stnd_basis_inst,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
     IF Get_PK_For_Validation (new_references.s_control_num )
        THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints ;
--*
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints ;
--*
   ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF Get_PK_For_Validation (new_references.s_control_num ) THEN
           Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
           Igs_Ge_Msg_Stack.Add;
           App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
         Check_Constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
null;
END IF;

END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_AV_STND_CONF_ALL
      where S_CONTROL_NUM = NEW_REFERENCES.S_CONTROL_NUM;
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_adv_stnd_basis_inst=>X_ADV_STND_BASIS_INST,
  x_adv_stnd_expiry_dt_alias=>X_ADV_STND_EXPIRY_DT_ALIAS,
  x_expiry_dt_increment=>X_EXPIRY_DT_INCREMENT,
  x_s_control_num=>NVL(X_S_CONTROL_NUM,1),
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_org_id=>igs_ge_gen_003.get_org_id
  );

  insert into IGS_AV_STND_CONF_ALL (
    S_CONTROL_NUM,
    EXPIRY_DT_INCREMENT,
    ADV_STND_EXPIRY_DT_ALIAS,
    ADV_STND_BASIS_INST,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.S_CONTROL_NUM,
    NEW_REFERENCES.EXPIRY_DT_INCREMENT,
    NEW_REFERENCES.ADV_STND_EXPIRY_DT_ALIAS,
    NEW_REFERENCES.ADV_STND_BASIS_INST,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2
	) AS
  cursor c1 is select
      EXPIRY_DT_INCREMENT,
      ADV_STND_EXPIRY_DT_ALIAS,
      ADV_STND_BASIS_INST
    from IGS_AV_STND_CONF_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.EXPIRY_DT_INCREMENT = X_EXPIRY_DT_INCREMENT)
      AND ((tlinfo.ADV_STND_EXPIRY_DT_ALIAS = X_ADV_STND_EXPIRY_DT_ALIAS)
           OR ((tlinfo.ADV_STND_EXPIRY_DT_ALIAS is null)
               AND (X_ADV_STND_EXPIRY_DT_ALIAS is null)))
      AND ((tlinfo.ADV_STND_BASIS_INST = X_ADV_STND_BASIS_INST)
           OR ((tlinfo.ADV_STND_BASIS_INST is null)
               AND (X_ADV_STND_BASIS_INST is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;

  Before_DML(
   p_action=>'UPDATE',
   x_rowid=>X_ROWID,
   x_adv_stnd_basis_inst=>X_ADV_STND_BASIS_INST,
   x_adv_stnd_expiry_dt_alias=>X_ADV_STND_EXPIRY_DT_ALIAS,
   x_expiry_dt_increment=>X_EXPIRY_DT_INCREMENT,
   x_s_control_num=>X_S_CONTROL_NUM,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  update IGS_AV_STND_CONF_ALL set
    EXPIRY_DT_INCREMENT = NEW_REFERENCES.EXPIRY_DT_INCREMENT,
    ADV_STND_EXPIRY_DT_ALIAS = NEW_REFERENCES.ADV_STND_EXPIRY_DT_ALIAS,
    ADV_STND_BASIS_INST = NEW_REFERENCES.ADV_STND_BASIS_INST,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_EXPIRY_DT_INCREMENT in NUMBER,
  X_ADV_STND_EXPIRY_DT_ALIAS in VARCHAR2,
  X_ADV_STND_BASIS_INST in VARCHAR2,
  X_MODE in VARCHAR2,
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AV_STND_CONF_ALL
     where S_CONTROL_NUM = NVL(X_S_CONTROL_NUM,1)
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_CONTROL_NUM,
     X_EXPIRY_DT_INCREMENT,
     X_ADV_STND_EXPIRY_DT_ALIAS,
     X_ADV_STND_BASIS_INST,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_CONTROL_NUM,
   X_EXPIRY_DT_INCREMENT,
   X_ADV_STND_EXPIRY_DT_ALIAS,
   X_ADV_STND_BASIS_INST,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AV_STND_CONF_ALL
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

END igs_av_stnd_conf_pkg;

/
