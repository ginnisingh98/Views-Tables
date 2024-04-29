--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_IV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_IV" AUTHID CURRENT_USER AS
/* $Header: IGSEN46S.pls 120.0 2005/06/01 21:00:48 appldev noship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function genp_val_staff_prsn removed

  -------------------------------------------------------------------------------------------
    --msrinivi    24-AUG-2001     Bug No. 1956374 .The function genp_val_prsn_id removed
  --
  --
  -- bug id : 1956374
  -- sjadhav , aug-28-2001
  -- removed function enrp_val_cnc_closed
  --


-- Validate the international visa contact
  FUNCTION enrp_val_iv_contact(
  p_org_unit_cd IN VARCHAR2 ,
  p_contact_name IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_iv_contact,WNDS);
  --
  -- Validate the international visa IGS_PE_PERSON id
  FUNCTION enrp_val_iv_person(
  p_org_unit_cd IN VARCHAR2 ,
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_iv_person,WNDS);
  --
  -- Validate the visa type closed indicator
  FUNCTION enrp_val_vit_closed(
  p_visa_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
-- PRAGMA RESTRICT_REFERENCES (enrp_val_vit_closed,WNDS);
END IGS_EN_VAL_IV;

 

/
