--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_EIS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_EIS" AUTHID CURRENT_USER AS
/* $Header: IGSAS17S.pls 115.4 2002/11/28 22:43:50 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed
  -------------------------------------------------------------------------------------------
  --w.r.t BUG #1956374 , Procedures assp_val_els_venue ,assp_val_esu_ese_ve are removed
  --w.r.t BUG #1956374 , Procedures assp_val_est_closed , assp_val_esu_ese_el are removed
  -- Validate if a person is an active student.
  FUNCTION ASSP_VAL_ACTV_STDNT(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ASSP_VAL_ACTV_STDNT,WNDS);

  --



  --
  -- Validate if more than one person incharge at a session and venue.
  FUNCTION ASSP_VAL_ESE_INCHRG(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  p_exam_supervisor_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ASSP_VAL_ESE_INCHRG,WNDS);

  --

  --
  -- Validate if person allocated as incharge when not normally incharge.
  FUNCTION ASSP_VAL_EST_INCHRG(
  p_person_id IN NUMBER ,
  p_exam_supervisor_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ASSP_VAL_EST_INCHRG,WNDS);

  --


  --
  -- Validate if the supervisor limit exceeded for the session and venue.
  FUNCTION ASSP_VAL_ESU_ESE_LMT(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(ASSP_VAL_ESU_ESE_LMT,WNDS);

END IGS_AS_VAL_EIS;

 

/
