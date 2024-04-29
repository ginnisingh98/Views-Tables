--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FT" AUTHID CURRENT_USER AS
/* $Header: IGSFI33S.pls 115.3 2002/11/29 00:22:02 nsidana ship $ */
  --
  -- Validate the optional payment indicator can be set to 'Y'.
  FUNCTION finp_val_ft_opt_pymt(
  p_fee_type IN VARCHAR2 ,
  p_optional_payment_ind IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ft_opt_pymt,WNDS);
  --
  -- Validate changes to s_fee_trigger_cat.
  FUNCTION finp_val_ft_trig(
  p_fee_type IN VARCHAR2 ,
  p_new_s_fee_trigger_cat IN VARCHAR2 ,
  p_old_s_fee_trigger_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ft_trig,WNDS);
  --
  -- Validate the s_fee_type and s_fee_trigger_cat are compatible.
  FUNCTION finp_val_ft_sft_trig(
  p_s_fee_type IN VARCHAR2 ,
  p_s_fee_trigger_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ft_sft_trig,WNDS);
  --
  -- Validate changes to s_fee_trigger_cat.
  FUNCTION finp_val_ft_sftc(
  p_fee_type IN VARCHAR2 ,
  p_new_s_fee_trigger_cat IN VARCHAR2 ,
  p_old_s_fee_trigger_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ft_sftc,WNDS);
END IGS_FI_VAL_FT;

 

/
