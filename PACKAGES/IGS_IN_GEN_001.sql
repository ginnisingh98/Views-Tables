--------------------------------------------------------
--  DDL for Package IGS_IN_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_IN_GEN_001" AUTHID CURRENT_USER AS
  /* $Header: IGSIN01S.pls 120.0 2005/06/01 16:58:28 appldev noship $ */
/*
| Who         When            What
|
| knaraset  09-May-03   Modified inqp_get_sua_achvd to add parameter p_uoo_id,
|                       as part of MUS build bug 2829262
|
*/
FUNCTION inqp_get_appl_ind(
  p_person_id IN NUMBER )
RETURN BOOLEAN ;
--PRAGMA RESTRICT_REFERENCES (inqp_get_appl_ind,WNDS);

FUNCTION inqp_get_encmb(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_level IN VARCHAR2 ,
  p_effective_dt IN DATE ,
  p_serious_only_ind IN VARCHAR2 ,
  p_include_all_course_ind IN VARCHAR2 ,
  p_academic_ind OUT NOCOPY VARCHAR2 ,
  p_admin_ind OUT NOCOPY VARCHAR2 )
RETURN boolean ;
--PRAGMA RESTRICT_REFERENCES (inqp_get_encmb,WNDS);
PROCEDURE inqp_get_enr_cat(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_enrolment_cat OUT NOCOPY VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 );

PROCEDURE inqp_get_prg_cp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cp_required OUT NOCOPY NUMBER ,
  p_cp_passed OUT NOCOPY NUMBER ,
  p_adv_granted OUT NOCOPY NUMBER ,
  p_enrolled_cp OUT NOCOPY NUMBER ,
  p_cp_remaining OUT NOCOPY NUMBER );

PROCEDURE inqp_get_sca_status(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_attempt_status IN VARCHAR2 ,
  p_commencement_dt IN DATE ,
  p_discontinued_dt IN DATE ,
  p_discontinuation_reason_cd IN VARCHAR2 ,
  p_lapsed_dt IN DATE ,
  p_status_dt OUT NOCOPY DATE ,
  p_reason_cd OUT NOCOPY VARCHAR2 ,
  p_description OUT NOCOPY VARCHAR2 );

PROCEDURE inqp_get_scho(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_hecs_payment_option OUT NOCOPY VARCHAR2 ,
  p_tax_file_number_ind OUT NOCOPY VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE );

PROCEDURE inqp_get_sci(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_start_dt OUT NOCOPY DATE ,
  p_end_dt OUT NOCOPY DATE ,
  p_voluntary_ind OUT NOCOPY VARCHAR2 );

FUNCTION inqp_get_sua_achvd(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_ci_end_dt IN DATE ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_override_achievable_cp IN NUMBER ,
  p_s_result_type IN VARCHAR2 ,
  p_repeatable_ind IN VARCHAR2 ,
  p_achievable_credit_points IN NUMBER ,
  p_enrolled_credit_points IN NUMBER,
  p_uoo_id IN igs_en_su_attempt.uoo_id%TYPE)
RETURN NUMBER;
 PRAGMA RESTRICT_REFERENCES(inqp_get_sua_achvd,WNDS,WNPS);

END igs_in_gen_001 ;

 

/
