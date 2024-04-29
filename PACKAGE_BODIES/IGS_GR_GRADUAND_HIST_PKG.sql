--------------------------------------------------------
--  DDL for Package Body IGS_GR_GRADUAND_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GR_GRADUAND_HIST_PKG" as
/* $Header: IGSGI13B.pls 115.7 2003/10/07 08:21:12 ijeddy ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_GR_GRADUAND_HIST_ALL%RowType;
  new_references IGS_GR_GRADUAND_HIST_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_honours_level IN VARCHAR2 DEFAULT NULL,
    x_conferral_dt IN DATE DEFAULT NULL,
    x_graduand_status IN VARCHAR2 DEFAULT NULL,
    x_graduand_appr_status IN VARCHAR2 DEFAULT NULL,
    x_s_graduand_type IN VARCHAR2 DEFAULT NULL,
    x_graduation_name IN VARCHAR2 DEFAULT NULL,
    x_proxy_award_ind IN VARCHAR2 DEFAULT NULL,
    x_proxy_award_person_id IN NUMBER DEFAULT NULL,
    x_previous_qualifications IN VARCHAR2 DEFAULT NULL,
    x_convocation_membership_ind IN VARCHAR2 DEFAULT NULL,
    x_sur_for_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sur_for_crs_version_number IN NUMBER DEFAULT NULL,
    x_sur_for_award_cd IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GR_GRADUAND_HIST_ALL
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
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.create_dt := x_create_dt;
    new_references.hist_start_dt := x_hist_start_dt;
    new_references.hist_end_dt := x_hist_end_dt;
    new_references.hist_who := x_hist_who;
    new_references.grd_cal_type := x_grd_cal_type;
    new_references.grd_ci_sequence_number := x_grd_ci_sequence_number;
    new_references.course_cd := x_course_cd;
    new_references.award_course_cd := x_award_course_cd;
    new_references.award_crs_version_number := x_award_crs_version_number;
    new_references.award_cd := x_award_cd;
    new_references.graduand_status := x_graduand_status;
    new_references.graduand_appr_status := x_graduand_appr_status;
    new_references.s_graduand_type := x_s_graduand_type;
    new_references.graduation_name := x_graduation_name;
    new_references.proxy_award_ind := x_proxy_award_ind;
    new_references.proxy_award_person_id := x_proxy_award_person_id;
    new_references.previous_qualifications := x_previous_qualifications;
    new_references.convocation_membership_ind := x_convocation_membership_ind;
    new_references.sur_for_course_cd := x_sur_for_course_cd;
    new_references.sur_for_crs_version_number := x_sur_for_crs_version_number;
    new_references.sur_for_award_cd := x_sur_for_award_cd;
    new_references.comments := x_comments;
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

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_create_dt IN DATE,
    x_hist_start_dt IN DATE
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GR_GRADUAND_HIST_ALL
      WHERE    person_id = x_person_id
      AND      create_dt = x_create_dt
      AND      hist_start_dt = x_hist_start_dt
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

  PROCEDURE CHECK_CONSTRAINTS(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
  BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'AWARD_CD' THEN
  new_references.AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'AWARD_COURSE_CD' THEN
  new_references.AWARD_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' THEN
  new_references.CONVOCATION_MEMBERSHIP_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRADUAND_APPR_STATUS' THEN
  new_references.GRADUAND_APPR_STATUS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRADUAND_STATUS' THEN
  new_references.GRADUAND_STATUS:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'S_GRADUAND_TYPE' THEN
  new_references.S_GRADUAND_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'HIST_WHO' THEN
  new_references.HIST_WHO:= COLUMN_VALUE ;


ELSIF upper(Column_name) = 'PROXY_AWARD_IND' THEN
  new_references.PROXY_AWARD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SUR_FOR_AWARD_CD' THEN
  new_references.SUR_FOR_AWARD_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SUR_FOR_COURSE_CD' THEN
  new_references.SUR_FOR_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'GRD_CAL_TYPE' THEN
  new_references.GRD_CAL_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PERSON_ID' THEN
  new_references.PERSON_ID:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' THEN
  new_references.GRD_CI_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'AWARD_CRS_VERSION_NUMBER' THEN
  new_references.AWARD_CRS_VERSION_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'S_GRADUAND_TYPE' THEN
  new_references.S_GRADUAND_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROXY_AWARD_IND' THEN
  new_references.PROXY_AWARD_IND:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROXY_AWARD_PERSON_ID' THEN
  new_references.PROXY_AWARD_PERSON_ID:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' THEN
  new_references.CONVOCATION_MEMBERSHIP_IND:= COLUMN_VALUE ;

END IF ;

IF upper(Column_name) = 'AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_CD<> upper(new_references.AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_COURSE_CD<> upper(new_references.AWARD_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CONVOCATION_MEMBERSHIP_IND<> upper(new_references.CONVOCATION_MEMBERSHIP_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRADUAND_APPR_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRADUAND_APPR_STATUS<> upper(new_references.GRADUAND_APPR_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRADUAND_STATUS' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRADUAND_STATUS<> upper(new_references.GRADUAND_STATUS) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_GRADUAND_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_GRADUAND_TYPE<> upper(new_references.S_GRADUAND_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'HIST_WHO' OR COLUMN_NAME IS NULL THEN
  IF new_references.HIST_WHO<> upper(new_references.HIST_WHO) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'PROXY_AWARD_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROXY_AWARD_IND<> upper(new_references.PROXY_AWARD_IND) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SUR_FOR_AWARD_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUR_FOR_AWARD_CD<> upper(new_references.SUR_FOR_AWARD_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SUR_FOR_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SUR_FOR_COURSE_CD<> upper(new_references.SUR_FOR_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CAL_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CAL_TYPE<> upper(new_references.GRD_CAL_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PERSON_ID' OR COLUMN_NAME IS NULL THEN
  IF new_references.PERSON_ID < 0 OR new_references.PERSON_ID > 9999999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'GRD_CI_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.GRD_CI_SEQUENCE_NUMBER < 1 OR new_references.GRD_CI_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'AWARD_CRS_VERSION_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.AWARD_CRS_VERSION_NUMBER < 0 OR new_references.AWARD_CRS_VERSION_NUMBER > 999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_GRADUAND_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_GRADUAND_TYPE not in  ( 'ATTENDING' , 'INABSENTIA' , 'ARTICULATE' , 'DEFERRED' , 'UNKNOWN' , 'DECLINED' ) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;
END IF ;

IF upper(Column_name) = 'PROXY_AWARD_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROXY_AWARD_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROXY_AWARD_PERSON_ID' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROXY_AWARD_PERSON_ID < 0 or new_references.PROXY_AWARD_PERSON_ID > 9999999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CONVOCATION_MEMBERSHIP_IND' OR COLUMN_NAME IS NULL THEN
  IF new_references.CONVOCATION_MEMBERSHIP_IND not in  ('Y','N') then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    App_Exception.Raise_Exception ;
  END IF;

END IF ;
  END CHECK_CONSTRAINTS;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_hist_start_dt IN DATE DEFAULT NULL,
    x_hist_end_dt IN DATE DEFAULT NULL,
    x_hist_who IN NUMBER DEFAULT NULL,
    x_grd_cal_type IN VARCHAR2 DEFAULT NULL,
    x_grd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_course_cd IN VARCHAR2 DEFAULT NULL,
    x_award_crs_version_number IN NUMBER DEFAULT NULL,
    x_award_cd IN VARCHAR2 DEFAULT NULL,
    x_honours_level IN VARCHAR2 DEFAULT NULL,
    x_conferral_dt IN DATE DEFAULT NULL,
    x_graduand_status IN VARCHAR2 DEFAULT NULL,
    x_graduand_appr_status IN VARCHAR2 DEFAULT NULL,
    x_s_graduand_type IN VARCHAR2 DEFAULT NULL,
    x_graduation_name IN VARCHAR2 DEFAULT NULL,
    x_proxy_award_ind IN VARCHAR2 DEFAULT NULL,
    x_proxy_award_person_id IN NUMBER DEFAULT NULL,
    x_previous_qualifications IN VARCHAR2 DEFAULT NULL,
    x_convocation_membership_ind IN VARCHAR2 DEFAULT NULL,
    x_sur_for_course_cd IN VARCHAR2 DEFAULT NULL,
    x_sur_for_crs_version_number IN NUMBER DEFAULT NULL,
    x_sur_for_award_cd IN VARCHAR2 DEFAULT NULL,
    x_comments IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id,
      x_create_dt,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_grd_cal_type,
      x_grd_ci_sequence_number,
      x_course_cd,
      x_award_course_cd,
      x_award_crs_version_number,
      x_award_cd,
      null,
      null,
      x_graduand_status,
      x_graduand_appr_status,
      x_s_graduand_type,
      x_graduation_name,
      x_proxy_award_ind,
      x_proxy_award_person_id,
      x_previous_qualifications,
      x_convocation_membership_ind,
      x_sur_for_course_cd,
      x_sur_for_crs_version_number,
      x_sur_for_award_cd,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF GET_PK_FOR_VALIDATION(
	    NEW_REFERENCES.person_id,
	    NEW_REFERENCES.create_dt,
	    NEW_REFERENCES.hist_start_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

	check_constraints;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF GET_PK_FOR_VALIDATION(
	    NEW_REFERENCES.person_id,
	    NEW_REFERENCES.create_dt,
	    NEW_REFERENCES.hist_start_dt
		) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		App_Exception.Raise_Exception;
	END IF;

	check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN

	check_constraints;
    END IF;

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_GR_GRADUAND_HIST_ALL
      where PERSON_ID = X_PERSON_ID
      and CREATE_DT = X_CREATE_DT
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_course_cd => X_COURSE_CD,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_graduand_status => NVL(X_GRADUAND_STATUS, 'POTENTIAL'),
    x_graduand_appr_status => NVL(X_GRADUAND_APPR_STATUS, 'WAITING'),
    x_s_graduand_type => NVL(X_S_GRADUAND_TYPE, 'UNKNOWN'),
    x_graduation_name => X_GRADUATION_NAME,
    x_proxy_award_ind => NVL(X_PROXY_AWARD_IND, 'N'),
    x_proxy_award_person_id => X_PROXY_AWARD_PERSON_ID,
    x_previous_qualifications => X_PREVIOUS_QUALIFICATIONS,
    x_convocation_membership_ind => NVL(X_CONVOCATION_MEMBERSHIP_IND, 'N'),
    x_sur_for_course_cd => X_SUR_FOR_COURSE_CD,
    x_sur_for_crs_version_number => X_SUR_FOR_CRS_VERSION_NUMBER,
    x_sur_for_award_cd => X_SUR_FOR_AWARD_CD,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN,
     x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_GR_GRADUAND_HIST_ALL (
    PERSON_ID,
    CREATE_DT,
    HIST_START_DT,
    HIST_END_DT,
    HIST_WHO,
    GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER,
    COURSE_CD,
    AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER,
    AWARD_CD,
    GRADUAND_STATUS,
    GRADUAND_APPR_STATUS,
    S_GRADUAND_TYPE,
    GRADUATION_NAME,
    PROXY_AWARD_IND,
    PROXY_AWARD_PERSON_ID,
    PREVIOUS_QUALIFICATIONS,
    CONVOCATION_MEMBERSHIP_IND,
    SUR_FOR_COURSE_CD,
    SUR_FOR_CRS_VERSION_NUMBER,
    SUR_FOR_AWARD_CD,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.HIST_START_DT,
    NEW_REFERENCES.HIST_END_DT,
    NEW_REFERENCES.HIST_WHO,
    NEW_REFERENCES.GRD_CAL_TYPE,
    NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.AWARD_COURSE_CD,
    NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    NEW_REFERENCES.AWARD_CD,
    NEW_REFERENCES.GRADUAND_STATUS,
    NEW_REFERENCES.GRADUAND_APPR_STATUS,
    NEW_REFERENCES.S_GRADUAND_TYPE,
    NEW_REFERENCES.GRADUATION_NAME,
    NEW_REFERENCES.PROXY_AWARD_IND,
    NEW_REFERENCES.PROXY_AWARD_PERSON_ID,
    NEW_REFERENCES.PREVIOUS_QUALIFICATIONS,
    NEW_REFERENCES.CONVOCATION_MEMBERSHIP_IND,
    NEW_REFERENCES.SUR_FOR_COURSE_CD,
    NEW_REFERENCES.SUR_FOR_CRS_VERSION_NUMBER,
    NEW_REFERENCES.SUR_FOR_AWARD_CD,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_CREATE_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      HIST_END_DT,
      HIST_WHO,
      GRD_CAL_TYPE,
      GRD_CI_SEQUENCE_NUMBER,
      COURSE_CD,
      AWARD_COURSE_CD,
      AWARD_CRS_VERSION_NUMBER,
      AWARD_CD,
      GRADUAND_STATUS,
      GRADUAND_APPR_STATUS,
      S_GRADUAND_TYPE,
      GRADUATION_NAME,
      PROXY_AWARD_IND,
      PROXY_AWARD_PERSON_ID,
      PREVIOUS_QUALIFICATIONS,
      CONVOCATION_MEMBERSHIP_IND,
      SUR_FOR_COURSE_CD,
      SUR_FOR_CRS_VERSION_NUMBER,
      SUR_FOR_AWARD_CD,
      COMMENTS
    from IGS_GR_GRADUAND_HIST_ALL
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

  if ( (tlinfo.HIST_END_DT = X_HIST_END_DT)
      AND (tlinfo.HIST_WHO = X_HIST_WHO)
      AND ((tlinfo.GRD_CAL_TYPE = X_GRD_CAL_TYPE)
           OR ((tlinfo.GRD_CAL_TYPE is null)
               AND (X_GRD_CAL_TYPE is null)))
      AND ((tlinfo.GRD_CI_SEQUENCE_NUMBER = X_GRD_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.GRD_CI_SEQUENCE_NUMBER is null)
               AND (X_GRD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.AWARD_COURSE_CD = X_AWARD_COURSE_CD)
           OR ((tlinfo.AWARD_COURSE_CD is null)
               AND (X_AWARD_COURSE_CD is null)))
      AND ((tlinfo.AWARD_CRS_VERSION_NUMBER = X_AWARD_CRS_VERSION_NUMBER)
           OR ((tlinfo.AWARD_CRS_VERSION_NUMBER is null)
               AND (X_AWARD_CRS_VERSION_NUMBER is null)))
      AND ((tlinfo.AWARD_CD = X_AWARD_CD)
           OR ((tlinfo.AWARD_CD is null)
               AND (X_AWARD_CD is null)))
      AND ((tlinfo.GRADUAND_STATUS = X_GRADUAND_STATUS)
           OR ((tlinfo.GRADUAND_STATUS is null)
               AND (X_GRADUAND_STATUS is null)))
      AND ((tlinfo.GRADUAND_APPR_STATUS = X_GRADUAND_APPR_STATUS)
           OR ((tlinfo.GRADUAND_APPR_STATUS is null)
               AND (X_GRADUAND_APPR_STATUS is null)))
      AND ((tlinfo.S_GRADUAND_TYPE = X_S_GRADUAND_TYPE)
           OR ((tlinfo.S_GRADUAND_TYPE is null)
               AND (X_S_GRADUAND_TYPE is null)))
      AND ((tlinfo.GRADUATION_NAME = X_GRADUATION_NAME)
           OR ((tlinfo.GRADUATION_NAME is null)
               AND (X_GRADUATION_NAME is null)))
      AND ((tlinfo.PROXY_AWARD_IND = X_PROXY_AWARD_IND)
           OR ((tlinfo.PROXY_AWARD_IND is null)
               AND (X_PROXY_AWARD_IND is null)))
      AND ((tlinfo.PROXY_AWARD_PERSON_ID = X_PROXY_AWARD_PERSON_ID)
           OR ((tlinfo.PROXY_AWARD_PERSON_ID is null)
               AND (X_PROXY_AWARD_PERSON_ID is null)))
      AND ((tlinfo.PREVIOUS_QUALIFICATIONS = X_PREVIOUS_QUALIFICATIONS)
           OR ((tlinfo.PREVIOUS_QUALIFICATIONS is null)
               AND (X_PREVIOUS_QUALIFICATIONS is null)))
      AND ((tlinfo.CONVOCATION_MEMBERSHIP_IND = X_CONVOCATION_MEMBERSHIP_IND)
           OR ((tlinfo.CONVOCATION_MEMBERSHIP_IND is null)
               AND (X_CONVOCATION_MEMBERSHIP_IND is null)))
      AND ((tlinfo.SUR_FOR_COURSE_CD = X_SUR_FOR_COURSE_CD)
           OR ((tlinfo.SUR_FOR_COURSE_CD is null)
               AND (X_SUR_FOR_COURSE_CD is null)))
      AND ((tlinfo.SUR_FOR_CRS_VERSION_NUMBER = X_SUR_FOR_CRS_VERSION_NUMBER)
           OR ((tlinfo.SUR_FOR_CRS_VERSION_NUMBER is null)
               AND (X_SUR_FOR_CRS_VERSION_NUMBER is null)))
      AND ((tlinfo.SUR_FOR_AWARD_CD = X_SUR_FOR_AWARD_CD)
           OR ((tlinfo.SUR_FOR_AWARD_CD is null)
               AND (X_SUR_FOR_AWARD_CD is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))

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
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
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
    app_exception.raise_exception;
  end if;

 Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
    x_person_id => X_PERSON_ID,
    x_create_dt => X_CREATE_DT,
    x_hist_start_dt => X_HIST_START_DT,
    x_hist_end_dt => X_HIST_END_DT,
    x_hist_who => X_HIST_WHO,
    x_grd_cal_type => X_GRD_CAL_TYPE,
    x_grd_ci_sequence_number => X_GRD_CI_SEQUENCE_NUMBER,
    x_course_cd => X_COURSE_CD,
    x_award_course_cd => X_AWARD_COURSE_CD,
    x_award_crs_version_number => X_AWARD_CRS_VERSION_NUMBER,
    x_award_cd => X_AWARD_CD,
    x_graduand_status => X_GRADUAND_STATUS,
    x_graduand_appr_status => X_GRADUAND_APPR_STATUS,
    x_s_graduand_type => X_S_GRADUAND_TYPE,
    x_graduation_name => X_GRADUATION_NAME,
    x_proxy_award_ind => X_PROXY_AWARD_IND,
    x_proxy_award_person_id => X_PROXY_AWARD_PERSON_ID,
    x_previous_qualifications => X_PREVIOUS_QUALIFICATIONS,
    x_convocation_membership_ind => X_CONVOCATION_MEMBERSHIP_IND,
    x_sur_for_course_cd => X_SUR_FOR_COURSE_CD,
    x_sur_for_crs_version_number => X_SUR_FOR_CRS_VERSION_NUMBER,
    x_sur_for_award_cd => X_SUR_FOR_AWARD_CD,
    x_comments => X_COMMENTS,
    x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_GR_GRADUAND_HIST_ALL set
    HIST_END_DT = NEW_REFERENCES.HIST_END_DT,
    HIST_WHO = NEW_REFERENCES.HIST_WHO,
    GRD_CAL_TYPE = NEW_REFERENCES.GRD_CAL_TYPE,
    GRD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.GRD_CI_SEQUENCE_NUMBER,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    AWARD_COURSE_CD = NEW_REFERENCES.AWARD_COURSE_CD,
    AWARD_CRS_VERSION_NUMBER = NEW_REFERENCES.AWARD_CRS_VERSION_NUMBER,
    AWARD_CD = NEW_REFERENCES.AWARD_CD,
    GRADUAND_STATUS = NEW_REFERENCES.GRADUAND_STATUS,
    GRADUAND_APPR_STATUS = NEW_REFERENCES.GRADUAND_APPR_STATUS,
    S_GRADUAND_TYPE = NEW_REFERENCES.S_GRADUAND_TYPE,
    GRADUATION_NAME = NEW_REFERENCES.GRADUATION_NAME,
    PROXY_AWARD_IND = NEW_REFERENCES.PROXY_AWARD_IND,
    PROXY_AWARD_PERSON_ID = NEW_REFERENCES.PROXY_AWARD_PERSON_ID,
    PREVIOUS_QUALIFICATIONS = NEW_REFERENCES.PREVIOUS_QUALIFICATIONS,
    CONVOCATION_MEMBERSHIP_IND = NEW_REFERENCES.CONVOCATION_MEMBERSHIP_IND,
    SUR_FOR_COURSE_CD = NEW_REFERENCES.SUR_FOR_COURSE_CD,
    SUR_FOR_CRS_VERSION_NUMBER = NEW_REFERENCES.SUR_FOR_CRS_VERSION_NUMBER,
    SUR_FOR_AWARD_CD = NEW_REFERENCES.SUR_FOR_AWARD_CD,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_CREATE_DT in DATE,
  X_HIST_START_DT in DATE,
  X_HIST_END_DT in DATE,
  X_HIST_WHO in NUMBER,
  X_GRD_CAL_TYPE in VARCHAR2,
  X_GRD_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_AWARD_COURSE_CD in VARCHAR2,
  X_AWARD_CRS_VERSION_NUMBER in NUMBER,
  X_AWARD_CD in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2 DEFAULT NULL,
  X_CONFERRAL_DT in DATE DEFAULT NULL,
  X_GRADUAND_STATUS in VARCHAR2,
  X_GRADUAND_APPR_STATUS in VARCHAR2,
  X_S_GRADUAND_TYPE in VARCHAR2,
  X_GRADUATION_NAME in VARCHAR2,
  X_PROXY_AWARD_IND in VARCHAR2,
  X_PROXY_AWARD_PERSON_ID in NUMBER,
  X_PREVIOUS_QUALIFICATIONS in VARCHAR2,
  X_CONVOCATION_MEMBERSHIP_IND in VARCHAR2,
  X_SUR_FOR_COURSE_CD in VARCHAR2,
  X_SUR_FOR_CRS_VERSION_NUMBER in NUMBER,
  X_SUR_FOR_AWARD_CD in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_GR_GRADUAND_HIST_ALL
     where PERSON_ID = X_PERSON_ID
     and CREATE_DT = X_CREATE_DT
     and HIST_START_DT = X_HIST_START_DT
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_CREATE_DT,
     X_HIST_START_DT,
     X_HIST_END_DT,
     X_HIST_WHO,
     X_GRD_CAL_TYPE,
     X_GRD_CI_SEQUENCE_NUMBER,
     X_COURSE_CD,
     X_AWARD_COURSE_CD,
     X_AWARD_CRS_VERSION_NUMBER,
     X_AWARD_CD,
     null,
     null,
     X_GRADUAND_STATUS,
     X_GRADUAND_APPR_STATUS,
     X_S_GRADUAND_TYPE,
     X_GRADUATION_NAME,
     X_PROXY_AWARD_IND,
     X_PROXY_AWARD_PERSON_ID,
     X_PREVIOUS_QUALIFICATIONS,
     X_CONVOCATION_MEMBERSHIP_IND,
     X_SUR_FOR_COURSE_CD,
     X_SUR_FOR_CRS_VERSION_NUMBER,
     X_SUR_FOR_AWARD_CD,
     X_COMMENTS,
     X_MODE,
     x_org_id
);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_CREATE_DT,
   X_HIST_START_DT,
   X_HIST_END_DT,
   X_HIST_WHO,
   X_GRD_CAL_TYPE,
   X_GRD_CI_SEQUENCE_NUMBER,
   X_COURSE_CD,
   X_AWARD_COURSE_CD,
   X_AWARD_CRS_VERSION_NUMBER,
   X_AWARD_CD,
   null,
   null,
   X_GRADUAND_STATUS,
   X_GRADUAND_APPR_STATUS,
   X_S_GRADUAND_TYPE,
   X_GRADUATION_NAME,
   X_PROXY_AWARD_IND,
   X_PROXY_AWARD_PERSON_ID,
   X_PREVIOUS_QUALIFICATIONS,
   X_CONVOCATION_MEMBERSHIP_IND,
   X_SUR_FOR_COURSE_CD,
   X_SUR_FOR_CRS_VERSION_NUMBER,
   X_SUR_FOR_AWARD_CD,
   X_COMMENTS,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin

  delete from IGS_GR_GRADUAND_HIST_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end DELETE_ROW;

end IGS_GR_GRADUAND_HIST_PKG;

/
