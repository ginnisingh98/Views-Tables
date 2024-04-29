--------------------------------------------------------
--  DDL for Package Body IGS_ST_GVT_SPSHT_CTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GVT_SPSHT_CTL_PKG" as
/* $Header: IGSVI08B.pls 115.6 2002/11/29 04:32:37 nsidana ship $ */
l_rowid VARCHAR2(25);
old_references IGS_ST_GVT_SPSHT_CTL_ALL%RowType;
new_references IGS_ST_GVT_SPSHT_CTL_ALL%RowType;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_ess_snapshot_dt_time IN DATE DEFAULT NULL,
    x_completion_dt IN DATE DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GVT_SPSHT_CTL_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.submission_yr := x_submission_yr;
    new_references.submission_number := x_submission_number;
    new_references.ess_snapshot_dt_time := x_ess_snapshot_dt_time;
    new_references.completion_dt := x_completion_dt;
    new_references.org_id := x_org_id;
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

PROCEDURE AfterRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name			VARCHAR2(30);
  BEGIN
	IF NVL(old_references.ess_snapshot_dt_time, IGS_GE_DATE.igsdate('1900/01/01')) <>
	    NVL(new_references.ess_snapshot_dt_time,IGS_GE_DATE.igsdate('1900/01/01')) THEN

  		IF IGS_ST_VAL_GSC.stap_val_gsc_sdt (
  				new_references.submission_yr,
  				new_references.ess_snapshot_dt_time,
  				v_message_name) = FALSE THEN
				FND_MESSAGE.SET_NAME('IGS',v_message_name);
			        IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  		IF IGS_ST_VAL_GSC.stap_val_gsc_sdt_upd (
  				new_references.submission_yr,
  				new_references.submission_number,
  				v_message_name) = FALSE THEN
				FND_MESSAGE.SET_NAME('IGS',v_message_name);
			        IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
	END IF;
  END AfterRowInsertUpdate1;


PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.ess_snapshot_dt_time = new_references.ess_snapshot_dt_time)) OR
        ((new_references.ess_snapshot_dt_time IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ST_SPSHT_CTL_PKG.Get_PK_For_Validation (
        new_references.ess_snapshot_dt_time
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_ST_GOVT_SEMESTER_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_ST_GVT_SPSHT_CHG_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_ST_GOVT_STDNT_EN_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBMAO_FN_AMTT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBMAO_FN_CTTT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBM_AOU_FNDTT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBMAO_FN_UITT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBM_PS_FNTRGT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

    IGS_AD_SBMINTAK_TRGT_PKG.GET_FK_IGS_ST_GVT_SPSHT_CTL (
      old_references.submission_yr,
      old_references.submission_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_SPSHT_CTL_ALL
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
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

  PROCEDURE GET_FK_IGS_EN_ST_SPSHT_CTL (
    x_ess_snapshot_dt_time IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_SPSHT_CTL_ALL
      WHERE    ess_snapshot_dt_time = x_ess_snapshot_dt_time;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSC_ESSC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ST_SPSHT_CTL;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'SUBMISSION_YR' THEN
      new_references.submission_yr := IGS_GE_NUMBER.to_num(column_value);
     ELSIF upper(column_name) = 'SUBMISSION_NUMBER' THEN
      new_references.submission_number := IGS_GE_NUMBER.to_num(column_value);
     END IF;

     IF upper(column_name) = 'SUBMISSION_YR' OR column_name IS NULL THEN
      IF new_references.submission_yr < 0 OR new_references.submission_yr > 9999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SUBMISSION_NUMBER' OR column_name IS NULL THEN
      IF new_references.submission_number < 1 OR new_references.submission_number > 3 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

   END CHECK_CONSTRAINTS;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_ess_snapshot_dt_time IN DATE DEFAULT NULL,
    x_completion_dt IN DATE DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
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
      x_submission_yr,
      x_submission_number,
      x_ess_snapshot_dt_time,
      x_completion_dt,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      --Check_Unique (x_rowid);
      IF GET_PK_FOR_VALIDATION(
        new_references.submission_yr,
        new_references.submission_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      --Check_Unique (x_rowid);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.submission_yr,
        new_references.submission_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
     ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
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
      AfterRowInsertUpdate1 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate1 ( p_updating => TRUE );
    END IF;

  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
  x_org_id IN NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_ST_GVT_SPSHT_CTL_ALL
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER;
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

   Before_DML (
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_ess_snapshot_dt_time => X_ESS_SNAPSHOT_DT_TIME,
    x_completion_dt => X_COMPLETION_DT,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
   );

  insert into IGS_ST_GVT_SPSHT_CTL_ALL (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    ESS_SNAPSHOT_DT_TIME,
    COMPLETION_DT,
    ORG_ID,
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
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.ESS_SNAPSHOT_DT_TIME,
    NEW_REFERENCES.COMPLETION_DT,
    NEW_REFERENCES.ORG_ID,
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

After_DML(
 p_action =>'INSERT',
 x_rowid => X_ROWID
);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE
) AS
  cursor c1 is select
      ESS_SNAPSHOT_DT_TIME,
      COMPLETION_DT
    from IGS_ST_GVT_SPSHT_CTL_ALL
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

      if ( ((tlinfo.ESS_SNAPSHOT_DT_TIME = X_ESS_SNAPSHOT_DT_TIME)
           OR ((tlinfo.ESS_SNAPSHOT_DT_TIME is null)
               AND (X_ESS_SNAPSHOT_DT_TIME is null)))
      AND ((tlinfo.COMPLETION_DT = X_COMPLETION_DT)
           OR ((tlinfo.COMPLETION_DT is null)
               AND (X_COMPLETION_DT is null)))
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
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

  Before_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_ess_snapshot_dt_time => X_ESS_SNAPSHOT_DT_TIME,
    x_completion_dt => X_COMPLETION_DT,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
   );


  if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
   if (X_REQUEST_ID = -1) then
    X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
   else
    X_PROGRAM_UPDATE_DATE := SYSDATE;
   end if;
  end if;
  update IGS_ST_GVT_SPSHT_CTL_ALL set
    ESS_SNAPSHOT_DT_TIME = NEW_REFERENCES.ESS_SNAPSHOT_DT_TIME,
    COMPLETION_DT = NEW_REFERENCES.COMPLETION_DT,
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

After_DML(
   p_action =>'UPDATE',
   x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ESS_SNAPSHOT_DT_TIME in DATE,
  X_COMPLETION_DT in DATE,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_ST_GVT_SPSHT_CTL_ALL
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SUBMISSION_YR,
     X_SUBMISSION_NUMBER,
     X_ESS_SNAPSHOT_DT_TIME,
     X_COMPLETION_DT,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_ESS_SNAPSHOT_DT_TIME,
   X_COMPLETION_DT,
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

  delete from IGS_ST_GVT_SPSHT_CTL_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(
   p_action =>'DELETE',
   x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_ST_GVT_SPSHT_CTL_PKG;

/
