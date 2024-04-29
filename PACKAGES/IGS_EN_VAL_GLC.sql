--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GLC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GLC" AUTHID CURRENT_USER AS
/* $Header: IGSEN43S.pls 115.3 2002/11/28 23:59:45 nsidana ship $ */
  --
  -- Validate the update of a government language code record.
  FUNCTION enrp_val_glc_upd(
  p_govt_language_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_glc_upd,WNDS);
END IGS_EN_VAL_GLC;

 

/
