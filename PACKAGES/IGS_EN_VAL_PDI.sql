--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PDI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PDI" AUTHID CURRENT_USER AS
/* $Header: IGSEN52S.pls 115.3 2002/11/29 00:02:55 nsidana ship $ */
  --
  -- To validate disability type of IGS_PE_PERSON disability record
  FUNCTION ENRP_VAL_PDI_DIT(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES( ENRP_VAL_PDI_DIT , WNDS);
  --
  -- To validate the IGS_PE_PERSON disability contact indicator
  FUNCTION ENRP_VAL_PD_CONTACT(
  p_disability_type IN VARCHAR2 ,
  p_contact_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(  ENRP_VAL_PD_CONTACT, WNDS);
  --
  -- Validate the disability type closed indicator
  FUNCTION enrp_val_dit_closed(
  p_disability_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(  enrp_val_dit_closed, WNDS);
END IGS_EN_VAL_PDI;

 

/
