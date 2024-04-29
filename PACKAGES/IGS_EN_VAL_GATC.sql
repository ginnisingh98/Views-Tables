--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GATC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GATC" AUTHID CURRENT_USER AS
/* $Header: IGSEN39S.pls 115.3 2002/11/28 23:58:51 nsidana ship $ */
  --
  -- Validate the update of a government aboriginal torres code record.
  FUNCTION enrp_val_gatc_upd(
  p_govt_aborig_torres_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_gatc_upd,WNDS);
END IGS_EN_VAL_GATC;

 

/
