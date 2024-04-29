--------------------------------------------------------
--  DDL for Package IGS_AS_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSAS02S.pls 115.7 2003/05/27 18:42:28 anilk ship $ */

FUNCTION assp_get_atyp_exmnbl(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.assessment_type%TYPE )
RETURN VARCHAR2 ;
FUNCTION assp_get_dflt_exloc(
  p_location_cd IN VARCHAR2 )
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(assp_get_dflt_exloc,WNDS,WNPS);
FUNCTION assp_get_dflt_finls(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER )
RETURN VARCHAR2 ;
 FUNCTION assp_get_dflt_grade(
  p_mark IN NUMBER ,
  p_grading_schema_cd IN VARCHAR2 ,
  p_gs_version_number IN NUMBER )
RETURN VARCHAR2 ;
 FUNCTION assp_get_exam_view(
  p_uai_exam_cal_type  IGS_AS_UNITASS_ITEM_ALL.exam_cal_type%TYPE ,
  p_uai_exam_ci_seq  IGS_AS_UNITASS_ITEM_ALL.exam_ci_sequence_number%TYPE ,
  p_ueciv_exam_cal_type  IGS_AS_UNITASS_ITEM_ALL.exam_cal_type%TYPE ,
  p_ueciv_exam_ci_seq  IGS_AS_UNITASS_ITEM_ALL.exam_ci_sequence_number%TYPE ,
  p_sua_person_id  IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_sua_course_cd  IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_sua_unit_cd  IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_sua_version_number  IGS_EN_SU_ATTEMPT_ALL.version_number%TYPE ,
  p_sua_cal_type  IGS_EN_SU_ATTEMPT_ALL.cal_type%TYPE ,
  p_sua_ci_seq  IGS_EN_SU_ATTEMPT_ALL.ci_sequence_number%TYPE ,
  p_sua_unit_attempt_status  IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE ,
  p_sua_location_cd  IGS_EN_SU_ATTEMPT_ALL.location_cd%TYPE ,
  p_ucl_unit_mode  IGS_AS_UNIT_CLASS_ALL.unit_mode%TYPE ,
  p_sua_unit_class  IGS_EN_SU_ATTEMPT_ALL.UNIT_CLASS%TYPE ,
  p_ueciv_ass_id  IGS_AS_UNITASS_ITEM_ALL.ass_id%TYPE )
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(assp_get_exam_view,WNDS,WNPS);
FUNCTION assp_get_gsg_cncd(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 )
RETURN VARCHAR2 ;
FUNCTION assp_get_gsg_rank(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 )
RETURN NUMBER ;
FUNCTION assp_get_gsg_result(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 )
RETURN VARCHAR2 ;
FUNCTION assp_get_mark_mndtry(
  p_grading_schema_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_grade IN VARCHAR2 )
RETURN VARCHAR2 ;
FUNCTION assp_get_ai_s_type(
  p_ass_id IN NUMBER )
RETURN VARCHAR2 ;
 PRAGMA RESTRICT_REFERENCES(assp_get_ai_s_type,WNDS,WNPS);
END IGS_AS_GEN_002 ;

 

/
