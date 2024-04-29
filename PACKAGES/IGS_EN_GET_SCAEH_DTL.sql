--------------------------------------------------------
--  DDL for Package IGS_EN_GET_SCAEH_DTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_GET_SCAEH_DTL" AUTHID CURRENT_USER AS
/* $Header: IGSEN15S.pls 115.3 2002/02/12 16:49:25 pkm ship    $ */

  -- Get student course attempt effective history column value
  FUNCTION enrp_get_scaeh_col(
  p_column_name IN VARCHAR2 ,
  p_column_value IN VARCHAR2 ,
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd  IGS_PS_COURSE.course_cd%TYPE ,
  p_hist_start_dt IN DATE ,
  p_course_attempt_status  VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_SCAEH_COL,WNDS);
  --
  -- Routine to get the effective end date for a SCA history
  FUNCTION enrp_get_scaeh_eff_end(
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_end_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_SCAEH_EFF_END,WNDS);
  --
  -- Routine to get the effective start date for a SCA history
  FUNCTION enrp_get_scaeh_eff_st(
  p_person_id IN IGS_AS_SC_ATTEMPT_H_ALL.person_id%TYPE ,
  p_course_cd IN IGS_AS_SC_ATTEMPT_H_ALL.course_cd%TYPE ,
  p_hist_start_dt IN DATE ,
  p_course_attempt_status IN VARCHAR2 )
RETURN DATE;
PRAGMA RESTRICT_REFERENCES (ENRP_GET_SCAEH_EFF_ST,WNDS);


END IGS_EN_GET_SCAEH_DTL;

 

/
