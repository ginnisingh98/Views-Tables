--------------------------------------------------------
--  DDL for Package Body IGS_EN_CAL_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CAL_CONF_PKG" AS
/* $Header: IGSEI26B.pls 120.1 2005/06/15 01:43:28 appldev  $ */

  l_rowid VARCHAR2(25);
  old_references IGS_EN_CAL_CONF%RowType;
  new_references IGS_EN_CAL_CONF%RowType;


  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_commence_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_effect_enr_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_record_open_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_record_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_sub_unit_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_variation_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_form_due_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_pckg_prod_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_load_effect_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_rule_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_invalid_rule_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_cleanup_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_lapse_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_schema_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_begin_trans_dt_alias IN VARCHAR2  DEFAULT NULL,
    x_clean_trans_dt_alias IN VARCHAR2  DEFAULT NULL,
    x_planning_open_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_schedule_open_dt_alias IN VARCHAR2 ,
    x_audit_status_dt_alias IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_CAL_CONF
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN( 'INSERT','VALIDATE_INSERT' )) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.s_control_num := x_s_control_num;
    new_references.commence_cutoff_dt_alias := x_commence_cutoff_dt_alias;
    new_references.commencement_dt_alias := x_commencement_dt_alias;
    new_references.effect_enr_strt_dt_alias := x_effect_enr_strt_dt_alias;
    new_references.record_open_dt_alias := x_record_open_dt_alias;
    new_references.record_cutoff_dt_alias := x_record_cutoff_dt_alias;
    new_references.sub_unit_dt_alias := x_sub_unit_dt_alias;
    new_references.variation_cutoff_dt_alias := x_variation_cutoff_dt_alias;
    new_references.enr_form_due_dt_alias := x_enr_form_due_dt_alias;
    new_references.enr_pckg_prod_dt_alias := x_enr_pckg_prod_dt_alias;
    new_references.load_effect_dt_alias := x_load_effect_dt_alias;
    new_references.enrolled_rule_cutoff_dt_alias := x_enr_rule_cutoff_dt_alias;
    new_references.invalid_rule_cutoff_dt_alias := x_invalid_rule_cutoff_dt_alias;
    new_references.enr_cleanup_dt_alias := x_enr_cleanup_dt_alias;
    new_references.lapse_dt_alias := x_lapse_dt_alias;
    new_references.grading_schema_dt_alias := x_grading_schema_dt_alias;
    new_references.begin_trans_dt_alias := x_begin_trans_dt_alias;
    new_references.clean_trans_dt_alias := x_clean_trans_dt_alias;
    new_references.planning_open_dt_alias := x_planning_open_dt_alias;
    new_references.schedule_open_dt_alias := x_schedule_open_dt_alias;
    new_references.audit_status_dt_alias := x_audit_status_dt_alias;

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




procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
      		NULL;
	ELSIF upper(column_name) = 'S_CONTROL_NUM' THEN
    	  new_references.s_control_num := igs_ge_number.to_num(TO_NUMBER(column_value));
	ELSIF upper(column_name) = 'COMMENCEMENT_DT_ALIAS' THEN
   	   new_references.commencement_dt_alias := column_value;
	ELSIF upper(column_name) = 'COMMENCE_CUTOFF_DT_ALIAS' THEN
  	    new_references.commence_cutoff_dt_alias := column_value;
	ELSIF upper(column_name) = 'EFFECT_ENR_STRT_DT_ALIAS' THEN
   	   new_references.effect_enr_strt_dt_alias := column_value;
	ELSIF upper(column_name) = 'ENROLLED_RULE_CUTOFF_DT_ALIAS' THEN
      		new_references.enrolled_rule_cutoff_dt_alias := column_value;
         ELSIF upper(column_name) = 'ENR_CLEANUP_DT_ALIAS' THEN
              new_references.enr_cleanup_dt_alias := column_value;
          ELSIF upper(column_name) = 'ENR_FORM_DUE_DT_ALIAS' THEN
              new_references.enr_form_due_dt_alias := column_value;
         ELSIF upper(column_name) = 'ENR_PCKG_PROD_DT_ALIAS' THEN
              new_references.enr_pckg_prod_dt_alias := column_value;
         ELSIF upper(column_name) = 'INVALID_RULE_CUTOFF_DT_ALIAS' THEN
              new_references.invalid_rule_cutoff_dt_alias := column_value;
         ELSIF upper(column_name) = 'LAPSE_DT_ALIAS' THEN
             new_references.lapse_dt_alias := column_value;
         ELSIF upper(column_name) = 'LOAD_EFFECT_DT_ALIAS' THEN
              new_references.load_effect_dt_alias := column_value;
          ELSIF upper(column_name) = 'RECORD_CUTOFF_DT_ALIAS' THEN
              new_references.record_cutoff_dt_alias := column_value;
         ELSIF upper(column_name) = 'RECORD_OPEN_DT_ALIAS' THEN
              new_references.record_open_dt_alias := column_value;
         ELSIF upper(column_name) = 'SUB_UNIT_DT_ALIAS' THEN
              new_references.sub_unit_dt_alias := column_value;
         ELSIF upper(column_name) = 'VARIATION_CUTOFF_DT_ALIAS' THEN
             new_references.variation_cutoff_dt_alias := column_value;
	END IF;

IF upper(column_name) = 'S_CONTROL_NUM' OR
       Column_name is null THEN
       IF new_references.s_control_num NOT IN ( 1 ) THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'COMMENCEMENT_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.commencement_dt_alias <>
                    upper(new_references.commencement_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'COMMENCE_CUTOFF_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.commence_cutoff_dt_alias <>
                    upper(new_references.commence_cutoff_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'EFFECT_ENR_STRT_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.effect_enr_strt_dt_alias <>
                    upper(new_references.effect_enr_strt_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'ENROLLED_RULE_CUTOFF_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.enrolled_rule_cutoff_dt_alias <>
                    upper(new_references.enrolled_rule_cutoff_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;
IF upper(column_name) = 'ENR_CLEANUP_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.enr_cleanup_dt_alias <>
                    upper(new_references.enr_cleanup_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'ENR_FORM_DUE_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.enr_form_due_dt_alias <>
                    upper(new_references.enr_form_due_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'ENR_PCKG_PROD_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.enr_pckg_prod_dt_alias <>
                    upper(new_references.enr_pckg_prod_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'INVALID_RULE_CUTOFF_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.invalid_rule_cutoff_dt_alias <>
                    upper(new_references.invalid_rule_cutoff_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'LAPSE_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.lapse_dt_alias <>
                    upper(new_references.lapse_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'LOAD_EFFECT_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.load_effect_dt_alias <>
                    upper(new_references.load_effect_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'RECORD_CUTOFF_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.record_cutoff_dt_alias <>
                    upper(new_references.record_cutoff_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'RECORD_OPEN_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.record_open_dt_alias <>
                    upper(new_references.record_open_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'SUB_UNIT_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.sub_unit_dt_alias <>
                    upper(new_references.sub_unit_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'VARIATION_CUTOFF_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.variation_cutoff_dt_alias <>
                    upper(new_references.variation_cutoff_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'BEGIN_TRANS_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.begin_trans_dt_alias <>
                    upper(new_references.begin_trans_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'CLEAN_TRANS_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.clean_trans_dt_alias <>
                    upper(new_references.clean_trans_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'PLANNING_OPEN_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.planning_open_dt_alias <>
                    upper(new_references.planning_open_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'SCHEDULE_OPEN_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.schedule_open_dt_alias <>
                    upper(new_references.schedule_open_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;

IF upper(column_name) = 'AUDIT_STATUS_DT_ALIAS' OR
       Column_name is null THEN
       IF new_references.audit_status_dt_alias <>
                    upper(new_references.audit_status_dt_alias)  THEN
              Fnd_Message.Set_Name ('IGS','IGS_GE_INVALID_VALUE');
              IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;
END IF;


END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.enr_pckg_prod_dt_alias = new_references.enr_pckg_prod_dt_alias)) OR
        ((new_references.enr_pckg_prod_dt_alias IS NULL))) THEN
      NULL;
    ELSE
       if not IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.enr_pckg_prod_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.record_cutoff_dt_alias = new_references.record_cutoff_dt_alias)) OR
        ((new_references.record_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      if not IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.record_cutoff_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.record_open_dt_alias = new_references.record_open_dt_alias)) OR
        ((new_references.record_open_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.record_open_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.sub_unit_dt_alias = new_references.sub_unit_dt_alias)) OR
        ((new_references.sub_unit_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.sub_unit_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.variation_cutoff_dt_alias = new_references.variation_cutoff_dt_alias)) OR
        ((new_references.variation_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
       IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.variation_cutoff_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.commencement_dt_alias = new_references.commencement_dt_alias)) OR
        ((new_references.commencement_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.commencement_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.commence_cutoff_dt_alias = new_references.commence_cutoff_dt_alias)) OR
        ((new_references.commence_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.commence_cutoff_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.enr_form_due_dt_alias = new_references.enr_form_due_dt_alias)) OR
        ((new_references.enr_form_due_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.enr_form_due_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.effect_enr_strt_dt_alias = new_references.effect_enr_strt_dt_alias)) OR
        ((new_references.effect_enr_strt_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.effect_enr_strt_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.enrolled_rule_cutoff_dt_alias = new_references.enrolled_rule_cutoff_dt_alias)) OR
        ((new_references.enrolled_rule_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.enrolled_rule_cutoff_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.invalid_rule_cutoff_dt_alias = new_references.invalid_rule_cutoff_dt_alias)) OR
        ((new_references.invalid_rule_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.invalid_rule_cutoff_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.lapse_dt_alias = new_references.lapse_dt_alias)) OR
        ((new_references.lapse_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.lapse_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.load_effect_dt_alias = new_references.load_effect_dt_alias)) OR
        ((new_references.load_effect_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.load_effect_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.enr_cleanup_dt_alias = new_references.enr_cleanup_dt_alias)) OR
        ((new_references.enr_cleanup_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.enr_cleanup_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.begin_trans_dt_alias = new_references.begin_trans_dt_alias)) OR
        ((new_references.begin_trans_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.begin_trans_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

    IF (((old_references.clean_trans_dt_alias = new_references.clean_trans_dt_alias)) OR
        ((new_references.clean_trans_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.clean_trans_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

     IF (((old_references.planning_open_dt_alias = new_references.planning_open_dt_alias)) OR
        ((new_references.planning_open_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.planning_open_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

     IF (((old_references.schedule_open_dt_alias = new_references.schedule_open_dt_alias)) OR
        ((new_references.schedule_open_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.schedule_open_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;

   IF (((old_references.audit_status_dt_alias = new_references.audit_status_dt_alias)) OR
        ((new_references.audit_status_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.audit_status_dt_alias
        ) then
          Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
	end if;
    END IF;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAL_CONF
      WHERE    s_control_num = x_s_control_num
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAL_CONF
      WHERE    commence_cutoff_dt_alias = x_dt_alias
         OR    commencement_dt_alias = x_dt_alias
         OR    effect_enr_strt_dt_alias = x_dt_alias
         OR    enr_cleanup_dt_alias = x_dt_alias
         OR    enr_form_due_dt_alias = x_dt_alias
         OR    enr_pckg_prod_dt_alias = x_dt_alias
         OR    enrolled_rule_cutoff_dt_alias = x_dt_alias
         OR    invalid_rule_cutoff_dt_alias = x_dt_alias
         OR    lapse_dt_alias = x_dt_alias
         OR    load_effect_dt_alias = x_dt_alias
         OR    record_cutoff_dt_alias = x_dt_alias
         OR    record_open_dt_alias = x_dt_alias
         OR    sub_unit_dt_alias = x_dt_alias
         OR    variation_cutoff_dt_alias = x_dt_alias
	 OR    begin_trans_dt_alias = x_dt_alias
	 OR    clean_trans_dt_alias = x_dt_alias
     OR planning_open_dt_alias = x_dt_alias
      OR schedule_open_dt_alias = x_dt_alias
      OR audit_status_dt_alias  = x_dt_alias;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_SECC_DA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_commence_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_commencement_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_effect_enr_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_record_open_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_record_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_sub_unit_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_variation_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_form_due_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_pckg_prod_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_load_effect_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_rule_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_invalid_rule_cutoff_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_enr_cleanup_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_lapse_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_grading_schema_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_begin_trans_dt_alias IN VARCHAR2  DEFAULT NULL,
    x_clean_trans_dt_alias IN VARCHAR2  DEFAULT NULL,
    x_planning_open_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_schedule_open_dt_alias IN VARCHAR2 DEFAULT NULL ,
    x_audit_status_dt_alias IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_commence_cutoff_dt_alias,
      x_commencement_dt_alias,
      x_effect_enr_strt_dt_alias,
      x_record_open_dt_alias,
      x_record_cutoff_dt_alias,
      x_sub_unit_dt_alias,
      x_variation_cutoff_dt_alias,
      x_enr_form_due_dt_alias,
      x_enr_pckg_prod_dt_alias,
      x_load_effect_dt_alias,
      x_enr_rule_cutoff_dt_alias,
      x_invalid_rule_cutoff_dt_alias,
      x_enr_cleanup_dt_alias,
      x_lapse_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_grading_schema_dt_alias,
      x_begin_trans_dt_alias,
      x_clean_trans_dt_alias,
      x_planning_open_dt_alias ,
      x_schedule_open_dt_alias ,
      x_audit_status_dt_alias
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	if Get_PK_For_Validation (
	    new_references.s_control_num
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	if Get_PK_For_Validation (
	    new_references.s_control_num
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 Check_constraints;
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
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_COMMENCE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_COMMENCEMENT_DT_ALIAS in VARCHAR2,
  X_EFFECT_ENR_STRT_DT_ALIAS in VARCHAR2,
  X_RECORD_OPEN_DT_ALIAS in VARCHAR2,
  X_RECORD_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SUB_UNIT_DT_ALIAS in VARCHAR2,
  X_VARIATION_CUTOFF_DT_ALIAS in VARCHAR2,
  X_ENR_FORM_DUE_DT_ALIAS in VARCHAR2,
  X_ENR_PCKG_PROD_DT_ALIAS in VARCHAR2,
  X_LOAD_EFFECT_DT_ALIAS in VARCHAR2,
  X_ENR_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_INVALID_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_LAPSE_DT_ALIAS in VARCHAR2,
  X_ENR_CLEANUP_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_grading_schema_dt_alias IN VARCHAR2,
  x_begin_trans_dt_alias IN VARCHAR2,
  x_clean_trans_dt_alias IN VARCHAR2,
  x_planning_open_dt_alias IN VARCHAR2 ,
  x_schedule_open_dt_alias IN VARCHAR2 ,
  x_audit_status_dt_alias IN VARCHAR2

  ) AS
    cursor C is select ROWID from IGS_EN_CAL_CONF
      where S_CONTROL_NUM = NEW_REFERENCES.S_CONTROL_NUM;
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
      p_action => 'INSERT' ,
      x_rowid => x_rowid ,
      x_s_control_num => NVL(x_s_control_num,1) ,
      x_commence_cutoff_dt_alias => x_commence_cutoff_dt_alias ,
      x_commencement_dt_alias => x_commencement_dt_alias ,
      x_effect_enr_strt_dt_alias => x_effect_enr_strt_dt_alias ,
      x_record_open_dt_alias => x_record_open_dt_alias ,
      x_record_cutoff_dt_alias => x_record_cutoff_dt_alias ,
      x_sub_unit_dt_alias => x_sub_unit_dt_alias ,
      x_variation_cutoff_dt_alias => x_variation_cutoff_dt_alias ,
      x_enr_form_due_dt_alias => x_enr_form_due_dt_alias ,
      x_enr_pckg_prod_dt_alias => x_enr_pckg_prod_dt_alias ,
      x_load_effect_dt_alias => x_load_effect_dt_alias ,
      x_enr_rule_cutoff_dt_alias => x_enr_rule_cutoff_dt_alias ,
      x_invalid_rule_cutoff_dt_alias => x_invalid_rule_cutoff_dt_alias ,
      x_enr_cleanup_dt_alias => x_enr_cleanup_dt_alias ,
      x_lapse_dt_alias => x_lapse_dt_alias ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login,
      x_grading_schema_dt_alias => x_grading_schema_dt_alias,
      x_begin_trans_dt_alias => x_begin_trans_dt_alias,
      x_clean_trans_dt_alias => x_clean_trans_dt_alias,
      x_planning_open_dt_alias =>x_planning_open_dt_alias,
      x_schedule_open_dt_alias => x_schedule_open_dt_alias,
      x_audit_status_dt_alias => x_audit_status_dt_alias
    );


  insert into IGS_EN_CAL_CONF (
    S_CONTROL_NUM,
    COMMENCE_CUTOFF_DT_ALIAS,
    COMMENCEMENT_DT_ALIAS,
    EFFECT_ENR_STRT_DT_ALIAS,
    RECORD_OPEN_DT_ALIAS,
    RECORD_CUTOFF_DT_ALIAS,
    SUB_UNIT_DT_ALIAS,
    VARIATION_CUTOFF_DT_ALIAS,
    ENR_FORM_DUE_DT_ALIAS,
    ENR_PCKG_PROD_DT_ALIAS,
    LOAD_EFFECT_DT_ALIAS,
    ENROLLED_RULE_CUTOFF_DT_ALIAS,
    INVALID_RULE_CUTOFF_DT_ALIAS,
    LAPSE_DT_ALIAS,
    ENR_CLEANUP_DT_ALIAS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    grading_schema_dt_alias,
    begin_trans_dt_alias,
    clean_trans_dt_alias,
    planning_open_dt_alias,
    schedule_open_dt_alias,
    audit_status_dt_alias
  ) values (
    NEW_REFERENCES.S_CONTROL_NUM,
    NEW_REFERENCES.COMMENCE_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.COMMENCEMENT_DT_ALIAS,
    NEW_REFERENCES.EFFECT_ENR_STRT_DT_ALIAS,
    NEW_REFERENCES.RECORD_OPEN_DT_ALIAS,
    NEW_REFERENCES.RECORD_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.SUB_UNIT_DT_ALIAS,
    NEW_REFERENCES.VARIATION_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.ENR_FORM_DUE_DT_ALIAS,
    NEW_REFERENCES.ENR_PCKG_PROD_DT_ALIAS,
    NEW_REFERENCES.LOAD_EFFECT_DT_ALIAS,
    NEW_REFERENCES.ENROLLED_RULE_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.INVALID_RULE_CUTOFF_DT_ALIAS,
    NEW_REFERENCES.LAPSE_DT_ALIAS,
    NEW_REFERENCES.ENR_CLEANUP_DT_ALIAS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    x_grading_schema_dt_alias,
    x_begin_trans_dt_alias,
    x_clean_trans_dt_alias,
    x_planning_open_dt_alias,
    x_schedule_open_dt_alias,
    x_audit_status_dt_alias
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
  X_ROWID IN VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_COMMENCE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_COMMENCEMENT_DT_ALIAS in VARCHAR2,
  X_EFFECT_ENR_STRT_DT_ALIAS in VARCHAR2,
  X_RECORD_OPEN_DT_ALIAS in VARCHAR2,
  X_RECORD_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SUB_UNIT_DT_ALIAS in VARCHAR2,
  X_VARIATION_CUTOFF_DT_ALIAS in VARCHAR2,
  X_ENR_FORM_DUE_DT_ALIAS in VARCHAR2,
  X_ENR_PCKG_PROD_DT_ALIAS in VARCHAR2,
  X_LOAD_EFFECT_DT_ALIAS in VARCHAR2,
  X_ENR_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_INVALID_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_LAPSE_DT_ALIAS in VARCHAR2,
  X_ENR_CLEANUP_DT_ALIAS in VARCHAR2,
  x_grading_schema_dt_alias IN VARCHAR2 ,
  x_begin_trans_dt_alias IN VARCHAR2,
  x_clean_trans_dt_alias IN VARCHAR2,
  x_planning_open_dt_alias IN VARCHAR2 DEFAULT NULL,
  x_schedule_open_dt_alias IN VARCHAR2 ,
  x_audit_status_dt_alias IN VARCHAR2 DEFAULT NULL
) AS
  cursor c1 is select
      COMMENCE_CUTOFF_DT_ALIAS,
      COMMENCEMENT_DT_ALIAS,
      EFFECT_ENR_STRT_DT_ALIAS,
      RECORD_OPEN_DT_ALIAS,
      RECORD_CUTOFF_DT_ALIAS,
      SUB_UNIT_DT_ALIAS,
      VARIATION_CUTOFF_DT_ALIAS,
      ENR_FORM_DUE_DT_ALIAS,
      ENR_PCKG_PROD_DT_ALIAS,
      LOAD_EFFECT_DT_ALIAS,
      ENROLLED_RULE_CUTOFF_DT_ALIAS,
      INVALID_RULE_CUTOFF_DT_ALIAS,
      LAPSE_DT_ALIAS,
      ENR_CLEANUP_DT_ALIAS,
      grading_schema_dt_alias ,
      begin_trans_dt_alias,
      clean_trans_dt_alias,
      planning_open_dt_alias,
      schedule_open_dt_alias,
      audit_status_dt_alias
    from IGS_EN_CAL_CONF
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

  if ( (tlinfo.COMMENCE_CUTOFF_DT_ALIAS = X_COMMENCE_CUTOFF_DT_ALIAS)
      AND ((tlinfo.COMMENCEMENT_DT_ALIAS = X_COMMENCEMENT_DT_ALIAS)
           OR ((tlinfo.COMMENCEMENT_DT_ALIAS is null)
               AND (X_COMMENCEMENT_DT_ALIAS is null)))
      AND (tlinfo.EFFECT_ENR_STRT_DT_ALIAS = X_EFFECT_ENR_STRT_DT_ALIAS)
      AND ((tlinfo.RECORD_OPEN_DT_ALIAS = X_RECORD_OPEN_DT_ALIAS)
           OR ((tlinfo.RECORD_OPEN_DT_ALIAS is null)
               AND (X_RECORD_OPEN_DT_ALIAS is null)))
      AND ((tlinfo.RECORD_CUTOFF_DT_ALIAS = X_RECORD_CUTOFF_DT_ALIAS)
           OR ((tlinfo.RECORD_CUTOFF_DT_ALIAS is null)
               AND (X_RECORD_CUTOFF_DT_ALIAS is null)))
      AND ((tlinfo.SUB_UNIT_DT_ALIAS = X_SUB_UNIT_DT_ALIAS)
           OR ((tlinfo.SUB_UNIT_DT_ALIAS is null)
               AND (X_SUB_UNIT_DT_ALIAS is null)))
      AND ((tlinfo.VARIATION_CUTOFF_DT_ALIAS = X_VARIATION_CUTOFF_DT_ALIAS)
           OR ((tlinfo.VARIATION_CUTOFF_DT_ALIAS is null)
               AND (X_VARIATION_CUTOFF_DT_ALIAS is null)))
      AND ((tlinfo.ENR_FORM_DUE_DT_ALIAS = X_ENR_FORM_DUE_DT_ALIAS)
           OR ((tlinfo.ENR_FORM_DUE_DT_ALIAS is null)
               AND (X_ENR_FORM_DUE_DT_ALIAS is null)))
      AND ((tlinfo.ENR_PCKG_PROD_DT_ALIAS = X_ENR_PCKG_PROD_DT_ALIAS)
           OR ((tlinfo.ENR_PCKG_PROD_DT_ALIAS is null)
               AND (X_ENR_PCKG_PROD_DT_ALIAS is null)))
      AND (tlinfo.LOAD_EFFECT_DT_ALIAS = X_LOAD_EFFECT_DT_ALIAS)
      AND ((tlinfo.ENROLLED_RULE_CUTOFF_DT_ALIAS = X_ENR_RULE_CUTOFF_DT_ALIAS)
           OR ((tlinfo.ENROLLED_RULE_CUTOFF_DT_ALIAS is null)
               AND (X_ENR_RULE_CUTOFF_DT_ALIAS is null)))
      AND ((tlinfo.INVALID_RULE_CUTOFF_DT_ALIAS = X_INVALID_RULE_CUTOFF_DT_ALIAS)
           OR ((tlinfo.INVALID_RULE_CUTOFF_DT_ALIAS is null)
               AND (X_INVALID_RULE_CUTOFF_DT_ALIAS is null)))
      AND (tlinfo.LAPSE_DT_ALIAS = X_LAPSE_DT_ALIAS)
      AND ((tlinfo.ENR_CLEANUP_DT_ALIAS = X_ENR_CLEANUP_DT_ALIAS)
           OR ((tlinfo.ENR_CLEANUP_DT_ALIAS is null)
               AND (X_ENR_CLEANUP_DT_ALIAS is null)))
      AND ((tlinfo.grading_schema_dt_alias = X_grading_schema_dt_alias)
           OR ((tlinfo.grading_schema_dt_alias is null)
               AND (X_grading_schema_dt_alias is null)))
      AND ((tlinfo.begin_trans_dt_alias = x_begin_trans_dt_alias)
           OR ((tlinfo.begin_trans_dt_alias is null)
               AND (x_begin_trans_dt_alias is null)))
      AND ((tlinfo.clean_trans_dt_alias = x_clean_trans_dt_alias)
           OR ((tlinfo.clean_trans_dt_alias is null)
               AND (x_clean_trans_dt_alias is null)))

  AND ((tlinfo.planning_open_dt_alias = x_planning_open_dt_alias)
           OR ((tlinfo.planning_open_dt_alias is null)
               AND (x_planning_open_dt_alias is null)))
     AND ((tlinfo.schedule_open_dt_alias = x_schedule_open_dt_alias)
           OR ((tlinfo.schedule_open_dt_alias is null)
               AND (x_schedule_open_dt_alias is null)))
     AND ((tlinfo.audit_status_dt_alias = x_audit_status_dt_alias)
           OR ((tlinfo.audit_status_dt_alias is null)
               AND (x_audit_status_dt_alias is null)))

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
  X_S_CONTROL_NUM in NUMBER,
  X_COMMENCE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_COMMENCEMENT_DT_ALIAS in VARCHAR2,
  X_EFFECT_ENR_STRT_DT_ALIAS in VARCHAR2,
  X_RECORD_OPEN_DT_ALIAS in VARCHAR2,
  X_RECORD_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SUB_UNIT_DT_ALIAS in VARCHAR2,
  X_VARIATION_CUTOFF_DT_ALIAS in VARCHAR2,
  X_ENR_FORM_DUE_DT_ALIAS in VARCHAR2,
  X_ENR_PCKG_PROD_DT_ALIAS in VARCHAR2,
  X_LOAD_EFFECT_DT_ALIAS in VARCHAR2,
  X_ENR_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_INVALID_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_LAPSE_DT_ALIAS in VARCHAR2,
  X_ENR_CLEANUP_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_grading_schema_dt_alias IN VARCHAR2 ,
  x_begin_trans_dt_alias IN VARCHAR2,
  x_clean_trans_dt_alias IN VARCHAR2,
  x_planning_open_dt_alias IN VARCHAR2 ,
  x_schedule_open_dt_alias IN VARCHAR2 ,
  x_audit_status_dt_alias IN VARCHAR2
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
      p_action => 'UPDATE' ,
      x_rowid => x_rowid ,
      x_s_control_num => x_s_control_num ,
      x_commence_cutoff_dt_alias => x_commence_cutoff_dt_alias ,
      x_commencement_dt_alias => x_commencement_dt_alias ,
      x_effect_enr_strt_dt_alias => x_effect_enr_strt_dt_alias ,
      x_record_open_dt_alias => x_record_open_dt_alias ,
      x_record_cutoff_dt_alias => x_record_cutoff_dt_alias ,
      x_sub_unit_dt_alias => x_sub_unit_dt_alias ,
      x_variation_cutoff_dt_alias => x_variation_cutoff_dt_alias ,
      x_enr_form_due_dt_alias => x_enr_form_due_dt_alias ,
      x_enr_pckg_prod_dt_alias => x_enr_pckg_prod_dt_alias ,
      x_load_effect_dt_alias => x_load_effect_dt_alias ,
      x_enr_rule_cutoff_dt_alias => x_enr_rule_cutoff_dt_alias ,
      x_invalid_rule_cutoff_dt_alias => x_invalid_rule_cutoff_dt_alias ,
      x_enr_cleanup_dt_alias => x_enr_cleanup_dt_alias ,
      x_lapse_dt_alias => x_lapse_dt_alias ,
      x_creation_date => x_last_update_date ,
      x_created_by => x_last_updated_by ,
      x_last_update_date => x_last_update_date ,
      x_last_updated_by => x_last_updated_by ,
      x_last_update_login => x_last_update_login ,
      x_grading_schema_dt_alias =>  x_grading_schema_dt_alias,
      x_begin_trans_dt_alias => x_begin_trans_dt_alias,
      x_clean_trans_dt_alias => x_clean_trans_dt_alias,
      x_planning_open_dt_alias =>x_planning_open_dt_alias,
      x_schedule_open_dt_alias => x_schedule_open_dt_alias,
      x_audit_status_dt_alias => x_audit_status_dt_alias
    );


  update IGS_EN_CAL_CONF set
    COMMENCE_CUTOFF_DT_ALIAS = NEW_REFERENCES.COMMENCE_CUTOFF_DT_ALIAS,
    COMMENCEMENT_DT_ALIAS = NEW_REFERENCES.COMMENCEMENT_DT_ALIAS,
    EFFECT_ENR_STRT_DT_ALIAS = NEW_REFERENCES.EFFECT_ENR_STRT_DT_ALIAS,
    RECORD_OPEN_DT_ALIAS = NEW_REFERENCES.RECORD_OPEN_DT_ALIAS,
    RECORD_CUTOFF_DT_ALIAS = NEW_REFERENCES.RECORD_CUTOFF_DT_ALIAS,
    SUB_UNIT_DT_ALIAS = NEW_REFERENCES.SUB_UNIT_DT_ALIAS,
    VARIATION_CUTOFF_DT_ALIAS = NEW_REFERENCES.VARIATION_CUTOFF_DT_ALIAS,
    ENR_FORM_DUE_DT_ALIAS = NEW_REFERENCES.ENR_FORM_DUE_DT_ALIAS,
    ENR_PCKG_PROD_DT_ALIAS = NEW_REFERENCES.ENR_PCKG_PROD_DT_ALIAS,
    LOAD_EFFECT_DT_ALIAS = NEW_REFERENCES.LOAD_EFFECT_DT_ALIAS,
    ENROLLED_RULE_CUTOFF_DT_ALIAS = NEW_REFERENCES.ENROLLED_RULE_CUTOFF_DT_ALIAS,
    INVALID_RULE_CUTOFF_DT_ALIAS = NEW_REFERENCES.INVALID_RULE_CUTOFF_DT_ALIAS,
    LAPSE_DT_ALIAS = NEW_REFERENCES.LAPSE_DT_ALIAS,
    ENR_CLEANUP_DT_ALIAS = NEW_REFERENCES.ENR_CLEANUP_DT_ALIAS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    grading_schema_dt_alias =  x_grading_schema_dt_alias ,
    begin_trans_dt_alias = x_begin_trans_dt_alias,
    clean_trans_dt_alias = x_clean_trans_dt_alias,
    planning_open_dt_alias=x_planning_open_dt_alias,
    schedule_open_dt_alias=x_schedule_open_dt_alias,
    audit_status_dt_alias=x_audit_status_dt_alias
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
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_COMMENCE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_COMMENCEMENT_DT_ALIAS in VARCHAR2,
  X_EFFECT_ENR_STRT_DT_ALIAS in VARCHAR2,
  X_RECORD_OPEN_DT_ALIAS in VARCHAR2,
  X_RECORD_CUTOFF_DT_ALIAS in VARCHAR2,
  X_SUB_UNIT_DT_ALIAS in VARCHAR2,
  X_VARIATION_CUTOFF_DT_ALIAS in VARCHAR2,
  X_ENR_FORM_DUE_DT_ALIAS in VARCHAR2,
  X_ENR_PCKG_PROD_DT_ALIAS in VARCHAR2,
  X_LOAD_EFFECT_DT_ALIAS in VARCHAR2,
  X_ENR_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_INVALID_RULE_CUTOFF_DT_ALIAS in VARCHAR2,
  X_LAPSE_DT_ALIAS in VARCHAR2,
  X_ENR_CLEANUP_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_grading_schema_dt_alias IN VARCHAR2 ,
  x_begin_trans_dt_alias IN VARCHAR2,
  x_clean_trans_dt_alias IN VARCHAR2,
  x_planning_open_dt_alias IN VARCHAR2 DEFAULT NULL,
  x_schedule_open_dt_alias IN VARCHAR2 ,
  x_audit_status_dt_alias IN VARCHAR2 DEFAULT NULL
  ) AS
  cursor c1 is select rowid from IGS_EN_CAL_CONF
     where S_CONTROL_NUM = nvl(X_S_CONTROL_NUM,1)
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_CONTROL_NUM,
     X_COMMENCE_CUTOFF_DT_ALIAS,
     X_COMMENCEMENT_DT_ALIAS,
     X_EFFECT_ENR_STRT_DT_ALIAS,
     X_RECORD_OPEN_DT_ALIAS,
     X_RECORD_CUTOFF_DT_ALIAS,
     X_SUB_UNIT_DT_ALIAS,
     X_VARIATION_CUTOFF_DT_ALIAS,
     X_ENR_FORM_DUE_DT_ALIAS,
     X_ENR_PCKG_PROD_DT_ALIAS,
     X_LOAD_EFFECT_DT_ALIAS,
     X_ENR_RULE_CUTOFF_DT_ALIAS,
     X_INVALID_RULE_CUTOFF_DT_ALIAS,
     X_LAPSE_DT_ALIAS,
     X_ENR_CLEANUP_DT_ALIAS,
     X_MODE,
     x_grading_schema_dt_alias,
     x_begin_trans_dt_alias,
     x_clean_trans_dt_alias,
     x_planning_open_dt_alias ,
     x_schedule_open_dt_alias ,
     x_audit_status_dt_alias
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_CONTROL_NUM,
   X_COMMENCE_CUTOFF_DT_ALIAS,
   X_COMMENCEMENT_DT_ALIAS,
   X_EFFECT_ENR_STRT_DT_ALIAS,
   X_RECORD_OPEN_DT_ALIAS,
   X_RECORD_CUTOFF_DT_ALIAS,
   X_SUB_UNIT_DT_ALIAS,
   X_VARIATION_CUTOFF_DT_ALIAS,
   X_ENR_FORM_DUE_DT_ALIAS,
   X_ENR_PCKG_PROD_DT_ALIAS,
   X_LOAD_EFFECT_DT_ALIAS,
   X_ENR_RULE_CUTOFF_DT_ALIAS,
   X_INVALID_RULE_CUTOFF_DT_ALIAS,
   X_LAPSE_DT_ALIAS,
   X_ENR_CLEANUP_DT_ALIAS,
   X_MODE,
   x_grading_schema_dt_alias,
   x_begin_trans_dt_alias,
   x_clean_trans_dt_alias,
   x_planning_open_dt_alias ,
   x_schedule_open_dt_alias ,
   x_audit_status_dt_alias
   );

end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
begin

  Before_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_EN_CAL_CONF
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML(
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );


end DELETE_ROW;

end IGS_EN_CAL_CONF_PKG;

/
