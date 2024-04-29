--------------------------------------------------------
--  DDL for Package Body IGS_AS_MARK_SHEET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_MARK_SHEET_PKG" as
/* $Header: IGSDI44B.pls 115.9 2002/11/28 23:21:35 nsidana ship $ */

 l_rowid VARCHAR2(25);
  old_references IGS_AS_MARK_SHEET_ALL%RowType;
  new_references IGS_AS_MARK_SHEET_ALL%RowType;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_sheet_number IN NUMBER DEFAULT NULL,
    x_group_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_production_dt IN DATE DEFAULT NULL,
    x_duplicate_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_grading_period_cd IN VARCHAR2 DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AS_MARK_SHEET_ALL
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
    new_references.org_id := x_org_id;
    new_references.sheet_number := x_sheet_number;
    new_references.group_sequence_number := x_group_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.unit_mode := x_unit_mode;
    new_references.production_dt := x_production_dt;
    new_references.duplicate_ind := x_duplicate_ind;
    new_references.grading_period_cd := x_grading_period_cd;
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


  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT(IGS_PS_UNIT_OFR_PAT_PKG.Get_PK_For_Validation (
        new_references.unit_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.ci_sequence_number
        ))THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     Igs_Ge_Msg_Stack.Add;
     App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) IS
BEGIN

      IF  column_name is null then
         NULL;
      ELSIF upper(Column_name) = 'CAL_TYPE' then
         new_references.cal_type:= column_value;
      ELSIF upper(Column_name) = 'UNIT_CD' then
         new_references.unit_cd:= column_value;
      ELSIF upper(Column_name) = 'CI_SEQUENCE_NUMBER' then
         new_references.ci_sequence_number:= IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF upper(Column_name) = 'GROUP_SEQUENCE_NUMBER' then
         new_references.group_sequence_number:= IGS_GE_NUMBER.TO_NUM(column_value);
      ELSIF upper(Column_name) = 'DUPLICATE_IND' then
         new_references.duplicate_ind:= column_value;
      END IF;

     IF upper(column_name) = 'CAL_TYPE' OR
        column_name is null Then
        IF new_references.cal_type <> UPPER(new_references.cal_type) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'UNIT_CD' OR
        column_name is null Then
        IF new_references.unit_cd <> UPPER(new_references.unit_cd) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF new_references.ci_sequence_number < 1  AND   new_references.ci_sequence_number > 999999 Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'GROUP_SEQUENCE_NUMBER' OR
        column_name is null Then
        IF  new_references.group_sequence_number < 1  AND   new_references.group_sequence_number > 999999  Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

     IF upper(column_name) = 'DUPLICATE_IND' OR
        column_name is null Then
        IF  new_references.duplicate_ind NOT  IN ( 'Y' , 'N' ) Then
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
        END IF;
     END IF;

END Check_Constraints;


  PROCEDURE Check_Child_Existance as
  BEGIN

    IGS_AS_MSHT_SU_ATMPT_PKG.GET_FK_IGS_AS_MARK_SHEET (
      old_references.sheet_number
      );

  END Check_Child_Existance;

  FUNCTION   Get_PK_For_Validation (
    x_sheet_number IN NUMBER
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_MARK_SHEET_ALL
      WHERE    sheet_number = x_sheet_number
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

  PROCEDURE GET_FK_IGS_PS_UNIT_OFR_PAT (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AS_MARK_SHEET_ALL
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AS_MS_UOP_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_UNIT_OFR_PAT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_sheet_number IN NUMBER DEFAULT NULL,
    x_group_sequence_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_mode IN VARCHAR2 DEFAULT NULL,
    x_production_dt IN DATE DEFAULT NULL,
    x_duplicate_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_period_cd IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_sheet_number,
      x_group_sequence_number,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_unit_mode,
      x_production_dt,
      x_duplicate_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_grading_period_cd
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
IF  Get_PK_For_Validation (
             new_references.sheet_number
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
Igs_Ge_Msg_Stack.Add;
App_Exception.Raise_Exception;
END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
IF  Get_PK_For_Validation (
             new_references.sheet_number
			             ) THEN
Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
Igs_Ge_Msg_Stack.Add;
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
  X_ORG_ID in NUMBER,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_PERIOD_CD in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_AS_MARK_SHEET_ALL
      where SHEET_NUMBER = X_SHEET_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;
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
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;

   X_PROGRAM_APPLICATION_ID :=
                                       FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := NULL;
     X_PROGRAM_ID := NULL;
     X_PROGRAM_APPLICATION_ID := NULL;
     X_PROGRAM_UPDATE_DATE := NULL;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_org_id=>igs_ge_gen_003.get_org_id,
 x_cal_type=>X_CAL_TYPE,
 x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
 x_duplicate_ind=> NVL(X_DUPLICATE_IND,'N'),
 x_group_sequence_number=>X_GROUP_SEQUENCE_NUMBER,
 x_location_cd=>X_LOCATION_CD,
 x_production_dt=>X_PRODUCTION_DT,
 x_sheet_number=>X_SHEET_NUMBER,
 x_unit_cd=>X_UNIT_CD,
 x_unit_mode=>X_UNIT_MODE,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_grading_period_cd=>X_GRADING_PERIOD_CD
);

  insert into IGS_AS_MARK_SHEET_ALL(
    ORG_ID,
    SHEET_NUMBER,
    GROUP_SEQUENCE_NUMBER,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    UNIT_MODE,
    PRODUCTION_DT,
    DUPLICATE_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    GRADING_PERIOD_CD
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.SHEET_NUMBER,
    NEW_REFERENCES.GROUP_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.UNIT_MODE,
    NEW_REFERENCES.PRODUCTION_DT,
    NEW_REFERENCES.DUPLICATE_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE ,
    NEW_REFERENCES.GRADING_PERIOD_CD
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
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_GRADING_PERIOD_CD in VARCHAR2
) as
  cursor c1 is select
      GROUP_SEQUENCE_NUMBER,
      UNIT_CD,
      VERSION_NUMBER,
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      LOCATION_CD,
      UNIT_MODE,
      PRODUCTION_DT,
      DUPLICATE_IND,
      GRADING_PERIOD_CD
    from IGS_AS_MARK_SHEET_ALL
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

  if ( (tlinfo.GROUP_SEQUENCE_NUMBER = X_GROUP_SEQUENCE_NUMBER)
      AND (tlinfo.UNIT_CD = X_UNIT_CD)
      AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.CAL_TYPE = X_CAL_TYPE)
      AND (tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
      AND (tlinfo.LOCATION_CD = X_LOCATION_CD)
      AND (tlinfo.UNIT_MODE = X_UNIT_MODE)
      AND (tlinfo.PRODUCTION_DT = X_PRODUCTION_DT)
      AND (tlinfo.DUPLICATE_IND = X_DUPLICATE_IND)
      AND (tlinfo.GRADING_PERIOD_CD = X_GRADING_PERIOD_CD)
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
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_PERIOD_CD in VARCHAR2
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID NUMBER;
    X_PROGRAM_ID NUMBER;
    X_PROGRAM_APPLICATION_ID NUMBER;
    X_PROGRAM_UPDATE_DATE DATE;

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
  x_cal_type=>X_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_duplicate_ind=>X_DUPLICATE_IND,
  x_group_sequence_number=>X_GROUP_SEQUENCE_NUMBER,
  x_location_cd=>X_LOCATION_CD,
  x_production_dt=>X_PRODUCTION_DT,
  x_sheet_number=>X_SHEET_NUMBER,
  x_unit_cd=>X_UNIT_CD,
  x_unit_mode=>X_UNIT_MODE,
  x_version_number=>X_VERSION_NUMBER,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN,
  x_grading_period_cd=>X_GRADING_PERIOD_CD
  );
 if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
  if (X_REQUEST_ID = -1) then
     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
     X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
     X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
 else
     X_PROGRAM_UPDATE_DATE := SYSDATE;
 end if;
end if;

  update IGS_AS_MARK_SHEET_ALL set
    GROUP_SEQUENCE_NUMBER = NEW_REFERENCES.GROUP_SEQUENCE_NUMBER,
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    UNIT_MODE = NEW_REFERENCES.UNIT_MODE,
    PRODUCTION_DT = NEW_REFERENCES.PRODUCTION_DT,
    DUPLICATE_IND = NEW_REFERENCES.DUPLICATE_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    GRADING_PERIOD_CD = X_GRADING_PERIOD_CD
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_SHEET_NUMBER in NUMBER,
  X_GROUP_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_UNIT_MODE in VARCHAR2,
  X_PRODUCTION_DT in DATE,
  X_DUPLICATE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_GRADING_PERIOD_CD in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_AS_MARK_SHEET_ALL
     where SHEET_NUMBER = X_SHEET_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_SHEET_NUMBER,
     X_GROUP_SEQUENCE_NUMBER,
     X_UNIT_CD,
     X_VERSION_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_UNIT_MODE,
     X_PRODUCTION_DT,
     X_DUPLICATE_IND,
     X_MODE,
     X_GRADING_PERIOD_CD);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SHEET_NUMBER,
   X_GROUP_SEQUENCE_NUMBER,
   X_UNIT_CD,
   X_VERSION_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_UNIT_MODE,
   X_PRODUCTION_DT,
   X_DUPLICATE_IND,
   X_MODE,
   X_GRADING_PERIOD_CD);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2) as
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
  delete from IGS_AS_MARK_SHEET_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


end DELETE_ROW;

end IGS_AS_MARK_SHEET_PKG;

/
