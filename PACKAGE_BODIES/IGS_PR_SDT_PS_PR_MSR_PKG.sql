--------------------------------------------------------
--  DDL for Package Body IGS_PR_SDT_PS_PR_MSR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_SDT_PS_PR_MSR_PKG" AS
/* $Header: IGSQI20B.pls 115.3 2002/11/29 03:19:08 nsidana ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PR_SDT_PS_PR_MSR%RowType;
  new_references IGS_PR_SDT_PS_PR_MSR%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_prg_measure_type IN VARCHAR2 DEFAULT NULL,
    x_calculation_dt IN DATE DEFAULT NULL,
    x_value IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_SDT_PS_PR_MSR
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.prg_cal_type := x_prg_cal_type;
    new_references.prg_ci_sequence_number := x_prg_ci_sequence_number;
    new_references.s_prg_measure_type := x_s_prg_measure_type;
    new_references.calculation_dt := x_calculation_dt;
    new_references.value := x_value;
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

    IF (((old_references.prg_cal_type = new_references.prg_cal_type) AND
         (old_references.prg_ci_sequence_number = new_references.prg_ci_sequence_number)) OR
        ((new_references.prg_cal_type IS NULL) OR
         (new_references.prg_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.prg_cal_type,
        new_references.prg_ci_sequence_number
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.s_prg_measure_type = new_references.s_prg_measure_type)) OR
        ((new_references.s_prg_measure_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
	'PRG_MEASURE_TYPE',
        new_references.s_prg_measure_type
        )THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_prg_cal_type IN VARCHAR2,
    x_prg_ci_sequence_number IN NUMBER,
    x_s_prg_measure_type IN VARCHAR2,
    x_calculation_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PS_PR_MSR
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      prg_cal_type = x_prg_cal_type
      AND      prg_ci_sequence_number = x_prg_ci_sequence_number
      AND      s_prg_measure_type = x_s_prg_measure_type
      AND      calculation_dt = x_calculation_dt
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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PS_PR_MSR
      WHERE    prg_cal_type = x_cal_type
      AND      prg_ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SCPM_CI_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PS_PR_MSR
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SCPM_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_prg_measure_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_SDT_PS_PR_MSR
      WHERE    s_prg_measure_type = x_s_prg_measure_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_SCPM_SPMT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_prg_cal_type IN VARCHAR2 DEFAULT NULL,
    x_prg_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_s_prg_measure_type IN VARCHAR2 DEFAULT NULL,
    x_calculation_dt IN DATE DEFAULT NULL,
    x_value IN NUMBER DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_prg_cal_type,
      x_prg_ci_sequence_number,
      x_s_prg_measure_type,
      x_calculation_dt,
      x_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       Check_Parent_Existance;
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.prg_cal_type,
		    new_references.prg_ci_sequence_number,
		    new_references.s_prg_measure_type,
		    new_references.calculation_dt) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       Check_Parent_Existance;
	CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
		    new_references.person_id,
		    new_references.course_cd,
		    new_references.prg_cal_type,
		    new_references.prg_ci_sequence_number,
		    new_references.s_prg_measure_type,
		    new_references.calculation_dt) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	CHECK_CONSTRAINTS;
	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	CHECK_CONSTRAINTS;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PR_SDT_PS_PR_MSR
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and PRG_CAL_TYPE = X_PRG_CAL_TYPE
      and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
      and S_PRG_MEASURE_TYPE = X_S_PRG_MEASURE_TYPE
      and CALCULATION_DT = X_CALCULATION_DT;
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
    x_rowid => x_rowid ,
    x_person_id => x_person_id ,
    x_course_cd => x_course_cd ,
    x_prg_cal_type => x_prg_cal_type ,
    x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
    x_s_prg_measure_type => x_s_prg_measure_type ,
    x_calculation_dt => x_calculation_dt ,
    x_value => x_value ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login =>x_last_update_login
  ) ;

  insert into IGS_PR_SDT_PS_PR_MSR (
    PERSON_ID,
    COURSE_CD,
    PRG_CAL_TYPE,
    PRG_CI_SEQUENCE_NUMBER,
    S_PRG_MEASURE_TYPE,
    CALCULATION_DT,
    VALUE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.PRG_CAL_TYPE,
    NEW_REFERENCES.PRG_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.S_PRG_MEASURE_TYPE,
    NEW_REFERENCES.CALCULATION_DT,
    NEW_REFERENCES.VALUE,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER
) AS
  cursor c1 is select
      VALUE
    from IGS_PR_SDT_PS_PR_MSR
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	close c1;
    app_exception.raise_exception;

    return;
  end if;
  close c1;

  if ( (tlinfo.VALUE = X_VALUE)
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
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
    p_action => 'UPDATE',
    x_rowid => x_rowid ,
    x_person_id => x_person_id ,
    x_course_cd => x_course_cd ,
    x_prg_cal_type => x_prg_cal_type ,
    x_prg_ci_sequence_number => x_prg_ci_sequence_number ,
    x_s_prg_measure_type => x_s_prg_measure_type ,
    x_calculation_dt => x_calculation_dt ,
    x_value => x_value ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login =>x_last_update_login
  ) ;

  update IGS_PR_SDT_PS_PR_MSR set
    VALUE = NEW_REFERENCES.VALUE,
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_PRG_CAL_TYPE in VARCHAR2,
  X_PRG_CI_SEQUENCE_NUMBER in NUMBER,
  X_S_PRG_MEASURE_TYPE in VARCHAR2,
  X_CALCULATION_DT in DATE,
  X_VALUE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PR_SDT_PS_PR_MSR
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and PRG_CAL_TYPE = X_PRG_CAL_TYPE
     and PRG_CI_SEQUENCE_NUMBER = X_PRG_CI_SEQUENCE_NUMBER
     and S_PRG_MEASURE_TYPE = X_S_PRG_MEASURE_TYPE
     and CALCULATION_DT = X_CALCULATION_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_PRG_CAL_TYPE,
     X_PRG_CI_SEQUENCE_NUMBER,
     X_S_PRG_MEASURE_TYPE,
     X_CALCULATION_DT,
     X_VALUE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID ,
   X_PERSON_ID,
   X_COURSE_CD,
   X_PRG_CAL_TYPE,
   X_PRG_CI_SEQUENCE_NUMBER,
   X_S_PRG_MEASURE_TYPE,
   X_CALCULATION_DT,
   X_VALUE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  ) ;
  delete from IGS_PR_SDT_PS_PR_MSR
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'VALUE' THEN
  new_references.VALUE:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' THEN
  new_references.PRG_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'VALUE' OR COLUMN_NAME IS NULL THEN
  IF new_references.VALUE < 0 or new_references.VALUE > 999.999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRG_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRG_CI_SEQUENCE_NUMBER < 1 or new_references.PRG_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
END Check_Constraints;


end IGS_PR_SDT_PS_PR_MSR_PKG;

/
