--------------------------------------------------------
--  DDL for Package IGS_SS_ENROLL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_SS_ENROLL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSS04S.pls 120.0 2005/06/01 21:52:12 appldev noship $ */

PROCEDURE insert_into_enr_cart
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_person_id  IN  VARCHAR2,
   p_cal_type IN VARCHAR2,
   p_ci_sequence_number IN VARCHAR2,
   p_call_number IN VARCHAR2,
   p_org_id IN NUMBER
) ;

PROCEDURE insert_into_enr_cart
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_insert_flag OUT NOCOPY VARCHAR2,
   p_person_id  IN  VARCHAR2,
   p_cal_type IN VARCHAR2,
   p_ci_sequence_number IN VARCHAR2,
   p_unit_cd IN VARCHAR2,
   p_unit_class IN VARCHAR2,
   p_org_id IN NUMBER
) ;

PROCEDURE insert_into_enr_cart
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_person_id  IN  VARCHAR2,
   p_uoo_id IN VARCHAR2,
   p_org_id IN NUMBER
) ;

PROCEDURE remove_from_shopping_cart
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_person_id  IN  VARCHAR2,
   p_uoo_id IN VARCHAR2,
   p_course_cd IN VARCHAR2
) ;

PROCEDURE insert_into_su_attempt
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_org_id  IN NUMBER,
   p_person_id  IN  VARCHAR2,
   p_course_cd IN VARCHAR2,
   p_uoo_id IN VARCHAR2,
   p_grading_schema IN VARCHAR2,
   p_enrolled_cp IN VARCHAR2
) ;

PROCEDURE delete_from_su_attempt
(
   p_return_status OUT NOCOPY VARCHAR2,
   p_msg_count OUT NOCOPY NUMBER,
   p_msg_data OUT NOCOPY VARCHAR2,
   p_org_id   IN NUMBER ,
   p_person_id  IN  VARCHAR2,
   p_course_cd IN VARCHAR2,
   p_uoo_id IN VARCHAR2
) ;

FUNCTION get_Sch_disp_acad(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_Sch_disp_term(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION get_Sch_disp_term_st_dt(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2)
  RETURN DATE;

FUNCTION enrf_get_lookup_meaning(
  p_lookup_code IN VARCHAR2,
  p_lookup_type IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION enrf_get_sca_trans_ind(
  p_person_id IN NUMBER ,
  p_source_program_cd IN VARCHAR2,
  p_dest_program_cd IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION enrf_get_sua_trans_ind(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_uoo_id IN NUMBER )
  RETURN VARCHAR2;

FUNCTION enrf_get_susa_trans_ind(
  p_person_id IN NUMBER ,
  p_program_cd IN VARCHAR2,
  p_unit_set_cd IN VARCHAR2,
  p_us_version_number IN NUMBER)
  RETURN VARCHAR2;

FUNCTION get_dup_sua_src_prog(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER)
  RETURN VARCHAR2;

FUNCTION enrf_get_mark_grade(
  p_person_id IN NUMBER,
  p_course_cd IN VARCHAR2,
  p_uoo_id IN NUMBER,
  p_unit_attempt_Status IN VARCHAR2)
  RETURN VARCHAR2;

FUNCTION enrf_get_cal_desc(
  p_cal_type IN VARCHAR2,
  p_sequence_number IN NUMBER)
  RETURN VARCHAR2;

FUNCTION enrf_get_acad_cal_desc(
  p_teach_cal_type IN VARCHAR2,
  p_teach_seqeunce_number IN NUMBER)
  RETURN VARCHAR2;

FUNCTION enrp_get_career_drop_dup(
  p_person_id in NUMBER ,
  p_program_cd in VARCHAR2,
  p_uoo_id in NUMBER)
  RETURN VARCHAR2;


end igs_ss_enroll_pkg ;

 

/
