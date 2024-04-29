--------------------------------------------------------
--  DDL for Package IGS_RE_GEN_003
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_GEN_003" AUTHID CURRENT_USER AS
/* $Header: IGSRE03S.pls 115.3 2002/11/29 03:27:15 nsidana ship $ */
PROCEDURE RESP_INS_MIL_HIST(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_milestone_type IN VARCHAR2 ,
  p_new_milestone_type IN VARCHAR2 ,
  p_old_milestone_status IN VARCHAR2 ,
  p_new_milestone_status IN VARCHAR2 ,
  p_old_due_dt IN DATE ,
  p_new_due_dt IN DATE ,
  p_old_description IN VARCHAR2 ,
  p_new_description IN VARCHAR2 ,
  p_old_actual_reached_dt IN DATE ,
  p_new_actual_reached_dt IN DATE ,
  p_old_preced_sequence_number IN NUMBER ,
  p_new_preced_sequence_number IN NUMBER ,
  p_old_ovrd_ntfctn_immnnt_days IN NUMBER ,
  p_new_ovrd_ntfctn_immnnt_days IN NUMBER ,
  p_old_ovrd_ntfctn_rmndr_days IN NUMBER ,
  p_new_ovrd_ntfctn_rmndr_days IN NUMBER ,
  p_old_re_reminder_days IN NUMBER ,
  p_new_re_reminder_days IN NUMBER ,
  p_old_comments IN VARCHAR2 ,
  p_new_comments IN VARCHAR2 ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE ) ;


 PROCEDURE RESP_INS_TEX_HIST(
  P_PERSON_ID IN NUMBER ,
  P_CA_SEQUENCE_NUMBER IN NUMBER ,
  P_THE_SEQUENCE_NUMBER IN NUMBER ,
  P_CREATION_DT IN DATE ,
  P_OLD_SUBMISSION_DT IN DATE ,
  P_NEW_SUBMISSION_DT IN DATE ,
  P_OLD_THESIS_EXAM_TYPE IN VARCHAR2 ,
  P_NEW_THESIS_EXAM_TYPE IN VARCHAR2 ,
  p_old_thesis_panel_type IN VARCHAR2 ,
  p_new_thesis_panel_type IN VARCHAR2 ,
  p_old_thesis_result_cd IN VARCHAR2 ,
  p_new_thesis_result_cd IN VARCHAR2 ,
  p_old_tracking_id IN NUMBER ,
  p_new_tracking_id  NUMBER ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE ) ;


 FUNCTION RESP_INS_TEX_TRI(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_thesis_panel_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
 RETURN NUMBER ;

 PROCEDURE RESP_INS_THE_HIST(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_title IN VARCHAR2 ,
  p_new_title IN VARCHAR2 ,
  p_old_final_title_ind IN VARCHAR2 ,
  p_new_final_title_ind IN VARCHAR2 ,
  p_old_short_title IN VARCHAR2 ,
  p_new_short_title IN VARCHAR2 ,
  p_old_abbreviated_title IN VARCHAR2 ,
  p_new_abbreviated_title IN VARCHAR2 ,
  p_old_thesis_result_cd IN VARCHAR2 ,
  p_new_thesis_result_cd IN VARCHAR2 ,
  p_old_expected_submission_dt IN DATE ,
  p_new_expected_submission_dt IN DATE ,
  p_old_library_lodgement_dt IN DATE ,
  p_new_library_lodgement_dt IN DATE ,
  p_old_library_catalogue_number IN VARCHAR2 ,
  p_new_library_catalogue_number IN VARCHAR2 ,
  p_old_embargo_expiry_dt IN DATE ,
  p_new_embargo_expiry_dt IN DATE ,
  p_old_thesis_format IN VARCHAR2 ,
  p_new_thesis_format IN VARCHAR2 ,
  p_old_logical_delete_dt IN DATE ,
  p_new_logical_delete_dt IN DATE ,
  p_old_embargo_details IN VARCHAR2 ,
  p_new_embargo_details IN VARCHAR2 ,
  p_old_thesis_topic IN VARCHAR2 ,
  p_new_thesis_topic IN VARCHAR2 ,
  p_old_citation IN VARCHAR2 ,
  p_new_citation IN VARCHAR2 ,
  p_old_comments IN VARCHAR2 ,
  p_new_comments IN VARCHAR2 ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE ) ;

 PROCEDURE RESP_INS_TPM_HIST(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_creation_dt IN DATE ,
  p_person_id IN NUMBER ,
  p_old_panel_member_type IN VARCHAR2 ,
  p_new_panel_member_type IN VARCHAR2 ,
  p_old_confirmed_dt IN DATE ,
  p_new_confirmed_dt IN DATE ,
  p_old_declined_dt IN DATE ,
  p_new_declined_dt IN DATE ,
  p_old_anonymity_ind IN VARCHAR2 ,
  p_new_anonymity_ind IN VARCHAR2 ,
  p_old_thesis_result_cd IN VARCHAR2 ,
  p_new_thesis_result_cd IN VARCHAR2 ,
  p_old_paid_dt IN DATE ,
  p_new_paid_dt IN DATE ,
  p_old_tracking_id IN NUMBER ,
  p_new_tracking_id IN NUMBER ,
  p_old_recommendation_summary IN VARCHAR2 ,
  p_new_recommendation_summary IN VARCHAR2 ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE ) ;


 FUNCTION RESP_INS_TPM_TRI(
  p_ca_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_panel_member_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
 RETURN NUMBER  ;

END IGS_RE_GEN_003 ;

 

/
