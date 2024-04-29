--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ATC" AUTHID CURRENT_USER AS
/* $Header: IGSEN24S.pls 115.3 2002/11/28 23:55:04 nsidana ship $ */

  --
  -- Validate the aborig/torres government aborig/torres code.
  FUNCTION enrp_val_atc_govt(
  p_govt_aborig_torres_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_atc_govt,WNDS);
END IGS_EN_VAL_ATC;

 

/
