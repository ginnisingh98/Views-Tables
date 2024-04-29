--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_CTFT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_CTFT" AUTHID CURRENT_USER AS
/* $Header: IGSFI16S.pls 115.5 2002/11/29 00:18:16 nsidana ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --avenkatr    29-AUG-2001    Bug Id : 1956374. Removed procedure "crsp_val_cty_closed"
  -------------------------------------------------------------------------------------------

  -- Ensure IGS_PS_COURSE group fee triggers can be created.
  FUNCTION finp_val_ctft_ins(
  p_fee_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ctft_ins,wnds);
  -- Ensure only one open IGS_PS_TYPE_FEE_TRG record exists..
  FUNCTION finp_val_ctft_open(
  p_fee_cat IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_course_type IN VARCHAR2 ,
  p_create_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
pragma restrict_references(finp_val_ctft_open,wnds);
END IGS_FI_VAL_CTFT;

 

/
