--------------------------------------------------------
--  DDL for Package IGS_PS_VAL_UAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_VAL_UAI" AUTHID CURRENT_USER AS
/* $Header: IGSPS76S.pls 115.10 2002/11/29 03:11:35 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  -- ddey      09-JAN-2001     The function assp_val_uai_links is removed.
  --  The function was called from the library IGSPS092.pld and was called from the TBH
  --  IGSPI0KB.pls of the . This TBH is used for the form IGSPS092. All the calls for
  --  this functions are removed form the library and the TBH. Apart form this, the function
  --  assp_val_uai_links is not called from any other place .
  --  As per the requirement mentioned in the DLD Calcualtion of results Part 1 (Bug # 2162831)
  --  this  function is no more required. Hence it is removed.
  --smadathi    29-AUG-2001     Bug No. 1956374 .The function declaration of genp_val_sdtt_sess removed

  -------------------------------------------------------------------------------------------
-- w.r.t Bug  # 1956374 procedure assp_val_ai_exmnbl ,assp_val_cutoff_dt ,assp_val_uai_cal are removed
  -- Bug No. 1956374 Procedure assp_val_optnl_links  ,assp_val_uai_uniqref
  --assp_val_sua_ai_acot,asp_val_sua_uai , assp_val_uai_uapi ,assp_val_uai_uniqref are  removed
  -- As part of the bug# 1956374 removed the function crsp_val_loc_cd
  -- As part of the bug# 1956374 removed the function  crsp_val_ucl_closed
  -- As part of the bug# 1956374 removed the function  crsp_val_um_closed
  -- As part of the bug# 1956374 removed the function  crsp_val_uo_cal_type


  --
  -- Validate Calendar Instance for IGS_PS_COURSE Information.
  FUNCTION CRSP_VAL_CRS_CI(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (CRSP_VAL_CRS_CI,WNDS);


  -- Retrofitted


  --
  -- Retrofitted
  FUNCTION assp_val_uai_opt_ref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_assessment_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (assp_val_uai_opt_ref,WNDS);
 --
  -- Retrofitted

  FUNCTION assp_val_uai_sameref(
  p_unit_cd IN VARCHAR2 ,
  p_version_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_sequence_number IN NUMBER ,
  p_reference IN VARCHAR2 ,
  p_ass_id IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES (assp_val_uai_sameref,WNDS);
  --

END IGS_PS_VAL_UAI;

 

/
