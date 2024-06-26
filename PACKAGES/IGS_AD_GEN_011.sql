--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_011
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_011" AUTHID CURRENT_USER AS
/* $Header: IGSAD11S.pls 120.2 2005/09/21 00:38:55 appldev ship $ */

Procedure Admp_Ins_Acai_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_new_adm_cal_type IN VARCHAR2 ,
  p_old_adm_cal_type IN VARCHAR2 ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_course_cd IN VARCHAR2 ,
  p_old_course_cd IN VARCHAR2 ,
  p_new_crv_version_number IN NUMBER ,
  p_old_crv_version_number IN NUMBER ,
  p_new_location_cd IN VARCHAR2 ,
  p_old_location_cd IN VARCHAR2 ,
  p_new_attendance_mode IN VARCHAR2 ,
  p_old_attendance_mode IN VARCHAR2 ,
  p_new_attendance_type IN VARCHAR2 ,
  p_old_attendance_type IN VARCHAR2 ,
  p_new_unit_set_cd IN VARCHAR2 ,
  p_old_unit_set_cd IN VARCHAR2 ,
  p_new_us_version_number IN NUMBER ,
  p_old_us_version_number IN NUMBER ,
  p_new_preference_number IN NUMBER ,
  p_old_preference_number IN NUMBER ,
  p_new_adm_doc_status IN VARCHAR2 ,
  p_old_adm_doc_status IN VARCHAR2 ,
  p_new_adm_entry_qual_status IN VARCHAR2 ,
  p_old_adm_entry_qual_status IN VARCHAR2 ,
  p_new_late_adm_fee_status IN VARCHAR2 ,
  p_old_late_adm_fee_status IN VARCHAR2 ,
  p_new_adm_outcome_status IN VARCHAR2 ,
  p_old_adm_outcome_status IN VARCHAR2 ,
  p_new_otcm_sts_auth_prsn_id IN NUMBER ,
  p_old_otcm_sts_auth_prsn_id IN NUMBER ,
  p_new_adm_otcm_status_auth_dt IN DATE ,
  p_old_adm_otcm_status_auth_dt IN DATE ,
  p_new_adm_otcm_status_reason IN VARCHAR2 ,
  p_old_adm_otcm_status_reason IN VARCHAR2 ,
  p_new_offer_dt IN DATE ,
  p_old_offer_dt IN DATE ,
  p_new_offer_response_dt IN DATE ,
  p_old_offer_response_dt IN DATE ,
  p_new_prpsd_commencement_dt IN DATE ,
  p_old_prpsd_commencement_dt IN DATE ,
  p_new_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_old_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_new_cndtnl_offer_stsfd_dt IN DATE ,
  p_old_cndtnl_offer_stsfd_dt IN DATE ,
  p_new_cndtnl_off_must_be_stsfd IN VARCHAR2 DEFAULT 'N',
  p_old_cndtnl_off_must_be_stsfd IN VARCHAR2 DEFAULT 'N',
  p_new_adm_offer_resp_status IN VARCHAR2 ,
  p_old_adm_offer_resp_status IN VARCHAR2 ,
  p_new_actual_response_dt IN DATE ,
  p_old_actual_response_dt IN DATE ,
  p_new_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_old_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_new_deferred_adm_cal_type IN VARCHAR2 ,
  p_old_deferred_adm_cal_type IN VARCHAR2 ,
  p_new_deferred_adm_ci_seq_num IN NUMBER ,
  p_old_deferred_adm_ci_seq_num IN NUMBER ,
  p_new_deferred_tracking_id IN NUMBER ,
  p_old_deferred_tracking_id IN NUMBER ,
  p_new_ass_rank IN NUMBER ,
  p_old_ass_rank IN NUMBER ,
  p_new_secondary_ass_rank IN NUMBER ,
  p_old_secondary_ass_rank IN NUMBER ,
  p_new_intrntnl_acpt_advice_num IN NUMBER ,
  p_old_intrntnl_acpt_advice_num IN NUMBER ,
  p_new_ass_tracking_id IN NUMBER ,
  p_old_ass_tracking_id IN NUMBER ,
  p_new_fee_cat IN VARCHAR2 ,
  p_old_fee_cat IN VARCHAR2 ,
  p_new_hecs_payment_option IN VARCHAR2 ,
  p_old_hecs_payment_option IN VARCHAR2 ,
  p_new_expected_completion_yr IN NUMBER ,
  p_old_expected_completion_yr IN NUMBER ,
  p_new_expected_completion_perd IN VARCHAR2 ,
  p_old_expected_completion_perd IN VARCHAR2 ,
  p_new_correspondence_cat IN VARCHAR2 ,
  p_old_correspondence_cat IN VARCHAR2 ,
  p_new_enrolment_cat IN VARCHAR2 ,
  p_old_enrolment_cat IN VARCHAR2 ,
  p_new_funding_source IN VARCHAR2 ,
  p_old_funding_source IN VARCHAR2 ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE ,
  p_new_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_old_applicant_acptnce_cndtn IN VARCHAR2 ,
  p_new_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_old_cndtnl_offer_cndtn IN VARCHAR2 ,
  p_new_appl_inst_status IN VARCHAR2 DEFAULT NULL,			--arvsrini igsm
  p_old_appl_inst_status IN VARCHAR2 DEFAULT NULL,
  P_NEW_DECISION_DATE            DATE     DEFAULT NULL,	-- begin APADEGAL adtd001 igs.m
  P_OLD_DECISION_DATE            DATE     DEFAULT NULL,
  P_NEW_DECISION_MAKE_ID         NUMBER   DEFAULT NULL,
  P_OLD_DECISION_MAKE_ID         NUMBER   DEFAULT NULL,
  P_NEW_DECISION_REASON_ID       NUMBER   DEFAULT NULL,
  P_OLD_DECISION_REASON_ID       NUMBER   DEFAULT NULL,
  P_NEW_PENDING_REASON_ID        NUMBER   DEFAULT NULL,
  P_OLD_PENDING_REASON_ID        NUMBER   DEFAULT NULL,
  P_NEW_WAITLIST_STATUS          VARCHAR2 DEFAULT NULL,
  P_OLD_WAITLIST_STATUS          VARCHAR2 DEFAULT NULL,
  P_NEW_WAITLIST_RANK            VARCHAR2 DEFAULT NULL,
  P_OLD_WAITLIST_RANK            VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ACAD_CAL_TYPE     VARCHAR2 DEFAULT NULL,
  P_OLD_FUTURE_ACAD_CAL_TYPE     VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ACAD_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_OLD_FUTURE_ACAD_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_NEW_FUTURE_ADM_CAL_TYPE      VARCHAR2 DEFAULT NULL,
  P_OLD_FUTURE_ADM_CAL_TYPE      VARCHAR2 DEFAULT NULL,
  P_NEW_FUTURE_ADM_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_OLD_FUTURE_ADM_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_NEW_DEF_ACAD_CAL_TYPE        VARCHAR2 DEFAULT NULL,
  P_OLD_DEF_ACAD_CAL_TYPE        VARCHAR2 DEFAULT NULL,
  P_NEW_DEF_ACAD_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_OLD_DEF_ACAD_CI_SEQ_NUM	 NUMBER   DEFAULT NULL,
  P_NEW_DECLINE_OFR_REASON       VARCHAR2 DEFAULT NULL,
  P_OLD_DECLINE_OFR_REASON       VARCHAR2 DEFAULT NULL	  -- end APADEGAL adtd001 igs.m

  );

Procedure Admp_Ins_Aca_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_new_transfer_course_cd IN VARCHAR2 ,
  p_old_transfer_course_cd IN VARCHAR2 ,
  p_new_basis_for_admission_type IN VARCHAR2 ,
  p_old_basis_for_admission_type IN VARCHAR2 ,
  p_new_admission_cd IN VARCHAR2 ,
  p_old_admission_cd IN VARCHAR2 ,
  p_new_course_rank_set IN VARCHAR2 ,
  p_old_course_rank_set IN VARCHAR2 ,
  p_new_course_rank_schedule IN VARCHAR2 ,
  p_old_course_rank_schedule IN VARCHAR2 ,
  p_new_req_for_reconsider_ind IN VARCHAR2 DEFAULT 'N',
  p_old_req_for_reconsider_ind IN VARCHAR2 DEFAULT 'N',
  p_new_req_for_adv_standing_ind IN VARCHAR2 DEFAULT 'N',
  p_old_req_for_adv_standing_ind IN VARCHAR2 DEFAULT 'N',
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE );
--
  Function Admp_Ins_Adm_Letter (
    p_acad_cal_type                  IN     VARCHAR2,
    p_acad_ci_sequence_number        IN     NUMBER,
    p_adm_cal_type                   IN     VARCHAR2,
    p_adm_ci_sequence_number         IN     NUMBER,
    p_admission_cat                  IN     VARCHAR2,
    p_s_admission_process_type       IN     VARCHAR2,
    p_correspondence_type            IN     VARCHAR2,
    p_person_id                      IN     NUMBER,
    p_admission_appl_number          IN     NUMBER,
    p_adm_outcome_status             IN     VARCHAR2,
    p_message_name                   OUT NOCOPY    VARCHAR2,
    p_reference_number               OUT NOCOPY    NUMBER,
    p_pgmofstudy                     IN     VARCHAR2,
    p_response_stat                  IN     VARCHAR2,
    p_resd_class                     IN     VARCHAR2,
    p_resd_stat                      IN     VARCHAR2,
    p_persid_grp                     IN     NUMBER,
    p_org_unit                       IN     VARCHAR2,
    p_sortby                         IN     VARCHAR2
  ) RETURN BOOLEAN;
--
  PROCEDURE Adms_Ins_Adm_Letter (
    errbuf                        OUT NOCOPY    VARCHAR2,
    retcode                       OUT NOCOPY    NUMBER,
    p_acad_perd                   IN     VARCHAR2,
    p_adm_perd                    IN     VARCHAR2,
    p_adm_cat                     IN     VARCHAR2,
    p_s_adm_prcss_type            IN     VARCHAR2,
    p_correspondence_type         IN     VARCHAR2,
    p_adm_outcome_stat            IN     VARCHAR2,
    p_org_id                      IN     NUMBER,
    p_pgmofstudy                  IN     VARCHAR2,
    p_response_stat               IN     VARCHAR2,
    p_resd_class                  IN     VARCHAR2,
    p_resd_stat                   IN     VARCHAR2,
    p_persid_grp                  IN     NUMBER,
    p_org_unit                    IN     VARCHAR2,
    p_sortby                      IN     VARCHAR2
  );

-- Removed Function for IGR migration (bug 4114493) sjlaport

Function Admp_Ins_Phrase_Splp(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_aal_sequence_number IN NUMBER ,
  p_letter_parameter_type IN VARCHAR2 ,
  p_letter_reference_number IN NUMBER ,
  p_spl_sequence_number IN NUMBER ,
  p_letter_repeating_group_cd IN VARCHAR2 ,
  p_splrg_sequence_number IN NUMBER,
  p_letter_order_number IN NUMBER)
RETURN BOOLEAN;

END IGS_AD_GEN_011;

 

/
