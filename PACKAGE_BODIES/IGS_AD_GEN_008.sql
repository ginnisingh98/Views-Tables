--------------------------------------------------------
--  DDL for Package Body IGS_AD_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_GEN_008" AS
/* $Header: IGSAD08B.pls 115.13 2003/11/28 13:19:45 rboddu ship $ */

Function Admp_Get_Safs(
  p_adm_fee_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	--admp_get_safs
	--Get the s_adm_fee_status for a specified IGS_AD_FEE_STAT.
DECLARE
	v_fee_status	IGS_AD_FEE_STAT.s_adm_fee_status%TYPE;
	CURSOR c_afs IS
		SELECT	s_adm_fee_status
		FROM	IGS_AD_FEE_STAT
		WHERE	adm_fee_status = p_adm_fee_status;
BEGIN
	--initialise v_fee_status
	v_fee_status := NULL;
	OPEN c_afs ;
	FETCH c_afs INTO v_fee_status;
	CLOSE c_afs ;
	RETURN v_fee_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_safs');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_safs;

Function Admp_Get_Saods(
  p_adm_offer_dfrmnt_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	--admp_get_saods
	--Get the s_adm_offer_dfrmnt_status for a specified IGS_AD_OFRDFRMT_STAT.
DECLARE
	v_dfrmnt_status		IGS_AD_OFRDFRMT_STAT.s_adm_offer_dfrmnt_status%TYPE;
	CURSOR c_aods IS
		SELECT	s_adm_offer_dfrmnt_status
		FROM	IGS_AD_OFRDFRMT_STAT
		WHERE	adm_offer_dfrmnt_status = p_adm_offer_dfrmnt_status;
BEGIN
	--initialise v_dfrmnt_status
	v_dfrmnt_status := NULL;
	OPEN c_aods ;
	FETCH c_aods INTO v_dfrmnt_status;
	CLOSE c_aods ;
	RETURN v_dfrmnt_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_saods');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_saods;

Function Admp_Get_Saors(
  p_adm_offer_resp_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	--admp_get_saors
	--Get the s_adm_offer_resp_status for a specified IGS_AD_OFR_RESP_STAT.
DECLARE
	v_resp_status		IGS_AD_OFR_RESP_STAT.s_adm_offer_resp_status%TYPE;
	CURSOR c_aors IS
		SELECT	s_adm_offer_resp_status
		FROM	IGS_AD_OFR_RESP_STAT
		WHERE	adm_offer_resp_status = p_adm_offer_resp_status;
BEGIN
	--initialise v_resp_status
	v_resp_status := NULL;
	OPEN c_aors ;
	FETCH c_aors INTO v_resp_status;
	CLOSE c_aors ;
	RETURN v_resp_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_saors');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_saors;

Function Admp_Get_Saos(
  p_adm_outcome_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
	--admp_get_saos
	--Get the s_adm_outcome_status for a specified IGS_AD_OU_STAT.
	v_outcome_status		IGS_AD_OU_STAT.s_adm_outcome_status%TYPE;
	CURSOR c_aos IS
		SELECT	s_adm_outcome_status
		FROM	IGS_AD_OU_STAT
		WHERE	adm_outcome_status = p_adm_outcome_status;
BEGIN
	--initialise v_outcome_status
	v_outcome_status := NULL;
	OPEN c_aos ;
	FETCH c_aos INTO v_outcome_status;
	CLOSE c_aos ;
	RETURN v_outcome_status;
END admp_get_saos;

Function Admp_Get_Sauos(
  p_adm_unit_outcome_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	--admp_get_sauos
	--Get the s_adm_unit_outcome_status for a specified IGS_AD_UNIT_OU_STAT
DECLARE
	v_adm_unit_outcome_status	IGS_AD_UNIT_OU_STAT.s_adm_outcome_status%TYPE;
	CURSOR c_auos IS
		SELECT	auos.s_adm_outcome_status
		FROM	IGS_AD_UNIT_OU_STAT		auos
		WHERE	auos.adm_unit_outcome_status = p_adm_unit_outcome_status;
BEGIN
	--initialise v_adm_unit_outcome_status
	v_adm_unit_outcome_status := NULL;
	OPEN c_auos ;
	FETCH c_auos INTO v_adm_unit_outcome_status;
	CLOSE c_auos ;
	RETURN v_adm_unit_outcome_status;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_auos%ISOPEN) THEN
			CLOSE c_auos;
		END IF;
		RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_sauos');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sauos;

Function Admp_Get_Short_Dt(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER )
RETURN DATE IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_short_dt
	-- Get the short admission date for an admission period.  If no short admission
	-- date alias exists for the admission period then null will be returned.
DECLARE
	CURSOR c_short_dt IS
		SELECT	daiv.alias_val
		FROM	IGS_CA_DA_INST_V	daiv,
			IGS_AD_CAL_CONF		sacc
		WHERE	daiv.cal_type		= p_adm_cal_type	AND
			daiv.ci_sequence_number	= p_adm_ci_sequence_number AND
			daiv.dt_alias		= sacc.adm_appl_short_strt_dt_alias
		ORDER BY daiv.alias_val DESC;
	v_short_dt_rec		c_short_dt%ROWTYPE;
BEGIN
	-- Get the short admission date for the admission period.
	OPEN c_short_dt;
	FETCH c_short_dt INTO v_short_dt_rec;
	IF (c_short_dt%FOUND) THEN
		CLOSE c_short_dt;
		RETURN v_short_dt_rec.alias_val;
	ELSE
		CLOSE c_short_dt;
		RETURN IGS_GE_DATE.IGSDATE(NULL);
	END IF;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_short_dt');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_short_dt;

Function Admp_Get_Status_Rule(
  p_person_id IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_appl_number  NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_s_letter_parameter_type IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_status_rule
	-- This function determines status and other values and passes them into a call
	--  to a rules function
	-- which will return text to be displayed on a letter according to rules
	-- defined for the passed parameters.
DECLARE
    v_message_name  		varchar2(30);
	v_effective_dt			DATE;
	v_out_string			VARCHAR2(2000);
	v_late				BOOLEAN;
	v_encumbrance			BOOLEAN;
	v_course_invalid		BOOLEAN;
	v_reconsideration		BOOLEAN;
	v_incomplete			BOOLEAN;
	v_late_ind			CHAR;
	v_return_type			VARCHAR2(255);
	v_apcs_pref_limit_ind		VARCHAR2(255);
	v_apcs_app_fee_ind		VARCHAR2(255);
	v_apcs_late_app_ind		VARCHAR2(255);
	v_apcs_late_fee_ind		VARCHAR2(255);
	v_apcs_chkpencumb_ind		VARCHAR2(255);
	v_apcs_fee_assess_ind		VARCHAR2(255);
	v_apcs_corcategry_ind		VARCHAR2(255);
	v_apcs_enrcategry_ind		VARCHAR2(255);
	v_apcs_chkcencumb_ind		VARCHAR2(255);
	v_apcs_unit_set_ind		VARCHAR2(255);
	v_apcs_un_crs_us_ind		VARCHAR2(255);
	v_apcs_chkuencmb_ind		VARCHAR2(255);
	v_apcs_unit_restr_ind		VARCHAR2(255);
	v_apcs_unit_restriction_num 	VARCHAR2(255);
	v_apcs_un_dob_ind		VARCHAR2(255);
	v_apcs_un_title_ind		VARCHAR2(255);
	v_apcs_asses_cond_ind		VARCHAR2(255);
	v_apcs_fee_cond_ind		VARCHAR2(255);
	v_apcs_doc_cond_ind		VARCHAR2(255);
	v_apcs_multi_off_ind		VARCHAR2(255);
	v_apcs_multi_off_restrict_num 	VARCHAR2(255);
	v_apcs_set_otcome_ind		VARCHAR2(255);
	v_apcs_override_o_ind		VARCHAR2(255);
	v_apcs_defer_ind_ind		VARCHAR2(255);
	v_apcs_ack_app_ind		VARCHAR2(255);
	v_apcs_outcome_lt_ind		VARCHAR2(255);
	v_apcs_pre_enrol_ind		VARCHAR2(255);
	v_mandatory_athletics		BOOLEAN;
	v_mandatory_alternate		BOOLEAN;
	v_mandatory_address		BOOLEAN;
	v_mandatory_disability		BOOLEAN;
	v_mandatory_visa		BOOLEAN;
	v_mandatory_finance		BOOLEAN;
	v_mandatory_notes		BOOLEAN;
	v_mandatory_statistics		BOOLEAN;
	v_mandatory_alias		BOOLEAN;
	v_mandatory_tertiary 		BOOLEAN;
	v_mandatory_aus_sec_ed 		BOOLEAN;
	v_mandatory_os_sec_ed 		BOOLEAN;
	v_mandatory_employment 		BOOLEAN;
	v_mandatory_membership 		BOOLEAN;
	v_mandatory_dob 		BOOLEAN;
	v_mandatory_title 		BOOLEAN;
	v_mandatory_referee 		BOOLEAN;
	v_mandatory_scholarship 	BOOLEAN;
	v_mandatory_lang_prof 		BOOLEAN;
	v_mandatory_interview 		BOOLEAN;
	v_mandatory_exchange 		BOOLEAN;
	v_mandatory_adm_test 		BOOLEAN;
	v_mandatory_fee_assess 		BOOLEAN;
	v_mandatory_cor_category 	BOOLEAN;
	v_mandatory_enr_category 	BOOLEAN;
	v_mandatory_research		BOOLEAN;
	v_mandatory_rank_app 		BOOLEAN;
	v_mandatory_completion 		BOOLEAN;
	v_mandatory_rank_set 		BOOLEAN;
	v_mandatory_basis_adm 		BOOLEAN;
	v_mandatory_crs_international 	BOOLEAN;
	v_mandatory_ass_tracking 	BOOLEAN;
	v_mandatory_adm_code 		BOOLEAN;
	v_mandatory_fund_source 	BOOLEAN;
	v_mandatory_location 		BOOLEAN;
	v_mandatory_att_mode 		BOOLEAN;
	v_mandatory_att_type 		BOOLEAN;
	v_mandatory_unit_set 		BOOLEAN;
	v_valid_athletics		BOOLEAN;
	v_valid_alternate		BOOLEAN;
	v_valid_address			BOOLEAN;
	v_valid_disability		BOOLEAN;
	v_valid_visa			BOOLEAN;
	v_valid_finance			BOOLEAN;
	v_valid_notes			BOOLEAN;
	v_valid_statistics		BOOLEAN;
	v_valid_alias			BOOLEAN;
	v_valid_tertiary		BOOLEAN;
	v_valid_aus_sec_ed		BOOLEAN;
	v_valid_os_sec_ed		BOOLEAN;
	v_valid_employment		BOOLEAN;
	v_valid_membership		BOOLEAN;
	v_valid_dob			BOOLEAN;
	v_valid_title			BOOLEAN;
	v_valid_referee			BOOLEAN;
	v_valid_scholarship		BOOLEAN;
	v_valid_lang_prof		BOOLEAN;
	v_valid_interview		BOOLEAN;
	v_valid_exchange		BOOLEAN;
	v_valid_adm_test		BOOLEAN;
	v_valid_fee_assess		BOOLEAN;
	v_valid_cor_category		BOOLEAN;
	v_valid_enr_category		BOOLEAN;
	v_valid_research		BOOLEAN;
	v_valid_rank_app		BOOLEAN;
	v_valid_completion		BOOLEAN;
	v_valid_rank_set		BOOLEAN;
	v_valid_basis_adm		BOOLEAN;
	v_valid_crs_international	BOOLEAN;
	v_valid_ass_tracking		BOOLEAN;
	v_valid_adm_code		BOOLEAN;
	v_valid_fund_source		BOOLEAN;
	v_valid_location		BOOLEAN;
	v_valid_att_mode		BOOLEAN;
	v_valid_att_type		BOOLEAN;
	v_valid_unit_set		BOOLEAN;
	v_valid_excurr                  BOOLEAN;
	v_mandatory_evaluation_tab	BOOLEAN;
	v_mandatory_prog_approval 	BOOLEAN;
	v_mandatory_indices       	BOOLEAN;
	v_mandatory_tst_scores    	BOOLEAN;
	v_mandatory_outcome           BOOLEAN ;
	v_mandatory_override          BOOLEAN ;
	v_mandatory_spl_consider      BOOLEAN ;
	v_mandatory_cond_offer        BOOLEAN ;
	v_mandatory_offer_dead        BOOLEAN ;
	v_mandatory_offer_resp        BOOLEAN ;
	v_mandatory_offer_defer       BOOLEAN ;
	v_mandatory_offer_compl       BOOLEAN ;
	v_mandatory_transfer          BOOLEAN ;
	v_mandatory_other_inst        BOOLEAN ;
	v_mandatory_edu_goals         BOOLEAN ;
	v_mandatory_acad_interest     BOOLEAN ;
	v_mandatory_app_intent        BOOLEAN ;
	v_mandatory_spl_interest      BOOLEAN ;
	v_mandatory_spl_talents       BOOLEAN ;
	v_mandatory_miscell           BOOLEAN ;
	v_mandatory_fees              BOOLEAN ;
	v_mandatory_program           BOOLEAN ;
	v_mandatory_completness       BOOLEAN ;
	v_mandatory_creden            BOOLEAN ;
	v_mandatory_review_det        BOOLEAN ;
	v_mandatory_recomm_det        BOOLEAN ;
	v_mandatory_fin_aid           BOOLEAN ;
	v_mandatory_acad_honors       BOOLEAN ;
	v_mandatory_des_unitsets      BOOLEAN ;  -- added for 2382599
        v_mandatory_excurr           BOOLEAN ;  -- added for 2682078 Person actitivies by rrengara on 24-NOV-2002

	CURSOR	c_acaiv IS
		SELECT	aa.person_id,
			aa.adm_appl_status,
			aa.adm_fee_status,
			aa.admission_cat,
			aa.s_admission_process_type,
			aa.appl_dt,
			acaiv.adm_doc_status,
			acaiv.adm_entry_qual_status,
			acaiv.late_adm_fee_status,
			acaiv.adm_outcome_status,
			acaiv.adm_cndtnl_offer_status,
			acaiv.adm_offer_resp_status,
			acaiv.adm_offer_dfrmnt_status,
			aca.req_for_reconsideration_ind,
			acaiv.course_cd,
			acaiv.crv_version_number,
			aa.acad_cal_type,
			aa.acad_ci_sequence_number,
			acaiv.location_cd,
			acaiv.attendance_mode,
			acaiv.attendance_type,
			acaiv.adm_cal_type,
			acaiv.adm_ci_sequence_number
		FROM
			igs_ad_appl			aa,
			igs_ad_ps_appl_inst		acaiv, /* Replacing IGS_AD_PS_APPL_INST_APLINST_V with base tables Bug: 3150054 */
			igs_ad_ps_appl                  aca
		WHERE
			acaiv.person_id 		= p_person_id			AND
			acaiv.admission_appl_number	= p_admission_appl_number	AND
			acaiv.nominated_course_cd	= p_nominated_course_cd		AND
			acaiv.sequence_number		= p_acai_sequence_number	AND
			aa.person_id			= acaiv.person_id		AND
		 	aa.admission_appl_number	= acaiv.admission_appl_number   AND
			aa.person_id                    = aca.person_id               AND
			acaiv.admission_appl_number        = aca.admission_appl_number   AND
			acaiv.nominated_course_cd          = aca.nominated_course_cd;
	v_acaiv_rec		c_acaiv%ROWTYPE;
BEGIN
	-- Validate parameters
	IF p_person_id IS NULL OR
			p_admission_appl_number IS NULL OR
			p_nominated_course_cd IS NULL OR
			p_acai_sequence_number IS NULL THEN
		RETURN NULL;
	END IF;
	v_effective_dt := TRUNC(SYSDATE);
	OPEN c_acaiv;
	FETCH c_acaiv INTO v_acaiv_rec;
	CLOSE c_acaiv;
	IGS_AD_GEN_004.admp_get_apcs_val(
		v_acaiv_rec.admission_cat,
		v_acaiv_rec.s_admission_process_type,
		v_apcs_pref_limit_ind,		-- OUT,
		v_apcs_app_fee_ind,		-- OUT,
		v_apcs_late_app_ind,		-- OUT,
		v_apcs_late_fee_ind,		-- OUT,
		v_apcs_chkpencumb_ind,		-- OUT,
		v_apcs_fee_assess_ind,		-- OUT,
		v_apcs_corcategry_ind,		-- OUT,
		v_apcs_enrcategry_ind,		-- OUT,
		v_apcs_chkcencumb_ind,		-- OUT,
		v_apcs_unit_set_ind,		-- OUT,
		v_apcs_un_crs_us_ind,		-- OUT,
		v_apcs_chkuencmb_ind,		-- OUT,
		v_apcs_unit_restr_ind,		-- OUT,
		v_apcs_unit_restriction_num,	-- OUT,
		v_apcs_un_dob_ind,		-- OUT,
		v_apcs_un_title_ind,		-- OUT,
		v_apcs_asses_cond_ind,		-- OUT,
		v_apcs_fee_cond_ind,		-- OUT,
		v_apcs_doc_cond_ind,		-- OUT,
		v_apcs_multi_off_ind,		-- OUT,
		v_apcs_multi_off_restrict_num,	-- OUT,
		v_apcs_set_otcome_ind,		-- OUT,
		v_apcs_override_o_ind,		-- OUT,
		v_apcs_defer_ind_ind,		-- OUT,
		v_apcs_ack_app_ind,		-- OUT,
		v_apcs_outcome_lt_ind,		-- OUT,
		v_apcs_pre_enrol_ind);		-- OUT)
	IF IGS_AD_VAL_ACAI.admp_val_acai_late(
			v_acaiv_rec.appl_dt,
			v_acaiv_rec.course_cd,
			v_acaiv_rec.crv_version_number,
			v_acaiv_rec.acad_cal_type,
			v_acaiv_rec.location_cd,
			v_acaiv_rec.attendance_mode,
			v_acaiv_rec.attendance_type,
			v_acaiv_rec.adm_cal_type,
			v_acaiv_rec.adm_ci_sequence_number,
			v_acaiv_rec.admission_cat,
			v_acaiv_rec.s_admission_process_type,
			v_apcs_late_app_ind,
			v_message_name) = FALSE THEN	-- OUT NOCOPY
		v_late := TRUE;
	ELSE
		v_late := FALSE;
	END IF;
	IF IGS_AD_VAL_ACAI.admp_val_acai_encmb(
			v_acaiv_rec.person_id,
			v_acaiv_rec.course_cd,
			v_acaiv_rec.adm_cal_type,
			v_acaiv_rec.adm_ci_sequence_number,
			v_apcs_chkcencumb_ind,
			'Y',
			v_message_name,			-- OUT,
			v_return_type) = FALSE THEN	-- OUT NOCOPY
		v_encumbrance := TRUE;
	ELSE
		v_encumbrance := FALSE;
	END IF;
	IF IGS_AD_VAL_ACAI.admp_val_acai_cop(
			v_acaiv_rec.course_cd,
			v_acaiv_rec.crv_version_number,
			v_acaiv_rec.location_cd,
			v_acaiv_rec.attendance_mode,
			v_acaiv_rec.attendance_type,
			v_acaiv_rec.acad_cal_type,
			v_acaiv_rec.acad_ci_sequence_number,
			v_acaiv_rec.adm_cal_type,
			v_acaiv_rec.adm_ci_sequence_number,
			v_acaiv_rec.admission_cat,
			v_acaiv_rec.s_admission_process_type,
			'N',
			v_acaiv_rec.appl_dt,
			v_apcs_late_app_ind,
			'N',
			v_message_name,		-- OUT,
			v_return_type,		-- OUT,
			v_late_ind) = FALSE THEN -- OUT NOCOPY
		v_course_invalid := TRUE;
	ELSE
		v_course_invalid := FALSE;
	END IF;
	IF v_acaiv_rec.req_for_reconsideration_ind = 'Y' THEN
		v_reconsideration := TRUE;
	ELSE
		v_reconsideration := FALSE;
	END IF;
	-- Call procedure to find mandatory fields
	IGS_AD_GEN_003.admp_get_apcs_mndtry(
			v_acaiv_rec.admission_cat,
			v_acaiv_rec.s_admission_process_type,
			v_mandatory_athletics,	--	OUT,
			v_mandatory_alternate,	--	OUT,
			v_mandatory_address,	--	OUT,
			v_mandatory_disability,	--	OUT,
			v_mandatory_visa,	--	OUT,
			v_mandatory_finance,	--	OUT,
			v_mandatory_notes,	--	OUT,
			v_mandatory_statistics,	--	OUT,
			v_mandatory_alias,	--	OUT,
			v_mandatory_tertiary,	--	OUT,
			v_mandatory_aus_sec_ed,	--	OUT,
			v_mandatory_os_sec_ed,	--	OUT,
			v_mandatory_employment,	--	OUT,
			v_mandatory_membership,	--	OUT,
			v_mandatory_dob,	--	OUT,
			v_mandatory_title,	--	OUT,
			v_mandatory_referee,	--	OUT,
			v_mandatory_scholarship,--	OUT,
			v_mandatory_lang_prof,	--	OUT,
			v_mandatory_interview,	--	OUT,
			v_mandatory_exchange,	--	OUT,
			v_mandatory_adm_test,	--	added 17/11/98
			v_mandatory_fee_assess,	--	OUT,
			v_mandatory_cor_category,	-- OUT,
			v_mandatory_enr_category,	-- OUT,
			v_mandatory_research,	--	OUT,
			v_mandatory_rank_app,	--	OUT,
			v_mandatory_completion,	--	OUT,
			v_mandatory_rank_set,	--	OUT,
			v_mandatory_basis_adm,	--	OUT,
			v_mandatory_crs_international,	-- OUT,
			v_mandatory_ass_tracking,	-- OUT,
			v_mandatory_adm_code,	--	OUT,
			v_mandatory_fund_source,	--added 17/11/98
			v_mandatory_location,	--	OUT,
			v_mandatory_att_mode,	--	OUT,
			v_mandatory_att_type,	--	OUT,
			v_mandatory_unit_set,	--	OUT)
			v_mandatory_evaluation_tab,
			v_mandatory_prog_approval ,
			v_mandatory_indices       ,
			v_mandatory_tst_scores   ,
			v_mandatory_outcome       ,
			v_mandatory_override      ,
			v_mandatory_spl_consider ,
			v_mandatory_cond_offer    ,
			v_mandatory_offer_dead    ,
			v_mandatory_offer_resp    ,
			v_mandatory_offer_defer   ,
			v_mandatory_offer_compl   ,
			v_mandatory_transfer      ,
			v_mandatory_other_inst   ,
			v_mandatory_edu_goals   ,
			v_mandatory_acad_interest ,
			v_mandatory_app_intent    ,
			v_mandatory_spl_interest  ,
			v_mandatory_spl_talents   ,
			v_mandatory_miscell       ,
			v_mandatory_fees          ,
			v_mandatory_program      ,
			v_mandatory_completness   ,
			v_mandatory_creden        ,
			v_mandatory_review_det   ,
			v_mandatory_recomm_det ,
			v_mandatory_fin_aid       ,
			v_mandatory_acad_honors  ,
                        v_mandatory_des_unitsets,    -- added for 2382599
			v_mandatory_excurr); -- added for Bug 2682078 Person activities by rrengara on 24-NOV-2002

	-- Call function to validate any mandatory steps exists for IGS_PE_PERSON.
	v_incomplete := FALSE;
	IF IGS_AD_VAL_ACAI.admp_val_pe_comp(
			p_person_id,
			v_effective_dt,
			v_mandatory_athletics,
			v_mandatory_alternate,
			v_mandatory_address,
			v_mandatory_disability,
			v_mandatory_visa,
			v_mandatory_finance,
			v_mandatory_notes,
			v_mandatory_statistics,
			v_mandatory_alias,
			v_mandatory_tertiary,
			v_mandatory_aus_sec_ed,
			v_mandatory_os_sec_ed,
			v_mandatory_employment,
			v_mandatory_membership,
			v_mandatory_dob,
			v_mandatory_title,
			v_mandatory_excurr,
			v_message_name,		-- OUT,
			v_valid_athletics,	-- OUT,
			v_valid_alternate,	-- OUT,
			v_valid_address,	-- OUT,
			v_valid_disability,	-- OUT,
			v_valid_visa,		-- OUT,
			v_valid_finance,	-- OUT,
			v_valid_notes,		-- OUT,
			v_valid_statistics,	-- OUT,
			v_valid_alias,		-- OUT,
			v_valid_tertiary,	-- OUT,
			v_valid_aus_sec_ed,	-- OUT,
			v_valid_os_sec_ed,	-- OUT,
			v_valid_employment,	-- OUT,
			v_valid_membership,	-- OUT,
			v_valid_dob,		-- OUT,
			v_valid_title,
			v_valid_excurr  ) = FALSE THEN	-- OUT NOCOPY
		v_incomplete := TRUE;
	END IF;
	-- Call function to validate any mandatory steps exists for admission IGS_PS_COURSE
 	-- application instance.
	IF IGS_AD_VAL_ACAI.admp_val_acai_comp(
			p_person_id,
			p_admission_appl_number,
			p_nominated_course_cd,
			p_acai_sequence_number,
			v_acaiv_rec.course_cd,
			v_acaiv_rec.crv_version_number,	--added 17/11/98
			v_acaiv_rec.s_admission_process_type,
			v_effective_dt,
			v_mandatory_referee,
			v_mandatory_scholarship,
			v_mandatory_lang_prof,
			v_mandatory_interview,
			v_mandatory_exchange,
			v_mandatory_adm_test,		--added 17/11/98
			v_mandatory_fee_assess,
			v_mandatory_cor_category,
			v_mandatory_enr_category,
			v_mandatory_research,
			v_mandatory_rank_app,
			v_mandatory_completion,
			v_mandatory_rank_set,
			v_mandatory_basis_adm,
			v_mandatory_crs_international,
			v_mandatory_ass_tracking,
			v_mandatory_adm_code,
			v_mandatory_fund_source,	--added 17/11/98
			v_mandatory_location,
			v_mandatory_att_mode,
			v_mandatory_att_type,
			v_mandatory_unit_set,
			v_message_name,
			v_valid_referee,	-- OUT,
			v_valid_scholarship,	-- OUT,
			v_valid_lang_prof,	-- OUT,
			v_valid_interview,	-- OUT,
			v_valid_exchange,	-- OUT,
			v_valid_adm_test,	--added 17/11/98
			v_valid_fee_assess,	-- OUT,
			v_valid_cor_category,	-- OUT,
			v_valid_enr_category,	-- OUT,
			v_valid_research,	-- OUT,
			v_valid_rank_app,	-- OUT,
			v_valid_completion,	-- OUT,
			v_valid_rank_set,	-- OUT,
			v_valid_basis_adm,	-- OUT,
			v_valid_crs_international,	-- OUT,
			v_valid_ass_tracking,	-- OUT,
			v_valid_adm_code,	-- OUT,
			v_valid_fund_source,	--added 17/11/98
			v_valid_location,	-- OUT,
			v_valid_att_mode,	-- OUT,
			v_valid_att_type,	-- OUT,
			v_valid_unit_set) = FALSE THEN	-- OUT NOCOPY
		v_incomplete := TRUE;
	END IF;
	v_out_string := IGS_RU_GEN_004.rulp_val_adm_status(
				p_s_letter_parameter_type,
				v_acaiv_rec.adm_appl_status,
				v_acaiv_rec.adm_fee_status,
				v_acaiv_rec.adm_doc_status,
				v_acaiv_rec.adm_entry_qual_status,
				v_acaiv_rec.late_adm_fee_status,
				v_acaiv_rec.adm_outcome_status,
				v_acaiv_rec.adm_cndtnl_offer_status,
				v_acaiv_rec.adm_offer_resp_status,
				v_acaiv_rec.adm_offer_dfrmnt_status,
				v_reconsideration,
				v_encumbrance,
				v_course_invalid,
				v_late,
				v_incomplete,
				p_correspondence_type,
				v_valid_alternate,
				v_valid_address,
				v_valid_disability,
				v_valid_visa,
				v_valid_finance,
				v_valid_notes,
				v_valid_statistics,
				v_valid_alias,
				v_valid_tertiary,
				v_valid_aus_sec_ed,
				v_valid_os_sec_ed,
				v_valid_employment,
				v_valid_membership,
				v_valid_dob,
				v_valid_title,
				v_valid_referee,
				v_valid_scholarship,
				v_valid_lang_prof,
				v_valid_interview,
				v_valid_exchange,
				v_valid_adm_test,
				v_valid_fee_assess,
				v_valid_cor_category,
				v_valid_enr_category,
				v_valid_research,
				v_valid_rank_app,
				v_valid_completion,
				v_valid_rank_set,
				v_valid_basis_adm,
				v_valid_crs_international,
				v_valid_ass_tracking,
				v_valid_adm_code,
				v_valid_fund_source,
				v_valid_location,
				v_valid_att_mode,
				v_valid_att_type,
				v_valid_unit_set);
	RETURN v_out_string;
EXCEPTION
	WHEN OTHERS THEN
		IF(c_acaiv%ISOPEN) THEN
			CLOSE c_acaiv;
		END IF;
	RAISE;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_status_rule');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_status_rule ;

Function Admp_Get_Sys_Aas(
  p_s_adm_appl_status IN VARCHAR2 )
RETURN VARCHAR2 IS
	gv_other_detail		VARCHAR2(255);
BEGIN	-- admp_get_sys_aas
	-- routine to return the user-defined system default admission application
	-- status for the given system admission application status
DECLARE
	CURSOR c_aas IS
		SELECT	aas.adm_appl_status
		FROM	IGS_AD_APPL_STAT aas
		WHERE	aas.s_adm_appl_status 	= p_s_adm_appl_status AND
			aas.system_default_ind  = 'Y' AND
			aas.closed_ind	        = 'N';
	v_adm_appl_status		IGS_AD_APPL_STAT.adm_appl_status%TYPE := NULL;
BEGIN
	FOR v_aas_rec IN c_aas LOOP
		IF c_aas%ROWCOUNT > 1 THEN
			v_adm_appl_status := NULL;
			exit;
		END IF;
		v_adm_appl_status := v_aas_rec.adm_appl_status;
	END LOOP;
	-- return null if no records or more than one record found
	RETURN v_adm_appl_status;
END;
EXCEPTION
	WHEN OTHERS THEN
	    Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
	    Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.admp_get_sys_aas');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
END admp_get_sys_aas;

PROCEDURE get_acad_cal (
   p_adm_cal_type         IN OUT NOCOPY   igs_ca_type.cal_type%TYPE,
   p_adm_seq              IN OUT NOCOPY   igs_ca_inst.sequence_number%TYPE,
   p_acad_cal_type        OUT NOCOPY      igs_ca_type.cal_type%TYPE,
   p_acad_seq             OUT NOCOPY      igs_ca_inst.sequence_number%TYPE,
   p_adm_alternate_code   OUT NOCOPY      igs_ca_inst.alternate_code%TYPE,
   p_message              OUT NOCOPY      VARCHAR2
)
AS

------------------------------------------------------------------
--Created by  : Karthikeyan Mohan, Oracle India
--Date created: 31-AUG-2001
--
--Purpose: This procedure gets the Admission Sequence Number if not passed
--         Academic Calendar and the Academic Calendar Sequence
--
--
--Known limitations/enhancements and/or remarks:
--
--Change History:
--Who         When            What
-- kamohan   3/30/02          For bug 2252875
-- kamohan     5/may-2002 Bug 2321651 Modified the cursor query for defaulting the alternate code
--hreddych  16-jun-2003       2890319 Modified the cur_sequence query
-------------------------------------------------------------------
   l_start_dt     DATE;
   l_end_dt       DATE;
   l_out          VARCHAR2 (2000);


-- Cursor for getting the Calendar Sequence for the
-- Calendar Type. The Calendar Instance Selected for this calendar
-- should be the nearest one to the System Date
   CURSOR cur_sequence (cp_cal_type igs_ca_type.cal_type%TYPE)
   IS
      SELECT   ci_adm.sequence_number adm_sequence_number,
               ci_acad.cal_type acad_cal_type,
               ci_acad.sequence_number acad_sequence_number,
               ci_adm.alternate_code adm_alternate_code
          FROM igs_ca_type ct_adm,
               igs_ca_inst ci_adm,
               igs_ca_stat cs,
               igs_ca_inst_rel cir,
               igs_ca_inst ci_acad,
               igs_ca_type ct_acad
         WHERE ct_adm.cal_type = cp_cal_type
           AND ct_adm.cal_type = ci_adm.cal_type
           AND SYSDATE <= ci_adm.end_dt
           AND ct_adm.s_cal_cat = 'ADMISSION'
           AND ci_adm.cal_status = cs.cal_status
           AND cs.s_cal_status = 'ACTIVE'
           AND ci_adm.cal_type = cir.sub_cal_type
           AND ci_adm.sequence_number = cir.sub_ci_sequence_number
           AND ct_acad.cal_type = ci_acad.cal_type
           AND ci_acad.cal_type = cir.sup_cal_type
           AND ci_acad.sequence_number = cir.sup_ci_sequence_number
           AND ct_acad.s_cal_cat = 'ACADEMIC'
      ORDER BY ci_adm.start_dt;

   sequence_rec   cur_sequence%ROWTYPE;

   CURSOR cur_adm_cal_conf
   IS
      SELECT inq_cal_type
        FROM igs_ad_cal_conf;
BEGIN
   p_message := NULL;


-- If the Admission Calendar Instance is not defined
-- then derive the Admisssion Calendar Instance

   IF p_adm_seq IS NULL
   THEN
      IF p_adm_cal_type IS NULL
      THEN
         OPEN cur_adm_cal_conf;
         FETCH cur_adm_cal_conf INTO p_adm_cal_type;
         CLOSE cur_adm_cal_conf;

-- If there is no default calendar set up then
-- return the proper error message.

	 IF p_adm_cal_type IS NULL
         THEN
            p_message := 'IGS_AD_INQ_DFLT_ADMCAL_NOTDFN';
            RETURN;
         END IF;
      END IF;

      OPEN cur_sequence (p_adm_cal_type);
      FETCH cur_sequence INTO sequence_rec;

-- If there is no admission calendar instance without any academic calendar associated with it and does not satisy the start date, end date
-- conditions provide proper error message.

      IF cur_sequence%NOTFOUND
      THEN
         p_message := 'IGS_AD_INQ_ADMCAL_SEQ_NOTDFN';
         RETURN;
      END IF;

      p_adm_seq := sequence_rec.adm_sequence_number;
      p_acad_cal_type := sequence_rec.acad_cal_type;
      p_acad_seq := sequence_rec.acad_sequence_number;
      p_adm_alternate_code := sequence_rec.adm_alternate_code;
      CLOSE cur_sequence;
   END IF;
EXCEPTION
   WHEN OTHERS
   THEN
      IF cur_adm_cal_conf%ISOPEN
      THEN
         CLOSE cur_adm_cal_conf;
      END IF;

      IF cur_sequence%ISOPEN
      THEN
         CLOSE cur_sequence;
      END IF;
      Fnd_Message.Set_Name('IGS','IGS_GE_UNHANDLED_EXP');
      Fnd_Message.Set_Token('NAME','IGS_AD_GEN_008.get_acad_cal');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
END get_acad_cal;

END igs_ad_gen_008;

/
