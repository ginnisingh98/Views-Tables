--------------------------------------------------------
--  DDL for Package Body IGS_ST_GVT_STDNTLOAD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GVT_STDNTLOAD_PKG" as
/* $Header: IGSVI09B.pls 115.4 2003/05/20 06:09:04 svanukur ship $ */
l_rowid VARCHAR2(25);
old_references IGS_ST_GVT_STDNTLOAD%RowType;
new_references IGS_ST_GVT_STDNTLOAD%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_sua_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sua_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_tr_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_tr_ou_start_dt IN DATE DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_industrial_ind IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_unit_completion_status IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_sua_location_cd IN VARCHAR2 DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GVT_STDNTLOAD
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
    new_references.crv_version_number := x_crv_version_number;
    new_references.govt_semester := x_govt_semester;
    new_references.unit_cd := x_unit_cd;
    new_references.uv_version_number := x_uv_version_number;
    new_references.sua_cal_type := x_sua_cal_type;
    new_references.sua_ci_sequence_number := x_sua_ci_sequence_number;
    new_references.tr_org_unit_cd := x_tr_org_unit_cd;
    new_references.tr_ou_start_dt := x_tr_ou_start_dt;
    new_references.discipline_group_cd := x_discipline_group_cd;
    new_references.govt_discipline_group_cd := x_govt_discipline_group_cd;
    new_references.industrial_ind := x_industrial_ind;
    new_references.eftsu := x_eftsu;
    new_references.unit_completion_status := x_unit_completion_status;
    new_references.unit_class :=x_unit_class;
    new_references.sua_location_cd := x_sua_location_cd;
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

PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
	v_message_name			VARCHAR2(30);
	v_transaction_type		VARCHAR2(15);
	v_submission_yr		IGS_ST_GVT_STDNTLOAD.submission_yr%TYPE;
	v_submission_number	IGS_ST_GVT_STDNTLOAD.submission_number%TYPE;
  BEGIN
	IF p_inserting THEN
		v_transaction_type := 'p_inserting';
		v_submission_yr := new_references.submission_yr;
		v_submission_number := new_references.submission_number;
	ELSIF p_updating THEN
		v_transaction_type := 'p_updating';
		v_submission_yr := new_references.submission_yr;
		v_submission_number := new_references.submission_number;
	ELSIF p_deleting THEN
		v_transaction_type := 'p_deleting';
		v_submission_yr := old_references.submission_yr;
		v_submission_number := old_references.submission_number;
	END IF;
	IF IGS_ST_VAL_GSE.stap_val_govt_snpsht (
			v_submission_yr,
			v_submission_number,
			v_transaction_type,
			v_message_name) = FALSE THEN
		--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
		FND_MESSAGE.SET_NAME('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;

  END BeforeRowInsertUpdateDelete1;

   PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.submission_yr = new_references.submission_yr) AND
         (old_references.submission_number = new_references.submission_number) AND
         (old_references.govt_semester = new_references.govt_semester)) OR
        ((new_references.submission_yr IS NULL) OR
         (new_references.submission_number IS NULL) OR
         (new_references.govt_semester IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_ST_GOVT_SEMESTER_PKG.Get_PK_For_Validation (
        new_references.submission_yr,
        new_references.submission_number,
        new_references.govt_semester
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
    x_govt_semester IN NUMBER,
    x_unit_cd IN VARCHAR2,
    x_sua_cal_type IN VARCHAR2,
    x_sua_ci_sequence_number IN NUMBER,
    x_tr_org_unit_cd IN VARCHAR2,
    x_tr_ou_start_dt IN DATE,
    x_discipline_group_cd IN VARCHAR2,
    x_govt_discipline_group_cd IN VARCHAR2
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_STDNTLOAD
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      govt_semester = x_govt_semester
      AND      unit_cd = x_unit_cd
      AND      sua_cal_type = x_sua_cal_type
      AND      sua_ci_sequence_number = x_sua_ci_sequence_number
      AND      tr_org_unit_cd = x_tr_org_unit_cd
      AND      tr_ou_start_dt = x_tr_ou_start_dt
      AND      discipline_group_cd = x_discipline_group_cd
      AND      govt_discipline_group_cd = x_govt_discipline_group_cd
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

  PROCEDURE GET_FK_IGS_ST_GOVT_SEMESTER (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_govt_semester IN NUMBER
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GVT_STDNTLOAD
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      govt_semester = x_govt_semester ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSLO_GSEM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GOVT_SEMESTER;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'INDUSTRIAL_IND' THEN
      new_references.industrial_ind := column_value;
     ELSIF upper(column_name) = 'SUBMISSION_YR' THEN
      new_references.submission_yr := IGS_GE_NUMBER.to_num(column_value);
     ELSIF upper(column_name) = 'EFTSU' THEN
      new_references.eftsu := IGS_GE_NUMBER.to_num(column_value);
     ELSIF upper(column_name) = 'UNIT_COMPLETION_STATUS' THEN
      new_references.unit_completion_status := IGS_GE_NUMBER.to_num(column_value);
     END IF;

     IF upper(column_name) = 'INDUSTRIAL_IND' OR column_name IS NULL THEN
      IF new_references.industrial_ind NOT IN ('Y','N') THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'SUBMISSION_YR' OR column_name IS NULL THEN
      IF new_references.submission_yr < 0000 OR new_references.submission_yr > 9999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'EFTSU' OR column_name IS NULL THEN
      IF new_references.eftsu < 0000.000 OR new_references.eftsu > 9999.999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'UNIT_COMPLETION_STATUS' OR column_name IS NULL THEN
      IF new_references.unit_completion_status NOT IN (1,2,3,4) THEN
      IGS_GE_MSG_STACK.ADD;
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
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_govt_semester IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_sua_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sua_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_tr_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_tr_ou_start_dt IN DATE DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_industrial_ind IN VARCHAR2 DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_unit_completion_status IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_sua_location_cd IN VARCHAR2 DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_submission_yr,
      x_submission_number,
      x_person_id,
      x_course_cd,
      x_crv_version_number,
      x_govt_semester,
      x_unit_cd,
      x_uv_version_number,
      x_sua_cal_type,
      x_sua_ci_sequence_number,
      x_tr_org_unit_cd,
      x_tr_ou_start_dt,
      x_discipline_group_cd,
      x_govt_discipline_group_cd,
      x_industrial_ind,
      x_eftsu,
      x_unit_completion_status,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_unit_class,
      x_sua_location_cd
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
       IF GET_PK_FOR_VALIDATION(
        new_references.submission_yr,
        new_references.submission_number,
        new_references.person_id,
        new_references.course_cd,
        new_references.govt_semester,
        new_references.unit_cd,
        new_references.sua_cal_type,
        new_references.sua_ci_sequence_number,
        new_references.tr_org_unit_cd,
        new_references.tr_ou_start_dt,
        new_references.discipline_group_cd,
        new_references.govt_discipline_group_cd
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Delete.
      IF GET_PK_FOR_VALIDATION(
        new_references.submission_yr,
        new_references.submission_number,
        new_references.person_id,
        new_references.course_cd,
        new_references.govt_semester,
        new_references.unit_cd,
        new_references.sua_cal_type,
        new_references.sua_ci_sequence_number,
        new_references.tr_org_unit_cd,
        new_references.tr_ou_start_dt,
        new_references.discipline_group_cd,
        new_references.govt_discipline_group_cd
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
      NULL;
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
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_EFTSU in NUMBER,
  X_UNIT_COMPLETION_STATUS in NUMBER,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_UNIT_CLASS IN VARCHAR2 ,
  X_SUA_LOCATION_CD IN VARCHAR2
  ) as
    cursor C is select ROWID from IGS_ST_GVT_STDNTLOAD
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and GOVT_SEMESTER = X_GOVT_SEMESTER
      and UNIT_CD = X_UNIT_CD
      and SUA_CAL_TYPE = X_SUA_CAL_TYPE
      and SUA_CI_SEQUENCE_NUMBER = X_SUA_CI_SEQUENCE_NUMBER
      and TR_ORG_UNIT_CD = X_TR_ORG_UNIT_CD
      and TR_OU_START_DT = X_TR_OU_START_DT
      and DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD
      and GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD;
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
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_crv_version_number => X_CRV_VERSION_NUMBER,
    x_govt_semester => X_GOVT_SEMESTER,
    x_unit_cd => X_UNIT_CD,
    x_uv_version_number => X_UV_VERSION_NUMBER,
    x_sua_cal_type => X_SUA_CAL_TYPE,
    x_sua_ci_sequence_number => X_SUA_CI_SEQUENCE_NUMBER,
    x_tr_org_unit_cd => X_TR_ORG_UNIT_CD,
    x_tr_ou_start_dt => X_TR_OU_START_DT,
    x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
    x_govt_discipline_group_cd => X_GOVT_DISCIPLINE_GROUP_CD,
    x_industrial_ind => X_INDUSTRIAL_IND,
    x_eftsu => X_EFTSU,
    x_unit_completion_status => X_UNIT_COMPLETION_STATUS,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN,
    x_unit_class => X_UNIT_CLASS,
    x_sua_location_cd =>X_SUA_LOCATION_CD
   );


  insert into IGS_ST_GVT_STDNTLOAD (
    TR_ORG_UNIT_CD,
    TR_OU_START_DT,
    DISCIPLINE_GROUP_CD,
    GOVT_DISCIPLINE_GROUP_CD,
    INDUSTRIAL_IND,
    EFTSU,
    UNIT_COMPLETION_STATUS,
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    PERSON_ID,
    COURSE_CD,
    CRV_VERSION_NUMBER,
    GOVT_SEMESTER,
    UNIT_CD,
    UV_VERSION_NUMBER,
    SUA_CAL_TYPE,
    SUA_CI_SEQUENCE_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    REQUEST_ID,
    PROGRAM_ID,
    PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE,
    UNIT_CLASS,
    SUA_LOCATION_CD
  ) values (
    NEW_REFERENCES.TR_ORG_UNIT_CD,
    NEW_REFERENCES.TR_OU_START_DT,
    NEW_REFERENCES.DISCIPLINE_GROUP_CD,
    NEW_REFERENCES.GOVT_DISCIPLINE_GROUP_CD,
    NEW_REFERENCES.INDUSTRIAL_IND,
    NEW_REFERENCES.EFTSU,
    NEW_REFERENCES.UNIT_COMPLETION_STATUS,
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.GOVT_SEMESTER,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.UV_VERSION_NUMBER,
    NEW_REFERENCES.SUA_CAL_TYPE,
    NEW_REFERENCES.SUA_CI_SEQUENCE_NUMBER,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_REQUEST_ID,
    X_PROGRAM_ID,
    X_PROGRAM_APPLICATION_ID,
    X_PROGRAM_UPDATE_DATE,
    NEW_REFERENCES.UNIT_CLASS,
    NEW_REFERENCES.SUA_LOCATION_CD
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_EFTSU in NUMBER,
  X_UNIT_COMPLETION_STATUS in NUMBER,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_UNIT_CLASS in VARCHAR2,
  X_SUA_LOCATION_CD in varchar2
) as
  cursor c1 is select
      INDUSTRIAL_IND,
      EFTSU,
      UNIT_COMPLETION_STATUS,
      CRV_VERSION_NUMBER,
      UV_VERSION_NUMBER
    from IGS_ST_GVT_STDNTLOAD
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

  if ( (tlinfo.INDUSTRIAL_IND = X_INDUSTRIAL_IND)
      AND (tlinfo.EFTSU = X_EFTSU)
      AND (tlinfo.UNIT_COMPLETION_STATUS = X_UNIT_COMPLETION_STATUS)
      AND (tlinfo.CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER)
      AND (tlinfo.UV_VERSION_NUMBER = X_UV_VERSION_NUMBER)
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
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_EFTSU in NUMBER,
  X_UNIT_COMPLETION_STATUS in NUMBER,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_UNIT_CLASS in VARCHAR2,
  X_SUA_LOCATION_CD in varchar2
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
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_submission_yr => X_SUBMISSION_YR,
    x_submission_number => X_SUBMISSION_NUMBER,
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_crv_version_number => X_CRV_VERSION_NUMBER,
    x_govt_semester => X_GOVT_SEMESTER,
    x_unit_cd => X_UNIT_CD,
    x_uv_version_number => X_UV_VERSION_NUMBER,
    x_sua_cal_type => X_SUA_CAL_TYPE,
    x_sua_ci_sequence_number => X_SUA_CI_SEQUENCE_NUMBER,
    x_tr_org_unit_cd => X_TR_ORG_UNIT_CD,
    x_tr_ou_start_dt => X_TR_OU_START_DT,
    x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
    x_govt_discipline_group_cd => X_GOVT_DISCIPLINE_GROUP_CD,
    x_industrial_ind => X_INDUSTRIAL_IND,
    x_eftsu => X_EFTSU,
    x_unit_completion_status => X_UNIT_COMPLETION_STATUS,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN,
    x_unit_class => X_UNIT_CLASS,
    x_sua_location_cd =>X_SUA_LOCATION_CD
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
  update IGS_ST_GVT_STDNTLOAD set
    INDUSTRIAL_IND = NEW_REFERENCES.INDUSTRIAL_IND,
    EFTSU = NEW_REFERENCES.EFTSU,
    UNIT_COMPLETION_STATUS = NEW_REFERENCES.UNIT_COMPLETION_STATUS,
    CRV_VERSION_NUMBER = NEW_REFERENCES.CRV_VERSION_NUMBER,
    UV_VERSION_NUMBER = NEW_REFERENCES.UV_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID = X_REQUEST_ID,
    PROGRAM_ID = X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    UNIT_CLASS = X_UNIT_CLASS,
    SUA_LOCATION_CD = X_SUA_LOCATION_CD
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
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_GOVT_SEMESTER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_INDUSTRIAL_IND in VARCHAR2,
  X_EFTSU in NUMBER,
  X_UNIT_COMPLETION_STATUS in NUMBER,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UV_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R',
  X_UNIT_CLASS in VARCHAR2,
  X_SUA_LOCATION_CD in varchar2
  ) as
  cursor c1 is select rowid from IGS_ST_GVT_STDNTLOAD
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and GOVT_SEMESTER = X_GOVT_SEMESTER
     and UNIT_CD = X_UNIT_CD
     and SUA_CAL_TYPE = X_SUA_CAL_TYPE
     and SUA_CI_SEQUENCE_NUMBER = X_SUA_CI_SEQUENCE_NUMBER
     and TR_ORG_UNIT_CD = X_TR_ORG_UNIT_CD
     and TR_OU_START_DT = X_TR_OU_START_DT
     and DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD
     and GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD
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
     X_GOVT_SEMESTER,
     X_UNIT_CD,
     X_SUA_CAL_TYPE,
     X_SUA_CI_SEQUENCE_NUMBER,
     X_TR_ORG_UNIT_CD,
     X_TR_OU_START_DT,
     X_DISCIPLINE_GROUP_CD,
     X_GOVT_DISCIPLINE_GROUP_CD,
     X_INDUSTRIAL_IND,
     X_EFTSU,
     X_UNIT_COMPLETION_STATUS,
     X_CRV_VERSION_NUMBER,
     X_UV_VERSION_NUMBER,
     X_MODE,
     X_UNIT_CLASS,
     X_SUA_LOCATION_CD);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_PERSON_ID,
   X_COURSE_CD,
   X_GOVT_SEMESTER,
   X_UNIT_CD,
   X_SUA_CAL_TYPE,
   X_SUA_CI_SEQUENCE_NUMBER,
   X_TR_ORG_UNIT_CD,
   X_TR_OU_START_DT,
   X_DISCIPLINE_GROUP_CD,
   X_GOVT_DISCIPLINE_GROUP_CD,
   X_INDUSTRIAL_IND,
   X_EFTSU,
   X_UNIT_COMPLETION_STATUS,
   X_CRV_VERSION_NUMBER,
   X_UV_VERSION_NUMBER,
   X_MODE,
   X_UNIT_CLASS,
   X_SUA_LOCATION_CD );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

  Before_DML(
   p_action =>'DELETE',
   x_rowid => X_ROWID
  );

  delete from IGS_ST_GVT_STDNTLOAD
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
   p_action =>'DELETE',
   x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_ST_GVT_STDNTLOAD_PKG;

/
