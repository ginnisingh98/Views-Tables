--------------------------------------------------------
--  DDL for Package Body IGS_AD_CAL_CONF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_CAL_CONF_PKG" as
/* $Header: IGSAI70B.pls 115.7 2002/11/28 22:13:48 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_AD_CAL_CONF%RowType;
  new_references IGS_AD_CAL_CONF%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_initialise_adm_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_encmb_chk_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_course_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_short_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_due_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_final_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_chg_of_pref_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_offer_resp_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_e_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_m_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_s_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
    X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
    X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_CAL_CONF
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
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.s_control_num := x_s_control_num;
    new_references.initialise_adm_perd_dt_alias := x_initialise_adm_perd_dt_alias;
    new_references.adm_appl_encmb_chk_dt_alias := x_adm_appl_encmb_chk_dt_alias;
    new_references.adm_appl_course_strt_dt_alias := x_ad_appl_course_strt_dt_alias;
    new_references.adm_appl_short_strt_dt_alias := x_adm_appl_short_strt_dt_alias;
    new_references.adm_appl_due_dt_alias := x_adm_appl_due_dt_alias;
    new_references.adm_appl_final_dt_alias := x_adm_appl_final_dt_alias;
    new_references.adm_appl_chng_of_pref_dt_alias := x_ad_appl_chg_of_pref_dt_alias;
    new_references.adm_appl_offer_resp_dt_alias := x_adm_appl_offer_resp_dt_alias;
    new_references.adm_appl_e_comp_perd_dt_alias := x_ad_appl_e_comp_perd_dt_alias;
    new_references.adm_appl_m_comp_perd_dt_alias := x_ad_appl_m_comp_perd_dt_alias;
    new_references.adm_appl_s_comp_perd_dt_alias := x_ad_appl_s_comp_perd_dt_alias;
    new_references.ADM_PRC_TRK_DT_ALIAS := X_ADM_PRC_TRK_DT_ALIAS;
    new_references.POST_ADM_TRK_DT_ALIAS := X_POST_ADM_TRK_DT_ALIAS;
    new_references.INQ_CAL_TYPE  :=  X_INQ_CAL_TYPE;
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
	v_message_name	VARCHAR2(30);
  BEGIN
    -- Validate the date alias values.
    -- Admission Application Offer Response Date Alias.
    IF	p_inserting OR
	((NVL(old_references.adm_appl_offer_resp_dt_alias, 'NULL') <>
   	  NVL(new_references.adm_appl_offer_resp_dt_alias, 'NULL')) AND
	  new_references.adm_appl_offer_resp_dt_alias IS NOT NULL) THEN
	     IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_offer_resp_dt_alias,
			'ADM_APPL_OFFER_RESP_DT_ALIAS',
			v_message_name) = FALSE THEN
		 Fnd_Message.Set_Name('IGS',v_message_name);
		 IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
	      END IF;
    END IF;

    -- Admission Application Change Of Preference Date Alias.
    IF	p_inserting OR
	((NVL(old_references.adm_appl_chng_of_pref_dt_alias, 'NULL') <>
 	  NVL(new_references.adm_appl_chng_of_pref_dt_alias, 'NULL')) AND
	  new_references.adm_appl_chng_of_pref_dt_alias IS NOT NULL) THEN
	    IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			  new_references.adm_appl_chng_of_pref_dt_alias,
			'ADM_APPL_CHNG_OF_PREF_DT_ALIAS',
			v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
                App_Exception.Raise_Exception;
	     END IF;
     END IF;
     -- Admission Application Due Date Alias.
     IF	p_inserting OR
	((NVL(old_references.adm_appl_due_dt_alias, 'NULL') <>
	  NVL(new_references.adm_appl_due_dt_alias, 'NULL')) AND
	  new_references.adm_appl_due_dt_alias IS NOT NULL) THEN
	     IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_due_dt_alias,
			'ADM_APPL_DUE_DT_ALIAS',
			v_message_name) = FALSE THEN
		 Fnd_Message.Set_Name('IGS',v_message_name);
		 IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
	      END IF;
     END IF;
     -- Admission Application Final Date Alias.
     IF	p_inserting OR
	 ((NVL(old_references.adm_appl_final_dt_alias, 'NULL') <>
	   NVL(new_references.adm_appl_final_dt_alias, 'NULL')) AND
	   new_references.adm_appl_final_dt_alias IS NOT NULL) THEN
  	     IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_final_dt_alias,
			'ADM_APPL_FINAL_DT_ALIAS',
			v_message_name) = FALSE THEN
		 Fnd_Message.Set_Name('IGS',v_message_name);
		 IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
	      END IF;
     END IF;
     -- Initialise Admission Period Date Alias .
     IF	p_inserting OR
	((NVL(old_references.initialise_adm_perd_dt_alias, 'NULL') <>
  	  NVL(new_references.initialise_adm_perd_dt_alias, 'NULL')) AND
	  new_references.initialise_adm_perd_dt_alias IS NOT NULL) THEN
	      IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.initialise_adm_perd_dt_alias,
			'INITIALISE_ADM_PERD_DT_ALIAS',
			v_message_name) = FALSE THEN
	          Fnd_Message.Set_Name('IGS',v_message_name);
	          IGS_GE_MSG_STACK.ADD;
                  App_Exception.Raise_Exception;
	      END IF;
     END IF;
     -- Admission Application Encumbrance Checking Date Alias.
     IF	p_inserting OR
	((NVL(old_references.adm_appl_encmb_chk_dt_alias, 'NULL') <>
  	  NVL(new_references.adm_appl_encmb_chk_dt_alias, 'NULL')) AND
	  new_references.adm_appl_encmb_chk_dt_alias IS NOT NULL) THEN
	     IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_encmb_chk_dt_alias,
			'ADM_APPL_ENCMB_CHK_DT_ALIAS',
			v_message_name) = FALSE THEN
	         Fnd_Message.Set_Name('IGS',v_message_name);
	         IGS_GE_MSG_STACK.ADD;
                 App_Exception.Raise_Exception;
	     END IF;
       END IF;
       -- Admission Application IGS_PS_COURSE Start Date Alias.
       IF	p_inserting OR
	   ((NVL(old_references.adm_appl_course_strt_dt_alias, 'NULL') <>
	     NVL(new_references.adm_appl_course_strt_dt_alias, 'NULL')) AND
	     new_references.adm_appl_course_strt_dt_alias IS NOT NULL) THEN
		IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_course_strt_dt_alias,
			'ADM_APPL_COURSE_STRT_DT_ALIAS',
			v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
		END IF;
	END IF;

	-- Admission Application Short Admission Start Date Alias.
	IF	p_inserting OR
		((NVL(old_references.adm_appl_short_strt_dt_alias, 'NULL') <>
		NVL(new_references.adm_appl_short_strt_dt_alias, 'NULL')) AND
		new_references.adm_appl_short_strt_dt_alias IS NOT NULL) THEN
		IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_short_strt_dt_alias,
			'ADM_APPL_SHORT_STRT_DT_ALIAS',
			v_message_name) = FALSE THEN
	            Fnd_Message.Set_Name('IGS',v_message_name);
	            IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Admission Application End Completion Period Date Alias.
	IF	p_inserting OR
		((NVL(old_references.adm_appl_e_comp_perd_dt_alias, 'NULL') <>
		NVL(new_references.adm_appl_e_comp_perd_dt_alias, 'NULL')) AND
		new_references.adm_appl_e_comp_perd_dt_alias IS NOT NULL) THEN
		IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_e_comp_perd_dt_alias,
			'ADM_APPL_E_COMP_PERD_DT_ALIAS',
			v_message_name) = FALSE THEN
	            Fnd_Message.Set_Name('IGS',v_message_name);
	            IGS_GE_MSG_STACK.ADD;
                    App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Admission Application Mid Completion Period Date Alias.
	IF	p_inserting OR
		((NVL(old_references.adm_appl_m_comp_perd_dt_alias, 'NULL') <>
		NVL(new_references.adm_appl_m_comp_perd_dt_alias, 'NULL')) AND
		new_references.adm_appl_m_comp_perd_dt_alias IS NOT NULL) THEN
		IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_m_comp_perd_dt_alias,
			'ADM_APPL_M_COMP_PERD_DT_ALIAS',
			v_message_name) = FALSE THEN
		    Fnd_Message.Set_Name('IGS',v_message_name);
		    IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Admission Application Summer Completion Period Date Alias.
	IF	p_inserting OR
		((NVL(old_references.adm_appl_s_comp_perd_dt_alias, 'NULL') <>
		 NVL(new_references.adm_appl_s_comp_perd_dt_alias, 'NULL')) AND
		 new_references.adm_appl_s_comp_perd_dt_alias IS NOT NULL) THEN
		 IF IGS_AD_VAL_SACCO.admp_val_sacco_da (
			new_references.adm_appl_s_comp_perd_dt_alias,
			'ADM_APPL_S_COMP_PERD_DT_ALIAS',
			v_message_name) = FALSE THEN
		     Fnd_Message.Set_Name('IGS',v_message_name);
		     IGS_GE_MSG_STACK.ADD;
                     App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
  )
  AS
  BEGIN
    IF Column_Name is null then
	NULL;
    ELSIF upper(Column_Name) = 'ADM_APPL_CHNG_OF_PREF_DT_ALIAS' then
	new_references.adm_appl_chng_of_pref_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_DUE_DT_ALIAS' then
	new_references.adm_appl_due_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_FINAL_DT_ALIAS' then
 	new_references.adm_appl_final_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_OFFER_RESP_DT_ALIAS' then
 	new_references.adm_appl_offer_resp_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'INITIALISE_ADM_PERD_DT_ALIAS' then
	new_references.initialise_adm_perd_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_ENCMB_CHK_DT_ALIAS' then
	new_references.adm_appl_encmb_chk_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_SHORT_STRT_DT_ALIAS' then
	new_references.adm_appl_short_strt_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_E_COMP_PERD_DT_ALIAS' then
	new_references.adm_appl_e_comp_perd_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_M_COMP_PERD_DT_ALIAS' then
 	new_references.adm_appl_m_comp_perd_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_S_COMP_PERD_DT_ALIAS' then
 	new_references.adm_appl_s_comp_perd_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'ADM_APPL_COURSE_STRT_DT_ALIAS' then
 	new_references.adm_appl_course_strt_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'S_CONTROL_NUM' then
	new_references.s_control_num := igs_ge_number.to_num(column_value);
    ELSIF upper(Column_Name) = 'ADM_PRC_TRK_DT_ALIAS' then
 	new_references.adm_appl_course_strt_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'POST_ADM_TRK_DT_ALIAS' then
 	new_references.adm_appl_course_strt_dt_alias := column_value;
    ELSIF upper(Column_Name) = 'INQ_CAL_TYPE' then
	new_references.inq_cal_type := column_value;
   END IF;

    IF upper(Column_Name) = 'ADM_APPL_CHNG_OF_PREF_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_chng_of_pref_dt_alias <> UPPER(new_references.adm_appl_chng_of_pref_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF upper(Column_Name) = 'ADM_APPL_DUE_DT_ALIAS' OR Column_Name IS NULL THEN
 	IF new_references.adm_appl_due_dt_alias <> UPPER(new_references.adm_appl_due_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
    END IF;
    IF upper(Column_Name) = 'ADM_APPL_FINAL_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_final_dt_alias <> UPPER(new_references.adm_appl_final_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
     END IF;
     IF upper(Column_Name) = 'ADM_APPL_OFFER_RESP_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_offer_resp_dt_alias <> UPPER(new_references.adm_appl_offer_resp_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
      IF upper(Column_Name) = 'INITIALISE_ADM_PERD_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.initialise_adm_perd_dt_alias <> UPPER(new_references.initialise_adm_perd_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
      IF upper(Column_Name) = 'ADM_APPL_ENCMB_CHK_DT_ALIAS' OR Column_Name IS NULL THEN
	 IF new_references.adm_appl_encmb_chk_dt_alias <> UPPER(new_references.adm_appl_encmb_chk_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
      IF upper(Column_Name) = 'ADM_APPL_SHORT_STRT_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_short_strt_dt_alias <> UPPER(new_references.adm_appl_short_strt_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
      IF upper(Column_Name) = 'ADM_APPL_E_COMP_PERD_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_e_comp_perd_dt_alias <> UPPER(new_references.adm_appl_e_comp_perd_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
      IF upper(Column_Name) = 'ADM_APPL_M_COMP_PERD_DT_ALIAS' OR Column_Name IS NULL THEN
	IF new_references.adm_appl_m_comp_perd_dt_alias <> UPPER(new_references.adm_appl_m_comp_perd_dt_alias) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
      END IF;
	IF upper(Column_Name) = 'ADM_APPL_S_COMP_PERD_DT_ALIAS' OR Column_Name IS NULL THEN
		IF new_references.adm_appl_s_comp_perd_dt_alias <> UPPER(new_references.adm_appl_s_comp_perd_dt_alias) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'ADM_APPL_COURSE_STRT_DT_ALIAS' OR Column_Name IS NULL THEN
		IF new_references.adm_appl_course_strt_dt_alias <> UPPER(new_references.adm_appl_course_strt_dt_alias) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'S_CONTROL_NUM' OR Column_Name IS NULL THEN
		IF new_references.s_control_num <> 1 THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'ADM_PRC_TRK_DT_ALIAS' OR Column_Name IS NULL THEN
		IF new_references.ADM_PRC_TRK_DT_ALIAS <> UPPER(new_references.ADM_PRC_TRK_DT_ALIAS) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'POST_ADM_TRK_DT_ALIAS' OR Column_Name IS NULL THEN
		IF new_references.POST_ADM_TRK_DT_ALIAS <> UPPER(new_references.POST_ADM_TRK_DT_ALIAS) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(Column_Name) = 'INQ_CAL_TYPE' OR Column_Name IS NULL THEN
		IF new_references.INQ_CAL_TYPE <> UPPER(new_references.INQ_CAL_TYPE) THEN
			Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.adm_appl_course_strt_dt_alias = new_references.adm_appl_course_strt_dt_alias)) OR
        ((new_references.adm_appl_course_strt_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_course_strt_dt_alias
	   ) THEN
	    Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	  END IF;
    END IF;

    IF (((old_references.adm_appl_final_dt_alias = new_references.adm_appl_final_dt_alias)) OR
        ((new_references.adm_appl_final_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_final_dt_alias
	   ) THEN
	    Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	  END IF;
    END IF;

    IF (((old_references.adm_appl_due_dt_alias = new_references.adm_appl_due_dt_alias)) OR
        ((new_references.adm_appl_due_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_due_dt_alias
	  ) THEN
	    Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	  END IF;
    END IF;

    IF (((old_references.adm_appl_encmb_chk_dt_alias = new_references.adm_appl_encmb_chk_dt_alias)) OR
        ((new_references.adm_appl_encmb_chk_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_encmb_chk_dt_alias
	   ) THEN
	     Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	  END IF;
    END IF;

    IF (((old_references.adm_appl_e_comp_perd_dt_alias = new_references.adm_appl_e_comp_perd_dt_alias)) OR
        ((new_references.adm_appl_e_comp_perd_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_e_comp_perd_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.initialise_adm_perd_dt_alias = new_references.initialise_adm_perd_dt_alias)) OR
        ((new_references.initialise_adm_perd_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.initialise_adm_perd_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_appl_m_comp_perd_dt_alias = new_references.adm_appl_m_comp_perd_dt_alias)) OR
        ((new_references.adm_appl_m_comp_perd_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_m_comp_perd_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_appl_chng_of_pref_dt_alias = new_references.adm_appl_chng_of_pref_dt_alias)) OR
        ((new_references.adm_appl_chng_of_pref_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_chng_of_pref_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_appl_offer_resp_dt_alias = new_references.adm_appl_offer_resp_dt_alias)) OR
        ((new_references.adm_appl_offer_resp_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_offer_resp_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_appl_short_strt_dt_alias = new_references.adm_appl_short_strt_dt_alias)) OR
        ((new_references.adm_appl_short_strt_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_short_strt_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.adm_appl_s_comp_perd_dt_alias = new_references.adm_appl_s_comp_perd_dt_alias)) OR
        ((new_references.adm_appl_s_comp_perd_dt_alias IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_DA_PKG.Get_PK_For_Validation (
        new_references.adm_appl_s_comp_perd_dt_alias
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.inq_cal_type = new_references.inq_cal_type)) OR
        ((new_references.inq_cal_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.inq_cal_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_s_control_num IN NUMBER
)return BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_CAL_CONF
      WHERE    s_control_num = x_s_control_num
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

  PROCEDURE GET_FK_IGS_CA_DA (
    x_dt_alias IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_CAL_CONF
      WHERE    adm_appl_course_strt_dt_alias = x_dt_alias
         OR    adm_appl_final_dt_alias = x_dt_alias
         OR    adm_appl_due_dt_alias = x_dt_alias
         OR    adm_appl_encmb_chk_dt_alias = x_dt_alias
         OR    adm_appl_e_comp_perd_dt_alias = x_dt_alias
         OR    initialise_adm_perd_dt_alias = x_dt_alias
         OR    adm_appl_m_comp_perd_dt_alias = x_dt_alias
         OR    adm_appl_chng_of_pref_dt_alias = x_dt_alias
         OR    adm_appl_offer_resp_dt_alias = x_dt_alias
         OR    adm_appl_short_strt_dt_alias = x_dt_alias
         OR    adm_appl_s_comp_perd_dt_alias = x_dt_alias;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SACCO_DA_DUE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_DA;



 PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM    IGS_AD_CAL_CONF
      WHERE   inq_cal_type = x_cal_type;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_SACCO_CAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_s_control_num IN NUMBER DEFAULT NULL,
    x_initialise_adm_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_encmb_chk_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_course_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_short_strt_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_due_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_final_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_chg_of_pref_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_adm_appl_offer_resp_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_e_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_m_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_ad_appl_s_comp_perd_dt_alias IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
    X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
    X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_s_control_num,
      x_initialise_adm_perd_dt_alias,
      x_adm_appl_encmb_chk_dt_alias,
      x_ad_appl_course_strt_dt_alias,
      x_adm_appl_short_strt_dt_alias,
      x_adm_appl_due_dt_alias,
      x_adm_appl_final_dt_alias,
      x_ad_appl_chg_of_pref_dt_alias,
      x_adm_appl_offer_resp_dt_alias,
      x_ad_appl_e_comp_perd_dt_alias,
      x_ad_appl_m_comp_perd_dt_alias,
      x_ad_appl_s_comp_perd_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      X_ADM_PRC_TRK_DT_ALIAS,
      X_POST_ADM_TRK_DT_ALIAS,
      X_INQ_CAL_TYPE
    );

    IF (p_action = 'INSERT') THEN
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
		new_references.s_control_num
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

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	IF Get_PK_For_Validation (
		new_references.s_control_num
	) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_INITIALISE_AD_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_ENCMB_CHK_DT_ALIAS in VARCHAR2,
  X_AD_APPL_COURSE_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_SHORT_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_DUE_DT_ALIAS in VARCHAR2,
  X_AD_APPL_FINAL_DT_ALIAS in VARCHAR2,
  X_AD_APPL_CHG_OF_PREF_DT_ALIAS in VARCHAR2,
  X_AD_APPL_OFFER_RESP_DT_ALIAS in VARCHAR2,
  X_AD_APPL_E_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_M_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_S_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
  ) AS
    cursor C is select ROWID from IGS_AD_CAL_CONF
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
    p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_s_control_num => Nvl(X_S_CONTROL_NUM, 1),
    x_initialise_adm_perd_dt_alias => X_INITIALISE_AD_PERD_DT_ALIAS,
    x_adm_appl_encmb_chk_dt_alias => X_AD_APPL_ENCMB_CHK_DT_ALIAS,
    x_ad_appl_course_strt_dt_alias => X_AD_APPL_COURSE_STRT_DT_ALIAS,
    x_adm_appl_short_strt_dt_alias => X_AD_APPL_SHORT_STRT_DT_ALIAS,
    x_adm_appl_due_dt_alias => X_AD_APPL_DUE_DT_ALIAS,
    x_adm_appl_final_dt_alias => X_AD_APPL_FINAL_DT_ALIAS,
    x_ad_appl_chg_of_pref_dt_alias => X_AD_APPL_CHG_OF_PREF_DT_ALIAS,
    x_adm_appl_offer_resp_dt_alias => X_AD_APPL_OFFER_RESP_DT_ALIAS,
    x_ad_appl_e_comp_perd_dt_alias => X_AD_APPL_E_COMP_PERD_DT_ALIAS,
    x_ad_appl_m_comp_perd_dt_alias => X_AD_APPL_M_COMP_PERD_DT_ALIAS,
    x_ad_appl_s_comp_perd_dt_alias => X_AD_APPL_S_COMP_PERD_DT_ALIAS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    X_ADM_PRC_TRK_DT_ALIAS => X_ADM_PRC_TRK_DT_ALIAS,
    X_POST_ADM_TRK_DT_ALIAS => X_POST_ADM_TRK_DT_ALIAS,
    X_INQ_CAL_TYPE => X_INQ_CAL_TYPE
     );

  insert into IGS_AD_CAL_CONF (
    S_CONTROL_NUM,
    INITIALISE_ADM_PERD_DT_ALIAS,
    ADM_APPL_ENCMB_CHK_DT_ALIAS,
    ADM_APPL_COURSE_STRT_DT_ALIAS,
    ADM_APPL_SHORT_STRT_DT_ALIAS,
    ADM_APPL_DUE_DT_ALIAS,
    ADM_APPL_FINAL_DT_ALIAS,
    ADM_APPL_CHNG_OF_PREF_DT_ALIAS,
    ADM_APPL_OFFER_RESP_DT_ALIAS,
    ADM_APPL_E_COMP_PERD_DT_ALIAS,
    ADM_APPL_M_COMP_PERD_DT_ALIAS,
    ADM_APPL_S_COMP_PERD_DT_ALIAS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ADM_PRC_TRK_DT_ALIAS,
    POST_ADM_TRK_DT_ALIAS,
    INQ_CAL_TYPE
  ) values (
    NEW_REFERENCES.S_CONTROL_NUM,
    NEW_REFERENCES.INITIALISE_ADM_PERD_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_ENCMB_CHK_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_COURSE_STRT_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_SHORT_STRT_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_DUE_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_FINAL_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_CHNG_OF_PREF_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_OFFER_RESP_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_E_COMP_PERD_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_M_COMP_PERD_DT_ALIAS,
    NEW_REFERENCES.ADM_APPL_S_COMP_PERD_DT_ALIAS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN ,
    NEW_REFERENCES.ADM_PRC_TRK_DT_ALIAS,
    NEW_REFERENCES.POST_ADM_TRK_DT_ALIAS,
    NEW_REFERENCES.INQ_CAL_TYPE
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
    x_rowid => X_ROWID);

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_S_CONTROL_NUM in NUMBER,
  X_INITIALISE_AD_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_ENCMB_CHK_DT_ALIAS in VARCHAR2,
  X_AD_APPL_COURSE_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_SHORT_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_DUE_DT_ALIAS in VARCHAR2,
  X_AD_APPL_FINAL_DT_ALIAS in VARCHAR2,
  X_AD_APPL_CHG_OF_PREF_DT_ALIAS in VARCHAR2,
  X_AD_APPL_OFFER_RESP_DT_ALIAS in VARCHAR2,
  X_AD_APPL_E_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_M_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_S_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
) AS
  cursor c1 is select
      INITIALISE_ADM_PERD_DT_ALIAS,
      ADM_APPL_ENCMB_CHK_DT_ALIAS,
      ADM_APPL_COURSE_STRT_DT_ALIAS,
      ADM_APPL_SHORT_STRT_DT_ALIAS,
      ADM_APPL_DUE_DT_ALIAS,
      ADM_APPL_FINAL_DT_ALIAS,
      ADM_APPL_CHNG_OF_PREF_DT_ALIAS,
      ADM_APPL_OFFER_RESP_DT_ALIAS,
      ADM_APPL_E_COMP_PERD_DT_ALIAS,
      ADM_APPL_M_COMP_PERD_DT_ALIAS,
      ADM_APPL_S_COMP_PERD_DT_ALIAS,
      ADM_PRC_TRK_DT_ALIAS,
      POST_ADM_TRK_DT_ALIAS,
      INQ_CAL_TYPE
    from IGS_AD_CAL_CONF
    where ROWID = X_ROWID for update nowait;
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

      if ( ((tlinfo.INITIALISE_ADM_PERD_DT_ALIAS = X_INITIALISE_AD_PERD_DT_ALIAS)
           OR ((tlinfo.INITIALISE_ADM_PERD_DT_ALIAS is null)
               AND (X_INITIALISE_AD_PERD_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_ENCMB_CHK_DT_ALIAS = X_AD_APPL_ENCMB_CHK_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_ENCMB_CHK_DT_ALIAS is null)
               AND (X_AD_APPL_ENCMB_CHK_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_COURSE_STRT_DT_ALIAS = X_AD_APPL_COURSE_STRT_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_COURSE_STRT_DT_ALIAS is null)
               AND (X_AD_APPL_COURSE_STRT_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_SHORT_STRT_DT_ALIAS = X_AD_APPL_SHORT_STRT_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_SHORT_STRT_DT_ALIAS is null)
               AND (X_AD_APPL_SHORT_STRT_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_DUE_DT_ALIAS = X_AD_APPL_DUE_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_DUE_DT_ALIAS is null)
               AND (X_AD_APPL_DUE_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_FINAL_DT_ALIAS = X_AD_APPL_FINAL_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_FINAL_DT_ALIAS is null)
               AND (X_AD_APPL_FINAL_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_CHNG_OF_PREF_DT_ALIAS = X_AD_APPL_CHG_OF_PREF_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_CHNG_OF_PREF_DT_ALIAS is null)
               AND (X_AD_APPL_CHG_OF_PREF_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_OFFER_RESP_DT_ALIAS = X_AD_APPL_OFFER_RESP_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_OFFER_RESP_DT_ALIAS is null)
               AND (X_AD_APPL_OFFER_RESP_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_E_COMP_PERD_DT_ALIAS = X_AD_APPL_E_COMP_PERD_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_E_COMP_PERD_DT_ALIAS is null)
               AND (X_AD_APPL_E_COMP_PERD_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_M_COMP_PERD_DT_ALIAS = X_AD_APPL_M_COMP_PERD_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_M_COMP_PERD_DT_ALIAS is null)
               AND (X_AD_APPL_M_COMP_PERD_DT_ALIAS is null)))
      AND ((tlinfo.ADM_APPL_S_COMP_PERD_DT_ALIAS = X_AD_APPL_S_COMP_PERD_DT_ALIAS)
           OR ((tlinfo.ADM_APPL_S_COMP_PERD_DT_ALIAS is null)
               AND (X_AD_APPL_S_COMP_PERD_DT_ALIAS is null)))
      AND ((tlinfo.ADM_PRC_TRK_DT_ALIAS = X_ADM_PRC_TRK_DT_ALIAS)
           OR ((tlinfo.ADM_PRC_TRK_DT_ALIAS is null)
               AND (X_ADM_PRC_TRK_DT_ALIAS is null)))
      AND ((tlinfo.POST_ADM_TRK_DT_ALIAS = X_POST_ADM_TRK_DT_ALIAS)
           OR ((tlinfo.POST_ADM_TRK_DT_ALIAS is null)
               AND (X_POST_ADM_TRK_DT_ALIAS is null)))
       AND ((tlinfo.INQ_CAL_TYPE = X_INQ_CAL_TYPE)
           OR ((tlinfo.INQ_CAL_TYPE is null)
               AND (X_INQ_CAL_TYPE is null)))
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
  X_S_CONTROL_NUM in NUMBER,
  X_INITIALISE_AD_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_ENCMB_CHK_DT_ALIAS in VARCHAR2,
  X_AD_APPL_COURSE_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_SHORT_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_DUE_DT_ALIAS in VARCHAR2,
  X_AD_APPL_FINAL_DT_ALIAS in VARCHAR2,
  X_AD_APPL_CHG_OF_PREF_DT_ALIAS in VARCHAR2,
  X_AD_APPL_OFFER_RESP_DT_ALIAS in VARCHAR2,
  X_AD_APPL_E_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_M_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_S_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
  ) As
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
    x_s_control_num => X_S_CONTROL_NUM,
    x_initialise_adm_perd_dt_alias => X_INITIALISE_AD_PERD_DT_ALIAS,
    x_adm_appl_encmb_chk_dt_alias => X_AD_APPL_ENCMB_CHK_DT_ALIAS,
    x_ad_appl_course_strt_dt_alias => X_AD_APPL_COURSE_STRT_DT_ALIAS,
    x_adm_appl_short_strt_dt_alias => X_AD_APPL_SHORT_STRT_DT_ALIAS,
    x_adm_appl_due_dt_alias => X_AD_APPL_DUE_DT_ALIAS,
    x_adm_appl_final_dt_alias => X_AD_APPL_FINAL_DT_ALIAS,
    x_ad_appl_chg_of_pref_dt_alias => X_AD_APPL_CHG_OF_PREF_DT_ALIAS,
    x_adm_appl_offer_resp_dt_alias => X_AD_APPL_OFFER_RESP_DT_ALIAS,
    x_ad_appl_e_comp_perd_dt_alias => X_AD_APPL_E_COMP_PERD_DT_ALIAS,
    x_ad_appl_m_comp_perd_dt_alias => X_AD_APPL_M_COMP_PERD_DT_ALIAS,
    x_ad_appl_s_comp_perd_dt_alias => X_AD_APPL_S_COMP_PERD_DT_ALIAS,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    X_ADM_PRC_TRK_DT_ALIAS => X_ADM_PRC_TRK_DT_ALIAS,
    X_POST_ADM_TRK_DT_ALIAS => X_POST_ADM_TRK_DT_ALIAS,
    X_INQ_CAL_TYPE => X_INQ_CAL_TYPE
    );

  update IGS_AD_CAL_CONF set
    INITIALISE_ADM_PERD_DT_ALIAS = NEW_REFERENCES.INITIALISE_ADM_PERD_DT_ALIAS,
    ADM_APPL_ENCMB_CHK_DT_ALIAS = NEW_REFERENCES.ADM_APPL_ENCMB_CHK_DT_ALIAS,
    ADM_APPL_COURSE_STRT_DT_ALIAS = NEW_REFERENCES.ADM_APPL_COURSE_STRT_DT_ALIAS,
    ADM_APPL_SHORT_STRT_DT_ALIAS = NEW_REFERENCES.ADM_APPL_SHORT_STRT_DT_ALIAS,
    ADM_APPL_DUE_DT_ALIAS = NEW_REFERENCES.ADM_APPL_DUE_DT_ALIAS,
    ADM_APPL_FINAL_DT_ALIAS = NEW_REFERENCES.ADM_APPL_FINAL_DT_ALIAS,
    ADM_APPL_CHNG_OF_PREF_DT_ALIAS = NEW_REFERENCES.ADM_APPL_CHNG_OF_PREF_DT_ALIAS,
    ADM_APPL_OFFER_RESP_DT_ALIAS = NEW_REFERENCES.ADM_APPL_OFFER_RESP_DT_ALIAS,
    ADM_APPL_E_COMP_PERD_DT_ALIAS = NEW_REFERENCES.ADM_APPL_E_COMP_PERD_DT_ALIAS,
    ADM_APPL_M_COMP_PERD_DT_ALIAS = NEW_REFERENCES.ADM_APPL_M_COMP_PERD_DT_ALIAS,
    ADM_APPL_S_COMP_PERD_DT_ALIAS = NEW_REFERENCES.ADM_APPL_S_COMP_PERD_DT_ALIAS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ADM_PRC_TRK_DT_ALIAS = NEW_REFERENCES.ADM_PRC_TRK_DT_ALIAS,
    POST_ADM_TRK_DT_ALIAS = NEW_REFERENCES.POST_ADM_TRK_DT_ALIAS,
    INQ_CAL_TYPE = NEW_REFERENCES.INQ_CAL_TYPE
     where ROWID = X_ROWID;

  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID);

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_S_CONTROL_NUM in out NOCOPY NUMBER,
  X_INITIALISE_AD_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_ENCMB_CHK_DT_ALIAS in VARCHAR2,
  X_AD_APPL_COURSE_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_SHORT_STRT_DT_ALIAS in VARCHAR2,
  X_AD_APPL_DUE_DT_ALIAS in VARCHAR2,
  X_AD_APPL_FINAL_DT_ALIAS in VARCHAR2,
  X_AD_APPL_CHG_OF_PREF_DT_ALIAS in VARCHAR2,
  X_AD_APPL_OFFER_RESP_DT_ALIAS in VARCHAR2,
  X_AD_APPL_E_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_M_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_AD_APPL_S_COMP_PERD_DT_ALIAS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R' ,
  X_ADM_PRC_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_POST_ADM_TRK_DT_ALIAS IN VARCHAR2 DEFAULT NULL,
  X_INQ_CAL_TYPE IN VARCHAR2 DEFAULT NULL
  ) AS
  cursor c1 is select rowid from IGS_AD_CAL_CONF
     where S_CONTROL_NUM = NVL(X_S_CONTROL_NUM,1);

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_S_CONTROL_NUM,
     X_INITIALISE_AD_PERD_DT_ALIAS,
     X_AD_APPL_ENCMB_CHK_DT_ALIAS,
     X_AD_APPL_COURSE_STRT_DT_ALIAS,
     X_AD_APPL_SHORT_STRT_DT_ALIAS,
     X_AD_APPL_DUE_DT_ALIAS,
     X_AD_APPL_FINAL_DT_ALIAS,
     X_AD_APPL_CHG_OF_PREF_DT_ALIAS,
     X_AD_APPL_OFFER_RESP_DT_ALIAS,
     X_AD_APPL_E_COMP_PERD_DT_ALIAS,
     X_AD_APPL_M_COMP_PERD_DT_ALIAS,
     X_AD_APPL_S_COMP_PERD_DT_ALIAS,
     X_MODE,
     X_ADM_PRC_TRK_DT_ALIAS ,
     X_POST_ADM_TRK_DT_ALIAS,
     X_INQ_CAL_TYPE
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_S_CONTROL_NUM,
   X_INITIALISE_AD_PERD_DT_ALIAS,
   X_AD_APPL_ENCMB_CHK_DT_ALIAS,
   X_AD_APPL_COURSE_STRT_DT_ALIAS,
   X_AD_APPL_SHORT_STRT_DT_ALIAS,
   X_AD_APPL_DUE_DT_ALIAS,
   X_AD_APPL_FINAL_DT_ALIAS,
   X_AD_APPL_CHG_OF_PREF_DT_ALIAS,
   X_AD_APPL_OFFER_RESP_DT_ALIAS,
   X_AD_APPL_E_COMP_PERD_DT_ALIAS,
   X_AD_APPL_M_COMP_PERD_DT_ALIAS,
   X_AD_APPL_S_COMP_PERD_DT_ALIAS,
   X_MODE,
   X_ADM_PRC_TRK_DT_ALIAS ,
   X_POST_ADM_TRK_DT_ALIAS,
   X_INQ_CAL_TYPE
   );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

  delete from IGS_AD_CAL_CONF
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID);

end DELETE_ROW;

end IGS_AD_CAL_CONF_PKG;

/
