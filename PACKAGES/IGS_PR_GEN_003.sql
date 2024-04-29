--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSPR24S.pls 115.5 2002/11/29 02:50:21 nsidana ship $ */

PROCEDURE IGS_PR_GET_CAL_PARM(

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_prg_cal_type IN VARCHAR2 ,

  p_level OUT NOCOPY VARCHAR2 ,

  p_org_unit_cd OUT NOCOPY VARCHAR2 ,

  p_ou_start_dt OUT NOCOPY DATE ,


  p_stream_number OUT NOCOPY NUMBER ,

  p_show_cause_length OUT NOCOPY NUMBER ,

  p_appeal_length OUT NOCOPY NUMBER )    ;

PROCEDURE IGS_PR_GET_CONFIG_LVL(

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_basic_level OUT NOCOPY VARCHAR2 ,

  p_calendar_level OUT NOCOPY VARCHAR2 ,

  p_org_unit_cd OUT NOCOPY VARCHAR2 ,

  p_ou_start_dt OUT NOCOPY DATE )  ;

PROCEDURE IGS_PR_GET_CONFIG_PARM(

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_apply_start_dt_alias OUT NOCOPY VARCHAR2 ,

  p_apply_end_dt_alias OUT NOCOPY VARCHAR2 ,

  p_end_benefit_dt_alias OUT NOCOPY VARCHAR2 ,

  p_end_penalty_dt_alias OUT NOCOPY VARCHAR2 ,


  p_show_cause_cutoff_dt_alias OUT NOCOPY VARCHAR2 ,

  p_appeal_cutoff_dt_alias OUT NOCOPY VARCHAR2 ,

  p_show_cause_ind OUT NOCOPY VARCHAR2 ,

  p_apply_before_show_ind OUT NOCOPY VARCHAR2 ,

  p_appeal_ind OUT NOCOPY VARCHAR2 ,

  p_apply_before_appeal_ind OUT NOCOPY VARCHAR2 ,


  p_count_sus_in_time_ind OUT NOCOPY VARCHAR2 ,

  p_count_exc_in_time_ind OUT NOCOPY VARCHAR2 ,

  p_calculate_wam_ind OUT NOCOPY VARCHAR2 ,

  p_calculate_gpa_ind OUT NOCOPY VARCHAR2 ,

  p_outcome_check_type OUT NOCOPY VARCHAR2 )  ;

PROCEDURE IGS_PR_INS_ADV_TODO(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_old_adv_stnd_type IN VARCHAR2 ,

  p_new_adv_stnd_type IN VARCHAR2 ,

  p_old_s_adv_stnd_grant_status IN VARCHAR2 ,


  p_new_s_adv_stnd_grant_status IN VARCHAR2 ,

  p_old_credit_points IN NUMBER ,

  p_new_credit_points IN NUMBER ,

  p_old_credit_percentage IN NUMBER ,

  p_new_credit_percentage IN NUMBER )  ;

PROCEDURE IGS_PR_INS_PRG_MSR(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_sequence_number IN NUMBER )  ;

PROCEDURE IGS_PR_INS_SPO_HIST(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_new_prg_cal_type IN VARCHAR2 ,

  p_old_prg_cal_type IN VARCHAR2 ,

  p_new_prg_ci_sequence_number IN NUMBER ,


  p_old_prg_ci_sequence_number IN NUMBER ,

  p_new_rule_check_dt IN DATE ,

  p_old_rule_check_dt IN DATE ,

  p_new_progression_rule_cat IN VARCHAR2 ,

  p_old_progression_rule_cat IN VARCHAR2 ,

  p_new_pra_sequence_number IN NUMBER ,


  p_old_pra_sequence_number IN NUMBER ,

  p_new_pro_pra_sequence_number IN NUMBER ,

  p_old_pro_pra_sequence_number IN NUMBER ,

  p_new_pro_sequence_number IN NUMBER ,

  p_old_pro_sequence_number IN NUMBER ,

  p_new_progression_outcome_type IN VARCHAR2 ,

  p_old_progression_outcome_type IN VARCHAR2 ,


  p_new_duration IN NUMBER ,

  p_old_duration IN NUMBER ,

  p_new_duration_type IN VARCHAR2 ,

  p_old_duration_type IN VARCHAR2 ,

  p_new_decision_status IN VARCHAR2 ,

  p_old_decision_status IN VARCHAR2 ,


  p_new_decision_dt IN DATE ,

  p_old_decision_dt IN DATE ,

  p_new_decision_org_unit_cd IN VARCHAR2 ,

  p_old_decision_org_unit_cd IN VARCHAR2 ,

  p_new_decision_ou_start_dt IN DATE ,

  p_old_decision_ou_start_dt IN DATE ,

  p_new_applied_dt IN DATE ,


  p_old_applied_dt IN DATE ,

  p_new_expiry_dt IN DATE ,

  p_old_expiry_dt IN DATE ,

  p_new_show_cause_expiry_dt IN DATE ,

  p_old_show_cause_expiry_dt IN DATE ,

  p_new_show_cause_dt IN DATE ,


  p_old_show_cause_dt IN DATE ,

  p_new_show_cause_outcome_dt IN DATE ,

  p_old_show_cause_outcome_dt IN DATE ,

  p_new_show_cause_outcome_type IN VARCHAR2 ,

  p_old_show_cause_outcome_type IN VARCHAR2 ,

  p_new_appeal_expiry_dt IN DATE ,

  p_old_appeal_expiry_dt IN DATE ,


  p_new_appeal_dt IN DATE ,

  p_old_appeal_dt IN DATE ,

  p_new_appeal_outcome_dt IN DATE ,

  p_old_appeal_outcome_dt IN DATE ,

  p_new_appeal_outcome_type IN VARCHAR2 ,

  p_old_appeal_outcome_type IN VARCHAR2 ,


  p_new_encmb_course_group_cd IN VARCHAR2 ,

  p_old_encmb_course_group_cd IN VARCHAR2 ,

  p_new_restricted_enrolment_cp IN NUMBER ,

  p_old_restricted_enrolment_cp IN NUMBER ,

  p_new_restricted_att_type IN VARCHAR2 ,

  p_old_restricted_att_type IN VARCHAR2 ,

  p_new_LAST_UPDATED_BY IN VARCHAR2 ,


  p_old_LAST_UPDATED_BY IN VARCHAR2 ,

  p_new_LAST_UPDATE_DATE IN DATE ,

  p_old_LAST_UPDATE_DATE IN DATE ,

  p_new_comments IN VARCHAR2 ,

  p_old_comments IN VARCHAR2 ,

  p_new_show_cause_comments IN VARCHAR2 ,


  p_old_show_cause_comments IN VARCHAR2 ,

  p_new_appeal_comments IN VARCHAR2 ,

  p_old_appeal_comments IN VARCHAR2 )   ;

  PROCEDURE IGS_PR_INS_SSP(
  p_creation_dt IN DATE ,
  p_key IN VARCHAR2 ,
  p_s_message_name IN VARCHAR2 ,
  p_text IN VARCHAR2 ,
  p_ssp_sequence_number OUT NOCOPY NUMBER );

END IGS_PR_GEN_003;

 

/
