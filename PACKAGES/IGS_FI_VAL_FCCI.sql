--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FCCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FCCI" AUTHID CURRENT_USER AS
/* $Header: IGSFI25S.pls 120.0 2005/06/02 04:28:43 appldev noship $ */
  --
  -- Validate FCCI can be made ACTIVE.
  FUNCTION finp_val_fcci_active(
  p_fee_cat_ci_status IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcci_active,WNDS);
  --
  -- Update the status of related FCFL records.
  FUNCTION finp_upd_fcci_status(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate the IGS_FI_F_CAT_CA_INST status
  FUNCTION finp_val_fcci_status(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_new_fcci_status IN VARCHAR2 ,
  p_old_fcci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcci_status,WNDS);
  --
  -- Ensure cal instance dates are consistent.
  FUNCTION finp_val_fcci_dates(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_start_dt_alias IN VARCHAR2 ,
  p_start_dai_sequence_number IN NUMBER ,
  p_end_dt_alias IN VARCHAR2 ,
  p_end_dai_sequence_number IN NUMBER ,
  p_retro_dt_alias IN VARCHAR2 ,
  p_retro_dai_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcci_dates,WNDS);
  --
  -- Validate the fee structure status closed indicator
  FUNCTION finp_val_fss_closed(
  p_fee_structure_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fss_closed,WNDS);
  --
  -- Ensure calendar instance is FEE and ACTIVE.
  FUNCTION finp_val_ci_fee(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ci_fee,WNDS);

END IGS_FI_VAL_FCCI;

 

/
