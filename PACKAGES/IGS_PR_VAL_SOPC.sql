--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SOPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SOPC" AUTHID CURRENT_USER AS
/* $Header: IGSPR12S.pls 115.4 2002/11/29 02:46:54 nsidana ship $ */
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
  FUNCTION prgp_val_sopc_apl(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_sopc_cause(
  p_org_unit_cd IN VARCHAR2 ,
  p_ou_start_dt IN DATE ,
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the {s_ou_conf,s_crv_conf}.appeal_ind
  FUNCTION prgp_val_appeal_ind(
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the {s_ou_conf,s_crv_conf}.show_cause_ind.
  FUNCTION prgp_val_cause_ind(
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate that the IGS_OR_UNIT is active.
  FUNCTION prgp_val_ou_active(
  p_org_unit_cd IN VARCHAR2 ,
  p_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(prgp_val_ou_active, WNDS);

END IGS_PR_VAL_SOPC;

 

/
