--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_HIST_PKG" AS
/* $Header: IGSAI05B.pls 120.0 2005/06/03 15:52:41 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_APPL_HIST_ALL%RowType;
  new_references IGS_AD_APPL_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_appl_dt IN DATE DEFAULT NULL,
    x_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_status IN VARCHAR2 DEFAULT NULL,
    x_adm_fee_status IN VARCHAR2 DEFAULT NULL,
    x_tac_appl_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APPL_HIST_ALL
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
    new_references.person_id := x_person_id;
    new_references.org_id := x_org_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.appl_dt := TRUNC(x_appl_dt);
    new_references.acad_cal_type := x_acad_cal_type;
    new_references.acad_ci_sequence_number := x_acad_ci_sequence_number;
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.adm_appl_status := x_adm_appl_status;
    new_references.adm_fee_status := x_adm_fee_status;
    new_references.tac_appl_ind := x_tac_appl_ind;
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

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_CAL'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.acad_cal_type = new_references.acad_cal_type) AND
         (old_references.acad_ci_sequence_number = new_references.acad_ci_sequence_number)) OR
        ((new_references.acad_cal_type IS NULL) OR
         (new_references.acad_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.acad_cal_type,
        new_references.acad_ci_sequence_number
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ACAD_CAL'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_PERSON'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_appl_status = new_references.adm_appl_status)) OR
        ((new_references.adm_appl_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_APPL_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_appl_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_APPL_STATUS'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.adm_fee_status = new_references.adm_fee_status)) OR
        ((new_references.adm_fee_status IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_FEE_STAT_PKG.Get_PK_For_Validation (
        new_references.adm_fee_status
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_FEE_STATUS'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat,
        new_references.s_admission_process_type
        )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND');
        FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_ADM_PRCS_CAT'));
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_hist_start_dt IN DATE
    )
   RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APPL_HIST_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      hist_start_dt = x_hist_start_dt
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

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'TAC_APPL_IND' THEN
      new_references.tac_appl_ind := column_value;
     END IF;

     IF upper(column_name) = 'TAC_APPL_IND' OR column_name IS NULL THEN
      IF new_references.tac_appl_ind NOT IN ('Y','N') THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE_WITH_CTXT');
       FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_TAC_APPL_IND'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

  END CHECK_CONSTRAINTS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_appl_dt IN DATE DEFAULT NULL,
    x_acad_cal_type IN VARCHAR2 DEFAULT NULL,
    x_acad_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_adm_cal_type IN VARCHAR2 DEFAULT NULL,
    x_adm_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_s_admission_process_type IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_status IN VARCHAR2 DEFAULT NULL,
    x_adm_fee_status IN VARCHAR2 DEFAULT NULL,
    x_tac_appl_ind IN VARCHAR2 DEFAULT NULL,
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
      x_org_id,
      x_person_id,
      x_admission_appl_number,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_appl_dt,
      x_acad_cal_type,
      x_acad_ci_sequence_number,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_s_admission_process_type,
      x_adm_appl_status,
      x_adm_fee_status,
      x_tac_appl_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.hist_start_dt
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
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.hist_start_dt
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
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
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_AD_APPL_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
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
Before_DML (
    p_action => 'INSERT',
    x_rowid  => X_ROWID,
    x_org_id  => igs_ge_gen_003.get_org_id,
    x_person_id=> X_PERSON_ID,
    x_admission_appl_number=> X_ADMISSION_APPL_NUMBER,
    x_hist_start_dt =>X_HIST_START_DT,
    x_hist_end_dt=> X_HIST_END_DT,
    x_hist_who =>X_HIST_WHO,
    x_appl_dt =>nvl(X_APPL_DT,SYSDATE),
    x_acad_cal_type =>X_ACAD_CAL_TYPE,
    x_acad_ci_sequence_number=> X_ACAD_CI_SEQUENCE_NUMBER,
    x_adm_cal_type=> X_ADM_CAL_TYPE,
    x_adm_ci_sequence_number =>X_ADM_CI_SEQUENCE_NUMBER,
    x_admission_cat=> X_ADMISSION_CAT,
    x_s_admission_process_type =>X_S_ADMISSION_PROCESS_TYPE,
    x_adm_appl_status =>X_ADM_APPL_STATUS,
    x_adm_fee_status=> X_ADM_FEE_STATUS,
    x_tac_appl_ind =>Nvl(X_TAC_APPL_IND, 'N'),
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );


  insert into IGS_AD_APPL_HIST_ALL (
    PERSON_ID,
    ORG_ID,
    ADMISSION_APPL_NUMBER,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    APPL_DT,
    ACAD_CAL_TYPE,
    ACAD_CI_SEQUENCE_NUMBER,
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE,
    ADM_APPL_STATUS,
    ADM_FEE_STATUS,
    TAC_APPL_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.APPL_DT,
    NEW_REFERENCES.ACAD_CAL_TYPE,
    NEW_REFERENCES.ACAD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.ADM_APPL_STATUS,
    NEW_REFERENCES.ADM_FEE_STATUS,
    NEW_REFERENCES.TAC_APPL_IND,
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
    p_action => 'INSERT',
    x_rowid  => X_ROWID
);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      APPL_DT,
      ACAD_CAL_TYPE,
      ACAD_CI_SEQUENCE_NUMBER,
      ADM_CAL_TYPE,
      ADM_CI_SEQUENCE_NUMBER,
      ADMISSION_CAT,
      S_ADMISSION_PROCESS_TYPE,
      ADM_APPL_STATUS,
      ADM_FEE_STATUS,
      TAC_APPL_IND
    from IGS_AD_APPL_HIST_ALL
    where ROWID = X_ROWID
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((TRUNC(tlinfo.APPL_DT) = TRUNC(X_APPL_DT))
           OR ((tlinfo.APPL_DT is null)
               AND (X_APPL_DT is null)))
      AND ((tlinfo.ACAD_CAL_TYPE = X_ACAD_CAL_TYPE)
           OR ((tlinfo.ACAD_CAL_TYPE is null)
               AND (X_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.ACAD_CI_SEQUENCE_NUMBER = X_ACAD_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ACAD_CI_SEQUENCE_NUMBER is null)
               AND (X_ACAD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ADM_CAL_TYPE = X_ADM_CAL_TYPE)
           OR ((tlinfo.ADM_CAL_TYPE is null)
               AND (X_ADM_CAL_TYPE is null)))
      AND ((tlinfo.ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.ADM_CI_SEQUENCE_NUMBER is null)
               AND (X_ADM_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ADMISSION_CAT = X_ADMISSION_CAT)
           OR ((tlinfo.ADMISSION_CAT is null)
               AND (X_ADMISSION_CAT is null)))
      AND ((tlinfo.S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE)
           OR ((tlinfo.S_ADMISSION_PROCESS_TYPE is null)
               AND (X_S_ADMISSION_PROCESS_TYPE is null)))
      AND ((tlinfo.ADM_APPL_STATUS = X_ADM_APPL_STATUS)
           OR ((tlinfo.ADM_APPL_STATUS is null)
               AND (X_ADM_APPL_STATUS is null)))
      AND ((tlinfo.ADM_FEE_STATUS = X_ADM_FEE_STATUS)
           OR ((tlinfo.ADM_FEE_STATUS is null)
               AND (X_ADM_FEE_STATUS is null)))
      AND ((tlinfo.TAC_APPL_IND = X_TAC_APPL_IND)
           OR ((tlinfo.TAC_APPL_IND is null)
               AND (X_TAC_APPL_IND is null)))
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
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  X_MODE in VARCHAR2
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
Before_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID,
    x_person_id=> X_PERSON_ID,
    x_admission_appl_number=> X_ADMISSION_APPL_NUMBER,
    x_hist_start_dt =>X_HIST_START_DT,
    x_hist_end_dt=> X_HIST_END_DT,
    x_hist_who =>X_HIST_WHO,
    x_appl_dt =>X_APPL_DT,
    x_acad_cal_type =>X_ACAD_CAL_TYPE,
    x_acad_ci_sequence_number=> X_ACAD_CI_SEQUENCE_NUMBER,
    x_adm_cal_type=> X_ADM_CAL_TYPE,
    x_adm_ci_sequence_number =>X_ADM_CI_SEQUENCE_NUMBER,
    x_admission_cat=> X_ADMISSION_CAT,
    x_s_admission_process_type =>X_S_ADMISSION_PROCESS_TYPE,
    x_adm_appl_status =>X_ADM_APPL_STATUS,
    x_adm_fee_status=> X_ADM_FEE_STATUS,
    x_tac_appl_ind =>X_TAC_APPL_IND,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login=> X_LAST_UPDATE_LOGIN
  );


  update IGS_AD_APPL_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    APPL_DT = NEW_REFERENCES.APPL_DT,
    ACAD_CAL_TYPE = NEW_REFERENCES.ACAD_CAL_TYPE,
    ACAD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ACAD_CI_SEQUENCE_NUMBER,
    ADM_CAL_TYPE = NEW_REFERENCES.ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER = NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT = NEW_REFERENCES.ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE = NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    ADM_APPL_STATUS = NEW_REFERENCES.ADM_APPL_STATUS,
    ADM_FEE_STATUS = NEW_REFERENCES.ADM_FEE_STATUS,
    TAC_APPL_IND = NEW_REFERENCES.TAC_APPL_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     IGS_GE_MSG_STACK.ADD;
     app_exception.raise_exception;
  end if;
After_DML (
    p_action => 'UPDATE',
    x_rowid  => X_ROWID
);

EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_PERSON_ID in NUMBER,
  X_ADMISSION_APPL_NUMBER in NUMBER,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_APPL_DT in DATE,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_ACAD_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_ADM_APPL_STATUS in VARCHAR2,
  X_ADM_FEE_STATUS in VARCHAR2,
  X_TAC_APPL_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_AD_APPL_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and HIST_START_DT = X_HIST_START_DT
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_PERSON_ID,
     X_ADMISSION_APPL_NUMBER,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_APPL_DT,
     X_ACAD_CAL_TYPE,
     X_ACAD_CI_SEQUENCE_NUMBER,
     X_ADM_CAL_TYPE,
     X_ADM_CI_SEQUENCE_NUMBER,
     X_ADMISSION_CAT,
     X_S_ADMISSION_PROCESS_TYPE,
     X_ADM_APPL_STATUS,
     X_ADM_FEE_STATUS,
     X_TAC_APPL_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_APPL_DT,
   X_ACAD_CAL_TYPE,
   X_ACAD_CI_SEQUENCE_NUMBER,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_ADMISSION_CAT,
   X_S_ADMISSION_PROCESS_TYPE,
   X_ADM_APPL_STATUS,
   X_ADM_FEE_STATUS,
   X_TAC_APPL_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
   x_rowid  => X_ROWID
);

  delete from IGS_AD_APPL_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     IGS_GE_MSG_STACK.ADD;
     app_exception.raise_exception;
  end if;
After_DML (
    p_action => 'DELETE',
   x_rowid  => X_ROWID
);
EXCEPTION
  WHEN OTHERS THEN
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
end DELETE_ROW;

end IGS_AD_APPL_HIST_PKG;

/
