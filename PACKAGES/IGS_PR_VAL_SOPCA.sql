--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SOPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SOPCA" AUTHID CURRENT_USER AS
/* $Header: IGSPR13S.pls 115.4 2002/11/29 02:47:16 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_cfg_cat
  --                            removed .
  -------------------------------------------------------------------------------------------
   -- Validate the show cause period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_sopca_cause(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the appeal period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_sopca_apl(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SOPCA;

 

/