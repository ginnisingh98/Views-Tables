--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ACAI_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ACAI_STATUS" AUTHID CURRENT_USER AS
/* $Header: IGSAD24S.pls 120.1 2005/08/11 10:06:23 appldev ship $ */
  --Bug 1956374 msrinivi Removed duplciate fun enrp_val_trnsfr_acpt 27 aug,01
  -- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  -- hreddych #2602077  SF Integration Added the FUNCTION admp_val_aods_update
  FUNCTION admp_val_acai_aeqs(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  -- Validate the IGS_AD_PS_APPL_INST.adm_entry_qual_status.
  FUNCTION admp_val_aeqs_item(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (admp_val_aeqs_item, WNDS, WNPS);
  --
  -- Validate if IGS_AD_ENT_QF_STAT.adm_entry_qual_status is closed.
  FUNCTION admp_val_aeqs_closed(
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (admp_val_aeqs_closed, WNDS, WNPS);
  --
  -- Validates adm_entry_qual_status against adm_outcome_status.
  FUNCTION admp_val_aeqs_aos(
  p_s_adm_entry_qual_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  -- Validate the IGS_AD_PS_APPL_INST.adm_doc_status.
  FUNCTION admp_val_acai_ads(
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  -- Validate the IGS_AD_PS_APPL_INST.adm_doc_status.
  FUNCTION admp_val_ads_item(
  p_adm_doc_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES (admp_val_ads_item, WNDS, WNPS);
  --
  -- Validate if IGS_AD_DOC_STAT.adm_doc_status is closed.
  FUNCTION admp_val_ads_closed(
  p_adm_doc_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (admp_val_ads_closed, WNDS, WNPS);
  --
  -- Validates adm_doc_status against adm_outcome_status.
  FUNCTION admp_val_ads_aos(
  p_s_adm_doc_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  FUNCTION admp_val_acai_aods(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_dfrmnt_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2 DEFAULT 'N',
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_dfrmnt_status.
  FUNCTION admp_val_aods_item(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate if IGS_AD_OFRDFRMT_STAT.adm_offer_dfrmnt_status is closed.
  FUNCTION admp_val_aods_closed(
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --
  -- Validates adm_offer_dfrmnt_status against adm_offer_resp_status.
  FUNCTION admp_val_aods_aors(
  p_s_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_s_adm_dfrmnt_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  FUNCTION admp_val_acai_lafs(
  p_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_fees_required IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
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
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.late_adm_fee_status.
  FUNCTION admp_val_lafs_item(
  p_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate if IGS_AD_FEE_STAT.adm_fee_status is closed.
  FUNCTION admp_val_afs_closed(
  p_adm_fee_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 -- Validates late_adm_fee_status against the course offering option.
  FUNCTION admp_val_lafs_coo(
  p_s_late_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_fees_required IN VARCHAR2 DEFAULT 'N',
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
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validates late_adm_fee_status against adm_outcome_status.
  FUNCTION admp_val_lafs_aos(
  p_s_late_adm_fee_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  FUNCTION admp_val_acai_aors(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_actual_response_dt IN DATE ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2 DEFAULT 'N',
  p_multi_offer_allowed IN VARCHAR2 DEFAULT 'N',
  p_multi_offer_limit IN NUMBER ,
  p_pre_enrol_step IN VARCHAR2 DEFAULT 'N',
  p_cndtnl_off_must_be_stsfd_ind IN VARCHAR2 DEFAULT 'N',
  p_cndtnl_offer_satisfied_dt IN DATE ,
  p_called_from IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2,
  p_decline_ofr_reason IN VARCHAR2 DEFAULT NULL,		-- IGSM
  p_attent_other_inst_cd IN VARCHAR2 DEFAULT NULL		-- igsm
)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_offer_resp_status.
  FUNCTION admp_val_aors_item(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_actual_response_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_deferral_allowed IN VARCHAR2 DEFAULT 'N',
  p_pre_enrol_step IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2,
  p_decline_ofr_reason IN VARCHAR2 DEFAULT NULL,		-- IGSM
  p_attent_other_inst_cd IN VARCHAR2 DEFAULT NULL		-- igsm
)
RETURN BOOLEAN;
  -- Validate if IGS_AD_OFR_RESP_STAT.adm_offer_resp_status is closed.
  FUNCTION admp_val_aors_closed(
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 -- Validates adm_offer_resp_status against adm_outcome_status.
  FUNCTION admp_val_aors_aos(
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_old_s_adm_offer_resp_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_acai_aos(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_set_outcome_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_assess_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_fees_required IN VARCHAR2 DEFAULT 'N',
  p_multi_offer_allowed IN VARCHAR2 DEFAULT 'N',
  p_multi_offer_limit IN NUMBER ,
  p_pref_allowed IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N',
  p_check_person_encumb IN VARCHAR2 DEFAULT 'N',
  p_check_course_encumb IN VARCHAR2 DEFAULT 'N',
  p_called_from IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
 -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_aos_item(
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_set_outcome_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_assess_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate if IGS_AD_OU_STAT.adm_outcome_status is closed.
  FUNCTION admp_val_aos_closed(
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_aos_status(
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_old_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_s_adm_fee_status IN VARCHAR2 ,
  p_late_s_adm_fee_status IN VARCHAR2 ,
  p_cond_offer_assess_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_fees_required IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_outcome_status.
  FUNCTION admp_val_acai_otcome(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_fee_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_adm_outcome_status_auth_dt IN DATE ,
  p_check_person_encumb IN VARCHAR2 DEFAULT 'N',
  p_check_course_encumb IN VARCHAR2 DEFAULT 'N',
  p_pref_allowed IN VARCHAR2 DEFAULT 'N',
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N',
  p_called_from IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- This module validates multiple IGS_AD_PS_APPL_INST offers.
  FUNCTION admp_val_offer_mult(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_multi_offer_allowed IN VARCHAR2 DEFAULT 'N',
  p_multi_offer_limit IN NUMBER ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate offers across admission process categories (same adm period).
  FUNCTION admp_val_offer_x_apc(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate update of the admission outcome status.
  FUNCTION admp_val_aos_update(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.IGS_AD_CNDNL_OFRSTAT.
  FUNCTION admp_val_acai_acos(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_fees_required IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_assess_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  FUNCTION admp_val_acos_item(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_fees_required IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_assess_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_fee_allowed IN VARCHAR2 DEFAULT 'N',
  p_cond_offer_doc_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate if IGS_AD_CNDNL_OFRSTAT.adm_cndtnl_offer_status is closed.
  FUNCTION admp_val_acos_closed(
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  -- Validate the IGS_AD_PS_APPL_INST.adm_cndtnl_offer_status.
  FUNCTION admp_val_acos_status(
  p_s_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_s_adm_cndtnl_offer_sts IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_s_adm_doc_status IN VARCHAR2 ,
  p_late_s_adm_fee_status IN VARCHAR2 ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
  --Validate the offer deferment status
  FUNCTION admp_val_aods_update(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_offer_deferment_status IN VARCHAR2,
  p_message_name  OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  FUNCTION admp_val_acai_ais(				--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_ais_reason IN VARCHAR2,
  p_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION admp_val_ais_item(				--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_ais_reason IN VARCHAR2,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION admp_val_ais_closed(				--arvsrini igsm
  p_appl_inst_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

FUNCTION admp_val_ais_aos(				--arvsrini igsm
  p_s_appl_inst_status IN VARCHAR2 ,
  p_s_adm_outcome_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_ACAI_STATUS;

 

/
