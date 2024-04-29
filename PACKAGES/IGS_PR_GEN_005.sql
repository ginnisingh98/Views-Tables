--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_005
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_005" AUTHID CURRENT_USER AS
/* $Header: IGSPR26S.pls 120.0 2005/07/05 12:26:21 appldev noship $ */

FUNCTION IGS_PR_CLC_APL_EXPRY(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER )
RETURN DATE ;

FUNCTION IGS_PR_CLC_CAUSE_EXPRY(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER )
RETURN DATE ;

FUNCTION IGS_PR_CLC_STDNT_COMP(
  p_person_id IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_sca_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number  NUMBER ,
  p_cst_sequence_number IN NUMBER ,
  p_predicted_ind IN VARCHAR2 DEFAULT 'N',
  p_s_rule_call_cd IN VARCHAR2 ,
  p_key IN VARCHAR2 ,
  p_evaluate_ind IN VARCHAR2 DEFAULT 'N',
  p_log_dt OUT NOCOPY DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN ;

FUNCTION IGS_PR_get_appeal_alwd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 ;

FUNCTION IGS_PR_get_cause_alwd(
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER )
RETURN VARCHAR2 ;

FUNCTION IGS_PR_get_num_fail(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_prg_rule_repeat_fail_type IN VARCHAR2 )
RETURN NUMBER ;

FUNCTION IGS_PR_get_prg_dai(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_alias_type IN VARCHAR2 )
RETURN DATE ;

FUNCTION IGS_PR_GET_PRG_PEN_END(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER )
RETURN DATE ;

FUNCTION IGS_PR_get_prg_status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER,
  p_prg_cal_type IN VARCHAR2,

  p_prg_ci_sequence_number IN NUMBER )

RETURN VARCHAR2 ;

FUNCTION IGS_PR_get_sca_appeal(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2  ;

FUNCTION IGS_PR_GET_SCA_APPL(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version_number IN NUMBER ,
  p_course_type IN VARCHAR2 ,
  p_progression_rule_cat IN VARCHAR2 ,
  p_pra_sequence_number IN NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_start_effective_period IN NUMBER ,
  p_num_of_applications IN NUMBER ,
  p_pra_s_relation_type IN VARCHAR2 ,
  p_pra_sca_person_id IN NUMBER ,
  p_pra_sca_course_cd IN VARCHAR2 ,
  p_pra_crv_course_cd IN VARCHAR2 ,
  p_pra_crv_version_number IN NUMBER ,
  p_pra_ou_org_unit_cd IN VARCHAR2 ,
  p_pra_ou_start_dt IN DATE ,
  p_pra_course_type IN VARCHAR2 )
RETURN VARCHAR2 ;

FUNCTION IGS_PR_GET_SCA_CMT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE )
RETURN VARCHAR2 ;

FUNCTION IGS_PR_GET_SCA_STATE(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER )
RETURN VARCHAR2 ;

FUNCTION IGS_PR_GET_SCPM_VALUE(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_s_prg_measure_type IN VARCHAR2 )
RETURN NUMBER ;

END IGS_PR_GEN_005;

 

/
