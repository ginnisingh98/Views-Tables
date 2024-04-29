--------------------------------------------------------
--  DDL for Package Body IGS_AD_SBMAO_FN_CTTT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SBMAO_FN_CTTT_PKG" as
/* $Header: IGSAI64B.pls 115.6 2003/10/30 13:21:37 rghosh ship $ */
l_rowid VARCHAR2(25);
old_references IGS_AD_SBMAO_FN_CTTT%RowType;
new_references IGS_AD_SBMAO_FN_CTTT%RowType;

PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_submission_yr IN NUMBER DEFAULT NULL,
    x_submission_number IN NUMBER DEFAULT NULL,
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_course_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_intake_target_type IN VARCHAR2 DEFAULT NULL,
    x_target IN NUMBER DEFAULT NULL,
    x_max_target IN NUMBER DEFAULT NULL,
    x_override_s_amount_type IN VARCHAR2 DEFAULT NULL,
    x_actual_enrolment IN NUMBER DEFAULT NULL,
    x_actual_enr_effective_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_SBMAO_FN_CTTT
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
    new_references.org_unit_cd := x_org_unit_cd;
    new_references.ou_start_dt := TRUNC(x_ou_start_dt);
    new_references.funding_source := x_funding_source;
    new_references.course_type_group_cd := x_course_type_group_cd;
    new_references.intake_target_type := x_intake_target_type;
    new_references.target := x_target;
    new_references.max_target := x_max_target;
    new_references.override_s_amount_type := x_override_s_amount_type;
    new_references.actual_enrolment := x_actual_enrolment;
    new_references.actual_enr_effective_dt := TRUNC(x_actual_enr_effective_dt);
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
	v_message_name			VARCHAR2(30);
	v_s_amount_type	IGS_AD_INTAK_TRG_TYP.s_amount_type%TYPE;
  BEGIN
	-- Validate Funding Source closed ind.
	IF p_inserting OR
	    (old_references.funding_source <> new_references.funding_source) THEN
		IF IGS_AD_VAL_SAFT.crsp_val_fs_closed(
					new_references.funding_source,
					v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate org IGS_PS_UNIT is active and at the local IGS_OR_INSTITUTION.
	IF p_inserting OR
	    (old_references.org_unit_cd <> new_references.org_unit_cd) OR
	    (TRUNC(old_references.ou_start_dt) <> new_references.ou_start_dt) THEN
		IF IGS_AD_VAL_SAFT.admp_val_trgt_aou(
					new_references.org_unit_cd,
					new_references.ou_start_dt,
					v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate Intake target Type closed ind.
	IF p_inserting OR
	    (old_references.course_type_group_cd <> new_references.course_type_group_cd) THEN
		IF IGS_AD_VAL_SAFT.crsp_val_ctg_closed(
					new_references.course_type_group_cd,
					v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate Intake target Type closed ind.
	IF p_inserting OR
	    (old_references.intake_target_type <> new_references.intake_target_type) THEN
		IF IGS_AD_VAL_SIT.admp_val_itt_closed(
					new_references.intake_target_type,
					v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate override system amount type does not equal the system amount type
	-- of the intake target type
	IF p_inserting OR
	    (NVL(old_references.override_s_amount_type, 'NULL')  <>
		NVL(new_references.override_s_amount_type, 'NULL')) THEN
		v_s_amount_type := IGS_AD_GEN_006.ADMP_GET_ITT_AMTTYP (new_references.intake_target_type);
		IF IGS_AD_VAL_SIT.admp_val_trgt_amttyp(
					v_s_amount_type,
					new_references.override_s_amount_type,
					v_message_name) = FALSE THEN
			--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	-- Validate target and maximum target against amount type
	IF p_inserting OR
	    (NVL(old_references.override_s_amount_type, 'NULL')
 		<> NVL(new_references.override_s_amount_type, 'NULL')) OR
	    (old_references.target <> new_references.target) OR
	    (old_references.max_target <> new_references.max_target) THEN
		IF new_references.override_s_amount_type IS NULL THEN
			v_s_amount_type := IGS_AD_GEN_006.ADMP_GET_ITT_AMTTYP (new_references.intake_target_type);
			IF IGS_AD_VAL_SIT.admp_val_trgt_amt(
						v_s_amount_type,
						new_references.target,
						new_references.max_target,
						v_message_name) = FALSE THEN
				--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
				FND_MESSAGE.SET_NAME('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		ELSE
			IF IGS_AD_VAL_SIT.admp_val_trgt_amt(
						new_references.override_s_amount_type,
						new_references.target,
						new_references.max_target,
						v_message_name) = FALSE THEN
				--raise_application_error(-20000, IGS_GE_GEN_002.GENP_GET_MESSAGE(v_message_num));
				FND_MESSAGE.SET_NAME('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_type_group_cd = new_references.course_type_group_cd)) OR
        ((new_references.course_type_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_TYPE_GRP_PKG.Get_PK_For_Validation (
        new_references.course_type_group_cd
        )THEN
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        )THEN
        FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
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
        )THEN
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.intake_target_type = new_references.intake_target_type)) OR
        ((new_references.intake_target_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_INTAK_TRG_TYP_PKG.Get_PK_For_Validation (
        new_references.intake_target_type,
        'N'
        )THEN
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.org_unit_cd = new_references.org_unit_cd) AND
         (TRUNC(old_references.ou_start_dt) = new_references.ou_start_dt)) OR
        ((new_references.org_unit_cd IS NULL) OR
         (new_references.ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.org_unit_cd,
        new_references.ou_start_dt
        )THEN
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
    END IF;

    IF (((old_references.override_s_amount_type = new_references.override_s_amount_type)) OR
        ((new_references.override_s_amount_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'AMOUNT_TYPE',
	  new_references.override_s_amount_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_submission_yr IN NUMBER,
    x_submission_number IN NUMBER,
    x_org_unit_cd IN VARCHAR2,
    x_ou_start_dt IN DATE,
    x_funding_source IN VARCHAR2,
    x_course_type_group_cd IN VARCHAR2,
    x_intake_target_type IN VARCHAR2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number
      AND      org_unit_cd = x_org_unit_cd
      AND      TRUNC(ou_start_dt) = TRUNC(x_ou_start_dt)
      AND      funding_source = x_funding_source
      AND      course_type_group_cd = x_course_type_group_cd
      AND      intake_target_type = x_intake_target_type
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

  PROCEDURE GET_FK_IGS_PS_TYPE_GRP (
    x_course_type_group_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    course_type_group_cd = x_course_type_group_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SAFCT_CTG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_TYPE_GRP;

  PROCEDURE GET_FK_IGS_FI_FUND_SRC (
    x_funding_source IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    funding_source = x_funding_source ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SAFCT_FS_FK');
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
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    submission_yr = x_submission_yr
      AND      submission_number = x_submission_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SAFCT_GSC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_ST_GVT_SPSHT_CTL;

  PROCEDURE GET_FK_IGS_AD_INTAK_TRG_TYP(
    x_intake_target_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    intake_target_type = x_intake_target_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SAFCT_ITT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_INTAK_TRG_TYP;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    org_unit_cd = x_org_unit_cd
      AND      TRUNC(ou_start_dt) = TRUNC(x_start_dt) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SAFCT_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_override_s_amount_type IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_SBMAO_FN_CTTT
      WHERE    override_s_amount_type = x_override_s_amount_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_OVR_AMT_SLV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  -- procedure to check constraints
  PROCEDURE CHECK_CONSTRAINTS(
     column_name IN VARCHAR2 DEFAULT NULL,
     column_value IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN
     IF column_name is null THEN
      NULL;
     ELSIF upper(column_name) = 'TARGET' THEN
      new_references.target := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'MAX_TARGET' THEN
      new_references.max_target := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'ACTUAL_ENROLMENT' THEN
      new_references.actual_enrolment := igs_ge_number.to_num(column_value);
     ELSIF upper(column_name) = 'INTAKE_TARGET_TYPE' THEN
      new_references.intake_target_type := column_value;
     ELSIF upper(column_name) = 'FUNDING_SOURCE' THEN
      new_references.funding_source := column_value;
     ELSIF upper(column_name) = 'ORG_UNIT_CD' THEN
      new_references.org_unit_cd := column_value;
     ELSIF upper(column_name) = 'COURSE_TYPE_GROUP_CD' THEN
      new_references.course_type_group_cd := column_value;
     END IF;

     IF upper(column_name) = 'TARGET' OR column_name IS NULL THEN
      IF new_references.target < 00000.000 OR new_references.target > 99999.999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'MAX_TARGET' OR column_name IS NULL THEN
      IF new_references.max_target < 00000.000 OR new_references.max_target > 99999.999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'ACTUAL_ENROLMENT' OR column_name IS NULL THEN
      IF new_references.actual_enrolment < 00000.000 OR new_references.actual_enrolment > 99999.999 THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'FUNDING_SOURCE' OR column_name IS NULL THEN
      IF new_references.funding_source <> UPPER(new_references.funding_source) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;
     IF upper(column_name) = 'INTAKE_TARGET_TYPE' OR column_name IS NULL THEN
      IF new_references.intake_target_type <> UPPER(new_references.intake_target_type) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
     END IF;

     IF upper(column_name) = 'COURSE_TYPE_GROUP_CD' OR column_name IS NULL THEN
      IF new_references.course_type_group_cd <> UPPER(new_references.course_type_group_cd) THEN
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
    x_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_course_type_group_cd IN VARCHAR2 DEFAULT NULL,
    x_intake_target_type IN VARCHAR2 DEFAULT NULL,
    x_target IN NUMBER DEFAULT NULL,
    x_max_target IN NUMBER DEFAULT NULL,
    x_override_s_amount_type IN VARCHAR2 DEFAULT NULL,
    x_actual_enrolment IN NUMBER DEFAULT NULL,
    x_actual_enr_effective_dt IN DATE DEFAULT NULL,
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
      x_org_unit_cd,
      x_ou_start_dt,
      x_funding_source,
      x_course_type_group_cd,
      x_intake_target_type,
      x_target,
      x_max_target,
      x_override_s_amount_type,
      x_actual_enrolment,
      x_actual_enr_effective_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      IF GET_PK_FOR_VALIDATION(
        new_references.submission_yr,
        new_references.submission_number,
        new_references.org_unit_cd,
        new_references.ou_start_dt,
        new_references.funding_source,
        new_references.course_type_group_cd,
        new_references.intake_target_type
       )THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
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
        new_references.org_unit_cd,
        new_references.ou_start_dt,
        new_references.funding_source,
        new_references.course_type_group_cd,
        new_references.intake_target_type
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_AD_SBMAO_FN_CTTT
      where SUBMISSION_YR = X_SUBMISSION_YR
      and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
      and ORG_UNIT_CD = X_ORG_UNIT_CD
      and OU_START_DT = X_OU_START_DT
      and FUNDING_SOURCE = X_FUNDING_SOURCE
      and COURSE_TYPE_GROUP_CD = X_COURSE_TYPE_GROUP_CD
      and INTAKE_TARGET_TYPE = X_INTAKE_TARGET_TYPE;
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
  x_submission_yr => X_SUBMISSION_YR,
  x_submission_number => X_SUBMISSION_NUMBER,
  x_org_unit_cd  => X_ORG_UNIT_CD,
  x_ou_start_dt => X_OU_START_DT,
  x_funding_source => X_FUNDING_SOURCE,
  x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
  x_intake_target_type => X_INTAKE_TARGET_TYPE,
  x_target => X_TARGET,
  x_max_target => X_MAX_TARGET,
  x_override_s_amount_type => X_OVERRIDE_S_AMOUNT_TYPE,
  x_actual_enrolment => X_ACTUAL_ENROLMENT,
  x_actual_enr_effective_dt => X_ACTUAL_ENR_EFFECTIVE_DT,
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

   insert into IGS_AD_SBMAO_FN_CTTT (
    SUBMISSION_YR,
    SUBMISSION_NUMBER,
    ORG_UNIT_CD,
    OU_START_DT,
    FUNDING_SOURCE,
    COURSE_TYPE_GROUP_CD,
    INTAKE_TARGET_TYPE,
    TARGET,
    MAX_TARGET,
    OVERRIDE_S_AMOUNT_TYPE,
    ACTUAL_ENROLMENT,
    ACTUAL_ENR_EFFECTIVE_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SUBMISSION_YR,
    NEW_REFERENCES.SUBMISSION_NUMBER,
    NEW_REFERENCES.ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.COURSE_TYPE_GROUP_CD,
    NEW_REFERENCES.INTAKE_TARGET_TYPE,
    NEW_REFERENCES.TARGET,
    NEW_REFERENCES.MAX_TARGET,
    NEW_REFERENCES.OVERRIDE_S_AMOUNT_TYPE,
    NEW_REFERENCES.ACTUAL_ENROLMENT,
    NEW_REFERENCES.ACTUAL_ENR_EFFECTIVE_DT,
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE
) AS
  cursor c1 is select
      TARGET,
      MAX_TARGET,
      OVERRIDE_S_AMOUNT_TYPE,
      ACTUAL_ENROLMENT,
      ACTUAL_ENR_EFFECTIVE_DT
    from IGS_AD_SBMAO_FN_CTTT
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

  if ( (tlinfo.TARGET = X_TARGET)
      AND ((tlinfo.MAX_TARGET = X_MAX_TARGET)
           OR ((tlinfo.MAX_TARGET is null)
               AND (X_MAX_TARGET is null)))
      AND ((tlinfo.OVERRIDE_S_AMOUNT_TYPE = X_OVERRIDE_S_AMOUNT_TYPE)
           OR ((tlinfo.OVERRIDE_S_AMOUNT_TYPE is null)
               AND (X_OVERRIDE_S_AMOUNT_TYPE is null)))
      AND ((tlinfo.ACTUAL_ENROLMENT = X_ACTUAL_ENROLMENT)
           OR ((tlinfo.ACTUAL_ENROLMENT is null)
               AND (X_ACTUAL_ENROLMENT is null)))
      AND ((TRUNC(tlinfo.ACTUAL_ENR_EFFECTIVE_DT) = TRUNC(X_ACTUAL_ENR_EFFECTIVE_DT))
           OR ((tlinfo.ACTUAL_ENR_EFFECTIVE_DT is null)
               AND (X_ACTUAL_ENR_EFFECTIVE_DT is null)))
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
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
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

  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_submission_yr => X_SUBMISSION_YR,
  x_submission_number => X_SUBMISSION_NUMBER,
  x_org_unit_cd  => X_ORG_UNIT_CD,
  x_ou_start_dt => X_OU_START_DT,
  x_funding_source => X_FUNDING_SOURCE,
  x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
  x_intake_target_type => X_INTAKE_TARGET_TYPE,
  x_target => X_TARGET,
  x_max_target => X_MAX_TARGET,
  x_override_s_amount_type => X_OVERRIDE_S_AMOUNT_TYPE,
  x_actual_enrolment => X_ACTUAL_ENROLMENT,
  x_actual_enr_effective_dt => X_ACTUAL_ENR_EFFECTIVE_DT,
  x_creation_date =>X_LAST_UPDATE_DATE,
  x_created_by =>X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by =>X_LAST_UPDATED_BY,
  x_last_update_login =>X_LAST_UPDATE_LOGIN
  );

  update IGS_AD_SBMAO_FN_CTTT set
    TARGET = NEW_REFERENCES.TARGET,
    MAX_TARGET = NEW_REFERENCES.MAX_TARGET,
    OVERRIDE_S_AMOUNT_TYPE = NEW_REFERENCES.OVERRIDE_S_AMOUNT_TYPE,
    ACTUAL_ENROLMENT = NEW_REFERENCES.ACTUAL_ENROLMENT,
    ACTUAL_ENR_EFFECTIVE_DT = NEW_REFERENCES.ACTUAL_ENR_EFFECTIVE_DT,
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
  X_SUBMISSION_YR in NUMBER,
  X_SUBMISSION_NUMBER in NUMBER,
  X_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_FUNDING_SOURCE in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_INTAKE_TARGET_TYPE in VARCHAR2,
  X_TARGET in NUMBER,
  X_MAX_TARGET in NUMBER,
  X_OVERRIDE_S_AMOUNT_TYPE in VARCHAR2,
  X_ACTUAL_ENROLMENT in NUMBER,
  X_ACTUAL_ENR_EFFECTIVE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_AD_SBMAO_FN_CTTT
     where SUBMISSION_YR = X_SUBMISSION_YR
     and SUBMISSION_NUMBER = X_SUBMISSION_NUMBER
     and ORG_UNIT_CD = X_ORG_UNIT_CD
     and OU_START_DT = X_OU_START_DT
     and FUNDING_SOURCE = X_FUNDING_SOURCE
     and COURSE_TYPE_GROUP_CD = X_COURSE_TYPE_GROUP_CD
     and INTAKE_TARGET_TYPE = X_INTAKE_TARGET_TYPE
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
     X_ORG_UNIT_CD,
     X_OU_START_DT,
     X_FUNDING_SOURCE,
     X_COURSE_TYPE_GROUP_CD,
     X_INTAKE_TARGET_TYPE,
     X_TARGET,
     X_MAX_TARGET,
     X_OVERRIDE_S_AMOUNT_TYPE,
     X_ACTUAL_ENROLMENT,
     X_ACTUAL_ENR_EFFECTIVE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUBMISSION_YR,
   X_SUBMISSION_NUMBER,
   X_ORG_UNIT_CD,
   X_OU_START_DT,
   X_FUNDING_SOURCE,
   X_COURSE_TYPE_GROUP_CD,
   X_INTAKE_TARGET_TYPE,
   X_TARGET,
   X_MAX_TARGET,
   X_OVERRIDE_S_AMOUNT_TYPE,
   X_ACTUAL_ENROLMENT,
   X_ACTUAL_ENR_EFFECTIVE_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin

    Before_DML(
     p_action =>'DELETE',
     x_rowid => X_ROWID
    );
  delete from IGS_AD_SBMAO_FN_CTTT
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(
     p_action =>'DELETE',
     x_rowid => X_ROWID
    );

end DELETE_ROW;

end IGS_AD_SBMAO_FN_CTTT_PKG;

/
