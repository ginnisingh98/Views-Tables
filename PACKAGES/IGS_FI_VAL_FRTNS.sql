--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FRTNS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FRTNS" AUTHID CURRENT_USER AS
/* $Header: IGSFI32S.pls 115.5 2002/11/29 00:21:45 nsidana ship $ */
  --
  /* Bug 1956374
     What Duplicate code finp_val_sched_mbrs
     Who msrinivi
  */
  -- Validate fee retention schedules can be created for the relation type.
  FUNCTION finp_val_frtns_creat(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_frtns_creat,WNDS);
  --
  -- Validate IGS_FI_FEE_RET_SCHD retention_amount
  FUNCTION finp_val_frtns_amt(
  p_retention_amount IN NUMBER ,
  p_retention_percentage IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_frtns_amt,WNDS);
  --
  -- Validate IGS_FI_FEE_RET_SCHD fee type
  FUNCTION finp_val_frtns_ft(
  p_fee_type IN VARCHAR2 ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_frtns_ft,WNDS);
  --
  -- Validate appropriate fields set for relation type.
  -- Bug 1956374 Removed duplicate code finp_val_sched_mbrs
  -- Validate insert of FRTNS does not clash IGS_FI_CUR with FCFL definitions
  FUNCTION finp_val_frtns_cur(
  p_fee_cal_type IN IGS_CA_TYPE.CAL_TYPE%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_s_relation_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_frtns_cur,WNDS);
END IGS_FI_VAL_FRTNS;

 

/
