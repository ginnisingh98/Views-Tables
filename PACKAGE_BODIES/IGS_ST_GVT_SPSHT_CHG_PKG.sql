--------------------------------------------------------
--  DDL for Package Body IGS_ST_GVT_SPSHT_CHG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GVT_SPSHT_CHG_PKG" as
/* $Header: IGSVI07B.pls 115.3 2002/11/29 04:32:19 nsidana ship $ */
l_rowid VARCHAR2(25);
  old_references IGS_ST_GVT_SPSHT_CHG%RowType;
  new_references IGS_ST_GVT_SPSHT_CHG%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_changed_update_who IN VARCHAR2 DEFAULT NULL,
    x_changed_update_on IN DATE DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_old_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_old_eftsu IN NUMBER DEFAULT NULL,
    x_old_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_old_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_old_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_old_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_old_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_old_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_old_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_old_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_reported_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GVT_SPSHT_CHG
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.sequence_number := x_sequence_number;
    new_references.changed_update_who := x_changed_update_who;
    new_references.changed_update_on := x_changed_update_on;
    new_references.govt_semester := x_govt_semester;
    new_references.unit_cd := x_unit_cd;
    new_references.eftsu := x_eftsu;
    new_references.hecs_prexmt_exie := x_hecs_prexmt_exie;
    new_references.hecs_amount_paid := x_hecs_amount_paid;
    new_references.hecs_payment_option := x_hecs_payment_option;
    new_references.differential_hecs_ind := x_differential_hecs_ind;
    new_references.citizenship_cd := x_citizenship_cd;
    new_references.perm_resident_cd := x_perm_resident_cd;
    new_references.prior_degree := x_prior_degree;
    new_references.prior_post_grad := x_prior_post_grad;
    new_references.old_unit_cd := x_old_unit_cd;
    new_references.old_eftsu := x_old_eftsu;
    new_references.old_hecs_prexmt_exie := x_old_hecs_prexmt_exie;
    new_references.old_hecs_amount_paid := x_old_hecs_amount_paid;
    new_references.old_hecs_payment_option := x_old_hecs_payment_option;
    new_references.old_differential_hecs_ind := x_old_differential_hecs_ind;
    new_references.old_citizenship_cd := x_old_citizenship_cd;
    new_references.old_perm_resident_cd := x_old_perm_resident_cd;
    new_references.old_prior_degree := x_old_prior_degree;
    new_references.old_prior_post_grad := x_old_prior_post_grad;
    new_references.reported_ind := x_reported_ind;
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

    IF (((old_references.submission_yr = new_references.submission_yr) AND
         (old_references.submission_number = new_references.submission_number)) OR
        ((new_references.submission_yr IS NULL) OR
         (new_references.submission_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_ST_GVT_SPSHT_CTL_PKG.Get_PK_For_Validation (
        new_references.submission_yr,
        new_references.submission_number
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_SPSHT_CHG
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_ST_GVT_SPSHT_CTL (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_SPSHT_CHG
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSCH_GSC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GVT_SPSHT_CTL;


  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'CHANGED_UPDATE_WHO' THEN
      new_references.changed_update_who := column_value;
     ELSIF upper(column_name) = 'CITIZENSHIP_CD' THEN
      new_references.citizenship_cd := column_value;
     ELSIF upper(column_name) = 'COURSE_CD' THEN
      new_references.course_cd := column_value;
     ELSIF upper(column_name) = 'DIFFERENTIAL_HECS_IND' THEN
      new_references.differential_hecs_ind := column_value;
     ELSIF upper(column_name) = 'HECS_PAYMENT_OPTION' THEN
      new_references.hecs_payment_option := column_value;
     ELSIF upper(column_name) = 'OLD_CITIZENSHIP_CD' THEN
      new_references.old_citizenship_cd := column_value;
     ELSIF upper(column_name) = 'OLD_DIFFERENTIAL_HECS_IND' THEN
      new_references.old_differential_hecs_ind := column_value;
     ELSIF upper(column_name) = 'OLD_HECS_PAYMENT_OPTION' THEN
      new_references.old_hecs_payment_option := column_value;
     ELSIF upper(column_name) = 'OLD_PERM_RESIDENT_CD' THEN
      new_references.old_perm_resident_cd := column_value;
     ELSIF upper(column_name) = 'OLD_PRIOR_DEGREE' THEN
      new_references.old_prior_degree := column_value;
     ELSIF upper(column_name) = 'OLD_PRIOR_POST_GRAD' THEN
      new_references.old_prior_post_grad := column_value;
     ELSIF upper(column_name) = 'OLD_UNIT_CD' THEN
      new_references.old_unit_cd := column_value;
     ELSIF upper(column_name) = 'PERM_RESIDENT_CD' THEN
      new_references.perm_resident_cd := column_value;
     ELSIF upper(column_name) = 'PRIOR_DEGREE' THEN
      new_references.prior_degree := column_value;
     ELSIF upper(column_name) = 'PRIOR_POST_GRAD' THEN
      new_references.prior_post_grad := column_value;
     ELSIF upper(column_name) = 'REPORTED_IND' THEN
      new_references.reported_ind := column_value;
     ELSIF upper(column_name) = 'UNIT_CD' THEN
      new_references.unit_cd := column_value;
     END IF;

     IF upper(column_name) = 'CHANGED_UPDATE_WHO' OR column_name IS NULL THEN
      IF new_references.changed_update_who <> UPPER(new_references.changed_update_who) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'CITIZENSHIP_CD' OR column_name IS NULL THEN
      IF new_references.citizenship_cd <> UPPER(new_references.citizenship_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'COURSE_CD' OR column_name IS NULL THEN
      IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'DIFFERENTIAL_HECS_IND' OR column_name IS NULL THEN
      IF new_references.differential_hecs_ind <> UPPER(new_references.differential_hecs_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'HECS_PAYMENT_OPTION' OR column_name IS NULL THEN
      IF new_references.hecs_payment_option <> UPPER(new_references.hecs_payment_option) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'OLD_CITIZENSHIP_CD' OR column_name IS NULL THEN
      IF new_references.old_citizenship_cd <> UPPER(new_references.old_citizenship_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_DIFFERENTIAL_HECS_IND' OR column_name IS NULL THEN
      IF new_references.old_differential_hecs_ind <> UPPER(new_references.old_differential_hecs_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_HECS_PAYMENT_OPTION' OR column_name IS NULL THEN
      IF new_references.old_hecs_payment_option <> UPPER(new_references.old_hecs_payment_option) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_PERM_RESIDENT_CD' OR column_name IS NULL THEN
      IF new_references.old_perm_resident_cd <> UPPER(new_references.old_perm_resident_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_PRIOR_DEGREE' OR column_name IS NULL THEN
      IF new_references.old_prior_degree <> UPPER(new_references.old_prior_degree) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_PRIOR_POST_GRAD' OR column_name IS NULL THEN
      IF new_references.old_prior_post_grad <> UPPER(new_references.old_prior_post_grad) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'OLD_UNIT_CD' OR column_name IS NULL THEN
      IF new_references.old_unit_cd <> UPPER(new_references.old_unit_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'PERM_RESIDENT_CD' OR column_name IS NULL THEN
      IF new_references.perm_resident_cd <> UPPER(new_references.perm_resident_cd) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'PRIOR_DEGREE' OR column_name IS NULL THEN
      IF new_references.prior_degree <> UPPER(new_references.prior_degree) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
    IF upper(column_name) = 'PRIOR_POST_GRAD' OR column_name IS NULL THEN
      IF new_references.prior_post_grad <> UPPER(new_references.prior_post_grad) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
   IF upper(column_name) = 'REPORTED_IND' OR column_name IS NULL THEN
      IF new_references.reported_ind <> UPPER(new_references.reported_ind) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;
   IF upper(column_name) = 'UNIT_CD' OR column_name IS NULL THEN
      IF new_references.unit_cd <> UPPER(new_references.unit_cd) THEN
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
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_changed_update_who IN VARCHAR2 DEFAULT NULL,
    x_changed_update_on IN DATE DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_old_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_old_eftsu IN NUMBER DEFAULT NULL,
    x_old_hecs_prexmt_exie IN NUMBER DEFAULT NULL,
    x_old_hecs_amount_paid IN NUMBER DEFAULT NULL,
    x_old_hecs_payment_option IN VARCHAR2 DEFAULT NULL,
    x_old_differential_hecs_ind IN VARCHAR2 DEFAULT NULL,
    x_old_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_old_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_old_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_old_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_reported_ind IN VARCHAR2 DEFAULT NULL,
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
      x_submission_yr,
      x_submission_number,
      x_person_id,
      x_course_cd,
      x_version_number,
      x_sequence_number,
      x_changed_update_who,
      x_changed_update_on,
      x_govt_semester,
      x_unit_cd,
      x_eftsu,
      x_hecs_prexmt_exie,
      x_hecs_amount_paid,
      x_hecs_payment_option,
      x_differential_hecs_ind,
      x_citizenship_cd,
      x_perm_resident_cd,
      x_prior_degree,
      x_prior_post_grad,
      x_old_unit_cd,
      x_old_eftsu,
      x_old_hecs_prexmt_exie,
      x_old_hecs_amount_paid,
      x_old_hecs_payment_option,
      x_old_differential_hecs_ind,
      x_old_citizenship_cd,
      x_old_perm_resident_cd,
      x_old_prior_degree,
      x_old_prior_post_grad,
      x_reported_ind,
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
        new_references.submission_yr,
        new_references.submission_number,
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
        new_references.submission_yr,
        new_references.submission_number,
        new_references.person_id,
        new_references.course_cd,
        new_references.sequence_number
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Delete.
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Call all the procedures related to Before Delete.
      null;

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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CHANGED_UPDATE_WHO in VARCHAR2,
  X_CHANGED_UPDATE_ON in DATE,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_OLD_UNIT_CD in VARCHAR2,
  X_OLD_EFTSU in NUMBER,
  X_OLD_HECS_PREXMT_EXIE in NUMBER,
  X_OLD_HECS_AMOUNT_PAID in NUMBER,
  X_OLD_HECS_PAYMENT_OPTION in VARCHAR2,
  X_OLD_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_OLD_CITIZENSHIP_CD in VARCHAR2,
  X_OLD_PERM_RESIDENT_CD in VARCHAR2,
  X_OLD_PRIOR_DEGREE in VARCHAR2,
  X_OLD_PRIOR_POST_GRAD in VARCHAR2,
  X_REPORTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_ST_GVT_SPSHT_CHG
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_person_id => X_PERSON_ID,
    x_course_cd =>X_COURSE_CD,
    x_version_number =>X_VERSION_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_changed_update_who => X_CHANGED_UPDATE_WHO,
    x_changed_update_on => X_CHANGED_UPDATE_ON,
    x_govt_semester => X_GOVT_SEMESTER,
    x_unit_cd => X_UNIT_CD,
    x_eftsu => X_EFTSU,
    x_hecs_prexmt_exie => X_HECS_PREXMT_EXIE,
    x_hecs_amount_paid => X_HECS_AMOUNT_PAID,
    x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
    x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
    x_citizenship_cd => X_CITIZENSHIP_CD,
    x_perm_resident_cd => X_PERM_RESIDENT_CD,
    x_prior_degree => X_PRIOR_DEGREE,
    x_prior_post_grad => X_PRIOR_POST_GRAD,
    x_old_unit_cd => X_OLD_UNIT_CD,
    x_old_eftsu => X_OLD_EFTSU,
    x_old_hecs_prexmt_exie => X_OLD_HECS_PREXMT_EXIE,
    x_old_hecs_amount_paid => X_OLD_HECS_AMOUNT_PAID,
    x_old_hecs_payment_option => X_OLD_HECS_PAYMENT_OPTION,
    x_old_differential_hecs_ind => X_OLD_DIFFERENTIAL_HECS_IND,
    x_old_citizenship_cd => X_OLD_CITIZENSHIP_CD,
    x_old_perm_resident_cd => X_OLD_PERM_RESIDENT_CD,
    x_old_prior_degree => X_OLD_PRIOR_DEGREE,
    x_old_prior_post_grad => X_OLD_PRIOR_POST_GRAD,
    x_reported_ind => NVL(X_REPORTED_IND,'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_ST_GVT_SPSHT_CHG (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    PERSON_ID,
    COURSE_CD,
    VERSION_NUMBER,
    SEQUENCE_NUMBER,
    CHANGED_UPDATE_WHO,
    CHANGED_UPDATE_ON,
    GOVT_SEMESTER,
    UNIT_CD,
    EFTSU,
    HECS_PREXMT_EXIE,
    HECS_AMOUNT_PAID,
    HECS_PAYMENT_OPTION,
    DIFFERENTIAL_HECS_IND,
    CITIZENSHIP_CD,
    PERM_RESIDENT_CD,
    PRIOR_DEGREE,
    PRIOR_POST_GRAD,
    OLD_UNIT_CD,
    OLD_EFTSU,
    OLD_HECS_PREXMT_EXIE,
    OLD_HECS_AMOUNT_PAID,
    OLD_HECS_PAYMENT_OPTION,
    OLD_DIFFERENTIAL_HECS_IND,
    OLD_CITIZENSHIP_CD,
    OLD_PERM_RESIDENT_CD,
    OLD_PRIOR_DEGREE,
    OLD_PRIOR_POST_GRAD,
    REPORTED_IND,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.CHANGED_UPDATE_WHO,
    NEW_REFERENCES.CHANGED_UPDATE_ON,
    NEW_REFERENCES.GOVT_SEMESTER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.EFTSU,
    NEW_REFERENCES.HECS_PREXMT_EXIE,
    NEW_REFERENCES.HECS_AMOUNT_PAID,
    NEW_REFERENCES.HECS_PAYMENT_OPTION,
    NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    NEW_REFERENCES.CITIZENSHIP_CD,
    NEW_REFERENCES.PERM_RESIDENT_CD,
    NEW_REFERENCES.PRIOR_DEGREE,
    NEW_REFERENCES.PRIOR_POST_GRAD,
    NEW_REFERENCES.OLD_UNIT_CD,
    NEW_REFERENCES.OLD_EFTSU,
    NEW_REFERENCES.OLD_HECS_PREXMT_EXIE,
    NEW_REFERENCES.OLD_HECS_AMOUNT_PAID,
    NEW_REFERENCES.OLD_HECS_PAYMENT_OPTION,
    NEW_REFERENCES.OLD_DIFFERENTIAL_HECS_IND,
    NEW_REFERENCES.OLD_CITIZENSHIP_CD,
    NEW_REFERENCES.OLD_PERM_RESIDENT_CD,
    NEW_REFERENCES.OLD_PRIOR_DEGREE,
    NEW_REFERENCES.OLD_PRIOR_POST_GRAD,
    NEW_REFERENCES.REPORTED_IND,
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
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CHANGED_UPDATE_WHO in VARCHAR2,
  X_CHANGED_UPDATE_ON in DATE,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_OLD_UNIT_CD in VARCHAR2,
  X_OLD_EFTSU in NUMBER,
  X_OLD_HECS_PREXMT_EXIE in NUMBER,
  X_OLD_HECS_AMOUNT_PAID in NUMBER,
  X_OLD_HECS_PAYMENT_OPTION in VARCHAR2,
  X_OLD_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_OLD_CITIZENSHIP_CD in VARCHAR2,
  X_OLD_PERM_RESIDENT_CD in VARCHAR2,
  X_OLD_PRIOR_DEGREE in VARCHAR2,
  X_OLD_PRIOR_POST_GRAD in VARCHAR2,
  X_REPORTED_IND in VARCHAR2
) as
  cursor c1 is select
      VERSION_NUMBER,
      CHANGED_UPDATE_WHO,
      CHANGED_UPDATE_ON,
      GOVT_SEMESTER,
      UNIT_CD,
      EFTSU,
      HECS_PREXMT_EXIE,
      HECS_AMOUNT_PAID,
      HECS_PAYMENT_OPTION,
      DIFFERENTIAL_HECS_IND,
      CITIZENSHIP_CD,
      PERM_RESIDENT_CD,
      PRIOR_DEGREE,
      PRIOR_POST_GRAD,
      OLD_UNIT_CD,
      OLD_EFTSU,
      OLD_HECS_PREXMT_EXIE,
      OLD_HECS_AMOUNT_PAID,
      OLD_HECS_PAYMENT_OPTION,
      OLD_DIFFERENTIAL_HECS_IND,
      OLD_CITIZENSHIP_CD,
      OLD_PERM_RESIDENT_CD,
      OLD_PRIOR_DEGREE,
      OLD_PRIOR_POST_GRAD,
      REPORTED_IND
    from IGS_ST_GVT_SPSHT_CHG
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

  if ( (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND ((tlinfo.CHANGED_UPDATE_WHO = X_CHANGED_UPDATE_WHO)
           OR ((tlinfo.CHANGED_UPDATE_WHO is null)
               AND (X_CHANGED_UPDATE_WHO is null)))
      AND ((tlinfo.CHANGED_UPDATE_ON = X_CHANGED_UPDATE_ON)
           OR ((tlinfo.CHANGED_UPDATE_ON is null)
               AND (X_CHANGED_UPDATE_ON is null)))
      AND ((tlinfo.GOVT_SEMESTER = X_GOVT_SEMESTER)
           OR ((tlinfo.GOVT_SEMESTER is null)
               AND (X_GOVT_SEMESTER is null)))
      AND ((tlinfo.UNIT_CD = X_UNIT_CD)
           OR ((tlinfo.UNIT_CD is null)
               AND (X_UNIT_CD is null)))
      AND ((tlinfo.EFTSU = X_EFTSU)
           OR ((tlinfo.EFTSU is null)
               AND (X_EFTSU is null)))
      AND ((tlinfo.HECS_PREXMT_EXIE = X_HECS_PREXMT_EXIE)
           OR ((tlinfo.HECS_PREXMT_EXIE is null)
               AND (X_HECS_PREXMT_EXIE is null)))
      AND ((tlinfo.HECS_AMOUNT_PAID = X_HECS_AMOUNT_PAID)
           OR ((tlinfo.HECS_AMOUNT_PAID is null)
               AND (X_HECS_AMOUNT_PAID is null)))
      AND ((tlinfo.HECS_PAYMENT_OPTION = X_HECS_PAYMENT_OPTION)
           OR ((tlinfo.HECS_PAYMENT_OPTION is null)
               AND (X_HECS_PAYMENT_OPTION is null)))
      AND ((tlinfo.DIFFERENTIAL_HECS_IND = X_DIFFERENTIAL_HECS_IND)
           OR ((tlinfo.DIFFERENTIAL_HECS_IND is null)
               AND (X_DIFFERENTIAL_HECS_IND is null)))
      AND ((tlinfo.CITIZENSHIP_CD = X_CITIZENSHIP_CD)
           OR ((tlinfo.CITIZENSHIP_CD is null)
               AND (X_CITIZENSHIP_CD is null)))
      AND ((tlinfo.PERM_RESIDENT_CD = X_PERM_RESIDENT_CD)
           OR ((tlinfo.PERM_RESIDENT_CD is null)
               AND (X_PERM_RESIDENT_CD is null)))
      AND ((tlinfo.PRIOR_DEGREE = X_PRIOR_DEGREE)
           OR ((tlinfo.PRIOR_DEGREE is null)
               AND (X_PRIOR_DEGREE is null)))
      AND ((tlinfo.PRIOR_POST_GRAD = X_PRIOR_POST_GRAD)
           OR ((tlinfo.PRIOR_POST_GRAD is null)
               AND (X_PRIOR_POST_GRAD is null)))
      AND ((tlinfo.OLD_UNIT_CD = X_OLD_UNIT_CD)
           OR ((tlinfo.OLD_UNIT_CD is null)
               AND (X_OLD_UNIT_CD is null)))
      AND ((tlinfo.OLD_EFTSU = X_OLD_EFTSU)
           OR ((tlinfo.OLD_EFTSU is null)
               AND (X_OLD_EFTSU is null)))
      AND ((tlinfo.OLD_HECS_PREXMT_EXIE = X_OLD_HECS_PREXMT_EXIE)
           OR ((tlinfo.OLD_HECS_PREXMT_EXIE is null)
               AND (X_OLD_HECS_PREXMT_EXIE is null)))
      AND ((tlinfo.OLD_HECS_AMOUNT_PAID = X_OLD_HECS_AMOUNT_PAID)
           OR ((tlinfo.OLD_HECS_AMOUNT_PAID is null)
               AND (X_OLD_HECS_AMOUNT_PAID is null)))
      AND ((tlinfo.OLD_HECS_PAYMENT_OPTION = X_OLD_HECS_PAYMENT_OPTION)
           OR ((tlinfo.OLD_HECS_PAYMENT_OPTION is null)
               AND (X_OLD_HECS_PAYMENT_OPTION is null)))
      AND ((tlinfo.OLD_DIFFERENTIAL_HECS_IND = X_OLD_DIFFERENTIAL_HECS_IND)
           OR ((tlinfo.OLD_DIFFERENTIAL_HECS_IND is null)
               AND (X_OLD_DIFFERENTIAL_HECS_IND is null)))
      AND ((tlinfo.OLD_CITIZENSHIP_CD = X_OLD_CITIZENSHIP_CD)
           OR ((tlinfo.OLD_CITIZENSHIP_CD is null)
               AND (X_OLD_CITIZENSHIP_CD is null)))
      AND ((tlinfo.OLD_PERM_RESIDENT_CD = X_OLD_PERM_RESIDENT_CD)
           OR ((tlinfo.OLD_PERM_RESIDENT_CD is null)
               AND (X_OLD_PERM_RESIDENT_CD is null)))
      AND ((tlinfo.OLD_PRIOR_DEGREE = X_OLD_PRIOR_DEGREE)
           OR ((tlinfo.OLD_PRIOR_DEGREE is null)
               AND (X_OLD_PRIOR_DEGREE is null)))
      AND ((tlinfo.OLD_PRIOR_POST_GRAD = X_OLD_PRIOR_POST_GRAD)
           OR ((tlinfo.OLD_PRIOR_POST_GRAD is null)
               AND (X_OLD_PRIOR_POST_GRAD is null)))
      AND (tlinfo.REPORTED_IND = X_REPORTED_IND)
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CHANGED_UPDATE_WHO in VARCHAR2,
  X_CHANGED_UPDATE_ON in DATE,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_OLD_UNIT_CD in VARCHAR2,
  X_OLD_EFTSU in NUMBER,
  X_OLD_HECS_PREXMT_EXIE in NUMBER,
  X_OLD_HECS_AMOUNT_PAID in NUMBER,
  X_OLD_HECS_PAYMENT_OPTION in VARCHAR2,
  X_OLD_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_OLD_CITIZENSHIP_CD in VARCHAR2,
  X_OLD_PERM_RESIDENT_CD in VARCHAR2,
  X_OLD_PRIOR_DEGREE in VARCHAR2,
  X_OLD_PRIOR_POST_GRAD in VARCHAR2,
  X_REPORTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
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
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_person_id => X_PERSON_ID,
    x_course_cd =>X_COURSE_CD,
    x_version_number =>X_VERSION_NUMBER,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_changed_update_who => X_CHANGED_UPDATE_WHO,
    x_changed_update_on => X_CHANGED_UPDATE_ON,
    x_govt_semester => X_GOVT_SEMESTER,
    x_unit_cd => X_UNIT_CD,
    x_eftsu => X_EFTSU,
    x_hecs_prexmt_exie => X_HECS_PREXMT_EXIE,
    x_hecs_amount_paid => X_HECS_AMOUNT_PAID,
    x_hecs_payment_option => X_HECS_PAYMENT_OPTION,
    x_differential_hecs_ind => X_DIFFERENTIAL_HECS_IND,
    x_citizenship_cd => X_CITIZENSHIP_CD,
    x_perm_resident_cd => X_PERM_RESIDENT_CD,
    x_prior_degree => X_PRIOR_DEGREE,
    x_prior_post_grad => X_PRIOR_POST_GRAD,
    x_old_unit_cd => X_OLD_UNIT_CD,
    x_old_eftsu => X_OLD_EFTSU,
    x_old_hecs_prexmt_exie => X_OLD_HECS_PREXMT_EXIE,
    x_old_hecs_amount_paid => X_OLD_HECS_AMOUNT_PAID,
    x_old_hecs_payment_option => X_OLD_HECS_PAYMENT_OPTION,
    x_old_differential_hecs_ind => X_OLD_DIFFERENTIAL_HECS_IND,
    x_old_citizenship_cd => X_OLD_CITIZENSHIP_CD,
    x_old_perm_resident_cd => X_OLD_PERM_RESIDENT_CD,
    x_old_prior_degree => X_OLD_PRIOR_DEGREE,
    x_old_prior_post_grad => X_OLD_PRIOR_POST_GRAD,
    x_reported_ind => X_REPORTED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
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
    update IGS_ST_GVT_SPSHT_CHG set
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    CHANGED_UPDATE_WHO = NEW_REFERENCES.CHANGED_UPDATE_WHO,
    CHANGED_UPDATE_ON = NEW_REFERENCES.CHANGED_UPDATE_ON,
    GOVT_SEMESTER = NEW_REFERENCES.GOVT_SEMESTER,
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    EFTSU = NEW_REFERENCES.EFTSU,
    HECS_PREXMT_EXIE = NEW_REFERENCES.HECS_PREXMT_EXIE,
    HECS_AMOUNT_PAID = NEW_REFERENCES.HECS_AMOUNT_PAID,
    HECS_PAYMENT_OPTION = NEW_REFERENCES.HECS_PAYMENT_OPTION,
    DIFFERENTIAL_HECS_IND = NEW_REFERENCES.DIFFERENTIAL_HECS_IND,
    CITIZENSHIP_CD = NEW_REFERENCES.CITIZENSHIP_CD,
    PERM_RESIDENT_CD = NEW_REFERENCES.PERM_RESIDENT_CD,
    PRIOR_DEGREE = NEW_REFERENCES.PRIOR_DEGREE,
    PRIOR_POST_GRAD = NEW_REFERENCES.PRIOR_POST_GRAD,
    OLD_UNIT_CD = NEW_REFERENCES.OLD_UNIT_CD,
    OLD_EFTSU = NEW_REFERENCES.OLD_EFTSU,
    OLD_HECS_PREXMT_EXIE = NEW_REFERENCES.OLD_HECS_PREXMT_EXIE,
    OLD_HECS_AMOUNT_PAID = NEW_REFERENCES.OLD_HECS_AMOUNT_PAID,
    OLD_HECS_PAYMENT_OPTION = NEW_REFERENCES.OLD_HECS_PAYMENT_OPTION,
    OLD_DIFFERENTIAL_HECS_IND = NEW_REFERENCES.OLD_DIFFERENTIAL_HECS_IND,
    OLD_CITIZENSHIP_CD = NEW_REFERENCES.OLD_CITIZENSHIP_CD,
    OLD_PERM_RESIDENT_CD = NEW_REFERENCES.OLD_PERM_RESIDENT_CD,
    OLD_PRIOR_DEGREE = NEW_REFERENCES.OLD_PRIOR_DEGREE,
    OLD_PRIOR_POST_GRAD = NEW_REFERENCES.OLD_PRIOR_POST_GRAD,
    REPORTED_IND = NEW_REFERENCES.REPORTED_IND,
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
After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
);
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_VERSION_NUMBER in NUMBER,
  X_CHANGED_UPDATE_WHO in VARCHAR2,
  X_CHANGED_UPDATE_ON in DATE,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_EFTSU in NUMBER,
  X_HECS_PREXMT_EXIE in NUMBER,
  X_HECS_AMOUNT_PAID in NUMBER,
  X_HECS_PAYMENT_OPTION in VARCHAR2,
  X_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_OLD_UNIT_CD in VARCHAR2,
  X_OLD_EFTSU in NUMBER,
  X_OLD_HECS_PREXMT_EXIE in NUMBER,
  X_OLD_HECS_AMOUNT_PAID in NUMBER,
  X_OLD_HECS_PAYMENT_OPTION in VARCHAR2,
  X_OLD_DIFFERENTIAL_HECS_IND in VARCHAR2,
  X_OLD_CITIZENSHIP_CD in VARCHAR2,
  X_OLD_PERM_RESIDENT_CD in VARCHAR2,
  X_OLD_PRIOR_DEGREE in VARCHAR2,
  X_OLD_PRIOR_POST_GRAD in VARCHAR2,
  X_REPORTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_ST_GVT_SPSHT_CHG
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
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
     X_PERSON_ID,
     X_COURSE_CD,
     X_SEQUENCE_NUMBER,
     X_VERSION_NUMBER,
     X_CHANGED_UPDATE_WHO,
     X_CHANGED_UPDATE_ON,
     X_GOVT_SEMESTER,
     X_UNIT_CD,
     X_EFTSU,
     X_HECS_PREXMT_EXIE,
     X_HECS_AMOUNT_PAID,
     X_HECS_PAYMENT_OPTION,
     X_DIFFERENTIAL_HECS_IND,
     X_CITIZENSHIP_CD,
     X_PERM_RESIDENT_CD,
     X_PRIOR_DEGREE,
     X_PRIOR_POST_GRAD,
     X_OLD_UNIT_CD,
     X_OLD_EFTSU,
     X_OLD_HECS_PREXMT_EXIE,
     X_OLD_HECS_AMOUNT_PAID,
     X_OLD_HECS_PAYMENT_OPTION,
     X_OLD_DIFFERENTIAL_HECS_IND,
     X_OLD_CITIZENSHIP_CD,
     X_OLD_PERM_RESIDENT_CD,
     X_OLD_PRIOR_DEGREE,
     X_OLD_PRIOR_POST_GRAD,
     X_REPORTED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_PERSON_ID,
   X_COURSE_CD,
   X_SEQUENCE_NUMBER,
   X_VERSION_NUMBER,
   X_CHANGED_UPDATE_WHO,
   X_CHANGED_UPDATE_ON,
   X_GOVT_SEMESTER,
   X_UNIT_CD,
   X_EFTSU,
   X_HECS_PREXMT_EXIE,
   X_HECS_AMOUNT_PAID,
   X_HECS_PAYMENT_OPTION,
   X_DIFFERENTIAL_HECS_IND,
   X_CITIZENSHIP_CD,
   X_PERM_RESIDENT_CD,
   X_PRIOR_DEGREE,
   X_PRIOR_POST_GRAD,
   X_OLD_UNIT_CD,
   X_OLD_EFTSU,
   X_OLD_HECS_PREXMT_EXIE,
   X_OLD_HECS_AMOUNT_PAID,
   X_OLD_HECS_PAYMENT_OPTION,
   X_OLD_DIFFERENTIAL_HECS_IND,
   X_OLD_CITIZENSHIP_CD,
   X_OLD_PERM_RESIDENT_CD,
   X_OLD_PRIOR_DEGREE,
   X_OLD_PRIOR_POST_GRAD,
   X_REPORTED_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
delete from IGS_ST_GVT_SPSHT_CHG
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_ST_GVT_SPSHT_CHG_PKG;

/
