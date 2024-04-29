--------------------------------------------------------
--  DDL for Package Body IGS_CA_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_INST_PKG" AS
/* $Header: IGSCI12B.pls 120.0 2005/06/01 22:19:16 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_CA_INST_ALL%ROWTYPE;
  new_references IGS_CA_INST_ALL%ROWTYPE;

  -- Forward declaring the procedure beforerowdelete, beforerowupdate
  PROCEDURE beforerowdelete;
  PROCEDURE beforerowupdate;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_end_dt IN DATE ,
    x_cal_status IN VARCHAR2 ,
    x_alternate_code IN VARCHAR2 ,
    x_sup_cal_status_differ_ind IN VARCHAR2 ,
    x_prior_ci_sequence_number IN NUMBER ,
    x_org_id   IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_ss_displayed IN VARCHAR2 ,
    x_description  IN VARCHAR2 ,
    x_ivr_display_ind  IN VARCHAR2,
    x_term_instruction_time IN NUMBER ,
    X_PLANNING_FLAG in VARCHAR2 ,
    X_SCHEDULE_FLAG in VARCHAR2 ,
    X_ADMIN_FLAG in VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_INST_ALL
      WHERE    ROWID = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN
      CLOSE cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.cal_type := x_cal_type;
    new_references.sequence_number := x_sequence_number;
    new_references.start_dt := x_start_dt;
    new_references.end_dt := x_end_dt;
    new_references.cal_status := x_cal_status;
    new_references.alternate_code := x_alternate_code;
    new_references.sup_cal_status_differ_ind := x_sup_cal_status_differ_ind;
    new_references.prior_ci_sequence_number := x_prior_ci_sequence_number;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.org_id := x_org_id ;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;
    new_references.ss_displayed := x_ss_displayed;
    new_references.ivr_display_ind := NVL(x_ivr_display_ind,'N');
    new_references.term_instruction_time := x_term_instruction_time;
    new_references.PLANNING_FLAG := NVL(X_PLANNING_FLAG,'N') ;  --default N
    new_references.SCHEDULE_FLAG := NVL(X_SCHEDULE_FLAG,'N') ;  --default N
    new_references.ADMIN_FLAG := NVL(X_ADMIN_FLAG,'N') ;        --default N

    --SINCE WE NEED TO COMMUNICATE TO THE USER THAT DESCRIPTION HAS TO BE SPECIFIED.
    --WITH RESPECT TO THE SWCR003 CALENDAR DESCRIPTION -- CHANGE REQUEST
    --Enh No      :-   2138560 Change Request for Calendar Instance
    --Add a Description Column

    IF  LTRIM(RTRIM(x_description))  IS NULL  THEN

       fnd_message.set_name('IGS','IGS_CA_CALDESC_NOT_AVAILABLE');
       new_references.description  :=fnd_message.get;

    ELSE
      new_references.description  :=LTRIM(RTRIM(x_description));

    END IF;
  END Set_Column_Values;



  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    -- BUG - 2563531
    -- CURSOR added to check uniqueness for alternate code for calendar categories
    -- load , academic and teaching
        CURSOR alt_code_unique IS
        SELECT count(*)
        FROM  IGS_CA_INST CI , IGS_CA_TYPE CAT
        WHERE   CAT.CAL_TYPE = CI.CAL_TYPE
        AND CAT.S_CAL_CAT IN ('LOAD','TEACHING','ACADEMIC')
        AND NEW_REFERENCES.ALTERNATE_CODE = CI.ALTERNATE_CODE
        AND ((l_rowid IS NULL) OR (CI.ROW_ID <> l_rowid)) ;
        l_count NUMBER(3);
	v_message_name	VARCHAR2(30);
  BEGIN
	-- Validate alternate code
	IF IGS_CA_VAL_CI.calp_val_ci_alt_cd(
		new_references.cal_type,
		new_references.alternate_code,
		v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;

	END IF;
	IF p_inserting OR
		(new_references.cal_status <> old_references.cal_status) THEN
		-- Validate calendar status
		IF IGS_CA_VAL_CI.calp_val_cs_closed(
			new_references.cal_status,
			v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
-- code to check uniqueness for alternate code for calendar categories
--  load ,teaching and academic
	 IF p_inserting OR p_updating THEN
           OPEN alt_code_unique;
           FETCH alt_code_unique INTO l_count;
           IF l_count > 0 THEN
		Fnd_Message.Set_Name('IGS','IGS_CA_UNIQUE_ALT_CODE');
        	IGS_GE_MSG_STACK.ADD;
		APP_EXCEPTION.RAISE_EXCEPTION;
           END IF;
           CLOSE alt_code_unique;
        END IF;

  END BeforeRowInsertUpdate1;


  PROCEDURE AfterRowInsertUpdate2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name	VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate calendar instance status
	IF (new_references.cal_status <> old_references.cal_status)
	THEN
		-- partial call to calp_val_ci_status
		IF IGS_CA_VAL_CI.calp_val_ci_status(p_cal_type => '',
			p_sequence_number => NULL,
			p_old_cal_status => old_references.cal_status,
			p_new_cal_status => new_references.cal_status,
			p_message_name => v_message_name) = FALSE
		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
	        END IF;
        END IF;
	-- Check that  the calendar type is not closed.
	IF IGS_CA_GEN_001.CALP_GET_CAT_CLOSED (new_references.cal_type,
		v_message_name) = TRUE
	THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
  END AfterRowInsertUpdate2;



  PROCEDURE AfterStmtInsertUpdateDelete3(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
    v_message_name	VARCHAR2(30);
  BEGIN
  	-- Validation routine calls.
  	-- Validate calendar instance status
  	IF p_inserting OR  p_updating THEN
  		-- Validate calendar instance status
  		-- not all parameters are included in the call to calp_val_ci_status
 	 	IF IGS_CA_VAL_CI.calp_val_ci_status (p_cal_type => NVL (new_references.cal_type, old_references.cal_type),
	  		p_sequence_number => NVL (new_references.sequence_number, old_references.sequence_number),
	  		p_old_cal_status => '',
	  		p_new_cal_status => NVL (new_references.cal_status, old_references.cal_status),
	  		p_message_name => v_message_name) = FALSE
	  	THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
 	 	END IF;
  	END IF;
  END AfterStmtInsertUpdateDelete3;

  PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	,
   Column_Value 	IN	VARCHAR2
   ) AS
  BEGIN
  IF Column_Name IS NULL THEN
  	NULL;
  ELSIF UPPER(Column_Name) = 'ALTERNATE_CODE' THEN
  	new_references.alternate_code := Column_Value;
  ELSIF UPPER(Column_Name) = 'CAL_STATUS' THEN
    	new_references.cal_status := Column_Value;
  ELSIF UPPER(Column_Name) = 'CAL_TYPE' THEN
  	new_references.cal_type:= Column_Value;
  ELSIF UPPER(Column_Name) = 'SUP_CAL_STATUS_DIFFER_IND' THEN
  	new_references.sup_cal_status_differ_ind := Column_Value;
  ELSIF UPPER(Column_Name) = 'PRIOR_CI_SEQUENCE_NUMBER' THEN
  	new_references.prior_ci_sequence_number := igs_ge_number.to_num(Column_Value);


  END IF;
	IF column_name IS NULL THEN
		IF (new_references.start_dt > new_references.end_dt) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
   	IF UPPER(Column_Name) = 'PRIOR_CI_SEQUENCE_NUMBER' OR
     		column_name IS NULL THEN
   		IF (new_references.prior_ci_sequence_number < 1 OR new_references.prior_ci_sequence_number > 999999) AND new_references.prior_ci_sequence_number IS NOT NULL THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
   			IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;
	IF UPPER(Column_Name) = 'SUP_CAL_STATUS_DIFFER_IND' OR
		  column_name IS NULL THEN
		IF new_references.sup_cal_status_differ_ind NOT IN ('Y', 'N') AND new_references.sup_cal_status_differ_ind IS NOT NULL THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF UPPER(Column_Name) = 'ALTERNATE_CODE' OR
  		column_name IS NULL THEN
		IF new_references.alternate_code <> UPPER(new_references.alternate_code) AND new_references.alternate_code IS NOT NULL THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF UPPER(Column_Name) = 'CAL_STATUS' OR
  		column_name IS NULL THEN
		IF (new_references.cal_status <> UPPER(new_references.cal_status)) AND new_references.cal_status IS NOT NULL THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF UPPER(Column_Name) = 'CAL_TYPE' OR
  		column_name IS NULL THEN
		IF new_references.cal_type <> UPPER(new_references.cal_type) AND new_references.cal_type IS NOT NULL THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;



  END Check_Constraints;

PROCEDURE Check_Uniqueness
IS
BEGIN
  	IF  Get_UK_For_Validation (
  	  	new_references.cal_type ,
  	  	new_references.sequence_number ,
  	  	new_references.start_dt ,
  	  	new_references.end_dt  )
		THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
  	END IF;
	IF  Get_UK2_For_Validation (
		new_references.cal_type ,
	    new_references.start_dt ,
	    new_references.end_dt   )
		THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	END IF;

END Check_Uniqueness;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.cal_type = new_references.cal_type)) OR
        ((new_references.cal_type IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_TYPE_PKG.Get_PK_For_Validation (
        new_references.cal_type
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.cal_status = new_references.cal_status)) OR
        ((new_references.cal_status IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_STAT_PKG.Get_PK_For_Validation (
        new_references.cal_status
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.cal_type = new_references.cal_type) AND
         (old_references.prior_ci_sequence_number = new_references.prior_ci_sequence_number)) OR
        ((new_references.cal_type IS NULL) OR
         (new_references.prior_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.cal_type,
        new_references.prior_ci_sequence_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --rmaddipa    14-sep-2004     Enh # 3316063 Reverted back the changes made in the earlier version of the file.
  --rmaddipa    07-Sep-2004     Enh # 3316063 Added call to igs_fi_tp_ret_schd_pkg.get_fk_igs_ca_inst
  --smvk        26-Aug-03       Enh # 3045007, Added igs_fi_pp_std_attrs_pkg
  --shtatiko    10-JUN-2003     Enh# 2831582, Added call to igs_fi_lb_fcis_pkg
  --sbaliga     18-Apr-2002     Bug 2278825, modified check child
  --vchappid    02-Apr-2002     Enh# bug2293676, modified check child
  --schodava	06-FEB-2002	Enh # 2187247
  --				SFCR021 : FCI-LCI Relation
  --				Removed the references to igs_fi_chg_mth_app_pkg
  --smvk        04-feb-2002     added igs_fi_credits_pkg.get_fk_igs_ca_inst_1
  --                            added igs_fi_credits_pkg.get_fk_igs_ca_inst_2
  --				call
  --smadathi    04-feb-2002     added igf_sp_stdnt_rel_pkg.get_fk_igs_ca_inst
  --                            call

  --ckasu       04-Dec-2003     Added IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_CA_INST
  --                            for Term Records Build
  -------------------------------------------------------------------

  BEGIN



    IGS_AD_PERD_AD_CAT_PKG.GET_UFK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number,
      old_references.start_dt,
      old_references.end_dt
      );

    IGS_EN_SU_ATTEMPT_PKG.GET_UFK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number,
      old_references.start_dt,
      old_references.end_dt
      );

    IGS_AS_SU_STMPTOUT_PKG.GET_UFK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number,
      old_references.start_dt,
      old_references.end_dt
      );

    IGS_PS_OFR_INST_PKG.GET_UFK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number,
      old_references.start_dt,
      old_references.end_dt
      );

    IGS_PS_UNIT_OFR_PAT_PKG.GET_UFK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number,
      old_references.start_dt,
      old_references.end_dt
      );

    IGS_AD_PS_APPL_INST_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_CA_INST_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_CA_INST_REL_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );


    IGS_GR_CRMN_ROUND_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_CO_ITM_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_ST_DFT_LOAD_APPO_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_CA_DA_INST_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_AS_EXAM_SESSION_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_FI_F_CAT_CA_INST_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_FI_F_TYP_CA_INST_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_ST_GVTSEMLOAD_CA_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_EN_SPA_TERMS_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    /*IGS_CO_OU_CO_REF_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      ); */

    IGS_PS_PAT_OF_STUDY_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_PR_RU_CA_TYPE_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_AS_SC_ATMPT_ENR_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_PR_SDT_PS_PR_MSR_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_PR_STDNT_PR_CK_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_AS_UNITASS_ITEM_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

    IGS_FI_UNIT_FEE_TRG_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

   IGS_EN_INST_WLST_OPT_PKG.GET_FK_IGS_CA_INST (
      old_references.cal_type,
      old_references.sequence_number
      );

   igs_ps_uso_cm_grp_pkg.get_fk_igs_ca_inst (
      old_references.cal_type,
      old_references.sequence_number
      );

   igs_ps_us_em_grp_pkg.get_fk_igs_ca_inst (
      old_references.cal_type,
      old_references.sequence_number
      );

   igs_ps_usec_x_grp_pkg.get_fk_igs_ca_inst (
      old_references.cal_type,
      old_references.sequence_number
      );
   igs_ps_unit_ver_pkg.get_fk_igs_ca_inst_all(
     old_references.cal_type,
     old_references.sequence_number
     );
   igs_ps_unit_ver_pkg.get_fk_igs_ca_inst_all1(
     old_references.cal_type,
     old_references.sequence_number
     );
   igs_en_elgb_ovr_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );
   -- Start of addition for Bug no. 1960126
    igs_av_stnd_unit_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    igs_av_stnd_unit_lvl_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );
   -- End of addition for Bug no. 1960126

    igs_pe_stat_details_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_PE_PERS_ENCUMB_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_EN_STDNT_PS_ATT_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_AS_SU_SETATMPT_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    --added by nalkumar, Bug:2126091
    IGS_FI_PERSON_HOLDS_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_AS_ANON_ID_US_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_AS_ANON_ID_ASS_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    IGS_PS_FAC_WL_PKG.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

    igf_sp_stdnt_rel_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );
     -- ADDED FOR 2191470 STARTS HERE
    igs_fi_credits_pkg.get_fk_igs_ca_inst_1(
       old_references.cal_type,
       old_references.sequence_number
     );

    igs_fi_credits_pkg.get_fk_igs_ca_inst_2(
      old_references.cal_type,
      old_references.sequence_number
     );
       -- ADDED FOR 2191470 ENDS HERE

    igs_fi_bill_pln_crd_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

     igs_he_fte_cal_prd_pkg.get_fk_igs_ca_inst1(
     old_references.cal_type,
     old_references.sequence_number
     );

     igs_he_fte_cal_prd_pkg.get_fk_igs_ca_inst2(
     old_references.cal_type,
     old_references.sequence_number
     );

     igs_pr_stu_acad_stat_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );

     igs_pr_cohort_inst_pkg.get_fk_igs_ca_inst(
     old_references.cal_type,
     old_references.sequence_number
     );
    -- DA UI 2829285 addition
    -- commented code for resolving depndency in the bug 2981279

     igs_da_cnfg_req_typ_pkg.get_fk_igs_ca_inst (
        x_cal_type        => old_references.cal_type,
        x_sequence_number => old_references.sequence_number
      );
     igs_da_req_wif_pkg.get_fk_igs_ca_inst (
        x_cal_type        => old_references.cal_type,
        x_sequence_number => old_references.sequence_number
      );
    -- DA UI 2829285 addition ends

     -- Enh# 2831582, Added the following call.
     igs_fi_lb_fcis_pkg.get_fk_igs_ca_inst(
       old_references.cal_type,
       old_references.sequence_number
     );

     -- Enh # 3045007
     igs_fi_pp_std_attrs_pkg.get_fk_igs_ca_inst (
       x_cal_type        => old_references.cal_type,
       x_sequence_number  => old_references.sequence_number
     );

     igs_en_psv_term_it_pkg.get_fk_igs_ca_inst (
       x_cal_type        =>  old_references.cal_type,
       x_sequence_number =>  old_references.sequence_number
     );

  END Check_Child_Existance;

    PROCEDURE Check_UK_Child_Existance AS
    BEGIN
        IF(((old_references.CAL_TYPE = new_references.CAL_TYPE)AND
            (old_references.SEQUENCE_NUMBER = new_references.SEQUENCE_NUMBER)AND
            (old_references.START_DT = new_references.START_DT)AND
            (old_references.END_DT = new_references.END_DT)) OR
           ((old_references.CAL_TYPE IS NULL)AND
            (old_references.SEQUENCE_NUMBER IS NULL)AND
            (old_references.START_DT IS NULL)AND
            (old_references.END_DT IS NULL))) THEN
            NULL;
         ELSE
             IGS_AD_PERD_AD_CAT_PKG.GET_UFK_IGS_CA_INST(
               old_references.CAL_TYPE,
               old_references.SEQUENCE_NUMBER,
               old_references.START_DT,
               old_references.END_DT);
             IGS_PS_OFR_INST_PKG.GET_UFK_IGS_CA_INST(
               old_references.CAL_TYPE,
               old_references.SEQUENCE_NUMBER,
               old_references.START_DT,
               old_references.END_DT);
             IGS_AS_SU_STMPTOUT_PKG.GET_UFK_IGS_CA_INST(
               old_references.CAL_TYPE,
               old_references.SEQUENCE_NUMBER,
               old_references.START_DT,
               old_references.END_DT);
             IGS_EN_SU_ATTEMPT_PKG.GET_UFK_IGS_CA_INST(
               old_references.CAL_TYPE,
               old_references.SEQUENCE_NUMBER,
               old_references.START_DT,
               old_references.END_DT);
             IGS_PS_UNIT_OFR_PAT_PKG.GET_UFK_IGS_CA_INST(
               old_references.CAL_TYPE,
               old_references.SEQUENCE_NUMBER,
               old_references.START_DT,
               old_references.END_DT);
        END IF;
       END Check_UK_Child_Existance;

FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS


    -- Bug#2409299, Depending on the calendar status lock on the table is acquired
    -- lock is required when the cal status is Planned since it is allowed to delete from the Calendar Instance Form
    -- lock is not required when the cal status is either Active or Inactive so an explicit lock is not required
    -- opening different cursors depending on the System calendar status
    CURSOR cur_get_status
        IS
        SELECT s.s_cal_status
        FROM   igs_ca_stat s,
               igs_ca_inst_all ci
        WHERE  ci.cal_status = s.cal_status
        AND    ci.cal_type = x_cal_type
        AND    ci.sequence_number = x_sequence_number;
    l_s_cal_status igs_ca_stat.s_cal_status%TYPE;

    CURSOR cur_rowid_planned IS
      SELECT   ROWID
      FROM     igs_ca_inst_all
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      FOR UPDATE NOWAIT;

    CURSOR cur_rowid_act_inact IS
      SELECT   ROWID
      FROM     igs_ca_inst_all
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number;

    lv_rowid cur_rowid_planned%ROWTYPE;

BEGIN

  OPEN cur_get_status;
  FETCH cur_get_status INTO l_s_cal_status;
  IF cur_get_status%NOTFOUND THEN
    CLOSE cur_get_status;
    RETURN(FALSE);
  ELSE
    CLOSE cur_get_status;
    IF l_s_cal_status = 'PLANNED' THEN
      OPEN cur_rowid_planned;
      FETCH cur_rowid_planned INTO lv_rowid;
      IF cur_rowid_planned%FOUND THEN
        CLOSE cur_rowid_planned;
        RETURN (TRUE);
      ELSE
        CLOSE cur_rowid_planned;
        RETURN (FALSE);
      END IF;
    ELSE
      OPEN cur_rowid_act_inact;
      FETCH cur_rowid_act_inact INTO lv_rowid;
      IF cur_rowid_act_inact%FOUND THEN
        CLOSE cur_rowid_act_inact;
        RETURN (TRUE);
      ELSE
        CLOSE cur_rowid_act_inact;
        RETURN (FALSE);
      END IF;
    END IF;
  END IF;

END Get_PK_For_Validation;

  FUNCTION Get_UK_For_Validation (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    )RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_CA_INST_ALL
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number
      AND      start_dt = x_start_dt
      AND      end_dt = x_end_dt
      AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid)) ;

    lv_rowid cur_rowid%ROWTYPE;

BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
 IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (TRUE);
 ELSE
       CLOSE cur_rowid;
       RETURN (FALSE);
 END IF;

END Get_UK_For_Validation;

FUNCTION Get_UK2_For_Validation (
    x_cal_type IN VARCHAR2,
    x_start_dt IN DATE,
    x_end_dt IN DATE
    )RETURN BOOLEAN AS

CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_CA_INST_ALL
      WHERE    cal_type = x_cal_type
      AND      start_dt = x_start_dt
      AND      end_dt = x_end_dt
	  AND      ((l_rowid IS NULL) OR (ROWID <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

BEGIN

  OPEN cur_rowid;
  FETCH cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
	       CLOSE cur_rowid;
	       RETURN (TRUE);
	 ELSE
	       CLOSE cur_rowid;
	       RETURN (FALSE);
 	 END IF;

END Get_UK2_For_Validation;

PROCEDURE GET_FK_IGS_CA_TYPE (
    x_cal_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_CA_INST_ALL
      WHERE    cal_type = x_cal_type ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
     CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CI_CAT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       RETURN;
    END IF;
    CLOSE cur_rowid;

  END GET_FK_IGS_CA_TYPE;

  PROCEDURE GET_FK_IGS_CA_STAT (
    x_cal_status IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_CA_INST_ALL
      WHERE    cal_status = x_cal_status ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CI_CS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END GET_FK_IGS_CA_STAT;

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     IGS_CA_INST_ALL
      WHERE    cal_type = x_cal_type
      AND      prior_ci_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CI_PRIOR_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END GET_FK_IGS_CA_INST;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_sequence_number IN NUMBER ,
    x_start_dt IN DATE ,
    x_end_dt IN DATE ,
    x_cal_status IN VARCHAR2 ,
    x_alternate_code IN VARCHAR2 ,
    x_sup_cal_status_differ_ind IN VARCHAR2 ,
    x_prior_ci_sequence_number IN NUMBER ,
    x_org_id  IN NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_ss_displayed IN VARCHAR2 ,
    x_description  IN VARCHAR2,
    x_ivr_display_ind IN VARCHAR2,
    x_term_instruction_time IN NUMBER ,
    X_PLANNING_FLAG IN VARCHAR2,
    X_SCHEDULE_FLAG IN VARCHAR2,
    X_ADMIN_FLAG IN VARCHAR2
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_cal_type,
      x_sequence_number,
      x_start_dt,
      x_end_dt,
      x_cal_status,
      x_alternate_code,
      x_sup_cal_status_differ_ind,
      x_prior_ci_sequence_number,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ss_displayed ,
      x_description,
      x_ivr_display_ind,
      x_term_instruction_time,
      X_PLANNING_FLAG,
      X_SCHEDULE_FLAG,
      X_ADMIN_FLAG

    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE ,p_updating => FALSE , p_deleting => FALSE);
	  IF Get_PK_For_Validation (
    		new_references.cal_type,
		    new_references.sequence_number ) THEN
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
				IGS_GE_MSG_STACK.ADD;
         	   App_Exception.Raise_Exception;
	  END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => FALSE , p_updating => TRUE , p_deleting => FALSE );
      beforerowupdate;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
      Check_UK_Child_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      beforerowdelete;
      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (
    		new_references.cal_type,
		    new_references.sequence_number ) THEN
				Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate2 ( p_inserting => TRUE , p_updating => FALSE , p_deleting => FALSE);
      AfterStmtInsertUpdateDelete3 ( p_inserting => TRUE , p_updating => FALSE , p_deleting => FALSE);
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate2 ( p_inserting => FALSE , p_updating => TRUE , p_deleting => FALSE );
      AfterStmtInsertUpdateDelete3 ( p_inserting => FALSE , p_updating => TRUE , p_deleting => FALSE );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      AfterStmtInsertUpdateDelete3 (p_inserting => FALSE , p_updating => FALSE , p_deleting => TRUE );
    END IF;

    l_rowid := NULL;

  END After_DML;

PROCEDURE INSERT_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_CAL_STATUS IN VARCHAR2,
  X_ALTERNATE_CODE IN VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND IN VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER IN NUMBER,
  X_ORG_ID IN NUMBER ,
  X_MODE IN VARCHAR2 ,
  X_SS_DISPLAYED IN VARCHAR2 ,
  X_DESCRIPTION  IN VARCHAR2,
  X_IVR_DISPLAY_IND  IN VARCHAR2,
  X_TERM_INSTRUCTION_TIME IN NUMBER,
  X_PLANNING_FLAG IN VARCHAR2,
  X_SCHEDULE_FLAG IN VARCHAR2,
  X_ADMIN_FLAG IN VARCHAR2
  ) AS
    CURSOR C IS SELECT ROWID FROM IGS_CA_INST_ALL
      WHERE CAL_TYPE = X_CAL_TYPE
      AND SEQUENCE_NUMBER = X_SEQUENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
Before_DML (
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_cal_type =>X_CAL_TYPE,
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_start_dt =>X_START_DT,
    x_end_dt =>X_END_DT,
    x_cal_status =>X_CAL_STATUS,
    x_alternate_code =>X_ALTERNATE_CODE,
    x_sup_cal_status_differ_ind =>NVL(X_SUP_CAL_STATUS_DIFFER_IND,'N'),
    x_prior_ci_sequence_number =>X_PRIOR_CI_SEQUENCE_NUMBER,
    x_org_id  => igs_ge_gen_003.get_org_id,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN,
    x_ss_displayed => X_SS_DISPLAYED,
    x_description => X_DESCRIPTION,
    x_ivr_display_ind => X_IVR_DISPLAY_IND,
    x_term_instruction_time => X_TERM_INSTRUCTION_TIME,
    X_PLANNING_FLAG =>  X_PLANNING_FLAG ,
    X_SCHEDULE_FLAG =>  X_SCHEDULE_FLAG,
    X_ADMIN_FLAG    =>  X_ADMIN_FLAG

  );
  INSERT INTO IGS_CA_INST_ALL (
    CAL_TYPE,
    SEQUENCE_NUMBER,
    START_DT,
    END_DT,
    CAL_STATUS,
    ALTERNATE_CODE,
    SUP_CAL_STATUS_DIFFER_IND,
    PRIOR_CI_SEQUENCE_NUMBER,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    SS_DISPLAYED,
    DESCRIPTION,
    IVR_DISPLAY_IND,
    TERM_INSTRUCTION_TIME,
    PLANNING_FLAG,
    SCHEDULE_FLAG,
    ADMIN_FLAG
) VALUES (
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.START_DT,
    NEW_REFERENCES.END_DT,
    NEW_REFERENCES.CAL_STATUS,
    NEW_REFERENCES.ALTERNATE_CODE,
    NEW_REFERENCES.SUP_CAL_STATUS_DIFFER_IND,
    NEW_REFERENCES.PRIOR_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    X_SS_DISPLAYED,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.IVR_DISPLAY_IND,
    NEW_REFERENCES.TERM_INSTRUCTION_TIME ,
    NEW_REFERENCES.PLANNING_FLAG,
    NEW_REFERENCES.SCHEDULE_FLAG,
    NEW_REFERENCES.ADMIN_FLAG
  );
  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;
After_DML (
    p_action =>'INSERT',
    x_rowid =>X_ROWID
  );
END INSERT_ROW;

PROCEDURE LOCK_ROW (
  X_ROWID IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_CAL_STATUS IN VARCHAR2,
  X_ALTERNATE_CODE IN VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND IN VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER IN NUMBER,
  X_SS_DISPLAYED IN VARCHAR2 ,
  X_DESCRIPTION  IN VARCHAR2,
  X_IVR_DISPLAY_IND IN VARCHAR2,
  X_TERM_INSTRUCTION_TIME IN NUMBER ,
  X_PLANNING_FLAG IN VARCHAR2,
  X_SCHEDULE_FLAG IN VARCHAR2,
  X_ADMIN_FLAG IN VARCHAR2

) AS
  CURSOR c1 IS SELECT
      START_DT,
      END_DT,
      CAL_STATUS,
      ALTERNATE_CODE,
      SUP_CAL_STATUS_DIFFER_IND,
      PRIOR_CI_SEQUENCE_NUMBER,
      DESCRIPTION,
      IVR_DISPLAY_IND,
      TERM_INSTRUCTION_TIME,
      PLANNING_FLAG,
      SCHEDULE_FLAG,
      ADMIN_FLAG
    FROM IGS_CA_INST_ALL
    WHERE ROWID=X_ROWID
    FOR UPDATE NOWAIT;
  tlinfo c1%ROWTYPE;

BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  IF (    (tlinfo.START_DT = X_START_DT)
      AND (tlinfo.END_DT = X_END_DT)
      AND (tlinfo.CAL_STATUS = X_CAL_STATUS)
      AND ((tlinfo.ALTERNATE_CODE = X_ALTERNATE_CODE)
            OR ((tlinfo.ALTERNATE_CODE IS NULL)
                 AND (X_ALTERNATE_CODE IS NULL)))
      AND (tlinfo.SUP_CAL_STATUS_DIFFER_IND = X_SUP_CAL_STATUS_DIFFER_IND)
      AND ((tlinfo.PRIOR_CI_SEQUENCE_NUMBER = X_PRIOR_CI_SEQUENCE_NUMBER)
            OR ((tlinfo.PRIOR_CI_SEQUENCE_NUMBER IS NULL)
                 AND (X_PRIOR_CI_SEQUENCE_NUMBER IS NULL)))
     AND ((tlinfo.DESCRIPTION=X_DESCRIPTION)
           OR ((tlinfo.DESCRIPTION IS NULL)
                AND (X_DESCRIPTION IS NULL )))
     AND ((tlinfo.IVR_DISPLAY_IND=X_IVR_DISPLAY_IND)
           OR ((tlinfo.IVR_DISPLAY_IND IS NULL)
                AND (X_IVR_DISPLAY_IND IS NULL )))
     AND ((tlinfo.TERM_INSTRUCTION_TIME = X_TERM_INSTRUCTION_TIME)
           OR ((tlinfo.TERM_INSTRUCTION_TIME IS NULL)
	        AND (X_TERM_INSTRUCTION_TIME IS NULL)))
     AND ((tlinfo.PLANNING_FLAG = X_PLANNING_FLAG)
           OR ((tlinfo.PLANNING_FLAG IS NULL)
	        AND (X_PLANNING_FLAG IS NULL)))
     AND ((tlinfo.SCHEDULE_FLAG = X_SCHEDULE_FLAG)
           OR ((tlinfo.SCHEDULE_FLAG IS NULL)
	        AND (X_SCHEDULE_FLAG IS NULL)))
     AND ((tlinfo.ADMIN_FLAG = X_ADMIN_FLAG)
           OR ((tlinfo.ADMIN_FLAG IS NULL)
	        AND (X_ADMIN_FLAG IS NULL)))

  ) THEN
    NULL;
  ELSE
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

PROCEDURE UPDATE_ROW (
  X_ROWID IN VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_CAL_STATUS IN VARCHAR2,
  X_ALTERNATE_CODE IN VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND IN VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER IN NUMBER,
  X_MODE IN VARCHAR2 ,
  X_SS_DISPLAYED IN VARCHAR2 ,
  X_DESCRIPTION  IN  VARCHAR2,
  X_IVR_DISPLAY_IND IN  VARCHAR2,
  X_TERM_INSTRUCTION_TIME IN NUMBER ,
  X_PLANNING_FLAG IN VARCHAR2,
  X_SCHEDULE_FLAG IN VARCHAR2,
  X_ADMIN_FLAG IN VARCHAR2
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
    X_SS_DISPLAYED_V VARCHAR2(1) := 'N';
    l_msg            VARCHAR2(30);

BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN IS NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;

--**
    IF X_SS_DISPLAYED IS NULL AND
       old_references.ss_displayed IS NOT NULL THEN
      X_SS_DISPLAYED_V := old_references.ss_displayed;
    ELSE
      X_SS_DISPLAYED_V := X_SS_DISPLAYED;
    END IF;
--**

Before_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_cal_type =>X_CAL_TYPE,
    x_sequence_number =>X_SEQUENCE_NUMBER,
    x_start_dt =>X_START_DT,
    x_end_dt =>X_END_DT,
    x_cal_status =>X_CAL_STATUS,
    x_alternate_code =>X_ALTERNATE_CODE,
    x_sup_cal_status_differ_ind =>X_SUP_CAL_STATUS_DIFFER_IND,
    x_prior_ci_sequence_number =>X_PRIOR_CI_SEQUENCE_NUMBER,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN,
    x_ss_displayed => X_SS_DISPLAYED_V,
    x_description  => X_DESCRIPTION,
    x_ivr_display_ind  => X_IVR_DISPLAY_IND,
    x_term_instruction_time => X_TERM_INSTRUCTION_TIME,
    X_PLANNING_FLAG =>  X_PLANNING_FLAG ,
    X_SCHEDULE_FLAG =>  X_SCHEDULE_FLAG,
    X_ADMIN_FLAG    =>  X_ADMIN_FLAG
  );

   --SINCE WE NEED TO COMMUNICATE TO THE USER THAT DESCRIPTION HAS TO BE SPECIFIED.
   --WITH RESPECT TO THE SWCR003 CALENDAR DESCRIPTION -- CHANGE REQUEST
   --Enh No      :-   2138560 Change Request for Calendar Instance
    --Add a Description Column

    IF  LTRIM(RTRIM(x_description))  IS NULL  THEN

       fnd_message.set_name('IGS','IGS_CA_CALDESC_NOT_AVAILABLE');
       l_msg  :=fnd_message.get;

    ELSE
      l_msg  :=LTRIM(RTRIM(x_description));

    END IF;

  UPDATE IGS_CA_INST_ALL SET
    START_DT = NEW_REFERENCES.START_DT,
    END_DT = NEW_REFERENCES.END_DT,
    CAL_STATUS = NEW_REFERENCES.CAL_STATUS,
    ALTERNATE_CODE = NEW_REFERENCES.ALTERNATE_CODE,
    SUP_CAL_STATUS_DIFFER_IND = NEW_REFERENCES.SUP_CAL_STATUS_DIFFER_IND,
    PRIOR_CI_SEQUENCE_NUMBER = NEW_REFERENCES.PRIOR_CI_SEQUENCE_NUMBER,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    SS_DISPLAYED = X_SS_DISPLAYED_V,
    IVR_DISPLAY_IND = X_IVR_DISPLAY_IND,
    TERM_INSTRUCTION_TIME = X_TERM_INSTRUCTION_TIME,
    DESCRIPTION = l_msg,
    PLANNING_FLAG = x_PLANNING_FLAG,
    SCHEDULE_FLAG = x_SCHEDULE_FLAG,
    ADMIN_FLAG    = x_ADMIN_FLAG
  WHERE ROWID=X_ROWID
  ;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
After_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID
  );
END UPDATE_ROW;

PROCEDURE ADD_ROW (
  X_ROWID IN OUT NOCOPY VARCHAR2,
  X_CAL_TYPE IN VARCHAR2,
  X_SEQUENCE_NUMBER IN NUMBER,
  X_START_DT IN DATE,
  X_END_DT IN DATE,
  X_CAL_STATUS IN VARCHAR2,
  X_ALTERNATE_CODE IN VARCHAR2,
  X_SUP_CAL_STATUS_DIFFER_IND IN VARCHAR2,
  X_PRIOR_CI_SEQUENCE_NUMBER IN NUMBER,
  X_ORG_ID IN NUMBER ,
  X_MODE IN VARCHAR2 ,
  X_SS_DISPLAYED IN VARCHAR2  ,
  X_DESCRIPTION  IN VARCHAR2,
  X_IVR_DISPLAY_IND  IN VARCHAR2,
  X_TERM_INSTRUCTION_TIME IN NUMBER,
  X_PLANNING_FLAG IN VARCHAR2,
  X_SCHEDULE_FLAG IN VARCHAR2,
  X_ADMIN_FLAG IN VARCHAR2
  ) AS
  CURSOR c1 IS SELECT ROWID FROM IGS_CA_INST_ALL
     WHERE CAL_TYPE = X_CAL_TYPE
     AND SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
  ;
BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%NOTFOUND) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_CAL_TYPE,
     X_SEQUENCE_NUMBER,
     X_START_DT,
     X_END_DT,
     X_CAL_STATUS,
     X_ALTERNATE_CODE,
     X_SUP_CAL_STATUS_DIFFER_IND,
     X_PRIOR_CI_SEQUENCE_NUMBER,
     X_ORG_ID,
     X_MODE,
     X_SS_DISPLAYED,
     X_DESCRIPTION,
     X_IVR_DISPLAY_IND,
     X_TERM_INSTRUCTION_TIME ,
     X_PLANNING_FLAG,
     X_SCHEDULE_FLAG ,
     X_ADMIN_FLAG
      );
    RETURN;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_TYPE,
   X_SEQUENCE_NUMBER,
   X_START_DT,
   X_END_DT,
   X_CAL_STATUS,
   X_ALTERNATE_CODE,
   X_SUP_CAL_STATUS_DIFFER_IND,
   X_PRIOR_CI_SEQUENCE_NUMBER,
   X_MODE,
   X_SS_DISPLAYED,
   X_DESCRIPTION,
   X_IVR_DISPLAY_IND,
   X_TERM_INSTRUCTION_TIME ,
   X_PLANNING_FLAG,
   X_SCHEDULE_FLAG ,
   X_ADMIN_FLAG
   );
END ADD_ROW;

PROCEDURE DELETE_ROW (
  X_ROWID IN VARCHAR2
) AS
BEGIN
Before_DML(
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  DELETE FROM IGS_CA_INST_ALL
  WHERE ROWID=X_ROWID;
  IF (SQL%NOTFOUND) THEN
    RAISE NO_DATA_FOUND;
  END IF;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
END DELETE_ROW;

PROCEDURE beforerowdelete AS
  ------------------------------------------------------------------
  --Created by  : vchappid, Oracle India
  --Date created: 12-Jun-2002
  --
  --Purpose: Only planned Calendar Instances are allowed for deletion
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  CURSOR cur_delete (cp_cal_type igs_ca_inst.cal_type%TYPE, cp_seq_number igs_ca_inst.sequence_number%TYPE)
  IS
  SELECT 'x'
  FROM   igs_ca_inst i, igs_ca_stat s
  WHERE  i.cal_status = s.cal_status
  AND    s.s_cal_status = 'PLANNED'
  AND    i.cal_type = cp_cal_type
  AND    i.sequence_number = cp_seq_number;
  l_check VARCHAR2(1);

BEGIN
         -- Only planned Calendar Instances are allowed for deletion
         OPEN  cur_delete (old_references.cal_type,old_references.sequence_number );
	 FETCH cur_delete INTO l_check;
	 IF cur_delete%NOTFOUND THEN
           close cur_delete;
           fnd_message.set_name('IGS','IGS_CA_NO_DELETE_ALLOWED');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
         END IF;
         close cur_delete;
END beforerowdelete;

PROCEDURE beforerowupdate AS
  ------------------------------------------------------------------
  --Created by  : vchappid, Oracle India
  --Date created: 12-Jun-2002
  --
  --Purpose: Active Calendar Status calendar instance can not be changed to Planned Status
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  --kpadiyar    06-May-2003     Added the validations for bug 2885873
  -------------------------------------------------------------------
        CURSOR cur_get_status (cp_cal_status igs_ca_inst.cal_status%TYPE)
        IS
        SELECT s_cal_status
        FROM   igs_ca_stat
        WHERE  cal_status = cp_cal_status;
        l_s_cal_status igs_ca_stat.s_cal_status%TYPE;

        CURSOR cur_check_update (cp_cal_type igs_ca_inst.cal_type%TYPE, cp_seq_number igs_ca_inst.sequence_number%TYPE)
        IS
        SELECT 'x'
        FROM   igs_ca_inst i, igs_ca_stat s
        WHERE  i.cal_status = s.cal_status
        AND    s.s_cal_status = 'ACTIVE'
        AND    i.cal_type = cp_cal_type
        AND    i.sequence_number = cp_seq_number;
        l_check VARCHAR2(1);
BEGIN
                -- get the system calendar status for the user defined cal status
                -- if the calendar status is changed and the in the form the system cal status is PLANNED and the
                -- old value of the system cal status is ACTIVE then the updation should be aborted
                OPEN cur_get_status(new_references.cal_status);
                FETCH cur_get_status INTO l_s_cal_status;
                IF cur_get_status%FOUND THEN
                CLOSE cur_get_status;
                  IF (l_s_cal_status = 'PLANNED') THEN
                    OPEN cur_check_update(old_references.cal_type, old_references.sequence_number);
                    FETCH cur_check_update INTO l_check;
                    IF cur_check_update%FOUND THEN
                      CLOSE cur_check_update;
                      fnd_message.set_name('IGS','IGS_CA_INACTIVE_NOTCHG_PLANN');
                      igs_ge_msg_stack.add;
                      app_exception.raise_exception;
                    END IF;
                    CLOSE cur_check_update;
                  END IF;
                ELSE
                  -- If the calendar status is not found then the record might have been deleted
                  CLOSE cur_get_status;
                  fnd_message.set_name('FND','FORM_RECORD_DELETED');
                  igs_ge_msg_stack.add;
                  app_exception.raise_exception;
                END IF;

		DECLARE
		 l_ret_status boolean;
		 l_message_name fnd_new_messages.message_name%TYPE;

		 CURSOR c_old_status (p_cal_status IN VARCHAR2) IS
		   SELECT s_cal_status
		   FROM   igs_ca_stat
		   WHERE  cal_status = p_cal_status
		   AND    closed_ind = 'N';

		 l_old_status igs_ca_stat.s_cal_status%TYPE;

		 CURSOR c_new_status (p_cal_status IN VARCHAR2) IS
		   SELECT s_cal_status
		   FROM   igs_ca_stat
		   WHERE  cal_status = p_cal_status
		   AND    closed_ind = 'N';

		 l_new_status igs_ca_stat.s_cal_status%TYPE;

		 CURSOR c_cal_type (p_cal_type IN VARCHAR2) IS
		   SELECT s_cal_cat
		   FROM   igs_ca_type
		   WHERE  cal_type = p_cal_type
		   AND    closed_ind = 'N';

		 l_cal_type igs_ca_type.s_cal_cat%TYPE;

		BEGIN
		  OPEN c_old_status(old_references.cal_status);
		   FETCH c_old_status INTO l_old_status;
		  CLOSE c_old_status;

		  OPEN c_new_status(new_references.cal_status);
		   FETCH c_new_status INTO l_new_status;
		  CLOSE c_new_status;

		  OPEN c_cal_type(new_references.cal_type);
		   FETCH c_cal_type INTO l_cal_type;
		  CLOSE c_cal_type;

		 IF (
		    (l_cal_type = 'TEACHING') AND
		    (l_old_status <> l_new_status) AND
		    (l_old_status IN ('ACTIVE','INACTIVE')) AND
		    (l_new_status IN ('ACTIVE','INACTIVE'))
		    )THEN
			  igs_ps_gen_001.Change_Unit_Section_Status(
						 l_old_status,
						 l_new_status,
						 new_references.cal_type,
						 new_references.sequence_number,
						 l_ret_status,
						 l_message_name);
			   IF NOT l_ret_status THEN
				 Fnd_Message.Set_Name ('IGS', l_message_name);
				 IGS_GE_MSG_STACK.ADD;
				 App_Exception.Raise_Exception;
			   END IF;
                END IF;

	      EXCEPTION
	        WHEN OTHERS THEN

		  IF c_old_status%ISOPEN THEN
		    CLOSE c_old_status;
		  END IF;

		  IF c_new_status%ISOPEN THEN
		    CLOSE c_new_status;
		  END IF;

		  IF c_cal_type%ISOPEN THEN
 		    CLOSE c_cal_type;
		  END IF;
		  --kumma, 2986872, Added the following line to raise the exception
		  App_Exception.Raise_Exception;
              END;

END beforerowupdate;

END igs_ca_inst_pkg;

/
