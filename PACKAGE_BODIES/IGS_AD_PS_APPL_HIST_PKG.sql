--------------------------------------------------------
--  DDL for Package Body IGS_AD_PS_APPL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PS_APPL_HIST_PKG" as
/* $Header: IGSAI17B.pls 120.0 2005/06/01 21:03:28 appldev noship $ */
l_rowid VARCHAR2(25);
old_references IGS_AD_PS_APPL_HIST_ALL%RowType;
new_references IGS_AD_PS_APPL_HIST_ALL%RowType;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_course_rank_set IN VARCHAR2 DEFAULT NULL,
    x_course_rank_schedule IN VARCHAR2 DEFAULT NULL,
    x_req_for_reconsideration_ind IN VARCHAR2 DEFAULT NULL,
    x_req_for_adv_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PS_APPL_HIST_ALL
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
    new_references.org_id := x_org_id;
    new_references.admission_appl_number := x_admission_appl_number;
    new_references.nominated_course_cd := x_nominated_course_cd;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.transfer_course_cd := x_transfer_course_cd;
    new_references.basis_for_admission_type := x_basis_for_admission_type;
    new_references.admission_cd := x_admission_cd;
    new_references.course_rank_set := x_course_rank_set;
    new_references.course_rank_schedule := x_course_rank_schedule;
    new_references.req_for_reconsideration_ind := x_req_for_reconsideration_ind;
    new_references.req_for_adv_standing_ind := x_req_for_adv_standing_ind;
    new_references.person_id := x_person_id;
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


FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_admission_appl_number IN NUMBER,
    x_nominated_course_cd IN VARCHAR2,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PS_APPL_HIST_ALL
      WHERE    person_id = x_person_id
      AND      admission_appl_number = x_admission_appl_number
      AND      nominated_course_cd = x_nominated_course_cd
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
     ELSIF upper(column_name) = 'ADMISSION_CD' THEN
      new_references.admission_cd := column_value;
     ELSIF upper(column_name) = 'BASIS_FOR_ADMISSION_TYPE' THEN
      new_references.basis_for_admission_type := column_value;
     ELSIF upper(column_name) = 'COURSE_RANK_SCHEDULE' THEN
      new_references.course_rank_schedule := column_value;
     ELSIF upper(column_name) = 'COURSE_RANK_SET' THEN
      new_references.course_rank_set := column_value;
     ELSIF upper(column_name) = 'NOMINATED_COURSE_CD' THEN
      new_references.nominated_course_cd := column_value;
     ELSIF upper(column_name) = 'REQ_FOR_ADV_STANDING_IND' THEN
      new_references.req_for_adv_standing_ind := column_value;
     ELSIF upper(column_name) = 'REQ_FOR_RECONSIDERATION_IND' THEN
      new_references.req_for_reconsideration_ind := column_value;
     ELSIF upper(column_name) = 'TRANSFER_COURSE_CD' THEN
      new_references.transfer_course_cd := column_value;
     END IF;

     IF upper(column_name) = 'ADMISSION_CD' OR column_name IS NULL THEN
      IF new_references.admission_cd <> UPPER(new_references.admission_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'BASIS_FOR_ADMISSION_TYPE' OR column_name IS NULL THEN
      IF new_references.basis_for_admission_type <> UPPER(new_references.basis_for_admission_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'COURSE_RANK_SCHEDULE' OR column_name IS NULL THEN
      IF new_references.course_rank_schedule <> UPPER(new_references.course_rank_schedule) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'COURSE_RANK_SET' OR column_name IS NULL THEN
      IF new_references.course_rank_set <> UPPER(new_references.course_rank_set) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'NOMINATED_COURSE_CD' OR column_name IS NULL THEN
      IF new_references.nominated_course_cd <> UPPER(new_references.nominated_course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'REQ_FOR_ADV_STANDING_IND' OR column_name IS NULL THEN
      IF new_references.req_for_adv_standing_ind <> UPPER(new_references.req_for_adv_standing_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'REQ_FOR_RECONSIDERATION_IND' OR column_name IS NULL THEN
      IF new_references.req_for_reconsideration_ind <> UPPER(new_references.req_for_reconsideration_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'TRANSFER_COURSE_CD' OR column_name IS NULL THEN
      IF new_references.transfer_course_cd <> UPPER(new_references.transfer_course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

  END CHECK_CONSTRAINTS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_admission_appl_number IN NUMBER DEFAULT NULL,
    x_nominated_course_cd IN VARCHAR2 DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_transfer_course_cd IN VARCHAR2 DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cd IN VARCHAR2 DEFAULT NULL,
    x_course_rank_set IN VARCHAR2 DEFAULT NULL,
    x_course_rank_schedule IN VARCHAR2 DEFAULT NULL,
    x_req_for_reconsideration_ind IN VARCHAR2 DEFAULT NULL,
    x_req_for_adv_standing_ind IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
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
      x_admission_appl_number,
      x_nominated_course_cd,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_transfer_course_cd,
      x_basis_for_admission_type,
      x_admission_cd,
      x_course_rank_set,
      x_course_rank_schedule,
      x_req_for_reconsideration_ind,
      x_req_for_adv_standing_ind,
      x_person_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd,
        new_references.hist_start_dt
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF GET_PK_FOR_VALIDATION(
        new_references.person_id,
        new_references.admission_appl_number,
        new_references.nominated_course_cd,
        new_references.hist_start_dt
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      null;
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
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
    cursor C is select ROWID from IGS_AD_PS_APPL_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
      and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
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

  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
	x_org_id => igs_ge_gen_003.get_org_id,
  x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd => X_NOMINATED_COURSE_CD,
  x_hist_start_dt => X_HIST_START_DT,
  x_hist_end_dt => X_HIST_END_DT,
  x_hist_who => X_HIST_WHO,
  x_transfer_course_cd => X_TRANSFER_COURSE_CD,
  x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
  x_admission_cd => X_ADMISSION_CD,
  x_course_rank_set  => X_COURSE_RANK_SET,
  x_course_rank_schedule  => X_COURSE_RANK_SCHEDULE,
  x_req_for_reconsideration_ind => NVL(X_REQ_FOR_RECONSIDERATION_IND,'N'),
  x_req_for_adv_standing_ind => NVL(X_REQ_FOR_ADV_STANDING_IND,'N'),
  x_person_id => X_PERSON_ID,
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_PS_APPL_HIST_ALL (
		ORG_ID,
    PERSON_ID,
    ADMISSION_APPL_NUMBER,
    NOMINATED_COURSE_CD,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    TRANSFER_COURSE_CD,
    BASIS_FOR_ADMISSION_TYPE,
    ADMISSION_CD,
    COURSE_RANK_SET,
    COURSE_RANK_SCHEDULE,
    REQ_FOR_RECONSIDERATION_IND,
    REQ_FOR_ADV_STANDING_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.ADMISSION_APPL_NUMBER,
    NEW_REFERENCES.NOMINATED_COURSE_CD,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.TRANSFER_COURSE_CD,
    NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    NEW_REFERENCES.ADMISSION_CD,
    NEW_REFERENCES.COURSE_RANK_SET,
    NEW_REFERENCES.COURSE_RANK_SCHEDULE,
    NEW_REFERENCES.REQ_FOR_RECONSIDERATION_IND,
    NEW_REFERENCES.REQ_FOR_ADV_STANDING_IND,
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

  After_DML(
   p_action =>'INSERT',
   x_rowid => X_ROWID
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
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2
) as
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      TRANSFER_COURSE_CD,
      BASIS_FOR_ADMISSION_TYPE,
      ADMISSION_CD,
      COURSE_RANK_SET,
      COURSE_RANK_SCHEDULE,
      REQ_FOR_RECONSIDERATION_IND,
      REQ_FOR_ADV_STANDING_IND
    from IGS_AD_PS_APPL_HIST_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.TRANSFER_COURSE_CD = X_TRANSFER_COURSE_CD)
           OR ((tlinfo.TRANSFER_COURSE_CD is null)
               AND (X_TRANSFER_COURSE_CD is null)))
      AND ((tlinfo.BASIS_FOR_ADMISSION_TYPE = X_BASIS_FOR_ADMISSION_TYPE)
           OR ((tlinfo.BASIS_FOR_ADMISSION_TYPE is null)
               AND (X_BASIS_FOR_ADMISSION_TYPE is null)))
      AND ((tlinfo.ADMISSION_CD = X_ADMISSION_CD)
           OR ((tlinfo.ADMISSION_CD is null)
               AND (X_ADMISSION_CD is null)))
      AND ((tlinfo.COURSE_RANK_SET = X_COURSE_RANK_SET)
           OR ((tlinfo.COURSE_RANK_SET is null)
               AND (X_COURSE_RANK_SET is null)))
      AND ((tlinfo.COURSE_RANK_SCHEDULE = X_COURSE_RANK_SCHEDULE)
           OR ((tlinfo.COURSE_RANK_SCHEDULE is null)
               AND (X_COURSE_RANK_SCHEDULE is null)))
      AND ((tlinfo.REQ_FOR_RECONSIDERATION_IND = X_REQ_FOR_RECONSIDERATION_IND)
           OR ((tlinfo.REQ_FOR_RECONSIDERATION_IND is null)
               AND (X_REQ_FOR_RECONSIDERATION_IND is null)))
      AND ((tlinfo.REQ_FOR_ADV_STANDING_IND = X_REQ_FOR_ADV_STANDING_IND)
           OR ((tlinfo.REQ_FOR_ADV_STANDING_IND is null)
               AND (X_REQ_FOR_ADV_STANDING_IND is null)))
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
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
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

  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_admission_appl_number => X_ADMISSION_APPL_NUMBER,
  x_nominated_course_cd => X_NOMINATED_COURSE_CD,
  x_hist_start_dt => X_HIST_START_DT,
  x_hist_end_dt => X_HIST_END_DT,
  x_hist_who => X_HIST_WHO,
  x_transfer_course_cd => X_TRANSFER_COURSE_CD,
  x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
  x_admission_cd => X_ADMISSION_CD,
  x_course_rank_set  => X_COURSE_RANK_SET,
  x_course_rank_schedule  => X_COURSE_RANK_SCHEDULE,
  x_req_for_reconsideration_ind => X_REQ_FOR_RECONSIDERATION_IND,
  x_req_for_adv_standing_ind => X_REQ_FOR_ADV_STANDING_IND,
  x_person_id => X_PERSON_ID,
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_PS_APPL_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    TRANSFER_COURSE_CD = NEW_REFERENCES.TRANSFER_COURSE_CD,
    BASIS_FOR_ADMISSION_TYPE = NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    ADMISSION_CD = NEW_REFERENCES.ADMISSION_CD,
    COURSE_RANK_SET = NEW_REFERENCES.COURSE_RANK_SET,
    COURSE_RANK_SCHEDULE = NEW_REFERENCES.COURSE_RANK_SCHEDULE,
    REQ_FOR_RECONSIDERATION_IND = NEW_REFERENCES.REQ_FOR_RECONSIDERATION_IND,
    REQ_FOR_ADV_STANDING_IND = NEW_REFERENCES.REQ_FOR_ADV_STANDING_IND,
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

  After_DML(
   p_action =>'UPDATE',
   x_rowid => X_ROWID
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
  X_NOMINATED_COURSE_CD in VARCHAR2,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_TRANSFER_COURSE_CD in VARCHAR2,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_ADMISSION_CD in VARCHAR2,
  X_COURSE_RANK_SET in VARCHAR2,
  X_COURSE_RANK_SCHEDULE in VARCHAR2,
  X_REQ_FOR_RECONSIDERATION_IND in VARCHAR2,
  X_REQ_FOR_ADV_STANDING_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) as
  cursor c1 is select rowid from IGS_AD_PS_APPL_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and ADMISSION_APPL_NUMBER = X_ADMISSION_APPL_NUMBER
     and NOMINATED_COURSE_CD = X_NOMINATED_COURSE_CD
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
     X_NOMINATED_COURSE_CD,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_TRANSFER_COURSE_CD,
     X_BASIS_FOR_ADMISSION_TYPE,
     X_ADMISSION_CD,
     X_COURSE_RANK_SET,
     X_COURSE_RANK_SCHEDULE,
     X_REQ_FOR_RECONSIDERATION_IND,
     X_REQ_FOR_ADV_STANDING_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_ADMISSION_APPL_NUMBER,
   X_NOMINATED_COURSE_CD,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_TRANSFER_COURSE_CD,
   X_BASIS_FOR_ADMISSION_TYPE,
   X_ADMISSION_CD,
   X_COURSE_RANK_SET,
   X_COURSE_RANK_SCHEDULE,
   X_REQ_FOR_RECONSIDERATION_IND,
   X_REQ_FOR_ADV_STANDING_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

 Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
 );


  delete from IGS_AD_PS_APPL_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
     FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     IGS_GE_MSG_STACK.ADD;
     app_exception.raise_exception;
  end if;

 After_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
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

end IGS_AD_PS_APPL_HIST_PKG;

/
