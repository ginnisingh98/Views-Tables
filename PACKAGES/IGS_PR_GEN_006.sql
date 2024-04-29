--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_006
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_006" AUTHID CURRENT_USER AS
/* $Header: IGSPR27S.pls 115.8 2002/12/13 07:58:34 smanglm ship $ */

FUNCTION IGS_PR_GET_SCSC_COMP(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_cst_sequence_number IN NUMBER )

RETURN VARCHAR2 ;


FUNCTION IGS_PR_get_spo_aply_dt(

  p_decision_status IN VARCHAR2 ,

  p_old_applied_dt IN DATE ,

  p_new_applied_dt IN DATE ,

  p_old_encmb_course_group_cd IN VARCHAR2 ,

  p_new_encmb_course_group_cd IN VARCHAR2 ,

  p_old_restricted_enrolment_cp IN NUMBER ,

  p_new_restricted_enrolment_cp IN NUMBER ,

  p_old_restricted_attend_type IN VARCHAR2 ,

  p_new_restricted_attend_type IN VARCHAR2 ,

  p_old_expiry_dt IN DATE ,

  p_new_expiry_dt IN DATE ,


  p_old_duration IN NUMBER ,

  p_new_duration IN NUMBER ,

  p_old_duration_type IN VARCHAR2 ,

  p_new_duration_type IN VARCHAR2 ,

  p_out_applied_dt OUT NOCOPY DATE )

RETURN BOOLEAN ;


FUNCTION IGS_PR_GET_SPO_CMT(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_org_unit_cd IN VARCHAR2 ,

  p_ou_start_dt IN DATE ,

  p_course_type IN VARCHAR2 ,

  p_location_cd IN VARCHAR2 ,

  p_attendance_mode IN VARCHAR2 )

RETURN VARCHAR2 ;


FUNCTION IGS_PR_get_spo_expiry(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_spo_expiry_dt IN DATE ,

  p_expiry_dt OUT NOCOPY DATE )

RETURN VARCHAR2;

FUNCTION IGS_PR_get_sprc_dsp(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_ci_sequence_number IN NUMBER ,

  p_rule_check_dt IN DATE ,

  p_progression_rule_cat IN VARCHAR2 ,

  p_pra_sequence_number IN NUMBER )

RETURN VARCHAR2;
FUNCTION IGS_PR_GET_STD_GPA(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_sequence_number IN NUMBER )

RETURN NUMBER;



FUNCTION IGS_PR_GET_STD_WAM(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_course_version IN NUMBER ,

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_sequence_number IN NUMBER )

RETURN NUMBER ;



FUNCTION IGS_PR_get_within_appl(

  p_prg_cal_type IN VARCHAR2 ,

  p_prg_sequence_number IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_version_number IN NUMBER ,

  p_application_type IN VARCHAR2 ,

  p_start_dt OUT NOCOPY DATE ,

  p_cutoff_dt OUT NOCOPY DATE )

RETURN VARCHAR2;



FUNCTION IGS_PR_INS_COPY_PRA(

  p_progression_rule_cat IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_new_course_cd IN VARCHAR2 ,

  p_new_version_number IN NUMBER ,

  p_new_org_unit_cd IN VARCHAR2 ,

  p_new_ou_start_dt IN DATE ,

  p_new_spo_person_id IN NUMBER ,

  p_new_spo_course_cd IN VARCHAR2 ,

  p_new_spo_sequence_number IN NUMBER ,

  p_new_sca_person_id IN NUMBER ,

  p_new_sca_course_cd IN VARCHAR2 ,


  p_message_name OUT NOCOPY VARCHAR2 )

RETURN NUMBER;



FUNCTION IGS_PR_INS_SSP_CMP_DTL(

  p_rule_text IN VARCHAR2 ,

  p_message_text IN VARCHAR2 ,

  p_log_dt IN DATE ,

  p_key IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN BOOLEAN ;

FUNCTION IGS_PR_upd_pen_clash(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_spo_sequence_number IN NUMBER ,

  p_application_type IN VARCHAR2 ,

  p_message_text OUT NOCOPY VARCHAR2 ,

  p_message_level OUT NOCOPY VARCHAR2 )

RETURN boolean ;



FUNCTION IGS_PR_UPD_SCA_STATUS(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_current_progression_status IN VARCHAR2 ,

  p_course_version IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2 )

RETURN boolean;



FUNCTION IGS_PR_upd_spo_pen(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_spo_sequence_number IN NUMBER ,

  p_authorising_person_id IN NUMBER ,

  p_application_type IN VARCHAR2 ,

  p_message_text OUT NOCOPY VARCHAR2 ,

  p_message_level OUT NOCOPY VARCHAR2 )

RETURN boolean ;

FUNCTION IGS_PR_GET_SPO_EXPIRY(

  p_person_id IN NUMBER ,

  p_course_cd IN VARCHAR2 ,

  p_sequence_number IN NUMBER ,

  p_spo_expiry_dt IN DATE )

  RETURN VARCHAR2;

FUNCTION get_antcp_compl_dt(

  p_person_id   igs_en_stdnt_ps_att_all.person_id%TYPE,

  p_course_cd   igs_en_stdnt_ps_att_all.course_cd%TYPE)

  RETURN DATE;

END IGS_PR_GEN_006;

 

/
