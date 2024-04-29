--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_PRCT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_PRCT" AUTHID CURRENT_USER AS
/* $Header: IGSPR05S.pls 115.4 2002/11/29 02:44:53 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_cfg_cat
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate the IGS_PR_RU_CA_TYPE start and end sequence_numbers.
  FUNCTION prgp_val_prct_ci(
  p_prg_cal_type IN VARCHAR2 ,
  p_start_sequence_number IN NUMBER ,
  p_end_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_prct_ci, WNDS);

END IGS_PR_VAL_PRCT;

 

/
