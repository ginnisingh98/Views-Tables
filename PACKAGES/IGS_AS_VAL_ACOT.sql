--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ACOT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ACOT" AUTHID CURRENT_USER AS
/* $Header: IGSAS10S.pls 115.4 2002/11/28 22:41:51 nsidana ship $ */
  -- Validate COURSE type closed indicator.
  FUNCTION crsp_val_cty_closed(
  p_course_type IN IGS_PS_TYPE_ALL.course_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(crsp_val_cty_closed,WNDS,WNPS);
END IGS_AS_VAL_ACOT;

 

/
