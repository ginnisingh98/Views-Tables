--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_CIC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_CIC" AUTHID CURRENT_USER AS
/* $Header: IGSEN29S.pls 115.3 2002/11/28 23:56:24 nsidana ship $ */


  --
  -- Validate the citizenship government citizenship code.
  FUNCTION enrp_val_cic_govt(
  p_govt_citizenship_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_cic_govt,WNDS);
END IGS_EN_VAL_CIC;

 

/
