--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PEN
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PEN" AUTHID CURRENT_USER AS
/* $Header: IGSEN54S.pls 115.4 2002/11/29 00:03:26 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
-- msrinivi Bug 1956374  removed genp_val_prsn_id
  --
  -- bug id : 1956374
  -- sjadhav,28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_et_closed
  --
  -- Validate the person does not have an active enrolment.
  FUNCTION finp_val_encmb_eff(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_fee_encumbrance_dt IN DATE ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  finp_val_encmb_eff, WNDS);
  --

  --
  -- Validate that person doesn't already have an open encumbrance.
  FUNCTION enrp_val_pen_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_pen_open, WNDS);
  --
  -- Validate the application of an encumbrance type to a person.
  FUNCTION enrp_val_prsn_encmb(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_expiry_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES(  enrp_val_prsn_encmb, WNDS);
END IGS_EN_VAL_PEN;

 

/
