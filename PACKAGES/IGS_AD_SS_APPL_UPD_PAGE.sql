--------------------------------------------------------
--  DDL for Package IGS_AD_SS_APPL_UPD_PAGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_SS_APPL_UPD_PAGE" AUTHID CURRENT_USER AS
/* $Header: IGSADC5S.pls 115.2 2003/06/20 07:52:41 nsinha noship $ */

  PROCEDURE create_perstat_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE check_adm_due_date_isvalid (
    p_adm_cal_type IN VARCHAR2 ,
    p_adm_ci_sequence_number IN NUMBER ,
    p_adm_cat IN VARCHAR2 ,
    p_s_adm_prc_type IN VARCHAR2 ,
    p_acad_cal_type IN VARCHAR2 ,
    l_msg_count OUT NOCOPY NUMBER,
    l_msg_data  OUT NOCOPY VARCHAR2 ,
    l_return_status OUT NOCOPY VARCHAR2);

 PROCEDURE validate_due_final_dt(
   p_adm_cal_type IN VARCHAR2,
   p_adm_ci_sequence_number IN NUMBER,
   p_adm_cat IN VARCHAR2,
   p_s_adm_prc_type IN VARCHAR2,
   p_course_cd IN VARCHAR2,
   p_crv_version_number IN NUMBER,
   p_acad_cal_type IN VARCHAR2,
   p_location_cd IN VARCHAR2,
   p_attendance_mode IN VARCHAR2,
   p_attendance_type IN VARCHAR2,
   l_msg_count OUT NOCOPY NUMBER,
   l_msg_data  OUT NOCOPY VARCHAR2,
   l_return_status OUT NOCOPY VARCHAR2);

 PROCEDURE validate_pref_unique(
    p_person_id IN  IGS_AD_PS_APPL_INST.person_id%TYPE,
    p_adm_appl_no IN IGS_AD_PS_APPL_INST.admission_appl_number%TYPE,
    p_course_cd IN IGS_AD_PS_APPL_INST.nominated_course_cd%TYPE,
    p_seq_number IN IGS_AD_PS_APPL_INST.sequence_number%TYPE,
    p_pref_number IN NUMBER,
    l_msg_count OUT NOCOPY NUMBER,
    l_msg_data  OUT NOCOPY VARCHAR2,
    l_return_status OUT NOCOPY VARCHAR2);

 FUNCTION admp_val_chg_of_pref(
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  l_message_name OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  FUNCTION admp_val_acai_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_admission_appl_number IN NUMBER ,
  p_nominated_course_cd IN VARCHAR2 ,
  p_acai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2,
  p_update_non_enrol_detail_ind OUT NOCOPY VARCHAR2 )RETURN VARCHAR2;

  FUNCTION admp_val_acai_pref(
  p_preference_number IN NUMBER ,
  p_pref_allowed IN VARCHAR2 DEFAULT 'N',
  p_pref_limit IN NUMBER ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2) RETURN VARCHAR2;

  FUNCTION admp_val_acai_opt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_adm_cal_type IN VARCHAR2 ,
  p_adm_ci_sequence_number IN NUMBER ,
  p_admission_cat IN VARCHAR2 ,
  p_s_admission_process_type IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_appl_dt IN DATE ,
  p_late_appl_allowed IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)RETURN VARCHAR2;


  FUNCTION admp_val_acai_us(
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_acad_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_admission_cat IN VARCHAR2 ,
  p_offer_ind IN VARCHAR2 DEFAULT 'N',
  p_unit_set_appl IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2,
  p_return_type OUT NOCOPY VARCHAR2 ) RETURN VARCHAR2;

  FUNCTION admp_val_aa_update(
  p_adm_appl_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )RETURN VARCHAR2;

  PROCEDURE final_scrn_intw_event(
            p_person_id                   IN NUMBER,
            p_admission_appl_number       IN NUMBER,
            p_nominated_course_cd         IN VARCHAR2,
            p_sequence_number             IN NUMBER,
            p_final_screening_decision    IN VARCHAR2,
            p_final_screening_date        IN DATE,
            p_panel_code                  IN VARCHAR2,
            p_raised_for                  IN VARCHAR2
  );
END igs_ad_ss_appl_upd_page;

 

/
