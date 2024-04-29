--------------------------------------------------------
--  DDL for Package IGS_CA_INS_ROLL_CI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_INS_ROLL_CI" AUTHID CURRENT_USER AS
/* $Header: IGSCA03S.pls 120.0 2005/06/01 22:33:38 appldev noship $ */
-- Bug No 1956374  ,  Procedure admp_val_apcood_da reference is changed
  -- To insert a date alias instance pair as part of the rollover process
  FUNCTION calp_ins_rollvr_daip(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_val_dt_alias IN VARCHAR2 ,
  p_val_dai_sequence_number IN NUMBER ,
  p_val_cal_type IN VARCHAR2 ,
  p_val_ci_sequence_number IN NUMBER ,
  p_daip_related IN boolean ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- To insert a dt alias inst offset constraint as part of the rollover.
  FUNCTION calp_ins_roll_daioc(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_offset_cal_type IN VARCHAR2 ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_new_dt_alias IN VARCHAR2 ,
  p_new_dai_sequence_number IN NUMBER ,
  p_new_cal_type IN VARCHAR2 ,
  p_new_ci_sequence_number IN NUMBER ,
  p_new_offset_dt_alias IN VARCHAR2 ,
  p_new_offset_dai_seq_number IN NUMBER ,
  p_new_offset_cal_type IN VARCHAR2 ,
  p_new_offset_ci_seq_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --



--
  -- Validate adm perd date override should be included in rollover.
  FUNCTION calp_val_apcood_roll(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_apcood_roll, WNDS);
--
  -- To insert a date alias instance offset as part of the rollover process
  FUNCTION calp_ins_rollvr_daio(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_val_dt_alias IN VARCHAR2 ,
  p_val_dai_sequence_number IN NUMBER ,
  p_val_cal_type IN VARCHAR2 ,
  p_val_ci_sequence_number IN NUMBER ,
  p_daio_offset IN boolean ,
  p_day_offset IN NUMBER ,
  p_week_offset IN NUMBER ,
  p_month_offset IN NUMBER ,
  p_year_offset IN NUMBER,
  p_ofst_override IN VARCHAR2,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_old_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- To insert a date alias instance as part of the rollover process
  FUNCTION calp_ins_rollvr_dai(
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_rollover_cal_type IN VARCHAR2 ,
  p_rollover_ci_sequence_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- To insert a ci relationship as part of the rollover process..
  FUNCTION CALP_INS_ROLLVR_CIR(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_ci_sequence_number  NUMBER ,
  p_sup_cal_type IN VARCHAR2 ,
  p_sup_ci_sequence_number IN NUMBER ,
  p_ci_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
  --
  -- To insert a calendar instance as part of the rollover process
  FUNCTION calp_ins_rollvr_ci(
  p_cal_type IN VARCHAR2 ,
  p_sequence_number IN NUMBER ,
  p_diff_days IN NUMBER ,
  p_diff_months IN NUMBER ,
  p_rollover_cal_type IN VARCHAR2 ,
  p_rollover_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;

FUNCTION chk_and_roll_ret(
  p_old_ca_type IN VARCHAR2,
  p_old_ci_seq_num IN NUMBER,
  p_old_da_alias IN VARCHAR2,
  p_old_dai_seq_num IN NUMBER,
  p_new_ci_seq_num IN NUMBER)
RETURN BOOLEAN;

gv_log_type		IGS_GE_S_LOG_ENTRY.s_log_type%TYPE;
gv_log_creation_dt	IGS_GE_S_LOG_ENTRY.creation_dt%TYPE;
gv_log_key		IGS_GE_S_LOG_ENTRY.key%TYPE;
gv_cal_count		NUMBER := 0;
END IGS_CA_INS_ROLL_CI;

 

/
