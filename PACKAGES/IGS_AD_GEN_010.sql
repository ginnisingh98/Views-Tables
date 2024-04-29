--------------------------------------------------------
--  DDL for Package IGS_AD_GEN_010
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_GEN_010" AUTHID CURRENT_USER AS
/* $Header: IGSAD10S.pls 115.7 2003/12/03 20:48:58 knag ship $ */

Function Admp_Get_Tac_Api(
  p_person_id IN NUMBER )
RETURN VARCHAR2;

Function Admp_Get_Tac_Ceprc(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_reference_cd IN VARCHAR2 ,
  p_admission_cat IN OUT NOCOPY VARCHAR2 ,
  p_course_cd OUT NOCOPY VARCHAR2 ,
  p_version_number OUT NOCOPY NUMBER ,
  p_cal_type OUT NOCOPY VARCHAR2 ,
  p_location_cd OUT NOCOPY VARCHAR2 ,
  p_attendance_mode OUT NOCOPY VARCHAR2 ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_unit_set_cd OUT NOCOPY VARCHAR2 ,
  p_us_version_number OUT NOCOPY NUMBER ,
  p_coo_id OUT NOCOPY NUMBER ,
  p_ref_cd_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Get_Tac_Return(
  p_tac_person_id IN VARCHAR2 ,
  p_surname IN VARCHAR2 ,
  p_given_name1 IN VARCHAR2 ,
  p_given_name2 IN VARCHAR2 ,
  p_tac_course_cd IN OUT NOCOPY VARCHAR2 ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_offer_response OUT NOCOPY VARCHAR2 ,
  p_enrol_status OUT NOCOPY VARCHAR2 ,
  p_attendance_type OUT NOCOPY VARCHAR2 ,
  p_attendance_mode OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Get_Unit_Det(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_record_number IN NUMBER )
RETURN VARCHAR2;

Function Admp_Ins_Aal(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Function Admp_Ins_Aal_Commit(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_correspondence_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

Procedure Admp_Ins_Aa_Hist(
  p_person_id IN IGS_AD_APPL_ALL.person_id%TYPE ,
  p_admission_appl_number IN NUMBER ,
  p_new_appl_dt IN IGS_AD_APPL_ALL.appl_dt%TYPE ,
  p_old_appl_dt IN IGS_AD_APPL_ALL.appl_dt%TYPE ,
  p_new_acad_cal_type IN IGS_AD_APPL_ALL.acad_cal_type%TYPE ,
  p_old_acad_cal_type IN IGS_AD_APPL_ALL.acad_cal_type%TYPE ,
  p_new_acad_ci_sequence_number IN NUMBER ,
  p_old_acad_ci_sequence_number IN NUMBER ,
  p_new_adm_cal_type IN IGS_AD_APPL_ALL.adm_cal_type%TYPE ,
  p_old_adm_cal_type IN IGS_AD_APPL_ALL.adm_cal_type%TYPE ,
  p_new_adm_ci_sequence_number IN NUMBER ,
  p_old_adm_ci_sequence_number IN NUMBER ,
  p_new_admission_cat IN IGS_AD_APPL_ALL.admission_cat%TYPE ,
  p_old_admission_cat IN IGS_AD_APPL_ALL.admission_cat%TYPE ,
  p_new_s_admission_process_type IN VARCHAR2 ,
  p_old_s_admission_process_type IN VARCHAR2 ,
  p_new_adm_appl_status IN IGS_AD_APPL_ALL.adm_appl_status%TYPE ,
  p_old_adm_appl_status IN IGS_AD_APPL_ALL.adm_appl_status%TYPE ,
  p_new_adm_fee_status IN IGS_AD_APPL_ALL.adm_fee_status%TYPE ,
  p_old_adm_fee_status IN IGS_AD_APPL_ALL.adm_fee_status%TYPE ,
  p_new_tac_appl_ind IN IGS_AD_APPL_ALL.tac_appl_ind%TYPE ,
  p_old_tac_appl_ind IN IGS_AD_APPL_ALL.tac_appl_ind%TYPE ,
  p_new_update_who IN IGS_AD_APPL_ALL.last_updated_by%TYPE ,
  p_old_update_who IN IGS_AD_APPL_ALL.last_updated_by%TYPE ,
  p_new_update_on IN IGS_AD_APPL_ALL.last_update_date%TYPE ,
  p_old_update_on IN IGS_AD_APPL_ALL.last_update_date%TYPE );

Procedure Admp_Ins_Acaiu_Hist(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_adm_ps_appl_inst_unit_id IN NUMBER DEFAULT NULL,
  p_new_uv_version_number IN NUMBER ,
  p_old_uv_version_number IN NUMBER ,
  p_new_cal_type IN VARCHAR2 ,
  p_old_cal_type IN VARCHAR2 ,
  p_new_ci_sequence_number IN NUMBER ,
  p_old_ci_sequence_number IN NUMBER ,
  p_new_location_cd IN VARCHAR2 ,
  p_old_location_cd IN VARCHAR2 ,
  p_new_unit_class IN VARCHAR2 ,
  p_old_unit_class IN VARCHAR2 ,
  p_new_unit_mode IN VARCHAR2 ,
  p_old_unit_mode IN VARCHAR2 ,
  p_new_adm_unit_outcome_status IN VARCHAR2 ,
  p_old_adm_unit_outcome_status IN VARCHAR2 ,
  p_new_ass_tracking_id IN NUMBER ,
  p_old_ass_tracking_id IN NUMBER ,
  p_new_rule_waived_dt IN DATE ,
  p_old_rule_waived_dt IN DATE ,
  p_new_rule_waived_person_id IN NUMBER ,
  p_old_rule_waived_person_id IN NUMBER ,
  p_new_sup_unit_cd IN VARCHAR2 ,
  p_old_sup_unit_cd IN VARCHAR2 ,
  p_new_sup_uv_version_number IN NUMBER ,
  p_old_sup_uv_version_number IN NUMBER ,
  p_new_update_who IN VARCHAR2 ,
  p_old_update_who IN VARCHAR2 ,
  p_new_update_on IN DATE ,
  p_old_update_on IN DATE );

END IGS_AD_GEN_010;

 

/
