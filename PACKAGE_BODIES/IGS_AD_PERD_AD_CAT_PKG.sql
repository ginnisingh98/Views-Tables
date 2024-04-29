--------------------------------------------------------
--  DDL for Package Body IGS_AD_PERD_AD_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PERD_AD_CAT_PKG" as
/* $Header: IGSAI29B.pls 115.11 2003/10/30 13:19:40 rghosh ship $*/

  l_rowid VARCHAR2(25);
  old_references IGS_AD_PERD_AD_CAT%RowType;
  new_references IGS_AD_PERD_AD_CAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PERD_AD_CAT
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
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.admission_cat := x_admission_cat;
    new_references.ci_start_dt := TRUNC(x_ci_start_dt);
    new_references.ci_end_dt := TRUNC(x_ci_end_dt);
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_alternate_code	IGS_CA_INST.alternate_code%TYPE;
	v_ci_start_dt	IGS_CA_INST.start_dt%TYPE;
	v_ci_end_dt		IGS_CA_INST.end_dt%TYPE;
  BEGIN
	IF p_inserting THEN
		-- Validate the admission calendar instance
		IF IGS_AD_VAL_APAC.admp_val_apac_ci(
			new_references.adm_cal_type,
			new_references.adm_ci_sequence_number,
			new_references.admission_cat,
			v_ci_start_dt,
			v_ci_end_dt,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		ELSE
			-- Set start and end dates
			new_references.ci_start_dt :=TRUNC( v_ci_start_dt);
			new_references.ci_end_dt := TRUNC(v_ci_end_dt);
		END IF;
		-- Validate the admission category
		IF IGS_AD_VAL_ACCT.admp_val_ac_closed(
			new_references.admission_cat,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	DEFAULT NULL,
	 Column_Value 	IN	VARCHAR2	DEFAULT NULL
)
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'ADM_CAL_TYPE' then
     new_references.adm_cal_type := column_value;
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
END IF;

IF upper(column_name) = 'ADM_CAL_TYPE' OR column_name is null Then
     IF new_references.adm_cal_type <> UPPER(new_references.adm_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADMISSION_CAT' OR column_name is null Then
     IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;
END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
	 IF NOT IGS_AD_CAT_PKG.Get_PK_For_Validation (
      	  new_references.admission_cat , 'N'
		) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;
    END IF;

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (TRUNC(old_references.ci_start_dt) = new_references.ci_start_dt) AND
         (TRUNC(old_references.ci_end_dt) = new_references.ci_end_dt)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.ci_start_dt IS NULL) OR
         (new_references.ci_end_dt IS NULL))) THEN
      NULL;

  ELSE
	 IF NOT IGS_CA_INST_PKG.Get_UK_For_Validation (
      	  new_references.adm_cal_type,
	        new_references.adm_ci_sequence_number,
	        new_references.ci_start_dt,
	        new_references.ci_end_dt
		) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	 END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_PRD_AD_PRC_CA_PKG.GET_FK_IGS_AD_PERD_AD_CAT (
      old_references.adm_cal_type,
      old_references.adm_ci_sequence_number,
      old_references.admission_cat
      );

    IGS_AD_PECRS_OFOP_DT_PKG.GET_FK_IGS_AD_PERD_AD_CAT (
      old_references.adm_cal_type,
      old_references.adm_ci_sequence_number,
      old_references.admission_cat
      );

  END Check_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2
    )
RETURN BOOLEAN
AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PERD_AD_CAT
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat;

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

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PERD_AD_CAT
      WHERE    admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APAC_AC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CAT;

  PROCEDURE GET_UFK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PERD_AD_CAT
      WHERE    adm_cal_type = x_cal_type
      AND      adm_ci_sequence_number = x_sequence_number
      AND      TRUNC(ci_start_dt) = TRUNC(x_start_dt)
      AND      TRUNC(ci_end_dt) = TRUNC(x_end_dt) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_APAC_CI_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_CA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_ci_start_dt IN DATE DEFAULT NULL,
    x_ci_end_dt IN DATE DEFAULT NULL,
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
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_ci_start_dt,
      x_ci_end_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
     BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       BeforeRowInsertUpdate1 ( p_updating => TRUE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       Check_Child_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat
          ) THEN
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
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_PERD_AD_CAT
      where ADM_CAL_TYPE = X_ADM_CAL_TYPE
      and ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER
      and ADMISSION_CAT = X_ADMISSION_CAT;
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

  Before_DML(p_action =>'INSERT',
  x_rowid => X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_ci_start_dt => X_CI_START_DT,
  x_ci_end_dt => X_CI_END_DT,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_PERD_AD_CAT (
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT,
    CI_START_DT,
    CI_END_DT,
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
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.CI_START_DT,
    NEW_REFERENCES.CI_END_DT,
    NEW_REFERENCES.CREATION_DATE,
    NEW_REFERENCES.CREATED_BY,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE
) AS
  cursor c1 is select
      CI_START_DT,
      CI_END_DT
    from IGS_AD_PERD_AD_CAT
    where ROWID = X_ROWID  for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) 	then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (TRUNC(tlinfo.CI_START_DT) = TRUNC(X_CI_START_DT))
      AND (TRUNC(tlinfo.CI_END_DT) = TRUNC(X_CI_END_DT))
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
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_ci_start_dt => X_CI_START_DT,
  x_ci_end_dt => X_CI_END_DT,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  if (X_MODE = 'R') then
	X_REQUEST_ID :=FND_GLOBAL.CONC_REQUEST_ID;
	X_PROGRAM_ID :=FND_GLOBAL.CONC_PROGRAM_ID;
	X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
	if (X_REQUEST_ID = -1) then
		X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
		X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
		X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
	else
		X_PROGRAM_UPDATE_DATE := SYSDATE;
	end if;
  end if;
  update IGS_AD_PERD_AD_CAT set
    CI_START_DT = NEW_REFERENCES.CI_START_DT,
    CI_END_DT = NEW_REFERENCES.CI_END_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_CI_START_DT in DATE,
  X_CI_END_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_PERD_AD_CAT
     where ADM_CAL_TYPE = X_ADM_CAL_TYPE
     and ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER
     and ADMISSION_CAT = X_ADMISSION_CAT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ADM_CAL_TYPE,
     X_ADM_CI_SEQUENCE_NUMBER,
     X_ADMISSION_CAT,
     X_CI_START_DT,
     X_CI_END_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_ADMISSION_CAT,
   X_CI_START_DT,
   X_CI_END_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

 Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
 );
  delete from IGS_AD_PERD_AD_CAT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_AD_PERD_AD_CAT_PKG;

/
