--------------------------------------------------------
--  DDL for Package Body IGS_PS_PAT_OF_STUDY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_PAT_OF_STUDY_PKG" as
/* $Header: IGSPI61B.pls 115.6 2003/10/30 13:31:15 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PS_PAT_OF_STUDY%RowType;
  new_references IGS_PS_PAT_OF_STUDY%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_admission_cal_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_aprvd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_number_of_periods IN NUMBER DEFAULT NULL,
    x_always_pre_enrol_ind IN VARCHAR2 DEFAULT NULL,
    X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_PAT_OF_STUDY
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
    new_references.sequence_number := x_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.admission_cal_type := x_admission_cal_type;
    new_references.admission_cat := x_admission_cat;
    new_references.aprvd_ci_sequence_number := x_aprvd_ci_sequence_number;
    new_references.number_of_periods := x_number_of_periods;
    new_references.always_pre_enrol_ind := x_always_pre_enrol_ind;
    new_references.ACAD_PERD_UNIT_SET := x_ACAD_PERD_UNIT_SET;
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
	v_message_name		VARCHAR2(30);
  BEGIN
	-- Validate the insert/update/delete
	IF p_inserting OR p_updating THEN
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				new_references.course_cd,
				new_references.version_number,
				v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
		END IF;
	ELSE
		IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
				old_references.course_cd,
				old_references.version_number,
				v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the insert/update
	IF p_inserting OR p_updating THEN
		-- Validate the IGS_AD_LOCATION Code
		IF (new_references.location_cd IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.location_cd <> old_references.location_cd))) THEN
		   -- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_POS.crsp_val_loc_cd
			IF IGS_PS_VAL_UOO.crsp_val_loc_cd (
					new_references.location_cd,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the Attendance Mode
		IF (new_references.attendance_mode IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.attendance_mode <> old_references.attendance_mode))) THEN
			IF IGS_AD_VAL_APCOO.crsp_val_am_closed (
					new_references.attendance_mode,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the Attendance Type
		IF (new_references.attendance_type IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.attendance_type <> old_references.attendance_type))) THEN
			IF IGS_AD_VAL_APCOO.crsp_val_att_closed (
					new_references.attendance_type,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the IGS_PS_UNIT Set Code
		IF (new_references.unit_set_cd IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.unit_set_cd <> old_references.unit_set_cd))) THEN
			IF IGS_PS_VAL_POS.crsp_val_us_active (
					new_references.unit_set_cd,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the Admission Calendar Type
		IF (new_references.admission_cal_type IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.admission_cal_type <> old_references.admission_cal_type))) THEN
			IF IGS_PS_VAL_POS.crsp_val_pos_cat (
					new_references.admission_cal_type,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the Admission Category
		IF (new_references.admission_cat IS NOT NULL AND (p_inserting OR
		   (p_updating AND new_references.admission_cat <> old_references.admission_cat))) THEN
			IF IGS_PS_VAL_POS.crsp_val_ac_closed (
					new_references.admission_cat,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate the Aproved Calendar Instance
		IF (new_references.aprvd_ci_sequence_number IS NOT NULL AND
		    (p_inserting OR (p_updating AND
		   new_references.aprvd_ci_sequence_number <> old_references.aprvd_ci_sequence_number))) THEN
			IF IGS_AS_VAL_UAI.crsp_val_crs_ci (
					new_references.cal_type,
					new_references.aprvd_ci_sequence_number,
					v_message_name) = FALSE THEN
						Fnd_Message.Set_Name('IGS', v_message_name);
						IGS_GE_MSG_STACK.ADD;
						App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'ADMISSION_CAL_TYPE' then
     new_references.admission_cal_type := column_value;
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
 ELSIF upper(Column_name) = 'ALWAYS_PRE_ENROL_IND' then
     new_references.always_pre_enrol_ind := column_value;
 ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
     new_references.attendance_mode := column_value;
 ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
     new_references.attendance_type := column_value;
 ELSIF upper(Column_name) = 'CAL_TYPE' then
     new_references.cal_type := column_value;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'LOCATION_CD' then
     new_references.location_cd := column_value;
 ELSIF upper(Column_name) = 'UNIT_SET_CD' then
     new_references.unit_set_cd := column_value;
 ELSIF upper(Column_name) = 'APRVD_CI_SEQUENCE_NUMBER' then
     new_references.aprvd_ci_sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
     new_references.sequence_number := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'NUMBER_OF_PERIODS' then
     new_references.number_of_periods := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'VERSION_NUMBER' then
     new_references.version_number := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'ACAD_PERD_UNIT_SET' then
     new_references.ACAD_PERD_UNIT_SET := column_value ;
 END IF;

IF upper(column_name) = 'ADMISSION_CAL_TYPE' OR
     column_name is null Then
     IF new_references.admission_cal_type <> UPPER(new_references.admission_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADMISSION_CAT' OR
     column_name is null Then
     IF new_references.admission_cat <> UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_MODE' OR
     column_name is null Then
     IF new_references.attendance_mode <> UPPER(new_references.attendance_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_TYPE' OR
     column_name is null Then
     IF new_references.attendance_type <> UPPER(new_references.attendance_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF new_references.cal_type <> UPPER(new_references.cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.location_cd <> UPPER(new_references.location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'UNIT_SET_CD' OR
     column_name is null Then
     IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.sequence_number < 0 OR new_references.sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'NUMBER_OF_PERIODS' OR
     column_name is null Then
     IF new_references.number_of_periods < 1 OR new_references.number_of_periods > 99 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ALWAYS_PRE_ENROL_IND' OR
     column_name is null Then
     IF new_references.always_pre_enrol_ind NOT IN ('Y','N') THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'APRVD_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.aprvd_ci_sequence_number < 0 OR new_references.aprvd_ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'VERSION_NUMBER' OR
     column_name is null Then
     IF new_references.version_number < 0 OR new_references.version_number > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CAT_PKG.Get_PK_For_Validation (
        new_references.admission_cat ,
        'N'
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
    	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.attendance_type = new_references.attendance_type)) OR
        ((new_references.attendance_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_TYPE_PKG.Get_PK_For_Validation (
        new_references.attendance_type
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.admission_cal_type = new_references.admission_cal_type)) OR
        ((new_references.admission_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.admission_cal_type
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.aprvd_ci_sequence_number =
new_references.aprvd_ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.aprvd_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.aprvd_ci_sequence_number
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_OFR_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.cal_type
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd ,
        'N'
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PS_PAT_STUDY_PRD_PKG.GET_FK_IGS_PS_PAT_OF_STUDY (
      old_references.course_cd,
      old_references.version_number,
      old_references.cal_type,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
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

  PROCEDURE GET_FK_IGS_AD_CAT (
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_AC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CAT;

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    attendance_mode = x_attendance_mode ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_AM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_MODE;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    admission_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_CAT_ADM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    cal_type = x_cal_type
      AND      aprvd_ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_CI_APRVD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_CO_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_PAT_OF_STUDY
      WHERE    location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_POS_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_admission_cal_type IN VARCHAR2 DEFAULT NULL,
    x_admission_cat IN VARCHAR2 DEFAULT NULL,
    x_aprvd_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_number_of_periods IN NUMBER DEFAULT NULL,
    x_always_pre_enrol_ind IN VARCHAR2 DEFAULT NULL,
    X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
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
      x_sequence_number,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_unit_set_cd,
      x_admission_cal_type,
      x_admission_cat,
      x_aprvd_ci_sequence_number,
      x_number_of_periods,
      x_always_pre_enrol_ind,
      x_acad_perd_unit_set,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
		    	new_references.course_cd,
		      new_references.version_number,
		      new_references.cal_type,
		      new_references.sequence_number
			) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
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
       Check_Child_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
		    	new_references.course_cd,
		      new_references.version_number,
		      new_references.cal_type,
		      new_references.sequence_number
			) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
  ) AS
  BEGIN

    l_rowid := x_rowid;


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2 default NULL,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PS_PAT_OF_STUDY
      where COURSE_CD = X_COURSE_CD
      and CAL_TYPE = X_CAL_TYPE
      and VERSION_NUMBER = X_VERSION_NUMBER
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
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

  Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_admission_cal_type => X_ADMISSION_CAL_TYPE,
    x_admission_cat => X_ADMISSION_CAT,
    x_aprvd_ci_sequence_number => X_APRVD_CI_SEQUENCE_NUMBER,
    x_number_of_periods => NVL(X_NUMBER_OF_PERIODS,1),
    x_always_pre_enrol_ind => NVL(X_ALWAYS_PRE_ENROL_IND,'N'),
    X_ACAD_PERD_UNIT_SET =>  X_ACAD_PERD_UNIT_SET,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  insert into IGS_PS_PAT_OF_STUDY (
    COURSE_CD,
    VERSION_NUMBER,
    CAL_TYPE,
    SEQUENCE_NUMBER,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    UNIT_SET_CD,
    ADMISSION_CAL_TYPE,
    ADMISSION_CAT,
    APRVD_CI_SEQUENCE_NUMBER,
    NUMBER_OF_PERIODS,
    ALWAYS_PRE_ENROL_IND,
    ACAD_PERD_UNIT_SET,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.ADMISSION_CAL_TYPE,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.APRVD_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.NUMBER_OF_PERIODS,
    NEW_REFERENCES.ALWAYS_PRE_ENROL_IND,
    NEW_REFERENCES.ACAD_PERD_UNIT_SET ,
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
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2
) as
  cursor c1 is select
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      UNIT_SET_CD,
      ADMISSION_CAL_TYPE,
      ADMISSION_CAT,
      APRVD_CI_SEQUENCE_NUMBER,
      NUMBER_OF_PERIODS,
      ALWAYS_PRE_ENROL_IND,
      ACAD_PERD_UNIT_SET
    from IGS_PS_PAT_OF_STUDY
    where ROWID = X_ROWID for update nowait;
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

      if ( ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.UNIT_SET_CD = X_UNIT_SET_CD)
           OR ((tlinfo.UNIT_SET_CD is null)
               AND (X_UNIT_SET_CD is null)))
      AND ((tlinfo.ADMISSION_CAL_TYPE = X_ADMISSION_CAL_TYPE)
           OR ((tlinfo.ADMISSION_CAL_TYPE is null)
               AND (X_ADMISSION_CAL_TYPE is null)))
      AND ((tlinfo.ADMISSION_CAT = X_ADMISSION_CAT)
           OR ((tlinfo.ADMISSION_CAT is null)
               AND (X_ADMISSION_CAT is null)))
      AND ((tlinfo.APRVD_CI_SEQUENCE_NUMBER = X_APRVD_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.APRVD_CI_SEQUENCE_NUMBER is null)
               AND (X_APRVD_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ACAD_PERD_UNIT_SET = X_ACAD_PERD_UNIT_SET)
           OR ((tlinfo.ACAD_PERD_UNIT_SET is null)
               AND (X_ACAD_PERD_UNIT_SET is null)))
      AND (tlinfo.NUMBER_OF_PERIODS = X_NUMBER_OF_PERIODS)
      AND (tlinfo.ALWAYS_PRE_ENROL_IND = X_ALWAYS_PRE_ENROL_IND)
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
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2  default NULL,
  X_MODE in VARCHAR2 default 'R'
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
 Before_DML( p_action => 'UDPATE',
    x_rowid => X_ROWID,
    x_course_cd => X_COURSE_CD,
    x_version_number => X_VERSION_NUMBER,
    x_cal_type => X_CAL_TYPE,
    x_sequence_number => X_SEQUENCE_NUMBER,
    x_location_cd => X_LOCATION_CD,
    x_attendance_mode => X_ATTENDANCE_MODE,
    x_attendance_type => X_ATTENDANCE_TYPE,
    x_unit_set_cd => X_UNIT_SET_CD,
    x_admission_cal_type => X_ADMISSION_CAL_TYPE,
    x_admission_cat => X_ADMISSION_CAT,
    x_aprvd_ci_sequence_number => X_APRVD_CI_SEQUENCE_NUMBER,
    x_number_of_periods => X_NUMBER_OF_PERIODS,
    x_always_pre_enrol_ind => X_ALWAYS_PRE_ENROL_IND,
    x_acad_perd_unit_set => X_ACAD_PERD_UNIT_SET,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_PS_PAT_OF_STUDY set
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    UNIT_SET_CD = NEW_REFERENCES.UNIT_SET_CD,
    ADMISSION_CAL_TYPE = NEW_REFERENCES.ADMISSION_CAL_TYPE,
    ADMISSION_CAT = NEW_REFERENCES.ADMISSION_CAT,
    APRVD_CI_SEQUENCE_NUMBER = NEW_REFERENCES.APRVD_CI_SEQUENCE_NUMBER,
    NUMBER_OF_PERIODS = NEW_REFERENCES.NUMBER_OF_PERIODS,
    ALWAYS_PRE_ENROL_IND = NEW_REFERENCES.ALWAYS_PRE_ENROL_IND,
    ACAD_PERD_UNIT_SET = NEW_REFERENCES.ACAD_PERD_UNIT_SET,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
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
  X_COURSE_CD in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_ADMISSION_CAL_TYPE in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_APRVD_CI_SEQUENCE_NUMBER in NUMBER,
  X_NUMBER_OF_PERIODS in NUMBER,
  X_ALWAYS_PRE_ENROL_IND in VARCHAR2,
  X_ACAD_PERD_UNIT_SET in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PS_PAT_OF_STUDY
     where COURSE_CD = X_COURSE_CD
     and CAL_TYPE = X_CAL_TYPE
     and VERSION_NUMBER = X_VERSION_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_CAL_TYPE,
     X_VERSION_NUMBER,
     X_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_UNIT_SET_CD,
     X_ADMISSION_CAL_TYPE,
     X_ADMISSION_CAT,
     X_APRVD_CI_SEQUENCE_NUMBER,
     X_NUMBER_OF_PERIODS,
     X_ALWAYS_PRE_ENROL_IND,
     X_ACAD_PERD_UNIT_SET,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_CAL_TYPE,
   X_VERSION_NUMBER,
   X_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_UNIT_SET_CD,
   X_ADMISSION_CAL_TYPE,
   X_ADMISSION_CAT,
   X_APRVD_CI_SEQUENCE_NUMBER,
   X_NUMBER_OF_PERIODS,
   X_ALWAYS_PRE_ENROL_IND,
   X_ACAD_PERD_UNIT_SET,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
X_ROWID in VARCHAR2
) as
begin
 Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_PS_PAT_OF_STUDY
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_PAT_OF_STUDY_PKG;

/
