--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SCPC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SCPC" AUTHID CURRENT_USER AS
/* $Header: IGSPR10S.pls 115.6 2002/11/29 02:46:15 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    27-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_appeal_ind
  --                            removed .
  --smadathi    26-AUG-2001     Bug No. 1956374 .The function declaration of prgp_val_cause_ind
  --                            removed .
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_crv_active"
  -------------------------------------------------------------------------------------------
  -- Validate the appeal indicator being set
  FUNCTION prgp_val_scpc_apl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_appeal_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the show cause indicator being set
  FUNCTION prgp_val_scpc_cause(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_show_cause_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  -- Validate the appeal period length of the s_prg_cal record.
  FUNCTION prgp_val_appeal_da(
  p_appeal_ind IN VARCHAR2 ,
  p_appeal_cutoff_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate the show cause period length of the s_prg_cal record.
  FUNCTION prgp_val_cause_da(
  p_show_cause_ind IN VARCHAR2 ,
  p_show_cause_cutoff_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

  --
  -- Validate that IGS_CA_DA.IGS_CA_DA is not closed.
  FUNCTION prgp_val_da_closed(
  p_dt_alias IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SCPC;

 

/
