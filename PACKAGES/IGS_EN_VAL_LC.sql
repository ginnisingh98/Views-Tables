--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_LC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_LC" AUTHID CURRENT_USER AS
/* $Header: IGSEN47S.pls 115.3 2002/11/29 00:01:17 nsidana ship $ */
  --
  -- To validate the delete of a language code record
  FUNCTION enrp_val_lc_del(
  p_language_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_lc_del,WNDS);
  --
  -- Validate the language government language code.
  FUNCTION enrp_val_lang_govt(
  p_govt_language_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_lang_govt,WNDS);
END IGS_EN_VAL_LC;

 

/
