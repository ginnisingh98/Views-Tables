--------------------------------------------------------
--  DDL for Package Body IGS_AD_PRC_TAC_OFFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PRC_TAC_OFFER" AS
/* $Header: IGSAD15B.pls 120.2 2005/10/18 02:48:51 appldev ship $ */

/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
sarakshi   20-May-2003   Enh#2858431,admp_ins_tac_course modified to replace TAC-FEE,TAC-HECS to OTHERS
vchappid   29-Aug-2001   Added new parameters into function calls, Enh Bug#1964478
ssawhney  feb15          bug 2225917 SWCR008 remove customer creation.
cdcruz    feb18          bug 2217104 Admit to future term Enhancement,updated tbh call for
                         new columns being added to IGS_AD_PS_APPL_INST
knag       21-Nov-2002   Added new parameters to admp_ins_adm_appl for bug 2664410
                         and new parameters to call to igs_ad_appl_pkg.insert_row
pkpatel   01-DEC-2002    Bug NO: 2599109 (Sevis DLD)
                         Modified the the signatute of call to TBH IGS_PE_ALT_PERS_ID_PKG.INSERT_ROW
anilk     18-FEB-2003    Bug#2784198
                         Added closed_ind = 'N' to where clause for cursor c_hl
asbala	  12-nov-03      3227107: address changes - signature of igs_pe_person_addr_pkg.insert_row and update_row changed
gmaheswa  19-Nov-2003    3227107: Modified cursor c_pa in admp_ins_person_addr to select records having active status.
******************************************************************/

  --
  -- Get the admission category for this COURSE offering option
  FUNCTION admp_get_ac_cooac(
  p_coo_id IN NUMBER ,
  p_admission_cat IN OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_get_ac_cooac
  	-- This module retrieves the admission category from the IGS_PS_COURSE
  	-- offering option admission category table
  DECLARE
  	v_x			VARCHAR2(1) DEFAULT NULL;
  	v_ret_val		BOOLEAN	DEFAULT TRUE;
  	CURSOR	c_cooac IS
  		SELECT	admission_cat
  		FROM	IGS_PS_OF_OPT_AD_CAT
  		WHERE	coo_id 			= p_coo_id AND
  			system_default_ind 	= 'Y';
  	CURSOR	c_cooac2 IS
  		SELECT	'x'
  		FROM	IGS_PS_OF_OPT_AD_CAT
  		WHERE	coo_id 			= p_coo_id AND
  			admission_cat 		= p_admission_cat;
  BEGIN
  	p_message_name := NULL;
  	IF p_admission_cat IS NULL THEN
  	-- Select default admission category
  		OPEN c_cooac;
  		LOOP
  			FETCH c_cooac INTO p_admission_cat;
  			IF (c_cooac%ROWCOUNT = 0 OR
  				c_cooac%ROWCOUNT > 1) THEN
				p_message_name := 'IGS_AD_CANNOTFIND_ADMCAT';
  				v_ret_val := FALSE;
  			END IF;
  			-- EXIT WHEN statement must be after IF statement as
  			-- p_message_name has to be set if no records found before
  			-- exiting the loop
  			EXIT WHEN (c_cooac%NOTFOUND);
  		END LOOP;
  		CLOSE c_cooac;
  	ELSE
  	-- Check that COURSE offering option admission category mapping exists
  	-- Select anything from course_offering_option_adm_cat
  		OPEN c_cooac2;
  		FETCH c_cooac2 INTO v_x;
  		IF (c_cooac2%NOTFOUND) THEN
  			CLOSE c_cooac2;
			p_message_name := 'IGS_GE_INVALID_VALUE';
  			RETURN FALSE;
  		END IF;
  		CLOSE c_cooac2;
  	END IF;
  	RETURN v_ret_val;
  	EXCEPTION
  		WHEN OTHERS THEN
  			IF (c_cooac%ISOPEN) THEN
  				CLOSE c_cooac;
  			END IF;
  			IF (c_cooac2%ISOPEN) THEN
  				CLOSE c_cooac2;
  			END IF;
  			RETURN FALSE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_get_ac_cooac');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_get_ac_cooac;
  --
  -- Insert an Australian secondary education record
  FUNCTION admp_ins_aus_scn_edu(
  p_person_id IN NUMBER ,
  p_result_obtained_yr IN NUMBER ,
  p_score IN NUMBER ,
  p_state_cd IN VARCHAR2 ,
  p_candidate_number IN NUMBER ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_secondary_school_cd IN VARCHAR2 ,
  p_ase_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_ins_aus_scn_edu
  	-- This procedure inserts a new IGS_AD_AUS_SEC_EDU record
  DECLARE
  	v_secondary_school_cd		IGS_AD_AUS_SEC_ED_SC.secondary_school_cd%TYPE := NULL;
  	v_ase_sequence_number		IGS_AD_AUS_SEC_EDU.sequence_number%TYPE;
  	CURSOR c_ass IS
  		SELECT 	secondary_school_cd
  		FROM 	IGS_AD_AUS_SEC_ED_SC
  		WHERE 	secondary_school_cd 	= p_secondary_school_cd  AND
  			closed_ind 		= 'N' AND
  			state_cd 		= p_state_cd;
  	CURSOR c_aseat IS
  		SELECT 	aus_scndry_edu_ass_type,
  			state_cd
  		FROM	IGS_AD_AUSE_ED_AS_TY
  		WHERE	aus_scndry_edu_ass_type = p_aus_scndry_edu_ass_type OR
  			p_aus_scndry_edu_ass_type 	IS NULL OR
  			tac_aus_scndry_edu_ass_type = p_aus_scndry_edu_ass_type;
  	CURSOR c_ases IS
  		SELECT	NVL(MAX(ase_sequence_number), 0) +1
  		FROM 	IGS_AD_AUS_SEC_ED_SU
  		WHERE 	person_id = p_person_id;
  	v_ass_rec		c_ass%ROWTYPE;
  	v_aseat_rec		c_aseat%ROWTYPE;
  	v_aseat_found		BOOLEAN := FALSE;
  	v_match_found		BOOLEAN := FALSE;
  	v_aus_scndry_edu_ass_type		VARCHAR2(255);
  	v_state_cd			VARCHAR2(255);
    lv_rowid 	VARCHAR2(25);
  BEGIN
  	p_message_name := NULL;
  	-- Validate Australian Secondary Education information
  	IF p_state_cd IS NULL OR
  			p_score IS NULL OR
  			p_aus_scndry_edu_ass_type IS NULL THEN
		p_message_name := 'IGS_AD_CANINS_ONE_STCD';
  		RETURN FALSE;
  	END IF;
  	-- Loop though all the states which match the
  	-- secondary education assessment type
  	FOR v_aseat_rec IN c_aseat LOOP
  		v_aus_scndry_edu_ass_type := v_aseat_rec.aus_scndry_edu_ass_type;
  		v_state_cd	:= v_aseat_rec.state_cd;
  		v_aseat_found := TRUE;
  		-- Validate the state code input parameter
  		IF (v_aseat_rec.state_cd IS NOT NULL AND
  				v_aseat_rec.state_cd = p_state_cd) OR
  				v_aseat_rec.state_cd IS NULL THEN
  			v_match_found := TRUE;
  			EXIT;
  		END IF;
  	END LOOP;
  	-- Record is not found
  	IF NOT v_aseat_found THEN
		p_message_name := 'IGS_AD_ASSTYPE_NOTVALID_ASSTY';
  		RETURN FALSE;
  	END IF;
  	-- No assessment type match is found
  	IF NOT v_match_found THEN
		p_message_name := 'IGS_AD_ASSTYPE_NOTVALID_STCD';
  		RETURN FALSE;
  	END IF;
  	-- Validate the secondary school code and include it
  	IF p_secondary_school_cd IS NOT NULL THEN
  		OPEN c_ass;
  		FETCH c_ass INTO v_ass_rec;
  		IF c_ass%FOUND THEN
  			v_secondary_school_cd := v_ass_rec.secondary_school_cd;
  		END IF;
  		CLOSE c_ass;
  	END IF;
  	-- Get the next sequence number for IGS_AD_AUS_SEC_ED_SC for PERSON
  	-- A number will always be returned, at least 1.
  	OPEN c_ases;
  	FETCH c_ases INTO v_ase_sequence_number;
  	CLOSE c_ases;
  	-- Insert the record
	 Igs_Ad_Aus_Sec_Edu_Pkg.Insert_Row (
	      					X_Mode                              => 'R',
	      					X_RowId                             => lv_rowid,
	      					X_Person_Id                         => p_person_id,
	      					X_Sequence_Number                   => v_ase_sequence_number,
	      					X_State_Cd                          => p_state_cd,
	      					X_Result_Obtained_Yr                => p_result_obtained_yr,
	      					X_Score                             => p_score,
	      					X_Aus_Scndry_Edu_Ass_Type           => v_aus_scndry_edu_ass_type,
	      					X_Candidate_Number                  => p_candidate_number,
	      					X_Secondary_School_Cd               => v_secondary_school_cd
	  );

  	p_ase_sequence_number := v_ase_sequence_number;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_aus_scn_edu');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_aus_scn_edu;
  --
  -- Insert an Australian secondary education subject record
  FUNCTION admp_ins_aus_scn_sub(
  p_person_id IN NUMBER ,
  p_ase_sequence_number IN NUMBER ,
  p_subject_result_yr IN NUMBER ,
  p_subject_cd IN VARCHAR2 ,
  p_subject_desc IN VARCHAR2 ,
  p_subject_mark IN VARCHAR2 ,
  p_subject_mark_level IN VARCHAR2 ,
  p_subject_weighting IN VARCHAR2 ,
  p_subject_ass_type IN VARCHAR2 ,
  p_notes IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_ins_aus_scn_sub
  	-- This procedure inserts a new IGS_AD_AUS_SEC_ED_SC record
  DECLARE
  	CURSOR c_aseat IS
  		SELECT 	aus_scndry_edu_ass_type
  		FROM 	IGS_AD_AUSE_ED_AS_TY
  		WHERE 	aus_scndry_edu_ass_type 	=  p_subject_ass_type OR
  			tac_aus_scndry_edu_ass_type 	= p_subject_ass_type;
  	v_aseat_rec		c_aseat%ROWTYPE;
  	v_subject_ass_type	IGS_AD_AUS_SEC_ED_SU.subject_ass_type%TYPE DEFAULT NULL;
    lv_rowid 	VARCHAR2(25);
  BEGIN
  	p_message_name := NULL;
  	-- Validate Parameters
  	IF p_person_id IS NULL OR
  			p_ase_sequence_number IS NULL OR
  			p_subject_result_yr IS NULL OR
  			p_subject_cd IS NULL THEN
		p_message_name := 'IGS_AD_SEC_EDU_CANINS_PRSNID';
  		RETURN FALSE;
  	END IF;
  	-- Get assessment type
  	OPEN c_aseat;
  	FETCH c_aseat INTO v_aseat_rec;
  	IF c_aseat%FOUND THEN
  		v_subject_ass_type := v_aseat_rec.aus_scndry_edu_ass_type;
  	END IF;
  	CLOSE c_aseat;

    Igs_Ad_Aus_Sec_Ed_Su_Pkg.Insert_Row (
      					X_Mode                              => 'R',
      					X_RowId                             => lv_rowid,
      					X_Person_Id                         => p_person_id,
      					X_Ase_Sequence_Number               => p_ase_sequence_number,
      					X_Subject_Result_Yr                 => p_subject_result_yr,
      					X_Subject_Cd                        => p_subject_cd,
      					X_Subject_Desc                      => p_Subject_Desc,
      					X_Subject_Mark                      => p_Subject_Mark,
      					X_Subject_Mark_Level                => p_Subject_Mark_Level,
      					X_Subject_Weighting                 => p_Subject_Weighting,
      					X_Subject_Ass_Type                  => p_Subject_Ass_Type,
      					X_Notes                             => NULL
    );

  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_aus_scn_sub');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_aus_scn_sub;
  --
  -- Retrieves the admission code and basis for admission type
  --
  -- Finds the user defined tertiary edu level of completion.
  FUNCTION ADMP_GET_LVL_COMP(
  p_tac_level_of_comp IN VARCHAR2 )
  RETURN VARCHAR2 IS
  BEGIN	-- ADMP_GET_LVL_COMP
  	--This module finds the user defined tertiary education
  	--level of completion from the TAC level of completion
  DECLARE
  	v_tertiary_edu_lvl_comp		IGS_AD_TER_ED_LV_COM.tertiary_edu_lvl_comp%TYPE;
  	CURSOR c_teloc IS
  		SELECT 	teloc.tertiary_edu_lvl_comp
  		FROM	IGS_AD_TER_ED_LV_COM	teloc
  		WHERE	teloc.tac_level_of_comp	= p_tac_level_of_comp	AND
  			teloc.closed_ind	= 'N';
  BEGIN
  	OPEN c_teloc;
  	FETCH c_teloc INTO v_tertiary_edu_lvl_comp;
  	IF (c_teloc%NOTFOUND) THEN
  		v_tertiary_edu_lvl_comp := NULL;
  	END IF;
  	--if multiple records are found just return the first one
  	CLOSE c_teloc;
  	RETURN v_tertiary_edu_lvl_comp;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_get_lvl_comp');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END ADMP_GET_LVL_COMP;
  --
  -- Inserts an admission application record
  FUNCTION admp_ins_adm_appl(
  p_person_id IN NUMBER ,
  p_appl_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN OUT NOCOPY VARCHAR2 ,
  p_tac_appl_ind IN VARCHAR2,
  p_adm_appl_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_spcl_grp_1   IN NUMBER ,  --Bug#1964478, Parameter added
  p_spcl_grp_2   IN NUMBER ,  --Bug#1964478, Parameter added
  p_common_app   IN VARCHAR2, --Bug#1964478, Parameter added
  p_application_type IN VARCHAR2,
  p_choice_number IN VARCHAR2,
  p_routeb_pref IN VARCHAR2,
  p_alt_appl_id IN VARCHAR2 ) -- Added for Bug 2664410
  RETURN BOOLEAN IS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
vchappid   29-Aug-2001   Added new parameters into function calls, Enh Bug#1964478
rboddu     04-OCT-2002     Creating application with Application_Type. Bug :2599457
******************************************************************/

  BEGIN	--admp_ins_adm_appl
  	--Procedure inserts a new IGS_AD_APPL record. It uses an
  	--output parameter to pass back the new admission_appl_number used
  DECLARE
  	v_dummy		CHAR;
  	v_adm_fee_status			VARCHAR2(10);
  	v_adm_appl_number		IGS_AD_APPL.admission_appl_number%TYPE;
  	v_message_name VARCHAR2(30);
  	v_return_type			VARCHAR2(1);
  	v_title_required_ind		VARCHAR2(1)	DEFAULT 'Y';
  	v_birth_dt_required_ind		VARCHAR2(1)	DEFAULT 'Y';
  	v_fees_required_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_person_encmb_chk_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_cond_offer_fee_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
  	cst_error				CONSTANT	VARCHAR2(1) := 'E';
  	cst_warn				CONSTANT	VARCHAR2(1) := 'W';
  	CURSOR c_apcs (
  		cp_admission_cat		IGS_AD_PRCS_CAT_STEP.admission_cat%TYPE,
  		cp_s_admission_process_type
  					IGS_AD_PRCS_CAT_STEP.s_admission_process_type%TYPE) IS
  	SELECT	s_admission_step_type
  	FROM	IGS_AD_PRCS_CAT_STEP
  	WHERE	admission_cat = cp_admission_cat AND
  		s_admission_process_type = cp_s_admission_process_type
  		AND step_group_type <> 'TRACK';
  	-- Have to find the last admission_appl_number used.
     	CURSOR	 c_aa IS
       	SELECT	 NVL(MAX(admission_appl_number),0) + 1
        	FROM  	 igs_ad_appl
        	WHERE 	 person_id = p_person_id;

    CURSOR c_sys_def_appl_type(cp_adm_cat igs_ad_appl_all.admission_cat%TYPE,
                             cp_s_adm_prc_typ  igs_ad_appl_all.s_admission_process_type%TYPE
                             )
    IS
    SELECT admission_application_type
  	FROM igs_ad_ss_appl_typ
  	WHERE admission_cat = cp_adm_cat
    AND S_admission_process_type = cp_s_adm_prc_typ
    AND System_default = 'Y'
    AND NVL(closed_ind, 'N') <> 'Y';

    l_application_type igs_ad_appl_all.application_type%TYPE;
    lv_rowid 	VARCHAR2(25);
    l_org_id	NUMBER(15);
  BEGIN
  	-- Work out NOCOPY the new admission_appl_number.
  	OPEN c_aa;
      	FETCH c_aa
      	INTO  v_adm_appl_number;
      	IF c_aa%NOTFOUND THEN
        		RAISE NO_DATA_FOUND;
      	END IF;
      	CLOSE c_aa;
  	--
  	-- Determine the admission process category steps.
  	--
  	FOR v_apcs_rec IN c_apcs (
  			p_admission_cat,
  			p_s_admission_process_type)
  	LOOP
  		IF v_apcs_rec.s_admission_step_type = 'UN-IGS_PE_TITLE' THEN
  			v_title_required_ind := 'N';
  		ELSIF v_apcs_rec.s_admission_step_type = 'UN-DOB' THEN
  			v_birth_dt_required_ind := 'N';
  		ELSIF v_apcs_rec.s_admission_step_type = 'APP-FEE' THEN
  			v_fees_required_ind := 'Y';
  		ELSIF v_apcs_rec.s_admission_step_type = 'CHKPENCUMB' THEN
  			v_person_encmb_chk_ind := 'Y';
  		ELSIF v_apcs_rec.s_admission_step_type = 'FEE-COND' THEN
  			v_cond_offer_fee_allowed_ind := 'Y';
  		END IF;
  	END LOOP;
  	-- Set fee status
  	IF v_fees_required_ind = 'Y' THEN
  		p_adm_fee_status := 'EXEMPT';
  	END IF;
  	--
  	-- Validate insert of the admission application record.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_insert (
  			p_person_id,
  			p_adm_cal_type,
  			p_adm_ci_sequence_number,
  			p_s_admission_process_type,
  			v_person_encmb_chk_ind,
  			p_appl_dt,
  			v_title_required_ind,
  			v_birth_dt_required_ind,
  			v_message_name,
  			v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--
  	-- Validate the Academic Calendar.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_acad_cal (
  			p_acad_cal_type,
  			p_acad_ci_sequence_number,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Calendar.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_adm_cal (
  			p_adm_cal_type,
  			p_adm_ci_sequence_number,
  			p_acad_cal_type,
  			p_acad_ci_sequence_number,
  			p_admission_cat,
  			p_s_admission_process_type,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Category.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_adm_cat (
  			p_admission_cat,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Application Date.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_appl_dt (
  			p_appl_dt,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Application Status.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_aas (
  			p_person_id,
  			v_adm_appl_number,
  			p_adm_appl_status,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the Admission Fee Status.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_afs (
  			p_person_id,
  			v_adm_appl_number,
  			p_adm_fee_status,
  			v_fees_required_ind,
  			v_cond_offer_fee_allowed_ind,
  			v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	--
  	-- Validate the TAC Application Indicator.
  	--
  	IF Igs_Ad_Val_Aa.admp_val_aa_tac_appl (
  			p_person_id,
  			p_tac_appl_ind,
  			p_appl_dt,
  			p_s_admission_process_type,
  			v_message_name,
  			v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--Now insert the new record
  	--Populate the org id
	l_org_id := igs_ge_gen_003.get_org_id;

      OPEN c_sys_def_appl_type(p_admission_cat,p_s_admission_process_type);
      FETCH c_sys_def_appl_type INTO l_application_type;
      CLOSE c_sys_def_appl_type;

    --Validate the Application Type and fail the validation if Application Type passed is NULL. Bug: 2599457
      IF l_application_type IS NULL THEN
        p_message_name:= 'IGS_AD_APPL_TYPE_NULL';
  			RETURN FALSE;
  		END IF;

    Igs_Ad_Appl_Pkg.Insert_Row (
      					X_Mode                              => 'R',
      					X_RowId                             => lv_rowid,
      					X_Person_Id                         => p_Person_Id,
      					X_Admission_Appl_Number             => v_adm_appl_number,
      					X_Appl_Dt                           => p_Appl_Dt,
      					X_Acad_Cal_Type                     => p_Acad_Cal_Type,
      					X_Acad_Ci_Sequence_Number           => p_Acad_Ci_Sequence_Number,
      					X_Adm_Cal_Type                      => p_Adm_Cal_Type,
      					X_Adm_Ci_Sequence_Number            => p_Adm_Ci_Sequence_Number,
      					X_Admission_Cat                     => p_Admission_Cat,
      					X_S_Admission_Process_Type          => p_S_Admission_Process_Type,
      					X_Adm_Appl_Status                   => p_Adm_Appl_Status,
      					X_Adm_Fee_Status                    => p_Adm_Fee_Status,
      					X_Tac_Appl_Ind                      => p_Tac_Appl_Ind,
      					X_Org_Id			    => l_org_id,
                                        X_Spcl_Grp_1                        => p_spcl_grp_1, -- bug# 1964478, parameter added
                                        X_Spcl_Grp_2                        => p_spcl_grp_2, -- bug# 1964478, parameter added
                                        X_Common_App                        => p_common_app,  -- bug# 1964478, parameter added
                                        x_application_type                  => l_application_type, -- Added as part of 2599457
                                        x_choice_number                     => p_choice_number,
                                        x_routeb_pref                       => p_routeb_pref,
                                        x_alt_appl_id                       => p_alt_appl_id -- Added for bug 2664410
    				);

  	p_adm_appl_number := v_adm_appl_number;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_adm_appl');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_adm_appl;
  --
  -- Inserts TAC details to form an admission COURSE application instance
  FUNCTION admp_ins_tac_acai(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_adm_fee_status IN VARCHAR2 ,
  p_preference_number IN NUMBER ,
  p_offer_dt IN DATE ,
  p_offer_response_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_insert_outcome_ind IN VARCHAR2 ,
  p_pre_enrol_ind IN VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
knag       28-Oct-2002   Called func igs_ad_gen_003.get_core_or_optional_unit for bug 2647482
******************************************************************/

  BEGIN	-- admp_ins_tac_acai
  	-- This procedure inserts a new IGS_AD_PS_APPL_INST record for the TAC
  	-- offer load process.
  DECLARE
  	e_resource_busy			EXCEPTION;
  	PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
  	p_dummy		VARCHAR2(10);
  	v_check			CHAR;
  	v_s_admission_process_type	IGS_AD_PRCS_CAT.s_admission_process_type%TYPE;
  	v_fee_cat			IGS_FI_FEE_CAT.fee_cat%TYPE;
  	v_enrolment_cat			IGS_EN_ENROLMENT_CAT.enrolment_cat%TYPE;
  	v_correspondence_cat		IGS_CO_CAT.correspondence_cat%TYPE;
  	v_hecs_payment_option		IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE;
  	v_description			IGS_FI_FEE_CAT.description%TYPE;
  	v_message_name VARCHAR2(30);
  	v_hecs_message_name		VARCHAR2(30);
  	v_pre_enrol_message_name	VARCHAR2(30);
  	v_outcome_message_name		VARCHAR2(30);
  	v_apcs_pref_limit_ind		VARCHAR2(127);
  	v_apcs_app_fee_ind		VARCHAR2(127);
  	v_apcs_late_app_ind		VARCHAR2(127);
  	v_apcs_late_fee_ind		VARCHAR2(127);
  	v_apcs_chkpencumb_ind		VARCHAR2(127);
  	v_apcs_fee_assess_ind		VARCHAR2(127);
  	v_apcs_corcategry_ind		VARCHAR2(127);
  	v_apcs_enrcategry_ind		VARCHAR2(127);
  	v_apcs_chkcencumb_ind		VARCHAR2(127);
  	v_apcs_unit_set_ind		VARCHAR2(127);
  	v_apcs_un_crs_us_ind		VARCHAR2(127);
  	v_apcs_chkuencumb_ind		VARCHAR2(127);
  	v_apcs_unit_restr_ind		VARCHAR2(127);
  	v_apcs_unit_restriction_num	VARCHAR2(127);
  	v_apcs_un_dob_ind		VARCHAR2(127);
  	v_apcs_un_title_ind		VARCHAR2(127);
  	v_apcs_asses_cond_ind		VARCHAR2(127);
  	v_apcs_fee_cond_ind		VARCHAR2(127);
  	v_apcs_doc_cond_ind		VARCHAR2(127);
  	v_apcs_multi_off_ind		VARCHAR2(127);
  	v_apcs_multi_off_restn_num	VARCHAR2(127);
  	v_apcs_set_otcome_ind		VARCHAR2(127);
  	v_apcs_override_o_ind		VARCHAR2(127);
  	v_apcs_defer_ind		VARCHAR2(127);
  	v_apcs_ack_app_ind		VARCHAR2(127);
  	v_apcs_outcome_lt_ind		VARCHAR2(127);
  	v_apcs_pre_enrol_ind		VARCHAR2(127);
  	v_hecs_pmnt_option_found	BOOLEAN DEFAULT TRUE;
  	v_offer_letter_ins		BOOLEAN DEFAULT TRUE;
  	v_pre_enr_done			BOOLEAN DEFAULT TRUE;
  	v_adm_doc_status 		VARCHAR2(127);
  	v_adm_entry_qual_status		VARCHAR2(127);
  	v_adm_pending_outcome_status	VARCHAR2(127);
  	v_adm_cndtnl_offer_status	VARCHAR2(127);
  	v_adm_offer_dfrmnt_status	VARCHAR2(127);
  	v_late_adm_fee_status		VARCHAR2(127);
  	v_acai_sequence_number		IGS_CA_INST.sequence_number%TYPE;
  	v_offer_adm_outcome_status	VARCHAR2(127);
  	v_adm_offer_resp_status		VARCHAR2(127);
  	v_new_adm_offer_resp_status	VARCHAR2(127);
  	v_offer_response_dt		DATE;
  	v_return_type			VARCHAR2(1);
  	cst_error			CONSTANT	VARCHAR2(1):= 'E';
  	CURSOR c_nxt_acai_seq_num IS
  		SELECT	NVL(MAX(sequence_number), 0) + 1
  		FROM	IGS_AD_PS_APPL_INST
  		WHERE
  			person_id		= p_person_id 	AND
  			admission_appl_number	= p_admission_appl_number AND
  			nominated_course_cd	= p_course_cd;
  	CURSOR c_upd_acai IS
		SELECT	ROWID, APAI.*
  		FROM	IGS_AD_PS_APPL_INST APAI
  		WHERE
  			person_id		= p_person_id			AND
  			admission_appl_number	= p_admission_appl_number	AND
  			nominated_course_cd	= p_course_cd			AND
  			sequence_number		= v_acai_sequence_number
  		FOR UPDATE OF person_id NOWAIT;
	 Rec_IGS_AD_PS_APPL_Inst		c_upd_acai%ROWTYPE;
	 LV_ROWID					VARCHAR2(25);
	 l_org_id	NUMBER(15);
  BEGIN
           /*
	  ||  Change History :
	  ||  Who             When            What
          ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
	  ||  rrengara      26-JUL-2001     Bug Enh No: 1891835 : For the DLD Process Student Response to Offer. Added two columns in TBH
	  ||  (reverse chronological order - newest change first)
        */

  	p_message_name := NULL;
  	v_s_admission_process_type := 'IGS_PS_COURSE';
  	--------------------------------------------------
  	-- Get the admission process category steps.
  	--------------------------------------------------
  	Igs_Ad_Gen_004.ADMP_GET_APCS_VAL(
  			p_admission_cat,
  			v_s_admission_process_type,
  			v_apcs_pref_limit_ind,		-- OUT NOCOPY
  			v_apcs_app_fee_ind,		-- OUT NOCOPY
  			v_apcs_late_app_ind,		-- OUT NOCOPY
  			v_apcs_late_fee_ind,		-- OUT NOCOPY
  			v_apcs_chkpencumb_ind,		-- OUT NOCOPY
  			v_apcs_fee_assess_ind,		-- OUT NOCOPY
  			v_apcs_corcategry_ind,		-- OUT NOCOPY
  			v_apcs_enrcategry_ind,		-- OUT NOCOPY
  			v_apcs_chkcencumb_ind,		-- OUT NOCOPY
  			v_apcs_unit_set_ind,		-- OUT NOCOPY
  			v_apcs_un_crs_us_ind,		-- OUT NOCOPY
  			v_apcs_chkuencumb_ind,		-- OUT NOCOPY
  			v_apcs_unit_restr_ind,		-- OUT NOCOPY
  			v_apcs_unit_restriction_num,	-- OUT NOCOPY
  			v_apcs_un_dob_ind,		-- OUT NOCOPY
  			v_apcs_un_title_ind,		-- OUT NOCOPY
  			v_apcs_asses_cond_ind,		-- OUT NOCOPY
  			v_apcs_fee_cond_ind,		-- OUT NOCOPY
  			v_apcs_doc_cond_ind,		-- OUT NOCOPY
  			v_apcs_multi_off_ind,		-- OUT NOCOPY
  			v_apcs_multi_off_restn_num,	-- OUT NOCOPY
  			v_apcs_set_otcome_ind,		-- OUT NOCOPY
  			v_apcs_override_o_ind,		-- OUT NOCOPY
  			v_apcs_defer_ind,		-- OUT NOCOPY
  			v_apcs_ack_app_ind,		-- OUT NOCOPY
  			v_apcs_outcome_lt_ind,		-- OUT NOCOPY
  			v_apcs_pre_enrol_ind);		-- OUT NOCOPY
  	--------------------------------
  	-- Set fee category
  	--------------------------------
  	IF p_fee_cat IS NULL	THEN
  		-- Derive the fee category
  		v_fee_cat := Igs_Ad_Gen_005.ADMP_GET_DFLT_FCM(
  					p_admission_cat,
  					v_description);
  	ELSIF Igs_Ad_Val_Acai.admp_val_acai_fc(
  				p_admission_cat,
  				p_fee_cat,
  				v_message_name) = FALSE THEN
  		v_fee_cat := NULL;
  	ELSE
  		v_fee_cat := p_fee_cat;
  	END IF;
  	--------------------------------
  	-- Set enrolment category
  	--------------------------------
  	IF p_enrolment_cat IS NULL THEN
  		-- Derive the enrolment category
  		v_enrolment_cat := Igs_Ad_Gen_005.ADMP_GET_DFLT_ECM(
  					p_admission_cat,
  					v_description);
  	ELSIF Igs_Ad_Val_Acai.admp_val_acai_ec(
  			p_admission_cat,
  			p_enrolment_cat,
  			v_message_name) = FALSE THEN
  		v_enrolment_cat := NULL;
  	ELSE
  		v_enrolment_cat := p_enrolment_cat;
  	END IF;
  	--------------------------------
  	-- Set correspondence category
  	--------------------------------
  	IF p_correspondence_cat IS NULL	THEN
  		-- Derive the correspondence category
  		v_correspondence_cat := Igs_Ad_Gen_005.ADMP_GET_DFLT_CCM(
  						p_admission_cat,
  						v_description);
  	ELSIF Igs_Ad_Val_Acai.admp_val_acai_cc(
  				p_admission_cat,
  				p_correspondence_cat,
  				v_message_name) = FALSE THEN
  		v_correspondence_cat := NULL;
  	ELSE
  		v_correspondence_cat := p_correspondence_cat;
  	END IF;
  	--------------------------------
  	-- Validate HECS payment option
  	--------------------------------
  	IF p_hecs_payment_option IS NOT NULL THEN
  		-- Validate HECS payment option
  		IF Igs_Ad_Val_Acai.admp_val_acai_hpo(
  				p_admission_cat,
  				p_hecs_payment_option,
  				v_message_name) = FALSE THEN
  			-- Set variable to indicate HECS payment option could not be determined
  			v_hecs_pmnt_option_found := FALSE;
  			v_hecs_message_name := v_message_name;
  			v_hecs_payment_option := NULL;
  		ELSE
  			v_hecs_payment_option := p_hecs_payment_option;
  		END IF;
  	ELSE
  		v_hecs_payment_option := NULL;
  	END IF;
  	--------------------------------------------------------------------------
  	-- Set admission COURSE application instance statuses for PENDING outcome
  	--------------------------------------------------------------------------
  	v_adm_doc_status 		:= Igs_Ad_Gen_009.ADMP_GET_SYS_ADS('SATISFIED');
  	v_adm_entry_qual_status		:= Igs_Ad_Gen_009.ADMP_GET_SYS_AEQS('QUALIFIED');
  	v_adm_pending_outcome_status	:= Igs_Ad_Gen_009.ADMP_GET_SYS_AOS('PENDING');
  	v_adm_cndtnl_offer_status	:= Igs_Ad_Gen_009.ADMP_GET_SYS_ACOS('NOT-APPLIC');
  	v_adm_offer_resp_status		:= Igs_Ad_Gen_009.ADMP_GET_SYS_AORS('NOT-APPLIC');
  	v_adm_offer_dfrmnt_status	:= Igs_Ad_Gen_009.ADMP_GET_SYS_AODS('NOT-APPLIC');
  	IF v_apcs_late_fee_ind = 'Y' THEN
  		v_late_adm_fee_status := IGS_AD_GEN_009.ADMP_GET_SYS_AFS('EXEMPT');
  	ELSE
  		v_late_adm_fee_status := IGS_AD_GEN_009.ADMP_GET_SYS_AFS('NOT-APPLIC');
  	END IF;
  	--------------------------------
  	-- Get the next sequence number
  	--------------------------------
  	OPEN c_nxt_acai_seq_num;
  	FETCH c_nxt_acai_seq_num INTO v_acai_sequence_number;
  	CLOSE c_nxt_acai_seq_num;
  	---------------------------------------------------
  	-- Validate the admission COURSE offering IGS_PS_UNIT set
  	---------------------------------------------------
  	IF Igs_Ad_Val_Acai.admp_val_acai_us (
  					p_unit_set_cd,
  					p_us_version_number,
  					p_course_cd,
  					p_crv_version_number,
  					p_acad_cal_type,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_admission_cat,
  					'N',
  					v_apcs_unit_set_ind,
  					v_message_name,
  					v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			p_return_type := v_return_type;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	--------------------------------------------------------------------------
  	-- Insert an admission COURSE application instance with PENDING outcome
  	--------------------------------------------------------------------------
    l_org_id := igs_ge_gen_003.get_org_id;
    Igs_Ad_Ps_Appl_Inst_Pkg.Insert_Row (
      					X_Mode                              => 'R',
      					X_RowId                             => lv_rowid,
      					X_Person_Id                         => p_Person_Id,
      					X_Admission_Appl_Number             => p_Admission_Appl_Number,
      					X_Nominated_Course_Cd               => p_course_cd,
      					X_Sequence_Number                   => v_acai_sequence_number,
      				      X_PREDICTED_GPA			      => NULL,
      				      X_ACADEMIC_INDEX		            => NULL,
      					X_Adm_Cal_Type                      => NULL,
      				      X_APP_FILE_LOCATION 		      => NULL,
      					X_Adm_Ci_Sequence_Number            => NULL,
      					X_Course_Cd                         => p_Course_Cd,
      				      X_APP_SOURCE_ID 		            => NULL,
      					X_Crv_Version_Number                => p_Crv_Version_Number,
      				      X_WAITLIST_RANK 		            => NULL,
      					X_Location_Cd                       => p_Location_Cd,
      				      X_ATTENT_OTHER_INST_CD 		      => NULL,
      					X_Attendance_Mode                   => p_Attendance_Mode,
      				      X_EDU_GOAL_PRIOR_ENROLL_ID 	      => NULL,
      					X_Attendance_Type                   => p_Attendance_Type,
      				      X_DECISION_MAKE_ID 		      => NULL,
      					X_Unit_Set_Cd                       => p_Unit_Set_Cd,
      				      X_DECISION_DATE 		            => NULL,
      				      X_ATTRIBUTE_CATEGORY 		      => NULL,
      				      X_ATTRIBUTE1 			      => NULL,
      				      X_ATTRIBUTE2 			      => NULL,
      				      X_ATTRIBUTE3 			      => NULL,
      				      X_ATTRIBUTE4 			      => NULL,
      				      X_ATTRIBUTE5 			      => NULL,
      				      X_ATTRIBUTE6 			      => NULL,
      				      X_ATTRIBUTE7 			      => NULL,
      				      X_ATTRIBUTE8 			      => NULL,
      				      X_ATTRIBUTE9 			      => NULL,
      				      X_ATTRIBUTE10 			      => NULL,
      				      X_ATTRIBUTE11 			      => NULL,
      				      X_ATTRIBUTE12 			      => NULL,
      				      X_ATTRIBUTE13 			      => NULL,
      				      X_ATTRIBUTE14 			      => NULL,
      				      X_ATTRIBUTE15 			      => NULL,
      				      X_ATTRIBUTE16 			      => NULL,
      				      X_ATTRIBUTE17 			      => NULL,
      				      X_ATTRIBUTE18 			      => NULL,
      				      X_ATTRIBUTE19 			      => NULL,
      				      X_ATTRIBUTE20 			      => NULL,
      				      X_DECISION_REASON_ID 		      => NULL,
      					X_Us_Version_Number                 => p_Us_Version_Number,
      				      X_DECISION_NOTES 		            => NULL,
      				      X_PENDING_REASON_ID 		      => NULL,
      					X_Preference_Number                 => p_Preference_Number,
      					X_Adm_Doc_Status                    => v_Adm_Doc_Status,
      					X_Adm_Entry_Qual_Status             => v_Adm_Entry_Qual_Status,
       					X_DEFICIENCY_IN_PREP 		      => NULL,
      					X_Late_Adm_Fee_Status               => v_Late_Adm_Fee_Status,
      				      X_SPL_CONSIDER_COMMENTS		      => NULL,
      				      X_APPLY_FOR_FINAID 		      => NULL,
      				      X_FINAID_APPLY_DATE 		      => NULL,
      					X_Adm_Outcome_Status                => v_adm_pending_outcome_status,
      					X_ADM_OTCM_STAT_AUTH_PER_ID         => NULL,
      					X_Adm_Outcome_Status_Auth_Dt        => NULL,
      					X_Adm_Outcome_Status_Reason         => NULL,
      					X_Offer_Dt                          => NULL,
      					X_Offer_Response_Dt                 => NULL,
      					X_Prpsd_Commencement_Dt             => NULL,
      					X_Adm_Cndtnl_Offer_Status           => v_adm_cndtnl_offer_status,
      					X_Cndtnl_Offer_Satisfied_Dt         => NULL,
      					X_CNDNL_OFR_MUST_BE_STSFD_IND       => 'N',
      					X_Adm_Offer_Resp_Status             => v_adm_offer_resp_status,
      					X_Actual_Response_Dt                => NULL,
      					X_Adm_Offer_Dfrmnt_Status           => v_adm_offer_dfrmnt_status,
      					X_Deferred_Adm_Cal_Type             => NULL,
      					X_Deferred_Adm_Ci_Sequence_Num      => NULL,
      					X_Deferred_Tracking_Id              => NULL,
      					X_Ass_Rank                          => NULL,
      					X_Secondary_Ass_Rank                => NULL,
      					X_INTR_ACCEPT_ADVICE_NUM    	      => NULL,
      					X_Ass_Tracking_Id                   => NULL,
      					X_Fee_Cat                           => v_Fee_Cat,
      					X_Hecs_Payment_Option               => v_Hecs_Payment_Option,
      					X_Expected_Completion_Yr            => NULL,
      					X_Expected_Completion_Perd          => NULL,
      					X_Correspondence_Cat                => v_Correspondence_Cat,
      					X_Enrolment_Cat                     => v_Enrolment_Cat,
      					X_Funding_Source                    => NULL,
      					X_Applicant_Acptnce_Cndtn           => NULL,
      					X_Cndtnl_Offer_Cndtn                => NULL,
      					X_ss_application_id                 => NULL,
      					X_ss_pwd	                        => NULL,
         		       		X_AUTHORIZED_DT                     => NULL,  -- BUG ENH NO : 1891835 Added this column in table
                          		X_AUTHORIZING_PERS_ID               => NULL,  -- BUG ENH NO : 1891835 Added this column in table
                                    X_IDX_CALC_DATE                     => NULL,
  				    X_Org_id			            => l_org_id,
                                    x_entry_status                      => NULL,  -- Enh Bug#1964478 added three parameters
                                    x_entry_level                       => NULL,  -- Enh Bug#1964478 added three parameters
                                    x_sch_apl_to_id                     => NULL,   -- Enh Bug#1964478 added three parameters
                                    X_FUT_ACAD_CAL_TYPE                          => NULL , -- Bug # 2217104
                                    X_FUT_ACAD_CI_SEQUENCE_NUMBER                => NULL ,-- Bug # 2217104
                                    X_FUT_ADM_CAL_TYPE                           => NULL , -- Bug # 2217104
                                    X_FUT_ADM_CI_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
                                    X_PREV_TERM_ADM_APPL_NUMBER                 => NULL , -- Bug # 2217104
                                    X_PREV_TERM_SEQUENCE_NUMBER                 => NULL , -- Bug # 2217104
                                    X_FUT_TERM_ADM_APPL_NUMBER                   => NULL , -- Bug # 2217104
                                    X_FUT_TERM_SEQUENCE_NUMBER                   => NULL , -- Bug # 2217104
				    X_DEF_ACAD_CAL_TYPE                             => NULL, -- Bug  2395510
				    X_DEF_ACAD_CI_SEQUENCE_NUM          => NULL,-- Bug  2395510
				    X_DEF_PREV_TERM_ADM_APPL_NUM  => NULL,-- Bug  2395510
				    X_DEF_PREV_APPL_SEQUENCE_NUM    => NULL,-- Bug  2395510
				    X_DEF_TERM_ADM_APPL_NUM               => NULL,-- Bug  2395510
				    X_DEF_APPL_SEQUENCE_NUM                 => NULL,-- Bug  2395510
				    X_ATTRIBUTE21 			      => NULL,
      				      X_ATTRIBUTE22 			      => NULL,
      				      X_ATTRIBUTE23 			      => NULL,
      				      X_ATTRIBUTE24 			      => NULL,
      				      X_ATTRIBUTE25 			      => NULL,
      				      X_ATTRIBUTE26 			      => NULL,
      				      X_ATTRIBUTE27 			      => NULL,
      				      X_ATTRIBUTE28 			      => NULL,
      				      X_ATTRIBUTE29 			      => NULL,
      				      X_ATTRIBUTE30 			      => NULL,
      				      X_ATTRIBUTE31 			      => NULL,
      				      X_ATTRIBUTE32 			      => NULL,
      				      X_ATTRIBUTE33 			      => NULL,
      				      X_ATTRIBUTE34 			      => NULL,
      				      X_ATTRIBUTE35 			      => NULL,
      				      X_ATTRIBUTE36 			      => NULL,
      				      X_ATTRIBUTE37 			      => NULL,
      				      X_ATTRIBUTE38 			      => NULL,
      				      X_ATTRIBUTE39 			      => NULL,
      				      X_ATTRIBUTE40 			      => NULL
                                   );

  	------------------------------------------------------------------------------
  	-- Set admission COURSE application instance statuses for OFFER outcome
  	------------------------------------------------------------------------------
  	v_offer_adm_outcome_status := Igs_Ad_Gen_009.ADMP_GET_SYS_AOS('OFFER');
  	v_new_adm_offer_resp_status := Igs_Ad_Gen_009.ADMP_GET_SYS_AORS('PENDING');
  	------------------------------------------------------------------------------
  	-- Validate that admission COURSE application instance is valid for an offer
  	------------------------------------------------------------------------------
  	IF Igs_Ad_Val_Acai_Status.admp_val_acai_aos(
  				p_person_id,
  				p_admission_appl_number,
  				p_course_cd,	-- (nominated COURSE code is the same as COURSE code)
  				v_acai_sequence_number,
  				p_course_cd,
  				p_crv_version_number,
  				p_location_cd,
  				p_attendance_mode,
  				p_attendance_type,
  				p_unit_set_cd,
  				p_us_version_number,
  				p_acad_cal_type,
  				p_acad_ci_sequence_number,
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				p_admission_cat,
  				v_s_admission_process_type,
  				p_appl_dt,
  				v_fee_cat,
  				v_correspondence_cat,
  				v_enrolment_cat,
  				v_offer_adm_outcome_status,
  				v_adm_pending_outcome_status,
  				v_adm_doc_status,
  				p_adm_fee_status,
  				v_late_adm_fee_status,
  				v_adm_cndtnl_offer_status,
  				v_adm_entry_qual_status,
  				v_new_adm_offer_resp_status,
  				v_adm_offer_resp_status,
  				NULL,		-- (outcome override authorisation date)
  				v_apcs_set_otcome_ind,
  				v_apcs_asses_cond_ind,
  				v_apcs_fee_cond_ind,
  				v_apcs_doc_cond_ind,
  				v_apcs_late_app_ind,
  				v_apcs_app_fee_ind,
  				v_apcs_multi_off_ind,
  				v_apcs_multi_off_restn_num,
  				v_apcs_pref_limit_ind,
  				v_apcs_unit_set_ind,
  				v_apcs_chkpencumb_ind,
  				v_apcs_chkcencumb_ind,
  				'FORM',		-- (want same validation as in form)
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		p_return_type := 'W';
  		RETURN FALSE;
  	END IF;
  	-------------------------------
  	-- Validate the offer date
  	-------------------------------
  	IF Igs_Ad_Val_Acai.admp_val_offer_dt(
  				p_offer_dt,
  				v_offer_adm_outcome_status,
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		p_return_type := 'W';
  		RETURN FALSE;
  	END IF;
  	-------------------------------
  	-- Set the offer response date
  	-------------------------------
  	IF p_offer_response_dt IS NULL THEN
  		-- Calculate the offer response date
  		v_offer_response_dt := Igs_Ad_Gen_007.ADMP_GET_RESP_DT(
  						p_course_cd,
  						p_crv_version_number,
  						p_acad_cal_type,
  						p_location_cd,
  						p_attendance_mode,
  						p_attendance_type,
  						p_admission_cat,
  						v_s_admission_process_type,
  						p_adm_cal_type,
  						p_adm_ci_sequence_number,
  						p_offer_dt);
  		IF v_offer_response_dt IS NULL THEN
			p_message_name := 'IGS_AD_INVALID_OFFER_RESPDATE';
  			p_return_type := 'W';
  			RETURN FALSE;
  		END IF;
  	ELSE
  		v_offer_response_dt := p_offer_response_dt;
  	END IF;
  	---------------------------------------------------
  	-- Validate the admission COURSE offering IGS_PS_UNIT set
  	---------------------------------------------------
  	IF Igs_Ad_Val_Acai.admp_val_acai_us (
  					p_unit_set_cd,
  					p_us_version_number,
  					p_course_cd,
  					p_crv_version_number,
  					p_acad_cal_type,
  					p_location_cd,
  					p_attendance_mode,
  					p_attendance_type,
  					p_admission_cat,
  					'Y',	--- offer ind
  					v_apcs_unit_set_ind,
  					v_message_name,
  					v_return_type) = FALSE THEN
  		IF NVL(v_return_type, '-1') = cst_error THEN
	  		p_message_name := v_message_name;
  			p_return_type := v_return_type;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	------------------------------------------------------------
  	-- Update admission COURSE application instance with OFFER
  	------------------------------------------------------------
  	BEGIN
  		OPEN c_upd_acai;
--  		FETCH c_upd_acai INTO v_check;
  		FETCH c_upd_acai INTO Rec_IGS_AD_PS_APPL_Inst;

	Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
		X_ROWID 				      	=> Rec_IGS_AD_PS_APPL_Inst.ROWID ,
		X_PERSON_ID 					=> Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
		X_ADMISSION_APPL_NUMBER 			=> Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
  		X_NOMINATED_COURSE_CD 				=> Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
  		X_SEQUENCE_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
  		X_PREDICTED_GPA 				      => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA ,
  		X_ACADEMIC_INDEX 			  	      => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
  		X_ADM_CAL_TYPE 					=> Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE ,
  		X_APP_FILE_LOCATION 				=> Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION ,
  		X_ADM_CI_SEQUENCE_NUMBER 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER ,
  		X_COURSE_CD 					=> Rec_IGS_AD_PS_APPL_Inst.COURSE_CD ,
  		X_APP_SOURCE_ID 				      => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID ,
  		X_CRV_VERSION_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER ,
		X_Waitlist_Rank   		            => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
		X_Waitlist_Status   		            => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
  		X_LOCATION_CD 					=> Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD ,
		X_Attent_Other_Inst_Cd            		=> Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
  		X_ATTENDANCE_MODE 				=> Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE ,
		X_Edu_Goal_Prior_Enroll_Id       		=> Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
  		X_ATTENDANCE_TYPE 				=> Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE ,
		X_Decision_Make_Id             		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
  		X_UNIT_SET_CD 					=> Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD ,
		X_Decision_Date                 		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
		X_Attribute_Category     		      => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
		X_Attribute1                        	=> Rec_IGS_AD_PS_APPL_Inst.Attribute1,
		X_Attribute2 		                  => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
		X_Attribute3            		      => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
		X_Attribute4              		      => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
		X_Attribute5                 	   		=> Rec_IGS_AD_PS_APPL_Inst.Attribute5,
		X_Attribute6                    	    	=> Rec_IGS_AD_PS_APPL_Inst.Attribute6,
		X_Attribute7          	              	=> Rec_IGS_AD_PS_APPL_Inst.Attribute7,
		X_Attribute8            	            => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
		X_Attribute9                    	      => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
		X_Attribute10    		                  => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
		X_Attribute11           	          	=> Rec_IGS_AD_PS_APPL_Inst.Attribute11,
		X_Attribute12                   	   	=> Rec_IGS_AD_PS_APPL_Inst.Attribute12,
		X_Attribute13                   		=> Rec_IGS_AD_PS_APPL_Inst.Attribute13,
		X_Attribute14   	        	            => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
		X_Attribute15           		      => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
		X_Attribute16  			            => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
		X_Attribute17                   	      => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
		X_Attribute18                    	 	=> Rec_IGS_AD_PS_APPL_Inst.Attribute18,
		X_Attribute19                   	    	=> Rec_IGS_AD_PS_APPL_Inst.Attribute19,
		X_Attribute20                    	 	=> Rec_IGS_AD_PS_APPL_Inst.Attribute20,
		X_Decision_Reason_Id              		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
  		X_US_VERSION_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER ,
		X_Decision_Notes	              		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
		X_Pending_Reason_Id              		=> Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
  		X_PREFERENCE_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER ,
  		X_ADM_DOC_STATUS 				      => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS ,
  		X_ADM_ENTRY_QUAL_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS ,
  		X_DEFICIENCY_IN_PREP 				=> Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP ,
  		X_LATE_ADM_FEE_STATUS 				=> Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS ,
            X_Spl_Consider_Comments 			=> Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
            X_Apply_For_Finaid                 		=> Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
            X_Finaid_Apply_Date                       => Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
  		X_ADM_OUTCOME_STATUS 				=> v_offer_adm_outcome_status,
  		X_ADM_OTCM_STAT_AUTH_PER_ID			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID ,
  		X_ADM_OUTCOME_STATUS_AUTH_DT 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT ,
  		X_ADM_OUTCOME_STATUS_REASON 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON ,
  		X_OFFER_DT 					      => p_offer_dt,
  		X_OFFER_RESPONSE_DT 				=> v_offer_response_dt,
  		X_PRPSD_COMMENCEMENT_DT 			=> Rec_IGS_AD_PS_APPL_Inst.Prpsd_Commencement_Dt,
  		X_ADM_CNDTNL_OFFER_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS ,
  		X_CNDTNL_OFFER_SATISFIED_DT 			=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT ,
  		X_CNDNL_OFR_MUST_BE_STSFD_IND 		=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND ,
  		X_ADM_OFFER_RESP_STATUS 			=> v_new_adm_offer_resp_status,
  		X_ACTUAL_RESPONSE_DT 				=> Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT ,
  		X_ADM_OFFER_DFRMNT_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS ,
  		X_DEFERRED_ADM_CAL_TYPE 			=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE ,
  		X_DEFERRED_ADM_CI_SEQUENCE_NUM 		=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
  		X_DEFERRED_TRACKING_ID 				=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID ,
  		X_ASS_RANK 					      => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK ,
  		X_SECONDARY_ASS_RANK 				=> Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK ,
  		X_INTR_ACCEPT_ADVICE_NUM 			=> Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
  		X_ASS_TRACKING_ID 				=> Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID ,
  		X_FEE_CAT 					      => Rec_IGS_AD_PS_APPL_Inst.FEE_CAT ,
  		X_HECS_PAYMENT_OPTION 				=> Rec_IGS_AD_PS_APPL_Inst.HECS_PAYMENT_OPTION ,
  		X_EXPECTED_COMPLETION_YR 			=> Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR ,
  		X_EXPECTED_COMPLETION_PERD			=> Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD ,
  		X_CORRESPONDENCE_CAT 				=> Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT ,
  		X_ENROLMENT_CAT 				      => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT ,
  		X_FUNDING_SOURCE 				      => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE ,
  		X_APPLICANT_ACPTNCE_CNDTN 			=> Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN ,
  		X_CNDTNL_OFFER_CNDTN 				=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN ,
  		X_SS_APPLICATION_ID  				=> Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID ,
  		X_SS_PWD        				      => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
    		X_AUTHORIZED_DT                           => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,  -- BUG ENH NO : 1891835 Added this column in table
  		X_AUTHORIZING_PERS_ID                     => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,  -- BUG ENH NO : 1891835 Added this column in table
  		X_IDX_CALC_DATE                           => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
  		X_MODE  					      => 'R',
            X_ENTRY_STATUS                            => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,  -- Enh Bug#1964478 added three parameters
            X_ENTRY_LEVEL                             => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,   -- Enh Bug#1964478 added three parameters
            X_SCH_APL_TO_ID                           => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID,  -- Enh Bug#1964478 added three parameters
	    X_Attribute21                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                X_FUT_ACAD_CAL_TYPE                          => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                X_FUT_ACAD_CI_SEQUENCE_NUMBER                => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                X_FUT_ADM_CAL_TYPE                           => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                X_FUT_ADM_CI_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                X_PREV_TERM_ADM_APPL_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_PREV_TERM_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_FUT_TERM_ADM_APPL_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_FUT_TERM_SEQUENCE_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_DEF_ACAD_CAL_TYPE                                        => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                X_DEF_ACAD_CI_SEQUENCE_NUM                   => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                X_DEF_PREV_TERM_ADM_APPL_NUM           => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_PREV_APPL_SEQUENCE_NUM              => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                X_DEF_TERM_ADM_APPL_NUM                        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_APPL_SEQUENCE_NUM                           => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
                X_Attribute22                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                X_Attribute23                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                X_Attribute24                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                X_Attribute25                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                X_Attribute26                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                X_Attribute27                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                X_Attribute28                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                X_Attribute29                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                X_Attribute30                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                X_Attribute31                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                X_Attribute32                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                X_Attribute33                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                X_Attribute34                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                X_Attribute35                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                X_Attribute36                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                X_Attribute37                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                X_Attribute38                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                X_Attribute39                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                X_Attribute40                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
		X_APPL_INST_STATUS				=> Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
		x_ais_reason					=> Rec_IGS_AD_PS_APPL_Inst.ais_reason,
		x_decline_ofr_reason				=> Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason

  		);

  		CLOSE c_upd_acai;
  	EXCEPTION
  		-- check for locking on update, although this should never occur
  		WHEN e_resource_busy THEN
			p_message_name := 'IGS_AD_APPL_NOTSET_LOCKING';
  			p_return_type := 'W';
  			RETURN FALSE;
  	END;
  	--------------------------
  	-- Insert outcome letter
  	--------------------------
  	IF p_insert_outcome_ind = 'Y'  AND
  		v_apcs_outcome_lt_ind = 'Y' THEN
  		-- Insert offer letter
  		IF Igs_Ad_Gen_010.ADMP_INS_AAL(
  				p_person_id,
  				p_admission_appl_number,
  				'OUTCOME-LT',
  				p_admission_cat,
  				v_s_admission_process_type,
  				v_message_name) = FALSE THEN
  			-- Set variable to indicate that the letter could not be inserted
  			v_offer_letter_ins := FALSE;
 			IF v_message_name = 'IGS_AD_UNISSUED_LETTER_EXISTS' THEN
  				v_outcome_message_name := 'IGS_PR_OUTCOMELETTER_NOTCREAT';
  			ELSE
  				v_outcome_message_name := v_message_name;
  			END IF;
  		END IF;
  	END IF;
  	------------------------------
  	-- Pre-enrol admission COURSE
  	------------------------------
  	IF p_pre_enrol_ind = 'Y' AND
  		v_apcs_pre_enrol_ind = 'Y' THEN
  		-- Pre-enrol admission COURSE application instance
      IF igs_ad_upd_initialise.perform_pre_enrol(
               p_person_id,
               p_admission_appl_number,
               p_course_cd,
               v_acai_sequence_number,
               'N',                     -- Confirm course indicator.
               'N',                     -- Perform eligibility check indicator.
               v_message_name) = FALSE THEN
        -- Set variable to indicate pre-enrolment could not be done
        v_pre_enr_done := FALSE;
        v_pre_enrol_message_name := v_message_name;
      ELSE
        v_pre_enrol_message_name := v_message_name;
      END IF;
  	END IF;

    IF v_hecs_pmnt_option_found = FALSE THEN
  		IF v_offer_letter_ins = FALSE THEN
  			IF v_pre_enr_done = FALSE THEN
				p_message_name := 'IGS_AD_HECS_PYMT_PREENRL';
  			ELSE
				p_message_name := 'IGS_AD_HECS_PYMT_CORTYPE';
  			END IF;
  		ELSE
  			IF v_pre_enr_done = FALSE THEN
				p_message_name := 'IGS_AD_HECS_PYMT_PRE_ENRL';
  			ELSE
  				-- Outcome and pre-enrolment were successful
  				p_message_name := v_hecs_message_name;
  			END IF;
  		END IF;
  		p_return_type := 'W';
  		RETURN FALSE;
  	END IF;
  	IF v_offer_letter_ins = FALSE THEN
 		IF v_pre_enr_done = FALSE THEN
			p_message_name := 'IGS_AD_OFRLETTER_CORTYPE_ENR';
  		ELSE
  			p_message_name := v_outcome_message_name;
  		END IF;
  		p_return_type := 'W';
  		RETURN FALSE;
  	END IF;
   	IF v_pre_enrol_message_name IS NOT NULL AND
  			v_pre_enrol_message_name > 0 THEN
  		p_message_name := v_pre_enrol_message_name;
  		p_return_type := 'W';
  		RETURN FALSE;
  	END IF;
  	p_message_name := NULL;
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_tac_acai');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_tac_acai;
  --
  -- Inserts TAC details to form an admission COURSE
  FUNCTION admp_ins_tac_course(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_tac_course_cd IN VARCHAR2 ,
  p_preference_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_offer_dt IN DATE ,
  p_basis_for_admission_type IN VARCHAR2 ,
  p_admission_cd IN VARCHAR2 ,
  p_fee_paying_appl_ind IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_insert_outcome_letter_ind IN VARCHAR2,
  p_pre_enrol_ind IN VARCHAR2 ,
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_tac_course_match_ind OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	-- admp_ins_tac_course
  	-- This process insert an admission COURSE application from a
  	-- TAC offer load process.
  DECLARE
  	e_resource_busy			EXCEPTION;
  	PRAGMA EXCEPTION_INIT (e_resource_busy, -54);
  	v_message_name VARCHAR2(30);
  	v_return_type			VARCHAR2(127);
  	v_admission_cat			IGS_AD_CAT.admission_cat%TYPE DEFAULT NULL;
  	v_course_cd             	IGS_PS_ENT_PT_REF_CD.course_cd%TYPE;
  	v_version_number        	IGS_PS_ENT_PT_REF_CD.version_number%TYPE;
  	v_cal_type              	IGS_PS_ENT_PT_REF_CD.cal_type%TYPE;
  	v_location_cd           	IGS_PS_ENT_PT_REF_CD.location_cd%TYPE;
  	v_attendance_mode       	IGS_PS_ENT_PT_REF_CD.attendance_mode%TYPE;
  	v_attendance_type       	IGS_PS_ENT_PT_REF_CD.attendance_type%TYPE;
  	v_unit_set_cd			VARCHAR2(255);
  	v_us_version_number		NUMBER(6);
  	v_coo_id                	IGS_PS_ENT_PT_REF_CD.coo_id%TYPE;
  	v_ref_cd_type           	IGS_GE_REF_CD_TYPE.reference_cd_type%TYPE;
  	v_acai_admission_appl_number
  					IGS_AD_PS_APPL_INST.admission_appl_number%TYPE;
  	v_acai_nominated_course_cd	IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE;
  	v_acai_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE;
  	v_acai_hecs_payment_option	IGS_AD_PS_APPL_INST.hecs_payment_option%TYPE;
  	v_hecs_payment_option		IGS_FI_HECS_PAY_OPTN.hecs_payment_option%TYPE;
  	v_adm_appl_status		IGS_AD_APPL_STAT.adm_appl_status%TYPE;
  	v_adm_fee_status		IGS_AD_FEE_STAT.adm_fee_status%TYPE;
  	v_admission_appl_number		IGS_AD_APPL.admission_appl_number%TYPE;
  	v_cnt_aa_acai_rec		NUMBER(2);
  	CURSOR c_aa_acai (
  			cp_course_cd	IGS_AD_PS_APPL_INST.course_cd%TYPE) IS
  		SELECT	COUNT(*),
  			acai.admission_appl_number,
  			acai.nominated_course_cd,
  			acai.sequence_number,
  			acai.hecs_payment_option
  		FROM
  			IGS_AD_APPL aa,
  			IGS_AD_PS_APPL_INST acai
  		WHERE
  			aa.person_id			= acai.person_id	AND
  			aa.admission_appl_number	= acai.admission_appl_number AND
  			acai.person_id			= p_person_id		AND
  			acai.nominated_course_cd	= cp_course_cd		AND
  			aa.acad_cal_type		= p_acad_cal_type	AND
  			aa.acad_ci_sequence_number	= p_acad_ci_sequence_number AND
  			aa.adm_cal_type			= p_adm_cal_type 	AND
  			aa.adm_ci_sequence_number	= p_adm_ci_sequence_number AND
  			aa.tac_appl_ind 		= 'Y'
  		GROUP BY
  			acai.admission_appl_number,
  			acai.nominated_course_cd,
  			acai.sequence_number,
  			acai.hecs_payment_option;
  	CURSOR c_upd_acai (
  			cp_admission_appl_number	IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
  			cp_nominated_course_cd	IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
  			cp_sequence_number		IGS_AD_PS_APPL_INST.sequence_number%TYPE) IS

		SELECT	ROWID, acai.*
  		FROM	IGS_AD_PS_APPL_INST acai
  		WHERE
  			acai.person_id				= p_person_id AND
  			acai.admission_appl_number	= cp_admission_appl_number AND
  			acai.nominated_course_cd	= cp_nominated_course_cd AND
  			acai.sequence_number		= cp_sequence_number
  		FOR UPDATE OF hecs_payment_option NOWAIT;

	 Rec_IGS_AD_PS_APPL_Inst		c_upd_acai%ROWTYPE;

  BEGIN
           /*
	  ||  Change History :
	  ||  Who             When            What
          ||  samaresh      02-DEC-2001     Bug # 2097333 : Impact of addition of the waitlist_status field to igs_ad_ps_appl_inst_all
	  ||  rrengara      26-JUL-2001     Bug Enh No: 1891835 : For the DLD Process Student Response to Offer. Added two columns in TBH
	  ||  (reverse chronological order - newest change first)
        */

  	p_message_name := NULL;
  	----------------------------------
  	-- Validate all input parameters
  	----------------------------------
  	p_tac_course_match_ind := 'N';
  	IF		p_acad_cal_type			IS NULL OR
  			p_acad_ci_sequence_number	IS NULL OR
  			p_adm_cal_type			IS NULL OR
  			p_adm_ci_sequence_number	IS NULL OR
  			p_person_id			IS NULL OR
  			p_tac_course_cd			IS NULL OR
  			p_appl_dt			IS NULL OR
  			p_offer_dt			IS NULL OR
  			p_fee_paying_appl_ind		IS NULL OR
  			p_insert_outcome_letter_ind	IS NULL OR
  			p_pre_enrol_ind 		IS NULL 	THEN
		p_message_name := 'IGS_AD_PARAMETERS_NOT_SUFFICI';
  		p_return_type := 'E';
  		RETURN FALSE;
  	END IF;
  	IF p_admission_cat IS NOT NULL	THEN
  		v_admission_cat := p_admission_cat;
  	END IF;
  	---------------------------------------------------------------
  	-- We need to convert the TAC COURSE code to a Callista code.
  	---------------------------------------------------------------
  	IF Igs_Ad_Gen_010.ADMP_GET_TAC_CEPRC(
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				p_acad_cal_type,
  				p_tac_course_cd,
  				v_admission_cat,	-- IN/OUT
  				v_course_cd, 		-- OUT NOCOPY
  				v_version_number,	-- OUT NOCOPY
  				v_cal_type,		-- OUT NOCOPY
  				v_location_cd,		-- OUT NOCOPY
  				v_attendance_mode,	-- OUT NOCOPY
  				v_attendance_type,	-- OUT NOCOPY
  				v_unit_set_cd,		-- OUT NOCOPY
  				v_us_version_number,	-- OUT NOCOPY
  				v_coo_id,		-- OUT NOCOPY
  				v_ref_cd_type,		-- OUT NOCOPY
  				v_message_name) = FALSE THEN
  		IF v_message_name <> 'IGS_GE_INVALID_VALUE' THEN
  			-- no record found to match TAC IGS_PS_COURSE
  			p_tac_course_match_ind  := 'Y';
  			p_course_cd 		:= v_course_cd;
  		END IF;
  		p_message_name := v_message_name;
  		p_return_type := 'E';
  		RETURN FALSE;
  	ELSE
  		p_tac_course_match_ind 	:= 'Y';
  		p_course_cd		:= v_course_cd;
  	END IF;
  	-------------------------------------------------------------------------------
  	-- Validate that a matching admission COURSE has not already been inserted for
  	-- this IGS_PE_PERSON via the TAC process in this admission period (this may be a
  	-- result of different payment options)
  	-------------------------------------------------------------------------------
  	OPEN c_aa_acai (v_course_cd);
  	FETCH c_aa_acai INTO
  			v_cnt_aa_acai_rec,
  			v_acai_admission_appl_number,
  			v_acai_nominated_course_cd,
  			v_acai_sequence_number,
  			v_acai_hecs_payment_option;
  	IF (c_aa_acai%FOUND) THEN
  		CLOSE c_aa_acai;
  		IF v_cnt_aa_acai_rec > 1 THEN
  			-- Something is wrong!! Offer should not be made to same IGS_PS_COURSE twice.
			p_message_name := 'IGS_AD_INVALID_APPLICANT';
  			p_return_type := 'E';
  			RETURN FALSE;
  		END IF;
  		IF v_acai_hecs_payment_option IS NOT NULL AND
  			((v_ref_cd_type = 'OTHER' AND p_fee_paying_appl_ind = 'U') OR
  			  p_fee_paying_appl_ind = 'N') THEN
  			-- Update existing HECS payment option, this should only be specified
  			-- when forcing payment with an offer.
  			BEGIN
  				OPEN c_upd_acai (
  						v_acai_admission_appl_number,
  						v_acai_nominated_course_cd,
  						v_acai_sequence_number);
--  				FETCH c_upd_acai INTO v_hecs_payment_option;
  				FETCH c_upd_acai INTO Rec_IGS_AD_PS_APPL_Inst;

  				IF (c_upd_acai%FOUND) THEN

	Igs_Ad_Ps_Appl_Inst_Pkg.UPDATE_ROW (
		X_ROWID 				  	      => Rec_IGS_AD_PS_APPL_Inst.ROWID ,
		X_PERSON_ID 					=> Rec_IGS_AD_PS_APPL_Inst.PERSON_ID ,
		X_ADMISSION_APPL_NUMBER 			=> Rec_IGS_AD_PS_APPL_Inst.ADMISSION_APPL_NUMBER ,
  		X_NOMINATED_COURSE_CD 				=> Rec_IGS_AD_PS_APPL_Inst.NOMINATED_COURSE_CD ,
  		X_SEQUENCE_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.SEQUENCE_NUMBER ,
  		X_PREDICTED_GPA 				      => Rec_IGS_AD_PS_APPL_Inst.PREDICTED_GPA ,
  		X_ACADEMIC_INDEX 				      => Rec_IGS_AD_PS_APPL_Inst.ACADEMIC_INDEX,
  		X_ADM_CAL_TYPE 					=> Rec_IGS_AD_PS_APPL_Inst.ADM_CAL_TYPE ,
  		X_APP_FILE_LOCATION 				=> Rec_IGS_AD_PS_APPL_Inst.APP_FILE_LOCATION ,
  		X_ADM_CI_SEQUENCE_NUMBER 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_CI_SEQUENCE_NUMBER ,
  		X_COURSE_CD 					=> Rec_IGS_AD_PS_APPL_Inst.COURSE_CD ,
  		X_APP_SOURCE_ID 				      => Rec_IGS_AD_PS_APPL_Inst.APP_SOURCE_ID ,
  		X_CRV_VERSION_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.CRV_VERSION_NUMBER ,
		X_Waitlist_Rank   		            => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Rank,
		X_Waitlist_Status   		            => Rec_IGS_AD_PS_APPL_Inst.Waitlist_Status,
  		X_LOCATION_CD 					=> Rec_IGS_AD_PS_APPL_Inst.LOCATION_CD ,
		X_Attent_Other_Inst_Cd            		=> Rec_IGS_AD_PS_APPL_Inst.Attent_Other_Inst_Cd,
  		X_ATTENDANCE_MODE 				=> Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_MODE ,
		X_Edu_Goal_Prior_Enroll_Id       		=> Rec_IGS_AD_PS_APPL_Inst.Edu_Goal_Prior_Enroll_Id,
  		X_ATTENDANCE_TYPE 				=> Rec_IGS_AD_PS_APPL_Inst.ATTENDANCE_TYPE ,
		X_Decision_Make_Id             		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Make_Id,
  		X_UNIT_SET_CD 					=> Rec_IGS_AD_PS_APPL_Inst.UNIT_SET_CD ,
		X_Decision_Date                 		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Date,
		X_Attribute_Category     		      => Rec_IGS_AD_PS_APPL_Inst.Attribute_Category,
		X_Attribute1                        	=> Rec_IGS_AD_PS_APPL_Inst.Attribute1,
		X_Attribute2 		                  => Rec_IGS_AD_PS_APPL_Inst.Attribute2,
		X_Attribute3            		      => Rec_IGS_AD_PS_APPL_Inst.Attribute3,
		X_Attribute4              		      => Rec_IGS_AD_PS_APPL_Inst.Attribute4,
		X_Attribute5                 	   		=> Rec_IGS_AD_PS_APPL_Inst.Attribute5,
		X_Attribute6                    	    	=> Rec_IGS_AD_PS_APPL_Inst.Attribute6,
		X_Attribute7          	              	=> Rec_IGS_AD_PS_APPL_Inst.Attribute7,
		X_Attribute8            	            => Rec_IGS_AD_PS_APPL_Inst.Attribute8,
		X_Attribute9                    	      => Rec_IGS_AD_PS_APPL_Inst.Attribute9,
		X_Attribute10    		                  => Rec_IGS_AD_PS_APPL_Inst.Attribute10,
		X_Attribute11           	          	=> Rec_IGS_AD_PS_APPL_Inst.Attribute11,
		X_Attribute12                   	   	=> Rec_IGS_AD_PS_APPL_Inst.Attribute12,
		X_Attribute13                   		=> Rec_IGS_AD_PS_APPL_Inst.Attribute13,
		X_Attribute14   	        	            => Rec_IGS_AD_PS_APPL_Inst.Attribute14,
		X_Attribute15           		      => Rec_IGS_AD_PS_APPL_Inst.Attribute15,
		X_Attribute16  			            => Rec_IGS_AD_PS_APPL_Inst.Attribute16,
		X_Attribute17                   	      => Rec_IGS_AD_PS_APPL_Inst.Attribute17,
		X_Attribute18                    	 	=> Rec_IGS_AD_PS_APPL_Inst.Attribute18,
		X_Attribute19                   	    	=> Rec_IGS_AD_PS_APPL_Inst.Attribute19,
		X_Attribute20                    	 	=> Rec_IGS_AD_PS_APPL_Inst.Attribute20,
		X_Decision_Reason_Id              		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Reason_Id,
  		X_US_VERSION_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.US_VERSION_NUMBER ,
		X_Decision_Notes	              		=> Rec_IGS_AD_PS_APPL_Inst.Decision_Notes,
		X_Pending_Reason_Id              		=> Rec_IGS_AD_PS_APPL_Inst.Pending_Reason_Id,
  		X_PREFERENCE_NUMBER 				=> Rec_IGS_AD_PS_APPL_Inst.PREFERENCE_NUMBER ,
  		X_ADM_DOC_STATUS 				      => Rec_IGS_AD_PS_APPL_Inst.ADM_DOC_STATUS ,
  		X_ADM_ENTRY_QUAL_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_ENTRY_QUAL_STATUS ,
  		X_DEFICIENCY_IN_PREP 				=> Rec_IGS_AD_PS_APPL_Inst.DEFICIENCY_IN_PREP ,
  		X_LATE_ADM_FEE_STATUS 				=> Rec_IGS_AD_PS_APPL_Inst.LATE_ADM_FEE_STATUS ,
            X_Spl_Consider_Comments 			=> Rec_IGS_AD_PS_APPL_Inst.Spl_Consider_Comments,
            X_Apply_For_Finaid                 	      => Rec_IGS_AD_PS_APPL_Inst.Apply_For_Finaid,
            X_Finaid_Apply_Date                 	=> Rec_IGS_AD_PS_APPL_Inst.Finaid_Apply_Date,
  		X_ADM_OUTCOME_STATUS 				=> Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS ,
  		X_ADM_OTCM_STAT_AUTH_PER_ID			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OTCM_STATUS_AUTH_PERSON_ID ,
  		X_ADM_OUTCOME_STATUS_AUTH_DT 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_AUTH_DT ,
  		X_ADM_OUTCOME_STATUS_REASON 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OUTCOME_STATUS_REASON ,
  		X_OFFER_DT 				      	=> Rec_IGS_AD_PS_APPL_Inst.OFFER_DT ,
  		X_OFFER_RESPONSE_DT 				=> Rec_IGS_AD_PS_APPL_Inst.OFFER_RESPONSE_DT ,
  		X_PRPSD_COMMENCEMENT_DT 			=> Rec_IGS_AD_PS_APPL_Inst.PRPSD_COMMENCEMENT_DT ,
  		X_ADM_CNDTNL_OFFER_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_CNDTNL_OFFER_STATUS ,
  		X_CNDTNL_OFFER_SATISFIED_DT 			=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_SATISFIED_DT ,
  		X_CNDNL_OFR_MUST_BE_STSFD_IND 		=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_MUST_BE_STSFD_IND ,
  		X_ADM_OFFER_RESP_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_RESP_STATUS ,
  		X_ACTUAL_RESPONSE_DT 				=> Rec_IGS_AD_PS_APPL_Inst.ACTUAL_RESPONSE_DT ,
  		X_ADM_OFFER_DFRMNT_STATUS 			=> Rec_IGS_AD_PS_APPL_Inst.ADM_OFFER_DFRMNT_STATUS ,
  		X_DEFERRED_ADM_CAL_TYPE 			=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CAL_TYPE ,
  		X_DEFERRED_ADM_CI_SEQUENCE_NUM 		=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_ADM_CI_SEQUENCE_NUM  ,
  		X_DEFERRED_TRACKING_ID 				=> Rec_IGS_AD_PS_APPL_Inst.DEFERRED_TRACKING_ID ,
  		X_ASS_RANK 					      => Rec_IGS_AD_PS_APPL_Inst.ASS_RANK ,
  		X_SECONDARY_ASS_RANK 				=> Rec_IGS_AD_PS_APPL_Inst.SECONDARY_ASS_RANK ,
  		X_INTR_ACCEPT_ADVICE_NUM 			=> Rec_IGS_AD_PS_APPL_Inst.INTRNTNL_ACCEPTANCE_ADVICE_NUM  ,
  		X_ASS_TRACKING_ID 				=> Rec_IGS_AD_PS_APPL_Inst.ASS_TRACKING_ID ,
  		X_FEE_CAT 				      	=> Rec_IGS_AD_PS_APPL_Inst.FEE_CAT ,
  		X_HECS_PAYMENT_OPTION 				=> NULL,
  		X_EXPECTED_COMPLETION_YR 			=> Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_YR ,
  		X_EXPECTED_COMPLETION_PERD			=> Rec_IGS_AD_PS_APPL_Inst.EXPECTED_COMPLETION_PERD ,
  		X_CORRESPONDENCE_CAT 				=> Rec_IGS_AD_PS_APPL_Inst.CORRESPONDENCE_CAT ,
  		X_ENROLMENT_CAT 				      => Rec_IGS_AD_PS_APPL_Inst.ENROLMENT_CAT ,
  		X_FUNDING_SOURCE 				      => Rec_IGS_AD_PS_APPL_Inst.FUNDING_SOURCE ,
  		X_APPLICANT_ACPTNCE_CNDTN 			=> Rec_IGS_AD_PS_APPL_Inst.APPLICANT_ACPTNCE_CNDTN ,
  		X_CNDTNL_OFFER_CNDTN 				=> Rec_IGS_AD_PS_APPL_Inst.CNDTNL_OFFER_CNDTN ,
            X_SS_APPLICATION_ID                       => Rec_IGS_AD_PS_APPL_Inst.SS_APPLICATION_ID ,
            X_SS_PWD                                  => Rec_IGS_AD_PS_APPL_Inst.SS_PWD,
   		X_AUTHORIZED_DT                           => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZED_DT,  -- BUG ENH NO : 1891835 Added this column in table
  		X_AUTHORIZING_PERS_ID                     => Rec_IGS_AD_PS_APPL_Inst.AUTHORIZING_PERS_ID,  -- BUG ENH NO : 1891835 Added this column in table
  		X_IDX_CALC_DATE                           => Rec_IGS_AD_PS_APPL_Inst.IDX_CALC_DATE,
  		X_MODE  					      => 'R',
            X_ENTRY_STATUS                            => Rec_IGS_AD_PS_APPL_Inst.ENTRY_STATUS,  -- Enh Bug#1964478 added three parameters
            X_ENTRY_LEVEL                             => Rec_IGS_AD_PS_APPL_Inst.ENTRY_LEVEL,   -- Enh Bug#1964478 added three parameters
            X_SCH_APL_TO_ID                           => Rec_IGS_AD_PS_APPL_Inst.SCH_APL_TO_ID,  -- Enh Bug#1964478 added three parameters
                X_FUT_ACAD_CAL_TYPE                          => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CAL_TYPE, -- Bug # 2217104
                X_FUT_ACAD_CI_SEQUENCE_NUMBER                => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ACAD_CI_SEQUENCE_NUMBER,-- Bug # 2217104
                X_FUT_ADM_CAL_TYPE                           => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CAL_TYPE, -- Bug # 2217104
                X_FUT_ADM_CI_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.FUTURE_ADM_CI_SEQUENCE_NUMBER, -- Bug # 2217104
                X_PREV_TERM_ADM_APPL_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_PREV_TERM_SEQUENCE_NUMBER                 => Rec_IGS_AD_PS_APPL_Inst.PREVIOUS_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_FUT_TERM_ADM_APPL_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_ADM_APPL_NUMBER, -- Bug # 2217104
                X_FUT_TERM_SEQUENCE_NUMBER                   => Rec_IGS_AD_PS_APPL_Inst.FUTURE_TERM_SEQUENCE_NUMBER, -- Bug # 2217104
                X_DEF_ACAD_CAL_TYPE                                        => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CAL_TYPE, --Bug 2395510
                X_DEF_ACAD_CI_SEQUENCE_NUM                   => Rec_IGS_AD_PS_APPL_Inst.DEF_ACAD_CI_SEQUENCE_NUM, --Bug 2395510
                X_DEF_PREV_TERM_ADM_APPL_NUM           => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_PREV_APPL_SEQUENCE_NUM              => Rec_IGS_AD_PS_APPL_Inst.DEF_PREV_APPL_SEQUENCE_NUM,--Bug 2395510
                X_DEF_TERM_ADM_APPL_NUM                        => Rec_IGS_AD_PS_APPL_Inst.DEF_TERM_ADM_APPL_NUM,--Bug 2395510
                X_DEF_APPL_SEQUENCE_NUM                           => Rec_IGS_AD_PS_APPL_Inst.DEF_APPL_SEQUENCE_NUM,--Bug 2395510
	    X_Attribute21                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute21,
                X_Attribute22                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute22,
                X_Attribute23                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute23,
                X_Attribute24                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute24,
                X_Attribute25                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute25,
                X_Attribute26                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute26,
                X_Attribute27                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute27,
                X_Attribute28                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute28,
                X_Attribute29                                    => Rec_IGS_AD_PS_APPL_Inst.Attribute29,
                X_Attribute30                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute30,
                X_Attribute31                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute31,
                X_Attribute32                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute32,
                X_Attribute33                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute33,
                X_Attribute34                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute34,
                X_Attribute35                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute35,
                X_Attribute36                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute36,
                X_Attribute37                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute37,
                X_Attribute38                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute38,
                X_Attribute39                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute39,
                X_Attribute40                                   => Rec_IGS_AD_PS_APPL_Inst.Attribute40,
		X_APPL_INST_STATUS				=> Rec_IGS_AD_PS_APPL_Inst.appl_inst_status,
		x_ais_reason					=> Rec_IGS_AD_PS_APPL_Inst.ais_reason,
		x_decline_ofr_reason				=> Rec_IGS_AD_PS_APPL_Inst.decline_ofr_reason
  		);

  				END IF;
  				CLOSE c_upd_acai;
  			EXCEPTION
  				WHEN e_resource_busy THEN
					p_message_name := 'IGS_AD_HECS_PAYMENT_NOT_RESET';
  					p_return_type := 'W';
  					RETURN FALSE;
  			END;
  			-- Warn that this applicant has been made more
  			--  than one offer with different payment options
			p_message_name := 'IGS_AD_APPL_MADE_INVALIDOFFER';
  			p_return_type := 'W';
  			RETURN FALSE;
  		ELSIF v_acai_hecs_payment_option IS  NULL AND
  			 ((v_ref_cd_type = 'OTHER' AND p_fee_paying_appl_ind = 'U') OR
  		          	p_fee_paying_appl_ind = 'Y') THEN
  			-- Warn that this applicant has been made more
  			--  than one offer with different payment options
			p_message_name := 'IGS_AD_APPL_MADE_INVALIDOFFER';
  			p_return_type := 'W';
  			RETURN FALSE;
  		ELSE
  			-- Something is wrong!! Offer should not be made to same IGS_PS_COURSE twice.
			p_message_name := 'IGS_AD_INVALID_APPLICANT';
  			p_return_type := 'E';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	CLOSE c_aa_acai;
  	----------------------------------
  	-- Insert admission application
  	----------------------------------
  	SAVEPOINT sp_save_point1;
  	v_adm_appl_status := Igs_Ad_Gen_008.ADMP_GET_SYS_AAS(
  					'RECEIVED');
  	v_adm_fee_status := Igs_Ad_Gen_009.ADMP_GET_SYS_AFS(
  					'NOT-APPLIC');
  	IF Igs_Ad_Prc_Tac_Offer.admp_ins_adm_appl(
  				p_person_id,
  				p_appl_dt,
  				p_acad_cal_type,
  				p_acad_ci_sequence_number,
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				v_admission_cat,
  				'COURSE',
  				v_adm_appl_status,
  				v_adm_fee_status,		-- IN OUT NOCOPY
  				'Y', 				-- (TAC application indicator)
  				v_admission_appl_number,	-- OUT NOCOPY
  				v_message_name,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null,
                                null) = FALSE	THEN
  		ROLLBACK TO sp_save_point1;
  		p_message_name := v_message_name;
  		p_return_type := 'E';
  		RETURN FALSE;
  	END IF;
  	----------------------------------------
  	-- Insert admission  COURSE application
  	----------------------------------------
  	IF Igs_Ad_Prc_Tac_Offer.admp_ins_adm_crs_app(
  				p_person_id,
  				v_admission_appl_number,
  				v_course_cd,
  				p_basis_for_admission_type,
  				p_admission_cd,
  				'N', 	-- (request for reconsideration indicator)
  				'N',	-- (request for advanced standing indicator)
  				v_message_name) = FALSE	THEN
  		ROLLBACK TO sp_save_point1;
  		p_message_name := v_message_name;
  		p_return_type := 'E';
  		RETURN FALSE;
  	END IF;
  	--------------------------------------------------
  	-- Determine if HECS payment option should be set
  	--------------------------------------------------
  	IF (	p_fee_paying_appl_ind = 'Y' OR
  		p_fee_paying_appl_ind  = 'U' AND v_ref_cd_type = 'OTHER')	THEN
  		v_hecs_payment_option := p_hecs_payment_option;
  	ELSE
  		v_hecs_payment_option := NULL;
  	END IF;
  	-- Insert admission  COURSE application instance
  	IF Igs_Ad_Prc_Tac_Offer.admp_ins_tac_acai (
  				p_person_id,
  				v_admission_appl_number,
  				p_acad_cal_type,
  				p_acad_ci_sequence_number,
  				p_adm_cal_type,
  				p_adm_ci_sequence_number,
  				v_admission_cat,
  				p_appl_dt,
  				v_adm_fee_status,
  				p_preference_number,
  				SYSDATE, 	-- offer date
  				NULL, 		-- offer response date
  				v_course_cd,
  				v_version_number,
  				v_location_cd,
  				v_attendance_mode,
  				v_attendance_type,
  				v_unit_set_cd,
  				v_us_version_number,
  				p_fee_cat,
  				v_hecs_payment_option,
  				p_correspondence_cat,
  				p_enrolment_cat,
  				p_insert_outcome_letter_ind,
  				p_pre_enrol_ind,
  				v_return_type,
  				v_message_name) = FALSE THEN
  		IF v_return_type = 'E' THEN
  			ROLLBACK TO sp_save_point1;
  		END IF;
  		p_message_name := v_message_name;
  		p_return_type := v_return_type;
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  EXCEPTION
  	WHEN OTHERS THEN
  		IF (c_aa_acai%ISOPEN) THEN
  			CLOSE c_aa_acai;
  		END IF;
  		IF (c_upd_acai%ISOPEN) THEN
  			CLOSE c_upd_acai;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_tac_course');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_tac_course;
  --
  -- Insert a tertiary education record
  FUNCTION admp_ins_tert_edu(
  p_person_id IN NUMBER ,
  p_exclusion_ind IN VARCHAR2 ,
  p_tertiary_edu_lvl_comp IN VARCHAR2 ,
  p_enrolment_first_yr IN NUMBER ,
  p_institution_cd IN VARCHAR2 ,
  p_enrolment_latest_yr IN NUMBER ,
  p_grade_point_average IN NUMBER ,
  p_language_of_tuition IN VARCHAR2 ,
  p_qualification IN VARCHAR2 ,
  p_institution_name IN VARCHAR2 ,
  p_equiv_full_time_yrs_enr IN NUMBER ,
  p_student_id IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_course_title IN VARCHAR2 ,
  p_state_cd IN VARCHAR2 ,
  p_level_of_achievement_type IN VARCHAR2 ,
  p_field_of_study IN VARCHAR2 ,
  p_language_component IN VARCHAR2 ,
  p_country_cd IN VARCHAR2 ,
  p_tertiary_edu_lvl_qual IN VARCHAR2 ,
  p_honours_level IN VARCHAR2 ,
  p_notes IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_inserted_ind OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	--admp_ins_tert_edu
  	-- This function inserts a new IGS_AD_TER_EDU record.
  DECLARE
  	CURSOR c_ins IS
  		SELECT	institution_cd,
  			local_institution_ind
  		FROM	IGS_OR_INSTITUTION
  		WHERE	govt_institution_cd 	= p_institution_cd OR
  			institution_cd 		= p_institution_cd;
  	CURSOR c_lc (
  		cp_language_cd		IGS_PE_LANGUAGE_CD.language_cd%TYPE) IS
  		SELECT 	DISTINCT(language_cd) 		language_cd
  		FROM 	IGS_PE_LANGUAGE_CD
  		WHERE 	govt_language_cd 	= cp_language_cd OR
  			language_cd 		= cp_language_cd;
  	CURSOR c_fos IS
  		SELECT 	DISTINCT(field_of_study)	field_of_study
  		FROM 	IGS_PS_FLD_OF_STUDY
  		WHERE 	govt_field_of_study 	= p_field_of_study OR
  			field_of_study 		= p_field_of_study;
  	CURSOR c_cd IS
  		SELECT 	DISTINCT(country_cd)		country_cd
  		FROM 	IGS_PE_COUNTRY_CD
  		WHERE	govt_country_cd = p_country_cd OR
  			country_cd 	= p_country_cd;
  	CURSOR c_hl IS
  		SELECT	DISTINCT(honours_level)		honours_level
  		FROM	IGS_GR_HONOURS_LEVEL
  		WHERE 	( govt_honours_level = p_honours_level OR
  			  honours_level	  = p_honours_level ) AND
			closed_ind = 'N';

  	v_ins_rec		c_ins%ROWTYPE;
  	v_institution_cd		IGS_AD_TER_EDU.institution_cd%TYPE DEFAULT NULL;
  	v_language_of_tuition
  				IGS_AD_TER_EDU.language_of_tuition%TYPE DEFAULT NULL;
  	v_language_cd			IGS_PE_LANGUAGE_CD.language_cd%TYPE DEFAULT NULL;
  	v_tertiary_edu_lvl_qual
  					IGS_AD_TER_EDU.tertiary_edu_lvl_qual%TYPE DEFAULT NULL;
  	v_tertiary_edu_lvl_comp
  					IGS_AD_TER_EDU.tertiary_edu_lvl_comp%TYPE DEFAULT NULL;
  	v_field_of_study		IGS_AD_TER_EDU.field_of_study%TYPE DEFAULT NULL;
  	v_language_component		IGS_AD_TER_EDU.language_component%TYPE DEFAULT NULL;
  	v_country_cd			IGS_AD_TER_EDU.country_cd%TYPE DEFAULT NULL;
  	v_honours_level			IGS_AD_TER_EDU.honours_level%TYPE DEFAULT NULL;
  	v_enrolment_latest_yr
  					IGS_AD_TER_EDU.enrolment_latest_yr%TYPE DEFAULT NULL;
  	v_institution_name		IGS_AD_TER_EDU.institution_name%TYPE DEFAULT NULL;
  	v_message_name VARCHAR2(30) DEFAULT 0;
  	v_inserted_ind			VARCHAR2(1) DEFAULT 'N';
  	v_institution_cd_found		BOOLEAN := TRUE;

    CURSOR C_IGS_AD_TER_EDU_SEQ_NUM_S IS
    SELECT IGS_AD_TER_EDU_SEQ_NUM_S.NEXTVAL FROM DUAL;

	lv_NextVal				NUMBER;
	lv_rowid			VARCHAR2(25);
  BEGIN
  	p_message_name := NULL;
  	p_inserted_ind := 'N';
  	-- Validate tertiary education parameters
  	-- Validate tertiary education level of completion
  	IF p_tertiary_edu_lvl_comp IS NULL THEN
		p_message_name := 'IGS_AD_TRTYEDU_CANINS_LOC_NS';
  		RETURN FALSE;
  	ELSE
  		v_tertiary_edu_lvl_comp := ADMP_GET_LVL_COMP(p_tertiary_edu_lvl_comp);
  		IF v_tertiary_edu_lvl_comp IS NULL THEN
			p_message_name := 'IGS_AD_TRTYEDU_CANINS_LOC_NE';
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate tertiary education level of qualification
  	IF p_tertiary_edu_lvl_qual IS NOT NULL THEN
  		v_tertiary_edu_lvl_qual := Igs_Ad_Gen_006.ADMP_GET_LVL_QUAL(p_tertiary_edu_lvl_qual);
  	END IF;
  	-- Validate tertiary education INSTITUTION details
  	IF p_institution_cd IS NOT NULL THEN
  		OPEN c_ins;
  		FETCH c_ins INTO v_ins_rec;
  		IF c_ins%NOTFOUND THEN
  			CLOSE c_ins;
  			v_institution_cd_found := FALSE;
  		ELSE
  			CLOSE c_ins;
  			IF v_ins_rec.local_institution_ind = 'Y' THEN
  				-- Do NOT insert tertiary education details,
  				-- these are available elsewhere in the database
  				RETURN TRUE;
  			ELSE
  				v_institution_cd := v_ins_rec.institution_cd;
  			END IF;
  		END IF;
  		IF NOT v_institution_cd_found THEN
  			IF p_institution_name IS NOT NULL THEN
  				v_institution_name := p_institution_name;
  			ELSE
				p_message_name := 'IGS_AD_TRTYEDU_CANINS_INCD_NS';
  				RETURN FALSE;
  			END IF;
  		END IF;
  	ELSE	-- p_institution_cd IS NULL
  		IF p_institution_name IS NULL THEN
			p_message_name := 'IGS_AD_TRTYEDU_CANINS_INCD_NE';
  			RETURN FALSE;
  		ELSE
  			v_institution_name := p_institution_name;
  		END IF;
  	END IF;
  	-- Validate language of tutition
  	IF p_language_of_tuition IS NOT NULL THEN
  		OPEN c_lc(
  			p_language_of_tuition);
  		FETCH c_lc INTO v_language_of_tuition;
  		CLOSE c_lc;
  	END IF;
  	-- Validate language component
  	IF p_language_component IS NOT NULL THEN
  		OPEN c_lc(
  			p_language_component);
  		FETCH c_lc INTO v_language_component;
  		CLOSE c_lc;
  	END IF;
  	-- Validate field of study
  	IF p_field_of_study IS NOT NULL THEN
  		OPEN c_fos;
  		FETCH c_fos INTO v_field_of_study;
  		CLOSE c_fos;
  	END IF;
  	-- Validate country code
  	IF p_country_cd IS NOT NULL THEN
  		OPEN c_cd;
  		FETCH c_cd INTO v_country_cd;
  		CLOSE c_cd;
  	END IF;
  	-- Validate honours level
  	IF p_honours_level IS NOT NULL THEN
  		OPEN c_hl;
  		FETCH c_hl INTO v_honours_level;
  		CLOSE c_hl;
  	END IF;
  	-- Validate enrolment years
  	IF  Igs_Ad_Val_Te.admp_val_te_enr_yr(
  				p_enrolment_first_yr,
  				p_enrolment_latest_yr,
  				v_message_name) <> FALSE THEN
  		v_enrolment_latest_yr := p_enrolment_latest_yr;
  	END IF;

        OPEN C_IGS_AD_TER_EDU_SEQ_NUM_S;
        FETCH C_IGS_AD_TER_EDU_SEQ_NUM_S INTO lv_NextVal;
        IF C_IGS_AD_TER_EDU_SEQ_NUM_S%NOTFOUND THEN
          RAISE NO_DATA_FOUND;
        END IF;
        CLOSE C_IGS_AD_TER_EDU_SEQ_NUM_S;

    	Igs_Ad_Ter_Edu_Pkg.Insert_Row (
      		X_Mode                              => 'R',
      		X_RowId                             => lv_rowid,
      		X_Person_Id                         => p_person_id,
      		X_Sequence_Number                   => lv_NextVal,
      		X_Tertiary_Edu_Lvl_Comp             => v_tertiary_edu_lvl_comp,
      		X_Exclusion_Ind                     => p_exclusion_ind,
      		X_Institution_Cd                    => v_institution_cd,
      		X_Institution_Name                  => v_institution_name,
      		X_Enrolment_First_Yr                => p_enrolment_first_yr,
      		X_Enrolment_Latest_Yr               => v_enrolment_latest_yr,
      		X_Course_Cd                         => p_course_cd,
      		X_Course_Title                      => p_course_title,
      		X_Field_Of_Study                    => v_field_of_study,
      		X_Language_Component                => v_language_component,
      		X_Student_Id                        => p_student_id,
      		X_Equiv_Full_Time_Yrs_Enr           => p_equiv_full_time_yrs_enr,
      		X_Tertiary_Edu_Lvl_Qual             => v_tertiary_edu_lvl_qual,
      		X_Qualification                     => p_qualification,
      		X_Honours_Level                     => v_honours_level,
      		X_Level_Of_Achievement_Type         => p_level_of_achievement_type,
      		X_Grade_Point_Average               => p_grade_point_average,
      		X_Language_Of_Tuition               => v_language_of_tuition,
      		X_State_Cd                          => p_state_cd,
      		X_Country_Cd                        => v_country_cd,
      		X_Notes                             => p_notes
    	);

  	p_inserted_ind := 'Y';
  	RETURN TRUE;
  EXCEPTION
  	WHEN NO_DATA_FOUND THEN
        CLOSE C_IGS_AD_TER_EDU_SEQ_NUM_S;
  	WHEN OTHERS THEN
  		IF(c_ins%ISOPEN) THEN
  			CLOSE c_ins;
  		END IF;
  		IF(c_lc%ISOPEN) THEN
  			CLOSE c_lc;
  		END IF;
  		IF(c_fos%ISOPEN) THEN
  			CLOSE c_fos;
  		END IF;
  		IF(c_cd%ISOPEN) THEN
  			CLOSE c_cd;
  		END IF;
  		IF(c_hl%ISOPEN) THEN
  			CLOSE c_hl;
  		END IF;
		App_Exception.Raise_Exception;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_tert_edu');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_tert_edu;

  --
  -- inserts a new record into the IGS_PE_ALT_PERS_ID table
  PROCEDURE admp_ins_alt_prsn_id(
  p_alt_person_id IN VARCHAR2 ,
  p_alt_person_id_type IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE )
  IS
  BEGIN
  DECLARE
  	v_api_person_id		IGS_PE_ALT_PERS_ID.api_person_id%TYPE;
  	CURSOR c_api IS
  		SELECT	api.api_person_id
  		FROM	IGS_PE_ALT_PERS_ID	api
  		WHERE	pe_person_id	= p_person_id       AND
                    	api_person_id	= p_alt_person_id   AND
                    	person_id_type	= p_alt_person_id_type;
	lv_rowid		VARCHAR2(25);
  BEGIN -- Procedure looks for an existing alternate PERSON ID matched from
        -- the parameters. If it does not exist, a new record is inserted.
  	OPEN c_api;
  	FETCH c_api INTO v_api_person_id;
  	IF (c_api%NOTFOUND) THEN

    	IGS_PE_ALT_PERS_ID_Pkg.Insert_Row (
      		X_Mode                              => 'R',
      		X_RowId                             => lv_rowid,
      		X_Pe_Person_Id                      => p_person_id,
      		X_Api_Person_Id                     => p_alt_person_id,
      		X_Person_Id_Type                    => p_alt_person_id_type,
      		X_Start_Dt                          => TRUNC(p_start_dt),
      		X_End_Dt                            => TRUNC(p_end_dt) ,
			X_ATTRIBUTE_CATEGORY                => NULL,
            X_ATTRIBUTE1                        => NULL,
            X_ATTRIBUTE2                        => NULL,
            X_ATTRIBUTE3                        => NULL,
            X_ATTRIBUTE4                        => NULL,
            X_ATTRIBUTE5                        => NULL,
            X_ATTRIBUTE6                        => NULL,
            X_ATTRIBUTE7                        => NULL,
            X_ATTRIBUTE8                        => NULL,
            X_ATTRIBUTE9                        => NULL,
            X_ATTRIBUTE10                       => NULL,
            X_ATTRIBUTE11                       => NULL,
            X_ATTRIBUTE12                       => NULL,
            X_ATTRIBUTE13                       => NULL,
            X_ATTRIBUTE14                       => NULL,
            X_ATTRIBUTE15                       => NULL,
            X_ATTRIBUTE16                       => NULL,
            X_ATTRIBUTE17                       => NULL,
            X_ATTRIBUTE18                       => NULL,
            X_ATTRIBUTE19                       => NULL,
            X_ATTRIBUTE20                       => NULL,
    		X_REGION_CD                         => NULL
    	);


  	END IF;
  	CLOSE c_api;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_alt_prsn_id');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_alt_prsn_id;
  --
  -- Inserts a IGS_PE_PERSON and alternate  PERSON ID record with data from TAC
  -- ssawhney 2225917 : remove customer creation
  FUNCTION admp_ins_tac_prsn(
  p_person_id IN NUMBER ,
  p_tac_person_id IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_given_names IN VARCHAR2 ,
  p_sex IN VARCHAR2 ,
  p_birth_dt IN DATE ,
  p_alt_person_id_type IN VARCHAR2 ,
  p_new_person_id OUT NOCOPY NUMBER ,
  p_message_out OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
skpandey   21-SEP-2005   Bug: 3663505
                         Description: Added ATTRIBUTES 21 TO 24 to store additional information
******************************************************************/

  BEGIN	-- admp_ins_tac_prsn
  	-- This module uses information from the TAC offer load process
  	-- to create IGS_PE_PERSON and alternate  PERSON ID records if they
  	-- don't already exist.
  DECLARE
  	v_new_person_id		IGS_PE_PERSON.person_id%TYPE;
  	v_new_person_number	IGS_PE_PERSON.person_number%TYPE;
  	v_message_name	VARCHAR2(30);
  	v_api_x			VARCHAR2(1) 	DEFAULT NULL;
  	v_new_sex		VARCHAR2(1) 	DEFAULT NULL;
	l_sex			Varchar2(30)	DEFAULT NULL;
  	CURSOR c_api IS
  		SELECT	'x'
  		FROM	IGS_PE_ALT_PERS_ID
  		WHERE	pe_person_id 	= p_person_id AND
  			api_person_id 	= p_tac_person_id AND
  			person_id_type 	= p_alt_person_id_type;
	lv_rowid			VARCHAR2(25);
	l_msg_count			NUMBER;
	l_msg_data			VARCHAR2(2000);
	l_return_status		VARCHAR2(1);

	--lv_acc_no VARCHAR2(1);
	l_object_version_number NUMBER;

  BEGIN
  	p_message_out := NULL;
  	IF NVL(p_person_id,0) <> 0 THEN
  		-- we matched a student
  		p_message_out := 'TAC student' || ' ' ||
    				 p_tac_person_id || ' ' ||
  				 p_surname || ' ' ||
  				 p_given_names || ' ' ||
  				 'matched Callista  person' || ' ' ||
  				 IGS_GE_NUMBER.TO_CANN(p_person_id);
  		-- Record the new TAC ID
  		-- First check if this TAC ID already exists in
  		-- IGS_PE_ALT_PERS_ID rec
  		OPEN c_api;
  		FETCH c_api INTO v_api_x;
  		IF (c_api%NOTFOUND) THEN
  			admp_ins_alt_prsn_id(
  					p_tac_person_id,
  					p_alt_person_id_type,
  					p_person_id,
  					SYSDATE,
  					NULL);
  		END IF;
  		CLOSE c_api;
  	ELSE
  		-- PERSON not found, need to create a new ID number
  		-- first must call IGS_GE_GEN_002.GENP_GET_NXT_PRSN_ID to return
  		-- the next person_id value by calling
  		IF IGS_GE_GEN_002.GENP_GET_NXT_PRSN_ID(
  					v_new_person_id,
  					v_message_name) = FALSE THEN
  			-- Cannot generate new ID
  			p_message_out := p_tac_person_id || ' ' || fnd_message.get_string('IGS',v_message_name);
  			RETURN FALSE;
  		ELSE
  			-- New ID generated, set output parameter
  			p_new_person_id := v_new_person_id;
  			-- Get fields for insert of new PERSON details
  			IF p_sex <> 'M' AND
  					p_sex <> 'F' THEN
  				v_new_sex := 'U';
  			ELSE
  				v_new_sex := p_sex;
  			END IF;
  			p_message_out := 'Creating ID '|| IGS_GE_NUMBER.TO_CANN(v_new_person_id);

-- Code added for Leap Frogging after customer bug#1700178 on ver 1.7 -tray -(03-05-2001)
-- changed by ssawhney bug 2225917 -- OSS Will not create customer account

--Bug# 3562134
			IF p_sex = 'M' THEN
				l_sex := 'MALE';
			ELSIF p_sex = 'F' THEN
  				l_sex := 'FEMALE';
  			ELSE
  				l_sex := 'UNKNOWN';
  			END IF;

			IGS_PE_PERSON_PKG.Insert_Row(
								   X_MSG_COUNT => l_msg_count,
								   X_MSG_DATA => l_msg_data,
								   	X_RETURN_STATUS => l_return_status,
									X_ROWID => lv_rowId,
									X_PERSON_ID => v_new_person_id,
									X_PERSON_NUMBER => v_new_person_number,
									X_SURNAME => p_surname,
									X_MIDDLE_NAME => NULL,
									X_GIVEN_NAMES => p_given_names,
									X_SEX => l_sex,
									X_TITLE => NULL,
									X_STAFF_MEMBER_IND => 'N',
									X_DECEASED_IND => 'N',
									X_SUFFIX => NULL,
									X_PRE_NAME_ADJUNCT => NULL,
									X_ARCHIVE_EXCLUSION_IND => 'N',
									X_ARCHIVE_DT => NULL,
									X_PURGE_EXCLUSION_IND => 'N',
									X_PURGE_DT => NULL,
									X_DECEASED_DATE => NULL,
									X_PROOF_OF_INS => NULL,
									X_PROOF_OF_IMMU => NULL,
									X_BIRTH_DT => P_BIRTH_DT,
									X_SALUTATION => NULL,
									X_ORACLE_USERNAME  => NULL,
									X_PREFERRED_GIVEN_NAME => NULL,
									X_EMAIL_ADDR => NULL,
									X_LEVEL_OF_QUAL_ID => NULL,
									X_MILITARY_SERVICE_REG=> NULL,
									X_VETERAN=> NULL,
									X_HZ_PARTIES_OVN => l_object_version_number,
									X_ATTRIBUTE_CATEGORY=> NULL,
									X_ATTRIBUTE1=> NULL,
									X_ATTRIBUTE2=> NULL,
									X_ATTRIBUTE3=> NULL,
									X_ATTRIBUTE4=> NULL,
									X_ATTRIBUTE5=> NULL,
									X_ATTRIBUTE6=> NULL,
									X_ATTRIBUTE7=> NULL,
									X_ATTRIBUTE8=> NULL,
									X_ATTRIBUTE9=> NULL,
									X_ATTRIBUTE10=> NULL,
									X_ATTRIBUTE11=> NULL,
									X_ATTRIBUTE12=> NULL,
									X_ATTRIBUTE13=> NULL,
									X_ATTRIBUTE14=> NULL,
									X_ATTRIBUTE15=> NULL,
									X_ATTRIBUTE16=> NULL,
									X_ATTRIBUTE17=> NULL,
									X_ATTRIBUTE18=> NULL,
									X_ATTRIBUTE19=> NULL,
									X_ATTRIBUTE20=> NULL,
									X_PERSON_ID_TYPE=> NULL,
									X_API_PERSON_ID=> NULL,
									X_ATTRIBUTE21=> NULL,
									X_ATTRIBUTE22=> NULL,
									X_ATTRIBUTE23=> NULL,
									X_ATTRIBUTE24=> NULL
								);




  			admp_ins_alt_prsn_id(
  					p_tac_person_id,
  					p_alt_person_id_type,
  					v_new_person_id,
  					SYSDATE,
  					NULL);
  		END IF; -- insert of new IGS_PE_PERSON
  	END IF; -- matched person_id <> 0
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_tac_prsn');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_tac_prsn;
  --
  -- Insert a new  PERSON address record and end date the previous record
  -- ssawhney : 2225917 SWCR008, made changes due to change in IGS_PE_PERSON_ADDR_PKG
  --
  FUNCTION admp_ins_person_addr(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_addr_line_1 IN VARCHAR2 ,
  p_addr_line_2  VARCHAR2 ,
  p_addr_line_3 IN VARCHAR2 ,
  p_addr_line_4 IN VARCHAR2 ,
  p_aust_postcode IN NUMBER ,
  p_os_code IN VARCHAR2 ,
  p_phone_1 IN VARCHAR2 ,
  p_phone_2 IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  BEGIN	--admp_ins_person_addr
  	--Procedure inserts a new  PERSON address record
  DECLARE
  	CURSOR c_pa IS
--  		SELECT	pa.start_dt
  		SELECT	pa.*
  		FROM	IGS_PE_PERSON_ADDR_V	pa
  		WHERE	pa.person_id	= p_person_id	AND
                    	pa.end_dt	IS NULL		AND
			pa.status = 'A' AND
  			pa.addr_type	IN (	SELECT	adt.addr_type
  						FROM	IGS_PE_PERSON_ADDR adt
  						WHERE	adt.correspondence_ind = 'Y');
--  		FOR	UPDATE OF pa.end_dt NOWAIT;
/* This logic will not work as expected because this cursor may retrieve more than one record
Also, the update will not take place since l_location_id is null */

	v_pa_rec		c_pa%ROWTYPE;
  	v_aust_postcode	NUMBER;
	Rec_IGS_PE_PERSON_Addr	c_pa%ROWTYPE;
	lv_rowid		VARCHAR2(25);

	l_party_site_ovn hz_party_sites.object_version_number%TYPE;
	l_location_ovn hz_locations.object_version_number%TYPE;

	 L_RETURN_STATUS VARCHAR2(1);
 	 L_MSG_DATA  VARCHAR2(2000);
 	 l_party_site_id NUMBER;
 	 l_party_type VARCHAR2(100);

 	 l_LAST_UPDATE_DATE DATE;
	 l_location_id		NUMBER;

  BEGIN
  	--Set the end date for the previous IGS_PE_PERSON_ADDR record
  	--of this address type
  	OPEN c_pa;
--  	FETCH c_pa INTO v_pa_rec;
  	FETCH c_pa INTO Rec_IGS_PE_PERSON_Addr;
  	IF (c_pa%FOUND) THEN
  		IF TRUNC(v_pa_rec.start_dt) <> TRUNC(p_start_dt) THEN

	l_party_site_ovn := Rec_IGS_PE_PERSON_Addr.party_site_ovn;
	l_location_ovn := Rec_IGS_PE_PERSON_Addr.location_ovn;

		   IGS_PE_PERSON_ADDR_PKG.Update_Row(
					 P_ACTION => 'U',
					 P_ROWID => lv_RowId,
 					 P_LOCATION_ID => l_location_Id,  -- This is wrong: location_id should not be null
					 P_START_DT => Rec_IGS_PE_PERSON_Addr.Start_Dt,
 					 P_END_DT => TRUNC(p_start_dt - 1),
 					 P_COUNTRY => Rec_IGS_PE_PERSON_Addr.COUNTRY,
 					 P_ADDRESS_STYLE => NULL,
 					 P_ADDR_LINE_1  => Rec_IGS_PE_PERSON_Addr.Addr_Line_1,
 					 P_ADDR_LINE_2=> Rec_IGS_PE_PERSON_Addr.Addr_Line_2,
 					 P_ADDR_LINE_3 => Rec_IGS_PE_PERSON_Addr.Addr_Line_3,
 					 P_ADDR_LINE_4 => Rec_IGS_PE_PERSON_Addr.Addr_Line_4,
 					 P_DATE_LAST_VERIFIED => Rec_IGS_PE_PERSON_Addr.DATE_LAST_VERIFIED,
 					 P_CORRESPONDENCE => Rec_IGS_PE_PERSON_Addr.CORRESPONDENCE_ind,
 					 P_CITY => Rec_IGS_PE_PERSON_Addr.CITY,
 					 P_STATE => Rec_IGS_PE_PERSON_Addr.STATE,
 					 P_PROVINCE => Rec_IGS_PE_PERSON_Addr.PROVINCE,
 					 P_COUNTY => Rec_IGS_PE_PERSON_Addr.COUNTY,
 					 P_POSTAL_CODE => Rec_IGS_PE_PERSON_Addr.postal_code,
 					 P_ADDRESS_LINES_PHONETIC => NULL,
 					 P_DELIVERY_POINT_CODE => Rec_IGS_PE_PERSON_Addr.DELIVERY_POINT_CODE,
 					 P_OTHER_DETAILS_1 => Rec_IGS_PE_PERSON_Addr.other_details_1,
 					 P_OTHER_DETAILS_2 => Rec_IGS_PE_PERSON_Addr.other_details_2,
 					 P_OTHER_DETAILS_3 => Rec_IGS_PE_PERSON_Addr.other_details_3,
 					 L_RETURN_STATUS => l_return_status,
 					 L_MSG_DATA => l_msg_data,
 					 P_PARTY_ID => Rec_IGS_PE_PERSON_Addr.Person_Id,
 					 P_PARTY_SITE_ID => l_party_site_id,
 					 P_PARTY_TYPE => l_party_type,
 					 P_LAST_UPDATE_DATE => l_last_update_date,
					 p_party_site_ovn => l_party_site_ovn,
					 p_location_ovn	 => l_location_ovn,
					 p_status	 => Rec_IGS_PE_PERSON_Addr.status
					 );

		  			CLOSE c_pa;
  		ELSE
  			CLOSE c_pa;
			p_message_name := 'IGS_AD_CORR_ADDRESS_EXISTS';
  			RETURN FALSE;
  		END IF;
  	END IF;

			   IGS_PE_PERSON_ADDR_PKG.Insert_Row(
					 P_ACTION => 'I',
					 P_ROWID => lv_RowId,
 					 P_LOCATION_ID => l_location_Id,
					 P_START_DT => NULL,
 					 P_END_DT => TRUNC(p_start_dt - 1),
 					 P_COUNTRY => Rec_IGS_PE_PERSON_Addr.COUNTRY,
 					 P_ADDRESS_STYLE => NULL,
 					 P_ADDR_LINE_1  => P_Addr_Line_1,
 					 P_ADDR_LINE_2=> P_Addr_Line_2,
 					 P_ADDR_LINE_3 => P_Addr_Line_3,
 					 P_ADDR_LINE_4 => P_Addr_Line_4,
 					 P_DATE_LAST_VERIFIED => Rec_IGS_PE_PERSON_Addr.DATE_LAST_VERIFIED,
 					 P_CORRESPONDENCE => Rec_IGS_PE_PERSON_Addr.CORRESPONDENCE_ind,
 					 P_CITY => Rec_IGS_PE_PERSON_Addr.CITY,
 					 P_STATE => Rec_IGS_PE_PERSON_Addr.STATE,
 					 P_PROVINCE => Rec_IGS_PE_PERSON_Addr.PROVINCE,
 					 P_COUNTY => Rec_IGS_PE_PERSON_Addr.COUNTY,
 					 P_POSTAL_CODE => Rec_IGS_PE_PERSON_Addr.postal_code,
 					 P_ADDRESS_LINES_PHONETIC => NULL,
 					 P_DELIVERY_POINT_CODE => Rec_IGS_PE_PERSON_Addr.DELIVERY_POINT_CODE,
 					 P_OTHER_DETAILS_1 => Rec_IGS_PE_PERSON_Addr.other_details_1,
 					 P_OTHER_DETAILS_2 => Rec_IGS_PE_PERSON_Addr.other_details_2,
 					 P_OTHER_DETAILS_3 => Rec_IGS_PE_PERSON_Addr.other_details_3,
 					 L_RETURN_STATUS => l_return_status,
 					 L_MSG_DATA => l_msg_data,
 					 P_PARTY_ID => Rec_IGS_PE_PERSON_Addr.Person_Id,
 					 P_PARTY_SITE_ID => l_party_site_id,
 					 P_PARTY_TYPE => l_party_type,
 					 p_last_update_date => l_last_update_date,
					 p_party_site_ovn   => l_party_site_ovn,
					 p_location_ovn	   => l_location_ovn,
					 p_status	   => Rec_IGS_PE_PERSON_Addr.status
					 );


  	IF v_aust_postcode = 9999 THEN
		p_message_name := 'IGS_GE_INVALID_VALUE';
  		RETURN FALSE;
  	ELSE
  		p_message_name := NULL;
  		RETURN TRUE;
  	END IF;
  END;
  EXCEPTION
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_person_addr');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_ins_person_addr;
  --
  -- Insert a admission  COURSE application record
  FUNCTION admp_ins_adm_crs_app(
  p_person_id IN NUMBER ,
  p_adm_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_basis_for_admission_type IN VARCHAR2 ,
  p_admission_cd IN VARCHAR2 ,
  p_req_for_reconsideration_ind IN VARCHAR2,
  p_req_for_adv_standing_ind IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN IS
  	e_integrity_exception		EXCEPTION;
  	PRAGMA EXCEPTION_INIT(e_integrity_exception, -2291);
  BEGIN	-- admp_ins_adm_crs_app
  	-- This module validate IGS_AD_PS_APLINSTUNT unit version.
  DECLARE
  	v_admission_cat			IGS_AD_APPL.admission_cat%TYPE DEFAULT NULL;
  	v_s_admission_process_type	IGS_AD_APPL.s_admission_process_type%TYPE DEFAULT
   NULL;
  	v_acad_cal_type			IGS_AD_APPL.acad_cal_type%TYPE DEFAULT NULL;
  	v_acad_ci_sequence_number
  					IGS_AD_APPL.acad_ci_sequence_number%TYPE DEFAULT 0;
  	v_adm_cal_type			IGS_AD_APPL.adm_cal_type%TYPE DEFAULT NULL;
  	v_adm_ci_sequence_number	IGS_AD_APPL.adm_ci_sequence_number%TYPE DEFAULT 0;
  	v_appl_dt			IGS_AD_APPL.appl_dt%TYPE DEFAULT NULL;
  	v_adm_appl_status		IGS_AD_APPL.adm_appl_status%TYPE DEFAULT NULL;
  	v_adm_fee_status		IGS_AD_APPL.adm_fee_status%TYPE DEFAULT NULL;
  	v_crv_version_number		IGS_PS_VER.version_number%TYPE DEFAULT 0;
  	v_message_name VARCHAR2(30) DEFAULT 0;
  	v_return_type			VARCHAR2(1) DEFAULT NULL;
  	v_pref_limit
  					IGS_AD_PRCS_CAT_STEP.step_type_restriction_num%TYPE DEFAULT NULL;
  	v_late_appl_allowed_ind		VARCHAR2(1)	DEFAULT 'N';
  	v_req_reconsider_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
  	v_req_adv_standing_allowed_ind	VARCHAR2(1)	DEFAULT 'N';
  	CURSOR c_apcs(
  			cp_admission_cat	IGS_AD_APPL.admission_cat%TYPE) IS
  		SELECT	apcs.s_admission_step_type,
  			step_type_restriction_num
  		FROM	IGS_AD_PRCS_CAT_STEP apcs
  		WHERE	apcs.admission_cat 		= cp_admission_cat AND
  			apcs.s_admission_process_type 	= 'COURSE' AND
  			apcs.step_group_type <> 'TRACK'; --2402377
	lv_rowid		VARCHAR2(25);
	l_org_id		NUMBER(15);
  BEGIN
  	p_message_name := NULL;
  	-- Get admission application details required for validation
  	Igs_Ad_Gen_002.ADMP_GET_AA_DTL(
  			p_person_id,
  			p_adm_appl_number,
  			v_admission_cat,
  			v_s_admission_process_type,
  			v_acad_cal_type,
  			v_acad_ci_sequence_number,
  			v_adm_cal_type,
  			v_adm_ci_sequence_number,
  			v_appl_dt,
  			v_adm_appl_status,
  			v_adm_fee_status);
  	IF v_appl_dt IS NULL THEN
		p_message_name := 'IGS_AD_ADMAPPL_NOT_FOUND';
  		RETURN FALSE;
  	END IF;
  	-- Determine the admission process category steps.
  	FOR v_apcs_rec IN c_apcs(
  				v_admission_cat	)  LOOP
  		IF v_apcs_rec.s_admission_step_type = 'PREF-LIMIT' THEN
  			v_pref_limit := v_apcs_rec.step_type_restriction_num;
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'LATE-APP' THEN
  			v_late_appl_allowed_ind := 'Y';
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'RECONSIDER' THEN
  			v_req_reconsider_allowed_ind := 'Y';
  		END IF;
  		IF v_apcs_rec.s_admission_step_type = 'ADVSTAND' THEN
  			v_req_adv_standing_allowed_ind := 'Y';
  		END IF;
  	END LOOP;
  	-- Validate preference limit
  	IF Igs_Ad_Val_Aca.admp_val_pref_limit(
  					p_person_id,
  					p_adm_appl_number,
  					p_nominated_course_cd,
  					-1,  			-- (acai sequence number not yet known)
  					'COURSE',
  					v_pref_limit,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Validate the nominated COURSE code
  	IF NOT Igs_Ad_Val_Acai.admp_val_acai_course(
  						p_nominated_course_cd,
  						NULL,			-- COURSE version number
  						v_admission_cat,
  						v_s_admission_process_type,
  						v_acad_cal_type,
  						v_acad_ci_sequence_number,
  						v_adm_cal_type,
  						v_adm_ci_sequence_number,
  						v_appl_dt,
  						v_late_appl_allowed_ind,
  						'N',			-- offer indicator
  						v_crv_version_number,	-- out NOCOPY parameters
  						v_message_name,
  						v_return_type) THEN
  		IF v_return_type = 'E' THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate against current student COURSE attempt
  	IF NOT Igs_Ad_Val_Acai.admp_val_aca_sca(
  					p_person_id,
  					p_nominated_course_cd,
  					v_appl_dt,
  					v_admission_cat,
  					v_s_admission_process_type,
  					NULL,	-- Fee category.
  					NULL,	-- Correspondence category.
  					NULL,	-- Enrolment category.
  					'N',	-- Offer indicator
  					v_message_name,
  					v_return_type) THEN
  		IF v_return_type = 'E' THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate basis for admission type closed indicator
  	IF p_basis_for_admission_type IS NOT NULL THEN
  		IF NOT Igs_Ad_Val_Aca.admp_val_bfa_closed(
  						p_basis_for_admission_type,
  						v_message_name) THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	-- Validate admission code closed indicator
  	IF p_admission_cd IS NOT NULL THEN
  		IF NOT Igs_Ad_Val_Aca.admp_val_aco_closed(
  						p_admission_cd,
  						v_message_name) THEN
	  		p_message_name := v_message_name;
  			RETURN FALSE;
  		END IF;
  	END IF;
  	IF  Igs_Ad_Val_Aca.admp_val_aca_req_rec(
  					p_req_for_reconsideration_ind,
  					v_req_reconsider_allowed_ind,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	IF  Igs_Ad_Val_Aca.admp_val_aca_req_adv(
  					p_req_for_adv_standing_ind,
  					v_req_adv_standing_allowed_ind,
  					v_message_name) = FALSE THEN
  		p_message_name := v_message_name;
  		RETURN FALSE;
  	END IF;
  	-- Insert the record after all validation has been performed
    l_org_id := igs_ge_gen_003.get_org_id;
    Igs_Ad_Ps_Appl_Pkg.Insert_Row (
      X_Mode                              => 'R',
      X_RowId                             => lv_rowid,
      X_Person_Id                         => p_person_id,
      X_Admission_Appl_Number             => p_adm_appl_number,
      X_Nominated_Course_Cd               => p_nominated_course_cd,
      X_Transfer_Course_Cd                => NULL,
      X_Basis_For_Admission_Type          => p_basis_for_admission_type,
      X_Admission_Cd                      => p_admission_cd,
      X_Course_Rank_Set                   => NULL,
      X_Course_Rank_Schedule              => NULL,
      X_Req_For_Reconsideration_Ind       => p_req_for_reconsideration_ind,
      X_Req_For_Adv_Standing_Ind          => p_req_for_adv_standing_ind,
      X_Org_Id				  => l_org_id
    );
  	RETURN TRUE;
  END;
  EXCEPTION
  	WHEN e_integrity_exception THEN
	    Fnd_Message.Set_Name('IGS','IGS_AD_ADM_APPL_NOT_INS');
		App_Exception.Raise_Exception;

  		RETURN FALSE;
  	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_PRC_TAC_OFFER.admp_ins_adm_crs_app');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
  END admp_ins_adm_crs_app;

END Igs_Ad_Prc_Tac_Offer;

/
