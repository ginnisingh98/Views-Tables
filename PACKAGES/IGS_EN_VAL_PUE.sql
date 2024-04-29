--------------------------------------------------------
--  DDL for Package IGS_EN_VAL_PUE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_VAL_PUE" AUTHID CURRENT_USER AS
/* $Header: IGSEN58S.pls 115.4 2002/11/29 00:04:36 nsidana ship $ */

  --
  --
--  gt_rowid_table t_pue_rowids;
  --
  --
--  gt_empty_table t_pue_rowids;
  --
  --
--  gv_table_index BINARY_INTEGER;
  --
  -- bug id : 1956374
  -- sjadhav , 28-aug-2001
  -- removed FUNCTION enrp_val_encmb_dt
  -- removed FUNCTION enrp_val_encmb_dts
  --
  -- To validate that expiry date is greater than or equal to start date.

  --
  -- Validate that person doesn't already have an open IGS_PS_UNIT exclusion.
  FUNCTION enrp_val_pue_open(
  p_person_id IN NUMBER ,
  p_encumbrance_type IN VARCHAR2 ,
  p_pen_start_dt IN DATE ,
  p_s_encmb_effect_type IN VARCHAR2 ,
  p_pee_start_dt IN DATE ,
  p_unit_cd IN VARCHAR2 ,
  p_pue_start_dt IN DATE ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_pue_open , WNDS);
  --
  -- Validate if person is enrolled in an exluded IGS_PS_UNIT.
  FUNCTION enrp_val_pue_unit(
  p_person_id IN NUMBER ,
  p_unit_cd IN VARCHAR2 ,
  p_course_cd IN VARCHAR2 ,
  p_message_name OUT NOCOPY VARCHAR2)
RETURN BOOLEAN;
--PRAGMA RESTRICT_REFERENCES( enrp_val_pue_unit , WNDS);
  --
  -- Validate the encumbrance effect table
  --
  -- bug id : 1956374
  -- removed FUNCTION enrp_val_encmb_dts
END IGS_EN_VAL_PUE;

 

/
