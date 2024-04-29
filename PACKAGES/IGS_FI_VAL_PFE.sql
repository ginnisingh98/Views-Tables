--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_PFE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_PFE" AUTHID CURRENT_USER AS
/* $Header: IGSFI37S.pls 115.7 2002/11/29 00:22:55 nsidana ship $ */
  --
  -- nalkumar       30-Nov-2001       Removed the function finp_val_pfe_status and finp_val_pfes_closed from this package.
  --		                      This is as per the SFCR015-HOLDS DLD. Bug:2126091
  --
  --msrinivi bug 1956374 . Removed finp_val_encmb_eff
  --bayadav         20-DEC-2001       Removed the function finp_val_sca_status from this package.
  --		                      This is as per the SFCR015-HOLDS DLD. Bug:2126091
  --
  -- Validate the IGS_PE_PERSON does not have an active encumbrance of this type.
  FUNCTION finp_val_prsn_encmb(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_fee_encumbrance_dt IN DATE ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_prsn_encmb,WNDS);
  --
  -- Removed the function finp_val_sca_status from this package.
  --This is as per the SFCR015-HOLDS DLD. Bug:2126091

END IGS_FI_VAL_PFE;

 

/
