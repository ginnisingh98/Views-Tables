--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_001" AUTHID CURRENT_USER AS
/* $Header: IGSPR01S.pls 115.3 2002/02/12 17:20:06 pkm ship    $ */
FUNCTION PRGP_GET_CAL_STREAM(
  P_COURSE_CD IN VARCHAR2 ,
  P_VERSION_NUMBER IN NUMBER ,
  P_PRG_CAL_TYPE IN VARCHAR2 ,
  p_comparison_prg_cal_type IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(PRGP_GET_CAL_STREAM, WNDS);

FUNCTION PRGP_GET_CRV_CMT(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(PRGP_GET_CRV_CMT, WNDS);

FUNCTION prgp_get_drtn_efctv(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(prgp_get_drtn_efctv, WNDS);

FUNCTION prgp_get_msr_efctv(
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(prgp_get_msr_efctv, WNDS);

FUNCTION prgp_get_prg_efctv(
  p_prg_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_prg_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES(prgp_get_prg_efctv, WNDS);

FUNCTION prgp_get_sca_elps_tm(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_commencement_dt IN DATE ,
  p_effective_dt IN DATE DEFAULT SYSDATE)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(prgp_get_sca_elps_tm, WNDS);

FUNCTION PRGP_GET_SCA_GPA(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_course_stage_type IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_best_worst IN VARCHAR2 ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_use_first_attempt_ind IN VARCHAR2 ,
  p_use_entered_grade_ind IN VARCHAR2 )
RETURN NUMBER;


END IGS_PR_GEN_001;

 

/
