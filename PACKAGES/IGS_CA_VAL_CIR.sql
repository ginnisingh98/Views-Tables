--------------------------------------------------------
--  DDL for Package IGS_CA_VAL_CIR
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_VAL_CIR" AUTHID CURRENT_USER AS
/* $Header: IGSCA06S.pls 115.3 2002/11/28 22:57:37 nsidana ship $ */
  -- To validate that the calendar has a IGS_CA_TYPE.s_cal_cat of type 'LOAD'
  FUNCTION calp_val_cat_load(
  p_cal_type IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN;
  PRAGMA RESTRICT_REFERENCES(calp_val_cat_load, WNDS);
--
  -- To validate calendar instanes in a relationship
  FUNCTION calp_val_cir_ci(
  p_sub_cal_type IN VARCHAR2 ,
  p_sub_ci_sequence_number IN NUMBER ,
  p_sup_cal_type IN VARCHAR2 ,
  p_sup_ci_sequence_number IN NUMBER ,
  p_message_name OUT NOCOPY VARCHAR2 )
RETURN boolean;
  PRAGMA RESTRICT_REFERENCES(calp_val_cir_ci, WNDS);
--
  -- To validate calendar instanes categories in a relationship
  FUNCTION calp_val_ci_rltnshp(
  p_sub_cal_cat IN VARCHAR2 ,
  p_sup_cal_cat IN VARCHAR2 )
RETURN VARCHAR2;
PRAGMA RESTRICT_REFERENCES(calp_val_ci_rltnshp, WNDS, WNPS);
END IGS_CA_VAL_CIR;

 

/
