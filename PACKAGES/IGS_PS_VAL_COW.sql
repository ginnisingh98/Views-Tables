--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_COW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_COW" AUTHID CURRENT_USER AS
 /* $Header: IGSPS30S.pls 115.4 2002/11/29 03:01:16 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_ou_sys_sts

  --
  -- Validate IGS_PS_COURSE ownership percentage for the IGS_PS_COURSE version.
  FUNCTION crsp_val_cow_perc(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_COw;

 

/
