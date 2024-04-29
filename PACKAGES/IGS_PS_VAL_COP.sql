--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COP" AUTHID CURRENT_USER AS
/* $Header: IGSPS27S.pls 115.4 2002/11/29 03:00:15 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_Crs_ci"
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_ent_ass_scr"
  -------------------------------------------------------------------------------------------
-- Bug # 1956374 Procedure assp_val_gs_cur_fut procedure is removed
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
RETURN BOOLEAN;
END IGS_PS_VAL_COp;

 

/
