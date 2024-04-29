--------------------------------------------------------
--  DDL for Package Body IGS_EN_ST_SNAPSHOT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ST_SNAPSHOT_PKG" as
/* $Header: IGSEI08B.pls 115.3 2002/11/28 23:33:02 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_ST_SNAPSHOT%RowType;
  new_references IGS_EN_ST_SNAPSHOT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ESS_ID IN NUMBER DEFAULT NULL,
    x_govt_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_major_course IN NUMBER DEFAULT NULL,
    x_commencing_student_ind IN VARCHAR2 DEFAULT NULL,
    x_school_leaver IN NUMBER DEFAULT NULL,
    x_new_to_higher_education IN NUMBER DEFAULT NULL,
    x_sua_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_weftsu IN NUMBER DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_reportable_ind IN VARCHAR2 DEFAULT NULL,
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_ci_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_sua_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sua_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_tr_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_tr_ou_start_dt IN DATE DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_ou_start_dt IN DATE DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_govt_course_type IN NUMBER DEFAULT NULL,
    x_course_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_sca_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ST_SNAPSHOT
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.ESS_ID := x_ESS_ID;
    new_references.govt_attendance_type := x_govt_attendance_type;
    new_references.funding_source := x_funding_source;
    new_references.govt_funding_source := x_govt_funding_source;
    new_references.major_course := x_major_course;
    new_references.commencing_student_ind := x_commencing_student_ind;
    new_references.school_leaver := x_school_leaver;
    new_references.new_to_higher_education := x_new_to_higher_education;
    new_references.sua_location_cd := x_sua_location_cd;
    new_references.unit_class := x_unit_class;
    new_references.unit_level := x_unit_level;
    new_references.enrolled_dt := x_enrolled_dt;
    new_references.discontinued_dt := x_discontinued_dt;
    new_references.eftsu := x_eftsu;
    new_references.weftsu := x_weftsu;
    new_references.unit_int_course_level_cd := x_unit_int_course_level_cd;
    new_references.govt_reportable_ind := x_govt_reportable_ind;
    new_references.snapshot_dt_time := x_snapshot_dt_time;
    new_references.ci_cal_type := x_ci_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.unit_cd := x_unit_cd;
    new_references.uv_version_number := x_uv_version_number;
    new_references.sua_cal_type := x_sua_cal_type;
    new_references.sua_ci_sequence_number := x_sua_ci_sequence_number;
    new_references.tr_org_unit_cd := x_tr_org_unit_cd;
    new_references.tr_ou_start_dt := x_tr_ou_start_dt;
    new_references.discipline_group_cd := x_discipline_group_cd;
    new_references.govt_discipline_group_cd := x_govt_discipline_group_cd;
    new_references.crv_org_unit_cd := x_crv_org_unit_cd;
    new_references.crv_ou_start_dt := x_crv_ou_start_dt;
    new_references.course_type := x_course_type;
    new_references.govt_course_type := x_govt_course_type;
    new_references.course_type_group_cd := x_course_type_group_cd;
    new_references.sca_location_cd := x_sca_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.govt_attendance_mode := x_govt_attendance_mode;
    new_references.attendance_type := x_attendance_type;
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

    IF (((old_references.snapshot_dt_time = new_references.snapshot_dt_time)) OR
        ((new_references.snapshot_dt_time IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ST_SPSHT_CTL_PKG.Get_PK_For_Validation (
        new_references.snapshot_dt_time
        ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE GET_FK_IGS_EN_ST_SPSHT_CTL (
    x_snapshot_dt_time IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ST_SNAPSHOT
      WHERE    snapshot_dt_time = x_snapshot_dt_time ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ESS_ESSC_FK');
IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ST_SPSHT_CTL;

  FUNCTION Get_PK_For_Validation (
    x_ESS_ID IN NUMBER
    ) RETURN BOOLEAN as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_ST_SNAPSHOT
      WHERE    ESS_ID = x_ESS_ID
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_ESS_ID IN NUMBER DEFAULT NULL,
    x_govt_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_govt_funding_source IN NUMBER DEFAULT NULL,
    x_major_course IN NUMBER DEFAULT NULL,
    x_commencing_student_ind IN VARCHAR2 DEFAULT NULL,
    x_school_leaver IN NUMBER DEFAULT NULL,
    x_new_to_higher_education IN NUMBER DEFAULT NULL,
    x_sua_location_cd IN VARCHAR2 DEFAULT NULL,
    x_unit_class IN VARCHAR2 DEFAULT NULL,
    x_unit_level IN VARCHAR2 DEFAULT NULL,
    x_enrolled_dt IN DATE DEFAULT NULL,
    x_discontinued_dt IN DATE DEFAULT NULL,
    x_eftsu IN NUMBER DEFAULT NULL,
    x_weftsu IN NUMBER DEFAULT NULL,
    x_unit_int_course_level_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_reportable_ind IN VARCHAR2 DEFAULT NULL,
    x_snapshot_dt_time IN DATE DEFAULT NULL,
    x_ci_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_uv_version_number IN NUMBER DEFAULT NULL,
    x_sua_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sua_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_tr_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_tr_ou_start_dt IN DATE DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_ou_start_dt IN DATE DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_govt_course_type IN NUMBER DEFAULT NULL,
    x_course_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_sca_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
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
      x_ESS_ID,
      x_govt_attendance_type,
      x_funding_source,
      x_govt_funding_source,
      x_major_course,
      x_commencing_student_ind,
      x_school_leaver,
      x_new_to_higher_education,
      x_sua_location_cd,
      x_unit_class,
      x_unit_level,
      x_enrolled_dt,
      x_discontinued_dt,
      x_eftsu,
      x_weftsu,
      x_unit_int_course_level_cd,
      x_govt_reportable_ind,
      x_snapshot_dt_time,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_person_id,
      x_course_cd,
      x_crv_version_number,
      x_unit_cd,
      x_uv_version_number,
      x_sua_cal_type,
      x_sua_ci_sequence_number,
      x_tr_org_unit_cd,
      x_tr_ou_start_dt,
      x_discipline_group_cd,
      x_govt_discipline_group_cd,
      x_crv_org_unit_cd,
      x_crv_ou_start_dt,
      x_course_type,
      x_govt_course_type,
      x_course_type_group_cd,
      x_sca_location_cd,
      x_attendance_mode,
      x_govt_attendance_mode,
      x_attendance_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation(
		 new_references.ESS_ID
	                            ) THEN

 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;
         Check_Parent_Existance;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.ESS_ID
				 ) THEN
		          Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
		          App_Exception.Raise_Exception;
     	        END IF;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      		  null;
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ESS_ID in out NOCOPY NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_EN_ST_SNAPSHOT
      where ESS_ID = X_ESS_ID;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID  NUMBER;
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

	x_request_id := fnd_global.conc_request_id;
 	x_program_id := fnd_global.conc_program_id;
	x_program_application_id := fnd_global.prog_appl_id;

	if (x_request_id = -1) then
	 x_request_id := NULL;
	 x_program_id := NULL;
	 x_program_application_id := NULL;
	 x_program_update_date := NULL;
	else
	 x_program_update_date := SYSDATE;
	end if;

  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;

      SELECT   IGS_EN_ST_SNAPSHOT_ESS_ID_S.Nextval
      INTO     X_ESS_ID
      FROM     DUAL;

 Before_DML(
  p_action=>'INSERT',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_ci_cal_type=>X_CI_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_commencing_student_ind=>X_COMMENCING_STUDENT_IND,
  x_course_cd=>X_COURSE_CD,
  x_course_type=>X_COURSE_TYPE,
  x_course_type_group_cd=>X_COURSE_TYPE_GROUP_CD,
  x_crv_org_unit_cd=>X_CRV_ORG_UNIT_CD,
  x_crv_ou_start_dt=>X_CRV_OU_START_DT,
  x_crv_version_number=>X_CRV_VERSION_NUMBER,
  x_discipline_group_cd=>X_DISCIPLINE_GROUP_CD,
  x_discontinued_dt=>X_DISCONTINUED_DT,
  x_eftsu=>X_EFTSU,
  x_enrolled_dt=>X_ENROLLED_DT,
  x_funding_source=>X_FUNDING_SOURCE,
  x_govt_attendance_mode=>X_GOVT_ATTENDANCE_MODE,
  x_govt_attendance_type=>X_GOVT_ATTENDANCE_TYPE,
  x_govt_course_type=>X_GOVT_COURSE_TYPE,
  x_govt_discipline_group_cd=>X_GOVT_DISCIPLINE_GROUP_CD,
  x_govt_funding_source=>X_GOVT_FUNDING_SOURCE,
  x_govt_reportable_ind=>X_GOVT_REPORTABLE_IND,
  x_major_course=>X_MAJOR_COURSE,
  x_new_to_higher_education=>X_NEW_TO_HIGHER_EDUCATION,
  x_person_id=>X_PERSON_ID,
  x_sca_location_cd=>X_SCA_LOCATION_CD,
  x_school_leaver=>X_SCHOOL_LEAVER,
  x_ESS_ID=>X_ESS_ID,
  x_snapshot_dt_time=>X_SNAPSHOT_DT_TIME,
  x_sua_cal_type=>X_SUA_CAL_TYPE,
  x_sua_ci_sequence_number=>X_SUA_CI_SEQUENCE_NUMBER,
  x_sua_location_cd=>X_SUA_LOCATION_CD,
  x_tr_org_unit_cd=>X_TR_ORG_UNIT_CD,
  x_tr_ou_start_dt=>X_TR_OU_START_DT,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_int_course_level_cd=>X_UNIT_INT_COURSE_LEVEL_CD,
  x_unit_level=>X_UNIT_LEVEL,
  x_uv_version_number=>X_UV_VERSION_NUMBER,
  x_weftsu=>X_WEFTSU,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );

  insert into IGS_EN_ST_SNAPSHOT (
    ESS_ID,
    SNAPSHOT_DT_TIME,
    CI_CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    PERSON_ID,
    COURSE_CD,
    CRV_VERSION_NUMBER,
    UNIT_CD,
    UV_VERSION_NUMBER,
    SUA_CAL_TYPE,
    SUA_CI_SEQUENCE_NUMBER,
    TR_ORG_UNIT_CD,
    TR_OU_START_DT,
    DISCIPLINE_GROUP_CD,
    GOVT_DISCIPLINE_GROUP_CD,
    CRV_ORG_UNIT_CD,
    CRV_OU_START_DT,
    COURSE_TYPE,
    GOVT_COURSE_TYPE,
    COURSE_TYPE_GROUP_CD,
    SCA_LOCATION_CD,
    ATTENDANCE_MODE,
    GOVT_ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    GOVT_ATTENDANCE_TYPE,
    FUNDING_SOURCE,
    GOVT_FUNDING_SOURCE,
    MAJOR_COURSE,
    COMMENCING_STUDENT_IND,
    SCHOOL_LEAVER,
    NEW_TO_HIGHER_EDUCATION,
    SUA_LOCATION_CD,
    UNIT_CLASS,
    UNIT_LEVEL,
    ENROLLED_DT,
    DISCONTINUED_DT,
    EFTSU,
    WEFTSU,
    UNIT_INT_COURSE_LEVEL_CD,
    GOVT_REPORTABLE_IND,
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
    new_references.ESS_ID,
    new_references.SNAPSHOT_DT_TIME,
    new_references.CI_CAL_TYPE,
    new_references.CI_SEQUENCE_NUMBER,
    new_references.PERSON_ID,
    new_references.COURSE_CD,
    new_references.CRV_VERSION_NUMBER,
    new_references.UNIT_CD,
    new_references.UV_VERSION_NUMBER,
    new_references.SUA_CAL_TYPE,
    new_references.SUA_CI_SEQUENCE_NUMBER,
    new_references.TR_ORG_UNIT_CD,
    new_references.TR_OU_START_DT,
    new_references.DISCIPLINE_GROUP_CD,
    new_references.GOVT_DISCIPLINE_GROUP_CD,
    new_references.CRV_ORG_UNIT_CD,
    new_references.CRV_OU_START_DT,
    new_references.COURSE_TYPE,
    new_references.GOVT_COURSE_TYPE,
    new_references.COURSE_TYPE_GROUP_CD,
    new_references.SCA_LOCATION_CD,
    new_references.ATTENDANCE_MODE,
    new_references.GOVT_ATTENDANCE_MODE,
    new_references.ATTENDANCE_TYPE,
    new_references.GOVT_ATTENDANCE_TYPE,
    new_references.FUNDING_SOURCE,
    new_references.GOVT_FUNDING_SOURCE,
    new_references.MAJOR_COURSE,
    new_references.COMMENCING_STUDENT_IND,
    new_references.SCHOOL_LEAVER,
    new_references.NEW_TO_HIGHER_EDUCATION,
    new_references.SUA_LOCATION_CD,
    new_references.UNIT_CLASS,
    new_references.UNIT_LEVEL,
    new_references.ENROLLED_DT,
    new_references.DISCONTINUED_DT,
    new_references.EFTSU,
    new_references.WEFTSU,
    new_references.UNIT_INT_COURSE_LEVEL_CD,
    new_references.GOVT_REPORTABLE_IND,
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
    p_action => 'INSERT',
    x_rowid => X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ESS_ID in NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2
) AS
  cursor c1 is select
      SNAPSHOT_DT_TIME,
      CI_CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      PERSON_ID,
      COURSE_CD,
      CRV_VERSION_NUMBER,
      UNIT_CD,
      UV_VERSION_NUMBER,
      SUA_CAL_TYPE,
      SUA_CI_SEQUENCE_NUMBER,
      TR_ORG_UNIT_CD,
      TR_OU_START_DT,
      DISCIPLINE_GROUP_CD,
      GOVT_DISCIPLINE_GROUP_CD,
      CRV_ORG_UNIT_CD,
      CRV_OU_START_DT,
      COURSE_TYPE,
      GOVT_COURSE_TYPE,
      COURSE_TYPE_GROUP_CD,
      SCA_LOCATION_CD,
      ATTENDANCE_MODE,
      GOVT_ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      GOVT_ATTENDANCE_TYPE,
      FUNDING_SOURCE,
      GOVT_FUNDING_SOURCE,
      MAJOR_COURSE,
      COMMENCING_STUDENT_IND,
      SCHOOL_LEAVER,
      NEW_TO_HIGHER_EDUCATION,
      SUA_LOCATION_CD,
      UNIT_CLASS,
      UNIT_LEVEL,
      ENROLLED_DT,
      DISCONTINUED_DT,
      EFTSU,
      WEFTSU,
      UNIT_INT_COURSE_LEVEL_CD,
      GOVT_REPORTABLE_IND
    from IGS_EN_ST_SNAPSHOT
    where rowid = x_rowid for update nowait;
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

  if ( (tlinfo.SNAPSHOT_DT_TIME = X_SNAPSHOT_DT_TIME)
      AND (tlinfo.CI_CAL_TYPE = X_CI_CAL_TYPE)
      AND (tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
      AND (tlinfo.PERSON_ID = X_PERSON_ID)
      AND (tlinfo.COURSE_CD = X_COURSE_CD)
      AND (tlinfo.CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER)
      AND (tlinfo.UNIT_CD = X_UNIT_CD)
      AND (tlinfo.UV_VERSION_NUMBER = X_UV_VERSION_NUMBER)
      AND (tlinfo.SUA_CAL_TYPE = X_SUA_CAL_TYPE)
      AND (tlinfo.SUA_CI_SEQUENCE_NUMBER = X_SUA_CI_SEQUENCE_NUMBER)
      AND (tlinfo.TR_ORG_UNIT_CD = X_TR_ORG_UNIT_CD)
      AND (tlinfo.TR_OU_START_DT = X_TR_OU_START_DT)
      AND (tlinfo.DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD)
      AND (tlinfo.GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD)
      AND (tlinfo.CRV_ORG_UNIT_CD = X_CRV_ORG_UNIT_CD)
      AND (tlinfo.CRV_OU_START_DT = X_CRV_OU_START_DT)
      AND (tlinfo.COURSE_TYPE = X_COURSE_TYPE)
      AND (tlinfo.GOVT_COURSE_TYPE = X_GOVT_COURSE_TYPE)
      AND ((tlinfo.COURSE_TYPE_GROUP_CD = X_COURSE_TYPE_GROUP_CD)
           OR ((tlinfo.COURSE_TYPE_GROUP_CD is null)
               AND (X_COURSE_TYPE_GROUP_CD is null)))
      AND (tlinfo.SCA_LOCATION_CD = X_SCA_LOCATION_CD)
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.GOVT_ATTENDANCE_MODE = X_GOVT_ATTENDANCE_MODE)
           OR ((tlinfo.GOVT_ATTENDANCE_MODE is null)
               AND (X_GOVT_ATTENDANCE_MODE is null)))
      AND (tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
      AND (tlinfo.GOVT_ATTENDANCE_TYPE = X_GOVT_ATTENDANCE_TYPE)
      AND ((tlinfo.FUNDING_SOURCE = X_FUNDING_SOURCE)
           OR ((tlinfo.FUNDING_SOURCE is null)
               AND (X_FUNDING_SOURCE is null)))
      AND ((tlinfo.GOVT_FUNDING_SOURCE = X_GOVT_FUNDING_SOURCE)
           OR ((tlinfo.GOVT_FUNDING_SOURCE is null)
               AND (X_GOVT_FUNDING_SOURCE is null)))
      AND (tlinfo.MAJOR_COURSE = X_MAJOR_COURSE)
      AND (tlinfo.COMMENCING_STUDENT_IND = X_COMMENCING_STUDENT_IND)
      AND (tlinfo.SCHOOL_LEAVER = X_SCHOOL_LEAVER)
      AND (tlinfo.NEW_TO_HIGHER_EDUCATION = X_NEW_TO_HIGHER_EDUCATION)
      AND (tlinfo.SUA_LOCATION_CD = X_SUA_LOCATION_CD)
      AND (tlinfo.UNIT_CLASS = X_UNIT_CLASS)
      AND (tlinfo.UNIT_LEVEL = X_UNIT_LEVEL)
      AND (tlinfo.ENROLLED_DT = X_ENROLLED_DT)
      AND ((tlinfo.DISCONTINUED_DT = X_DISCONTINUED_DT)
           OR ((tlinfo.DISCONTINUED_DT is null)
               AND (X_DISCONTINUED_DT is null)))
      AND (tlinfo.EFTSU = X_EFTSU)
      AND (tlinfo.WEFTSU = X_WEFTSU)
      AND ((tlinfo.UNIT_INT_COURSE_LEVEL_CD = X_UNIT_INT_COURSE_LEVEL_CD)
           OR ((tlinfo.UNIT_INT_COURSE_LEVEL_CD is null)
               AND (X_UNIT_INT_COURSE_LEVEL_CD is null)))
      AND (tlinfo.GOVT_REPORTABLE_IND = X_GOVT_REPORTABLE_IND)
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
  x_rowid IN VARCHAR2,
  X_ESS_ID in NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_REQUEST_ID  NUMBER;
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

  Before_DML(
  p_action=>'UPDATE',
  x_rowid=>X_ROWID,
  x_attendance_mode=>X_ATTENDANCE_MODE,
  x_attendance_type=>X_ATTENDANCE_TYPE,
  x_ci_cal_type=>X_CI_CAL_TYPE,
  x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
  x_commencing_student_ind=>X_COMMENCING_STUDENT_IND,
  x_course_cd=>X_COURSE_CD,
  x_course_type=>X_COURSE_TYPE,
  x_course_type_group_cd=>X_COURSE_TYPE_GROUP_CD,
  x_crv_org_unit_cd=>X_CRV_ORG_UNIT_CD,
  x_crv_ou_start_dt=>X_CRV_OU_START_DT,
  x_crv_version_number=>X_CRV_VERSION_NUMBER,
  x_discipline_group_cd=>X_DISCIPLINE_GROUP_CD,
  x_discontinued_dt=>X_DISCONTINUED_DT,
  x_eftsu=>X_EFTSU,
  x_enrolled_dt=>X_ENROLLED_DT,
  x_funding_source=>X_FUNDING_SOURCE,
  x_govt_attendance_mode=>X_GOVT_ATTENDANCE_MODE,
  x_govt_attendance_type=>X_GOVT_ATTENDANCE_TYPE,
  x_govt_course_type=>X_GOVT_COURSE_TYPE,
  x_govt_discipline_group_cd=>X_GOVT_DISCIPLINE_GROUP_CD,
  x_govt_funding_source=>X_GOVT_FUNDING_SOURCE,
  x_govt_reportable_ind=>X_GOVT_REPORTABLE_IND,
  x_major_course=>X_MAJOR_COURSE,
  x_new_to_higher_education=>X_NEW_TO_HIGHER_EDUCATION,
  x_person_id=>X_PERSON_ID,
  x_sca_location_cd=>X_SCA_LOCATION_CD,
  x_school_leaver=>X_SCHOOL_LEAVER,
  x_ESS_ID=>X_ESS_ID,
  x_snapshot_dt_time=>X_SNAPSHOT_DT_TIME,
  x_sua_cal_type=>X_SUA_CAL_TYPE,
  x_sua_ci_sequence_number=>X_SUA_CI_SEQUENCE_NUMBER,
  x_sua_location_cd=>X_SUA_LOCATION_CD,
  x_tr_org_unit_cd=>X_TR_ORG_UNIT_CD,
  x_tr_ou_start_dt=>X_TR_OU_START_DT,
  x_unit_cd=>X_UNIT_CD,
  x_unit_class=>X_UNIT_CLASS,
  x_unit_int_course_level_cd=>X_UNIT_INT_COURSE_LEVEL_CD,
  x_unit_level=>X_UNIT_LEVEL,
  x_uv_version_number=>X_UV_VERSION_NUMBER,
  x_weftsu=>X_WEFTSU,
  x_creation_date=>X_LAST_UPDATE_DATE,
  x_created_by=>X_LAST_UPDATED_BY,
  x_last_update_date=>X_LAST_UPDATE_DATE,
  x_last_updated_by=>X_LAST_UPDATED_BY,
  x_last_update_login=>X_LAST_UPDATE_LOGIN
  );


  if (X_MODE = 'R') then
	x_request_id := fnd_global.conc_request_id;
 	x_program_id := fnd_global.conc_program_id;
	x_program_application_id := fnd_global.prog_appl_id;

	if (x_request_id = -1) then
      	 	X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
      	 	X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
       		X_PROGRAM_APPLICATION_ID :=
        	    OLD_REFERENCES.PROGRAM_APPLICATION_ID;
       		X_PROGRAM_UPDATE_DATE :=
        	    OLD_REFERENCES.PROGRAM_UPDATE_DATE;
	else
	 x_program_update_date := SYSDATE;
	end if;
  end if;

  update IGS_EN_ST_SNAPSHOT set
    SNAPSHOT_DT_TIME = new_references.SNAPSHOT_DT_TIME,
    CI_CAL_TYPE = new_references.CI_CAL_TYPE,
    CI_SEQUENCE_NUMBER = new_references.CI_SEQUENCE_NUMBER,
    PERSON_ID = new_references.PERSON_ID,
    COURSE_CD = new_references.COURSE_CD,
    CRV_VERSION_NUMBER = new_references.CRV_VERSION_NUMBER,
    UNIT_CD = new_references.UNIT_CD,
    UV_VERSION_NUMBER = new_references.UV_VERSION_NUMBER,
    SUA_CAL_TYPE = new_references.SUA_CAL_TYPE,
    SUA_CI_SEQUENCE_NUMBER = new_references.SUA_CI_SEQUENCE_NUMBER,
    TR_ORG_UNIT_CD = new_references.TR_ORG_UNIT_CD,
    TR_OU_START_DT = new_references.TR_OU_START_DT,
    DISCIPLINE_GROUP_CD = new_references.DISCIPLINE_GROUP_CD,
    GOVT_DISCIPLINE_GROUP_CD = new_references.GOVT_DISCIPLINE_GROUP_CD,
    CRV_ORG_UNIT_CD = new_references.CRV_ORG_UNIT_CD,
    CRV_OU_START_DT = new_references.CRV_OU_START_DT,
    COURSE_TYPE = new_references.COURSE_TYPE,
    GOVT_COURSE_TYPE = new_references.GOVT_COURSE_TYPE,
    COURSE_TYPE_GROUP_CD = new_references.COURSE_TYPE_GROUP_CD,
    SCA_LOCATION_CD = new_references.SCA_LOCATION_CD,
    ATTENDANCE_MODE = new_references.ATTENDANCE_MODE,
    GOVT_ATTENDANCE_MODE = new_references.GOVT_ATTENDANCE_MODE,
    ATTENDANCE_TYPE = new_references.ATTENDANCE_TYPE,
    GOVT_ATTENDANCE_TYPE = new_references.GOVT_ATTENDANCE_TYPE,
    FUNDING_SOURCE = new_references.FUNDING_SOURCE,
    GOVT_FUNDING_SOURCE = new_references.GOVT_FUNDING_SOURCE,
    MAJOR_COURSE = new_references.MAJOR_COURSE,
    COMMENCING_STUDENT_IND = new_references.COMMENCING_STUDENT_IND,
    SCHOOL_LEAVER = new_references.SCHOOL_LEAVER,
    NEW_TO_HIGHER_EDUCATION = new_references.NEW_TO_HIGHER_EDUCATION,
    SUA_LOCATION_CD = new_references.SUA_LOCATION_CD,
    UNIT_CLASS = new_references.UNIT_CLASS,
    UNIT_LEVEL = new_references.UNIT_LEVEL,
    ENROLLED_DT = new_references.ENROLLED_DT,
    DISCONTINUED_DT = new_references.DISCONTINUED_DT,
    EFTSU = new_references.EFTSU,
    WEFTSU = new_references.WEFTSU,
    UNIT_INT_COURSE_LEVEL_CD = new_references.UNIT_INT_COURSE_LEVEL_CD,
    GOVT_REPORTABLE_IND = new_references.GOVT_REPORTABLE_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    REQUEST_ID =  X_REQUEST_ID,
    PROGRAM_ID =  X_PROGRAM_ID,
    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,
    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
  where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;


  After_DML(
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ESS_ID in out NOCOPY NUMBER,
  X_SNAPSHOT_DT_TIME in DATE,
  X_CI_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_UNIT_CD in VARCHAR2,
  X_UV_VERSION_NUMBER in NUMBER,
  X_SUA_CAL_TYPE in VARCHAR2,
  X_SUA_CI_SEQUENCE_NUMBER in NUMBER,
  X_TR_ORG_UNIT_CD in VARCHAR2,
  X_TR_OU_START_DT in DATE,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CRV_ORG_UNIT_CD in VARCHAR2,
  X_CRV_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_SCA_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_GOVT_FUNDING_SOURCE in NUMBER,
  X_MAJOR_COURSE in NUMBER,
  X_COMMENCING_STUDENT_IND in VARCHAR2,
  X_SCHOOL_LEAVER in NUMBER,
  X_NEW_TO_HIGHER_EDUCATION in NUMBER,
  X_SUA_LOCATION_CD in VARCHAR2,
  X_UNIT_CLASS in VARCHAR2,
  X_UNIT_LEVEL in VARCHAR2,
  X_ENROLLED_DT in DATE,
  X_DISCONTINUED_DT in DATE,
  X_EFTSU in NUMBER,
  X_WEFTSU in NUMBER,
  X_UNIT_INT_COURSE_LEVEL_CD in VARCHAR2,
  X_GOVT_REPORTABLE_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_EN_ST_SNAPSHOT
     where ESS_ID = X_ESS_ID;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ESS_ID,
     X_SNAPSHOT_DT_TIME,
     X_CI_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_PERSON_ID,
     X_COURSE_CD,
     X_CRV_VERSION_NUMBER,
     X_UNIT_CD,
     X_UV_VERSION_NUMBER,
     X_SUA_CAL_TYPE,
     X_SUA_CI_SEQUENCE_NUMBER,
     X_TR_ORG_UNIT_CD,
     X_TR_OU_START_DT,
     X_DISCIPLINE_GROUP_CD,
     X_GOVT_DISCIPLINE_GROUP_CD,
     X_CRV_ORG_UNIT_CD,
     X_CRV_OU_START_DT,
     X_COURSE_TYPE,
     X_GOVT_COURSE_TYPE,
     X_COURSE_TYPE_GROUP_CD,
     X_SCA_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_GOVT_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_GOVT_ATTENDANCE_TYPE,
     X_FUNDING_SOURCE,
     X_GOVT_FUNDING_SOURCE,
     X_MAJOR_COURSE,
     X_COMMENCING_STUDENT_IND,
     X_SCHOOL_LEAVER,
     X_NEW_TO_HIGHER_EDUCATION,
     X_SUA_LOCATION_CD,
     X_UNIT_CLASS,
     X_UNIT_LEVEL,
     X_ENROLLED_DT,
     X_DISCONTINUED_DT,
     X_EFTSU,
     X_WEFTSU,
     X_UNIT_INT_COURSE_LEVEL_CD,
     X_GOVT_REPORTABLE_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ESS_ID,
   X_SNAPSHOT_DT_TIME,
   X_CI_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_PERSON_ID,
   X_COURSE_CD,
   X_CRV_VERSION_NUMBER,
   X_UNIT_CD,
   X_UV_VERSION_NUMBER,
   X_SUA_CAL_TYPE,
   X_SUA_CI_SEQUENCE_NUMBER,
   X_TR_ORG_UNIT_CD,
   X_TR_OU_START_DT,
   X_DISCIPLINE_GROUP_CD,
   X_GOVT_DISCIPLINE_GROUP_CD,
   X_CRV_ORG_UNIT_CD,
   X_CRV_OU_START_DT,
   X_COURSE_TYPE,
   X_GOVT_COURSE_TYPE,
   X_COURSE_TYPE_GROUP_CD,
   X_SCA_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_GOVT_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_GOVT_ATTENDANCE_TYPE,
   X_FUNDING_SOURCE,
   X_GOVT_FUNDING_SOURCE,
   X_MAJOR_COURSE,
   X_COMMENCING_STUDENT_IND,
   X_SCHOOL_LEAVER,
   X_NEW_TO_HIGHER_EDUCATION,
   X_SUA_LOCATION_CD,
   X_UNIT_CLASS,
   X_UNIT_LEVEL,
   X_ENROLLED_DT,
   X_DISCONTINUED_DT,
   X_EFTSU,
   X_WEFTSU,
   X_UNIT_INT_COURSE_LEVEL_CD,
   X_GOVT_REPORTABLE_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (X_ROWID IN VARCHAR2
) AS
begin
 Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_EN_ST_SNAPSHOT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_EN_ST_SNAPSHOT_PKG;

/
