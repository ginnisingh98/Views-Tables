--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAIP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAIP" AUTHID CURRENT_USER AS
/* $Header: IGSCA10S.pls 115.3 2002/11/28 22:58:34 nsidana ship $ */
  -- Validate dt alias instance pair related value.
  FUNCTION calp_val_daip_value(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_daip_value, WNDS);
--
  -- Validate dt alias instance pair calendar type.
  FUNCTION calp_val_daip_ct(
  p_cal_type IN VARCHAR2 ,
  p_related_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_daip_ct, WNDS);
--
  -- Validate dt alias instance pair values are different.
  FUNCTION calp_val_daip_dai(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(calp_val_daip_dai, WNDS);
 --
  -- Validate only one date alias instance pair exists.
  FUNCTION calp_val_daip_unique(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_related_dt_alias IN VARCHAR2 ,
  p_related_dai_sequence_number IN NUMBER ,
  p_related_cal_type IN VARCHAR2 ,
  p_related_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(calp_val_daip_unique, WNDS);
END IGS_CA_VAL_DAIP;

 

/
