--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ESVS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ESVS" AUTHID CURRENT_USER AS
/* $Header: IGSAS21S.pls 115.4 2002/11/28 22:44:48 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn
  --                            removed
  -------------------------------------------------------------------------------------------
--w.r.t BUG #1956374 , Procedure assp_val_est_inchrg is removed
  --
  -- As part of the bug# 1956374 procedure assp_val_actv ,assp_val_ese_inchrg are removed
  --w.r.t BUG #1956374 , Procedure assp_val_est_closed , assp_val_esu_ese_lmt are  removed
  -- Validate exam instance exists for the session and IGS_GR_VENUE.
  FUNCTION ASSP_VAL_EI_VENUE(
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_GR_VENUE is within the supervisor's exam IGS_AD_LOCATIONs
  FUNCTION ASSP_VAL_ELS_VENUE(
  p_person_id IN NUMBER ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --



  --



  --
  -- Validate if supervisor allocated different exam IGS_AD_LOCATION for same day.
  FUNCTION ASSP_VAL_ESU_ESE_EL(
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

  --

  --
  -- Supervisor cannot be allocated concurrent sessions at different IGS_GR_VENUEs
  FUNCTION ASSP_VAL_ESU_ESE_VE(
  p_person_id IN NUMBER ,
  p_exam_cal_type IN VARCHAR2 ,
  p_exam_ci_sequence_number IN NUMBER ,
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_start_time IN DATE ,
  p_end_time IN DATE ,
  p_override_start_time IN DATE ,
  p_override_end_time IN DATE ,
  p_venue_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --

END IGS_AS_VAL_ESVS;

 

/
