--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_CGFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_CGFT" AUTHID CURRENT_USER AS
/* $Header: IGSFI14S.pls 115.4 2002/11/29 00:18:01 nsidana ship $ */
  -- Ensure IGS_PS_COURSE group fee triggers can be created.
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_crs_gp_clsd
  --
  -- Ensure IGS_PS_COURSE group fee triggers can be created.
  FUNCTION finp_val_cgft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cgft_ins,wnds);
  --
  -- Ensure only one open IGS_PS_GRP_FEE_TRG record exists..
  FUNCTION finp_val_cgft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_group_cd IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_cgft_open,wnds);

END IGS_FI_VAL_CGFT;

 

/
