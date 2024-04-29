--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_GPRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_GPRC" AUTHID CURRENT_USER AS
/* $Header: IGSEN44S.pls 115.3 2002/11/29 00:00:04 nsidana ship $ */
  --
  -- Validate the update of a government permanent resident code record.
  FUNCTION enrp_val_gprc_upd(
  p_govt_perm_resident_cd IN NUMBER ,
  p_closed_ind IN VARCHAR2 DEFAULT 'N',
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_gprc_upd,WNDS);
END IGS_EN_VAL_GPRC;

 

/
