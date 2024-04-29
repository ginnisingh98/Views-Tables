--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FCFL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FCFL" AUTHID CURRENT_USER AS
/* $Header: IGSFI26S.pls 115.6 2002/11/29 00:20:41 nsidana ship $ */
  --
  --who        when         what
  --vvutukur  29-Jul-2002  Bug#2425767. Removed function finp_val_fcfl_rank,as payment_hierarchy_rank column
  --                       is obsoleted.
/* Bug 1956374
   What : Duplicate code removal Removed finp_val_fss_closed
   Who  :msrinivi
*/
  -- Validate FCFL can be made ACTIVE.
  FUNCTION finp_val_fcfl_active(
  p_fee_liability_status IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcfl_active,WNDS);
  --
  -- Ensure fields are/are not allowable.
  FUNCTION finp_val_fcfl_rqrd(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_chg_method IN VARCHAR2 ,
  p_rule_sequence IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcfl_rqrd,WNDS);
  --
  -- Ensure status value is allowed.
  FUNCTION finp_val_fcfl_status(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_cat IN VARCHAR2 ,
  p_fee_type IN VARCHAR2 ,
  p_fee_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcfl_status,WNDS);
  --
  -- Validate insert of FCFL does not clash currency with FTCI definitions
  FUNCTION finp_val_fcfl_cur(
  p_fee_cal_type IN IGS_CA_TYPE.cal_type%TYPE ,
  p_fee_ci_sequence_number IN IGS_CA_INST_ALL.sequence_number%TYPE ,
  p_fee_type IN IGS_FI_FEE_TYPE_ALL.fee_type%TYPE ,
  p_fee_cat IN IGS_FI_FEE_CAT_ALL.fee_cat%TYPE ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_fcfl_cur,WNDS);
  --
  -- Duplicate code removal msrinivi
  -- Validate the PAYMENT_HIERARCHY_RANK
  -- Removed function finp_val_fcfl_rank, as part of bug fix#2425767, as this function validates
  -- an obsoleted column, payment_hierarchy_rank.
END IGS_FI_VAL_FCFL;

 

/
