--------------------------------------------------------
--  DDL for Package IGS_RU_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RU_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSRU04S.pls 115.5 2002/11/29 03:39:49 nsidana ship $ */

Procedure Rulp_Ins_Make_Rule(
  p_description_number IN NUMBER DEFAULT NULL,
  p_return_type  VARCHAR2 DEFAULT NULL,
  p_rule_description  VARCHAR2 DEFAULT NULL,
  p_turing_function  VARCHAR2 DEFAULT NULL,
  p_rule_text  VARCHAR2 DEFAULT NULL,
  p_message_rule_text  VARCHAR2 DEFAULT NULL,
  p_description_text  VARCHAR2 ,
  p_group IN NUMBER DEFAULT 1,
  p_select_group IN NUMBER DEFAULT 1);

Function Rulp_Ins_Ur_Rule(
  p_unit_cd IN VARCHAR2 ,
  p_s_rule_call_cd IN VARCHAR2 ,
  p_insert_rule_only IN BOOLEAN ,
  p_rul_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Rulp_Val_Adm_Status(
  p_letter_parameter_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN VARCHAR2 ,
  p_adm_doc_status IN VARCHAR2 ,
  p_adm_entry_qual_status IN VARCHAR2 ,
  p_late_adm_fee_status IN VARCHAR2 ,
  p_adm_outcome_status IN VARCHAR2 ,
  p_adm_cndtnl_offer_status IN VARCHAR2 ,
  p_adm_offer_resp_status IN VARCHAR2 ,
  p_adm_offer_dfrmnt_status IN VARCHAR2 ,
  p_reconsideration IN BOOLEAN ,
  p_encumbrance IN BOOLEAN ,
  p_course_invalid IN BOOLEAN ,
  p_late IN BOOLEAN ,
  p_incomplete IN BOOLEAN ,
  p_correspondence_type  VARCHAR2 ,
  p_valid_alternate  BOOLEAN ,
  p_valid_address  BOOLEAN ,
  p_valid_disability  BOOLEAN ,
  p_valid_visa  BOOLEAN ,
  p_valid_finance  BOOLEAN ,
  p_valid_notes  BOOLEAN ,
  p_valid_statistics  BOOLEAN ,
  p_valid_alias  BOOLEAN ,
  p_valid_tertiary  BOOLEAN ,
  p_valid_aus_sec_ed  BOOLEAN ,
  p_valid_os_sec_ed  BOOLEAN ,
  p_valid_employment  BOOLEAN ,
  p_valid_membership  BOOLEAN ,
  p_valid_dob  BOOLEAN ,
  p_valid_title  BOOLEAN ,
  p_valid_referee  BOOLEAN ,
  p_valid_scholarship  BOOLEAN ,
  p_valid_lang_prof  BOOLEAN ,
  p_valid_interview  BOOLEAN ,
  p_valid_exchange  BOOLEAN ,
  p_valid_adm_test IN BOOLEAN ,
  p_valid_fee_assess  BOOLEAN ,
  p_valid_cor_category  BOOLEAN ,
  p_valid_enr_category  BOOLEAN ,
  p_valid_research  BOOLEAN ,
  p_valid_rank_app  BOOLEAN ,
  p_valid_completion  BOOLEAN ,
  p_valid_rank_set  BOOLEAN ,
  p_valid_basis_adm  BOOLEAN ,
  p_valid_crs_international  BOOLEAN ,
  p_valid_ass_tracking  BOOLEAN ,
  p_valid_adm_code  BOOLEAN ,
  p_valid_fund_source IN BOOLEAN ,
  p_valid_location  BOOLEAN ,
  p_valid_att_mode  BOOLEAN ,
  p_valid_att_type  BOOLEAN ,
  p_valid_unit_set  BOOLEAN )
RETURN VARCHAR2;


Function Rulp_Val_Desc_Rgi(
  p_description_number IN NUMBER ,
  p_description_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (Rulp_Val_Desc_Rgi, WNDS)   ;

Function Rulp_Val_Gpa(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_best_worst IN VARCHAR2 DEFAULT 'N',
  p_recommend_ind IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;


Function Rulp_Val_Named_Rule(
  p_return_type  VARCHAR2 ,
  p_rule_name  VARCHAR2 ,
  p_person_id IN NUMBER )
RETURN VARCHAR2;


Function Rulp_Val_Wam(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version  NUMBER ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_ci_sequence_number IN NUMBER ,
  p_recommend_ind IN VARCHAR2 DEFAULT 'N',
  p_abort_when_missing IN VARCHAR2 DEFAULT 'N')
RETURN VARCHAR2;


END IGS_RU_GEN_004;

 

/
