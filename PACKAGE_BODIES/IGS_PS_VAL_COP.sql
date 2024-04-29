--------------------------------------------------------
--  DDL for Package Body IGS_PS_VAL_COP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_VAL_COP" AS
/* $Header: IGSPS27B.pls 115.5 2002/11/29 03:00:05 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
  --
  -- Validate IGS_PS_COURSE Offering Option is active.
  FUNCTION CRSP_VAL_COO_INACTIV(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_location_cd IN VARCHAR2 ,
  p_attendance_mode IN VARCHAR2 ,
  p_attendance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN AS
  BEGIN
  	p_message_name := NULL;
  	-- check for INACTIVE IGS_PS_VER
  	IF (IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl(
  			p_course_cd,
  			p_version_number,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Check for closed calendar type
  	IF (IGS_CA_GEN_002.CALP_VAL_CI_CAT(p_cal_type, p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Check for closed IGS_AD_LOCATION code
  	-- As part of the bug# 1956374 changed to the below call from IGS_PS_VAL_COO.crsp_val_loc_cd
  	IF (IGS_PS_VAL_UOO.crsp_val_loc_cd(
  			p_location_cd,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Check for closed attendance mode
  	IF (IGS_PS_VAL_COo.crsp_val_coo_am(
  			p_attendance_mode,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	-- Check for closed attendance type
  	IF (IGS_PS_VAL_COo.crsp_val_coo_att(
  			p_attendance_type,
  			p_message_name) = FALSE) THEN
  		RETURN FALSE;
  	END IF;
  	RETURN TRUE;
  END crsp_val_coo_inactiv;
END IGS_PS_VAL_COp;

/
