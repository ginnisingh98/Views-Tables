--------------------------------------------------------
--  DDL for Package IGS_PR_VAL_SCPCA
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_VAL_SCPCA" AUTHID CURRENT_USER AS
/* $Header: IGSPR11S.pls 115.4 2002/11/29 02:46:34 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    29-AUG-2001     Bug No. 1956374 .The pragma added to function prgp_val_cfg_cat

  -------------------------------------------------------------------------------------------
  -- Validate the calendar type.
  FUNCTION prgp_val_cfg_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

PRAGMA RESTRICT_REFERENCES(prgp_val_cfg_cat,WNDS);
  --
  -- Validate the show cause period length of the s_crv_prg_cal record.
  FUNCTION prgp_val_scpca_cause(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_show_cause_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the appeal period length of the s_ou_prg_cal record.
  FUNCTION prgp_val_scpca_apl(
  p_course_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_appeal_length IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;

END IGS_PR_VAL_SCPCA;

 

/
