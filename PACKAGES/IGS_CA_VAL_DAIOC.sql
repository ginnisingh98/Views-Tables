--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_DAIOC
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_DAIOC" AUTHID CURRENT_USER AS
/* $Header: IGSCA09S.pls 115.3 2002/11/28 22:58:20 nsidana ship $ */
  -- Ensure dt alias instance offset constraints can be created.
  FUNCTION calp_val_daioc_ins(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  --
  -- Validate dt alias offset constraints do not clash.
  FUNCTION calp_val_sdoct_clash(
  p_dt_alias IN VARCHAR2 ,
  p_offset_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_offset_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_offset_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_offset_ci_sequence_number IN NUMBER ,
  p_s_dt_offset_constraint_type IN VARCHAR2 ,
  p_constraint_condition IN VARCHAR2 ,
  p_constraint_resolution IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
 PRAGMA RESTRICT_REFERENCES(calp_val_sdoct_clash, WNDS);
 --
  -- Validate if date alias instance offset constraints exist.
  FUNCTION calp_val_daioc_exist(
  p_dt_alias IN VARCHAR2 ,
  p_dai_sequence_number IN NUMBER ,
  p_cal_type IN VARCHAR2 ,
  p_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_daioc_exist, WNDS);
--
  -- Validate if offset constraint type code is closed.
  FUNCTION calp_val_sdoct_clsd(
  p_s_dt_offset_constraint_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
PRAGMA RESTRICT_REFERENCES(calp_val_sdoct_clsd, WNDS);
END IGS_CA_VAL_DAIOC;

 

/
