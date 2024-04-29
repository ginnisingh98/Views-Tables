--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FLS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FLS" AUTHID CURRENT_USER AS
/* $Header: IGSFI30S.pls 115.6 2002/11/29 00:21:29 nsidana ship $ */
  /* bug 1956374
  --Duplicate code removal Removed func finp_val_fls_pps,finp_val_fss_closed1,finp_upd_pps_spnsr
  */
  -- Validate the Fee Cat Fee Liability is active
  FUNCTION finp_val_fls_fcfl(
  p_fee_cat IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_cat%TYPE ,
  p_fee_cal_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_cal_type%TYPE ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN IGS_FI_F_CAT_FEE_LBL_ALL.fee_type%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fls_fcfl,WNDS);
  -- Removed func finp_val_fls_scafs with pragma
  -- Removed func finp_val_fls_status with prgma
  -- Removed func finp_val_fls_status2 with pragma
  -- Removed func finp_val_fls_del with pragma
  -- Removed func finp_val_fss_closed1
  -- Removed finp_upd_pps_spnsr
  -- Validate that it is OK to delete record

END IGS_FI_VAL_FLS;

 

/
