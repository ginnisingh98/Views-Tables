--------------------------------------------------------
--  DDL for Package IGS_AD_PRC_TAC_OFFER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PRC_TAC_OFFER" AUTHID CURRENT_USER AS
/* $Header: IGSAD15S.pls 115.8 2002/11/28 21:25:48 nsidana ship $ */

/******************************************************************
Created By:
Date Created By:
Purpose:
Known limitations,enhancements,remarks:
Change History
Who        When          What
vchappid   29-Aug-2001   Added new parameters into function calls, Enh Bug#1964478
knag       21-Nov-2002   Added new parameters to admp_ins_adm_appl for bug 2664410
******************************************************************/


  --
  -- Get the admission category for this course offering option
  FUNCTION admp_get_ac_cooac(
  p_coo_id IN NUMBER ,
  p_admission_cat IN OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Insert an Australian secondary education record
  FUNCTION admp_ins_aus_scn_edu(
  p_person_id IN NUMBER ,
  p_result_obtained_yr IN NUMBER ,
  p_score IN NUMBER ,
  p_state_cd IN VARCHAR2 ,
  p_candidate_number IN NUMBER ,
  p_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_secondary_school_cd IN VARCHAR2 ,
  p_ase_sequence_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Insert an Australian secondary education subject record
  FUNCTION admp_ins_aus_scn_sub(
  p_person_id IN NUMBER ,
  p_ase_sequence_number IN NUMBER ,
  p_subject_result_yr IN NUMBER ,
  p_subject_cd IN VARCHAR2 ,
  p_subject_desc IN VARCHAR2 ,
  p_subject_mark IN VARCHAR2 ,
  p_subject_mark_level IN VARCHAR2 ,
  p_subject_weighting IN VARCHAR2 ,
  p_subject_ass_type IN VARCHAR2 ,
  p_notes IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Retrieves the admission code and basis for admission type

  --
  -- Finds the user defined tertiary edu level of completion.
FUNCTION ADMP_GET_LVL_COMP(
  p_tac_level_of_comp IN VARCHAR2 )
RETURN VARCHAR2;

  --
  -- Inserts an admission application record
  FUNCTION admp_ins_adm_appl(
  p_person_id IN NUMBER ,
  p_appl_dt IN DATE ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_adm_appl_status IN VARCHAR2 ,
  p_adm_fee_status IN OUT NOCOPY VARCHAR2 ,
  p_tac_appl_ind IN VARCHAR2 DEFAULT 'N',
  p_adm_appl_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_spcl_grp_1   IN NUMBER DEFAULT NULL,  --Bug#1964478, Parameter added
  p_spcl_grp_2   IN NUMBER DEFAULT NULL,  --Bug#1964478, Parameter added
  p_common_app   IN VARCHAR2 DEFAULT NULL, --Bug#1964478, Parameter added
  p_application_type IN VARCHAR2 DEFAULT NULL,
  p_choice_number IN VARCHAR2 DEFAULT NULL,
  p_routeb_pref IN VARCHAR2 DEFAULT NULL,
  p_alt_appl_id IN VARCHAR2 DEFAULT NULL  -- Added for Bug 2664410
 )
RETURN BOOLEAN;

  --
  -- Inserts TAC details to form an admission course application instance
  FUNCTION admp_ins_tac_acai(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_appl_dt IN DATE ,
  p_adm_fee_status IN VARCHAR2 ,
  p_preference_number IN NUMBER ,
  p_offer_dt IN DATE ,
  p_offer_response_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_insert_outcome_ind IN VARCHAR2 DEFAULT 'N',
  p_pre_enrol_ind IN VARCHAR2 DEFAULT 'N',
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Inserts TAC details to form an admission course
  FUNCTION admp_ins_tac_course(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_enrolment_cat IN VARCHAR2 ,
  p_correspondence_cat IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_tac_course_cd IN VARCHAR2 ,
  p_preference_number IN NUMBER ,
  p_appl_dt IN DATE ,
  p_offer_dt IN DATE ,
  p_basis_for_admission_type IN VARCHAR2 ,
  p_admission_cd IN VARCHAR2 ,
  p_fee_paying_appl_ind IN VARCHAR2 ,
  p_hecs_payment_option IN VARCHAR2 ,
  p_insert_outcome_letter_ind IN VARCHAR2 DEFAULT 'N',
  p_pre_enrol_ind IN VARCHAR2 DEFAULT 'N',
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_tac_course_match_ind OUT NOCOPY VARCHAR2 ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Insert a tertiary education record
  FUNCTION admp_ins_tert_edu(
  p_person_id IN NUMBER ,
  p_exclusion_ind IN VARCHAR2 DEFAULT 'N',
  p_tertiary_edu_lvl_comp IN VARCHAR2 ,
  p_enrolment_first_yr IN NUMBER ,
  p_institution_cd IN VARCHAR2 ,
  p_enrolment_latest_yr IN NUMBER ,
  p_grade_point_average IN NUMBER ,
  p_language_of_tuition IN VARCHAR2 ,
  p_qualification IN VARCHAR2 ,
  p_institution_name IN VARCHAR2 ,
  p_equiv_full_time_yrs_enr IN NUMBER ,
  p_student_id IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_course_title IN VARCHAR2 ,
  p_state_cd IN VARCHAR2 ,
  p_level_of_achievement_type IN VARCHAR2 ,
  p_field_of_study IN VARCHAR2 ,
  p_language_component IN VARCHAR2 ,
  p_country_cd IN VARCHAR2 ,
  p_tertiary_edu_lvl_qual IN VARCHAR2 ,
  p_honours_level IN VARCHAR2 ,
  p_notes IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_inserted_ind OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- inserts a new record into the IGS_PE_ALT_PERS_ID table
  PROCEDURE admp_ins_alt_prsn_id(
  p_alt_person_id IN VARCHAR2 ,
  p_alt_person_id_type IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE )
;
  --
  -- Inserts a IGS_PE_PERSON and alternate IGS_PE_PERSON ID record with data from TAC
  FUNCTION admp_ins_tac_prsn(
  p_person_id IN NUMBER ,
  p_tac_person_id IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_given_names IN VARCHAR2 ,
  p_sex IN VARCHAR2 ,
  p_birth_dt IN DATE ,
  p_alt_person_id_type IN VARCHAR2 ,
  p_new_person_id OUT NOCOPY NUMBER ,
  p_message_out OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Insert a new IGS_PE_PERSON address record and end date the previous record
  FUNCTION admp_ins_person_addr(
  p_person_id IN NUMBER ,
  p_addr_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_addr_line_1 IN VARCHAR2 ,
  p_addr_line_2  VARCHAR2 ,
  p_addr_line_3 IN VARCHAR2 ,
  p_addr_line_4 IN VARCHAR2 ,
  p_aust_postcode IN NUMBER ,
  p_os_code IN VARCHAR2 ,
  p_phone_1 IN VARCHAR2 ,
  p_phone_2 IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Insert a admission course application record
  FUNCTION admp_ins_adm_crs_app(
  p_person_id IN NUMBER ,
  p_adm_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_basis_for_admission_type IN VARCHAR2 ,
  p_admission_cd IN VARCHAR2 ,
  p_req_for_reconsideration_ind IN VARCHAR2 DEFAULT 'N',
  p_req_for_adv_standing_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_PRC_TAC_OFFER;

 

/
