--------------------------------------------------------
--  DDL for Package Body IGS_ST_GOVT_STDNT_EN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_ST_GOVT_STDNT_EN_PKG" as
/* $Header: IGSVI10B.pls 115.4 2002/11/29 04:33:14 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_ST_GOVT_STDNT_EN%RowType;
  new_references IGS_ST_GOVT_STDNT_EN%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_birth_dt IN DATE DEFAULT NULL,
    x_sex IN VARCHAR2 DEFAULT NULL,
    x_aborig_torres_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_aborig_torres_cd IN NUMBER DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_perm_resident_cd IN NUMBER DEFAULT NULL,
    x_home_location IN VARCHAR2 DEFAULT NULL,
    x_govt_home_location IN VARCHAR2 DEFAULT NULL,
    x_term_location IN VARCHAR2 DEFAULT NULL,
    x_govt_term_location IN VARCHAR2 DEFAULT NULL,
    x_birth_country_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_birth_country_cd IN VARCHAR2 DEFAULT NULL,
    x_yr_arrival IN VARCHAR2 DEFAULT NULL,
    x_home_language_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_home_language_cd IN NUMBER DEFAULT NULL,
    x_prior_ug_inst IN VARCHAR2 DEFAULT NULL,
    x_govt_prior_ug_inst IN VARCHAR2 DEFAULT NULL,
    x_prior_other_qual IN VARCHAR2 DEFAULT NULL,
    x_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_prior_subdeg_notafe IN VARCHAR2 DEFAULT NULL,
    x_prior_subdeg_tafe IN VARCHAR2 DEFAULT NULL,
    x_prior_seced_tafe IN VARCHAR2 DEFAULT NULL,
    x_prior_seced_school IN VARCHAR2 DEFAULT NULL,
    x_prior_tafe_award IN VARCHAR2 DEFAULT NULL,
    x_prior_studies_exemption IN NUMBER DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_exempt_institu_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_major_course IN NUMBER DEFAULT NULL,
    x_tertiary_entrance_score IN NUMBER DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_govt_basis_for_adm_type IN VARCHAR2 DEFAULT NULL,
    x_govt_disability IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_ST_GOVT_STDNT_EN
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND p_action NOT IN ('INSERT','VALIDATE_INSERT') THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.submission_yr := x_submission_yr;
    new_references.submission_number := x_submission_number;
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.birth_dt := x_birth_dt;
    new_references.sex := x_sex;
    new_references.aborig_torres_cd := x_aborig_torres_cd;
    new_references.govt_aborig_torres_cd := x_govt_aborig_torres_cd;
    new_references.citizenship_cd := x_citizenship_cd;
    new_references.govt_citizenship_cd := x_govt_citizenship_cd;
    new_references.perm_resident_cd := x_perm_resident_cd;
    new_references.govt_perm_resident_cd := x_govt_perm_resident_cd;
    new_references.home_location := x_home_location;
    new_references.govt_home_location := x_govt_home_location;
    new_references.term_location := x_term_location;
    new_references.govt_term_location := x_govt_term_location;
    new_references.birth_country_cd := x_birth_country_cd;
    new_references.govt_birth_country_cd := x_govt_birth_country_cd;
    new_references.yr_arrival := x_yr_arrival;
    new_references.home_language_cd := x_home_language_cd;
    new_references.govt_home_language_cd := x_govt_home_language_cd;
    new_references.prior_ug_inst := x_prior_ug_inst;
    new_references.govt_prior_ug_inst := x_govt_prior_ug_inst;
    new_references.prior_other_qual := x_prior_other_qual;
    new_references.prior_post_grad := x_prior_post_grad;
    new_references.prior_degree := x_prior_degree;
    new_references.prior_subdeg_notafe := x_prior_subdeg_notafe;
    new_references.prior_subdeg_tafe := x_prior_subdeg_tafe;
    new_references.prior_seced_tafe := x_prior_seced_tafe;
    new_references.prior_seced_school := x_prior_seced_school;
    new_references.prior_tafe_award := x_prior_tafe_award;
    new_references.prior_studies_exemption := x_prior_studies_exemption;
    new_references.exemption_institution_cd := x_exemption_institution_cd;
    new_references.govt_exemption_institution_cd := x_govt_exempt_institu_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.govt_attendance_mode := x_govt_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.govt_attendance_type := x_govt_attendance_type;
    new_references.commencement_dt := x_commencement_dt;
    new_references.major_course := x_major_course;
    new_references.tertiary_entrance_score := x_tertiary_entrance_score;
    new_references.basis_for_admission_type := x_basis_for_admission_type;
    new_references.govt_basis_for_admission_type := x_govt_basis_for_adm_type;
    new_references.govt_disability := x_govt_disability;
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
    ) AS
	v_message_name VARCHAR2(30);
	v_transaction_type		VARCHAR2(11);
	v_submission_yr		IGS_ST_GOVT_STDNT_EN.submission_yr%TYPE;
	v_submission_number	IGS_ST_GOVT_STDNT_EN.submission_number%TYPE;
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
		Fnd_Message.Set_Name('IGS', v_message_name);
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE Check_Parent_Existance AS
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
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

function Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GOVT_STDNT_EN
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      person_id = x_person_id
      AND      course_cd = x_course_cd
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

  PROCEDURE get_fk_igs_st_gvt_spsht_ctl (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_ST_GOVT_STDNT_EN
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_ST_GSE_GSC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END get_fk_igs_st_gvt_spsht_ctl;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_birth_dt IN DATE DEFAULT NULL,
    x_sex IN VARCHAR2 DEFAULT NULL,
    x_aborig_torres_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_aborig_torres_cd IN NUMBER DEFAULT NULL,
    x_citizenship_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_citizenship_cd IN NUMBER DEFAULT NULL,
    x_perm_resident_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_perm_resident_cd IN NUMBER DEFAULT NULL,
    x_home_location IN VARCHAR2 DEFAULT NULL,
    x_govt_home_location IN VARCHAR2 DEFAULT NULL,
    x_term_location IN VARCHAR2 DEFAULT NULL,
    x_govt_term_location IN VARCHAR2 DEFAULT NULL,
    x_birth_country_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_birth_country_cd IN VARCHAR2 DEFAULT NULL,
    x_yr_arrival IN VARCHAR2 DEFAULT NULL,
    x_home_language_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_home_language_cd IN NUMBER DEFAULT NULL,
    x_prior_ug_inst IN VARCHAR2 DEFAULT NULL,
    x_govt_prior_ug_inst IN VARCHAR2 DEFAULT NULL,
    x_prior_other_qual IN VARCHAR2 DEFAULT NULL,
    x_prior_post_grad IN VARCHAR2 DEFAULT NULL,
    x_prior_degree IN VARCHAR2 DEFAULT NULL,
    x_prior_subdeg_notafe IN VARCHAR2 DEFAULT NULL,
    x_prior_subdeg_tafe IN VARCHAR2 DEFAULT NULL,
    x_prior_seced_tafe IN VARCHAR2 DEFAULT NULL,
    x_prior_seced_school IN VARCHAR2 DEFAULT NULL,
    x_prior_tafe_award IN VARCHAR2 DEFAULT NULL,
    x_prior_studies_exemption IN NUMBER DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_govt_exempt_institu_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_govt_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt IN DATE DEFAULT NULL,
    x_major_course IN NUMBER DEFAULT NULL,
    x_tertiary_entrance_score IN NUMBER DEFAULT NULL,
    x_basis_for_admission_type IN VARCHAR2 DEFAULT NULL,
    x_govt_basis_for_adm_type IN VARCHAR2 DEFAULT NULL,
    x_govt_disability IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_version_number,
      x_birth_dt,
      x_sex,
      x_aborig_torres_cd,
      x_govt_aborig_torres_cd,
      x_citizenship_cd,
      x_govt_citizenship_cd,
      x_perm_resident_cd,
      x_govt_perm_resident_cd,
      x_home_location,
      x_govt_home_location,
      x_term_location,
      x_govt_term_location,
      x_birth_country_cd,
      x_govt_birth_country_cd,
      x_yr_arrival,
      x_home_language_cd,
      x_govt_home_language_cd,
      x_prior_ug_inst,
      x_govt_prior_ug_inst,
      x_prior_other_qual,
      x_prior_post_grad,
      x_prior_degree,
      x_prior_subdeg_notafe,
      x_prior_subdeg_tafe,
      x_prior_seced_tafe,
      x_prior_seced_school,
      x_prior_tafe_award,
      x_prior_studies_exemption,
      x_exemption_institution_cd,
      x_govt_exempt_institu_cd,
      x_attendance_mode,
      x_govt_attendance_mode,
      x_attendance_type,
      x_govt_attendance_type,
      x_commencement_dt,
      x_major_course,
      x_tertiary_entrance_score,
      x_basis_for_admission_type,
      x_govt_basis_for_adm_type,
      x_govt_disability,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.submission_yr,
		new_references.submission_number,
		new_references.person_id,
		new_references.course_cd
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Null;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
	Null;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.submission_yr,
		new_references.submission_number,
		new_references.person_id,
		new_references.course_cd
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
	        IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Null;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Null;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_ABORIG_TORRES_CD in VARCHAR2,
  X_GOVT_ABORIG_TORRES_CD in NUMBER,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_HOME_LOCATION in VARCHAR2,
  X_GOVT_HOME_LOCATION in VARCHAR2,
  X_TERM_LOCATION in VARCHAR2,
  X_GOVT_TERM_LOCATION in VARCHAR2,
  X_BIRTH_COUNTRY_CD in VARCHAR2,
  X_GOVT_BIRTH_COUNTRY_CD in VARCHAR2,
  X_YR_ARRIVAL in VARCHAR2,
  X_HOME_LANGUAGE_CD in VARCHAR2,
  X_GOVT_HOME_LANGUAGE_CD in NUMBER,
  X_PRIOR_UG_INST in VARCHAR2,
  X_GOVT_PRIOR_UG_INST in VARCHAR2,
  X_PRIOR_OTHER_QUAL in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_SUBDEG_NOTAFE in VARCHAR2,
  X_PRIOR_SUBDEG_TAFE in VARCHAR2,
  X_PRIOR_SECED_TAFE in VARCHAR2,
  X_PRIOR_SECED_SCHOOL in VARCHAR2,
  X_PRIOR_TAFE_AWARD in VARCHAR2,
  X_PRIOR_STUDIES_EXEMPTION in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GOVT_EXEMPT_INSTITU_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_MAJOR_COURSE in NUMBER,
  X_TERTIARY_ENTRANCE_SCORE in NUMBER,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_GOVT_DISABILITY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_ST_GOVT_STDNT_EN
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD;
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
     x_course_cd => X_COURSE_CD,
     x_version_number => X_VERSION_NUMBER,
     x_birth_dt => X_BIRTH_DT,
     x_sex => X_SEX,
     x_aborig_torres_cd => X_ABORIG_TORRES_CD,
     x_govt_aborig_torres_cd => X_GOVT_ABORIG_TORRES_CD,
     x_citizenship_cd => X_CITIZENSHIP_CD,
     x_govt_citizenship_cd => X_GOVT_CITIZENSHIP_CD,
     x_perm_resident_cd => X_PERM_RESIDENT_CD,
     x_govt_perm_resident_cd => X_GOVT_PERM_RESIDENT_CD,
     x_home_location => X_HOME_LOCATION,
     x_govt_home_location => X_GOVT_HOME_LOCATION,
     x_term_location => X_TERM_LOCATION,
     x_govt_term_location => X_GOVT_TERM_LOCATION,
     x_birth_country_cd => X_BIRTH_COUNTRY_CD,
     x_govt_birth_country_cd => X_GOVT_BIRTH_COUNTRY_CD,
     x_yr_arrival => X_YR_ARRIVAL,
     x_home_language_cd => X_HOME_LANGUAGE_CD,
     x_govt_home_language_cd => X_GOVT_HOME_LANGUAGE_CD,
     x_prior_ug_inst => X_PRIOR_UG_INST,
     x_govt_prior_ug_inst => X_GOVT_PRIOR_UG_INST,
     x_prior_other_qual => X_PRIOR_OTHER_QUAL,
     x_prior_post_grad => X_PRIOR_POST_GRAD,
     x_prior_degree => X_PRIOR_DEGREE,
     x_prior_subdeg_notafe => X_PRIOR_SUBDEG_NOTAFE,
     x_prior_subdeg_tafe => X_PRIOR_SUBDEG_TAFE,
     x_prior_seced_tafe => X_PRIOR_SECED_TAFE,
     x_prior_seced_school => X_PRIOR_SECED_SCHOOL,
     x_prior_tafe_award => X_PRIOR_TAFE_AWARD,
     x_prior_studies_exemption => X_PRIOR_STUDIES_EXEMPTION,
     x_exemption_institution_cd => X_EXEMPTION_INSTITUTION_CD,
     x_govt_exempt_institu_cd => X_GOVT_EXEMPT_INSTITU_CD,
     x_attendance_mode => X_ATTENDANCE_MODE,
     x_govt_attendance_mode => X_GOVT_ATTENDANCE_MODE,
     x_attendance_type => X_ATTENDANCE_TYPE,
     x_govt_attendance_type => X_GOVT_ATTENDANCE_TYPE,
     x_commencement_dt => X_COMMENCEMENT_DT,
     x_major_course => X_MAJOR_COURSE,
     x_tertiary_entrance_score => X_TERTIARY_ENTRANCE_SCORE,
     x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
     x_govt_basis_for_adm_type => X_GOVT_BASIS_FOR_ADM_TYPE,
     x_govt_disability => X_GOVT_DISABILITY,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_ST_GOVT_STDNT_EN (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    PERSON_ID,
    COURSE_CD,
    VERSION_NUMBER,
    BIRTH_DT,
    SEX,
    ABORIG_TORRES_CD,
    GOVT_ABORIG_TORRES_CD,
    CITIZENSHIP_CD,
    GOVT_CITIZENSHIP_CD,
    PERM_RESIDENT_CD,
    GOVT_PERM_RESIDENT_CD,
    HOME_LOCATION,
    GOVT_HOME_LOCATION,
    TERM_LOCATION,
    GOVT_TERM_LOCATION,
    BIRTH_COUNTRY_CD,
    GOVT_BIRTH_COUNTRY_CD,
    YR_ARRIVAL,
    HOME_LANGUAGE_CD,
    GOVT_HOME_LANGUAGE_CD,
    PRIOR_UG_INST,
    GOVT_PRIOR_UG_INST,
    PRIOR_OTHER_QUAL,
    PRIOR_POST_GRAD,
    PRIOR_DEGREE,
    PRIOR_SUBDEG_NOTAFE,
    PRIOR_SUBDEG_TAFE,
    PRIOR_SECED_TAFE,
    PRIOR_SECED_SCHOOL,
    PRIOR_TAFE_AWARD,
    PRIOR_STUDIES_EXEMPTION,
    EXEMPTION_INSTITUTION_CD,
    GOVT_EXEMPTION_INSTITUTION_CD,
    ATTENDANCE_MODE,
    GOVT_ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    GOVT_ATTENDANCE_TYPE,
    COMMENCEMENT_DT,
    MAJOR_COURSE,
    TERTIARY_ENTRANCE_SCORE,
    BASIS_FOR_ADMISSION_TYPE,
    GOVT_BASIS_FOR_ADMISSION_TYPE,
    GOVT_DISABILITY,
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
    NEW_REFERENCES.BIRTH_DT,
    NEW_REFERENCES.SEX,
    NEW_REFERENCES.ABORIG_TORRES_CD,
    NEW_REFERENCES.GOVT_ABORIG_TORRES_CD,
    NEW_REFERENCES.CITIZENSHIP_CD,
    NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    NEW_REFERENCES.PERM_RESIDENT_CD,
    NEW_REFERENCES.GOVT_PERM_RESIDENT_CD,
    NEW_REFERENCES.HOME_LOCATION,
    NEW_REFERENCES.GOVT_HOME_LOCATION,
    NEW_REFERENCES.TERM_LOCATION,
    NEW_REFERENCES.GOVT_TERM_LOCATION,
    NEW_REFERENCES.BIRTH_COUNTRY_CD,
    NEW_REFERENCES.GOVT_BIRTH_COUNTRY_CD,
    NEW_REFERENCES.YR_ARRIVAL,
    NEW_REFERENCES.HOME_LANGUAGE_CD,
    NEW_REFERENCES.GOVT_HOME_LANGUAGE_CD,
    NEW_REFERENCES.PRIOR_UG_INST,
    NEW_REFERENCES.GOVT_PRIOR_UG_INST,
    NEW_REFERENCES.PRIOR_OTHER_QUAL,
    NEW_REFERENCES.PRIOR_POST_GRAD,
    NEW_REFERENCES.PRIOR_DEGREE,
    NEW_REFERENCES.PRIOR_SUBDEG_NOTAFE,
    NEW_REFERENCES.PRIOR_SUBDEG_TAFE,
    NEW_REFERENCES.PRIOR_SECED_TAFE,
    NEW_REFERENCES.PRIOR_SECED_SCHOOL,
    NEW_REFERENCES.PRIOR_TAFE_AWARD,
    NEW_REFERENCES.PRIOR_STUDIES_EXEMPTION,
    NEW_REFERENCES.EXEMPTION_INSTITUTION_CD,
    NEW_REFERENCES.GOVT_EXEMPTION_INSTITUTION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.GOVT_ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.GOVT_ATTENDANCE_TYPE,
    NEW_REFERENCES.COMMENCEMENT_DT,
    NEW_REFERENCES.MAJOR_COURSE,
    NEW_REFERENCES.TERTIARY_ENTRANCE_SCORE,
    NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    NEW_REFERENCES.GOVT_BASIS_FOR_ADMISSION_TYPE,
    NEW_REFERENCES.GOVT_DISABILITY,
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
  X_VERSION_NUMBER in NUMBER,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_ABORIG_TORRES_CD in VARCHAR2,
  X_GOVT_ABORIG_TORRES_CD in NUMBER,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_HOME_LOCATION in VARCHAR2,
  X_GOVT_HOME_LOCATION in VARCHAR2,
  X_TERM_LOCATION in VARCHAR2,
  X_GOVT_TERM_LOCATION in VARCHAR2,
  X_BIRTH_COUNTRY_CD in VARCHAR2,
  X_GOVT_BIRTH_COUNTRY_CD in VARCHAR2,
  X_YR_ARRIVAL in VARCHAR2,
  X_HOME_LANGUAGE_CD in VARCHAR2,
  X_GOVT_HOME_LANGUAGE_CD in NUMBER,
  X_PRIOR_UG_INST in VARCHAR2,
  X_GOVT_PRIOR_UG_INST in VARCHAR2,
  X_PRIOR_OTHER_QUAL in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_SUBDEG_NOTAFE in VARCHAR2,
  X_PRIOR_SUBDEG_TAFE in VARCHAR2,
  X_PRIOR_SECED_TAFE in VARCHAR2,
  X_PRIOR_SECED_SCHOOL in VARCHAR2,
  X_PRIOR_TAFE_AWARD in VARCHAR2,
  X_PRIOR_STUDIES_EXEMPTION in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GOVT_EXEMPT_INSTITU_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_MAJOR_COURSE in NUMBER,
  X_TERTIARY_ENTRANCE_SCORE in NUMBER,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_GOVT_DISABILITY in VARCHAR2
) AS
  cursor c1 is select
      VERSION_NUMBER,
      BIRTH_DT,
      SEX,
      ABORIG_TORRES_CD,
      GOVT_ABORIG_TORRES_CD,
      CITIZENSHIP_CD,
      GOVT_CITIZENSHIP_CD,
      PERM_RESIDENT_CD,
      GOVT_PERM_RESIDENT_CD,
      HOME_LOCATION,
      GOVT_HOME_LOCATION,
      TERM_LOCATION,
      GOVT_TERM_LOCATION,
      BIRTH_COUNTRY_CD,
      GOVT_BIRTH_COUNTRY_CD,
      YR_ARRIVAL,
      HOME_LANGUAGE_CD,
      GOVT_HOME_LANGUAGE_CD,
      PRIOR_UG_INST,
      GOVT_PRIOR_UG_INST,
      PRIOR_OTHER_QUAL,
      PRIOR_POST_GRAD,
      PRIOR_DEGREE,
      PRIOR_SUBDEG_NOTAFE,
      PRIOR_SUBDEG_TAFE,
      PRIOR_SECED_TAFE,
      PRIOR_SECED_SCHOOL,
      PRIOR_TAFE_AWARD,
      PRIOR_STUDIES_EXEMPTION,
      EXEMPTION_INSTITUTION_CD,
      GOVT_EXEMPTION_INSTITUTION_CD,
      ATTENDANCE_MODE,
      GOVT_ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      GOVT_ATTENDANCE_TYPE,
      COMMENCEMENT_DT,
      MAJOR_COURSE,
      TERTIARY_ENTRANCE_SCORE,
      BASIS_FOR_ADMISSION_TYPE,
      GOVT_BASIS_FOR_ADMISSION_TYPE,
      GOVT_DISABILITY
    from IGS_ST_GOVT_STDNT_EN
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

  if ( (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND ((tlinfo.BIRTH_DT = X_BIRTH_DT)
           OR ((tlinfo.BIRTH_DT is null)
               AND (X_BIRTH_DT is null)))
      AND (tlinfo.SEX = X_SEX)
      AND (tlinfo.ABORIG_TORRES_CD = X_ABORIG_TORRES_CD)
      AND (tlinfo.GOVT_ABORIG_TORRES_CD = X_GOVT_ABORIG_TORRES_CD)
      AND (tlinfo.CITIZENSHIP_CD = X_CITIZENSHIP_CD)
      AND (tlinfo.GOVT_CITIZENSHIP_CD = X_GOVT_CITIZENSHIP_CD)
      AND (tlinfo.PERM_RESIDENT_CD = X_PERM_RESIDENT_CD)
      AND (tlinfo.GOVT_PERM_RESIDENT_CD = X_GOVT_PERM_RESIDENT_CD)
      AND (tlinfo.HOME_LOCATION = X_HOME_LOCATION)
      AND (tlinfo.GOVT_HOME_LOCATION = X_GOVT_HOME_LOCATION)
      AND (tlinfo.TERM_LOCATION = X_TERM_LOCATION)
      AND (tlinfo.GOVT_TERM_LOCATION = X_GOVT_TERM_LOCATION)
      AND (tlinfo.BIRTH_COUNTRY_CD = X_BIRTH_COUNTRY_CD)
      AND (tlinfo.GOVT_BIRTH_COUNTRY_CD = X_GOVT_BIRTH_COUNTRY_CD)
      AND (tlinfo.YR_ARRIVAL = X_YR_ARRIVAL)
      AND (tlinfo.HOME_LANGUAGE_CD = X_HOME_LANGUAGE_CD)
      AND (tlinfo.GOVT_HOME_LANGUAGE_CD = X_GOVT_HOME_LANGUAGE_CD)
      AND (tlinfo.PRIOR_UG_INST = X_PRIOR_UG_INST)
      AND (tlinfo.GOVT_PRIOR_UG_INST = X_GOVT_PRIOR_UG_INST)
      AND (tlinfo.PRIOR_OTHER_QUAL = X_PRIOR_OTHER_QUAL)
      AND (tlinfo.PRIOR_POST_GRAD = X_PRIOR_POST_GRAD)
      AND (tlinfo.PRIOR_DEGREE = X_PRIOR_DEGREE)
      AND (tlinfo.PRIOR_SUBDEG_NOTAFE = X_PRIOR_SUBDEG_NOTAFE)
      AND (tlinfo.PRIOR_SUBDEG_TAFE = X_PRIOR_SUBDEG_TAFE)
      AND (tlinfo.PRIOR_SECED_TAFE = X_PRIOR_SECED_TAFE)
      AND (tlinfo.PRIOR_SECED_SCHOOL = X_PRIOR_SECED_SCHOOL)
      AND (tlinfo.PRIOR_TAFE_AWARD = X_PRIOR_TAFE_AWARD)
      AND (tlinfo.PRIOR_STUDIES_EXEMPTION = X_PRIOR_STUDIES_EXEMPTION)
      AND (tlinfo.EXEMPTION_INSTITUTION_CD = X_EXEMPTION_INSTITUTION_CD)
      AND (tlinfo.GOVT_EXEMPTION_INSTITUTION_CD = X_GOVT_EXEMPT_INSTITU_CD)
      AND (tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
      AND (tlinfo.GOVT_ATTENDANCE_MODE = X_GOVT_ATTENDANCE_MODE)
      AND (tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
      AND (tlinfo.GOVT_ATTENDANCE_TYPE = X_GOVT_ATTENDANCE_TYPE)
      AND (tlinfo.COMMENCEMENT_DT = X_COMMENCEMENT_DT)
      AND (tlinfo.MAJOR_COURSE = X_MAJOR_COURSE)
      AND (tlinfo.TERTIARY_ENTRANCE_SCORE = X_TERTIARY_ENTRANCE_SCORE)
      AND (tlinfo.BASIS_FOR_ADMISSION_TYPE = X_BASIS_FOR_ADMISSION_TYPE)
      AND (tlinfo.GOVT_BASIS_FOR_ADMISSION_TYPE = X_GOVT_BASIS_FOR_ADM_TYPE)
      AND (tlinfo.GOVT_DISABILITY = X_GOVT_DISABILITY)
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
  X_VERSION_NUMBER in NUMBER,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_ABORIG_TORRES_CD in VARCHAR2,
  X_GOVT_ABORIG_TORRES_CD in NUMBER,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_HOME_LOCATION in VARCHAR2,
  X_GOVT_HOME_LOCATION in VARCHAR2,
  X_TERM_LOCATION in VARCHAR2,
  X_GOVT_TERM_LOCATION in VARCHAR2,
  X_BIRTH_COUNTRY_CD in VARCHAR2,
  X_GOVT_BIRTH_COUNTRY_CD in VARCHAR2,
  X_YR_ARRIVAL in VARCHAR2,
  X_HOME_LANGUAGE_CD in VARCHAR2,
  X_GOVT_HOME_LANGUAGE_CD in NUMBER,
  X_PRIOR_UG_INST in VARCHAR2,
  X_GOVT_PRIOR_UG_INST in VARCHAR2,
  X_PRIOR_OTHER_QUAL in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_SUBDEG_NOTAFE in VARCHAR2,
  X_PRIOR_SUBDEG_TAFE in VARCHAR2,
  X_PRIOR_SECED_TAFE in VARCHAR2,
  X_PRIOR_SECED_SCHOOL in VARCHAR2,
  X_PRIOR_TAFE_AWARD in VARCHAR2,
  X_PRIOR_STUDIES_EXEMPTION in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GOVT_EXEMPT_INSTITU_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_MAJOR_COURSE in NUMBER,
  X_TERTIARY_ENTRANCE_SCORE in NUMBER,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_GOVT_DISABILITY in VARCHAR2,
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
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_submission_yr => X_SUBMISSION_YR,
     x_submission_number => X_SUBMISSION_NUMBER,
     x_person_id => X_PERSON_ID,
     x_course_cd => X_COURSE_CD,
     x_version_number => X_VERSION_NUMBER,
     x_birth_dt => X_BIRTH_DT,
     x_sex => X_SEX,
     x_aborig_torres_cd => X_ABORIG_TORRES_CD,
     x_govt_aborig_torres_cd => X_GOVT_ABORIG_TORRES_CD,
     x_citizenship_cd => X_CITIZENSHIP_CD,
     x_govt_citizenship_cd => X_GOVT_CITIZENSHIP_CD,
     x_perm_resident_cd => X_PERM_RESIDENT_CD,
     x_govt_perm_resident_cd => X_GOVT_PERM_RESIDENT_CD,
     x_home_location => X_HOME_LOCATION,
     x_govt_home_location => X_GOVT_HOME_LOCATION,
     x_term_location => X_TERM_LOCATION,
     x_govt_term_location => X_GOVT_TERM_LOCATION,
     x_birth_country_cd => X_BIRTH_COUNTRY_CD,
     x_govt_birth_country_cd => X_GOVT_BIRTH_COUNTRY_CD,
     x_yr_arrival => X_YR_ARRIVAL,
     x_home_language_cd => X_HOME_LANGUAGE_CD,
     x_govt_home_language_cd => X_GOVT_HOME_LANGUAGE_CD,
     x_prior_ug_inst => X_PRIOR_UG_INST,
     x_govt_prior_ug_inst => X_GOVT_PRIOR_UG_INST,
     x_prior_other_qual => X_PRIOR_OTHER_QUAL,
     x_prior_post_grad => X_PRIOR_POST_GRAD,
     x_prior_degree => X_PRIOR_DEGREE,
     x_prior_subdeg_notafe => X_PRIOR_SUBDEG_NOTAFE,
     x_prior_subdeg_tafe => X_PRIOR_SUBDEG_TAFE,
     x_prior_seced_tafe => X_PRIOR_SECED_TAFE,
     x_prior_seced_school => X_PRIOR_SECED_SCHOOL,
     x_prior_tafe_award => X_PRIOR_TAFE_AWARD,
     x_prior_studies_exemption => X_PRIOR_STUDIES_EXEMPTION,
     x_exemption_institution_cd => X_EXEMPTION_INSTITUTION_CD,
     x_govt_exempt_institu_cd => X_GOVT_EXEMPT_INSTITU_CD,
     x_attendance_mode => X_ATTENDANCE_MODE,
     x_govt_attendance_mode => X_GOVT_ATTENDANCE_MODE,
     x_attendance_type => X_ATTENDANCE_TYPE,
     x_govt_attendance_type => X_GOVT_ATTENDANCE_TYPE,
     x_commencement_dt => X_COMMENCEMENT_DT,
     x_major_course => X_MAJOR_COURSE,
     x_tertiary_entrance_score => X_TERTIARY_ENTRANCE_SCORE,
     x_basis_for_admission_type => X_BASIS_FOR_ADMISSION_TYPE,
     x_govt_basis_for_adm_type => X_GOVT_BASIS_FOR_ADM_TYPE,
     x_govt_disability => X_GOVT_DISABILITY,
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
      X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;
      X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
      X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
  end if;

update IGS_ST_GOVT_STDNT_EN set
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    BIRTH_DT = NEW_REFERENCES.BIRTH_DT,
    SEX = NEW_REFERENCES.SEX,
    ABORIG_TORRES_CD = NEW_REFERENCES.ABORIG_TORRES_CD,
    GOVT_ABORIG_TORRES_CD = NEW_REFERENCES.GOVT_ABORIG_TORRES_CD,
    CITIZENSHIP_CD = NEW_REFERENCES.CITIZENSHIP_CD,
    GOVT_CITIZENSHIP_CD = NEW_REFERENCES.GOVT_CITIZENSHIP_CD,
    PERM_RESIDENT_CD = NEW_REFERENCES.PERM_RESIDENT_CD,
    GOVT_PERM_RESIDENT_CD = NEW_REFERENCES.GOVT_PERM_RESIDENT_CD,
    HOME_LOCATION = NEW_REFERENCES.HOME_LOCATION,
    GOVT_HOME_LOCATION = NEW_REFERENCES.GOVT_HOME_LOCATION,
    TERM_LOCATION = NEW_REFERENCES.TERM_LOCATION,
    GOVT_TERM_LOCATION = NEW_REFERENCES.GOVT_TERM_LOCATION,
    BIRTH_COUNTRY_CD = NEW_REFERENCES.BIRTH_COUNTRY_CD,
    GOVT_BIRTH_COUNTRY_CD = NEW_REFERENCES.GOVT_BIRTH_COUNTRY_CD,
    YR_ARRIVAL = NEW_REFERENCES.YR_ARRIVAL,
    HOME_LANGUAGE_CD = NEW_REFERENCES.HOME_LANGUAGE_CD,
    GOVT_HOME_LANGUAGE_CD = NEW_REFERENCES.GOVT_HOME_LANGUAGE_CD,
    PRIOR_UG_INST = NEW_REFERENCES.PRIOR_UG_INST,
    GOVT_PRIOR_UG_INST = NEW_REFERENCES.GOVT_PRIOR_UG_INST,
    PRIOR_OTHER_QUAL = NEW_REFERENCES.PRIOR_OTHER_QUAL,
    PRIOR_POST_GRAD = NEW_REFERENCES.PRIOR_POST_GRAD,
    PRIOR_DEGREE = NEW_REFERENCES.PRIOR_DEGREE,
    PRIOR_SUBDEG_NOTAFE = NEW_REFERENCES.PRIOR_SUBDEG_NOTAFE,
    PRIOR_SUBDEG_TAFE = NEW_REFERENCES.PRIOR_SUBDEG_TAFE,
    PRIOR_SECED_TAFE = NEW_REFERENCES.PRIOR_SECED_TAFE,
    PRIOR_SECED_SCHOOL = NEW_REFERENCES.PRIOR_SECED_SCHOOL,
    PRIOR_TAFE_AWARD = NEW_REFERENCES.PRIOR_TAFE_AWARD,
    PRIOR_STUDIES_EXEMPTION = NEW_REFERENCES.PRIOR_STUDIES_EXEMPTION,
    EXEMPTION_INSTITUTION_CD = NEW_REFERENCES.EXEMPTION_INSTITUTION_CD,
    GOVT_EXEMPTION_INSTITUTION_CD = NEW_REFERENCES.GOVT_EXEMPTION_INSTITUTION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    GOVT_ATTENDANCE_MODE = NEW_REFERENCES.GOVT_ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    GOVT_ATTENDANCE_TYPE = NEW_REFERENCES.GOVT_ATTENDANCE_TYPE,
    COMMENCEMENT_DT = NEW_REFERENCES.COMMENCEMENT_DT,
    MAJOR_COURSE = NEW_REFERENCES.MAJOR_COURSE,
    TERTIARY_ENTRANCE_SCORE = NEW_REFERENCES.TERTIARY_ENTRANCE_SCORE,
    BASIS_FOR_ADMISSION_TYPE = NEW_REFERENCES.BASIS_FOR_ADMISSION_TYPE,
    GOVT_BASIS_FOR_ADMISSION_TYPE = NEW_REFERENCES.GOVT_BASIS_FOR_ADMISSION_TYPE,
    GOVT_DISABILITY = NEW_REFERENCES.GOVT_DISABILITY,
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
  X_VERSION_NUMBER in NUMBER,
  X_BIRTH_DT in DATE,
  X_SEX in VARCHAR2,
  X_ABORIG_TORRES_CD in VARCHAR2,
  X_GOVT_ABORIG_TORRES_CD in NUMBER,
  X_CITIZENSHIP_CD in VARCHAR2,
  X_GOVT_CITIZENSHIP_CD in NUMBER,
  X_PERM_RESIDENT_CD in VARCHAR2,
  X_GOVT_PERM_RESIDENT_CD in NUMBER,
  X_HOME_LOCATION in VARCHAR2,
  X_GOVT_HOME_LOCATION in VARCHAR2,
  X_TERM_LOCATION in VARCHAR2,
  X_GOVT_TERM_LOCATION in VARCHAR2,
  X_BIRTH_COUNTRY_CD in VARCHAR2,
  X_GOVT_BIRTH_COUNTRY_CD in VARCHAR2,
  X_YR_ARRIVAL in VARCHAR2,
  X_HOME_LANGUAGE_CD in VARCHAR2,
  X_GOVT_HOME_LANGUAGE_CD in NUMBER,
  X_PRIOR_UG_INST in VARCHAR2,
  X_GOVT_PRIOR_UG_INST in VARCHAR2,
  X_PRIOR_OTHER_QUAL in VARCHAR2,
  X_PRIOR_POST_GRAD in VARCHAR2,
  X_PRIOR_DEGREE in VARCHAR2,
  X_PRIOR_SUBDEG_NOTAFE in VARCHAR2,
  X_PRIOR_SUBDEG_TAFE in VARCHAR2,
  X_PRIOR_SECED_TAFE in VARCHAR2,
  X_PRIOR_SECED_SCHOOL in VARCHAR2,
  X_PRIOR_TAFE_AWARD in VARCHAR2,
  X_PRIOR_STUDIES_EXEMPTION in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_GOVT_EXEMPT_INSTITU_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_GOVT_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_GOVT_ATTENDANCE_TYPE in VARCHAR2,
  X_COMMENCEMENT_DT in DATE,
  X_MAJOR_COURSE in NUMBER,
  X_TERTIARY_ENTRANCE_SCORE in NUMBER,
  X_BASIS_FOR_ADMISSION_TYPE in VARCHAR2,
  X_GOVT_BASIS_FOR_ADM_TYPE in VARCHAR2,
  X_GOVT_DISABILITY in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_ST_GOVT_STDNT_EN
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
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
     X_VERSION_NUMBER,
     X_BIRTH_DT,
     X_SEX,
     X_ABORIG_TORRES_CD,
     X_GOVT_ABORIG_TORRES_CD,
     X_CITIZENSHIP_CD,
     X_GOVT_CITIZENSHIP_CD,
     X_PERM_RESIDENT_CD,
     X_GOVT_PERM_RESIDENT_CD,
     X_HOME_LOCATION,
     X_GOVT_HOME_LOCATION,
     X_TERM_LOCATION,
     X_GOVT_TERM_LOCATION,
     X_BIRTH_COUNTRY_CD,
     X_GOVT_BIRTH_COUNTRY_CD,
     X_YR_ARRIVAL,
     X_HOME_LANGUAGE_CD,
     X_GOVT_HOME_LANGUAGE_CD,
     X_PRIOR_UG_INST,
     X_GOVT_PRIOR_UG_INST,
     X_PRIOR_OTHER_QUAL,
     X_PRIOR_POST_GRAD,
     X_PRIOR_DEGREE,
     X_PRIOR_SUBDEG_NOTAFE,
     X_PRIOR_SUBDEG_TAFE,
     X_PRIOR_SECED_TAFE,
     X_PRIOR_SECED_SCHOOL,
     X_PRIOR_TAFE_AWARD,
     X_PRIOR_STUDIES_EXEMPTION,
     X_EXEMPTION_INSTITUTION_CD,
     X_GOVT_EXEMPT_INSTITU_CD,
     X_ATTENDANCE_MODE,
     X_GOVT_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_GOVT_ATTENDANCE_TYPE,
     X_COMMENCEMENT_DT,
     X_MAJOR_COURSE,
     X_TERTIARY_ENTRANCE_SCORE,
     X_BASIS_FOR_ADMISSION_TYPE,
     X_GOVT_BASIS_FOR_ADM_TYPE,
     X_GOVT_DISABILITY,
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
   X_VERSION_NUMBER,
   X_BIRTH_DT,
   X_SEX,
   X_ABORIG_TORRES_CD,
   X_GOVT_ABORIG_TORRES_CD,
   X_CITIZENSHIP_CD,
   X_GOVT_CITIZENSHIP_CD,
   X_PERM_RESIDENT_CD,
   X_GOVT_PERM_RESIDENT_CD,
   X_HOME_LOCATION,
   X_GOVT_HOME_LOCATION,
   X_TERM_LOCATION,
   X_GOVT_TERM_LOCATION,
   X_BIRTH_COUNTRY_CD,
   X_GOVT_BIRTH_COUNTRY_CD,
   X_YR_ARRIVAL,
   X_HOME_LANGUAGE_CD,
   X_GOVT_HOME_LANGUAGE_CD,
   X_PRIOR_UG_INST,
   X_GOVT_PRIOR_UG_INST,
   X_PRIOR_OTHER_QUAL,
   X_PRIOR_POST_GRAD,
   X_PRIOR_DEGREE,
   X_PRIOR_SUBDEG_NOTAFE,
   X_PRIOR_SUBDEG_TAFE,
   X_PRIOR_SECED_TAFE,
   X_PRIOR_SECED_SCHOOL,
   X_PRIOR_TAFE_AWARD,
   X_PRIOR_STUDIES_EXEMPTION,
   X_EXEMPTION_INSTITUTION_CD,
   X_GOVT_EXEMPT_INSTITU_CD,
   X_ATTENDANCE_MODE,
   X_GOVT_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_GOVT_ATTENDANCE_TYPE,
   X_COMMENCEMENT_DT,
   X_MAJOR_COURSE,
   X_TERTIARY_ENTRANCE_SCORE,
   X_BASIS_FOR_ADMISSION_TYPE,
   X_GOVT_BASIS_FOR_ADM_TYPE,
   X_GOVT_DISABILITY,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
  delete from IGS_ST_GOVT_STDNT_EN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_ST_GOVT_STDNT_EN_PKG;

/
