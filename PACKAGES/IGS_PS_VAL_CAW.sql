--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CAW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CAW" AUTHID CURRENT_USER AS
/* $Header: IGSPS17S.pls 115.4 2002/11/29 02:57:36 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of GRDP_VAL_AWARD_TYPE
  --                            removed .
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_aw_closed"
  --avenkatr    30-AUG-2001     Bug No 1956374. Removed procedure "crsp_val_cfos_caw"
  -------------------------------------------------------------------------------------------
  --
  -- Validate the IGS_PS_COURSE IGS_PS_AWD - IGS_PS_AWD code.
  FUNCTION crsp_val_caw_award(
  p_award_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
   -- Validate an insert on the IGS_PS_COURSE IGS_PS_AWD table.
  FUNCTION crsp_val_caw_insert(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CAW;

 

/
