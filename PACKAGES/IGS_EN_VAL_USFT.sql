--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_USFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_USFT" AUTHID CURRENT_USER AS
/* $Header: IGSEN72S.pls 115.4 2002/11/29 00:09:02 nsidana ship $ */
  --

  -- gt_rowid_table IGS_FI_VAL_CFT.t_cft_rowids;

  --

  --

  --gt_empty_table IGS_FI_VAL_CFT.t_cft_rowids;

  --

  --

  --gv_table_index BINARY_INTEGER;

  --

  --

  -- Ensure IGS_PS_UNIT set fee triggers can be created.

  FUNCTION finp_val_usft_ins(

  p_fee_type IN VARCHAR2 ,

  p_message_name OUT NOCOPY VARCHAR2)

RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES(finp_val_usft_ins , WNDS);

  --

  -- Validate IGS_PS_UNIT set fee trigger can belong to a fee trigger group.

  FUNCTION finp_val_usft_ftg(

  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,

  p_fee_trigger_group_num IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2)

RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( finp_val_usft_ftg, WNDS);

  --

  -- Ensure only one open IGS_EN_UNITSETFEETRG record exists.

  FUNCTION finp_val_usft_open(

  p_fee_cat IN IGS_EN_UNITSETFEETRG.fee_cat%TYPE ,

  p_fee_cal_type IN IGS_EN_UNITSETFEETRG.fee_cal_type%TYPE ,

  p_fee_ci_sequence_number IN NUMBER ,

  p_fee_type IN IGS_EN_UNITSETFEETRG.fee_type%TYPE ,

  p_unit_set_cd IN IGS_EN_UNITSETFEETRG.unit_set_cd%TYPE ,

  p_version_number IN IGS_EN_UNITSETFEETRG.version_number%TYPE ,

  p_create_dt IN IGS_EN_UNITSETFEETRG.create_dt%TYPE ,

  p_fee_trigger_group_number IN NUMBER ,

  p_message_name OUT NOCOPY VARCHAR2)

RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( finp_val_usft_open, WNDS);

  --

  -- To validate the calendar instance system cal status is not 'INACTIVE'

  FUNCTION FINP_VAL_US_STATUS(

  p_unit_set_cd IN IGS_EN_UNIT_SET_ALL.unit_set_cd%TYPE ,

  p_version_number IN IGS_EN_UNIT_SET_ALL.version_number%TYPE ,

  p_message_name OUT NOCOPY VARCHAR2)

RETURN boolean;
--PRAGMA RESTRICT_REFERENCES(FINP_VAL_US_STATUS , WNDS);

  --

  -- Routine to clear rowids saved in a PL/SQL TABLE from a prior commit.

 -- PROCEDURE genp_prc_clear_rowid;

  --

  -- Routine to save rowids in a PL/SQL TABLE for the current commit.

 -- PROCEDURE genp_set_rowid(  v_rowid  ROWID );

  --

  -- Routine to process usft rowids in PL/SQL TABLE for the current commit.



END IGS_EN_VAL_USFT;

 

/
