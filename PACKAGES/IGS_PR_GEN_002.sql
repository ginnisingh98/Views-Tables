--------------------------------------------------------
--  DDL for Package IGS_PR_GEN_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_GEN_002" AUTHID CURRENT_USER AS
/* $Header: IGSPR02S.pls 120.1 2006/04/28 05:47:59 sepalani noship $ */
/************************************************************************
  Know limitations, enhancements or remarks
  Change History
  Who            When            What
  sepalani     11-Apr-2006     Bug # 5076203
***************************************************************/
FUNCTION prgp_get_sca_wam(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_course_version IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_course_stage_type IN VARCHAR2 ,
  p_prg_cal_type IN VARCHAR2 ,
  p_prg_sequence_number IN NUMBER ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_abort_when_missing_ind IN VARCHAR2 )
RETURN NUMBER;

FUNCTION prgp_get_stg_comp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_course_stage_type IN VARCHAR2 )
RETURN VARCHAR2;
--PRAGMA RESTRICT_REFERENCES(PRGP_GET_STG_COMP, WNDS);

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_gpa_val
--
FUNCTION prgp_get_sua_gpa_val(
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_best_worst IN VARCHAR2 ,
  p_recommended_ind IN VARCHAR2,
  p_uoo_id IN NUMBER DEFAULT NULL)
RETURN IGS_AS_GRD_SCH_GRADE.gpa_val%TYPE;
PRAGMA RESTRICT_REFERENCES(prgp_get_sua_gpa_val, WNDS);

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_num
--
FUNCTION prgp_get_sua_prg_num(
  p_prg_cal_type IN VARCHAR ,
  p_prg_sequence_number IN NUMBER ,
  p_number_of_periods IN NUMBER ,
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER,
  p_uoo_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(prgp_get_sua_prg_num, WNDS);

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_prg_prd
--
FUNCTION prgp_get_sua_prg_prd(
  p_prg_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_prg_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_person_id IN IGS_EN_SU_ATTEMPT_ALL.person_id%TYPE ,
  p_course_cd IN IGS_EN_SU_ATTEMPT_ALL.course_cd%TYPE ,
  p_unit_cd IN IGS_EN_SU_ATTEMPT_ALL.unit_cd%TYPE ,
  p_cal_type IN IGS_CA_INST_ALL.cal_type%TYPE ,
  p_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_details_ind IN VARCHAR2 ,
  p_unit_attempt_status IN VARCHAR2 ,
  p_discontinued_dt IN DATE,
  p_uoo_id IN NUMBER DEFAULT NULL)
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(prgp_get_sua_prg_prd, WNDS);

--
-- kdande; 22-Apr-2003; Bug# 2829262
-- Added p_uoo_id parameter to the FUNCTION prgp_get_sua_wam
--
FUNCTION prgp_get_sua_wam(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_use_recommended_ind IN VARCHAR2 ,
  p_abort_when_missing_ind IN VARCHAR2,
  p_wam_type IN VARCHAR2 DEFAULT 'COURSE',
  p_uoo_id IN NUMBER DEFAULT NULL)
RETURN NUMBER;
PRAGMA RESTRICT_REFERENCES(PRGP_GET_SUA_WAM, WNDS);

END IGS_PR_GEN_002;

 

/
