--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_LPT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_LPT" AUTHID CURRENT_USER AS
/* $Header: IGSCO13S.pls 115.4 2002/11/28 23:05:56 nsidana ship $ */
  -- Validate if System Letter Parameter Type allows letter text to exist.
  FUNCTION corp_val_lpt_ltr_txt(
  p_s_letter_parameter_type IN VARCHAR2 ,
  p_letter_text IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_lpt_ltr_txt,WNDS);
  --
  -- Validate if System Letter Parameter Type is closed.
  FUNCTION corp_val_slpt_closed(
  p_s_letter_parameter_type IN CHAR ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_slpt_closed,WNDS);
END IGS_CO_VAL_LPT;

 

/
