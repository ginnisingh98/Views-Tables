--------------------------------------------------------
--  DDL for Package Body IGS_AU_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AU_GEN_001" AS
/* $Header: IGSAU01B.pls 115.7 2003/12/03 20:48:58 knag ship $ */
Function Audp_Get_Aah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AD_APPL_HIST_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_hist_end_dt IN IGS_AD_APPL_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_aah_col
	-- get the oldest column value (after a given date) for a
	-- specified column and person_id, admission_appl_number
	-- for IGS_AD_APPL_HIST table
DECLARE
	cst_appl_dt			CONSTANT	VARCHAR2(7) := 'APPL_DT';
	cst_acad_cal_type		CONSTANT	VARCHAR2(13) := 'ACAD_CAL_TYPE';
	cst_acad_ci_sequence_number	CONSTANT	VARCHAR2(23) := 'ACAD_CI_SEQUENCE_NUMBER';
	cst_adm_cal_type		CONSTANT	VARCHAR2(12) := 'ADM_CAL_TYPE';
	cst_adm_ci_sequence_number	CONSTANT	VARCHAR2(22) := 'ADM_CI_SEQUENCE_NUMBER';
	cst_admission_cat		CONSTANT	VARCHAR2(13) := 'ADMISSION_CAT';
	cst_s_admission_process_type	CONSTANT
							VARCHAR2(24) := 'S_ADMISSION_PROCESS_TYPE';
	cst_adm_appl_status		CONSTANT	VARCHAR2(15) := 'ADM_APPL_STATUS';
	cst_adm_fee_status		CONSTANT	VARCHAR2(14) := 'ADM_FEE_STATUS';
	cst_tac_appl_ind		CONSTANT	VARCHAR2(12) := 'TAC_APPL_IND';
	CURSOR c_aah IS
		SELECT
			DECODE (
				p_column_name,
				cst_appl_dt,			IGS_GE_DATE.igschar(aah.appl_dt),
				cst_acad_cal_type,			aah.acad_cal_type,
				cst_acad_ci_sequence_number,	TO_CHAR(aah.acad_ci_sequence_number),
				cst_adm_cal_type,			aah.adm_cal_type,
				cst_adm_ci_sequence_number,	TO_CHAR(aah.adm_ci_sequence_number),
				cst_admission_cat,		aah.ADMISSION_CAT,
				cst_s_admission_process_type,	aah.s_admission_process_type,
				cst_adm_appl_status,		aah.ADM_APPL_STATUS,
				cst_adm_fee_status,		aah.ADM_FEE_STATUS,
				cst_tac_appl_ind,			aah.tac_appl_ind)
		FROM	IGS_AD_APPL_HIST	aah
		WHERE	aah.person_id		= p_person_id AND
			aah.admission_appl_number	= p_admission_appl_number AND
			aah.hist_start_dt		>= p_hist_end_dt AND
			DECODE (
				p_column_name,
				cst_appl_dt,			IGS_GE_DATE.igschar(aah.appl_dt),
				cst_acad_cal_type,			aah.acad_cal_type,
				cst_acad_ci_sequence_number,	TO_CHAR(aah.acad_ci_sequence_number),
				cst_adm_cal_type,			aah.adm_cal_type,
				cst_adm_ci_sequence_number,	TO_CHAR(aah.adm_ci_sequence_number),
				cst_admission_cat,		aah.ADMISSION_CAT,
				cst_s_admission_process_type,	aah.s_admission_process_type,
				cst_adm_appl_status,		aah.ADM_APPL_STATUS,
				cst_adm_fee_status,		aah.ADM_FEE_STATUS,
				cst_tac_appl_ind,			aah.tac_appl_ind) IS NOT NULL
		ORDER BY
			aah.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
BEGIN
	OPEN c_aah;
	FETCH c_aah INTO v_column_value;
	CLOSE c_aah;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF c_aah%ISOPEN THEN
			CLOSE c_aah;
		END IF;
		RAISE;
END;
END audp_get_aah_col;

Function Audp_Get_Acah_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN IGS_AD_PS_APPL_HIST_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_hist_end_dt IN IGS_AD_PS_APPL_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_acah_col
	-- get the oldest column value (after a given date) for a
	-- specified column and admission_cd, nominated_course_cd for
	-- IGS_AD_PS_APPL_HIST table
DECLARE
	cst_transfer_course_cd		CONSTANT	VARCHAR2(18) := 'TRANSFER_COURSE_CD';
	cst_basis_for_admission_type    CONSTANT
							VARCHAR2(24) := 'BASIS_FOR_ADMISSION_TYPE';
	cst_admission_cd		CONSTANT	VARCHAR2(12) := 'ADMISSION_CD';
	cst_course_rank_set		CONSTANT	VARCHAR2(15) := 'COURSE_RANK_SET';
	cst_course_rank_schedule	CONSTANT	VARCHAR2(20) := 'COURSE_RANK_SCHEDULE';
	cst_req_for_reconsideratn_ind	CONSTANT
							VARCHAR2(27) :='REQ_FOR_RECONSIDERATION_IND';
	cst_req_for_adv_standing_ind	CONSTANT
							VARCHAR2(24) := 'REQ_FOR_ADV_STANDING_IND';
	CURSOR c_acah IS
		SELECT
			DECODE (
				p_column_name,
				cst_transfer_course_cd,		acah.transfer_course_cd,
				cst_basis_for_admission_type,	acah.basis_for_admission_type,
				cst_admission_cd,			acah.ADMISSION_CD,
				cst_course_rank_set,		acah.course_rank_set,
				cst_course_rank_schedule,		acah.course_rank_schedule,
				cst_req_for_reconsideratn_ind,	acah.req_for_reconsideration_ind,
				cst_req_for_adv_standing_ind,	acah.req_for_adv_standing_ind)
		FROM	IGS_AD_PS_APPL_HIST	acah
		WHERE	acah.person_id			= p_person_id	 AND
			acah.admission_appl_number	= p_admission_appl_number AND
			acah.nominated_course_cd		= p_nominated_course_cd AND
			acah.hist_start_dt			>= p_hist_end_dt AND
			DECODE (
				p_column_name,
				cst_transfer_course_cd,		acah.transfer_course_cd,
				cst_basis_for_admission_type,	acah.basis_for_admission_type,
				cst_admission_cd,		acah.ADMISSION_CD,
				cst_course_rank_set,		acah.course_rank_set,
				cst_course_rank_schedule,	acah.course_rank_schedule,
				cst_req_for_reconsideratn_ind,	acah.req_for_reconsideration_ind,
				cst_req_for_adv_standing_ind,	acah.req_for_adv_standing_ind) IS NOT NULL
		ORDER BY
			acah.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
BEGIN
	OPEN c_acah;
	FETCH c_acah INTO v_column_value;
	CLOSE c_acah;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF c_acah%ISOPEN THEN
			CLOSE c_acah;
		END IF;
		RAISE;
END;
END audp_get_acah_col;

Function Audp_Get_Acaih_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_acaih_col
	-- get the oldest column value (after a given date) for a
	-- specified column and person_id, admission_appl_number,
	-- nominated_course_cd and sequence_number for
	-- IGS_AD_PS_APLINSTHST table
DECLARE
	cst_hist_offer_round_number		CONSTANT
								VARCHAR2(23) := 'HIST_OFFER_ROUND_NUMBER';
	cst_adm_cal_type			CONSTANT	VARCHAR2(12) := 'ADM_CAL_TYPE';
	cst_adm_ci_sequence_number		CONSTANT	VARCHAR2(22) := 'ADM_CI_SEQUENCE_NUMBER';
	cst_course_cd				CONSTANT	VARCHAR2(9)  := 'COURSE_CD';
	cst_crv_version_number			CONSTANT	VARCHAR2(18) := 'CRV_VERSION_NUMBER';
	cst_location_cd				CONSTANT	VARCHAR2(11) := 'LOCATION_CD';
	cst_attendance_mode			CONSTANT	VARCHAR2(15) := 'ATTENDANCE_MODE';
	cst_attendance_type			CONSTANT	VARCHAR2(15) := 'ATTENDANCE_TYPE';
	cst_unit_set_cd				CONSTANT	VARCHAR2(11) := 'UNIT_SET_CD';
	cst_us_version_number			CONSTANT	VARCHAR2(17) := 'US_VERSION_NUMBER';
	cst_preference_number			CONSTANT	VARCHAR2(17) := 'PREFERENCE_NUMBER';
	cst_adm_doc_status			CONSTANT	VARCHAR2(14) := 'ADM_DOC_STATUS';
	cst_adm_entry_qual_status		CONSTANT	VARCHAR2(21) := 'ADM_ENTRY_QUAL_STATUS';
	cst_late_adm_fee_status			CONSTANT	VARCHAR2(19) := 'LATE_ADM_FEE_STATUS';
	cst_adm_outcome_status       		CONSTANT	VARCHAR2(18) := 'ADM_OUTCOME_STATUS';
	cst_adm_otcm_stus_auth_prsn_id		CONSTANT
								VARCHAR2(30) := 'ADM_OTCM_STATUS_AUTH_PERSON_ID';
	cst_adm_outcome_status_auth_dt		CONSTANT
								VARCHAR2(26) := 'ADM_OUTCOME_STATUS_AUTH_DT';
	cst_adm_outcome_status_reason		CONSTANT
								VARCHAR2(25) := 'ADM_OUTCOME_STATUS_REASON';
	cst_offer_dt				CONSTANT	VARCHAR2(8)  := 'OFFER_DT';
	cst_offer_response_dt           	CONSTANT	VARCHAR2(17) := 'OFFER_RESPONSE_DT';
	cst_prpsd_commencement_dt		CONSTANT	VARCHAR2(30) := 'PRPSD_COMMENCEMENT_DT';
	cst_adm_cndtnl_offer_status        	CONSTANT
								VARCHAR2(23) := 'ADM_CNDTNL_OFFER_STATUS';
	cst_cndtnl_offer_satisfied_dt 		CONSTANT
								VARCHAR2(25) := 'CNDTNL_OFFER_SATISFIED_DT';
	cst_cndtnl_offer_must_be_stsfd		CONSTANT
								VARCHAR2(30) :=  'CNDTNL_OFFER_MUST_BE_STSFD_IND';
	cst_adm_offer_resp_status		CONSTANT	VARCHAR2(21) := 'ADM_OFFER_RESP_STATUS';
	cst_actual_response_dt			CONSTANT	VARCHAR2(18) := 'ACTUAL_RESPONSE_DT';
	cst_adm_offer_dfrmnt_status 		CONSTANT
								VARCHAR2(23) := 'ADM_OFFER_DFRMNT_STATUS';
	cst_deferred_adm_cal_type          	CONSTANT
								VARCHAR2(21) := 'DEFERRED_ADM_CAL_TYPE';
	cst_defer_adm_ci_sequnc_num   		CONSTANT
								VARCHAR2(28) := 'DEFERRED_ADM_CI_SEQUENCE_NUM';
	cst_deferred_tracking_id       		CONSTANT
								VARCHAR2(20) := 'DEFERRED_TRACKING_ID';
	cst_ass_rank				CONSTANT	VARCHAR2(8)  := 'ASS_RANK';
	cst_secondary_ass_rank			CONSTANT	VARCHAR2(18) := 'SECONDARY_ASS_RANK';
	cst_intrnnl_accptnce_adv_num		CONSTANT
								VARCHAR2(30) := 'INTRNTNL_ACCEPTANCE_ADVICE_NUM';
	cst_ass_tracking_id			CONSTANT	VARCHAR2(15) := 'ASS_TRACKING_ID';
	cst_fee_cat				CONSTANT	VARCHAR2(7)  := 'FEE_CAT';
	cst_hecs_payment_option			CONSTANT	VARCHAR2(19) := 'HECS_PAYMENT_OPTION';
	cst_expected_completion_yr		CONSTANT	VARCHAR2(22) := 'EXPECTED_COMPLETION_YR';
	cst_expected_completion_perd		CONSTANT
								VARCHAR2(24) := 'EXPECTED_COMPLETION_PERD';
	cst_correspondence_cat        		CONSTANT	VARCHAR2(18) := 'CORRESPONDENCE_CAT';
	cst_enrolment_cat			CONSTANT	VARCHAR2(13) := 'ENROLMENT_CAT';
	cst_funding_source			CONSTANT	VARCHAR2(15) := 'FUNDING_SOURCE';
	cst_applicant_acptnce_cndtn		CONSTANT
								VARCHAR2(23) := 'APPLICANT_ACPTNCE_CNDTN';
	cst_cndtnl_offer_cndtn			CONSTANT	VARCHAR2(18) := 'CNDTNL_OFFER_CNDTN';
	CURSOR c_acaih IS
		SELECT
			DECODE (
				p_column_name,
				cst_hist_offer_round_number, 	TO_CHAR(acaih.hist_offer_round_number),
				cst_adm_cal_type,		acaih.adm_cal_type,
				cst_adm_ci_sequence_number,  	TO_CHAR(acaih.adm_ci_sequence_number),
				cst_course_cd,			acaih.course_cd,
				cst_crv_version_number,		TO_CHAR(acaih.crv_version_number),
				cst_location_cd,		acaih.location_cd,
				cst_attendance_mode,		acaih.ATTENDANCE_MODE,
				cst_attendance_type,		acaih.ATTENDANCE_TYPE,
				cst_unit_set_cd,		acaih.unit_set_cd,
				cst_us_version_number,    	TO_CHAR(acaih.us_version_number),
				cst_preference_number,		TO_CHAR(acaih.preference_number),
				cst_adm_doc_status,		acaih.ADM_DOC_STATUS,
				cst_adm_entry_qual_status, 	acaih.ADM_ENTRY_QUAL_STATUS,
				cst_late_adm_fee_status,	acaih.late_adm_fee_status,
				cst_adm_outcome_status,		acaih.ADM_OUTCOME_STATUS,
				cst_adm_otcm_stus_auth_prsn_id,
								TO_CHAR(acaih.adm_otcm_status_auth_person_id),
				cst_adm_outcome_status_auth_dt,
								IGS_GE_DATE.igschar(acaih.adm_outcome_status_auth_dt),
				cst_adm_outcome_status_reason, 	acaih.adm_outcome_status_reason,
				cst_offer_dt,			IGS_GE_DATE.igschar(acaih.offer_dt),
				cst_offer_response_dt,		IGS_GE_DATE.igschar(acaih.offer_response_dt),
				cst_prpsd_commencement_dt,
								IGS_GE_DATE.igschar(acaih.prpsd_commencement_dt),
				cst_adm_cndtnl_offer_status,	acaih.ADM_CNDTNL_OFFER_STATUS,
				cst_cndtnl_offer_satisfied_dt,
								IGS_GE_DATE.igschar(acaih.cndtnl_offer_satisfied_dt),
				cst_cndtnl_offer_must_be_stsfd,	acaih.cndtnl_offer_must_be_stsfd_ind,
				cst_adm_offer_resp_status,	acaih.ADM_OFFER_RESP_STATUS,
				cst_actual_response_dt,		IGS_GE_DATE.igschar(acaih.actual_response_dt),
				cst_adm_offer_dfrmnt_status,    acaih.ADM_OFFER_DFRMNT_STATUS,
				cst_deferred_adm_cal_type,      acaih.deferred_adm_cal_type,
				cst_defer_adm_ci_sequnc_num, 	TO_CHAR(acaih.deferred_adm_ci_sequence_num),
				cst_deferred_tracking_id,      	TO_CHAR(acaih.deferred_tracking_id),
				cst_ass_rank,               	TO_CHAR(acaih.ass_rank),
				cst_secondary_ass_rank,      	TO_CHAR(acaih.secondary_ass_rank),
				cst_intrnnl_accptnce_adv_num,
								TO_CHAR(acaih.intrntnl_acceptance_advice_num),
				cst_ass_tracking_id,         	TO_CHAR(acaih.ass_tracking_id),
				cst_fee_cat,           		acaih.FEE_CAT,
				cst_hecs_payment_option,    	acaih.HECS_PAYMENT_OPTION,
				cst_expected_completion_yr,   	TO_CHAR(acaih.expected_completion_yr),
				cst_expected_completion_perd,  	acaih.expected_completion_perd,
				cst_correspondence_cat,		acaih.CORRESPONDENCE_CAT,
				cst_enrolment_cat,		acaih.ENROLMENT_CAT,
				cst_funding_source,		acaih.FUNDING_SOURCE,
				cst_applicant_acptnce_cndtn,   	acaih.applicant_acptnce_cndtn,
				cst_cndtnl_offer_cndtn,		acaih.cndtnl_offer_cndtn)
		FROM	IGS_AD_PS_APLINSTHST	acaih
		WHERE	acaih.person_id			= p_person_id AND
			acaih.admission_appl_number	= p_admission_appl_number AND
			acaih.nominated_course_cd	= p_nominated_course_cd AND
			acaih.sequence_number		= p_sequence_number AND
			acaih.hist_start_dt		>= p_hist_end_dt AND
			DECODE (
				p_column_name,
				cst_hist_offer_round_number, 	TO_CHAR(acaih.hist_offer_round_number),
				cst_adm_cal_type,		acaih.adm_cal_type,
				cst_adm_ci_sequence_number,  	TO_CHAR(acaih.adm_ci_sequence_number),
				cst_course_cd,			acaih.course_cd,
				cst_crv_version_number,		TO_CHAR(acaih.crv_version_number),
				cst_location_cd,		acaih.location_cd,
				cst_attendance_mode,		acaih.ATTENDANCE_MODE,
				cst_attendance_type,		acaih.ATTENDANCE_TYPE,
				cst_unit_set_cd,		acaih.unit_set_cd,
				cst_us_version_number,		TO_CHAR(acaih.us_version_number),
				cst_preference_number,		TO_CHAR(acaih.preference_number),
				cst_adm_doc_status,		acaih.ADM_DOC_STATUS,
				cst_adm_entry_qual_status, 	acaih.ADM_ENTRY_QUAL_STATUS,
				cst_late_adm_fee_status,	acaih.late_adm_fee_status,
				cst_adm_outcome_status,		acaih.ADM_OUTCOME_STATUS,
				cst_adm_otcm_stus_auth_prsn_id,
								TO_CHAR(acaih.adm_otcm_status_auth_person_id),
				cst_adm_outcome_status_auth_dt,
								IGS_GE_DATE.igschar(acaih.adm_outcome_status_auth_dt),
				cst_adm_outcome_status_reason, 	acaih.adm_outcome_status_reason,
				cst_offer_dt,			IGS_GE_DATE.igschar(acaih.offer_dt),
				cst_offer_response_dt,		IGS_GE_DATE.igschar(acaih.offer_response_dt),
				cst_prpsd_commencement_dt,
								IGS_GE_DATE.igschar(acaih.prpsd_commencement_dt),
				cst_adm_cndtnl_offer_status,	acaih.ADM_CNDTNL_OFFER_STATUS,
				cst_cndtnl_offer_satisfied_dt,
								IGS_GE_DATE.igschar(acaih.cndtnl_offer_satisfied_dt),
				cst_cndtnl_offer_must_be_stsfd,	acaih.cndtnl_offer_must_be_stsfd_ind,
				cst_adm_offer_resp_status,	acaih.ADM_OFFER_RESP_STATUS,
				cst_actual_response_dt,		IGS_GE_DATE.igschar(acaih.actual_response_dt),
				cst_adm_offer_dfrmnt_status,    acaih.ADM_OFFER_DFRMNT_STATUS,
				cst_deferred_adm_cal_type,      acaih.deferred_adm_cal_type,
				cst_defer_adm_ci_sequnc_num, 	TO_CHAR(acaih.deferred_adm_ci_sequence_num),
				cst_deferred_tracking_id,      	TO_CHAR(acaih.deferred_tracking_id),
				cst_ass_rank,               	TO_CHAR(acaih.ass_rank),
				cst_secondary_ass_rank,      	TO_CHAR(acaih.secondary_ass_rank),
				cst_intrnnl_accptnce_adv_num,	TO_CHAR(acaih.intrntnl_acceptance_advice_num),
				cst_ass_tracking_id,         	TO_CHAR(acaih.ass_tracking_id),
				cst_fee_cat,           		acaih.FEE_CAT,
				cst_hecs_payment_option,	acaih.HECS_PAYMENT_OPTION,
				cst_expected_completion_yr,   	TO_CHAR(acaih.expected_completion_yr),
				cst_expected_completion_perd,  	acaih.expected_completion_perd,
				cst_correspondence_cat,		acaih.CORRESPONDENCE_CAT,
				cst_enrolment_cat,		acaih.ENROLMENT_CAT,
				cst_funding_source,		acaih.FUNDING_SOURCE,
				cst_applicant_acptnce_cndtn,   	acaih.applicant_acptnce_cndtn,
				cst_cndtnl_offer_cndtn,		acaih.cndtnl_offer_cndtn) IS NOT NULL
		ORDER BY
			acaih.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
BEGIN
	OPEN c_acaih;
	FETCH c_acaih INTO v_column_value;
	CLOSE c_acaih;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF c_acaih%ISOPEN THEN
			CLOSE c_acaih;
		END IF;
		RAISE;
END;
END audp_get_acaih_col;

Function Audp_Get_Acaiuh_Col(
  p_column_name IN user_tab_columns.column_name%TYPE ,
  p_adm_ps_appl_inst_unit_id IN NUMBER ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN IGS_AD_PS_APINTUNTHS_ALL.unit_cd%TYPE ,
  p_hist_end_dt IN DATE )
RETURN VARCHAR2 AS

BEGIN
DECLARE
	cst_uv_version_number		CONSTANT
							user_tab_columns.column_name%TYPE := 'UV_VERSION_NUMBER';
	cst_cal_type			CONSTANT	user_tab_columns.column_name%TYPE := 'CAL_TYPE';
	cst_ci_sequence_number		CONSTANT
							user_tab_columns.column_name%TYPE := 'CI_SEQUENCE_NUMBER';
	cst_location_cd			CONSTANT	user_tab_columns.column_name%TYPE := 'LOCATION_CD';
	cst_unit_class			CONSTANT	user_tab_columns.column_name%TYPE := 'UNIT_CLASS';
	cst_unit_mode			CONSTANT	user_tab_columns.column_name%TYPE := 'UNIT_MODE';
	cst_adm_unit_outcome_status	CONSTANT
							user_tab_columns.column_name%TYPE := 'ADM_UNIT_OUTCOME_STATUS';
	cst_ass_tracking_id		CONSTANT
							user_tab_columns.column_name%TYPE := 'ASS_TRACKING_ID';
	cst_rule_waived_dt		CONSTANT
							user_tab_columns.column_name%TYPE := 'RULE_WAIVED_DT';
	cst_rule_waived_person_id	CONSTANT
							user_tab_columns.column_name%TYPE := 'RULE_WAIVED_PERSON_ID';
	cst_sup_unit_cd			CONSTANT	user_tab_columns.column_name%TYPE := 'SUP_UNIT_CD';
	cst_sup_uv_version_number	CONSTANT
							user_tab_columns.column_name%TYPE := 'SUP_UV_VERSION_NUMBER';
	v_column_value		VARCHAR2(2000) := NULL;
	CURSOR c_acaiuh IS
		SELECT	DECODE(p_column_name,
				cst_uv_version_number,		TO_CHAR(acaiuh.uv_version_number),
				cst_cal_type,			acaiuh.CAL_TYPE,
				cst_ci_sequence_number,		TO_CHAR(acaiuh.ci_sequence_number),
				cst_location_cd,		acaiuh.location_cd,
				cst_unit_class,			acaiuh.UNIT_CLASS,
				cst_unit_mode,			acaiuh.UNIT_MODE,
				cst_adm_unit_outcome_status,	acaiuh.ADM_UNIT_OUTCOME_STATUS,
				cst_ass_tracking_id,		TO_CHAR(acaiuh.ass_tracking_id),
				cst_rule_waived_dt,
								IGS_GE_DATE.igscharDT(acaiuh.rule_waived_dt),
				cst_rule_waived_person_id,	TO_CHAR(acaiuh.rule_waived_person_id),
				cst_sup_unit_cd,		acaiuh.sup_unit_cd,
				cst_sup_uv_version_number,	TO_CHAR(acaiuh.sup_uv_version_number))
		FROM	IGS_AD_PS_APINTUNTHS	acaiuh
		WHERE	acaiuh.adm_ps_appl_inst_unit_id = p_adm_ps_appl_inst_unit_id AND
    /*********************** 3083148 ***********************
      acaiuh.person_id		= p_person_id AND
			acaiuh.admission_appl_number	= p_admission_appl_number AND
			acaiuh.nominated_course_cd	= p_nominated_course_cd AND
			acaiuh.acai_sequence_number	= p_acai_sequence_number AND
			acaiuh.unit_cd			= p_unit_cd AND
    *********************** 3083148 ***********************/
			acaiuh.hist_start_dt		>= p_hist_end_dt AND
			DECODE(p_column_name,
				cst_uv_version_number,		TO_CHAR(acaiuh.uv_version_number),
				cst_cal_type,			acaiuh.CAL_TYPE,
				cst_ci_sequence_number,		TO_CHAR(acaiuh.ci_sequence_number),
				cst_location_cd,		acaiuh.location_cd,
				cst_unit_class,			acaiuh.UNIT_CLASS,
				cst_unit_mode,			acaiuh.UNIT_MODE,
				cst_adm_unit_outcome_status,	acaiuh.ADM_UNIT_OUTCOME_STATUS,
				cst_ass_tracking_id,		TO_CHAR(acaiuh.ass_tracking_id),
				cst_rule_waived_dt,
								IGS_GE_DATE.igscharDT(acaiuh.rule_waived_dt),
				cst_rule_waived_person_id,	TO_CHAR(acaiuh.rule_waived_person_id),
				cst_sup_unit_cd,		acaiuh.sup_unit_cd,
				cst_sup_uv_version_number,	TO_CHAR(acaiuh.sup_uv_version_number))
							IS NOT NULL
		ORDER BY acaiuh.hist_start_dt;
BEGIN
	OPEN c_acaiuh;
	FETCH c_acaiuh INTO v_column_value;
	CLOSE c_acaiuh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_acaiuh%ISOPEN) THEN
			CLOSE c_acaiuh;
		END IF;
		RAISE;
END;
END audp_get_acaiuh_col;

Function Audp_Get_Cfosh_Col(
  p_course_cd  IGS_PS_FLD_STD_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_FLD_STD_HIST_ALL.version_number%TYPE ,
  p_field_of_study  IGS_PS_FLD_STD_HIST_ALL.field_of_study%TYPE ,
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_hist_date  IGS_PS_FLD_STD_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_cfosh_col
	-- get the column_value (after a given date) for a given
	-- column_name, course_cd, version_number and field_of_study
DECLARE
	v_column_value		VARCHAR2(2000) := NULL;
	cst_percentage		VARCHAR2(30) := 'PERCENTAGE';
	cst_major_field_ind	VARCHAR2(30) := 'MAJOR_FIELD_IND';
	CURSOR	c_cfosh IS
		SELECT	DECODE (p_column_name,
				cst_percentage,		TO_CHAR(cfosh.percentage),
				cst_major_field_ind,	cfosh.major_field_ind)
		FROM	IGS_PS_FLD_STD_HIST	cfosh
		WHERE	cfosh.course_cd		= p_course_cd AND
			cfosh.version_number	= p_version_number AND
			cfosh.field_of_study	= p_field_of_study AND
			cfosh.hist_start_dt		>= p_hist_date AND
			DECODE (p_column_name,
				cst_percentage,		TO_CHAR(cfosh.percentage),
				cst_major_field_ind,	cfosh.major_field_ind) IS NOT NULL
		ORDER BY cfosh.hist_start_dt;
BEGIN
	OPEN c_cfosh;
	FETCH c_cfosh INTO v_column_value;
	CLOSE c_cfosh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_cfosh%ISOPEN) THEN
			CLOSE c_cfosh;
		END IF;
		RAISE;
END;
END audp_get_cfosh_col;

Function Audp_Get_Coh_Col(
  p_course_cd  IGS_PS_OWN_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_OWN_HIST_ALL.version_number%TYPE ,
  p_org_unit_cd  IGS_PS_OWN_HIST_ALL.org_unit_cd%TYPE ,
  p_ou_start_dt  IGS_PS_OWN_HIST_ALL.ou_start_dt%TYPE ,
  p_hist_date  IGS_PS_OWN_HIST_ALL.hist_start_dt%TYPE )
RETURN NUMBER AS

BEGIN	-- audp_get_coh_col
	-- get the oldest column value (after a given date) for the percentage
	-- column for a given course_cd, version_number, org_unit_cd and
	-- ou_start_dt
DECLARE
	v_column_value		IGS_PS_OWN_HIST.percentage%TYPE := NULL;
	CURSOR	c_coh IS
		SELECT	coh.percentage
		FROM	IGS_PS_OWN_HIST	coh
		WHERE	coh.course_cd		= p_course_cd AND
			coh.version_number	= p_version_number AND
			coh.org_unit_cd		= p_org_unit_cd AND
			coh.ou_start_dt		= p_ou_start_dt AND
			coh.hist_start_dt		>= p_hist_date AND
			coh.percentage		IS NOT NULL
		ORDER BY coh.hist_start_dt;
BEGIN
	OPEN c_coh;
	FETCH c_coh INTO v_column_value;
	CLOSE c_coh;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_coh%ISOPEN) THEN
			CLOSE c_coh;
		END IF;
		RAISE;
END;
END audp_get_coh_col;

Function Audp_Get_Crch_Col(
  p_course_cd  IGS_PS_REF_CD_HIST_ALL.course_cd%TYPE ,
  p_version_number  IGS_PS_REF_CD_HIST_ALL.version_number%TYPE ,
  p_reference_cd_type  IGS_PS_REF_CD_HIST_ALL.reference_cd_type%TYPE ,
  p_reference_cd  IGS_PS_REF_CD_HIST_ALL.reference_cd%TYPE ,
  p_hist_date  IGS_PS_REF_CD_HIST_ALL.hist_start_dt%TYPE )
RETURN VARCHAR2 AS

BEGIN	-- audp_get_crch_col
	-- get the oldest column value (after a given date) for the descritpion
	-- column for a given course_cd, version_number, reference_cd_type and
	-- reference_cd
DECLARE
	v_column_value		VARCHAR2(2000) := NULL;
	CURSOR	c_crch IS
		SELECT	crch.description
		FROM	IGS_PS_REF_CD_HIST	crch
		WHERE	crch.course_cd		= p_course_cd AND
			crch.version_number	= p_version_number AND
			crch.reference_cd_type	= p_reference_cd_type AND
			crch.reference_cd		= p_reference_cd AND
			crch.hist_start_dt		>= p_hist_date AND
			crch.description		IS NOT NULL
		ORDER BY crch.hist_start_dt;
BEGIN
	OPEN c_crch;
	FETCH c_crch INTO v_column_value;
	CLOSE c_crch;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF (c_crch%ISOPEN) THEN
			CLOSE c_crch;
		END IF;
		RAISE;
END;
END audp_get_crch_col;

Function Audp_Get_Cth_Col(
  p_column_name  user_tab_columns.column_name%TYPE ,
  p_course_type  IGS_PS_TYPE_ALL.course_type%TYPE ,
  p_hist_end_dt  IGS_PS_TYPE_HIST_ALL.hist_end_dt%TYPE )
RETURN VARCHAR2 AS
 -- HISTORY
 -- WHO       WHEN         WHAT
 -- sarakshi  3-Oct-2002   Enh#2603626,the cursor c_cth added column fin_aid_program_type in the decode
 --                        statement for both select and where clause

BEGIN	-- audp_get_cth_col
	-- get the oldest column value (after a given date) for a
	-- specified column and course_type
	-- added the primary_auto_select column as part of Career impact dld, bug 2027984,pmarada
DECLARE
	CURSOR c_cth IS
		SELECT
			DECODE (p_column_name,
				'DESCRIPTION',		cth.description,
				'GOVT_COURSE_TYPE',	TO_CHAR(cth.GOVT_COURSE_TYPE),
				'COURSE_TYPE_GROUP_CD',	cth.course_type_group_cd,
				'TAC_COURSE_LEVEL',	cth.tac_course_level,
				'CLOSED_IND',		cth.closed_ind,
				'AWARD_COURSE_IND',	cth.award_course_ind,
				'RESEARCH_TYPE_IND',	cth.research_type_ind,
				'PRIMARY_AUTO_SELECT',  cth.primary_auto_select,
                                'FIN_AID_PROGRAM_TYPE', cth.fin_aid_program_type)
		FROM	IGS_PS_TYPE_HIST	cth
		WHERE	cth.course_type		= p_course_type AND
			cth.hist_start_dt	>= p_hist_end_dt AND
			DECODE (p_column_name,
				'DESCRIPTION',		cth.description,
				'GOVT_COURSE_TYPE',	TO_CHAR(cth.GOVT_COURSE_TYPE),
				'COURSE_TYPE_GROUP_CD',	cth.course_type_group_cd,
				'TAC_COURSE_LEVEL',	cth.tac_course_level,
				'CLOSED_IND',		cth.closed_ind,
				'AWARD_COURSE_IND',	cth.award_course_ind,
				'RESEARCH_TYPE_IND',	cth.research_type_ind,
				'PRIMARY_AUTO_SELECT',  cth.primary_auto_select,
                                'FIN_AID_PROGRAM_TYPE', cth.fin_aid_program_type) IS NOT NULL
		ORDER BY
			cth.hist_start_dt;
	v_column_value		VARCHAR2(2000) := NULL;
BEGIN
	OPEN c_cth;
	FETCH c_cth INTO v_column_value;
	CLOSE c_cth;
	RETURN v_column_value;
EXCEPTION
	WHEN OTHERS THEN
		IF c_cth%ISOPEN THEN
			CLOSE c_cth;
		END IF;
		RAISE;
END;
END audp_get_cth_col;

END IGS_AU_GEN_001;

/
