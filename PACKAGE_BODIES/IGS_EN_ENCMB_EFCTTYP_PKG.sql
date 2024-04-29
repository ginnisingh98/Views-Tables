--------------------------------------------------------
--  DDL for Package Body IGS_EN_ENCMB_EFCTTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ENCMB_EFCTTYP_PKG" AS
/* $Header: IGSEI32B.pls 115.5 2003/02/17 12:31:08 adhawan ship $ */

l_rowid VARCHAR2(25);
  old_references IGS_EN_ENCMB_EFCTTYP%RowType;
  new_references IGS_EN_ENCMB_EFCTTYP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_apply_to_course_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ENCMB_EFCTTYP
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ( 'INSERT','VALIDATE_INSERT' )) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.s_encmb_effect_type := x_s_encmb_effect_type;
    new_references.apply_to_course_ind := x_apply_to_course_ind;
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

  procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
      		NULL;
          ELSIF upper(column_name) = 'APPLY_TO_COURSE_IND' THEN
              new_references.apply_to_course_ind := column_value;
         ELSIF upper(column_name) = 'CLOSED_IND' THEN
              new_references.closed_ind := column_value;
        ELSIF upper(column_name) = 'S_ENCMB_EFFECT_TYPE' THEN
             new_references.s_encmb_effect_type := column_value;
        END IF;

IF upper(column_name) = 'APPLY_TO_COURSE_IND' OR
       Column_name is null THEN
       IF new_references.apply_to_course_ind NOT IN ('Y','N') THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'CLOSED_IND' OR
       Column_name is null THEN
       IF new_references.closed_ind NOT IN ('Y','N') THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'S_ENCMB_EFFECT_TYPE' OR
       Column_name is null THEN
       IF new_references.s_encmb_effect_type <>
                    upper(new_references.s_encmb_effect_type)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

END check_constraints;

 FUNCTION Get_PK_For_Validation (
    x_s_encmb_effect_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ENCMB_EFCTTYP
      WHERE    s_encmb_effect_type = x_s_encmb_effect_type;


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_s_encmb_effect_type IN VARCHAR2 DEFAULT NULL,
    x_apply_to_course_ind IN VARCHAR2 DEFAULT NULL,
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
      x_s_encmb_effect_type,
      x_apply_to_course_ind,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	 IF Get_PK_For_Validation (
	    new_references.s_encmb_effect_type
    	) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;
      Check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_constraints;


   ELSIF (p_action = 'VALIDATE_INSERT') then
	 IF Get_PK_For_Validation (
	    new_references.s_encmb_effect_type
    	) THEN
	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
    IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;

   Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;
   END IF;
 END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ENCMB_EFCTTYP
      where S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE;
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
    p_action =>'INSERT',
    x_rowid =>  x_rowid,
    x_s_encmb_effect_type => x_s_encmb_effect_type,
    x_apply_to_course_ind => x_apply_to_course_ind,
    x_closed_ind => x_closed_ind,
    x_creation_date => X_LAST_UPDATE_date,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login
  );
  insert into IGS_EN_ENCMB_EFCTTYP (
    S_ENCMB_EFFECT_TYPE,
    APPLY_TO_COURSE_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    new_references.S_ENCMB_EFFECT_TYPE,
    new_references.APPLY_TO_COURSE_IND,
    new_references.CLOSED_IND,
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
    p_action =>'INSERT',
    x_rowid =>  x_rowid );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) AS
  cursor c1 is select
      APPLY_TO_COURSE_IND,
       CLOSED_IND
    from IGS_EN_ENCMB_EFCTTYP
    where ROWID = X_ROWID  for update nowait;
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

  if ( (tlinfo.APPLY_TO_COURSE_IND = X_APPLY_TO_COURSE_IND)
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
  X_ROWID IN VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
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

Before_DML (
    p_action =>'UPDATE',
    x_rowid =>  x_rowid,
    x_s_encmb_effect_type => x_s_encmb_effect_type,
    x_apply_to_course_ind => x_apply_to_course_ind,
    x_closed_ind => x_closed_ind,
    x_creation_date => X_LAST_UPDATE_date,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login
  );
  update IGS_EN_ENCMB_EFCTTYP set
    APPLY_TO_COURSE_IND = X_APPLY_TO_COURSE_IND,
    CLOSED_IND = X_CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'UPDATE',
    x_rowid =>  x_rowid );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_ENCMB_EFFECT_TYPE in VARCHAR2,
  X_APPLY_TO_COURSE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ENCMB_EFCTTYP
     where S_ENCMB_EFFECT_TYPE = X_S_ENCMB_EFFECT_TYPE;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_ENCMB_EFFECT_TYPE,
      X_APPLY_TO_COURSE_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_ENCMB_EFFECT_TYPE,
   X_APPLY_TO_COURSE_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;


END igs_en_encmb_efcttyp_pkg;

/
