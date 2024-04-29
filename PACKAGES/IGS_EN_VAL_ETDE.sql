--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_ETDE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_ETDE" AUTHID CURRENT_USER AS
/* $Header: IGSEN38S.pls 115.6 2002/11/28 23:58:37 nsidana ship $ */
  --
  -- Validate the encumbrance type closed indicator.
  FUNCTION enrp_val_et_closed(
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_et_closed,WNDS);
  --
  -- Validate the system encumbrance effect type closed indicator.
  FUNCTION enrp_val_seet_closed(
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES (enrp_val_seet_closed,WNDS);
  -- Validate the s_progression_outcome_type.
  FUNCTION enrp_val_et_pot(
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name1 OUT NOCOPY VARCHAR2 ,
  p_message_name2 OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
END IGS_EN_VAL_ETDE;

 

/
