--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COUS" AUTHID CURRENT_USER AS
/* $Header: IGSPS28S.pls 115.4 2002/11/29 03:00:44 nsidana ship $ */

  ----------------------------------------------------------------------------
  --  Change History :
  --  Who             When            What
  -- avenkatr      30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_iud_crv_dtl"
  -- avenkatr      30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_iud_us_dtl"
  ----------------------------------------------------------------------------

  --
  -- Validate crs off IGS_PS_UNIT sets against IGS_PS_UNIT set IGS_PS_COURSE type restrictions
  FUNCTION crsp_val_cous_usctv(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate crs off IGS_PS_UNIT set 'only as subordinate' indicator
  FUNCTION crsp_val_cous_subind(
  p_course_cd IN VARCHAR2 ,
  p_crv_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_unit_set_cd IN VARCHAR2 ,
  p_us_version_number IN NUMBER ,
  p_old_only_as_sub_ind IN VARCHAR2 DEFAULT 'N',
  p_new_only_as_sub_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_COus;

 

/
