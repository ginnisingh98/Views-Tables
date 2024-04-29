--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_ERR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_ERR" AUTHID CURRENT_USER AS
/* $Header: IGSFI21S.pls 115.3 2002/11/29 00:19:09 nsidana ship $ */
  --
  -- Ensure elements range rate can be created.
  FUNCTION finp_val_err_create(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_err_create,wnds);
  --
  -- Ensure only one elements range rate is active.
  FUNCTION finp_val_err_active(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_rate_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_err_active,wnds);
  --
  -- Ensure elements range rate can be created.
  FUNCTION finp_val_err_ins(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_rate_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_err_ins,wnds);
END IGS_FI_VAL_ERR;

 

/
