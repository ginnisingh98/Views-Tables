--------------------------------------------------------
--  DDL for Package IGS_AD_UPD_INITIALISE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_UPD_INITIALISE" AUTHID CURRENT_USER AS
/* $Header: IGSAD16S.pls 120.2 2006/05/02 05:23:53 apadegal noship $ */

  --
  -- Update admission COURSE application instance IGS_PS_UNIT initialisation.

  PROCEDURE admp_upd_acaiu_init(
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offered_ind IN VARCHAR2 DEFAULT 'N',
  p_s_log_type IN VARCHAR2 ,
  p_creation_dt IN DATE )
;

FUNCTION perform_pre_enrol (
        p_person_id IN igs_ad_ps_appl_inst. person_id%TYPE,
        p_admission_appl_number IN igs_ad_ps_appl_inst. admission_appl_number%TYPE,
        p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
        p_sequence_number IN igs_ad_ps_appl_inst.sequence_number%TYPE,
        p_confirm_ind IN VARCHAR2,
        p_check_eligibility_ind IN VARCHAR2,
	p_message_name OUT NOCOPY VARCHAR2)
  RETURN BOOLEAN ;

PROCEDURE perform_pre_enrol (
        p_person_id IN igs_ad_ps_appl_inst. person_id%TYPE,
        p_admission_appl_number IN igs_ad_ps_appl_inst. admission_appl_number%TYPE,
        p_nominated_course_cd IN igs_ad_ps_appl_inst.nominated_course_cd%TYPE,
        p_sequence_number IN igs_ad_ps_appl_inst.sequence_number%TYPE,
        p_confirm_ind IN VARCHAR2,
        p_check_eligibility_ind IN VARCHAR2);

FUNCTION get_msg_name_mapping (
       p_msg_name IN VARCHAR2)
  RETURN VARCHAR2 ;

PROCEDURE update_per_stats (
     p_person_id  IN igs_ad_ps_appl_inst.person_id%TYPE,
     p_admission_appl_number IN igs_ad_ps_appl_inst.admission_appl_number%TYPE DEFAULT NULL,
     p_acptd_or_reopnd_ind  IN VARCHAR2 DEFAULT NULL
   ) ;

END IGS_AD_UPD_INITIALISE;

 

/
