--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CAL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CAL" AUTHID CURRENT_USER AS
 /* $Header: IGSPS14S.pls 115.6 2002/11/29 02:56:54 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    28-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_strt_end_dt
  --                            removed .
  -------------------------------------------------------------------------------------------

  -- Validate there are IGS_PS_COURSE annual load IGS_PS_UNIT links to copy.
  FUNCTION crsp_val_calul_copy(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE )
RETURN BOOLEAN;

  -- Validate the IGS_PS_COURSE annual load end date.
  FUNCTION crsp_val_cal_end_dt(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_yr_num IN NUMBER ,
  p_effective_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CAL;

 

/
