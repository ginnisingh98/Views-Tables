--------------------------------------------------------
--  DDL for Package IGS_CO_VAL_OC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CO_VAL_OC" AUTHID CURRENT_USER AS
/* $Header: IGSCO16S.pls 115.5 2002/11/28 23:06:28 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The function Declaration of GENP_VAL_SDTT_SESS
  --                            Removed
  -------------------------------------------------------------------------------------------
  -- Validate that the outgoing cor dates are in sequence
  FUNCTION corp_val_oc_dateseq(
  p_creation_dt IN DATE ,
  p_issued_dt IN DATE ,
  p_sent_dt IN DATE ,
  p_returned_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(corp_val_oc_dateseq,WNDS);
  --
  -- Validate a IGS_PE_PERSON id.
  FUNCTION genp_val_prsn_id(
  p_person_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
  RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(genp_val_prsn_id,WNDS);
  --

END IGS_CO_VAL_OC;

 

/
