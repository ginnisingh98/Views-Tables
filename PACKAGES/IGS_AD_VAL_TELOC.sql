--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_TELOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_TELOC" AUTHID CURRENT_USER AS
/* $Header: IGSAD73S.pls 115.3 2002/11/28 21:40:40 nsidana ship $ */

  --
  -- Validate the Tertiary Admissions Centre level of completion closed ind
  FUNCTION admp_val_tloc_closed(
  p_tac_level_of_comp IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_AD_VAL_TELOC;

 

/
