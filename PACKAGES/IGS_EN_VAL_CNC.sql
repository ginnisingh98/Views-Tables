--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_CNC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_CNC" AUTHID CURRENT_USER AS
/* $Header: IGSEN30S.pls 115.3 2002/11/28 23:56:38 nsidana ship $ */
  --
  -- Validate the country government country code.
  FUNCTION enrp_val_cnc_govt(
  p_govt_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_cnc_govt,WNDS);
  --
  -- To validate the delete of country code
  FUNCTION enrp_val_cnc_del(
  p_country_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_cnc_del,WNDS);
END IGS_EN_VAL_CNC;

 

/
