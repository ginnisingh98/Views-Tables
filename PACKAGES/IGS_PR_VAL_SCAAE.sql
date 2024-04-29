--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SCAAE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SCAAE" AUTHID CURRENT_USER AS
/* $Header: IGSPR09S.pls 115.6 2002/11/29 02:46:00 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    25-AUG-2001     Bug No. 1956374 .The function declaration of GENP_VAL_SDTT_SESS
  --                            removed .
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_exists"
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  -------------------------------------------------------------------------------------------
  -- Validate the Student IGS_PS_COURSE Attempt Status for completion purposes.
  FUNCTION prgp_val_sca_cmplt(
  p_person_id IN NUMBER ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_sca_cmplt, WNDS);

  -- Validate the Student Crs Attempt Approved Alt Exit complete indicator.
  FUNCTION prgp_val_scaae_cmplt(
  p_rqrmnts_complete_ind IN VARCHAR2 DEFAULT 'N',
  p_rqrmnts_complete_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SCAAE;

 

/
