--------------------------------------------------------
--  DDL for Package Body IGS_GR_CRMN_ROUND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_CRMN_ROUND_PKG" as
/* $Header: IGSGI07B.pls 115.9 2003/09/22 06:29:12 nalkumar ship $ */
       -- BUG #1956374 , Procedure assp_val_ci_status reference is changed
  l_rowid VARCHAR2(25);
  old_references IGS_GR_CRMN_ROUND_ALL%RowType;
  new_references IGS_GR_CRMN_ROUND_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL,
    x_conferral_start_date   IN DATE DEFAULT NULL,
    x_conferral_end_date     IN DATE DEFAULT NULL,
    x_completion_start_date  IN DATE DEFAULT NULL,
    x_completion_end_date    IN DATE DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_CRMN_ROUND_ALL
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
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.start_dt_alias := x_start_dt_alias;
    new_references.start_dai_sequence_number := x_start_dai_sequence_number;
    new_references.end_dt_alias := x_end_dt_alias;
    new_references.end_dai_sequence_number := x_end_dai_sequence_number;
    new_references.org_id := x_org_id;
    new_references.conferral_start_date  := x_conferral_start_date ;
    new_references.conferral_end_date    := x_conferral_end_date   ;
    new_references.completion_start_date := x_completion_start_date;
    new_references.completion_end_date   := x_completion_end_date  ;
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

  -- Trigger description :-
  -- "OSS_TST".trg_crd_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_GR_CRMN_ROUND_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  v_message_name  VARCHAR2(30);
  BEGIN
  -- Validate the graduation cal instance is of the correct category and status
  IF p_inserting THEN
    IF IGS_GR_VAL_CRD.grdp_val_ci_grad(
        new_references.grd_cal_type,
        v_message_name) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;

    IF IGS_AS_VAL_EVSA.assp_val_ci_status(
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number,
        v_message_name) = FALSE THEN
      Fnd_Message.Set_Name('IGS', v_message_name);
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
  END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
    FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.end_dt_alias = new_references.end_dt_alias) AND
         (old_references.end_dai_sequence_number = new_references.end_dai_sequence_number) AND
         (old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.end_dt_alias IS NULL) OR
         (new_references.end_dai_sequence_number IS NULL) OR
         (new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.end_dt_alias,
        new_references.end_dai_sequence_number,
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
    FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

    IF (((old_references.start_dt_alias = new_references.start_dt_alias) AND
         (old_references.start_dai_sequence_number = new_references.start_dai_sequence_number) AND
         (old_references.grd_cal_type = new_references.grd_cal_type) AND
         (old_references.grd_ci_sequence_number = new_references.grd_ci_sequence_number)) OR
        ((new_references.start_dt_alias IS NULL) OR
         (new_references.start_dai_sequence_number IS NULL) OR
         (new_references.grd_cal_type IS NULL) OR
         (new_references.grd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.start_dt_alias,
        new_references.start_dai_sequence_number,
        new_references.grd_cal_type,
        new_references.grd_ci_sequence_number
        ) THEN
    FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE CHECK_CONSTRAINTS(
  Column_Name IN VARCHAR2 DEFAULT NULL,
  Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
IF Column_Name is null THEN
  NULL;

ELSIF upper(Column_name) = 'START_DAI_SEQUENCE_NUMBER' THEN
  new_references.START_DAI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE);

ELSIF upper(Column_name) = 'END_DAI_SEQUENCE_NUMBER' THEN
  new_references.END_DAI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE);

ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE);

ELSIF upper(Column_name) = 'END_DT_ALIAS' THEN
  new_references.END_DT_ALIAS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_CAL_TYPE' THEN
  new_references.GRD_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'START_DT_ALIAS' THEN
  new_references.START_DT_ALIAS:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'START_DAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.START_DAI_SEQUENCE_NUMBER < 1 OR new_references.START_DAI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'END_DAI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.END_DAI_SEQUENCE_NUMBER < 1 OR new_references.END_DAI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER < 1 OR new_references.GRD_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'END_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.END_DT_ALIAS<> upper(NEW_REFERENCES.END_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CAL_TYPE<> upper(NEW_REFERENCES.GRD_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'START_DT_ALIAS' OR COLUMN_NAME IS NULL THEN
  IF new_references.START_DT_ALIAS<> upper(NEW_REFERENCES.START_DT_ALIAS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

 END;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_GR_CRM_ROUND_PRD_PKG.GET_FK_IGS_GR_CRMN_ROUND (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number
      );

    IGS_GR_GRADUAND_PKG.GET_FK_IGS_GR_CRMN_ROUND (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number
      );

    IGS_GR_AWD_CRMN_PKG.GET_FK_IGS_GR_CRMN_ROUND (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number
      );

    IGS_GR_CRMN_PKG.GET_FK_IGS_GR_CRMN_ROUND (
      old_references.grd_cal_type,
      old_references.grd_ci_sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_grd_cal_type IN VARCHAR2,
    x_grd_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ROUND_ALL
      WHERE    grd_cal_type = x_grd_cal_type
      AND      grd_ci_sequence_number = x_grd_ci_sequence_number ;

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
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ROUND_ALL
      WHERE    grd_cal_type = x_cal_type
      AND      grd_ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_CRD_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_CRMN_ROUND_ALL
      WHERE    (end_dt_alias = x_dt_alias
      AND      end_dai_sequence_number = x_sequence_number
      AND      grd_cal_type = x_cal_type
      AND      grd_ci_sequence_number = x_ci_sequence_number)
  OR     (start_dt_alias = x_dt_alias
      AND      start_dai_sequence_number = x_sequence_number
      AND      grd_cal_type = x_cal_type
      AND      grd_ci_sequence_number = x_ci_sequence_number) ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GR_CRD_END_DAIV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_start_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_start_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_end_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_end_dai_sequence_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_conferral_start_date   IN DATE DEFAULT NULL,
    x_conferral_end_date     IN DATE DEFAULT NULL,
    x_completion_start_date  IN DATE DEFAULT NULL,
    x_completion_end_date    IN DATE DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_start_dt_alias,
      x_start_dai_sequence_number,
      x_end_dt_alias,
      x_end_dai_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_conferral_start_date ,
      x_conferral_end_date   ,
      x_completion_start_date,
      x_completion_end_date  );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF Get_PK_For_Validation (
      NEW_REFERENCES.grd_cal_type,
      NEW_REFERENCES.grd_ci_sequence_number
  ) THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
      END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
  IF GET_PK_FOR_VALIDATION(
    NEW_REFERENCES.grd_cal_type,
        NEW_REFERENCES.grd_ci_sequence_number
    ) THEN
    Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END IF;

  check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

  check_constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID                 IN NUMBER,
  X_CONFERRAL_START_DATE   IN DATE DEFAULT NULL,
  X_CONFERRAL_END_DATE     IN DATE DEFAULT NULL,
  X_COMPLETION_START_DATE  IN DATE DEFAULT NULL,
  X_COMPLETION_END_DATE    IN DATE DEFAULT NULL
  ) AS
    cursor C is select ROWID from IGS_GR_CRMN_ROUND_ALL
      where GRD_CAL_TYPE = X_GRD_CAL_TYPE
      and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER;
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
     x_rowid => X_ROWID,
     x_grd_cal_type => X_GRD_CAL_TYPE,
     x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
     x_start_dt_alias => X_START_DT_ALIAS,
     x_start_dai_sequence_number => X_START_DAI_SEQUENCE_NUMBER,
     x_end_dt_alias => X_END_DT_ALIAS,
     x_end_dai_sequence_number => X_END_DAI_SEQUENCE_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login     => X_LAST_UPDATE_LOGIN,
     x_org_id                => igs_ge_gen_003.get_org_id,
     x_conferral_start_date  => X_CONFERRAL_START_DATE ,
     x_conferral_end_date    => X_CONFERRAL_END_DATE   ,
     x_completion_start_date => X_COMPLETION_START_DATE,
     x_completion_end_date   => X_COMPLETION_END_DATE
  );

  insert into IGS_GR_CRMN_ROUND_ALL (
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    CONFERRAL_START_DATE ,
    CONFERRAL_END_DATE   ,
    COMPLETION_START_DATE,
    COMPLETION_END_DATE
    ) values (
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.START_DT_ALIAS,
    NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.END_DT_ALIAS,
    NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.CONFERRAL_START_DATE ,
    NEW_REFERENCES.CONFERRAL_END_DATE   ,
    NEW_REFERENCES.COMPLETION_START_DATE,
    NEW_REFERENCES.COMPLETION_END_DATE
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
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_CONFERRAL_START_DATE   IN DATE,
  X_CONFERRAL_END_DATE     IN DATE,
  X_COMPLETION_START_DATE  IN DATE,
  X_COMPLETION_END_DATE    IN DATE
) AS
  cursor c1 is select
      START_DT_ALIAS,
      START_DAI_SEQUENCE_NUMBER,
      END_DT_ALIAS,
      END_DAI_SEQUENCE_NUMBER
    from IGS_GR_CRMN_ROUND_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.START_DT_ALIAS = X_START_DT_ALIAS)
      AND (tlinfo.START_DAI_SEQUENCE_NUMBER = X_START_DAI_SEQUENCE_NUMBER)
      AND (tlinfo.END_DT_ALIAS = X_END_DT_ALIAS)
      AND (tlinfo.END_DAI_SEQUENCE_NUMBER = X_END_DAI_SEQUENCE_NUMBER)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE                   IN VARCHAR2 default 'R',
  X_CONFERRAL_START_DATE   IN DATE DEFAULT NULL,
  X_CONFERRAL_END_DATE     IN DATE DEFAULT NULL,
  X_COMPLETION_START_DATE  IN DATE DEFAULT NULL,
  X_COMPLETION_END_DATE    IN DATE DEFAULT NULL
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
     x_rowid => X_ROWID,
     x_grd_cal_type => X_GRD_CAL_TYPE,
     x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
     x_start_dt_alias => X_START_DT_ALIAS,
     x_start_dai_sequence_number => X_START_DAI_SEQUENCE_NUMBER,
     x_end_dt_alias => X_END_DT_ALIAS,
     x_end_dai_sequence_number => X_END_DAI_SEQUENCE_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_conferral_start_date  => X_CONFERRAL_START_DATE ,
     x_conferral_end_date    => X_CONFERRAL_END_DATE   ,
     x_completion_start_date => X_COMPLETION_START_DATE,
     x_completion_end_date   => X_COMPLETION_END_DATE
  );

  update IGS_GR_CRMN_ROUND_ALL set
    START_DT_ALIAS = NEW_REFERENCES.START_DT_ALIAS,
    START_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.START_DAI_SEQUENCE_NUMBER,
    END_DT_ALIAS = NEW_REFERENCES.END_DT_ALIAS,
    END_DAI_SEQUENCE_NUMBER = NEW_REFERENCES.END_DAI_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    CONFERRAL_START_DATE = X_CONFERRAL_START_DATE ,
    CONFERRAL_END_DATE   = X_CONFERRAL_END_DATE   ,
    COMPLETION_START_DATE= X_COMPLETION_START_DATE,
    COMPLETION_END_DATE  = X_COMPLETION_END_DATE
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_START_DT_ALIAS in VARCHAR2,
  X_START_DAI_SEQUENCE_NUMBER in NUMBER,
  X_END_DT_ALIAS in VARCHAR2,
  X_END_DAI_SEQUENCE_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID                 IN NUMBER,
  X_CONFERRAL_START_DATE   IN DATE,
  X_CONFERRAL_END_DATE     IN DATE,
  X_COMPLETION_START_DATE  IN DATE,
  X_COMPLETION_END_DATE    IN DATE
  ) AS
  cursor c1 is select rowid from IGS_GR_CRMN_ROUND_ALL
     where GRD_CAL_TYPE = X_GRD_CAL_TYPE
     and GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_START_DT_ALIAS,
     X_START_DAI_SEQUENCE_NUMBER,
     X_END_DT_ALIAS,
     X_END_DAI_SEQUENCE_NUMBER,
     X_MODE,
     x_org_id,
     X_CONFERRAL_START_DATE ,
     X_CONFERRAL_END_DATE   ,
     X_COMPLETION_START_DATE,
     X_COMPLETION_END_DATE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_START_DT_ALIAS,
   X_START_DAI_SEQUENCE_NUMBER,
   X_END_DT_ALIAS,
   X_END_DAI_SEQUENCE_NUMBER,
   X_MODE,
   X_CONFERRAL_START_DATE ,
   X_CONFERRAL_END_DATE   ,
   X_COMPLETION_START_DATE,
   X_COMPLETION_END_DATE
);
end ADD_ROW;

end IGS_GR_CRMN_ROUND_PKG;

/
