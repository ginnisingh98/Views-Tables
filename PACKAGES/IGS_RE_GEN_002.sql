--------------------------------------------------------
--  DDL for Package IGS_RE_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_RE_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSRE02S.pls 120.0 2005/06/02 04:07:36 appldev noship $ */
PROCEDURE resp_get_ca_exists(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_check_thesis IN BOOLEAN ,
  p_check_field_of_study IN BOOLEAN ,
  p_check_seo_class_cd IN BOOLEAN ,
  p_check_supervisor IN BOOLEAN ,
  p_check_milestone IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_thesis_exists OUT NOCOPY BOOLEAN ,
  p_field_of_study_exists OUT NOCOPY BOOLEAN ,
  p_seo_class_cd_exists OUT NOCOPY BOOLEAN ,
  p_supervisor_exists OUT NOCOPY BOOLEAN ,
  p_milestone_exists OUT NOCOPY BOOLEAN ,
  p_scholarship_exists OUT NOCOPY BOOLEAN ) ;

FUNCTION resp_get_rsup_start(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
  p_acai_admission_appl_number IN NUMBER ,
  p_acai_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_parent IN VARCHAR2 )
RETURN DATE ;
PRAGMA RESTRICT_REFERENCES(RESP_GET_RSUP_START,WNDS,WNPS);

PROCEDURE resp_get_sca_ca_acai(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_out_admission_appl_number OUT NOCOPY NUMBER ,
  p_out_nominated_course_cd OUT NOCOPY VARCHAR2 ,
  p_out_acai_sequence_number OUT NOCOPY NUMBER ) ;


FUNCTION RESP_GET_SUA_EFTD(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_unit_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_effective_dt IN DATE ,
  p_load_cal_type IN VARCHAR2 ,
  p_load_ci_sequence_number IN NUMBER ,
  p_cal_type_eftd OUT NOCOPY NUMBER )
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(RESP_GET_SUA_EFTD,WNDS,WNPS);


FUNCTION RESP_GET_TEACH_DAYS(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE )
RETURN NUMBER ;
PRAGMA RESTRICT_REFERENCES(RESP_GET_TEACH_DAYS, WNDS,WNPS);


PROCEDURE RESP_GET_THE_EXISTS(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_check_thesis_exam IN boolean ,
  p_check_milestone IN boolean ,
  p_thesis_exam_exists OUT NOCOPY boolean ,
  p_milestone_exists OUT NOCOPY boolean ) ;



FUNCTION RESP_GET_THE_STATUS(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_the_sequence_number IN NUMBER ,
  p_details_passed_ind IN VARCHAR2 ,
  p_logical_delete_dt IN DATE ,
  p_thesis_result_cd IN VARCHAR2 )
RETURN VARCHAR2 ;
PRAGMA RESTRICT_REFERENCES(RESP_GET_THE_STATUS, WNDS,WNPS);


FUNCTION resp_ins_ca_cah(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_sca_course_cd IN VARCHAR2 ,
p_old_attendance_percentage IN NUMBER ,
p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN  ;

PROCEDURE resp_ins_ca_hist(
  p_person_id IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_old_sca_course_cd IN VARCHAR2 ,
  p_new_sca_course_cd IN VARCHAR2 ,
  p_old_acai_adm_appl_num IN NUMBER ,
  p_new_acai_adm_appl_num IN NUMBER ,
  p_old_acai_nominated_course_cd IN VARCHAR2 ,
  p_new_acai_nominated_course_cd IN VARCHAR2 ,
  p_old_acai_sequence_number IN NUMBER ,
  p_new_acai_sequence_number IN NUMBER ,
  p_old_attendance_percentage IN NUMBER ,
  p_new_attendance_percentage IN NUMBER ,
  p_old_govt_type_of_activity_cd IN VARCHAR2 ,
  p_new_govt_type_of_activity_cd IN VARCHAR2 ,
  p_old_max_submission_dt IN DATE ,
  p_new_max_submission_dt IN DATE ,
  p_old_min_submission_dt IN DATE ,
  p_new_min_submission_dt IN DATE ,
  p_old_research_topic IN VARCHAR2 ,
  p_new_research_topic IN VARCHAR2 ,
  p_old_industry_links IN VARCHAR2 ,
  p_new_industry_links IN VARCHAR2 ,
  p_old_update_who IN NUMBER ,
  p_new_update_who IN NUMBER ,
  p_old_update_on IN DATE ,
  p_new_update_on IN DATE ) ;


FUNCTION RESP_INS_DFLT_MIL(
  p_person_id IN NUMBER ,
  p_ca_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean  ;

END IGS_RE_GEN_002;

 

/
