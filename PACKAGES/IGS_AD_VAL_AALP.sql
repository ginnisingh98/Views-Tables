--------------------------------------------------------
--  DDL for Package IGS_AD_VAL_AALP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_VAL_AALP" AUTHID CURRENT_USER AS
/* $Header: IGSAD18S.pls 115.4 2002/11/28 21:26:16 nsidana ship $ */

  --
  -- Validate if letter parameter type is closed.
  FUNCTION corp_val_lpt_closed(
  p_letter_parameter_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate  letter_parameter_type has  s_letter_parameter_typ = PHRASE
  FUNCTION corp_val_lpt_phrase(
  p_letter_parameter_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate if letter phrase is closed.
  FUNCTION corp_val_ltp_closed(
  p_phrase_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_AD_VAL_AALP;

 

/
