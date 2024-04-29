--------------------------------------------------------
--  DDL for Package IGS_FI_VAL_FTCI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_VAL_FTCI" AUTHID CURRENT_USER AS
/* $Header: IGSFI34S.pls 120.0 2005/06/02 03:53:22 appldev noship $ */
  --
 /* Bug 1956374
   What :Duplicate code removal removed finp_val_ft_closed
   Who  :msrinivi
 */

  /*  Who          When                     What
     vvutukur     29-Jul-2002              Bug#2425767.Removed function finp_val_ftci_rank,as this function is
                                           removed from package body also.
     vchappid     25-Apr-2002              Bug# 2329407, Removed the parameters account_cd, fin_cal_type
                                           and fin_ci_sequence_number from the function call finp_val_ftci_rqrd
     vivuyyur     10-sep-2001		   Bug No :1966961
                                           PROCEDURE finp_val_ftci_ac is changed  */

  -- Validate the IGS_FI_ACC has the correct calendar relations.
  FUNCTION finp_val_ftci_ac(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftci_ac,WNDS);
  --
  -- Ensure Fee calendar has relationship to Teaching Calendar
  FUNCTION finp_chk_tchng_prds(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_chk_tchng_prds,WNDS);
  --
  -- Update the status of related FCFL records.
  FUNCTION finp_upd_fcfl_status(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  --Duplicate code removal , msrinivi removed proc finp_val_ci_fee

  -- Validate the fee structure status closed indicator
  -- Bug 1956374 Duplicate code removal REmoved proc finp_val_fss_closed
  -- Validate the IGS_FI_F_TYP_CA_INST s_chg_method_type.
  FUNCTION finp_val_ftci_c_mthd(
  p_fee_type IN VARCHAR ,
  p_chg_method IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftci_c_mthd,WNDS);
  --
  -- Validate the IGS_FI_F_TYP_CA_INST date aliases
  FUNCTION finp_val_ftci_dates(
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
PRAGMA RESTRICT_REFERENCES(finp_val_ftci_dates,WNDS);
  --
  -- Validate the IGS_FI_F_TYP_CA_INST required data
  FUNCTION finp_val_ftci_rqrd(
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_fee_type IN VARCHAR2 ,
  p_old_chg_method IN VARCHAR2 ,
  p_old_rule_sequence IN NUMBER ,
  p_chg_method IN VARCHAR2 ,
  p_rule_sequence IN NUMBER ,
  p_fee_type_ci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftci_rqrd,WNDS);
  --
  -- Validate the IGS_FI_F_TYP_CA_INST status
  FUNCTION finp_val_ftci_status(
  p_fee_type IN VARCHAR2 ,
  p_fee_cal_type IN VARCHAR2 ,
  p_fee_ci_sequence_number IN NUMBER ,
  p_new_ftci_status IN VARCHAR2 ,
  p_old_ftci_status IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(finp_val_ftci_status,WNDS);
  --
  -- Validate the IGS_FI_FEE_TYPE in the fee_type_account is not closed.
  -- bug 1956374 Removed finp_val_ft_closed duplicate code msrinivi
  -- Validate PAYMENT HIERARCHY RAN
  -- As part of bugfix#2425767,removed function finp_val_ftci_rank.
END IGS_FI_VAL_FTCI;

 

/
