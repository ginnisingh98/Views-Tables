--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SPCA" AUTHID CURRENT_USER AS
/* $Header: IGSPR14S.pls 115.4 2002/11/29 02:47:33 nsidana ship $ */
 -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_cfg_cat
  --                            removed .
  -------------------------------------------------------------------------------------------
  -- Validate the appeal length field.
  FUNCTION prgp_val_spca_appeal(
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the show cause length field.
  FUNCTION prgp_val_spca_cause(
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SPCA;

 

/
