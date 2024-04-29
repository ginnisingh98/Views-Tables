--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_POT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_POT" AUTHID CURRENT_USER AS
/* $Header: IGSPR03S.pls 115.4 2002/11/29 02:44:24 nsidana ship $ */
  -- Validate the dflt_restricted_enrolment_cp field.
--
-- bug id : 1956374
-- sjadhav , 28-aug-2001
-- removed function enrp_val_et_closed
--
----------------------------------------------------------------------------
--  Change History :
--  Who             When            What
-- avenkatr      30-AUG-2001	   Removed procedure "crsp_val_att_closed"
----------------------------------------------------------------------------
  FUNCTION prgp_val_pot_att(
  p_dflt_restricted_att_type IN VARCHAR2 ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pot_att, WNDS);

  -- Validate the dflt_restricted_enrolment_cp field.
  FUNCTION prgp_val_pot_cp(
  p_dflt_restricted_enrolment_cp IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pot_cp, WNDS);

  -- Validate the Encumbrance Type.
  FUNCTION prgp_val_pot_et(
  p_s_progression_outcome_type IN VARCHAR2 ,
  p_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pot_et, WNDS);

  -- Validate the Change of Encumbrance Type.
  FUNCTION prgp_val_pot_et_upd(
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_encumbrance_type IN VARCHAR2 ,
  p_new_encumbrance_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pot_et_upd, WNDS);

  -- Validate the Change of System Progression Outcome Type.
  FUNCTION prgp_val_pot_spot_u(
  p_progression_outcome_type IN VARCHAR2 ,
  p_old_s_prg_outcome_type IN VARCHAR2 ,
  p_new_s_prg_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_pot_spot_u, WNDS);

  --
  -- Validate that the s_progression_outcome_type is not closed
  FUNCTION prgp_val_spot_closed(
  p_s_prog_outcome_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_spot_closed, WNDS);
END IGS_PR_VAL_POT;

 

/
