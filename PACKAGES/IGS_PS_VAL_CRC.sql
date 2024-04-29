--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CRC" AUTHID CURRENT_USER AS
 /* $Header: IGSPS31S.pls 115.4 2002/11/29 03:01:31 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_exists"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_sys_sts"
  -------------------------------------------------------------------------------------------

  --
  -- Validate the IGS_PS_COURSE categorisation IGS_PS_COURSE category.
  FUNCTION crsp_val_crc_crs_cat(
  p_course_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_PS_VAL_CRC;

 

/
