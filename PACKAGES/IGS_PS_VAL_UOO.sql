--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UOO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UOO" AUTHID CURRENT_USER AS
/* $Header: IGSPS65S.pls 115.5 2002/11/29 03:09:43 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
-- Bug #1956374
-- As part of the bug# 1956374 added the pragma for the function crsp_val_loc_cd
-- Bug # 1956374 Procedure assp_val_gs_cur_fut is removed
-- Bug #1956374
-- As part of the bug# 1956374 removed the function  crsp_val_uo_cal_type
  --
 --
  -- Validate IGS_PS_COURSE IGS_AD_LOCATION code.
  FUNCTION crsp_val_loc_cd(
  p_location_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(crsp_val_loc_cd,wnds);

  --
  -- Validate the IGS_PS_UNIT class for IGS_PS_UNIT offering option.
  FUNCTION crsp_val_uoo_uc(
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate the IGS_PS_UNIT contact for IGS_PS_UNIT offering option is a staff member.
  FUNCTION crsp_val_uoo_contact(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT Offering Option is active.
  FUNCTION CRSP_VAL_UOO_INACTIV(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --


END IGS_PS_VAL_UOo;

 

/
