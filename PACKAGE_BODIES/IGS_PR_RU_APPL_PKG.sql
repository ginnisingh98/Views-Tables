--------------------------------------------------------
--  DDL for Package Body IGS_PR_RU_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_RU_APPL_PKG" AS
/* $Header: IGSQI10B.pls 115.15 2003/06/05 13:02:48 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PR_RU_APPL_ALL%RowType;
  new_references IGS_PR_RU_APPL_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sca_course_cd IN VARCHAR2 DEFAULT NULL,
    x_pro_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pro_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_spo_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_ou_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_crv_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_sca_person_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL,
    x_min_cp IN NUMBER DEFAULT NULL,
    x_max_cp IN NUMBER DEFAULT NULL,
    x_igs_pr_class_std_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.sca_course_cd := x_sca_course_cd;
    new_references.pro_progression_rule_cat := x_pro_progression_rule_cat;
    new_references.pro_pra_sequence_number := x_pro_pra_sequence_number;
    new_references.pro_sequence_number := x_pro_sequence_number;
    new_references.spo_person_id := x_spo_person_id;
    new_references.spo_course_cd := x_spo_course_cd;
    new_references.spo_sequence_number := x_spo_sequence_number;
    new_references.logical_delete_dt := x_logical_delete_dt;
    new_references.message := x_message;
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.sequence_number := x_sequence_number;
    new_references.s_relation_type := x_s_relation_type;
    new_references.progression_rule_cd := x_progression_rule_cd;
    new_references.reference_cd := x_reference_cd;
    new_references.rul_sequence_number := x_rul_sequence_number;
    new_references.attendance_type := x_attendance_type;
    new_references.ou_org_unit_cd := x_ou_org_unit_cd;
    new_references.ou_start_dt := x_ou_start_dt;
    new_references.course_type := x_course_type;
    new_references.crv_course_cd := x_crv_course_cd;
    new_references.crv_version_number := x_crv_version_number;
    new_references.sca_person_id := x_sca_person_id;
    new_references.org_id := x_org_id;
    new_references.min_cp := x_min_cp;
    new_references.max_cp := x_max_cp;
    new_references.igs_pr_class_std_id := x_igs_pr_class_std_id;

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
  -- "OSS_TST".trg_pra_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_PR_RU_APPL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name varchar2(30);
  BEGIN
	-- Validate the IGS_PS_COURSE type is not closed
	IF p_inserting OR
	  (p_updating AND NVL(new_references.course_type, 'NULL')  <>
	  NVL(old_references.course_type,'NULL')) THEN
		IF IGS_as_VAL_acot.crsp_val_cty_closed (
					new_references.course_type,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the IGS_PS_COURSE version is active
	IF p_inserting OR
	  (p_updating AND (NVL(new_references.crv_course_cd, 'NULL')  <>
	  NVL(old_references.crv_course_cd,'NULL') OR
	  NVL(new_references.crv_version_number, 0)  <>
	  NVL(old_references.crv_version_number,0))) THEN
		IF IGS_PR_VAL_PRA.crsp_val_crv_active (
					new_references.crv_course_cd,
					new_references.crv_version_number,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the IGS_OR_UNIT is active
	IF p_inserting OR
	  (p_updating AND (NVL(new_references.ou_org_unit_cd, 'NULL')  <>
	  NVL(old_references.ou_org_unit_cd,'NULL') OR
	  NVL((fnd_date.date_to_canonical(new_references.ou_start_dt)),  '1900/01/01')  <>
	  NVL((fnd_date.date_to_canonical(old_references.ou_start_dt)), '1900/01/01'))) THEN
		IF IGS_PR_VAL_SOPC.prgp_val_ou_active (
					new_references.ou_org_unit_cd,
					new_references.ou_start_dt,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the progression IGS_RU_RULE category
	IF p_inserting THEN
		IF IGS_PR_VAL_PRA.prgp_val_prgc_closed (
					new_references.progression_rule_cat,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the progression IGS_RU_RULE
	IF new_references.progression_rule_cd IS NOT NULL AND (p_inserting OR
	  (p_updating AND NVL(new_references.progression_rule_cd, 'NULL')  <>
	  NVL(old_references.progression_rule_cd,'NULL'))) THEN
		IF IGS_PR_VAL_PRA.prgp_val_prr_closed (
					new_references.progression_rule_cd,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the attendance type
	IF new_references.attendance_type IS NOT NULL AND (p_inserting OR
	  (p_updating AND NVL(new_references.attendance_type, 'NULL')  <>
	  NVL(old_references.attendance_type, 'NULL'))) THEN
          --
          -- bug id : 1956374
          -- sjadhav , 28-aug-2001
          -- change igs_pr_val_pra.enrp_val_att_closed
          -- to     igs_en_val_pee.enrp_val_att_closed
          --
		IF IGS_EN_VAL_PEE.enrp_val_att_closed (
					new_references.attendance_type,
					v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the record has the required details
	IF p_inserting OR p_updating THEN
		IF IGS_PR_VAL_PRA.prgp_val_pra_rqrd (
					new_references.s_relation_type,
					new_references.progression_rule_cd,
					new_references.rul_sequence_number,
					new_references.ou_org_unit_cd,
					new_references.ou_start_dt,
					new_references.course_type,
					new_references.crv_course_cd,
					new_references.crv_version_number,
					new_references.sca_person_id,
					new_references.sca_course_cd,
					new_references.pro_progression_rule_cat,
					new_references.pro_pra_sequence_number,
					new_references.pro_sequence_number,
					new_references.spo_person_id,
					new_references.spo_course_cd,
					new_references.spo_sequence_number,
					v_message_name) = FALSE THEN

			Fnd_Message.Set_Name('IGS',v_message_name);
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

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

    IF (((old_references.crv_course_cd = new_references.crv_course_cd) AND
         (old_references.crv_version_number = new_references.crv_version_number)) OR
        ((new_references.crv_course_cd IS NULL) OR
         (new_references.crv_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.crv_course_cd,
        new_references.crv_version_number
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.course_type = new_references.course_type)) OR
        ((new_references.course_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_TYPE_PKG.Get_PK_For_Validation (
        new_references.course_type
        ) THEN

			Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
      END IF;

    END IF;

    IF (((old_references.ou_org_unit_cd = new_references.ou_org_unit_cd) AND
         (old_references.ou_start_dt = new_references.ou_start_dt)) OR
        ((new_references.ou_org_unit_cd IS NULL) OR
         (new_references.ou_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.ou_org_unit_cd,
        new_references.ou_start_dt
        ) THEN

			Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                        IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

      END IF;

    END IF;

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat)) OR
        ((new_references.progression_rule_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_CAT_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

      END IF;

    END IF;

    IF (((old_references.pro_progression_rule_cat = new_references.pro_progression_rule_cat) AND
         (old_references.pro_pra_sequence_number = new_references.pro_pra_sequence_number) AND
         (old_references.pro_sequence_number = new_references.pro_sequence_number)) OR
        ((new_references.pro_progression_rule_cat IS NULL) OR
         (new_references.pro_pra_sequence_number IS NULL) OR
         (new_references.pro_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_OU_PKG.Get_PK_For_Validation (
        new_references.pro_progression_rule_cat,
        new_references.pro_pra_sequence_number,
        new_references.pro_sequence_number
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.progression_rule_cd = new_references.progression_rule_cd)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.progression_rule_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RULE_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.progression_rule_cd
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.sca_person_id = new_references.sca_person_id) AND
         (old_references.sca_course_cd = new_references.sca_course_cd)) OR
        ((new_references.sca_person_id IS NULL) OR
         (new_references.sca_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.sca_person_id,
        new_references.sca_course_cd
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    IF (((old_references.spo_person_id = new_references.spo_person_id) AND
         (old_references.spo_course_cd = new_references.spo_course_cd) AND
         (old_references.spo_sequence_number = new_references.spo_sequence_number)) OR
        ((new_references.spo_person_id IS NULL) OR
         (new_references.spo_course_cd IS NULL) OR
         (new_references.spo_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_STDNT_PR_OU_PKG.Get_PK_For_Validation (
        new_references.spo_person_id,
        new_references.spo_course_cd,
        new_references.spo_sequence_number
        ) THEN

		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
                IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

    END IF;

    -- This piece of code is added as part of 'Academic Standing and Progression DLD'

    IF (((old_references.igs_pr_class_std_id = new_references.igs_pr_class_std_id)) OR
        ((new_references.igs_pr_class_std_id IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_CLASS_STD_PKG.Get_PK_For_Validation (
         new_references.igs_pr_class_std_id
        ) THEN

	  Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
	  App_Exception.Raise_Exception;

      END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_PR_RU_CA_TYPE_PKG.GET_FK_IGS_PR_RU_APPL (
      old_references.progression_rule_cat,
      old_references.sequence_number
      );

    IGS_PR_RU_OU_PKG.GET_FK_IGS_PR_RU_APPL (
      old_references.progression_rule_cat,
      old_references.sequence_number
      );

    IGS_PR_SDT_PR_RU_CK_PKG.GET_FK_IGS_PR_RU_APPL (
      old_references.progression_rule_cat,
      old_references.sequence_number
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
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

  PROCEDURE GET_FK_IGS_PR_CLASS_STD (
    x_igs_pr_class_std_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    igs_pr_class_std_id = x_igs_pr_class_std_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_PCS_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_CLASS_STD;

  PROCEDURE GET_FK_IGS_EN_ATD_TYPE (
    x_attendance_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    attendance_type = x_attendance_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null ) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_ATT_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
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
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    crv_course_cd = x_course_cd
      AND      crv_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_CRV_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;


  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    ou_org_unit_cd = x_org_unit_cd
      AND      ou_start_dt = x_start_dt ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_OU_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_OR_UNIT;

  PROCEDURE GET_FK_IGS_PR_RU_CAT (
    x_progression_rule_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_PRGC_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_CAT;

  PROCEDURE GET_FK_IGS_PR_RU_OU (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    pro_progression_rule_cat = x_progression_rule_cat
      AND      pro_pra_sequence_number = x_pra_sequence_number
      AND      pro_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_PRO_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_OU;

  PROCEDURE GET_FK_IGS_PR_RULE (
    x_progression_rule_cat IN VARCHAR2,
    x_progression_rule_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      progression_rule_cd = x_progression_rule_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_PRR_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RULE;

  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN VARCHAR2,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    sca_person_id = x_person_id
      AND      sca_course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE GET_FK_IGS_PR_STDNT_PR_OU (
    x_person_id IN VARCHAR2,
    x_course_cd IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid,logical_delete_dt
      FROM     IGS_PR_RU_APPL_ALL
      WHERE    spo_person_id = x_person_id
      AND      spo_course_cd = x_course_cd
      AND      spo_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND and lv_rowid.logical_delete_dt is null) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_PRA_SPO_FK');
      IGS_GE_MSG_STACK.ADD;
	  Close cur_rowid;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_STDNT_PR_OU;

  PROCEDURE BeforeInsertUpdate( p_action VARCHAR2 ) AS
  /*
  ||  Created By : anilk
  ||  Created On : 25-FEB-2003
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_parent (
         cp_progression_rule_cat    IGS_PR_RU_OU.progression_rule_cat%TYPE,
         cp_pra_sequence_number     IGS_PR_RU_OU.pra_sequence_number%TYPE,
         cp_sequence_number         IGS_PR_RU_OU.sequence_number%TYPE  ) IS
     SELECT 1
     FROM   IGS_PR_RU_OU pro
     WHERE  pro.progression_rule_cat = cp_progression_rule_cat    AND
            pro.pra_sequence_number  = cp_pra_sequence_number AND
            pro.sequence_number      = cp_sequence_number     AND
            pro.logical_delete_dt is NULL;

    l_dummy NUMBER;

  BEGIN

   IF (p_action = 'INSERT') AND new_references.pro_progression_rule_cat IS NOT NULL
                            AND new_references.pro_pra_sequence_number  IS NOT NULL
			    AND new_references.pro_sequence_number      IS NOT NULL THEN
      OPEN c_parent( new_references.pro_progression_rule_cat, new_references.pro_pra_sequence_number, new_references.pro_sequence_number );
      FETCH c_parent INTO l_dummy;
      IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE c_parent;
   ELSIF(p_action = 'UPDATE') THEN
      IF NVL(new_references.pro_progression_rule_cat,'1') <> NVL(old_references.pro_progression_rule_cat,'1')  OR
         NVL(new_references.pro_pra_sequence_number,1) <> NVL(old_references.pro_pra_sequence_number,1)  OR
         NVL(new_references.pro_sequence_number,1) <> NVL(old_references.pro_sequence_number,1)  THEN
        OPEN c_parent( new_references.pro_progression_rule_cat,  new_references.pro_pra_sequence_number, new_references.pro_sequence_number );
        FETCH c_parent INTO l_dummy;
        IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE c_parent;
      END IF;
   END IF;

  END BeforeInsertUpdate;

	PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_sca_course_cd IN VARCHAR2 DEFAULT NULL,
    x_pro_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pro_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_spo_person_id IN NUMBER DEFAULT NULL,
    x_spo_course_cd IN VARCHAR2 DEFAULT NULL,
    x_spo_sequence_number IN NUMBER DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_message IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_sequence_number IN NUMBER DEFAULT NULL,
    x_s_relation_type IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_reference_cd IN VARCHAR2 DEFAULT NULL,
    x_rul_sequence_number IN NUMBER DEFAULT NULL,
    x_attendance_type IN VARCHAR2 DEFAULT NULL,
    x_ou_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_ou_start_dt IN DATE DEFAULT NULL,
    x_course_type IN VARCHAR2 DEFAULT NULL,
    x_crv_course_cd IN VARCHAR2 DEFAULT NULL,
    x_crv_version_number IN NUMBER DEFAULT NULL,
    x_sca_person_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_min_cp IN NUMBER DEFAULT NULL,
    x_max_cp IN NUMBER DEFAULT NULL,
    x_igs_pr_class_std_id IN NUMBER DEFAULT NULL
  )

/*****************************************************************************************************************************
 --
 -- Changed History
 -- Who          When            What
 -- Aiyer        16-Apr-2002     Modified for the bug #2274631 Call to BeforeRowInsertUpdate1 from before_dml in case of update
 --                              needs to happen only for those a records which have not been logically deleted.
 --
 *********************************************************************************************************************************/

  AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_sca_course_cd,
      x_pro_progression_rule_cat,
      x_pro_pra_sequence_number,
      x_pro_sequence_number,
      x_spo_person_id,
      x_spo_course_cd,
      x_spo_sequence_number,
      x_logical_delete_dt,
      x_message,
      x_progression_rule_cat,
      x_sequence_number,
      x_s_relation_type,
      x_progression_rule_cd,
      x_reference_cd,
      x_rul_sequence_number,
      x_attendance_type,
      x_ou_org_unit_cd,
      x_ou_start_dt,
      x_course_type,
      x_crv_course_cd,
      x_crv_version_number,
      x_sca_person_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      x_min_cp,
      x_max_cp,
      x_igs_pr_class_std_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
      Check_Parent_Existance;
	IF Get_PK_For_Validation (
    			new_references.progression_rule_cat,
			new_references.sequence_number
				    ) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	CHECK_CONSTRAINTS;

    ELSIF (p_action = 'UPDATE') THEN

      -- Modified by aiyer for the bug #2274631
      -- Call BeforeRowInsertUpdate1 procedure
      -- only for those a records which have not been logically deleted
      IF x_logical_delete_dt IS NULL THEN
        BeforeRowInsertUpdate1 ( p_updating => TRUE );
        Check_Parent_Existance;
	CHECK_CONSTRAINTS;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;


	ELSIF (p_action = 'VALIDATE_INSERT') THEN
		IF Get_PK_For_Validation (
    			new_references.progression_rule_cat,
			new_references.sequence_number
				    ) THEN
		  Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
                  IGS_GE_MSG_STACK.ADD;
		  App_Exception.Raise_Exception;
	       END IF;
	CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN
		CHECK_CONSTRAINTS;

	ELSIF (p_action = 'VALIDATE_DELETE') THEN
	Check_Child_Existance;
    END IF;

    -- anilk, bug#2784198
    BeforeInsertUpdate(p_action);

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_REFERENCE_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_OU_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_CRV_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SCA_PERSON_ID in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_PRO_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRO_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_SPO_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MESSAGE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER,
  X_MIN_CP IN NUMBER DEFAULT NULL,
  X_MAX_CP IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  ) AS
    cursor C is select ROWID from IGS_PR_RU_APPL_ALL
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
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
    x_rowid => x_rowid ,
    x_sca_course_cd => x_sca_course_cd ,
    x_pro_progression_rule_cat => x_pro_progression_rule_cat ,
    x_pro_pra_sequence_number => x_pro_pra_sequence_number ,
    x_pro_sequence_number => x_pro_sequence_number ,
    x_spo_person_id => x_spo_person_id ,
    x_spo_course_cd => x_spo_course_cd ,
    x_spo_sequence_number => x_spo_sequence_number ,
    x_logical_delete_dt => x_logical_delete_dt ,
    x_message => x_message ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_sequence_number => x_sequence_number ,
    x_s_relation_type => x_s_relation_type ,
    x_progression_rule_cd => x_progression_rule_cd ,
    x_reference_cd => x_reference_cd ,
    x_rul_sequence_number => x_rul_sequence_number ,
    x_attendance_type => x_attendance_type ,
    x_ou_org_unit_cd => x_ou_org_unit_cd ,
    x_ou_start_dt => x_ou_start_dt ,
    x_course_type => x_course_type ,
    x_crv_course_cd => x_crv_course_cd ,
    x_crv_version_number => x_crv_version_number ,
    x_sca_person_id => x_sca_person_id ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login =>x_last_update_login ,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_min_cp => x_min_cp,
    x_max_cp => x_max_cp,
    x_igs_pr_class_std_id => x_igs_pr_class_std_id
  );

  insert into IGS_PR_RU_APPL_ALL (
    PROGRESSION_RULE_CAT,
    SEQUENCE_NUMBER,
    S_RELATION_TYPE,
    PROGRESSION_RULE_CD,
    REFERENCE_CD,
    RUL_SEQUENCE_NUMBER,
    ATTENDANCE_TYPE,
    OU_ORG_UNIT_CD,
    OU_START_DT,
    COURSE_TYPE,
    CRV_COURSE_CD,
    CRV_VERSION_NUMBER,
    SCA_PERSON_ID,
    SCA_COURSE_CD,
    PRO_PROGRESSION_RULE_CAT,
    PRO_PRA_SEQUENCE_NUMBER,
    PRO_SEQUENCE_NUMBER,
    SPO_PERSON_ID,
    SPO_COURSE_CD,
    SPO_SEQUENCE_NUMBER,
    LOGICAL_DELETE_DT,
    MESSAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    MIN_CP,
    MAX_CP,
    IGS_PR_CLASS_STD_ID
  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.S_RELATION_TYPE,
    NEW_REFERENCES.PROGRESSION_RULE_CD,
    NEW_REFERENCES.REFERENCE_CD,
    NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    NEW_REFERENCES.ATTENDANCE_TYPE,
    NEW_REFERENCES.OU_ORG_UNIT_CD,
    NEW_REFERENCES.OU_START_DT,
    NEW_REFERENCES.COURSE_TYPE,
    NEW_REFERENCES.CRV_COURSE_CD,
    NEW_REFERENCES.CRV_VERSION_NUMBER,
    NEW_REFERENCES.SCA_PERSON_ID,
    NEW_REFERENCES.SCA_COURSE_CD,
    NEW_REFERENCES.PRO_PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PRO_PRA_SEQUENCE_NUMBER,
    NEW_REFERENCES.PRO_SEQUENCE_NUMBER,
    NEW_REFERENCES.SPO_PERSON_ID,
    NEW_REFERENCES.SPO_COURSE_CD,
    NEW_REFERENCES.SPO_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.MESSAGE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.MIN_CP,
    NEW_REFERENCES.MAX_CP,
    NEW_REFERENCES.IGS_PR_CLASS_STD_ID
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_REFERENCE_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_OU_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_CRV_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SCA_PERSON_ID in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_PRO_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRO_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_SPO_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MESSAGE in VARCHAR2,
  X_MIN_CP IN NUMBER DEFAULT NULL,
  X_MAX_CP IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
) AS
  cursor c1 is select
      S_RELATION_TYPE,
      PROGRESSION_RULE_CD,
      REFERENCE_CD,
      RUL_SEQUENCE_NUMBER,
      ATTENDANCE_TYPE,
      OU_ORG_UNIT_CD,
      OU_START_DT,
      COURSE_TYPE,
      CRV_COURSE_CD,
      CRV_VERSION_NUMBER,
      SCA_PERSON_ID,
      SCA_COURSE_CD,
      PRO_PROGRESSION_RULE_CAT,
      PRO_PRA_SEQUENCE_NUMBER,
      PRO_SEQUENCE_NUMBER,
      SPO_PERSON_ID,
      SPO_COURSE_CD,
      SPO_SEQUENCE_NUMBER,
      LOGICAL_DELETE_DT,
      MESSAGE,
      MIN_CP,
      MAX_CP,
      IGS_PR_CLASS_STD_ID
    from IGS_PR_RU_APPL_ALL
    where ROWID = X_ROWID for update nowait;
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

  if ( (tlinfo.S_RELATION_TYPE = X_S_RELATION_TYPE)
      AND ((tlinfo.PROGRESSION_RULE_CD = X_PROGRESSION_RULE_CD)
           OR ((tlinfo.PROGRESSION_RULE_CD is null)
               AND (X_PROGRESSION_RULE_CD is null)))
      AND ((tlinfo.REFERENCE_CD = X_REFERENCE_CD)
           OR ((tlinfo.REFERENCE_CD is null)
               AND (X_REFERENCE_CD is null)))
      AND ((tlinfo.RUL_SEQUENCE_NUMBER = X_RUL_SEQUENCE_NUMBER)
           OR ((tlinfo.RUL_SEQUENCE_NUMBER is null)
               AND (X_RUL_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.ATTENDANCE_TYPE = X_ATTENDANCE_TYPE)
           OR ((tlinfo.ATTENDANCE_TYPE is null)
               AND (X_ATTENDANCE_TYPE is null)))
      AND ((tlinfo.OU_ORG_UNIT_CD = X_OU_ORG_UNIT_CD)
           OR ((tlinfo.OU_ORG_UNIT_CD is null)
               AND (X_OU_ORG_UNIT_CD is null)))
      AND ((tlinfo.OU_START_DT = X_OU_START_DT)
           OR ((tlinfo.OU_START_DT is null)
               AND (X_OU_START_DT is null)))
      AND ((tlinfo.COURSE_TYPE = X_COURSE_TYPE)
           OR ((tlinfo.COURSE_TYPE is null)
               AND (X_COURSE_TYPE is null)))
      AND ((tlinfo.CRV_COURSE_CD = X_CRV_COURSE_CD)
           OR ((tlinfo.CRV_COURSE_CD is null)
               AND (X_CRV_COURSE_CD is null)))
      AND ((tlinfo.CRV_VERSION_NUMBER = X_CRV_VERSION_NUMBER)
           OR ((tlinfo.CRV_VERSION_NUMBER is null)
               AND (X_CRV_VERSION_NUMBER is null)))
      AND ((tlinfo.SCA_PERSON_ID = X_SCA_PERSON_ID)
           OR ((tlinfo.SCA_PERSON_ID is null)
               AND (X_SCA_PERSON_ID is null)))
      AND ((tlinfo.SCA_COURSE_CD = X_SCA_COURSE_CD)
           OR ((tlinfo.SCA_COURSE_CD is null)
               AND (X_SCA_COURSE_CD is null)))
      AND ((tlinfo.PRO_PROGRESSION_RULE_CAT = X_PRO_PROGRESSION_RULE_CAT)
           OR ((tlinfo.PRO_PROGRESSION_RULE_CAT is null)
               AND (X_PRO_PROGRESSION_RULE_CAT is null)))
      AND ((tlinfo.PRO_PRA_SEQUENCE_NUMBER = X_PRO_PRA_SEQUENCE_NUMBER)
           OR ((tlinfo.PRO_PRA_SEQUENCE_NUMBER is null)
               AND (X_PRO_PRA_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.PRO_SEQUENCE_NUMBER = X_PRO_SEQUENCE_NUMBER)
           OR ((tlinfo.PRO_SEQUENCE_NUMBER is null)
               AND (X_PRO_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.SPO_PERSON_ID = X_SPO_PERSON_ID)
           OR ((tlinfo.SPO_PERSON_ID is null)
               AND (X_SPO_PERSON_ID is null)))
      AND ((tlinfo.SPO_COURSE_CD = X_SPO_COURSE_CD)
           OR ((tlinfo.SPO_COURSE_CD is null)
               AND (X_SPO_COURSE_CD is null)))
      AND ((tlinfo.SPO_SEQUENCE_NUMBER = X_SPO_SEQUENCE_NUMBER)
           OR ((tlinfo.SPO_SEQUENCE_NUMBER is null)
               AND (X_SPO_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
      AND ((tlinfo.MIN_CP = X_MIN_CP)
           OR ((tlinfo.MIN_CP is null)
               AND (X_MIN_CP is null)))
      AND ((tlinfo.MAX_CP = X_MAX_CP)
           OR ((tlinfo.MAX_CP is null)
               AND (X_MAX_CP is null)))
      AND ((tlinfo.IGS_PR_CLASS_STD_ID = X_IGS_PR_CLASS_STD_ID)
           OR ((tlinfo.IGS_PR_CLASS_STD_ID is null)
               AND (X_IGS_PR_CLASS_STD_ID is null)))
      AND ((tlinfo.MESSAGE = X_MESSAGE)
           OR ((tlinfo.MESSAGE is null)
               AND (X_MESSAGE is null)))
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
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_REFERENCE_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_OU_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_CRV_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SCA_PERSON_ID in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_PRO_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRO_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_SPO_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MESSAGE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_MIN_CP IN NUMBER DEFAULT NULL,
  X_MAX_CP IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
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
    x_rowid => x_rowid ,
    x_sca_course_cd => x_sca_course_cd,
    x_pro_progression_rule_cat => x_pro_progression_rule_cat ,
    x_pro_pra_sequence_number => x_pro_pra_sequence_number ,
    x_pro_sequence_number => x_pro_sequence_number ,
    x_spo_person_id => x_spo_person_id ,
    x_spo_course_cd => x_spo_course_cd ,
    x_spo_sequence_number => x_spo_sequence_number ,
    x_logical_delete_dt => x_logical_delete_dt ,
    x_message => x_message ,
    x_progression_rule_cat => x_progression_rule_cat ,
    x_sequence_number => x_sequence_number ,
    x_s_relation_type => x_s_relation_type ,
    x_progression_rule_cd => x_progression_rule_cd ,
    x_reference_cd => x_reference_cd ,
    x_rul_sequence_number => x_rul_sequence_number ,
    x_attendance_type => x_attendance_type ,
    x_ou_org_unit_cd => x_ou_org_unit_cd ,
    x_ou_start_dt => x_ou_start_dt ,
    x_course_type => x_course_type ,
    x_crv_course_cd => x_crv_course_cd ,
    x_crv_version_number => x_crv_version_number ,
    x_sca_person_id => x_sca_person_id ,
    x_creation_date => x_last_update_date ,
    x_created_by => x_last_updated_by ,
    x_last_update_date => x_last_update_date ,
    x_last_updated_by => x_last_updated_by ,
    x_last_update_login =>x_last_update_login,
    x_min_cp => x_min_cp,
    x_max_cp => x_max_cp,
    x_igs_pr_class_std_id => x_igs_pr_class_std_id
  );

  update IGS_PR_RU_APPL_ALL set
    S_RELATION_TYPE = NEW_REFERENCES.S_RELATION_TYPE,
    PROGRESSION_RULE_CD = NEW_REFERENCES.PROGRESSION_RULE_CD,
    REFERENCE_CD = NEW_REFERENCES.REFERENCE_CD,
    RUL_SEQUENCE_NUMBER = NEW_REFERENCES.RUL_SEQUENCE_NUMBER,
    ATTENDANCE_TYPE = NEW_REFERENCES.ATTENDANCE_TYPE,
    OU_ORG_UNIT_CD = NEW_REFERENCES.OU_ORG_UNIT_CD,
    OU_START_DT = NEW_REFERENCES.OU_START_DT,
    COURSE_TYPE = NEW_REFERENCES.COURSE_TYPE,
    CRV_COURSE_CD = NEW_REFERENCES.CRV_COURSE_CD,
    CRV_VERSION_NUMBER = NEW_REFERENCES.CRV_VERSION_NUMBER,
    SCA_PERSON_ID = NEW_REFERENCES.SCA_PERSON_ID,
    SCA_COURSE_CD = NEW_REFERENCES.SCA_COURSE_CD,
    PRO_PROGRESSION_RULE_CAT = NEW_REFERENCES.PRO_PROGRESSION_RULE_CAT,
    PRO_PRA_SEQUENCE_NUMBER = NEW_REFERENCES.PRO_PRA_SEQUENCE_NUMBER,
    PRO_SEQUENCE_NUMBER = NEW_REFERENCES.PRO_SEQUENCE_NUMBER,
    SPO_PERSON_ID = NEW_REFERENCES.SPO_PERSON_ID,
    SPO_COURSE_CD = NEW_REFERENCES.SPO_COURSE_CD,
    SPO_SEQUENCE_NUMBER = NEW_REFERENCES.SPO_SEQUENCE_NUMBER,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    MESSAGE = NEW_REFERENCES.MESSAGE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    MIN_CP = NEW_REFERENCES.MIN_CP,
    MAX_CP = NEW_REFERENCES.MAX_CP,
    IGS_PR_CLASS_STD_ID = NEW_REFERENCES.IGS_PR_CLASS_STD_ID
  where ROWID = X_ROWID  ;

  if (sql%notfound) then
    raise no_data_found;
  end if;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_S_RELATION_TYPE in VARCHAR2,
  X_PROGRESSION_RULE_CD in VARCHAR2,
  X_REFERENCE_CD in VARCHAR2,
  X_RUL_SEQUENCE_NUMBER in NUMBER,
  X_ATTENDANCE_TYPE in VARCHAR2,
  X_OU_ORG_UNIT_CD in VARCHAR2,
  X_OU_START_DT in DATE,
  X_COURSE_TYPE in VARCHAR2,
  X_CRV_COURSE_CD in VARCHAR2,
  X_CRV_VERSION_NUMBER in NUMBER,
  X_SCA_PERSON_ID in NUMBER,
  X_SCA_COURSE_CD in VARCHAR2,
  X_PRO_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRO_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_SPO_PERSON_ID in NUMBER,
  X_SPO_COURSE_CD in VARCHAR2,
  X_SPO_SEQUENCE_NUMBER in NUMBER,
  X_LOGICAL_DELETE_DT in DATE,
  X_MESSAGE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER,
  X_MIN_CP IN NUMBER DEFAULT NULL,
  X_MAX_CP IN NUMBER DEFAULT NULL,
  X_IGS_PR_CLASS_STD_ID IN NUMBER DEFAULT NULL
  ) AS
     cursor c1 is select rowid from IGS_PR_RU_APPL_ALL
     where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PROGRESSION_RULE_CAT,
     X_SEQUENCE_NUMBER,
     X_S_RELATION_TYPE,
     X_PROGRESSION_RULE_CD,
     X_REFERENCE_CD,
     X_RUL_SEQUENCE_NUMBER,
     X_ATTENDANCE_TYPE,
     X_OU_ORG_UNIT_CD,
     X_OU_START_DT,
     X_COURSE_TYPE,
     X_CRV_COURSE_CD,
     X_CRV_VERSION_NUMBER,
     X_SCA_PERSON_ID,
     X_SCA_COURSE_CD,
     X_PRO_PROGRESSION_RULE_CAT,
     X_PRO_PRA_SEQUENCE_NUMBER,
     X_PRO_SEQUENCE_NUMBER,
     X_SPO_PERSON_ID,
     X_SPO_COURSE_CD,
     X_SPO_SEQUENCE_NUMBER,
     X_LOGICAL_DELETE_DT,
     X_MESSAGE,
     X_MODE,
     X_ORG_ID,
     X_MIN_CP,
     X_MAX_CP,
     X_IGS_PR_CLASS_STD_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PROGRESSION_RULE_CAT,
   X_SEQUENCE_NUMBER,
   X_S_RELATION_TYPE,
   X_PROGRESSION_RULE_CD,
   X_REFERENCE_CD,
   X_RUL_SEQUENCE_NUMBER,
   X_ATTENDANCE_TYPE,
   X_OU_ORG_UNIT_CD,
   X_OU_START_DT,
   X_COURSE_TYPE,
   X_CRV_COURSE_CD,
   X_CRV_VERSION_NUMBER,
   X_SCA_PERSON_ID,
   X_SCA_COURSE_CD,
   X_PRO_PROGRESSION_RULE_CAT,
   X_PRO_PRA_SEQUENCE_NUMBER,
   X_PRO_SEQUENCE_NUMBER,
   X_SPO_PERSON_ID,
   X_SPO_COURSE_CD,
   X_SPO_SEQUENCE_NUMBER,
   X_LOGICAL_DELETE_DT,
   X_MESSAGE,
   X_MODE,
   X_MIN_CP,
   X_MAX_CP,
   X_IGS_PR_CLASS_STD_ID);

end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) is
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PR_RU_APPL_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 DEFAULT NULL,
	Column_Value IN VARCHAR2 DEFAULT NULL
	) AS
    BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'ATTENDANCE_TYPE' THEN
  new_references.ATTENDANCE_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'COURSE_TYPE' THEN
  new_references.COURSE_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'CRV_COURSE_CD' THEN
  new_references.CRV_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'OU_ORG_UNIT_CD' THEN
  new_references.OU_ORG_UNIT_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' THEN
  new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CD' THEN
  new_references.PROGRESSION_RULE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'REFERENCE_CD' THEN
  new_references.REFERENCE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SCA_COURSE_CD' THEN
  new_references.SCA_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'SPO_COURSE_CD' THEN
  new_references.SPO_COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRO_PROGRESSION_RULE_CAT' THEN
  new_references.PRO_PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'S_RELATION_TYPE' THEN
  new_references.S_RELATION_TYPE:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRO_PRA_SEQUENCE_NUMBER' THEN
  new_references.PRO_PRA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRO_SEQUENCE_NUMBER' THEN
  new_references.PRO_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'SPO_SEQUENCE_NUMBER' THEN
  new_references.SPO_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'MIN_CP' THEN
  new_references.MIN_CP := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'MAX_CP' THEN
  new_references.MAX_CP := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'IGS_PR_CLASS_STD_ID' THEN
  new_references.IGS_PR_CLASS_STD_ID := IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'ATTENDANCE_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.ATTENDANCE_TYPE<> upper(new_references.ATTENDANCE_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'COURSE_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_TYPE<> upper(new_references.COURSE_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'CRV_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.CRV_COURSE_CD<> upper(new_references.CRV_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;


IF upper(Column_name) = 'PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CAT<> upper(new_references.PROGRESSION_RULE_CAT) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROGRESSION_RULE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CD<> upper(new_references.PROGRESSION_RULE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'REFERENCE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.REFERENCE_CD<> upper(new_references.REFERENCE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SCA_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SCA_COURSE_CD<> upper(new_references.SCA_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SPO_COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.SPO_COURSE_CD<> upper(new_references.SPO_COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRO_PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRO_PROGRESSION_RULE_CAT<> upper(new_references.PRO_PROGRESSION_RULE_CAT) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'S_RELATION_TYPE' OR COLUMN_NAME IS NULL THEN
  IF new_references.S_RELATION_TYPE<> upper(new_references.S_RELATION_TYPE) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

  IF new_references.S_RELATION_TYPE not in  ('OU' , 'CTY' , 'CRV' , 'SCA' , 'PRR' , 'PRGC' , 'SPO' , 'PRO' ) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRO_PRA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRO_PRA_SEQUENCE_NUMBER < 1 or new_references.PRO_PRA_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRO_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRO_SEQUENCE_NUMBER < 1 or new_references.PRO_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'SPO_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.SPO_SEQUENCE_NUMBER < 1 or new_references.SPO_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

END Check_Constraints;


end IGS_PR_RU_APPL_PKG;

/
