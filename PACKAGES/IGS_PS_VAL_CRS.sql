--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_CRS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_CRS" AUTHID CURRENT_USER AS
 /* $Header: IGSPS33S.pls 115.3 2002/11/29 03:01:59 nsidana ship $ */

  --
  -- Validate if inserts/updates/deletes can be made to IGS_PS_COURSE version dtls
  FUNCTION crsp_val_iud_crv_dtl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_CRS;

 

/
