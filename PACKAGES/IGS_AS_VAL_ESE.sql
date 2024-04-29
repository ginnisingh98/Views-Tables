--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ESE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ESE" AUTHID CURRENT_USER AS
/* $Header: IGSAS19S.pls 115.3 2002/11/28 22:44:19 nsidana ship $ */

  --
  -- To validate the uniqueness of the exam session number
  FUNCTION ASSP_VAL_ESE_NUM(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --
  -- To validate for overlap in start/end times of exam sessions
  FUNCTION ASSP_VAL_ESE_OVRLP(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --
  -- Validate the IGS_AS_EXAM_SESSION calendar instance
  FUNCTION ASSP_VAL_ESE_CI(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --
  -- Compare time component of two dates and start time is before end time.
  FUNCTION GENP_VAL_STRT_END_TM(
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_ESE;

 

/
