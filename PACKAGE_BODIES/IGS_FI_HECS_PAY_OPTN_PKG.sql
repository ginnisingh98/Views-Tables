--------------------------------------------------------
--  DDL for Package Body IGS_FI_HECS_PAY_OPTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_HECS_PAY_OPTN_PKG" AS
/* $Header: IGSSI54B.pls 115.3 2002/11/29 03:50:52 nsidana ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_FI_HECS_PAY_OPTN%RowType;
  new_references IGS_FI_HECS_PAY_OPTN%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_expire_aftr_acdmc_perd_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_FI_HECS_PAY_OPTN
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
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.govt_hecs_payment_option := x_govt_hecs_payment_option;
    new_references.description := x_description;
    new_references.expire_aftr_acdmc_perd_ind := x_expire_aftr_acdmc_perd_ind;
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
  PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER (column_name) = 'CLOSED_IND') THEN
      new_references.closed_ind := column_value;
    ELSIF (UPPER (column_name) = 'EXPIRE_AFTR_ACDMC_PERD_IND') THEN
      new_references.expire_aftr_acdmc_perd_ind := column_value;
    ELSIF (UPPER (column_name) = 'DESCRIPTION') THEN
      new_references.description := column_value;
    ELSIF (UPPER (column_name) = 'GOVT_HECS_PAYMENT_OPTION') THEN
      new_references.govt_hecs_payment_option := column_value;
    ELSIF (UPPER (column_name) = 'HECS_PAYMENT_OPTION') THEN
      new_references.hecs_payment_option := column_value;
    END IF;
    IF ((UPPER (column_name) = 'CLOSED_IND') OR (column_name IS NULL)) THEN
      IF (new_references.closed_ind NOT IN ('Y', 'N')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'EXPIRE_AFTR_ACDMC_PERD_IND') OR (column_name IS NULL)) THEN
      IF (new_references.expire_aftr_acdmc_perd_ind NOT IN ('Y', 'N')) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'GOVT_HECS_PAYMENT_OPTION') OR (column_name IS NULL)) THEN
      IF (new_references.govt_hecs_payment_option <> UPPER (new_references.govt_hecs_payment_option)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
    IF ((UPPER (column_name) = 'HECS_PAYMENT_OPTION') OR (column_name IS NULL)) THEN
      IF (new_references.hecs_payment_option <> UPPER (new_references.hecs_payment_option)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END;
  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.govt_hecs_payment_option = new_references.govt_hecs_payment_option)) OR
        ((new_references.govt_hecs_payment_option IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_GOV_HEC_PA_OP_PKG.Get_PK_For_Validation (
               new_references.govt_hecs_payment_option
               ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END Check_Parent_Existance;
  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_AD_CT_HECS_PAYOP_PKG.GET_FK_IGS_FI_HECS_PAY_OPTN (
      old_references.hecs_payment_option
      );
    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_FI_HECS_PAY_OPTN (
      old_references.hecs_payment_option
      );
    IGS_EN_STDNTPSHECSOP_PKG.GET_FK_IGS_FI_HECS_PAY_OPTN (
      old_references.hecs_payment_option
      );
  END Check_Child_Existance;
  FUNCTION Get_PK_For_Validation (
    x_hecs_payment_option IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_HECS_PAY_OPTN
      WHERE    hecs_payment_option = x_hecs_payment_option
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
  PROCEDURE GET_FK_IGS_FI_GOV_HEC_PA_OP (
    x_govt_hecs_payment_option IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_HECS_PAY_OPTN
      WHERE    govt_hecs_payment_option = x_govt_hecs_payment_option ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_HPO_GHPO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_FI_GOV_HEC_PA_OP;
  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_expire_aftr_acdmc_perd_ind IN VARCHAR2 DEFAULT NULL,
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
      x_hecs_payment_option,
      x_govt_hecs_payment_option,
      x_description,
      x_expire_aftr_acdmc_perd_ind,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF (Get_PK_For_Validation (
            new_references.hecs_payment_option
            )) THEN
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF (Get_PK_For_Validation (
            new_references.hecs_payment_option
          )) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPIRE_AFTR_ACDMC_PERD_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_HECS_PAY_OPTN
      where HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION;
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
 x_closed_ind=>NVL(X_CLOSED_IND,'N'),
 x_description=>X_DESCRIPTION,
 x_expire_aftr_acdmc_perd_ind=>NVL(X_EXPIRE_AFTR_ACDMC_PERD_IND,'N'),
 x_govt_hecs_payment_option=>X_GOVT_HECS_PAYMENT_OPTION,
 x_hecs_payment_option=>X_HECS_PAYMENT_OPTION,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  insert into IGS_FI_HECS_PAY_OPTN (
    HECS_PAYMENT_OPTION,
    GOVT_HECS_PAYMENT_OPTION,
    DESCRIPTION,
    EXPIRE_AFTR_ACDMC_PERD_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.HECS_PAYMENT_OPTION,
    NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.EXPIRE_AFTR_ACDMC_PERD_IND,
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
end INSERT_ROW;
procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPIRE_AFTR_ACDMC_PERD_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      GOVT_HECS_PAYMENT_OPTION,
      DESCRIPTION,
      EXPIRE_AFTR_ACDMC_PERD_IND,
      CLOSED_IND
    from IGS_FI_HECS_PAY_OPTN
    where ROWID=X_ROWID
    for update nowait;
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
      if ( ((tlinfo.GOVT_HECS_PAYMENT_OPTION = X_GOVT_HECS_PAYMENT_OPTION)
           OR ((tlinfo.GOVT_HECS_PAYMENT_OPTION is null)
               AND (X_GOVT_HECS_PAYMENT_OPTION is null)))
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.EXPIRE_AFTR_ACDMC_PERD_IND = X_EXPIRE_AFTR_ACDMC_PERD_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPIRE_AFTR_ACDMC_PERD_IND in VARCHAR2,
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_closed_ind=>X_CLOSED_IND,
 x_description=>X_DESCRIPTION,
 x_expire_aftr_acdmc_perd_ind=>X_EXPIRE_AFTR_ACDMC_PERD_IND,
 x_govt_hecs_payment_option=>X_GOVT_HECS_PAYMENT_OPTION,
 x_hecs_payment_option=>X_HECS_PAYMENT_OPTION,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);
  update IGS_FI_HECS_PAY_OPTN set
    GOVT_HECS_PAYMENT_OPTION = NEW_REFERENCES.GOVT_HECS_PAYMENT_OPTION,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    EXPIRE_AFTR_ACDMC_PERD_IND = NEW_REFERENCES.EXPIRE_AFTR_ACDMC_PERD_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;
procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_GOVT_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPIRE_AFTR_ACDMC_PERD_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_HECS_PAY_OPTN
     where HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_HECS_PAYMENT_OPTION,
     X_GOVT_HECS_PAYMENT_OPTION,
     X_DESCRIPTION,
     X_EXPIRE_AFTR_ACDMC_PERD_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_HECS_PAYMENT_OPTION,
   X_GOVT_HECS_PAYMENT_OPTION,
   X_DESCRIPTION,
   X_EXPIRE_AFTR_ACDMC_PERD_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_HECS_PAY_OPTN
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_HECS_PAY_OPTN_PKG;

/
