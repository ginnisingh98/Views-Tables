--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_QLITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_QLITY" AUTHID CURRENT_USER AS
/* $Header: IGSCA14S.pls 120.0 2005/06/01 22:43:24 appldev noship $ */
  -- To validate research calendar instance (part of the quality check)
  PROCEDURE CALP_VAL_RESEARCH_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;
  --
  -- To quality check admission calendar instances
  PROCEDURE CALP_VAL_ADM_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;
  --
  -- To quality check calendar data structures
  FUNCTION CALP_VAL_QUAL_CHK(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_calendar_category IN VARCHAR2 )
RETURN DATE;

  --
  -- To quality check system control dates within calendar instances.
  PROCEDURE CALP_VAL_DATES_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;
  --
  -- To quality check enrolment calendar instances
  PROCEDURE CALP_VAL_ENROL_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;
  --
  -- To quality check load calendar instances
  PROCEDURE CALP_VAL_LOAD_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;
  --
  -- To quality check teaching calendar instances
  PROCEDURE CALP_VAL_TEACH_CI(
  p_acad_cal_type IN VARCHAR2 ,
  p_acad_sequence_number IN NUMBER ,
  p_s_log_type IN VARCHAR2 ,
  p_log_creation_dt IN DATE )
;

  PROCEDURE CHK_ONE_PER_CAL(p_acad_cal_type        IN VARCHAR2,
                            p_acad_sequence_number IN NUMBER,
                            p_cal_cat              IN VARCHAR2,
                            p_s_log_type           IN VARCHAR2,
                            p_log_creation_dt      IN DATE);

  g_cal_cat VARCHAR2(30);

END IGS_CA_VAL_QLITY;

 

/
