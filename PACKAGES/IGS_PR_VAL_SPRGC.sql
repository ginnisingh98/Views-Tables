--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPRGC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPRGC" AUTHID CURRENT_USER AS
/* $Header: IGSPR15S.pls 115.4 2002/11/29 02:47:49 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of PRGP_VAL_APPEAL_DA
  --                            removed .
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of PRGP_VAL_CAUSE_DA
  --                            removed .
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of PRGP_VAL_DA_CLOSED
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate the appeal indicator being set
  FUNCTION prgp_val_sprgc_apl(
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_sprgc_cause(
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SPRGC;

 

/
