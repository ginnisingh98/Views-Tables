--------------------------------------------------------
--  DDL for Package Body IGS_AS_SPCL_CONS_OUT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SPCL_CONS_OUT_PKG" as
/* $Header: IGSDI48B.pls 115.7 2003/05/19 04:44:29 ijeddy ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AS_SPCL_CONS_OUT%RowType;
  new_references IGS_AS_SPCL_CONS_OUT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spcl_consideration_outcome IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_explanation IN VARCHAR2 DEFAULT NULL,
    x_sought_outcome_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_SPCL_CONS_OUT
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
    new_references.spcl_consideration_outcome:= x_spcl_consideration_outcome;
    new_references.description := x_description;
    new_references.explanation := x_explanation;
    new_references.sought_outcome_ind := x_sought_outcome_ind;
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

  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AS_SPL_CONS_APPL_PKG.GET_FK_IGS_AS_SPCL_CONS_OUT(
      old_references.spcl_consideration_outcome
      );

    IGS_AS_SPL_CONS_APPL_PKG.GET_FK_IGS_AS_SPCL_CONS_OUT(
      old_references.spcl_consideration_outcome
      );

  END Check_Child_Existance;

  FUNCTION   Get_PK_For_Validation (
    x_spcl_consideration_outcome IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_SPCL_CONS_OUT
      WHERE    spcl_consideration_outcome= x_spcl_consideration_outcome
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

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN
      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'CLOSED_IND' then
         new_references.closed_ind:= column_value;
      ELSIF upper(Column_name) = 'SOUGHT_OUTCOME_IND' then
         new_references.sought_outcome_ind:= column_value;
      ELSIF upper(Column_name) = 'SPCL_CONSIDERATION_OUTCOME' then
         new_references.spcl_consideration_outcome:= column_value;
      END IF;

     IF upper(column_name) = 'CLOSED_IND' OR
        column_name is null Then
        IF new_references.closed_ind <> UPPER(new_references.closed_ind) or  new_references.closed_ind NOT IN ( 'Y' , 'N' ) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'SPCL_CONSIDERATION_OUTCOME' OR
        column_name is null Then
        IF new_references.spcl_consideration_outcome <> UPPER(new_references.spcl_consideration_outcome) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;
     IF upper(column_name) = 'SOUGHT_OUTCOME_IND' OR
        column_name is null Then
        IF new_references.sought_outcome_ind NOT IN ( 'Y' , 'N' ) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

END Check_Constraints;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_spcl_consideration_outcome IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_explanation IN VARCHAR2 DEFAULT NULL,
    x_sought_outcome_ind IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_spcl_consideration_outcome,
      x_description,
      x_explanation,
      x_sought_outcome_ind,
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
IF  Get_PK_For_Validation (
             new_references.spcl_consideration_outcome
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
Igs_Ge_Msg_Stack.Add;
App_Exception.Raise_Exception;
END IF;

      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
     Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.spcl_consideration_outcome
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
Igs_Ge_Msg_Stack.Add;
App_Exception.Raise_Exception;
END IF;
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Check_Child_Existance;
    END IF;
/* Code added by ijeddy for Bug# 2868726 */
L_ROWID := null;
  END Before_DML;



procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_SOUGHT_OUTCOME_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AS_SPCL_CONS_OUT
      where SPCL_CONSIDERATION_OUTCOME = X_SPCL_CONSIDERATION_OUTCOME;
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
  x_closed_ind=> NVL(X_CLOSED_IND,'N'),
  x_description=>X_DESCRIPTION,
  x_explanation=>X_EXPLANATION,
  x_sought_outcome_ind=> NVL(X_SOUGHT_OUTCOME_IND,'Y'),
  x_spcl_consideration_outcome=>X_SPCL_CONSIDERATION_OUTCOME,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AS_SPCL_CONS_OUT (
    SPCL_CONSIDERATION_OUTCOME,
    DESCRIPTION,
    EXPLANATION,
    SOUGHT_OUTCOME_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SPCL_CONSIDERATION_OUTCOME,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.EXPLANATION,
    NEW_REFERENCES.SOUGHT_OUTCOME_IND,
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
  X_ROWID in  VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_SOUGHT_OUTCOME_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) as
  cursor c1 is select
      DESCRIPTION,
      EXPLANATION,
      SOUGHT_OUTCOME_IND,
      CLOSED_IND
    from IGS_AS_SPCL_CONS_OUT
    where ROWID = X_ROWID  for update  nowait;
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.EXPLANATION = X_EXPLANATION)
      AND (tlinfo.SOUGHT_OUTCOME_IND = X_SOUGHT_OUTCOME_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
  X_ROWID in  VARCHAR2,
  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_SOUGHT_OUTCOME_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
 Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_closed_ind=>X_CLOSED_IND,
  x_description=>X_DESCRIPTION,
  x_explanation=>X_EXPLANATION,
  x_sought_outcome_ind=>X_SOUGHT_OUTCOME_IND,
  x_spcl_consideration_outcome=>X_SPCL_CONSIDERATION_OUTCOME,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  update IGS_AS_SPCL_CONS_OUT set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    EXPLANATION = NEW_REFERENCES.EXPLANATION,
    SOUGHT_OUTCOME_IND = NEW_REFERENCES.SOUGHT_OUTCOME_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,

  X_SPCL_CONSIDERATION_OUTCOME in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_EXPLANATION in VARCHAR2,
  X_SOUGHT_OUTCOME_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AS_SPCL_CONS_OUT
     where SPCL_CONSIDERATION_OUTCOME = X_SPCL_CONSIDERATION_OUTCOME
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SPCL_CONSIDERATION_OUTCOME,
     X_DESCRIPTION,
     X_EXPLANATION,
     X_SOUGHT_OUTCOME_IND,
     X_CLOSED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SPCL_CONSIDERATION_OUTCOME,
   X_DESCRIPTION,
   X_EXPLANATION,
   X_SOUGHT_OUTCOME_IND,
   X_CLOSED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_SPCL_CONS_OUT
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_AS_SPCL_CONS_OUT_PKG;

/
