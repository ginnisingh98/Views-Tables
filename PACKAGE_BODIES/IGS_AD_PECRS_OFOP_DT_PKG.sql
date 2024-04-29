--------------------------------------------------------
--  DDL for Package Body IGS_AD_PECRS_OFOP_DT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PECRS_OFOP_DT_PKG" AS
/* $Header: IGSAI35B.pls 115.7 2003/10/30 13:19:57 rghosh ship $*/
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PECRS_OFOP_DT%RowType;
  new_references IGS_AD_PECRS_OFOP_DT%RowType;
  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_adm_cal_type IN VARCHAR2 ,
    x_adm_ci_sequence_number IN NUMBER ,
    x_admission_cat IN VARCHAR2 ,
    x_dt_alias IN VARCHAR2 ,
    x_dai_sequence_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_acad_cal_type IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_rollover_inclusion_ind IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PECRS_OFOP_DT
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
    new_references.adm_cal_type := x_adm_cal_type;
    new_references.adm_ci_sequence_number := x_adm_ci_sequence_number;
    new_references.admission_cat := x_admission_cat;
    new_references.dt_alias := x_dt_alias;
    new_references.dai_sequence_number := x_dai_sequence_number;
    new_references.sequence_number := x_sequence_number;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.acad_cal_type := x_acad_cal_type;
    new_references.location_cd := x_location_cd;
    new_references.attendance_mode := x_attendance_mode;
    new_references.attendance_type := x_attendance_type;
    new_references.rollover_inclusion_ind := x_rollover_inclusion_ind;
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
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
	v_cal_type	IGS_CA_INST.cal_type%TYPE;
	v_sequence_number IGS_CA_INST.sequence_number%TYPE;
	v_start_dt	IGS_CA_INST.start_dt%TYPE;
	v_end_dt		IGS_CA_INST.end_dt%TYPE;
	v_alternate_code	IGS_CA_INST.alternate_code%TYPE;
  BEGIN
	-- Validate that the admission period is not inactive
	IF p_inserting OR p_updating THEN
		v_cal_type := new_references.adm_cal_type;
		v_sequence_number := new_references.adm_ci_sequence_number;
	ELSE	-- must be p_deleting
		v_cal_type := old_references.adm_cal_type;
		v_sequence_number := old_references.adm_ci_sequence_number;
	END IF;
	IF IGS_AD_VAL_APAC.admp_val_adm_ci(
		v_cal_type,
		v_sequence_number,
		v_start_dt,
		v_end_dt,
		v_alternate_code,
		v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	IF p_inserting OR p_updating THEN
		/* Partial rollover is now handled
		-- Set rollover inclusion indicator to 'N', this functionality is
		-- currently not available
		IF new_references.rollover_inclusion_ind = 'Y' THEN
			new_references.rollover_inclusion_ind := 'N';
		END IF;*/
		-- Validate admission period date alias
		IF IGS_AD_VAL_APCOOD.admp_val_apcood_da(
			new_references.dt_alias,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
		-- Validate admission period date course offering
		IF new_references.course_cd IS NOT NULL THEN
			IF IGS_AD_VAL_APCOOD.admp_val_apcood_co(
				new_references.course_cd,
				new_references.version_number,
				new_references.acad_cal_type,
				new_references.admission_cat,
				new_references.s_admission_process_type,
				new_references.adm_cal_type,
				new_references.adm_ci_sequence_number,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
			END IF;
		END IF;
		-- Validate admission period date course offering option components
		IF IGS_AD_VAL_APCOOD.admp_val_apcood_opt(
			new_references.course_cd,
			new_references.version_number,
			new_references.acad_cal_type,
			new_references.location_cd,
			new_references.attendance_mode,
			new_references.attendance_type,
			new_references.adm_cal_type,
			new_references.adm_ci_sequence_number,
			new_references.admission_cat,
			new_references.s_admission_process_type,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    v_message_name VARCHAR2(30);
  BEGIN
  		IF p_inserting OR	p_updating THEN
  			-- Validate inserting/updating the admission period IGS_PS_COURSE offering option
  			-- date
  			IF IGS_AD_VAL_APCOOD.admp_val_apcood_ins(
  				new_references.adm_cal_type,
  				new_references.adm_ci_sequence_number,
  				new_references.admission_cat,
  				new_references.dt_alias,
  				new_references.dai_sequence_number,
  				new_references.sequence_number,
  				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
  			END IF;
  			IF IGS_AD_VAL_APCOOD.admp_val_apcood_link (
  				new_references.adm_cal_type,
  				new_references.adm_ci_sequence_number,
  				new_references.admission_cat,
  				new_references.dt_alias,
  				new_references.dai_sequence_number,
  				new_references.sequence_number,
  				new_references.s_admission_process_type,
  				new_references.course_cd,
  				new_references.version_number,
  				new_references.acad_cal_type,
  				new_references.location_cd,
  				new_references.attendance_mode,
  				new_references.attendance_type,
  				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
  			END IF;
  		END IF;
  END AfterRowInsertUpdate2;

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2	,
	 Column_Value 	IN	VARCHAR2
)
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'DT_ALIAS' then
     new_references.dt_alias := column_value;
 ELSIF upper(Column_name) = 'ADM_CAL_TYPE' then
     new_references.adm_cal_type := column_value;
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
 ELSIF upper(Column_name) = 'S_ADMISSION_PROCESS_TYPE' then
     new_references.s_admission_process_type := column_value;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'ACAD_CAL_TYPE' then
     new_references.acad_cal_type := column_value;
 ELSIF upper(Column_name) = 'LOCATION_CD' then
     new_references.location_cd := column_value;
 ELSIF upper(Column_name) = 'ATTENDANCE_MODE' then
     new_references.attendance_mode := column_value;
 ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' then
     new_references.attendance_type := column_value;
 ELSIF upper(Column_name) = 'ADM_CI_SEQUENCE_NUMBER' then
     new_references.adm_ci_sequence_number  := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'DAI_SEQUENCE_NUMBER' then
     new_references.dai_sequence_number  := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'SEQUENCE_NUMBER' then
     new_references.sequence_number  := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'VERSION_NUMBER' then
     new_references.version_number := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'ROLLOVER_INCLUSION_IND' then
     new_references.rollover_inclusion_ind  := column_value;
END IF;

IF upper(column_name) = 'DT_ALIAS' OR
     column_name is null Then
     IF new_references.dt_alias <> UPPER(new_references.dt_alias) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ADM_CAL_TYPE' OR
     column_name is null Then
     IF new_references.adm_cal_type <>
UPPER(new_references.adm_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ADMISSION_CAT' OR
     column_name is null Then
     IF new_references.admission_cat <>
UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' OR
     column_name is null Then
     IF new_references.s_admission_process_type <>
UPPER(new_references.s_admission_process_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <>
UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ACAD_CAL_TYPE' OR
     column_name is null Then
     IF new_references.acad_cal_type <>
UPPER(new_references.acad_cal_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'LOCATION_CD' OR
     column_name is null Then
     IF new_references.location_cd <>
UPPER(new_references.location_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_MODE' OR
     column_name is null Then
     IF new_references.attendance_mode <>
UPPER(new_references.attendance_mode) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ATTENDANCE_TYPE' OR
     column_name is null Then
     IF new_references.attendance_type <>
UPPER(new_references.attendance_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'ADM_CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.adm_ci_sequence_number   < 1 OR
          new_references.adm_ci_sequence_number  > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'DAI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.dai_sequence_number   < 1 OR
          new_references.dai_sequence_number  > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'SEQUENCE_NUMBER' OR
     column_name is null Then
     IF new_references.sequence_number  < 1 OR
          new_references.sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'VERSION_NUMBER' OR
     column_name is null Then
     IF new_references.version_number   < 1 OR
          new_references.version_number  > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'ROLLOVER_INCLUSION_IND' OR
     column_name is null Then
     IF new_references.rollover_inclusion_ind  NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
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
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
 	IF NOT IGS_AD_PERD_AD_CAT_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number,
        new_references.admission_cat
		) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number) AND
         (old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL) OR
         (new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_AD_PRD_AD_PRC_CA_PKG.Get_PK_For_Validation (
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number,
        new_references.admission_cat,
        new_references.s_admission_process_type ,
        'N'
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

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.acad_cal_type = new_references.acad_cal_type)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.acad_cal_type IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_PS_OFR_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.acad_cal_type
       ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.dt_alias = new_references.dt_alias) AND
         (old_references.dai_sequence_number = new_references.dai_sequence_number) AND
         (old_references.adm_cal_type = new_references.adm_cal_type) AND
         (old_references.adm_ci_sequence_number = new_references.adm_ci_sequence_number)) OR
        ((new_references.dt_alias IS NULL) OR
         (new_references.dai_sequence_number IS NULL) OR
         (new_references.adm_cal_type IS NULL) OR
         (new_references.adm_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_CA_DA_INST_PKG.Get_PK_For_Validation (
        new_references.dt_alias,
        new_references.dai_sequence_number,
        new_references.adm_cal_type,
        new_references.adm_ci_sequence_number
        )THEN
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
        new_references.location_cd , 'N'
        )THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
		'ADMISSION_PROCESS_TYPE',
		new_references.s_admission_process_type
		)THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	 IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_dt_alias IN VARCHAR2,
    x_dai_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    )
RETURN BOOLEAN
 AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat
      AND      dt_alias = x_dt_alias
      AND      dai_sequence_number = x_dai_sequence_number
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

  PROCEDURE GET_FK_IGS_EN_ATD_MODE (
    x_attendance_mode IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    attendance_mode = x_attendance_mode ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_AM_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_MODE;

  PROCEDURE GET_FK_IGS_AD_PERD_AD_CAT (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_APAC_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PERD_AD_CAT;

  PROCEDURE GET_FK_IGS_AD_PRD_AD_PRC_CA (
    x_adm_cal_type IN VARCHAR2,
    x_adm_ci_sequence_number IN NUMBER,
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    adm_cal_type = x_adm_cal_type
      AND      adm_ci_sequence_number = x_adm_ci_sequence_number
      AND      admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_APAPC_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRD_AD_PRC_CA;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_ATT_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ATD_TYPE;

  PROCEDURE GET_FK_IGS_PS_OFR (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      acad_cal_type = x_cal_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_CO_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_OFR;

  PROCEDURE GET_FK_IGS_CA_DA_INST (
    x_dt_alias IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    dt_alias = x_dt_alias
      AND      dai_sequence_number = x_sequence_number
      AND      adm_cal_type = x_cal_type
      AND      adm_ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_DAI_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA_INST;

  PROCEDURE GET_FK_IGS_AD_LOCATION (
    x_location_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    location_cd = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_LOC_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_LOCATION;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PECRS_OFOP_DT
      WHERE    s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCOOD_SLV_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_adm_cal_type IN VARCHAR2 ,
    x_adm_ci_sequence_number IN NUMBER ,
    x_admission_cat IN VARCHAR2 ,
    x_dt_alias IN VARCHAR2 ,
    x_dai_sequence_number IN NUMBER ,
    x_sequence_number IN NUMBER ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_course_cd IN VARCHAR2 ,
    x_version_number IN NUMBER ,
    x_acad_cal_type IN VARCHAR2 ,
    x_location_cd IN VARCHAR2 ,
    x_attendance_mode IN VARCHAR2 ,
    x_attendance_type IN VARCHAR2 ,
    x_rollover_inclusion_ind IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_adm_cal_type,
      x_adm_ci_sequence_number,
      x_admission_cat,
      x_dt_alias,
      x_dai_sequence_number,
      x_sequence_number,
      x_s_admission_process_type,
      x_course_cd,
      x_version_number,
      x_acad_cal_type,
      x_location_cd,
      x_attendance_mode,
      x_attendance_type,
      x_rollover_inclusion_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE,  p_updating => FALSE, p_deleting => FALSE);
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat,
          new_references.dt_alias,
          new_references.dai_sequence_number,
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
       BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,  p_updating => TRUE, p_deleting => FALSE);
        Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete1 ( p_inserting => FALSE,  p_updating => FALSE, p_deleting => TRUE);
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.adm_cal_type,
          new_references.adm_ci_sequence_number,
          new_references.admission_cat,
          new_references.dt_alias,
          new_references.dai_sequence_number,
          new_references.sequence_number
		) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		 IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
END IF;
END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      AfterRowInsertUpdate2 ( p_inserting => TRUE, p_updating => FALSE , p_deleting => FALSE );
    ELSIF (p_action = 'UPDATE') THEN
      AfterRowInsertUpdate2 ( p_inserting => FALSE, p_updating => TRUE , p_deleting => FALSE);
    END IF;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ROLLOVER_INCLUSION_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_AD_PECRS_OFOP_DT
      where ADM_CAL_TYPE = X_ADM_CAL_TYPE
      and ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER
      and ADMISSION_CAT = X_ADMISSION_CAT
      and DT_ALIAS = X_DT_ALIAS
      and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
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
  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_dt_alias => X_DT_ALIAS,
  x_dai_sequence_number => X_DAI_SEQUENCE_NUMBER,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_course_cd =>X_COURSE_CD,
  x_version_number=>  X_VERSION_NUMBER,
  x_acad_cal_type =>  X_ACAD_CAL_TYPE ,
  x_sequence_number=>  X_SEQUENCE_NUMBER,
  x_location_cd  =>  X_LOCATION_CD  ,
  x_attendance_mode=>   X_ATTENDANCE_MODE,
  x_attendance_type =>  X_ATTENDANCE_TYPE ,
  x_rollover_inclusion_ind=>   NVL(X_ROLLOVER_INCLUSION_IND,'N'),
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_PECRS_OFOP_DT (
    ADM_CAL_TYPE,
    ADM_CI_SEQUENCE_NUMBER,
    ADMISSION_CAT,
    DT_ALIAS,
    DAI_SEQUENCE_NUMBER,
    SEQUENCE_NUMBER,
    S_ADMISSION_PROCESS_TYPE,
    COURSE_CD,
    VERSION_NUMBER,
    ACAD_CAL_TYPE,
    LOCATION_CD,
    ATTENDANCE_MODE,
    ATTENDANCE_TYPE,
    ROLLOVER_INCLUSION_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ADM_CAL_TYPE,
    NEW_REFERENCES.ADM_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.DT_ALIAS,
    NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.ACAD_CAL_TYPE,
    NEW_REFERENCES.LOCATION_CD,
    NEW_REFERENCES.ATTENDANCE_MODE,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.ROLLOVER_INCLUSION_IND,
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

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ROLLOVER_INCLUSION_IND in VARCHAR2
) AS
  cursor c1 is select
      S_ADMISSION_PROCESS_TYPE,
      COURSE_CD,
      VERSION_NUMBER,
      ACAD_CAL_TYPE,
      LOCATION_CD,
      ATTENDANCE_MODE,
      ATTENDANCE_TYPE,
      ROLLOVER_INCLUSION_IND
    from IGS_AD_PECRS_OFOP_DT
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

      if ( ((tlinfo.S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE)
           OR ((tlinfo.S_ADMISSION_PROCESS_TYPE is null)
               AND (X_S_ADMISSION_PROCESS_TYPE is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
           OR ((tlinfo.VERSION_NUMBER is null)
               AND (X_VERSION_NUMBER is null)))
      AND ((tlinfo.ACAD_CAL_TYPE = X_ACAD_CAL_TYPE)
           OR ((tlinfo.ACAD_CAL_TYPE is null)
               AND (X_ACAD_CAL_TYPE is null)))
      AND ((tlinfo.LOCATION_CD = X_LOCATION_CD)
           OR ((tlinfo.LOCATION_CD is null)
               AND (X_LOCATION_CD is null)))
      AND ((tlinfo.ATTENDANCE_MODE = X_ATTENDANCE_MODE)
           OR ((tlinfo.ATTENDANCE_MODE is null)
               AND (X_ATTENDANCE_MODE is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND (tlinfo.ROLLOVER_INCLUSION_IND = X_ROLLOVER_INCLUSION_IND)
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
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ROLLOVER_INCLUSION_IND in VARCHAR2,
  X_MODE in VARCHAR2
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

  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_adm_cal_type => X_ADM_CAL_TYPE,
  x_adm_ci_sequence_number => X_ADM_CI_SEQUENCE_NUMBER,
  x_admission_cat => X_ADMISSION_CAT,
  x_dt_alias => X_DT_ALIAS,
  x_dai_sequence_number => X_DAI_SEQUENCE_NUMBER,
  x_sequence_number => X_SEQUENCE_NUMBER,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_course_cd =>X_COURSE_CD ,
  x_version_number=>  X_VERSION_NUMBER,
  x_acad_cal_type =>  X_ACAD_CAL_TYPE ,
  x_location_cd  =>  X_LOCATION_CD  ,
  x_attendance_mode=>   X_ATTENDANCE_MODE,
  x_attendance_type =>  X_ATTENDANCE_TYPE ,
  x_rollover_inclusion_ind=>   X_ROLLOVER_INCLUSION_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_PECRS_OFOP_DT set
    S_ADMISSION_PROCESS_TYPE = NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    DAI_SEQUENCE_NUMBER = NEW_REFERENCES.DAI_SEQUENCE_NUMBER,
    ACAD_CAL_TYPE = NEW_REFERENCES.ACAD_CAL_TYPE,
    LOCATION_CD = NEW_REFERENCES.LOCATION_CD,
    ATTENDANCE_MODE = NEW_REFERENCES.ATTENDANCE_MODE,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    ROLLOVER_INCLUSION_IND = NEW_REFERENCES.ROLLOVER_INCLUSION_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
  X_ADM_CAL_TYPE in VARCHAR2,
  X_ADM_CI_SEQUENCE_NUMBER in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_DT_ALIAS in VARCHAR2,
  X_DAI_SEQUENCE_NUMBER in NUMBER,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_ACAD_CAL_TYPE in VARCHAR2,
  X_LOCATION_CD in VARCHAR2,
  X_ATTENDANCE_MODE in VARCHAR2,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_ROLLOVER_INCLUSION_IND in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_AD_PECRS_OFOP_DT
     where ADM_CAL_TYPE = X_ADM_CAL_TYPE
     and ADM_CI_SEQUENCE_NUMBER = X_ADM_CI_SEQUENCE_NUMBER
     and ADMISSION_CAT = X_ADMISSION_CAT
     and DT_ALIAS = X_DT_ALIAS
     and DAI_SEQUENCE_NUMBER = X_DAI_SEQUENCE_NUMBER
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ADM_CAL_TYPE,
     X_ADM_CI_SEQUENCE_NUMBER,
     X_ADMISSION_CAT,
     X_DT_ALIAS,
     X_DAI_SEQUENCE_NUMBER,
     X_SEQUENCE_NUMBER,
     X_S_ADMISSION_PROCESS_TYPE,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_ACAD_CAL_TYPE,
     X_LOCATION_CD,
     X_ATTENDANCE_MODE,
     X_ATTENDANCE_TYPE,
     X_ROLLOVER_INCLUSION_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADM_CAL_TYPE,
   X_ADM_CI_SEQUENCE_NUMBER,
   X_ADMISSION_CAT,
   X_DT_ALIAS,
   X_DAI_SEQUENCE_NUMBER,
   X_SEQUENCE_NUMBER,
   X_S_ADMISSION_PROCESS_TYPE,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_ACAD_CAL_TYPE,
   X_LOCATION_CD,
   X_ATTENDANCE_MODE,
   X_ATTENDANCE_TYPE,
   X_ROLLOVER_INCLUSION_IND,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_AD_PECRS_OFOP_DT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_AD_PECRS_OFOP_DT_PKG;

/
