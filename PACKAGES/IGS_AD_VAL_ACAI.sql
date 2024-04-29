--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACAI" AUTHID CURRENT_USER AS
 /* $Header: IGSAD22S.pls 120.0 2005/06/01 23:28:41 appldev noship $ */
--
-- bug id : 1956374
-- sjadhav , 29-aug-2001
-- removed function enrp_val_hpo_closed
--
   ------------------------------------------------------------------------------------------p
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The pragma restrict refrence added to function genp_val_staff_prsn
 -- rghosh     03-mar-2003   Changed the signature of the function ADMP_VAL_DFRMNT_CAL (bug#2765260)
    -------------------------------------------------------------------------------------------
 -- Bug # 1956374
 -- As part of bug 1956374 removed function crsp_val_loc_cd,finp_val_fc_closed
  -- Bug # 1956374
  --  As part of bug  1956374 removed the function admp_val_aa_adm_cal,admp_val_aca_trnsfr,admp_val_pref_limit
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_ec_closed
  --

  -- Validate insert of an IGS_AD_PS_APPL_INST record.
  FUNCTION admp_val_acai_insert(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_pref_limit IN NUMBER ,
  p_validate_aa_only IN BOOLEAN ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate update of an IGS_AD_PS_APPL_INST record.
  FUNCTION admp_val_acai_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_update_non_enrol_detail_ind OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate delete of an IGS_AD_PS_APPL_INST record.
  FUNCTION admp_val_acai_delete(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate change of preferences.
  FUNCTION admp_val_chg_of_pref(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;



 --
   --
  -- Validate the course code of the admission application.
  FUNCTION admp_val_acai_course(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_crv_version_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

 --
  -- Perform encumbrance check for admission_course_appl_instance.course_cd
  FUNCTION admp_val_acai_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate course appl process type against the student course attempt.
  FUNCTION admp_val_aca_sca(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --


 --
  -- Validate the adm course application instance course offering pattern.
  FUNCTION admp_val_acai_cop(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_deferred_appl IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_late_ind OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the adm course application instance course offering option.
  FUNCTION admp_val_acai_coo(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_deferred_appl IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_late_ind OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (admp_val_acai_coo,WNDS,WNPS);
  --
  -- Validate if the IGS_AD_PS_APPL_INST is late.
  FUNCTION admp_val_acai_late(
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (admp_val_acai_late,WNDS,WNPS);
  --
  -- Validate the admission course appl instance offering option details.
  FUNCTION admp_val_acai_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Validate the admission course application IGS_PS_UNIT set.
  FUNCTION admp_val_acai_us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate CACUS can only be created when US is not a subordinate
  FUNCTION crsp_val_cacus_sub(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Do encumbrance checks for the IGS_AD_PS_APPL_INST.unit_set_cd.
  FUNCTION admp_val_us_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_course_encmb_chk_ind IN VARCHAR2 DEFAULT 'N',
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.offer_dt.
  FUNCTION admp_val_offer_dt(
  p_offer_dt IN DATE ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.offer_response_dt.
  FUNCTION admp_val_off_resp_dt(
  p_offer_response_dt IN DATE ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_offer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.actual_response_dt.
  FUNCTION admp_val_act_resp_dt(
  p_actual_response_dt IN DATE ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_offer_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_satisfied_dt.
  FUNCTION admp_val_stsfd_dt(
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_cndtn.
  FUNCTION admp_val_offer_cndtn(
  p_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.applicant_acptnce_cndtn.
  FUNCTION admp_val_acpt_cndtn(
  p_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.cndtnl_offer_must_be_stsfd_ind.
  FUNCTION admp_val_must_stsfd(
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 DEFAULT 'N',
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate adm course application instance deferred admission calendar.
  FUNCTION admp_val_dfrmnt_cal(
  p_deferred_adm_cal_type IN VARCHAR2 ,
  p_deferred_adm_ci_sequence_num IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_deferral_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2,
  p_def_acad_ci_sequence_num IN NUMBER DEFAULT NULL
  )
RETURN BOOLEAN;
  --
  -- Validate if admission course application instance corresponce cat.
  FUNCTION admp_val_acai_cc(
  p_admission_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate if IGS_CO_CAT.correspondence_cat is closed.
  FUNCTION corp_val_cc_closed(
  p_correspondence_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate if admission course application instance enrolment category.
  FUNCTION admp_val_acai_ec(
  p_admission_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_ec_closed
  --
  -- Validate if admission course application instance fee category.
  FUNCTION admp_val_acai_fc(
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate admission course application instance HECS payment option.
  FUNCTION admp_val_acai_hpo(
  p_admission_cat IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_auth_dt.
  FUNCTION admp_val_ovrd_dt(
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_otcm_status_auth_person_id.
  FUNCTION admp_val_ovrd_person(
  p_adm_otcm_status_auth_person IN NUMBER ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate a person id to ensure the person is a staff member.
  FUNCTION genp_val_staff_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES (genp_val_staff_prsn,WNDS);
  --
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status_reason.
  FUNCTION admp_val_ovrd_reason(
  p_adm_outcome_status_reason IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_override_outcome_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate that the course application is complete on offer.
  FUNCTION admp_val_offer_comp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_called_from IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate if the specified IGS_AD_PS_APPL_INST is complete.
  FUNCTION admp_val_acai_comp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_check_referee IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_check_lang_prof IN BOOLEAN ,
  p_check_interview IN BOOLEAN ,
  p_check_exchange IN BOOLEAN ,
  p_check_adm_test IN BOOLEAN ,
  p_check_fee_assess IN BOOLEAN ,
  p_check_cor_category IN BOOLEAN ,
  p_check_enr_category IN BOOLEAN ,
  p_check_research IN BOOLEAN ,
  p_check_rank_app IN BOOLEAN ,
  p_check_completion IN BOOLEAN ,
  p_check_rank_set IN BOOLEAN ,
  p_check_basis_adm IN BOOLEAN ,
  p_check_crs_international IN BOOLEAN ,
  p_check_ass_tracking IN BOOLEAN ,
  p_check_adm_code IN BOOLEAN ,
  p_check_fund_source IN BOOLEAN ,
  p_check_location IN BOOLEAN ,
  p_check_att_mode IN BOOLEAN ,
  p_check_att_type IN BOOLEAN ,
  p_check_unit_set IN BOOLEAN ,
  p_message_name OUT NOCOPY  VARCHAR2,
  p_valid_referee OUT NOCOPY BOOLEAN ,
  p_valid_scholarship OUT NOCOPY BOOLEAN ,
  p_valid_lang_prof OUT NOCOPY BOOLEAN ,
  p_valid_interview OUT NOCOPY BOOLEAN ,
  p_valid_exchange OUT NOCOPY BOOLEAN ,
  p_valid_adm_test OUT NOCOPY BOOLEAN ,
  p_valid_fee_assess OUT NOCOPY BOOLEAN ,
  p_valid_cor_category OUT NOCOPY BOOLEAN ,
  p_valid_enr_category OUT NOCOPY BOOLEAN ,
  p_valid_research OUT NOCOPY BOOLEAN ,
  p_valid_rank_app OUT NOCOPY BOOLEAN ,
  p_valid_completion OUT NOCOPY BOOLEAN ,
  p_valid_rank_set OUT NOCOPY BOOLEAN ,
  p_valid_basis_adm OUT NOCOPY BOOLEAN ,
  p_valid_crs_international OUT NOCOPY BOOLEAN ,
  p_valid_ass_tracking OUT NOCOPY BOOLEAN ,
  p_valid_adm_code OUT NOCOPY BOOLEAN ,
  p_valid_fund_source OUT NOCOPY BOOLEAN ,
  p_valid_location OUT NOCOPY BOOLEAN ,
  p_valid_att_mode OUT NOCOPY BOOLEAN ,
  p_valid_att_type OUT NOCOPY BOOLEAN ,
  p_valid_unit_set OUT NOCOPY BOOLEAN )
RETURN BOOLEAN;
  --
  -- Validate if the specified admission application person is complete.
  FUNCTION admp_val_pe_comp(
  p_person_id IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_athletics IN BOOLEAN ,
  p_check_alternate IN BOOLEAN ,
  p_check_address IN BOOLEAN ,
  p_check_disability IN BOOLEAN ,
  p_check_visa IN BOOLEAN ,
  p_check_finance IN BOOLEAN ,
  p_check_notes IN BOOLEAN ,
  p_check_statistics IN BOOLEAN ,
  p_check_alias IN BOOLEAN ,
  p_check_tertiary IN BOOLEAN ,
  p_check_aus_sec_ed IN BOOLEAN ,
  p_check_os_sec_ed IN BOOLEAN ,
  p_check_employment IN BOOLEAN ,
  p_check_membership IN BOOLEAN ,
  p_check_dob IN BOOLEAN ,
  p_check_title IN BOOLEAN ,
  p_check_excurr IN BOOLEAN DEFAULT FALSE, --tray
  p_message_name OUT NOCOPY VARCHAR2,
  p_valid_athletics OUT NOCOPY BOOLEAN ,
  p_valid_alternate OUT NOCOPY BOOLEAN ,
  p_valid_address OUT NOCOPY BOOLEAN ,
  p_valid_disability OUT NOCOPY BOOLEAN ,
  p_valid_visa OUT NOCOPY BOOLEAN ,
  p_valid_finance OUT NOCOPY BOOLEAN ,
  p_valid_notes OUT NOCOPY BOOLEAN ,
  p_valid_statistics OUT NOCOPY BOOLEAN ,
  p_valid_alias OUT NOCOPY BOOLEAN ,
  p_valid_tertiary OUT NOCOPY BOOLEAN ,
  p_valid_aus_sec_ed OUT NOCOPY BOOLEAN ,
  p_valid_os_sec_ed OUT NOCOPY BOOLEAN ,
  p_valid_employment OUT NOCOPY BOOLEAN ,
  p_valid_membership OUT NOCOPY BOOLEAN ,
  p_valid_dob OUT NOCOPY BOOLEAN ,
  p_valid_title OUT NOCOPY BOOLEAN,
  p_valid_excurr OUT NOCOPY BOOLEAN) --tray
RETURN BOOLEAN;
  --
  -- Validate the deferment of  IGS_AD_PS_APLINSTUNT records.
  FUNCTION admp_val_acaiu_defer(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the IGS_AD_PS_APPL_INST.preference_number.
  FUNCTION admp_val_acai_pref(
  p_preference_number IN NUMBER ,
  p_pref_allowed IN VARCHAR2 DEFAULT 'N',
  p_pref_limit IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate adm course application instance expected completion details.
  FUNCTION admp_val_expctd_comp(
  p_expected_completion_yr IN NUMBER ,
  p_expected_completion_perd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validate the admission course application instance funding source.
  FUNCTION admp_val_acai_fs(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_funding_source IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 --
 -- Validate a IGS_PE_PERSON id to ensure the IGS_PE_PERSON is a staff member.
 FUNCTION genp_val_staff_fculty_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
 RETURN BOOLEAN;

  -- Validate a IGS_PE_PERSON id to ensure the IGS_PE_PERSON is a staff/Faculty OR Evaluator  member.
 FUNCTION genp_val_staff_fac_eva_prsn(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
 RETURN BOOLEAN;


END IGS_AD_VAL_ACAI;

 

/
