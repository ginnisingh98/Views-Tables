--------------------------------------------------------
--  DDL for Package Body IGS_AD_SBM_PS_FNTRGT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SBM_PS_FNTRGT_PKG" as
/* $Header: IGSAI60B.pls 115.5 2003/10/30 13:21:04 rghosh ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_SBM_PS_FNTRGT%RowType;
  new_references IGS_AD_SBM_PS_FNTRGT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_SBM_PS_FNTRGT
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
    new_references.course_cd := x_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.funding_source := x_funding_source;
    new_references.sequence_number := x_sequence_number;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.unit_set_cd := x_unit_set_cd;
    new_references.us_version_number := x_us_version_number;
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
    ) AS
	v_message_name VARCHAR2(30);
  BEGIN
	-- Validate System Intake Target Type closed ind.
	IF p_inserting OR (old_references.funding_source <> new_references.funding_source) THEN
		IF IGS_AD_VAL_SAFT.crsp_val_fs_closed(
					new_references.funding_source,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the course version details.
	IF p_inserting OR
	    (old_references.course_cd <> new_references.course_cd) OR
	    (old_references.crv_version_number <> new_references.crv_version_number) THEN
		IF IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
					new_references.course_cd,
					new_references.crv_version_number,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		IF IGS_AD_VAL_SCFT.admp_val_scft_cop(
					new_references.submission_yr,
					new_references.submission_number,
					new_references.course_cd,
					new_references.crv_version_number,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate location_cd, attendance_mode and attendance_type
	IF p_inserting OR
	    (old_references.location_cd <> new_references.location_cd) OR
	    (old_references.attendance_mode <> new_references.attendance_mode) OR
	    (old_references.attendance_type <> new_references.attendance_type) THEN
		IF IGS_AD_VAL_SCFT.admp_val_scft_dtl(
					new_references.submission_yr,
					new_references.submission_number,
					new_references.course_cd,
					new_references.crv_version_number,
					new_references.location_cd,
					new_references.attendance_mode,
					new_references.attendance_type,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate unit set details
	IF p_inserting OR
	    (old_references.unit_set_cd <> new_references.unit_set_cd) OR
	    (old_references.us_version_number <> new_references.us_version_number) OR
	    (old_references.location_cd <> new_references.location_cd) OR
	    (old_references.attendance_mode <> new_references.attendance_mode) OR
	    (old_references.attendance_type <> new_references.attendance_type) THEN
		IF IGS_AD_VAL_SCFT.admp_val_scft_cous(
					new_references.course_cd,
					new_references.crv_version_number,
					new_references.unit_set_cd,
					new_references.us_version_number,
					new_references.location_cd,
					new_references.attendance_mode,
					new_references.attendance_type,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate funding source with funding source restrictions
	IF p_inserting OR
	    (old_references.course_cd <> new_references.course_cd) OR
	    (old_references.crv_version_number <> new_references.crv_version_number) OR
	    (old_references.funding_source <> new_references.funding_source) THEN
		IF IGS_AD_VAL_SCFT.admp_val_scft_fs(
					new_references.course_cd,
					new_references.crv_version_number,
					new_references.funding_source,
					v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name VARCHAR2(30);
  BEGIN
		IF  p_inserting OR p_updating THEN
  		 IF  IGS_AD_VAL_SCFT.admp_val_scft_uniq (
			new_references.submission_yr,
			new_references.submission_number,
			new_references.course_cd,
			new_references.crv_version_number,
			new_references.funding_source,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type,
			new_references.unit_set_cd,
  			new_references.us_version_number,
			v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS', v_message_name);
		    IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
  		END IF;
           END IF;
	END AfterRowInsertUpdate2;

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
	ELSIF upper(Column_Name) = 'ATTENDANCE_MODE' then
		new_references.attendance_mode := column_value;
	ELSIF upper(Column_Name) = 'ATTENDANCE_TYPE' then
		new_references.attendance_type := column_value;
	ELSIF upper(Column_Name) = 'COURSE_CD' then
		new_references.course_cd := column_value;
	ELSIF upper(Column_Name) = 'FUNDING_SOURCE' then
		new_references.funding_source := column_value;
	ELSIF upper(Column_Name) = 'LOCATION_CD' then
		new_references.location_cd := column_value;
	ELSIF upper(Column_Name) = 'UNIT_SET_CD' then
		new_references.unit_set_cd := column_value;
	END IF;

	IF upper(Column_Name) = 'SEQUENCE_NUMBER' OR Column_Name IS NULL THEN
		IF new_references.sequence_number < 1 OR new_references.sequence_number > 9999999999 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ATTENDANCE_MODE' OR Column_Name IS NULL THEN
		IF new_references.attendance_mode <> UPPER(new_references.attendance_mode) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ATTENDANCE_TYPE' OR Column_Name IS NULL THEN
		IF new_references.attendance_type <> UPPER(new_references.attendance_type) THEN
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
	IF upper(Column_Name) = 'FUNDING_SOURCE' OR Column_Name IS NULL THEN
		IF new_references.funding_source <> UPPER(new_references.funding_source) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'LOCATION_CD' OR Column_Name IS NULL THEN
		IF new_references.location_cd <> UPPER(new_references.location_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'UNIT_SET_CD' OR Column_Name IS NULL THEN
		IF new_references.unit_set_cd <> UPPER(new_references.unit_set_cd) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.attendance_mode = new_references.attendance_mode)) OR
        ((new_references.attendance_mode IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ATD_MODE_PKG.Get_PK_For_Validation (
        new_references.attendance_mode
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
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
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.crv_version_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

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

    IF (((old_references.location_cd = new_references.location_cd)) OR
        ((new_references.location_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_LOCATION_PKG.Get_PK_For_Validation (
        new_references.location_cd,
        'N'
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.unit_set_cd = new_references.unit_set_cd) AND
         (old_references.us_version_number = new_references.us_version_number)) OR
        ((new_references.unit_set_cd IS NULL) OR
         (new_references.us_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_UNIT_SET_PKG.Get_PK_For_Validation (
        new_references.unit_set_cd,
        new_references.us_version_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_SBMPS_FN_ITTT_PKG.GET_FK_IGS_AD_SBM_PS_FNTRGT (
      old_references.submission_yr,
      old_references.submission_number,
      old_references.course_cd,
      old_references.crv_version_number,
      old_references.funding_source,
      old_references.sequence_number
      );

  END Check_Child_Existance;

function Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_crv_version_number IN NUMBER,
    x_funding_source IN VARCHAR2,
    x_sequence_number IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      course_cd = x_course_cd
      AND      crv_version_number = x_crv_version_number
      AND      funding_source = x_funding_source
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

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    attendance_mode = x_attendance_mode ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_AM_FK');
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
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    course_cd = x_course_cd
      AND      crv_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;

  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    funding_source = x_funding_source ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;

      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_FS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_FUND_SRC;

  PROCEDURE GET_FK_IGS_ST_GVT_SPSHT_CTL (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_GSC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GVT_SPSHT_CTL;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_EN_UNIT_SET (
    x_unit_set_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBM_PS_FNTRGT
      WHERE    unit_set_cd = x_unit_set_cd
      AND      us_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SCFT_US_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_UNIT_SET;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_location_cd IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode IN VARCHAR2 DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_unit_set_cd IN VARCHAR2 DEFAULT NULL,
    x_us_version_number IN NUMBER DEFAULT NULL,
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
      x_course_cd,
      x_crv_version_number,
      x_funding_source,
      x_sequence_number,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_unit_set_cd,
      x_us_version_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.submission_yr,
		new_references.submission_number,
		new_references.course_cd,
		new_references.crv_version_number,
		new_references.funding_source,
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
		new_references.submission_yr,
		new_references.submission_number,
		new_references.course_cd,
		new_references.crv_version_number,
		new_references.funding_source,
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
  ) AS
  BEGIN
    l_rowid := x_rowid;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_SBM_PS_FNTRGT
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and COURSE_CD = X_COURSE_CD
      and CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER
      and FUNDING_SOURCE = X_FUNDING_SOURCE
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
  Before_DML (
     p_action => 'INSERT',
     x_rowid => X_ROWID,
     x_submission_yr => X_SUBMISSION_YR,
     x_submission_number => X_SUBMISSION_NUMBER,
     x_course_cd => X_COURSE_CD,
     x_crv_version_number => X_CRV_VERSION_NUMBER,
     x_funding_source => X_FUNDING_SOURCE,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_location_cd => X_LOCATION_CD,
     x_attendance_mode => X_ATTENDANCE_MODE,
     x_attendance_type => X_ATTENDANCE_TYPE,
     x_unit_set_cd => X_UNIT_SET_CD,
     x_us_version_number => X_US_VERSION_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );


  insert into IGS_AD_SBM_PS_FNTRGT (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    COURSE_CD,
    CRV_VERSION_NUMBER,
    FUNDING_SOURCE,
    SEQUENCE_NUMBER,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    UNIT_SET_CD,
    US_VERSION_NUMBER,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.UNIT_SET_CD,
    NEW_REFERENCES.US_VERSION_NUMBER,
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
     x_rowid => X_ROWID
    );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER
) AS
  cursor c1 is select
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      UNIT_SET_CD,
      US_VERSION_NUMBER
    from IGS_AD_SBM_PS_FNTRGT
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
      AND ((tlinfo.US_VERSION_NUMBER = X_US_VERSION_NUMBER)
           OR ((tlinfo.US_VERSION_NUMBER is null)
               AND (X_US_VERSION_NUMBER is null)))
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
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
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
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  Before_DML (
     p_action => 'UPDATE',
     x_rowid => X_ROWID,
     x_submission_yr => X_SUBMISSION_YR,
     x_submission_number => X_SUBMISSION_NUMBER,
     x_course_cd => X_COURSE_CD,
     x_crv_version_number => X_CRV_VERSION_NUMBER,
     x_funding_source => X_FUNDING_SOURCE,
     x_sequence_number => X_SEQUENCE_NUMBER,
     x_location_cd => X_LOCATION_CD,
     x_attendance_mode => X_ATTENDANCE_MODE,
     x_attendance_type => X_ATTENDANCE_TYPE,
     x_unit_set_cd => X_UNIT_SET_CD,
     x_us_version_number => X_US_VERSION_NUMBER,
     x_creation_date => X_LAST_UPDATE_DATE,
     x_created_by => X_LAST_UPDATED_BY,
     x_last_update_date => X_LAST_UPDATE_DATE,
     x_last_updated_by => X_LAST_UPDATED_BY,
     x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_SBM_PS_FNTRGT set
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    UNIT_SET_CD = NEW_REFERENCES.UNIT_SET_CD,
    US_VERSION_NUMBER = NEW_REFERENCES.US_VERSION_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
  X_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_FUNDING_SOURCE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_UNIT_SET_CD in VARCHAR2,
  X_US_VERSION_NUMBER in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_AD_SBM_PS_FNTRGT
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and COURSE_CD = X_COURSE_CD
     and CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER
     and FUNDING_SOURCE = X_FUNDING_SOURCE
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
     X_COURSE_CD,
     X_CRV_VERSION_NUMBER,
     X_FUNDING_SOURCE,
     X_SEQUENCE_NUMBER,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_UNIT_SET_CD,
     X_US_VERSION_NUMBER,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_COURSE_CD,
   X_CRV_VERSION_NUMBER,
   X_FUNDING_SOURCE,
   X_SEQUENCE_NUMBER,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_UNIT_SET_CD,
   X_US_VERSION_NUMBER,
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
  delete from IGS_AD_SBM_PS_FNTRGT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
     p_action => 'DELETE',
     x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_AD_SBM_PS_FNTRGT_PKG;

/
