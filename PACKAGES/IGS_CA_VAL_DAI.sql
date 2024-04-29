--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAI
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAI" AUTHID CURRENT_USER AS
/* $Header: IGSCA07S.pls 115.3 2002/11/28 22:57:50 nsidana ship $ */
  -- Validate calendar category is HOLIDAY.
  FUNCTION calp_val_holiday_cat(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_holiday_cat, WNDS);
--
  -- To validate the insert of a IGS_CA_DA_INST record
  FUNCTION calp_val_dai_upd(
  p_dt_alias IN VARCHAR2 ,
  p_sequence_number IN NUMBER DEFAULT NULL,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER DEFAULT NULL,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  --
  -- Validate the dt_alias of the IGS_CA_DA_INST
  FUNCTION CALP_VAL_DAI_DA(
  p_dt_alias IN VARCHAR2 ,
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN boolean;
PRAGMA RESTRICT_REFERENCES(CALP_VAL_DAI_DA, WNDS);
END IGS_CA_VAL_DAI;

 

/
