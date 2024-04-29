--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_CFAR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_CFAR" AUTHID CURRENT_USER AS
/* $Header: IGSFI12S.pls 120.0 2005/06/01 21:26:15 appldev noship $ */

  --
  -- Ensure  S_FEE_TYPE is 'OTHER' and S_FEE_TRIGGER_CAT is not 'INSTITUTN'
  FUNCTION finp_val_cfar_ins(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cfar_ins,wnds);
  --
  -- Ensure the start and end dates don't overlap with other records.
  FUNCTION finp_val_cfar_ovrlp(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cfar_ovrlp,wnds);
  --
  -- Validate that only one record has an open end date.
  FUNCTION finp_val_cfar_open(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cfar_open,wnds);
  --
  -- Validate that end date is null or >= start date.
  FUNCTION finp_val_cfar_end_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cfar_end_dt,wnds);
  --
  -- Validate the Attendance Mode closed indicator
  FUNCTION finp_val_am_closed(
  p_attendance_mode IN IGS_EN_ATD_MODE_ALL.attendance_mode%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_am_closed,wnds);
  --
  -- Validate the Attendance Type closed indicator
  FUNCTION finp_val_att_closed(
  p_attendance_type IN IGS_EN_ATD_TYPE_ALL.attendance_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_att_closed,wnds);
  --
  -- Validate the IGS_AD_LOCATION closed indicator
  FUNCTION finp_val_loc_closed(
  p_location_cd IN IGS_AD_LOCATION_ALL.location_cd%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_loc_closed,wnds);
  --
  -- Validate the IGS_FI_FEE_TYPE in the fee_type_account is not closed.
  FUNCTION finp_val_ft_closed(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ft_closed,wnds);
END IGS_FI_VAL_CFAR;

 

/
