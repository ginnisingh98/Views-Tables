--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FTG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FTG" AUTHID CURRENT_USER AS
/* $Header: IGSFI35S.pls 115.3 2002/11/29 00:22:40 nsidana ship $ */
  --
  -- Ensure fee trigger group can be created.
  FUNCTION finp_val_ftg_ins(
  p_fee_type IN VARCHAR2 ,
 p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftg_ins,WNDS);
  --
  -- Validate logical delete of the fee trigger group
  FUNCTION finp_val_ftg_lgl_del(
  p_fee_cat IN IGS_FI_FEE_TRG_GRP.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_FI_FEE_TRG_GRP.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_FEE_TRG_GRP.fee_type%TYPE ,
  p_fee_trigger_group_num IN NUMBER ,
  p_message_name OUT NOCOPY varchar2)
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftg_lgl_del,WNDS);
END IGS_FI_VAL_FTG;

 

/
