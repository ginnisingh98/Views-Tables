--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_004
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_004" AUTHID CURRENT_USER AS
/* $Header: IGSAD04S.pls 115.5 2002/11/28 21:23:20 nsidana ship $ */
/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
rrengara   2-APR-2002    Added parameter P_error_message_research in procedure Admp_Get_Crs_Exists for the bug 2285677
rboddu     28-OCT-2002   Added the parameters p_attendance_mode and p_location_cd to the procedure Admp_Get_Crv_Comp_Dt. Bug: 2647482
-------------------------------------------------------------------*/

PROCEDURE Admp_Get_Apcs_Val(
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_apcs_pref_limit_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_app_fee_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_late_app_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_late_fee_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkpencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_fee_assess_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_corcategry_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_enrcategry_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkcencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_set_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_un_crs_us_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_chkuencumb_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_restr_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_unit_restriction_num OUT NOCOPY NUMBER ,
  p_apcs_un_dob_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_un_title_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_asses_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_fee_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_doc_cond_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_multi_off_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_multi_off_restrict_num OUT NOCOPY NUMBER ,
  p_apcs_set_otcome_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_override_o_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_defer_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_ack_app_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_outcome_lt_ind OUT NOCOPY VARCHAR2 ,
  p_apcs_pre_enrol_ind OUT NOCOPY VARCHAR2 );

FUNCTION Admp_Get_Archive_Ind(
  p_person_id IN NUMBER )
RETURN VARCHAR2;


FUNCTION Admp_Get_Chg_Pref_Dt(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2;


FUNCTION Admp_Get_Comm_Perd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2;


FUNCTION Admp_Get_Course_Det(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_record_number IN NUMBER ,
  p_extra_context OUT NOCOPY VARCHAR2 )
RETURN VARCHAR2;


FUNCTION Admp_Get_Cricos_Cd(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER )
RETURN VARCHAR2;


PROCEDURE Admp_Get_Crs_Exists(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_check_referee IN BOOLEAN ,
  p_check_scholarship IN BOOLEAN ,
  p_check_lang_prof IN BOOLEAN ,
  p_check_interview IN BOOLEAN ,
  p_check_exchange IN BOOLEAN ,
  p_check_adm_test IN BOOLEAN ,
  p_check_research IN BOOLEAN ,
  p_referee_exists OUT NOCOPY BOOLEAN ,
  p_scholarship_exists OUT NOCOPY BOOLEAN ,
  p_lang_prof_exists OUT NOCOPY BOOLEAN ,
  p_interview_exists OUT NOCOPY BOOLEAN ,
  p_exchange_exists OUT NOCOPY BOOLEAN ,
  p_adm_test_exists OUT NOCOPY BOOLEAN ,
  p_research_exists OUT NOCOPY BOOLEAN,
  p_error_message_research OUT NOCOPY VARCHAR2);

PROCEDURE Admp_Get_Crv_Comp_Dt(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expected_completion_yr IN OUT NOCOPY NUMBER ,
  p_expected_completion_perd IN OUT NOCOPY VARCHAR2 ,
  p_completion_dt OUT NOCOPY DATE,
  p_attendance_mode IN VARCHAR2 DEFAULT NULL,
  p_location_cd IN VARCHAR2 DEFAULT NULL);

END igs_ad_gen_004;

 

/
