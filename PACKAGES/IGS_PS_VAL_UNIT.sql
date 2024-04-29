--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UNIT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UNIT" AUTHID CURRENT_USER AS
/* $Header: IGSPS63S.pls 115.3 2002/11/29 03:09:28 nsidana ship $ */

  --
  -- Validate if insert/updates/deletes can be made to IGS_PS_UNIT version details
  FUNCTION crsp_val_iud_uv_dtl(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PS_VAL_UNIT;

 

/
