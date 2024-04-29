--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CAO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CAO" AUTHID CURRENT_USER AS
/* $Header: IGSPS16S.pls 115.4 2002/11/29 02:57:22 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts

  --
  -- Validate if IGS_PS_COURSE IGS_PS_AWD ownership records exist for a IGS_PS_COURSE IGS_PS_AWD.
  FUNCTION crsp_val_cao_exists(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate IGS_PS_COURSE IGS_PS_AWD ownership % for the IGS_PS_COURSE version IGS_PS_AWD.
  FUNCTION crsp_val_cao_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CAO;

 

/
