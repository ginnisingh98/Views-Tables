--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_UFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_UFT" AUTHID CURRENT_USER AS
/* $Header: IGSFI42S.pls 115.5 2002/11/29 00:23:12 nsidana ship $ */
-- Bug #1956374
-- As part of the bug# 1956374 removed the function crsp_val_loc_cd
-- As part of the bug# 1956374 removed the function crsp_val_posp_cat
-- As part of the bug# 1956374 removed the function crsp_val_uv_sys_sts
-- As part of the bug# 1956374 removed the function crsp_val_ucl_closed
-- As part of the bug# 1956374 removed the function crsp_val_uv_active

  -- Ensure IGS_PS_UNIT fee triggers can be created.
  FUNCTION finp_val_uft_ins(
  p_fee_type IN VARCHAR2 ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_uft_ins,WNDS);

  --
  -- Validate IGS_PS_UNIT fee trigger can belong to a fee trigger group.
  FUNCTION finp_val_uft_ftg(
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_trigger_group_num IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_uft_ftg,WNDS);

  --
  -- Ensure only one open IGS_FI_UNIT_FEE_TRG record exists.
  FUNCTION finp_val_uft_open(
  p_fee_cat IN IGS_FI_UNIT_FEE_TRG.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_FI_UNIT_FEE_TRG.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_UNIT_FEE_TRG.fee_type%TYPE ,
  p_unit_cd IN IGS_FI_UNIT_FEE_TRG.unit_cd%TYPE ,
  p_sequence_number IN NUMBER ,
  p_version_number IN IGS_FI_UNIT_FEE_TRG.version_number%TYPE ,
  p_cal_type IN IGS_FI_UNIT_FEE_TRG.CAL_TYPE%TYPE ,
  p_ci_sequence_number IN NUMBER ,
  p_unit_class IN IGS_FI_UNIT_FEE_TRG.unit_class%TYPE ,
  p_location_cd IN IGS_FI_UNIT_FEE_TRG.location_cd%TYPE ,
  p_create_dt IN IGS_FI_UNIT_FEE_TRG.create_dt%TYPE ,
  p_fee_trigger_group_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_uft_open,WNDS);

  --
  -- Warn if no IGS_PS_UNIT offering option exists for the specified options.
  FUNCTION finp_val_uft_uoo(
  p_unit_cd IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_location_cd IN VARCHAR2 ,
  p_unit_class IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_uft_uoo,WNDS);




END IGS_FI_VAL_UFT;

 

/
