--------------------------------------------------------
--  DDL for Package IGS_EN_GET_SUAEH_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GET_SUAEH_DTL" AUTHID CURRENT_USER AS
/* $Header: IGSEN16S.pls 115.6 2003/05/13 08:28:42 kkillams ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --kkillams    28-04-2003      New parameter p_uoo_id is added to the  enrp_get_suaeh_col, enrp_get_suaeh_eff_st
  --                            and enrp_get_suaeh_eff_end functions w.r.t. bug number 2829262
  -------------------------------------------------------------------------------------------
  -- Get student IGS_PS_UNIT attempt effective history column value
  FUNCTION enrp_get_suaeh_col(
  p_column_name                 IN VARCHAR2 ,
  p_column_value                IN VARCHAR2 ,
  p_person_id                   IN HZ_PARTIES.PARTY_ID%TYPE,
  p_course_cd                   IN IGS_PS_COURSE.course_cd%TYPE ,
  p_unit_cd                     IN IGS_PS_UNIT.unit_cd%TYPE ,
  p_cal_type                    IN IGS_CA_TYPE.cal_type%TYPE ,
  p_ci_seq_num                  IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_hist_start_dt               IN DATE ,
  p_unit_attempt_status         IN VARCHAR2,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES (ENRP_GET_SUAEH_COL,WNDS);
  --
  -- Routine to get the effective end date for a SUA history
  FUNCTION enrp_get_suaeh_eff_end(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_num             IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_end_dt                 IN IGS_EN_SU_ATTEMPT_H_ALL.hist_end_dt%TYPE ,
  p_unit_attempt_status         IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_SUAEH_EFF_END,WNDS);

  -- Routine to get the effective start date for a SUA history
  FUNCTION enrp_get_suaeh_eff_st(
  p_person_id                   IN IGS_EN_SU_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd                   IN IGS_EN_SU_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_unit_cd                     IN IGS_EN_SU_ATTEMPT_H_ALL.unit_cd%TYPE ,
  p_cal_type                    IN IGS_EN_SU_ATTEMPT_H_ALL.cal_type%TYPE ,
  p_ci_sequence_num             IN IGS_EN_SU_ATTEMPT_H_ALL.ci_sequence_number%TYPE ,
  p_hist_start_dt               IN IGS_EN_SU_ATTEMPT_H_ALL.hist_start_dt%TYPE ,
  p_unit_attempt_status         IN IGS_EN_SU_ATTEMPT_ALL.unit_attempt_status%TYPE,
  p_uoo_id                      IN IGS_EN_SU_ATTEMPT.UOO_ID%TYPE)
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_SUAEH_EFF_ST,WNDS);

END IGS_EN_GET_SUAEH_DTL;

 

/
