--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_ASEAT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_ASEAT" AUTHID CURRENT_USER AS
/* $Header: IGSAD44S.pls 115.4 2002/11/28 21:33:19 nsidana ship $ */
  -- Validate the TAC Aus Secondary Edu Assessment Type closed ind
  FUNCTION ADMP_VAL_TASEATCLOSE(
  p_tac_aus_scndry_edu_ass_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_ASEAT;

 

/
