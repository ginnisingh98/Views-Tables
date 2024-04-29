--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_US
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_US" AUTHID CURRENT_USER AS
/* $Header: IGSPS68S.pls 115.5 2002/11/29 03:09:58 nsidana ship $ */

  --sarakshi  14-nov-2002  bug#2649028,modified function crsp_val_ver_dt, added parameter p_lgcy_validator
  -- Bug #1956374
  -- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts
  -- As part of the bug# 1956374 removed the function crsp_val_us_exists

  -- Validate the IGS_PS_UNIT set status closed indicator.
  FUNCTION crsp_val_uss_closed(
  p_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the IGS_PS_UNIT set category closed indicator.
  FUNCTION crsp_val_usc_closed(
  p_unit_set_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate version dates for IGS_PS_COURSE and IGS_PS_UNIT versions.
  FUNCTION crsp_val_ver_dt(
  p_start_dt IN DATE ,
  p_end_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 ,
  p_lgcy_validator IN BOOLEAN DEFAULT FALSE)
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT set end date and IGS_PS_UNIT set status
  FUNCTION crsp_val_us_end_sts(
  p_end_dt IN DATE ,
  p_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT set end date and status when active students exist
  FUNCTION crsp_val_us_enr(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT set status changes
  FUNCTION crsp_val_us_status(
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_UNIT set expiry date and IGS_PS_UNIT set status
  FUNCTION crsp_val_us_exp_sts(
  p_unit_set_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_unit_set_status IN VARCHAR2 ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate IGS_PS_UNIT set status for ins/upd/del of IGS_PS_UNIT set details
  FUNCTION crsp_val_iud_us_dtl2(
  p_old_unit_set_status IN VARCHAR2 ,
  p_new_unit_set_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;



  --
  -- Validate IGS_PS_UNIT set category changes
  FUNCTION crsp_val_us_category(
  p_unit_set_status IN VARCHAR2 ,
  p_old_unit_set_cat IN VARCHAR2 ,
  p_new_unit_set_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_US;

 

/
