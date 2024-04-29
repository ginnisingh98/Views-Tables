--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_SEI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_SEI" AUTHID CURRENT_USER AS
/* $Header: IGSAS29S.pls 115.5 2003/05/27 18:45:02 anilk ship $ */

  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.
  --
  -- Validate IGS_AS_STD_EXM_INSTN teaching calendar instance
  FUNCTION ASSP_VAL_SEI_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

  --
  -- Validate for IGS_AS_STD_EXM_INSTN duplicate within exam period
  FUNCTION ASSP_VAL_SEI_DPLCT(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_ass_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  -- anilk, 22-Apr-2003, Bug# 2829262
  p_uoo_id IN NUMBER DEFAULT NULL )
RETURN boolean;

  --
  -- Routine to process rowids in a PL/SQL TABLE for the current commit.

  --
  -- Validate seat not allocated twice within an examination and IGS_GR_VENUE.
  FUNCTION ASSP_VAL_SEI_SEAT(
  p_ese_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_person_id OUT NOCOPY NUMBER ,
  p_seat_number OUT NOCOPY NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_SEI;

 

/
