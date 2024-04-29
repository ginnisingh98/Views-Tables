--------------------------------------------------------
--  DDL for Package Body IGS_RU_WORK_SET_MBR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_WORK_SET_MBR_PKG" as
/* $Header: IGSUI16B.pls 115.6 2002/11/29 04:29:12 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_RU_WORK_SET_MBR%RowType;
  new_references IGS_RU_WORK_SET_MBR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_rws_sequence_number IN NUMBER ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_WORK_SET_MBR
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_RU_GEN_006.SET_TOKEN('IGS_RU_WORK_SET   : P_ACTION  INSERT, VALIDATE_INSERT  : IGSUI16B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.rws_sequence_number := x_rws_sequence_number;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
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


   IF (((old_references.rws_sequence_number = new_references.rws_sequence_number)) OR
        ((new_references.rws_sequence_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_RU_WORK_SET_PKG.Get_PK_For_Validation (
        new_references.rws_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	 IGS_RU_GEN_006.SET_TOKEN('IGS_RU_WORK_SET   : P_ACTION  Check_Parent_Existance rws_sequence_number: IGSUI16B.PLS');
	 IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_rws_sequence_number IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_version_number IN VARCHAR2,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN VARCHAR2
)return BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_WORK_SET_MBR
      WHERE    rws_sequence_number = x_rws_sequence_number
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_RU_WORK_SET (
    x_sequence_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_RU_WORK_SET_MBR
      WHERE    rws_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_RU_RWSM_RWS_FK');
	   IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_WORK_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2,
    x_rws_sequence_number IN NUMBER ,
    x_unit_cd IN VARCHAR2 ,
    x_version_number IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_ci_sequence_number IN VARCHAR2 ,
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
      x_rws_sequence_number,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.rws_sequence_number,
		new_references.unit_cd,
		new_references.version_number,
		new_references.cal_type,
		new_references.ci_sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	  IF Get_PK_For_Validation (
		new_references.rws_sequence_number,
		new_references.unit_cd,
		new_references.version_number,
		new_references.cal_type,
		new_references.ci_sequence_number
	  ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	  END IF;
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
  X_RWS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_RU_WORK_SET_MBR
      where RWS_SEQUENCE_NUMBER = X_RWS_SEQUENCE_NUMBER
      and UNIT_CD = X_UNIT_CD
      and VERSION_NUMBER = X_VERSION_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER;
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
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
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
	 IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML(
   p_action=>'INSERT',
   x_rowid=>X_ROWID,
   x_cal_type=>X_CAL_TYPE,
   x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
   x_rws_sequence_number=>X_RWS_SEQUENCE_NUMBER,
   x_unit_cd=>X_UNIT_CD,
   x_version_number=>X_VERSION_NUMBER,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_RU_WORK_SET_MBR (
    RWS_SEQUENCE_NUMBER,
    UNIT_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE
  ) values (
    NEW_REFERENCES.RWS_SEQUENCE_NUMBER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_RWS_SEQUENCE_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_VERSION_NUMBER in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in VARCHAR2
) as
  cursor c1 is select ROWID
    from IGS_RU_WORK_SET_MBR
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_RU_GEN_006.SET_TOKEN('IGS_RU_WORK_SET   : P_ACTION  LOCK_ROW : IGSUI16B.PLS');
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

  delete from IGS_RU_WORK_SET_MBR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_RU_WORK_SET_MBR_PKG;

/
