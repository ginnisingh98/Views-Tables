--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_CFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_CFT" AUTHID CURRENT_USER AS
/* $Header: IGSFI13S.pls 115.6 2002/11/29 00:17:40 nsidana ship $ */
  -- Bug #1956374
  -- As part of the bug# 1956374 removed the function crsp_val_loc_cd
  -- As part of the bug# 1956374 removed the function enrp_val_am_closed
  --
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_att_closed
  --
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------
  -- Ensure IGS_PS_COURSE fee triggers can be created.
  FUNCTION finp_val_cft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cft_ins,wnds);
  --
  -- Ensure only one open IGS_PS_FEE_TRG record exists.
  FUNCTION finp_val_cft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_fee_trigger_group_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cft_open,wnds);
  --
  -- Validate IGS_PS_COURSE code has an 'ACTIVE' or 'PLANNED' version.
  FUNCTION finp_val_cft_crs(
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cft_crs,wnds);
  --
  -- Validate calendar type has a system category of 'ACADEMIC'.
  FUNCTION finp_val_ct_academic(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ct_academic,wnds);

  -- Validate the Calendar Type closed ind
  FUNCTION calp_val_cat_closed(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(calp_val_cat_closed,wnds);
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_att_closed
  --
  -- Validate IGS_PS_COURSE fee trigger can belong to a fee trigger group.
  FUNCTION finp_val_cft_ftg(
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_num IN NUMBER ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_course_cd IN IGS_PS_COURSE.course_cd%TYPE ,
  p_fee_trigger_group_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cft_ftg,wnds);
END IGS_FI_VAL_CFT;

 

/
