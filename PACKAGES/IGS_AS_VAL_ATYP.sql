--------------------------------------------------------
--  DDL for Package IGS_AS_VAL_ATYP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_VAL_ATYP" AUTHID CURRENT_USER AS
/* $Header: IGSAS15S.pls 115.4 2002/11/28 22:43:20 nsidana ship $ */
  --
  -- Validate system assessment type closed indicator
  FUNCTION assp_val_sat_closed(
  p_s_assessment_type IN IGS_AS_SASSESS_TYPE.s_assessment_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate assessment items exist for assessment type
  FUNCTION assp_val_ai_exist2(
  p_assessment_type IN IGS_AS_ASSESSMNT_ITM_ALL.assessment_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AS_VAL_ATYP;

 

/
