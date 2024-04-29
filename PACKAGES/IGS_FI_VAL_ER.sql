--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_ER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_ER" AUTHID CURRENT_USER AS
/* $Header: IGSFI20S.pls 115.4 2002/11/29 00:18:52 nsidana ship $ */
  --
  -- Validate elements ranges can be created for the relation type.
  FUNCTION finp_val_er_defn(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_defn,wnds);
  --
  -- Ensure elements range values do not overlap.
  FUNCTION finp_val_er_ovrlp(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_range_number IN NUMBER ,
  p_lower_range IN NUMBER ,
  p_upper_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_ovrlp,wnds);
  --
  -- Ensure elements range rate can be created.
  --Duplicate code removal, msrinivi Removed proc finp_val_err_ins
  -- Ensure elements range can be created.
  FUNCTION finp_val_er_create(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_create,wnds);
  --
  -- Ensure elements range values are valid.
  FUNCTION finp_val_er_ranges(
  p_lower_range IN NUMBER ,
  p_upper_range IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_ranges,wnds);
  --
  -- Ensure elements range relations are valid.
  FUNCTION finp_val_er_rltn(
  p_s_relation_type IN VARCHAR2 ,
  p_fee_cat IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_rltn,wnds);
  --
  -- Ensure elements range can be created.
  FUNCTION finp_val_er_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_er_ins,wnds);
END IGS_FI_VAL_ER;

 

/
