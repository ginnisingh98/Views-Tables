--------------------------------------------------------
--  DDL for Package Body IGS_PS_OFR_PAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_OFR_PAT_PKG" AS
/* $Header: IGSPI25B.pls 115.7 2002/11/29 02:13:15 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_OFR_PAT%RowType;
  new_references IGS_PS_OFR_PAT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_cop_id IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_offered_ind IN VARCHAR2 DEFAULT NULL,
    x_confirmed_offering_ind IN VARCHAR2 DEFAULT NULL,
    x_entry_point_ind IN VARCHAR2 DEFAULT NULL,
    x_pre_enrol_units_ind IN VARCHAR2 DEFAULT NULL,
    x_enrollable_ind IN VARCHAR2 DEFAULT NULL,
    x_ivrs_available_ind IN VARCHAR2 DEFAULT NULL,
    x_min_entry_ass_score IN NUMBER DEFAULT NULL,
    x_guaranteed_entry_ass_scr IN NUMBER DEFAULT NULL,
    x_max_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_max_cross_location_cp IN NUMBER DEFAULT NULL,
    x_max_cross_mode_cp IN NUMBER DEFAULT NULL,
    x_max_hist_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_adm_ass_officer_person_id IN NUMBER DEFAULT NULL,
    x_adm_contact_person_id IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_OFR_PAT
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
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.cal_type := x_cal_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.cop_id := x_cop_id;
    new_references.coo_id := x_coo_id;
    new_references.offered_ind := x_offered_ind;
    new_references.confirmed_offering_ind := x_confirmed_offering_ind;
    new_references.entry_point_ind := x_entry_point_ind;
    new_references.pre_enrol_units_ind := x_pre_enrol_units_ind;
    new_references.enrollable_ind := x_enrollable_ind;
    new_references.ivrs_available_ind := x_ivrs_available_ind;
    new_references.min_entry_ass_score := x_min_entry_ass_score;
    new_references.guaranteed_entry_ass_scr := x_guaranteed_entry_ass_scr;
    new_references.max_cross_faculty_cp := x_max_cross_faculty_cp;
    new_references.max_cross_location_cp := x_max_cross_location_cp;
    new_references.max_cross_mode_cp := x_max_cross_mode_cp;
    new_references.max_hist_cross_faculty_cp := x_max_hist_cross_faculty_cp;
    new_references.adm_ass_officer_person_id := x_adm_ass_officer_person_id;
    new_references.adm_contact_person_id := x_adm_contact_person_id;
    new_references.grading_schema_cd := x_grading_schema_cd;
    new_references.gs_version_number := x_gs_version_number;
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
  -- "OSS_TST".TRG_COP_BR_IUD
  -- BEFORE  INSERT  OR UPDATE  OR DELETE  ON IGS_PS_OFR_PAT
  -- REFERENCING
  --  NEW AS NEW
  --  OLD AS OLD
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_course_cd		IGS_PS_VER.course_cd%TYPE;
	v_version_number		IGS_PS_VER.version_number%TYPE;
	v_cal_type		IGS_PS_OFR_PAT.cal_type%TYPE;
	v_ci_sequence_number	IGS_PS_OFR_PAT.ci_sequence_number%TYPE;
  BEGIN

	-- Set IGS_PS_OFR_OPT key.
	IF p_inserting THEN
		IGS_PS_GEN_003.CRSP_GET_COO_KEY (
			new_references.coo_id,
			new_references.course_cd,
			new_references.version_number,
			new_references.cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type);
	END IF;
	-- Set variables
	IF p_inserting OR p_updating THEN
		v_course_cd := new_references.course_cd;
		v_version_number := new_references.version_number;
		v_cal_type := new_references.cal_type;
		v_ci_sequence_number := new_references.ci_sequence_number;
	ELSE	-- p_deleting
		v_course_cd := old_references.course_cd;
		v_version_number := old_references.version_number;
		v_cal_type := old_references.cal_type;
		v_ci_sequence_number := old_references.ci_sequence_number;
	END IF;
	-- Validate that IGS_PS_COURSE version is active
	IF IGS_PS_VAL_CRS.CRSP_VAL_IUD_CRV_DTL(
		v_course_cd,
		v_version_number,
		v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate calendar instance is active
	IF igs_as_val_uai.crsp_val_crs_ci (
		v_cal_type,
		v_ci_sequence_number,
		v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	-- Validate that inserts are allowed
	IF p_inserting THEN
		-- Validate IGS_PS_COURSE offering option
		-- IGS_GE_NOTE:crsp_val_iud_crv_dtl called from this function
		IF IGS_PS_VAL_COp.crsp_val_coo_inactiv (
			new_references.course_cd,
			new_references.version_number,
			new_references.cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF p_inserting OR p_updating THEN
		-- Validate entry assessment scores.
		IF IGS_PS_VAL_COI.crsp_val_ent_ass_scr(
			new_references.min_entry_ass_score,
			new_references.guaranteed_entry_ass_scr,
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE Check_Uniqueness
	AS
  BEGIN
	  IF Get_UK_For_Validation(
	     new_references.cop_id
	     )THEN
       	Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
       	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	  END IF;
  END Check_Uniqueness;

  PROCEDURE Check_Constraints(
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'ATTENDANCE_MODE' THEN
	   new_references.attendance_mode := column_value;
	ELSIF upper(column_name) = 'ATTENDANCE_TYPE' THEN
	   new_references.attendance_type := column_value;
	ELSIF upper(column_name) = 'CAL_TYPE' THEN
	   new_references.cal_type := column_value;
	ELSIF upper(column_name) = 'CONFIRMED_OFFERING_IND' THEN
	   new_references.confirmed_offering_ind := column_value;
	ELSIF upper(column_name) = 'COURSE_CD' THEN
	   new_references.course_cd := column_value;
	ELSIF upper(column_name) = 'ENROLLABLE_IND' THEN
	   new_references.enrollable_ind := column_value;
	ELSIF upper(column_name) = 'ENTRY_POINT_IND' THEN
	   new_references.entry_point_ind := column_value;
	ELSIF upper(column_name) = 'GRADING_SCHEMA_CD' THEN
	   new_references.grading_schema_cd := column_value;
	ELSIF upper(column_name) = 'IVRS_AVAILABLE_IND' THEN
	   new_references.ivrs_available_ind := column_value;
	ELSIF upper(column_name) = 'LOCATION_CD' THEN
	   new_references.location_cd := column_value;
	ELSIF upper(column_name) = 'OFFERED_IND' THEN
	   new_references.offered_ind := column_value;
	ELSIF upper(column_name) = 'PRE_ENROL_UNITS_IND' THEN
	   new_references.pre_enrol_units_ind := column_value;
	ELSIF upper(column_name) = 'MIN_ENTRY_ASS_SCORE' THEN
	   new_references.min_entry_ass_score := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'GUARANTEED_ENTRY_ASS_SCR' THEN
	   new_references.guaranteed_entry_ass_scr := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'MAX_CROSS_FACULTY_CP' THEN
	   new_references.max_cross_faculty_cp := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'MAX_CROSS_LOCATION_CP' THEN
	   new_references.max_cross_location_cp:= IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'MAX_CROSS_MODE_CP' THEN
	   new_references.max_cross_mode_cp := IGS_GE_NUMBER.TO_NUM(column_value);
	ELSIF upper(column_name) = 'MAX_HIST_CROSS_FACULTY_CP' THEN
	   new_references.max_hist_cross_faculty_cp := IGS_GE_NUMBER.TO_NUM(column_value);
	END IF;

	IF upper(column_name) = 'ATTENDANCE_MODE' OR
		column_name is null THEN
		IF new_references.attendance_mode <> UPPER(new_references.attendance_mode)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'ATTENDANCE_TYPE' OR
		column_name is null THEN
		IF new_references.attendance_type <> UPPER(new_references.attendance_type)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'CAL_TYPE' OR
		column_name is null THEN
		IF new_references.cal_type <> UPPER(new_references.cal_type)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_CD' OR
		column_name is null THEN
		IF new_references.course_cd <> UPPER(new_references.course_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
            	END IF;
	END IF;

	IF upper(column_name)= 'GRADING_SCHEMA_CD' OR
		column_name is null THEN
		IF new_references.grading_schema_cd <> UPPER(new_references.grading_schema_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'LOCATION_CD' OR
		column_name is null THEN
		IF new_references.location_cd <> UPPER(new_references.location_cd)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'PRE_ENROL_UNITS_IND' OR
		column_name is null THEN
		IF new_references.pre_enrol_units_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;


  	IF upper(column_name)= 'ENROLLABLE_IND' OR
		column_name is null THEN
		IF new_references.enrollable_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'IVRS_AVAILABLE_IND' OR
		column_name is null THEN
		IF new_references.ivrs_available_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'MIN_ENTRY_ASS_SCORE' OR
		column_name is null THEN
		IF new_references.min_entry_ass_score < 1 OR
		 new_references.min_entry_ass_score  > 999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;


	IF column_name is null THEN
		IF new_references.min_entry_ass_score > new_references.guaranteed_entry_ass_scr
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'GUARANTEED_ENTRY_ASS_SCR' OR
		column_name is null THEN
		IF new_references.guaranteed_entry_ass_scr <1 OR
		 new_references.guaranteed_entry_ass_scr > 999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'MAX_CROSS_FACULTY_CP' OR
		column_name is null THEN
		IF new_references.max_cross_faculty_cp <0.001 OR    --Changes as per Bug# 2022150
		 new_references.max_cross_faculty_cp > 999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'MAX_CROSS_LOCATION_CP' OR
		column_name is null THEN
		IF new_references.max_cross_location_cp <0.001  OR
		 new_references.max_cross_location_cp > 999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'MAX_CROSS_MODE_CP' OR
		column_name is null THEN
		IF new_references.max_cross_mode_cp < 0.001  OR
		 new_references.max_cross_mode_cp > 999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'MAX_HIST_CROSS_FACULTY_CP' OR
		column_name is null THEN
		IF new_references.max_hist_cross_faculty_cp < 0.001  OR
		 new_references.max_hist_cross_faculty_cp > 999.999
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'OFFERED_IND' OR
		column_name is null THEN
		IF new_references.offered_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'CONFIRMED_OFFERING_IND' OR
		column_name is null THEN
		IF new_references.confirmed_offering_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'ENTRY_POINT_IND' OR
		column_name is null THEN
		IF new_references.entry_point_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_PS_OFR_INST_PKG.Get_PK_For_Validation(
		new_references.course_cd,
		new_references.version_number,
		new_references.cal_type,
 		new_references.ci_sequence_number
		)THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.location_cd = new_references.location_cd) AND
         (old_references.attendance_mode = new_references.attendance_mode) AND
         (old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.location_cd IS NULL) OR
         (new_references.attendance_mode IS NULL) OR
         (new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type,
        new_references.location_cd,
        new_references.attendance_mode,
        new_references.attendance_type
        )THEN
	  	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	  	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.coo_id = new_references.coo_id)) OR
        ((new_references.coo_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_OPT_PKG.Get_UK_For_Validation (
        new_references.coo_id
        )THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.grading_schema_cd = new_references.grading_schema_cd) AND
         (old_references.gs_version_number = new_references.gs_version_number)) OR
        ((new_references.grading_schema_cd IS NULL) OR
         (new_references.gs_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AS_GRD_SCHEMA_PKG.Get_PK_For_Validation (
        new_references.grading_schema_cd,
        new_references.gs_version_number
        )THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_ass_officer_person_id = new_references.adm_ass_officer_person_id)) OR
        ((new_references.adm_ass_officer_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.adm_ass_officer_person_id
        )THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_contact_person_id = new_references.adm_contact_person_id)) OR
        ((new_references.adm_contact_person_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
        new_references.adm_contact_person_id
        )THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_OFR_PAT_NOTE_PKG.GET_UFK_IGS_PS_OFR_PAT(
      old_references.cop_id
      );

    IGS_PS_OFR_PAT_NOTE_PKG.GET_FK_IGS_PS_OFR_PAT(
     old_references.course_cd,
     old_references.version_number,
     old_references.cal_type,
     old_references.ci_sequence_number,
     old_references.location_cd,
     old_references.attendance_mode,
     old_references.attendance_type
      );

  END Check_Child_Existance;

  PROCEDURE Check_UK_Child_Existance IS
  BEGIN
		IF (((old_references.cop_id = new_references.cop_id)) OR
		((old_references.cop_id IS NULL)))THEN
		NULL;
		ELSE
		IGS_PS_OFR_PAT_NOTE_PKG.GET_UFK_IGS_PS_OFR_PAT(old_references.cop_id
		);
		END IF;
  END Check_UK_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type
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

  FUNCTION Get_UK_For_Validation (
    x_cop_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    cop_id = x_cop_id
	AND (l_rowid IS NULL OR rowid <> l_rowid)

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

  END Get_UK_For_Validation;


  PROCEDURE GET_FK_IGS_PS_OFR_INST (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;
  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COP_COI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_INST;

  PROCEDURE GET_FK_IGS_PS_OFR_OPT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_location_cd IN VARCHAR2,
    x_attendance_mode IN VARCHAR2,
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      location_cd = x_location_cd
      AND      attendance_mode = x_attendance_mode
      AND      attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COP_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR_OPT;

  PROCEDURE GET_UFK_IGS_PS_OFR_OPT (
    x_coo_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    coo_id = x_coo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COP_COO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_UFK_IGS_PS_OFR_OPT;

  PROCEDURE GET_FK_IGS_AS_GRD_SCHEMA (
    x_grading_schema_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    grading_schema_cd = x_grading_schema_cd
      AND      gs_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COP_GS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AS_GRD_SCHEMA;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_OFR_PAT
      WHERE    (adm_ass_officer_person_id = x_person_id )
 	OR	   (adm_contact_person_id = x_person_id );

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_COP_PE_AAO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_cop_id IN NUMBER DEFAULT NULL,
    x_coo_id IN NUMBER DEFAULT NULL,
    x_offered_ind IN VARCHAR2 DEFAULT NULL,
    x_confirmed_offering_ind IN VARCHAR2 DEFAULT NULL,
    x_entry_point_ind IN VARCHAR2 DEFAULT NULL,
    x_pre_enrol_units_ind IN VARCHAR2 DEFAULT NULL,
    x_enrollable_ind IN VARCHAR2 DEFAULT NULL,
    x_ivrs_available_ind IN VARCHAR2 DEFAULT NULL,
    x_min_entry_ass_score IN NUMBER DEFAULT NULL,
    x_guaranteed_entry_ass_scr IN NUMBER DEFAULT NULL,
    x_max_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_max_cross_location_cp IN NUMBER DEFAULT NULL,
    x_max_cross_mode_cp IN NUMBER DEFAULT NULL,
    x_max_hist_cross_faculty_cp IN NUMBER DEFAULT NULL,
    x_adm_ass_officer_person_id IN NUMBER DEFAULT NULL,
    x_adm_contact_person_id IN NUMBER DEFAULT NULL,
    x_grading_schema_cd IN VARCHAR2 DEFAULT NULL,
    x_gs_version_number IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_cop_id,
      x_coo_id,
      x_offered_ind,
      x_confirmed_offering_ind,
      x_entry_point_ind,
      x_pre_enrol_units_ind,
      x_enrollable_ind,
      x_ivrs_available_ind,
      x_min_entry_ass_score,
      x_guaranteed_entry_ass_scr,
      x_max_cross_faculty_cp,
      x_max_cross_location_cp,
      x_max_cross_mode_cp,
      x_max_hist_cross_faculty_cp,
      x_adm_ass_officer_person_id,
      x_adm_contact_person_id,
      x_grading_schema_cd,
      x_gs_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number ,
    		new_references.cal_type ,
    		new_references.ci_sequence_number ,
    		new_references.location_cd ,
    		new_references.attendance_mode ,
    		new_references.attendance_type
	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Uniqueness;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );
      Check_Uniqueness;
	Check_Constraints;
      Check_Parent_Existance;
	Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_cd ,
    		new_references.version_number ,
    		new_references.cal_type ,
    		new_references.ci_sequence_number ,
    		new_references.location_cd ,
    		new_references.attendance_mode ,
    		new_references.attendance_type
	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Uniqueness;
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
	Check_Constraints;
	Check_UK_Child_Existance;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    l_rowid:=NULL;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PS_OFR_PAT
      where COURSE_CD = X_COURSE_CD
      and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
      and CAL_TYPE = X_CAL_TYPE
      and VERSION_NUMBER = X_VERSION_NUMBER
      and LOCATION_CD = X_LOCATION_CD
      and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
      and ATTENDANCE_MODE = X_ATTENDANCE_MODE;
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
    X_PROGRAM_ID :=  FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    IF (X_REQUEST_ID = -1) THEN
	 X_REQUEST_ID := NULL;
	 X_PROGRAM_ID := NULL;
	 X_PROGRAM_APPLICATION_ID := NULL;
       X_PROGRAM_UPDATE_DATE := NULL;
    ELSE
	 X_PROGRAM_UPDATE_DATE := SYSDATE;
    END IF;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
Before_DML (
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_cop_id => X_COP_ID,
    x_coo_id => X_COO_ID,
    x_offered_ind => NVL(X_OFFERED_IND,'N'),
    x_confirmed_offering_ind => NVL(X_CONFIRMED_OFFERING_IND,'Y'),
    x_entry_point_ind => NVL(X_ENTRY_POINT_IND,'Y'),
    x_pre_enrol_units_ind => NVL(X_PRE_ENROL_UNITS_IND,'Y'),
    x_enrollable_ind => NVL(X_ENROLLABLE_IND,'Y'),
    x_ivrs_available_ind => NVL(X_IVRS_AVAILABLE_IND,'Y'),
    x_min_entry_ass_score => X_MIN_ENTRY_ASS_SCORE ,
    x_guaranteed_entry_ass_scr => X_GUARANTEED_ENTRY_ASS_SCR ,
    x_max_cross_faculty_cp => X_MAX_CROSS_FACULTY_CP ,
    x_max_cross_location_cp => X_MAX_CROSS_LOCATION_CP ,
    x_max_cross_mode_cp => X_MAX_CROSS_MODE_CP ,
    x_max_hist_cross_faculty_cp => X_MAX_HIST_CROSS_FACULTY_CP ,
    x_adm_ass_officer_person_id => X_ADM_ASS_OFFICER_PERSON_ID ,
    x_adm_contact_person_id => X_ADM_CONTACT_PERSON_ID ,
    x_grading_schema_cd => X_GRADING_SCHEMA_CD ,
    x_gs_version_number => X_GS_VERSION_NUMBER ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
    x_last_update_login => X_LAST_UPDATE_LOGIN
 );

  insert into IGS_PS_OFR_PAT (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    COP_ID,
    COO_ID,
    OFFERED_IND,
    CONFIRMED_OFFERING_IND,
    ENTRY_POINT_IND,
    PRE_ENROL_UNITS_IND,
    ENROLLABLE_IND,
    IVRS_AVAILABLE_IND,
    MIN_ENTRY_ASS_SCORE,
    GUARANTEED_ENTRY_ASS_SCR,
    MAX_CROSS_FACULTY_CP,
    MAX_CROSS_LOCATION_CP,
    MAX_CROSS_MODE_CP,
    MAX_HIST_CROSS_FACULTY_CP,
    ADM_ASS_OFFICER_PERSON_ID,
    ADM_CONTACT_PERSON_ID,
    GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER,
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
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.COP_ID,
    NEW_REFERENCES.COO_ID,
    NEW_REFERENCES.OFFERED_IND,
    NEW_REFERENCES.CONFIRMED_OFFERING_IND,
    NEW_REFERENCES.ENTRY_POINT_IND,
    NEW_REFERENCES.PRE_ENROL_UNITS_IND,
    NEW_REFERENCES.ENROLLABLE_IND,
    NEW_REFERENCES.IVRS_AVAILABLE_IND,
    NEW_REFERENCES.MIN_ENTRY_ASS_SCORE,
    NEW_REFERENCES.GUARANTEED_ENTRY_ASS_SCR,
    NEW_REFERENCES.MAX_CROSS_FACULTY_CP,
    NEW_REFERENCES.MAX_CROSS_LOCATION_CP,
    NEW_REFERENCES.MAX_CROSS_MODE_CP,
    NEW_REFERENCES.MAX_HIST_CROSS_FACULTY_CP,
    NEW_REFERENCES.ADM_ASS_OFFICER_PERSON_ID,
    NEW_REFERENCES.ADM_CONTACT_PERSON_ID,
    NEW_REFERENCES.GRADING_SCHEMA_CD,
    NEW_REFERENCES.GS_VERSION_NUMBER,
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
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER
) AS
  cursor c1 is select
      COP_ID,
      COO_ID,
      OFFERED_IND,
      CONFIRMED_OFFERING_IND,
      ENTRY_POINT_IND,
      PRE_ENROL_UNITS_IND,
      ENROLLABLE_IND,
      IVRS_AVAILABLE_IND,
      MIN_ENTRY_ASS_SCORE,
      GUARANTEED_ENTRY_ASS_SCR,
      MAX_CROSS_FACULTY_CP,
      MAX_CROSS_LOCATION_CP,
      MAX_CROSS_MODE_CP,
      MAX_HIST_CROSS_FACULTY_CP,
      ADM_ASS_OFFICER_PERSON_ID,
      ADM_CONTACT_PERSON_ID,
      GRADING_SCHEMA_CD,
      GS_VERSION_NUMBER
    from IGS_PS_OFR_PAT
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

  if ( (tlinfo.COP_ID = X_COP_ID)
      AND (tlinfo.COO_ID = X_COO_ID)
      AND (tlinfo.OFFERED_IND = X_OFFERED_IND)
      AND (tlinfo.CONFIRMED_OFFERING_IND = X_CONFIRMED_OFFERING_IND)
      AND (tlinfo.ENTRY_POINT_IND = X_ENTRY_POINT_IND)
      AND (tlinfo.PRE_ENROL_UNITS_IND = X_PRE_ENROL_UNITS_IND)
      AND (tlinfo.ENROLLABLE_IND = X_ENROLLABLE_IND)
      AND (tlinfo.IVRS_AVAILABLE_IND = X_IVRS_AVAILABLE_IND)
      AND ((tlinfo.MIN_ENTRY_ASS_SCORE = X_MIN_ENTRY_ASS_SCORE)
           OR ((tlinfo.MIN_ENTRY_ASS_SCORE is null)
               AND (X_MIN_ENTRY_ASS_SCORE is null)))
      AND ((tlinfo.GUARANTEED_ENTRY_ASS_SCR = X_GUARANTEED_ENTRY_ASS_SCR)
           OR ((tlinfo.GUARANTEED_ENTRY_ASS_SCR is null)
               AND (X_GUARANTEED_ENTRY_ASS_SCR is null)))
      AND ((tlinfo.MAX_CROSS_FACULTY_CP = X_MAX_CROSS_FACULTY_CP)
           OR ((tlinfo.MAX_CROSS_FACULTY_CP is null)
               AND (X_MAX_CROSS_FACULTY_CP is null)))
      AND ((tlinfo.MAX_CROSS_LOCATION_CP = X_MAX_CROSS_LOCATION_CP)
           OR ((tlinfo.MAX_CROSS_LOCATION_CP is null)
               AND (X_MAX_CROSS_LOCATION_CP is null)))
      AND ((tlinfo.MAX_CROSS_MODE_CP = X_MAX_CROSS_MODE_CP)
           OR ((tlinfo.MAX_CROSS_MODE_CP is null)
               AND (X_MAX_CROSS_MODE_CP is null)))
      AND ((tlinfo.MAX_HIST_CROSS_FACULTY_CP = X_MAX_HIST_CROSS_FACULTY_CP)
           OR ((tlinfo.MAX_HIST_CROSS_FACULTY_CP is null)
               AND (X_MAX_HIST_CROSS_FACULTY_CP is null)))
      AND ((tlinfo.ADM_ASS_OFFICER_PERSON_ID = X_ADM_ASS_OFFICER_PERSON_ID)
           OR ((tlinfo.ADM_ASS_OFFICER_PERSON_ID is null)
               AND (X_ADM_ASS_OFFICER_PERSON_ID is null)))
      AND ((tlinfo.ADM_CONTACT_PERSON_ID = X_ADM_CONTACT_PERSON_ID)
           OR ((tlinfo.ADM_CONTACT_PERSON_ID is null)
               AND (X_ADM_CONTACT_PERSON_ID is null)))
      AND ((tlinfo.GRADING_SCHEMA_CD = X_GRADING_SCHEMA_CD)
           OR ((tlinfo.GRADING_SCHEMA_CD is null)
               AND (X_GRADING_SCHEMA_CD is null)))
      AND ((tlinfo.GS_VERSION_NUMBER = X_GS_VERSION_NUMBER)
           OR ((tlinfo.GS_VERSION_NUMBER is null)
               AND (X_GS_VERSION_NUMBER is null)))
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
  X_ROWID IN VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
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
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_ci_sequence_number => X_CI_SEQUENCE_NUMBER,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_cop_id => X_COP_ID,
    x_coo_id => X_COO_ID,
    x_offered_ind => X_OFFERED_IND,
    x_confirmed_offering_ind => X_CONFIRMED_OFFERING_IND ,
    x_entry_point_ind => X_ENTRY_POINT_IND ,
    x_pre_enrol_units_ind => X_PRE_ENROL_UNITS_IND ,
    x_enrollable_ind => X_ENROLLABLE_IND ,
    x_ivrs_available_ind => X_IVRS_AVAILABLE_IND ,
    x_min_entry_ass_score => X_MIN_ENTRY_ASS_SCORE ,
    x_guaranteed_entry_ass_scr => X_GUARANTEED_ENTRY_ASS_SCR ,
    x_max_cross_faculty_cp => X_MAX_CROSS_FACULTY_CP ,
    x_max_cross_location_cp => X_MAX_CROSS_LOCATION_CP ,
    x_max_cross_mode_cp => X_MAX_CROSS_MODE_CP ,
    x_max_hist_cross_faculty_cp => X_MAX_HIST_CROSS_FACULTY_CP ,
    x_adm_ass_officer_person_id => X_ADM_ASS_OFFICER_PERSON_ID ,
    x_adm_contact_person_id => X_ADM_CONTACT_PERSON_ID ,
    x_grading_schema_cd => X_GRADING_SCHEMA_CD ,
    x_gs_version_number => X_GS_VERSION_NUMBER ,
    x_creation_date => X_LAST_UPDATE_DATE  ,
    x_created_by => X_LAST_UPDATED_BY ,
    x_last_update_date => X_LAST_UPDATE_DATE  ,
    x_last_updated_by => X_LAST_UPDATED_BY ,
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


  update IGS_PS_OFR_PAT set
    COP_ID = NEW_REFERENCES.COP_ID,
    COO_ID = NEW_REFERENCES.COO_ID,
    OFFERED_IND = NEW_REFERENCES.OFFERED_IND,
    CONFIRMED_OFFERING_IND = NEW_REFERENCES.CONFIRMED_OFFERING_IND,
    ENTRY_POINT_IND = NEW_REFERENCES.ENTRY_POINT_IND,
    PRE_ENROL_UNITS_IND = NEW_REFERENCES.PRE_ENROL_UNITS_IND,
    ENROLLABLE_IND = NEW_REFERENCES.ENROLLABLE_IND,
    IVRS_AVAILABLE_IND = NEW_REFERENCES.IVRS_AVAILABLE_IND,
    MIN_ENTRY_ASS_SCORE = NEW_REFERENCES.MIN_ENTRY_ASS_SCORE,
    GUARANTEED_ENTRY_ASS_SCR = NEW_REFERENCES.GUARANTEED_ENTRY_ASS_SCR,
    MAX_CROSS_FACULTY_CP = NEW_REFERENCES.MAX_CROSS_FACULTY_CP,
    MAX_CROSS_LOCATION_CP = NEW_REFERENCES.MAX_CROSS_LOCATION_CP,
    MAX_CROSS_MODE_CP = NEW_REFERENCES.MAX_CROSS_MODE_CP,
    MAX_HIST_CROSS_FACULTY_CP = NEW_REFERENCES.MAX_HIST_CROSS_FACULTY_CP,
    ADM_ASS_OFFICER_PERSON_ID = NEW_REFERENCES.ADM_ASS_OFFICER_PERSON_ID,
    ADM_CONTACT_PERSON_ID = NEW_REFERENCES.ADM_CONTACT_PERSON_ID,
    GRADING_SCHEMA_CD = NEW_REFERENCES.GRADING_SCHEMA_CD,
    GS_VERSION_NUMBER = NEW_REFERENCES.GS_VERSION_NUMBER,
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
  X_COURSE_CD in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_COP_ID in NUMBER,
  X_COO_ID in NUMBER,
  X_OFFERED_IND in VARCHAR2,
  X_CONFIRMED_OFFERING_IND in VARCHAR2,
  X_ENTRY_POINT_IND in VARCHAR2,
  X_PRE_ENROL_UNITS_IND in VARCHAR2,
  X_ENROLLABLE_IND in VARCHAR2,
  X_IVRS_AVAILABLE_IND in VARCHAR2,
  X_MIN_ENTRY_ASS_SCORE in NUMBER,
  X_GUARANTEED_ENTRY_ASS_SCR in NUMBER,
  X_MAX_CROSS_FACULTY_CP in NUMBER,
  X_MAX_CROSS_LOCATION_CP in NUMBER,
  X_MAX_CROSS_MODE_CP in NUMBER,
  X_MAX_HIST_CROSS_FACULTY_CP in NUMBER,
  X_ADM_ASS_OFFICER_PERSON_ID in NUMBER,
  X_ADM_CONTACT_PERSON_ID in NUMBER,
  X_GRADING_SCHEMA_CD in VARCHAR2,
  X_GS_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PS_OFR_PAT
     where COURSE_CD = X_COURSE_CD
     and CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER
     and CAL_TYPE = X_CAL_TYPE
     and VERSION_NUMBER = X_VERSION_NUMBER
     and LOCATION_CD = X_LOCATION_CD
     and ATTENDANCE_TYPE = X_ATTENDANCE_TYPE
     and ATTENDANCE_MODE = X_ATTENDANCE_MODE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_CI_SEQUENCE_NUMBER,
     X_CAL_TYPE,
     X_VERSION_NUMBER,
     X_LOCATION_CD,
     X_ATTENDANCE_TYPE,
     X_ATTENDANCE_MODE,
     X_COP_ID,
     X_COO_ID,
     X_OFFERED_IND,
     X_CONFIRMED_OFFERING_IND,
     X_ENTRY_POINT_IND,
     X_PRE_ENROL_UNITS_IND,
     X_ENROLLABLE_IND,
     X_IVRS_AVAILABLE_IND,
     X_MIN_ENTRY_ASS_SCORE,
     X_GUARANTEED_ENTRY_ASS_SCR,
     X_MAX_CROSS_FACULTY_CP,
     X_MAX_CROSS_LOCATION_CP,
     X_MAX_CROSS_MODE_CP,
     X_MAX_HIST_CROSS_FACULTY_CP,
     X_ADM_ASS_OFFICER_PERSON_ID,
     X_ADM_CONTACT_PERSON_ID,
     X_GRADING_SCHEMA_CD,
     X_GS_VERSION_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_CI_SEQUENCE_NUMBER,
   X_CAL_TYPE,
   X_VERSION_NUMBER,
   X_LOCATION_CD,
   X_ATTENDANCE_TYPE,
   X_ATTENDANCE_MODE,
   X_COP_ID,
   X_COO_ID,
   X_OFFERED_IND,
   X_CONFIRMED_OFFERING_IND,
   X_ENTRY_POINT_IND,
   X_PRE_ENROL_UNITS_IND,
   X_ENROLLABLE_IND,
   X_IVRS_AVAILABLE_IND,
   X_MIN_ENTRY_ASS_SCORE,
   X_GUARANTEED_ENTRY_ASS_SCR,
   X_MAX_CROSS_FACULTY_CP,
   X_MAX_CROSS_LOCATION_CP,
   X_MAX_CROSS_MODE_CP,
   X_MAX_HIST_CROSS_FACULTY_CP,
   X_ADM_ASS_OFFICER_PERSON_ID,
   X_ADM_CONTACT_PERSON_ID,
   X_GRADING_SCHEMA_CD,
   X_GS_VERSION_NUMBER,
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
  delete from IGS_PS_OFR_PAT
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
	p_action => 'DELETE',
	x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_PS_OFR_PAT_PKG;

/
