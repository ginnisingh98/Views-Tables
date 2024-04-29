--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PRC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PRC" AUTHID CURRENT_USER AS
/* $Header: IGSEN56S.pls 115.3 2002/11/29 00:03:55 nsidana ship $ */
  --
  -- Validate the permanent resident government permanent resident code.
  FUNCTION enrp_val_prc_govt(
  p_govt_perm_resident_cd IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_prc_govt, WNDS);
END IGS_EN_VAL_PRC;

 

/
