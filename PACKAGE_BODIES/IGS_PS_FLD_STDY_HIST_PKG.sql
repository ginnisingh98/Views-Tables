--------------------------------------------------------
--  DDL for Package Body IGS_PS_FLD_STDY_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_FLD_STDY_HIST_PKG" as
 /* $Header: IGSPI55B.pls 120.1 2006/07/25 15:06:56 sommukhe noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_FLD_STDY_HIST_ALL%RowType;
  new_references IGS_PS_FLD_STDY_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_fos_type_code IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_FLD_STDY_HIST_ALL
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
    new_references.hist_who := x_hist_who;
    new_references.description := x_description;
    new_references.govt_field_of_study := x_govt_field_of_study;
    new_references.closed_ind := x_closed_ind;
    new_references.field_of_study := x_field_of_study;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
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
    new_references.fos_type_code := x_fos_type_code;

  END Set_Column_Values;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'CLOSED_IND' then
     new_references.closed_ind := column_value;
 ELSIF upper(Column_name) = 'FIELD_OF_STUDY' then
     new_references.field_of_study := column_value;
 ELSIF upper(Column_name) = 'GOVT_FIELD_OF_STUDY' then
     new_references.govt_field_of_study := column_value;
END IF;

IF upper(column_name) = 'CLOSED_IND' OR
     column_name is null Then
     IF new_references.closed_ind NOT IN ('Y','N') THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'FIELD_OF_STUDY' OR
     column_name is null Then
     IF new_references.field_of_study <> UPPER(new_references.field_of_study) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'GOVT_FIELD_OF_STUDY' OR
     column_name is null Then
     IF new_references.govt_field_of_study <> UPPER(new_references.govt_field_of_study) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;

  FUNCTION Get_PK_For_Validation (
    x_field_of_study IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_FLD_STDY_HIST_ALL
      WHERE    field_of_study = x_field_of_study
      AND      hist_start_dt = x_hist_start_dt
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_govt_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_fos_type_code IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_hist_who,
      x_description,
      x_govt_field_of_study,
      x_closed_ind,
      x_field_of_study,
      x_hist_start_dt,
      x_hist_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_fos_type_code
    );
 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      IF  Get_PK_For_Validation (
		    new_references.field_of_study,
		    new_references.hist_start_dt
		 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       Check_Constraints;

 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
		    new_references.field_of_study,
		    new_references.hist_start_dt
		 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_FOS_TYPE_CODE VARCHAR2
  ) as
    cursor C is select ROWID from IGS_PS_FLD_STDY_HIST_ALL
      where FIELD_OF_STUDY = X_FIELD_OF_STUDY
      and HIST_START_DT = X_HIST_START_DT;
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

  Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_hist_who => X_HIST_WHO,
    x_description => X_DESCRIPTION,
    x_govt_field_of_study => X_GOVT_FIELD_OF_STUDY,
    x_closed_ind => X_CLOSED_IND,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_fos_type_code => X_FOS_TYPE_CODE
  );

  insert into IGS_PS_FLD_STDY_HIST_ALL (
    FIELD_OF_STUDY,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    DESCRIPTION,
    GOVT_FIELD_OF_STUDY,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    FOS_TYPE_CODE
  ) values (
    NEW_REFERENCES.FIELD_OF_STUDY,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_FIELD_OF_STUDY,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.FOS_TYPE_CODE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_FOS_TYPE_CODE VARCHAR2

) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      DESCRIPTION,
      GOVT_FIELD_OF_STUDY,
      CLOSED_IND

    from IGS_PS_FLD_STDY_HIST_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION is null)
               AND (X_DESCRIPTION is null)))
      AND ((tlinfo.GOVT_FIELD_OF_STUDY = X_GOVT_FIELD_OF_STUDY)
           OR ((tlinfo.GOVT_FIELD_OF_STUDY is null)
               AND (X_GOVT_FIELD_OF_STUDY is null)))
      AND ((tlinfo.CLOSED_IND = X_CLOSED_IND)
           OR ((tlinfo.CLOSED_IND is null)
               AND (X_CLOSED_IND is null)))

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
  X_FIELD_OF_STUDY in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_FOS_TYPE_CODE in VARCHAR2,
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
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_hist_who => X_HIST_WHO,
    x_description => X_DESCRIPTION,
    x_govt_field_of_study => X_GOVT_FIELD_OF_STUDY,
    x_closed_ind => X_CLOSED_IND,
    x_field_of_study => X_FIELD_OF_STUDY,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_fos_type_code => X_FOS_TYPE_CODE
  );
  update IGS_PS_FLD_STDY_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_FIELD_OF_STUDY = NEW_REFERENCES.GOVT_FIELD_OF_STUDY,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    FOS_TYPE_CODE = NEW_REFERENCES.FOS_TYPE_CODE

  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_FIELD_OF_STUDY in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_FOS_TYPE_CODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_PS_FLD_STDY_HIST_ALL
     where FIELD_OF_STUDY = X_FIELD_OF_STUDY
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FIELD_OF_STUDY,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_DESCRIPTION,
     X_GOVT_FIELD_OF_STUDY,
     X_CLOSED_IND,
     X_MODE,
     X_ORG_ID,
     X_FOS_TYPE_CODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_FIELD_OF_STUDY,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_DESCRIPTION,
   X_GOVT_FIELD_OF_STUDY,
   X_CLOSED_IND,
   X_FOS_TYPE_CODE,
   X_MODE
   );
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) as
begin
  Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
     );
  delete from IGS_PS_FLD_STDY_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_FLD_STDY_HIST_PKG;

/
