--------------------------------------------------------
--  DDL for Package Body IGS_AD_TER_EDU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_TER_EDU_PKG" as
/* $Header: IGSAI54B.pls 115.6 2003/10/30 13:20:48 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_TER_EDU%RowType;
  new_references IGS_AD_TER_EDU%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_tertiary_edu_lvl_comp IN VARCHAR2 DEFAULT NULL,
    x_exclusion_ind IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_institution_name IN VARCHAR2 DEFAULT NULL,
    x_enrolment_first_yr IN NUMBER DEFAULT NULL,
    x_enrolment_latest_yr IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_course_title IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_language_component IN VARCHAR2 DEFAULT NULL,
    x_student_id IN VARCHAR2 DEFAULT NULL,
    x_equiv_full_time_yrs_enr IN NUMBER DEFAULT NULL,
    x_tertiary_edu_lvl_qual IN VARCHAR2 DEFAULT NULL,
    x_qualification IN VARCHAR2 DEFAULT NULL,
    x_honours_level IN VARCHAR2 DEFAULT NULL,
    x_level_of_achievement_type IN VARCHAR2 DEFAULT NULL,
    x_grade_point_average IN NUMBER DEFAULT NULL,
    x_language_of_tuition IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_country_cd IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_TER_EDU
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
    new_references.person_id := x_person_id;
    new_references.sequence_number := x_sequence_number;
    new_references.tertiary_edu_lvl_comp := x_tertiary_edu_lvl_comp;
    new_references.exclusion_ind := x_exclusion_ind;
    new_references.institution_cd := x_institution_cd;
    new_references.institution_name := x_institution_name;
    new_references.enrolment_first_yr := x_enrolment_first_yr;
    new_references.enrolment_latest_yr := x_enrolment_latest_yr;
    new_references.course_cd := x_course_cd;
    new_references.course_title := x_course_title;
    new_references.field_of_study := x_field_of_study;
    new_references.language_component := x_language_component;
    new_references.student_id := x_student_id;
    new_references.equiv_full_time_yrs_enr := x_equiv_full_time_yrs_enr;
    new_references.tertiary_edu_lvl_qual := x_tertiary_edu_lvl_qual;
    new_references.qualification := x_qualification;
    new_references.honours_level := x_honours_level;
    new_references.level_of_achievement_type := x_level_of_achievement_type;
    new_references.grade_point_average := x_grade_point_average;
    new_references.language_of_tuition := x_language_of_tuition;
    new_references.state_cd := x_state_cd;
    new_references.country_cd := x_country_cd;
    new_references.notes := x_notes;
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
    ) as
	v_message_name VARCHAR2(30);
  BEGIN
	--
	-- Validate Tertiary Education.
	--
	IF p_inserting
	OR (old_references.tertiary_edu_lvl_comp <> new_references.tertiary_edu_lvl_comp) THEN
		-- Validate tertiary education level of completion
		IF IGS_AD_VAL_TE.admp_val_telocclosed(
				new_references.tertiary_edu_lvl_comp,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF (p_inserting AND new_references.tertiary_edu_lvl_qual IS NOT NULL)
	OR (old_references.tertiary_edu_lvl_qual <> new_references.tertiary_edu_lvl_qual)
	OR (old_references.tertiary_edu_lvl_qual IS NULL
		AND new_references.tertiary_edu_lvl_qual IS NOT NULL) THEN
		-- Validate tertiary education level of qualification
		IF IGS_AD_VAL_TE.admp_val_teloqclosed(
				new_references.tertiary_edu_lvl_qual,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF (p_inserting
		OR (old_references.enrolment_first_yr <> new_references.enrolment_first_yr)
		OR (old_references.enrolment_first_yr IS NULL
			AND new_references.enrolment_first_yr IS NOT NULL)
		OR (old_references.enrolment_latest_yr <> new_references.enrolment_latest_yr)
		OR (old_references.enrolment_latest_yr IS NULL
			AND new_references.enrolment_latest_yr IS NOT NULL))
	AND (new_references.enrolment_first_yr IS NOT NULL
		AND new_references.enrolment_latest_yr IS NOT NULL) THEN
		-- Validate enrolment years
		IF IGS_AD_VAL_TE.admp_val_te_enr_yr(
				new_references.enrolment_first_yr,
				new_references.enrolment_latest_yr,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting
	OR (old_references.institution_cd <> new_references.institution_cd)
	OR (old_references.institution_cd IS NULL AND new_references.institution_cd IS NOT NULL)
	OR (old_references.institution_name <> new_references.institution_name)
	OR (old_references.institution_name IS NULL AND new_references.institution_name IS NOT NULL)
	THEN
		-- Validate the institution code and name
		IF IGS_AD_VAL_TE.admp_val_te_inst(
				new_references.institution_cd,
				new_references.institution_name,
				v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  procedure Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN

	IF Column_Name is null then
		NULL;
	ELSIF upper(Column_Name) = 'SEQUENCE_NUMBER' then
		new_references.sequence_number := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'ENROLMENT_FIRST_YR' then
		new_references.enrolment_first_yr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'ENROLMENT_LATEST_YR' then
		new_references.enrolment_latest_yr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'EXCLUSION_IND' then
		new_references.exclusion_ind := column_value;
	ELSIF upper(Column_Name) = 'COUNTRY_CD' then
		new_references.country_cd := column_value;
	ELSIF upper(Column_Name) = 'COURSE_CD' then
		new_references.course_cd := column_value;
	ELSIF upper(Column_Name) = 'COURSE_TITLE' then
		new_references.course_title := column_value;
	ELSIF upper(Column_Name) = 'FIELD_OF_STUDY' then
		new_references.field_of_study := column_value;
	ELSIF upper(Column_Name) = 'HONOURS_LEVEL' then
		new_references.honours_level := column_value;
	ELSIF upper(Column_Name) = 'INSTITUTION_CD' then
		new_references.institution_cd := column_value;
	ELSIF upper(Column_Name) = 'INSTITUTION_NAME' then
		new_references.institution_name := column_value;
	ELSIF upper(Column_Name) = 'LANGUAGE_COMPONENT' then
		new_references.language_component := column_value;
	ELSIF upper(Column_Name) = 'LANGUAGE_OF_TUITION' then
		new_references.language_of_tuition := column_value;
	ELSIF upper(Column_Name) = 'LEVEL_OF_ACHIEVEMENT_TYPE' then
		new_references.level_of_achievement_type := column_value;
	ELSIF upper(Column_Name) = 'QUALIFICATION' then
		new_references.qualification := column_value;
	ELSIF upper(Column_Name) = 'STUDENT_ID' then
		new_references.student_id := column_value;
	ELSIF upper(Column_Name) = 'TERTIARY_EDU_LVL_COMP' then
		new_references.tertiary_edu_lvl_comp := column_value;
	ELSIF upper(Column_Name) = 'TERTIARY_EDU_LVL_QUAL' then
		new_references.tertiary_edu_lvl_qual := column_value;
	ELSIF upper(Column_Name) = 'EQUIV_FULL_TIME_YRS_ENR' then
		new_references.equiv_full_time_yrs_enr := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'GRADE_POINT_AVERAGE' then
		new_references.grade_point_average := igs_ge_number.to_num(column_value);
	ELSIF upper(Column_Name) = 'STATE_CD' then
		new_references.state_cd := column_value;
	END IF;

	IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.sequence_number < 1 OR new_references.sequence_number > 999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ENROLMENT_FIRST_YR' OR Column_Name IS NULL THEN
		IF new_references.enrolment_first_yr < 1900 OR new_references.enrolment_first_yr > 2050 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ENROLMENT_LATEST_YR' OR Column_Name IS NULL THEN
		IF new_references.enrolment_latest_yr < 1900 OR new_references.enrolment_latest_yr > 2050 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'EXCLUSION_IND' OR Column_Name IS NULL THEN
		IF new_references.exclusion_ind NOT IN ('Y','N') THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'COUNTRY_CD' OR Column_Name IS NULL THEN
		IF new_references.country_cd <> UPPER(new_references.country_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'COURSE_CD' OR Column_Name IS NULL THEN
		IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'COURSE_TITLE' OR Column_Name IS NULL THEN
		IF new_references.course_title <> UPPER(new_references.course_title) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'FIELD_OF_STUDY' OR Column_Name IS NULL THEN
		IF new_references.field_of_study <> UPPER(new_references.field_of_study) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'HONOURS_LEVEL' OR Column_Name IS NULL THEN
		IF new_references.honours_level <> UPPER(new_references.honours_level) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'INSTITUTION_NAME' OR Column_Name IS NULL THEN
		IF new_references.institution_name <> UPPER(new_references.institution_name) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'LANGUAGE_COMPONENT' OR Column_Name IS NULL THEN
		IF new_references.language_component <> UPPER(new_references.language_component) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'LANGUAGE_OF_TUITION' OR Column_Name IS NULL THEN
		IF new_references.language_of_tuition <> UPPER(new_references.language_of_tuition) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'LEVEL_OF_ACHIEVEMENT_TYPE' OR Column_Name IS NULL THEN
		IF new_references.level_of_achievement_type <> UPPER(new_references.level_of_achievement_type) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'QUALIFICATION' OR Column_Name IS NULL THEN
		IF new_references.qualification <> UPPER(new_references.qualification) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'STUDENT_ID' OR Column_Name IS NULL THEN
		IF new_references.student_id <> UPPER(new_references.student_id) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'TERTIARY_EDU_LVL_COMP' OR Column_Name IS NULL THEN
		IF new_references.tertiary_edu_lvl_comp <> UPPER(new_references.tertiary_edu_lvl_comp) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'TERTIARY_EDU_LVL_QUAL' OR Column_Name IS NULL THEN
		IF new_references.tertiary_edu_lvl_qual <> UPPER(new_references.tertiary_edu_lvl_qual) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'EQUIV_FULL_TIME_YRS_ENR' OR Column_Name IS NULL THEN
		IF new_references.equiv_full_time_yrs_enr < 0 OR new_references.equiv_full_time_yrs_enr > 99.99 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'GRADE_POINT_AVERAGE' OR Column_Name IS NULL THEN
		IF new_references.grade_point_average < 0 OR new_references.grade_point_average > 999.99 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'STATE_CD' OR Column_Name IS NULL THEN
		IF new_references.state_cd <> UPPER(new_references.state_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.country_cd = new_references.country_cd)) OR
        ((new_references.country_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_COUNTRY_CD_PKG.Get_PK_For_Validation (
        new_references.country_cd
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.field_of_study = new_references.field_of_study)) OR
        ((new_references.field_of_study IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_FLD_OF_STUDY_PKG.Get_PK_For_Validation (
        new_references.field_of_study
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.honours_level = new_references.honours_level)) OR
        ((new_references.honours_level IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_GR_HONOURS_LEVEL_PKG.Get_PK_For_Validation (
        new_references.honours_level
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.institution_cd = new_references.institution_cd)) OR
        ((new_references.institution_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_INSTITUTION_PKG.Get_PK_For_Validation (
        new_references.institution_cd
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.language_component = new_references.language_component)) OR
        ((new_references.language_component IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_LANGUAGE_CD_PKG.Get_PK_For_Validation (
        new_references.language_component
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.language_of_tuition = new_references.language_of_tuition)) OR
        ((new_references.language_of_tuition IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_LANGUAGE_CD_PKG.Get_PK_For_Validation (
        new_references.language_of_tuition
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.person_id
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.tertiary_edu_lvl_comp = new_references.tertiary_edu_lvl_comp)) OR
        ((new_references.tertiary_edu_lvl_comp IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_TER_ED_LV_COM_PKG.Get_PK_For_Validation (
        new_references.tertiary_edu_lvl_comp,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.tertiary_edu_lvl_qual = new_references.tertiary_edu_lvl_qual)) OR
        ((new_references.tertiary_edu_lvl_qual IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_TER_ED_LVL_QF_PKG.Get_PK_For_Validation (
        new_references.tertiary_edu_lvl_qual,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_TER_ED_UNI_AT_PKG.GET_FK_IGS_AD_TER_EDU (
      old_references.person_id,
      old_references.sequence_number
      );

  END Check_Child_Existance;

function Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_sequence_number IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    person_id = x_person_id
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_PE_COUNTRY_CD (
    x_country_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    country_cd = x_country_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_CNC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_COUNTRY_CD;


  PROCEDURE GET_FK_IGS_GR_HONOURS_LEVEL (
    x_honours_level IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    honours_level = x_honours_level ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_HL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_GR_HONOURS_LEVEL;

  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    institution_cd = x_institution_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_INS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_INSTITUTION;

  PROCEDURE GET_FK_IGS_PE_LANGUAGE_CD (
    x_language_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    language_component = x_language_cd
         OR    language_of_tuition = x_language_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_LC_COMPONENT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_LANGUAGE_CD;


  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE GET_FK_IGS_AD_TER_EDU_LV_COM (
    x_tertiary_edu_lvl_comp IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    tertiary_edu_lvl_comp = x_tertiary_edu_lvl_comp ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_TELOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_TER_EDU_LV_COM;

  PROCEDURE GET_FK_IGS_AD_TER_EDU_LVL_QF (
    x_tertiary_edu_lvl_qual IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_TER_EDU
      WHERE    tertiary_edu_lvl_qual = x_tertiary_edu_lvl_qual ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_TE_TELOQ_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_TER_EDU_LVL_QF;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_tertiary_edu_lvl_comp IN VARCHAR2 DEFAULT NULL,
    x_exclusion_ind IN VARCHAR2 DEFAULT NULL,
    x_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_institution_name IN VARCHAR2 DEFAULT NULL,
    x_enrolment_first_yr IN NUMBER DEFAULT NULL,
    x_enrolment_latest_yr IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_course_title IN VARCHAR2 DEFAULT NULL,
    x_field_of_study IN VARCHAR2 DEFAULT NULL,
    x_language_component IN VARCHAR2 DEFAULT NULL,
    x_student_id IN VARCHAR2 DEFAULT NULL,
    x_equiv_full_time_yrs_enr IN NUMBER DEFAULT NULL,
    x_tertiary_edu_lvl_qual IN VARCHAR2 DEFAULT NULL,
    x_qualification IN VARCHAR2 DEFAULT NULL,
    x_honours_level IN VARCHAR2 DEFAULT NULL,
    x_level_of_achievement_type IN VARCHAR2 DEFAULT NULL,
    x_grade_point_average IN NUMBER DEFAULT NULL,
    x_language_of_tuition IN VARCHAR2 DEFAULT NULL,
    x_state_cd IN VARCHAR2 DEFAULT NULL,
    x_country_cd IN VARCHAR2 DEFAULT NULL,
    x_notes IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_sequence_number,
      x_tertiary_edu_lvl_comp,
      x_exclusion_ind,
      x_institution_cd,
      x_institution_name,
      x_enrolment_first_yr,
      x_enrolment_latest_yr,
      x_course_cd,
      x_course_title,
      x_field_of_study,
      x_language_component,
      x_student_id,
      x_equiv_full_time_yrs_enr,
      x_tertiary_edu_lvl_qual,
      x_qualification,
      x_honours_level,
      x_level_of_achievement_type,
      x_grade_point_average,
      x_language_of_tuition,
      x_state_cd,
      x_country_cd,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
      Null;
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.person_id,
		new_references.sequence_number
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  )as
  BEGIN
    l_rowid := x_rowid;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TERTIARY_EDU_LVL_COMP in VARCHAR2,
  X_EXCLUSION_IND in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_NAME in VARCHAR2,
  X_ENROLMENT_FIRST_YR in NUMBER,
  X_ENROLMENT_LATEST_YR in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_COURSE_TITLE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_LANGUAGE_COMPONENT in VARCHAR2,
  X_STUDENT_ID in VARCHAR2,
  X_EQUIV_FULL_TIME_YRS_ENR in NUMBER,
  X_TERTIARY_EDU_LVL_QUAL in VARCHAR2,
  X_QUALIFICATION in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_LEVEL_OF_ACHIEVEMENT_TYPE in VARCHAR2,
  X_GRADE_POINT_AVERAGE in NUMBER,
  X_LANGUAGE_OF_TUITION in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_AD_TER_EDU
      where PERSON_ID = X_PERSON_ID
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
     x_person_id => X_PERSON_ID,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_tertiary_edu_lvl_comp => X_TERTIARY_EDU_LVL_COMP,
     x_exclusion_ind => NVL(X_EXCLUSION_IND,'N'),
     x_institution_cd => X_INSTITUTION_CD,
     x_institution_name => X_INSTITUTION_NAME,
     x_enrolment_first_yr => X_ENROLMENT_FIRST_YR,
     x_enrolment_latest_yr => X_ENROLMENT_LATEST_YR,
     x_course_cd => X_COURSE_CD,
     x_course_title => X_COURSE_TITLE,
     x_field_of_study => X_FIELD_OF_STUDY,
     x_language_component => X_LANGUAGE_COMPONENT,
     x_student_id => X_STUDENT_ID,
     x_equiv_full_time_yrs_enr => X_EQUIV_FULL_TIME_YRS_ENR,
     x_tertiary_edu_lvl_qual => X_TERTIARY_EDU_LVL_QUAL,
     x_qualification => X_QUALIFICATION,
     x_honours_level => X_HONOURS_LEVEL,
     x_level_of_achievement_type => X_LEVEL_OF_ACHIEVEMENT_TYPE,
     x_grade_point_average => X_GRADE_POINT_AVERAGE,
     x_language_of_tuition => X_LANGUAGE_OF_TUITION,
     x_state_cd => X_STATE_CD,
     x_country_cd => X_COUNTRY_CD,
     x_notes => X_NOTES,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_AD_TER_EDU (
    PERSON_ID,
    SEQUENCE_NUMBER,
    TERTIARY_EDU_LVL_COMP,
    EXCLUSION_IND,
    INSTITUTION_CD,
    INSTITUTION_NAME,
    ENROLMENT_FIRST_YR,
    ENROLMENT_LATEST_YR,
    COURSE_CD,
    COURSE_TITLE,
    FIELD_OF_STUDY,
    LANGUAGE_COMPONENT,
    STUDENT_ID,
    EQUIV_FULL_TIME_YRS_ENR,
    TERTIARY_EDU_LVL_QUAL,
    QUALIFICATION,
    HONOURS_LEVEL,
    LEVEL_OF_ACHIEVEMENT_TYPE,
    GRADE_POINT_AVERAGE,
    LANGUAGE_OF_TUITION,
    STATE_CD,
    COUNTRY_CD,
    NOTES,
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
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.TERTIARY_EDU_LVL_COMP,
    NEW_REFERENCES.EXCLUSION_IND,
    NEW_REFERENCES.INSTITUTION_CD,
    NEW_REFERENCES.INSTITUTION_NAME,
    NEW_REFERENCES.ENROLMENT_FIRST_YR,
    NEW_REFERENCES.ENROLMENT_LATEST_YR,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.COURSE_TITLE,
    NEW_REFERENCES.FIELD_OF_STUDY,
    NEW_REFERENCES.LANGUAGE_COMPONENT,
    NEW_REFERENCES.STUDENT_ID,
    NEW_REFERENCES.EQUIV_FULL_TIME_YRS_ENR,
    NEW_REFERENCES.TERTIARY_EDU_LVL_QUAL,
    NEW_REFERENCES.QUALIFICATION,
    NEW_REFERENCES.HONOURS_LEVEL,
    NEW_REFERENCES.LEVEL_OF_ACHIEVEMENT_TYPE,
    NEW_REFERENCES.GRADE_POINT_AVERAGE,
    NEW_REFERENCES.LANGUAGE_OF_TUITION,
    NEW_REFERENCES.STATE_CD,
    NEW_REFERENCES.COUNTRY_CD,
    NEW_REFERENCES.NOTES,
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
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TERTIARY_EDU_LVL_COMP in VARCHAR2,
  X_EXCLUSION_IND in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_NAME in VARCHAR2,
  X_ENROLMENT_FIRST_YR in NUMBER,
  X_ENROLMENT_LATEST_YR in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_COURSE_TITLE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_LANGUAGE_COMPONENT in VARCHAR2,
  X_STUDENT_ID in VARCHAR2,
  X_EQUIV_FULL_TIME_YRS_ENR in NUMBER,
  X_TERTIARY_EDU_LVL_QUAL in VARCHAR2,
  X_QUALIFICATION in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_LEVEL_OF_ACHIEVEMENT_TYPE in VARCHAR2,
  X_GRADE_POINT_AVERAGE in NUMBER,
  X_LANGUAGE_OF_TUITION in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_NOTES in VARCHAR2
) as
  cursor c1 is select
      TERTIARY_EDU_LVL_COMP,
      EXCLUSION_IND,
      INSTITUTION_CD,
      INSTITUTION_NAME,
      ENROLMENT_FIRST_YR,
      ENROLMENT_LATEST_YR,
      COURSE_CD,
      COURSE_TITLE,
      FIELD_OF_STUDY,
      LANGUAGE_COMPONENT,
      STUDENT_ID,
      EQUIV_FULL_TIME_YRS_ENR,
      TERTIARY_EDU_LVL_QUAL,
      QUALIFICATION,
      HONOURS_LEVEL,
      LEVEL_OF_ACHIEVEMENT_TYPE,
      GRADE_POINT_AVERAGE,
      LANGUAGE_OF_TUITION,
      STATE_CD,
      COUNTRY_CD,
      NOTES
    from IGS_AD_TER_EDU
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

  if ( (tlinfo.TERTIARY_EDU_LVL_COMP = X_TERTIARY_EDU_LVL_COMP)
      AND (tlinfo.EXCLUSION_IND = X_EXCLUSION_IND)
      AND ((tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)
           OR ((tlinfo.INSTITUTION_CD is null)
               AND (X_INSTITUTION_CD is null)))
      AND ((tlinfo.INSTITUTION_NAME = X_INSTITUTION_NAME)
           OR ((tlinfo.INSTITUTION_NAME is null)
               AND (X_INSTITUTION_NAME is null)))
      AND ((tlinfo.ENROLMENT_FIRST_YR = X_ENROLMENT_FIRST_YR)
           OR ((tlinfo.ENROLMENT_FIRST_YR is null)
               AND (X_ENROLMENT_FIRST_YR is null)))
      AND ((tlinfo.ENROLMENT_LATEST_YR = X_ENROLMENT_LATEST_YR)
           OR ((tlinfo.ENROLMENT_LATEST_YR is null)
               AND (X_ENROLMENT_LATEST_YR is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.COURSE_TITLE = X_COURSE_TITLE)
           OR ((tlinfo.COURSE_TITLE is null)
               AND (X_COURSE_TITLE is null)))
      AND ((tlinfo.FIELD_OF_STUDY = X_FIELD_OF_STUDY)
           OR ((tlinfo.FIELD_OF_STUDY is null)
               AND (X_FIELD_OF_STUDY is null)))
      AND ((tlinfo.LANGUAGE_COMPONENT = X_LANGUAGE_COMPONENT)
           OR ((tlinfo.LANGUAGE_COMPONENT is null)
               AND (X_LANGUAGE_COMPONENT is null)))
      AND ((tlinfo.STUDENT_ID = X_STUDENT_ID)
           OR ((tlinfo.STUDENT_ID is null)
               AND (X_STUDENT_ID is null)))
      AND ((tlinfo.EQUIV_FULL_TIME_YRS_ENR = X_EQUIV_FULL_TIME_YRS_ENR)
           OR ((tlinfo.EQUIV_FULL_TIME_YRS_ENR is null)
               AND (X_EQUIV_FULL_TIME_YRS_ENR is null)))
      AND ((tlinfo.TERTIARY_EDU_LVL_QUAL = X_TERTIARY_EDU_LVL_QUAL)
           OR ((tlinfo.TERTIARY_EDU_LVL_QUAL is null)
               AND (X_TERTIARY_EDU_LVL_QUAL is null)))
      AND ((tlinfo.QUALIFICATION = X_QUALIFICATION)
           OR ((tlinfo.QUALIFICATION is null)
               AND (X_QUALIFICATION is null)))
      AND ((tlinfo.HONOURS_LEVEL = X_HONOURS_LEVEL)
           OR ((tlinfo.HONOURS_LEVEL is null)
               AND (X_HONOURS_LEVEL is null)))
      AND ((tlinfo.LEVEL_OF_ACHIEVEMENT_TYPE = X_LEVEL_OF_ACHIEVEMENT_TYPE)
           OR ((tlinfo.LEVEL_OF_ACHIEVEMENT_TYPE is null)
               AND (X_LEVEL_OF_ACHIEVEMENT_TYPE is null)))
      AND ((tlinfo.GRADE_POINT_AVERAGE = X_GRADE_POINT_AVERAGE)
           OR ((tlinfo.GRADE_POINT_AVERAGE is null)
               AND (X_GRADE_POINT_AVERAGE is null)))
      AND ((tlinfo.LANGUAGE_OF_TUITION = X_LANGUAGE_OF_TUITION)
           OR ((tlinfo.LANGUAGE_OF_TUITION is null)
               AND (X_LANGUAGE_OF_TUITION is null)))
      AND ((tlinfo.STATE_CD = X_STATE_CD)
           OR ((tlinfo.STATE_CD is null)
               AND (X_STATE_CD is null)))
      AND ((tlinfo.COUNTRY_CD = X_COUNTRY_CD)
           OR ((tlinfo.COUNTRY_CD is null)
               AND (X_COUNTRY_CD is null)))
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES is null)
               AND (X_NOTES is null)))
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
  X_SEQUENCE_NUMBER in NUMBER,
  X_TERTIARY_EDU_LVL_COMP in VARCHAR2,
  X_EXCLUSION_IND in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_NAME in VARCHAR2,
  X_ENROLMENT_FIRST_YR in NUMBER,
  X_ENROLMENT_LATEST_YR in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_COURSE_TITLE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_LANGUAGE_COMPONENT in VARCHAR2,
  X_STUDENT_ID in VARCHAR2,
  X_EQUIV_FULL_TIME_YRS_ENR in NUMBER,
  X_TERTIARY_EDU_LVL_QUAL in VARCHAR2,
  X_QUALIFICATION in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_LEVEL_OF_ACHIEVEMENT_TYPE in VARCHAR2,
  X_GRADE_POINT_AVERAGE in NUMBER,
  X_LANGUAGE_OF_TUITION in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_NOTES in VARCHAR2,
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
     x_person_id => X_PERSON_ID,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_tertiary_edu_lvl_comp => X_TERTIARY_EDU_LVL_COMP,
     x_exclusion_ind => X_EXCLUSION_IND,
     x_institution_cd => X_INSTITUTION_CD,
     x_institution_name => X_INSTITUTION_NAME,
     x_enrolment_first_yr => X_ENROLMENT_FIRST_YR,
     x_enrolment_latest_yr => X_ENROLMENT_LATEST_YR,
     x_course_cd => X_COURSE_CD,
     x_course_title => X_COURSE_TITLE,
     x_field_of_study => X_FIELD_OF_STUDY,
     x_language_component => X_LANGUAGE_COMPONENT,
     x_student_id => X_STUDENT_ID,
     x_equiv_full_time_yrs_enr => X_EQUIV_FULL_TIME_YRS_ENR,
     x_tertiary_edu_lvl_qual => X_TERTIARY_EDU_LVL_QUAL,
     x_qualification => X_QUALIFICATION,
     x_honours_level => X_HONOURS_LEVEL,
     x_level_of_achievement_type => X_LEVEL_OF_ACHIEVEMENT_TYPE,
     x_grade_point_average => X_GRADE_POINT_AVERAGE,
     x_language_of_tuition => X_LANGUAGE_OF_TUITION,
     x_state_cd => X_STATE_CD,
     x_country_cd => X_COUNTRY_CD,
     x_notes => X_NOTES,
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

  update IGS_AD_TER_EDU set
    TERTIARY_EDU_LVL_COMP = NEW_REFERENCES.TERTIARY_EDU_LVL_COMP,
    EXCLUSION_IND = NEW_REFERENCES.EXCLUSION_IND,
    INSTITUTION_CD = NEW_REFERENCES.INSTITUTION_CD,
    INSTITUTION_NAME = NEW_REFERENCES.INSTITUTION_NAME,
    ENROLMENT_FIRST_YR = NEW_REFERENCES.ENROLMENT_FIRST_YR,
    ENROLMENT_LATEST_YR = NEW_REFERENCES.ENROLMENT_LATEST_YR,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    COURSE_TITLE = NEW_REFERENCES.COURSE_TITLE,
    FIELD_OF_STUDY = NEW_REFERENCES.FIELD_OF_STUDY,
    LANGUAGE_COMPONENT = NEW_REFERENCES.LANGUAGE_COMPONENT,
    STUDENT_ID = NEW_REFERENCES.STUDENT_ID,
    EQUIV_FULL_TIME_YRS_ENR = NEW_REFERENCES.EQUIV_FULL_TIME_YRS_ENR,
    TERTIARY_EDU_LVL_QUAL = NEW_REFERENCES.TERTIARY_EDU_LVL_QUAL,
    QUALIFICATION = NEW_REFERENCES.QUALIFICATION,
    HONOURS_LEVEL = NEW_REFERENCES.HONOURS_LEVEL,
    LEVEL_OF_ACHIEVEMENT_TYPE = NEW_REFERENCES.LEVEL_OF_ACHIEVEMENT_TYPE,
    GRADE_POINT_AVERAGE = NEW_REFERENCES.GRADE_POINT_AVERAGE,
    LANGUAGE_OF_TUITION = NEW_REFERENCES.LANGUAGE_OF_TUITION,
    STATE_CD = NEW_REFERENCES.STATE_CD,
    COUNTRY_CD = NEW_REFERENCES.COUNTRY_CD,
    NOTES = NEW_REFERENCES.NOTES,
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
  X_PERSON_ID in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_TERTIARY_EDU_LVL_COMP in VARCHAR2,
  X_EXCLUSION_IND in VARCHAR2,
  X_INSTITUTION_CD in VARCHAR2,
  X_INSTITUTION_NAME in VARCHAR2,
  X_ENROLMENT_FIRST_YR in NUMBER,
  X_ENROLMENT_LATEST_YR in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_COURSE_TITLE in VARCHAR2,
  X_FIELD_OF_STUDY in VARCHAR2,
  X_LANGUAGE_COMPONENT in VARCHAR2,
  X_STUDENT_ID in VARCHAR2,
  X_EQUIV_FULL_TIME_YRS_ENR in NUMBER,
  X_TERTIARY_EDU_LVL_QUAL in VARCHAR2,
  X_QUALIFICATION in VARCHAR2,
  X_HONOURS_LEVEL in VARCHAR2,
  X_LEVEL_OF_ACHIEVEMENT_TYPE in VARCHAR2,
  X_GRADE_POINT_AVERAGE in NUMBER,
  X_LANGUAGE_OF_TUITION in VARCHAR2,
  X_STATE_CD in VARCHAR2,
  X_COUNTRY_CD in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AD_TER_EDU
     where PERSON_ID = X_PERSON_ID
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_SEQUENCE_NUMBER,
     X_TERTIARY_EDU_LVL_COMP,
     X_EXCLUSION_IND,
     X_INSTITUTION_CD,
     X_INSTITUTION_NAME,
     X_ENROLMENT_FIRST_YR,
     X_ENROLMENT_LATEST_YR,
     X_COURSE_CD,
     X_COURSE_TITLE,
     X_FIELD_OF_STUDY,
     X_LANGUAGE_COMPONENT,
     X_STUDENT_ID,
     X_EQUIV_FULL_TIME_YRS_ENR,
     X_TERTIARY_EDU_LVL_QUAL,
     X_QUALIFICATION,
     X_HONOURS_LEVEL,
     X_LEVEL_OF_ACHIEVEMENT_TYPE,
     X_GRADE_POINT_AVERAGE,
     X_LANGUAGE_OF_TUITION,
     X_STATE_CD,
     X_COUNTRY_CD,
     X_NOTES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_SEQUENCE_NUMBER,
   X_TERTIARY_EDU_LVL_COMP,
   X_EXCLUSION_IND,
   X_INSTITUTION_CD,
   X_INSTITUTION_NAME,
   X_ENROLMENT_FIRST_YR,
   X_ENROLMENT_LATEST_YR,
   X_COURSE_CD,
   X_COURSE_TITLE,
   X_FIELD_OF_STUDY,
   X_LANGUAGE_COMPONENT,
   X_STUDENT_ID,
   X_EQUIV_FULL_TIME_YRS_ENR,
   X_TERTIARY_EDU_LVL_QUAL,
   X_QUALIFICATION,
   X_HONOURS_LEVEL,
   X_LEVEL_OF_ACHIEVEMENT_TYPE,
   X_GRADE_POINT_AVERAGE,
   X_LANGUAGE_OF_TUITION,
   X_STATE_CD,
   X_COUNTRY_CD,
   X_NOTES,
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
  delete from IGS_AD_TER_EDU
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_AD_TER_EDU_PKG;

/
