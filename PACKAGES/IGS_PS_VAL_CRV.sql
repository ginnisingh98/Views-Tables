--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CRV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CRV" AUTHID CURRENT_USER AS
 /* $Header: IGSPS34S.pls 115.4 2002/11/29 03:02:17 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ver_dt
--Bug No 1956374, Removed procedure "crsp_val_caw_insert"

  -- Validate IGS_PS_COURSE version government special IGS_PS_COURSE type.
  FUNCTION crsp_val_crv_gsct(
  p_govt_special_course_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_COURSE version IGS_PS_COURSE type.
  FUNCTION crsp_val_crv_type(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_course_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --


  --
  -- Validate organisational IGS_PS_UNIT system status is ACTIVE
  FUNCTION crsp_val_ou_sys_sts(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the IGS_PS_COURSE version end date and status.
  FUNCTION crsp_val_crv_end_sts(
  p_end_dt IN DATE ,
  p_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate IGS_PS_COURSE version expiry date and status
  FUNCTION crsp_val_crv_exp_sts(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_expiry_dt IN DATE ,
  p_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;


  --
  -- Validate the IGS_PS_COURSE version status.
  FUNCTION crsp_val_crv_status(
  p_new_course_status IN VARCHAR2 ,
  p_old_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;

  --
  -- Perform quality validation checks on a IGS_PS_COURSE version and its details.
  FUNCTION CRSP_VAL_CRV_QUALITY(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_old_course_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate that a IGS_PS_COURSE version can end, looking at sca status
  FUNCTION crsp_val_crv_end(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_return_type OUT NOCOPY VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CRV;

 

/
